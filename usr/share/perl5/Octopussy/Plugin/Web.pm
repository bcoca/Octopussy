#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Plugin::Web - Octopussy Plugin Web

=cut

package Octopussy::Plugin::Web;

use strict;
use Octopussy;

my @browsers = ();
my @operating_systems = ();

=head1 FUNCTIONS

=head2 Init()

=cut

sub Init
{
	my $bot_conf = AAT::List::Configuration("AAT_Bot");
	my $browser_conf = AAT::List::Configuration("AAT_Browser");
	my $mobile_conf = AAT::List::Configuration("AAT_MobilePhone");
	my $os_conf = AAT::List::Configuration("AAT_Operating_System");
	
	my @list =
    (AAT::ARRAY($browser_conf->{item}), AAT::ARRAY($mobile_conf->{item}),
    AAT::ARRAY($bot_conf->{item}));
  foreach my $i (@list)
  {
    push(@browsers, { label => $i->{label},
      logo => $i->{logo}, regexp => qr/$i->{regexp}/ })
			if (AAT::NOT_NULL($i->{regexp}));
  }
	foreach my $i (AAT::ARRAY($os_conf->{item}))
  {
    push(@operating_systems, { label => $i->{label},
      logo => $i->{logo}, regexp => qr/$i->{regexp}/ })
			if (AAT::NOT_NULL($i->{regexp}));
  }
}

=head2 Logo($logo, $alt)

=cut

sub Logo($$)
{
	my ($logo, $alt) = @_;

	my $file = "AAT/IMG/${logo}.png";
	
	return ("<img src=\"$file\" alt=\"$alt\"><b>$alt</b>"); 
	return ($alt);
}

=head2 UserAgent_Browser($ua)

=cut

sub UserAgent_Browser($)
{
	my $ua = shift;
	
	foreach my $i (@browsers)
	{
		if ((defined $i->{regexp}) && ($ua =~ /$i->{regexp}/))
		{
			return (Logo("$i->{logo}", $i->{label}))
				if (defined $i->{logo});
			return ($i->{label});
		}
	}

	return ($ua);
}

=head2 UserAgent_OS($ua)

=cut

sub UserAgent_OS($)
{
	my $ua = shift;

  foreach my $i (@operating_systems)
  {
    return (Logo(($i->{logo} || ""), $i->{label})) 
			if ((defined $i->{regexp}) && ($ua =~ /$i->{regexp}/));
  }

  return ($ua);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
