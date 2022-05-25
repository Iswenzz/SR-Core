#include sr\libs\portal\_general;

stop_physics()
{
	self notify( "physics_stop" );
	self.origin = self.origin;
	self.angles = self.angles;
}


portalobjectCollisionTrace( start, end )	//check if there is a portal object in the way
{
	//trace = self portalobjectCollisionTrace_only( end );
	trace["hit"] = false;	//kept simple for grenades
	if( !trace["hit"] )
	{
		ignore_ents = self add_portal_ignore_ents();
		trace = trace_array( start, end, false, ignore_ents );
		trace["hit"] = (trace["fraction"] != 1);
	}
	else
		iprintln( "hit pobject" );
	return trace;

}

add_portal_ignore_ents()
{
	ignore_ents = [];

	ignore_ents[0] = self;

	if(isdefined(self.physics["model_parts"]))
	{
		for(i=0;i<self.physics["model_parts"].size;i++)
			ignore_ents[i+1] = self.physics["model_parts"][i];
	}

	for(i=0;i<level.portalobjects.size;i++)
		ignore_ents[ignore_ents.size] = level.portalobjects[i];	//adds self twice, but wth

	return ignore_ents;
}


start_physics( initial_vel )
{
	/*
	TODO:
	end on max
	add max count
	*/

	self notify( "physics_start" );
	self endon( "physics_start" );
	self endon( "physics_stop" );

	obj_bounce = self.physics["bounce"];
	obj_adhesion = self.physics["adhesion"];

	colSize = self.physics["colSize"];


	obj_rotate = self.physics["rotate"];
	obj_rotation_speed = self.physics["rotation_speed"];

	rotation = 4;	//rotation duration
	max = 10;	//max time the object should be able to fall

	strengthmin = 10;	//decides when the object should stop bouncing on floor

	increase = (0,0,-2);	//constant increase in speed due to gravity

	trace["position"] = (0,0,0);	//just to define the variable, not important
	trace["normal"] = (0,0,-1);		//^


	vel = initial_vel/20;
	strength = length( vel );

	while( strength > strengthmin*(1-obj_bounce) || trace["normal"][2] <= (1 - obj_adhesion) )
	{
		//iprintln("move");
		self movegravity( vel*20, max );

		while( true )	//loop calculating the freefall
		{
			vel += increase;
			pos1 = self.origin;
			pos2 = pos1 + vel;

			if( self.physics["colType"] == "cube" )
				add = vectornormalize(vel)*colSize + ((0,0,-1)*colSize/2) * (sign2(vel[2])!=1);	//giveobjectcollisionradius(vel) is exact, but not needed since it all happens fast
			else	//( self.physics["colType"] == "sphere" )
				add = vectornormalize(vel)*colSize;	//note: change this back to upper script (not needed though, since im only using it on grenades atm)

			trace = self portalobjectCollisionTrace( pos1, pos2 + add );

			if( trace["hit"] )	//object hit a wall/object	//NOTE: Change back to ["hit"]!!!
				break;

		}

		surface_bounce = surface_bounce( trace["surfacetype"] );


		//reflection vector projected at wallnormal
		vel1 = vectordot( trace["normal"], vel ) * trace["normal"] * -1;

		//reflection vector projected at wall (needed later for rotation)
		vel2 = vel + vel1;

		//calculate the reflection vector
		vel = vel1 + vel2;

		//calculate lost force
		vel = (vel + increase*2)*( 1 - (1-obj_bounce)*(1-surface_bounce) );

		strength = length( vel );


		//calculate rotation
		//damn rotations, explanation: http://www.freemathhelp.com/forum/threads/76822-Rotation-Matrix-to-RPY?p=316782&posted=1#post316782
		/*
		if( obj_rotate )
		{

			//rotate object about orthogonal vector to the output vector
			ortho = vectornormalize( vectorprod( vel, trace["normal"] ) );

			ortho = rotatevec_z( ortho, self.angles[1]*-1 );

			//buggy after other rotations
			//ortho = rotatevec_y( ortho, self.angles[0]*-1 );
			//ortho = rotatevec_x( ortho, self.angles[2]*-1 );

			angles = ( ortho[1], ortho[2], ortho[0] )*-1;

			rotation_strength = length( vel2 );

			self rotatevelocity( angles*obj_rotation_speed*rotation*20*rotation_strength, rotation, rotation*0.05, rotation*0.95 );

		}*/

		if( isdefined( self.physics["bounce_sound"] ) )
			self playsound( self.physics["bounce_sound"] );//self playsound( "cube_hit_0" + randomintrange(1,10) );

	}

	self.angles = normalize_angles(self.angles);



	/*
	n = vectorprod( trace["normal"], (0,0,-1) );

	if( n != (0,0,0) )	//wallnormal pointing in opposite direction of gravity dir
	{
		n = rotatevec_z( n, self.angles[1]*-1 );

		n = ( round(n[1],3), round(n[0],3), round(n[2],3) )*-1;

		iprintln( "^5" + n );
	}

	a = self.angles;

	if( n[0] )
		a = (snap_angle(a[0],90),a[1],a[2]);
	if( n[1] )
		a = (a[0],snap_angle(a[1],90),a[2]);
	if( n[2] )
		a = (a[0],a[1],snap_angle(a[2],90));
	*/


	/* Snapping to floor */ //note: very poorly scripted, cod4s rotations are just too hard to understand
	if( self.physics["colType"] == "cube" )
	{
		alpha = 0;
		beta = 0;
		if( round(trace["normal"][2],1) != 1 )
		{
			//try to find the face that is the closest to ground
			v[0] = anglestoforward( self.angles );
			v[1] = anglestoright( self.angles )*-1;
			v[2] = vectorprod( v[0], v[1] );

			inverted = [];
			distances=[];
			for(i=0;i<3;i++)
			{
				inverted[i] = 1;

				distances[i] = distancesquared( v[i], trace["normal"]*-1 );
				if(distances[i]>2)	//degree between wallnormal and vector > 90�
				{
					//v[i] *= -1;		//invert the vector
					//iprintln( "inverting " + i );
					inverted[i] = -1;
					distances[i] = distancesquared( v[i], trace["normal"] );

				}
			}

			x = smallest_value_index( distances );	//index of the face-normal that is pointing to ground

			if(!( x==2 && inverted[2]==-1 ) )	//z isnt up, fk it, too complicated (could add every case)
			{
				//self.angles = (self.angles[0],self.angles[1],0);

				/*	Tried rotating the cube so that z will be up since it works then
				x = smallest_value_index( distances );
				iprintln(x);
				drawline( trace["position"]+(0,0,20),trace["position"]+(0,0,20)+v[x]*inverted[x]*50 );

				self.origin = trace["position"]+(0,0,20);
				iprintln("rotating z up");

				wait 5;

				rotate = (90*(x==0)*inverted[0]*-1+180*(x==2)*(inverted[2]==1),0,90*(x==1)*inverted[1]);

				self.angles += rotate;
				*/
			}
			else
			{
				x=-1;
				if(distancesquared( v[0], trace["normal"]*-1 )>2)	//degree between wallnormal and vector > 90�
					x =1;

				alpha = acos(vectordot( vectornormalize(vectorprod(v[1],trace["normal"] )), v[0] ))*x;
				beta = acos(vectordot( vectornormalize(vectorprod(v[0],trace["normal"] )), v[2] ));
			}
		}

		snap_angles = (snap_angle_90(self.angles[0], alpha),self.angles[1],snap_angle_90(self.angles[2], beta));

		new_angles = snap_angles;
	}
	else
		new_angles = self.angles;


	//NOTE:
	//add no stand on turrets and spheres
	//finish box trace

	/*if( isdefined(trace["hit_object"]) )	//object is on an object
	{

	}
	else*/
	//self.origin = boxCollisionTrace( trace["position"]+(0,0,0.1), new_angles, colSize, self ); //end + (0,0,20);//
	self.origin = trace["position"]+(0,0,self.physics["colSize"]);

	self rotateto( new_angles, 0.05 );
	self notify( "physics_stop" );

}







