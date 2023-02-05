#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("owner", 		"poll", 		::cmd_Poll);
	cmd("trusted", 		"vote", 		::cmd_Vote);
	cmd("trusted", 		"vote_cd", 		::cmd_VoteCooldown);
	cmd("masteradmin", 	"vote_fail", 	::cmd_VoteFail);
	cmd("masteradmin", 	"vote_pass", 	::cmd_VotePass);
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

	result = sr\game\_poll::poll(title, values);
	if (isDefined(result))
		level sr\sys\_notifications::show(fmt("^5[%d] Poll result: ^7%s", result.votes, result.label));
}

cmd_Vote(args)
{
	if (args.size < 1)
		return self pm("Usage: vote <value>");

	value = args[0];
	type = Ternary(StartsWith(value, "mp_"), "map", "msg");

	self log();
	sr\game\_vote::start(type, value);
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
