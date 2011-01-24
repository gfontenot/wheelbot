#!/bin/sh

pwd

until /usr/bin/env ./script/run_bot; do
	echo "Wheelbot crashed with exit code $?. Respawning.." >&2
	sleep 1
done