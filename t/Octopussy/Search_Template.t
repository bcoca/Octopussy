#!/usr/bin/perl

=head1 NAME

t/Octopussy/Search_Template.t - Test Suite for Octopussy::Search_Template module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use List::MoreUtils qw(true);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::Search_Template;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $DIR_TPLS    => Octopussy::FS::Directory('search_templates');
Readonly my $PREFIX         => 'Octo_TEST_';
Readonly my $USER           => "${PREFIX}user";
Readonly my $DEVICE         => "${PREFIX}device";
Readonly my $SERVICE        => "${PREFIX}service";
Readonly my $SRCH_TPL_TITLE => "${PREFIX}search_template";
Readonly my $FILE_TPL       => "${DIR_TPLS}${USER}/${SRCH_TPL_TITLE}.xml";
Readonly my $BEGIN_TPL      => '201001010000';
Readonly my $END_TPL        => '201001010010';

my %conf = (
  name        => $SRCH_TPL_TITLE,
  device      => [$DEVICE],
  service     => [$SERVICE],
  loglevel    => '-ANY-',
  taxonomy    => '-ANY-',
  msgid       => '-ANY-',
  begin       => $BEGIN_TPL,
  end         => $END_TPL,
  re_include  => 'incl1',
  re_include2 => 'incl2',
  re_include3 => 'incl3',
  re_exclude  => 'excl1',
  re_exclude2 => 'excl2',
  re_exclude3 => 'excl3',
);

unlink $FILE_TPL;

my @list1 = Octopussy::Search_Template::List($USER);

Octopussy::Search_Template::New($USER, \%conf);
ok(-f $FILE_TPL, 'Octopussy::Search_Template::New()');

my @list2 = Octopussy::Search_Template::List($USER);
ok((scalar @list1 == scalar @list2 - 1) && (grep { /$SRCH_TPL_TITLE/ } @list2),
  'Octopussy::Search_Template::List()');

my @list3 = Octopussy::Search_Template::List_Any_User();
ok(
  (scalar @list3 >= scalar @list2)
    && (true { $_->{name} =~ /^$SRCH_TPL_TITLE$/ } @list3),
  'Octopussy::Search_Template::List_Any_User()'
);

my $tconf = Octopussy::Search_Template::Configuration($USER, $SRCH_TPL_TITLE);
ok($tconf->{begin} eq $BEGIN_TPL && $tconf->{end} eq $END_TPL,
  'Octopussy::Search_Template::Configuration()');

Octopussy::Search_Template::Remove($USER, $SRCH_TPL_TITLE);
ok(!-f $FILE_TPL, 'Octopussy::Search_Template::Remove()');

# 3 Tests for invalid search_template name
foreach my $name (undef, '', 'template with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Search_Template::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Search_Template::Valid_Name(' 
		. $param_str . ") => $is_valid");
}

# 2 Tests for valid search_template name
foreach my $name ('valid-template', 'valid_template')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Search_Template::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Search_Template::Valid_Name(' 
		. $param_str . ") => $is_valid");
}

rmtree $DIR_TPLS;

done_testing(5 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
