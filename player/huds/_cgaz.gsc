#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
    event("spawn", ::hud);
    event("death", ::clear);
}

hud()
{
    self endon("death");
    self endon("disconnect");

    self clear();
    self cgazHud();

    while (true)
    {
        if (m_vector_length2(self getVelocity()))
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
    yaw = atan2(self.cgaz.wishvel[1], self.cgaz.wishvel[0]) - self.cgaz.d_vel;
    
    y = 10;
    h = 5;

    self.huds["cgaz"]["accel"] fillAngleYaw(self.screen, neg(self.cgaz.d_min), pos(self.cgaz.d_min), yaw, y, h);
    self.huds["cgaz"]["accelPartialPos"] fillAngleYaw(self.screen, pos(self.cgaz.d_min), pos(self.cgaz.d_opt), yaw, y, h);
    self.huds["cgaz"]["accelPartialNeg"] fillAngleYaw(self.screen, neg(self.cgaz.d_opt), neg(self.cgaz.d_min), yaw, y, h);
    self.huds["cgaz"]["accelFullPos"] fillAngleYaw(self.screen, pos(self.cgaz.d_opt), pos(self.cgaz.d_max_cos), yaw, y, h);
    self.huds["cgaz"]["accelFullNeg"] fillAngleYaw(self.screen, neg(self.cgaz.d_max_cos), neg(self.cgaz.d_opt), yaw, y, h);
    self.huds["cgaz"]["turnZonePos"] fillAngleYaw(self.screen, pos(self.cgaz.d_max_cos), pos(self.cgaz.d_max), yaw, y, h);
    self.huds["cgaz"]["turnZoneNeg"] fillAngleYaw(self.screen, neg(self.cgaz.d_max), neg(self.cgaz.d_max_cos), yaw, y, h);
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
    self.cgaz.forwardMove = 0;
    self.cgaz.rightMove = 0;
    self.cgaz.velocity = self getVelocity();
    self.cgaz.previousVelocity = (0, 0, 0);

    self.screen = spawnStruct(); // @TODO get player screen size
    self.screen.width = 1280;
    self.screen.height = 720;

    self.huds["cgaz"] = [];
    self.huds["cgaz"]["accel"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accel"].color = (0.25, 0.25, 0.25);
    self.huds["cgaz"]["accel"].archived = false;
    self.huds["cgaz"]["accel"].hidewheninmenu = true;

    self.huds["cgaz"]["accelPartialPos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelPartialPos"].color = (0, 1, 0);
    self.huds["cgaz"]["accelPartialPos"].archived = false;
    self.huds["cgaz"]["accelPartialPos"].hidewheninmenu = true;

    self.huds["cgaz"]["accelPartialNeg"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelPartialNeg"].color = (0, 1, 0);
    self.huds["cgaz"]["accelPartialNeg"].archived = false;
    self.huds["cgaz"]["accelPartialNeg"].hidewheninmenu = true;

    self.huds["cgaz"]["accelFullPos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelFullPos"].color = (0, 0.25, 0.25);
    self.huds["cgaz"]["accelFullPos"].archived = false;
    self.huds["cgaz"]["accelFullPos"].hidewheninmenu = true;

    self.huds["cgaz"]["accelFullNeg"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelFullNeg"].color = (0, 0.25, 0.25);
    self.huds["cgaz"]["accelFullNeg"].archived = false;
    self.huds["cgaz"]["accelFullNeg"].hidewheninmenu = true;

    self.huds["cgaz"]["turnZonePos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["turnZonePos"].color = (1, 1, 0);
    self.huds["cgaz"]["turnZonePos"].archived = false;
    self.huds["cgaz"]["turnZonePos"].hidewheninmenu = true;

    self.huds["cgaz"]["turnZoneNeg"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["turnZoneNeg"].color = (1, 1, 0);
    self.huds["cgaz"]["turnZoneNeg"].archived = false;
    self.huds["cgaz"]["turnZoneNeg"].hidewheninmenu = true;
}

pmove()
{
    self.cgaz.velocity = self getVelocity();
    self.cgaz.viewAngles = self getPlayerAngles();
    self.cgaz.forward = anglesToForward(self.cgaz.viewAngles);
    self.cgaz.right = anglesToRight(self.cgaz.viewAngles);
    self.cgaz.up = anglesToUp(self.cgaz.viewAngles);
    self.cgaz.frameTime = 1 / self getFPS();
    self.cgaz.viewHeight = int(eye()[2]);

    if (!self.cgaz.forwardMove && !self.cgaz.rightMove)
        self.cgaz.forwardMove = 127;

    if (self isOnGround())
        self pm_walkMove();
    else
        self pm_airMove();
}

pm_walkMove()
{
    self.cgaz.forward = vectorNormalize((self.cgaz.forward[0], self.cgaz.forward[1], 0));
    self.cgaz.right = vectorNormalize((self.cgaz.right[0], self.cgaz.right[1], 0));

    for (i = 0; i < 2; i++)
    {
        self.cgaz.forwardMove = self getForwardMove();
        self.cgaz.rightMove = self getRightMove();

        self.cgaz.wishvel[i] = self.cgaz.forwardMove * self.cgaz.forward[i] + 
            self.cgaz.rightMove * self.cgaz.right[i];
    }

    dmgScale = self pm_damageScaleWalk(1) * self pm_cmdScaleWalk();
    wishSpeed = dmgScale * m_vector_length2(self.cgaz.wishvel);

    if (false) // @TODO knockback / slick
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

    total = sqrt(self.cgaz.rightMove * self.cgaz.rightMove + 
        self.cgaz.forwardMove * self.cgaz.forwardMove);

    scale = self.speed * max / (total * 127);
    if (self.modes["noclip"])
        scale *= 3;
    if (self.sessionstate == "spectator")
        scale *= spectateSpeedScale;
    return scale;
}

pm_cmdScaleWalk()
{
    total = sqrt(self.cgaz.rightMove * self.cgaz.rightMove + 
        self.cgaz.forwardMove * self.cgaz.forwardMove);

    speed = 0;
    if (self.cgaz.forwardMove >= 0)
        speed = abs(self.cgaz.forwardMove);
    else
        speed = abs(self.cgaz.forwardMove * 1);
    if (speed - abs(self.cgaz.rightMove * 1) < 0)
        speed = abs(self.cgaz.rightMove * 1);
    if (speed == 0)
        return 0;

    scale = (self.speed * speed) / (127 * total);
    if (self getStance() == "prone")
        scale *= 0.40000001;
    if (self sprintButtonPressed() && self.cgaz.viewHeight == 60)
        scale *= 1;
    if (self.modes["noclip"])
        scale *= 3;
    else
        scale *= self pm_cmdScaleForStance();
    return scale * self.moveSpeedScale;
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
    return 0;
}

pm_damageScaleWalk(damageTimer)
{
    return 1;
}

pm_accelerate(wishspeed, accel)
{
    self update_d(wishspeed, accel, 0);
}

pm_slickAccelerate(wishspeed, accel)
{
    self update_d(wishspeed, accel, self.gravity * self.cgaz.frameTime);
}

pm_airMove()
{
    self.cgaz.forward = vectorNormalize((self.cgaz.forward[0], self.cgaz.forward[1], 0));
    self.cgaz.right = vectorNormalize((self.cgaz.right[0], self.cgaz.right[1], 0));

    for (i = 0; i < 2; i++)
    {
        self.cgaz.forwardMove = self getForwardMove();
        self.cgaz.rightMove = self getRightMove();

        self.cgaz.wishvel[i] = self.cgaz.forwardMove * self.cgaz.forward[i] + 
            self.cgaz.rightMove * self.cgaz.right[i];
    }

    scale = self pm_cmdScale();
    wishspeed = scale * m_vector_length2(self.cgaz.wishvel);
	self pm_accelerate(wishspeed, 9);
}

update_d(wishspeed, accel, slickGravity)
{
    self.cgaz.g_squared = slickGravity * slickGravity;
    self.cgaz.v_squared = length_squared2(self.cgaz.previousVelocity);
    self.cgaz.vf_squared = length_squared2(self.cgaz.velocity);
    self.cgaz.wishspeed = wishspeed;
    self.cgaz.a = accel * self.cgaz.wishspeed * self.cgaz.frameTime;
    self.cgaz.a_squared = self.cgaz.a * self.cgaz.a;

    if (self.cgaz.v_squared - self.cgaz.vf_squared >= 2 * self.cgaz.a * self.cgaz.wishspeed - self.cgaz.a_squared)
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

    if (num >= self.cgaz.vf)
        return 0;
    return acos1(num / self.cgaz.vf);
}

update_d_opt()
{
    num = self.cgaz.wishspeed - self.cgaz.a;

    if (num >= self.cgaz.vf)
        return 0;
    return acos1(num / self.cgaz.vf);
}

update_d_max_cos(d_opt)
{
    num = sqrt(self.cgaz.v_squared - self.cgaz.g_squared) - self.cgaz.vf;

    d_max_cos = 0;
    if (!(num >= self.cgaz.a))
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

fillAngleYaw(screen, start, end, yaw, y, h)
{
    range = angleToRange(screen, start, end, yaw);

    if (!range.split)
        self fillRect(screen, range.x1, y, range.x2 - range.x1, h);
    else
    {
        self fillRect(screen, 0, y, range.x1, h);
        self fillRect(screen, range.x2, y, 640 - range.x2, h);
    }
}

fillRect(screen, x, y, w, h)
{
    adjust = screen adjustFrom640(x, y, w, h);

    x = adjust.x;
    y = adjust.y;
    w = adjust.w;
    h = adjust.h;

    wSign = w >= 0;

    x = int(x);
    y = int(y);
    w = int(abs(w));
    h = int(abs(h));

    if (!w || !h)
    {
        self.alpha = 0;
        return;
    }
    
    self setShader("white", w, h);
    self.alpha = 0.5;
    self.x = x;
    self.y = y;
}

adjustFrom640(x, y, w, h)
{
    adjust = spawnStruct();
    scale = self.width / 640;

    adjust.x = x * scale;
    adjust.y = y * scale;
    adjust.w = w * scale;
    adjust.h = h * scale;

    return adjust;
}

angleToRange(screen, start, end, yaw)
{
    range = spawnStruct();

    if (abs(end - start) > 2 * pi())
    {
        range.x1 = 0;
        range.x2 = 640;
        range.split = false;
        return range;
    }

    split = end > start;
    start = angle_normalize_pi(start - yaw);
    end	= angle_normalize_pi(end - yaw);

    if (end > start)
    {
        split = !split;

        tmp = start;
        start = end;
        end	= tmp;
    }

    range.x1 = screen angleScreenProjection(start);
    range.x2 = screen angleScreenProjection(end);
    range.split = split;
    return range;
}

angleScreenProjection(angle)
{
    playerFov = 80;
    halfTanY = tan(playerFov * 0.01745329238474369 * 0.5) * 0.75;
    halfTanX = halfTanY * (self.width / self.height);
    halfFovX = atan(halfTanX); // @TODO wrong fov

    if (angle >= halfFovX)
        return 0;
        
    if (angle <= neg(halfFovX))
        return 640;
        
    return 640 / 2 * (1 - tan(angle) / tan(halfFovX));
}

angle_normalize_pi(angle)
{
    t_angle = fmod(angle + pi(), 2 * pi());

    if (t_angle < 0)
        return t_angle + pi();
    return t_angle - pi();
}

length_squared2(vec)
{
    return vec[0] * vec[0] + vec[1] * vec[1];
}

m_vector_length2(vec)
{
    return sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
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
