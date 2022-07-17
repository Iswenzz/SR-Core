#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.SNAP_NORMAL = 1;
	level.SNAP_HL_ACTIVE = 2;
	level.SNAP_45 = 4;
	level.SNAP_BLUERED = 8;
	level.SNAP_HEIGHT = 16;

	level.snap_max_huds = 10;
	level.snap_colors = [];
	level.snap_colors[level.snap_colors.size] = (0, 0.9, 0.9);
	level.snap_colors[level.snap_colors.size] = (0.05, 0.05, 0.05);
	level.snap_colors[level.snap_colors.size] = (0.5, 0.6, 0.9);
	level.snap_colors[level.snap_colors.size] = (0.5, 0.7, 0.9);
	level.snap_colors[level.snap_colors.size] = (0.5, 0.6, 0.9);
	level.snap_colors[level.snap_colors.size] = (0.05, 0.05, 0.05);

	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
}

hud()
{
	self endon("death");
	self endon("disconnect");

	if (!self.settings["hud_snap"])
		return;

	self clear();
	self snapHud();

	while (true)
	{
		wait 0.05;

		self.player = IfUndef(self getSpectatorClient(), self);

		self pmove();
		self resetGraph();
	}
}

resetGraph()
{
	for (i = 0; i < level.snap_max_huds; i++)
	{
		if (!isDefined(self.huds["snap"][i]))
			continue;

		if (!self.huds["snap"][i].rendered)
			self.huds["snap"][i].alpha = 0;
		self.huds["snap"][i].rendered = false;
	}
}

oneZoneDraw(start, end, yaw, y, h, defColor, altColor, hlColor, overrideColor)
{
	if (self.snap.hudIndex >= level.snap_max_huds)
		return;

	color = IfUndef(overrideColor, level.snap_colors[defColor + altColor]);
	index = self.snap.hudIndex;
	self.snap.hudIndex++;

	if (hlColor && angleNormalize65536(yaw - start) <= angleNormalize65536(end - start))
		color = level.snap_colors[2 + altColor];

	self.huds["snap"][index].rendered = true;
	self.huds["snap"][index].color = color;
	self.huds["snap"][index] fillAngleYaw(self, short2rad(start), short2rad(end), short2rad(yaw), y, h);
}

oneSnapDraw(yaw)
{
	y = 0;
	h = 4;

	hlActive = self.snapFlags & level.SNAP_HL_ACTIVE;

	if (self.snapFlags & level.SNAP_BLUERED)
	{
		diffAbsAccel = self.snap.maxAbsAccel - self.snap.minAbsAccel;

		alt_color = 0;
		for (i = 0; i < 2 * self.snap.maxAccel; i++)
		{
			color = ((self.snap.absAccel[i + 1] - self.snap.minAbsAccel) / diffAbsAccel, 0,
				(self.snap.maxAbsAccel - self.snap.absAccel[i + 1]) / diffAbsAccel);

			for (j = 0; j < 65536; j += 16384)
			{
				if (alt_color)
					continue;

				bSnap = self.snap.zones[i] + 1 + j;
				eSnap = self.snap.zones[i + 1] + 0 + j;
				self oneZoneDraw(bSnap, eSnap, yaw, y, h, 0, 0, hlActive, color);
			}
			alt_color ^= 1;
		}
	}
	if (self.snapFlags & level.SNAP_45)
	{
		alt_color = 0;
		for (i = 0; i < 2 * self.snap.maxAccel; i++)
		{
			for (j = 0; j < 65536; j += 16384)
			{
				if (alt_color)
					continue;

				bSnap = self.snap.zones[i] + 1 + j;
				eSnap = self.snap.zones[i + 1] + 0 + j;
				self oneZoneDraw(bSnap, eSnap, yaw + 8192, y, h, 4, alt_color, false);
			}
			alt_color ^= 1;
		}
	}
	if (self.snapFlags & level.SNAP_NORMAL)
	{
		alt_color = 0;
		for (i = 0; i < 2 * self.snap.maxAccel; i++)
		{
			for (j = 0; j < 65536; j += 16384)
			{
				if (alt_color)
					continue;

				bSnap = self.snap.zones[i] + 1 + j;
				eSnap = self.snap.zones[i + 1] + 0 + j;
				self oneZoneDraw(bSnap, eSnap, yaw, y, h, 0, alt_color, hlActive);
			}
			alt_color ^= 1;
		}
	}
	if (self.snapFlags & level.SNAP_HEIGHT)
	{
		alt_color = 0;
		gain = 0;
		diffAbsAccel = self.snap.maxAbsAccel - self.snap.minAbsAccel;

		for (i = 0; i < 2 * self.snap.maxAccel; i++)
		{
			gain = (self.snap.absAccel[i + 1] - self.snap.minAbsAccel) / diffAbsAccel;
			gain *= 0.8 + 0.2;

			_h = gain;
			_y = y * (1 - gain);

			for (j = 0; j < 65536; j += 16384)
			{
				if (alt_color)
					continue;

				bSnap = self.snap.zones[i] + 1 + j;
				eSnap = self.snap.zones[i + 1] + 0 + j;
				self oneZoneDraw(bSnap, eSnap, yaw, _y, _h, 0, 0, hlActive);
			}
			alt_color ^= 1;
		}
	}
}

