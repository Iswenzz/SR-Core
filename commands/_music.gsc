main()
{
	level.sr_music = [];

	cmd("adminplus", "music", ::cmd_Music);

	addMusic("dame_tu_cosita");
	addMusic("ways_to_die");
	addMusic("this_is_minecraft");
	addMusic("stal");
	addMusic("fn_despacito");
	addMusic("oof");
	addMusic("mc");
	addMusic("doot");
	addMusic("despacito");
	addMusic("dead");
	addMusic("delfino");
	addMusic("ninja");
	addMusic("poopy");
	addMusic("wii");
	addMusic("ricardo");
	addMusic("fishe");
	addMusic("tense");
	addMusic("cow");
	addMusic("polish");
	addMusic("minion");
}

playMusic(name)
{
	stopMusic();

	if(name == "stop")
		return;

	wait 0.05;
	srm = level.sr_music[name];
	if (isDefined(srm))
		AmbientPlay(srm, 2);
}

stopAmbient()
{
	self clientcmd("snd_stopambient");
}

stopMusic()
{
	AmbientStop(2);
}

musicHelp()
{
	aliases = getArrayKeys(level.sr_music);
	string = StrJoin(aliases, ",");

	exec(fmt("tell %d %s", self getEntityNumber(), string));
}

addMusic(name)
{
	index = level.sr_music.size + 1;
	level.sr_music[name] = fmt("srm%d", index);
}
