main()
{
	cmd("masteradmin", 	"bounce",		::cmd_Bounce);
	cmd("owner", 		"clone",		::cmd_Clone);
	cmd("owner", 		"damage"		::cmd_Damage);
	cmd("admin", 		"dance",		::cmd_Dance);
	cmd("adminplus", 	"drop",			::cmd_Drop);
	cmd("adminplus", 	"flash",		::cmd_Flash);
	cmd("owner", 		"g_gravity",	::cmd_G_Gravity);
	cmd("owner", 		"g_speed",		::cmd_G_Speed);
	cmd("owner", 		"god",			::cmd_God);
	cmd("owner", 		"jetpack",		::cmd_Jetpack);
	cmd("admin",        "kill"			::cmd_Kill);
	cmd("owner", 		"knockback",	::cmd_Knockback);
	cmd("owner", 		"model",		::cmd_Model);
	cmd("owner", 		"noclip",		::cmd_NoClip);
	cmd("masteradmin", 	"sr_freeze",	::cmd_Freeze);
	cmd("masteradmin", 	"sr_unfreeze",	::cmd_UnFreeze);
	cmd("adminplus", 	"shock",		::cmd_Shock);
	cmd("masteradmin", 	"shovel",		::cmd_Shovel);
	cmd("player", 		"stopmusic",	::cmd_StopMusic);
	cmd("adminplus", 	"takeall"		::cmd_TakeAll);
	cmd("owner", 		"uammo",		::cmd_UAmmo);
	cmd("adminplus", 	"weapon",		::cmd_Weapon);
	cmd("adminplus", 	"weapon_all",	::cmd_WeaponAll);
	cmd("adminplus", 	"weapon_acti",	::cmd_WeaponActi);
}
