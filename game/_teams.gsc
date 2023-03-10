#include sr\sys\_events;
#include sr\utils\_common;

setPlayerModel()
{
	self detachAll();

	character = self getCustomizeCharacter();
	glove = self getCustomizeGlove();

	self setModel(character["model"]);
	self setViewModel(glove["model"]);
}

setHealth()
{
	self.maxhealth = 100;
	switch (self.pers["team"])
	{
		case "allies":
			self.maxhealth = level.dvar["allies_health"];
			break;
		case "axis":
			self.maxhealth = level.dvar["axis_health"];
			break;
	}
	self.health = self.maxhealth;
}

setTeam(team)
{
	if (self.pers["team"] == team)
		return;

	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	if (self isPlaying())
		self suicide();
}

setSpectator()
{
	self setTeam("spectator");
	self setSpectatePermissions();
	self eventSpectator(true);
	self spawnSpectator();
}

setSpectatePermissions()
{
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", false);
}
