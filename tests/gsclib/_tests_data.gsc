#include sr\tests\gsclib\_main;

// Tests for gsclib/data
test()
{
	comPrintF("\n[======{Data}======]\n");

	level.MYSQL_TYPE_DECIMAL      = 0;
	level.MYSQL_TYPE_TINY         = 1;
	level.MYSQL_TYPE_SHORT        = 2;
	level.MYSQL_TYPE_LONG         = 3;
	level.MYSQL_TYPE_FLOAT        = 4;
	level.MYSQL_TYPE_DOUBLE       = 5;
	level.MYSQL_TYPE_NULL         = 6;
	level.MYSQL_TYPE_TIMESTAMP    = 7;
	level.MYSQL_TYPE_LONGLONG     = 8;
	level.MYSQL_TYPE_INT24        = 9;
	level.MYSQL_TYPE_DATE         = 10;
	level.MYSQL_TYPE_TIME         = 11;
	level.MYSQL_TYPE_DATETIME     = 12;
	level.MYSQL_TYPE_YEAR         = 13;
	level.MYSQL_TYPE_NEWDATE      = 14;
	level.MYSQL_TYPE_VARCHAR      = 15;
	level.MYSQL_TYPE_BIT          = 16;
	level.MYSQL_TYPE_TIMESTAMP2   = 17;
	level.MYSQL_TYPE_DATETIME2    = 18;
	level.MYSQL_TYPE_TIME2        = 19;
	level.MYSQL_TYPE_JSON         = 245;
	level.MYSQL_TYPE_NEWDECIMAL   = 246;
	level.MYSQL_TYPE_ENUM         = 247;
	level.MYSQL_TYPE_SET          = 248;
	level.MYSQL_TYPE_TINY_BLOB    = 249;
	level.MYSQL_TYPE_MEDIUM_BLOB  = 250;
	level.MYSQL_TYPE_LONG_BLOB    = 251;
	level.MYSQL_TYPE_BLOB         = 252;
	level.MYSQL_TYPE_VAR_STRING   = 253;
	level.MYSQL_TYPE_STRING       = 254;
	level.MYSQL_TYPE_GEOMETRY     = 255;

	// it_RegexMatch();
	// it_RegexReplace();
	// it_RegexSplit();
	
	// it_SQL_Version();
	// it_SQL_Connect();

	// it_SQL_SelectDB();
	// it_SQL_ListDB();
	// it_SQL_ListTables();

	// it_SQL_Query();
	// it_SQL_AffectedRows();
	// it_SQL_NumRows();
	// it_SQL_NumFields();
	// it_SQL_FetchFields();
	// it_SQL_FetchRowDict();
	// it_SQL_FetchRow();
	// it_SQL_FetchRowsDict();
	// it_SQL_FetchRows();

	// it_SQL_PrepareBindParam();
	it_SQL_PrepareBindResult();
	it_SQL_Execute();
	it_SQL_FetchRow();

	// it_SQL_HexString();
	// it_SQL_EscapeString();
	// it_SQL_Close();
}

it_SQL_PrepareBindResult()
{
	comPrintF("\n<-------[SQL_Prepare SQL_BindResult]------->\n");
	printVariable(SQL_Prepare("SELECT name, guid FROM speedrun_ranks"));
	// SQL_BindParam("Iswenzz", level.MYSQL_TYPE_VAR_STRING);
	SQL_BindResult(level.MYSQL_TYPE_VAR_STRING, 60);
	SQL_BindResult(level.MYSQL_TYPE_VAR_STRING, 60);
	// SQL_BindResult(level.MYSQL_TYPE_LONG);
	// SQL_BindResult(level.MYSQL_TYPE_LONG);
	// SQL_BindResult(level.MYSQL_TYPE_LONG);
}

it_SQL_PrepareBindParam()
{
	comPrintF("\n<-------[SQL_Prepare SQL_BindParam]------->\n");
	printVariable(SQL_Prepare("INSERT INTO speedrun_ranks (name, guid, xp, rank, prestige) VALUES (?, ?, ?, ?, ?)"));
	SQL_BindParam("Iswenzz", level.MYSQL_TYPE_VAR_STRING);
	SQL_BindParam("313354b4", level.MYSQL_TYPE_VAR_STRING);
	SQL_BindParam("1296000", level.MYSQL_TYPE_LONG);
	SQL_BindParam("80", level.MYSQL_TYPE_LONG);
	SQL_BindParam("10", level.MYSQL_TYPE_LONG);
	SQL_Execute();
}

