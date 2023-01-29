#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("practise");

	event("spawn", ::practise);
}

practise()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!IsInMode("practise"))
		return;

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^5Practise Mode");
	self.practise = IfUndef(self.practise, []);

	wait 0.05;

	self thread watchSave();
	self thread watchLoad();
}

watchSave()
{
	self endon("disconnect");
	self endon("death");

	while (true)
	{
		if (self meleeButtonPressed())
		{
			if (self isOnGround() && !self isMantling() && !self isOnLadder())
			{
				self.practise["origin"] = self getOrigin();
				self.practise["angle"] = self getPlayerAngles();
				self iPrintLn("^2Position saved");
				wait 0.2;
			}
		}
		wait 0.05;
	}
}

watchLoad()
{
	self endon("disconnect");
	self endon("death");

	while (true)
	{
		if (self useButtonPressed())
		{
			if (!isDefined(self.practise["origin"]) || !isDefined(self.practise["angle"]))
			{
				self iPrintLn("^1No position saved");
				wait 0.2;
				continue;
			}

			self freezeControls(1);
			self SetOrigin(self.practise["origin"]);
			self SetPlayerAngles(self.practise["angle"]);
			self iPrintLn("^5Position loaded");
			wait 0.05;
			self freezeControls(0);
			wait 0.2;
		}
		wait 0.05;
	}
}
