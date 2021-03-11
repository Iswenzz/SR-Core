/**/

#include sr\portal\general;


/*

spawncollisionwall(pos,angles,width,height)
{
	test = spawn( "script_model", pos );
	test setmodel( "collision_wall_100x75" );
	
	right = anglestoright( angles );
	up = anglestoup( angles );
	
	radius = 10;
	
	for( n = 0; n < height; n+= radius )
	{
		for( i = 0; i < width; i+= radius )
		{
			tmp = spawn( "script_model", pos + up*n + right*i);
			tmp setModel( "tag_origin" );
			tmp setcontents( 1 );
		}
		
	}
}


project_wall( start, angles )
{
	obj = spawnstruct();
	obj thread project_wall_2( start, angles, 1 );
}

project_wall_2( start, angles,r )
{
	
	
	//!!move normal fx further infront, add start fx without kill
	
	
	
	self endon( "kill_projected_wall" );
	
	maxdist = 10000;
	
	forward = anglestoforward( angles );
	right = anglestoright( angles );
	up = anglestoup( angles );
	
	end = bullettrace( start, start + forward * maxdist, false, undefined )["position"];
	
	if( distancesquared( start, end ) > (maxdist*maxdist) )
	{
		iprintln( "^1projected wall length bigger than " + maxdist );
		return;
	}
	
	self.wall = spawnfx( level._effect["projected_wall"], start, up, forward );
	self.wall_end = spawnfx( level._effect["projected_wall_end"], end, up, right );
	
	triggerfx( self.wall, -10000 );
	triggerfx( self.wall_end, -10000 );
	
	
	self.nextwall = spawnstruct();
	self.nextactive = false;
	if( !r )
	return;
	while( true )
	{
		for( i = 0; i < level.portals.size; i++ )
		{
			if( level.portals[i].activated )
			{
				trans = point_translation( level.portals[i].trace["position"], end, level.portals[i].trace["normal"], level.portals[i].trace["right"], level.portals[i].trace["up"] );
				
				if( !( round(trans[2],2) ) )	//portal is on same wall
				{
					if( abs(trans[0]) < level.portalwidth/2 && abs(trans[1]) < level.portalheight/2 )
					{
						iprintln( " wall in portal " );
						
						
						self.nextwall thread project_wall_2( level.portals[i].otherportal.trace["position"], level.portals[i].otherportal.angles, 0);//portal_out_angles( level.portals[i].angles, level.portals[i].otherportal.angles, angles ) );
						//nextactive = true;
					}
				}
			}
		}
		level waittill( "portal_rearange" );
		wait 0.05;
						if( self.nextactive )
							self.nextwall kill_projected_wall();
		
	}
}

kill_projected_wall()
{
	self.wall delete();
	self.wall_end delete();
	self notify( "kill_projected_wall" );
	
	if( self.nextactive )	//delete all next walls
		self.nextwall kill_projected_wall();
}
*/


redlaser( start, angles )
{
	obj = spawnstruct();
	obj thread _redlaser( start, angles );
}

_redlaser( start, angles )
{
	
	self endon( "kill_laser" );
	
	maxdist = 10000;
	
	forward = anglestoforward( angles );
	
	end = bullettrace( start, start + forward * maxdist, false, undefined )["position"];
	
	if( distancesquared( start, end ) > (maxdist*maxdist) )
	{
		iprintln( "^1laser length bigger than " + maxdist );
		return;
	}
	
	self.laser = spawnfx( level._effect["redlaser"], start, forward ) ;
	//self.laser_end = spawnfx( level._effect["redlaser_end"], end, forward );
	
	triggerfx( self.laser, -100 );
	//triggerfx( self.laser_end, -10000 );
	
	
	self.nextlaser = spawnstruct();
	self.nextactive = false;
	
	while( true )
	{
		for( i = 0; i < level.portals.size; i++ )
		{
			if( level.portals[i].activated )
			{
				trans = point_translation( level.portals[i].trace["position"], end, level.portals[i].trace["normal"], level.portals[i].trace["right"], level.portals[i].trace["up"] );
				
				if( !( round(trans[2],2) ) )	//portal is on same wall
				{
					if( abs(trans[0]) < level.portalwidth*0.3 && abs(trans[1]) < level.portalheight*0.3 )
					{
						iprintln( " laser in portal " );
						
						
						//self.nextlaser thread _redlaser( level.portals[i].otherportal.trace["position"], portal_out_angles( level.portals[i].angles, level.portals[i].otherportal.angles, angles ) );
						//nextactive = true;
					}
				}
			}
		}
		
		iprintln( " ! " );
		level waittill( "portal_rearange" );
		wait 0.05;
		
		if( self.nextactive )
			self.nextlaser kill_laser();
		
	}
}

kill_laser()
{
	self.laser delete();
	//self.laser_end delete();
	self notify( "kill_laser" );
	
	if( self.nextactive )	//delete all next walls
		self.nextwall kill_laser();
}





//addfx( fx )