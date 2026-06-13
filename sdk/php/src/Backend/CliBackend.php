<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Backend;

use Noizu\DirenvConfig\Exception\DcException;
use Symfony\Component\Yaml\Yaml;

final readonly class CliBackend implements BackendInterface
{
    public function __construct(
        private string $storePath,
        private string $dcBinary = 'dc',
    ) {}

    public function get(string $config, ?string $path = null): mixed
    {
        $args = ['get', $config];
        if ($path !== null && $path !== '') {
            $args[] = $path;
        }
        $args[] = '--raw';

        $output = $this->exec($args);
        return Yaml::parse($output);
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

    public function set(string $config, string $key, string $value, string $layer = 'local', bool $noBump = false): void
    {
        $args = ['set', $config, $key, $value];
        if ($layer !== 'local') {
            $args[] = '--layer';
            $args[] = $layer;
        }
        if ($noBump) {
            $args[] = '--no-bump';
        }
        $this->exec($args);
    }

    /** @param string[] $keys */
    public function unset(string $config, array $keys, string $layer = 'local', bool $noBump = false): void
    {
        $args = ['unset', $config, ...$keys];
        if ($layer !== 'local') {
            $args[] = '--layer';
            $args[] = $layer;
        }
        if ($noBump) {
            $args[] = '--no-bump';
        }
        $this->exec($args);
    }

    public function bump(): int
    {
        $output = $this->exec(['bump']);
        return intval(trim($output));
    }

    private function exec(array $args): string
    {
        $cmd = escapeshellcmd($this->dcBinary);
        foreach ($args as $arg) {
            $cmd .= ' ' . escapeshellarg($arg);
        }

        $descriptors = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        $process = proc_open($cmd, $descriptors, $pipes);
        if (!is_resource($process)) {
            throw new DcException("Failed to execute: {$cmd}");
        }

        fclose($pipes[0]);
        $stdout = stream_get_contents($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        $exitCode = proc_close($process);
        if ($exitCode !== 0) {
            throw new DcException("dc command failed (exit {$exitCode}): {$stderr}");
        }

        return $stdout;
    }
}
