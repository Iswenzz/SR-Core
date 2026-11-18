#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("mkw", "player", ::cmd_Mkw, "Race Mario Kart Wii's courses on foot, with its items");
	cmd("mk_start", "admin", ::cmd_MkStart, "Race now, without the lobby's wait: !mk_start [laps]");
	cmd("mk_stop", "admin", ::cmd_MkStop, "Stop the Mario Kart race that is on");
	cmd("mk_item", "admin", ::cmd_MkItem, "Hold a Mario Kart item: !mk_item <name>");
}

cmd_MkStart(args)
{
	if (!level.minigames["mkw"].queue.size)
	{
		self pm("^1Nobody is racing. [^1!mkw^7]");
		return;
	}
	laps = 3;
	if (args.size && int(args[0]) > 0)
		laps = int(args[0]);
	sr\minigames\_mkw_race::start(laps);
}

cmd_MkStop(args)
{
	sr\minigames\_mkw_race::stop();
}

cmd_MkItem(args)
{
	if (!args.size || !self sr\minigames\_mkw_items::give(args[0]))
	{
		names = "";
		for (i = 0; i < level.mkItems.size; i++)
			names += level.mkItems[i].name + " ";
		self pm("^1Race first [^1!mkw^7], then one of: ^7" + names);
	}
}

cmd_Mkw(args)
{
	if (self sr\core\_minigames::isInOtherQueue("mkw"))
		return;

	if (!self sr\core\_minigames::isInQueue("mkw"))
		sr\minigames\_mkw::join();
	else
		sr\minigames\_mkw::leave();
}
