#include sr\sys\_admins;
#include sr\player\fx\_shaders;

main()
{
    cmd("player", 	"fov",		::cmd_FOV);
	cmd("player", 	"fps",		::cmd_FPS);
	cmd("player", 	"sheep",	::cmd_Sheep);
	cmd("player", 	"fxenable",	::cmd_FX);
	cmd("vip", 		"color",	::cmd_Color);
	cmd("owner", 	"shader",	::cmd_Shader);
}

cmd_Shader(args)
{
	if (args.size < 1)
		return self pm("Usage: shader <name> <...props>");

	switch (args[0])
	{
		case "translate":
			self translate(ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3]));
			break;
		case "shake":
			self shake(ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]));
			break;
		case "zoom":
			self zoom(ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3]));
			break;
		case "edge":
			self edge((ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3])), ToFloat(args[4]));
			break;
		case "vhs":
			self vhs(ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]));
			break;
		case "blur":
			self blur(ToFloat(args[1]), ToFloat(args[2]), ToFloat(args[3]));
			break;
		default:
			self removeShaders();
			break;
	}
}

cmd_FOV(args)
{
	if (args.size < 1)
		return self pm("Usage: fov <value>");

	value = ToFloat(args[0]);
	f3 = fmt("%.3f", value);
	normalized = ToInt(Replace(f3, ".", ""));

	if (normalized > 2000 || normalized < 200)
		return;

	self pm("FOV scale ^5" + value);
	self.settings["gfx_fov"] = normalized;
	self sr\player\_settings::update();
}

cmd_FPS(args)
{
	self.settings["gfx_fullbright"] = !self.settings["gfx_fullbright"];
	msg = Ternary(self.settings["gfx_fullbright"], "^2Fullbright On", "^1Fullbright Off");

	self pm(msg);
	self sr\player\_settings::update();
}

cmd_Sheep(args)
{
	for (i = 0; i < 25; i++)
	{
		self iPrintLnBold("^3S^2h^1e^4e^6p ^3w^2i^1z^4a^6r^5d");
		wait 0.1;
	}
	self setClientDvar("r_specular", 1);
	self setClientDvar("r_specularmap", 2);
}

cmd_FX(args)
{
	self.settings["gfx_fx"] = !self.settings["gfx_fx"];
	msg = Ternary(self.settings["gfx_fx"], "^2FX On", "^1FX Off");

	self pm(msg);
	self sr\player\_settings::update();
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
