# XSLT Batch Format & Indent Demo

Use `xsl:accumulator` for the line length and `xsl:iterate` to iterate over text node tokens.

Respect significant whitespace and preformatted text.

See [the library’s README](https://github.com/transpect/xslt-util/blob/master/format-indent/README.md) for Saxon version requirements.

## Motivation

- An unindented XML document with rather long lines is opened in an editor
- The document has an associated schema (DTD, XSD, or RNG)
- If the editor, unlike Oxygen, cannot do format&indent that respects the schema, it is hard to edit
- If the editor, like Notepad++, inserts additional whitespace (where it’s significant) or flattens preformatted text, the content will be marred
          
## Requirement

- Apply batch format&indenting prior to opening the document
- Significant whitespace in mixed content must be respected. For instance, don’t convert `<p><i>I</i><b>B</b></p>` to

  ```xml
  <p>
    <i>I</i>
    <b>B</b>
  </p>
  ```
  since it introduces extra whitespace.  

## Run the demo

```bash
#!/bin/bash

set -x

# Remove formatting (apart from preformat):
saxon-PE127 -s:jats-article.xml \
	    -xsl:xslt-util/format-indent/xsl/undo-format-indent.xsl \
	    +schema-docs=JATS/1.4/rng/JATS-journalpublishing1-4-mathml3.rng \
	    -o:jats-article.noindent.xml
# Format & indent (apart from preformat):
saxon-PE127 -s:jats-article.noindent.xml \
	    -xsl:xslt-util/format-indent/xsl/format-indent.xsl \
	    -o:jats-article.formatted.xml \
	    +schema-docs=JATS/1.4/rng/JATS-journalpublishing1-4-mathml3.rng \
	    target-line-length=80
```

## Approach

- Analyze an XSD or RNG version of the schema  
  - for elements that may hold “#PCDATA”, such as the `p` above
  - for contexts that are declared `xml:space="preserve"`
  - (the processing isn’t schema-aware in an XSLT sense)
  - We don’t support DTDs because they are hard to parse (looking forward to `fn:invisible-xml` and Sheila’s DTD grammar).
- Use an xsl:accumulator that adds the lengths of the serialized tags, namespace declarations, attributes, etc.
- At places where space is significant (but not to be preserved):
  - Tokenize text nodes at whitespace
  - iterate over the tokens, update the accumulator that holds the line length so far
  - If the added lengths in the accumulator exceed the target length, 
  - wrap the line,
  - reset the accumulator,
  - insert the calculated indentation (spaces or tabs, as you prefer)
  - continue until you run of tokens

## Disadvantages

- No good lookahead. If `of <monospace>p</monospace>` starts at column 77, the line won’t be wrapped.
- No breaks between attributes (using the default serializer, without indentation)

## Alternatives

- Write your own serializer with better line-wrap optimization 
  - in Java
  - or one that generates strings with XSLT

- But I wanted to use XSLT and accumulators
- and I unearthed a [Saxon Bug](https://saxonica.plan.io/issues/6679) that was fixed in 12.6, making life better for everyone that uses `xsl:iterate` in `xsl:accumulator-rule` (who doesn’t?)
 
