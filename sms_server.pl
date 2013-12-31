#!/usr/bin/env perl

#
# Author:       Eric Blue - ericblue76@gmail.com
# Project:      Home Automation Hack - Belkin Wemo + Twillio + Siri
# Version:      1.0 - 12-30-2013    Initial Relase
#

use WebService::Belkin::WeMo::Discover;
use WebService::Belkin::WeMo::Device;
use Mojolicious::Lite;
use Data::Dumper;
use Encode;
use strict;

# Helpful if you run behind nginx

helper reply => sub {

    my $self    = shift;
    my $message = shift;

    my $reply = qq{<?xml version="1.0" encoding="UTF-8"?><Response><Sms>$message</Sms></Response>};
    return $self->render( text => $reply );

};

# "real_ip" helper
helper real_ip => sub {
    my $self      = shift;
    my $forwarded = $self->req->headers->header('X-Forwarded-For');
    if ( defined($forwarded) ) {
        $forwarded =~ /([^,\s]+)$/ and return $1;
    }
    else {
        return $self->tx->{remote_address};
    }

};

get '/' => sub {
    my $self = shift;
    $self->render( text => "Welcome to the Belkin Wemo SMS Server" );
};

post '/sms' => sub {
    my $self = shift;

    my $sms_data = {
        "ip"        => $self->real_ip,
        "uas"       => $self->req->headers->user_agent,
        "Body"      => $self->param('Body'),
        "From"      => $self->param('From'),
        "FromCity"  => $self->param('FromCity'),
        "FromState" => $self->param('FromState'),
        "FromZip"   => $self->param('FromZip'),
        "ToCountry" => $self->param('ToCountry'),
        "ToState"   => $self->param('ToState'),
        "ToZip"     => $self->param('ToZip'),
        "ToCountry" => $self->param('ToCountry')
    };

    $self->app->log->info( Dumper($sms_data) );

    if ( $self->param('From') ne "+13106999664" ) {
        $self->res->headers->header( 'Content-Type' => 'text/html' );
        $self->render( text => 'Invalid Request', status => 500 );
    }
    else {

        $self->res->headers->header( 'Content-Type' => 'text/xml' );

        my $belkindb     = "/etc/belkin.db";
        my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();
        my $discovered   = $wemoDiscover->load($belkindb);

        my $command = $self->param('Body');

        $self->app->log->info("Got command - $command");

        my $valid_commands = {
            '1' => 'test',
            '2' => 'get devices',
            '3' => 'get commands',
            '4' => 'turn all lights on',
            '5' => 'turn all lights off',
            '6' => 'turn upstairs lights on',
            '7' => 'turn upstairs lights off',
            '8' => 'turn downstairs lights on',
            '9' => 'turn downstairs lights off'
        };

        if ( lc($command) eq "test" ) {
            $self->reply("Got it!");
        }
        elsif ( lc($command) eq "get devices" ) {

            my $devices;
            foreach my $ip ( keys %{$discovered} ) {
                my $wemo = WebService::Belkin::WeMo::Device->new(
                    ip => $ip,
                    db => $belkindb
                );
                $devices .= $wemo->getFriendlyName();
                $devices .= "[" . $wemo->getBinaryState() . "],";
            }
            chop $devices;

            $self->reply($devices);

        }
        elsif ( lc($command) eq "get commands" ) {

            my $commands;
            foreach my $cmd ( values %{$valid_commands} ) {
                $commands .= "$cmd,";
            }
            chop $commands;

            $self->reply($commands);

        }
        elsif ( lc($command) =~ m/turn (\w+) lights (off|on)/g ) {

            my $target = $1;
            my $action = $2;
            $self->app->log->info("t = $target, o = $action");

            if ( $target eq "all" ) {

                foreach my $ip ( keys %{$discovered} ) {

                    if ( $discovered->{$ip}->{'type'} eq "switch" ) {

                        my $wemo = WebService::Belkin::WeMo::Device->new(
                            ip => $ip,
                            db => $belkindb
                        );
                        $self->app->log->info("Turning off light for wemo $ip");
                        if ( $action eq "off" ) {
                            $wemo->off();
                        }
                        if ( $action eq "on" ) {
                            $wemo->on();
                        }
                    }
                }

                $self->reply("OK");

            } elsif ( $target =~ "upstairs|loft|downstairs" ) {

                my @lights;
                if ($target =~ "upstairs|loft") {
                    @lights = ("Loft Desk", "Loft Light Rear");
                }
                if ($target eq "downstairs") {
                    @lights = ("Living Room Couch", "Living Room Chair");
                }

               foreach (@lights) {

                        my $wemo = WebService::Belkin::WeMo::Device->new(
                            name => $_,
                            db => $belkindb
                        );
                        $self->app->log->info("Turning off light for wemo $_");
                        if ( $action eq "off" ) {
                            $wemo->off();
                        }
                        if ( $action eq "on" ) {
                            $wemo->on();
                        }
                }

                $self->reply("OK");

            } else {
                $self->reply("ERROR - Bad Target");
            }

        } 
        else {
            $self->reply("ERROR - Bad Command");
        }

    }

};

app->config( hypnotoad => { listen => ['http://*:9000'] } );
app->log->path('log/debug.log');
app->log->level('info');
app->start;
