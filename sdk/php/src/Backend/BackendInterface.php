<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Backend;

interface BackendInterface
{
    public function get(string $config, ?string $path = null): mixed;

    /** @return string[] */
    public function listConfigs(): array;

    public function set(string $config, string $key, string $value, string $layer = 'local', bool $noBump = false): void;

    /** @param string[] $keys */
    public function unset(string $config, array $keys, string $layer = 'local', bool $noBump = false): void;

    public function bump(): int;
}
