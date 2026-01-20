#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\sys\_http;
#include sr\utils\_common;

main()
{
	cmd("member",		"screen",			::cmd_Screen);
	cmd("member",		"video",			::cmd_Video);
	cmd("member",		"shorts",			::cmd_Shorts);
	cmd("member",		"playlist",			::cmd_Playlist);
	cmd("member",		"pause",			::cmd_Pause);
	cmd("member",		"seek",				::cmd_Seek);
	cmd("member",		"next",				::cmd_Next);
	cmd("member",		"prev",				::cmd_Prev);
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
	HTTP_Post(request, "", fmt("http://localhost:9000/api/youtube/video?id=%s", id));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Shorts(args)
{
	keywords = StrJoin(args, ",");

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/youtube/shorts?keywords=%s", keywords));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Playlist(args)
{
	if (args.size < 1)
		return self pm("Usage: !playlist <id> <?page>");

	id = args[0];
	page = IfUndef(args[1], "1");

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/youtube/playlist?id=%s&page=%s", id, page));
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

cmd_Next(args)
{
	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", "http://localhost:9000/api/video/next");
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_Prev(args)
{
	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", "http://localhost:9000/api/video/prev");
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
