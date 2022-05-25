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



#include sr\libs\portal\_general;
#include sr\libs\portal\_hud;
#include sr\libs\portal\_portal;

// ################################# &&

main()	//this is onplayerconnect
{

}


onPlayerSpawned()
{

}


watchvelocity()
{
	self endon("disconnect");
	self endon("death");

	playingsound = 0;

	for(;;)
	{
		vel2 = lengthsquared( self getvelocity() );

		if( vel2 > 600*600 || ( playingsound && ( vel2 > 200*200 || ( self.portal["inportal"] && !self isonground() ) ) ) )
		{
			if( !playingsound )
			{
				self thread startwindsoundloop();
				playingsound = 1;
			}
		}
		else
		{
			if( playingsound )
			{
				self notify( "stopwindsound" );
				self stoplocalsound( "fall_wind_sound_start" );
				self stoplocalsound( "fall_wind_sound_loop" );
				playingsound = 0;

				if( !self isonground() )
					self playlocalsound( "fall_wind_sound_end" );
				else
					self playlocalsound( "fall_wind_sound_endfast" );
			}
		}

		if( playingsound )
			wait 0.05;
		else
			wait 0.1;

	}
}

startwindsoundloop()
{
	self endon( "death" );
	self endon( "disconnect" );

	self endon( "stopwindsound" );

	self playlocalsound( "fall_wind_sound_start" );

	wait 1;

	self stoplocalsound( "fall_wind_sound_start" );

	for(;;)
	{
		self playlocalsound( "fall_wind_sound_loop" );
		wait 4.9;
	}

}


/*
watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	for(;;)
	{
		self waittill("begin_firing");
		self watchcurrentfiring();
	}
}*/


watchfps()
{
	self notify("stop_watch_fps");
	self endon("stop_watch_fps");
	self endon("disconnect");

	while( true )
	{
		if( !getdvarint( "portal_release_fps" ) )
			self setclientdvar( "con_maxfps", level.capfps );
		wait 0.1;
	}
}

monitor_death()
{
	//self endon("stop_all");
	self endon("disconnect");
	while( true )
	{
		self waittill_any("death","joined_spectators");//,"spawned");
		self thread stop_all(1);
	}
}

monitor_dc()
{
	//self endon("stop_all");
	self waittill("disconnect");
	self thread stop_all(1,true);
}

watchdoubletapKey( button, func )
{
	self endon("stop_watch_button");

	limit = 10;

	while( 1 )
	{
		if( self [[button]]() )	//player pressed usebutton once
		{
			while( self [[button]]() )	//wait for player to release the button
				wait 0.05;

			count = 0;
			for(; count<limit && !self [[button]](); count++)	//wait for player to press the button again or time to run out
				wait 0.05;

			if( count != limit )	//player pressed usebutton twice in time limit
				self thread [[func]]();

			while( self [[button]]() )	//wait for him to release the button again and restart check
				wait 0.05;

		}
		wait 0.05;
	}
}

usebutton()
{
	return self usebuttonpressed();
}
meleebutton()
{
	return self meleebuttonpressed();
}

watchUsage()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	//self endon("stop_all");

	while( true )
	{
		self waittill( "menuresponse", menu, response );

		if( menu == "portal" )
		{
			if( (!level.inPrematchPeriod || level._debug) && isdefined( self.pers["team"] ) && self.pers["team"] != "spectator" )
			{
				if( !self isonladder() && !self ismantling() && !self.throwingGrenade )
				{
					if( self getCurrentWeapon() == level.portalgun )
					{


						if( ( response == "blue" || response == "red" ) )
						{
							if( self.portal["can_use"] )
							{
								self thread fire();
								self playlocalsound( "portal_gun_shoot_"+response );
								//thread PlaySoundonPosition( "portal_gun_shoot_"+response, self.origin );
								self thread setup_portal( response );

								wait 0.3;
							}
						}

						else if( response == "pickup" )
						{
							self thread portal\_pickup::pickup_init();
							wait 0.3;
						}
					}
					else if( self getCurrentWeapon() == level.portalgun_bendi )
					{
						if( response == "pickup" )
						{
							self thread portal\_pickup::pickup_init();
							wait 0.4;
						}
					}
					else
						wait 0.1;


					if( response == "turret" )
					{
						self thread turret();
						wait 0.1;
					}

					//if( response == "test" )
					//	self thread test();

				}
				else
					wait 0.1;
			}
			else
				wait 0.5;
		}
	}
}

reset_portals()
{
	self notify("Deactivate_Portals");

	self thread Delete_Portal( "blue" );
	self thread Delete_Portal( "red" );

	self thread updatehud( "default" );
}

