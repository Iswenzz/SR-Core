#include sr\sys\_events;

initPerks()
{
	level.perks = [];
	level.mapPerks = [];

	addPerk("specialty_bulletdamage", "Stopping Power", undefined, ::stock);
	addPerk("specialty_bulletaccuracy", "Steady Aim", undefined, ::stock);
	addPerk("specialty_armorvest", "Juggernaut", undefined, ::stock);
	addPerk("specialty_rof", "Rapid Fire", undefined, ::stock);
	addPerk("specialty_grenadepulldeath", "Martyrdom", undefined, ::stock);
	addPerk("specialty_gpsjammer", "Cold Blooded", undefined, ::stock);

	event("spawn", ::spawn);
}

spawn()
{
	self.perks = [];

	for (i = 0; i < level.mapPerks.size; i++)
		self playerSetPerk(level.mapPerks[i]);
}

addPerk(id, name, model, callback)
{
	perk = spawnStruct();
	perk.id = id;
	perk.name = name;
	perk.callback = callback;
	perk.model = model;

	level.perks[id] = perk;

	if (isDefined(model))
		precacheModel(model);
}

playerSetPerk(id)
{
	perk = level.perks[id];
	self.perks[self.perks.size] = id;
	self thread [[perk.callback]](perk);
}

playerRemovePerk(id)
{
	self.perks = Remove(self.perks, id);
}

playerHasPerk(id)
{
	return Contains(self.perks, id);
}

stock(perk)
{
	self setPerk(perk.id);
}