snapHud()
{
	self.snap = spawnStruct();
	self.snap.wishvel = [];
	self.snap.forwardMove = 0;
	self.snap.rightMove = 0;
	self.snap.velocity = (0, 0, 0);
	self.snap.a = 0;
	self.snap.maxAccel = 0;
	self.snap.minAbsAccel = 0;
	self.snap.maxAbsAccel = 0;
	self.snap.absAccel = [];
	self.snap.xAccel = [];
	self.snap.yAccel = [];
	self.snap.zones = [];
	self.snap.hudIndex = 0;

	self.huds["snap"] = [];
	for (i = 0; i < level.snap_max_huds; i++)
	{
		self.huds["snap"][i] = addHud(self, 0, 0, 1, "left", "middle", 1.4, 100);
		self.huds["snap"][i].horzAlign = "fullscreen";
	}
}

getSnapFlags(mode)
{
	if (mode == 1)
		return level.SNAP_NORMAL;
	if (mode == 2)
		return level.SNAP_BLUERED | level.SNAP_45;
	if (mode == 3)
		return level.SNAP_HEIGHT | level.SNAP_HL_ACTIVE;
	return 0;
}

pmove()
{
	self.snapFlags = self getSnapFlags(self.settings["hud_snap"]);

	self.snap.velocity = self.player getVelocity();
	self.snap.viewAngles = self.player getPlayerAngles();
	self.snap.forward = anglesToForward(self.snap.viewAngles);
	self.snap.right = anglesToRight(self.snap.viewAngles);
	self.snap.up = anglesToUp(self.snap.viewAngles);
	self.snap.forwardMove = self.player getForwardMove();
	self.snap.rightMove = self.player getRightMove();
	self.snap.frameTime = 1 / self.player getFPS();
	self.snap.viewHeight = int(self.player eye()[2]);
	self.snap.hudIndex = 0;
	self.snap.speed = IfUndef(self.player.speed, 190);
	self.snap.moveSpeedScale = IfUndef(self.player.moveSpeedScale, 1.05);

	if (self isOnGround())
		self pm_walkMove();
	else
		self pm_airMove();

	yaw = rad2short(atan2(self.snap.wishvel[1], self.snap.wishvel[0]));
	yaw = Ternary(!yaw, 8, angleNormalize65536(int(ceil(yaw))));
  	self oneSnapDraw(yaw);
}

pm_walkMove()
{
	self pm_friction();

	self.snap.forward = vectorNormalize((self.snap.forward[0], self.snap.forward[1], 0));
	self.snap.right = vectorNormalize((self.snap.right[0], self.snap.right[1], 0));

	for (i = 0; i < 2; i++)
	{
		if (!self.snap.forwardMove && !self.snap.rightMove)
			self.snap.forwardMove = 127;

		self.snap.wishvel[i] = self.snap.forwardMove * self.snap.forward[i] +
			self.snap.rightMove * self.snap.right[i];
	}

	dmgScale = pm_damageScaleWalk(self getDamageTimer()) * pm_cmdScaleWalk();
	wishSpeed = dmgScale * vectorLength2(self.snap.wishvel);

	if (self SurfaceFlags() & 2 || self PmFlags() & 256)
		self pm_slickAccelerate(wishSpeed, 9);

	accel = 0;
	switch (self.snap.viewHeight)
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

	self.snap.forward = vectorNormalize((self.snap.forward[0], self.snap.forward[1], 0));
	self.snap.right = vectorNormalize((self.snap.right[0], self.snap.right[1], 0));

	for (i = 0; i < 2; i++)
	{
		if (!self.snap.forwardMove && !self.snap.rightMove)
			self.snap.forwardMove = 127;

		self.snap.wishvel[i] = self.snap.forwardMove * self.snap.forward[i] +
			self.snap.rightMove * self.snap.right[i];
	}

	scale = pm_cmdScale();
	wishspeed = scale * vectorLength2(self.snap.wishvel);

	self pm_accelerate(wishspeed, 1);
}

