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

#include sr\libs\portal\_portal;
#include sr\libs\portal\_general;
//#include portal\_hud;



/* Scripts for throwing Grenades through Portals */

//called from maps\mp\gametypes\_weapons::beginGrenadeTracking()
trackgrenade( grenade, weaponName, cookTime )	//NOTE: make this available for all physics objects, add rotations?
{
	//self endon ( "death" );
	//self endon ( "disconnect" );

	min_length = 50;

	_info["is_c4"] = false;
	_info["radius"] = 5;

	_info["weapon"] = weaponName;
	//_info["fx"] = level._effects[weaponName+"_explosion"];

	switch( weaponName ){
	case "c4_mp":
	_info["fuse_time"] = 20;
	_info["model"] = "weapon_c4";
	_info["is_c4"] = true;
	_info["radius"] = 10;
	break;

	case "concussion_grenade_mp":
	_info["fuse_time"] = 0.95;
	_info["model"] = "weapon_concussion_grenade";
	//_info["sound"] = "grenade_explode_default";
	//_info["shellshock"] = concussion_explode;
	break;

	case "flash_grenade_mp":
	_info["fuse_time"] = 1.4;
	_info["model"] = "weapon_m84_flashbang_grenade";
	//_info["sound"] = "flashbang_explode_default";
	//_info["shellshock"] = flash_explode;
	break;

	case "smoke_grenade_mp":
	_info["fuse_time"] = 1;
	_info["model"] = "projectile_us_smoke_grenade";
	//_info["sound"] = "smokegrenade_explode_default";
	//_info["shellshock"] = empty;
	break;

	default:
	_info["fuse_time"] = 4;
	_info["model"] = "projectile_m67fraggrenade";
	//_info["sound"] = "grenade_explode_default";
	//_info["shellshock"] = grenade_explode;
	break;
	}

	grenade setcontents(0);

	//_info["fuse_time"] = getdvarfloat("g_test");

	if( weaponName != "frag_grenade_mp" )	//only frags can cook
		cookTime = 0;

	restTime = _info["fuse_time"]-cookTime;

	//iprintln("restTime: " + restTime + " , " + restTime*20);



	if( weaponName == "frag_grenade_mp" )
		grenade thread Grenade_watchExplosionForTurrets( restTime );
	else if( weaponName == "c4_mp" )
		grenade thread C4_watchExplosionForTurrets( self );



	if( WeaponName != "c4_mp" )		//is this needed?
		grenade notify( "detonate" );




	old_pos = self eyepos();


	vel = anglestoforward( self getplayerangles() )*min_length;

	firstloop = true;

	original_grenade = grenade;

	for(i=int(restTime*20); i>0 && isdefined(original_grenade) && isdefined(grenade);i--)	//restTime is pretty much useless, used for c4 max limit
	{
		if( level.portals.size >= 2 )
		{
			if( firstloop )
				firstloop = false;
			else
				vel = grenade.origin - old_pos - (0,0,2);

			for(n=0;n<level.portals.size;n++)
			{
				if( !level.portals[n].active )
					continue;

				p1 = level.portals[n].trace;

				if( vectordot(vel,p1["normal"]) >= 0 || vectordot(grenade.origin-level.portals[n].trace["position"],p1["normal"]) <= 0 )
					continue;	//grenade isn't coming at portal

				vec = grenade.origin - p1["position"] - p1["normal"]*_info["radius"];	//add the grenade collision size
				x = vectordot(vec,p1["right"]);
				y = vectordot(vec,p1["up"]);
				z = vectordot((vec + vel),p1["normal"]);	//forward value must be from the next frame
				inportal = isinportal(x,y,-12,-12) && z<=0;

				if( inportal )
				{
					grenade notify("physics_stop");
					grenade.origin = grenade.origin + vel;	//make it disappear in portal without the hit sound
					old_grenade = grenade;

					//iprintln("hit portal");

					p2 = level.portals[n].otherportal.trace;

					pos = p2["fx_position"] + x*p2["right"]*-1 + y*p2["up"];
					vel_out = vectordot( vel, p1["right"]*-1 ) * p2["right"] + vectordot( vel, p1["up"] ) * p2["up"] + vectordot( vel, p1["normal"]*-1 ) * p2["normal"];

					grenade = spawn_grenade( pos, vel_out, _info["model"], _info["is_c4"] );

					grenade.originalGrenade = original_grenade;

					original_grenade hide();
					original_grenade _linkto( grenade );

					wait 0.05;

					old_grenade notify("delete");
					if( isdefined( old_grenade ) && old_grenade != original_grenade )
						old_grenade delete();

					i--;
					break;
				}
			}
		}
		if( grenade != original_grenade && !_info["is_c4"] )
			grenade rotateto( original_grenade.angles, 0.05 );
		old_pos = grenade.origin;
		wait 0.05;
	}

	grenade notify( "remove" );

}


