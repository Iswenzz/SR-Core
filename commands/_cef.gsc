#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\sys\_http;
#include sr\utils\_common;

main()
{
	cmd("member",		"screen",			::cmd_Screen);
	cmd("member",		"video",			::cmd_Video);
	cmd("member",		"pause",			::cmd_Pause);
	cmd("member",		"seek",				::cmd_Seek);
	cmd("member",		"short",			::cmd_Short);
	cmd("member",		"short_next",		::cmd_ShortNext);
	cmd("member",		"short_prev",		::cmd_ShortPrev);
	cmd("owner",		"cef",				::cmd_CEF);
}

cmd_Screen(args)
{
	angles = self getPlayerAngles();
	model = spawn("script_model", self.origin + (0, 0, 100));
	model.targetname = "spawned_model";
	model.angles = (180, 180 + (90 + angles[1]), 0);
	model setModel("x_screen");
}

cmd_Video(args)
{
	if (args.size < 1)
		return self pm("Usage: !video <id>");

	id = args[0];

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/video/youtube?id=%s", id));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Pause(args)
{
	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", "http://localhost:9000/api/video/pause");
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Seek(args)
{
	if (args.size < 1)
		return self pm("Usage: !seek <time>");

	time = args[0];

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/video/seek?time=%s", time));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Short(args)
{
	if (args.size < 1)
		return self pm("Usage: !short <keywords> (separated by comma)");

	keywords = args[0];

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/shorts/youtube?keywords=%s", keywords));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_ShortNext(args)
{
	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", "http://localhost:9000/api/shorts/next");
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_ShortPrev(args)
{
	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", "http://localhost:9000/api/shorts/prev");
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_CEF(args)
{
	url = args[0];

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] clientCmd(fmt("cef_url %s", url));
}
