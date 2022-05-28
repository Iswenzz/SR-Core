main()
{
	cmd("member", 	"kz",			::cmd_Kz);
    cmd("owner", 	"kz_spawn",		::cmd_KzSpawn);
	cmd("owner", 	"kz_save"		::cmd_KzSave);
	cmd("admin", 	"kz_weapon",	::cmd_KzWeapon);
}
