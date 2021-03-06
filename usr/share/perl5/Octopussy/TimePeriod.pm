=head1 NAME

Octopussy::TimePeriod - Octopussy TimePeriod module

=cut

package Octopussy::TimePeriod;

use strict;
use warnings;

use Readonly;

use AAT::Utils qw( ARRAY HASH_KEYS NOT_NULL );
use AAT::XML;
use Octopussy::FS;

Readonly my $FILE_TIMEPERIODS => 'timeperiods';
Readonly my $XML_ROOT         => 'octopussy_timeperiods';
Readonly my $DIGIT_HOUR       => 100;

=head1 FUNCTIONS

=head2 New($conf)

Create a new Timeperiod

=cut

sub New
{
  my $new = shift;

  my $file = Octopussy::FS::File($FILE_TIMEPERIODS);
  my $conf = AAT::XML::Read($file);
  push @{$conf->{timeperiod}}, $new;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($file);
}

=head2 Remove($timeperiod)

Remove a Timeperiod

=cut

sub Remove
{
  my $timeperiod = shift;

  my $file = Octopussy::FS::File($FILE_TIMEPERIODS);
  my $conf = AAT::XML::Read($file);
  my @tps =
    grep { $_->{label} ne $timeperiod } ARRAY($conf->{timeperiod});
  $conf->{timeperiod} = \@tps;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($file);
}

=head2 List()

Returns List of Timeperiods

=cut

sub List
{
  my @tps = AAT::XML::File_Array_Values(Octopussy::FS::File($FILE_TIMEPERIODS),
    'timeperiod', 'label');

  return (@tps);
}

=head2 Configuration($tp_name)

=cut

sub Configuration
{
  	my $tp_name = shift;

	return (undef)	if (!defined $tp_name);

  	my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TIMEPERIODS));
  	foreach my $tp (ARRAY($conf->{timeperiod}))
  	{
    	if ($tp->{label} eq $tp_name)
    	{
      		my $str = '';
      		foreach my $dt (ARRAY($tp->{dt}))
      		{
        		foreach my $k (HASH_KEYS($dt))
        		{
          			if ($k =~ /^(\S{3})\S+/)
          			{
            			$str .= "$1: $dt->{$k}, ";
          			}
        		}
      		}
      		$str =~ s/, $//;

      		return ({label => $tp->{label}, periods => $str});
    	}
  	}

  	return (undef);
}

=head2 Configurations($sort)

Returns TimePeriods COnfigurations sorted by '$sort' (default: 'label')

=cut

sub Configurations
{
  my $sort = shift || 'label';
  my (@configurations, @sorted_configurations) = ((), ());
  my @tps = List();

  foreach my $tp (@tps)
  {
    my $conf = Configuration($tp);
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Match($timeperiod, $datetime)

Checks if $datetime (format: 'dayname hour:min') matches TimePeriod $timeperiod

=cut

sub Match
{
  my ($timeperiod, $datetime) = @_;

  return (1) if ((!defined $timeperiod) || ($timeperiod =~ /-ANY-/));
  if ($datetime =~ /^(\S+) (\d+):(\d+)$/)
  {
    my ($day, $hour, $min) = ($1, $2, $3);
    my $nb   = $hour * $DIGIT_HOUR + $min;
    my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TIMEPERIODS));

    foreach
      my $tp (grep { $_->{label} eq $timeperiod } ARRAY($conf->{timeperiod}))
    {
      foreach my $dt (ARRAY($tp->{dt}))
      {
        foreach my $k (grep { $_ eq $day } HASH_KEYS($dt))
        {

          if ($dt->{$k} =~ /^\!(\d+):(\d+)-(\d+):(\d+)$/)
          {
            return (1)
              if (($nb < ($1 * $DIGIT_HOUR + $2))
              || ($nb > ($3 * $DIGIT_HOUR + $4)));
          }
          elsif ($dt->{$k} =~ /^(\d+):(\d+)-(\d+):(\d+)$/)
          {
            return (1)
              if (($nb > ($1 * $DIGIT_HOUR + $2))
              && ($nb < ($3 * $DIGIT_HOUR + $4)));
          }

        }
      }
    }
  }

  return (0);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for a TimePeriod name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1)  if ((NOT_NULL($name)) && ($name =~ /^[a-z0-9][a-z0-9_-]*$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
