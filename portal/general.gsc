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

vectorprod( vec1, vec2 )
{
	return ( (vec1[1]*vec2[2]-vec1[2]*vec2[1]), (vec1[2]*vec2[0]-vec1[0]*vec2[2]), (vec1[0]*vec2[1]-vec1[1]*vec2[0]) );
}

random_vec( max )
{
	return ( randomintrange( max*-1, max+1 ), randomintrange( max*-1, max+1 ), randomintrange( max*-1, max+1 ) );
}

rotatevec_x( vec, deg )
{
	a = sin( deg );
	b = cos( deg );
	return  ( vec[0], vec[1] * b - vec[2] * a, vec[1] * a + vec[2] * b ); 
}

rotatevec_y( vec, deg )
{
	a = sin( deg );
	b = cos( deg );
	return  ( vec[0] * b + vec[2] * a, vec[1], vec[2] * b - vec[0] * a ); 
}

rotatevec_z( vec, deg )
{
	a = sin( deg );
	b = cos( deg );
	return  ( vec[0] * b - vec[1] * a, vec[0] * a + vec[1] * b, vec[2] ); 
}

vector_divide_index( v, i, s )
{
	switch(i){ case 0: return (v[0]/s,v[1],v[2]);
	case 1: return (v[0],v[1]/s,v[2]);
	case 2: return (v[0],v[1],v[2]/s);
	}
}

swap_scale( v, n, i )	//swap 2 indexes out of vector v
{
	w[n] = v[i];
	w[i] = v[n];
	w[3-n-i] = v[3-n-i];
	return ( w[0], w[1], w[2] );
}

vec_2d( vec )
{
	return vectornormalize( ( vec[0], vec[1], 0 ) );
}

/*  -   Angles   - */

normalize_angle( angle )
{
	while( abs(angle) > 180 )
		angle += 360 * sign(angle) * -1;
	return angle;
}

normalize_angles( angles )
{
	return( normalize_angle( angles[0] ), normalize_angle( angles[1] ), normalize_angle( angles[2] ) );
}

max_x_angle( angle )
{
	while( abs(angle) > 90 )
		angle = sign(angle) * 180 - angle;
	return angle;
}

angle_subtract( angle1, angle2 )
{
	return normalize_angle( normalize_angle(angle2) - normalize_angle(angle1) );
}

combined_angles_to_vector( vec, angles ) //return angles needed in order to look in vectors direction from angles point of view
{
	a = vec_translation_angles_2( vec, angles );
	//iprintln( a );
	angles = normalize_angles(vectortoangles(a));
	return (angles[0],angles[1]*-1,0);
}

portal_out_angles( angles1, angles2, angles3 )		//calculate the angles after travelling through a portal
{
	return ( normalize_angle( angles2[0] + angles3[0] + angles1[0] ) , angles2[1] - angles1[1] + angles3[1] - 180,  normalize_angle( normalize_angle( angles3[1] - angles1[1] - 180) * ( max_x_angle( normalize_angle( abs( angles1[0] + normalize_angle(180 - angles2[0]) ) ) ) / 90)) );
}

portal_out_angles_player( angles1, angles2, angles3 )	//calculate player angles after travelling through a portal
{
	angles = portal_out_angles( angles1, angles2, angles3 );
	
	while( abs(angles[0]) > 120 ) 	// if the x-Angle is going over 120 degrees player will be flipped (max player angle is 85)
		angles = ( max_x_angle( angles[0] ) , angles[1] + 180, normalize_angle( angles[2] + 180 ) );
	
	return angles;
}

snap_angle( angle, deg )
{
	return round(angle/deg,0)*deg;
}

snap_angle_90( angle, offset )
{
	return round((angle-offset)/90,0)*90+offset;
}

/*  -   Math   - */

round( f, e )	//rounds the float number using e valid digits, e can be negative
{
	s = sign2(f);
    c =  exp( 10, e );
	a = ( c * f * 10 - int( c * f )*10 );
	a = (a >= 5) || (a<-5);
    return ( (int( f * c ) + a*s ) / c );
}

exp( base, e )
{
	if( e < 0 )
	{
		base = 1/base;
		e*=-1;
	}
	output = 1;
	for( i = 0; i < e; i++)
		output *= base;
	return output;
}

cheap_cos( deg )
{
	return cheap_sin(deg+90);
}

