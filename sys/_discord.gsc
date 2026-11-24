#include sr\sys\_events;
#include sr\sys\_http;
#include sr\sys\_file;

initDiscord()
{
	level.discord = [];
	level.discord["icon"] = "https://sr-speedrun.com/images/logo.jpg";
	level.discord["token"] = level.envs["DISCORD_TOKEN"];
	level.discord["channels"] = [];
	level.discord["json"] = [];
	level.discord["json"]["record"] = FILE_ReadAll(PATH_Mod("sr/data/files/discord/record.json"));

	channel("feed", level.envs["DISCORD_FEED"]);
}

template(id)
{
	return IfUndef(level.discord["json"][id], "");
}

channel(name, id)
{
	if (IsNullOrEmpty(level.discord["token"]) || IsNullOrEmpty(id))
	{
		comPrintLn(fmt("Discord channel '%s' is not configured", name));
		return;
	}
	level.discord["channels"][name] = fmt("https://discord.com/api/v10/channels/%s/messages", id);
}

send(name, json)
{
	url = level.discord["channels"][name];
	if (!isDefined(url))
		return undefined;

	critical_enter("http");

	request = HTTP_Init();
	HTTP_JSON(request);
	HTTP_AddHeader(request, fmt("Authorization: Bot %s", level.discord["token"]));
	HTTP_AddHeader(request, "User-Agent: DiscordBot (https://sr-speedrun.com, 1.0)");
	HTTP_Post(request, json, url);
	AsyncWait(request);
	response = HTTP_Response(request);
	HTTP_Free(request);

	critical_release("http");
	return response;
}
