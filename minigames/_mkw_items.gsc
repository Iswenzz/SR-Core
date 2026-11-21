#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

// Mario Kart's items for whoever races: taken from a course's item boxes, drawn by a roulette with the game's
// own odds for the place held, used with the fire button and thrown where the camera looks. What follows the
// road in the game follows the course's own item line here (level.iz_route).
main()
{
	level.mkItems = [];
	// The game's table for a race: how often out of 200 each place draws it, first to twelfth.
	item("green_shell", 1, "65 35 25 15 5 0 0 0 0 0 0 0");
	item("red_shell", 1, "0 50 45 40 25 15 10 0 0 0 0 0");
	item("banana", 1, "75 35 20 5 5 0 0 0 0 0 0 0");
	item("fake_box", 1, "35 20 10 5 0 0 0 0 0 0 0 0");
	item("mushroom", 1, "0 20 35 45 35 30 20 15 5 0 0 0");
	item("triple_mushroom", 3, "0 0 5 15 30 45 55 65 75 65 45 15");
	item("bobomb", 1, "0 5 10 15 10 10 0 0 0 0 0 0");
	item("blue_shell", 1, "0 0 0 5 10 15 15 10 5 0 0 0");
	item("lightning", 1, "0 0 0 0 0 0 0 0 0 0 0 45");
	item("star", 1, "0 0 0 0 0 0 10 25 35 50 45 35");
	item("golden_mushroom", 1, "0 0 0 0 0 5 20 40 50 70 70 40");
	item("mega_mushroom", 1, "0 0 0 5 15 20 20 10 10 0 0 0");
	item("blooper", 1, "0 0 0 0 10 10 10 10 10 0 0 0");
	item("pow", 1, "0 0 0 0 10 10 15 10 10 0 0 0");
	item("mega_cloud", 1, "0 0 10 15 15 15 10 5 0 0 0 0");
	item("bullet", 1, "0 0 0 0 0 0 0 0 0 15 40 65");
	item("triple_green", 3, "0 10 20 20 10 5 0 0 0 0 0 0");
	item("triple_red", 3, "0 0 5 10 20 20 15 10 0 0 0 0");
	item("triple_banana", 3, "25 25 15 5 0 0 0 0 0 0 0 0");

	// The game's own spread of its twelve places over fewer racers (StaticR.rel, ItemSlotData's
	// PostProcessVSTable at 807bad20): with n racing, each place draws from the twelve-racer place named here.
	places = [];
	places[1] = "1";
	places[2] = "1 4";
	places[3] = "1 3 6";
	places[4] = "1 3 6 9";
	places[5] = "1 3 5 7 10";
	places[6] = "1 3 5 7 9 11";
	places[7] = "1 3 5 7 9 10 12";
	places[8] = "1 2 4 6 7 9 10 12";
	places[9] = "1 2 4 5 7 8 9 11 12";
	places[10] = "1 2 3 5 6 7 8 10 11 12";
	places[11] = "1 2 3 4 5 7 8 9 10 11 12";
	places[12] = "1 2 3 4 5 6 7 8 9 10 11 12";
	level.mkPlaces = [];
	for (n = 1; n <= 12; n++)
	{
		level.mkPlaces[n] = [];
		named = strTok(places[n], " ");
		for (i = 0; i < named.size; i++)
			level.mkPlaces[n][i] = int(named[i]) - 1;
	}
	// Counted up each time a race ends, so what is still out from one knows to go.
	level.mkRound = 0;

	// What the whole race feels is not drawn twice in a row: how long after one before the next, and none
	// of them in a race's first half minute.
	level.mkRare = [];
	level.mkRare["lightning"] = 30000;
	level.mkRare["blue_shell"] = 20000;
	level.mkRare["pow"] = 20000;
	level.mkRare["blooper"] = 15000;
	level.mkLast = [];

	// The limits what is used runs under, in units a second: a star, a mega mushroom, a bullet, a cloud.
	level.mkStar = 1860;
	level.mkMega = 1683;
	level.mkBullet = 2569;
	level.mkCloud = 1637;

	level.mkModels = [];
	level.mkModels["banana"] = "mkw_item_banana";
	level.mkModels["green"] = "mkw_item_green_shell";
	level.mkModels["red"] = "mkw_item_red_shell";
	level.mkModels["blue"] = "mkw_item_blue_shell";
	level.mkModels["bobomb"] = "mkw_item_bobomb";
	level.mkModels["fake"] = "mkw_item_fake_box";
	level.mkModels["fake_mark"] = "mkw_item_fake_box_mark";
	level.mkModels["bullet"] = "mkw_item_bullet";
	level.mkModels["cloud"] = "mkw_item_cloud";
	level.mkModels["bolt"] = "mkw_item_bolt";
	keys = getArrayKeys(level.mkModels);
	for (i = 0; i < keys.size; i++)
		precacheModel(level.mkModels[keys[i]]);
	for (i = 0; i < level.mkItems.size; i++)
		precacheShader("mkw_icon_" + level.mkItems[i].icon);
	precacheShader("black");
	precacheShader("white");

	level.mkFx = [];
	level.mkFx["burst"] = loadFx("explosions/grenadeExp_default");
	level.mkFx["big"] = loadFx("explosions/aerial_explosion");
	level.mkFx["puff"] = loadFx("impacts/20mm_default_impact");
	level.mkFx["spark"] = loadFx("speedrun/wr_fx");
	level.mkFx["foot_boost"] = loadFx("mkw/foot_boost");
	level.mkFx["cloud"] = loadFx("mkw/cloud");

	level.mkFx["flash"] = loadFx("explosions/grenade_flash");

	level.mkThings = [];
	level.mkRoute = [];
	level.mkLine = undefined;
	event("map", ::boxes);
	event("spawn", ::farSide);
}

item(name, uses, odds)
{
	entry = spawnStruct();
	entry.name = name;
	entry.icon = name;
	entry.uses = uses;
	entry.odds = [];
	places = strTok(odds, " ");
	for (i = 0; i < places.size; i++)
		entry.odds[i] = int(places[i]);

	// Retro Rewind's cloud, under the picture the game has for its own.
	if (name == "mega_cloud")
	{
		entry.icon = "thunder_cloud";
		level.mkCloudItem = level.mkItems.size;
	}
	level.mkItems[level.mkItems.size] = entry;
}

