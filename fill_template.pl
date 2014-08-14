#!/usr/bin/perl

use strict;

my %vars;
my $varname;
my $buf;
my $data;
my $temp;

while ($data = <STDIN>)
{
  chomp $data;
  if (($temp) = $data =~ m/^(\w+)::/)
  {
    closebuf();
    $buf = $data;
    $buf =~ s/^\w+::\s*//;
    $varname = $temp;
  }
  elsif ($data =~ m/^!fill/)
  {
    closebuf();
    fill_template();
  }
  elsif ($data =~ m/^\s*#/)
  {
    # do nothing
  }
  else
  {
    $buf .= "\n" . $data;
  }
}

sub closebuf
{
  if ($buf && $varname)
  {
    $vars{$varname} = encode($buf);
    $varname = "";
  }
}

sub fill_template
{
  my $data;
  my $fill_var;
  
  open TEMPLATEFILE, $vars{'template'};
  open OUTFILE, '>', $vars{'output'};

  while ($data = <TEMPLATEFILE>)
  {
    while (($fill_var) = $data =~ m/\$(\w+)/)
    {
      $data =~ s/\$$fill_var/$vars{$fill_var}/;
    }
    print OUTFILE $data;
  }
  close OUTFILE;
  close TEMPLATEFILE;
}

sub encode
{
  my $buf = shift;
  $buf =~ s/^\s+//;
  $buf =~ s/&/\&amp;/g;
  $buf =~ s/</\&lt;/g;
  $buf =~ s/>/\&gt;/g;
  $buf =~ s/\{\{/</g;
  $buf =~ s/\}\}/>/g;
  return $buf;
}
