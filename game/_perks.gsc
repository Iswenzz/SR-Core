#include sr\sys\_events;

initPerks()
{
	level.perks = [];
	level.mapPerks = [];

	addPerk("health", undefined, ::health);

	event("spawn", ::spawn);
}

spawn()
{
	self.perks = [];

	for (i = 0; i < level.mapPerks.size; i++)
		self playerSetPerk(level.mapPerks[i]);
}

addPerk(name, model, callback)
{
	perk = spawnStruct();
	perk.name = name;
	perk.callback = callback;
	perk.model = model;

	level.perks[name] = perk;

	if (isDefined(model))
		precacheModel(model);
}

playerSetPerk(name)
{
	perk = level.perks[name];
	self.perks[self.perks.size] = name;
	self thread [[perk.callback]]();
}

playerRemovePerk(name)
{
	self.perks = Remove(self.perks, name);
}

playerHasPerk(name)
{
	return Contains(self.perks, name);
}

health()
{
	self.maxhealth *= 2;
	self.health = self.maxhealth;
}
