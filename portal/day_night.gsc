main()
{

}

random_rain()
{

}














day_night()
{
	
	
}


set_time( time )
{
	
}


setDayDvars(  LightTint, DarkTint, SunLight, SunDir, Amount  )
{

}

toggle_sun()
{
	
}

toggle_shadow()
{
	
}


time_exp( x, a, b, c )
{
	if( x < b + c - 1440 )
		x += 1440;
	b /= 2;
	c += b;
	x = ( x / b - c / b );
	z = x;
	for( i = 1; i < a; i++)
		x *= z;
	x = 1 - (x);
	x = int(  x * ( x > 0 ) * 100 ) / 100;
	return x;
}

time_difference( a, b )
{
	x = time_loop( a - b );
	if( x > 770 )
		x = 1440 - x;
	return abs( x );
}

time_loop( time )
{
	while( time >= 1440 ) 	time -= 1440;
	while( time < 0 ) 		time += 1440;
	return time;
}

getCurrentTime()
{
	return ConverttoTime( level.time );
}

ConverttoTime( x )
{
	a = x * ( 24 / 1440 );
	
	b = ( a - int( a ) ) / ( 24 / 1440 );
	
	a = int( a );
	
	b = int( b );
	
	if( a < 10 )
		a = "0" + a;
	
	if( b < 10 )
		b = "0" + b;
		
	return a + ":" + b;
}

ConvertfromTime( time )
{
	time = strtok( time, ":" );
	return int( int( time[0] ) / 0.0166666 ) + int( time[1] );
}

float( str )
{
	str += "";
	str = strtok( str, "." );
	if( !isdefined( str[1] ) )
		str[1] = "0";
	return int( str[0] ) + int( str[1] ) / exp( 10, str[1].size );
}

exp( a, x )
{
	for( i = 1; i < x; i++)
		a *= a;
	return a;
}

float_vec( str )
{
	str = strtok( str, " " );
	return (float(str[0]), float(str[1]), float(str[2]) );
}