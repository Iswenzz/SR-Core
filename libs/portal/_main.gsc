#include sr\sys\_events;
#include sr\sys\_dvar;
#include sr\utils\_math;

main()
{
	level.defaultknockback = 1000;
	level.maxdistance =  99999999999;
	level.object_gravity = 800;
	level.throw_max_force = 30;

	sr\libs\portal\_pickup::main();
	sr\libs\portal\_portal_gun::main();
	sr\libs\portal\_turret::main();

	addDvar("portal_owner_walkthrough_only", 	"portal_owner_walkthrough_only", 	0, 0, 1, 	"int");
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

onConnect()
{
	self endon("disconnect");

	wait 0.05;

	self setClientDvar("r_distortion", 1);

	self.portal = [];
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
	self.portal["hud"] = newClientHudElem(self);
	self.turrets = [];
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

	level.fx["blueportal"]				= loadfx("portal/portal_blue");
	level.fx["redportal"]				= loadfx("portal/portal_red");
	level.fx["blueportal_open"]			= loadfx("portal/portal_blue_open");
	level.fx["redportal_open"]			= loadfx("portal/portal_red_open");
	level.fx["blueportal_close"]		= loadfx("portal/portal_blue_close");
	level.fx["redportal_close"]			= loadfx("portal/portal_red_close");
	level.fx["blueportal_fail"]			= loadfx("portal/portal_blue_fail");
	level.fx["redportal_fail"]			= loadfx("portal/portal_red_fail");
	level.fx["portalballblue"]			= loadfx("portal/portal_ball_blue");
	level.fx["portalballred"]			= loadfx("portal/portal_ball_red");
	level.fx["redlaser"]				= loadfx("portal/redlaser");
}
