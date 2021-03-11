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
#include sr\portal\hud;

// ################################# &&

saveWeapons()
{
	
}

restoreWeapons()
{
	
}
/*
//this function already exists in stock cod4: getweaponslist()
getweaplist()
{
	weaplist = [];
	allweaps = strtok( "ak47_acog_mp,ak47_gl_mp,ak47_mp,ak47_reflex_mp,ak47_silencer_mp,ak74u_acog_mp,ak74u_reflex_mp,ak74u_silencer_mp,ak74u_mp,aw50_acog_mp,aw50_mp,barrett_acog_mp,barrett_mp,beretta_mp,beretta_silencer_mp,brick_blaster_mp,brick_bomb_mp,c4_mp,claymore_mp,colt45_mp,colt45_silencer_mp,concussion_grenade_mp,defaultweapon_mp,deserteagle_mp,deserteaglegold_mp,dragunov_mp,dragunov_acog_mp,flash_grenade_mp,frag_grenade_mp,g36c_acog_mp,g36c_reflex_mp,g36c_silencer_mp,g36c_gl_mp,g36c_mp,g3_acog_mp,g3_reflex_mp,g3_silencer_mp,g3_gl_mp,g3_mp,gl_ak47_mp,gl_g36c_mp,gl_g3_mp,gl_m14_mp,gl_m4_mp,gl_mp,m1014_reflex_mp,m1014_grip_mp,m1014_mp,m14_acog_mp,m14_reflex_mp,m14_silencer_mp,m14_gl_mp,m14_mp,m16_acog_mp,m16_reflex_mp,m16_silencer_mp,m16_gl_mp,m16_mp,m21_acog_mp,m21_mp,m40a3_acog_mp,m40a3_mp,m4_acog_mp,m4_reflex_mp,m4_silencer_mp,m4_gl_mp,m4_mp,m60e4_acog_mp,m60e4_reflex_mp,m60e4_grip_mp,m60e4_mp,mp44_mp,mp5_acog_mp,mp5_reflex_mp,mp5_silencer_mp,mp5_mp,p90_acog_mp,p90_reflex_mp,p90_silencer_mp,p90_mp,remington700_acog_mp,remington700_mp,rpd_mp,rpg_mp,saw_acog_mp,saw_reflex_mp,saw_silencer_mp,saw_mp,skorpion_acog_mp,skorpion_reflex_mp,skorpion_silencer_mp,skorpion_mp,usp_mp,usp_silencer_mp,uzi_acog_mp,uzi_reflex_mp,uzi_silencer_mp,uzi_mp,winchester1200_reflex_mp,winchester1200_grip_mp,winchester1200_mp", "," );
	for( i = 0; i < allweaps.size; i++ )
	if( self hasWeapon( allweaps[i] ) )
		weaplist[weaplist.size] = allweaps[i];
	return weaplist;
}*/

isinportal( x, y, rx_add, ry_add )	//ellipse function
{
	if( !isdefined(rx_add) )
		rx_add = 0;
	if( !isdefined(ry_add) )
		ry_add = 0;
	rx = (level.portalwidth/2) + rx_add;
	ry = (level.portalheight/2) + ry_add;
	return ( (x*x)/(rx*rx) + y*y/(ry*ry) ) <= 1;
}

isportalgun( weapon )
{
	return issubstr( weapon, level.portalgun );
}

dropPortalgunForDeath( disconnected )
{
	
	weapon = level.portalgun;
	
	if( getdvarint("portal_mode") != 0 )
		return;
	
	//iprintln("hasweap"+self hasweapon( weapon )+"triggerhurt"+ (isdefined( self.lastMeansOfDeath ) && self.lastMeansofDeath == "MOD_TRIGGER_HURT")+"dc"+ isdefined(disconnected) );
	
	if( !self hasweapon( weapon ) || (isdefined( self.lastMeansOfDeath ) && self.lastMeansofDeath == "MOD_TRIGGER_HURT") || isdefined(disconnected) )	//player somehow lost the portalgun (through take all?), respawn it
	{
		thread portalgun_random_spawn();
		return;
	}
	
	
	self setweaponammostock( weapon, 1 );	//so it can be dropped
	item = self dropItem( weapon );
	
	level.hiddenportalgun = item;
	
	item thread PortalGunRespawn(20);
	
}

