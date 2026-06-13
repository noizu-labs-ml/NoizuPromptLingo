<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Backend\NativeBackend;
use Noizu\DirenvConfig\Store;
use Noizu\DirenvConfig\Version;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Yaml\Yaml;

final class ContractTest extends TestCase
{
    private static array $expectations;
    private static string $fixturesDir;

    public static function setUpBeforeClass(): void
    {
        self::$fixturesDir = dirname(__DIR__, 2) . '/contract-tests/fixtures';
        $path = dirname(__DIR__, 2) . '/contract-tests/expectations.yaml';
        self::$expectations = Yaml::parseFile($path);
    }

    /** @return iterable<string, array{array}> */
    public static function contractCases(): iterable
    {
        $fixturesDir = dirname(__DIR__, 2) . '/contract-tests/fixtures';
        $path = dirname(__DIR__, 2) . '/contract-tests/expectations.yaml';
        $data = Yaml::parseFile($path);

        foreach ($data['tests'] as $test) {
            yield $test['name'] => [$test];
        }
    }

    #[\PHPUnit\Framework\Attributes\DataProvider('contractCases')]
    public function testContractExpectation(array $test): void
    {
        $name = $test['name'];

        if (isset($test['expected_version'])) {
            $this->runVersionTest($test);
            return;
        }

        if (isset($test['expected_configs'])) {
            $this->runListConfigsTest($test);
            return;
        }

        if (isset($test['input_path'])) {
            $this->runPathHashTest($test);
            return;
        }

        $this->runGetTest($test);
    }

    private function runGetTest(array $test): void
    {
        $storePath = self::$fixturesDir . '/' . $test['store'];
        $backend = new NativeBackend($storePath);
        $path = $test['path'] ?? null;
        if ($path === 'null') {
            $path = null;
        }

        $result = $backend->get($test['config'], $path);
        $type = $test['type'];

        match ($type) {
            'string' => $this->assertSame($test['expected'], $result),
            'integer' => $this->assertSame((int) $test['expected'], $result),
            'boolean' => $this->assertSame((bool) $test['expected'], $result),
            'null' => $this->assertNull($result),
            'string_array' => $this->assertSame($test['expected'], $result),
            'integer_array' => $this->assertSame(
                array_map(fn($v) => (int) $v, $test['expected']),
                $result
            ),
            'map' => $this->assertExpectedKeys($test, $result),
            default => $this->fail("Unknown type: {$type}"),
        };
    }

    private function assertExpectedKeys(array $test, mixed $result): void
    {
        $this->assertIsArray($result);
        foreach ($test['expected_keys'] as $key) {
            $this->assertArrayHasKey($key, $result, "Missing key: {$key}");
        }
    }

    private function runVersionTest(array $test): void
    {
        $storePath = self::$fixturesDir . '/' . $test['store'];
        $version = Version::read($storePath);
        $this->assertSame((int) $test['expected_version'], $version);
    }

    private function runListConfigsTest(array $test): void
    {
        $storePath = self::$fixturesDir . '/' . $test['store'];
        $backend = new NativeBackend($storePath);
        $configs = $backend->listConfigs();
        sort($configs);
        $expected = $test['expected_configs'];
        sort($expected);
        $this->assertSame($expected, $configs);
    }

    private function runPathHashTest(array $test): void
    {
        $hash = Store::pathToHash($test['input_path']);
        $this->assertSame($test['expected_hash'], $hash);
    }
}
