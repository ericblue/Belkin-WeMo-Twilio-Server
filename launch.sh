#!/bin/sh

# Run under daemon
#./sms_server.pl daemon --listen "http://*:9000"

# Run under hypnotoad
# TODO Figure out why hypnotoad stop is caching old data
hypnotoad -s sms_server.pl
kill -9 `pidof sms_server.pl`
hypnotoad sms_server.pl

