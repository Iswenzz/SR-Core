main()
{
	sr\game\_hud::main();
	sr\sys\_file::main();
    sr\sys\_mysql::main();

    sr\tests\_main::runTests();
}

onConnect()
{
	self endon("disconnect");

	self thread sr\game\_hud::event();
	self thread sr\sys\_menu::event();
}

onSpawn()
{
	self endon("disconnect");
}
