#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("portal");

	event("spawn", ::watch);
}

watch()
{
	self endon("disconnect");
	self endon("death");

	self allowAds(true);

	if (!isInMode("portal"))
		return;

	self waittill("speedrun_hud");
	self.runId = "Portal";
	self.huds["speedrun"]["name"] setText("^5Portal");

	wait 0.05;
	self giveWeapon(level.portalgun);
	self giveMaxAmmo(level.portalgun);
	wait 0.05;
	self switchToWeapon(level.portalgun);

	while (true)
	{
		wait 0.05;

		if (self getCurrentWeapon() != level.portalgun || self isOnLadder() || self isMantling() || self.throwingGrenade)
		{
			self sr\libs\portal\_hud::updateHud("none");
			wait 1;
			continue;
		}

		color = undefined;
		if (self attackButtonPressed())
			color = "blue";
		else if (self aimButtonPressed())
			color = "red";
		else if (self fragButtonPressed())
			self sr\libs\portal\_portal_gun::resetPortals();

		if (isDefined(color))
		{
			self playLocalSound("portal_gun_shoot_" + color);
			self thread sr\libs\portal\_portal_gun::portal(color);
		}
		while (self attackButtonPressed() || self aimButtonPressed() || self fragButtonPressed())
			wait 0.05;
	}
}
