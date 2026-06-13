<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Resolve;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Yaml\Yaml;

final class ResolveTest extends TestCase
{
    private string $tmpDir;

    protected function setUp(): void
    {
        $this->tmpDir = sys_get_temp_dir() . '/dc-resolve-test-' . uniqid();
        mkdir($this->tmpDir, 0755, true);
    }

    protected function tearDown(): void
    {
        // Clean up DC_ENV if set
        putenv('DC_ENV');

        if (is_dir($this->tmpDir)) {
            exec('rm -rf ' . escapeshellarg($this->tmpDir));
        }
    }

    public function testMergesBaseAndLocalLayers(): void
    {
        $configDir = $this->tmpDir . '/myconfig';
        mkdir($configDir, 0755, true);

        file_put_contents($configDir . '/base.yaml', Yaml::dump(['a' => 1, 'b' => 1]));
        file_put_contents($configDir . '/local.yaml', Yaml::dump(['b' => 2, 'c' => 3]));

        $result = Resolve::resolveActive($this->tmpDir, 'myconfig');

        $this->assertSame(1, $result['a']);
        $this->assertSame(2, $result['b']);
        $this->assertSame(3, $result['c']);
    }

    public function testRespectsDcEnv(): void
    {
        $configDir = $this->tmpDir . '/myconfig';
        mkdir($configDir, 0755, true);

        file_put_contents($configDir . '/base.yaml', Yaml::dump(['env' => 'base']));
        file_put_contents($configDir . '/staging.yaml', Yaml::dump(['env' => 'staging']));

        putenv('DC_ENV=staging');

        $result = Resolve::resolveActive($this->tmpDir, 'myconfig');

        $this->assertSame('staging', $result['env']);
    }

    public function testSkipsMissingLayers(): void
    {
        $configDir = $this->tmpDir . '/myconfig';
        mkdir($configDir, 0755, true);

        // Only base.yaml exists — no dev.yaml, no local.yaml, no secrets.yaml
        file_put_contents($configDir . '/base.yaml', Yaml::dump(['only' => 'base']));

        $result = Resolve::resolveActive($this->tmpDir, 'myconfig');

        $this->assertSame('base', $result['only']);
    }

    public function testWritesActiveFile(): void
    {
        $configDir = $this->tmpDir . '/myconfig';
        mkdir($configDir, 0755, true);

        file_put_contents($configDir . '/base.yaml', Yaml::dump(['x' => 1]));

        Resolve::resolveActive($this->tmpDir, 'myconfig');

        $activePath = $configDir . '/.active';
        $this->assertFileExists($activePath);

        $activeContent = Yaml::parse(file_get_contents($activePath));
        $this->assertSame(1, $activeContent['x']);
    }

    public function testReturnsMergedValue(): void
    {
        $configDir = $this->tmpDir . '/myconfig';
        mkdir($configDir, 0755, true);

        file_put_contents($configDir . '/base.yaml', Yaml::dump(['k' => 'v']));

        $result = Resolve::resolveActive($this->tmpDir, 'myconfig');

        $this->assertIsArray($result);
        $this->assertSame('v', $result['k']);
    }
}
