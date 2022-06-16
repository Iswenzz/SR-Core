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

	if (!self.modes["portal"])
		return;

	while (true)
	{
		wait 0.05;

		if (self getCurrentWeapon() != level.portalgun || self isOnLadder() || self isMantling() || self.throwingGrenade)
		{
			wait 1;
			self sr\libs\portal\_hud::updateHud("none");
			continue;
		}

		color = undefined;
		if (self attackButtonPressed())
			color = "blue";
		else if (self adsButtonPressed())
		{
			color = "red";
			while (self adsButtonPressed())
				wait 0.05;
		}
		else if (self fragButtonPressed())
			self sr\libs\portal\_portal_gun::resetPortals();

		if (isDefined(color))
		{
			self playLocalSound("portal_gun_shoot_" + color);
			self thread sr\libs\portal\_portal_gun::fire();
			self thread sr\libs\portal\_portal_gun::portal(color);
		}
		wait 0.2;
	}
}