/* Physics for Grenade ( just to keep it simple for now ) */

start_grenade_physics( initial_vel, is_c4 )
{
	self notify( "physics_start" );
	self endon( "physics_start" );
	self endon( "physics_stop" );
	self endon( "remove" );

	obj_bounce = 0.2;
	obj_adhesion = 0.1;
	strengthmin = 10;

	//rotation = 4;

	increase = (0,0,-2);

	trace["position"] = (0,0,0);
	trace["normal"] = (0,0,-1);


	vel = initial_vel/20;
	strength = 100;

	max = 10;

	bounce_count = 0;

	maxloops = 5;
	infinite_loop_stop = maxloops;	//just added for safety

	while( ( strength > strengthmin*(1-obj_bounce) || trace["normal"][2] < (1 - obj_adhesion) ) && infinite_loop_stop >= 0 )
	{
		self movegravity( vel*20, max );
		//vel -= increase;

		wait 0.05;	//needs 0.05 secs to take effect

		vel += increase/2;	//not correct without this

		while( true )
		{
			waittillframeend;
			pos1 = self.origin;
			pos2 = pos1 + vel;

			//trace = bullettrace( pos1, pos2, false, self );	//NOTE: add can hit players
			ignore_ent[0] = self;
			if( isdefined( self.originalgrenade ) )
				ignore_ent[1] = self.originalgrenade;
			trace = self trace_array( pos1, pos2, false, ignore_ent );

			if( trace["fraction"] != 1 )
				break;

			infinite_loop_stop = maxloops;

			vel += increase;

			wait 0.05;


		}

		//iprintln("bounce");

		bounce_count++;

		if( is_c4 )
			break;

		vel1 = vectordot( trace["normal"], vel ) * trace["normal"] * -1;

		vel2 = vel + vel1;

		vel = vel1*0.25 + vel2*0.5;	//default settings

		strength = length( vel );

		self playsound( "grenade_bounce_"+trace["surfacetype"] );

		infinite_loop_stop--;

	}

	self.origin = trace["position"]+(0,0,2);

	if( isdefined( self.originalGrenade ) )	//could have been picked up
		self.originalGrenade show();
	self.angles = self.angles;
	//if( can_pickup )
	//	self thread portal\_portal::watchGrenadePickup();

	self delete();
	self notify( "physics_stop" );

}


