#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");
	time = 0;

	setExpFog(200, 500, 0, 0.04, 0.1, 0);
	addFX(level.gfx["rain"], level.spawn["spectator"].origin);

	time = timeline(time, 10.9);

	for (i = 0; i < 30; i++)
		addFX(level.gfx["thunder"], level.spawn["spectator"].origin);
}
