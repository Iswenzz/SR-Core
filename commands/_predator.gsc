main()
{
	cmd("owner", "predator", ::cmd_Predator);
}

init(l)
{
	level.shaders = strTok("ui_host;line_vertical;nightvision_overlay_goggles;hud_arrow_left",";");
	for(i=0;i<level.shaders.size;i++)
		precacheShader(level.shaders[i]);
	level.map_vips["guid"] = [];
	level.srmenuoption["name"] = [];

	//------------------Menu options-------------------
	addsrmenuOption("^7 XD", "main", ::xd, undefined);
	addsrmenuOption("^7 GOD", "main", ::god, undefined);
	addsrSubMenu("^7 Music", "music");
		addsrmenuOption("^7 This is minecraft", "music", ::music, "this_is_minecraft");
		addsrmenuOption("^7 Stal", "music", ::music, "stal");
		addsrmenuOption("^7 Despacito", "music", ::music, "despacito");
		addsrmenuOption("^7 Dame tu cosita", "music", ::music, "dame_tu_cosita");
		addsrmenuOption("^7 OOF", "music", ::music, "oof");
		addsrmenuOption("^7 MC", "music", ::music, "mc");
		addsrmenuOption("^7 Doot", "music", ::music, "doot");
		addsrmenuOption("^7 FN Despacito", "music", ::music, "fn_despacito");
		addsrmenuOption("^7 Ninja", "music", ::music, "ninja");
		addsrmenuOption("^7 Delfino", "music", ::music, "delfino");
		addsrmenuOption("^7 Poopy", "music", ::music, "poopy");
		addsrmenuOption("^7 Ricardo", "music", ::music, "ricardo");
		addsrmenuOption("^7 Dead", "music", ::music, "dead");
		addsrmenuOption("^7 Wii", "music", ::music, "wii");
	addsrmenuOption("^7 Epic Speed", "main", ::epicspeed, undefined);
	addsrmenuOption("^7 Q3 Toggle", "main", ::q3, undefined);
	addsrmenuOption("^7 Q3 Weapons", "main", ::q3weap, undefined);
	addsrSubMenu("^7 Epic weapons", "weap");
		addsrmenuOption("^7 Frag", "weap", ::weap, "frag_grenade_mp");
		addsrmenuOption("^7 Smoke", "weap", ::weap, "smoke_grenade_mp");
		addsrmenuOption("^7 Flash", "weap", ::weap, "flash_grenade_mp");
		addsrmenuOption("^7 Dance", "weap", ::weap, "fortnite_mp");
	addsrmenuOption("^7 Unlimited Ammo", "main", ::uammo, undefined);
	addsrmenuOption("^7 Can Kill", "main", ::cankill, undefined);
	addsrSubMenu("^7 Redirect All", "redirect");
		addsrmenuOption("^7 Sr- BattleRoyale", "redirect", ::redirectall, "213.32.18.205:28964");
		addsrmenuOption("^7 Sr- Deathrun", "redirect", ::redirectall, "213.32.18.205:28962");
		addsrmenuOption("^7 Zsever", "redirect", ::redirectall, "cod4.zsever-gaming.es:28972");
		addsrmenuOption("^7 3xP CJ", "redirect", ::redirectall, "c.3xP-Clan.com:1337");
		addsrmenuOption("^7 Test Server", "redirect", ::redirectall, "213.32.18.205:28970");
	//-------------------------------------------------
}

god(arg)
{
	self sr\sys\_admins::commands("god", "");
	wait 1;
}

music(arg)
{
	self sr\sys\_admins::commands("music", arg);
	wait 1;
}

redirectAll(arg)
{
	self sr\sys\_admins::commands("redirectall", arg);
	wait 1;
}

epicspeed(arg)
{
	self sr\sys\_admins::commands("gspeed", "500");
	wait 1;
}

q3(arg)
{
	self sr\sys\_admins::commands("practise", "");
	self sr\sys\_admins::commands("knockback", "");
	wait 1;
}

q3weap(arg)
{
	self thread q3weap_late();
	self thread endMenu();
	self notify("close_sr_menu");
	wait 1;
}

q3weap_late()
{
	wait 2;
	self takeAllWeapons();
	self giveWeapon("gl_ak47_mp");
	self giveWeapon("gl_g3_mp");
	wait 0.05;
	self switchToWeapon("gl_ak47_mp");
}

