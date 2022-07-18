#include sr\utils\_math;

// Calculate the angles after travelling through a portal
portalOutAngles(angles1, angles2, angles3)
{
	return (angleNormalize(angles2[0] + angles3[0] + angles1[0]),angles2[1] - angles1[1] + angles3[1] - 180, 0);
}

// Calculate player angles after travelling through a portal
playerPortalOutAngles(angles1, angles2, angles3)
{
	angles = portalOutAngles(angles1, angles2, angles3);

	// If the x-Angle is going over 120 degrees player will be flipped (max player angle is 85)
	while (abs(angles[0]) > 120)
		angles = (angleMax(angles[0]) , angles[1] + 180, 0);

	return angles;
}

coneTrace(pos, angles, objects, conedegree, maxlength)
{
	close = [];

	for (i = 0; i < objects.size; i++)
	{
		q = objects[i].origin;
		if (lengthsquared(q - pos) < maxlength*maxlength)
		{
			angles2 = vectortoangles(q - pos);
			if (abs(angleNormalize(angles[0] - angles2[0])) < conedegree &&
				abs(angleNormalize(angles[1] - angles2[1])) < conedegree)
			{
				if (objects[i] SightConeTrace(pos, self))
					close[close.size] = objects[i];
			}
		}
	}
	return close;
}

closestConeTrace(pos, angles, objects, conedegree, maxlength)
{
	// Get an array of the possible objects
	close = ConeTrace(pos, angles, objects, conedegree, maxlength);
	if (!close.size)
		return;

	// Check for the closest object
	object = close[0];

	for (i = 1; i < close.size; i++)
	{
		if (distancesquared(object.origin, pos) > distancesquared(close[i].origin, pos))
			object = close[i];
	}
	return object;
}

// True if point p and q are on the same wall given the wallnormal
isOnSameWall(p, q, normal)
{
	return !(round(vectordot(q - p, normal), 2));
}

arrow(n, normal, pos)
{
	if (!isDefined(level.testarrow))
		level.testarrow = [];
	if (!isDefined(pos))
		pos = self eyepos() + anglesToForward(self getPlayerAngles()) * 200;
	if (!isDefined(level.testarrow[n]))
	{
		level.testarrow[n] = spawn("script_model", pos);
		level.testarrow[n] setModel("projectile_sidewinder_missile");
	}
	else
		level.testarrow[n].origin = pos;
	level.testarrow[n].angles =  (0, 90, 0) - vectortoangles(normal);
}
