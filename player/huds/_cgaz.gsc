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
        self.cgaz.previousVelocity = self getVelocity();

        wait 0.05;
        if (m_vector_length2(self getVelocity()) >= 1)
        {
            self pmove();
            self draw();
        }
    }
}

draw()
{
    size = (100, 12, 0);
    yaw = atan2(self.cgaz.wishvel[1], self.cgaz.wishvel[0]) - self.cgaz.d_vel;

    self.huds["cgaz"]["accel"] fillAngleYaw(neg(self.cgaz.d_min), pos(self.cgaz.d_min), yaw, size[0], size[1]);
    self.huds["cgaz"]["accelPartialPos"] fillAngleYaw(pos(self.cgaz.d_min), pos(self.cgaz.d_opt), yaw, size[0], size[1]);
    self.huds["cgaz"]["accelPartialNeg"] fillAngleYaw(neg(self.cgaz.d_opt), neg(self.cgaz.d_min), yaw, size[0], size[1]);
    self.huds["cgaz"]["accelFullPos"] fillAngleYaw(pos(self.cgaz.d_opt), pos(self.cgaz.d_max_cos), yaw, size[0], size[1]);
    self.huds["cgaz"]["accelFullNeg"] fillAngleYaw(neg(self.cgaz.d_max_cos), neg(self.cgaz.d_opt), yaw, size[0], size[1]);
    self.huds["cgaz"]["turnZonePos"] fillAngleYaw(pos(self.cgaz.d_max_cos), pos(self.cgaz.d_max), yaw, size[0], size[1]);
    self.huds["cgaz"]["turnZoneNeg"] fillAngleYaw(neg(self.cgaz.d_max), neg(self.cgaz.d_max_cos), yaw, size[0], size[1]);
}

cgazHud()
{
    self.cgaz = spawnStruct();
    self.cgaz.wishvel = [];
    self.cgaz.moveForward = 0;
    self.cgaz.moveRight = 0;
    self.huds["cgaz"] = [];

    self.huds["cgaz"]["accel"] = addHud(self, 0, 0, 0.5, "right", "middle");
    self.huds["cgaz"]["accel"].color = (0.25, 0.25, 0.25);
    self.huds["cgaz"]["accel"].archived = false;
    self.huds["cgaz"]["accel"].hidewheninmenu = true;

    self.huds["cgaz"]["accelPartialPos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelPartialPos"].color = (0, 1, 0);
    self.huds["cgaz"]["accelPartialPos"].archived = false;
    self.huds["cgaz"]["accelPartialPos"].hidewheninmenu = true;

    self.huds["cgaz"]["accelPartialNeg"] = addHud(self, 0, 0, 0.5, "right", "middle");
    self.huds["cgaz"]["accelPartialNeg"].color = (0, 1, 0);
    self.huds["cgaz"]["accelPartialNeg"].archived = false;
    self.huds["cgaz"]["accelPartialNeg"].hidewheninmenu = true;

    self.huds["cgaz"]["accelFullPos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["accelFullPos"].color = (0, 0.25, 0.25);
    self.huds["cgaz"]["accelFullPos"].archived = false;
    self.huds["cgaz"]["accelFullPos"].hidewheninmenu = true;

    self.huds["cgaz"]["accelFullNeg"] = addHud(self, 0, 0, 0.5, "right", "middle");
    self.huds["cgaz"]["accelFullNeg"].color = (0, 0.25, 0.25);
    self.huds["cgaz"]["accelFullNeg"].archived = false;
    self.huds["cgaz"]["accelFullNeg"].hidewheninmenu = true;

    self.huds["cgaz"]["turnZonePos"] = addHud(self, 0, 0, 0.5, "left", "middle");
    self.huds["cgaz"]["turnZonePos"].color = (1, 1, 0);
    self.huds["cgaz"]["turnZonePos"].archived = false;
    self.huds["cgaz"]["turnZonePos"].hidewheninmenu = true;

    self.huds["cgaz"]["turnZoneNeg"] = addHud(self, 0, 0, 0.5, "right", "middle");
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
    self.cgaz.frameTime = 1 / 125;
    self.cgaz.viewHeight = int(eye()[2]);

    comPrintLn("forward: %f %f %f", self.cgaz.forward[0], self.cgaz.forward[1], self.cgaz.forward[2]);

    if (!self.cgaz.moveForward && !self.cgaz.moveRight)
        self.cgaz.moveForward = 127;

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
        self.cgaz.moveForward = Ternary(self forwardButtonPressed(), 127, 0);
        self.cgaz.moveRight = Ternary(self moveRightButtonPressed(), 127, 0);

        self.cgaz.wishvel[i] = self.cgaz.moveForward * self.cgaz.forward[i] + 
            self.cgaz.moveRight * self.cgaz.right[i];
    }

    dmgScale = self pm_damageScaleWalk(1) * self pm_cmdScaleWalk();
    wishSpeed = dmgScale * m_vector_length2(self.cgaz.wishvel);

    comPrintLn("speed: %f %f %f", float(dmgScale), float(wishSpeed), m_vector_length2(self.cgaz.wishvel));

    // @TODO knockback / slick
    if (false)
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

    max = abs(self.cgaz.moveForward);
    if (abs(self.cgaz.moveRight) > max)
        max = abs(self.cgaz.moveRight);
    if (!max)
        return 0;

    total = sqrt(self.cgaz.moveRight * self.cgaz.moveRight + 
        self.cgaz.moveForward * self.cgaz.moveForward);

    scale = self.speed * max / (total * 127);
    if (self.modes["noclip"])
        scale *= 3;
    if (self.sessionstate == "spectator")
        scale *= spectateSpeedScale;
    return scale;
}