cheap_sin_setup()
{
	level._sin[0] = 0.000;
	level._sin[1] = 0.017;
	level._sin[2] = 0.035;
	level._sin[3] = 0.052;
	level._sin[4] = 0.070;
	level._sin[5] = 0.087;
	level._sin[6] = 0.105;
	level._sin[7] = 0.122;
	level._sin[8] = 0.139;
	level._sin[9] = 0.156;
	level._sin[10] = 0.174;
	level._sin[11] = 0.191;
	level._sin[12] = 0.208;
	level._sin[13] = 0.225;
	level._sin[14] = 0.242;
	level._sin[15] = 0.259;
	level._sin[16] = 0.276;
	level._sin[17] = 0.292;
	level._sin[18] = 0.309;
	level._sin[19] = 0.326;
	level._sin[20] = 0.342;
	level._sin[21] = 0.358;
	level._sin[22] = 0.375;
	level._sin[23] = 0.391;
	level._sin[24] = 0.407;
	level._sin[25] = 0.423;
	level._sin[26] = 0.438;
	level._sin[27] = 0.454;
	level._sin[28] = 0.469;
	level._sin[29] = 0.485;
	level._sin[30] = 0.500;
	level._sin[31] = 0.515;
	level._sin[32] = 0.530;
	level._sin[33] = 0.545;
	level._sin[34] = 0.559;
	level._sin[35] = 0.574;
	level._sin[36] = 0.588;
	level._sin[37] = 0.602;
	level._sin[38] = 0.616;
	level._sin[39] = 0.629;
	level._sin[40] = 0.643;
	level._sin[41] = 0.656;
	level._sin[42] = 0.669;
	level._sin[43] = 0.682;
	level._sin[44] = 0.695;
	level._sin[45] = 0.707;
	level._sin[46] = 0.719;
	level._sin[47] = 0.731;
	level._sin[48] = 0.743;
	level._sin[49] = 0.755;
	level._sin[50] = 0.766;
	level._sin[51] = 0.777;
	level._sin[52] = 0.788;
	level._sin[53] = 0.799;
	level._sin[54] = 0.809;
	level._sin[55] = 0.819;
	level._sin[56] = 0.829;
	level._sin[57] = 0.839;
	level._sin[58] = 0.848;
	level._sin[59] = 0.857;
	level._sin[60] = 0.866;
	level._sin[61] = 0.875;
	level._sin[62] = 0.883;
	level._sin[63] = 0.891;
	level._sin[64] = 0.899;
	level._sin[65] = 0.906;
	level._sin[66] = 0.914;
	level._sin[67] = 0.921;
	level._sin[68] = 0.927;
	level._sin[69] = 0.934;
	level._sin[70] = 0.940;
	level._sin[71] = 0.946;
	level._sin[72] = 0.951;
	level._sin[73] = 0.956;
	level._sin[74] = 0.961;
	level._sin[75] = 0.966;
	level._sin[76] = 0.970;
	level._sin[77] = 0.974;
	level._sin[78] = 0.978;
	level._sin[79] = 0.982;
	level._sin[80] = 0.985;
	level._sin[81] = 0.988;
	level._sin[82] = 0.990;
	level._sin[83] = 0.993;
	level._sin[84] = 0.995;
	level._sin[85] = 0.996;
	level._sin[86] = 0.998;
	level._sin[87] = 0.999;
	level._sin[88] = 0.999;
	level._sin[89] = 1.000;
	level._sin[90] = 1.000;
}

cheap_sin( deg )
{
	deg = int(round(deg,0));
	p = deg%360;
	//iprintln(p);
	if( p < 0 )
		return cheap_sin(p*-1)*-1;
	if( p > 90 && p <= 180 )
		return level._sin[180-p];
	if( p > 180 && p <= 270 )
		return level._sin[p-180]*-1;
	if( p > 270 )
		return level._sin[360-p]*-1;
	return level._sin[p];	//0<=p<=90
}

sign( x )
{
	if ( isDefined(x) && x >= 0 )
		return 1;
	return -1;
}

sign2( x )
{
	if ( isDefined(x) && x > 0 )
		return 1;
	if( x < 0 )
		return -1;
	return 0;
}

atan2( x, y )
{
	if( x > 0 )
		return atan( y / x );
	if( y >= 0 && x < 0 )
		return atan( y / x ) + 90;
	if( y < 0 && x < 0 )
		return atan( y / x ) - 90;
	if( y > 0 && x == 0 )
		return 90;
	if( y < 0 && x == 0 )
		return -90;
	return 0;
}

