/*

  _|_|_|            _|      _|      _|                  _|
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/

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
			if (self isOnGround() && !self IsMantling() && !self IsOnLadder())
			{
				self.sr_savePos["origin"] = self GetOrigin();
				self.sr_savePos["angle"] = self GetPlayerAngles();
				self IPrintLn("^2Position saved");
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
				self IPrintLn("^1No position saved");
				wait 0.2;
				continue;
			}

			self freezeControls(1);
			self SetOrigin(self.sr_savePos["origin"]);
			self SetPlayerAngles(self.sr_savePos["angle"]);
			self IPrintLn("^5Position loaded");
			wait 0.05;
			self freezeControls(0);
			wait 0.2;
		}

		wait 0.05;
	}
}
