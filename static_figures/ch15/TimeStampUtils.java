import java.util.Calendar;
import java.util.Date;
import java.text.DateFormat;

public class TimeStampUtils
{
    public static String getDate(String timeStampString)
    {
        DateFormat d = DateFormat.getDateInstance();
        long milliseconds = Long.parseLong( timeStampString ) * 1000;
        return 
            d.format(new Date(milliseconds));
    }
    
    public static Double getHour(String timeStampString)
    {
        long milliseconds = Long.parseLong( timeStampString ) * 1000;
        Calendar c = Calendar.getInstance();
        c.setTime( new Date( milliseconds ) );
        return new Double( c.get( Calendar.HOUR_OF_DAY ) );
    }
    
    public static Double getMinute(String timeStampString)
    {
        long milliseconds = Long.parseLong( timeStampString ) * 1000;
        Calendar c = Calendar.getInstance();
        c.setTime( new Date( milliseconds ) );
        return new Double( c.get( Calendar.MINUTE ) );
    }
}