named(name)
{
	for (i = 0; i < level.mkItems.size; i++)
	{
		if (level.mkItems[i].name == name)
			return i;
	}
	return undefined;
}

// A course's item boxes hide themselves when run through; a racer beside one that just hid took it.
// A map with no item box hands a racer an item every so often instead.
boxes()
{
	wait 3;
	route();
	boxes = getEntArray("iz_itembox", "targetname");
	for (i = 0; i < boxes.size; i++)
		boxes[i] thread box();
	level.mkBoxes = boxes.size;
}

box()
{
	reach = 60;
	if (isDefined(self.radius))
		reach = self.radius;

	for (;;)
	{
		while (!isDefined(self.iz_taken))
			wait 0.05;

		racers = level.minigames["mkw"].queue;
		for (i = 0; i < racers.size; i++)
		{
			if (isAlive(racers[i]) && racers[i] rolls() && distance(racers[i].origin + (0, 0, 35), self.origin) < reach + 80)
				racers[i] thread roll();
		}
		while (isDefined(self.iz_taken))
			wait 0.05;
	}
}

// Items are a race's: none is drawn before its start, after its end, or once over the line.
rolls()
{
	return isDefined(level.mkRace) && level.mkRace.started && isDefined(self.mkRacing) && !isDefined(self.mkDone);
}

// The course's item line, each point put down on the road under it or, where it lies below, over it.
route()
{
	level.mkRoute = [];
	if (!isDefined(level.iz_route))
		return;

	for (i = 0; i < level.iz_route.size; i++)
	{
		spot = level.iz_route[i];
		down = bulletTrace(spot + (0, 0, 40), spot - (0, 0, 6000), false, undefined);
		if (down["fraction"] < 1)
			spot = down["position"];
		else
		{
			up = bulletTrace(spot, spot + (0, 0, 3000), false, undefined);
			if (up["fraction"] < 1)
				spot = up["position"] + (0, 0, 8);
		}
		level.mkRoute[i] = spot;
	}

	// Where the course's line crosses the route. Its trigger stands far taller than the road: its height is the grid's.
	finish = getEntArray("iz_finish", "targetname");
	if (level.mkRoute.size > 3 && finish.size)
	{
		spot = finish[0] getOrigin();
		if (isDefined(level.spawn["player"]))
			spot = (spot[0], spot[1], level.spawn["player"].origin[2]);
		on = routeOn(spot);
		level.mkLine = on[0] + on[1];
	}
}

// The line is right by the start, so a lap needs the far side of the course first: crossing it backwards and
// forwards again, or straight from the grid, is no lap however few gates a course has.
farSide()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	// A racer put back after a fall keeps the lap they were on.
	if (!self sr\minigames\_mkw_race::racing())
		self.mkFar = undefined;
	if (!isDefined(level.iz_route))
		return;
	for (;;)
	{
		wait 0.25;
		if (isDefined(self.mkFar) || !isDefined(level.mkLine))
			continue;
		on = routeOn(self.origin);
		share = (on[0] + on[1] - level.mkLine) / level.mkRoute.size;
		if (share < 0)
			share += 1;
		if (share > 0.3 && share < 0.7)
			self.mkFar = true;
	}
}

// Whether crossing the course's line ends a lap, and so a run. Any line off a course does.
lapped()
{
	return !isDefined(level.mkLine) || isDefined(self.mkFar);
}

// A spot against the stretch of the line after a point: how far off it squared, and how far along it.
stretch(spot, i)
{
	from = level.mkRoute[i];
	way = level.mkRoute[(i + 1) % level.mkRoute.size] - from;
	share = 0;
	if (lengthSquared(way) > 1)
		share = vectorDot(spot - from, way) / lengthSquared(way);
	if (share < 0)
		share = 0;
	if (share > 1)
		share = 1;
	return (distanceSquared(spot, from + way * share), share, 0);
}

// The stretch a spot is on: its first point, how far along it, how far off it squared. By stretches and
// not by points, which under a bridge are nearer than the bridge's own.
routeOn(spot)
{
	best = (0, 0, -1);
	for (i = 0; i < level.mkRoute.size; i++)
	{
		at = stretch(spot, i);
		if (best[2] < 0 || at[0] < best[2])
			best = (i, at[1], at[0]);
	}
	return best;
}

// The point of the line to make for from a spot: the end of the stretch it is on.
routeAfter(spot)
{
	return (int(routeOn(spot)[0]) + 1) % level.mkRoute.size;
}

// Run for as long as a racer lives.
carry()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	self.mkItem = undefined;
	self.mkUses = 0;
	self.mkRolling = undefined;
	self.mkSpun = undefined;
	self.mkCarried = undefined;
	self.mkImmune = 0;
	self.mkSpared = 0;
	self.mkGolden = 0;
	self.mkBoosted = 0;
	self.mkBoostLimit = 0;
	self.mkStarred = 0;
	self.mkGrown = 0;
	self.mkFired = 0;
	self.mkSmall = 0;
	self.mkSquashed = 0;
	self.mkClouded = 0;
	self.mkLimit = 0;
	self.mkBig = false;
	self.mkState = "";
	self.mkGiven = getTime();
	if (self getStat(1702))
		self setStat(1702, 0);
	if (!self sr\minigames\_mkw_race::held())
		self freezeControls(false);
	self show();
	self hud();
	self thread hazards();
	self thread gone();

	held = false;
	tick = 0;
	for (;;)
	{
		self pace();
		wait 0.05;
		now = getTime();
		tick++;

		pressed = self attackButtonPressed();
		if (pressed && !held && isDefined(self.mkItem) && !isDefined(self.mkRolling) && !isDefined(self.mkSpun)
			&& !isDefined(self.mkCarried))
			self use();
		held = pressed;

		if (self.mkGolden && now > self.mkGolden)
		{
			self.mkGolden = 0;
			self spend(true);
		}
		self state(now);

		// A star, a mega mushroom and a bullet knock over whoever they touch.
		if (now < self.mkImmune)
		{
			touched = near(self.origin + (0, 0, 10), 85, self);
			if (isDefined(touched))
			{
				if (now < self.mkGrown && now >= self.mkStarred && now >= self.mkFired)
					touched thread hit(self, "squash");
				else
					touched thread hit(self);
			}
		}
		if (tick % 2 == 0)
		{
			if (now < self.mkBoosted && !isDefined(self.mkCarried))
				playFxOnTag(level.mkFx["foot_boost"], self, "tag_origin");
			if (now < self.mkStarred && tick % 4 == 0)
				playFx(level.mkFx["spark"], self.origin + (0, 0, 40));
		}
		if (isDefined(level.mkBoxes) && !level.mkBoxes && !isDefined(self.mkItem) && !isDefined(self.mkRolling)
			&& now - self.mkGiven > 15000 && self rolls())
			self thread roll();
	}
}

