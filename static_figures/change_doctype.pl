#!/usr/bin/perl

use File::Find;

find(\&changetype, ".");

sub changetype
{
  my $data;
  my $filename = $_;
  if ($filename =~ m/\.svg$/) {
    print STDERR "Analyzing $filename\n";
    open OUTFILE, ">/tmp/temp.svg";
    open INFILE, $filename;
    while ($data = <INFILE>) {
      $data =~ s!PUBLIC "-//W3C//DTD SVG 1.0//EN"!PUBLIC "-//W3C//DTD SVG 1.1//EN"!;
      $data =~ s! "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"!"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"!;
      $data =~ s!PUBLIC "-//W3C//DTD SVG 20001102//EN"!PUBLIC "-//W3C//DTD SVG 1.1//EN"!;
      $data =~ s!"http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd"! "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"!;

      print OUTFILE $data;
    }
    close INFILE;
    close OUTFILE;
    system("mv /tmp/temp.svg $filename");
  }
}