weap(arg)
{
	self thread weap_late(arg);
	self thread endMenu();
	self notify("close_sr_menu");
	wait 1;
}

weap_late(arg)
{
	wait 2;
	self giveWeapon(arg);
	wait 0.05;
	self switchToWeapon(arg);
}

uammo(arg)
{
	self sr\sys\_admins::commands("uammo", "");
	wait 1;
}

cankill(arg)
{
	self sr\sys\_admins::commands("candamage", "");
	wait 1;
}

xd(arg)
{
	iprintlnbold("XD");
}

OnMenuResponse()
{
	self endon("disconnect");
	self.insrmenu = false;

	for(;; wait .2)
	{
		if(!isDefined(self))
			break;

		weap = self GetCurrentWeapon();
		if(!self.insrmenu && weap == "shop_mp")
		{
			if(self.sessionstate != "playing" || self.pers["team"] == "spectator")
				continue;

			self.insrmenu = true;
			self notify("open_sr_menu");

			for(; self.sessionstate == "playing" && !self isOnGround(); wait .05){}

			//self thread speedrun\player\_hud_speedrun::destroyClientHud("fix");
			wait 0.2;
			self thread srMenu();

			// self freezeControls(true);
			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "none", false );
			wait 1.3;
		}
		else if(self.insrmenu && weap != "shop_mp")
			self endMenu();
		else if(self.insrmenu && self meleebuttonpressed())
			self endMenu();
	}
}

endMenu(fix)
{
	self notify("close_sr_menu");
	self takeWeapon("shop_mp");

	if(!isDefined(self.srmenu))
		return;

	for(i=0;i<self.srmenu.size;i++)
	{
		if(isDefined(self.srmenu[i]))
		self.srmenu[i] thread FadeOut(1,true,"right");
	}

	self.insrmenu = false;

	self switchtoweapon( self.pers["weapon"] );

	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", true );

	wait 0.5;

	self giveweapon("shop_mp");
}

addsrmenuOption(name,menu,script,arg)
{
	if(!isDefined(level.srmenuoption["name"][menu]))
		level.srmenuoption["name"][menu] = [];

	level.srmenuoption["name"][menu][level.srmenuoption["name"][menu].size] = name;
	level.srmenuoption["script"][menu][level.srmenuoption["name"][menu].size] = script;
	level.srmenuoption["arg"][menu][level.srmenuoption["name"][menu].size] = arg;
}

addsrSubMenu(displayname,name)
{
	addsrmenuOption(displayname,"main",name);
}

GetMenuStuct(menu)
{
	itemlist = "";
	for(i=0;i<level.srmenuoption["name"][menu].size;i++)
		itemlist = itemlist + level.srmenuoption["name"][menu][i] + "\n";
	return itemlist;
}

