#include sr\sys\_events;

initDiscord()
{
	level.discord = [];
	level.discord["icon"] = "https://cdn.discordapp.com/icons/335075122467700740/8152834be097199cff8d46a2ae1e5588.png";
	level.discord["color"] = 10753784;
	level.discord["webhooks"] = [];

	webhook("SR", "768027900841689108/Z2BNqAwA2kXmr98JyhJWo7wSr1OOoRKgrVa04kA3zxUcFCQjKMyjiiqzHhzdwBDKyAYs");
}

webhook(name, id)
{
	level.discord["webhooks"][name] = spawnStruct();
	level.discord["webhooks"][name].name = name;
	level.discord["webhooks"][name].url = fmt("https://discord.com/api/webhooks/%s", id);
}

webhookEmbed(webhook, title, message)
{
	hook = level.discord["webhooks"][webhook];
	json = fmt("{ \"embeds\": [{ \"color\": %d, \"title\": \"%s\", \"description\": \"%s\", \"thumbnail\": { \"url\": \"%s\" } }] }",
		level.discord["color"], title, message, level.discord["icon"]);

	mutex_acquire("curl");

	CURL_AddOpt(41, 1);
	sr\sys\_curl::json();
	response = HTTPS_PostString(json, hook.url);

	mutex_release("curl");
}
