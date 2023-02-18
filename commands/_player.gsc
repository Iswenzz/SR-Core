#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("masteradmin", 	"angles",			::cmd_Angles);
	cmd("masteradmin", 	"bounce",			::cmd_Bounce);
	cmd("owner", 		"bullet",			::cmd_Bullet);
	cmd("owner", 		"clone",			::cmd_Clone);
	cmd("owner", 		"debug",			::cmd_Debug);
	cmd("owner", 		"damage",			::cmd_Damage);
	cmd("vip", 			"dance",			::cmd_Dance);
	cmd("adminplus", 	"drop",				::cmd_Drop);
	cmd("adminplus", 	"flash",			::cmd_Flash);
	cmd("owner", 		"g_gravity",		::cmd_G_Gravity);
	cmd("owner", 		"g_speed",			::cmd_G_Speed);
	cmd("owner", 		"god",				::cmd_God);
	cmd("owner",		"jump_height",		::cmd_JumpHeight);
	cmd("admin",        "kill",				::cmd_Kill);
	cmd("owner", 		"model",			::cmd_Model);
	cmd("masteradmin", 	"sr_freeze",		::cmd_Freeze);
	cmd("masteradmin", 	"sr_unfreeze",		::cmd_UnFreeze);
	cmd("adminplus", 	"shock",			::cmd_Shock);
	cmd("vip", 			"shovel",			::cmd_Shovel);
	cmd("masteradmin", 	"respawn",			::cmd_Respawn);
	cmd("masteradmin", 	"respawnall",		::cmd_RespawnAll);
	cmd("adminplus", 	"takeall",			::cmd_TakeAll);
	cmd("owner", 		"trooper",			::cmd_Trooper);
	cmd("admin", 		"teleport_player",	::cmd_TeleportPlayer);
	cmd("admin", 		"teleport_at",		::cmd_TeleportAt);
	cmd("admin", 		"teleport_ent",		::cmd_TeleportEnt);
	cmd("owner", 		"uammo",			::cmd_UAmmo);
	cmd("adminplus", 	"weapon",			::cmd_Weapon);
	cmd("adminplus", 	"weapon_all",		::cmd_WeaponAll);
	cmd("adminplus", 	"weapon_acti",		::cmd_WeaponActi);
}

cmd_Respawn(args)
{
	player = IfUndef(getPlayerByName(args[0]), self);
	if (!isDefined(player))
		return pm("Could not find player");

	self log();

	if (!player isPlaying())
		player respawn();
}

cmd_RespawnAll(args)
{
	self log();
	players = getDeadPlayers();

	for (i = 0; i < players.size; i++)
		players[i] respawn();
	level message("^5All players respawned.");
}

cmd_TeleportPlayer(args)
{
	if (args.size < 1)
		return self pm("Usage: teleport_player <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");
	if (!player sr\player\modes\_main::isInMode("practise"))
		return self pm("^1Player need to be in practise mode");

	player cheat();
	player setOrigin(self.origin);
}

cmd_TeleportAt(args)
{
	if (args.size < 3)
		return self pm("Usage: teleport_at <X> <Y> <Z>");
	if (!self sr\player\modes\_main::isInMode("practise"))
		return self pm("^1Player need to be in practise mode");

	x = ToFloat(args[0]);
	y = ToFloat(args[1]);
	z = ToFloat(args[2]);

	self cheat();
	self setOrigin((x, y, z));
}

cmd_TeleportEnt(args)
{
	if (args.size < 1)
		return self pm("Usage: teleport_ent <targetname>");
	if (!self sr\player\modes\_main::isInMode("practise"))
		return self pm("^1Player need to be in practise mode");

	ent = getEntArray(args[0], "targetname");
	if (!isDefined(ent) || !ent.size)
		return;

	self cheat();
	self setOrigin(ent[0].origin);
}

cmd_Angles(args)
{
	if (args.size < 4)
		return self pm("Usage: angles <player> <x> <y> <z>");

	player = getPlayerByName(args[0]);
	player cheat();

	if (!isDefined(player))
		return pm("Could not find player");

	x = ToFloat(args[1]);
	y = ToFloat(args[2]);
	z = ToFloat(args[3]);

	player setPlayerAngles((x, y, z));
}

cmd_Bounce(args)
{
	self log();
	player = IfUndef(getPlayerByName(args[0]), self);
	player cheat();
	player bounce(player.origin, vectorNormalize((0, 0, 20)), 800);
	player bounce(player.origin, vectorNormalize((0, 0, 20)), 800);
}

