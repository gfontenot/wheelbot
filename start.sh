#!/bin/sh

until /usr/bin/env ruby ./lib/bot.rb; do
	echo "Wheelbot crashed with exit code $?. Respawning.." >&2
	sleep 1
done