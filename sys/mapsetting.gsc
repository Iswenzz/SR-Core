// TODO remove this gsc and place the changes in their own map gsc.

// Add certain map changes here.
init()
{

	switch (level.mapName)
	{
	case "mp_q3_slide_awumpus":
		level.masterSpawn = spawn("script_origin",(4608,-7776,0));
        level.masterSpawn.angles = (0,360,0);
        break;
	case "mp_q3_slide_dfwc2017_2":
		level.masterSpawn = spawn("script_origin",(2384,-8031,344));
        level.masterSpawn.angles = (0,180,0);
        break;
	case "mp_deathrun_spaceball":
		level.masterSpawn = spawn("script_origin",(9,-43,4037));
        level.masterSpawn.angles = (0,0,0);
        break;
	case "mp_sr_fl4pmy4ss":
		level.masterSpawn = spawn("script_origin",(-3072,448,-671));
        level.masterSpawn.angles = (0,0,0);
        break;
	case "mp_sr_a55":
		level.masterSpawn = spawn("script_origin",(-3008,-656,2552));
        level.masterSpawn.angles = (0,0,0);
        break;
	case "mp_dr_nighty_v2":
		level.masterSpawn = spawn("script_origin",(-6512,824,1144));
        level.masterSpawn.angles = (0,270,0);
        break;
	case "mp_q3_slide_nood_adr":
		level.masterSpawn = spawn("script_origin",(-713,-7372.6,384));
        level.masterSpawn.angles = (0,360,0);
        break;
	case "mp_q3_slide_dfwc2017_6":
		level.masterSpawn = spawn("script_origin",(-5632,3427,224));
        level.masterSpawn.angles = (0,159.5,0);
        break;
	case "mp_dr_rage":
		level.masterSpawn = spawn("script_origin",(145, 0, 0));
        level.masterSpawn.angles = (0,360,0);
        break;
	case "mp_deathrun_darkness":
		level.masterSpawn = spawn("script_origin",(-4, -197, 0));
        level.masterSpawn.angles = (0,90,0);
        break;
	case "mp_deathrun_uncharted":
		level.masterSpawn = spawn("script_origin",(-161, 1547, 95));
        level.masterSpawn.angles = (0,360,0);
        break;
	case "mp_deathrun_hop":
		level.masterSpawn = spawn("script_origin",(-7, 45, 0));
        level.masterSpawn.angles = (0,0,0);
        break;
	case "mp_peds_propel":
		level.masterSpawn = spawn("script_origin",(2316, 71, 0));
        level.masterSpawn.angles = (0,0,0);
		break;
	case "mp_dr_glass3":
		level.masterSpawn = spawn("script_origin",(1228, 786, -160));
        level.masterSpawn.angles = (0,90,0);
		break;
	case "mp_dr_train_rush":
		level.masterSpawn = spawn("script_origin",(0, -19544, 192));
        level.masterSpawn.angles = (0,90,0);
		break;
	case "mp_dr_guest_list":
        level.masterSpawn = spawn("script_origin",(-30,642,130));
        level.masterSpawn.angles = (0,270,0);
        break;
	case "mp_dr_destiny":
        level.masterSpawn = spawn("script_origin",(825,368,200));
        level.masterSpawn.angles = (0,270,0);
        break;
	case "mp_dr_terror":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin + (121,0,0));
        level.masterSpawn.angles = (0,270,0);
        break;
	case "mp_deathrun_fluxx":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = (0,90,0);
        break;
	case "mp_dr_caelum":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        break;
	case "mp_deathrun_jailhouse":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin - (0,49,0));
        level.masterSpawn.angles = (0,180,0);
        break;
	case "mp_deathrun_snowic":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        break;
	case "mp_deathrun_sanctuary":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][2].origin + (125,0,0));
        level.masterSpawn.angles = (0,270,0);
		del = getEnt("endmap_trig","targetname");
		del delete();
		trig = spawn("trigger_radius", (5513.96, -2223.63, 32.125), 0, 105, 100);
		trig.targetname = "endmap_trig";
		trig.radius = 105;
		level.mapHasTimeTrigger = true;
		while (true)
		{
			trig waittill("trigger", player);
			player thread braxi\_mod::endTimer();
		}
        break;
	case "mp_dr_spacetunnel":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][5].origin - (159,0,0));
        level.masterSpawn.angles = level.spawn["allies"][5].angles;
        break;
	case "mp_dr_jurapark":
        level.masterSpawn = spawn("script_origin", (-321,295,-87));
        level.masterSpawn.angles = level.spawn["allies"][2].angles;
        break;
	case "mp_deathrun_cookie":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][2].origin);
        level.masterSpawn.angles = level.spawn["allies"][2].angles;
        break;
	case "mp_deathrun_qube":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        break;
	case "mp_deathrun_mirroredge":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        break;
	case "mp_fnrp_iceland_v2":
		trig = getEnt("finaldoor", "targetname");
		level.mapHasTimeTrigger = true;
		wait 1;
		thread sr\game\fx\_trigger::createTrigFx(trig, "endtrig");
        while (true)
        {
            trig waittill("trigger", player);
            player thread braxi\_mod::endTimer();
        }
        break;
	case "mp_deathrun_wipeout_v2":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        break;
	case "mp_dr_urban":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][10].origin);
        level.masterSpawn.angles = level.spawn["allies"][10].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_dr_lazyriver":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][3].origin);
        level.masterSpawn.angles = level.spawn["allies"][3].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_dr_overgrownv2":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][3].origin);
        level.masterSpawn.angles = level.spawn["allies"][3].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_dr_imaginary":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][3].origin);
        level.masterSpawn.angles = level.spawn["allies"][3].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_dr_beat":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][5].origin);
        level.masterSpawn.angles = level.spawn["allies"][5].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_fnrp_monderland":
        trig=getEnt("finaldoor", "targetname");
        level.mapHasTimeTrigger = true;
        while (true)
        {
            trig waittill("trigger", player);
            player thread braxi\_mod::endTimer();
        }
        break;
	case "mp_deathrun_ruin":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][10].origin);
        level.masterSpawn.angles = level.spawn["allies"][10].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_dr_blue":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][6].origin);
        level.masterSpawn.angles = level.spawn["allies"][6].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_deathrun_tribute":
        level.masterSpawn = spawn("script_origin", (623,4,-259));
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_dr_free":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_deathrun_bricky":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        level.masterSpawn placeSpawnPoint();
        break;
    case "mp_deathrun_scoria":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][0].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_sr_parkour":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_deathrun_mine":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_dr_asu":
		level.masterSpawn = spawn("script_origin", (-176,48,-52));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_dr_watercity":
		level.masterSpawn = spawn("script_origin", (1861,-567,125));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_dr_skydeath":
		level.masterSpawn = spawn("script_origin", (-205,-1343,82));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_deathrun_skypillar":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_deathrun_saw":
		level.masterSpawn = spawn("script_origin", (-494,3,82));
		level.masterSpawn.angles = (0,0,0);
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_deathrun_haunted":
        level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
        level.masterSpawn.angles = level.spawn["allies"][6].angles;
        level.masterSpawn placeSpawnPoint();
        break;
	case "mp_deathrun_gold":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = (0,270,0);
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_deathrun_backlot":
		level.masterSpawn = spawn("script_origin", (-450,1515,126));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;
	case "mp_dr_something":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_dr_ravine":
		level.masterSpawn = spawn("script_origin", (-774,-3072,335));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_dr_pool":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_dr_indipyramid":
		level.masterSpawn = spawn("script_origin", (-3046,155,-308));
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_dr_bounce":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][3].origin);
		level.masterSpawn.angles = level.spawn["allies"][3].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_deathrun_fusion":
		level.masterSpawn = spawn("script_origin", level.spawn["allies"][0].origin);
		level.masterSpawn.angles = level.spawn["allies"][0].angles;
		level.masterSpawn placeSpawnPoint();
		break;

	case "mp_deathrun_framey_v3":
		trig=getent("activator_door_trig","targetname");
		level.mapHasTimeTrigger = true;
		while (true)
		{
			trig waittill("trigger", player);
			player thread braxi\_mod::endTimer();
		}
		break;

	default:
		break;
	}
}