// What a racer left running is put away when they die, spawn again or leave.
gone()
{
	self any("disconnect", "death", "spawned");
	if (!isDefined(self))
		return;
	self stopLocalSound("mkw_star");
	self stopLocalSound("mkw_mega_state");
	self stopLocalSound("mkw_bullet_fly");
	self stopLocalSound("mkw_roulette");
	self.mkCarried = undefined;
	self unlink();
	self show();
}

// Until any of these is said.
any(a, b, c, d, e)
{
	done = spawnStruct();
	self thread anyOne(a, done);
	self thread anyOne(b, done);
	self thread anyOne(c, done);
	if (isDefined(d))
		self thread anyOne(d, done);
	if (isDefined(e))
		self thread anyOne(e, done);
	done waittill("said");
	done notify("over");
}

anyOne(said, done)
{
	done endon("over");
	self waittill(said);
	done notify("said");
}

// The limit the racer runs under now, and their size: the most of what boosts, cut by what shrank.
pace()
{
	now = getTime();
	limit = level.mkSpeed;
	if (now < self.mkClouded)
		limit = level.mkCloud;
	if (now < self.mkGrown)
		limit = level.mkMega;
	if (now < self.mkStarred)
		limit = level.mkStar;
	if (now < self.mkBoosted && self.mkBoostLimit > limit)
		limit = self.mkBoostLimit;
	if (now < self.mkFired)
		limit = level.mkBullet;
	if (now < self.mkSmall)
		limit = int(limit * 0.65);
	if (now < self.mkSquashed)
		limit = int(limit * 0.5);

	if (limit != self.mkLimit)
	{
		self.mkLimit = limit;
		self setMoveSpeed(limit);
	}
	big = now < self.mkGrown;
	if (big != self.mkBig)
	{
		self.mkBig = big;
		self setStat(1702, int(big));
	}
}

// What a racer is under, heard for as long as it lasts and no longer.
state(now)
{
	state = "";
	if (now < self.mkGrown)
		state = "mkw_mega_state";
	if (now < self.mkStarred)
		state = "mkw_star";
	if (now < self.mkFired)
		state = "mkw_bullet_fly";
	if (state == self.mkState)
		return;

	if (self.mkState != "")
	{
		self stopLocalSound(self.mkState);
		if (self.mkState == "mkw_mega_state")
			self playLocalSound("mkw_mega_end");
		if (self.mkState == "mkw_bullet_fly")
			self playLocalSound("mkw_bullet_end");
	}
	if (state != "")
		self playLocalSound(state);
	self.mkState = state;
}

// A sound where something happened, for whoever is near.
noise(alias, spot)
{
	speaker = spawn("script_origin", spot);
	speaker playSound(alias);
	speaker thread noiseEnd();
}

noiseEnd()
{
	wait 4;
	self delete();
}

// A mushroom's, a boost panel's or a ramp's: the higher limit for a while, the longer of two at once.
boost(time, limit)
{
	if (!isDefined(self.mkBoosted) || isDefined(self.mkSpun))
		return;

	now = getTime();
	if (now >= self.mkBoosted)
		self playSound("mkw_dash");
	if (now >= self.mkBoosted || limit >= self.mkBoostLimit)
		self.mkBoostLimit = limit;
	if (now + time > self.mkBoosted)
		self.mkBoosted = now + time;
	self pace();
}

// Nothing stops the racer for this long, and nothing keeps them small.
immune(time)
{
	if (getTime() + time > self.mkImmune)
		self.mkImmune = getTime() + time;
	self.mkSmall = 0;
	self.mkSquashed = 0;
	self pace();
}

grow()
{
	self.mkGrown = getTime() + 7500;
	self immune(7500);
	self playLocalSound("mkw_mega");
}

// What a course moves by itself says so when it touches a runner: a racer is hit by it.
hazards()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	for (;;)
	{
		self waittill("iz_hit");
		self thread hit();
	}
}

// The item box, top left where the run's own HUD is outside a race, and in it the picture of what is held.
// With nothing held and nothing being drawn, no box is shown.
hud()
{
	self clean();

	self.mkHud = addHud(self, 8, 8, 0, "left", "top", 1.4, 4);
	self.mkHud setShader("black", 72, 72);
	self.mkIcon = addHud(self, 12, 12, 0, "left", "top", 1.4, 5);
	self.mkIcon setShader("black", 64, 64);
	self.mkCount = addHud(self, 84, 56, 0, "left", "top", 1.6, 6);
	self.mkCount setText("");

	self thread hudEnd(self.mkHud);
	self thread hudEnd(self.mkIcon);
	self thread hudEnd(self.mkCount);
}

hudEnd(hud)
{
	self any("disconnect", "death", "spawned");
	if (isDefined(hud))
		hud destroy();
}

clean()
{
	if (isDefined(self.mkHud))
		self.mkHud destroy();
	if (isDefined(self.mkIcon))
		self.mkIcon destroy();
	if (isDefined(self.mkCount))
		self.mkCount destroy();
	if (isDefined(self.mkInk))
		self.mkInk destroy();
	if (isDefined(self.mkPow))
		self.mkPow destroy();
	self.mkHud = undefined;
	self.mkIcon = undefined;
	self.mkCount = undefined;
	self.mkInk = undefined;
	self.mkPow = undefined;
}

picture(index)
{
	if (!isDefined(self.mkIcon))
		return;
	if (isDefined(self.mkCount))
	{
		self.mkCount.alpha = 0;
		if (isDefined(index) && isDefined(self.mkItem) && index == self.mkItem && self.mkUses > 1)
		{
			self.mkCount setText("^3x" + self.mkUses);
			self.mkCount.alpha = 1;
		}
	}
	if (!isDefined(index))
	{
		self.mkIcon.alpha = 0;
		if (isDefined(self.mkHud))
			self.mkHud.alpha = 0;
		return;
	}
	self.mkIcon setShader("mkw_icon_" + level.mkItems[index].icon, 64, 64);
	self.mkIcon.alpha = 1;
	if (isDefined(self.mkHud))
		self.mkHud.alpha = 0.55;
}

