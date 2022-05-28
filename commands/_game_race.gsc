main()
{
    cmd("member", 	"race",			::cmd_Race);
    cmd("admin", 	"race_trig",	::cmd_RaceTrig);
	cmd("admin", 	"race_spawn",	::cmd_RaceSpawn);
	cmd("owner", 	"race_mk",		::cmd_RaceMk);
	cmd("owner", 	"race_save",	::cmd_RaceSave);
}
