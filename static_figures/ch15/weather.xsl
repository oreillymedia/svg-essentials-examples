<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://www.w3.org/2000/svg">

  <xsl:output method="xml" indent="yes"
    doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system=
      "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

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
        <xsl:when test="$t &gt; 0">red</xsl:when>
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
        fill="{$tint}" clip-path="url(#thermoclip)"/>
    </xsl:if>

  </g>
  </xsl:template>
  
  <xsl:template match="observation_time_rfc822">
    <xsl:variable name="time" select="."/>
    
    <text font-size="10pt" x="345" y="20" text-anchor="end">
      <xsl:value-of select="substring($time, 6, 11)"/>
    </text>

    <xsl:call-template name="draw-time-and-clock">
      <xsl:with-param name="hour"
        select="number(substring($time, 18, 2))"/>
      <xsl:with-param name="minute"
        select="number(substring($time, 21, 2))"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="draw-time-and-clock">
    <xsl:param name="hour">0</xsl:param>
    <xsl:param name="minute">0</xsl:param>
    
    <!-- clock face is light yellow from 6 AM to 6 PM, 
        otherwise light blue -->
    <xsl:variable name="tint">
      <xsl:choose>
        <xsl:when test="$hour &gt;= 6 and $hour &lt; 18"
            >#ffffcc</xsl:when>
        <xsl:otherwise>#ccccff</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- calculate angles for hour and minute hand
      of analog clock -->
    <xsl:variable name="hourAngle"
      select="(30 * ($hour mod 12 + $minute div 60)) - 90"/>
    <xsl:variable name="minuteAngle"
      select="($minute * 6) - 90"/>

    <text font-size="10pt" x="345" y="40" text-anchor="end">
      <xsl:value-of select="format-number($hour,'00')"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="format-number($minute,'00')"/>
    </text>
    <g id="clock" transform="translate(255, 30)">
      <circle cx="20" cy="20" r="20" fill="{$tint}" 
              stroke="black"/>
      <line transform="rotate({$minuteAngle}, 20, 20)"
        x1="20" y1="20" x2="38" y2="20" stroke="black"/>
      <line transform="rotate({$hourAngle}, 20, 20)"
        x1="20" y1="20" x2="33" y2="20" stroke="black"/>
    </g>
  </xsl:template>

  <xsl:template match="wind_degrees">
    <xsl:call-template name="draw-wind">
      <xsl:with-param name="dir" select="number(.)"/> 
      <xsl:with-param name="speed" 
          select="number(../wind_mph) * 1609.344 div 3600"/>
      <xsl:with-param name="gust" 
          select="number(following-sibling::wind_gust_mph) * 
            1609.344 div 3600"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="draw-wind">
    <xsl:param name="dir">0</xsl:param> 
    <xsl:param name="speed">0</xsl:param>
    <xsl:param name="gust">0</xsl:param>

    <g id="compass" font-size="8pt" font-family="sans-serif"
      transform="translate(110, 70)">
      <circle cx="40" cy="40" r="30" stroke="black" fill="none"/>
      <!-- tick marks at cardinal directions -->
      <path stroke="black" fill="none"
        d= "M 40 10 L 40 14
        M 70 40 L 66 40
        M 40 70 L 40 66
        M 10 40 L 14 40"/>
      <xsl:if test="$speed &gt;= 0">
        <path transform="rotate({$dir - 90},40,40)"
          d="M 40 40 h 25"
          fill="none" stroke="black"/>
      </xsl:if>
      <text x="40" y="9" text-anchor="middle">N</text>
      <text x="73" y="44">E</text>
      <text x="40" y="80" text-anchor="middle">S</text>
      <text x="8" y="44" text-anchor="end">W</text>
      <text x="40" y="100" text-anchor="middle">Wind (m/sec)</text>
      <text x="40" y="115" text-anchor="middle">
        <xsl:choose>
          <xsl:when test="$speed &gt;= 0">
            <xsl:value-of select="format-number($speed, '0.##')"/>
          </xsl:when>
          <xsl:otherwise>N/A</xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$gust &gt; 0">
          <xsl:text> - </xsl:text>
          <xsl:value-of select="format-number($gust, '0.##')"/>
        </xsl:if>
      </text>
    </g>
  </xsl:template>
  
  <xsl:template match="visibility_mi">
    <xsl:call-template name="draw-visibility">
      <xsl:with-param name="v" select="number(.) * 1.609344"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="draw-visibility">
    <xsl:param name="v">0</xsl:param>
    <g id="visbar" transform="translate(220,110)" 
      font-size="8pt" text-anchor="middle">

    <!-- fill in the rectangle if there is a visibility value -->
    <xsl:if test="$v &gt;= 0">
      <xsl:variable name="width">
        <xsl:choose>
        <xsl:when test="$v &gt; 40">100</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$v * 100.0 div 40.0"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <rect fill="green" stroke="none"
        x="0" y="0" width="{$width}" height="20"/>
    </xsl:if>

    <rect x="0" y="0" width="100" height="20" 
          stroke="black" fill="none"/>
    
    <path fill="none" stroke="black"
      d="M 25 20 L 25 25 M 50 20 L 50 25 M 75 20 L 75 25"/>

    <text x="0" y="35">0</text>
    <text x="25" y="35">10</text>
    <text x="50" y="35">20</text>
    <text x="75" y="35">30</text>
    <text x="100" y="35">40+</text>
    <text x="50" y="60">
      Visibility (km)
    </text>
    <text x="50" y="75">
      <xsl:choose>
        <xsl:when test="$v &gt;= 0">
          <xsl:value-of select="format-number($v,'0.###')"/>
        </xsl:when>
        <xsl:otherwise>N/A</xsl:otherwise>
      </xsl:choose>
    </text>
  </g>
  </xsl:template>

  <xsl:template match="text()"/>
</xsl:stylesheet>
