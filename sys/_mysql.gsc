#include sr\sys\_events;

initMySQL()
{
	SQL_Connect("192.168.1.86", 3306, "root", "rootpassword");
	SQL_SelectDB("speedrun");

	mutex("mysql");

    variables();
}

variables()
{
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
	level.MYSQL_TYPE_STRING       = 253;
	level.MYSQL_TYPE_TEXT         = 254;
	level.MYSQL_TYPE_GEOMETRY     = 255;
}
