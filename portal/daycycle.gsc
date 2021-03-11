/*

                        ,_____________
                   ,__NNNNNNNNNNNNNNNNNNN__
                ,_NNNNNNNF"""""""""""4NNNNNNN_.
              _NNNNNN""                 ""NNNNNL_
              "NNN"`                       �"NNNNN.
               ,N.                            "NNNNL
              _NNNL.                            4NNNN.
            ,JNNNF`�\.                           �NNNN.
            NNNN"    �\.                          �NNNN.
           JNNN`       �\.        __               (NNNL
          ,NNN)          �\.      NN                4NNN.
          NNNF____       __JL_    NN    ,__   ,____.(NNN)
         (NNNF"""4N_   _NF""""N.  NN  ,JN"  ,JN""""4NNNNN
         (NNN     NN  ,NF    ,NF\.NN,JN"    JN      NNNNN
         (NNN     NN  (NF""""""  �NNN"4N.   NN      NNNNF
         (NNN     NN   NL     _.  NN\  4N.  �NL    _NNNN)
         (NNN.    4N    "4NNNF"`  NN "_ "NN  �"NNNN4NNNN
          NNNL                         "_         ,NNNN`
          �NNN)                          "_      ,NNNN)
           4NNN.                           "_   _NNNN"
            NNNN_                            "_JNNNN`
            �4NNNL.                            "NN"
              "NNNNL.                           _L.
               �4NNNNN_.                     _JNNNNL
                 �"NNNNNNL__            ,__JNNNNNF"
                    �"NNNNNNNNNNN___NNNNNNNNNNF" 
                        ""4NNNNNNNNNNNNNNN""`
                               """"""` 

                        ASCIIARTBY - R4d0xZz 
								� 2k11

*/

#include sr\portal\general;

main()
{
	
}

random_rain()
{
	
}

setup_clock()
{
	
	

}

new_clock_elem(x,y)
{
	
}


destroy_clock()
{
	
}


set_clock_time( h, m )
{

}

setdigit( t )
{
	
}



On()
{
	
}


Off()
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


SetTweaks()
{
	
}


setupTimeSpeed( RealTime )
{

}


time_exp( x, a, b, c )
{
	if( x < b + c - level.seconds )
		x += level.seconds;
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
	if( x > (level.seconds/2) )
		x = level.seconds - x;
	return abs( x );
}

time_loop( time )
{
	while( time >= level.seconds ) 	time -= level.seconds;
	while( time < 0 ) 		time += level.seconds;
	return time;
}

getCurrentTime()
{
	return ConverttoTime( level.time );
}

ConverttoTime( x )
{
	a = x * ( 24 / level.seconds );
	
	b = ( a - int( a ) )*60;
	
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
	return int( int( time[0] )*level.seconds / 24 ) + int( int( time[1] ) * level.seconds/(24*60) );
}


get_Sun_Dir( map )
{

}