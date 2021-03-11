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

#include sr\portal\portal;
#include sr\portal\general;

main()
{
	
	
}

AddDvar( dvar )
{
	dvar = "portal_" + dvar;
	value = getdvarInt( dvar );
	setDvar( dvar, value );
	return value;
}


onPlayerConnect()
{
	
	while( true )
	{
		level waittill( "connected", player);
		
		player thread portal\portal_gun::main();
		
		player thread setup_vars();
		
		player thread load_settings();
		player thread watchOptionsChange();
		
		//player thread portal\daycycle::onPlayerDisconnect();
	
	}
}



load_settings()
{
	
	//loads the players right-mouse-button
	stat = self getstat( level.portal_options_num );
	
	if(	stat == 2 )
		self setclientdvar( "_p_options_ads", 2 );	//used when the player loads the next map (and suddenly needs normal settings again), or if he leaves through the ingame menu
	else
		self setclientdvar( "_p_options_ads", 1 );
	
	
	//loads the daycycle setting
	stat = self getstat( level.portal_options_num+2 );
	
	if( stat == 1 || ( getdvarInt( "portal_daycycle_default_on" ) && !stat ) )
		self thread portal\daycycle::On();
	else
		self thread portal\daycycle::Off();
	
}




setup_vars()
{
	
	self setClientDvar("r_distortion", 1);
	
	
	self.portal = [];
	self.portal["blue_exist"]	= false;
	self.portal["red_exist"] 	= false;
	
	self.portal["object"] = undefined;
	self.portal["bendi_fx_playing"] = false;
	self.portal["inzoom"] = false;
	self.portal["inportal"] = false;
	self.portal["can_use"] = true;
	self.portal["forceturretshoot"] = false;
	self.portal["played_intro"] = false;
	
	self.portal["saved_weapon"] = [];
	self.portal["saved_ammoclip"] = [];
	self.portal["saved_ammostock"] = [];
	
	self.portal["hud"] = NewClientHudElem( self );
	
	self thread setupDvars();
	

}

setupDvars()
{
	
	//Dvars that need to be read client side via a menu
	
	self setClientDvar( "_p0rtal_exec", "\"\"" );
	self setClientDvar( "portal_version", level.version );
	self setClientDvar( "portal_mode", level.portal_mode );
	self setClientDvar( "portal_daycycle_default_on", getdvarint("portal_daycycle_default_on") );
}


watchOptionsChange()
{
	self endon("disconnect");
	while( true )
	{
		self waittill( "menuresponse", menu, response );
		//if( menu == "portal_options" )
		{
			if( response == "toggle_ads0" )
			{
				self setstat( level.portal_options_num, 2 );
				self setclientdvar( "_p_options_ads", 2 );	//used for the next map
				//self setClientDvar("_p0rtal_options_ads", self getstat(9000));
			}
			if( response == "toggle_ads1" )
			{
				self setstat( level.portal_options_num, 1 );
				self setclientdvar( "_p_options_ads", 1 );
				//self setClientDvar("_p0rtal_options_ads", self getstat(9000));
			}
			
			if( response == "sound_intro1" )
				self setstat( level.portal_options_num+1, 1 );
			if( response == "sound_intro0" )
				self setstat( level.portal_options_num+1, 2 );
			
			if( response == "daycycle0" )
			{
				self setstat( level.portal_options_num+2, 2 );
				self thread portal\daycycle::Off();
			}
			if( response == "daycycle1" )
			{
				self setstat( level.portal_options_num+2, 1 );
				self thread portal\daycycle::On();
			}
			
		}
		
	}
}

/*
watchOptionsChange()
{
	self endon("disconnect");
	while( true )
	{
		self waittill( "menuresponse", menu, response );
		iprintln( menu + " ," + response );
		
	}
}*/

