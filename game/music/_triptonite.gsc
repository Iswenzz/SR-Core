#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");
	time = 0;

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_hexagon");
	addEnt(skybox);
}
