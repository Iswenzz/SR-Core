#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	level.sr_music = [];

	// Commands
	cmd("adminplus", 	"music", 		::cmd_Music);
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

cmd_Music(args)
{
	if (args.size < 1)
		return self pm("Usage: music <name>");

	name = args[0];
	play(name);
}

cmd_MusicHelp()
{
	aliases = getArrayKeys(level.sr_music);
	string = StrJoin(aliases, ",");

	self pm(string);
}

cmd_MusicStop()
{
	self clientcmd("snd_stopambient");
}

play(name)
{
	stop();

	if (name == "stop")
		return;

	wait 0.05;
	srm = level.sr_music[name];
	if (isDefined(srm))
		AmbientPlay(srm, 2);
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
