#!/usr/bin/env bash
set -Eeo pipefail

source /tmp/docker-entrypoint.sh

# _main_demo copied and adapted from
# https://github.com/docker-library/postgres/blob/6bbf1c7b308d1c4288251d73c37f6caf75f8a3d4/14/buster/docker-entrypoint.sh
# -> _main

_main_demo() {
		docker_setup_env
		if [ "$(id -u)" = '0' ]; then
			# then restart script as postgres user
			exec gosu postgres "$BASH_SOURCE" "$@"
		fi

			docker_verify_minimum_env

			# PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
			# e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
			export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
			docker_temp_server_start "$@"

			docker_process_init_files /tmp/setup-demo-data.sh

			docker_temp_server_stop
			unset PGPASSWORD

			echo
			echo 'Demo data added; ready for start up.'
			echo
}

if ! _is_sourced; then
	_main_demo "$@"
fi
