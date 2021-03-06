#!/usr/bin/perl

=head1 NAME

t/Octopussy/ServiceGroup.t - Test Suite for Octopussy::ServiceGroup module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::ServiceGroup;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $PREFIX          => 'Octo_TEST_';
Readonly my $SG_FILE         => Octopussy::FS::File('servicegroups');
Readonly my $SG_ID           => "${PREFIX}servicegroup";
Readonly my $SG_DESC         => "${PREFIX}servicegroup Description";
Readonly my $DIR_SERVICES    => Octopussy::FS::Directory('services');
Readonly my @SERVICES_KERNEL => (
  {sid => 'Linux_Kernel', rank => '01'},
  {
    sid  => 'Linux_Kernel_Bluetooth',
    rank => '02'
  },
  {sid => 'Linux_Kernel_USB', rank => '03'},
);
Readonly my $SERVICE_TO_ADD => 'Linux_Kernel_FS_Ext3';

my %conf = (
  sg_id       => $SG_ID,
  description => $SG_DESC,
  service     => \@SERVICES_KERNEL,
);

my @list1 = Octopussy::ServiceGroup::List();

my $error1 = Octopussy::ServiceGroup::Add(\%conf);
my $error2 = Octopussy::ServiceGroup::Add(\%conf);
ok(((!defined $error1) && (defined $error2)), 'Octopussy::ServiceGroup::Add()');

my $new_conf = Octopussy::ServiceGroup::Configuration($SG_ID);
ok($new_conf->{sg_id} eq $SG_ID, 'Octopussy::ServiceGroup::Configuration()');

my @list2 = Octopussy::ServiceGroup::List();
ok(scalar @list1 + 1 == scalar @list2, 'Octopussy::ServiceGroup::List()');

my @services = Octopussy::ServiceGroup::Services($SG_ID);
ok(
  scalar @SERVICES_KERNEL == scalar @services,
  'Octopussy::ServiceGroup::Services()'
);

my $service_added =
  Octopussy::ServiceGroup::Add_Service($SG_ID, $SERVICE_TO_ADD);
ok($service_added eq $SERVICE_TO_ADD, 'Octopussy::ServiceGroup::Add_Service()');

my $rank = Octopussy::ServiceGroup::Move_Service($SG_ID, $service_added, 'up');
ok($rank eq '03', 'Octopussy::ServiceGroup::Move_Service()');

Octopussy::ServiceGroup::Remove_Service($SG_ID, $service_added);
my @services2 = Octopussy::ServiceGroup::Services($SG_ID);
ok(
  scalar @services == scalar @services2,
  'Octopussy::ServiceGroup::Remove_Service()'
);

Octopussy::ServiceGroup::Remove($SG_ID);
my @list4 = Octopussy::ServiceGroup::List();
ok(scalar @list4 == scalar @list1, 'Octopussy::ServiceGroup::Remove()');

# 3 Tests for invalid servicegroup name
foreach my $name (undef, '', 'servicegroup with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::ServiceGroup::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::ServiceGroup::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid servicegroup name
foreach my $name ('valid-servicegroup', 'valid_servicegroup')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::ServiceGroup::Valid_Name($name);
    ok($is_valid,
        'Octopussy::ServiceGroup::Valid_Name(' . $param_str . ") => $is_valid");
}

unlink $SG_FILE;

done_testing(8 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
