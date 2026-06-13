<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Version;
use PHPUnit\Framework\TestCase;

final class VersionTest extends TestCase
{
    private string $tmpDir;

    protected function setUp(): void
    {
        $this->tmpDir = sys_get_temp_dir() . '/dc-version-test-' . uniqid();
        mkdir($this->tmpDir, 0755, true);
    }

    protected function tearDown(): void
    {
        if (is_dir($this->tmpDir)) {
            exec('rm -rf ' . escapeshellarg($this->tmpDir));
        }
    }

    public function testBumpFromZeroReturnsOne(): void
    {
        // No .version file exists yet — read returns 0
        $this->assertSame(0, Version::read($this->tmpDir));

        $next = Version::bump($this->tmpDir);
        $this->assertSame(1, $next);
        $this->assertSame(1, Version::read($this->tmpDir));
    }

    public function testBumpIncrementsExisting(): void
    {
        file_put_contents($this->tmpDir . '/.version', '5');
        $this->assertSame(5, Version::read($this->tmpDir));

        $next = Version::bump($this->tmpDir);
        $this->assertSame(6, $next);
        $this->assertSame(6, Version::read($this->tmpDir));
    }

    public function testSequentialBumps(): void
    {
        $v1 = Version::bump($this->tmpDir);
        $v2 = Version::bump($this->tmpDir);
        $v3 = Version::bump($this->tmpDir);

        $this->assertSame(1, $v1);
        $this->assertSame(2, $v2);
        $this->assertSame(3, $v3);
        $this->assertSame(3, Version::read($this->tmpDir));
    }
}