// The roulette: the pictures go by in turn to the game's own sound, then the one the place held earns.
// As in the game, the button stops it early.
roll()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	if (isDefined(self.mkItem) || isDefined(self.mkRolling) || isDefined(self.mkCarried))
		return;
	self.mkRolling = true;
	self.mkGiven = getTime();

	self playLocalSound("mkw_roulette");
	first = randomInt(level.mkItems.size);
	for (i = 0; i < 60; i++)
	{
		self picture((first + i) % level.mkItems.size);
		wait 0.05;
		if (i > 10 && self attackButtonPressed())
			break;
	}
	self stopLocalSound("mkw_roulette");
	self.mkRolling = undefined;
	// A roulette a race's start or end caught turning gives nothing.
	if (!self rolls())
	{
		self picture(undefined);
		return;
	}
	self hold(self draw());
	self playLocalSound("mkw_item");
}

// An item in hand, or for the cloud over the head at once: that one is never held.
hold(index)
{
	self.mkGiven = getTime();
	name = level.mkItems[index].name;
	if (isDefined(level.mkRare[name]))
		level.mkLast[name] = getTime();

	if (index == level.mkCloudItem)
	{
		self picture(undefined);
		self thread cloud(getTime() + 10000);
		return;
	}
	self.mkItem = index;
	self.mkUses = level.mkItems[index].uses;
	self.mkGolden = 0;
	self picture(index);
	if (name == "triple_green" || name == "triple_red")
		self thread orbit(name);
}

// An admin's hand-out, to try an item without the roulette.
give(name)
{
	index = named(name);
	if (!isDefined(index) || !isDefined(self.mkImmune))
		return false;
	self notify("mk_orbit");
	self hold(index);
	return true;
}

// How far back in the race the racer is, 0 in front and 1 last, as the game's table places them.
behind()
{
	return self place() / 11;
}

// The twelve-racer place, 0 for first, whose odds the racer draws from: the game's own table up to twelve
// racing, evenly spread past that. Alone, or with no race on, it is first.
place()
{
	racers = sr\minigames\_mkw_race::raceList();
	if (racers.size < 2 || !isDefined(self.mkRank))
		return 0;
	rank = self.mkRank;
	if (rank > racers.size)
		rank = racers.size;
	if (racers.size > 12)
		return int((rank - 1) * 11 / (racers.size - 1));
	return level.mkPlaces[racers.size][rank - 1];
}

// Whether an item may be drawn now: the cloud not under one, and what the whole race feels neither in a
// race's first half minute nor soon after the last of its kind.
drawn(index)
{
	now = getTime();
	if (index == level.mkCloudItem && now < self.mkClouded)
		return false;

	name = level.mkItems[index].name;
	if (!isDefined(level.mkRare[name]))
		return true;
	if (isDefined(level.mkRace) && level.mkRace.started && now - level.mkRace.time < 30000)
		return false;
	return !isDefined(level.mkLast[name]) || now - level.mkLast[name] > level.mkRare[name];
}

// The odds of the place the game's table reads for the racer's.
draw()
{
	place = self place();
	odds = [];
	total = 0;
	for (i = 0; i < level.mkItems.size; i++)
	{
		odds[i] = level.mkItems[i].odds[place];
		if (!self drawn(i))
			odds[i] = 0;
		total += odds[i];
	}
	pick = randomFloat(total);
	for (i = 0; i < level.mkItems.size; i++)
	{
		pick -= odds[i];
		if (pick < 0)
			return i;
	}
	return 0;
}

spend(all)
{
	self.mkUses--;
	if (isDefined(all) || self.mkUses <= 0)
	{
		self.mkItem = undefined;
		self.mkUses = 0;
		self.mkGiven = getTime();
	}
	self picture(self.mkItem);
}

// What is held, lost to lightning, a POW block or being flattened.
lose()
{
	if (!isDefined(self.mkItem) || isDefined(self.mkRolling))
		return;
	self.mkItem = undefined;
	self.mkUses = 0;
	self.mkGolden = 0;
	self picture(undefined);
}

use()
{
	name = level.mkItems[self.mkItem].name;
	switch (name)
	{
	case "mushroom":
	case "triple_mushroom":
		self boost(1500, level.mkBoost);
		self spend();
		break;
	case "golden_mushroom":
		// As many as can be pressed out of it for seven and a half seconds.
		if (!self.mkGolden)
			self.mkGolden = getTime() + 7500;
		self.mkBoosted = 0;
		self boost(1500, level.mkBoost);
		break;
	case "star":
		self.mkStarred = getTime() + 7500;
		self immune(7500);
		self spend();
		break;
	case "mega_mushroom":
		self grow();
		self spend();
		break;
	case "bullet":
		self spend();
		self thread bullet();
		break;
	case "banana":
	case "triple_banana":
		self thread toss("banana", 1200);
		self spend();
		break;
	case "fake_box":
		self thread toss("fake", 1200);
		self spend();
		break;
	case "bobomb":
		self thread toss("bobomb", 1600);
		self spend();
		break;
	case "green_shell":
	case "triple_green":
		self thread shell("green", 2300, undefined, 6);
		self spend();
		break;
	case "red_shell":
	case "triple_red":
		self thread shell("red", 2100, self ahead(), 0);
		self spend();
		break;
	case "blue_shell":
		self thread spiny();
		self spend();
		break;
	case "lightning":
		self thread lightning();
		self spend();
		break;
	case "pow":
		self thread pow();
		self spend();
		break;
	case "blooper":
		self playLocalSound("mkw_blooper");
		self others(::inked, self);
		self spend();
		break;
	}
}

others(run, by)
{
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		if (racers[i] != self && isAlive(racers[i]) && isDefined(racers[i].mkImmune))
			racers[i] thread [[run]](by);
	}
}

// Whether a racer is in front of another in the race; with no race on, everyone else is.
leads(other)
{
	if (isDefined(self.mkRank) && isDefined(other.mkRank))
		return self.mkRank < other.mkRank;
	return true;
}

