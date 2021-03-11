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
	thread precache();
	level.portal_turrets = [];
	
	thread addTurretsInMap();
}

precache()
{
	preCacheModel( "turret" );
	preCacheModel( "turret_wing0" );
	preCacheModel( "turret_wing1" );
	preCacheModel( "turret_broken" );
	preCacheModel( "turret_wing0_broken" );
	preCacheModel( "turret_wing1_broken" );
	
	level._effect["turret_flash"] = loadfx("portal/turret_flash");
	level._effect["turret_light_flash"] = loadfx("portal/turret_light_flash");
	
	level._effect["turret_explode"] = loadfx("portal/turret_explosion");
	level._effect["turret_sparks_pop"] = loadfx("portal/turret_sparks_pop");
	level._effect["turret_sparks"] = loadfx("portal/turret_sparks");
	level._effect["turret_cookoff"] = loadfx("portal/turret_cookoff");
	
	level.turret_killed_player_this_frame = false;
}

spawn_turret( pos, angles )
{
	if( getentarray().size > 700 )
	{
		println( "too many turrets spawned, deleting old turrets" );
		level.portal_turrets[0] delete_turret();
	}
	
	angles = ( angles[0], angles[1], 0 );
	
	pos = bullettrace( pos, pos + (0,0,-1000), false, undefined )["position"];
	
	if( !isdefined( pos ) )
		return;
	
	turret = sr\portal\portal::spawn_portal_object( "turret", (pos[0],pos[1],pos[2]), angles, "cylinder", 10, 0.3, 0.25, true, 0.1, 20 );
	
	turret.physics["pickup_script"] = portal\turret::pickup;
	
	if( isdefined( self ) )
		turret.owner = self;
	
	turret.forward = anglestoforward( angles );
	turret.up = anglestoup( angles );
	
	turret.center = pos + turret.forward*5 + turret.up*34;
	
	turret.speed = 0.15;
	turret.swayspeed = turret.speed*8;
	turret.searchtime = 4.5;
	turret.shootspeed = 0.1;
	
	turret.damage = 3;
	turret.explosionradius = 220;
	turret.explosiondamage = 70;
	
	turret.activatespeed = 0.5;
	
	turret.maxdist = 1100;
	turret.degreex = 60;	//degrees of freedom for turret in x direction, up/down
	turret.degreey = 50;	//y, left/right
	turret.targettime = turret.speed * 4;
	turret.defaultangles = angles;
	turret.angles = angles;
	
	turret.aim = spawn( "script_origin", turret gettagorigin("tag_aim") );	//wings will rotate according to this
	turret.aim hide();
	turret.aim.angles = angles;
	turret.eyepos = turret gettagorigin("tag_eye");
	
	turret.wings = [];
	turret.physics["ignore_ents"] = [];
	for( i = 0; i < 2; i++ )
	{
		turret.wings[i] = spawn( "script_model", turret gettagorigin("tag_aim") );
		turret.wings[i] setmodel( "turret_wing" + i );
		turret.wings[i].angles = angles;
		turret.wings[i] linkto( turret.aim );
		turret.wings[i] hide();
		turret.wings[i] setcontents( 1 );
		turret.wings[i].physics["name"] = "turret_wing" + i;
		turret.physics["ignore_ents"][i] = turret.wings[i];
	}
	
	turret.physics["ignore_ents"][2] = turret;
	turret.targets = [];
	turret.isturret = true;
	
	turret.active = false;
	turret.alive = true;
	
	turret.activating = false;
	turret.isturret = true;
	turret.exploding = false;
	turret.firing = false;
	turret.shouttimeover = true;
	turret.shotat = false;
	
	turret.health = 500;
	turret.candamage = true;
	
	turret thread damagelistener( turret );
	turret.wings[0] thread damagelistener( turret );
	turret.wings[1] thread damagelistener( turret );
	
	turret playloopSound( "turret_loop" );
	turret thread sleep();
	
	level.portal_turrets[level.portal_turrets.size] = turret;
	return turret;
}

