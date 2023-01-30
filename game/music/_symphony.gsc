#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	setExpFog(700, 500, 0, 0.1, 0, 0);

	addFX(level.gfx["endgame"], level.spawn["spectator"].origin);
}
