getClientDvar(dvar)
{
	self endon("disconnect");

	self clientCmd(fmt("setu %s 0", dvar));
	value = self getuserinfo(dvar);
	return value;
}

getAllPlayers()
{
	return getEntArray("player", "classname");
}

bounce(origin, power)
{
	self endon("disconnect");

	previousHealth = self.health;
	self.health = self.health + power;

	self setClientDvars(
		"bg_viewKickMax", 0, 
		"bg_viewKickMin", 0, 
		"bg_viewKickRandom", 0, 
		"bg_viewKickScale", 0
	);
	self finishPlayerDamage(self, self, power, 0, "MOD_PROJECTILE", 
		"none", undefined, origin, "none", 0);
	self.health = previousHealth;
	wait .05;

	self setClientDvars(
		"bg_viewKickMax", 90, 
		"bg_viewKickMin", 5, 
		"bg_viewKickRandom", 0.4, 
		"bg_viewKickScale", 0.2
	);
}
