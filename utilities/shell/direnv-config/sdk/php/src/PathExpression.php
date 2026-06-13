<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

final class PathExpression
{
    /**
     * Set a value at the given path, creating intermediate structures as needed.
     */
    public static function set(mixed &$root, string $path, mixed $value): void
    {
        $segments = self::parse($path);
        if (count($segments) === 0) {
            $root = $value;
            return;
        }

        if ($root === null) {
            $root = [];
        }

        $ref = &$root;

        for ($i = 0; $i < count($segments); $i++) {
            $seg = $segments[$i];
            $isLast = ($i === count($segments) - 1);

            if ($seg->type === SegmentType::Key) {
                if (!is_array($ref)) {
                    $ref = [];
                }
                if ($isLast) {
                    $ref[$seg->value] = $value;
                } else {
                    if (!array_key_exists($seg->value, $ref) || !is_array($ref[$seg->value])) {
                        $ref[$seg->value] = [];
                    }
                    $ref = &$ref[$seg->value];
                }
            } elseif ($seg->type === SegmentType::Index) {
                if (!is_array($ref)) {
                    $ref = [];
                }
                $index = $seg->value;
                $len = count($ref);
                $resolved = $index < 0 ? $len + $index : $index;

                if ($resolved < 0) {
                    throw new Exception\DcException("Negative index {$index} out of bounds for array of length {$len}");
                }

                // Pad with nulls if needed
                while (count($ref) <= $resolved) {
                    $ref[] = null;
                }

                if ($isLast) {
                    $ref[$resolved] = $value;
                } else {
                    if (!is_array($ref[$resolved])) {
                        $ref[$resolved] = [];
                    }
                    $ref = &$ref[$resolved];
                }
            } elseif ($seg->type === SegmentType::Wildcard) {
                throw new Exception\DcException('Cannot use wildcard [*] in set path');
            } elseif ($seg->type === SegmentType::Length) {
                throw new Exception\DcException('Cannot use .length in set path');
            }
        }
    }

    /**
     * Delete the value at the given path. Returns true if found and removed.
     */
    public static function delete(mixed &$root, string $path): bool
    {
        $segments = self::parse($path);
        if (count($segments) === 0) {
            return false;
        }

        if (!is_array($root)) {
            return false;
        }

        // Walk to parent
        $ref = &$root;
        for ($i = 0; $i < count($segments) - 1; $i++) {
            $seg = $segments[$i];

            if ($seg->type === SegmentType::Key) {
                if (!is_array($ref) || array_is_list($ref) || !array_key_exists($seg->value, $ref)) {
                    return false;
                }
                $ref = &$ref[$seg->value];
            } elseif ($seg->type === SegmentType::Index) {
                if (!is_array($ref) || !array_is_list($ref)) {
                    return false;
                }
                $len = count($ref);
                $resolved = $seg->value < 0 ? $len + $seg->value : $seg->value;
                if ($resolved < 0 || $resolved >= $len) {
                    return false;
                }
                $ref = &$ref[$resolved];
            } elseif ($seg->type === SegmentType::Wildcard) {
                throw new Exception\DcException('Cannot use wildcard [*] in delete path');
            } elseif ($seg->type === SegmentType::Length) {
                throw new Exception\DcException('Cannot use .length in delete path');
            }
        }

        $last = $segments[count($segments) - 1];

        if ($last->type === SegmentType::Key) {
            if (!is_array($ref) || array_is_list($ref) || !array_key_exists($last->value, $ref)) {
                return false;
            }
            unset($ref[$last->value]);
            return true;
        } elseif ($last->type === SegmentType::Index) {
            if (!is_array($ref) || !array_is_list($ref)) {
                return false;
            }
            $len = count($ref);
            $resolved = $last->value < 0 ? $len + $last->value : $last->value;
            if ($resolved < 0 || $resolved >= $len) {
                return false;
            }
            array_splice($ref, $resolved, 1);
            return true;
        } elseif ($last->type === SegmentType::Wildcard) {
            throw new Exception\DcException('Cannot use wildcard [*] in delete path');
        } elseif ($last->type === SegmentType::Length) {
            throw new Exception\DcException('Cannot use .length in delete path');
        }

        return false;
    }

    /** @return Segment[] */
    public static function parse(string $path): array
    {
        $segments = [];
        if ($path === '') {
            return $segments;
        }

        $tokens = explode('.', $path);
        foreach ($tokens as $token) {
            if ($token === 'length' && count($segments) > 0) {
                $segments[] = Segment::length();
                continue;
            }

            $bracketPos = strpos($token, '[');
            if ($bracketPos !== false) {
                $keyPart = substr($token, 0, $bracketPos);
                if ($keyPart !== '') {
                    $segments[] = Segment::key($keyPart);
                }

                $rest = substr($token, $bracketPos);
                while (str_contains($rest, '[')) {
                    $open = strpos($rest, '[');
                    $close = strpos($rest, ']');
                    $inner = substr($rest, $open + 1, $close - $open - 1);
                    if ($inner === '*') {
                        $segments[] = Segment::wildcard();
                    } else {
                        $segments[] = Segment::index((int) $inner);
                    }
                    $rest = substr($rest, $close + 1);
                }
            } else {
                $segments[] = Segment::key($token);
            }
        }

        return $segments;
    }

    public static function resolve(mixed $root, string $path): mixed
    {
        $segments = self::parse($path);
        return self::walk($root, $segments);
    }

    /** @param Segment[] $segments */
    private static function walk(mixed $current, array $segments): mixed
    {
        if (count($segments) === 0) {
            return $current;
        }

        $seg = array_shift($segments);

        return match ($seg->type) {
            SegmentType::Key => self::walkKey($current, $seg->value, $segments),
            SegmentType::Index => self::walkIndex($current, $seg->value, $segments),
            SegmentType::Wildcard => self::walkWildcard($current, $segments),
            SegmentType::Length => self::walkLength($current, $segments),
        };
    }

    /** @param Segment[] $rest */
    private static function walkKey(mixed $current, string $key, array $rest): mixed
    {
        if (!is_array($current) || array_is_list($current)) {
            return null;
        }
        if (!array_key_exists($key, $current)) {
            return null;
        }
        return self::walk($current[$key], $rest);
    }

    /** @param Segment[] $rest */
    private static function walkIndex(mixed $current, int $index, array $rest): mixed
    {
        if (!is_array($current) || !array_is_list($current)) {
            return null;
        }
        $len = count($current);
        $resolved = $index < 0 ? $len + $index : $index;
        if ($resolved < 0 || $resolved >= $len) {
            return null;
        }
        return self::walk($current[$resolved], $rest);
    }

    /** @param Segment[] $rest */
    private static function walkWildcard(mixed $current, array $rest): mixed
    {
        if (!is_array($current) || !array_is_list($current)) {
            return null;
        }
        $results = [];
        foreach ($current as $elem) {
            $val = self::walk($elem, $rest);
            if ($val !== null) {
                $results[] = $val;
            }
        }
        return $results;
    }

    /** @param Segment[] $rest */
    private static function walkLength(mixed $current, array $rest): mixed
    {
        if (count($rest) > 0) {
            return null;
        }
        if (is_array($current)) {
            return count($current);
        }
        return null;
    }
}