surface_bounce( surfacetype )
{
	//iprintln( surfacetype );
	switch( surfacetype )
	{
		default:		return 0.5;
	}
}






/*
trace from player while he is holding an object using the given collision Size
*/
player_portalobjectCollisionTrace( start, angles, distance )
{
	ignore_ents = self add_portal_ignore_ents();

	colSize = self.physics["colSize"];
	object_radius = self.physics["colSize_forward"];	//NOTE: Add this shit

	r = 16;	//player radius
	h = 15;	//height above start: player height

	forward = anglestoforward( angles );
	pos = start + forward*( r + distance + colSize );

	object_radius = self givecollisionradius(forward);
	end = pos + forward*object_radius;

	//if( portal_trace( pos, angles, colSize, self ) )	//basically if object is in a portal. if it is, portal_trace will do the rest
	updatedpos = pos;

	playerheight = 25;	//NOTE: check players actual height, height/2

	for(i=0;i<level.players.size;i++)
	{
		vec = level.players[i].origin+(0,0,playerheight)-pos;
		obj_r = self givemaxcollisionradius();	//guess
		if( lengthsquared( (vec[0],vec[1],0) ) < exp( r+ obj_r, 2 ) && abs(vec[2]-obj_r)< playerheight )
		{
			obj_r = self givecollisionradius(vec);	//exact calculation
			if( lengthsquared( (vec[0],vec[1],0) ) < exp( r+ obj_r, 2 ) && abs(vec[2]-obj_r)< playerheight )
			{
				iprintln("hit player");
			}
		}
	}

	//do a trace forward
	trace = trace_array( start, end, false, ignore_ents, ignore_ents[0] );

	in_portal = false;

	angles2 = ( 0, angles[1], 0 );

	//this part would make the object show up on the other portal,
	/*
	if( trace["fraction"] != 1 )	//object hit wall
	{
		//check all active portals if object is inside them
		for( i = 0; i < level.portals.size && level.portals[i].activated; i++ )
		{
			vec = trace["position"] - level.portals[i].trace["position"];

			a = level.portals[i].trace["right"];
			b = level.portals[i].trace["up"];
			c = level.portals[i].trace["normal"];

			trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of trace["position"] from portal's point of view

			//portal boundaries
			max_x = (level.portalwidth/2-colSize);
			max_y = (level.portalheight/2-colSize);

			if( abs(trans[0]) < max_x && abs(trans[1]) < max_y && isOnSameWall( level.portals[i].origin, trace["position"], trace["normal"] ))		//object is inside of portal
			{

				in_portal = true;

				//make sure object stays inside portal
				vec = pos - level.portals[i].origin;
				trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of pos from portal's point of view

				if( abs(trans[0]) > max_x )
					trans = ( max_x*sign(trans[0]), trans[1], trans[2] );
				if( abs(trans[1]) > max_y )
					trans = ( trans[0], max_y*sign(trans[1]), trans[2] );

				if( isdefined( self.physics["mirrorobject"] ) )
				{
					if( level.portals[i].id == self.physics["mirrorobject"].portal1id && level.portals[i].otherportal.id == self.physics["mirrorobject"].portal2id )
						self notify("update_mirror_pos", trans, angles2 );
					else	//portals have changed
						self thread mirror_object( level.portals[i], level.portals[i].otherportal, trans, angles2 );
				}
				else
					self thread mirror_object( level.portals[i], level.portals[i].otherportal, trans, angles2 );

				updatedpos = level.portals[i].origin + trans[0]*a + trans[1]*b + trans[2]*c;


			}
		}


	}

	if( isdefined( self.physics["mirrorobject"] ) && !in_portal && !self.physics["mirrorobject"].delete )
	{
		self thread delete_mirror();
		//if( !self.physics["owner"].portal["inportal"] )
		//	self notify("update_mirror_pos", trans, angles2 );
	}
	*/

	if( !in_portal )
	{

		if( trace["fraction"] == 1 )	//no wall interfering forwards
		{
			//do a trace to the left
			left = vectorprod( (0,0,1), forward );
			trace = trace_array( pos, pos + left*object_radius, false, ignore_ents, ignore_ents[1] );
			if( trace["fraction"] == 1 )
			{
				//do a trace to the right
				trace = trace_array( pos, pos - left*object_radius, false, ignore_ents, ignore_ents[2] );
				if( trace["fraction"] == 1 )
				{
					//no walls interfering, check for other objects
					trace = self portalobjectcollisiontrace_only( pos );
					if( trace["hit"] )
					{
						//self thread draw_collision( (1,0,0) );
						return pos;
					}
					else
					{
						//self thread draw_collision( (0,1,0) );

						return pos;
					}
				}
			}
		}


		q = trace["position"];

		u = trace["normal"];
		a = vectordot( u, (start-q) ) - object_radius;


		wall_angles = vectortoangles( u*-1 );
		dir = sign( normalize_angle( angles[1] - wall_angles[1] ) );


		if( u == (0,0,1) )
		{

		}

		v = vectorprod( (0,0,1), u );	//NOTE: FIX
		w = vectorprod( u, v );

		c = vectordot( (q-start), w );

		b = abs(vectordot( q - start, v ));

		touchingplayer = ( a <= (r+object_radius) && b <= (r+object_radius) && c < h+object_radius );

		if( touchingplayer )
			b = sqrt( (r+object_radius)*(r+object_radius) - a*a );

		updatedpos = start - u*a - b*v*dir + w*c;

		t = trace_array( updatedpos + u, updatedpos - v*dir*object_radius + u, false, ignore_ents, ignore_ents[1] );

		//check if another wall is interfering at updatedpos
		if( t["fraction"] != 1 )
		{
			if( touchingplayer )
				updatedpos = start - u*a + b*v*dir + w*c ;	//switch to other side if player is in way
			else
				updatedpos = t["position"] + v*dir*object_radius - u;	//move away from second wall
		}

	}

	return updatedpos;
}


