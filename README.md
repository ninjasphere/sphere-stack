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

# configuring

First, create a default configuration. This step will generate some unique keys.

```
./sphere-stack.sh init
```

Review the configuration at any time with:

```
./sphere-stack.sh edit
```

Now create the docker container (the so-called 'resources composition') that will contain the resource services.

```
./sphere-stack.sh create resources
```

## databases

Then if this is the first time you have run it you need to import the SQL database.

```
./sphere-stack.sh create mysql
```

Then ensure the couchdb database is created and create the secondary index.

```
./sphere-stack.sh create couch
```

## openssl

```
./sphere-stack.sh create keys
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

## services

Then start the services.

```
./sphere-stack.sh start services
```

## IP address

To learn the IP address of your docker-machine, run:

```
./sphere-stack.sh ip
```

## host file

Add an entry like the following to your local hosts /etc/hosts file:

```
192.168.99.100 id.example.com api.example.com mqtt.example.com
```

You can generate the correct entry with:

```
./sphere-stack.sh hosts-append
```

## douitsu

* Register your first user in douitsu (https://id.example.com), this will be used to setup the oauth2 applications.

* You will probably find things easier if you choose trust to the self-signed certificate using the mechanisms provided by your browser &/or host operating systems.

* Add an application for the sphere API service.

	* "Something that users will trust" - "Private Ninja Cloud"
	* "The full URL to your application homepage." - https://api.example.com
	* "Your application’s callback URL; Read our OAuth documentation for more info." - https://api.example.com/auth/ninja/callback
    * "This text is displayed to all potential users of your application." - "This is a private Ninja Cloud"

After saving, take note of the "Client ID" and "Secret" under the "Application Details" title.

* Update the NINJA_APP_TOKEN and NINJA_APP_KEY variables with the values collected from the last step

```
./sphere-stack.sh edit
```

* Enable some flags for the REST API service application

```
./sphere-stack.sh update application-table
```

* Recreate the services composition

```
./sphere-stack.sh recreate services
```

## security

On the VPS you only need to expose ports 80, 443 and 8883, the rest can be accessed using SSH port forwarding.

```
ssh -D 3000 USERNAME@HOST
```

Then configure your browser as required to use this socks proxy using something like [switchysharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm?hl=en).

# Licensing

sphere-stack is licensed under the MIT License. See LICENSE for the full license text.

# Revisions

##1.3
* changed default endpoint names from 'apiservice' to 'api' and from 'douitsu' to 'id'

##1.2
* replace all configuration with environment files
* generate all environment files from master configuration using shell templates
* add support for init and edit commands

##1.1
* added 'sphere-stack.sh' to encapsulate scriplets used in instructions
* ensured that resources used by resources-docker-compose.yml are located on persistent storage of the VM

##1.0
* Initial release
