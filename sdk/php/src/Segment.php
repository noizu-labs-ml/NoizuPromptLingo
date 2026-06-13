<?php

declare(strict_types=1);

namespace Noizu\DirenvConfig;

enum SegmentType
{
    case Key;
    case Index;
    case Wildcard;
    case Length;
}

final readonly class Segment
{
    public function __construct(
        public SegmentType $type,
        public string|int|null $value = null,
    ) {}

    public static function key(string $value): self
    {
        return new self(SegmentType::Key, $value);
    }

    public static function index(int $value): self
    {
        return new self(SegmentType::Index, $value);
    }

    public static function wildcard(): self
    {
        return new self(SegmentType::Wildcard);
    }

    public static function length(): self
    {
        return new self(SegmentType::Length);
    }
}
