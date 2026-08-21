#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.weapons = [];

	event("spawn", ::onSpawn);
	event("connect", ::onConnect);

	addWeapon(::weapon_RPG);
	addWeapon(::weapon_FortniteRPG);
	addWeapon(::weapon_Q3Rocket);
	addWeapon(::weapon_Q3Plasma);
}

weapon_RPG()
{
	weapon["type"] = "stock";
	weapon["name"] = "RPG";
	weapon["item"] = "m60e4_reflex_mp";
	weapon["projectile"] = "projectile_rpg7";
	weapon["muzzle"] = loadFX("muzzleflashes/at4_flash");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("smoke/smoke_geotrail_rpg");
	weapon["sfx_fire"] = "weap_rpg_fire_plr";
	weapon["sfx_trail"] = "weap_rpg_loop";
	weapon["sfx_impact"] = "weap_rpg_loop";
	weapon["damage"] = 100;
	weapon["knockback"] = 100;
	weapon["knockback_range"] = 140;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

	return weapon;
}

weapon_FortniteRPG()
{
	weapon["type"] = "stock";
	weapon["name"] = "Fortnite RPG";
	weapon["item"] = "m60e4_acog_mp";
	weapon["projectile"] = "projectile_rpg7";
	weapon["muzzle"] = loadFX("muzzleflashes/at4_flash");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("smoke/smoke_geotrail_rpg");
	weapon["sfx_fire"] = "weap_rpg_fire_plr";
	weapon["sfx_trail"] = "weap_rpg_loop";
	weapon["sfx_impact"] = "weap_rpg_loop";
	weapon["damage"] = 100;
	weapon["knockback"] = 100;
	weapon["knockback_range"] = 140;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

	return weapon;
}

weapon_Q3Rocket()
{
	weapon["type"] = "q3";
	weapon["name"] = "Q3 Rocket";
	weapon["item"] = "gl_ak47_mp";
	weapon["delay"] = 0.8;
	weapon["speed"] = 900;
	weapon["projectile"] = "quake_rocket_projectile";
	weapon["muzzle"] = loadFX("muzzleflashes/m203_flshview");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("q3/rocket_trail");
	weapon["sfx_fire"] = "weap_quake_rocket_shoot";
	weapon["sfx_impact"] = "weap_quake_rocket_explode";
	weapon["damage"] = 100;
	weapon["knockback"] = 100;
	weapon["knockback_range"] = 120;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireQ3Weapon;

	return weapon;
}

weapon_Q3Plasma()
{
	weapon["type"] = "q3";
	weapon["name"] = "Q3 Plasma";
	weapon["item"] = "gl_g3_mp";
	weapon["delay"] = 0.1;
	weapon["speed"] = 2000;
	weapon["projectile"] = "tag_origin";
	weapon["muzzle"] = loadFX("muzzleflashes/mist_mk2_flashview");
	weapon["trail"] = loadFX("q3/plasma_fire");
	weapon["sfx_fire"] = "weap_quake_plasma_shoot";
	weapon["sfx_impact"] = "weap_quake_plasma_explode";
	weapon["damage"] = 20;
	weapon["knockback"] = 20;
	weapon["knockback_range"] = 20;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireQ3Weapon;

	return weapon;
}

addWeapon(callback)
{
	weapon = [[callback]]();

	weapon["type"] = IfUndef(weapon["type"], "stock");
	weapon["item"] = IfUndef(weapon["item"], "undefined");
	weapon["predelay"] = IfUndef(weapon["predelay"], 0);
	weapon["delay"] = IfUndef(weapon["delay"], 0);
	weapon["damage"] = IfUndef(weapon["damage"], 0);
	weapon["knockback"] = IfUndef(weapon["knockback"], 0);
	weapon["knockback_range"] = IfUndef(weapon["knockback_range"], 0);
	weapon["fire_condition"] = IfUndef(weapon["fire_condition"], ::noopFalse);
	weapon["ads_condition"] = IfUndef(weapon["ads_condition"], ::noopFalse);
	weapon["melee_condition"] = IfUndef(weapon["melee_condition"], ::noopFalse);
	weapon["frag_condition"] = IfUndef(weapon["frag_condition"], ::noopFalse);
	weapon["use_condition"] = IfUndef(weapon["use_condition"], ::noopFalse);
	weapon["frame"] = IfUndef(weapon["frame"], ::noop);

	if (isDefined(weapon["projectile"]))
		precacheModel(weapon["projectile"]);

	level.weapons[level.weapons.size] = weapon;
}

