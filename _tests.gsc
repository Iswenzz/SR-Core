#include sr\libs\gscunit\_main;
#include sr\libs\gscunit\_utils;

runTests()
{
    if (!setup())
		return;

    sr\libs\gsclib\__test__\_suite::gsclib();

	summarize(true);
}

setup()
{
	gscunitEnv();

	level.tests = spawnStruct();
	level.tests.ftp = true;
	level.tests.sftp = true;
	level.tests.mysql = true;

	return level.gscunit.enabled;
}
