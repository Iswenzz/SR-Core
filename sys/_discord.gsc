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

	webhook("reports", level.envs["DISCORD_REPORTS"]);
	webhook("admins", level.envs["DISCORD_ADMINS"]);
}

json()
{
	level.discord["json"]["embed"] = FILE_ReadAll(PATH_Mod("sr/data/files/discord/embed.json"));
}

template(id)
{
	return IfUndef(level.discord["json"][id], "");
}

// An unset id leaves the webhook unregistered, which disables it at the call sites.
webhook(name, id)
{
	if (IsNullOrEmpty(id))
	{
		comPrintLn(fmt("Discord webhook '%s' is not configured", name));
		return;
	}
	level.discord["webhooks"][name] = spawnStruct();
	level.discord["webhooks"][name].name = name;
	level.discord["webhooks"][name].url = fmt("https://discord.com/api/webhooks/%s", id);
}

embed(webhook, title, message)
{
	hook = level.discord["webhooks"][webhook];
	if (!isDefined(hook))
		return;

	json = fmt(template("embed"), level.discord["color"], title, message, level.discord["icon"]);

	critical_enter("http");

	request = HTTP_Init();
	HTTP_JSON(request);

	HTTP_Post(request, json, hook.url);
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}

image(webhook, title, message, image)
{
	if (!EndsWith(image, ".jpg") && !EndsWith(image, ".png") && !EndsWith(image, ".gif"))
		return;

	hook = level.discord["webhooks"][webhook];
	if (!isDefined(hook))
		return;

	json = fmt(template("embed"), level.discord["color"], title, message, "");

	critical_enter("http");

	request = HTTP_Init();
	HTTP_JSON(request);
	HTTP_Post(request, json, hook.url);
	AsyncWait(request);
	HTTP_Free(request);

	request = HTTP_Init();
	HTTP_AddHeader(request, "Content-Type: multipart/form-data");
	HTTP_Verbose(request);
	HTTP_PostFile(request, image, hook.url);
	AsyncWait(request);
	HTTP_Free(request);

	critical_release("http");
}
