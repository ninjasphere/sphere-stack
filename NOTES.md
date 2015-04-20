# This we need to automate.

* Import the initial test_data.sql
* Add users to rabbitmq
* Enable the mqtt plugin in rabbitmq

# mysql 

* Restore the databases.

```
cat test_data.sql | docker exec -i spherestack_spheremysql_1 mysql -uroot
```

# couchdb

curl -X PUT http://crusty.local:5984/sphere_modelstore/_design/manifest -d @manifest.json

http://IPOFDOCKERHOST:5984/_utils/database.html?sphere_modelstore/_all_docs

# rabbitmq 

```
docker exec -i spherestack_sphererabbit_1 rabbitmq-plugins enable rabbitmq_mqtt
```

http://IPOFDOCKERHOST:15672/#/

# developing

Add these to your `/etc/hosts' file, where IPOFDOCKERHOST is the ip address of the machine hosting your docker containers.

```
IPOFDOCKERHOST doiutsu
IPOFDOCKERHOST apiservice
```

# douitsu

* Register your first user in douitsu, this will be used to setup the oauth2 applications.

* Add an application for the sphere API service.

* Enable some flags for the api service application.

```
update application set is_ninja_official=1 where id = '35573a18-7f12-47c2-89f7-a82d6087a144';
```

# openssl 

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
Common Name (e.g. server FQDN or YOUR name) []:*.your_domain.com
Email Address []:your_email@domain.com
```
Combine these files.

```
cat haproxy/ssl/sphere.key haproxy/ssl/sphere.crt >> haproxy/ssl/wildcard.pem
```
