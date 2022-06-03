#include sr\sys\_menu;
#include sr\sys\_events;

main()
{
	precache();

	event("connect", ::onConnect);
}

onConnect()
{
	self thread portal\_portal_gun::main();

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
	self.portal["hud"] = newClientHudElem(self);
}

precache()
{
	cheapSinSetup();

	preCacheItem(level.portalgun);
	preCacheItem(level.portalgun_bendi);
	preCacheModel("collision_wall_100x75");
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

	level._effect["bullettest"]				= loadfx("portal/bullettest");
	level._effect["blueportal"]				= loadfx("portal/portal_blue");
	level._effect["redportal"]				= loadfx("portal/portal_red");
	level._effect["blueportal_open"]		= loadfx("portal/portal_blue_open");
	level._effect["redportal_open"]			= loadfx("portal/portal_red_open");
	level._effect["blueportal_close"]		= loadfx("portal/portal_blue_close");
	level._effect["redportal_close"]		= loadfx("portal/portal_red_close");
	level._effect["blueportal_fail"]		= loadfx("portal/portal_blue_fail");
	level._effect["redportal_fail"]			= loadfx("portal/portal_red_fail");
	level._effect["portalballblue"]			= loadfx("portal/portal_ball_blue");
	level._effect["portalballred"]			= loadfx("portal/portal_ball_red");
	level._effect["projected_wall"]			= loadfx("portal/projected_wall");
	level._effect["projected_wall_end"]		= loadfx("portal/projected_wall_end");
	level._effect["projected_wall_start"]	= loadfx("portal/projected_wall_start");
	level._effect["projected_wall_mask"]	= loadfx("portal/projected_wall_mask");
	level._effect["redlaser"]				= loadfx("portal/redlaser");
	level._effects["impact_bark"] 			= loadfx("impacts/large_woodhit");
	level._effects["impact_brick"] 			= loadfx("impacts/small_brick");
	level._effects["impact_carpet"]	 		= loadfx("impacts/default_hit");
	level._effects["impact_cloth"] 			= loadfx("impacts/cloth_hit");
	level._effects["impact_concrete"] 		= loadfx("impacts/small_concrete");
	level._effects["impact_dirt"] 			= loadfx("impacts/small_dirt");
	level._effects["impact_flesh"] 			= loadfx("impacts/flesh_hit");
	level._effects["impact_foliage"] 		= loadfx("impacts/small_foliage");
	level._effects["impact_glass"] 			= loadfx("impacts/small_glass");
	level._effects["impact_grass"] 			= loadfx("impacts/small_grass");
	level._effects["impact_gravel"] 		= loadfx("impacts/small_gravel");
	level._effects["impact_ice"] 			= loadfx("impacts/small_snowhit");
	level._effects["impact_metal"] 			= loadfx("impacts/small_metalhit");
	level._effects["impact_mud"] 			= loadfx("impacts/small_mud");
	level._effects["impact_paper"] 			= loadfx("impacts/default_hit");
	level._effects["impact_plaster"] 		= loadfx("impacts/small_concrete");
	level._effects["impact_rock"] 			= loadfx("impacts/small_rock");
	level._effects["impact_sand"] 			= loadfx("impacts/small_dirt");
	level._effects["impact_snow"] 			= loadfx("impacts/small_snowhit");
	level._effects["impact_water"] 			= loadfx("impacts/small_waterhit");
	level._effects["impact_wood"] 			= loadfx("impacts/large_woodhit");
	level._effects["impact_asphalt"] 		= loadfx("impacts/small_concrete");
	level._effects["impact_ceramic"] 		= loadfx("impacts/small_ceramic");
	level._effects["impact_plastic"] 		= loadfx("impacts/large_plastic");
	level._effects["impact_rubber"] 		= loadfx("impacts/default_hit");
	level._effects["impact_cushion"] 		= loadfx("impacts/cushion_hit");
	level._effects["impact_fruit"] 			= loadfx("impacts/default_hit");
	level._effects["impact_paintedmetal"] 	= loadfx("impacts/large_metal_painted_hit");
	level._effects["impact_default"] 		= loadfx("impacts/default_hit");

	level._effects["impact_flesh_body_nonfatal"] 	= loadfx("impacts/flesh_hit_body_nonfatal");
	level._effects["impact_flesh_body_fatal"] 		= loadfx("impacts/flesh_hit_body_fatal_exit");
	level._effects["impact_flesh_head_nonfatal"] 	= loadfx("impacts/flesh_hit_body_nonfatal");
}
