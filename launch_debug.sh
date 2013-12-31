#!/bin/sh

# Make sure perl is > 5.10.x
sudo /usr/bin/perl ./sms_server.pl daemon --listen "http://*:9000"