precache()
{
	
	//portal\turret::precache();
	
	cheap_sin_setup();
	
	
	
	//portalgun
	preCacheItem( level.portalgun );
	preCacheItem( level.portalgun_bendi );
	
	//Models
	preCacheModel( "collision_wall_100x75" );
	preCacheModel( "collision_sphere" );
	/*preCacheModel( "axis" );
	preCacheModel( "projectile_sidewinder_missile" );*/
	
	//preCacheModel( "cake" );
	preCacheModel( "cube" );
	preCacheModel( "companion_cube" );
	preCacheModel( "energy_ball" );
	
	preCacheModel( "portal_dummy_blue" );
	preCacheModel( "portal_dummy_red" );
	preCacheModel( "portal_blue" );
	preCacheModel( "portal_red" );
	
	//Menus
	
	preCacheMenu( "portal" );
	preCacheMenu( "portal_options" );
	//preCacheMenu( "portal_options_popup" );
	preCacheMenu( "portal_about" );
	preCacheMenu( "_exec" );
	/*
	preCacheMenu( "__exec_fire" );
	preCacheMenu( "__exec_ads" );
	preCacheMenu( "__binds_portalgun" );
	preCacheMenu( "__binds_normal_toggle" );
	preCacheMenu( "__binds_normal_hold" );*/
	
	//Shader
	preCacheShader("reticle_portal");
	preCacheShader("reticle_portal_blue");
	preCacheShader("reticle_portal_red");
	preCacheShader("reticle_portal_both");
	
	
	level._effect["bullettest"]				= loadfx("portal/bullettest");
	
	//level._effect["blueportal"]				= loadfx("portal/portal_blue");
	//level._effect["redportal"]				= loadfx("portal/portal_red");
	level._effect["blueportal_open"]		= loadfx("portal/portal_blue_open");
	level._effect["redportal_open"]			= loadfx("portal/portal_red_open");
	level._effect["blueportal_close"]		= loadfx("portal/portal_blue_close");
	level._effect["redportal_close"]		= loadfx("portal/portal_red_close");
	level._effect["blueportal_fail"]		= loadfx("portal/portal_blue_fail");
	level._effect["redportal_fail"]			= loadfx("portal/portal_red_fail");
	
	level._effect["portalballblue"]			= loadfx("portal/portal_ball_blue");
	level._effect["portalballred"]			= loadfx("portal/portal_ball_red");
	
	level._effect["projected_wall"]			= loadfx("portal/projected_wall");
	level._effect["projected_wall_end"]		= loadfx("portal/projected_wall_end");
	//level._effect["projected_wall_start"]	= loadfx("portal/projected_wall_start");
	//level._effect["projected_wall_mask"]	= loadfx("portal/projected_wall_mask");
	
	level._effect["redlaser"]	= loadfx("portal/redlaser");
	
	//bullet impacts
	level._effects["impact_bark"] = 	 	 	 	 loadfx("impacts/large_woodhit");
	level._effects["impact_brick"] = 	 	 	 	 loadfx("impacts/small_brick");
	level._effects["impact_carpet"] = 	 	 	 	 loadfx("impacts/default_hit");
	level._effects["impact_cloth"] = 	 	 	 	 loadfx("impacts/cloth_hit");
	level._effects["impact_concrete"] = 	 	 	 loadfx("impacts/small_concrete");
	level._effects["impact_dirt"] = 	 	 	 	 loadfx("impacts/small_dirt");
	level._effects["impact_flesh"] = 	 	 	 	 loadfx("impacts/flesh_hit");
	level._effects["impact_foliage"] = 	 	 		 loadfx("impacts/small_foliage");
	level._effects["impact_glass"] = 	 	 	 	 loadfx("impacts/small_glass");
	level._effects["impact_grass"] = 	 	 	 	 loadfx("impacts/small_grass");
	level._effects["impact_gravel"] = 	 	 	 	 loadfx("impacts/small_gravel");
	level._effects["impact_ice"] = 	 	 	 		 loadfx("impacts/small_snowhit");
	level._effects["impact_metal"] = 	 	 	 	 loadfx("impacts/small_metalhit");
	level._effects["impact_mud"] =	 	 	 	 	 loadfx("impacts/small_mud");
	level._effects["impact_paper"] = 	 	 	 	 loadfx("impacts/default_hit");
	level._effects["impact_plaster"] = 	 	 		 loadfx("impacts/small_concrete");
	level._effects["impact_rock"] = 	 	 	 	 loadfx("impacts/small_rock");
	level._effects["impact_sand"] = 	 	 	 	 loadfx("impacts/small_dirt");
	level._effects["impact_snow"] = 	 	 	 	 loadfx("impacts/small_snowhit");
	level._effects["impact_water"] = 	 	 	 	 loadfx("impacts/small_waterhit");
	level._effects["impact_wood"] = 	 	 	 	 loadfx("impacts/large_woodhit");
	level._effects["impact_asphalt"] = 	 	 		 loadfx("impacts/small_concrete");
	level._effects["impact_ceramic"] = 	 	 		 loadfx("impacts/small_ceramic");
	level._effects["impact_plastic"] = 	 	 		 loadfx("impacts/large_plastic");
	level._effects["impact_rubber"] = 	 	 	 	 loadfx("impacts/default_hit");
	level._effects["impact_cushion"] = 	 	 	 	 loadfx("impacts/cushion_hit");
	level._effects["impact_fruit"] = 	 	 	 	 loadfx("impacts/default_hit");
	level._effects["impact_paintedmetal"] = 	 	 loadfx("impacts/large_metal_painted_hit");
	level._effects["impact_flesh_body_nonfatal"] = 	 loadfx("impacts/flesh_hit_body_nonfatal");
	level._effects["impact_flesh_body_fatal"] = 	 loadfx("impacts/flesh_hit_body_fatal_exit");
	level._effects["impact_flesh_head_nonfatal"] =   loadfx("impacts/flesh_hit_body_nonfatal");
	level._effects["impact_default"] = 	 	 	 	 loadfx("impacts/default_hit");
	
}





