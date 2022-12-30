#include sr\sys\_events;

initHTTP()
{
	critical("http");
}

HTTP_JSON(http)
{
	CURL_AddHeader(http, "Accept: application/json");
	CURL_AddHeader(http, "Content-Type: application/json");
}
