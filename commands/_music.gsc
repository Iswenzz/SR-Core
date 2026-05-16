#include sr\sys\_admins;
#include sr\sys\_file;
#include sr\utils\_common;

main()
{
	cmd("music_help", "adminplus", ::cmd_MusicHelp,     "List the music aliases");
	cmd("music_seq",  "adminplus", ::cmd_MusicSequence, "Play a music sequence");
	cmd("music_stop", "player",    ::cmd_MusicStop,     "Stop the current track");
	cmd("music",      "adminplus", ::cmd_Music,         "Play a music track");
	cmd("radio",      "owner",     ::cmd_Radio,         "Start a radio stream");
	cmd("soundalias", "adminplus", ::cmd_SoundAlias,    "List the sound aliases");
}

cmd_Radio(args)
{
	if (args.size < 1)
		return self pm("Usage: !radio <file> (.wav/.mp3)");

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
		return self pm("Usage: !music_seq <name>");

	name = args[0];

	level thread sr\core\_music::playSequence(name);
}

cmd_Music(args)
{
	if (args.size < 1)
		return self pm("Usage: !music <name>");

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
	aliases = [];
	soundaliases = SoundAlias();
	excluded = strTok("end_map;end_round;srm;music_mainmenu;last_alive;first_blood;wtf", ";");

	for (i = 0; i < soundaliases.size; i++)
    {
        skip = false;
        for (j = 0; j < excluded.size; j++)
            if (StartsWith(soundaliases[i], excluded[j]))
				skip = true;

        if (!skip)
            aliases[aliases.size] = soundaliases[i];
    }
	self pm(fmt("^5%d aliases", aliases.size));
	for (i = 0; i < aliases.size; i++)
	{
		self pm(aliases[i]);
		wait 0.05;
	}
}