portalobjectCollisionTrace_only( pos )	//check if there is a portal object at pos
{

	trace["hit"] = false;
	trace["position"] = pos;
	trace["hit_object"] = undefined;
	trace["normal"] = undefined;

	for( i=0; i<level.portalobjects.size; i++)
	{
		if( self == level.portalobjects[i] )
			continue;
		if( isdefined( self.physics["ignore_ents"] ) )
			if( level.portalobjects isinarray(self.physics["ignore_ents"]) )
				continue;

		if( exp(self givemaxcollisionradius() + level.portalobjects[i] givemaxcollisionradius(), 2 ) > distancesquared( pos, level.portalobjects[i].origin ) )	//cheap guess if objects might collide
		{
			vec = pos - level.portalobjects[i].origin;
			r1 = level.portalobjects[i] givecollisionradius( vec );
			r2 = self givecollisionradius( vec*-1 );

			if( exp( r1 + r2, 2 ) > distancesquared( pos, level.portalobjects[i].origin ) )	//objects collide
			{
				trace["hit"] = true;
				trace["hit_object"] = level.portalobjects[i];
				trace["normal"] = vectornormalize( vec );
				if( trace["normal"] == (0,0,0) )
					trace["normal"] = (0,0,1);

				trace["fraction"] = 1 - level.portalobjects[i] givecollisionradius( vec ) / length(vec);
				trace["position"] = level.portalobjects[i].origin + vec*trace["fraction"];
				trace["surfacetype"] = "portal_object";
				//thread draw_point( trace["position"], 5 );
				break;	//one check is enough
			}
		//iprintln("^2r = " +b);
		}
	}


	return trace;
}