pm_accelerate(wishspeed, accel)
{
	a = accel * (1 * wishspeed) * self.snap.frameTime;
	if (a > 50)
		a = 50;

	if (a != self.snap.a)
	{
		self.snap.a = a;
		self updateSnapState();
	}
}

pm_slickAccelerate(wishspeed, accel)
{
	self pm_accelerate(wishspeed, accel);
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
	vec[0] = self.snap.velocity[0];
	vec[1] = self.snap.velocity[1];
	vec[2] = self.snap.velocity[2];

	if (self.player isOnGround())
		vec[2] = 0;

	speed = abs(vec[0]);
	if (speed < 1)
	{
		self.snap.velocity = (0, 0, 0);
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

		drop = ((control * 5.5) * self.snap.frameTime) + drop;
	}
	if (surfaceSlick)
	{
		player_sliding_friction = 1;
		drop = ((speed * player_sliding_friction) * self.snap.frameTime) + drop;
	}
	if (self.player PmType() == 4)
		drop = ((speed * 5.0) * self.snap.frameTime) + drop;

	newspeed = speed - drop;
	if ((speed - drop) < 0.0)
		newspeed = 0;

	ratio = newspeed / speed;
	vec[0] = ratio * vec[0];
	vec[1] = ratio * vec[1];
	vec[2] = ratio * vec[2];

	self.snap.velocity = (vec[0], vec[1], vec[2]);
}

pm_cmdScale()
{
	total = 0;
	scale = 0;
	spectateSpeedScale = 1;

	max = abs(self.snap.forwardMove);
	if (abs(self.snap.rightMove) > max)
		max = abs(self.snap.rightMove);
	if (!max)
		return 0;

	total = sqrt(self.snap.rightMove * self.snap.rightMove + self.snap.forwardMove * self.snap.forwardMove);

	scale = self.snap.speed * max / (total * 127);
	if (self.modes["noclip"])
		scale *= 3;
	if (self.sessionstate == "spectator")
		scale *= spectateSpeedScale;
	return scale;
}

pm_cmdScaleWalk()
{
	total = sqrt(self.snap.rightMove * self.snap.rightMove + self.snap.forwardMove * self.snap.forwardMove);

	speed = 0;
	if (self.snap.forwardMove >= 0)
		speed = abs(self.snap.forwardMove);
	else
		speed = abs(self.snap.forwardMove * 1);
	if (speed - abs(self.snap.rightMove * 1) < 0)
		speed = abs(self.snap.rightMove * 1);
	if (speed == 0)
		return 0;

	scale = (self.snap.speed * speed) / (127 * total);
	if (self.player getStance() == "prone")
		scale *= 0.40000001;
	if (self.player sprintButtonPressed() && self.snap.viewHeight == 60)
		scale *= 1;
	if (self.modes["noclip"])
		scale *= 3;
	else
		scale *= self pm_cmdScaleForStance();
	return scale * self.snap.moveSpeedScale;
}

