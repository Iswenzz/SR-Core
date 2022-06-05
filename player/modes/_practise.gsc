init()
{
	self thread watchLoad();
	self thread watchSave();
}

watchSave()
{
	self endon("disconnect");
	self endon("death");

	while (true)
	{
		if (self meleeButtonPressed() && self.sr_cheatmode)
		{
			if (self isOnGround() && !self isMantling() && !self isOnLadder())
			{
				self.sr_savePos["origin"] = self getOrigin();
				self.sr_savePos["angle"] = self getPlayerAngles();
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
		if (self useButtonPressed() && self.sr_cheatmode)
		{
			if (!isDefined(self.sr_savePos["origin"]) || !isDefined(self.sr_savePos["angle"]))
			{
				self iPrintLn("^1No position saved");
				wait 0.2;
				continue;
			}

			self freezeControls(1);
			self SetOrigin(self.sr_savePos["origin"]);
			self SetPlayerAngles(self.sr_savePos["angle"]);
			self iPrintLn("^5Position loaded");
			wait 0.05;
			self freezeControls(0);
			wait 0.2;
		}
		wait 0.05;
	}
}
