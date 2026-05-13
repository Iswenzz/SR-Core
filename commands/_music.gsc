#include sr\sys\_admins;
#include sr\sys\_file;
#include sr\utils\_common;

main()
{
	cmd("adminplus", 	"music", 		::cmd_Music);
	cmd("adminplus", 	"music_seq", 	::cmd_MusicSequence);
	cmd("adminplus", 	"music_help", 	::cmd_MusicHelp);
	cmd("player", 		"music_stop", 	::cmd_MusicStop);
	cmd("owner",  		"radio",		::cmd_Radio);
	cmd("adminplus",	"soundalias", 	::cmd_SoundAlias);
}

cmd_Radio(args)
{
	if (args.size < 1)
		return self pm("Usage: radio <file> (.wav/.mp3)");

	if (args[0] == "stop")
	{
		self pm("^1Radio stop");
		RadioPlay("stop", "null");
		return;
	}

	toks = strTok(args[0], ".");
	if (toks.size != 2)
		return self pm("^1Wrong file name.");

	file = fmt("%s.%s", toks[0], toks[1]);
	type = toks[1];

	path = PathJoin(level.directories["downloads"], file);
	self pm(fmt("^3Playing %s", file));

	RadioPlay(path, type);
}

cmd_MusicSequence(args)
{
	if (args.size < 1)
		return self pm("Usage: music_seq <name>");

	name = args[0];

	level thread sr\core\_music::playSequence(name);
}

cmd_Music(args)
{
	if (args.size < 1)
		return self pm("Usage: music <name>");

	name = args[0];
	sr\core\_music::playAmbient(name);
}

cmd_MusicHelp(args)
{
	aliases = StrJoin(getArrayKeys(level.music_ambient), ", ");
	aliases = strTokByPixLen(aliases, 500);

	self pm("Music aliases:");
	for (i = 0; i < aliases.size; i++)
		self pm(aliases[i]);
}

cmd_MusicStop(args)
{
	self clientcmd("snd_stopambient");
}

cmd_SoundAlias(args)
{
	aliases = SoundAlias();
	for (i = 0; i < aliases.size; i++)
	{
		self pm(aliases[i]);
		wait 0.05;
	}
}
