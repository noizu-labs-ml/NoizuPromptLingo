<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Merge;
use PHPUnit\Framework\TestCase;

final class MergeTest extends TestCase
{
    public function testOverlayReplacesScalar(): void
    {
        $result = Merge::deepMerge(
            ['name' => 'old'],
            ['name' => 'new']
        );
        $this->assertSame('new', $result['name']);
    }

    public function testAddsNewKeys(): void
    {
        $result = Merge::deepMerge(
            ['a' => 1],
            ['b' => 2]
        );
        $this->assertSame(1, $result['a']);
        $this->assertSame(2, $result['b']);
    }

    public function testRecursiveMapMerge(): void
    {
        $result = Merge::deepMerge(
            ['db' => ['host' => 'localhost', 'port' => 5432]],
            ['db' => ['port' => 3306, 'name' => 'mydb']]
        );
        $this->assertSame('localhost', $result['db']['host']);
        $this->assertSame(3306, $result['db']['port']);
        $this->assertSame('mydb', $result['db']['name']);
    }

    public function testArrayOverlayReplacesBase(): void
    {
        $result = Merge::deepMerge(
            ['tags' => ['a', 'b']],
            ['tags' => ['x']]
        );
        $this->assertSame(['x'], $result['tags']);
    }

    public function testTombstoneStripsSubtree(): void
    {
        $result = Merge::deepMerge(
            ['feature' => ['enabled' => true, 'config' => ['x' => 1]]],
            ['feature' => ['_dc_pruned' => true]]
        );
        $this->assertArrayNotHasKey('feature', $result);
    }

    public function testNestedTombstone(): void
    {
        $result = Merge::deepMerge(
            ['a' => ['b' => ['c' => 1], 'd' => 2]],
            ['a' => ['b' => ['_dc_pruned' => true]]]
        );
        $this->assertArrayNotHasKey('b', $result['a']);
        $this->assertSame(2, $result['a']['d']);
    }

    public function testDeepMergeMultiEmptyReturnsNull(): void
    {
        $result = Merge::deepMergeMulti([]);
        $this->assertNull($result);
    }

    public function testDeepMergeMultiSingleElement(): void
    {
        $result = Merge::deepMergeMulti([['key' => 'value']]);
        $this->assertSame(['key' => 'value'], $result);
    }

    public function testDeepMergeMultiFoldsLeftToRight(): void
    {
        $result = Merge::deepMergeMulti([
            ['a' => 1, 'b' => 1],
            ['b' => 2, 'c' => 2],
            ['c' => 3, 'd' => 3],
        ]);
        $this->assertSame(1, $result['a']);
        $this->assertSame(2, $result['b']);
        $this->assertSame(3, $result['c']);
        $this->assertSame(3, $result['d']);
    }
}
