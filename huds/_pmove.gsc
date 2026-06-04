#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.PMF_PRONE = 1;
	level.PMF_DUCKED = 2;
	level.PMF_MANTLE = 4;
	level.PMF_LADDER = 8;
	level.PMF_SIGHT_AIMING = 16;
	level.PMF_BACKWARDS_RUN = 32;
	level.PMF_WALKING = 64;
	level.PMF_TIME_HARDLANDING = 128;
	level.PMF_TIME_KNOCKBACK = 256;
	level.PMF_PRONEMOVE_OVERRIDDEN = 512;
	level.PMF_RESPAWNED = 1024;
	level.PMF_FROZEN = 2048;
	level.PMF_NO_PRONE = 4096;
	level.PMF_LADDER_FALL = 8192;
	level.PMF_JUMPING = 16384;
	level.PMF_SPRINTING = 32768;
	level.PMF_SHELLSHOCKED = 65536;
	level.PMF_MELEE_CHARGE = 131072;
	level.PMF_NO_SPRINT = 262144;
	level.PMF_NO_JUMP = 524288;
	level.PMF_VEHICLE_ATTACHED = 1048576;

	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
}

hud()
{
	self endon("spawned");
	self endon("spectator");
	self endon("death");
	self endon("disconnect");

    if (!self.settings["hud_pmove"])
		return;

	self clear();
	self create();

	prev_pm_flags_helper = "";

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		pm_flags = self.player PmFlags();
		pm_flags_helper = "";

		if (pm_flags & level.PMF_PRONE)
			pm_flags_helper += "P";
		if (pm_flags & level.PMF_DUCKED)
			pm_flags_helper += "D";
		if (pm_flags & level.PMF_MANTLE)
			pm_flags_helper += "M";
		if (pm_flags & level.PMF_LADDER)
			pm_flags_helper += "L";
		if (pm_flags & level.PMF_BACKWARDS_RUN)
			pm_flags_helper += "B";
		if (pm_flags & level.PMF_WALKING)
			pm_flags_helper += "W";
		if (pm_flags & level.PMF_TIME_HARDLANDING)
			pm_flags_helper += "H";
		if (pm_flags & level.PMF_TIME_KNOCKBACK)
			pm_flags_helper += "K";
		if (pm_flags & level.PMF_FROZEN)
			pm_flags_helper += "F";
		if (pm_flags & level.PMF_JUMPING)
			pm_flags_helper += "J";
		if (pm_flags & level.PMF_SPRINTING)
			pm_flags_helper += "S";

		self.huds["pmove"][0].alpha = Ternary(pm_flags_helper.size, 1, 0);
		if (pm_flags_helper != prev_pm_flags_helper)
			self.huds["pmove"][0] setText(pm_flags_helper);

		pm_time = self.player PmTime();
		self.huds["pmove"][1].alpha = Ternary(pm_time, 1, 0);
		self.huds["pmove"][1] setValue(pm_time);

		wait 0.05;

		prev_pm_flags_helper = pm_flags_helper;
	}
}

create()
{
	self.huds["pmove"] = [];
	self.huds["pmove"][0] = addHud(self, 150, 20, 0.8, "center", "middle", 1.4);
	self.huds["pmove"][1] = addHud(self, 200, 20, 0.8, "center", "middle", 1.4);
}

clear()
{
	if (isDefined(self.huds["pmove"]))
	{
		for (i = 0; i < self.huds["pmove"].size; i++)
		{
			if (isDefined(self.huds["pmove"][i]))
				self.huds["pmove"][i] destroy();
		}
	}
}
