<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig\Tests;

use Noizu\DirenvConfig\Store;
use PHPUnit\Framework\TestCase;

final class StoreTest extends TestCase
{
    public function testPathToHashSimple(): void
    {
        $this->assertSame(
            'Users-keith-Github-k8-projects',
            Store::pathToHash('/Users/keith/Github/k8/projects')
        );
    }

    public function testPathToHashRoot(): void
    {
        $this->assertSame('', Store::pathToHash('/'));
    }

    public function testPathToHashSingleSegment(): void
    {
        $this->assertSame('tmp', Store::pathToHash('/tmp'));
    }

    public function testPathToHashTruncation(): void
    {
        $longPath = '/' . implode('/', array_fill(0, 100, 'segment'));
        $hash = Store::pathToHash($longPath);

        $this->assertLessThanOrEqual(209, strlen($hash));
        $this->assertStringStartsWith(substr(str_replace('/', '-', substr($longPath, 1)), 0, 200), $hash);

        $expectedSha = substr(hash('sha256', $longPath), 0, 8);
        $this->assertStringEndsWith('-' . $expectedSha, $hash);
    }

    public function testPathToHashShortIsUnchanged(): void
    {
        $path = '/short/path';
        $hash = Store::pathToHash($path);
        $this->assertSame('short-path', $hash);
        $this->assertLessThanOrEqual(200, strlen($hash));
    }
}
