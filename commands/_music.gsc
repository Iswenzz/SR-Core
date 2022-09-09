#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	level.sr_music = [];

	// Commands
	cmd("adminplus", 	"music", 		::cmd_Music);
	cmd("masteradmin", 	"music_seq", 	::cmd_MusicSequence);
	cmd("owner", 		"music_seqend", ::cmd_MusicSequenceEnd);
	cmd("adminplus", 	"music_help", 	::cmd_MusicHelp);
	cmd("player", 		"music_stop", 	::cmd_MusicStop);

	// Musics
	add("dame_tu_cosita");
	add("ways_to_die");
	add("this_is_minecraft");
	add("stal");
	add("fn_despacito");
	add("oof");
	add("mc");
	add("doot");
	add("despacito");
	add("dead");
	add("delfino");
	add("ninja");
	add("poopy");
	add("wii");
	add("ricardo");
	add("fishe");
	add("tense");
	add("cow");
	add("polish");
	add("minion");
}

cmd_MusicSequenceEnd(args)
{
	if (args.size < 1)
		return self pm("Usage: music_seqend <name>");

	name = args[0];

	sr\game\music\_main::stop();
	thread sr\game\_map::end();
	thread sr\game\music\_main::play(name);
}

cmd_MusicSequence(args)
{
	if (args.size < 1)
		return self pm("Usage: music_seq <name>");

	name = args[0];

	sr\game\music\_main::stop();
	thread sr\game\music\_main::play(name);
}

cmd_Music(args)
{
	if (args.size < 1)
		return self pm("Usage: music <name>");

	name = args[0];
	play(name);
}

cmd_MusicHelp(args)
{
	aliases = StrJoin(getArrayKeys(level.sr_music), ", ");
	aliases = strTokByPixLen(aliases, 500);

	self pm("Music aliases:");
	for (i = 0; i < aliases.size; i++)
		self pm(aliases[i]);
}

cmd_MusicStop(args)
{
	self clientcmd("snd_stopambient");
}

play(name)
{
	stop();

	if (name == "stop")
		return;

	AmbientPlay(IfUndef(level.sr_music[name], name), 2);
}

stop()
{
	AmbientStop(2);
}

add(name)
{
	index = level.sr_music.size + 1;
	level.sr_music[name] = fmt("srm%d", index);
}
