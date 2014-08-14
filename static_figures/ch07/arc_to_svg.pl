#!/usr/bin/perl

#
#   Convert an elliptical arc based around a central point
#   to an elliptical arc parameterized for SVG.
#
#   Input is a list containing:
#       center x coordinate
#       center y coordinate
#       x-radius of ellipse
#       y-radius of ellipse
#       beginning angle of arc in degrees
#       arc extent in degrees
#       x-axis rotation angle in degrees
#
#   Output is a list containing:
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
sub convert_to_svg
{
    my ($cx, $cy, $rx, $ry, $theta1, $delta, $phi) = @_;
    my ($theta2, $pi);
    my ($x0, $y0, $x1, $y1, $large_arc, $sweep);

    #
    #   Convert angles to radians
    #
    $pi = atan2(1,1) * 4;       # approximation of pi

    $theta2 = $delta + $theta1;
    $theta1 = $theta1 * $pi / 180.0;
    $theta2 = $theta2 * $pi / 180.0;
    $phi_r = $phi * $pi / 180.0;

    #
    #   Figure out the coordinates of the beginning and
    #   ending points
    #
    $x0 = $cx + cos($phi_r) * $rx * cos($theta1) +
        sin(-$phi_r) * $ry * sin($theta1);
    $y0 = $cy + sin($phi_r) * $rx * cos($theta1) +
        cos($phi_r) * $ry * sin($theta1);

    $x1 = $cx + cos($phi_r) * $rx * cos($theta2) +
        sin(-$phi_r) * $ry * sin($theta2);
    $y1 = $cy + sin($phi_r) * $rx * cos($theta2) +
        cos($phi_r) * $ry * sin($theta2);

    $large_arc = ($delta > 180) ? 1 : 0;
    $sweep = ($delta > 0) ? 1 : 0;
    
    return ($x0, $y0, $rx, $ry, $phi, $large_arc, $sweep, $x1, $y1);
}

#
#   Request input
#
print "Enter center x,y coordinates > ";
$data = <>;
$data =~ s/,/ /g;
($cx, $cy) = split /\s+/, $data;

print "Enter x and y radii > ";
$data = <>;
$data =~ s/,/ /g;
($rx, $ry) = split/\s+/, $data;

print "Enter starting angle in degrees > ";
$theta = <>;
chomp $theta;

print "Enter angle extent in degrees > ";
$delta = <>;
chomp $delta;

print "Enter angle of rotation in degrees > ";
$phi = <>;
chomp $phi;

#
#   Echo original data
#
print "(cx,cy)=($cx,$cy)  rx=$rx ry=$ry ",
    "start angle=$theta extent=$delta rotate=$phi\n";

($x0, $y0, $rx, $ry, $phi, $large_arc_flag, $sweep_flag, $x1, $y1) =
    convert_to_svg( $cx, $cy, $rx, $ry, $theta, $delta, $phi);

#
#   Produce a <path> element that fits the
#   specifications
#
print "<path d=\"M $x0 $y0 ",   # Moveto initial point
    "A $rx $ry ",               # Arc command and radii,
    "$phi ",                    # angle of rotation,
    "$large_arc_flag ",         # the "large-arc" flag,
    "$sweep_flag ",             # the "sweep" flag,
    "$x1 $y1\"/>\n";            # and the endpoint
