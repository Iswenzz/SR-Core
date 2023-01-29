#include sr\sys\_events;
#include sr\utils\_math;
#include sr\utils\_common;

main()
{
	event("connect", ::pickup);
}

pickup()
{
	self endon("connect");
	self endon("disconnect");

	self.pickupMode = 0;

	if (!self sr\sys\_admins::isRole("masteradmin"))
		return;

	while (true)
	{
		wait 0.05;

		while (!self secondaryOffHandButtonPressed())
			wait 0.05;

		start = self getEye();
		end = start + vectorScale(anglesToForward(self getPlayerAngles()), 999999);
		trace = bulletTrace(start, end, true, self);

		ent = trace["entity"];
		if (!isDefined(ent))
			continue;

		self.sr_cheat = true;
		ent.distance = distance(start, trace["position"]);

		if (IsPlayer(ent))
		{
			ent.sr_cheat = true;
			ent sr\api\_player::antiElevator(false);
		}
		else if (!isDefined(ent.defaultOrigin))
		{
			ent.defaultOrigin = ent.origin;
			ent.defaultAngles = ent.angles;

			if (isDefined(ent.targetname))
				self iPrintLn(ent.targetname);
		}
		wait 0.1;

		// In use
		while (isDefined(ent))
		{
			wait 0.05;

			if (self useButtonPressed())
				self mode();

			start = self getEye();
			end = start + vectorScale(anglesToForward(self getPlayerAngles()), ent.distance);
			trace = bulletTrace(start, end, false, ent);
			ent.distance = distance(start, trace["position"]);

			if (!isDefined(ent.linker))
			{
				ent.linker = spawn("script_origin", trace["position"]);
            	ent linkto(ent.linker);
			}
			ent.linker.origin = trace["position"];

			if (self secondaryOffHandButtonPressed() || isDefined(ent.reset))
			{
				self reset(ent);
				break;
			}
			if (!self fragButtonPressed())
				continue;

			switch (self.pickupMode)
			{
				case 0: 	self rotate(ent, 2); 	break;
				case 1: 	self rotate(ent, 1); 	break;
				case 2: 	self rotate(ent, 0); 	break;
				case 3: 	self move(ent);			break;
				case 4: 	ent.reset = true; 		break;
			}
		}
	}
}

mode()
{
	modes = strTok("^3Yaw;^3Pitch;^3Roll;^5Move;^1Reset;", ";");
	self.pickupMode = intRange(self.pickupMode, 0, 4);
	self iPrintLn(fmt("Mode: %s", modes[self.pickupMode]));
	wait 0.2;
}

rotate(ent, direction)
{
	speed = 2;
	angles = ent.linker.angles;
	forward = self meleeButtonPressed();
	newAngle = angles[direction];

	if (newAngle == Ternary(forward, -180, 180))
		newAngle = Ternary(forward, 180, -180);
	newAngle += Ternary(forward, speed * -1, speed);

	switch (direction)
	{
		case 0: angles = (newAngle, angles[1], angles[2]); break;
		case 1: angles = (angles[0], newAngle, angles[2]); break;
		case 2: angles = (angles[0], angles[1], newAngle); break;
	}
	ent.linker rotateTo(angles, 0.05);
}

move(ent)
{
	speed = 15;
	ent.distance += Ternary(self MeleeButtonPressed(), speed, speed * -1);
}

reset(ent)
{
	ent unlink();
	ent.linker delete();

	if (isDefined(ent.reset) && isDefined(ent.defaultOrigin))
	{
		ent moveTo(ent.defaultOrigin, 0.05);
		ent.angles = ent.defaultAngles;
	}
	ent.reset = undefined;

	wait 0.1;
}
