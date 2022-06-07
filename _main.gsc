main()
{
	precache();
	precacheText();
	precacheFx();

	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::deletePickups();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\_weapons::init();

	sr\sys\_dvar::initDvars();
	sr\sys\_events::initEvents();
	sr\sys\_file::initFiles();
    sr\sys\_mysql::initMySQL();
	sr\sys\_discord::initDiscord();
	sr\sys\_admins::initAdmins();

	sr\commands\_admin::main();
	sr\commands\_graphics::main();
	sr\commands\_misc::main();
	sr\commands\_music::main();
	sr\commands\_player::main();
	sr\commands\_vote::main();
	sr\commands\game\_kz::main();
	sr\commands\game\_minesweeper::main();
	sr\commands\game\_portal::main();
	sr\commands\game\_race::main();
	sr\commands\map\_edit::main();

	sr\game\_rank::initRank();
	sr\game\_cheat::main();
	sr\game\_credits::main();
	sr\game\_demo::main();
	sr\game\_hitmarker::main();
	sr\game\_killcam::main();
	sr\game\_map::main();
	sr\game\_match::main();
	sr\game\_menus::main();
	sr\game\fx\_trail::main();
	sr\game\fx\_trigger::main();
	sr\game\menus\_main::initMenus();
	sr\game\menus\_owner::main();
	sr\game\minigames\_main::initMinigames();
	sr\game\minigames\_kz::initKz();
	sr\game\minigames\_minesweeper::initMinesweeper();
	sr\game\minigames\_race::initRace();
	sr\game\weapons\_main::main();

	sr\player\_id::main();
	sr\player\_insertion::main();
	sr\player\_settings::main();
	sr\player\customize\_main::initCustomize();
	sr\player\fx\_spray::main();
	sr\player\huds\_player::main();
	sr\player\modes\_noclip::main();
	sr\player\modes\_pickup::main();
	sr\player\modes\_practise::main();

    sr\_tests::runTests();
}

precache()
{
	level.texts = [];
	level.fx = [];

	precacheShader("black");
	precacheShader("white");
	precacheShader("time_hud");
	precacheShader("killiconsuicide");
	precacheShader("killiconmelee");
	precacheShader("killiconheadshot");
	precacheShader("killiconfalling");
	precacheShader("stance_stand");
	precacheShader("hudstopwatch");
	precacheShader("score_icon");
	precacheShader("sr_shop");
	precacheShader("sr_dice");
	precacheShader("sr_vip");
	precacheShader("sr_insert");
	precacheShader("speedrunner_logo");

	precacheModel("tag_origin");
	precacheModel("german_sheperd_dog");
	precacheModel("viewmodel_hands_zombie");
	precacheModel("body_mp_usmc_cqb");
	precacheModel("collision_sphere");
	precacheModel("mil_frame_charge");
}

precacheText()
{
	level.texts["round_begins_in"] 		= &"BRAXI_ROUND_BEGINS_IN";
	level.texts["waiting_for_players"] 	= &"BRAXI_WAITING_FOR_PLAYERS";
	level.texts["jumpers_count"] 		= &"BRAXI_ALIVE_JUMPERS";
	level.texts["call_freeround"] 		= &"BRAXI_CALL_FREEROUND";
	level.texts["time"] 				= &"^2&&1";

	precacheString(level.texts["time"]);
	precacheString(level.texts["round_begins_in"]);
	precacheString(level.texts["waiting_for_players"]);
	precacheString(level.texts["jumpers_count"]);
	precacheString(level.texts["call_freeround"]);
}

precacheFx()
{
	level.fx["endgame"] 				= loadFx("deathrun/endgame_fx");
	level.fx["gib_splat"] 				= loadFx("deathrun/gib_splat");
	level.fx["light_blink"] 			= loadFx("misc/light_c4_blink");
	level.fx["endtrig_fx"] 				= loadFx("deathrun/endtrig_fx");
	level.fx["endtrigcircle_fx"] 		= loadFx("deathrun/endtrigcircle_fx");
	level.fx["secrettrig_fx"] 			= loadFx("deathrun/secrettrig_fx");
	level.fx["yellow_fx"] 				= loadFx("deathrun/yellow_fx");
	level.fx["red_fx"] 					= loadFx("deathrun/red_fx");
	level.fx["purple_fx"] 				= loadFx("deathrun/purple_fx");
	level.fx["orange_fx"] 				= loadFx("deathrun/orange_fx");
	level.fx["green_fx"] 				= loadFx("deathrun/green_fx");
	level.fx["cyan_fx"] 				= loadFx("deathrun/cyan_fx");
	level.fx["secrettrigcircle_fx"] 	= loadFx("deathrun/secrettrigcircle_fx");
	level.fx["wr_event"] 				= loadFx("deathrun/wr_fx");
	level.fx["viptrail1"] 				= loadFx("deathrun/vip_trail1");
	level.fx["viptrail2"] 				= loadFx("deathrun/vip_trail2");
	level.fx["viptrail3"] 				= loadFx("deathrun/vip_trail3");
	level.fx["viptrail4"] 				= loadFx("deathrun/vip_trail4");
	level.fx["viptrail5"] 				= loadFx("deathrun/vip_trail5");
	level.fx["startnstop"] 				= loadFx("deathrun/flare_startnstop");
	level.fx["jetpack"] 				= loadFx("smoke/jetpack");
	level.fx["meteor"] 					= loadFX("fire/tank_fire_engine");
	level.fx["explosion"] 				= loadfx("explosions/grenadeExp_concrete_1");
	level.fx["flame"] 					= loadfx("fire/tank_fire_engine");

	visionSetNaked(toLower(getDvar("mapname")), 0);
}
