#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	setExpFog(200, 500, 0, 0, 0, 0);

	addFX(level.fx["snow"], level.spawn["spectator"].origin);
}
