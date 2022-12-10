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

	self hud();

	while (true)
	{
		isVoiceChatting = self VoiceChatButtonPressed();

		self.huds["voice"].alpha = isVoiceChatting;
		self.headicon = Ternary(isVoiceChatting, "voice_on", self.headicon);

		wait 0.05;
	}
}

hud()
{
	self.huds["voice"] = addHud(self, 5, -5, 0, "left", "bottom", 1.4);
	self.huds["voice"] setShader("voice_on", 32, 32);
}
