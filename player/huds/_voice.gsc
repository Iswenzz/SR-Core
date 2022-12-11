#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	event("spawn", ::onConnect);

	precacheHeadIcon("voice_on");
	precacheShader("voice_on");
}

onConnect()
{
	self endon("disconnect");

	while (true)
	{
		isVoiceChatting = self VoiceChatButtonPressed();
		self.headicon = Ternary(isVoiceChatting, "voice_on", self.headicon);

		wait 0.05;
	}
}
