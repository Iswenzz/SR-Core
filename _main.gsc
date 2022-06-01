main()
{
	sr\sys\_events::initEvents();
	sr\sys\_file::initFile();
	sr\sys\_hud::initHud();
	sr\sys\_menu::initMenu();
    sr\sys\_mysql::initMySQL();
	sr\sys\_rank::initRank();

	sr\player\customize\_main::initCustomize();

    sr\tests\_main::runTests();
}
