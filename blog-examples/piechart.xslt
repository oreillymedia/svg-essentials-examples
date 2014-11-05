<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns="http://www.w3.org/2000/svg">

<xsl:output method="xml" 
  indent="yes"
  standalone="no"
  doctype-public = "-//W3C//DTD SVG 20001102//EN"
  doctype-system = "http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd"
/>

<xsl:template match="pie">

<svg width="100%" height="100%" viewBox="0 0 800 500"
  xmlns="http://www.w3.org/2000/svg">
  <title>SVG Pie Chart Built with XSLT from XML data</title>
  <g style="font-family: sans-serif; stroke:none; fill:black">
    <xsl:apply-templates select="slice"/>    
  </g>
</svg>
</xsl:template>

<xsl:template match="slice">

  <xsl:variable name="index" select="position()" />

  <xsl:variable name="total" select="sum(../slice/@percent)"/>
  <xsl:variable name="startAngle">
    <xsl:choose>
      <xsl:when test="preceding-sibling::slice">
        <xsl:value-of select="sum(preceding-sibling::slice/@percent)"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="factor" select="100.0 div $total"/>
  
  <!-- create the pie slice (needs some variables for ease of reading) -->
  <xsl:variable name="largeArc">
    <xsl:choose>
      <xsl:when test="($factor * @percent) &gt; 50">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="endAngle">
    <xsl:call-template name="toRadians">
      <xsl:with-param name="degrees" select="$factor * 3.6 * @percent"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="endSin">
    <xsl:call-template name="sin">
      <xsl:with-param name="x" select="$endAngle"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="endCos">
    <xsl:call-template name="cos">
      <xsl:with-param name="x" select="$endAngle"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="midDegrees">
    <xsl:value-of select="$factor * 3.6 * ($startAngle + @percent div 2)"/>
  </xsl:variable>
  
  <xsl:variable name="midAngle">
    <xsl:call-template name="toRadians">
      <xsl:with-param name="degrees" select="-90 + $midDegrees"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="midSin">
    <xsl:call-template name="sin">
      <xsl:with-param name="x" select="$midAngle"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="midCos">
    <xsl:call-template name="cos">
      <xsl:with-param name="x" select="$midAngle"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="rotation">
    <xsl:value-of select="-90 + 360 * ($factor * $startAngle) div 100"/>
  </xsl:variable>

  
<g id="#slice{$index}" >
  <path  
   transform="translate(250, 250) rotate({$rotation})" 
    d="M 0 0 L 150 0 A150 150  0 {$largeArc} 1
    {150 * $endCos} {150 * $endSin} L 0 0 Z"
    style="fill: {@colour}; stroke: black" >

    <animate attributeName="stroke"
        attributeType="CSS"
        values="black;darkred;darkred;black"
        dur="3s"
        keyTimes="0;0.2;0.8;1"
        begin="highlight{$index}.begin" 
        end="highlight{$index}.end" /> 

    <animate attributeName="stroke-width"
        attributeType="CSS"
        values="1;5;5;1"
        dur="3s"
        keyTimes="0;0.2;0.8;1"
        begin="highlight{$index}.begin" 
        end="highlight{$index}.end" /> 

  </path>
  
  <xsl:if test="@percent &gt; 2">
    <xsl:variable name="anchor">
      <xsl:choose>
        <xsl:when test="$midDegrees &lt; 180">start</xsl:when>
        <xsl:otherwise>end</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
        
    <text transform="translate(250, 250)"
      style="text-anchor: {$anchor}"
      x="{160 * $midCos}" y="{160 * $midSin}">
      <xsl:value-of select="@percent"/><xsl:text>%</xsl:text>
    </text>
  </xsl:if>
