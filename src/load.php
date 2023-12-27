<?php

use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Bundle\FrameworkBundle\FrameworkBundle;
use Symfony\Component\Config\Loader\LoaderInterface;
use Symfony\Component\HttpKernel\Kernel;
use GuzzleHttp\Client;
use Psr\Log\LoggerInterface;
use Psr\Log\NullLogger;

require_once __DIR__.'/../vendor/autoload.php';

final class Service
{
    public function __construct(
        private ?string $apiKey,
        private Client $client = new Client(),
        private LoggerInterface $logger = new NullLogger(),
    ) {}
}

class AppKernel extends Kernel
{
    public function registerBundles(): iterable
    {
        return [
            new FrameworkBundle(),
        ];
    }

    public function registerContainerConfiguration(LoaderInterface $loader): void
    {
        $loader->load(__DIR__ . '/config.php');
    }
}

class ApplicationConfiguration
{
    protected $kernel;

    public function __construct()
    {
        $this->kernel = new AppKernel('dev', true);
        $this->kernel->boot();
    }

    public function getKernel()
    {
        return $this->kernel;
    }
}

exit(
    (require $_SERVER['SCRIPT_FILENAME'])()->run(new ArgvInput(), new ConsoleOutput())
);