damagelistener( turret )
{
	turret endon("picked_up");
	turret endon("destroyed");
	turret endon("delete");
	
	for(;;)
	{
		self waittill( "damage", damage, player, this, nthat , meansofdeath );
		
		if( !isdefined( meansofdeath ) )
			meansofdeath = "";
		
		turret.health -= damage;
		if( turret.health < 0 )
			turret.health = 0;
		
		if( turret.health == 0 )
			turret thread explode(meansofdeath);
		else
		{
			if( meansofdeath != "MOD_EXPLOSIVE" )
			{
				if( randomint(2) )
					turret thread shout_hurt();
				
				if( !randomint(15) )
					playfx( level._effect["turret_sparks"], turret gettagorigin( "tag_wing"+randomint(2) ) );
			}
			if( turret.active )
			{
				if( isdefined( player ) )
					if( player isinarray( turret.targets ) )
						turret thread target( player );
			}
			else
			{
				turret.wakeup_means = meansofdeath;
				turret thread activate(1);
			}
		}
	}
}

shout_hurt()
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	if( self.shouttimeover && !self.activating && !self.firing )
	{
		self playsound( "turret_hurt" );
		self.shouttimeover = false;
		self thread resetshouttime( 2.2 + randomfloat( 2 ) );
	}
	
	self.shotat = true;
	self.swayspeed = self.speed*4;	//make turret sway faster
	
	self notify("shot_taken");
	self endon("shot_taken");
	
	startledtime = 1.5;
	
	wait startledtime;
	self.swayspeed = self.speed*8;	//default
	wait (self.searchtime+0.3-startledtime);
	self.shotat = false;
}

resetshouttime( time )
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	wait time;
	self.shouttimeover = true;
}

explode(meansofdeath)
{
	self endon("delete");
	
	self.exploding = 1;
	self.alive = 0;
	
	self notify("destroyed");
	self playsound( "turret_ignite" );
	playfx( level._effect["turret_explode"], self.center );
	
	wait 0.05;
	
	ignore_ents[0] = self;
	ignore_ents[1] = self.wings[0];
	ignore_ents[2] = self.wings[1];
	
	sr\portal\_weapons_portal::explosion_radiusdamage( self.center+self.up*40, self.explosionradius, self.explosiondamage, 10, ignore_ents );
	
	self setmodel( "turret_broken" );
	self.wings[0] setmodel( "turret_wing0_broken" );
	self.wings[1] setmodel( "turret_wing1_broken" );
	
	if( meansofdeath != "MOD_EXPLOSIVE" )
	{
		if( randomintrange(0,5) )
		{
			wait randomfloat(1.5);
			self playsound( "turret_sparks" );
			playfx( level._effect["turret_sparks_pop"], self gettagorigin( "tag_wing0" ) );
			playfx( level._effect["turret_sparks_pop"], self gettagorigin( "tag_wing1" ) );
		}
		else
		{
			wait 0.05;
			self playsound( "turret_cookoff" );
			playfx( level._effect["turret_cookoff"], self.center );
			wait 0.1;
			self playsound( "turret_sparks" );
		}
	}
	
	if( self.active )
	{
		wait ( 0.5 + randomfloat(1) );
		
		self playsound( "turret_hurt_explosion" );
		
		if( randomint(3) )
		{
			wait (1 + randomfloat(1.5) );
			self playsound( "turret_destroyed" );
			self deactivate( true );
		}
		
	}
	else
	{
		wait 1.5;
		self playsound( "turret_destroyed" );
	}
	
	
	self stoploopsound();
	
	self hidepart( "tag_eye" );
	
	self.active = 0;
	self.exploding = 0;
	self.destroyed = 1;
	
	turrets = [];	//turrets witnessed death
	
	for( i = 0; i < level.portal_turrets.size; i++ )
	{
		if( level.portal_turrets[i] == self )
			continue;
		if( distancesquared( self.center, level.portal_turrets[i].center ) < 600*600 )
			turrets[turrets.size] = level.portal_turrets[i];	//ignore walls for now
	}
	
	wait 1.2;
	
	thread turrets_taunt( turrets, 0 );
	
	
}

