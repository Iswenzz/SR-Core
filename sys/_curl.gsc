#include sr\sys\_events;

initCURL()
{
	mutex("curl");
}

CURL_Wait(request)
{
	status = CURL_Status(request);
	while (status <= 1)
	{
		wait 0.05;
		status = CURL_Status(request);
	}
	return status;
}
