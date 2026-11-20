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

// Off the stage once it has fallen freely for twenty seconds on end, with nothing under it all that time.
// Nothing sooner: a stage's own way on can be a long drop past nothing to a part far below.
fallen()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	self endon("sr_ride_off");

	since = getTime();
	for (;;)
	{
		wait 0.1;
		under = bulletTrace(self.origin + (0, 0, 10), self.origin - (0, 0, 120), false, self);
		if (under["fraction"] < 1)
			since = getTime();
		else if (getTime() - since >= 20000)
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