pi()
{
	return 3.14159265;
}

/*  -   Player   - */

getheight()
{
	switch(self getstance())
	{
		case "crouch":	height = (0,0,52);
		break;
		case "prone":	height = (0,0,31);
		break;
		default:		height = (0,0,72);
	}
	return height;
}

getcenter()
{
	return self getheight()/2;
}

centerpos()
{
	return self.origin + self getcenter();
}

eye()
{
	
	switch(self getstance())
	{
		case "crouch":	height = (0,0,40);
		break;
		case "prone":	height = (0,0,11);
		break;
		default:		height = (0,0,60);
	}
	
	// right = anglestoright( self getplayerangles() );
	
	// lean_offset = vectordot( right, ( self gettagorigin( "tag_eye" ) - self.origin ) );
	
	// if( abs(lean_offset) > 7 )
		// height += right * sign( lean_offset ) * 14.67 + (0,0,-3.125);
	
	return height;
}

eyepos()
{
	return self eye() + self.origin;
}

isinarray( array )
{
	for( i=0; i<array.size; i++ )
	{
		if( self==array[i] )
		{
			//iprintln(i);
			return true;
		}
	}
	return false;
}

/*  -   Trace   - */

trace_array( start, end, hit_players, ignore_array )	//trace allowing object arrays to be ignored
{
	
	if(!isdefined(ignore_array))	//change this probably
		ignore_ent = undefined;
	
	else
		ignore_ent = ignore_array[0];
	
	if( !isdefined(hit_players) )
		hit_players = false;
	
	trace = bullettrace( start, end, hit_players, ignore_ent );
	
	if( getdvarint( "portal_debug" ) )
	{
		drawline( start, trace["position"], getdvarint("portal_debugtime"), (1,0.3,0.2)*(trace["fraction"]!=1) + (0,1,0)*(trace["fraction"]==1) );
		if( trace["fraction"] != 1 )
			drawline( trace["position"], end, getdvarint("portal_debugtime"), (1,1,0.3) );
		//drawtext( start + 0.5*(trace["position"]-start), level.debugtracenum + "", 40, (0.8,0,0)*(trace["fraction"]!=1) + (0,1,0)*(trace["fraction"]==1) );
		level.debugtracenum++;
	}
	
	if( isdefined(ignore_array) )
		if( isdefined(trace["entity"]) )
			if( trace["entity"] isinarray(ignore_array) )
				return trace_array_raw( trace["position"], end, hit_players, ignore_array, trace["entity"], trace["fraction"] );
	
	return trace;
}

trace_array_raw( start, end, hit_players, ignore_array, ignore_ent, fraction_add )	//trace allowing object arrays to be ignored
{
	trace = bullettrace( start, end, hit_players, ignore_ent );
	
	trace["fraction"] = fraction_add + (1-fraction_add)*trace["fraction"];	//fraction needs to be corrected
	
	if( isdefined(trace["entity"]) )
		if( trace["entity"] isinarray(ignore_array) )
			return trace_array_raw( trace["position"], end, hit_players, ignore_array, trace["entity"], trace["fraction"] );
	
	return trace;
}

ConeTrace( pos, angles, objects, conedegree, maxlength )
{
	close = [];
	
	for( i = 0; i < objects.size; i++ )
	{
		q = objects[i].origin;
		if( lengthsquared( q - pos ) < maxlength*maxlength )
		{
			angles2 = vectortoangles( q - pos );
			if( abs(normalize_angle( angles[0] - angles2[0] ))<conedegree && abs(normalize_angle(angles[1] - angles2[1]))<conedegree )
				if( objects[i] SightConeTrace( pos, self ) )
					close[close.size] = objects[i];
		}
	}
	
	return close;
}

//NOTE: should probably change from closest distance to which is being likelier aimed at
ClosestConeTrace( pos, angles, objects, conedegree, maxlength )
{
	//get an array of the possible objects
	close = ConeTrace( pos, angles, objects, conedegree, maxlength );
	
	//none found
	if( !close.size )
		return;
	
	//check for the closest object
	object = close[0];
	
	for( i = 1; i < close.size; i++ )
	{
		if( distancesquared( object.origin, pos ) > distancesquared( close[i].origin, pos ) )
			object = close[i];
	}
	
	return object;
}

/*  -   Random   - */

