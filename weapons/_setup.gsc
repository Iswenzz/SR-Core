#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

main()
{
	thread sr\weapons\_portal_gun::main();
	thread sr\weapons\_portal_turret::main();
	thread sr\weapons\_bullettrace::main();
}

self_setup()
{
	self thread sr\weapons\_portal_gun::portal_stuff();
	self thread sr\weapons\_bullettrace::bt_check();
}