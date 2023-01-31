#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
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

	if (!self.settings["hud_cgaz"])
		return;

	self clear();
	self cgazHud();

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		if (self.player getPlayerVelocity() >= 1)
		{
			self pmove();
			self draw();
		}
		else
			self hide();

		wait 0.05;

		self.cgaz.previousVelocity = self.cgaz.velocity;
	}
}

draw()
{
	if (!isDefined(self.cgaz.d_vel))
		return;

	yaw = atan2(self.cgaz.wishvel[1], self.cgaz.wishvel[0]) - self.cgaz.d_vel;

	y = 2;
	h = 8;

	self.huds["cgaz"]["accel"] fillAngleYaw(self, neg(self.cgaz.d_min), self.cgaz.d_min, yaw, y, h);
	self.huds["cgaz"]["accelPartialPos"] fillAngleYaw(self, self.cgaz.d_min, self.cgaz.d_opt, yaw, y, h);
	self.huds["cgaz"]["accelPartialNeg"] fillAngleYaw(self, neg(self.cgaz.d_opt), neg(self.cgaz.d_min), yaw, y, h);
	self.huds["cgaz"]["accelFullPos"] fillAngleYaw(self, self.cgaz.d_opt, self.cgaz.d_max_cos, yaw, y, h);
	self.huds["cgaz"]["accelFullNeg"] fillAngleYaw(self, neg(self.cgaz.d_max_cos), neg(self.cgaz.d_opt), yaw, y, h);
	self.huds["cgaz"]["turnZonePos"] fillAngleYaw(self, self.cgaz.d_max_cos, self.cgaz.d_max, yaw, y, h);
	self.huds["cgaz"]["turnZoneNeg"] fillAngleYaw(self, neg(self.cgaz.d_max), neg(self.cgaz.d_max_cos), yaw, y, h);
}

hide()
{
	self.huds["cgaz"]["accel"].alpha = 0;
	self.huds["cgaz"]["accelPartialPos"].alpha = 0;
	self.huds["cgaz"]["accelPartialNeg"].alpha = 0;
	self.huds["cgaz"]["accelFullPos"].alpha = 0;
	self.huds["cgaz"]["accelFullNeg"].alpha = 0;
	self.huds["cgaz"]["turnZonePos"].alpha = 0;
	self.huds["cgaz"]["turnZoneNeg"].alpha = 0;
}

