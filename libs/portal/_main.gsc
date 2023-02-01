#include sr\sys\_events;
#include sr\sys\_dvar;
#include sr\utils\_common;
#include sr\utils\_math;

initPortal()
{
	level.defaultknockback = 1000;
	level.maxdistance =  99999999999;
	level.object_gravity = 800;
	level.throw_max_force = 30;

	sr\libs\portal\_pickup::main();
	sr\libs\portal\_portal_gun::main();
	sr\libs\portal\_turret::main();

	addDvar("portal_block_bullet", 				"portal_block_bullet", 				1, 0, 1, 	"int");
	addDvar("portal_block_c4", 					"portal_block_c4", 					0, 0, 1, 	"int");
	addDvar("portal_block_grenade", 			"portal_block_grenade", 			0, 0, 1, 	"int");
	addDvar("portal_forbid_terrain", 			"portal_forbid_terrain", 			0, 0, 1, 	"int");
	addDvar("portal_help_orientation", 			"portal_help_orientation", 			1, 0, 1, 	"int");
	addDvar("portal_max_turrets", 				"portal_max_turrets", 				4, 0, 10, 	"int");
	addDvar("portal_turret_target_owner", 		"portal_turret_target_owner", 		0, 0, 1, 	"int");

	precache();

	event("connect", ::onConnect);
}

precache()
{
	cheapSinSetup();

	preCacheItem(level.portalgun);
	preCacheModel("collision_sphere");
	preCacheModel("cube");
	preCacheModel("companion_cube");
	preCacheModel("energy_ball");
	preCacheModel("portal_dummy_blue");
	preCacheModel("portal_dummy_red");
	preCacheModel("portal_blue");
	preCacheModel("portal_red");
	preCacheShader("reticle_portal");
	preCacheShader("reticle_portal_blue");
	preCacheShader("reticle_portal_red");
	preCacheShader("reticle_portal_both");

	level.gfx["blueportal"]				= loadFx("portal/portal_blue");
	level.gfx["redportal"]				= loadFx("portal/portal_red");
	level.gfx["blueportal_open"]		= loadFx("portal/portal_blue_open");
	level.gfx["redportal_open"]			= loadFx("portal/portal_red_open");
	level.gfx["blueportal_close"]		= loadFx("portal/portal_blue_close");
	level.gfx["redportal_close"]		= loadFx("portal/portal_red_close");
	level.gfx["blueportal_fail"]		= loadFx("portal/portal_blue_fail");
	level.gfx["redportal_fail"]			= loadFx("portal/portal_red_fail");
	level.gfx["portalballblue"]			= loadFx("portal/portal_ball_blue");
	level.gfx["portalballred"]			= loadFx("portal/portal_ball_red");
	level.gfx["redlaser"]				= loadFx("portal/redlaser");
}

onConnect()
{
	self endon("connect");
	self endon("disconnect");

	self.portals = [];
	self.portal = [];
	self.physics = [];
	self.turrets = [];

	self.portal["blue_exist"] = false;
	self.portal["red_exist"] = false;
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
	self.portal["inportal"] = false;
	self.portal["first_enter"] = true;
}