spawn_grenade( pos, vel, model, is_c4 )
{
	//iprintln("spawning grenade");
	grenade = spawn( "script_model", pos );
	grenade setmodel( model );

	grenade thread sr\libs\portal\_physics::start_grenade_physics( vel*20, is_c4 );

	grenade thread watchdetonation();

	return grenade;
}

watchdetonation()
{
	self endon("delete");
	self endon("physics_stop");
	self waittill( "remove" );
	if( isdefined( self.originalGrenade ) )	//could have been picked up
		self.originalGrenade show();
	self delete();
	self notify("delete");	//does this work?
	//thread drawtext( self.origin, "BOOoom!" );
}


Grenade_watchExplosionForTurrets( restTime )
{
	self endon( "delete" );
	self endon( "disconnect" );
	self endon( "death" );

	wait restTime;

	explosion_radiusdamage_turrets( self.origin , 200, 700, 100 );	//actual damage is 300

}

C4_watchExplosionForTurrets( player )
{
	player endon( "disconnect" );
	player endon( "death" );

	player waittill( "detonate" );

	explosion_radiusdamage_turrets( self.origin , 200, 600, 100 );	//actual damage is 200


}


/*
watchGrenadePickup()	//currently unused
{
	self endon("delete");

	player = undefined;

	while (true)
	{
		self.trigger waittill( "trigger", player );
		//player maps\mp\gametypes\_hud_message::hintMessage( "throw grenade" );
		iprintln( "throwback" );
		if( player fragbuttonpressed() )
			break;
	}

	if( !player hasweapon( "frag_grenade_mp" ) )
		player giveweapon( "frag_grenade_mp" );

	player SetWeaponAmmoClip( "frag_grenade_mp", player GetWeaponAmmoClip("frag_grenade_mp")+1 );

	player _exec( "-frag;+frag;-frag" );

}*/



/* Added Scripts for Shooting through Portals */

//called from maps\mp\gametypes\_weapons::onPlayerSpawned()
watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		self waittill ( "weapon_fired" );
		if( !getdvarint("portal_block_bullet") )
			self thread watchCurrentFiringForPortals();
	}
}

