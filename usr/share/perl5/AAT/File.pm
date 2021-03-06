# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::File - AAT File module

=cut

package AAT::File;

use strict;
use warnings;
use Readonly;

use AAT::Utils qw( NOT_NULL );

Readonly my $DIR_MIME_SMALL => 'THEMES/DEFAULT/mime/22x22';
Readonly my $DIR_MIME_BIG   => 'THEMES/DEFAULT/mime/128x128';

=head1 FUNCTIONS

=head2 Mime_Icon($file, $type)

=cut

sub Mime_Icon
{
  my ($file, $type) = @_;

  my $dir = (
    ((NOT_NULL($type)) && ($type =~ /BIG/i))
    ? $DIR_MIME_BIG
    : $DIR_MIME_SMALL
  );
  if ($file =~ /.+\.(\w+)$/)
  {
    my $ext = $1;
    return ("$dir/$ext.png")
      if ((defined $ext) && (-f "$dir/$ext.png"));
  }
  return ("$dir/DIRECTORY.png") if (-d $file);
  return ("$dir/FILE.png");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