PortalGunRespawn(time)	//should add random checks, seeing if portalgun exists
{
	self endon("stop_wait");
	
	wait time;
	
	//iprintln( "respawning " + isDefined( self ) );
	
	if ( !isDefined( self ) )	//was picked up, bugged!!
		return;
	
	thread portalgun_random_spawn();
	
	self delete();
}



launch( sMeansOfDeath, sWeapon, vPoint, vDir, strength )
{
	
	self endon("death");
	self endon("disconnect");
	
	maxhealth 	= 	self.maxhealth;
	health 		= 	self.health;
	
	self.maxhealth 	+= 1000000;
	self.health 	+= 1000000;
	
	//strength = strength
	
	setDvar( "g_knockback", strength );	//*8.4
	
	self FinishPlayerDamage( self, self, 100, 0, sMeansOfDeath, sWeapon, vPoint, vDir, "none", 0 );
	
	wait 0.05;
	
	setDvar( "g_knockback", level.defaultknockback );
	
	self.maxhealth 	= maxhealth;
	self.health 	= health;
}


_linkto( ent )
{
	self thread _linkto_thread( ent );
}

_linkto_thread( ent )
{
	self notify("unlink");
	self endon("unlink");
	self endon("death");
	ent endon("death");
	for(;;)
	{
		if( !isdefined( ent ) || !isdefined( self ) )
			self notify("unlink");
		self.origin = ent.origin;
		wait 0.05;
	}
}

_exec( string )
{
	self setclientdvar( "_p0rtal_exec", string );
	self openmenunomouse( "_exec" );
	self closemenu( "_exec" );
}

spawn_portal_object(
	name,		//String of the modelname
	pos, 		//Positionvector
	angles, 	//Anglevector
	colType, 	//Type of collision used, String "cube","sphere","cylinder"
	colSize, 	//Size of the collision Box
	bounce, 	//bounce factor		(force absorption by collision with wall), floatvalue 0-1
	adhesion, 	//object adhesion	(min wall-slope the object will stick to, values are 1 - wallnormal[2]; the higher, the stickier), floatvalue 0-1
	rotate, 	//object rotates, boolean (true/false)
	rot_speed, 	//object rotation speed, floatvalue 0-1
	cyl_height	//height of the Collisioncylinder
)
{
	
	model = spawn( "script_model", pos );
	model setmodel( name );
	
	model.angles = angles;
	
	
	model.physics = [];
	
	model.physics["name"] = name;
	
	model.physics["colType"] = colType;
	model.physics["colSize"] = colSize;
	model.physics["colHeight"] = cyl_height;
	
	model.physics["bounce"] = bounce;
	model.physics["adhesion"] = adhesion;			
	model.physics["rotate"] = rotate; 				
	model.physics["rotation_speed"] = rot_speed; 	
	
	//model.physics["bounce_sound"] = ""; //add this manually
	
	model.physics["sway_amount"] = 5;
	model.physics["sway_speed"] = 0.5;
	
	model.physics["model_parts"] = [];	//all model parts which should be ignored by collision traces should go in here
	
	level.portalobjects[level.portalobjects.size] = model;
	
	// if( getdvarint( "portal_debug" ) )
	// 	model thread draw_collision();
	
	return model;
}


