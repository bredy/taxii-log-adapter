<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:t="http://taxii.mitre.org/messages/taxii_xml_binding-1.1"
                xmlns:s="http://stix.mitre.org/stix-1"
                xmlns:inc="http://stix.mitre.org/Incident-1"
                xmlns:ttp="http://stix.mitre.org/TTP-1"
                xmlns:ind="http://stix.mitre.org/Indicator-2"
                xmlns:sc="http://stix.mitre.org/common-1"
                xmlns:cc="http://cybox.mitre.org/common-2">

    <xsl:output method="text" encoding="utf-8"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="/t:Poll_Response">
        <xsl:apply-templates select="t:Content_Block/t:Content"/>
    </xsl:template>

    <xsl:template match="/t:Status_Message">
        <!-- Ignore Status_Message -->
    </xsl:template>

    <xsl:template match="s:STIX_Package">
        <xsl:apply-templates select="s:Incidents">
            <xsl:with-param name="customer" select="s:STIX_Header/s:Information_Source/sc:Identity/@id"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="s:Incident">
        <xsl:param name="customer"/>
        <xsl:apply-templates select="inc:Related_Indicators">
            <xsl:with-param name="customer" select="$customer"/>
            <xsl:with-param name="incidentId" select="@id"/>
            <xsl:with-param name="incidentTitle" select="inc:Title"/>
            <xsl:with-param name="victim" select="inc:Victim/sc:Name"/>
            <xsl:with-param name="confidence" select="inc:Confidence/sc:Value"/>
            <xsl:with-param name="tool" select="inc:Information_Source/sc:Tools/cc:Tool/@idref"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="sc:Indicator">
        <xsl:param name="customer"/>
        <xsl:param name="incidentId"/>
        <xsl:param name="incidentTitle"/>
        <xsl:param name="victim"/>
        <xsl:param name="confidence"/>
        <xsl:param name="tool"/>
        <xsl:apply-templates select="ind:Observable">
            <xsl:with-param name="customer" select="$customer"/>
            <xsl:with-param name="incidentId" select="$incidentId"/>
            <xsl:with-param name="incidentTitle" select="$incidentTitle"/>
            <xsl:with-param name="victim" select="$victim"/>
            <xsl:with-param name="confidence" select="$confidence"/>
            <xsl:with-param name="tool" select="$tool"/>
            <xsl:with-param name="indicatorId" select="@id"/>
            <xsl:with-param name="activity" select="ind:Indicated_TTP/sc:TTP/ttp:Title"/>
            <xsl:with-param name="campaign" select="ind:Related_Campaigns/ind:Related_Campaign/sc:Campaign/@idref"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="cc:Custom_Properties">

        <xsl:param name="customer"/>
        <xsl:param name="incidentId"/>
        <xsl:param name="incidentTitle"/>
        <xsl:param name="victim"/>
        <xsl:param name="confidence"/>
        <xsl:param name="tool"/>
        <xsl:param name="indicatorId"/>
        <xsl:param name="activity"/>
        <xsl:param name="campaign"/>

        <xsl:text>{</xsl:text>

        <xsl:for-each select="cc:Property">
            <xsl:call-template name="property">
                <xsl:with-param name="key" select="@name"/>
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="property">
            <xsl:with-param name="key">customer</xsl:with-param>
            <xsl:with-param name="value" select="$customer"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">incidentId</xsl:with-param>
            <xsl:with-param name="value" select="$incidentId"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">incidentTitle</xsl:with-param>
            <xsl:with-param name="value" select="$incidentTitle"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">victim</xsl:with-param>
            <xsl:with-param name="value" select="$victim"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">confidence</xsl:with-param>
            <xsl:with-param name="value" select="$confidence"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">tool</xsl:with-param>
            <xsl:with-param name="value" select="$tool"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">indicatorId</xsl:with-param>
            <xsl:with-param name="value" select="$indicatorId"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">activity</xsl:with-param>
            <xsl:with-param name="value" select="$activity"/>
        </xsl:call-template>

        <xsl:call-template name="property">
            <xsl:with-param name="key">campaign</xsl:with-param>
            <xsl:with-param name="value" select="$campaign"/>
            <xsl:with-param name="delimiter"/>
        </xsl:call-template>

            <xsl:text>}
</xsl:text>
    </xsl:template>


    <xsl:template name="property">
        <xsl:param name="key"/>
        <xsl:param name="value"/>
        <xsl:param name="delimiter">true</xsl:param>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$key"/>
        <xsl:text>"</xsl:text>
        <xsl:text>:</xsl:text>
        <xsl:choose>
            <xsl:when test="string(number($value)) = 'NaN'">
                <xsl:text>"</xsl:text>
                <xsl:variable name="text" select="fn:replace($value, '(\\|&quot;)', '\\$1')"/>
                <xsl:value-of select="$text"/>
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$delimiter">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>