startup()
{
	self _exec( "bind mouse1 openscriptmenu portal blue;bind mouse2 openscriptmenu portal red;" );

	self thread watchdoubletapKey( ::usebutton, ::reset_portals );
	self thread watchdoubletapKey( ::meleebutton, ::aim_down_sight );

	self thread watchfps();


	//self allowsprint( false );
	self allowads( false );
	self setweaponammoclip( level.portalgun, 0 );

	self.portal["inzoom"] = false;
	self.portal["can_use"] = false;

	if( self.portal["blue_exist"] )
		self updatehud( "blue" );
	else if( self.portal["red_exist"] )
		self updatehud( "red" );
	else
		self thread updatehud( "default" );

	self thread playStartupSound();
	self thread usedelay();

}

usedelay()
{
	self endon("death");
	self endon("disconnect");
	self endon("weapon_change");

	wait 0.55;

	self.portal["can_use"] = true;

}

playStartupSound()
{
	self endon("death");
	self endon("disconnect");
	self endon("weapon_change");

	if( !self.portal["played_intro"] && level.portal_mode != 1 )
	{

		self playlocalsound( "portal_gun_activation" );

		wait 0.8;


		if( self getstat( level.portal_options_num+1 ) == 1 )
			self playlocalsound( "portalgun_intro" );
		else if( self getstat( level.portal_options_num+1 ) == 0 )
		{
			self playlocalsound( "glados_first_intro" );
			self setstat( level.portal_options_num+1, 1 );
		}

		self.portal["played_intro"] = true;
	}
}

stop_all( delete_portals, disconnected )
{
	if( delete_portals )	//player has died or dced
	{
		self notify("Deactivate_Portals");

		self thread Delete_Portal( "blue" );
		self thread Delete_Portal( "red" );

		self notify("place_turret");
		if( isdefined( self.test_turret) )
			self.test_turret delete();

		for( i = 0; i < self.turrets.size; i++ )
			self.turrets[i] portal\_turret::delete_turret();

		self.turrets = [];	//update array when delete_turret is called by some other thread?

		self thread dropPortalgunForDeath(disconnected);
	}

	self notify("stop_watch_button");
	self notify("stop_watch_fps");


	//self setClientDvar( "cl_bypassmouseinput", 1 );
	if( isdefined( disconnected ) )
		return;

	if( self getstat( level.portal_options_num ) == 2 )
		self _exec( "bind mouse1 +attack;bind mouse2 +speed_throw;" );	//hold
	else
		self _exec( "bind mouse1 +attack;bind mouse2 +toggleads_throw;" );

	//self allowsprint( true );
	if( self hasweapon( level.portalgun ) && !delete_portals )
		self setweaponammoclip( level.portalgun, 0 );

	//if(self.portal["inzoom"]) self thread Portal_Zoom_Out();
	self allowads( true );
	self.portal["inzoom"] = false;
	self.portal["can_use"] = false;
	//if(self.hasobject) self thread LetDown_Object();

	//NOTE: Add 0.05 secs? player can switch weapon and keep portal hud
	self thread updatehud( "none" );

	self notify("stop_all");



}

fire()
{
	self endon("disconnect");
	self endon("death");
	//NOTE: change to grenade_weapon
	//setDvar( "sv_clientsidebullets", 0 );
	weap = self getcurrentweapon();
	self setweaponammoclip( weap, 1 );
	self _exec( "-attack;+attack;-attack" );

	/*
	wait 0.05;
	if( !isdefined( self ) )
		return;
	self setweaponammoclip( weap, 0 );*/
	//wait 0.05;
	//setDvar( "sv_clientsidebullets", 1 );
}

