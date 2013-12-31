#!/usr/bin/perl

use WebService::Belkin::WeMo::Device;
use WebService::Belkin::WeMo::Discover;
use Data::Dumper;
use strict;

# Belkin DB of switches and sensors originally created using the Discover module
# my $discovered = $wemoDiscover->search();
# $wemoDiscover->save("/etc/belkin.db");


my $wemo = WebService::Belkin::WeMo::Device->new(name => 'Loft Desk', db => '/etc/belkin.db');

$wemo->off();

sleep(5);

$wemo->on();
