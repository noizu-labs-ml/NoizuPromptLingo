use anyhow::{anyhow, Result};
use serde_yaml::Value;

// ---------------------------------------------------------------------------
// Path parsing
// ---------------------------------------------------------------------------

/// A single segment in a parsed path expression.
#[derive(Debug, Clone, PartialEq)]
enum Segment {
    /// A plain map key, e.g. `name`
    Key(String),
    /// An integer index into a sequence, e.g. `[2]` or `[-1]`
    Index(i64),
    /// Wildcard index `[*]` — iterates all elements
    Wildcard,
    /// The `.length` pseudo-property
    Length,
}

/// Parse a dot-separated path string into segments.
///
/// Examples:
/// - `name`             → [Key("name")]
/// - `a.b.c`            → [Key("a"), Key("b"), Key("c")]
/// - `a[0].b`           → [Key("a"), Index(0), Key("b")]
/// - `a[-1]`            → [Key("a"), Index(-1)]
/// - `a[*].host`        → [Key("a"), Wildcard, Key("host")]
/// - `items.length`     → [Key("items"), Length]
fn parse_path(path: &str) -> Vec<Segment> {
    let mut segments = Vec::new();
    if path.is_empty() {
        return segments;
    }

    // Split on `.` but we need to handle `[...]` within dot-separated tokens.
    for token in path.split('.') {
        if token == "length" && !segments.is_empty() {
            segments.push(Segment::Length);
            continue;
        }

        // A token might be `foo[2]` or `foo[*]` or `[3]` or just `foo`.
        if let Some(bracket_pos) = token.find('[') {
            // Part before the bracket is a key (if non-empty).
            let key_part = &token[..bracket_pos];
            if !key_part.is_empty() {
                segments.push(Segment::Key(key_part.to_string()));
            }

            // Parse bracket expressions — there could be chained ones like `[0][1]`.
            let mut rest = &token[bracket_pos..];
            while let Some(open) = rest.find('[') {
                let close = rest.find(']').expect("unmatched bracket in path");
                let inner = &rest[open + 1..close];
                if inner == "*" {
                    segments.push(Segment::Wildcard);
                } else {
                    let idx: i64 = inner.parse().expect("non-integer index in path");
                    segments.push(Segment::Index(idx));
                }
                rest = &rest[close + 1..];
            }
        } else {
            segments.push(Segment::Key(token.to_string()));
        }
    }

    segments
}

// ---------------------------------------------------------------------------
// get_path
// ---------------------------------------------------------------------------

/// Resolve a path expression against a YAML Value tree.
/// Returns the found value (cloned), or `None` if any segment fails to resolve.
pub fn get_path(root: &Value, path: &str) -> Option<Value> {
    let segments = parse_path(path);
    get_segments(root, &segments)
}

fn get_segments(current: &Value, segments: &[Segment]) -> Option<Value> {
    if segments.is_empty() {
        return Some(current.clone());
    }

    let seg = &segments[0];
    let rest = &segments[1..];

    match seg {
        Segment::Key(key) => {
            let map = current.as_mapping()?;
            let child = map.get(Value::String(key.clone()))?;
            get_segments(child, rest)
        }
        Segment::Index(idx) => {
            let seq = current.as_sequence()?;
            let resolved = resolve_index(*idx, seq.len())?;
            get_segments(&seq[resolved], rest)
        }
        Segment::Wildcard => {
            let seq = current.as_sequence()?;
            let collected: Vec<Value> = seq
                .iter()
                .filter_map(|elem| get_segments(elem, rest))
                .collect();
            Some(Value::Sequence(collected))
        }
        Segment::Length => {
            if !rest.is_empty() {
                return None; // length must be terminal
            }
            let len = match current {
                Value::Sequence(s) => s.len(),
                Value::Mapping(m) => m.len(),
                _ => return None,
            };
            Some(Value::Number(serde_yaml::Number::from(len as u64)))
        }
    }
}

