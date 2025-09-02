#include sr\sys\_admins;
#include sr\sys\_events;
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
	cmd("owner", 		"dog",				::cmd_Dog);
	cmd("adminplus", 	"flash",			::cmd_Flash);
	cmd("owner", 		"g_gravity",		::cmd_G_Gravity);
	cmd("owner", 		"g_speed",			::cmd_G_Speed);
	cmd("owner", 		"dr_jumpers_speed",	::cmd_Dr_Jumpers_Speed);
	cmd("owner", 		"god",				::cmd_God);
	cmd("admin", 		"heal",				::cmd_Heal);
	cmd("owner",		"jump_height",		::cmd_JumpHeight);
	cmd("admin",        "kill",				::cmd_Kill);
	cmd("owner", 		"model",			::cmd_Model);
	cmd("masteradmin", 	"practise_mode",	::cmd_PractiseMode);
	cmd("masteradmin", 	"sr_freeze",		::cmd_Freeze);
	cmd("masteradmin", 	"sr_unfreeze",		::cmd_UnFreeze);
	cmd("adminplus", 	"shock",			::cmd_Shock);
	cmd("vip", 			"shovel",			::cmd_Shovel);
	cmd("masteradmin", 	"respawn",			::cmd_Respawn);
	cmd("masteradmin", 	"respawn_all",		::cmd_RespawnAll);
	cmd("adminplus", 	"team",				::cmd_Team);
	cmd("adminplus", 	"takeall",			::cmd_TakeAll);
	cmd("owner", 		"trooper",			::cmd_Trooper);
	cmd("admin", 		"teleport_player",	::cmd_TeleportPlayer);
	cmd("admin", 		"teleport_to",		::cmd_TeleportTo);
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
	message("^5All players respawned.");
}

cmd_TeleportPlayer(args)
{
	if (args.size < 1)
		return self pm("Usage: teleport_player <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player cheat();
	player setOrigin(self.origin);
}

cmd_TeleportTo(args)
{
	if (args.size < 1)
		return self pm("Usage: teleport_to <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	self cheat();
	self setOrigin(player.origin);
}

cmd_TeleportAt(args)
{
	if (args.size < 3)
		return self pm("Usage: teleport_at <X> <Y> <Z>");

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

	entity = player dropItem(player getCurrentWeapon());
	if (isDefined(entity))
		entity thread dropPickup();
}

cmd_Dog(args)
{
    self thread dog();
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

cmd_Dr_Jumpers_Speed(args)
{
	if (args.size < 1)
		return self pm("Usage: dr_jumpers_speed <value> <playerName>");

	value = ToFloat(args[0]);
	player = IfUndef(getPlayerByName(args[1]), self);
	player cheat();

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player.moveSpeedScale = value;
	player setMoveSpeedScale(player.moveSpeedScale);
}

cmd_God(args)
{
	player = IfUndef(getPlayerByName(args[0]), self);
	player cheat();
	player.godmode = Ternary(!isDefined(player.godmode), true, undefined);
	player pm(Ternary(isDefined(player.godmode), "^3God mode enabled!", "^1God mode disabled!"));
}

cmd_Heal(args)
{
	if (args.size < 1)
		return self pm("Usage: heal <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player cheat();
	player.health = player.maxhealth;
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

cmd_PractiseMode(args)
{
	if (self sr\player\modes\_main::isInOtherMode("practise"))
		return;

	self sr\player\modes\_main::toggleMode("practise");
	self suicide();

	self pm(Ternary(self.modes["practise"], "^5Practise mode enabled!", "^1Practise mode disabled!"));
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
	self giveWeapon("saw_mp");
	self giveMaxAmmo("saw_mp");
	wait 0.05;
	self switchToWeapon("saw_mp");
}

cmd_Team(args)
{
	if (args.size < 2)
		return self pm("Usage: team <playerName> <team>");

	player = getPlayerByName(args[0]);
	team = args[1];

	if (!isDefined(player))
		return pm("Could not find player");

	player sr\game\_teams::setTeam(team);
	player eventSpawn();
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
	self cheat();
	self thread unlimitedAmmo();
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

	self cheat();

	while (isDefined(self))
	{
		wait 0.05;

		weapon = self getCurrentWeapon();
		if (weapon == "none")
			continue;

		self setWeaponAmmoClip(weapon, weaponClipSize(weapon));
	}
}

dropPickup()
{
	self.cheat = true;
	while (isDefined(self))
	{
		self waittill("trigger", player);
		player cheat();
	}
}

dog()
{
	self endon("disconnect");
    self endon("death");

	self.pers["isDog"] = true;

	self giveWeapon("artillery_mp");
	self switchToWeapon("artillery_mp");

	while (true)
	{
		if (self getCurrentWeapon() != "artillery_mp" || self isOnLadder())
			self sr\game\_teams::setPlayerModel();
		else
			self setModel("german_sheperd_dog");

		wait 0.05;
	}
}