// The racer in the place ahead, or failing a race the nearest one the look is turned to.
ahead()
{
	racers = level.minigames["mkw"].queue;
	found = undefined;
	forward = anglesToForward((0, self getPlayerAngles()[1], 0));
	for (i = 0; i < racers.size; i++)
	{
		other = racers[i];
		if (other == self || !isAlive(other))
			continue;
		if (isDefined(self.mkRank) && isDefined(other.mkRank))
		{
			if (other.mkRank == self.mkRank - 1)
				return other;
			continue;
		}
		to = other.origin - self.origin;
		if (vectorDot(vectorNormalize(to), forward) < 0.3 || length(to) > 4000)
			continue;
		if (!isDefined(found) || length(to) < distance(found.origin, self.origin))
			found = other;
	}
	return found;
}

// Whoever leads the race, the thrower too when it is them; failing a race, whoever else is furthest off.
leader()
{
	racers = level.minigames["mkw"].queue;
	found = undefined;
	for (i = 0; i < racers.size; i++)
	{
		other = racers[i];
		if (!isAlive(other))
			continue;
		if (isDefined(other.mkRank) && other.mkRank == 1)
			return other;
		if (other == self)
			continue;
		if (!isDefined(found) || distance(other.origin, self.origin) > distance(found.origin, self.origin))
			found = other;
	}
	return found;
}

// Whoever is within reach of a spot along the ground, standing on it or anywhere in a jump over it:
// a jump clears nothing.
near(spot, reach, but)
{
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		racer = racers[i];
		if (!isAlive(racer) || (isDefined(but) && racer == but))
			continue;
		if (distance2D(racer.origin, spot) < reach && racer.origin[2] > spot[2] - 70 && racer.origin[2] < spot[2] + 110)
			return racer;
	}
	return undefined;
}

// A hit. A shell, a banana or a star spins the racer round where they stand; a blast throws them up and
// keeps them longer; a mega mushroom flattens them, slow for a while after and with nothing left in hand.
hit(by, how)
{
	now = getTime();
	if (isDefined(self.mkSpun) || !isAlive(self) || !isDefined(self.mkImmune) || now < self.mkImmune || now < self.mkSpared)
		return;
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	self.mkSpun = true;
	self.mkBoosted = 0;
	time = 1.3;
	if (isDefined(how) && how == "burn")
	{
		self setVelocity((0, 0, 420));
		self playSound("mkw_burn");
		time = 2;
	}
	else if (isDefined(how) && how == "squash")
	{
		self setVelocity((0, 0, 0));
		self playSound("mkw_squash");
		self lose();
		self.mkSquashed = now + 4000;
		self thread unsquash();
		time = 1;
	}
	else
	{
		self setVelocity((0, 0, 0));
		self playSound("mkw_spin");
	}
	if (isDefined(by) && isPlayer(by) && by != self && isDefined(by.mkStarred) && now < by.mkStarred)
		by playLocalSound("mkw_star_hit");

	self freezeControls(true);
	wait time;
	if (!self sr\minigames\_mkw_race::held())
		self freezeControls(false);
	self.mkSpared = getTime() + 1000;
	self.mkSpun = undefined;
}

unsquash()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	while (getTime() < self.mkSquashed)
		wait 0.1;
	self playLocalSound("mkw_unsquash");
}

// Lightning: everyone else is struck small, loses what they hold, and stays small the longer the further
// in front they are.
lightning()
{
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
		racers[i] playLocalSound("mkw_lightning");
	self others(::struck, self);
}

struck(by)
{
	if (getTime() < self.mkImmune)
		return;
	self bolt();
	self lose();
	self.mkSmall = getTime() + 4000 + int(6000 * (1 - self behind()));
	self playLocalSound("mkw_shrink");
	self thread hit(by);
	self thread regrow();
}

regrow()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	while (getTime() < self.mkSmall)
		wait 0.1;
	self playLocalSound("mkw_grow");
}

// The bolt that strikes a racer, there for the blink of it.
bolt()
{
	flash = spawn("script_model", self.origin + (0, 0, 60));
	flash setModel(level.mkModels["bolt"]);
	flash notSolid();
	playFx(level.mkFx["flash"], self.origin + (0, 0, 30));
	flash thread boltEnd();
}

boltEnd()
{
	wait 0.35;
	self delete();
}

// Retro Rewind's mega thunder cloud: it hangs over whoever drew it, flickering, faster while it does, and is
// handed on by touching another racer. Whoever it strikes grows as under a mega mushroom instead of shrinking.
cloud(until, handed)
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	self notify("mk_cloud");
	self endon("mk_cloud");

	self.mkClouded = until;
	if (isDefined(handed))
		self playLocalSound("mkw_cloud_pass");
	else
		self playLocalSound("mkw_cloud");
	self iPrintLnBold("^3Mega Thunder Cloud! ^7Touch someone to hand it on");

	shape = spawn("script_model", self.origin + (0, 0, 105));
	shape setModel(level.mkModels["cloud"]);
	shape notSolid();
	shape linkTo(self);
	self thread cloudEnd(shape);

	kept = getTime() + 1000;
	warned = false;
	flickers = 0;
	while (getTime() < until)
	{
		wait 0.05;
		now = getTime();
		flickers++;
		if (flickers % 8 == 0 || (warned && flickers % 3 == 0))
			playFxOnTag(level.mkFx["cloud"], shape, "tag_origin");
		if (!warned && until - now < 2500)
		{
			warned = true;
			self playLocalSound("mkw_cloud_sign");
		}
		if (now < kept)
			continue;
		other = near(self.origin + (0, 0, 10), 85, self);
		if (isDefined(other) && isDefined(other.mkImmune) && now >= other.mkImmune && now >= other.mkClouded)
		{
			self.mkClouded = 0;
			self playLocalSound("mkw_cloud_off");
			other thread cloud(until, true);
			self notify("mk_cloud_off");
			return;
		}
	}
	self.mkClouded = 0;
	self bolt();
	self playSound("mkw_cloud_strike");
	self grow();
	self notify("mk_cloud_off");
}

cloudEnd(shape)
{
	self any("disconnect", "death", "spawned", "mk_cloud", "mk_cloud_off");
	if (isDefined(shape))
		shape delete();
}

// The road under a spot, where there is any within a fall's reach.
road(spot)
{
	trace = bulletTrace(spot + (0, 0, 60), spot - (0, 0, 400), false, undefined);
	if (trace["fraction"] < 1)
		return trace["position"];
	return undefined;
}