spawn_portal_gun( pos, angles )
{
	/*
	pos = bullettrace( pos, pos + (0,0,-500), false, undefined )["position"];
	
	if( !isdefined( pos ) )
		return;
	*/
	
	//iprintln("spawning at " + pos);
	
	portalgun = spawn( "script_model", pos );
	portalgun setmodel( level.portalgun_w );
	
	if( isdefined( angles ) )
		portalgun.angles = angles;
	
	portalgun.trigger = spawn( "trigger_radius", pos, 0, 50, 40 );
	
	/*
	setdvar( "pg_org", "0 0 0" );
	setdvar( "pg_z", "0" );
	setdvar( "pg_ang", "0 0 0" );
	
	while( true )
	{
		pos = float_vec(getdvar( "pg_org" ));
		portalgun.origin = (pos[0],pos[1],float( getdvar("pg_z") ));
		portalgun.angles = float_vec( getdvar("pg_ang") );
		wait 0.2;
	}*/
	
	//portalgun.trigger waittill( "trigger", player );
	//iprintln( "triggered" );
	//portalgun.trigger sethint( "hello" );
	
	portalgun thread waitForPickup();
	portalgun.trigger thread setTriggerUse();
	
	return portalgun;
}

waitForPickup()
{
	self.trigger waittill( "trigger_activate", player );
	self notify("delete");
	self.trigger delete();
	self delete();
	player dropitem( player getcurrentweapon() );	//what if player only has 1 weapon?
	player giveweapon( level.portalgun );
	player switchtoweapon( level.portalgun );
	
	level.hiddenportalgun = undefined;
}

setTriggerUse()
{
	self endon("setTriggerNormal");
	self endon("delete");
	
	while(true)
	{
		self waittill("trigger", player);
		if( player usebuttonpressed() )	//multiple players??
		{
			self notify("trigger_activate", player);
			wait 0.1;
		}
	}
}


check_portalgun_existence()
{
	//iprintln("hidden:"+isdefined( level.hiddenportalgun ));
	if( isdefined( level.hiddenportalgun ) )
		return true;
	for(i=0;i<level.players.size;i++)
		if( isdefined(level.players[i]) && level.players[i] hasweapon( level.portalgun ) )
			return true;
	return false;
	
}



portalgun_random_spawn()
{
	//iprintln("calling random spawn");
	
	wait 3;	//takes this long for player to lose weapon on death
	
	if( check_portalgun_existence() )
		return;
	
	positions = get_spawn_locations( getdvar( "mapname" ) );
	
	//firstchoice = positions[0];
	//secondchoice = positions[1];	//add if!defined secondchoice??
	
	//firstangles = positions[2];
	//secondangles = positions[3];
	
	if( !positions[0].size )	//spawn locations not set
		return;
	
	index = 0;
	if( !randomintrange(0,4) )	//25% for second-choice-positions to be selected
		index = 1;
	
	index2 = randomintrange(0,positions[index].size);
	
	if( !isdefined( positions[index][index2] ) )
	{
		iprintln("^1error: tried spawning portalgun, but index "+index+", "+index2+" is not defined on map "+getdvar("mapname"));
		return;
	}
	
	level.hiddenportalgun = spawn_portal_gun( positions[index][index2], positions[index+2][index2] );
}