turret()
{

	if( !getdvarint( "portal_allow_turrets" ) )
	{
		self iprintln( "Turrets not allowed" );
		return;
	}

	if( self.turrets.size >= getdvarint( "portal_max_turrets" ) )
	{
		self notify("place_turret");

		if( isdefined( self.test_turret ) )
			self.test_turret delete();

		self iprintln( "You cannot spawn any more turrets" );
		return;
	}

	if( !isdefined( self.test_turret ) )
	{
		eye = self eyepos();
		angles = self getPlayerAngles();

		pos = eye + anglestoforward( angles )*(15 + level.pickup_object_distance + 17 ) - (0,0,30);
		self.test_turret = spawn( "script_model", pos );
		self.test_turret setmodel( "turret" );
		self.test_turret hidepart( "tag_eye" );

		self endon("death");
		self endon("disconnect");
		self endon("place_turret");

		old_eye = (0,0,0);
		old_ang = (0,0,0);

		for(;;)
		{
			eye = self eyepos();
			angles = self getPlayerAngles();

			if( eye!=old_eye || angles!=old_ang )
			{
				self.test_turret moveto( playerphysicstrace( eye, eye + anglestoforward( angles )*(15 + level.pickup_object_distance + 17 ) - (0,0,30)), 0.1 );
				self.test_turret rotateto( (0,angles[1],0), 0.1 );
			}

			old_eye = eye;
			old_ang = angles;
			wait 0.1;
		}
	}
	else
	{
		for( i = 0; i < level.players.size; i++ )
		{
			pos1 = level.players[i].origin;
			pos2 = self.test_turret.origin;
			if( distancesquared( (pos1[0],pos1[1],0), (pos2[0],pos2[1],0) ) < 37*37 && pos2[2]-pos1[2] > -40 && pos2[2]-pos1[2] < 60 )
			{
				self iprintln( "turret too close to player" );
				return;
			}
		}
		self notify( "place_turret" );
		self.turrets[self.turrets.size] = self thread portal\_turret::spawn_turret( self.test_turret.origin, self.test_turret.angles );
		self.test_turret delete();
	}


}



/*print()
{
	logprint( level.turret_log + "break;\n\n\n" );
	irpintln( "Turret Log Printed" );
}

saveturret()
{
	level.turret_log += "Loc["+level.turretnum+"][0] = " + level.turret.origin + "; ";
	level.turret_log += "Loc["+level.turretnum+"][1] = " + level.turret.angles + "; \n";
	iprintln( "Turret "+level.turretnum+" saved" );
	iprintln( "Vergess nicht den Log zu printen!" );
	level.turretnum++;
}*/

test()
{

	//guid = getSubStr( self getguid(), 24, 32 );
	//if( guid != "060485e6" || guid != "35d98773" )
	//	return;

	/*if( !isdefined( level.turret ) )
		level.turret = portal\_portal::spawn_portal_object( "turret", (0,0,0), (0,0,0), "cylinder", 10, 0.3, 0.25, true, 0.1, 20 );


	if( isdefined(level.t_inpos) && level.t_inpos == true )
		return;

	level.t_inpos = true;

	level.turret.origin = self.origin;

	iprintln( "Turret "+level.turretnum + " Position Set" );

	self endon( "stop_test" );

	self thread test_ang();

	while( true )
	{
		level.turret.angles = self getplayerangles();
		wait 0.2;
	}*/



}
/*
test_ang()
{
	while( true )
	{
		self waittill( "menuresponse", menu, response );
		if( response == "test" )
		{
			self notify( "stop_test" );
			iprintln( "Turret "+level.turretnum + " Angles Set" );
			level.t_inpos = false;
			return;
		}
	}
}*/


/*portaldebug()
{
	while( true )
	{

		draw_text( level.portaltracer, ".", 0.05, (0.3,0,0.3), 1, 0.2 );
	}
}*/