turrets_taunt( turrets, idx )
{
	if( !isdefined( turrets[idx] ) )
		return;
	
	if( turrets[idx].alive && !turrets[idx].active && !turrets[idx].activating && !randomint(3) )
	{
		turrets[idx] playsound( "turret_witnessdeath" );
		wait 1.5 + randomfloat(1);
	}
	thread turrets_taunt( turrets, idx+1 );
}

updatetargets()
{
	self.targets = [];
	
	for( i = 0; i < level.players.size; i++ )
	{
		if( !getdvarint("portal_turret_target_owner") && level.players[i] == self.owner )
			continue;
		
		d2 = distancesquared( level.players[i].origin, self.aim.origin );
		if( d2 < self.maxdist*self.maxdist && level.players[i].health > 0 )
		{
			
			if( d2 < 80*80 )
				aim_position = level.players[i] centerpos();
			else
				aim_position = level.players[i] eyepos();
			
			angles = vectortoangles( aim_position - self.aim.origin );
			
			if( abs(normalize_angle( self.defaultangles[0] - angles[0] )) < self.degreex && abs(normalize_angle(self.defaultangles[1] - angles[1])) < self.degreey )	//player in sight
			{
				//if( trace_array( self.aimpos, level.players[i] eyepos() )["entity"] == level.players[i] || level.players[i].portal["forceturretshoot"] )
				//	self.targets[self.targets.size] = level.players[i];
			//}
				if( level.players[i] SightConeTrace( self.eyepos, self ) || level.players[i].portal["forceturretshoot"] )
					self.targets[self.targets.size] = level.players[i];
			}
		}
	}
}


sleep()
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self endon("activated");
	
	self hidepart( "tag_eye" );
	
	while( !self.targets.size )
	{
		self updatetargets();
		wait self.targettime;	//depending on turrets reaction from sleep (I just took the targettime)
	}
	
	self thread activate(0);
}


activate( woken_up )	//woken up by bullet
{
	
	if( self.active || self.activating )
		return;
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self notify("activated");
	
	self.activating = true;
	
	self hidepart( "tag_aim" );	//hide original wings and spawn scripted ones so they can be animated
	
	self showpart( "tag_eye" );	//show turrets eye
	
	for( i = 0; i < self.wings.size; i++ )
	{
		self.wings[i] unlink();
		self.wings[i] setmodel( "turret_wing" + i );
		self.wings[i] show();
		self.wings[i] moveto( self gettagorigin( "tag_wing" + i), self.activatespeed);
	}
	
	
	self playsound( "turret_active_sound" );
	if( randomintrange(0,4) && !woken_up )
		self playsound( "turret_active" );	//25% chance turret wont say anything
	
	self playsound( "turret_deploy" );
	
	wait self.activatespeed;
	
	for( i = 0; i < self.wings.size; i++ )
		self.wings[i] linkto( self.aim );
	
	
	self.activating = false;
	self.active = 1;
	
	self playsound( "turret_ping" );
	
	wait 0.1;
	
	wait 0.1;
	
	wait 0.1;
	
	
	self thread deploying( woken_up );
}

deploying( woken_up )
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self.killedtarget = false;
	self.losttarget = true;
	
	self updatetargets();
	
	self.last_target = self;	//just so we got something defined
	
	for( ; ;  )
	{
		if( !level.turret_killed_player_this_frame )	//note: make this better
			self.losttarget = true;
		
		self updatetargets();
		
		if( !self.targets.size )
			break;
		
		//if( i == 0 )
		//	self.losttarget = false;	//target exists
		
		target = self.targets[randomint(self.targets.size)];
		
		self target( target );
		//if( self.losttarget )	//otherwise this will turn into an infinite loop, if the player is on the edge of turrets sight-cone
		//	wait self.shootspeed;
	}
	
	self.firing = 0;
	
	//iprintln( "killed target: " + self.killedtarget + " lost target: " + self.losttarget + "woken up: " + woken_up );
	
	if( (self.killedtarget || level.turret_killed_player_this_frame) || (!self.losttarget && !woken_up) )	//target was killed, either by this turret, or other turrets (or disconnected, or magically disappeared)
	{
		wait 0.2;
		self setangles( self.defaultangles, 0.2 );
		wait 0.1;
		if( self.killedtarget )
			self playsound( "turret_retire" );
		wait 0.1;
		self thread deactivate();	//no targets left
	}
	else
	{
		if( woken_up && !self.losttarget )	//turret was woken up without targets
		{
			self playsound( "turret_woken_up" );
			self thread searchmode( 0 );
		}
		else
			self thread searchmode( 1 );	//target lost
	}
}



