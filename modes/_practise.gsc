#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	sr\core\_modes::createMode("practise");

	level.practise_max_saves = 32;
	level.practise_rewind_steps = 10;
	level.practise_rewind_chain = 1500;

	event("spawn", ::practise);

	menu("-1", "save", ::menu_Save);
	menu("-1", "load", ::menu_Load);
	menu("-1", "rewind", ::menu_Rewind);
}

practise()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!sr\core\_modes::IsInMode("practise"))
		return;

	if (!isDefined(self.practise))
	{
		self.practise = [];
		self.practise_index = 0;
	}
	self.practise_rewind = undefined;

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^5Practise");
}

menu_Save(arg)
{
	if (!self canPractise())
		return;

	// Once full, the oldest save hands its slot to the new one.
	slot = self.practise.size;
	if (slot == level.practise_max_saves)
	{
		slot = self.practise[0].slot;
		saves = [];
		for (i = 1; i < self.practise.size; i++)
			saves[saves.size] = self.practise[i];
		self.practise = saves;
	}

	save = spawnStruct();
	save.slot = slot;
	save.origin = self getOrigin();
	save.angles = self getPlayerAngles();

	self saveState(slot);
	self callEvent("practise_save", save);

	self.practise[self.practise.size] = save;
	self.practise_index = self.practise.size - 1;
	self iPrintLn(fmt("^2Position saved ^7%d/%d", self.practise.size, self.practise.size));
}

menu_Load(arg)
{
	if (!self canPractise())
		return;

	if (!self.practise.size)
	{
		self iPrintLn("^1No position saved");
		return;
	}

	// Holding use steps back one save, wrapping to the newest so a single bind cycles through all of them.
	if (self useButtonPressed())
		self.practise_index = Ternary(self.practise_index > 0, self.practise_index - 1, self.practise.size - 1);

	save = self.practise[self.practise_index];

	self unlinkNoclip();
	self loadState(save.slot);
	self setOrigin(save.origin);
	self setPlayerAngles(save.angles);
	self callEvent("practise_load", save);

	// A rewind chain started before the load would land back where the load came from.
	self.practise_rewind = undefined;
	self iPrintLn(fmt("^5Position loaded ^7%d/%d", self.practise_index + 1, self.practise.size));
}

menu_Rewind(arg)
{
	if (!self canPractise())
		return;

	// Presses close together keep stepping back from the first one; after a pause it starts over from now.
	now = getTime();
	if (!isDefined(self.practise_rewind) || now - self.practise_rewind.last > level.practise_rewind_chain)
	{
		self.practise_rewind = spawnStruct();
		self.practise_rewind.anchor = now;
		self.practise_rewind.steps = 0;
	}
	self.practise_rewind.last = now;
	if (self.practise_rewind.steps < level.practise_rewind_steps)
		self.practise_rewind.steps++;

	self unlinkNoclip();

	target = self.practise_rewind.anchor - self.practise_rewind.steps * 1000;
	time = self rewindState(now - target);
	if (!isDefined(time))
		return;

	rewind = spawnStruct();
	rewind.time = time;
	self callEvent("practise_rewind", rewind);

	self iPrintLn(fmt("^5Rewind ^7-%ds", self.practise_rewind.steps));
}

canPractise()
{
	if (!self isPlaying() || self isDead() || self isDemo() || !isDefined(self.practise))
		return false;
	return self sr\core\_modes::isInMode("practise");
}

// Noclip keeps the player linked, which would pull them straight back.
unlinkNoclip()
{
	if (!isDefined(self.linker))
		return;

	self unlink();
	self.linker delete();
}

// Lets the mod keep its own state, such as the run timer, in step with a save, a load or a rewind.
callEvent(name, data)
{
	for (i = 0; isDefined(level.events[name]) && i < level.events[name].size; i++)
		self [[level.events[name][i]]](data);
}
