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

main()
{
	LoadPlugin( sr\plugins\_hideplayers::init, "Hide Players", "SuX Lolz & NitroFire" );
	LoadPlugin( sr\plugins\_srmenu::init, "SR Menu", "SuX Lolz" );
	LoadPlugin( sr\plugins\_hitmarker::init, "Hitmarker", "IDK" );
}

// ===== DO NOT EDIT ANYTHING UNDER THIS LINE ===== //
LoadPlugin( pluginScript, name, author )
{
	thread [[ pluginScript ]]( game["DeathRunVersion"] );
	println( "" + name + " ^7plugin created by " + author + "\n" );
}
