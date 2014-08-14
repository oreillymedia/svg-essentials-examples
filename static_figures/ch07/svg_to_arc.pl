#!/usr/bin/perl

sub acos
{
    atan2( sqrt(1 - $_[0] * $_[0]), $_[0] );
}

#
#   Convert an elliptical arc parameterized for SVG
#   to an elliptical arc based around a central point.
#
#   Input is a list containing:
#
#       x-coordinate of beginning of arc
#       y-coordinate of beginning of arc
#       x-radius of ellipse
#       y-radius of ellipse
#       large-arc-flag as defined in SVG specification
#       sweep-flag  as defined in SVG specification
#       x-coordinate of endpoint of arc
#       y-coordinate of endpoint of arc
#
#   Output is a list containing:
#       center x coordinate
#       center y coordinate
#       x-radius of ellipse
#       y-radius of ellipse
#       beginning angle of arc in degrees
#       arc extent in degrees
#       x-axis rotation angle in degrees
#

sub convert_from_svg
{
    my ($x0, $y0, $rx, $ry, $phi, $large_arc, $sweep, $x, $y) = @_;
    my ($cx, $cy, $theta, $delta, $phi);
    
    # a plethora of temporary variables 
    my (
        $dx2, $dy2, $phi_r, $x1, $y1,
        $rx_sq, $ry_sq,
        $x1_sq, $y1_sq,
        $sign, $sq, $coef,
        $cx1, $cy1, $sx2, $sy2,
        $p, $n,
        $ux, $uy, $vx, $vy
    );
        
    # Compute 1/2 distance between current and final point
    $dx2 = ($x0 - $x) / 2.0;
    $dy2 = ($y0 - $y) / 2.0;

    # Convert from degrees to radians
    $pi = atan2(1, 1) * 4.0;
    $phi %= 360;
    $phi_r = $phi * $pi / 180.0;

    # Compute (x1, y1)
    $x1 = cos($phi_r) * $dx2 + sin($phi_r) * $dy2;
    $y1 = -sin($phi_r) * $dx2 + cos($phi_r) * $dy2;

    # Make sure radii are large enough
    $rx = abs($rx); $ry = abs($ry);
    $rx_sq = $rx * $rx;
    $ry_sq = $ry * $ry;
    $x1_sq = $x1 * $x1;
    $y1_sq = $y1 * $y1;

    $radius_check = ($x1_sq / $rx_sq) + ($y1_sq / $ry_sq);
    if ($radius_check > 1)
    {
        $rx *= sqrt($radius_check);
        $ry *= sqrt($adius_check);
        $rx_sq = $rx * $rx;
        $ry_sq = $ry * $ry;
    }

    # Step 2: Compute (cx1, cy1)

    $sign = ($large_arc == $sweep) ? -1 : 1;
    $sq = (($rx_sq * $ry_sq) - ($rx_sq * $y1_sq) - ($ry_sq * $x1_sq)) /
        (($rx_sq * $y1_sq) + ($ry_sq * $x1_sq));
    $sq = ($sq < 0) ? 0 : $sq;
    $coef = ($sign * sqrt($sq));
    $cx1 = $coef * (($rx * $y1) / $ry);
    $cy1 = $coef * -(($ry * $x1) / $rx);

    #   Step 3: Compute (cx, cy) from (cx1, cy1)

    $sx2 = ($x0 + $x) / 2.0;
    $sy2 = ($y0 + $y) / 2.0;

    $cx = $sx2 + (cos($phi_r) * $cx1 - sin($phi_r) * $cy1);
    $cy = $sy2 + (sin($phi_r) * $cx1 + cos($phi_r) * $cy1);

    #   Step 4: Compute angle start and angle extent

    $ux = ($x1 - $cx1) / $rx;
    $uy = ($y1 - $cy1) / $ry;
    $vx = (-$x1 - $cx1) / $rx;
    $vy = (-$y1 - $cy1) / $ry;
    $n = sqrt( ($ux * $ux) + ($uy * $uy) );
    $p = $ux; # 1 * ux + 0 * uy
    $sign = ($uy < 0) ? -1 : 1;

    $theta = $sign * acos( $p / $n );
    $theta = $theta * 180 / $pi;

    $n = sqrt(($ux * $ux + $uy * $uy) * ($vx * $vx + $vy * $vy));
    $p = $ux * $vx + $uy * $vy;
    $sign = (($ux * $vy - $uy * $vx) < 0) ? -1 : 1;
    $delta = $sign * acos( $p / $n );
    $delta = $delta * 180 / $pi;

    if ($sweep == 0 && $delta > 0)
    {
        $delta -= 360;
    }
    elsif ($sweep == 1 && $delta < 0)
    {
        $delta += 360;
    }

    $delta %= 360;
    $theta %= 360;
    
    return ($cx, $cy, $rx, $ry, $theta, $delta, $phi);
}
     
#
#   Request input
#
print "Enter starting x,y coordinates > ";
$data = <>;
$data =~ s/,/ /g;
($x0, $y0) = split /\s+/, $data;

print "Enter ending x,y coordinates > ";
$data = <>;
$data =~ s/,/ /g;
($x, $y) = split /\s+/, $data;

print "Enter x and y radii > ";
$data = <>;
$data =~ s/,/ /g;
($rx, $ry) = split/\s+/, $data;

print "Enter rotation angle in degrees ";
$phi = <>;
chomp $phi;

print "Large arc flag (0=no, 1=yes) > ";
$large_arc = <>;
chomp $large_arc;

print "Sweep flag (0=negative, 1=positive) > ";
$sweep = <>;
chomp $sweep;

print "From ($x0,$y0) to ($x,$y) rotate $phi",
    " large arc=$large_arc sweep=$sweep\n";

($cx, $cy, $rx, $ry, $theta, $delta, $phi) =
    convert_from_svg( $x0, $y0, $rx, $ry, $phi, $large_arc, $sweep, $x, $y );

print "Ellipse center = ($cx, $cy)\n";
print "Start angle = $theta\n";
print "Angle extent = $delta\n";
