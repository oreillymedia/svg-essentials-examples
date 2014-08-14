<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns="http://www.w3.org/2000/svg">

<xsl:output method="xml" 
  indent="yes"
  standalone="no"
  doctype-public = "-//W3C//DTD SVG 20001102//EN"
    doctype-system =
  "http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd"
/>

<xsl:template match="current_observation">
<svg width="350" height="200" viewBox="0 0 350 200"
  xmlns="http://www.w3.org/2000/svg">
  <g style="font-family: sans-serif">
  
  <!-- Process all child elements -->
  <xsl:apply-templates />
  </g>
</svg>
</xsl:template>

<xsl:template match="station_id">
 <text font-size="10pt" x="10" y="20">
    <xsl:value-of select="."/>
  </text>
</xsl:template>

<xsl:template match="temp_c">
  <xsl:call-template name="draw-thermometer">
    <xsl:with-param name="t" select="."/>
  </xsl:call-template>
</xsl:template>


<xsl:template name="draw-thermometer">
  <xsl:param name="t" select="0"/>
  <g id="thermometer" transform="translate(10, 40)">

  <path id="thermometer-path" stroke="black" fill="none"
    d= "M 25 0 25 90 A 10 10 0 1 0 35 90 L 35 0 Z"/>
    
  <g id="thermometer-text" font-size="8pt" font-family="sans-serif">
    <text x="20" y="95" text-anchor="end">-40</text>
    <text x="20" y="55" text-anchor="end">0</text>
    <text x="20" y="5" text-anchor="end">50</text>
    <text x="10" y="110" text-anchor="end">C</text>
    <text x="40" y="95">-40</text>
    <text x="40" y="55">32</text>
    <text x="40" y="5">120</text>
    <text x="50" y="110">F</text>
    <text x="30" y="130" text-anchor="middle">Temp.</text>
  
    <text x="30" y="145" text-anchor="middle">
      <xsl:choose>
        <xsl:when test="$t != ''">
          <xsl:value-of select="round($t)"/>&#176;C /
          <xsl:value-of select="round($t div 5 * 9 + 32)"/>&#176;F
        </xsl:when>
        <xsl:otherwise>N/A</xsl:otherwise>
      </xsl:choose>
    </text>
  </g>

  <xsl:if test="$t != ''">
    <xsl:variable name="tint">
    <xsl:choose>
      <xsl:when test="$t > 0">red</xsl:when>
      <xsl:otherwise>blue</xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    
    <!-- "fill" the thermometer by drawing a solid
      rectangle and clipping it to the shape of
      the thermometer -->
    <xsl:variable name="h">
      <xsl:choose>
        <xsl:when test="$t &lt; -55">
          <xsl:value-of select="105"/>
        </xsl:when>
        <xsl:when test="$t &gt; 50">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="50 - $t"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <clipPath id="thermoclip">
      <use xlink:href="#thermometer-path"/>
    </clipPath>
    <path d="M 10 {$h} h40 V 120 h-40 Z"
      style="fill: {$tint}" clip-path="url(#thermoclip)"/>
  </xsl:if>
  
</g>
</xsl:template>

<!-- discard any text nodes -->
<xsl:template match="text()"/>

<!-- don't automatically scan all elements -->
<xsl:template match="*"/>

</xsl:stylesheet>

