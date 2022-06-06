#include sr\sys\_events;
#include sr\utils\_math;
#include sr\utils\_common;

main()
{
	event("connect", ::pickup);
}

pickup()
{
	self endon("disconnect");
	self.pickupMode = 0;

	while (true)
	{
		while (!self secondaryOffHandButtonPressed())
			wait 0.05;

		start = self getEye();
		end = start + vectorScale(anglesToForward(self getPlayerAngles()), 999999);
		trace = bulletTrace(start, end, true, self);
		ent = trace["entity"];
		ent.distance = distance(start, trace["position"]);

		if (!isDefined(ent))
			continue;
		if (!IsPlayer(ent))
		{
			if (!isDefined(ent.originalPlace))
				ent.originalPlace = ent getOrigin();
		}
		if (isDefined(ent.targetname))
			self iPrintLn(ent.targetname);

		// In use
		while (!self secondaryOffHandButtonPressed() && isDefined(ent))
		{
			wait 0.05;

			if (self useButtonPressed())
				self mode();

			start = self getEye();
			end = start + vectorScale(anglesToForward(self getPlayerAngles()), ent.distance);
			trace = bulletTrace(start, end, false, ent);
			ent.distance = distance(start, trace["position"]);

			if (!self fragButtonPressed())
				continue;

			switch (self.pickupMode)
			{
				case 0: 	self rotate(ent, 3); 	break;
				case 1: 	self rotate(ent, 2); 	break;
				case 2: 	self rotate(ent, 1); 	break;
				case 3: 	self move(ent);			break;
				case 4: 	self reset(ent); 		break;
			}
			if (isDefined(ent.reset))
			{
				ent.reset = undefined;
				break;
			}

			end = start + vectorScale(anglesToForward(self getPlayerAngles()), ent.distance);
			trace = bulletTrace(start, end, false, ent);
			ent.origin = trace["position"];
		}
	}
}

mode()
{
	modes = strTok("Yaw;Pitch;Roll;Move;Reset", ";");
	self.pickupMode = range(self.pickupMode + 1, 0, 4);
	self iPrintLn(modes[self.pickupMode]);
}

rotate(ent, direction)
{
	speed = 2;
	angles = ent.angles;
	forward = self meleeButtonPressed();

	if (angles[direction] == Ternary(forward, -180, 180))
		angles[direction] = Ternary(forward, 180, -180);

	angles[direction] += Ternary(forward, -speed, speed);

	ent rotateTo(angles, 0.05);
}

move()
{
	speed = 15;
	ent.distance += Ternary(self MeleeButtonPressed(), speed, -speed);
}

reset(ent)
{
	ent moveTo(ent.originalPlace, 0.05);
	ent rotateTo((0, 0, 0), 0.05);
	ent.reset = true;
}