target( player )	//make the turret follow the target
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self notify( "stop_target" );
	self endon( "stop_target" );
	player endon( "death" );
	player endon( "disconnect" );
	
	if( player != self.last_target )	//need some time to reconfigue
		wait self.speed;
	
	self.last_target = player;
	self.killedtarget = false;
	self.losttarget = false;
	
	self thread loopshoot( player );	//shoot in facing direction
	
	count = self.targettime / self.speed;
	
	for( i = 0; i < count && isAlive( player ) && player.sessionstate == "playing" && player.health > 0; i++ )
	{
		d2 = distancesquared( player.origin, self.aim.origin );
		if( d2 < 80*80 )
			aim_position = player centerpos();
		else
			aim_position = player eyepos();
		
		if( !self setangles( vectortoangles( aim_position - self.aim.origin ) ) )	//if player is out of sight, target next
		{
			//iprintln( "player out of range" );
			self.losttarget = true;
			self notify( "stop_target" );
		}
		wait self.speed;
	}
	
	self notify( "stop_target" );
}


loopshoot( player )
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self endon( "stop_target" );
	player endon( "death" );
	player endon( "disconnect" );
	
	self.firing = 1;
	
	while( true )
	{
		eye = player eyepos();
		
		//vec = eye - self.center;
		
		dir = anglestoforward( self.aim.angles );
		
		for( n = 0; n < 2; n++ )
		{
			for( i = 0; i < 2; i++ )
			{
				pos = self.wings[n] gettagorigin( "tag_flash" + i );
				playfx( level._effect["turret_flash"], pos, dir + (random_vec(2)/1000) );
				//playfx( level._effect["bullettest"], pos, eye - pos );
			}
		}
		
		self playSound("turret_fire");
		playfx( level._effect["turret_light_flash"], self.eyepos );
		
		trace = trace_array( self.eyepos, self.eyepos + dir*self.maxdist, true, self.physics["ignore_ents"] );//self.physics["ignore_ents"] );
		
		killed_ent = false;
		
		if( trace["fraction"] != 1 )
		{
			
			if( isplayer( trace["entity"] ) )	//dont play impact fx
				playSoundOnPosition( "bullet_small_" + trace["surfacetype"], trace["position"] );
			else
				sr\portal\_weapons_portal::play_impact_fx( trace["surfacetype"], trace["position"], trace["normal"] );
			
			if( isdefined( trace["entity"] ) )
			{
				range_travelled = self.maxdist*trace["fraction"];
				max_dmg_range = (self.maxdist/2);
				
				damagefraction = sr\portal\_weapons_portal::calculate_damage_fraction( range_travelled, max_dmg_range, max_dmg_range*1.25, 0.5 );
				
				damage = self.damage * damagefraction;
				
				if( !isplayer( trace["entity"] ) )	//a player is way too fragile
					damage *= 15;
				
				killed_ent = trace["entity"] sr\portal\_weapons_portal::damage_ent( self, int(damage), "TURRET_BULLET", "", trace["position"], dir );
			}
		}
		
		if( !isdefined( trace["entity"] ) || isdefined( trace["entity"] ) && trace["entity"] != player )
		{
			if( distancesquared( self.aim.origin, trace["position"] ) > distancesquared( self.aim.origin, eye ) )
			{
				player_distance = vectordot( eye - self.aim.origin, dir );
				sight_pos = self.aim.origin + player_distance * dir;
				if( distancesquared( eye, sight_pos ) < 32*32 )	//turret shot right past player and hit an entity behind player (or none), still damage player, but with less damage
				{
					damage = self.damage * 0.25 * sr\portal\_weapons_portal::calculate_damage_fraction( player_distance, self.maxdist*0.5, self.maxdist*0.625, 0.5 );
					self.killedtarget = player sr\portal\_weapons_portal::damage_ent( self, int(damage), "TURRET_BULLET", "", sight_pos, dir );
				}
			}
		}
		else
			self.killedtarget = killed_ent;
		
		if( self.killedtarget )
		{
			level.turret_killed_player_this_frame = true;	//other option: run a check on all turrets if they share the same target and if player was killed that frame
			thread resetplayerkilledvar();
		}
		
		wait self.shootspeed;
	}
}