setup_portal(color)		// various checks weather the portal can be placed or not
{


	othercolor = othercolor( color );

	eye = self eyepos();	// Position of player's eye
	forward = anglesToForward( self getPlayerAngles() ) * level.maxdistance;

	trace = trace_array( eye, eye + forward, false, level.portalobjects );

	//Checks wether hit position is too far away
	if( trace["fraction"] == 1 )
		portalfailed = true;
	else
		portalfailed = false;

	//Check for valid surface
	if( !portalfailed )
	{
		portalfailed = true;
		for( i = 0; i < level.portalSurfaces.size; i++ )
			if( trace["surfacetype"] == level.portalSurfaces[i] )
				portalfailed = false;
	}

	//if( isdefined( trace["surfacetype"] ) )
	//	iprintln( trace["surfacetype"] );

	terrain = !getdvarint( "portal_forbid_terrain" );


	//define usefull variables
	oldpos = trace["position"];
	pos = oldpos;
	normal = trace["normal"];
	angles = vectortoangles( normal );

	on_ground = false;	//var telling if portal is on ground or ceiling
	on_terrain = false;

	if( abs(round(normal[2],3-terrain)) == 1 )		//wider tolerance for terrain floors
		on_ground = true;

	if( on_ground  )
		angles = ( angles[0], self getPlayerAngles()[1] - 180, 0 );

	right =	anglestoright( 	angles 	);
	up = 	anglestoup( 	angles 	);

	//	iprintln( "normal: " + normal[2] + " on ground: " + on_ground );

	if( !portalfailed )
	{

		slope_increase = abs(normal[2])*3 * !on_ground;

		width = level.portalwidth;
		height = level.portalheight + slope_increase;	//make the portal check bigger for sloped walls, so portal fx doesnt go into floor

		if( on_ground )		//on ceiling or ground, widen check for other portals
			width = height * 0.8;

		/*
		this part will check if other portals might interfere with the portal that is being placed
		portals that are close to the portal being placed and are on the same wall, are saved in the 'portals' array for a second check later
		*/

		forward = 	normal * (1 + terrain*5*on_ground);	//widen check acceptance on uneven surfaces (for terrain)
		backward = 	forward * -1;


		portals = [];

		for( i = 0; i < level.portals.size; i++ )
		{
			if( isDefined( self.portal[color] ) )
				if( self.portal[color] == level.portals[i] )
					continue;

			p = level.portals[i].trace["position"];
			q = pos;

			vec = pos - level.portals[i].trace["position"];

			a = level.portals[i].trace["right"];
			b = level.portals[i].trace["up"];
			c = level.portals[i].trace["normal"];

			trans = ( vectordot( vec, a ), vectordot( vec, b ), vectordot( vec, c ) );	//translation of portal1 from portal2 oriented by portal2's angles

			if( !( round(trans[2],-1) ) )	//other portal is on same wall
			{
				x = abs(trans[0]);
				y = abs(trans[1]);
				if( x < 2*width && y < 2*height )	//possible interactions between portals
					portals[portals.size] = level.portals[i];

				if( x < width && y < height )		//other portal is inside of portal
				{
					if( y < x*(height/width) )		//move up
						pos = p + b * trans[1] + a * width * sign( trans[0] );
					else
						pos = p + a * trans[0] + b * height * sign( trans[1] );

					if( trace_array( p + forward, pos + forward, false, level.portalobjects )["fraction"] != 1 )
					{
						portalfailed = true;
						break;
					}
				}
			}

		}

		//level.portaltracer = pos;
		//level.debugtracenum = 0;
		//wait 1;
		//thread portaldebug();


		vec = [];
		vec[1] = up*(1+(height/2));		//up
		vec[2] = vec[1] * -1;			//down
		vec[3] = right*(1+(width/2))*-1;//right, players POV
		vec[4] = vec[3] * -1;			//left

		//diagonal directions

		a = 0.8;

		vec[5] = ( vec[1] + vec[3] ) * a;	//up-right
		vec[6] = vec[5] * -1;				//left-down
		vec[7] = ( vec[1] + vec[4] ) * a;	//up-left
		vec[8] = vec[7] * -1;				//right-down


		failed = [];	//this will store the directions which failed with the check

		vital_dir = [];		//vital_dir is going to show which directions have to have passed for the current check, example: down-check needs up trace to not have hit a wall
		for( i = 1; i < 9; i++ )
		{
			vital_dir[i] = [];
			failed[i] = false;	//set the whole array to false
		}

		for( i = 2; i < 9; i+=2 )	//add opposite directions
			vital_dir[i][0] = i-1;

		vital_dir[5][0] = 2;	//up-right-check needs both, down and left trace to not have hit a wall, and so on..
		vital_dir[5][1] = 4;
		vital_dir[6][1] = 1;
		vital_dir[6][2] = 3;
		vital_dir[7][0] = 2;
		vital_dir[7][1] = 3;
		vital_dir[8][1] = 1;
		vital_dir[8][2] = 4;

		updated_pos = pos;
		second_check = false;

		/*
		this part will move the portal being placed away from walls and ledges
		if a wall is interfering the portal will be repositioned and the check will be run again
		if there is still a wall interfering on the second check it cannot be placed
		*/
		for( i = 1; i < 9 && !portalfailed; i++ )
		{

			//level.portaltracer = pos;

			/*
			vec[i] is the current side being checked ^

			hit: fraction from portal's side to center (infront of portal)
			hit == 0: nothing in the way					,hit = false
			hit >  0: hit fraction of wall in way			,hit = true
			*/

			//do a trace from the middle to each side
			//NOTE: add slope increase, depending on the normal difference of portal wall and trace hit wall, to remove the glitchy looks on terrain
			hit = 1 - trace_array( pos + forward, pos + forward + vec[i], false, level.portalobjects )["fraction"];

			if( !hit )		//no wall on portal's side
			{
				tmp_ground_trace = trace_array( pos + forward + vec[i], pos + backward + vec[i], false, level.portalobjects );
				if( tmp_ground_trace["fraction"] == 1 )		//portal's side is not on a surface (must be a ledge then)
					hit = trace_array( pos + backward + vec[i], pos + backward, false, level.portalobjects )["fraction"];	//hit: fraction from portal's side to center (behind portal!), checking ledges
				if( hit == 1 )
					portalfailed = true;	//portal was placed on the edge of terrain?? (no object infront or behind portal)

				//add a check if the floor is terrain
				if( !on_terrain && on_ground && tmp_ground_trace["fraction"] == 1 )
					on_terrain = normal != tmp_ground_trace["normal"];
			}

			//hit = round(hit,2);

			if( hit )	//side is too close to a wall or a ledge
			{
				if( !on_ground || (on_ground && second_check) )	//if the portal is on the floor it has more possibilities to reposition, so just leave this out
				{
					for( j = 0; j < vital_dir[i].size; j++ )
					{
						if( failed[vital_dir[i][j]] )
						{
							//iprintln( "failed placing portal, since hit side " + vital_dir[i][j] );
							portalfailed = true;
						}
					}
				}

				//wait 0.05;

				failed[i] = true;

				if( portalfailed )
					break;

				updated_pos -= vec[i] * ( hit + 0.02 );	//move portal away from wall given the fraction

				//this part eliminates weird behavior and can be ignored for understanding
				//(it at first doesnt update pos with updated_pos, so it can be positioned correctly if portal is on a wall and there is a corner sticking out, rare case )
				if( i <= 4 && !second_check && !on_ground )
				{
					if( (failed[1]+failed[2]+failed[3]+failed[4]) >= 2 )	//start check from beginning with the new updated pos
					{
						pos = updated_pos;
						second_check = true; i = 0; continue;
						for( i = 1; i < 9; i++ )
							failed[i] = false;	//reset the fail array
					}
				}
				else
					pos = updated_pos;



				//iprintln( "side " + i + " hit: " + hit );
				//wait 0.05;
			}

			//NOTE: trace i+1 can be skipped (i<=4) if i hit a wall, add this?

			if( i == 4 )	//if right/left/up/down-traces are done, update the position
			{
				pos = updated_pos;
				if( (failed[1]+failed[2]+failed[3]+failed[4]) && !second_check)	//restart, if a wall was hit
				{
					second_check = true; i = 0; continue;
					for( i = 1; i < 9; i++ )
						failed[i] = false;
				}
			}
		}



		//2nd check if surrounding portals are too close (after repositioning from wall)
		for( i = 0; i < portals.size && !portalfailed; i++ )
		{
			vec = pos - portals[i].trace["position"];
			a = portals[i].trace["right"];
			b = portals[i].trace["up"];
			x = vectordot( vec, a );
			y = vectordot( vec, b );
			if( ( abs(x) < width - 1 ) && ( abs(y) < height - 1 ) )
				portalfailed = true;
		}



	}


	portal_out_pos = (0,0,0);
	safe_exit = (0,0,0);

	if( !portalfailed )
	{
		//move portal out-position, so player doesn't get stuck coming out of portals
		portal_out_pos = pos + normal * ( ( normal[2] >= 0 ) * ( 20 * ( 1 - normal[2] ) ) + ( -90 * normal[2] ) * ( normal[2] < 0 ) );	//move legs away, move head away

		safe_exit = portal_out_pos - 30 * ( 1 - abs(normal[2]) ) * up;

		//check if theres enough space for the player to get out
		if( playerphysicstrace( safe_exit, safe_exit + normal ) != (safe_exit + normal) )
			portalfailed = true;

	}



	/*	portal was positioned correctly and now has to be created 	*/
	if( !portalfailed )
	{
		trace["position"] = pos;
		trace["fx_position"] = pos + normal*( 1 + on_terrain*2 );	//move forward, so portal wont look glitchy in terrain
		trace["start_position"] = eye;
		trace["old_position"] = oldpos;

		trace["portal_out"] = portal_out_pos;
		trace["safe_exit"] = safe_exit;
		trace["on_ground"] = on_ground;

		trace["angles"] = angles;
		trace["right"] = right;
		trace["up"] = up;

		self Create_Portal( color, trace );
	}

	/*
	portal cannot be created
	*/
	else
	{
		self playLocalSound( "portal_invalid_surface_player" );

		if( trace["fraction"] != 1 )
		{
			self playSoundOnPosition( "portal_invalid_surface", trace["position"], true );
			if( !getdvarint("portal_disable_fancy_fx") )
				playfx( level._effect[color+"portal_fail"], trace["position"] + trace["normal"] );
			//self iprintln(trace["surfacetype"]);
		}
		//else
			//iprintln("too far");
	}

}


