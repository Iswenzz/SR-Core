#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	setExpFog(900, 700, 0.67, 0.03, 0.88, 0);

	addFX(level.fx["endgame"], level.spawn["spectator"].origin);
}