// A race's end takes everything off the road. What lies there goes quietly, by its own thread, and what
// still flies stops when it sees the count moved on.
clear()
{
	for (i = 0; i < level.mkThings.size; i++)
	{
		if (!isDefined(level.mkThings[i]))
			continue;
		level.mkThings[i].mkCleared = true;
		level.mkThings[i].mkBroken = true;
	}
	level.mkThings = [];
	level.mkRound++;
}

// What lies on the road is kept track of, so a shell can break on it.
lay(what)
{
	kept = [];
	for (i = 0; i < level.mkThings.size; i++)
	{
		if (isDefined(level.mkThings[i]))
			kept[kept.size] = level.mkThings[i];
	}
	kept[kept.size] = what;
	level.mkThings = kept;
}

thingNear(spot, reach, but)
{
	for (i = 0; i < level.mkThings.size; i++)
	{
		what = level.mkThings[i];
		if (isDefined(what) && (!isDefined(but) || what != but) && !isDefined(what.mkBroken) && distance(what.origin, spot) < reach)
			return what;
	}
	return undefined;
}

// Thrown ahead, the further the faster its thrower goes, and carried on by the thrower's own run for as
// long as it flies. It comes down on the first ground under where it ends, however far below, and one that
// finds none is gone. With back held, or on foot looked down at the feet, it is left behind instead.
toss(kind, reach)
{
	owner = self;
	round = level.mkRound;
	from = self getEye();
	flat = anglesToForward((0, self getPlayerAngles()[1], 0));
	rest = 16;
	if (kind == "fake")
		rest = 58;

	run = self getVelocity();
	run = (run[0], run[1], 0);
	far = reach + length(run) * 0.6;
	if (self backButtonPressed() || self getPlayerAngles()[0] > 45)
	{
		far = -70;
		run = (0, 0, 0);
	}
	time = 0.3 + abs(far) / 2400;
	if (time > 1.2)
		time = 1.2;

	// Nothing is thrown through a wall.
	aim = from + flat * far + run * time;
	wall = bulletTrace(from, aim, false, self);
	if (wall["fraction"] < 1)
		aim = wall["position"] - vectorNormalize(aim - from) * 20;
	down = bulletTrace(aim, aim - (0, 0, 20000), false, self);

	thing = spawn("script_model", from);
	thing setModel(level.mkModels[kind]);
	thing notSolid();
	thing.angles = (0, randomInt(360), 0);
	thing playSound("mkw_throw");
	mark = undefined;
	if (kind == "fake")
	{
		mark = spawn("script_model", from);
		mark setModel(level.mkModels["fake_mark"]);
		mark notSolid();
		thing.mkMark = mark;
	}

	lift = 400 * time;
	if (down["fraction"] >= 1)
	{
		way = ((aim[0] - from[0]) / time, (aim[1] - from[1]) / time, lift);
		thing moveGravity(way, 3);
		if (isDefined(mark))
			mark moveGravity(way, 3);
		wait 3;
		if (isDefined(mark))
			mark delete();
		thing delete();
		return;
	}
	to = down["position"] + (0, 0, rest);

	// Onto ground well below it leaves the hand as a level throw does and falls the rest of the way.
	drop = to[2] - from[2];
	if (drop < -100)
		time = (lift + sqrt(lift * lift - 1600 * drop)) / 800;
	else
		lift = drop / time + 400 * time;
	way = ((to[0] - from[0]) / time, (to[1] - from[1]) / time, lift);
	thing moveGravity(way, time);
	if (isDefined(mark))
		mark moveGravity(way, time);
	wait time;
	if (round != level.mkRound)
	{
		if (isDefined(mark))
			mark delete();
		thing delete();
		return;
	}
	thing.origin = to;
	if (isDefined(mark))
		mark.origin = to;
	lay(thing);

	if (kind == "bobomb")
	{
		thing playSound("mkw_bomb_land");
		thing thread fuse(owner);
		return;
	}
	if (kind == "fake")
	{
		thing playSound("mkw_box_land");
		thing thread tumble();
		mark thread turn();
	}
	else
		thing playSound("mkw_land");
	thing thread trap(owner, kind);
}

// The fake box tumbles as a course's own does, and its mark turns inside it.
tumble()
{
	self endon("death");

	for (;;)
	{
		self rotateVelocity((40, 110, 25), 10);
		wait 10;
	}
}

turn()
{
	self endon("death");

	for (;;)
	{
		self rotateYaw(360, 8);
		wait 8;
	}
}

trap(owner, kind)
{
	ends = getTime() + 180000;
	while (getTime() < ends && !isDefined(self.mkBroken))
	{
		wait 0.05;
		racer = near(self.origin, 60, undefined);
		if (!isDefined(racer))
			continue;
		// Whoever nothing can stop runs it over and it is gone all the same.
		racer thread hit(owner);
		if (kind == "fake")
			noise("mkw_fake", self.origin);
		break;
	}
	if (!isDefined(self.mkCleared))
		playFx(level.mkFx["puff"], self.origin);
	if (isDefined(self.mkMark))
		self.mkMark delete();
	self delete();
}

// A bob-omb goes off when someone comes near, when a shell meets it, or when its time is up.
fuse(owner)
{
	armed = getTime() + 500;
	ends = getTime() + 2000;
	while (getTime() < ends && !isDefined(self.mkBroken))
	{
		wait 0.05;
		racer = near(self.origin, 90, undefined);
		if (isDefined(racer) && (!isDefined(owner) || racer != owner || getTime() >= armed))
			break;
	}
	if (!isDefined(self.mkCleared))
		burst(self.origin, 280, owner, "burst", "mkw_bomb");
	self delete();
}

// A mover kept going a frame at a time. moveTo measures from where the mover stood a frame before but sets
// off from where it is now, so each ask is short by the last frame's step, or it overshoots and rocks back.
glide(to)
{
	if (!isDefined(self.mkAt))
	{
		self.mkAt = self.origin;
		self.mkStep = (0, 0, 0);
	}
	self moveTo(to - self.mkStep, 0.05);
	self.mkStep = to - self.mkAt;
	self.mkAt = to;
}

// The road under a spot and a little to each side of the way a shell goes, the highest of the three, so
// that a seam or a kerb's edge does not jolt it.
roadUnder(spot, forward)
{
	side = (0 - forward[1], forward[0], 0) * 14;
	found = undefined;
	for (i = -1; i <= 1; i++)
	{
		low = road(spot + side * i);
		if (isDefined(low) && (!isDefined(found) || low[2] > found))
			found = low[2];
	}
	return found;
}

