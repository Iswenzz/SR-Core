#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_aurora");
	addEnt(skybox);

	setExpFog(900, 700, 0.05, 0.09, 0.21, 0);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}