watchCurrentFiringForPortals()	//and turrets!
{

	weapon = self getcurrentweapon();

	max_dmg_range = weapon_max_dmg_range( weapon );
	if( !max_dmg_range )
		return;

	max_checkrange = 2.5*max_dmg_range;

	if( weapon == "deserteagle_mp" || weapon == "deserteaglegold_mp" )
		max_checkrange = 3000;

	if( max_dmg_range > 4000)
		max_checkrange = 4000;	//this will only be the range where entities will be checked on

	angle_vec = anglestoforward( self getplayerangles() );




	for(n=0;n<level.portal_turrets.size;n++)	//check if player is aiming at a turret
	{
		if( !level.portal_turrets[n].health )
			continue;

		p = level.portal_turrets[n].center;

		eyepos = self eyepos();
		vec = eyepos - p;

		if( sign( vectordot( vec, angle_vec ) ) == -1 )	//if player is facing turret
		{
			length = vectordot( p - eyepos, angle_vec );

			range_left = max_checkrange - length;

			if( range_left < 0 )	//weapon bullet can't reach turret
				continue;

			vecx2 = distancesquared( p, (eyepos + length * angle_vec) );	//vector-length-squared from turret center to players line of sight

			if( vecx2 < 20*20 )	//player is roughly aiming at turret
			{
				trace = bullettrace( eyepos, eyepos + angle_vec*(length+10), true, self );
				if( isdefined(trace["entity"]) && ( trace["entity"] == level.portal_turrets[n] || trace["entity"] == level.portal_turrets[n].wings[0] || trace["entity"] == level.portal_turrets[n].wings[1] ) )
				{
					self maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
					damage = calculate_weapon_damage( weapon, length, max_dmg_range );
					trace["entity"] notify("damage", damage, self );	// this will only be a turret	//, (0,0,0), (0,0,0), weapon_meansofdeath( weapon ), "", "" );
					return;
				}
			}
		}
	}




	for(n=0;n<level.portals.size;n++)	//check if player is aiming at a portal
	{
		if( !level.portals[n].active )
			continue;

		p1 = level.portals[n].trace;

		eyepos = self eyepos();
		vec = eyepos - p1["position"];

		w_normal = p1["normal"];
		r = p1["right"];
		u = p1["up"];

		if( sign( vectordot( vec, w_normal ) ) == 1 && sign( vectordot( vec, angle_vec ) ) == -1 )	//if player is facing portal
		{
			length = vectordot(vec,w_normal) / vectordot(w_normal*-1,angle_vec);

			range_left = max_checkrange - length;

			if( range_left < 0 )	//weapon bullet doesnt reach portal
				continue;

			wallpos = eyepos + angle_vec*( length );	//basically the position a trace from player to portals wall with players angles would give
			portaltowallpos = wallpos - p1["position"];
			x = vectordot( portaltowallpos, r );
			y = vectordot( portaltowallpos, u );

			if( isinportal(x,y,-12,-12) )	//player is aiming in portal
			{
				if( physicstrace( eyepos, wallpos + w_normal*2 ) != ( wallpos + w_normal*2 ) )	//there is a wall between the player and the portal
					continue;

				p2 = level.portals[n].otherportal.trace;

				pos = p2["fx_position"] + x*p2["right"]*-1 + y*p2["up"];
				forward = vectordot( angle_vec, r*-1 ) * p2["right"] + vectordot( angle_vec, u ) * p2["up"] + vectordot( angle_vec, w_normal*-1 ) * p2["normal"];

				self thread shoot_out_portal( pos, forward, length, range_left, max_dmg_range, weapon );
				return;
			}

		}
	}

}

shoot_out_portal( pos, vec, range_travelled, range_left, max_dmg_range, weapon )
{
	//vec should already be normalized
	//vec = vectornormalize( vec );

	//playfx( level._effect["bullettest"], pos, vec );

	trace = bullettrace( pos, pos + vec*range_left, true, undefined );

	if( trace["fraction"] == 1 )	//bullet didnt hit anything coming out of other portal
		return;

	if( isdefined( trace["entity"] ) )
	{
		damage = calculate_weapon_damage( weapon, range_travelled + range_left*trace["fraction"], max_dmg_range );

		meansofdeath = weapon_meansofdeath(weapon);

		trace["entity"] damage_ent( self, damage, meansofdeath, weapon, trace["position"], vec );
	}

	wait 0.05;

	play_impact_fx( trace["surfacetype"], trace["position"], trace["normal"] );

}

calculate_weapon_damage( weapon, range_travelled, max_dmg_range )
{

	min_dmg_range = max_dmg_range*1.25;

	if( weapon == "deserteagle_mp" || weapon == "deserteaglegold_mp" )
		min_dmg_range = max_dmg_range*3;

	return int( get_weapon_damage( weapon )*calculate_damage_fraction( range_travelled, max_dmg_range, min_dmg_range, 0.4 ) );
}

