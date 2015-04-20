# sphere-stack

This setup is used to launch a standalone copy of the sphere platform either on your local machine or on a cloud host.

# prerequisites 

To start you need a host running ubuntu 14.04.02 with docker installed, this can be setup using docker-machine.

* [docker](http://docker.io)
* [docker-compose](https://docs.docker.com/compose/)
* [docker-machine](https://docs.docker.com/machine/) [optional]

# overview

I have broken the system up into two compose configuration files, being resources and services.

## resources

This are the resource services, consisting of mysql, rabbitmq, couchdb and redis.

These services keep their data in the following folders on the docker host:

* /data/couchdb
* /data/mysql
* /data/rabbitmq

## services

These are the services which ninjablocks developed.

* [douitsu](https://github.com/ninjablocks/douitsu)
* [activation](https://github.com/ninjablocks/sphere-activation-service)
* [apiservice](https://github.com/ninjablocks/sphere-api-service)
* [rpcservice](https://github.com/ninjablocks/sphere-cloud-rpc-service)
* [modelservice](https://github.com/ninjablocks/sphere-cloud-modelstore-service)
* [sphere-go-state-service](https://github.com/ninjablocks/sphere-go-state-service)
* [mqtt-proxy](https://github.com/ninjablocks/mqtt-proxy)

# Licensing

sphere-stack is licensed under the MIT License. See LICENSE for the full license text.