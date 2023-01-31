#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	event("connect", ::onConnect);

	precacheHeadIcon("headicon_voice");
	precacheShader("voice_on");
}

onConnect()
{
	self endon("connect");
	self endon("disconnect");

	self.prevHeadicon = self.headicon;

	while (true)
	{
		self.isVoiceChatting = self VoiceChatButtonPressed();

		if (self.headicon != "headicon_voice")
			self.prevHeadicon = self.headicon;
		self.headicon = Ternary(self.isVoiceChatting, "headicon_voice", self.prevHeadicon);

		wait 0.05;
	}
}