resetplayerkilledvar()
{
	wait 0.1;
	level.turret_killed_player_this_frame = false;
}

searchmode( play_sound )
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self thread sway();
	
	checkspeed = 0.1;
	
	for( i = 0; ( (i < self.searchtime/checkspeed) || self.shotat ) && !self.targets.size; i++ )
	{
		wait checkspeed;
		self updatetargets();
		if( i == 18 && !self.targets.size && play_sound && !(isdefined(self.wakeup_means) && self.wakeup_means == "MOD_EXPLOSIVE" ) )
			self playsound( "turret_search" );
	}
	
	self notify( "end_search" );
	
	if( self.targets.size )
		self thread deploying(0);	//target was found
	else
		self thread deactivate();	//no targets found
}

sway()
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self endon( "end_search" );
	
	wait self.speed;
	
	x_0 = int(self.degreex*0.3);
	x_1 = int(self.degreex*-0.35);
	
	y = int(self.degreey*0.7);
	
	while( true )
	{
		self setangles( self.defaultangles + ( randomintrange(x_1, x_0), y, 0 ), self.swayspeed );
		wait self.swayspeed;
		y *= -1;
	}
}

deactivate( destroyed )
{
	
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	
	self notify( "stop_target" );
	
	self playsound( "turret_retract" );
	
	self setangles( self.defaultangles );
	wait self.speed + 0.05;
	
	for( i = 0; i < self.wings.size; i++ )
	{
		self.wings[i] unlink();
		self.wings[i] moveto(self gettagorigin("tag_aim"), self.activatespeed);
	}
	
	wait self.activatespeed;
	
	self showpart( "tag_aim" );
	for( i = 0; i < self.wings.size; i++ )
	{
		self.wings[i] hide();
		self.wings[i] linkto( self.aim );
	}
	
	wait 0.05;
	
	self.active = 0;
	
	if( isdefined( destroyed ) && destroyed )
	{
		
		self notify ("destroyed");
	}
	else
	{
		self thread sleep();
	}
}




setangles( angles, time )
{
	if( !isdefined( time ) )
		time = self.speed;
	
	angles = ( normalize_angle( angles[0] ), normalize_angle( angles[1] ), 0 );
	
	new_degree_x = normalize_angle( self.defaultangles[0] - angles[0] )*-1;
	new_degree_y = normalize_angle( self.defaultangles[1] - angles[1] )*-1;
	
	x_ok = abs(new_degree_x) <= self.degreex;
	y_ok = abs(new_degree_y) <= self.degreey;
	
	if( !x_ok )
		new_degree_x = sign(new_degree_x)*self.degreex;
	if( !y_ok )
		new_degree_y = sign(new_degree_y)*self.degreey;
	
	self.aim rotateto( self.defaultangles + (new_degree_x,new_degree_y,0), time );
	
	return (x_ok && y_ok);
}


delete_turret()
{
	self notify( "delete" );
	
	newarray = [];
	for( i = 0; i < level.portal_turrets.size; i ++ )
	{
		if( level.portal_turrets[i] == self )
			continue;
		newarray[newarray.size] = level.portal_turrets[i];
	}
	level.portal_turrets = newarray;
	
	self.aim delete();
	self.wings[0] delete();
	self.wings[1] delete();
	self delete();
}