givemaxcollisionradius()
{
	if( self.physics["colType"] == "sphere" )
		return self.physics["colSize"];
	if( self.physics["colType"] == "cube" )
		return self.physics["colSize"]*1.73;	//farthest point of cube from center
	if( self.physics["colType"] == "cylinder" )
		return self.physics["colHeight"]*1.2;	//cheap guess
	iprintln("^1error, coltype not set");
	return 0;
}

givecollisionradius( direction )
{
	array = [];
	if( direction == (0,0,0) )	//objects share the same position
	{
		array["radius"] = self givemaxcollisionradius();
		return array;
	}
	if( self.physics["colType"] == "sphere" )
		return self.physics["colSize"];
	if( self.physics["colType"] == "cube" )
	{

		a = anglestoforward( self.angles );					//forward vector
		b = anglestoright( self.angles )*-1;				//left vector
		c = vectorprod( a, b );								//up vector

		vec_dir = ( vectordot( direction, a ), vectordot( direction, b ), vectordot( direction, c ) );
		angles = normalize_angles(vectortoangles(vec_dir));

		M = [];
		M[0] = [];
		M[1] = [];
		M[2] = [];

		M[0][0] = a[0];
		M[0][1] = a[1];
		M[0][2] = a[2];
		M[1][0] = b[0];
		M[1][1] = b[1];
		M[1][2] = b[2];
		M[2][0] = c[0];
		M[2][1] = c[1];
		M[2][2] = c[2];

		//array["position"] = self.origin +


		//drawline( self.origin, self.origin + matrix_solve( vec_dir, self.angles ), 1 );
		alpha=max_45_deg(angles[1]);
		beta=max_45_deg(angles[0]);
		array["radius"] = ( self.physics["colSize"]/cos(alpha) )/cos(beta);
	}
	if( self.physics["colType"] == "cylinder" )
		return self.physics["colHeight"]*1.2;	//cheap guess
	iprintln("^1error, coltype not set");
	return array["radius"];
}

/*
givecollisionradius( direction )
{
	array = [];
	if( direction == (0,0,0) )	//objects share the same position
	{
		array["radius"] = self givemaxcollisionradius;
		return array;
	}
	if( self.physics["colType"] == "sphere" )
		return self.physics["colSize"];
	if( self.physics["colType"] == "cube" )
	{

		a = anglestoforward( self.angles );					//forward vector
		b = anglestoright( self.angles )*-1;				//left vector
		c = vectorprod( a, b );								//up vector

		vec_dir = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );
		angles = normalize_angles(vectortoangles(vec_dir));

		M = [];
		M[0] = [];
		M[1] = [];
		M[2] = [];

		M[0][0] = a[0];
		M[0][1] = a[1];
		M[0][2] = a[2];
		M[1][0] = b[0];
		M[1][1] = b[1];
		M[1][2] = b[2];
		M[2][0] = c[0];
		M[2][1] = c[1];
		M[2][2] = c[2];

		array["position"] = self.origin +


		drawline( self.origin, self.origin + matrix_solve( vec_dir, self.angles ), 1 );
		alpha=max_45_deg(angles[1]);
		beta=max_45_deg(angles[0]);
		array["radius"] = ( self.physics["colSize"]/cos(alpha) )/cos(beta);
	}
	if( self.physics["colType"] == "cylinder" )
		return self.physics["colHeight"]*1.2;	//cheap guess
	iprintln("^1error, coltype not set");
	return array;
}*/



















biggest_value( vec )
{
	return ( sign(vec[0])*(vec[0]>=vec[1]&&vec[0]>=vec[2]), sign(vec[1])*(vec[1]>vec[0]&&vec[1]>=vec[2]), sign(vec[2])*(vec[2]>vec[1]&&vec[2]>vec[0]) );
}

max_45_deg( angle )
{
	while( abs(angle) > 45 )
		angle = sign(angle) * 90 - angle;
	return angle;
}

