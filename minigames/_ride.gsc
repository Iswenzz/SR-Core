// A model stood where what the player rides is, turned as it is, until the player dies, spawns again, leaves
// or takes another ride. The server moves it; a client that predicts its own ride draws it where it predicts
// itself. A second model is stood inside the first, its feet on the bottom of it, and turns with it.
ride(model, inside)
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	self endon("sr_ride_off");

	ride = spawn("script_model", self.origin);
	ride setModel(model);
	ride notSolid();
	self.sr_ride = ride;
	self keep(ride);
	self thread fallen();

	rider = undefined;
	if (isDefined(inside))
	{
		rider = spawn("script_model", self.origin);
		rider setModel(inside);
		rider notSolid();
		self keep(rider);
	}

	while (true)
	{
		ride followMovement(self);
		if (isDefined(rider))
			rider followMovement(self, true);
		wait 0.05;
	}
}

// Off the stage: with nothing under the ride, and well below where something last was, it has fallen out.
// Falling fast for three seconds on end says the same where the map has a floor nobody was meant to reach.
fallen()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	self endon("sr_ride_off");

	falling = 0;
	over = self.origin[2];
	for (;;)
	{
		wait 0.1;
		under = bulletTrace(self.origin + (0, 0, 10), self.origin - (0, 0, 6000), false, self);
		if (under["fraction"] < 1)
			over = self.origin[2];
		else if (self.origin[2] < over - 600)
		{
			self suicide();
			return;
		}

		if (self getVelocity()[2] < -900)
			falling++;
		else
			falling = 0;
		if (falling >= 30)
		{
			self suicide();
			return;
		}
	}
}

// Gone with whatever ends the ride it is part of.
keep(part)
{
	self thread rideEnd(part, "disconnect");
	self thread rideEnd(part, "death");
	self thread rideEnd(part, "spawned");
	self thread rideEnd(part, "sr_ride_off");
}

rideEnd(ride, ended)
{
	ride endon("death");

	self waittill(ended);
	if (isDefined(ride))
		ride delete();
}
