#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\sys\_http;
#include sr\utils\_common;

main()
{
	cmd("cef",        "owner",  ::cmd_CEF,             "Set the CEF URL");
	cmd("next",       "member", ::cmd_Next,            "Skip to the next media");
	cmd("pause",      "member", ::cmd_Pause,           "Pause the current media");
	cmd("playlist",   "member", ::cmd_Playlist,        "Play a playlist");
	cmd("prev",       "member", ::cmd_Prev,            "Go to the previous media");
	cmd("screen",     "member", ::cmd_Screen,          "Spawn a screen");
	cmd("seek",       "member", ::cmd_Seek,            "Seek to a position in the media");
	cmd("shorts",     "member", ::cmd_Shorts,          "Start youtube shorts");
	cmd("tg_channel", "member", ::cmd_TelegramChannel, "Play a media from a Telegram channel");
	cmd("tg_video",   "member", ::cmd_TelegramVideo,   "Play a specific Telegram video");
	cmd("video",      "player", ::cmd_Video,           "Play a video");
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
	ifEnded = Ternary(self.admin_role == "player", "&ifEnded=true", "");

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/youtube/video?id=%s%s", id, ifEnded));
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

cmd_TelegramChannel(args)
{
	if (args.size < 1)
		return self pm("Usage: !tg_channel <name>");

	name = args[0];

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/telegram/channel?name=%s", name));
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

cmd_TelegramVideo(args)
{
	if (args.size < 1)
		return self pm("Usage: !tg_video <messageId>");

	messageId = args[0];

	critical_enter("http");

	request = HTTP_Init();
	HTTP_Post(request, "", fmt("http://localhost:9000/api/telegram/video?messageId=%s", messageId));
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
	time = Replace(time, "+", "p");
	time = Replace(time, "-", "n");

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