Delete_Portal( color )
{

	for(i=0;i<level.players.size;i++)	//workaround for some odd bugg which kept on occuring
		if( level.players[i].portal["inportal"] )
			level.players[i] freezecontrols( false );


	if( !self.portal[color + "_exist"] )
		return;
	error( !isdefined( self.portal[color] ) ,"Tried to delete, but " + color + "portal is not defined" );

	level notify( "portal_rearange" );

	self.portal[color] stoploopSound();
	self.portal[color] playSound( "portal_close" );
	self.portal[color] playSound( "portal_close_"+color );
	self.portal[color] notify("stop_fx");


	if( !getdvarint("portal_disable_fancy_fx") )
		playfx( level._effect[color + "portal_close"], self.portal[color].trace["position"], self.portal[color].trace["normal"], self.portal[color].trace["up"] );

	self.portal[color].dummy delete();

	self.portal[color] delete();

	self.portal[color + "_exist"] = false;

	clean_portal_array( self.portal[color] );
}

Create_Portal( color, trace )
{

	for( i = 0; i < level.players.size; i++ )
		level.players[i].portal["inportal"] = false;	//reset


	self updatehud( color );

	self Delete_Portal( color );

	portal[color] = spawn( "script_model", trace["fx_position"] );	//this will also catch bullets
	portal[color] setcontents( 0 );

	portal[color].angles = trace["angles"] + (180,0,0);	//maya decided to break down, so ill just manually rotate it

	portal[color].trace = trace;
	portal[color].color = color;
	portal[color].active = false;


	portal[color].dummy = spawn( "script_model", trace["fx_position"] );
	portal[color].dummy.angles = trace["angles"];
	portal[color].dummy setcontents( 0 );

	//portal[color].id = randomint( 10000 );

	portal[color].owner = self;

	self.portal[color] = portal[color];
	level.portals[level.portals.size] = self.portal[color];

	self.portal[color + "_exist"] = true;

	if( self.portal["blue_exist"] && self.portal["red_exist"] )
		self thread Activate_Portals();

	portal[color] thread Portal_fx();

	/*
	pos = trace["fx_position"];

	f = trace["normal"]*20;
	r = trace["right"]*-20;
	u = trace["up"]*20;

	for( i = 1; i != 20*20; i++ )
	{
		//x
		thread draw_line( pos, pos + f, 0.05, (1,0,0) );
		//y
		thread draw_line( pos, pos + r, 0.05, (0,0,1) );
		//z
		thread draw_line( pos, pos + u, 0.05, (0,1,0) );

		wait 0.05;
	}*/
}


