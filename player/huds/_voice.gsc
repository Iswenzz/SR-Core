#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	event("spawn", ::onConnect);

	precacheHeadIcon("headicon_voice");
	precacheShader("voice_on");
}

onConnect()
{
	self endon("disconnect");

	while (true)
	{
		isVoiceChatting = self VoiceChatButtonPressed();

		if (self.headicon != "headicon_voice")
			self.prevHeadicon = self.headicon;
		self.headicon = Ternary(isVoiceChatting, "headicon_voice", self.prevHeadicon);

		wait 0.05;
	}
}
