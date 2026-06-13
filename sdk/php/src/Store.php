<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

use Noizu\DirenvConfig\Exception\StoreNotFoundException;

final class Store
{
    public static function stateDir(): string
    {
        $xdg = $_ENV['XDG_STATE_HOME'] ?? getenv('XDG_STATE_HOME');
        if ($xdg && $xdg !== '') {
            return $xdg . '/direnv-config';
        }
        $home = $_ENV['HOME'] ?? getenv('HOME') ?: (PHP_OS_FAMILY === 'Windows' ? $_ENV['USERPROFILE'] ?? getenv('USERPROFILE') : '');
        return $home . '/.local/state/direnv-config';
    }

    public static function pathToHash(string $dir): string
    {
        $stripped = str_starts_with($dir, '/') ? substr($dir, 1) : $dir;
        $name = str_replace('/', '-', $stripped);

        if (strlen($name) <= 200) {
            return $name;
        }

        $hash = hash('sha256', $dir);
        return substr($name, 0, 200) . '-' . substr($hash, 0, 8);
    }

    public static function storePath(string $dir): string
    {
        return self::stateDir() . '/' . self::pathToHash($dir);
    }

    /**
     * Ensure the store directory exists and has a .meta file.
     */
    public static function ensureStore(string $directory): string
    {
        $sp = self::storePath($directory);
        if (!is_dir($sp)) {
            mkdir($sp, 0755, true);
        }

        $metaPath = $sp . '/.meta';
        if (!file_exists($metaPath)) {
            $meta = [
                'source' => $directory,
                'created' => date('c'),
                'configs' => [],
            ];
            file_put_contents($metaPath, \Symfony\Component\Yaml\Yaml::dump($meta, 4, 2));
        }

        return $sp;
    }

    /**
     * Ensure a config subdirectory exists within the store.
     */
    public static function ensureConfig(string $store, string $name): string
    {
        $configDir = $store . '/' . $name;
        if (!is_dir($configDir)) {
            mkdir($configDir, 0755, true);
        }
        return $configDir;
    }

    /**
     * Return the path for a specific layer file.
     */
    public static function layerPath(string $store, string $name, string $layer): string
    {
        return $store . '/' . $name . '/' . $layer . '.yaml';
    }

    /**
     * Return the path for the .active file.
     */
    public static function activePath(string $store, string $name): string
    {
        return $store . '/' . $name . '/.active';
    }

    public static function findCurrentStore(?string $startDir = null): string
    {
        $dir = $startDir ?? getcwd();

        while (true) {
            $sp = self::storePath($dir);
            if (is_dir($sp)) {
                return $sp;
            }

            $parent = dirname($dir);
            if ($parent === $dir) {
                break;
            }
            $dir = $parent;
        }

        throw new StoreNotFoundException(
            'No store found for ' . ($startDir ?? getcwd()) . ' (searched all parent directories). Run `dc init` first.'
        );
    }
}