/*
trace
17-10-13

portalobjectCollisionTrace( start, angles, distance, object, ignore_ent )
{
	if(isdefined(ignore_ent))
		ignore_ent[ignore_ent.size] = object;
	else
		ignore_ent[0] = object;

	colSize = object.physics["colSize"];

	r = 16;	//player radius
	h = 15;	//height above start: player height-eye (actual number would be 12)

	forward = anglestoforward( angles );
	pos = start + forward*( r + distance + colSize );
	end = pos + forward*colSize;

	//if( portal_trace( pos, angles, colSize, object ) )	//basically if object is in a portal. if it is, portal_trace will do the rest
	updatedpos = pos;


	//do a trace forward
	trace = trace_array( start, end, false, ignore_ent );

	in_portal = false;

	angles2 = ( 0, angles[1], 0 );

	if( trace["fraction"] != 1 )	//object hit wall
	{
		//check all active portals if object is inside them
		for( i = 0; i < level.portals.size && level.portals[i].activated; i++ )
		{
			vec = trace["position"] - level.portals[i].trace["position"];

			a = level.portals[i].trace["right"];
			b = level.portals[i].trace["up"];
			c = level.portals[i].trace["normal"];

			trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of trace["position"] from portal's point of view

			//portal boundaries
			max_x = (level.portalwidth/2-colSize);
			max_y = (level.portalheight/2-colSize);

			if( abs(trans[0]) < max_x && abs(trans[1]) < max_y && isOnSameWall( level.portals[i].origin, trace["position"], trace["normal"] ))		//object is inside of portal
			{

				in_portal = true;

				//make sure object stays inside portal
				vec = pos - level.portals[i].origin;
				trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of pos from portal's point of view

				if( abs(trans[0]) > max_x )
					trans = ( max_x*sign(trans[0]), trans[1], trans[2] );
				if( abs(trans[1]) > max_y )
					trans = ( trans[0], max_y*sign(trans[1]), trans[2] );

				if( isdefined( object.physics["mirrorobject"] ) )
				{
					if( level.portals[i].id == object.physics["mirrorobject"].portal1id && level.portals[i].otherportal.id == object.physics["mirrorobject"].portal2id )
						object notify("update_mirror_pos", trans, angles2 );
					else	//portals have changed
						object thread mirror_object( level.portals[i], level.portals[i].otherportal, trans, angles2 );
				}
				else
					object thread mirror_object( level.portals[i], level.portals[i].otherportal, trans, angles2 );

				updatedpos = level.portals[i].origin + trans[0]*a + trans[1]*b + trans[2]*c;


			}
		}


	}

	if( isdefined( object.physics["mirrorobject"] ) && !in_portal && !self.physics["mirrorobject"].delete )
	{
		object thread delete_mirror();
		//if( !object.physics["owner"].portal["inportal"] )
		//	object notify("update_mirror_pos", trans, angles2 );
	}

	if( !in_portal )
	{

		if( trace["fraction"] == 1 )	//no wall interfering forwards
		{
			//do a trace to the left
			left = vectorprod( (0,0,1), forward );
			trace = trace_array( pos, pos + left*colSize, false, ignore_ent );
			if( trace["fraction"] == 1 )
			{
				//do a trace to the right
				trace = trace_array( pos, pos - left*colSize, false, ignore_ent );
				if( trace["fraction"] == 1 )
					return end - forward*colSize;
			}
		}


		q = trace["position"];

		u = trace["normal"];
		a = vectordot( u, (start-q) ) - colSize;


		wall_angles = vectortoangles( u*-1 );
		dir = sign( normalize_angle( angles[1] - wall_angles[1] ) );


		v = vectorprod( (0,0,1), u );	//NOTE: FIX
		w = vectorprod( u, v );

		c = vectordot( (q-start), w );

		b = abs(vectordot( q - start, v ));

		touchingplayer = ( a <= (r+colSize) && b <= (r+colSize) && c < h+colSize );

		if( touchingplayer )
			b = sqrt( (r+colSize)*(r+colSize) - a*a );

		updatedpos = start - u*a - b*v*dir + w*c;

		t = trace_array( updatedpos + u, updatedpos - v*dir*colSize + u, false, ignore_ent )["position"];

		//check if another wall is interfering at updatedpos
		if( (updatedpos - v*dir*colSize + u) != t )
		{
			if( touchingplayer )
				updatedpos = start - u*a + b*v*dir + w*c ;	//switch to other side if player is in way
			else
				updatedpos = t + v*dir*colSize - u;	//move away from second wall
		}

	}

	return updatedpos;
}*/



