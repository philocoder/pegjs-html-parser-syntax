/*
 *
 * Licensed like: Do whatever you want with this piece of code.
 *
 * I picked some lines of code from else where, and this is a mix
 * between the ideas I got there and there, you know...
 *
 * There are also other more competent parsers out there, 
 * just check it out if you need rigorous HTML parsing,
 * and also for PEGjs parser.
 * 
 * This parser does not check the correspondence between
 * opened and closed tags (the name can change, and the 
 * parser would accept the input).
 * 
 * But tracks that the same number of opened tags is the same
 * number of closed tags, and that the first tag is a pure HTML
 * tag.
 *
 * I needed an html parser, but I wanted it to be small, and not very strict.
 *
 * But feel free to change, modify, amplify or whatever you 
 * want with this code.
 *
 *
 *
 */
HTML_CODE = code:Html_Code_First {return text();}
Html_Code_First = (Html_Tag_Closed / (Html_Tag_Open_First Html_Tag_Content)) {}
Html_Code = (Html_Tag_Closed / (Html_Tag_Open Html_Tag_Content)) {return text();}
Html_Tag_Closed = (("<") (Html_Word) (Html_Attributes) ((Html_Space)? ("/>"))) {}
Html_Attributes = ((Html_Space) (Html_Word) ((Html_Space)? (Html_EquivalenceSymbol) (Html_Space)? (Generative_String))?)* {}
Html_Tag_Open = "<" tag:(Html_Word) attrs:(Html_Attributes) (Html_Space)? ">" {}
Html_Tag_Open_First = tag:("<a" / "<abbr" / "<acronym" / "<abbr" / "<address" / "<applet" / "<embed" / "<object" / "<area" / "<article" / "<aside" / "<audio" / "<b" / "<base" / "<basefont" / "<bdi" / "<bdo" / "<big" / "<blockquote" / "<body" / "<br" / "<button" / "<canvas" / "<caption" / "<center" / "<cite" / "<code" / "<col" / "<colgroup" / "<colgroup" / "<datalist" / "<dd" / "<del" / "<details" / "<dfn" / "<dialog" / "<dir" / "<ul" / "<div" / "<dl" / "<dt" / "<em" / "<embed" / "<fieldset" / "<figcaption" / "<figure" / "<figure" / "<font" / "<footer" / "<form" / "<frame" / "<frameset" / "<head" / "<header" / "<hr" / "<html" / "<i" / "<iframe" / "<img" / "<input" / "<ins" / "<kbd" / "<keygen" / "<label" / "<input" / "<legend" / "<fieldset" / "<li" / "<link" / "<main" / "<map" / "<mark" / "<menu" / "<menuitem" / "<meta" / "<meter" / "<nav" / "<noframes" / "<noscript" / "<object" / "<ol" / "<optgroup" / "<option" / "<output" / "<p" / "<param" / "<pre" / "<progress" / "<q" / "<rp" / "<rt" / "<ruby" / "<s" / "<samp" / "<script" / "<section" / "<select" / "<small" / "<source" / "<video" / "<audio" / "<span" / "<strike" / "<del" / "<s" / "<strong" / "<style" / "<sub" / "<summary" / "<details" / "<sup" / "<table" / "<tbody" / "<td" / "<textarea" / "<tfoot" / "<th" / "<thead" / "<time" / "<title" / "<tr" / "<track" / "<video" / "<audio" / "<tt" / "<u" / "<ul" / "<var" / "<video" / "<wbr") ((Html_Attributes) (Html_Space)?)? ">" {}
Html_Tag_Close = "</" tag:(Html_Word) ">" {}
Html_Tag_Content = (!(Html_Tag_Close) (Html_Code / Html_Space / .))* Html_Tag_Close {return text();}
Html_Word = ([A-Za-z]) ([A-Za-z\-_\:]*) {return text();}
Html_Space = [\n\r\t ]+ {}
Html_EquivalenceSymbol = "=" {}
/*And we import the "string" syntax in js for the HTML attributes:*/
Generative_String = str:js_StringLiteral {return str;}
/*The resources needed from JS syntax:*/
js_DoubleStringCharacter = !('"' / "\\" / js_LineTerminator) js_SourceCharacter { return text(); }
  / "\\" sequence:js_EscapeSequence { return sequence; }
  / js_LineContinuation
js_LineTerminator = [\n\r\u2028\u2029]
js_StringLiteral "string"
  = '"' chars:js_DoubleStringCharacter* '"' {return text();}
  / "'" chars:js_SingleStringCharacter* "'" {return '"' + JSON.stringify(chars.join("")) + '"';}
js_SourceCharacter = .
js_EscapeSequence = js_CharacterEscapeSequence / "0" !js_DecimalDigit { return "\0"; }
  / js_HexEscapeSequence / js_UnicodeEscapeSequence
js_LineContinuation = "\\" js_LineTerminatorSequence { return ""; }
js_SingleStringCharacter = !("'" / "\\" / js_LineTerminator) js_SourceCharacter { return text(); }
  / "\\" sequence:js_EscapeSequence { return sequence; }
  / js_LineContinuation
js_CharacterEscapeSequence = js_SingleEscapeCharacter
  / js_NonEscapeCharacter
js_DecimalDigit = [0-9]
js_HexEscapeSequence = "x" digits:$(js_HexDigit js_HexDigit) {return String.fromCharCode(parseInt(digits, 16));}
js_UnicodeEscapeSequence = "u" digits:$(js_HexDigit js_HexDigit js_HexDigit js_HexDigit) {return String.fromCharCode(parseInt(digits, 16));}
js_LineTerminatorSequence "end of line" = "\n" / "\r\n" / "\r" / "\u2028" / "\u2029"
js_SingleEscapeCharacter = "'" / '"' / "\\"
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; }
js_NonEscapeCharacter = !(js_EscapeCharacter / js_LineTerminator) js_SourceCharacter { return text(); }
js_HexDigit = [0-9a-f]i
js_EscapeCharacter = js_SingleEscapeCharacter / js_DecimalDigit / "x" / "u"
