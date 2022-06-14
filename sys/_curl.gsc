#include sr\sys\_events;

initCurl()
{
	mutex("curl");
}

json()
{
	CURL_AddHeader("Accept: application/json");
	CURL_AddHeader("Content-Type: application/json");
}