pm_cmdScaleForStance()
{
	lerpFrac = self pm_getViewHeightLerp(40, 11);
	if (lerpFrac != 0)
		return 0.15000001 * lerpFrac + (1 - lerpFrac) * 0.64999998;

	lerpFrac = self pm_getViewHeightLerp(11, 40);
	if (lerpFrac != 0)
		return 0.64999998 * lerpFrac + (1 - lerpFrac) * 0.15000001;

	if (self.snap.viewHeight == 11)
		return 0.15000001;
	if (self.snap.viewHeight == 22 || self.snap.viewHeight == 40)
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

updateSnapState()
{
	self.snap.maxAccel = int(self.snap.a + 0.5);
	xnyAccel = int(self.snap.a / sqrt(2) + 0.5);

	for (i = 0; i <= xnyAccel - 1; i++)
		self.snap.zones[self.snap.maxAccel + i] = 16383 - int(rad2short(acos1((i + 0.5) / self.snap.a)));
	for (i = xnyAccel; i <= self.snap.maxAccel - 1; i++)
	{
		self.snap.zones[self.snap.maxAccel + (self.snap.maxAccel - 1) - (i - xnyAccel)] =
			int(rad2short(acos1((i + 0.5) / self.snap.a)));
	}

	// Merge 2 sorted arrays in the lowerhalf
	bi = self.snap.maxAccel + 0;
	ei = self.snap.maxAccel + xnyAccel;
	bj = self.snap.maxAccel + xnyAccel;
	ej = self.snap.maxAccel + self.snap.maxAccel;

	i = bi;
	j = bj;
	k = 0;

	xAccel = self.snap.maxAccel - (j - bj);
	yAccel = i - bi;
	absAccel = 0;
	self.snap.minAbsAccel = 2 * self.snap.maxAccel;
	self.snap.maxAbsAccel = 0;

	while (i < ei && j < ej)
	{
		absAccel = sqrt((xAccel * xAccel + yAccel * yAccel));
		if (absAccel < self.snap.minAbsAccel)
			self.snap.minAbsAccel = absAccel;
		if (absAccel > self.snap.maxAbsAccel)
			self.snap.maxAbsAccel = absAccel;

		self.snap.xAccel[k] = xAccel;
		self.snap.yAccel[k] = yAccel;
		self.snap.absAccel[k] = absAccel;
		self.snap.xAccel[2 * self.snap.maxAccel - k] = yAccel;
		self.snap.yAccel[2 * self.snap.maxAccel - k] = xAccel;
		self.snap.absAccel[2 * self.snap.maxAccel - k] = absAccel;

		if (self.snap.zones[i] < self.snap.zones[j])
		{
			self.snap.zones[k] = self.snap.zones[i];
			k++; i++;
			yAccel = i - bi;
		}
		else
		{
			self.snap.zones[k] = self.snap.zones[j];
			k++; i++;
			xAccel = self.snap.maxAccel - (j - bj);
		}
	}
	while (i < ei) // Store remaining elements
	{
		absAccel = sqrt(xAccel * xAccel + yAccel * yAccel);
		if (absAccel < self.snap.minAbsAccel)
			self.snap.minAbsAccel = absAccel;
		if (absAccel > self.snap.maxAbsAccel)
			self.snap.maxAbsAccel = absAccel;

		self.snap.xAccel[k] = xAccel;
		self.snap.yAccel[k] = yAccel;
		self.snap.absAccel[k] = absAccel;
		self.snap.xAccel[2 * self.snap.maxAccel - k] = yAccel;
		self.snap.yAccel[2 * self.snap.maxAccel - k] = xAccel;
		self.snap.absAccel[2 * self.snap.maxAccel - k] = absAccel;
		self.snap.zones[k] = self.snap.zones[i];
		k++; i++;
		yAccel = i - bi;
	}
	while (j < ej) // Store remaining elements
	{
		absAccel = sqrt((xAccel * xAccel + yAccel * yAccel));
		if (absAccel < self.snap.minAbsAccel)
			self.snap.minAbsAccel = absAccel;
		if (absAccel > self.snap.maxAbsAccel)
			self.snap.maxAbsAccel = absAccel;

		self.snap.xAccel[k] = xAccel;
		self.snap.yAccel[k] = yAccel;
		self.snap.absAccel[k] = absAccel;
		self.snap.xAccel[2 * self.snap.maxAccel - k] = yAccel;
		self.snap.yAccel[2 * self.snap.maxAccel - k] = xAccel;
		self.snap.absAccel[2 * self.snap.maxAccel - k] = absAccel;
		self.snap.zones[k] = self.snap.zones[j];
		k++; j++;
		xAccel = self.snap.maxAccel - (j - bj);
	}

	// Fill in the acceleration of the snapzone at 45deg since we only searched
	// for shortangles smaller than 45deg (= 8192)
	absAccel = sqrt(2) * xnyAccel;
	if (absAccel < self.snap.minAbsAccel)
		self.snap.minAbsAccel = absAccel;
	if (absAccel > self.snap.maxAbsAccel)
		self.snap.maxAbsAccel = absAccel;

	self.snap.xAccel[k] = xnyAccel;
	self.snap.yAccel[k] = xnyAccel;
	self.snap.absAccel[k] = absAccel;

	for (i = 0; i < self.snap.maxAccel; i++)
		self.snap.zones[self.snap.maxAccel + i] = 16383 - self.snap.zones[self.snap.maxAccel - 1 - i];
	self.snap.zones[2 * self.snap.maxAccel] = self.snap.zones[0] + 16384;
}

clear()
{
	if (!isDefined(self.huds["snap"]))
		return;

	for (i = 0; i < self.huds["snap"].size; i++)
	{
		if (isDefined(self.huds["snap"][i]))
			self.huds["snap"][i] destroy();
	}
}