/// Resolve a possibly-negative index into a concrete usize.
fn resolve_index(idx: i64, len: usize) -> Option<usize> {
    let resolved = if idx < 0 {
        len as i64 + idx
    } else {
        idx
    };
    if resolved < 0 || (resolved as usize) >= len {
        None
    } else {
        Some(resolved as usize)
    }
}

// ---------------------------------------------------------------------------
// set_path
// ---------------------------------------------------------------------------

/// Set a value at the given path, creating intermediate maps and sequences as needed.
pub fn set_path(root: &mut Value, path: &str, value: Value) -> Result<()> {
    let segments = parse_path(path);
    if segments.is_empty() {
        return Err(anyhow!("empty path"));
    }
    set_segments(root, &segments, value)
}

fn set_segments(current: &mut Value, segments: &[Segment], value: Value) -> Result<()> {
    if segments.is_empty() {
        return Err(anyhow!("empty segments (internal)"));
    }

    let seg = &segments[0];
    let rest = &segments[1..];

    match seg {
        Segment::Key(key) => {
            // Ensure current is a mapping.
            if !current.is_mapping() {
                *current = Value::Mapping(serde_yaml::Mapping::new());
            }
            let map = current.as_mapping_mut().unwrap();
            let yaml_key = Value::String(key.clone());

            if rest.is_empty() {
                map.insert(yaml_key, value);
                Ok(())
            } else {
                // Ensure child exists.
                if !map.contains_key(&yaml_key) {
                    // Peek at next segment to decide whether to create a map or a sequence.
                    let placeholder = next_segment_placeholder(&rest[0]);
                    map.insert(yaml_key.clone(), placeholder);
                }
                let child = map.get_mut(&yaml_key).unwrap();
                set_segments(child, rest, value)
            }
        }
        Segment::Index(idx) => {
            // Ensure current is a sequence.
            if !current.is_sequence() {
                *current = Value::Sequence(Vec::new());
            }
            let seq = current.as_sequence_mut().unwrap();

            // Extend with nulls if index is beyond current length.
            let resolved = if *idx < 0 {
                let r = seq.len() as i64 + *idx;
                if r < 0 {
                    return Err(anyhow!("negative index {} out of range for len {}", idx, seq.len()));
                }
                r as usize
            } else {
                let r = *idx as usize;
                while seq.len() <= r {
                    seq.push(Value::Null);
                }
                r
            };

            if resolved >= seq.len() {
                return Err(anyhow!("index {} out of range for len {}", idx, seq.len()));
            }

            if rest.is_empty() {
                seq[resolved] = value;
                Ok(())
            } else {
                set_segments(&mut seq[resolved], rest, value)
            }
        }
        Segment::Wildcard => {
            Err(anyhow!("wildcard [*] is not supported in set_path"))
        }
        Segment::Length => {
            Err(anyhow!(".length is not supported in set_path"))
        }
    }
}

fn next_segment_placeholder(seg: &Segment) -> Value {
    match seg {
        Segment::Index(_) | Segment::Wildcard => Value::Sequence(Vec::new()),
        _ => Value::Mapping(serde_yaml::Mapping::new()),
    }
}

// ---------------------------------------------------------------------------
// delete_path
// ---------------------------------------------------------------------------

/// Delete the value at the given path. Returns `true` if the key was found and removed.
pub fn delete_path(root: &mut Value, path: &str) -> bool {
    let segments = parse_path(path);
    if segments.is_empty() {
        return false;
    }
    delete_segments(root, &segments)
}

