<?php

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void
{
    $container->services()->set(Service::class)
        ->class(Service::class)
        ->autowire()
        ->public()
        ->arg('$apiKey', '%env(default::SERVICE_API_KEY)%');
};