Portal_fx()
{

	self endon("stop_fx");

	oldpos = self.trace["old_position"];
	fxpos = self.trace["fx_position"];
	p = self.trace["start_position"];
	p += vectornormalize( oldpos - p ) * 33;

	speed = 1500;

	t = length( fxpos - p ) / speed*1.5;

	if( t > 0.5 )
		t = 0.5;

	self.bullet = spawn( "script_model" , (-10000,0,0) );
	self.bullet setmodel( "collision_sphere" );


	//bullet setcontents( 1 );

	wait 0.05;

	playfxontag( level._effect["portalball"+self.color], self.bullet, "collision_sphere" );

	angles = self.owner getplayerangles();

	f = anglestoforward(angles);
	u = anglestoup(angles);
	r = vectorprod(f,u);

	self.bullet move_curve( self.owner eyepos() + f*22 + u*-6 + r, oldpos, self.trace["position"], t );

	//play sound
	self thread playOpenSound( self.color, fxpos + self.trace["normal"]*2 );

	self hide();
	self setmodel( "portal_" + self.color );


	self.dummy hide();
	self.dummy setmodel( "portal_dummy_" + self.color );

	//open effect
	if( !getdvarint("portal_disable_fancy_fx") )
	{
		playfx( level._effect[self.color + "portal_open"], fxpos, self.trace["normal"], self.trace["up"] );
		wait 0.75;
	}

	if( getdvarint("portal_dummy_show_to_team") && isdefined(self.pers["team"]) )
	{

		team = self.pers["team"];

		for(i=0;i<level.players.size;i++)
			if( isdefined(level.players[i].pers["team"]) && (level.players[i].pers["team"] == team) )
				self.dummy showtoplayer( level.players[i] );
	}
	else
		self.dummy showtoplayer( self.owner );

	self show();

	wait 0.6;

	self playloopSound( "portal_ambient_loop" );

}


playOpenSound( color, soundPos )
{
	self endon( "stop_fx" );

	wait 0.3;

	playSoundOnPosition( "portal_open", soundPos );
	playSoundOnPosition( "portal_open_"+self.color, soundPos );

}