</g>

  <!-- now add to the legend on right hand side -->
  <xsl:variable name="y" select="position() * 25" />
  <a xlink:href="#slice{$index}" id="legend{$index}">
    <rect x="500" y="{$y}" width="15" height="15"
      style="stroke:black; fill: {@colour}"/>
    <text x="520" y="{$y + 12}" style="font-size:12pt">
      <xsl:value-of select="@label"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@percent"/>
      <xsl:text>%)</xsl:text>
    </text>

    <set id="highlight{$index}" attributeName="fill"
        attributeType="CSS"
        to="darkred"
        begin="click; focus; mouseover;" 
        end="click + 3s; blur; mouseout;" /> 
  </a>
</xsl:template>

<!--
  Utility template to convert degrees to radians
-->
<xsl:template name="toRadians">
  <xsl:param name="degrees"/>
  <xsl:value-of select="3.141592653 * $degrees div 180.0"/>
</xsl:template>

<!--
  Use a Maclaurin series expansion to calculate
  sin and cos; the parameters allow me to use a single
  helper template that recursively calls itself until
  the next estimate is less than 0.0001 from the previous
  estimate.
-->
<xsl:template name="sin">
  <xsl:param name="x"/>
  <xsl:call-template name="trigHelper">
    <xsl:with-param name="x" select="$x"/>
    <xsl:with-param name="sum" select="$x - $x * $x * $x div 6"/>
    <xsl:with-param name="numerator" select="$x * $x * $x"/>
    <xsl:with-param name="denominator" select="6"/>
    <xsl:with-param name="factorial" select="3"/>
    <xsl:with-param name="sign" select="1"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="cos">
  <xsl:param name="x"/>
  <xsl:call-template name="trigHelper">
    <xsl:with-param name="x" select="$x"/>
    <xsl:with-param name="sum" select="1 - $x * $x div 2"/>
    <xsl:with-param name="numerator" select="$x * $x"/>
    <xsl:with-param name="denominator" select="2"/>
    <xsl:with-param name="factorial" select="2"/>
    <xsl:with-param name="sign" select="1"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="trigHelper">
  <xsl:param name="x" select="0"/>
  <xsl:param name="sum" select="0"/>
  <xsl:param name="numerator" select="0"/>
  <xsl:param name="denominator" select="2"/>
  <xsl:param name="factorial" select="1"/>
  <xsl:param name="sign" select="1"/>
  <xsl:variable name="d2" select="$denominator * ($factorial + 1) * ($factorial + 2)"/>
  <xsl:variable name="n2" select="$numerator * $x * $x"/> 
  <xsl:variable name="next" select="$sum + $sign * $n2 div $d2"/>
  <!--
  <xsl:message>
    <xsl:value-of select="$x"/><xsl:text> </xsl:text>
    <xsl:value-of select="$sum"/><xsl:text> </xsl:text>
    <xsl:value-of select="$numerator"/><xsl:text> </xsl:text>
    <xsl:value-of select="$denominator"/><xsl:text> </xsl:text>
    <xsl:value-of select="$factorial"/><xsl:text> </xsl:text>
    <xsl:value-of select="$sign"/><xsl:text> </xsl:text>
    <xsl:value-of select="$d2"/><xsl:text> </xsl:text>
    <xsl:value-of select="$n2"/><xsl:text> </xsl:text>
    <xsl:value-of select="$next"/><xsl:text> </xsl:text>
  </xsl:message>
  -->
  <xsl:choose>
    <xsl:when test="(($sum - $next) &gt; -0.00001) and (($sum - $next) &lt; 0.00001)">
      <xsl:value-of select="$next"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="trigHelper">
        <xsl:with-param name="x" select="$x"/>
        <xsl:with-param name="sum" select="$next"/>
        <xsl:with-param name="numerator" select="$n2"/>
        <xsl:with-param name="denominator" select="$d2"/>
        <xsl:with-param name="factorial" select="$factorial + 2"/>
        <xsl:with-param name="sign" select="-$sign"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- discard any text nodes -->
<xsl:template match="text()"/>

<!-- don't automatically scan all elements -->
<xsl:template match="*"/>

</xsl:stylesheet>