/*   unstable   */


pickup( player )
{
	self notify("picked_up");
	
	self unlink();
	
	//NOTE: Add if is alive
	
	self showpart( "tag_eye" );
	
	self setcontents(0);
	
	self hidepart( "tag_aim" );
	for( i = 0; i < self.wings.size; i++ )
	{
		self.wings[i] unlink();
		self.wings[i] setmodel("turret_wing"+i);
		self.wings[i] show();
		self.wings[i] setcontents(0);
		self.wings[i].origin = self gettagorigin( "tag_wing" + i);
	}
	
	self playsound( "turret_pickup_" + randomintrange(1,11) );
	
	self.active = 0;
	
	self thread follow_player();
	
}

follow_player( player )
{
	self notify( "physics_stop" );
	self endon( "unlink" );
	
	
	old_eye = (0,0,0);
	old_ang = (0,0,0);
	
	player = self.physics["owner"];
	
	angle_offset = self.angles[1]-player getPlayerAngles()[1];
	
	self.physics["sway"] = false;
	self.physics["sway_offset"] = (0,0,0);
	
	random_pos = (0,0,0);
	skip_arm_sway = 0;
	//self thread sway_pickup();
	
	pos = self.origin;
	
	while( true )
	{
		eye = player eyepos();
		angles = player getPlayerAngles();
		
		if( eye!=old_eye || angles!=old_ang )
		{
			self.physics["sway"] = false;
			//pos = self player_portalobjectCollisionTrace( eye, angles, level.pickup_object_distance );
			
			//pos = self sr\portal\physics::player_portalobjectCollisionTrace( eye, angles, level.pickup_object_distance );
			
			forward = anglestoforward( angles );
			
			pos = playerphysicstrace( self.origin - (0,0,20), eye - (0,0,20) + forward*(15 + level.pickup_object_distance + 17 ));
			
			//pos = (eye+forward*(15 + level.pickup_object_distance + 17 ));
			
			pos+= self.physics["sway_offset"];
			
			
			forward = anglestoforward( (angles[0],angles[1]+angle_offset,angles[2]) );
			
			
			r = vectorprod( forward, (0,0,1) );
			f = vectorprod( (0,0,1), r );
			
			self moveto( pos , 0.1 );
			self rotateto( (0,angles[1]+angle_offset,0), 0.1 );
			
			self.wings[0] moveto( pos + r*-6 + f*4 + (0,0,3.4), 0.1 );
			self.wings[1] moveto( pos + r*6 + f*4 + (0,0,3.4), 0.1 );
			
			
			
		}
		else
			self.physics["sway"] = true;
		
		
		if( skip_arm_sway )
		{
			if(randomintrange(0,4))
				random_pos = (randomintrange(int(self.degreex*-0.5),int(self.degreex*0.5)),randomintrange(int(self.degreey*-0.5),int(self.degreey*0.5)),0);
			skip_arm_sway++;
		}
		else
			skip_arm_sway--;
		
		self.wings[0] rotateto( random_pos+(0,angle_offset+angles[1],0), 0.2, 0.05, 0.05 );
		self.wings[1] rotateto( random_pos+(0,angle_offset+angles[1],0), 0.2, 0.05, 0.05 );
		
		wait 0.1;
	}
}

sway_pickup()
{
	self endon( "unlink" );
	
	old_sway = (0,0,0);
	
	for(i=0;;i+=10)
	{
		self.physics["sway_offset"] = (cheap_sin(i)*self.physics["sway_amount"],cheap_sin(i+90)*self.physics["sway_amount"],cheap_sin(i*2)*self.physics["sway_amount"]*2);
		old_sway = self.physics["sway_offset"];
		
		if( self.physics["sway"] )
			self moveto( self.origin + self.physics["sway_offset"] - old_sway, self.physics["sway_speed"] + 0.1 );
		
		wait self.physics["sway_speed"];
		if(i>=360)
			i-=360;
	}
}






addTurretsInMap()
{
	
	
}



