#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("masteradmin", 	"bounce",		::cmd_Bounce);
	cmd("owner", 		"clone",		::cmd_Clone);
	cmd("owner", 		"damage",		::cmd_Damage);
	cmd("admin", 		"dance",		::cmd_Dance);
	cmd("adminplus", 	"drop",			::cmd_Drop);
	cmd("adminplus", 	"flash",		::cmd_Flash);
	cmd("owner", 		"g_gravity",	::cmd_G_Gravity);
	cmd("owner", 		"g_speed",		::cmd_G_Speed);
	cmd("owner", 		"god",			::cmd_God);
	cmd("admin",        "kill",			::cmd_Kill);
	cmd("owner", 		"knockback",	::cmd_Knockback);
	cmd("owner", 		"model",		::cmd_Model);
	cmd("owner", 		"noclip",		::cmd_NoClip);
	cmd("player", 		"pm", 			::cmd_PM);
	cmd("masteradmin", 	"sr_freeze",	::cmd_Freeze);
	cmd("masteradmin", 	"sr_unfreeze",	::cmd_UnFreeze);
	cmd("adminplus", 	"shock",		::cmd_Shock);
	cmd("masteradmin", 	"shovel",		::cmd_Shovel);
	cmd("adminplus", 	"takeall",		::cmd_TakeAll);
	cmd("owner", 		"trooper",		::cmd_Trooper);
	cmd("owner", 		"uammo",		::cmd_UAmmo);
	cmd("adminplus", 	"weapon",		::cmd_Weapon);
	cmd("adminplus", 	"weapon_all",	::cmd_WeaponAll);
	cmd("adminplus", 	"weapon_acti",	::cmd_WeaponActi);
}

cmd_Bounce(args)
{
	self log();
	player = IfUndef(getPlayerByName(args[0]), self);

	player bounce(vectorNormalize(player.origin - (player.origin - (0, 0, 20))), 400);
}

cmd_Clone()
{
	Ternary(!isDefined(self.clone), clone(), cloneDespawn());
}

cmd_Damage()
{
	self.teamKill = !self.teamKill;
}

cmd_Dance()
{
	self thread fortniteDance();
}

