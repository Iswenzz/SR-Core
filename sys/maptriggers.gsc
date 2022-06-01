#include braxi\_common;

// TODO remove this gsc and place the changes in their own map gsc.

// Spawn endmap_trig if the map doesn't have one.
init()
{
	switch ( level.mapName )
	{
	case "mp_dr_nighty_v2":
		trigger = spawn( "trigger_radius", (-3883,8317,6316), 0, 150, 400 );
	    trigger.targetname = "endmap_trig";
	    trigger.radius = 150;
		break;
	case "mp_peds_propel":
		trigger = spawn( "trigger_radius", (7557,-1010,364), 0, 100, 400 );
	    trigger.targetname = "endmap_trig";
	    trigger.radius = 100;
	    thread cj_dvar();
		break;
	case "mp_dr_xm":
		trigger = spawn( "trigger_radius", (-10213, 2535.82, -1423.88), 0, 110, 120 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 110;
		break;
	case "mp_dr_muddled":
		trigger = spawn( "trigger_radius", (10297.4, 1450.59, -687.875), 0, 365, 75 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 365;
		break;

	case "mp_dr_glass2":
		trigger = spawn( "trigger_radius", (3492.48, 3184.86, 32.125), 0, 65, 75 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 65;
		break;
	case "mp_deathrun_cave":
		trigger = spawn( "trigger_radius", (2226.29, 3548.81, 4.125), 0, 55, 55 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 55;
		break;

	case "mp_deathrun_supermario":
		trigger = spawn( "trigger_radius", (293.538, -1472, 8.12501), 0, 40, 50 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 40;
		break;
	case "mp_deathrun_glass":
		trigger = spawn( "trigger_radius", (106.077, 2241.14, 64.125), 0, 55, 50 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 55;
		break;
	case "mp_deathrun_azteca":
		trigger = spawn( "trigger_radius", (6.59441, -808.602, 32.125), 0, 60, 50 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 60;
		break;

	case "mp_deathrun_colourful":
		trigger = spawn( "trigger_radius", (350.749, 197.533, 688.125), 0, 65, 40 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 65;
		break;

	case "mp_deathrun_escape2":
		trigger = spawn( "trigger_radius", (-6464.2, -2495.73, 184.125), 0, 60, 60 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 60;
		break;

	case "mp_deathrun_ruin2":
		trigger = spawn( "trigger_radius", (9329.7, 380.853, 128.125), 0, 255, 140 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 255;
		break;

// ===== Thanks to DuffMan for these ===== //
	case "mp_dr_bigfall":
		trigger = spawn( "trigger_radius", (-5484.02, -123.487, -12273.5), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_scary":
		trigger = spawn( "trigger_radius", (1.12299, -4825.81, 624.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_apocalypse_v2":
		trigger = spawn( "trigger_radius", (-7.09212, 3671.36, 976.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_framey_v2":
		trigger = spawn( "trigger_radius", (-2423.35, 794.684, 4.90718), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_backlot":
		trigger = spawn( "trigger_radius", (-939.774, 222.606, 106.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_max":
		trigger = spawn( "trigger_radius", (671.125, 13371.2, 0.125002), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_terror":
		trigger = spawn( "trigger_radius", (26.0624, 1312.15, 202.402), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.inAir = true;
		trigger.radius = 96;
		break;
	case "mp_dr_pool":
		trigger = spawn( "trigger_radius", (-876.881, 678.355, 184.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_skypillar":
		trigger = spawn( "trigger_radius", (-2044.31, -338.131, 1057.13), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_ssc_nothing":
		trigger = spawn( "trigger_radius", (228.711, -81.1929, 243.998), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_diehard":
		trigger = spawn( "trigger_radius", (-1095.76, -2331.43, 643.575), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_metal2":
		trigger = spawn( "trigger_radius", (-465.821, 975.085, 16.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_greenland":
		trigger = spawn( "trigger_radius", (175.547, -756.876, 144.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_sm_world":
		trigger = spawn( "trigger_radius", (-3499.54, -2704.88, 64.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_palm":
		trigger = spawn( "trigger_radius", (251.21, -256.368, 384.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_watchit_v3":
		trigger = spawn( "trigger_radius", (393.125, 1254.06, 640.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_city":
		trigger = spawn( "trigger_radius", (1271.56, -847.444, 0.124998), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_jailhouse":
		trigger = spawn( "trigger_radius", (-4908.72, 447.658, 218.524), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.inAir = true;
		trigger.radius = 96;
		break;
	case "mp_deathrun_crazy":
		trigger = spawn( "trigger_radius", (757.689, -2349.56, 1040.13), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_finalshuttle":
		trigger = spawn( "trigger_radius", (339.854, 2194.73, 428.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_indipyramid":
		trigger = spawn( "trigger_radius", (-273.908, 87.884, -229.875), 0, 196, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 196;
		break;
	case "mp_dr_bananaphone_v2":
		trigger = spawn( "trigger_radius", (2445.84, -424.875, 176.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_zero":
		trigger = spawn( "trigger_radius", (-1860.46, -8.91591, 16.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_wood_v3":
		trigger = spawn( "trigger_radius", (2884.08, 1041.26, 1024.06), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_takecare":
		trigger = spawn( "trigger_radius", (-701.125, 931.948, 192.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_portal_v3":
		trigger = spawn( "trigger_radius", (-4064.87, 1593.28, -63.875), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_minecraft":
		trigger = spawn( "trigger_radius", (-656.331, 1533.39, -31.875), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_liferun":
		trigger = spawn( "trigger_radius", (-279.875, 4833.46, 168.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_grassy":
		trigger = spawn( "trigger_radius", (2917.52, -1518.72, 64.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_dungeon":
		trigger = spawn( "trigger_radius", (1855.13, -2200.61, -183.875), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_dirt":
		trigger = spawn( "trigger_radius", (-30.625, -839.474, 768.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_destroyed":
		trigger = spawn( "trigger_radius", (-9224.88, 125.72, 484.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_darkness":
		trigger = spawn( "trigger_radius", (985.723, -587.125, 16.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_deathrun_clear":
		trigger = spawn( "trigger_radius", (-771.999, 520.011, 48.125), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_pacman":
		trigger = spawn( "trigger_radius", (41.1631, 600.943, 1033.63), 0, 96, 48 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 96;
		break;
	case "mp_dr_jurapark":
		trigger = spawn( "trigger_radius", (1007, 2044.27, -86.875), 0, 100, 90 );
		trigger.targetname = "endmap_trig";
		trigger.radius = 100;
		break;

	//======= Added by Blade =======//
	    case "mp_dr_gooby":
	            trigger = spawn( "trigger_radius", (328, 1018, -211), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_skypower":
	            trigger = spawn( "trigger_radius", (1507, -871, -896), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	             trigger.radius = 300;
	            break;
	    case "mp_dr_wtf":
	            trigger = spawn( "trigger_radius", (553, -611, 92), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_watercity":
	            trigger = spawn( "trigger_radius", (1491, 1096, 444), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_levels":
	            trigger = spawn( "trigger_radius", (4, 16672, -1917), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_mirroredge":
	            trigger = spawn( "trigger_radius", (-8191, -5991, -2968), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_easy_v2":
	            trigger = spawn( "trigger_radius", (12701.4, 2072.74, -143.875), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_moustache":
	            trigger = spawn( "trigger_radius", (-235, 475, 90), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_ruin":
	            trigger = spawn( "trigger_radius", (409, 1538, -2820), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_wipeout":
	            trigger = spawn( "trigger_radius", (2687, 2503, 92), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_wipeout_v2":
	            trigger = spawn( "trigger_radius", (1687, 3765, 524), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_blue":
	            trigger = spawn( "trigger_radius", (4582, 2556, -1714), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_sm_v2":
	            trigger = spawn( "trigger_radius", (1156, -1447, 68), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_detained":
	            trigger = spawn( "trigger_radius", (-171, -14776, -678), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_blackandwhite":
	            trigger = spawn( "trigger_radius", (13590, 133, 36), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_hilly_v2":
	            trigger = spawn( "trigger_radius", (7401, 2571, 54), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_neon":
	            trigger = spawn( "trigger_radius", (1394, -2105, 188), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_rock":
	            trigger = spawn( "trigger_radius", (6840, 506, -821), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_running":
	            trigger = spawn( "trigger_radius", (3093, -992, 381), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_takeshi":
	            trigger = spawn( "trigger_radius", (-929, -14, 600), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_up":
	            trigger = spawn( "trigger_radius", (14991, -2500, -14), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_vector":
	            trigger = spawn( "trigger_radius", (-410, -3992, -2244), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_mine":
	            trigger = spawn( "trigger_radius", (856.534, 5721.54, -985.875), 0, 90, 90 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 90;
	            break;
	    case "mp_deathrun_ponies":
	            trigger = spawn( "trigger_radius", (7767.31, -295.282, 352.125), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_deathrun_rainy_v2":
	            trigger = spawn( "trigger_radius", (9679.06, -1678.88, -391.875), 0, 175, 130 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 175;
	            break;
	    case "mp_deathrun_short_v4":
	            trigger = spawn( "trigger_radius", (181.322, -654.961, 72.125), 0, 40, 90 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 40;
	            break;
	    case "mp_deathrun_storm":
	            trigger = spawn( "trigger_radius", (-383.474, 9841.98, 464.125), 0, 65, 120 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 65;
	            break;
	    case "mp_deathrun_tribute":
	            trigger = spawn( "trigger_radius", (473.171, 390.95, -288.875), 0, 80, 125 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 80;
	            break;
	    case "mp_dr_color":
	            trigger = spawn( "trigger_radius", (-104.861, -418.832, -1483.88), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_electric":
	            trigger = spawn( "trigger_radius", (71.6143, 3940.71, -47.875), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_free":
	            trigger = spawn( "trigger_radius", (948.234, 2095.15, -2159.88), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_lithium":
	            trigger = spawn( "trigger_radius", (6899.93, -2205.18, -223.875), 0, 120, 185 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 120;
	            break;
	    case "mp_dr_mario_land":
	            trigger = spawn( "trigger_radius", (4406.08, 1638.91, 32.125), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_spedex":
	            trigger = spawn( "trigger_radius", (1183.8, -1292.02, -139.875), 0, 300, 300 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 300;
	            break;
	    case "mp_dr_stronghold":
	            trigger = spawn( "trigger_radius", (2936.97, -1045.97, 688.125), 0, 40, 105 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 40;
	            break;
	    //======= Added by Sheep =======//
	    case "mp_deathrun_islands":
	            trigger = spawn( "trigger_radius", (-612.406, -2376.85, -2087.88), 0, 75, 95 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 75;
	            break;
	    case "mp_deathrun_fluxx":
	            trigger = spawn( "trigger_radius", (-1663.35, 16682.4, -143.875), 0, 210, 75 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 210;
	            break;
	    case "mp_deathrun_oreo":
	            trigger = spawn( "trigger_radius", (14345.2, 520.546, -13671.9), 0, 160, 70 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 160;
	            break;
	    case "mp_dr_antichamber":
	            trigger = spawn( "trigger_radius", (346.666, 2394.72, -2815.88), 0, 230, 10 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 230;
	            break;
	    case "mp_deathrun_crystal":
	            trigger = spawn( "trigger_radius", (5852.35, -3361.35, 96.125), 0, 315, 55 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 315;
	            break;
	    case "mp_deathrun_qube":
	            trigger = spawn( "trigger_radius", (-3658.48, -1024.13, 2818.13), 0, 510, 10 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 510;
	            break;
	    case "mp_deathrun_dragonball":
	            trigger = spawn( "trigger_radius", (-19136.2, 13545.1, 256.125), 0, 325, 110 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 325;
	            break;
	    case "mp_deathrun_arbase":
	            trigger = spawn( "trigger_radius", (297.55, -197.924, -500.915), 0, 145, 60 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 145;
	            break;
	    case "mp_deathrun_bricky":
	            trigger = spawn( "trigger_radius", (170.32, 1645.52, -76.9696), 0, 220, 150 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 220;
				trigger.inAirCustom = true;
				trigger.inAirValue = 20;
	            break;
	    case "mp_deathrun_bunker":
	            trigger = spawn( "trigger_radius", (3531.79, 1671.2, -141.875), 0, 130, 80 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 130;
	            break;
	    case "mp_deathrun_clockwork":
	            trigger = spawn( "trigger_radius", (16593.9, -0.335908, 16.125), 0, 160, 135 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 160;
	            break;
	    case "mp_deathrun_cookie":
	            trigger = spawn( "trigger_radius", (-2.43295, -301.38, 128.125), 0, 40, 120 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 40;
	            break;
	    case "mp_deathrun_cosmic":
	            trigger = spawn( "trigger_radius", (6869.81, 512.292, 544.125), 0, 315, 80 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 315;
	            break;
	    case "mp_deathrun_easy":
	            trigger = spawn( "trigger_radius", (8311.36, -192.61, 16.125), 0, 90, 60 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 90;
	            break;
	    case "mp_deathrun_empire":
	            trigger = spawn( "trigger_radius", (1295.09, 1986.1, -632.477), 0, 200, 20 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 200;
	            break;
	    case "mp_deathrun_factory":
	            trigger = spawn( "trigger_radius", (803.975, -1479.65, 135.125), 0, 75, 25 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 75;
	            break;
	    case "mp_deathrun_illusion":
	            trigger = spawn( "trigger_radius", (1537.73, 19611.5, 671.113), 0, 150, 20 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 150;
	            break;
	    case "mp_deathrun_metal":
	            trigger = spawn( "trigger_radius", (-4164, 3753.78, 16.125), 0, 35, 105 );
	            trigger.targetname = "endmap_trig";
	            trigger.radius = 35;
	            break;
	}

	if( !isDefined( level.trapTriggers ) )
	{
		level.trapTriggers = [];
		switch ( level.mapName )
		{
		// BraXi's MAPS
		case "mp_deathrun_darkness":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t7", "targetname" );
			break;
		case "mp_deathrun_long":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger8", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger9", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger10", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger11", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger12", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger13", "targetname" );
			spawnCollision( (112,3440,24), 70, 16 );
			spawnCollision( (16,3696,28), 70, 16 );
			spawnCollision( (-112,3440,28), 70, 16 );
			spawnCollision( (-112,3440,28), 70, 16 );
			spawnCollision( (1136,3936,28), 110, 16 );
			spawnCollision( (304,-352,20), 110, 48 );
			break;

		// Viking's MAPS
		case "mp_deathrun_watchit_v2":
		case "mp_deathrun_watchit_v3":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t8", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t9", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t10", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t11", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t12", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t13", "targetname" );
			break;

		// MR-X's MAPS
		case "mp_deathrun_takecare":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_8", "targetname" );
			break;
		case "mp_deathrun_glass":
		case "mp_deathrun_dungeon":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_8", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig_9", "targetname" );
			break;
		case "mp_deathrun_supermario":

			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig8", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trig9", "targetname" );
			break;

		// Patrick's MAPS
		case "mp_deathrun_short":
		case "mp_deathrun_short_v2":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "t5", "targetname" );
			break;

		// Rednose's MAPS
		case "mp_deathrun_grassy":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger7", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger8", "targetname" );
			break;
		case "mp_deathrun_portal":
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger1", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger2", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger3", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger4", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger5", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger6", "targetname" );
			level.trapTriggers[level.trapTriggers.size] = getEnt( "trigger7", "targetname" );
			break;
		}
	}

	if( isDefined( level.trapTriggers ) )
	{
		level thread checkTrapUsage();
	}
}

checkTrapUsage()
{

	if( !level.trapTriggers.size )
	{
		warning( "checkTrapUsage() reported that level.trapTriggers.size is -1, add trap activation triggers to level.trapTriggers array and recompile FF" );
		warning( "Map doesn't support free run and XP for activation" );
		return;
	}

	for( i = 0; i < level.trapTriggers.size; i++ )
	{
		if ( level.dvar[ "freeRunChoice" ] == 2 )
		{
			level.trapTriggers[i] thread killFreeRunIfActivated();
		}
		if ( level.dvar[ "giveXpForActivation" ] )
		{
			level.trapTriggers[i] thread giveXpIfActivated();
		}
	}
}

killFreeRunIfActivated()
{
	level endon( "death" );
	level endon( "delete" );
	level endon( "deleted" );
	level endon( "kill_free_run_choice" );

	//level.trapsDisabled
	while( isDefined( self ) )
	{
		self waittill( "trigger", who );
		if( who.pers["team"] == "axis" )
		{
			level.canCallFreeRun = false;
			if( !level.trapsDisabled )
				level notify( "kill_free_run_choice" );
			break;
		}
	}
}

giveXpIfActivated()
{
	level endon( "death" );
	level endon( "delete" );
	level endon( "deleted" );

	while( isDefined( self ) )
	{
		self waittill( "trigger", who );
		if( who.pers["team"] == "axis" )
		{
			if( game["state"] != "playing" )
				return;
			who sr\sys\_rank::giveRankXP( "trap_activation" );
			break;
		}
	}
}

cj_dvar()
{
	setDvar("bg_falldamageminheight", 1280000);
	setDvar("bg_falldamagemaxheight", 3000000);
	level.sr_CJ = true;
}