it_SQL_Execute()
{
	comPrintF("\n<-------[SQL_Execute]------->\n");
	printVariable(SQL_Execute());
}

it_SQL_HexString()
{
	comPrintF("\n<-------[SQL_HexString]------->\n");
	printVariable(SQL_HexString("Iswenzz"));
}

it_SQL_EscapeString()
{
	comPrintF("\n<-------[SQL_EscapeString]------->\n");
	printVariable(SQL_EscapeString("\\"));
}

it_SQL_AffectedRows()
{
	comPrintF("\n<-------[SQL_AffectedRows]------->\n");
	printVariable(SQL_AffectedRows());
}

it_SQL_Query()
{
	comPrintF("\n<-------[SQL_Query]------->\n");
	printVariable(SQL_Query("SELECT * FROM speedrun_ranks"));
}

it_SQL_FetchFields()
{
	comPrintF("\n<-------[SQL_FetchFields]------->\n");
	printArray(SQL_FetchFields());
}

it_SQL_FetchRow()
{
	comPrintF("\n<-------[SQL_FetchRow]------->\n");
	printArray(SQL_FetchRow());
}

it_SQL_FetchRows()
{
	comPrintF("\n<-------[SQL_FetchRows]------->\n");

	rows = SQL_FetchRows();
	if (isDefined(rows) && isDefined(rows.size))
	{
		for (i = 0; i < rows.size; i++)
			printArray(rows[i]);
	}
}

it_SQL_FetchRowDict()
{
	comPrintF("\n<-------[SQL_FetchRowDict]------->\n");
	printArrayKeys(SQL_FetchRow());
}

it_SQL_FetchRowsDict()
{
	comPrintF("\n<-------[SQL_FetchRowsDict]------->\n");

	rows = SQL_FetchRowsDict();
	if (isDefined(rows) && isDefined(rows.size))
	{
		for (i = 0; i < rows.size; i++)
			printArrayKeys(rows[i]);
	}
}

it_SQL_NumFields()
{
	comPrintF("\n<-------[SQL_NumFields]------->\n");
	printVariable(SQL_NumFields());
}

it_SQL_NumRows()
{
	comPrintF("\n<-------[SQL_NumRows]------->\n");
	printVariable(SQL_NumRows());
}

it_SQL_SelectDB()
{
	comPrintF("\n<-------[SQL_SelectDB]------->\n");
	printVariable(SQL_SelectDB("sr"));
}

it_SQL_ListDB()
{
	comPrintF("\n<-------[SQL_ListDB]------->\n");
	printArray(SQL_ListDB());
}

it_SQL_ListTables()
{
	comPrintF("\n<-------[SQL_ListTables]------->\n");
	printArray(SQL_ListTables());
}

it_SQL_Version()
{
	comPrintF("\n<-------[SQL_Version]------->\n");
	printVariable(SQL_Version());
}

it_SQL_Connect()
{
	comPrintF("\n<-------[SQL_Connect]------->\n");
	printVariable(SQL_Connect("127.0.0.1", 3306, "root", "rootpassword"));
}

it_SQL_Close()
{
	comPrintF("\n<-------[SQL_Close]------->\n");
	printVariable(SQL_Close());
}

it_RegexMatch()
{
	comPrintF("\n<-------[RegexMatch]------->\n");
	printArray(RegexMatch("zzzz123affff12345ffffb", "\\d+"));
}

it_RegexSplit()
{
	comPrintF("\n<-------[RegexSplit]------->\n");
	printArray(RegexSplit("zzzz123affff12345ffffb", "\\d+"));
}

it_RegexReplace()
{
	comPrintF("\n<-------[RegexReplace]------->\n");
	printVariable(RegexReplace("zzzz123affff12345ffffb", "", "\\d+"));
}
