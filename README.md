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

# running

First CHANGE PASSWORDS as follows:

1. Any variable containing `signing_secret`, at the moment for simplicity set them all to the same thing.
2. RabbitMQ admin password, and all the associated connection strings beginning with `amqp://`.

```
docker-compose -f resources-docker-compose.yml up -d
```

## databases

Then to if this is the first time you have run it you need to import the SQL database.

```
cat test_data.sql | docker exec -i spherestack_spheremysql_1 mysql -uroot
```

Then ensure the couchdb database is created and create the secondary index.

```
docker exec -i spherestack_spherecouch_1 curl -X PUT http://127.0.0.1:5984/sphere_modelstore
curl -X PUT http://IPOFDOCKERHOST.local:5984/sphere_modelstore/_design/manifest -d @manifest.json
```

## openssl

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout haproxy/ssl/sphere.key -out haproxy/ssl/sphere.crt
```

When you hit "ENTER", you will be asked a number of questions.

```
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:New York
Locality Name (eg, city) []:New York City
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Your Company
Organizational Unit Name (eg, section) []:Department of Kittens
Common Name (e.g. server FQDN or YOUR name) []:*.example.com
Email Address []:your_email@domain.com
```
Combine these files.

```
cat haproxy/ssl/sphere.key haproxy/ssl/sphere.crt >> haproxy/ssl/wildcard.pem
```

## services

Then start the services.

```
docker-compose -f services-docker-compose.yml up -d
```

## douitsu

* Register your first user in douitsu, this will be used to setup the oauth2 applications.

* Add an application for the sphere API service.

* Enable some flags for the REST API service application.

```
update application set is_ninja_official=1 where id = '<UUID primary key for this application>';
```

* Update the following environment variables for this application in services-docker-compose.yml:

	* usvc_oauth_callbackURL=https://apiservice.example.com/auth/ninja/callback
    * usvc_oauth_authorizationURL=https://douitsu.example.com/dialog/authorize
    * usvc_oauth_clientID=app_XX
    * usvc_oauth_clientSecret=sk_XX

* Restart the composition
```
docker-compose -f services-docker-compose.yml stop
docker-compose -f services-docker-compose.yml rm
docker-compose -f services-docker-compose.yml up
```

## security

On the VPS you only need to expose ports 80, 443 and 8883, the rest can be accessed using SSH port forwarding.

```
ssh -D 3000 USERNAME@HOST
```

Then configure your browser as required to use this socks proxy using something like [switchysharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm?hl=en).

# Licensing

sphere-stack is licensed under the MIT License. See LICENSE for the full license text.
