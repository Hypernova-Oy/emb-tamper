#!/usr/bin/perl

use Modern::Perl;
use utf8;
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use Test::More;

use File::Basename;

use Tamper;

subtest "Daemon starts, and closes", \&daemon;
sub daemon {

  my ($conf, $tempFile, $statsRow, $todayYmd, @lines);

  $ARGV[0] = '--pollCount';
  $ARGV[1] = 10;
  my $cmd = "cat ".File::Basename::dirname(__FILE__)."/../scripts/tamper";
  my $tamper = eval `$cmd`;

  is(ref($tamper), 'Tamper', 'Got the Tamper');
  ok(defined($tamper->{newPowerLevel}),  'New Power Level exists');
  ok(defined($tamper->{prevPowerLevel}), 'Old Power Level exists');
}

done_testing;
