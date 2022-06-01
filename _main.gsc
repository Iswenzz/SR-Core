main()
{
	sr\sys\_menu::initMenu();
	sr\sys\_file::initFile();
    sr\sys\_mysql::initMySQL();
	sr\sys\_hud::initHud();
	sr\player\customize\_main::initCustomize();

    sr\tests\_main::runTests();
}

onConnect()
{
	self endon("disconnect");

	self thread sr\sys\_hud::eventHud();
	self thread sr\sys\_menu::eventMenu();
}

onSpawn()
{
	self endon("disconnect");
}