cmd_Drop(args)
{
	if (args.size < 1)
		return self pm("Usage: drop <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player dropItem(player getCurrentWeapon());
}

cmd_Flash(args)
{
	if (args.size < 1)
		return self pm("Usage: flash <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player thread maps\mp\_flashgrenades::applyFlash(4, 0.75);
}

cmd_G_Gravity(args)
{
	if (args.size < 1)
		return self pm("Usage: g_gravity <value> <playerName>");

	value = ToInt(args[0]);
	player = IfUndef(getPlayerByName(args[1]), self);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player setGravity(value);
}

cmd_G_Speed(args)
{
	if (args.size < 1)
		return self pm("Usage: g_speed <value> <playerName>");

	value = ToInt(args[0]);
	player = IfUndef(getPlayerByName(args[1]), self);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player setMoveSpeed(value);
}

cmd_God(args)
{
	player = IfUndef(getPlayerByName(args[0]), self);

	player.health = 999999999999999999;
	player.maxhealth = 999999999999999999;
}

cmd_Kill(args)
{
	if (args.size < 1)
		return self pm("Usage: kill <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player suicide();
}

cmd_Knockback(args)
{
	player = IfUndef(getPlayerByName(args[0]), self);
	self log();

	player.bt_knockback = Ternary(!isDefined(player.bt_knockback), true, undefined);
}

cmd_Model(args)
{
	if (args.size < 1)
		return self pm("Usage: model <name> <playerName>");

	model = args[0];
	player = IfUndef(getPlayerByName(args[1]), self);

	if (!isDefined(player))
		return pm("Could not find player");

	player setModel(model);
}

cmd_NoClip()
{
	self.noclip = !self.noclip;
	self sr\api\_player::antiElevator(!self.noclip);
}

cmd_PM(args)
{
	if (args.size < 2)
		return self pm("Usage: !!pm <playerName> <message>");

	player = getPlayerByName(args[0]);
	msg = args[1];

	exec(fmt("tell %d ^5%s PM You:^7 %s", player getEntityNumber(), self.name, msg));
	exec(fmt("tell %d ^5You PM to %s:^7 %s", self getEntityNumber(), player.name, msg));
}

cmd_Freeze(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_freeze <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player freezeControls(true);
}

cmd_UnFreeze(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_unfreeze <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player freezeControls(false);
}

cmd_Shock(args)
{
	if (args.size < 2)
		return self pm("Usage: shock <playerName> <name>");

	player = getPlayerByName(args[0]);
	shock = args[1];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player shellShock(shock, 5);
}

cmd_Shovel()
{
	self giveWeapon("shovel_mp");
	self giveMaxAmmo("shovel_mp");
	self switchToWeapon("shovel_mp");
}

cmd_TakeAll(args)
{
	if (args.size < 2)
		return self pm("Usage: takeall <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player takeAllWeapons();
}

cmd_Trooper()
{
	self thread trooper();
}

cmd_UAmmo()
{
	self thread unlimitedAmmo();
}

cmd_Weapon(args)
{
	if (args.size < 2)
		return self pm("Usage: weapon <playerName> <weapon>");

	player = getPlayerByName(args[0]);
	weapon = args[1];

	if (!isDefined(player))
		return pm("Could not find player");

	player giveWeapon(weapon);
	player switchToWeapon(weapon);
	player giveMaxAmmo(weapon);
}

cmd_WeaponAll(args)
{
	if (args.size < 1)
		return self pm("Usage: weapon_all <weapon>");

	weapon = args[0];

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] giveWeapon(weapon);
		players[i] switchToWeapon(weapon);
		players[i] giveMaxAmmo(weapon);
	}
}

cmd_WeaponActi(args)
{
	if (args.size < 1)
		return self pm("Usage: weapon_acti <weapon>");

	weapon = args[0];

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i].team == "axis")
		{
			players[i] giveWeapon(weapon);
			players[i] switchToWeapon(weapon);
			players[i] giveMaxAmmo(weapon);
		}
	}
}

cloneDespawn()
{
	self notify("clone");
	if (isDefined(self.clone))
		self.clone delete();
}

clone()
{
	self notify("clone");
	wait 0.05;
	self endon("disconnect");
	self endon("clone");

	while (true)
	{
		if (isDefined(self))
		{
			self.clone = self clonePlayer(10);
        	self.clone.origin = self.origin;
        	self.clone.angles = self.angles;
		}
        wait 0.05;
    }
}

fortniteDance()
{
	self endon("disconnect");
	self endon("death");

	weapon = self getCurrentWeapon();
	self giveWeapon("fortnite_mp");
	self switchToWeapon("fortnite_mp");

	wait 0.2;

	self setClientDvar("cg_thirdperson", 1);
	self setClientDvar("cg_thirdpersonangle", 180);

	wait 7;

	self takeWeapon("fortnite_mp");
	self switchToWeapon(weapon);
	self setClientDvar("cg_thirdperson", 0);
	self setClientDvar("cg_thirdpersonangle", 0);
}

trooper()
{
	self endon("death");
	self endon("disconnect");

	wait 2;

	while (true)
	{
		playFxOnTag(level.fx["jetpack"], self, "tag_jetpack_l");
		playFxOnTag(level.fx["jetpack"], self, "tag_jetpack_r");
		wait 3;
	}
}

unlimitedAmmo()
{
	self endon("death");
	self endon("disconnect");

	while (isDefined(self))
	{
		self SetWeaponAmmoClip(self GetCurrentWeapon(),
			WeaponClipSize(self GetCurrentWeapon()));
		wait 0.05;
	}
}