biggest_value_index( vec )
{
	return 0*(vec[0]>=vec[1]&&vec[0]>=vec[2]) + 1*(vec[1]>vec[0]&&vec[1]>=vec[2]) + 2*(vec[2]>vec[1]&&vec[2]>vec[0]);
}

smallest_value_index( vec )
{
	return 0*(vec[0]<=vec[1]&&vec[0]<=vec[2]) + 1*(vec[1]<vec[0]&&vec[1]<=vec[2]) + 2*(vec[2]<vec[1]&&vec[2]<vec[0]);
}

isOnSameWall( p, q, normal )	//will return true, if point p and q are on the same wall given the wallnormal
{
	return !( round( vectordot( q - p, normal ), 2 ) );
}

point_translation_angles( p, q, angles )	//return the translation of point q from p oriented by the given angles
{
	vec = q - p;
	
	a = anglestoforward( angles );						//forward vector
	b = anglestoright( angles );						//right vector
	c = vectornormalize( vectorprod( b, a ) );			//up vector
	
	return ( vectordot( vec, b ), vectordot( vec, c ), vectordot( vec, a ) );
}

vec_translation_angles( vec, angles )	//return the translation of point q from p oriented by the given angles
{
	a = anglestoforward( angles );						//forward vector
	b = anglestoright( angles );						//right vector
	c = vectornormalize( vectorprod( b, a ) );			//up vector
	
	return ( vectordot( vec, b ), vectordot( vec, c ), vectordot( vec, a ) );
}

vec_translation_angles_2( vec, angles )	//return the actual translation of point q from p oriented by the given angles
{
	a = anglestoforward( angles );						//forward vector
	b = anglestoright( angles )*-1;						//left vector
	c = vectorprod( a, b );								//up vector
	
	v = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );
	
	return v;
}

localtoworldcoordinates( vec, angles ) //all the matrix shit cause IW cant make a working function
{
	if( vec == (0,0,0) )
		return (0,0,0);
	M = [];
	M[0] = [];
	M[1] = [];
	M[2] = [];
	
	a = anglestoforward( angles );						//forward vector
	b = anglestoright( angles )*-1;						//left vector
	c = vectorprod( a, b );								//up vector
	
	M[0][0] = a[0];
	M[0][1] = a[1];
	M[0][2] = a[2];
	M[1][0] = b[0];
	M[1][1] = b[1];
	M[1][2] = b[2];
	M[2][0] = c[0];
	M[2][1] = c[1];
	M[2][2] = c[2];
	
	return matrix_solve( M, vec );
}

float_vec( str )
{
	str = strtok( str, " " );
	return (float(str[0]), float(str[1]), float(str[2]) );
}

float( str )
{
	str += "";
	str = strtok( str, "." );
	if( !isdefined( str[1] ) )
		str[1] = "0";
	return int( str[0] ) + int( str[1] ) / exp( 10, str[1].size );
}

/*
a: forward
b: right
c: up
*/
point_translation( p, q, a, b, c )	//return the translation of point q from p oriented by the given vector angles
{
	vec = q - p;
	return ( vectordot( vec, b ), vectordot( vec, c ), vectordot( vec, a ) );
}

/*  -   Debug   - */

drawline( from, to, time, color )
{
	thread draw_line( from, to, time, color );
}

drawtext( pos, text, time, color )
{
	thread draw_text( pos, text, time, color, 0.5, 1 );
}

draw_text( pos, text, time, color, alpha, scale )
{
	
	if( !isdefined( color ) )
		color = random_color_dark();
	
	if( !isdefined( time ) || time==0 )
		time = -1;
	
	time = int(time*20);
	
	for( i = 0; i != time; i++ )
	{
		print3d( pos, text, color, alpha, scale );
		wait 0.05;
	}
}

random_color()
{
	return (randomint(100)/100,randomint(100)/100,randomint(100)/100 );
}

random_color_dark()
{
	return (randomint(50)/100,randomint(50)/100,randomint(50)/100 );
}

draw_point( pos, time, color )	//this failed, draw "." text instead?
{
	if( !isdefined( color ) )
		color = random_color_dark();
	
	if( !isdefined( time ) )
		time = 0;
	
	lines = [];
	count = 5;
	
	for( i=0; i<count*2; i+=2 )
	{
		l = vectornormalize(random_color());
		lines[i] = pos - l/10;
		lines[i+1] = pos + l/10;
	}
	
	for( j = 1; j != 20*time; j++ )
	{
		for( i=0; i<count*2; i+=2 )
			line( lines[i], lines[i+1], color, true );
		wait 0.05;
	}
	
}