pm_cmdScaleWalk()
{
    total = sqrt(self.cgaz.moveRight * self.cgaz.moveRight + 
        self.cgaz.moveForward * self.cgaz.moveForward);

    speed = 0;
    if (self.cgaz.moveForward >= 0)
        speed = abs(self.cgaz.moveForward);
    else
        speed = abs(self.cgaz.moveForward * 1);
    if (speed - abs(self.cgaz.moveRight * 1) < 0)
        speed = abs(self.cgaz.moveRight * 1);
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
    comPrintLn("scale: %f %f %f", self.moveSpeedScale, speed, scale);
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
        self.cgaz.moveForward = Ternary(self forwardButtonPressed(), 127, 0);
        self.cgaz.moveRight = Ternary(self moveRightButtonPressed(), 127, 0);

        self.cgaz.wishvel[i] = self.cgaz.moveForward * self.cgaz.forward[i] + 
            self.cgaz.moveRight * self.cgaz.right[i];
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

    comPrintLn("accel: %f %f %f", float(accel), float(self.cgaz.wishspeed), self.cgaz.frameTime);

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

    return Ternary(num >= self.cgaz.vf, 0, acos2(num / self.cgaz.vf));
}

update_d_opt()
{
    num = self.cgaz.wishspeed - self.cgaz.a;

    return Ternary(num >= self.cgaz.vf, 0, acos2(num / self.cgaz.vf));
}

update_d_max_cos(d_opt)
{
    num = sqrt(self.cgaz.v_squared - self.cgaz.g_squared) - self.cgaz.vf;
    d_max_cos = Ternary(num >= self.cgaz.a, 0, acos2(num / self.cgaz.a));
    
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

    d_max = acos2(num / den);

    if (d_max < d_max_cos)
        d_max = d_max_cos;
    return d_max;
}

fillAngleYaw(start, end, yaw, y, h, color)
{
    range = angleToRange(start, end, yaw);

    if (!range.split)
        self fillRect(range.x1, y, range.x2 - range.x1, h, color);
    else
    {
        self fillRect(0, y, range.x1, h, color);
        self fillRect(range.x2, y, 640 - range.x2, h, color);
    }
}

fillRect(x, y, w, h, color)
{
    wNeg = w < 0;
    hNeg = h < 0;

    x = int(x);
    y = int(y);
    w = int(abs(w));
    h = int(abs(h));

    iPrintLnBold(fmt("%d %d %d %d", x, y, w, h));

    if (!w || !h)
        return;
    
    self setShader("white", w, h);
    self.x = x;
    self.y = y;
}

angleToRange(start, end, yaw)
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

    range.x1 = angleScreenProjection(start);
    range.x2 = angleScreenProjection(end);
    range.split = split;
    return range;
}

angleScreenProjection(angle)
{
    halfTanY = tan(80 * 0.01745329238474369 * 0.5) * 0.75;
    halfTanX = halfTanY * (640 / 480);
    half_fov_x = atan(halfTanX);

    if (angle >= half_fov_x)
        return 0;
        
    if (angle <= neg(half_fov_x))
        return 640;
        
    return 640 / 2 * (1 - tan(angle) / tan(half_fov_x));
}

angle_normalize_pi(angle)
{
    t_angle = fmod(angle + pi(), 2 * pi());
    return Ternary(t_angle < 0, t_angle + pi(), t_angle - pi());
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
