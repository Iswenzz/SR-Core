#include sr\sys\_events;
#include sr\sys\_http;
#include sr\sys\_file;
#include sr\utils\_common;

initGPT()
{
	level.gpt = [];
	level.gpt["json"] = [];

	json();
}

json()
{
	level.gpt["json"]["chat"] = FILE_ReadAll(PATH_Mod("sr/data/files/gpt/chat.json"));
}

template(id)
{
	return IfUndef(level.gpt["json"][id], "");
}

completions(message)
{
	message(fmt("^5[Prompt]^7 %s: %s", self.name, message));

	critical_enter("http");

	url = "https://openrouter.ai/api/v1/chat/completions";
	json = fmt(template("chat"), message);

	request = HTTP_Init();
	HTTP_JSON(request);
	CURL_AddHeader(request, fmt("Authorization: Bearer %s", level.envs["API_GPT"]));

	HTTP_Post(request, json, url);
	status = AsyncWait(request);
	response = HTTP_Response(request);
	HTTP_Free(request);

	start = stringIndex(response, "\"content\"");
	end = stringIndex(response, ",\"refusal\":null");
	if (start != -1) start += 11;

	critical_release("http");

	if (status != 2 || start == -1 || end == -1 || start > end)
	{
		message("^1[AI] Error");
		return;
	}
	response = getSubStr(response, start, end);
	while (isSubStr(response, "\\n"))
		response = Replace(response, "\\n", "");

	chunks = stringChunk(response, 128);
	for (i = 0; i < chunks.size; i++)
		message(fmt("^5[AI] ^7%s", chunks[i]));
}
