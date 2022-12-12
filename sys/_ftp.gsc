#include sr\sys\_events;

initFTP()
{
	mutex("ftp");
}

FTP_Wait(request)
{
	status = FTP_Status(request);
	while (status <= 1)
	{
		wait 0.05;
		status = FTP_Status(request);
	}
	return status;
}