move_curve( p, q1, q2, t )
{
	//self hide();

	self.origin = p;

	n = 6;			//edges in curve
	curve = 1;		//curve amount (x*0.5) ( > 1 ), 0.5 = linear interpolate

	if( t < 0.3 )
	{
		n = 3;
		t *= 1.5;
	}

	vec1 = q1 - p;
	vec2 = q2 - q1;

	t /= n;

	vecx = (0,0,0);

	for( i = 1; i < n+1 ; i++ )
	{
		if( i != 1 )
			wait t;
		fraction = exp( i / n, curve * 2);
		vec = vec2*fraction + i*vec1/n;
		//t = length( vec - vecx ) / (n * speed);
		vecx = vec;
		pos = p + vec;
		//pos = (int(pos[0]),int(pos[1]),int(pos[2]));
		self moveto( pos, t );
	}

	self thread delete_fx_after_time( t );
}

delete_fx_after_time( t )	//deleting a spawned fx is buggy
{
	wait t;
	self moveto( (0,0,100000), 0.05 );
	wait 0.1;
	self delete();
}


Portal_wait( color, othercolor )
{
	self endon("Deactivate_Portals");

	p1 = self.portal[color];
	p2 = self.portal[othercolor];

	self.portal[color].otherportal = self.portal[othercolor];

	c = ((0,0,level.gravity) + (0,0,15)) * -0.05;	//constant showing the increase in velocity through gravity in 0.05 secs ( for 125 fps )

	while( true )
	{
		for( i = 0; i < level.players.size; i++ )
		{
			if( getdvarint( "portal_owner_walkthrough_only" ) )
				if(	level.players[i] != self )
					continue;

			if( level.players[i].portal["inportal"] )	//player is already in portal
				continue;


			player_on_ground = level.players[i] isonground();

			vel = level.players[i] getvelocity() * 0.05;

			check_dist = level.portalcheckdist;
			if( player_on_ground )
				check_dist *= 0.2;

			else if( vectordot(vel,p1.trace["normal"]) > 60 )
				check_dist *= 1.5;

			if( !(distancesquared( p1.trace["position"], level.players[i].origin ) < check_dist*check_dist ) )	//player isnt in the check-distance
				continue;

			if( vectordot(vel,p1.trace["normal"]) > 0 || vectordot(level.players[i].origin-p1.trace["position"]+(0,0,5),p1.trace["normal"]) <= 0 )	//player isn't coming at portal
				continue;

			vec = level.players[i].origin + level.players[i] getcenter() - p1.trace["position"] + vel + c*(vel[2]<0);	//vector from portal1 to players center, only add gravity, if player is falling
			offset = ( vectordot( vec, p1.trace["right"] ), vectordot( vec, p1.trace["up"] ), vectordot( vec, p1.trace["normal"] ) );	//estimated player offset from portal1's view in 0.05 secs

			z = abs(p1.trace["normal"][2]);

			x_add = -16;
			y_add = 0;//z*-16;

			if( isinportal(offset[0],offset[1],x_add,y_add) && offset[2] < (z * 40 + (1-z) * 20) )//&& offset[2] > 0 )	//actually (z * playerheight/2 + (1-z) * playerwidth/2), but added some extra space
				level.players[i] Portal_Kick( p1, p2, vel );

		}
		wait 0.05;
	}
}


// ################################# &&



