#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Plugin::Proxy - Octopussy Plugin Proxy

=cut

package Octopussy::Plugin::Proxy;

use strict;
use Octopussy;

my @mimes = ();

=head1 FUNCTIONS

=head2 Init()

=cut

sub Init
{
	my $mime_conf = AAT::List::Configuration("AAT_Mime");
	
  foreach my $i (AAT::ARRAY($mime_conf->{item}))
  {
    push(@mimes, { label => $i->{label},
      logo => $i->{logo}, regexp => qr/$i->{regexp}/i })
			if (AAT::NOT_NULL($i->{regexp}));
  }
}

=head2 Cache_Status($str)

=cut

sub Cache_Status
{
	my $str = shift;

	return ("Cached")	if ($str =~ /.+_HIT.*/);
	return ("Not Cached");
}

=head2 Logo($logo, $alt)

=cut

sub Logo($$)
{
  my ($logo, $alt) = @_;

  return ("<img src=\"AAT/IMG/${logo}.png\" alt=\"$alt\"><b>$alt</b>");
  return ($alt);
}

=head2 Mime($str) 

=cut

sub Mime($)
{
	my $str = shift;

  foreach my $i (@mimes)
  {
    return (Logo("web_mime/" . ($i->{logo} || ""), $i->{label})) 
			if ((defined $i->{regexp}) && ($str =~ /$i->{regexp}/));
  }

  return ($str);
}

=head2 TLD($url)

=cut

sub TLD
{
	my $url = shift;

	if (($url =~ /^(https?:\/\/)?[^\/]*\.([a-z]{2,4})(:\d+)*$/i)       
		|| ($url =~ /^(https?:\/\/)?[^\/]*\.([a-z]{2,4})(:\d+)*\/.*$/i))
	{
		my $tld = $2;
		return (Logo("flags/$tld", $tld)) if (-f "AAT/IMG/flags/$tld.png");
		return ($tld);
	}
	return ($url);
}

=head2 WebSite($url)

=cut

sub WebSite
{
	my $url = shift;

	return ($3)	if (($url =~ /^(https?:\/\/)?[^\/]*?(\.)?(\d+\.\d+\.\d+\.\d+)(:\d+)*$/i)
		|| ($url =~ /^(https?:\/\/)?[^\/]*?(\.)?([a-z0-9_-]+\.[a-z]+)(:\d+)*$/i)
    || ($url =~ /^(https?:\/\/)?[^\/]*?(\.)?([a-z0-9_-]+\.[a-z]+)(:\d+)*\/.*$/i));

	return ($url);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