calculate_damage_fraction( range_travelled, max_dmg_range, min_dmg_range, min_dmg_fraction )
{
	x = ( min_dmg_range - range_travelled )/( min_dmg_range - max_dmg_range );	//hit fraction from end point to end of max-damage point
	if( x > 1 )
		x = 1;
	if( x < 0 )
		x = 0;
	return ((min_dmg_fraction) + (1-min_dmg_fraction)*x); //make damage fall linearly to min_dmg_fraction after maximum-damage-distance has been reached and after minimum-damage-distance use the given fraction
}


play_impact_fx( surfacetype, pos, vec )
{
}

//only checking weapons that can shoot through portals
base_weapon( weap )
{
	allweaps = strtok( "ak47,ak74u,barrett,beretta,colt45,defaultweapon,deserteagle,deserteaglegold,dragunov,g36c,g3,m1014,m14,m16,m21,m40a3,m4,m60e4,mp44,mp5,p90,remington700,rpd,rpg,saw,skorpion,usp,uzi,winchester1200", "," );
	for(i=0;i<allweaps.size;i++)
		if( issubstr( weap, allweaps[i] ) )
			return allweaps[i] + "_mp";
	return "";
}

weapon_max_dmg_range(weap)
{
	weap = base_weapon( weap );
	switch( weap )
	{
		case "barrett_mp":
		case "dragunov_mp":
		case "m21_mp":
		case "m40a3_mp":
		case "remington700_mp":
			return 4000;
		case "defaultweapon_mp":
			return 1200;
		case "ak47_mp":
		case "g36c_mp":
		case "g3_mp":
		case "m16_mp":
		case "m4_mp":
		case "mp44_mp":
		case "rpd_mp":
		case "saw_mp":
			return 1500;
		case "m60e4_mp":
			return 1000;
		case "ak74u_mp":
		case "mp5_mp":
		case "p90_mp":
		case "usp_mp":
		case "uzi_mp":
			return 750;
		case "deserteagle_mp":
		case "deserteaglegold_mp":
		case "colt45_mp":
			return 350;
		case "m1014_mp":
			return 300;
		case "beretta_mp":
		case "winchester1200_mp":
			return 250;
		case "skorpion_mp":
			return 200;
		default:
			return 0;
	}
}

get_weapon_damage(weap)
{
	switch( weap )
	{
		case "defaultweapon_mp":
		case "winchester1200_mp":	//actual is 40, but 8 chunks
			return 100;
		case "barrett_mp":
		case "dragunov_mp":
		case "m21_mp":
		case "m40a3_mp":
		case "remington700_mp":
			return 70;
		case "m60e4_mp":
		case "deserteagle_mp":
		case "deserteaglegold_mp":
		case "skorpion_mp":
			return 50;
		case "ak47_mp":
		case "g3_mp":
		case "m16_mp":
		case "mp44_mp":
		case "rpd_mp":
		case "ak74u_mp":
		case "mp5_mp":
		case "usp_mp":
		case "colt45_mp":
		case "beretta_mp":
			return 40;
		case "g36c_mp":
		case "m4_mp":
		case "saw_mp":
		case "p90_mp":
		case "uzi_mp":
		case "m1014_mp":
			return 30;
		default:
			return 30;
	}
}

weapon_meansofdeath( weap )
{
	switch( weap )
	{
		case "deserteagle_mp":
		case "deserteaglegold_mp":
		case "usp_mp":
		case "colt45_mp":
		case "beretta_mp":
			return "MOD_PISTOL_BULLET";
		default:
			return "MOD_RIFLE_BULLET";
	}
}


