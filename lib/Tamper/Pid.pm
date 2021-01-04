#!/usr/bin/perl
#
# Copyright (C) 2017 Koha-Suomi
#
# This file is part of emb-tamper.
#

package Tamper::Pid;

our $VERSION = "0.01";

use Modern::Perl;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Try::Tiny;
use Scalar::Util qw(blessed);

use Proc::PID::File;

use TaLog;
my $l = bless({}, 'TaLog');

=head1 SYNOPSIS

This is a static extension class to Tamper.pm

This encapsulates all process management logic.

=cut

=head2 checkPid

Checks if this daemon is already listening to the given pins.
If a daemon is using these pins, the existing daemon is killed and this
daemon is started.

TODO:: Duplicates emb-rtttl PID-mechanism

=cut

sub checkPid {
    my ($self) = @_;

    $self->{pid} = getPid($self);
    $l->debug("Binding to pid file: ".$self->{pid});
    _killExistingProgram($self->{pid}) if $self->{pid}->alive();
    $self->{pid}->touch();
}

=head2 killTamper

A static method for killing a Tamper-daemon matching the given configuration.

=cut

sub killTamper {
    my ($conf) = @_;
    _killExistingProgram(getPid($conf));
}

=head2 getPid

A static method to get the Proc::PID::File of this daemon from the given config.

=cut

sub getPid {
    my ($conf) = @_;

    my $name = 'tamper';
    return Proc::PID::File->new({
        name => $name,
        verify => $name,
    });
}

sub _killExistingProgram {
    my ($pid) = @_;
    $l->debug("Killing existing Tamper-program '".($pid->read() // 'undef')."' from: $pid");
    kill 'INT', $pid->read();
}

1;