onConnect()
{
	self.forceWeaponVisual = false;
	self.forceWeaponKnockback = false;
	self.forceWeaponHitPlayers = false;
	self.scriptedBullets = 0;
	self.scriptedAmmo = 0;
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		if (!self isPlaying() || !self playerHasWeapon())
		{
			wait 0.05;
			continue;
		}
		self.scriptedWeapon = self getPlayerWeapon();

		if (self [[self.scriptedWeapon["fire_condition"]]]())
			self [[self.scriptedWeapon["fire"]]]();
		wait 0.05;
	}
}

fire()
{
	weapon = self.scriptedWeapon;
	bullet = weapon createBullet(self);

	wait self firePreDelay(weapon);

	eye = self eyePos();
	forward = anglesToForward(self getPlayerAngles()) * 999999;
	hitPlayers = self shouldHitPlayers();
	trace = bulletTrace(eye, eye + forward, hitPlayers, self);

	pos = trace["position"];
	normal = trace["normal"];
	angles = vectorToAngles(normal);
	right = anglesToRight(angles);
	up = anglesToUp(angles);

	trace["position"] = pos;
	trace["fx_position"] = pos + normal;
	trace["start_position"] = eye;
	trace["old_position"] = pos;
	trace["angles"] = angles;
	trace["up"] = up;
	bullet.trace = trace;

	oldpos = trace["old_position"];
	fxpos = trace["fx_position"];
	p = trace["start_position"];
	p += vectorNormalize(oldpos - p) * 33;
	speed = IfUndef(weapon["speed"], 1000);
	time = length(fxpos - p) / speed;

	if (isDefined(weapon["sfx_fire"]))
		self playSoundToPlayer(weapon["sfx_fire"], self);
	bullet thread trailFX();
	bullet.model moveTo(trace["position"], time);
	bullet thread impact(time);

	wait self fireDelay(weapon);
}

impact(time)
{
	self.player endon("disconnect");
	if (self.player isQ3())
		self.player endon("death");

	self thread impactCleanup();

	wait time;

	if (isDefined(self.model))
	{
		self.model.origin = self.trace["position"];
		self.model.angles = self.trace["angles"];
		self.model stopLoopSound();

		if (isDefined(self.weapon["sfx_impact"]))
			self.model playSound(self.weapon["sfx_impact"]);
		if (isDefined(self.weapon["impact"]))
			playFXOnTag(self.weapon["impact"], self.model, "tag_origin");
	}

	self thread damage();
	wait 0.05;
	self notify("impact");
}

impactWaittill()
{
	self.player endon("disconnect");
	if (self.player isQ3())
		self.player endon("death");

	self waittill("impact");
}

impactCleanup()
{
	self impactWaittill();

	if (isDefined(self.model))
		self.model delete();
	if (isDefined(self.player))
		self.player.scriptedBullets--;
}

damage()
{
	self.player endon("disconnect");
	self.player endon("death");

	position = self.trace["fx_position"];
	range = self.weapon["knockback_range"];
	damage = self.weapon["damage"];
	knockbackPlayers = self.player shouldKnockback();
	knockback = Ternary(knockbackPlayers, self.weapon["knockback"], 0);

	self.player doRadiusDamage(position, range, damage, knockback);
	self knockback();
}