setup_portal_objects()
{
	
	
	//spawn_portal_gun( (0,-200,100) );
	
	
	/*
	if( getdvarint("portal_mode") == 1 )
	{
		player = 
	}*/
	
	
	
	/*
	
	//spawn_portal_object( "cake", (0,0,0), (0,0,0), true, 10 );
	
	c1 = spawn_portal_object( "companion_cube", (0,0,20), (0,0,0), "cube", 20, 0.3, 0.25, true, 0.3 );
	c2 = spawn_portal_object( "cube", (-200,0,20), (0,0,0), "cube", 20, 0.3, 0.25, true, 0.3 );*/
	//spawn_portal_object( "energy_ball", (0,0,20), (0,0,0), true, 10, 0.3, 0, true, 0.5 );
	/*
	
	wait 5;
	while(1)
	{
		//v = c1.origin - level.players[0].origin;
		//v = vectorprod( v, (0,0,1));
		//c1 rotateaxis( v , 0.05 );
		c1 rotatevelocity( (0,40,40), 0.05 );
		wait 0.05;
	}*/
	
	/*
	c1.angles = (0,0,0);
	wait 5;
	
	c1 rotatevelocity( rotatetest( 	(0.3333,0.9107,-0.244), (-0.244,0.3333,0.9107) )*10, 5 );
	
	wait 1.5;
	
	iprintln( c1.angles );
	*/
	/*
	while( 1 )
	{
	c1 rotatevelocity( (0.9107,-0.244,0.3333)*100, 1 );
	wait 1;
	}
	/*
	//c1 rotateto( (90,0,45), 1 );
	c1 rotatevelocity( (90,0,0), 1 );
	wait 2;
	c1 rotateto( (0,-135,-90), 1 );
	wait 2;
	*/
	//c1 rotatevelocity( (0,0,-90), 1 );
	//iprintln( "^2" + c1.angles );
	
	
	//spawn turrets,bounces
}
/*
rotateaxis( axis, time )
{
	axis = vectornormalize( axis )*20;
	drawline( self.origin - axis, self.origin + axis, 0.1, (0,0,0) );
	axis = (axis[1],axis[2],axis[0]);
	axis = vec_translation_angles_2( axis, self.angles );
	axis = (axis[1],axis[2],axis[0]);
	iprintln( axis );
	self rotatevelocity( axis*10, time );
}




vectorprod2d(vec1,vec2) //returns Z-direction of resulting vec.
{
	return(vec1[0]*vec2[1]-vec1[1]*vec2[0]);
}

rotatetest(fw, rg) //call on object
{
	a = vectortoangles(fw);
	if(rg[0] == 0 && rg[1] == 0)
	{
		if(rg[2] >0)
			a = (a[0], a[1], -90);
		else
			a = (a[0], a[1], 90);
	}
	else
	{
		if(vectorprod2d(rg, fw) <0)
			a = (a[0], a[1], 180 - asin(rg[2]));
		else
			a = (a[0], a[1], asin(rg[2]));
	}
	return a;
}*/






