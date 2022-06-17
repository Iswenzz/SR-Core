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

	if (!self.modes["portal"])
		return;

	wait 0.05;
	self giveWeapon(level.portalgun);
	self giveMaxAmmo(level.portalgun);
	self switchToWeapon(level.portalgun);

	while (true)
	{
		wait 0.05;

		if (self getCurrentWeapon() != level.portalgun || self isOnLadder() || self isMantling() || self.throwingGrenade)
		{
			wait 1;
			self sr\libs\portal\_hud::updateHud("none");
			self allowAds(true);
			continue;
		}
		self allowAds(false);

		color = undefined;
		if (self attackButtonPressed())
			color = "blue";
		else if (self adsButtonPressed())
			color = "red";
		else if (self fragButtonPressed())
			self sr\libs\portal\_portal_gun::resetPortals();

		if (isDefined(color))
		{
			self playLocalSound("portal_gun_shoot_" + color);
			self thread sr\libs\portal\_portal_gun::fire();
			self thread sr\libs\portal\_portal_gun::portal(color);
		}
		wait 0.05;
	}
}
