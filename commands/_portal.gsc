#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("owner", 	"portal_mode",		::cmd_Portal);
	cmd("owner", 	"portal_players",	::cmd_PortalPlayers);
	cmd("owner", 	"detonate",			::cmd_Detonate);
    cmd("owner", 	"turret",			::cmd_Turret);
	cmd("owner", 	"turret_delete",	::cmd_TurretDelete);
}

cmd_Portal(args)
{
	if (self.sr_mode == "Portal" || self sr\player\modes\_main::isInOtherMode("portal"))
		return;

	self sr\player\modes\_main::toggleMode("portal");
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

cmd_Detonate(args)
{
	self.detonate = true;
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
