#include sr\libs\gscunit\_main;
#include sr\libs\gscunit\_utils;

runTests()
{
    setup();

    sr\libs\gsclib\__test__\_suite::gsclib();

	summarize(true);
}

setup()
{
	gscunitEnv();

	if (!level.gscunit.enabled)
		return;

	spawnBots(5);
	level.tests = spawnStruct();
	level.tests.ftp = true;
	level.tests.sftp = true;
	level.tests.mysql = true;
}
