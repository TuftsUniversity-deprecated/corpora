import java.util.regex.*;
import org.znerd.xmlenc.*;
import java.io.*;

public class SplitSpeech
{
    private static Pattern whoPat = Pattern.compile( "(\\p{Alpha}+)\\s*:\\s*(.*)" );
    private static Pattern spacePat = Pattern.compile( "\\s*" );

    public static String splitSpeech( String speech )
	throws IOException
    {
	StringWriter sw = new StringWriter();
	XMLEncoder xenc = XMLEncoder.getEncoder( "US-ASCII" );

	String[] lines = speech.replaceAll( "\\x0D", "" ).split( "\\n" ); 
	
	for( int i = 0; i < lines.length; i++ ) {
	    if( !spacePat.matcher( lines[i] ).matches() ) {
		Matcher m = whoPat.matcher( lines[i] );
		sw.write( "\n" );
		if( m.matches() ) {
		    sw.write( "<u" );
		    xenc.attribute( sw, "who", m.group(1), '"', true );
		    sw.write( ">" );
		    xenc.text( sw, m.group( 2 ), true );
		    sw.write( "</u>" );
		} else {
		    sw.write( "<u>" );
		    xenc.text( sw, lines[i], true );
		    sw.write( "</u>" );
		}
	    }
	}
	sw.write( "\n" );

	return sw.toString();
    }
}
