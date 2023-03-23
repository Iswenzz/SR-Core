#include sr\sys\_events;

initHTTP()
{
	critical("http");
}

HTTP_Verbose(http)
{
	CURL_AddOpt(http, 41, 1);
}

HTTP_JSON(http)
{
	CURL_AddHeader(http, "Accept: application/json");
	CURL_AddHeader(http, "Content-Type: application/json");
}