explosion_radiusdamage_turrets( pos, radius, max_dmg, min_dmg )
{
	for( i = 0; i < level.portal_turrets.size; i++ )
	{
		if( !level.portal_turrets[i].alive )
			continue;

		if( distancesquared( pos, level.portal_turrets[i].center ) > radius*radius )
			continue;

		s = level.portal_turrets[i] sightconetrace( pos, level.players[0] );	//why the fuck is a second parameter required

		//if( !isdefined( trace["entity"] ) || trace["entity"] != level.portal_turrets[i] || trace["entity"] != level.portal_turrets[i].wings[0] || trace["entity"] != level.portal_turrets[i].wings[1] )
		//	continue;

		damage = max_dmg * s * calculate_damage_fraction( distance( pos, level.portal_turrets[i].center ), radius*0.25, radius, min_dmg/max_dmg );

		level.portal_turrets[i] notify( "damage", int(damage), self, "MOD_EXPLOSIVE" );
	}
}

explosion_radiusdamage( pos, radius, max_dmg, min_dmg, ignore_ents )
{

	if( !isdefined( ignore_ents ) )
		ignore_ents = [];

	ents = getentarray("destructable", "targetname");

	for( i = 0; i < ents.size; i++ )
	{
		//if( ents[i] isinarray( ignore_ents ) )
		//	continue;

		if( distancesquared( pos, ents[i].origin ) > radius*radius )
			continue;

		trace = trace_array( pos, ents[i].origin + (0,0,20), false, ignore_ents );

		if( !isdefined( trace["entity"] ) || trace["entity"] != ents[i] )
			continue;

		damage = max_dmg * calculate_damage_fraction( distance(pos,trace["position"]), radius*0.25, radius, min_dmg/max_dmg );

		ents[i] damage_ent( self, damage, "MOD_EXPLOSIVE", "", trace["position"], trace["position"] - pos );
	}

	for( i = 0; i < level.players.size; i++ )
	{
		//if( level.players[i] isinarray( ignore_ents ) )
		//	continue;

		if( distancesquared( pos, level.players[i].origin ) > radius*radius )
			continue;

		player_center = level.players[i].origin + level.players[i] getcenter();

		trace = trace_array( pos, player_center, false, ignore_ents );

		if( distancesquared( pos, trace["position"] ) < ( distancesquared( pos, player_center ) - 8*8 ) )
			continue;

		damage = max_dmg * calculate_damage_fraction( distance( pos, player_center ), radius*0.25, radius, min_dmg/max_dmg );

		level.players[i] damage_ent( self, damage, "MOD_EXPLOSIVE", "", trace["position"], trace["position"] - pos );
	}


}

damage_ent( eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir )
{

	if( !isdefined( self ) )
		return;

	if( iDamage <= 0 )
		iDamage = 1;

	iDamage = int( iDamage );

	//note: add friendly fire check n shit?

	if( isplayer( eAttacker ) && ( (isdefined(self.candamage) && self.candamage) || isplayer( self ) ) )	//player or turret
		eAttacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);

	if( isplayer( self ) )
	{
		shitloc = "body";

		//iprintln( distance( self eyepos(), vPoint ) );

		if( distancesquared( self eyepos(), vPoint ) < 16*16 && sMeansofDeath != "MOD_EXPLOSIVE" && sMeansofDeath != "MOD_GRENADE" )
		{
			shitloc = "head";
			iDamage = int(iDamage*1.4);
		}

		self thread finishPlayerDamageWrapper( eAttacker, eAttacker, iDamage, 0, sMeansOfDeath, sWeapon, vPoint, vDir, shitloc, 0 );

		if( self.health - iDamage <= 0 )
			return true;
	}
	else
		self notify( "damage", iDamage, eAttacker, vDir, vPoint, sMeansOfDeath, "", "" );

	return false;

}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{

	if( sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_GRENADE" )
		self shellShock( "damage_mp", 0.2 );
	else if( sMeansOfDeath != "TURRET_BULLET" )
		self shellShock( "damage_mp", 0.05 );
	else
		sMeansOfDeath = "MOD_RIFLE_BULLET";

	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	self maps\mp\gametypes\_shellshock::shellshockOnDamage( sMeansOfDeath, iDamage );
}
