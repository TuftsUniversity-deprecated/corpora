<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:uriEnc="java:URLUTF8Encoder"
                xmlns:splitSpeech="java:SplitSpeech"
                xmlns:timeCalc="java:TimeCalc"
		xmlns:saxon="http://icl.com/saxon" 

      version="1.0"
      exclude-result-prefixes="uriEnc timeCalc splitSpeech xs saxon">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
      <TEI.2>
	<teiHeader>
	  <fileDesc>
	    <titleStmt>
	      <title><xsl:comment>Fill in a title</xsl:comment></title>
	      <author><xsl:comment>Fill in the author</xsl:comment></author>
	    </titleStmt>
	    <extent><xsl:comment>fill in the extent</xsl:comment></extent>
	    <publicationStmt>
	      <distributor>Tufts University Digital Collections and Archives</distributor>
	      <address>
		<addrLine>Tufts University</addrLine>
		<addrLine>35 Professors Row</addrLine>
		<addrLine>Tisch Library Medford, MA 01255</addrLine>
	      </address>
	      <idno><xsl:comment>fill in the ID number</xsl:comment></idno>
	      <availability status="free">
		<p>This publication is freely available for scholarly or educational use.</p>
	      </availability>
	    </publicationStmt>
	    <sourceDesc>
	      <recordingStmt>
		<recording type="audio" dur="{/Timeline/@mediaLength}ms">
		  <date><xsl:comment>Fill in the date of the _recording_</xsl:comment></date>
		  <equipment><p><xsl:comment>Fill in details about the recoring equipment</xsl:comment></p></equipment>
		  <respStmt>
		    <resp>interview conducted by:</resp>
		    <name><xsl:comment>Fill in the person responsable for the recording</xsl:comment></name>
		  </respStmt>
		</recording>
	      </recordingStmt>
	    </sourceDesc>
	  </fileDesc>
	  <encodingDesc>
	    <editorialDecl>
	      <stdVals>
		<p>Standard date values are given in ISO form: yyyy-mm-dd.</p>
	      </stdVals>
	    </editorialDecl>
	    <classDecl>
	      <taxonomy id="LCSH">
		<bibl>
		  <title>Library of Congress Subject Headings</title>
		</bibl>
	      </taxonomy>
	      <taxonomy id="LC">
		<bibl>
		  <title>Library of Congress</title>
		</bibl>
	      </taxonomy>
	    </classDecl>
	  </encodingDesc>
	  <profileDesc>
	    <creation>
	      <date><xsl:comment>Fill in an appropriate creation date (for the transcript)</xsl:comment></date>
	    </creation>
	    <langUsage>
	      <language id="EN" usage="100">English.</language>
	    </langUsage>
	    <particDesc>
	      <xsl:comment>Fill in interview participants here</xsl:comment>
	    </particDesc>
	  </profileDesc>
	</teiHeader>

	<text>
	  <body>
	    <xsl:call-template name="timeline"/>

	    <div1 id="transcript.1" n="Transcript">
	      <xsl:call-template name="text"/>
	    </div1>
	  </body>
	</text>
      </TEI.2>
    </xsl:template>

    <xsl:template name="timeline">

      <timeline id="transcript_timeline" unit="millisecond" origin="timepoint_begin">
	<when id="timepoint_begin" absolute="beginning of recording"/>

	<xsl:for-each select="/Timeline/Bubble/Bubble">
	  <xsl:variable name="pos" select="position()"/>

	  <when id="timepoint_{@label}" since="timepoint_begin"
		interval="{timeCalc:elapsedMillis(@time)}"/>
	  
	</xsl:for-each>

	<when id="timepoint_end" since="timepoint_begin"
	      interval="{/Timeline/@mediaLength}"/>
      </timeline>

    </xsl:template>

    <xsl:template name="text">
      <xsl:for-each select="/Timeline/Bubble/Bubble">
	<xsl:variable name="pos" select="position()"/>

	<u rend="transcript_chunk" start="timepoint_{@label}" n="{@label}">
	  <xsl:attribute name="end">
	    <xsl:choose>
	      <xsl:when test="$pos = last()">
		<xsl:text>timepoint_end</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>timepoint_</xsl:text>
		<xsl:value-of select="/Timeline/Bubble/Bubble[$pos+1]/@label"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  
	  <xsl:call-template name="splitSpeakers">
	    <xsl:with-param name="script" select="Annotation"/>
	  </xsl:call-template>
	</u>

      </xsl:for-each>
    </xsl:template>

    <xsl:template name="splitSpeakers">
      <xsl:param name="script"/>
      
      <xsl:value-of disable-output-escaping="yes" select="splitSpeech:splitSpeech($script)"/>
    </xsl:template>

</xsl:stylesheet>
