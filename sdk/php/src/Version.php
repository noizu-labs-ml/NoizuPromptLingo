<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

final class Version
{
    private int $lastVersion = -1;

    public function __construct(
        private readonly string $storePath,
    ) {}

    public static function read(string $storePath): int
    {
        $file = $storePath . '/.version';
        if (!file_exists($file)) {
            return 0;
        }
        $content = file_get_contents($file);
        if ($content === false) {
            return 0;
        }
        return intval(trim($content));
    }

    /**
     * Atomically increment the version and return the new value.
     */
    public static function bump(string $storePath): int
    {
        $current = self::read($storePath);
        $next = $current + 1;

        $file = $storePath . '/.version';
        $tmp = $storePath . '/.version.tmp';
        file_put_contents($tmp, (string) $next);
        rename($tmp, $file);

        return $next;
    }

    public function poll(): ?int
    {
        $current = self::read($this->storePath);
        if ($current !== $this->lastVersion) {
            $this->lastVersion = $current;
            return $current;
        }
        return null;
    }

    public function run(callable $callback, int $intervalMs = 1000): void
    {
        while (true) {
            $version = $this->poll();
            if ($version !== null) {
                $callback($version);
            }
            usleep($intervalMs * 1000);
        }
    }
}