srmenu()
{
	self endon("close_sr_menu");
	self endon("disconnect");
	self endon("death");

	submenu = "main";
	self.srmenu[0] = addTextHud( self, -200, 0, .6, "left", "top", "right",0, 101 );
	self.srmenu[0] setShader("nightvision_overlay_goggles", 400, 650);
	self.srmenu[0] thread FadeIn(.5,true,"right");
	self.srmenu[1] = addTextHud( self, -200, 0, .5, "left", "top", "right", 0, 101 );
	self.srmenu[1] setShader("black", 400, 650);
	self.srmenu[1] thread FadeIn(.5,true,"right");
	self.srmenu[2] = addTextHud( self, -200, 89, .5, "left", "top", "right", 0, 102 );
	self.srmenu[2] setShader("line_vertical", 600, 22);
	self.srmenu[2] thread FadeIn(.5,true,"right");
	self.srmenu[3] = addTextHud( self, -190, 93, 1, "left", "top", "right", 0, 104 );
	self.srmenu[3] setShader("ui_host", 14, 14);
	self.srmenu[3] thread FadeIn(.5,true,"right");
	self.srmenu[4] = addTextHud( self, -165, 100, 1, "left", "middle", "right", 1.4, 103 );
	self.srmenu[4] settext(GetMenuStuct(submenu));
	self.srmenu[4] thread FadeIn(.5,true,"right");
	self.srmenu[5] = addTextHud( self, -170, 400, 1, "left", "middle", "right" ,1.4, 103 );
	self.srmenu[5] settext("^7Select: ^7[Right or Left Mouse]^7\nUse: ^7[[{+activate}]]^7\nLeave: ^7[[{+melee}]]\nPoints: "+self getStat(3256)+"/250");
	self.srmenu[5] thread FadeIn(.5,true,"right");

	for(selected = 0; !self meleebuttonpressed(); wait .05)
	{
		if(self Attackbuttonpressed())
		{
			self playLocalSound( "mouse_over" );
			if(selected == level.srmenuoption["name"][submenu].size-1) selected = 0;
			else selected++;
		}
		if(self adsbuttonpressed())
		{
			self braxi\_common::clientCmd("-speed_throw");
			self playLocalSound( "mouse_over" );
			if(selected == 0) selected = level.srmenuoption["name"][submenu].size-1;
			else selected--;
		}
		if(self adsbuttonpressed() || self Attackbuttonpressed())
		{
			if(submenu == "main")
			{
				self.srmenu[2] moveOverTime( .05 );
				self.srmenu[2].y = 89 + (16.8 * selected);
				self.srmenu[3] moveOverTime( .05 );
				self.srmenu[3].y = 93 + (16.8 * selected);
			}
			else
			{
				self.srmenu[7] moveOverTime( .05 );
				self.srmenu[7].y = 10 + self.srmenu[6].y + (16.8 * selected);
			}
		}
		if((self adsbuttonpressed() || self Attackbuttonpressed()) && !self UseButtonPressed())
			wait .15;
		if(self UseButtonPressed())
		{
			if(!isString(level.srmenuoption["script"][submenu][selected+1]))
			{
				self [[level.srmenuoption["script"][submenu][selected+1]]](level.srmenuoption["arg"][submenu][selected+1]);
				//self thread endMenu();
				//self notify("close_sr_menu");
			}
			else
			{
				abstand = (16.8 * selected);
				submenu = level.srmenuoption["script"][submenu][selected+1];
				self.srmenu[6] = addTextHud( self, -430, abstand + 50, .5, "left", "top", "right", 0, 101 );
				self.srmenu[6] setShader("black", 200, 300);
				self.srmenu[6] thread FadeIn(.5,true,"left");
				self.srmenu[7] = addTextHud( self, -430, abstand + 60, .5, "left", "top", "right", 0, 102 );
				self.srmenu[7] setShader("line_vertical", 200, 22);
				self.srmenu[7] thread FadeIn(.5,true,"left");
				self.srmenu[8] = addTextHud( self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104 );
				self.srmenu[8] setShader("hud_arrow_left", 14, 14);
				self.srmenu[8] thread FadeIn(.5,true,"left");
				self.srmenu[9] = addTextHud( self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103 );
				self.srmenu[9] settext(GetMenuStuct(submenu));
				self.srmenu[9] thread FadeIn(.5,true,"left");
				selected = 0;
				wait .2;
			}
		}
	}
	self thread endMenu();
}

addTextHud( who, x, y, alpha, alignX, alignY, vert, fontScale, sort )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.horzAlign = vert;
	if(fontScale != 0)
		hud.fontScale = fontScale;
	return hud;
}

FadeOut(time,slide,dir)
{
	if(!isDefined(self))
		return;
	if(isdefined(slide) && slide)
	{
		self MoveOverTime(0.2);
		if(isDefined(dir) && dir == "right")
			self.x+=600;
		else
			self.x-=600;
	}
	self fadeovertime(time);
	self.alpha = 0;
	wait time;
	if(isDefined(self)) self destroy();
}

FadeIn(time,slide,dir)
{
	if(!isDefined(self))
		return;
	if(isdefined(slide) && slide)
	{
		if(isDefined(dir) && dir == "right")
			self.x+=600;
		else
			self.x-=600;

		self moveOverTime( .2 );

		if(isDefined(dir) && dir == "right")
			self.x-=600;
		else
			self.x+=600;
	}
	alpha = self.alpha;
	self.alpha = 0;
	self fadeovertime(time);
	self.alpha = alpha;
}

Blur(start,end)
{
	self notify("newblur");
	self endon("newblur");
	start = start * 10;
	end = end * 10;
	self endon("disconnect");
	self endon("death");

	if(start <= end)
	{
		for(i=start;i<end;i++)
		{
			self setClientDvar("r_blur", i / 10);
			wait .05;
		}
	}
	else for(i=start;i>=end;i--)
	{
		self setClientDvar("r_blur", i / 10);
		wait .05;
	}
}
