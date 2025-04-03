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

	self.practise = IfUndef(self.practise, []);

	self thread watchSave();
	self thread watchLoad();

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^5Practise");
}

watchSave()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		if (self meleeButtonPressed())
		{
			self.practise["origin"] = self getOrigin();
			self.practise["angles"] = self getPlayerAngles();
			self.practise["velocity"] = self getVelocity();
			self.practise["flags"] = self pmFlags();
			self iPrintLn("^2Position saved");
			wait 0.2;
		}
		wait 0.05;
	}
}

watchLoad()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		if (self useButtonPressed())
		{
			if (!isDefined(self.practise["origin"]) || !isDefined(self.practise["angles"]))
			{
				self iPrintLn("^1No position saved");
				wait 0.2;
				continue;
			}
			self setOrigin(self.practise["origin"]);
			self setPlayerAngles(self.practise["angles"]);
			self setVelocity(self.practise["velocity"]);
			self setPmFlags(self.practise["flags"]);
			self iPrintLn("^5Position loaded");
			wait 0.2;
		}
		wait 0.05;
	}
}
