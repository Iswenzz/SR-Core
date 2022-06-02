main()
{
    cmd("player", 	"fov",		::cmd_FOV);
	cmd("player", 	"fps",		::cmd_FPS);
	cmd("player", 	"sheep",	::cmd_Sheep);
	cmd("player", 	"fxenable",	::cmd_FX);
	cmd("vip", 		"color",	::cmd_Color);
}

cmd_FOV(args)
{
	if (args.size < 1)
		return self pm("Usage: fov <value>");

	value = ToFloat(args[0]);
	f3 = fmt("%.3f", value);
	normalized = ToInt(Replace(f3, ".", ""));

	if (normalized > 2000 || normalized < 200))
		return;

	self.fovscale = normalized;
	self setClientDvar("cg_fovscale", normalized);
	self IPrintLnBold("^5FOV scale ^7" + normalized);
	self.settings["gfx_fov"] = self.fovscale;
	self thread sr\player\_settings::update();
}

cmd_FPS()
{
	self.settings["gfx_fullbright"] = !self.settings["gfx_fullbright"];
	msg = Ternary(self.settings["gfx_fullbright"], "^2Fullbright On", "^1Fullbright Off");

	self setClientDvar("r_fullbright", self.settings["gfx_fullbright"]);
	self pm(msg);
	self thread sr\player\_settings::update();
}

cmd_Sheep()
{
	for (i = 0; i < 25; i++)
	{
		self IPrintLnBold("^3S^2h^1e^4e^6p ^3w^2i^1z^4a^6r^5d");
		wait 0.1;
	}
	self setClientDvar("r_specular", 1);
	self setClientDvar("r_specularmap", 2);
}

cmd_FX()
{
	self.settings["gfx_fx"] = !self.settings["gfx_fx"];
	msg = Ternary(self.settings["gfx_fx"], "^2FX On", "^1FX Off");

	self setClientDvar("fx_enabled", self.settings["gfx_fx"]);
	self pm(msg);
	self thread sr\player\_settings::update();
}

cmd_Color(args)
{
	if (args.size < 3)
		return self pm("Usage: color <r> <g> <b>");

	r = ToInt(args[0]);
	g = ToInt(args[1]);
	b = ToInt(args[2]);

	self setStat(1650, r);
	self setStat(1651, g);
	self setStat(1652, b);
	self suicide();
}
