#!/usr/bin/env bash

VERSION=1.3

die() {
    echo "$*" 1>&2
    exit 1
}

version() {
    echo "$VERSION"
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
    echo ${NINJA_CLOUD_DOMAIN}
}

machine() {
    if test -n "$DOCKER_HOST"; then
		docker-machine ls | cut -c1-20 | grep "\*" | cut -f1 -d' '
    else
		echo ""
		return 1
    fi
}

create() {

    config() {
	mkdir -p config
	chmod 0700 config
	cd templates
	for f in *.sh; do
	    (. ./$f) > ../config/$(basename $f .sh) || die "died while running template $f"
	done
	cd ..
    }

    services() {
        docker-compose -p spherestack -f services-docker-compose.yml up -d
    }

    resources() {
        if test -z "$DOCKER_HOST"; then
           sudo mkdir -p /var/lib/sphere-stack || die "failed to create sphere-stack"
        else
           ssh -i ~/.docker/machine/machines/$(machine)/id_rsa docker@$(ip) <<EOF
sudo mkdir -p /mnt/sda1/var/lib/sphere-stack &&
sudo ln -sf /mnt/sda1/var/lib/sphere-stack /var/lib/sphere-stack
EOF
        fi
        docker-compose -p spherestack -f resources-docker-compose.yml up -d
    }

    couch() {
        docker exec -i spherestack_spherecouch_1 curl -X PUT http://127.0.0.1:5984/sphere_modelstore;
        curl -X PUT http://$(ip):5984/sphere_modelstore/_design/manifest -d @manifest.json
    }

    mysql() {
        cat test_data.sql | docker exec -i spherestack_spheremysql_1 mysql -uroot
    }

    keys() {
	mkdir -p haproxy/ssl &&
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout haproxy/ssl/sphere.key -out haproxy/ssl/sphere.crt &&
        cat haproxy/ssl/sphere.key haproxy/ssl/sphere.crt >> haproxy/ssl/wildcard.pem
    }

    "$@"
}


hosts-append() {
    local d=$(domain) || exit $?
    echo $(ip) \
    	${NINJA_API_ENDPOINT} \
    	${NINJA_ID_ENDPOINT} \
    	mqtt.$d \
    	""
}

start() {
    resource=$1
    shift 1
    case "$resource" in
	resources)
	    docker-compose -p spherestack -f resources-docker-compose.yml up -d
    ;;
    services)
	    docker-compose -p spherestack -f services-docker-compose.yml up -d
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
        docker-compose -p spherestack -f resources-docker-compose.yml stop
        docker-compose -p spherestack -f resources-docker-compose.yml rm
        docker-compose -p spherestack -f resources-docker-compose.yml up -d
    ;;
    services)
        docker-compose -p spherestack -f services-docker-compose.yml stop
        docker-compose -p spherestack -f services-docker-compose.yml rm -f
        docker-compose -p spherestack -f services-docker-compose.yml up -d
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
	    docker-compose -p spherestack -f resources-docker-compose.yml stop
    ;;
    services)
	    docker-compose -p spherestack -f services-docker-compose.yml stop
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
	    docker-compose -p spherestack -f resources-docker-compose.yml logs
    ;;
	services)
	    docker-compose -p spherestack  -f services-docker-compose.yml logs
	    ;;
	*)
	    die "unknown resource: $resource"
	    ;;
    esac
}

pwgen() {
    cat /dev/urandom | dd count=1 bs=256 2>/dev/null | openssl base64 | cut -c1-20 | head -1
}

edit() {
    ${EDITOR:-vi} .sphere-stack/master
    create config
}

update() {
	application-table() {
		docker exec -i spherestack_spheremysql_1 mysql douitsu -uroot <<EOF
update application set is_ninja_official=1 where appid = '${NINJA_APP_TOKEN}';
EOF
	}
	"$@"
}

generate() {
	master() {
		cat <<EOF
NINJA_SIGNING_SECRET=$(pwgen);
NINJA_SESSION_SECRET=$(pwgen);
NINJA_RABBIT_SECRET=$(pwgen);
NINJA_CLOUD_DOMAIN=example.com;
NINJA_API_ENDPOINT=api.\${NINJA_CLOUD_DOMAIN};
NINJA_ID_ENDPOINT=id.\${NINJA_CLOUD_DOMAIN};
NINJA_APP_TOKEN=app_XX;
NINJA_APP_KEY=sk_XX;
EOF
	}

	"$@"
}

init() {
    mkdir -p .sphere-stack
    chmod 0700 .sphere-stack
	generate master > .sphere-stack/defaults
    if ! test -f .sphere-stack/master; then
		generate master > .sphere-stack/master
        echo "./sphere-stack/master has been initialized"
    else
        echo "skipping initialization of .sphere-stack/master - existing tokens will be used"
    fi
    . .sphere-stack/defaults
    . .sphere-stack/master
    create config
}

usage() {
    cat <<EOF
$0 init                         - initialize the current directory with a default configuration
$0 edit                         - edit the configuration
$0 create                       - create the couch database
$0 ip                           - the ip of the docker machine
$0 domain                       - the domain of the stack
$0 machine                      - the machine
$0 generate master              - generate the master
$0 create resources             - create the resources composition
$0 create services              - create the services composition
$0 create couch                 - create the couch data store
$0 create mysql                 - create the mysql data store
$0 create keys                  - create the keys
$0 start [resources|services]   - start the specified composition
$0 stop [resources|services]    - stop the specified composition
$0 logs [resources|services]    - logs from the specified composition
$0 restart [resources|services] - restart the specified composition
$0 version                      - report the script version
EOF
}

cmd=$1
shift 1
case $cmd in
    init|version)
       $cmd "$@"
    ;;
    ip|domain|hosts-append|machine|init|edit|update)
       test -f .sphere-stack/master || die "run ./sphere-stack.sh init first!"
       test -f .sphere-stack/defaults && . .sphere-stack/defaults
       . .sphere-stack/master
	   $cmd "$@"
       ;;
    create|start|stop|logs|recreate)
       test -f .sphere-stack/master || die "run ./sphere-stack.sh init first!"
       test -f .sphere-stack/defaults && . .sphere-stack/defaults
       . .sphere-stack/master
       if test "$1" == "all"; then
       		shift 1
       		case "$cmd" in
		       	stop)
		       		$cmd services "$@"
		       		$cmd resources "$@"
		       	;;
		       	*)
		       		$cmd resources "$@"
		       		$cmd services "$@"
		       	;;
       		esac
	   else
		    $cmd "$@"
	   fi
		;;
    *)
    	usage
	;;
esac