cmd_Bullet(args)
{
	if (isDefined(self.instantBullet))
	{
		self.instantBullet = undefined;
		self pm("^1Instant bullets");
	}
	else
	{
		self.instantBullet = true;
		self cheat();
		self pm("^2Instant bullets");
	}
}

cmd_Clone(args)
{
	if (!isDefined(self.clone))
		clone();
	else
		cloneDespawn();
}

cmd_Debug(args)
{
	if (self sr\player\modes\_main::isInOtherMode("debug"))
		return;

	self sr\player\modes\_main::toggleMode("debug");
	self suicide();

	self pm(Ternary(self.modes["debug"], "^5Debug mode enabled!", "^1Debug mode disabled!"));
}

cmd_Damage(args)
{
	self.teamKill = !self.teamKill;

	self pm(Ternary(self.teamKill, "^2Damage enabled", "^1Damage disabled"));
}

cmd_Dance(args)
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
	player cheat();

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player.gravity = value;
	player setGravity(player.gravity);
}

cmd_G_Speed(args)
{
	if (args.size < 1)
		return self pm("Usage: g_speed <value> <playerName>");

	value = ToInt(args[0]);
	player = IfUndef(getPlayerByName(args[1]), self);
	player cheat();

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player.moveSpeed = value;
	player setMoveSpeed(player.moveSpeed);
}

cmd_God(args)
{
	player = IfUndef(getPlayerByName(args[0]), self);
	player cheat();
	player.godmode = Ternary(!isDefined(player.godmode), true, undefined);
	player pm(Ternary(isDefined(player.godmode), "^3God mode enabled!", "^1God mode disabled!"));
}

cmd_JumpHeight(args)
{
	if (args.size < 1)
		return self pm("Usage: jump_height <value> <playerName>");

	value = ToInt(args[0]);
	player = IfUndef(getPlayerByName(args[1]), self);
	player cheat();

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player.jumpHeight = value;
	player setJumpHeight(player.jumpHeight);
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

cmd_Freeze(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_freeze <playerName>");

	player = getPlayerByName(args[0]);
	player cheat();

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
	player cheat();

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

cmd_Shovel(args)
{
	self giveWeapon("shovel_mp");
	self giveMaxAmmo("shovel_mp");
	wait 0.05;
	self switchToWeapon("shovel_mp");
}

cmd_TakeAll(args)
{
	if (args.size < 1)
		return self pm("Usage: takeall <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player takeAllWeapons();
}

cmd_Trooper(args)
{
	self thread trooper();
}

cmd_UAmmo(args)
{
	self thread unlimitedAmmo();
	self cheat();
}

cmd_Weapon(args)
{
	if (args.size < 2)
		return self pm("Usage: weapon <playerName> <weapon>");

	player = getPlayerByName(args[0]);
	player cheat();
	weapon = args[1];

	if (!isDefined(player))
		return pm("Could not find player");

	player giveWeapon(weapon);
	player switchToWeapon(weapon);
	wait 0.05;
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
		players[i] cheat();
		players[i] giveWeapon(weapon);
		players[i] giveMaxAmmo(weapon);
		wait 0.05;
		players[i] switchToWeapon(weapon);
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
			players[i] giveMaxAmmo(weapon);
			wait 0.05;
			players[i] switchToWeapon(weapon);
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

	while (isDefined(self))
	{
		self.clone = self clonePlayer(10);
		self.clone.origin = self.origin;
		self.clone.angles = self.angles;
        wait 0.05;
    }
}

fortniteDance()
{
	self endon("disconnect");
	self endon("death");

	weapon = self getCurrentWeapon();
	self giveWeapon("fortnite_mp");
	wait 0.05;
	self switchToWeapon("fortnite_mp");
	wait 0.2;
	self setClientDvars("cg_thirdperson", 1, "cg_thirdpersonangle", 180);
	wait 7;
	self takeWeapon("fortnite_mp");

	if (isDefined(weapon))
		self switchToWeapon(weapon);
	self setClientDvars("cg_thirdperson", 0, "cg_thirdpersonangle", 0);
}

trooper()
{
	self endon("death");
	self endon("disconnect");

	wait 2;

	while (true)
	{
		playFxOnTag(level.gfx["jetpack"], self, "tag_jetpack_l");
		playFxOnTag(level.gfx["jetpack"], self, "tag_jetpack_r");
		wait 3;
	}
}

unlimitedAmmo()
{
	self endon("death");
	self endon("disconnect");

	while (isDefined(self))
	{
		self SetWeaponAmmoClip(self GetCurrentWeapon(), WeaponClipSize(self GetCurrentWeapon()));
		wait 0.05;
	}
}
