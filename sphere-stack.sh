#!/usr/bin/env bash

die() {
    echo "$*" 1>&2
    exit 1
}

ip() {
    local ip=${DOCKER_HOST#tcp://};
    echo ${ip%:*};
}

domain() {
    local domain=$(cat haproxy/ssl/wildcard.pem | openssl x509 -text | grep DirName | sed -n "s/.*CN=\*.//;s|/.*||p")
    test -n "$domain" || die "make sure you have run create-keys with domain like *.example.com first"
    echo $domain
}

create-couch() {
    docker exec -i spherestack_spherecouch_1 curl -X PUT http://127.0.0.1:5984/sphere_modelstore;
    curl -X PUT http://$(ip):5984/sphere_modelstore/_design/manifest -d @manifest.json
}

create-mysql() {
    cat test_data.sql | docker exec -i spherestack_spheremysql_1 mysql -uroot
}

create-keys() {
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout haproxy/ssl/sphere.key -out haproxy/ssl/sphere.crt &&
    cat haproxy/ssl/sphere.key haproxy/ssl/sphere.crt >> haproxy/ssl/wildcard.pem
}

hosts-append() {
    local d=$(domain) || exit $?
    echo $(ip) douitsu.$(domain) mqtt.$(domain) apiservice.$(domain)
}

usage() {
    cat <<EOF
$0 create-couch - create the couch database
$0 create-mysql - create the mysql database
$0 create-keys  - create the keys
$0 ip           - the ip of the docker machine
EOF
}

cmd=$1
shift 1
case $cmd in
    create-couch|create-mysql|create-keys|ip|domain|hosts-append)
	   $cmd "$@"
	;;
    *)
    	usage
	;;
esac