Portal_Kick( p1, p2, vel )
{

	self endon("death");
	self endon("disconnect");

	self.portal["inportal"] = true;

	//strength = vectordot( vel, p1.trace["normal"]*-1 ) ;

	//iprintln("___KICK");

	strength = length(vel);

	if(strength < 0 )	//coming from the back, behind the wall
	{
		wait 0.05;
		self.portal["inportal"] = false;
		return;
	}

	if( self.portal["first_enter"] )
	{
		//iprintln( "yep" );
		strength += 5;
		self thread watch_airtime();
	}


	strength = int(strength*0.2)*5;
	if( ( strength < 15 ) && ( p2.trace["normal"][2] >= 0 ) )
		strength = 15 * ( p2.trace["normal"][2] ) + ( p2.trace["normal"][2] == 0 )*1.5;
	else if( p2.trace["normal"][2] == -1 )
		strength = 10;

	multiplier = 210;
	if( strength >= 40 && strength <= 50 )
		multiplier = 192;
	else if( strength >= 55 && strength <= 70 )
		multiplier = 180;
	else if( strength >= 70 )
		multiplier = 160;

	if( strength >= 20 )
		self playLocalSound( "player_portal_enter" );

	vec = self.origin - p1.trace["position"];
	offset = ( vectordot( vec, p1.trace["right"] ), vectordot( vec, p1.trace["up"] ), 0 );	//current offset from portal1's view
	//iprintln(offset[1]);
	if( abs(offset[0]) > (level.portalwidth/2 - 16 ) )
		offset = ( (level.portalwidth/2 - 16 )*sign(offset[0]), offset[1], 0 );


	if( offset[1] < (level.portalheight/-2) )
		offset = ( offset[0], (level.portalheight/-2), 0 );
	/*
	**NOTE: Add different Stances?
	*/
	if( offset[1] > (level.portalheight/2 - 72 ) )
		offset = ( offset[0], (level.portalheight/2 - 72 ), 0 );

	position = p2.trace["portal_out"] + p2.trace["right"] * offset[0] * -1 + p2.trace["up"] * offset[1];
	if( playerphysicstrace( position, position + p2.trace["normal"] ) != position + p2.trace["normal"] )	//player will get stuck, use safe exit
		position = p2.trace["safe_exit"];

	p1 playsound( "portal_enter" );
	//self PlayLocalSound( "portal_enter" );

	//iprintln( strength );

	self resetVelocity( position );

	//help player orientation
	if( !(getdvarint("portal_help_orientation") && p1.trace["on_ground"] && p2.trace["on_ground"]) )	//disable rotations completely if dvar is true and both portals on ground
		self setplayerangles( portal_out_angles_player( p1.trace["angles"], p2.trace["angles"], self getPlayerAngles() ) );



	earthquake( 0.5, 0.2, self eyepos(), 100);

	self thread portal_turn_z();

	//iprintln(strength);

	self thread launch( "MOD_UNKNOWN", "portal", self.origin, p2.trace["normal"], strength * multiplier );

	//NOTE: check dis shit
	//playSoundOnPosition( "player_portal_enter" + randomintrange(1,3),  );

	wait 0.05;

	p2 playsound( "portal_exit" );

	if( p2.trace["normal"][2] >= 0 )
		wait 0.45;
	else
		wait 0.1;

	self.portal["inportal"] = false;

}

resetVelocity( pos )
{
	//self endon("disconnect");
	//iprintln("stopped controls");
	self freezeControls( true );
	wait 0.05;
	if(!isdefined(self) )
	{
		//iprintln("not defined");
		return;
	}
	//iprintln("start controls");
	self freezeControls( false );
	self setOrigin( pos );

}

watch_airtime()
{
	self endon("death");
	self endon("disconnect");

	self.portal["first_enter"] = false;

	while( !self isonground() )
		wait 0.1;

	self.portal["first_enter"] = true;
}

portal_turn_z()
{
	self notify("portal_turn_z");
	self endon("portal_turn_z");

	self endon("death");
	self endon("disconnect");


	angles = self getPlayerAngles();
	if( !angles[2] ) return;

	if( abs( angles[2] ) == 180 )
		if( RandomIntRange( 0, 2) )
			angles *= (1,1,-1); 	//if player gets turned z 180 degrees, script should randomize the turn direction

	sign = sign( angles[2] );	//angles[2] / abs(angles[2]);	//sign = signum

	startValue = 15; //	/ ( 180 / abs( angles[2] ) );
	turnAmount = startValue;

	for( x = 0; abs( angles[2] ) - turnAmount > 0; x++ )
	{
		wait 0.05;
		angles = self getPlayerAngles() - ( 0, 0, turnAmount * sign);
		self setPlayerAngles( angles );
		turnAmount = StartValue * exp( 0.95, x);
		//iprintln( turnAmount );
	}

	self setPlayerAngles( self getPlayerAngles() * (1,1,0) );

}




aim_down_sight()
{
	if( !self.portal["inzoom"] )
		self thread Portal_Zoom_In();
	else
		self thread Portal_Zoom_Out();
}

Portal_Zoom_In()
{
	self allowads( true );
	self _exec( "+toggleads_throw" );
	self.portal["inzoom"] = true;
}

Portal_Zoom_Out()
{
	self allowads( false );
	self _exec( "-toggleads_throw" );
	self.portal["inzoom"] = false;
}




Activate_Portals()
{

	self notify("Deactivate_Portals");

	self thread Portal_wait( "blue" ,"red" );
	self thread Portal_wait( "red" ,"blue" );

	self.portal["blue"].active = true;
	self.portal["red"].active = true;

}




clean_portal_array( portal )
{
	newarray = [];
	for( i = 0; i < level.portals.size; i ++ )
	{
		if ( level.portals[i] == portal )
			continue;
		newarray[newarray.size] = level.portals[i];
	}
	level.portals = newarray;
}

