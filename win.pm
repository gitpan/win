package win;
$VERSION = '0.01';
require Exporter;
our @ISA = qw(Exporter);

sub import {

    my $class = shift;

    ($pkg) = (caller)[0];
    $current = __PACKAGE__;

    $default = <<"EOF";
use Win32;
use Win32::Autoglob;
use Win32::Die;
EOF

    $mods = "";

    &rerun unless (@_);

    my @list = split /,/, $_[0];

    foreach (@list) {
        $_ =~ s/^\s+//;
        $_ =~ s/\s+$//;
        $mods .= "use Win32::$_;\n";
    }

    &rerun;

}    

sub rerun {

    eval qq[
        package $pkg;
        $default;
        $mods;
        package $current;
    ];
    if ($@) {

        if ( $@ =~ /Can't locate/ ) {
            &ppmcall;
        }
        else {
            require Carp;
            Carp::croak("$@");

        }
    }
}

sub ppmcall {

    do {
        print "$@\n";
        print "Looks like you don't have the module you requested\n";
        print "Shall I have PPM fetch it for you? (y/n) ";
    } while ( ( $_ = <STDIN> ) && ( $_ !~ /y|n/i ) );

    unless ( $_ =~ /y/i ) {

        print "Bye!\n" and exit;

    }

    use File::Which qw(which);
    unless ( defined( which('ppm') ) ) {
        print <<'EOF';

Bad news: I can't find PPM in your path. 

Most likely PPM is on your system. 
Search for PPM and put its location in your path. Or you can download PPM 
from http://www.activestate.com. Look under their Perl section. 
Exiting ... 

EOF

        exit;
    }

    my (@ppmods) = $mods =~ /(Win32.*?);/g;
    foreach (@ppmods) {
        my $pm = $_;

        $pm =~ s/::/\//g;
        $pm = "$pm" . ".pm";

        my $found = 0;
        foreach (@INC) {
            $found++ if ( -e "$_/$pm" );
        }
        unless ($found) {
            print "Please wait ...\n";
            print "Activating PPM\n";
            my $ppm_results = `ppm install $_`;
            print "$ppm_results\n";
        }
    }

    print "PPM done. Goodbye.\n" and exit;

}
1;
__END__

=head1 NAME

win - Win32 programming and development tool

=head1 DESCRIPTION

The goal of win, the Perl Win32 programming tool, is to make Perl Win32 programming simpler, quicker, and less of a hassle. The win tool seeks to achieve its goal by:

1. Addressing the integration of Win32 modules.
2. Addressing Win32 idiosyncrasies.

You can call other Win32 modules via win and if your system doesn't have the module, win is polite enough to download and install the module for you (using PPM). 

By default, win also enables a handful of basic and useful Win32 modules, specifically Win32, Win32::Autoglob, and Win32::Die. You can think of win as a broom that sweeps the idiosyncrasies of Windows under the rug. It is good to know what those idiosyncrasies are, but sometimes you don't want to deal with them. If that's ever the case, then win is for you.

=head1 EXAMPLES

        # use Win32::OLE and Win32::API
 
        use win q(ole, api);    

        # just use the default modules    
     
        use win;

        # use Win32::OLE, Win32::API, and Win32::TieRegistry

        use win q(  ole,
                    api,
                    TieRegistry(Delimiter=>"/")
                 );

=head1 DEFAULTS

By default, win enables a few basic and useful Win32 modules. Originally, I planned for these modules to be optional. But none of them should interfere with other Win32 modules and they are relatively small. If you are concerned about the execution speed of your program, then you shouldn't be using the win tool anyway. 

Here's a listing of the default modules:

L<Win32>
L<Win32::Autoglob>
L<Win32::Die>

Please see their documentation for more information about them. More modules may be added in future releases.

=head1 NOTES

Observe that arguments to import are passed via q// and not qw//. Of course, you could also use single quotes, but I prefer not to. Commas are the delimiter because they seem more appropriate than spaces. Also commas, unlike spaces, are rarely used in import arguments. (I thought long and hard about the delimiter. So if you can think of a better solution, please email me.) 

The win tool is good for rapid prototyping and everyday Win32 scripting. I wouldn't recommend using it in distributed software, but no one is stopping you.

=head1 BUGS

None known

=head1 AUTHOR

Mike Accardo <mikeaccardo@yahoo.com>
Comments and suggestions welcomed

=head1 COPYRIGHT 

Copyright (c) 2003, Mike Accardo. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
