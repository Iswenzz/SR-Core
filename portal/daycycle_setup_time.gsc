

get_Start_Time()	//if dvar, portal_daycycle_starttime is not set, time will start at 2pm
{
}


/*

//Uncomment this get_Start_Time() function and remove the above if you wish to enable a realtime-daycycle and
//are using the Linux Ninja Files ( you must be able to read the current time through the getRealTime() function )

get_Start_Time()
{
	setDvar( "portal_daycycle_realtime", 1 );	//time should pass in realtime
	return portal\daycycle::converttotime( getRealTime()%(24*60*60) + getdvarint( "portal_daycycle_hour_add" )*60*60 );
}

*/