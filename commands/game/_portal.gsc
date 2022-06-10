#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("owner", 	"detonate",			::cmd_Detonate);
    cmd("owner", 	"turret",			::cmd_Turret);
	cmd("owner", 	"turret_delete",	::cmd_TurretDelete);
}

cmd_Detonate(args)
{
	self.detonate = true;
}

cmd_Turret(args)
{
	self clientCmd("centerview");
	wait 0.2;
	thread sr\libs\portal\_turret::turretSpawn(self.origin, self getPlayerAngles());
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
