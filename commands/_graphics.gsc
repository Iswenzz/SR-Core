#include sr\sys\_admins;
#include sr\player\fx\_shaders;
#include sr\utils\_common;

main()
{
    cmd("player", 		"fov",			::cmd_FOV);
	cmd("player", 		"fps",			::cmd_FPS);
	cmd("vip", 			"color",		::cmd_Color);
	cmd("owner", 		"shader",		::cmd_Shader);
	cmd("owner", 		"spawn_model",	::cmd_SpawnModel);
	cmd("owner", 		"mirror",		::cmd_Mirror);
	cmd("owner", 		"vision",		::cmd_Vision);
}

cmd_Vision(args)
{
	if (args.size < 1)
		return self pm("Usage: vision <name>");

	vision = args[0];

	visionSetNaked(vision, 0);
}

cmd_SpawnModel(args)
{
	name = args[0];

	if (name == "clear")
	{
		models = getEntArray("spawned_model", "targetname");
		for (i = 0; i < models.size; i++)
			models[i] delete();
		return;
	}
	angles = self getPlayerAngles();
	model = spawn("script_model", self.origin);
	model.targetname = "spawned_model";
	model.angles = (0, angles[1], 0);
	model setModel(name);
}

cmd_Mirror(args)
{
	angles = self getPlayerAngles();
	model = spawn("script_model", self.origin + (0, 0, 30));
	model.targetname = "spawned_model";
	model.angles = (0, 90 + angles[1], 0);
	model setModel("x_mirror");
}

cmd_Shader(args)
{
	if (args.size < 2)
		return self pm("Usage: shader <player> <name> <...props>");

	player = IfUndef(getPlayerByName(args[0]), self);
	name = args[1];

	switch (name)
	{
		case "translate":
			player translate(ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]));
			break;
		case "shake":
			player shake(ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]), ToFloat(args[5]));
			break;
		case "zoom":
			player zoom(ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]));
			break;
		case "edge":
			player edge((ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4])), ToFloat(args[5]));
			break;
		case "vhs":
			player vhs(ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]), ToFloat(args[5]));
			break;
		case "blur":
			player blur(ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4]));
			break;
		case "psy_glass":
			player psyGlass(ToFloat(args[2]), ToFloat(args[3]));
			break;
		case "psy_edge":
			player psyEdge((ToFloat(args[2]), ToFloat(args[3]), ToFloat(args[4])));
			break;
		case "glitch":
			player glitch(ToFloat(args[2]), ToFloat(args[3]));
			break;
		default:
			player removeShaders();
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
	self sr\player\_settings::update("gfx_fov");
}

cmd_FPS(args)
{
	self sr\player\_settings::toggle("gfx_fullbright");

	msg = Ternary(self.settings["gfx_fullbright"], "^2Fullbright On", "^1Fullbright Off");
	self pm(msg);
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

	if (self isAxis())
		return;

	self suicide();
}
