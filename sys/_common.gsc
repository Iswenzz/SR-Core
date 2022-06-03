// TODO: Remove this legacy file.

//Add lines to a file
WriteToFile(path, string)
{
	checkQueue();
	iPrintLnBold(path);
	file = FS_FOpen(path, "append");
	level.openFiles++;
	FS_WriteLine(file, string);
	FS_FClose(file);
	level.openFiles--;
	return true;

}

//read all lines in a file and return in an array
readAll(a)
{
	checkQueue();
	file = FS_FOpen(a, "read");
	level.openFiles++;

	array = [];
	while (true)
	{
		line = FS_ReadLine(file);
		if (isDefined(line))
			array[array.size] = line;
		else
			break;
	}
	FS_FClose(file);
	level.openFiles--;

	return array;
}

//delete a file
deleteFile(a)
{
	FS_Remove(a);
}

//delete a file late
deleteFile_late(a)
{
	wait 2;
	FS_Remove(a);
}

//check how many files are open
checkQueue()
{
	if (!isDefined(level.openFiles))
		level.openFiles = 0;

	while (level.openFiles > 8)
		wait .05;
}

//check files exists
checkfile(a)
{
	file = FS_TestFile(a);
	return file;
}
