#include sr\sys\_events;

initHTTP()
{
	critical("http");
}

HTTP_Verbose(http)
{
	HTTP_AddOpt(http, 41, 1);
}

HTTP_JSON(http)
{
	HTTP_AddHeader(http, "Accept: application/json");
	HTTP_AddHeader(http, "Content-Type: application/json");
}
