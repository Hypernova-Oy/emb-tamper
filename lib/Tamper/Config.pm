#!/usr/bin/perl
#
# Copyright (C) 2017 Koha-Suomi
#
# This file is part of emb-tamper.
#
# emb-tamper is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

package Tamper::Config;

our $VERSION = "0.01";

use Modern::Perl;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Carp qw(longmess);

use Config::Simple;
use DateTime::TimeZone;

#use TaLog; #We cannot use Log::Log4perl here, because the configuration hasn't been validated yet. Configuration controls logging. Die on errors instead.
my $l = bless({}, 'TaLog');

my $configFile = "/etc/emb-tamper/daemon.conf";

=head2 configure

Configures the whole program

@RETURNS HASHRef with configuration values

=cut

my $olConfig;
sub configure {
    my ($params) = @_;

    $olConfig = _mergeConfig($params);
    #Global config is set here. After this point logger can be used in this package.
    $l->debug("Using configurations: ".$l->flatten($olConfig));

    my $tz = setTimeZone();
    $l->debug("Using time zone: $tz");

    return $olConfig;
}

=head2 mergeConfig

Take user parameters and system configuration and override with user parameters.
Validate config.

=cut

sub _mergeConfig {
    my ($params) = @_;
    $l->debug("Received following configuration overrides: ".$l->flatten($params)) if $params;

    my $config = _slurpConfig();

    #Merge params to config
    if(ref($params) eq 'HASH') {
        while( my ($k,$v) = each(%$params) ) {
            $config->{$k} = $params->{$k};
        }
    }

    _isConfigValid($config);
    return $config;
}

sub _slurpConfig {
    my $c = new Config::Simple($configFile)
        || die(Config::Simple->error());
    $c = $c->vars();
    my %c;
    while (my ($k,$v) = each(%$c)) {
        my $newKey = $k;
        $newKey =~ s/^default\.//;
        $c{$newKey} = $c->{$k};
    }
    return \%c;
}

=head2

Get config and remove strange default-block

=cut

sub getConfig {
    return $olConfig if $olConfig;
    return configure();
}


my $signed_float_regexp = '-?\d+\.?\d*';
my $signed_int_regexp = '-?\d+';
my $unsigned_int_regexp = '\d+';
sub _isConfigValid() {
    my ($c) = @_;

    unless (defined($c->{DoorPin}) && $c->{DoorPin} =~ /^$unsigned_int_regexp$/) {
        die("DoorPin is not a valid unsigned int");
    }
    unless (defined($c->{PollIntervalMs}) && $c->{PollIntervalMs} =~ /^$unsigned_int_regexp$/) {
        die("PollIntervalMs is not a valid unsigned int");
    }

    return 1;
}

=head2 makeConfig

Make a configuration HASH from an ordered set of values.
This is only meant for helper function when dealing with CLI-scripts

=cut

sub makeConfig {
    my %conf;
    $conf{DoorPin}        = $_[0] if $_[0];
    $conf{PollIntervalMs} = $_[1] if $_[1];
    $conf{Verbose}        = $_[2] if $_[2];
    return \%conf;
}

=head2 setTimeZone
@STATIC @PARAMETERLESS

Autoconfigures the system timezone

=cut

sub setTimeZone {
    return $ENV{TZ} if $ENV{TZ};
    my $TZ = `/bin/cat /etc/timezone`;
    die "Timezone not defined in /etc/timezone" unless $TZ;
    chomp($TZ);
    my $tz = DateTime::TimeZone->new(name => $TZ);
    die "Timezone '$tz' from /etc/timezone is not valid" unless $tz;
    $ENV{TZ} = $TZ;
    return $ENV{TZ};
}







#############################
###### Config accessors #####
#############################

sub doorPin {
    return $olConfig->{DoorPin};
}
sub pollIntervalMs {
    return $olConfig->{PollIntervalMs};
}

1;