// A shell along the road, the way the camera faces. A green one goes straight and comes back off the
// walls; a red one keeps to the course's line until whoever is ahead is near, then goes for them, and
// breaks on the first wall. It keeps to the road it is on, up at once and down a share at a time, and
// falls only where the road is well below it or gone.
shell(kind, speed, target, bounces)
{
	owner = self;
	// No slower than whoever throws it is going, and some.
	least = length(self getVelocity()) * 1.2 + 400;
	if (least > speed)
		speed = least;
	forward = anglesToForward((0, self getPlayerAngles()[1], 0));
	spot = self.origin + forward * 70 + (0, 0, 20);
	shell = spawn("script_model", spot);
	shell setModel(level.mkModels[kind]);
	shell notSolid();
	shell playLoopSound("mkw_shell_" + kind);
	shell rotateVelocity((0, 720, 0), 20);

	at = -1;
	if (isDefined(target) && level.mkRoute.size > 1)
		at = routeAfter(spot);

	safe = getTime() + 400;
	ends = getTime() + 15000;
	round = level.mkRound;
	fall = 0;
	struck = false;
	while (getTime() < ends && round == level.mkRound)
	{
		if (isDefined(target))
		{
			if (!isAlive(target))
				break;
			to = target.origin - spot;
			to = (to[0], to[1], 0);
			if (length(to) < 900 || at < 0)
				forward = vectorNormalize(to);
			else
			{
				way = level.mkRoute[at] - spot;
				way = (way[0], way[1], 0);
				if (length(way) < 160)
				{
					at = (at + 1) % level.mkRoute.size;
					way = level.mkRoute[at] - spot;
					way = (way[0], way[1], 0);
				}
				forward = vectorNormalize(way);
			}
		}
		next = spot + forward * speed * 0.05;

		// Road that rises is not a wall: only what is too steep to run up turns a shell or breaks it.
		wall = bulletTrace(spot, next, false, undefined);
		if (wall["fraction"] < 1 && wall["normal"][2] < 0.7)
		{
			if (bounces <= 0)
				break;
			normal = wall["normal"];
			forward = forward - normal * (2 * vectorDot(forward, normal));
			forward = vectorNormalize((forward[0], forward[1], 0));
			bounces--;
			shell playSound("mkw_shell_bounce");
			// It stays where it struck for this frame, still gliding, so the next step sets off from there.
			next = spot;
		}
		else
		{
			low = roadUnder(next, forward);
			if (isDefined(low) && next[2] - low < 160 && !fall)
			{
				rest = low + 18;
				if (rest < next[2])
					rest = next[2] + (rest - next[2]) * 0.6;
				next = (next[0], next[1], rest);
			}
			else
			{
				fall += 40;
				next = next - (0, 0, fall * 0.05);
				if (isDefined(low) && next[2] < low + 18)
				{
					next = (next[0], next[1], low + 18);
					fall = 0;
					shell playSound("mkw_shell_land");
				}
				if (fall > 2400)
					break;
			}
		}
		shell glide(next);
		spot = next;

		// A shell and what it meets on the road are both done for.
		met = thingNear(next, 50, undefined);
		if (isDefined(met))
		{
			met.mkBroken = true;
			break;
		}
		but = undefined;
		if (getTime() < safe)
			but = owner;
		racer = near(next, 65, but);
		if (isDefined(racer))
		{
			racer thread hit(owner);
			noise("mkw_shell_hit", next);
			struck = true;
			break;
		}
		wait 0.05;
	}
	if (round == level.mkRound)
	{
		playFx(level.mkFx["puff"], spot);
		if (!struck)
			noise("mkw_shell_break", spot);
	}
	shell delete();
}

// The spiny shell: over the course's line to whoever leads, then down on them, and everyone near is caught.
spiny()
{
	owner = self;
	target = self leader();
	shell = spawn("script_model", self.origin + (0, 0, 90));
	shell setModel(level.mkModels["blue"]);
	shell notSolid();
	shell playLoopSound("mkw_blue_fly");

	at = -1;
	if (level.mkRoute.size > 1)
		at = routeAfter(shell.origin);

	warned = undefined;
	ends = getTime() + 30000;
	round = level.mkRound;
	spot = shell.origin;
	while (getTime() < ends && round == level.mkRound)
	{
		if ((!isDefined(target) || !isAlive(target)) && isDefined(owner))
			target = owner leader();
		if (!isDefined(target) || !isAlive(target))
			break;

		to = target.origin + (0, 0, 40) - spot;
		flat = length((to[0], to[1], 0));
		if (flat < 800 || at < 0)
			aim = target.origin + (0, 0, 40);
		else
		{
			aim = level.mkRoute[at] + (0, 0, 230);
			way = aim - spot;
			if (length((way[0], way[1], 0)) < 220)
			{
				at = (at + 1) % level.mkRoute.size;
				aim = level.mkRoute[at] + (0, 0, 230);
			}
		}
		if (flat < 2500 && !isDefined(warned))
		{
			warned = target;
			target playLocalSound("mkw_alarm");
		}
		way = vectorNormalize(aim - spot);
		spot = spot + way * 2700 * 0.05;
		shell glide(spot);
		shell.angles = vectorToAngles(way);

		if (distance(spot, target.origin + (0, 0, 40)) < 90)
			break;
		wait 0.05;
	}
	if (isDefined(warned))
		warned stopLocalSound("mkw_alarm");
	if (round == level.mkRound)
		burst(spot, 300, owner, "big", "mkw_blue_burst");
	shell delete();
}

burst(spot, reach, owner, fx, alias)
{
	playFx(level.mkFx[fx], spot);
	noise(alias, spot);
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		if (isAlive(racers[i]) && distance(racers[i].origin, spot) < reach)
			racers[i] thread hit(owner, "burn");
	}
	for (i = 0; i < level.mkThings.size; i++)
	{
		if (isDefined(level.mkThings[i]) && distance(level.mkThings[i].origin, spot) < reach)
			level.mkThings[i].mkBroken = true;
	}
}

