#include sr\sys\_events;

initHTTP()
{
	mutex("http");
}

HTTP_Wait(request)
{
	status = HTTP_Status(request);
	while (status <= 1)
	{
		wait 0.05;
		status = HTTP_Status(request);
	}
	return status;
}

HTTP_JSON(http)
{
	CURL_AddHeader(http, "Accept: application/json");
	CURL_AddHeader(http, "Content-Type: application/json");
}
