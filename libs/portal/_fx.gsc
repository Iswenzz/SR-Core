#include sr\utils\_math;

redlaser(start, angles)
{
	obj = spawnstruct();
	obj thread redlaserSpawn(start, angles);
}

redlaserSpawn(start, angles)
{
	self endon("kill_laser");

	maxdist = 10000;
	forward = anglestoforward(angles);
	end = bullettrace(start, start + forward * maxdist, false, undefined)["position"];

	if (distancesquared(start, end) > (maxdist * maxdist))
		return;

	self.laser = spawnfx(level.gfx["redlaser"], start, forward);
	triggerfx(self.laser, -100);

	self.nextlaser = spawnstruct();
	self.nextactive = false;

	while (true)
	{
		for (i = 0; i < self.portals.size; i++)
		{
			if (self.portals[i].activated)
			{
				trans = pointTranslation(self.portals[i].trace["position"], end,
					self.portals[i].trace["normal"], self.portals[i].trace["right"], self.portals[i].trace["up"]);

				if (!(round(trans[2], 2)))
				{
					// Laser in portal
					if (abs(trans[0]) < level.portal_width * 0.3 && abs(trans[1]) < level.portal_height * 0.3)
						continue;
				}
			}
		}
		level waittill("portal_rearange");
		wait 0.05;

		if (self.nextactive)
			self.nextlaser laserKill();
	}
}

laserKill()
{
	self.laser delete();
	self notify("kill_laser");

	// delete all next walls
	if (self.nextactive)
		self.nextwall laserKill();
}
