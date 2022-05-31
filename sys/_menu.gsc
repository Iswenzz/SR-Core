event()
{
	self endon("disconnect");
	self.menus = [];

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if (isDefined(self.menus[menu]))
		{
			if (self.menus[menu].response == response)
				self thread [[self.menus[menu].callback]]();
			if (isDefined(self.menus[menu].callbackMenu))
				self thread [[self.menus[menu].callbackMenu]](response);
		}
	}
}

menu(name, response, callback, callbackMenu)
{
	self.menus[name] = spawnStruct();
	self.menus[name].name = name;
	self.menus[name].response = response;
	self.menus[name].callback = callback;
	self.menus[name].callbackMenu = callbackMenu;
}

range(variable, min, max)
{

}

menu_noop() { }