draw_line( from, to, time, color )
{
	
	if( !isdefined( color ) )
		color = random_color_dark();
	
	if( !isdefined( time ) || time==0 )
		time = -1;
	
	time = int(time*20);
	
	for( i = 0; i != time; i++ )
	{
		line( from, to, color, true );
		wait 0.05;
	}
}

draw_axis( time, pos )
{
	
	if( !isdefined( time ) )
		time = 0;
	
	time = int(time*20);
	
	if( !isdefined( pos ) )
		pos = self.origin;
	if( !isdefined( pos ) )
		return;
	
	f = anglestoforward( self.angles )*20;
	r = anglestoright( self.angles )*-20;
	u = anglestoup( self.angles )*20;
	
	for( i = 1; i != time; i++ )
	{
		//x
		thread draw_line( pos, pos + f, 0.05, (1,0,0) );
		//y
		thread draw_line( pos, pos + r, 0.05, (0,0,1) );
		//z
		thread draw_line( pos, pos + u, 0.05, (0,1,0) );
		
		wait 0.05;
	}
}

draw_collision( color )
{
	self notify("draw_collision");
	self endon("draw_collision");
	
	if( !isdefined( color ) )
		color = random_color_dark();
	
	
	if( self.physics["colType"] == "cube" )
	{
		while(1)
		{
			f = anglestoforward( self.angles )*self.physics["colSize"];
			r = anglestoright( self.angles )*self.physics["colSize"]*-1;
			u = anglestoup( self.angles )*self.physics["colSize"];
			
			thread draw_line( self.origin, self.origin + f/2, 0.05, (1,0,0) );
			thread draw_line( self.origin, self.origin + r/2, 0.05, (0,0,1) );
			thread draw_line( self.origin, self.origin + u/2, 0.05, (0,1,0) );
			
			thread draw_line( self.origin - f - u - r, self.origin + f - u - r, 0.05, color );
			thread draw_line( self.origin - f + u - r, self.origin + f + u - r, 0.05, color );
			thread draw_line( self.origin - f - u + r, self.origin + f - u + r, 0.05, color );
			thread draw_line( self.origin - f + u + r, self.origin + f + u + r, 0.05, color );
			
			thread draw_line( self.origin - f - u - r, self.origin - f - u + r, 0.05, color );
			thread draw_line( self.origin + f - u - r, self.origin + f - u + r, 0.05, color );
			thread draw_line( self.origin - f + u - r, self.origin - f + u + r, 0.05, color );
			thread draw_line( self.origin + f + u - r, self.origin + f + u + r, 0.05, color );
			
			thread draw_line( self.origin - f - u - r, self.origin - f + u - r, 0.05, color );
			thread draw_line( self.origin + f - u - r, self.origin + f + u - r, 0.05, color );
			thread draw_line( self.origin - f - u + r, self.origin - f + u + r, 0.05, color );
			thread draw_line( self.origin + f - u + r, self.origin + f + u + r, 0.05, color );
			
			wait 0.05;
		}
	}
}

error( x, text )
{
	if( x )
		iprintlnbold( "^1" + text );
}

arrow( n, normal, pos)
{
	if( !isDefined( level.testarrow ) )
		level.testarrow = [];
	if( !isDefined( pos ) )
		pos = self eyepos() + anglesToForward( self getPlayerAngles() ) * 200;
	if( !isDefined( level.testarrow[n] ) )
	{
		level.testarrow[n] = spawn( "script_model", pos );
		level.testarrow[n] setModel( "projectile_sidewinder_missile" );
		
	}
	else
		level.testarrow[n].origin = pos;
	level.testarrow[n].angles =  (0,90,0) - vectortoangles( normal );
}

bullettrace_debug( start, end, hit_characters, ignore_entity )
{
	drawline( start, end, 0.1 );
	return bullettrace( start, end, hit_characters, ignore_entity );
}

physicstrace_debug( start, end )
{
	drawline( start, end, 0.1 );
	return physicstrace( start, end );
}

