#include sr\utils\_common;
#include sr\utils\_hud;

initNotifications()
{
	level.notifications = 0;
	level.max_notifications = 5;
}

message(message, duration)
{
	notification = spawnStruct();
	notification.message = message;
	notification.duration = IfUndef(duration, 3);
	notification.displayed = false;

	self thread animate(notification);
}

animate(notification)
{
	level.notifications++;

	if (self == level)
		playSoundOnAllPlayers("mp_ingame_summary");
	else
		self playLocalSound("mp_ingame_summary");

	y = level.notifications * 30;

	notification.huds = [];
	notification.huds[0] = addHud(self, 0, 100, 0.7, "left", "top", 1.4, 990);
	notification.huds[0] setShader("black", 195, 20);
	notification.huds[0].y += y;

	notification.huds[1] = addHud(self, 2, 102, 1, "left", "top", 1.4, 993);
	notification.huds[1].font = "objective";
	notification.huds[1] setText(notification.message);
	notification.huds[1].y += y;

	for (i = 0; i < notification.huds.size; i++)
		notification.huds[i] thread fadeIn(0.2, "right", 1);
	wait notification.duration;

	for (i = 0; i < notification.huds.size; i++)
		notification.huds[i] thread fadeOut(0.2, "left", 1);
	wait 0.2;

	level.notifications--;
}
