# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::Application - AAT Application module

=cut

package AAT::Application;

use strict;
use warnings;

use AAT::Utils qw( ARRAY );
use AAT::XML;

my $AAT_CONF_FILE = '/etc/aat/aat.xml';

=head1 FUNCTIONS

=head2 Set_Config_File($file)

=cut

sub Set_Config_File
{
	my $file = shift;
	
    $AAT_CONF_FILE = $file;    	
}


=head2 Info($appli)

Returns Application Information

=cut

sub Info
{
  my $appli = shift;

  my $conf = AAT::XML::Read($AAT_CONF_FILE);
  foreach my $a (ARRAY($conf->{application}))
  {
    return ($a) if ($a->{name} eq $appli);
  }

  return (undef);
}

=head2 Directory($appli, $name)

Returns Directory for Application '$appli' Name '$name'

=cut

sub Directory
{
  my ($appli, $name) = @_;
  
  my $conf = AAT::XML::Read($AAT_CONF_FILE);
  foreach my $a (ARRAY($conf->{application}))
  {
    if ($a->{name} eq $appli)
    {
      foreach my $d (ARRAY($a->{directory}))
      {
        return ($d->{value}) if ($d->{name} eq $name);
      }
    }
  }

  return (undef);
}

=head2 File($appli, $name)

Returns File for Application '$appli' Name '$name'

=cut

sub File
{
  my ($appli, $name) = @_;
  my $conf = AAT::XML::Read($AAT_CONF_FILE);
  foreach my $a (ARRAY($conf->{application}))
  {
    if ($a->{name} eq $appli)
    {
      foreach my $f (ARRAY($a->{file}))
      {
        return ($f->{value}) if ($f->{name} eq $name);
      }
    }
  }

  return (undef);
}

=head2 Parameter($appli, $param)

Returns Parameter Default Value for Application '$appli' Parameter '$param'

=cut

sub Parameter
{
  my ($appli, $param) = @_;
  my $conf = AAT::XML::Read($AAT_CONF_FILE);
  foreach my $a (ARRAY($conf->{application}))
  {
    if ($a->{name} eq $appli)
    {
      foreach my $p (ARRAY($a->{parameter}))
      {
        return ($p->{value}) if ($p->{name} eq $param);
      }
    }
  }

  return (undef);
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
