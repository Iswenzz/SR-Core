main()
{
	sr\sys\_file::main();
    sr\sys\_mysql::main();

    sr\tests\_main::runTests();
}

event()
{
	self endon("disconnect");

	self thread sr\sys\_menu::event();
}