knockback()
{
	if (!self.player shouldKnockback())
		return;

	position = self.trace["fx_position"];
	range = self.weapon["knockback_range"];
	knockback = self.weapon["knockback"];
	origin = self.player.origin;

	if (isDefined(self.player.instantBullet))
		self.player cheat();

	// Blast resolves a frame late, inflating distance at speed. Scalar only,
	// so push direction is untouched. Capped so small splashes stay small.
	dist = bboxDistanceAt(origin, position);
	slack = length(self.player getVelocity()) * 0.05;
	maxSlack = range * 0.5;
	if (slack > maxSlack)
		slack = maxSlack;

	dist -= slack;
	if (dist < 0)
		dist = 0;

	if (dist > range)
		return;

	// Q3: dir = player center - explosion, +24 up (center is +35 on cod4 feet origin)
	direction = origin + (0, 0, 59) - position;

	kb = int(knockback * (1 - dist / (range * 1.0)));
	if (kb < 1)
		return;

	self.player bounce(position, direction, kb);
}

trailFX()
{
	if (isDefined(self.model))
	{
		self.model.angles = self.player getPlayerAngles();
		if (isDefined(self.weapon["sfx_trail"]) && self.player showVisual())
			self.model playLoopSound(self.weapon["sfx_trail"]);
	}
	wait 0.05;

	if (isDefined(self.model))
	{
		if (isDefined(self.weapon["muzzle"]))
			playFXOnTag(self.weapon["muzzle"], self.model, "tag_origin");
		if (isDefined(self.weapon["trail"]))
			playFXOnTag(self.weapon["trail"], self.model, "tag_origin");
	}
}

playerHasWeapon()
{
	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return true;
	}
	return false;
}

getPlayerWeapon()
{
	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return level.weapons[i];
	}
	return undefined;
}

isSameWeapon()
{
	weapon = self.scriptedWeapon;
	current = self getPlayerWeapon();

	return isDefined(weapon) && isDefined(current) && current["item"] == weapon["item"];
}

createBullet(player)
{
	player.scriptedBullets++;

	bullet = spawnStruct();
	bullet.weapon = self;
	bullet.player = player;

	if (isDefined(bullet.weapon["projectile"]))
	{
		bullet.model = spawn("script_model", player eyePos());
		bullet.model setContents(0);
		bullet.model setModel(bullet.weapon["projectile"]);

		if (!player showVisual())
		{
			bullet.model hide();
			bullet.model showToPlayer(player);
		}
	}
	return bullet;
}

waitStockFireAnimation()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");
	self endon("weapon_change");
	self waittill("weapon_fired");
}

fireDelay(weapon)
{
	if (isDefined(self.instantBullet))
		return 0;

	delay = weapon["delay"];
	if (self sr\core\_perks::playerHasPerk("haste"))
		delay /= 1.3;
	delay -= 0.05;
	if (delay < 0.05)
		delay = 0;
	return delay;
}

firePreDelay(weapon)
{
	if (isDefined(self.instantBullet))
		return 0;

	delay = weapon["predelay"];
	if (delay < 0.05)
		delay = 0;
	return delay;
}

canFireWeapon()
{
	if (!isDefined(self.scriptedWeapon["fire"]))
		return false;
	if (!self getWeaponAmmoClip(self.scriptedWeapon["item"]))
		return false;
	if (!self attackButtonPressed() && !self demoButton("fire"))
		return false;
	if (self.scriptedBullets >= 100)
		return false;
	if (self.scriptedWeapon["type"] == "stock")
	{
		self waitStockFireAnimation();
		return self isSameWeapon();
	}
	return true;
}

canFireQ3Weapon()
{
	if (!isDefined(self.scriptedWeapon["fire"]))
		return false;
	if (!self.scriptedAmmo)
		return false;
	if (!self attackButtonPressed() && !self demoButton("fire"))
		return false;
	if (self.scriptedBullets >= 100)
		return false;
	self.scriptedAmmo--;
	return true;
}

showVisual()
{
	return self.forceWeaponVisual || !self isQ3();
}

shouldKnockback()
{
	return self.forceWeaponKnockback || self.teamKill || self isQ3();
}

shouldHitPlayers()
{
	return self.forceWeaponHitPlayers || self.teamKill || !self isQ3();
}
