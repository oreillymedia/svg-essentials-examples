#!/usr/bin/perl

use File::Find;

my $base = "./";
my %toc = ();
my @months = qw(Jan Feb Mar Apr May Jun
  Jul Aug Sep Oct Nov Dec);
my @files;
my @info;

find(\&wanted, $base);

foreach my $dir (sort keys %toc) {
  open OUTFILE, ">$dir/index.html";
  
  print OUTFILE <<"HTML_PRELUDE";
<!DOCTYPE html>
<html xml:lang="en" lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Chapter $dir</title>
    <link rel="stylesheet" type="text/css" href="../style.css"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1>$dir</h1>
<table>
  <thead>
    <tr>
      <th>File</th><th>Last Modified</th><th>Size</th>
    </tr>
  </thead>
  <tbody>
HTML_PRELUDE
  @files = sort by_file_name @{$toc{$dir}};
  
  foreach my $item (@files) {
    @info = @{$item};
    print OUTFILE <<"TABLE_ROW";
    <tr>
      <td><a href="$info[0]">$info[0]</a></td>
      <td>$info[1]</td><td style="text-align:right">$info[2]</td>
    </tr>
TABLE_ROW
  }
  
  print OUTFILE <<"HTML_POSTLUDE";
  </tbody>
</table>
</body>
</html>
HTML_POSTLUDE
  close OUTFILE;
}

sub by_file_name {
  my @arr_a = @{$a};
  my @arr_b = @{$b};
  return (uc($arr_a[0]) cmp uc($arr_b[0]));
}

sub wanted {
  my $dir = $File::Find::dir;
  my $filename = $_;
  my @info;
  my @dt;
  my $date_time;
  
  $dir =~ s!$base!!;
  if ($dir =~ m/^ch\d\d$/) {
    @info = stat($filename);
    @dt = gmtime($info[9]); # modification time
    $date_time = sprintf("%02d-%s-%04d %02d:%02d",
      $dt[3], $months[$dt[4]], $dt[5] + 1900, $dt[2], $dt[1]);
    push @{$toc{$dir}}, [$filename, $date_time, $info[7]];
  }
}