// Three shells held turn round the racer and take whoever comes against them, one shell a racer.
orbit(name)
{
	self endon("disconnect");
	self notify("mk_orbit");
	self endon("mk_orbit");

	kind = "green";
	if (name == "triple_red")
		kind = "red";
	index = self.mkItem;
	held = spawnStruct();
	held.shells = [];
	self thread orbitEnd(held);

	turn = 0;
	while (isAlive(self) && isDefined(self.mkItem) && self.mkItem == index && self.mkUses > 0)
	{
		if (held.shells.size != self.mkUses)
		{
			shells = [];
			for (i = 0; i < held.shells.size; i++)
			{
				if (i < self.mkUses)
					shells[i] = held.shells[i];
				else
					held.shells[i] delete();
			}
			for (i = shells.size; i < self.mkUses; i++)
			{
				shells[i] = spawn("script_model", self.origin);
				shells[i] setModel(level.mkModels[kind]);
				shells[i] notSolid();
			}
			held.shells = shells;
		}
		turn += 20;
		taken = false;
		for (i = 0; i < held.shells.size; i++)
		{
			angle = turn + i * 360 / held.shells.size;
			spot = self.origin + (cos(angle) * 58, sin(angle) * 58, 26);
			held.shells[i] glide(spot);
			held.shells[i].angles = (0, angle * 3, 0);
			racer = near(spot, 48, self);
			if (!taken && isDefined(racer) && isDefined(racer.mkImmune) && getTime() >= racer.mkImmune && !isDefined(racer.mkSpun))
			{
				racer thread hit(self);
				noise("mkw_shell_hit", spot);
				taken = true;
			}
		}
		if (taken)
			self spend();
		wait 0.05;
	}
	self notify("mk_orbit_off");
}

orbitEnd(held)
{
	self any("disconnect", "death", "spawned", "mk_orbit", "mk_orbit_off");
	for (i = 0; i < held.shells.size; i++)
	{
		if (isDefined(held.shells[i]))
			held.shells[i] delete();
	}
	held.shells = [];
}

// A bullet: carried along the course's line with nothing to steer, faster than anything, through whoever
// is in the way, and for longer the further back it was fired. A map with no line leaves the steering.
bullet()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	time = 3000 + int(4000 * self behind());
	self.mkFired = getTime() + time;
	self immune(time);
	self playLocalSound("mkw_bullet");
	if (level.mkRoute.size < 2)
		return;

	carrier = spawn("script_origin", self.origin);
	shape = spawn("script_model", self.origin + (0, 0, 40));
	shape setModel(level.mkModels["bullet"]);
	shape notSolid();
	shape.angles = aimed(anglesToForward((0, self getPlayerAngles()[1], 0)));
	self.mkCarried = carrier;
	self thread bulletEnd(carrier, shape);
	self hide();
	self linkTo(carrier);

	at = routeAfter(self.origin);
	way = anglesToForward((0, self getPlayerAngles()[1], 0));
	until = getTime() + time;
	skipped = 0;
	from = carrier.origin;
	while (getTime() < until)
	{
		to = level.mkRoute[at] + (0, 0, 24);
		far = distance(from, to);
		if (far < 80 && skipped < level.mkRoute.size)
		{
			at = (at + 1) % level.mkRoute.size;
			skipped++;
			continue;
		}
		skipped = 0;
		reach = level.mkBullet * 0.05;
		if (far > reach)
			to = from + (to - from) * (reach / far);
		way = vectorNormalize(to - from);
		carrier glide(to);
		shape glide(to + (0, 0, 40));
		shape rotateTo(aimed(way), 0.1);
		from = to;
		wait 0.05;
	}
	self.mkCarried = undefined;
	self unlink();
	self show();
	self setVelocity((way[0], way[1], 0) * level.mkSpeed);
	self notify("mk_bullet_off");
}

// The bullet's nose is its model's +Y, not +X: a quarter turn less, and tipped up or down by roll.
aimed(way)
{
	angles = vectorToAngles(way);
	return (0, angles[1] - 90, 0 - angles[0]);
}

bulletEnd(carrier, shape)
{
	self any("disconnect", "death", "spawned", "mk_bullet_off");
	if (isDefined(shape))
		shape delete();
	if (isDefined(carrier))
		carrier delete();
}

// A POW block: three beats over the screens of everyone in front, and on the third whoever of them stands
// on the ground is thrown and loses what they hold. In the air they are spared.
pow()
{
	self endon("disconnect");

	victims = [];
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		if (racers[i] != self && isAlive(racers[i]) && isDefined(racers[i].mkImmune) && racers[i] leads(self))
			victims[victims.size] = racers[i];
	}
	for (beat = 1; beat <= 3; beat++)
	{
		self playLocalSound("mkw_pow_" + beat);
		for (i = 0; i < victims.size; i++)
		{
			if (isDefined(victims[i]))
				victims[i] thread powBeat(beat);
		}
		wait 1;
	}
	for (i = 0; i < victims.size; i++)
	{
		if (isDefined(victims[i]) && isAlive(victims[i]))
			victims[i] thread shaken(self);
	}
}

powBeat(beat)
{
	self endon("disconnect");

	self playLocalSound("mkw_pow_" + beat);
	if (!isDefined(self.mkPow))
	{
		self.mkPow = addHud(self, 0, 60, 1, "center", "top", 1.4, 6);
		self.mkPow setShader("mkw_icon_pow", 96, 96);
	}
	self.mkPow.alpha = 1;
	self.mkPow scaleOverTime(0.15, 128, 128);
	wait 0.15;
	if (!isDefined(self.mkPow))
		return;
	self.mkPow scaleOverTime(0.3, 96, 96);
	if (beat < 3)
		return;
	wait 0.9;
	if (isDefined(self.mkPow))
		self.mkPow destroy();
	self.mkPow = undefined;
}

// The third beat. Whoever is in the air it passes under; anyone on the ground is thrown and loses what they
// hold.
shaken(by)
{
	if (getTime() < self.mkImmune)
		return;
	if (!self isOnGround())
		return;
	self lose();
	self thread hit(by);
}

// Ink over the screen of whoever is ahead.
inked(by)
{
	if (!self leads(by))
		return;
	if (isDefined(self.mkInk) || getTime() < self.mkImmune)
		return;
	self endon("disconnect");

	self playLocalSound("mkw_ink");
	self.mkInk = addHud(self, 0, 0, 0.9, "center", "middle", 1.4, 3);
	self.mkInk setShader("black", 420, 300);
	wait 5;
	if (isDefined(self.mkInk))
	{
		self.mkInk fadeOverTime(2);
		self.mkInk.alpha = 0;
		wait 2;
	}
	if (isDefined(self.mkInk))
		self.mkInk destroy();
	self.mkInk = undefined;
}
