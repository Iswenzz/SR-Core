main()
{
	sr\sys\_events::initEvents();
	sr\sys\_file::initFile();
    sr\sys\_mysql::initMySQL();

	sr\game\_rank::initRank();
	sr\player\_id::initId();
	sr\player\customize\_main::initCustomize();

    sr\_tests::runTests();
}
