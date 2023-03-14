#include sr\sys\_events;
#include sr\sys\_http;
#include sr\sys\_file;

initDiscord()
{
	level.discord = [];
	level.discord["icon"] = "https://cdn.discordapp.com/icons/335075122467700740/8152834be097199cff8d46a2ae1e5588.png";
	level.discord["color"] = 10753784;
	level.discord["webhooks"] = [];
	level.discord["json"] = [];

	json();

	webhook("SR", "768027900841689108/Z2BNqAwA2kXmr98JyhJWo7wSr1OOoRKgrVa04kA3zxUcFCQjKMyjiiqzHhzdwBDKyAYs");
}

json()
{
	level.discord["json"]["embed"] = FILE_OpenJSON(PATH_Mod("sr/data/json/discord/embed.json"));
}

template(id)
{
	return IfUndef(level.discord["json"][id], "");
}

webhook(name, id)
{
	level.discord["webhooks"][name] = spawnStruct();
	level.discord["webhooks"][name].name = name;
	level.discord["webhooks"][name].url = fmt("https://discord.com/api/webhooks/%s", id);
}

embed(webhook, title, message)
{
	hook = level.discord["webhooks"][webhook];
	json = fmt(template("embed"), level.discord["color"], title, message, level.discord["icon"]);

	critical_enter("http");

	request = HTTP_Init();
	HTTP_JSON(request);

	HTTP_Post(request, json, hook.url);
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}
