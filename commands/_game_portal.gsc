main()
{
	cmd("owner", 	"detonate",			::cmd_Detonate);
    cmd("owner", 	"turret",			::cmd_Turret);
	cmd("owner", 	"turret_delete"		::cmd_TurretDelete);
}
