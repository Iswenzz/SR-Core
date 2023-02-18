#include sr\sys\_events;
#include sr\sys\_admins;
#include sr\utils\_common;
#include sr\utils\_hud;

settings(index, id, name, stat, value, updateCallback, toggleCallback)
{
	level.settings[index] = spawnStruct();
	level.settings[index].name = name;
	level.settings[index].index = index;
	level.settings[index].id = id;
	level.settings[index].stat = stat;
	level.settings[index].value = value;
	level.settings[index].updateCallback = updateCallback;
	level.settings[index].toggleCallback = toggleCallback;
}

menu_Setting(args)
{
	self endon("disconnect");

	index = ToInt(args[1]);
	setting = level.settings[index];
	toggle(setting.id);
}

init()
{
	self.settings = self getPersistence("settings", []);
	if (!self isFirstConnection())
		return;

	if (isDefined(self.new))
		self reset();
	self load();
}

save()
{
	self endon("disconnect");

	for (i = 0; i < level.settings.size; i++)
		self setStat(level.settings[i].stat, self.settings[level.settings[i].id]);

	self setPersistence("settings", self.settings);
}

load()
{
	for (i = 0; i < level.settings.size; i++)
	{
		setting = level.settings[i];
		self.settings[setting.id] = self getStat(setting.stat);
		self thread [[setting.updateCallback]](setting);
	}
	self setPersistence("settings", self.settings);
	self thread dvars();
}

dvars()
{
	self endon("disconnect");

	wait 1;
	for (i = 0; i < level.settings.size; i++)
	{
		if (!(i % 5))
			wait 0.05;
		self setClientDvar(fmt("sr_setting_%d", i), level.settings[i].name);
	}
}

reset()
{
	for (i = 0; i < level.settings.size; i++)
		self.settings[level.settings[i].id] = level.settings[i].value;

	self save();
}

update(id)
{
	setting = getSetting(id);
	if (!isDefined(setting))
		return;

	self [[setting.updateCallback]](setting);
	self save();
}

toggle(id)
{
	setting = getSetting(id);
	if (!isDefined(setting))
		return;

	self [[setting.toggleCallback]](setting);
	self [[setting.updateCallback]](setting);

	self save();
}

getSetting(id)
{
	setting = undefined;
	for (i = 0; i < level.settings.size; i++)
	{
		if (level.settings[i].id == id)
		{
			setting = level.settings[i];
			break;
		}
	}
	return setting;
}

updateHud(index, state, string)
{
	value = IfUndef(string, Ternary(state, "^2ON", "^1OFF"));
	self setClientDvar("sr_setting_value_" + index, value);
}