mirror_object( portal1, portal2, trans, angles )
{
	self notify("stop_mirror");
	self endon("stop_mirror");

	pos = portal2.origin + portal2.trace["right"]*trans[0]*-1 + portal2.trace["up"]*trans[1] + portal2.trace["normal"]*trans[2]*-1;

	if( !isdefined( self.physics["mirrorobject"] ) )
	{
		self.physics["mirrorobject"] = spawn( "script_model", pos );
		self.physics["mirrorobject"] setmodel( self.physics["name"] );
	}

	self.physics["mirrorobject"].origin = pos;
	self.physics["mirrorobject"].angles = portal_out_angles( portal2.angles, portal1.angles, angles );


	self.physics["mirrorobject"].portal1id = portal1.id;
	self.physics["mirrorobject"].portal2id = portal2.id;

	self.physics["mirrorobject"].delete = false;

	while( true )
	{
		self waittill("update_mirror_pos", trans, angles );

		self.physics["mirrorobject"] moveto( portal2.origin + portal2.trace["right"]*trans[0]*-1 + portal2.trace["up"]*trans[1] + portal2.trace["normal"]*trans[2]*-1, 0.1 );
		self.physics["mirrorobject"] rotateto( portal_out_angles( portal2.angles, portal1.angles, angles ), 0.1 );

	}
}





delete_mirror()
{
	self.physics["mirrorobject"].delete = true;
	wait 0.1;
	self notify("stop_mirror");
	self.physics["mirrorobject"] delete();
	self.physics["mirrorobject"] = undefined;
}









/*
portal_trace( pos, angles, colSize, object )
{
	//check all active portals if object is inside them
	for( i = 0; i < level.portals.size && level.portals[i].activated; i++ )
	{
		vec = pos - level.portals[i].trace["position"];

		a = level.portals[i].trace["right"];
		b = level.portals[i].trace["up"];
		c = level.portals[i].trace["normal"];

		trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of pos from portal's point of view

		if( abs(trans[0]) < (level.portalwidth/2-colSize) && abs(trans[1]) < (level.portalheight/2-colSize) && trans[2] < colSize && trans[2] > colSize*-2)		//object is inside of portal
		{
			pos2 = level.portals[i].otherportal.trace["position"] + level.portals[i].otherportal.trace["right"]*trans[0]*-1 + level.portals[i].otherportal.trace["up"]*trans[1] + level.portals[i].otherportal.trace["normal"]*trans[2]*-1;
			angles2 = portal_out_angles( level.portals[i].otherportal.trace["angles"], level.portals[i].trace["angles"], angles );

			iprintln( trans[2] );

			if( !isdefined( object.physics["mirrorobject"] ) )
			{
				object.physics["mirrorobject"] = spawn( "script_model", pos2 );
				object.physics["mirrorobject"] setmodel( object.physics["name"] );
			}
			object.physics["mirrorobject"] moveto( pos2, 0.1 );
			object.physics["mirrorobject"].angles = (0,angles2[1],0);

			return true;
		}
	}
	return false;
}


*/















boxCollisionTrace( pos, angles, colSize, ignore_ent )
{

	pos += (0,0,colSize);

	forward = 	anglestoforward( angles );
	right = 	anglestoright( angles );
	up = vectorprod( right, forward );

	vec = [];
	vec[0] = forward*(1+colSize);	//forward
	vec[1] = vec[0] * -1;			//backward
	vec[2] = right*(1+colSize);		//right
	vec[3] = vec[2] * -1;			//left
	vec[4] = up*(1+colSize);		//up
	vec[5] = vec[4] * -1;			//down

	//move object away from walls
	fail = [];

	for( i = 0; i < 6; i++ )
	{
		//vec[i] is the current side being checked ^

		hit = 1 - bulletTrace( pos , pos + vec[i], false, ignore_ent )["fraction"];

		if( hit )	//object is too close to a wall
		{
			fail[fail.size] = i;	//side
			fail[fail.size] = hit;	//fraction to move object away from wall
			i++;	//would be meaningless to move the object forwards and then backwards
		}
	}

	for( i = 0; i < fail.size; i += 2 )
		pos -= vec[fail[i]] * fail[i+1];	//move object away from wall given the fraction

	return pos;
}