mute() // Mute Script By _DanTheMan_ !!
{
	// Wait for global logic to initiate
	for(;!isDefined(game["gamestarted"]);)
		wait 0.05;
	wait 0.05;

	// Remove suspense music that fucks up ambience
	for(i = 0;i < game["music"]["suspense"].size;i++)
		game["music"]["suspense"][i] = "null";

	// Remove dialog voice and intro/outro songs
	team[0] = "allies";
	team[1] = "axis";
	for(i = 0;i < 2;i++)
	{
		game["music"]["spawn_" + team[i]]   = "null";
		game["music"]["victory_" + team[i]] = "null";
		game["strings"][team[i] + "_name"] = "";
		game["colors"][team[i]] = (0.4,0.44,0.49);
		game["icons"][team[i]] = "";
	}
	game["music"]["defeat"]            ="null";
	game["music"]["victory_spectator"] ="null";
	game["music"]["winning"]           ="null";
	game["music"]["losing"]            ="null";
	game["music"]["victory_tie"]       ="null";

	game["dialog"]["gametype"]        = undefined;
	game["dialog"]["mission_success"] = "null";
	game["dialog"]["mission_failure"] = "null";
	game["dialog"]["mission_draw"]    = "null";
	game["dialog"]["round_success"]   = "null";
	game["dialog"]["round_failure"]   = "null";
	game["dialog"]["round_draw"]      = "null";
	game["dialog"]["timesup"]         = "null";
	game["dialog"]["winning"]         = "null";
	game["dialog"]["losing"]          = "null";
	game["dialog"]["lead_lost"]       = "null";
	game["dialog"]["lead_tied"]       = "null";
	game["dialog"]["lead_taken"]      = "null";
	game["dialog"]["last_alive"]      = "null";
	game["dialog"]["boost"]           = "null";
	game["dialog"]["offense_obj"]     = "null";
	game["dialog"]["defense_obj"]     = "null";
	game["dialog"]["hardcore"]        = "null";
	game["dialog"]["oldschool"]       = "null";
	game["dialog"]["highspeed"]       = "null";
	game["dialog"]["tactical"]        = "null";
	game["dialog"]["challenge"]       = "null";
	game["dialog"]["promotion"]       = "null";
	game["dialog"]["attack"]          = "null";
	game["dialog"]["defend"]          = "null";
	game["dialog"]["offense"]         = "null";
	game["dialog"]["defense"]         = "null";
	game["dialog"]["halftime"]        = "null";
	game["dialog"]["overtime"]        = "null";
	game["dialog"]["side_switch"]     = "null";
}