get_spawn_locations( map )
{
	loc = [];
	loc[0] = [];
	loc[1] = [];
	loc[2] = [];
	loc[3] = [];
	
	switch( map )
	{
		case "mp_backlot":		loc[0][0]=(410,-300,399); loc[0][1]=(-1195,-315,-79); loc[0][2]=(496,-382,207); //positions
								loc[1][0]=(778,-1267,255); loc[1][1]=(1676,-87,252); loc[1][2]=(-295,133,109); loc[1][3]=(446,479,201);
								loc[2][0]=(2,-1,0); loc[2][1]=(0,-90,0); loc[2][2]=(0,-80,0);					//corresponding angles
								loc[3][0]=(0,90,0); loc[3][1]=(-20,-30,0); loc[3][2]=(0,20,20); break;
								
		case "mp_bloc":			loc[0][0]=(1027,-5822,-21); loc[0][1]=(1065,-7114,10); loc[0][2]=(1318,-4522,15); 
								loc[1][0]=(1265,-4742,187); loc[1][1]=(729,-6889,148); loc[1][2]=(-2570,-4177,-157);
								loc[2][0]=(0,-90,0); loc[2][1]=(0,130,0); loc[2][2]=(0,-80,0);
								loc[3][0]=(0,30,0); loc[3][1]=(0,90,0); loc[3][2]=(0,20,20); break;
								
		case "mp_bog":			loc[0][0]=(4450,1381,90); loc[0][1]=(4284,47,49);
								loc[1][0]=(3431,1451,29); break;
								
		case "mp_broadcast":	loc[0][0]=(-651,-288,251); loc[0][1]=(-1015,-572,-8); loc[0][2]=(57,532,30); loc[0][3]=(751,1416,139);
								loc[1][0]=(-470,500,158); loc[1][1]=(-1687,2009,122); loc[1][2]=(-1248,231,10);
								loc[2][0]=(0,-60,0); loc[2][1]=(0,-60,0); loc[2][2]=(0,90,0); loc[2][3]=(0,-80,0);
								loc[3][0]=(0,30,0); loc[3][1]=(0,-90,0); loc[3][2]=(0,10,0); break;
								
		case "mp_carentan":		loc[0][0]=(597,1276,176); loc[0][1]=(711,1801,199); loc[0][2]=(232,1872,-107);
								loc[1][0]=(1315,1636,147); loc[1][1]=(-1035,2020,13);
								loc[2][0]=(0,90,0); loc[2][2]=(0,-100,0); break;
								
		case "mp_cargoship":	loc[0][0]=(529,-168,66);
								loc[1][0]=(650,-546,230); loc[1][1]=(-143,-565,230);
								loc[3][0]=(0,-90,0); loc[3][1]=(0,90,0); break;
								
		case "mp_citystreets":	loc[0][0]=(4422,-370,-105); loc[0][1]=(5719,56,-78); loc[0][2]=(2505,-277,-93);
								loc[1][0]=(2338,-1038,-38); loc[1][1]=(2402,854,3);
								loc[2][0]=(0,30,0); loc[2][1]=(0,90,0); loc[2][2]=(0,-90,0);
								loc[3][1]=(0,90,0); break;
								
		case "mp_convoy":		loc[0][0]=(111,-271,-125); loc[0][1]=(690,-31,85);
								loc[1][0]=(-906,788,210); loc[1][1]=(-2742,-699,166); loc[1][2]=(744,632,90); loc[1][3]=(2792,1255,107);
								loc[2][1]=(0,90,0);
								loc[3][2]=(10,-10,0); break;
								
		case "mp_countdown":	loc[0][0]=(-43,143,-21); loc[0][1]=(-38,-1776,33); loc[0][2]=(603,2242,-21);
								loc[1][0]=(1173,-1492,131); loc[1][1]=(-1514,2118,-15);
								loc[2][0]=(0,90,0);
								loc[3][0]=(-5,-70,-10); break;
		case "mp_crash":
		case "mp_crash_snow":	loc[0][0]=(1548,529,624); loc[0][1]=(80,-168,220); loc[0][2]=(793,-50,155); loc[0][3]=(844,566,151); loc[0][4]=(1555,463,180); loc[0][5]=(1415,478,311);
								loc[1][0]=(-32,-1140,373); loc[1][1]=(-581,1781,419); loc[1][2]=(-33,-677,165); loc[1][3]=(238,2134,299); loc[1][4]=(729,1165,276); loc[1][5]=(1309,-1438,229);
								loc[2][1]=(0,110,0); loc[2][2]=(0,90,0); loc[2][3]=(5,20,10); loc[2][4]=(0,93,0);
								loc[3][0]=(0,90,0); loc[3][1]=(-8,10,0); loc[3][2]=(0,30,0); loc[3][3]=(0,90,0); loc[3][4]=(0,90,0); loc[3][5]=(0,90,0);break;
								
		case "mp_creek":		loc[0][0]=(-97,7836,16); loc[0][1]=(-2228,5296,-45); loc[0][2]=(-1784,5743,282);
								loc[1][0]=(-3622,8245,235); loc[1][1]=(-2865,6817,591); loc[1][2]=(300,5913,75);
								loc[2][0]=(18,-15,10); loc[2][1]=(10,0,7); loc[2][2]=(10,180,0);
								loc[3][0]=(5,-55,0); loc[3][1]=(5,-55,0);break;
								
		case "mp_crossfire":	loc[0][0]=(5292,-2488,40); loc[0][1]=(5705,-3270,-41); loc[0][2]=(4251,-2797,165);
								loc[1][0]=(4448,-1876,178); loc[1][1]=(3593,-3553,-5); loc[1][2]=(6028,-1423,185);
								loc[2][0]=(0,-33,5); loc[2][1]=(-20,-40,35);
								loc[3][0]=(-50,-100,20); loc[3][2]=(0,-125,0); break;
								
		case "mp_farm":			loc[0][0]=(666,1037,284); loc[0][1]=(314,1041,388); loc[0][2]=(1605,1002,261);
								loc[1][0]=(2045,1952,277); loc[1][1]=(643,-1096,130);
								loc[2][0]=(0,10,0);loc[2][2]=(5,-105,0); break;
								
		case "mp_killhouse":	loc[0][0]=(637,1438,263);
								loc[1][0]=(1254,1348,52);
								loc[2][0]=(0,-90,0);
								loc[3][0]=(0,90,0); break;
								
		case "mp_overgrown":	loc[0][0]=(243,-2006,-345); loc[0][1]=(-798,-2172,3); loc[0][2]=(2805,-2159,-95); loc[0][3]=(1000,-2929,-148);
								loc[1][0]=(-411,147,-173); loc[1][1]=(-712,-5365,-115);
								loc[2][0]=(-16,30,10); loc[2][1]=(0,90,0); loc[2][2]=(0,-97,0); loc[2][3]=(-27,0,20);
								loc[3][1]=(7,170,0); break;
								
		case "mp_pipeline":		loc[0][0]=(182,1272,-117); loc[0][1]=(-94,748,252); loc[0][2]=(1054,1423,305); loc[0][3]=(1369,485,55); 
								loc[1][0]=(-141,244,17); loc[1][1]=(1812,3350,20); loc[1][2]=(2038,1659,3);
								loc[2][2]=(0,-90,0); loc[2][3]=(0,90,0);
								loc[3][2]=(0,-90,0); break;
								
		case "mp_shipment":		loc[0][0]=(266,188,204); loc[0][1]=(3,42,195);
								loc[1][0]=(-672,686,195); loc[1][1]=(638,-540,195);
								loc[2][0]=(0,90,0);
								loc[3][0]=(0,45,0); loc[3][1]=(0,-135,0);break;
								
		case "mp_showdown":		loc[0][0]=(-663,456,91); loc[0][1]=(-1055,136,80); loc[0][2]=(510,333,27); loc[0][3]=(668,-397,39);
								loc[1][0]=(869,955,27); loc[1][1]=(1000,-1360,19); loc[1][2]=(-1074,-1208,165);
								loc[2][1]=(10,-20,-20); loc[2][2]=(0,150,0); loc[2][2]=(0,-90,0);
								loc[3][0]=(0,90,0); loc[3][1]=(0,-138,0); loc[3][2]=(-30,90,0); break;
								
		case "mp_strike":		loc[0][0]=(-640,1872,19); loc[0][1]=(-156,582,60); loc[0][2]=(225,-548,40);
								loc[1][0]=(693,-1593,78); loc[1][1]=(-1020,475,77);
								loc[2][2]=(-50,120,0);
								loc[3][1]=(0,-90,0); break;
								
		case "mp_vacant":		loc[0][0]=(-310,1618,-37); loc[0][1]=(133,-61,-21); loc[0][2]=(536,-1296,-101); loc[0][3]=(-8,-573,-9);
								loc[1][0]=(-1793,1748,-101); loc[1][1]=(-500,343,-45); loc[1][2]=(576,274,-26);
								loc[2][0]=(-20,-100,-10); loc[2][1]=(0,-20,0); loc[2][2]=(0,-90,0);
								loc[3][1]=(0,90,0); loc[3][2]=(0,-90,0); break;
	}
	return loc;
}










