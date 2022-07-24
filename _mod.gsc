main()
{
	precache();
	precacheText();
	precacheFx();

	maps\mp\gametypes\_hud::init();
	maps\mp\gametypes\_hud_message::init();
	maps\mp\gametypes\_damagefeedback::init();
	maps\mp\gametypes\_clientids::init();
	maps\mp\gametypes\_gameobjects::init();
	maps\mp\gametypes\_spawnlogic::init();
	maps\mp\gametypes\_oldschool::deletePickups();
	maps\mp\gametypes\_hud::init();
	maps\mp\gametypes\_quickmessages::init();
	maps\mp\_weapons::init();

	sr\sys\_dvar::initDvars();
	sr\sys\_events::initEvents();
	sr\sys\_file::initFiles();
	sr\sys\_ids::initIds();
    sr\sys\_mysql::initMySQL();
    sr\sys\_curl::initCurl();
	sr\sys\_discord::initDiscord();
	sr\sys\_admins::initAdmins();
	sr\sys\_notifications::initNotifications();

	sr\game\_map::main();
	sr\game\_rank::initRank();
	sr\game\_cheat::main();
	sr\game\_demo::main();
	sr\game\_menus::main();
	sr\game\_perks::initPerks();
	sr\game\_defrag::main();
	sr\game\_teams::main();
	sr\game\_vote::initVote();
	sr\game\fx\_trail::main();
	sr\game\menus\_main::initMenus();
	sr\game\menus\_owner::main();
	sr\game\minigames\_main::initMinigames();
	sr\game\weapons\_main::main();

	sr\commands\_admin::main();
	sr\commands\_debug::main();
	sr\commands\_graphics::main();
	sr\commands\_misc::main();
	sr\commands\_music::main();
	sr\commands\_player::main();
	sr\commands\_vote::main();
	sr\commands\game\_portal::main();
	sr\commands\map\_edit::main();

	sr\libs\portal\_main::main();

	sr\player\_hide::main();
	sr\player\_insertion::main();
	sr\player\_settings::main();
	sr\player\fx\_spray::main();
	sr\player\modes\_main::initModes();
	sr\player\modes\_defrag::main();
	sr\player\modes\_noclip::main();
	sr\player\modes\_pickup::main();
	sr\player\modes\_portal::main();
	sr\player\huds\_cgaz::main();
	sr\player\huds\_crosshair::main();
	sr\player\huds\_snap::main();
	sr\player\huds\_fps::main();
	sr\player\huds\_keys::main();
	sr\player\huds\_velocity::main();
}

precache()
{
	level.assets = [];
	level.texts = [];
	level.fx = [];

	precacheItem("shop_mp");
	precacheItem("vip_mp");
	precacheItem("tomahawk_mp");
	precacheItem("fortnite_mp");
	precacheItem("colt45_mp");
	precacheItem("claymore_mp");
	precacheItem("knife_mp");
	precacheItem("dog_mp");
	precacheItem("shovel_mp");
	precacheItem("rpg_mp");
	precacheItem("c4_mp");
	precacheItem("rtd_mp");
	precacheItem("frag_grenade_short_mp");
	precacheItem("frag_grenade_mp");
	precacheItem("smoke_grenade_mp");
	precacheItem("flash_grenade_mp");

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
	level.texts["round_begins_in"] 		= &"SR_ROUND_BEGINS_IN";
	level.texts["waiting_for_players"] 	= &"SR_WAITING_FOR_PLAYERS";
	level.texts["jumpers_count"] 		= &"SR_ALIVE_JUMPERS";
	level.texts["call_freeround"] 		= &"SR_CALL_FREEROUND";
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
	level.fx["pickup"]					= loadfx("misc/ui_pickup_available");
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
	level.fx["meteor"] 					= loadFx("fire/tank_fire_engine");
	level.fx["explosion"] 				= loadfx("explosions/grenadeExp_concrete_1");
	level.fx["flame"] 					= loadfx("fire/tank_fire_engine");

	visionSetNaked(toLower(level.map), 0);
}
