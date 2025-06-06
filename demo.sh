#!/bin/bash

set -x

saxon-PE127 -s:jats-article.xml \
	    -xsl:xslt-util/format-indent/xsl/undo-format-indent.xsl \
	    +schema-docs=JATS/1.4/rng/JATS-journalpublishing1-4-mathml3.rng \
	    -o:jats-article.noindent.xml
saxon-PE127 -xsl:xslt-util/render-xml-source/xsl/render-xml-source-as-html.xsl \
	    -s:jats-article.noindent.xml \
	    -o:jats-article.noindent.html \
	    indent=false scaffold=true
saxon-PE127 -s:jats-article.noindent.xml \
	    -xsl:xslt-util/format-indent/xsl/format-indent.xsl \
	    -o:jats-article.formatted.xml \
	    +schema-docs=JATS/1.4/rng/JATS-journalpublishing1-4-mathml3.rng \
	    target-line-length=80
saxon-PE127 -xsl:xslt-util/render-xml-source/xsl/render-xml-source-as-html.xsl \
	    -s:jats-article.formatted.xml \
	    -o:jats-article.formatted.html \
	    indent=false scaffold=true
