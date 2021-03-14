/*

  _|_|_|            _|      _|      _|                  _|            
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|  
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|    
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|      
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|  

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/
#include sr\sys\_gsxcommon;
// TODO more secure

checkid()
{
	if(self getstat(995) == 0 || self getstat(996) == 0 || self getstat(997) == 0)
	{
		newid = createid();
		self setstat(995, newid[0]);
		self setstat(996, newid[1]);
		self setstat(997, newid[2]);
	}
	self.playerID = self getstat(995) +""+self getstat(996)+""+self getstat(997);
}

createid()
{
	self IPrintLn("creating ID");
	path = "./sr/server_data/speedrun/admin/player_ids.txt";
	file_exists = checkfile(path);
	if(!file_exists)
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);
	}
	a = readAll(path);
	check = false;
	id = [];
	string = "";
	while(!check)
	{
		id[0] = RandomIntRange(1, 255);
		id[1] = RandomIntRange(1, 255);
		id[2] = RandomIntRange(1, 255);
		string = id[0] +""+id[1]+""+id[2];
		for(i = 0; i<a.size; i++)
			if(string == a[i])
				continue;
		check = true;
	}
	WriteToFile(path, string);
	return id;
}
