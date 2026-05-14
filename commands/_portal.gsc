#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("portal_mode",    "owner", ::cmd_Portal,        "Toggle portal mode");
	cmd("portal_players", "owner", ::cmd_PortalPlayers, "Allow players to go through other players portals");
	cmd("turret_delete",  "owner", ::cmd_TurretDelete,  "Delete turrets");
    cmd("turret",         "owner", ::cmd_Turret,        "Spawn a turret");
}

cmd_Portal(args)
{
	if (self.sr_mode == "Portal" || self sr\core\_modes::isInOtherMode("portal"))
		return;

	self sr\core\_modes::toggleMode("portal");
	self suicide();

	self pm(Ternary(self.modes["portal"], "^5Portal mode enabled!", "^1Portal mode disabled!"));
}

cmd_PortalPlayers(args)
{
	if (self.forcePortalPlayersAllowed)
	{
		self.forcePortalPlayersAllowed = false;
		self.forcePortalVisual = false;
	}
	else
	{
		self.forcePortalPlayersAllowed = true;
		self.forcePortalVisual = true;
	}
	self pm(Ternary(self.forcePortalPlayersAllowed, "^5Portal players", "^1Portal players"));
}

cmd_Turret(args)
{
	self thread sr\libs\portal\_turret::turret();
}

cmd_TurretDelete(args)
{
	for (i = 0; i < level.portal_turrets.size; i++)
	{
		level.portal_turrets[i] sr\libs\portal\_turret::explode("MOD_EXPLOSIVE");
		wait 1;
		level.portal_turrets[i] sr\libs\portal\_turret::turretDelete();
	}
}
