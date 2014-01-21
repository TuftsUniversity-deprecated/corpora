import java.util.regex.*;
import java.text.*;

public class TimeCalc {

    public static Pattern longPat  = Pattern.compile( "(\\d*):(\\d*):(\\d*\\.\\d*)" );
    public static Pattern shortPat = Pattern.compile(        "(\\d*):(\\d*\\.\\d*)" );
    public static NumberFormat outputFormat = new DecimalFormat( "00000.000s" );

    public static String timeDiff(String start,String end)
	throws ParseException
    {
	long startMillis = elapsedMillis( start );
	long endMillis   = elapsedMillis( end );

	long interval    = endMillis - startMillis;

	double seconds   = ((double) interval) / 1000.0;
	return outputFormat.format( seconds );
    }

    public static String formatMillis( String millisStr )
    {
	long millis    = (long) Double.parseDouble( millisStr );
	double seconds = ((double) millis) / 1000.0;
	return outputFormat.format( seconds );
    }
    
    public static long elapsedMillis( String time )
    {
	Matcher m = longPat.matcher( time );
	if ( m.matches() ) {

	    // long pattern match

	    long hourMillis = Long.parseLong( m.group(1) ) * 60*60*1000;
            long minMillis  = Long.parseLong( m.group(2) ) *    60*1000;
            long secMillis  = (long) (Float.parseFloat( m.group(3) ) * 1000);
	    
	    long millis     = hourMillis + minMillis + secMillis;
	    return millis;

	} else {
	    m = shortPat.matcher( time );
	    if( m.matches() ) {

		// short pattern match

		long minMillis  = Long.parseLong( m.group(1) ) *    60*1000;
		long secMillis  = (long) (Float.parseFloat( m.group(2) ) * 1000);
	    
		long millis = minMillis + secMillis;
		return millis;

	    } else {
		throw new RuntimeException( "invalid time string '"+time+"'" );
	    }
	}
    }
}
