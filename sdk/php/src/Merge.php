<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

final class Merge
{
    /**
     * Deep-merge two values. Maps merge recursively; lists/scalars: overlay wins.
     */
    public static function deepMerge(mixed $base, mixed $overlay): mixed
    {
        $result = self::mergeInner($base, $overlay);
        return self::stripTombstones($result);
    }

    /**
     * Deep-merge multiple layers in order (first = lowest priority).
     *
     * @param mixed[] $layers
     */
    public static function deepMergeMulti(array $layers): mixed
    {
        if (count($layers) === 0) {
            return null;
        }

        $result = $layers[0];
        for ($i = 1; $i < count($layers); $i++) {
            $result = self::mergeInner($result, $layers[$i]);
        }

        return self::stripTombstones($result);
    }

    private static function mergeInner(mixed $base, mixed $overlay): mixed
    {
        if (!self::isMap($base) || !self::isMap($overlay)) {
            return $overlay;
        }

        $result = $base;
        foreach ($overlay as $key => $value) {
            if (array_key_exists($key, $result) && self::isMap($result[$key]) && self::isMap($value)) {
                $result[$key] = self::mergeInner($result[$key], $value);
            } else {
                $result[$key] = $value;
            }
        }

        return $result;
    }

    private static function stripTombstones(mixed $val): mixed
    {
        if (!is_array($val)) {
            return $val;
        }

        // Check for tombstone marker
        if (self::isMap($val) && isset($val['_dc_pruned']) && $val['_dc_pruned'] === true) {
            return null;
        }

        if (self::isMap($val)) {
            $result = [];
            foreach ($val as $key => $item) {
                $stripped = self::stripTombstones($item);
                if ($stripped !== null) {
                    $result[$key] = $stripped;
                }
            }
            return $result;
        }

        // List
        $result = [];
        foreach ($val as $item) {
            $result[] = self::stripTombstones($item);
        }
        return $result;
    }

    private static function isMap(mixed $val): bool
    {
        return is_array($val) && !array_is_list($val);
    }
}
