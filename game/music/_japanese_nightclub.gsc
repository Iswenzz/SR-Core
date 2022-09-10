#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	addFX(level.fx["lasershow"], level.spawn["spectator"].origin);

	setExpFog(900, 700, 0.03, 0.68, 0.81, 0);
}