cgazHud()
{
	self.cgaz = spawnStruct();
	self.cgaz.wishvel = [];
	self.cgaz.wishvel[0] = 0;
	self.cgaz.wishvel[1] = 0;
	self.cgaz.forwardMove = 0;
	self.cgaz.rightMove = 0;
	self.cgaz.velocity = (0, 0, 0);
	self.cgaz.previousVelocity = (0, 0, 0);

	self.huds["cgaz"] = [];
	self.huds["cgaz"]["accel"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["accel"].horzAlign = "fullscreen";
	self.huds["cgaz"]["accel"].color = (0.25, 0.25, 0.25);

	self.huds["cgaz"]["accelPartialPos"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["accelPartialPos"].horzAlign = "fullscreen";
	self.huds["cgaz"]["accelPartialPos"].color = (0, 1, 0);

	self.huds["cgaz"]["accelPartialNeg"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["accelPartialNeg"].horzAlign = "fullscreen";
	self.huds["cgaz"]["accelPartialNeg"].color = (0, 1, 0);

	self.huds["cgaz"]["accelFullPos"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["accelFullPos"].horzAlign = "fullscreen";
	self.huds["cgaz"]["accelFullPos"].color = (0, 0.25, 0.25);

	self.huds["cgaz"]["accelFullNeg"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["accelFullNeg"].horzAlign = "fullscreen";
	self.huds["cgaz"]["accelFullNeg"].color = (0, 0.25, 0.25);

	self.huds["cgaz"]["turnZonePos"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["turnZonePos"].horzAlign = "fullscreen";
	self.huds["cgaz"]["turnZonePos"].color = (1, 1, 0);

	self.huds["cgaz"]["turnZoneNeg"] = addHud(self, 0, 0, 0.5, "left", "middle", 1.4, 90);
	self.huds["cgaz"]["turnZoneNeg"].horzAlign = "fullscreen";
	self.huds["cgaz"]["turnZoneNeg"].color = (1, 1, 0);
}

pmove()
{
	if (!self.player getFPS())
		return;

	self.cgaz.velocity = self.player getVelocity();
	self.cgaz.viewAngles = self.player getPlayerAngles();
	self.cgaz.forward = anglesToForward(self.cgaz.viewAngles);
	self.cgaz.right = anglesToRight(self.cgaz.viewAngles);
	self.cgaz.up = anglesToUp(self.cgaz.viewAngles);
	self.cgaz.forwardMove = Ternary(self.player getDemoForwardMove(), self.player getDemoForwardMove(), self.player getForwardMove());
	self.cgaz.rightMove = Ternary(self.player getDemoRightMove(), self.player getDemoRightMove(), self.player getRightMove());
	self.cgaz.frameTime = 1 / self.player getFPS();
	self.cgaz.viewHeight = int(self.player eye()[2]);
	self.cgaz.speed = IfUndef(self.player.speed, 190);
	self.cgaz.moveSpeedScale = IfUndef(self.player.moveSpeedScale, 1.05);
	self.cgaz.gravity = IfUndef(self.player.gravity, 800);

	if (self isOnGround())
		self pm_walkMove();
	else
		self pm_airMove();
}

pm_walkMove()
{
	self pm_friction();

	self.cgaz.forward = vectorNormalize((self.cgaz.forward[0], self.cgaz.forward[1], 0));
	self.cgaz.right = vectorNormalize((self.cgaz.right[0], self.cgaz.right[1], 0));

	for (i = 0; i < 2; i++)
	{
		if (!self.cgaz.forwardMove && !self.cgaz.rightMove)
			self.cgaz.forwardMove = 127;

		self.cgaz.wishvel[i] = self.cgaz.forwardMove * self.cgaz.forward[i] +
			self.cgaz.rightMove * self.cgaz.right[i];
	}

	dmgScale = self pm_damageScaleWalk(self getDamageTimer()) * self pm_cmdScaleWalk();
	wishSpeed = dmgScale * vectorLength2(self.cgaz.wishvel);

	if (self SurfaceFlags() & 2 || self PmFlags() & 256)
		self pm_slickAccelerate(wishSpeed, 9);

	accel = 0;
	switch (self.cgaz.viewHeight)
	{
		case 11: accel = 19; break;
		case 40: accel = 12; break;
		default: accel = 9; break;
	}
	self pm_accelerate(wishspeed, accel);
}

pm_airMove()
{
	self pm_friction();

	self.cgaz.forward = vectorNormalize((self.cgaz.forward[0], self.cgaz.forward[1], 0));
	self.cgaz.right = vectorNormalize((self.cgaz.right[0], self.cgaz.right[1], 0));

	for (i = 0; i < 2; i++)
	{
		if (!self.cgaz.forwardMove && !self.cgaz.rightMove)
			self.cgaz.forwardMove = 127;

		self.cgaz.wishvel[i] = self.cgaz.forwardMove * self.cgaz.forward[i] +
			self.cgaz.rightMove * self.cgaz.right[i];
	}

	scale = self pm_cmdScale();
	wishspeed = scale * vectorLength2(self.cgaz.wishvel);

	self pm_accelerate(wishspeed, 1);
}

pm_jumpReduceFriction()
{
	if (self.player PmTime() > 1800)
		return 1;
	return self pm_jumpGetSlowdownFriction();
}

pm_jumpGetSlowdownFriction()
{
	if (!getDvarInt("jump_slowdownEnable"))
		return 1.0;
	if (self.player PmTime() < 1700)
		return self.player PmTime() * 1.5 * 0.00058823527 + 1;
	return 2.5;
}

pm_friction()
{
	vec = [];
	vec[0] = self.cgaz.velocity[0];
	vec[1] = self.cgaz.velocity[1];
	vec[2] = self.cgaz.velocity[2];

	if (self.player isOnGround())
		vec[2] = 0;

	speed = abs(vec[0]);
	if (speed < 1)
	{
		self.cgaz.velocity = (0, 0, 0);
		return;
	}

	drop = 0;
	surfaceSlick = self SurfaceFlags() & 2;
	if (self.player isOnGround() && !surfaceSlick && !(self.player PmFlags() & 256))
	{
		control = Ternary(100 <= speed, speed, 100);
		if (self.player PmFlags() & 128)
			control = control * 0.30000001;
		else if (self.player PmFlags() & 16384)
			control = self pm_jumpReduceFriction() * control;

		drop = ((control * 5.5) * self.cgaz.frameTime) + drop;
	}
	if (surfaceSlick)
	{
		player_sliding_friction = 1;
		drop = ((speed * player_sliding_friction) * self.cgaz.frameTime) + drop;
	}
	if (self.player PmType() == 4)
		drop = ((speed * 5.0) * self.cgaz.frameTime) + drop;

	newspeed = speed - drop;
	if ((speed - drop) < 0.0)
		newspeed = 0;

	ratio = newspeed / speed;
	vec[0] = ratio * vec[0];
	vec[1] = ratio * vec[1];
	vec[2] = ratio * vec[2];

	self.cgaz.velocity = (vec[0], vec[1], vec[2]);
}

pm_cmdScale()
{
	total = 0;
	scale = 0;
	spectateSpeedScale = 1;

	max = abs(self.cgaz.forwardMove);
	if (abs(self.cgaz.rightMove) > max)
		max = abs(self.cgaz.rightMove);
	if (!max)
		return 0;

	total = sqrt(self.cgaz.rightMove * self.cgaz.rightMove + self.cgaz.forwardMove * self.cgaz.forwardMove);

	scale = self.cgaz.speed * max / (total * 127);
	if (self.sessionstate == "spectator")
		scale *= spectateSpeedScale;
	return scale;
}

pm_cmdScaleWalk()
{
	total = sqrt(self.cgaz.rightMove * self.cgaz.rightMove + self.cgaz.forwardMove * self.cgaz.forwardMove);

	speed = 0;
	if (self.cgaz.forwardMove >= 0)
		speed = abs(self.cgaz.forwardMove);
	else
		speed = abs(self.cgaz.forwardMove * 1);
	if (speed - abs(self.cgaz.rightMove * 1) < 0)
		speed = abs(self.cgaz.rightMove * 1);
	if (speed == 0)
		return 0;

	scale = (self.cgaz.speed * speed) / (127 * total);
	if (self.player getStance() == "prone")
		scale *= 0.40000001;
	if (self.player sprintButtonPressed() && self.cgaz.viewHeight == 60)
		scale *= 1;
	else
		scale *= self pm_cmdScaleForStance();
	return scale * self.cgaz.moveSpeedScale;
}

pm_cmdScaleForStance()
{
	lerpFrac = self pm_getViewHeightLerp(40, 11);
	if (lerpFrac != 0)
		return 0.15000001 * lerpFrac + (1 - lerpFrac) * 0.64999998;

	lerpFrac = self pm_getViewHeightLerp(11, 40);
	if (lerpFrac != 0)
		return 0.64999998 * lerpFrac + (1 - lerpFrac) * 0.15000001;

	if (self.cgaz.viewHeight == 11)
		return 0.15000001;
	if (self.cgaz.viewHeight == 22 || self.cgaz.viewHeight == 40)
		return 0.64999998;
	return 1;
}

pm_getViewHeightLerp(fromHeight, toHeight)
{
	viewHeightLerpTime = self getViewHeightLerpTime();
	viewHeightLerpTarget = self getViewHeightLerpTarget();
	viewHeightLerpDown = self getViewHeightLerpDown();

	if (!viewHeightLerpTime)
		return 0;

	if (fromHeight != -1 && toHeight != -1
		&& (toHeight != viewHeightLerpTarget || toHeight == 40
		&& (fromHeight != 11 || viewHeightLerpDown)
		&& (fromHeight != 60 || !viewHeightLerpDown)))
		return 0;

	flerpFrac = float((getTime() - viewHeightLerpTime)) / pm_getViewHeightLerpTime(viewHeightLerpTarget, viewHeightLerpDown);
	if (flerpFrac >= 0)
	{
		if (flerpFrac > 1)
			flerpFrac = 1;
	}
	else
		flerpFrac = 0;

	return flerpFrac;
}

pm_getViewHeightLerpTime(iTarget, bDown)
{
	if (iTarget == 11)
		return 400;
	if (iTarget != 40)
		return 200;
	if (bDown)
		return 200;
	return 400;
}

pm_damageScaleWalk(damageTimer)
{
	player_dmgtimer_maxTime = 750;
	player_dmgtimer_minScale = 0;

	if (!damageTimer || player_dmgtimer_maxTime == 0)
		return 1;

	return ((neg(player_dmgtimer_minScale) / player_dmgtimer_maxTime) * damageTimer + 1);
}

pm_accelerate(wishspeed, accel)
{
	self update_d(wishspeed, accel, 0);
}

pm_slickAccelerate(wishspeed, accel)
{
	self update_d(wishspeed, accel, self.cgaz.gravity * self.cgaz.frameTime);
}

update_d(wishspeed, accel, slickGravity)
{
	self.cgaz.g_squared = slickGravity * slickGravity;
	self.cgaz.v_squared = vectorLengthSquared2(self.cgaz.previousVelocity);
	self.cgaz.vf_squared = vectorLengthSquared2(self.cgaz.velocity);
	self.cgaz.wishspeed = wishspeed;
	self.cgaz.a = accel * self.cgaz.wishspeed * self.cgaz.frameTime;
	self.cgaz.a_squared = self.cgaz.a * self.cgaz.a;
	self.cgaz.v_squared = self.cgaz.vf_squared;

	self.cgaz.v = sqrt(self.cgaz.v_squared);
	self.cgaz.vf = sqrt(self.cgaz.vf_squared);

	self.cgaz.d_min = self update_d_min();
	self.cgaz.d_opt = self update_d_opt();
	self.cgaz.d_max_cos = self update_d_max_cos(self.cgaz.d_opt);
	self.cgaz.d_max = self update_d_max(self.cgaz.d_max_cos);

	self.cgaz.d_vel = atan2(self.cgaz.velocity[1], self.cgaz.velocity[0]);
}

update_d_min()
{
	num_squared = self.cgaz.wishspeed * self.cgaz.wishspeed - self.cgaz.v_squared +
		self.cgaz.vf_squared + self.cgaz.g_squared;
	num = sqrt(num_squared);

	if (num >= self.cgaz.vf || !self.cgaz.vf)
		return 0;
	return acos1(num / self.cgaz.vf);
}

update_d_opt()
{
	num = self.cgaz.wishspeed - self.cgaz.a;

	if (num >= self.cgaz.vf || !self.cgaz.vf)
		return 0;
	return acos1(num / self.cgaz.vf);
}

update_d_max_cos(d_opt)
{
	num = sqrt(self.cgaz.v_squared - self.cgaz.g_squared) - self.cgaz.vf;

	d_max_cos = 0;
	if (!(num >= self.cgaz.a) && self.cgaz.a != 0)
		d_max_cos = acos1(num / self.cgaz.a);

	if (d_max_cos < d_opt)
		d_max_cos = d_opt;
	return d_max_cos;
}

update_d_max(d_max_cos)
{
	num = self.cgaz.v_squared - self.cgaz.vf_squared - self.cgaz.a_squared - self.cgaz.g_squared;
	den = 2 * self.cgaz.a * self.cgaz.vf;

	if (num >= den)
		return 0;

	if (neg(num) >= den)
		return pi();

	d_max = acos1(num / den);

	if (d_max < d_max_cos)
		d_max = d_max_cos;
	return d_max;
}

clear()
{
	if (!isDefined(self.huds["cgaz"]))
		return;

	keys = getArrayKeys(self.huds["cgaz"]);
	for (i = 0; i < keys.size; i++)
	{
		if (isDefined(self.huds["cgaz"][keys[i]]))
			self.huds["cgaz"][keys[i]] destroy();
	}
}
