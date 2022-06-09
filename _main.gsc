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

	thread sr\sys\_dvar::initDvars();
	thread sr\sys\_events::initEvents();
	thread sr\sys\_file::initFiles();
    thread sr\sys\_mysql::initMySQL();
	thread sr\sys\_discord::initDiscord();
	thread sr\sys\_admins::initAdmins();

	thread sr\commands\_admin::main();
	thread sr\commands\_graphics::main();
	thread sr\commands\_misc::main();
	thread sr\commands\_music::main();
	thread sr\commands\_player::main();
	thread sr\commands\_vote::main();
	thread sr\commands\game\_kz::main();
	thread sr\commands\game\_minesweeper::main();
	thread sr\commands\game\_portal::main();
	thread sr\commands\game\_race::main();
	thread sr\commands\map\_edit::main();

	thread sr\game\_rank::initRank();
	thread sr\game\_cheat::main();
	thread sr\game\_credits::main();
	// thread sr\game\_demo::main();
	thread sr\game\_hitmarker::main();
	thread sr\game\_killcam::main();
	thread sr\game\_map::main();
	thread sr\game\_menus::main();
	thread sr\game\fx\_trail::main();
	thread sr\game\fx\_trigger::main();
	// thread sr\game\menus\_main::initMenus();
	// thread sr\game\menus\_owner::main();
	thread sr\game\minigames\_main::initMinigames();
	// thread sr\game\minigames\_kz::initKz();
	// thread sr\game\minigames\_minesweeper::initMinesweeper();
	// thread sr\game\minigames\_race::initRace();
	thread sr\game\weapons\_main::main();

	thread sr\player\_id::main();
	thread sr\player\_insertion::main();
	thread sr\player\_settings::main();
	thread sr\player\fx\_spray::main();
	thread sr\player\huds\_player::main();
	// thread sr\player\modes\_noclip::main();
	// thread sr\player\modes\_pickup::main();
	thread sr\player\modes\_practise::main();

    thread sr\_tests::runTests();
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
	level.texts["ended_game"]			= &"MP_HOST_ENDED_GAME";
	level.texts["endgame"]				= &"MP_HOST_ENDGAME_RESPONSE";

	precacheString(level.texts["time"]);
	precacheString(level.texts["round_begins_in"]);
	precacheString(level.texts["waiting_for_players"]);
	precacheString(level.texts["jumpers_count"]);
	precacheString(level.texts["call_freeround"]);
	precacheString(level.texts["ended_game"]);
	precacheString(level.texts["endgame"]);
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
