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
	level.gpt["json"]["completions"] = FILE_OpenJSON(PATH_Mod("sr/data/json/gpt/completions.json"));
}

template(id)
{
	return IfUndef(level.gpt["json"][id], "");
}

completions(message)
{
	message(fmt("^5[Prompt]^7 %s: %s", self.name, message));

	critical_enter("http");

	url = "https://api.openai.com/v1/completions";
	json = fmt(template("completions"), message);

	request = HTTP_Init();
	HTTP_JSON(request);
	CURL_AddHeader(request, fmt("Authorization: Bearer %s", level.envs["API_GPT"]));

	HTTP_Post(request, json, url);
	status = AsyncWait(request);
	response = HTTP_Response(request);
	HTTP_Free(request);

	start = stringIndex(response, "\"text\"");
	end = stringIndex(response, "\"index\"");
	if (start != -1) start += 8;
	if (end != -1) end -= 2;

	critical_release("http");

	if (status != 2 || start == -1 || end == -1)
	{
		message("^1[GPT] Error");
		return;
	}

	response = getSubStr(response, start, end);
	while (isSubStr(response, "\\n"))
		response = Replace(response, "\\n", "");

	chunks = stringChunk(response, 128);
	for (i = 0; i < chunks.size; i++)
		message(fmt("^2[GPT] ^7%s", chunks[i]));
}
