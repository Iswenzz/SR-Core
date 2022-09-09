#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");
	time = 0;

	setExpFog(200, 500, 0, 0.04, 0.1, 0);
	addEnt(playLoopedFX(level.fx["rain"], 50, level.spawn["spectator"].origin));

	time = timeline(time, 10.9);

	while (true)
	{
		playFX(level.fx["thunder"], level.spawn["spectator"].origin);
		wait 0.5;
	}
}
