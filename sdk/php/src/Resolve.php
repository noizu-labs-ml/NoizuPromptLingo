<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

use Symfony\Component\Yaml\Yaml;

final class Resolve
{
    /**
     * Merge layer files and write the resolved .active file.
     *
     * Layer order: base.yaml → {DC_ENV}.yaml → local.yaml → secrets.yaml
     */
    public static function resolveActive(string $storePath, string $name): mixed
    {
        $configDir = $storePath . '/' . $name;
        $env = getenv('DC_ENV') ?: 'dev';

        $layerFiles = [
            $configDir . '/base.yaml',
            $configDir . '/' . $env . '.yaml',
            $configDir . '/local.yaml',
            $configDir . '/secrets.yaml',
        ];

        $layers = [];
        foreach ($layerFiles as $file) {
            if (file_exists($file)) {
                $content = file_get_contents($file);
                $parsed = Yaml::parse($content);
                if ($parsed !== null) {
                    $layers[] = $parsed;
                }
            }
        }

        $merged = count($layers) > 0 ? Merge::deepMergeMulti($layers) : [];

        // Ensure config dir exists
        if (!is_dir($configDir)) {
            mkdir($configDir, 0755, true);
        }

        $activePath = $configDir . '/.active';
        file_put_contents($activePath, Yaml::dump($merged, 4, 2));

        return $merged;
    }
}
