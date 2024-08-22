<?php

namespace Oscmarb\Template;

final class Example
{
    public function integer(): int
    {
        return 1;
    }

    public function exception(): void
    {
        throw new \RuntimeException();
    }
}