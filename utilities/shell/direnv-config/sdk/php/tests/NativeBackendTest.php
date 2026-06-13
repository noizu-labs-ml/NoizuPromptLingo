<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Backend\NativeBackend;
use Noizu\DirenvConfig\Exception\ConfigNotFoundException;
use Noizu\DirenvConfig\Version;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Yaml\Yaml;

final class NativeBackendTest extends TestCase
{
    private string $tmpDir;

    private static function fixturesDir(): string
    {
        return dirname(__DIR__, 2) . '/contract-tests/fixtures';
    }

    protected function setUp(): void
    {
        $this->tmpDir = sys_get_temp_dir() . '/dc-native-backend-test-' . uniqid();
        mkdir($this->tmpDir, 0755, true);
    }

    protected function tearDown(): void
    {
        if (is_dir($this->tmpDir)) {
            exec('rm -rf ' . escapeshellarg($this->tmpDir));
        }
    }

    private function seedStore(string $config, array $baseData): NativeBackend
    {
        $configDir = $this->tmpDir . '/' . $config;
        mkdir($configDir, 0755, true);

        file_put_contents($configDir . '/base.yaml', Yaml::dump($baseData, 4, 2));
        file_put_contents($configDir . '/.active', Yaml::dump($baseData, 4, 2));

        return new NativeBackend($this->tmpDir);
    }

    public function testGetSimpleString(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertSame('noizu', $backend->get('cluster', 'name'));
    }

    public function testGetNestedString(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertSame('m5.xlarge', $backend->get('cluster', 'node_pool.instance_type'));
    }

    public function testGetInteger(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertSame(6443, $backend->get('cluster', 'port'));
    }

    public function testGetBoolean(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertTrue($backend->get('cluster', 'enabled'));
    }

    public function testGetEntireConfig(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $result = $backend->get('cluster');
        $this->assertIsArray($result);
        $this->assertArrayHasKey('name', $result);
        $this->assertArrayHasKey('port', $result);
    }

    public function testGetWithWildcard(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/nested-store');
        $result = $backend->get('app', 'endpoints[*].host');
        $this->assertSame(['api.example.com', 'internal.example.com', 'backup.example.com'], $result);
    }

    public function testGetMissingPath(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertNull($backend->get('cluster', 'nonexistent'));
    }

    public function testListConfigs(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->assertSame(['cluster'], $backend->listConfigs());
    }

    public function testGetMissingConfig(): void
    {
        $backend = new NativeBackend(self::fixturesDir() . '/simple-store');
        $this->expectException(ConfigNotFoundException::class);
        $backend->get('nonexistent');
    }

    // ── Write tests ──────────────────────────────────────────────────

    public function testSetWritesToLayerAndUpdatesActive(): void
    {
        $backend = $this->seedStore('app', ['host' => 'localhost']);

        $backend->set('app', 'port', '8080');

        // Verify the local layer was written
        $layerContent = Yaml::parse(file_get_contents($this->tmpDir . '/app/local.yaml'));
        $this->assertSame(8080, $layerContent['port']);

        // Verify .active was regenerated with merged result
        $active = Yaml::parse(file_get_contents($this->tmpDir . '/app/.active'));
        $this->assertSame('localhost', $active['host']);
        $this->assertSame(8080, $active['port']);

        // Verify version was bumped
        $this->assertGreaterThan(0, Version::read($this->tmpDir));
    }

    public function testSetWithNoBumpSkipsVersionBump(): void
    {
        $backend = $this->seedStore('app', ['x' => 1]);

        $backend->set('app', 'y', '2', 'local', noBump: true);

        $this->assertSame(0, Version::read($this->tmpDir));
    }

    public function testUnsetRemovesKeyAndUpdatesActive(): void
    {
        $backend = $this->seedStore('app', ['keep' => 'yes']);

        // First set a key in the local layer
        $backend->set('app', 'remove_me', 'gone', 'local', noBump: true);

        // Confirm it's there
        $layerBefore = Yaml::parse(file_get_contents($this->tmpDir . '/app/local.yaml'));
        $this->assertArrayHasKey('remove_me', $layerBefore);

        // Now unset it
        $backend->unset('app', ['remove_me']);

        $layerAfter = Yaml::parse(file_get_contents($this->tmpDir . '/app/local.yaml'));
        $this->assertArrayNotHasKey('remove_me', $layerAfter);

        // .active should no longer contain the key
        $active = Yaml::parse(file_get_contents($this->tmpDir . '/app/.active'));
        $this->assertArrayNotHasKey('remove_me', $active);

        // Version was bumped by unset
        $this->assertGreaterThan(0, Version::read($this->tmpDir));
    }

    public function testBumpIncrementsVersion(): void
    {
        $backend = $this->seedStore('app', ['x' => 1]);

        $v1 = $backend->bump();
        $v2 = $backend->bump();

        $this->assertSame(1, $v1);
        $this->assertSame(2, $v2);
        $this->assertSame(2, Version::read($this->tmpDir));
    }
}
