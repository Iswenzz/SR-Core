#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.weapons = [];

	event("spawn", ::onSpawn);
	event("connect", ::onConnect);

	addWeapon(::RPG);
	addWeapon(::FortniteRPG);
	addWeapon(::Q3Rocket);
	addWeapon(::Q3Plasma);
}

RPG()
{
	weapon["type"] = "stock";
	weapon["name"] = "RPG";
	weapon["item"] = "bt_rpg_mp";
	weapon["projectile"] = "projectile_rpg7";
	weapon["muzzle"] = loadFX("muzzleflashes/at4_flash");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("smoke/smoke_geotrail_rpg");
	weapon["sfx_fire"] = "weap_rpg_fire_plr";
	weapon["sfx_trail"] = "weap_rpg_loop";
	weapon["sfx_impact"] = "weap_rpg_loop";
	weapon["damage"] = 200;
	weapon["knockback"] = 500;
	weapon["knockback_range"] = 140;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

	return weapon;
}

FortniteRPG()
{
	weapon["type"] = "stock";
	weapon["name"] = "Fortnite RPG";
	weapon["item"] = "fn_rpg_mp";
	weapon["projectile"] = "projectile_rpg7";
	weapon["muzzle"] = loadFX("muzzleflashes/at4_flash");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("smoke/smoke_geotrail_rpg");
	weapon["sfx_fire"] = "weap_rpg_fire_plr";
	weapon["sfx_trail"] = "weap_rpg_loop";
	weapon["sfx_impact"] = "weap_rpg_loop";
	weapon["damage"] = 200;
	weapon["knockback"] = 500;
	weapon["knockback_range"] = 140;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

	return weapon;
}

Q3Rocket()
{
	weapon["type"] = "script";
	weapon["name"] = "Q3 Rocket";
	weapon["item"] = "gl_ak47_mp";
	weapon["delay"] = 0.8;
	weapon["projectile"] = "quake_rocket_projectile";
	weapon["muzzle"] = loadFX("muzzleflashes/m203_flshview");
	weapon["impact"] = loadFX("explosions/grenadeExp_default");
	weapon["trail"] = loadFX("q3/rocket_trail");
	weapon["sfx_fire"] = "weap_quake_rocket_shoot";
	weapon["sfx_trail"] = "weap_quake_rocket_loop";
	weapon["sfx_impact"] = "weap_quake_rocket_explode";
	weapon["damage"] = 200;
	weapon["knockback"] = 500;
	weapon["knockback_range"] = 120;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

	return weapon;
}

Q3Plasma()
{
	weapon["type"] = "script";
	weapon["name"] = "Q3 Plasma";
	weapon["item"] = "gl_g3_mp";
	weapon["delay"] = 0.05;
	weapon["projectile"] = "tag_origin";
	weapon["muzzle"] = loadFX("muzzleflashes/mist_mk2_flashview");
	weapon["trail"] = loadFX("q3/plasma_fire");
	weapon["sfx_fire"] = "weap_quake_plasma_shoot";
	weapon["sfx_trail"] = "weap_quake_plasma_loop";
	weapon["sfx_impact"] = "weap_quake_plasma_explode";
	weapon["damage"] = 20;
	weapon["knockback"] = 30;
	weapon["knockback_range"] = 40;
	weapon["fire"] = ::fire;
	weapon["fire_condition"] = ::canFireWeapon;

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
	self.scriptedBullets = 0;
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		if (!self isReallyAlive() || !self playerHasWeapon())
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
	hitPlayers = !bullet.run;
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
	speed = 1500;
	time = length(fxpos - p) / speed * 1.5;

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
	if (self.run)
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

	if (self.run)
		self.player endon("death");

	self waittill("impact");
}

impactCleanup()
{
	self impactWaittill();

	if (isDefined(self.model))
		self.model delete();

	self.player.scriptedBullets--;
}

damage()
{
	self.player endon("disconnect");
	self.player endon("death");

	position = self.trace["position"];
	range = self.weapon["knockback_range"];
	damage = self.weapon["damage"];
	knockback = Ternary(self.run || self.player.teamKill, self.weapon["knockback"], 0);

	self.player doRadiusDamage(position, range, damage, knockback);
	self runKnockback();
}

runKnockback()
{
	if (!self.run)
		return;

	position = self.trace["position"];
	range =  self.weapon["knockback_range"];
	knockback = self.weapon["knockback"];
	direction = self.player eyePos() - position;
	distance = int(distance(position, self.player.origin));
	multiplier = 2;

	if (distance > range)
		return;

	self.player bounce(position, direction, knockback, multiplier);
}

trailFX()
{
	if (isDefined(self.model))
	{
		self.model.angles = self.player getPlayerAngles();
		if (isDefined(self.weapon["sfx_trail"]) && self.run)
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
	self endon("disconnect");

	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return true;
	}
	return false;
}

getPlayerWeapon()
{
	self endon("disconnect");

	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return level.weapons[i];
	}
	return undefined;
}

isRun()
{
	return self isDefrag() || self isPortal();
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
	bullet.run = player isRun();

	if (isDefined(bullet.weapon["projectile"]))
	{
		bullet.model = spawn("script_model", player eyepos());
		bullet.model setContents(0);
		bullet.model setModel(bullet.weapon["projectile"]);

		if (bullet.run)
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
	if (self sr\game\_perks::playerHasPerk("haste"))
		delay /= 1.3;
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
	if (self.scriptedBullets >= 100)
		return false;
	if (!self attackButtonPressed() && !self demoButton("fire"))
		return false;
	if (self.scriptedWeapon["type"] == "stock")
		self waitStockFireAnimation();
	return self isSameWeapon();
}
