#!/usr/bin/perl
#
# Copyright (C) 2016 Koha-Suomi
#
# This file is part of emb-tamper.
#
# emb-tamper is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# emb-tamper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with emb-tamper.  If not, see <http://www.gnu.org/licenses/>.

package Tamper;

our $VERSION = "0.01";

use Modern::Perl;
use Data::Dumper;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Try::Tiny;
use Scalar::Util qw(blessed);

use Time::HiRes;
use HiPi::GPIO;
use HiPi qw( :rpi );

use Tamper::Config;
use Tamper::Pid;

use TaLog;
my $l = bless({}, 'TaLog');

sub new {
    my ($class, $params) = @_;
    print("New Tamper - Logging is written to /var/log/emb-tamper/tamper.log\n");

    my $self = Tamper::Config::configure($params);
    bless $self, $class;
    Tamper::Pid::checkPid($self);

    $self->{gpio} = HiPi::GPIO->new;
    $self->{doorButton} = $self->{gpio}->get_pin(Tamper::Config::doorPin);
    $self->{doorButton}->mode(RPI_MODE_INPUT);

    return $self;
}

sub start {
    my ($self, $pollCount) = @_;

    try {
        $self->{prevPowerLevel} = -1;
        while (1) {
            return $self if (defined($pollCount) && $pollCount-- <= 0);

            $self->{newPowerLevel} = $self->{doorButton}->value();
            if ($self->{prevPowerLevel} != $self->{newPowerLevel}) {
                $l->fatal("Tamper detected - Enclosure lid open") if ($self->{newPowerLevel} == 1);
                $l->info ("Tamper subsided - Enclosure lid closed") if ($self->{newPowerLevel} == 0);
            }
            $self->{prevPowerLevel} = $self->{newPowerLevel};
            Time::HiRes::usleep(Tamper::Config::pollIntervalMs()*1000);
        }
    } catch {
        $l->fatal("Main loop crashed with error: ".Data::Dumper::Dumper($_));
        die("Main loop crashed with error: ".Data::Dumper::Dumper($_));
    };
    return $self;
}

1;
