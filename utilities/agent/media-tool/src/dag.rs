use std::collections::{HashMap, VecDeque};

use crate::schema::ParsedPrompt;

pub fn topological_sort(prompts: Vec<ParsedPrompt>) -> color_eyre::Result<Vec<ParsedPrompt>> {
    if prompts.len() <= 1 {
        return Ok(prompts);
    }

    let mut by_id: HashMap<String, usize> = HashMap::new();
    let mut by_path: HashMap<String, usize> = HashMap::new();

    for (i, p) in prompts.iter().enumerate() {
        let id = &p.meta.id;
        if by_id.contains_key(id) {
            let other = &prompts[by_id[id]];
            color_eyre::eyre::bail!(
                "Duplicate prompt ID: {}\n  {}\n  {}",
                id,
                other.meta.path.display(),
                p.meta.path.display()
            );
        }
        by_id.insert(id.clone(), i);
        by_path.insert(p.meta.path.to_string_lossy().into_owned(), i);
    }

    let n = prompts.len();
    let mut adj: Vec<Vec<usize>> = vec![vec![]; n];
    let mut in_degree: Vec<usize> = vec![0; n];

    for (i, p) in prompts.iter().enumerate() {
        for dep in &p.payload.depends_on {
            let ref_str = dep.ref_id();
            let resolved = if let Some(&idx) = by_id.get(ref_str) {
                idx
            } else {
                let abs_ref = p.meta.output_dir.join(ref_str);
                let abs_str = abs_ref.to_string_lossy().into_owned();
                if let Some(&idx) = by_path.get(&abs_str) {
                    idx
                } else {
                    color_eyre::eyre::bail!(
                        "Unresolved dependency '{}' in {}\n  Known IDs: {}",
                        ref_str,
                        p.meta.path.display(),
                        by_id.keys().cloned().collect::<Vec<_>>().join(", ")
                    );
                }
            };

            if resolved == i {
                color_eyre::eyre::bail!(
                    "Self-referencing dependency in {}",
                    p.meta.path.display()
                );
            }

            adj[resolved].push(i);
            in_degree[i] += 1;
        }
    }

    let mut queue: VecDeque<usize> = VecDeque::new();
    for (i, &deg) in in_degree.iter().enumerate() {
        if deg == 0 {
            queue.push_back(i);
        }
    }

    let mut sorted_indices: Vec<usize> = Vec::with_capacity(n);
    while let Some(current) = queue.pop_front() {
        sorted_indices.push(current);
        for &neighbor in &adj[current] {
            in_degree[neighbor] -= 1;
            if in_degree[neighbor] == 0 {
                queue.push_back(neighbor);
            }
        }
    }

    if sorted_indices.len() != n {
        let remaining: Vec<&str> = prompts
            .iter()
            .enumerate()
            .filter(|(i, _)| !sorted_indices.contains(i))
            .map(|(_, p)| p.meta.id.as_str())
            .collect();
        color_eyre::eyre::bail!("Dependency cycle detected involving: {}", remaining.join(", "));
    }

    let mut prompts = prompts;
    let mut result = Vec::with_capacity(n);
    // Build in reverse to pop efficiently
    let mut slots: Vec<Option<ParsedPrompt>> = prompts.drain(..).map(Some).collect();
    for idx in sorted_indices {
        result.push(slots[idx].take().unwrap());
    }

    Ok(result)
}
