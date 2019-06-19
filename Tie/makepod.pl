use strict;
use warnings;

use Pod::HtmlEasy;
my $podhtml = Pod::HtmlEasy->new ();
my $html = $podhtml->pod2html( 'LinkedHash.pm' );
open(my $fh, ">LinkedHash.html") or die $!;
print $fh $html;
close $fh;