#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("poll",      "owner",       ::cmd_Poll,          "Start a poll");
	cmd("vote_cd",   "trusted",     ::cmd_VoteCooldown,  "Reset the vote cooldown");
	cmd("vote_fail", "masteradmin", ::cmd_VoteFail,      "Force the current vote to fail");
	cmd("vote_pass", "masteradmin", ::cmd_VotePass,      "Force the current vote to pass");
	cmd("vote",      "trusted",     ::cmd_Vote,          "Start a vote");
}

cmd_Poll(args)
{
	if (args.size < 4)
		return self pm("Usage: poll <title> : <values...>");

	delimiter = IndexOf(args, ":");
	if (delimiter < 0)
		return self pm("Usage: poll <title> : <values...>");

	title = StrJoin(Range(args, 0, delimiter), " ");
	values = Range(args, delimiter + 1, args.size);

	result = sr\core\_poll::poll(title, values);
	if (isDefined(result))
		level sr\huds\_notifications::show(fmt("^5[%d] Poll result: ^7%s", result.votes, result.label));
}

cmd_Vote(args)
{
	if (args.size < 1)
		return self pm("Usage: vote <value>");

	value = args[0];
	type = Ternary(StartsWith(value, "mp_"), "map", "msg");

	self log();
	sr\core\_vote::start(type, value);
}

cmd_VoteFail(args)
{
	level notify("vote_ended");
	level.voteNo = 9999;
	level.voteTimer = 0;
}

cmd_VoteCooldown(args)
{
	self.voteCooldown = -1000000;
	self pm("^6Vote CD cleared");
}

cmd_VotePass(args)
{
	level notify("vote_ended");
	level.voteYes = 9999;
	level.voteTimer = 0;
}
