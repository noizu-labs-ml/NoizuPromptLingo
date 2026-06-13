<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Backend;

use Noizu\DirenvConfig\Exception\ConfigNotFoundException;
use Noizu\DirenvConfig\PathExpression;
use Noizu\DirenvConfig\Resolve;
use Noizu\DirenvConfig\Store;
use Noizu\DirenvConfig\Version;
use Symfony\Component\Yaml\Yaml;

final readonly class NativeBackend implements BackendInterface
{
    public function __construct(
        private string $storePath,
    ) {}

    public function get(string $config, ?string $path = null): mixed
    {
        $activePath = $this->storePath . '/' . $config . '/.active';
        if (!file_exists($activePath)) {
            throw new ConfigNotFoundException("Config not found: {$config}");
        }

        $content = file_get_contents($activePath);
        $root = Yaml::parse($content);

        if ($path === null || $path === '') {
            return $root;
        }

        return PathExpression::resolve($root, $path);
    }

    public function set(string $config, string $key, string $value, string $layer = 'local', bool $noBump = false): void
    {
        Store::ensureConfig($this->storePath, $config);

        $layerFile = Store::layerPath($this->storePath, $config, $layer);
        $doc = file_exists($layerFile) ? (Yaml::parse(file_get_contents($layerFile)) ?? []) : [];

        // Parse value: try YAML parse, fall back to raw string
        $parsed = Yaml::parse($value);
        if ($parsed === null && $value !== '' && strtolower($value) !== 'null') {
            $parsed = $value;
        }

        PathExpression::set($doc, $key, $parsed);

        file_put_contents($layerFile, Yaml::dump($doc, 4, 2));
        Resolve::resolveActive($this->storePath, $config);

        if (!$noBump) {
            Version::bump($this->storePath);
        }
    }

    /** @param string[] $keys */
    public function unset(string $config, array $keys, string $layer = 'local', bool $noBump = false): void
    {
        $layerFile = Store::layerPath($this->storePath, $config, $layer);
        if (!file_exists($layerFile)) {
            return;
        }

        $doc = Yaml::parse(file_get_contents($layerFile)) ?? [];

        foreach ($keys as $key) {
            PathExpression::delete($doc, $key);
        }

        file_put_contents($layerFile, Yaml::dump($doc, 4, 2));
        Resolve::resolveActive($this->storePath, $config);

        if (!$noBump) {
            Version::bump($this->storePath);
        }
    }

    public function bump(): int
    {
        return Version::bump($this->storePath);
    }

    /** @return string[] */
    public function listConfigs(): array
    {
        $metaPath = $this->storePath . '/.meta';
        if (!file_exists($metaPath)) {
            return [];
        }

        $content = file_get_contents($metaPath);
        $meta = Yaml::parse($content);

        return $meta['configs'] ?? [];
    }
}
