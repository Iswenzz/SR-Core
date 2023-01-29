#include sr\sys\_admins;
#include sr\utils\_common;
#include sr\game\_vote;

main()
{
	cmd("trusted", 		"vote", 		::cmd_Vote);
	cmd("masteradmin", 	"vote_cancel", 	::cmd_VoteCancel);
	cmd("trusted", 		"vote_cd", 		::cmd_VoteCooldown);
	cmd("masteradmin", 	"vote_force", 	::cmd_VoteForce);
}

cmd_Vote(args)
{
	if (args.size < 1)
		return self pm("Usage: vote <value>");

	value = args[0];
	type = Ternary(StartsWith(value, "mp_"), "map", "msg");

	self log();
	vote(type, value);
}

cmd_VoteCancel(args)
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

cmd_VoteForce(args)
{
	level notify("vote_ended");
	level.voteYes = 9999;
	level.voteTimer = 0;
}
