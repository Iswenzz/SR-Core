#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.sprays = [];

	event("spawn", ::onSpawn);

	thread visuals();
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!level.dvar["sprays"])
		return;

	while (true)
	{
		wait 0.05;

		if (!self fragButtonPressed())
		{
			wait 0.2;
			continue;
		}

		angles = self getPlayerAngles();
		eye = self getTagOrigin("j_head");
		forward = eye + vectorScale(anglesToForward(angles), 70);
		trace = bulletTrace(eye, forward, false, self);

		if (trace["fraction"] == 1)
			continue;

		sprayNum = self getStat(979);
		asset = level.assets["spray"][sprayNum];

		if (!isDefined(asset))
			continue;

		switch (asset["type"])
		{
			case "fx": 		self fx(asset, trace);		break;
			case "gif": 	self gif(asset, trace);		break;
		}
	}
}

fx(asset, trace)
{
	eye = self getTagOrigin("j_head");
	position = trace["position"] - vectorScale(anglesToForward(self getPlayerAngles()), -2);
	angles = vectorToAngles(eye - position);
	forward = anglesToForward(angles);
	up = anglesToUp(angles);

	playFX(asset["effect"], position, forward, up);
	self playSound("sprayer");

	wait Ternary(self sr\sys\_admins::isRole("owner"), 0, level.dvar["sprays_delay"]);
}

gif(asset, trace)
{
	if (isDefined(self.spray))
	{
		self.spray delete();
		level.sprays = Remove(level.sprays, self.spray);
	}

	on_terrain = false;
	on_ground = false;

	terrain = 1;
	position = trace["position"];
	normal = trace["normal"];
	angles = vectorToAngles(normal);
	fxPosition = position + normal * (1 + on_terrain * 2);

	if (abs(round(normal[2], 3 - terrain)) == 1)
		on_ground = true;
	if (on_ground)
		angles = (0, self getPlayerAngles()[1] - 180, angles[2] + 90);

	self.spray = spawn("script_model", fxPosition);
	self.spray.angles = angles + (0, -90, 0);
	self.spray setModel(asset["effect"]);
	self.spray hide();

	self playSound("sprayer");

	level.sprays[level.sprays.size] = self.spray;
	if (level.sprays.size >= 10)
	{
		first = level.sprays[0];
		level.sprays = Remove(level.sprays, first);
		first delete();
	}
	wait level.dvar["sprays_delay"];
}

visuals()
{
	while (true)
	{
		players = getAllPlayers();

		for (i = 0; i < level.sprays.size; i++)
		{
			level.sprays[i] hide();

			for (j = 0; j < players.size; j++)
			{
				if (players[j].settings["gfx_fx"])
					level.sprays[i] showToPlayer(players[j]);
			}
		}
		wait 1;
	}
}
