#!/usr/bin/env bash

die() {
    echo "$*" 1>&2
    exit 1
}

ip() {
    if test -n "$DOCKER_HOST"; then
	local ip=${DOCKER_HOST#tcp://};
	echo ${ip%:*};
    else
	echo "127.0.0.1"
    fi
}

domain() {
    local domain=$(cat haproxy/ssl/wildcard.pem | openssl x509 -text | grep DirName | sed -n "s/.*CN=\*.//;s|/.*||p")
    test -n "$domain" || die "make sure you have run create-keys with domain like *.example.com first"
    echo $domain
}

machine() {
    if test -n "$DOCKER_HOST"; then
	docker-machine ls | cut -c1-20 | grep "\*\$" | cut -f1 -d' '
    else
	echo ""
	return 1
    fi
}

create() {

    services() {
        docker-compose -f services-docker-compose.yml up -d
    }

    resources() {
        if test -z "$DOCKER_HOST"; then
           mkdir /var/lib/sphere-stack || die "failed to create sphere-stack"
        else
           ssh -i ~/.docker/machine/machines/$(machine)/id_rsa docker@$(ip) <<EOF
sudo mkdir -p /mnt/sda1/var/lib/sphere-stack &&
sudo ln -sf /mnt/sda1/var/lib/sphere-stack /var/lib/sphere-stack
EOF
            docker-compose -f resources-docker-compose.yml up -d
        fi
    }

    couch() {
        docker exec -i spherestack_spherecouch_1 curl -X PUT http://127.0.0.1:5984/sphere_modelstore;
        curl -X PUT http://$(ip):5984/sphere_modelstore/_design/manifest -d @manifest.json
    }

    mysql() {
        cat test_data.sql | docker exec -i spherestack_spheremysql_1 mysql -uroot
    }

    keys() {
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout haproxy/ssl/sphere.key -out haproxy/ssl/sphere.crt &&
        cat haproxy/ssl/sphere.key haproxy/ssl/sphere.crt >> haproxy/ssl/wildcard.pem
    }

    "$@"
}


hosts-append() {
    local d=$(domain) || exit $?
    echo $(ip) douitsu.$(domain) mqtt.$(domain) apiservice.$(domain)
}

start() {
    resource=$1
    shift 1
    case "$resource" in
	resources)
	    docker-compose -f resources-docker-compose.yml up -d
    ;;
    services)
	    docker-compose -f services-docker-compose.yml up -d
    ;;
	*)
	    die "unknown resource: $resource"
	    ;;
    esac
}

recreate() {
    resource=$1
    shift 1
    case "$resource" in
    resources)
        docker-compose -f resources-docker-compose.yml stop
        docker-compose -f resources-docker-compose.yml rm
        docker-compose -f resources-docker-compose.yml up -d
    ;;
    services)
        docker-compose -f services-docker-compose.yml stop
        docker-compose -f services-docker-compose.yml rm -f
        docker-compose -f services-docker-compose.yml up -d
    ;;
    *)
    ;;
    esac
}

stop() {
    resource=$1
    shift 1
    case "$resource" in
	resources)
	    docker-compose -f resources-docker-compose.yml stop
    ;;
    services)
	    docker-compose -f services-docker-compose.yml stop
    ;;
	*)
	    die "unknown resource: $resource"
	    ;;
    esac
}

restart() {
    resource=$1
    shift 1
    (stop "$resource" "$@")
    start "$resource" "$@"
}

logs() {
    resource=$1
    shift 1
    case "$resource" in
	resources)
	    docker-compose -f resources-docker-compose.yml logs
    ;;
	services)
	    docker-compose -f services-docker-compose.yml logs
	    ;;
	*)
	    die "unknown resource: $resource"
	    ;;
    esac
}

usage() {
    cat <<EOF
$0 create                       - create the couch database
$0 ip                           - the ip of the docker machine
$0 domain                       - the domain of the stack
$0 machine                      - the machine
$0 create resources             - create the resources composition
$0 create services              - create the services composition
$0 create couch                 - create the couch data store
$0 create mysql                 - create the mysql data store
$0 create keys                  - create the keys
$0 restart [resources|services] - restart the specified composition
$0 start [resources|services]   - start the specified composition
$0 stop [resources|services]    - stop the specified composition
$0 logs [resources|services]    - logs from the specified composition
EOF
}

cmd=$1
shift 1
case $cmd in
    create|ip|domain|hosts-append|machine|start|stop|logs|recreate)
	   $cmd "$@"
	;;
    *)
    	usage
	;;
esac
