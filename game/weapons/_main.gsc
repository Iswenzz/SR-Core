#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

main()
{
	thread sr\game\weapons\_portal_gun::main();
	thread sr\game\weapons\_portal_turret::main();
	thread sr\game\weapons\_bullet_trace::main();
}

self_setup()
{
	self thread sr\game\weapons\_portal_gun::portal_stuff();
	self thread sr\game\weapons\_bullet_trace::bt_check();
}