printz( t0, t1, t2, t3, t4, t5, t6, t7, t8, t9 )
{
	t = "";
	
	spacer = " ^1: ^7";
	
	if( isdefined( t0 ) )
		t = t0;
	if( isdefined( t1 ) )
		t += spacer + t1;
	if( isdefined( t2 ) )
		t += spacer + t2;
	if( isdefined( t3 ) )
		t += spacer + t3;
	if( isdefined( t4 ) )
		t += spacer + t4;
	if( isdefined( t5 ) )
		t += spacer + t5;
	if( isdefined( t6 ) )
		t += spacer + t6;
	if( isdefined( t7 ) )
		t += spacer + t7;
	if( isdefined( t8 ) )
		t += spacer + t8;
	if( isdefined( t9 ) )
		t += spacer + t9;
	
	iprintln( t );
}

/*  -   Matrix   - */

Matrix_solve( A, b )
{
	
	//extended matrix
	A[0][3] = b[0];
	A[1][3] = b[1];
	A[2][3] = b[2];
	
	//iprintln( "Original: " );
	//print_matrix( A );
	
	M = A;
	
	for(i=0;i<3;i++)
	{
		A = pivot_row( M, i );
		M = A;
		for(j=0;j<3;j++)
		{
			if( M[j][i] && j != i )
				M = restore_row( subtract_row( multiply_row(M,i,M[j][i]) ,j,i), A, i );
		}
	}
	
	return (M[0][3],M[1][3],M[2][3]);
	
}

restore_row(M,A,n)
{
	for(i=0;i<4;i++)
		M[n][i] = A[n][i];
	//iprintln( "Restoring row " + n );
	//print_matrix( M );
	return M;
}

multiply_row(M,n,s)
{
	for(i=0;i<4;i++)
		M[n][i] *= s;
	//iprintln( "Multiplying row " + n + " by " + s );
	//print_matrix( M );
	return M;
}

subtract_row(M,n,j)	//n-j
{
	for(i=0;i<4;i++)
		M[n][i] -= M[j][i];
	//iprintln( "Subtracting row " + j + " from row " + n + " ( " + n + " - " + j + " ) " );
	//print_matrix( M );
	return M;
}

pivot_row( M, n )
{
	if(!M[n][n])	//if its 0 it has to be swapped with row x
	{
		x = biggest_value_index( (0,M[1][n]*(n<1),M[2][n]*(n<2)) );
		
		//swap row
		temp = M[n];
		M[n] = M[x];
		M[x] = temp;
		
		//iprintln( "Swapping row " + n + " with " + x );
		//print_matrix( M );
	}
	
	//divide row to pivot
	d = M[n][n];
	
	for(i=0;i<4;i++)
		M[n][i] /= d;
	
	
	//iprintln( "Pivoting row " + n + " ( divide by " + d + " ) " );
	//print_matrix( M );
	
	return M;
}

print_matrix(A)
{
	iprintln( ".");
	for(i=0;i<A.size;i++)
	{
		line = "";
		for(j=0;j<A[i].size;j++)
			line += A[i][j] + " | ";
		
		iprintln( line );
	}
	iprintln( ".");
}

/*  -   Sound   - */

playSoundOnPosition( soundAlias, pos, local )
{
	soundObj = spawn("script_model", pos);
	if( isdefined( local ) && local )
		soundObj playSoundToPlayer( soundAlias, self );
	soundObj playSound( soundAlias );
	soundObj delete();
}

PlayLoopSoundToPlayer( soundAlias, length, endon_str )
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("spawned");
	self endon( endon_str );
	
	while( true )
	{
		self playlocalsound( soundAlias );
		wait length;
	}
}

playlocalsoundloop( SoundAlias, repeatTime)
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self notify( "stoplocalsoundloop_"+SoundAlias );
	self endon( "stoplocalsoundloop_"+SoundAlias );
	
	for(;;)
	{
		self playlocalsound( "fall_wind_sound" );
		wait repeatTime;
	}
}


PlayLoopSound( soundAlias, length, endon_str )
{
	self endon( endon_str );
	
	while( true )
	{
		if( !isdefined( self ) )
			return;
		self playsound( soundAlias );
		wait length;
	}
	
}

/*  -   Other   - */

waittill_any( string1, string2, string3, string4, string5 )
{
	assert( isdefined( string1 ) );
	
	if ( isdefined( string2 ) )
		self endon( string2 );

	if ( isdefined( string3 ) )
		self endon( string3 );

	if ( isdefined( string4 ) )
		self endon( string4 );

	if ( isdefined( string5 ) )
		self endon( string5 );
	
	self waittill( string1 );
}

clean_array( array )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		if ( !isdefined( array[i] ) )
			continue;
		newarray[newarray.size] = array[i];
	}
	return newarray;
}
