#!/usr/bin/perl

#
#	Imagemagick's mogrify and convert was too slow for batch image conversion. 
#	Epeg is 4 times faster than mogrify/convert and the filesize is also much smaller.
#	
#	Epeg info:
#	http://leocharre.com/articles/faster-image-resizing-in-linux/
#	http://cpan.uwinnipeg.ca/htdocs/Image-Epeg/Image/Epeg.pm.html	 
#	https://github.com/mattes/epeg
#
use strict;
use warnings;

use constant MAINTAIN_ASPECT_RATIO => 1;
use constant IMG_QUALITY => 70;
use Image::Epeg qw(:constants);

my $src=$ARGV[0];
my $dst=$ARGV[1];

print "Creating $dst \n \n";

my $epg = new Image::Epeg( $src );
$epg->resize( 800, 600, MAINTAIN_ASPECT_RATIO );
$epg->set_quality( IMG_QUALITY );
$epg->write_file( $dst );