fn delete_segments(current: &mut Value, segments: &[Segment]) -> bool {
    if segments.is_empty() {
        return false;
    }

    let seg = &segments[0];
    let rest = &segments[1..];

    match seg {
        Segment::Key(key) => {
            let map = match current.as_mapping_mut() {
                Some(m) => m,
                None => return false,
            };
            let yaml_key = Value::String(key.clone());

            if rest.is_empty() {
                map.remove(&yaml_key).is_some()
            } else {
                match map.get_mut(&yaml_key) {
                    Some(child) => delete_segments(child, rest),
                    None => false,
                }
            }
        }
        Segment::Index(idx) => {
            let seq = match current.as_sequence_mut() {
                Some(s) => s,
                None => return false,
            };
            let resolved = match resolve_index(*idx, seq.len()) {
                Some(r) => r,
                None => return false,
            };

            if rest.is_empty() {
                seq.remove(resolved);
                true
            } else {
                delete_segments(&mut seq[resolved], rest)
            }
        }
        _ => false,
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;
    use serde_yaml::Value;

    fn yaml(s: &str) -> Value {
        serde_yaml::from_str(s).unwrap()
    }

    // -- parse_path ---------------------------------------------------------

    #[test]
    fn parse_simple_key() {
        assert_eq!(parse_path("name"), vec![Segment::Key("name".into())]);
    }

    #[test]
    fn parse_dotted() {
        assert_eq!(
            parse_path("a.b.c"),
            vec![
                Segment::Key("a".into()),
                Segment::Key("b".into()),
                Segment::Key("c".into()),
            ]
        );
    }

    #[test]
    fn parse_index() {
        assert_eq!(
            parse_path("items[0]"),
            vec![Segment::Key("items".into()), Segment::Index(0)]
        );
    }

    #[test]
    fn parse_negative_index() {
        assert_eq!(
            parse_path("items[-1]"),
            vec![Segment::Key("items".into()), Segment::Index(-1)]
        );
    }

    #[test]
    fn parse_wildcard() {
        assert_eq!(
            parse_path("endpoints[*].host"),
            vec![
                Segment::Key("endpoints".into()),
                Segment::Wildcard,
                Segment::Key("host".into()),
            ]
        );
    }

    #[test]
    fn parse_length() {
        assert_eq!(
            parse_path("items.length"),
            vec![Segment::Key("items".into()), Segment::Length]
        );
    }

    #[test]
    fn parse_mixed() {
        assert_eq!(
            parse_path("folder[5].person.mobile"),
            vec![
                Segment::Key("folder".into()),
                Segment::Index(5),
                Segment::Key("person".into()),
                Segment::Key("mobile".into()),
            ]
        );
    }

    // -- get_path -----------------------------------------------------------

    #[test]
    fn get_simple_key() {
        let v = yaml("name: alice");
        assert_eq!(get_path(&v, "name"), Some(Value::String("alice".into())));
    }

    #[test]
    fn get_nested_dot() {
        let v = yaml("db:\n  host: localhost\n  port: 5432");
        assert_eq!(get_path(&v, "db.host"), Some(Value::String("localhost".into())));
        assert_eq!(get_path(&v, "db.port"), Some(yaml("5432")));
    }

    #[test]
    fn get_missing_key() {
        let v = yaml("a: 1");
        assert_eq!(get_path(&v, "b"), None);
    }

    #[test]
    fn get_array_index() {
        let v = yaml("items:\n  - alpha\n  - beta\n  - gamma");
        assert_eq!(get_path(&v, "items[0]"), Some(Value::String("alpha".into())));
        assert_eq!(get_path(&v, "items[2]"), Some(Value::String("gamma".into())));
    }

    #[test]
    fn get_negative_index() {
        let v = yaml("items:\n  - alpha\n  - beta\n  - gamma");
        assert_eq!(get_path(&v, "items[-1]"), Some(Value::String("gamma".into())));
        assert_eq!(get_path(&v, "items[-2]"), Some(Value::String("beta".into())));
    }

    #[test]
    fn get_out_of_bounds() {
        let v = yaml("items:\n  - a");
        assert_eq!(get_path(&v, "items[5]"), None);
        assert_eq!(get_path(&v, "items[-5]"), None);
    }

    #[test]
    fn get_length_sequence() {
        let v = yaml("items:\n  - a\n  - b\n  - c");
        let len = get_path(&v, "items.length").unwrap();
        assert_eq!(len, Value::Number(serde_yaml::Number::from(3u64)));
    }

    #[test]
    fn get_length_map() {
        let v = yaml("m:\n  a: 1\n  b: 2");
        let len = get_path(&v, "m.length").unwrap();
        assert_eq!(len, Value::Number(serde_yaml::Number::from(2u64)));
    }

    #[test]
    fn get_wildcard() {
        let v = yaml(
            r#"
            endpoints:
              - host: a.com
                port: 80
              - host: b.com
                port: 443
            "#,
        );
        let result = get_path(&v, "endpoints[*].host").unwrap();
        let seq = result.as_sequence().unwrap();
        assert_eq!(seq.len(), 2);
        assert_eq!(seq[0], Value::String("a.com".into()));
        assert_eq!(seq[1], Value::String("b.com".into()));
    }

    #[test]
    fn get_mixed_map_array() {
        let v = yaml(
            r#"
            folder:
              - name: zero
              - name: one
              - name: two
              - name: three
              - name: four
              - person:
                  mobile: "555-1234"
            "#,
        );
        assert_eq!(
            get_path(&v, "folder[5].person.mobile"),
            Some(Value::String("555-1234".into()))
        );
    }

    // -- set_path -----------------------------------------------------------

    #[test]
    fn set_simple() {
        let mut v = yaml("a: 1");
        set_path(&mut v, "a", Value::String("hello".into())).unwrap();
        assert_eq!(v["a"], Value::String("hello".into()));
    }

    #[test]
    fn set_nested_creates_intermediate() {
        let mut v = Value::Mapping(serde_yaml::Mapping::new());
        set_path(&mut v, "a.b.c", yaml("42")).unwrap();
        assert_eq!(get_path(&v, "a.b.c"), Some(yaml("42")));
    }

    #[test]
    fn set_array_index() {
        let mut v = yaml("items:\n  - a\n  - b\n  - c");
        set_path(&mut v, "items[1]", Value::String("B".into())).unwrap();
        assert_eq!(get_path(&v, "items[1]"), Some(Value::String("B".into())));
    }

    #[test]
    fn set_extends_array() {
        let mut v = yaml("items:\n  - a");
        set_path(&mut v, "items[3]", Value::String("d".into())).unwrap();
        let seq = v["items"].as_sequence().unwrap();
        assert_eq!(seq.len(), 4);
        assert_eq!(seq[3], Value::String("d".into()));
        assert!(seq[1].is_null());
    }

    #[test]
    fn set_creates_array_for_index_segment() {
        let mut v = Value::Mapping(serde_yaml::Mapping::new());
        set_path(&mut v, "list[0].name", Value::String("first".into())).unwrap();
        assert_eq!(get_path(&v, "list[0].name"), Some(Value::String("first".into())));
    }

    // -- delete_path --------------------------------------------------------

    #[test]
    fn delete_existing_key() {
        let mut v = yaml("a: 1\nb: 2");
        assert!(delete_path(&mut v, "a"));
        assert!(v["a"].is_null());
        assert_eq!(v["b"], yaml("2"));
    }

    #[test]
    fn delete_nested_key() {
        let mut v = yaml("top:\n  child: 1\n  other: 2");
        assert!(delete_path(&mut v, "top.child"));
        assert!(get_path(&v, "top.child").is_none());
        assert_eq!(get_path(&v, "top.other"), Some(yaml("2")));
    }

    #[test]
    fn delete_array_element() {
        let mut v = yaml("items:\n  - a\n  - b\n  - c");
        assert!(delete_path(&mut v, "items[1]"));
        let seq = v["items"].as_sequence().unwrap();
        assert_eq!(seq.len(), 2);
        assert_eq!(seq[0], Value::String("a".into()));
        assert_eq!(seq[1], Value::String("c".into()));
    }

    #[test]
    fn delete_missing_returns_false() {
        let mut v = yaml("a: 1");
        assert!(!delete_path(&mut v, "nonexistent"));
        assert!(!delete_path(&mut v, "a.b.c"));
    }
}
