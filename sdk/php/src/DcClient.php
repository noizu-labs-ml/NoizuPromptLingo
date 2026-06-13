<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

use Noizu\DirenvConfig\Backend\BackendInterface;
use Noizu\DirenvConfig\Backend\CliBackend;
use Noizu\DirenvConfig\Backend\NativeBackend;
use Noizu\DirenvConfig\Exception\DcException;

final class DcClient
{
    private readonly BackendInterface $backend;
    private readonly string $storePath;

    public function __construct(
        string $mode = 'native',
        ?string $directory = null,
        ?string $stateDir = null,
        string $dcBinary = 'dc',
    ) {
        $this->storePath = $stateDir ?? Store::findCurrentStore($directory);

        $this->backend = match ($mode) {
            'cli' => new CliBackend($this->storePath, $dcBinary),
            default => new NativeBackend($this->storePath),
        };
    }

    public function get(string $config, ?string $path = null): mixed
    {
        return $this->backend->get($config, $path);
    }

    public function getOrThrow(string $config, ?string $path = null): mixed
    {
        $result = $this->get($config, $path);
        if ($result === null) {
            $target = $path !== null ? "{$config}.{$path}" : $config;
            throw new DcException("Value not found: {$target}");
        }
        return $result;
    }

    public function getString(string $config, string $path): ?string
    {
        $result = $this->get($config, $path);
        if ($result === null) {
            return null;
        }
        return (string) $result;
    }

    public function getInt(string $config, string $path): ?int
    {
        $result = $this->get($config, $path);
        if ($result === null) {
            return null;
        }
        if (is_numeric($result)) {
            return (int) $result;
        }
        return null;
    }

    public function getBool(string $config, string $path): ?bool
    {
        $result = $this->get($config, $path);
        if ($result === null) {
            return null;
        }
        if (is_bool($result)) {
            return $result;
        }
        if ($result === 'true') {
            return true;
        }
        if ($result === 'false') {
            return false;
        }
        return null;
    }

    /** @return string[] */
    public function listConfigs(): array
    {
        return $this->backend->listConfigs();
    }

    public function set(string $config, string $key, string $value, string $layer = 'local', bool $noBump = false): void
    {
        $this->backend->set($config, $key, $value, $layer, $noBump);
    }

    /** @param string[] $keys */
    public function unset(string $config, array $keys, string $layer = 'local', bool $noBump = false): void
    {
        $this->backend->unset($config, $keys, $layer, $noBump);
    }

    public function bump(): int
    {
        return $this->backend->bump();
    }

    public function version(): int
    {
        return Version::read($this->storePath);
    }

    public function hasChanged(int $since): bool
    {
        return $this->version() !== $since;
    }
}
