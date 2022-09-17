#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	setExpFog(700, 600, 0, 0.18, 0.17, 0);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.fx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}
