#include maps\mp\_utility;
#include common_scripts\utility;

#include sr\sys\_events;

main()
{
	precache();

	menu("minesweeper", "open", ::menu_Open);
}

precache()
{
	precacheShader("minesweeper_square");
	precacheShader("minesweeper_smile");
	precacheShader("minesweeper_minered");
	precacheShader("minesweeper_mine");
	precacheShader("minesweeper_glasses");
	precacheShader("minesweeper_flag");
	precacheShader("minesweeper_dead");
	precacheShader("minesweeper_board");
}

menu_Open(arg)
{
	self.mines = IfUndef(ToInt(arg), 10);

	self notify("minesweep_gameover");
	self openMenu("minesweeper");

	self setClientDvars();
	self placeMines();
	self placeNumbers();
	self setup();
}

setClientDvars()
{
	x = 9;
	y = 9;

	if (!isDefined(self.ms_personalbest))
		self.ms_personalbest = [];

	self.type = [];
	self.hidden = [];

	self SetClientDvar("minesweeper_face", "minesweeper_smile");
	self SetClientDvar("minesweeper_numofmines", self.mines);
	self SetClientDvar("minesweeper_timer", "000");

	for (i = 0; i < x; i++)
	{
		for (z = 0; z < y; z++)
		{
			self SetClientDvar("minesweeper_cellshader" + i + "_" + z, "minesweeper_square");
			self SetClientDvar("minesweep_" + i + "_" + z, "");
			self SetClientDvar("hideminebutton" + i + "_" + z, "false");
			self.hidden[i][z] = false;
			self.type[i][z] = "x";
		}
		wait 0.1;
	}
}

placeMines()
{
	x = 0;
	while (x < self.mines)
	{
		rndX = RandomInt(9);
		rndY = RandomInt(9);

		if (self.type[rndX][rndy] == "mine")
			continue;

		self SetClientDvar("minesweep_" + rndX + "_" + rndY, "M");
		self.type[rndX][rndy] = "mine";
		x++;
	}
}

placeNumbers()
{
	for (x = 0; x < 9; x++)
	{
		for (y = 0; y < 9; y++)
		{
			if (self.type[x][y] == "mine")
				continue;

			self SetClientDvar("minesweep_" + x + "_" + y, setStringColour(getSurroundingMines(x, y)));
			self.type[x][y] = "" + getSurroundingMines(x,y);
		}
	}
}

menu_Close()
{
	self.mineSweeperOpen = false;
	self closeMenu();
	self notify("minesweep_gameover");
}

menu_Restart()
{
	self thread menu_Open();
}

menu_Button(args)
{
	self.mode = args[1];
	self SetClientDvar("minesweeper_mode", "Mode: " + self.mode);
}

menu_Mine()
{
	if (!self.ms_timestarted)
		self thread startTimer();

	x = token[0];
	y = token[1];

	self SetClientDvar("hideminebutton" + x + "_" + y, "true");

	self.hidden[int(x)][int(y)] = true;
	if (self.type[int(x)][int(y)] == "mine")
	{
		if (self.numOfClicks == 0)
			self thread menu_Open();
		self SetClientDvar("hideminebutton" + x + "_" + y, "false");
		self revealBoard(int(x), int(y));
		self SetClientDvar("minesweeper_face", "minesweeper_dead");
		self watchRestart();
	}
	if (self.type[int(x)][int(y)] == "0")
		self openSurroundingMines(int(x),int(y));

	self.numOfClicks++;
	self SetClientDvar("minesweeper_numofmines", self.minesLeft);
	checkIfWon();
}

menu_Flag()
{
	if (!self.ms_timestarted)
		self thread startTimer();

	x = token[0];
	y = token[1];

	self SetClientDvar("hideminebutton" + x + "_" + y, "true");

	if (self.hidden[int(x)][int(y)])
		return;

	// This whole bit is confusing sry
	if (self.type[int(x)][int(y)] == "flag")
	{
		if (isDefined(self.oldtype[int(x)][int(y)]))
		{
			self.type[int(x)][int(y)] = self.oldtype[int(x)][int(y)];

			if (self.oldtype[int(x)][int(y)] == "mine")
				self SetClientDvar("minesweep_" + x + "_" + y, "M");
			else if (self.oldtype[int(x)][int(y)] == "0")
				self SetClientDvar("minesweep_" + x + "_" + y, "");
			else
				self SetClientDvar("minesweep_" + x + "_" + y, setStringColour(int(self.oldtype[int(x)][int(y)])));
		}

		self SetClientDvar("hideminebutton" + x + "_" + y, "false");
		self SetClientDvar("minesweeper_cellshader" + x + "_" + y, "minesweeper_square");
		self.minesLeft++;
	}
	else
	{
		self.oldtype[int(x)][int(y)] = self.type[int(x)][int(y)];
		self.type[int(x)][int(y)] = "flag";
		self SetClientDvar("hideminebutton" + x + "_" + y, "false");
		self SetClientDvar("minesweeper_cellshader" + x + "_" + y, "minesweeper_flag");
		self.minesLeft--;
	}
	self.numOfClicks++;
	self SetClientDvar("minesweeper_numofmines", self.minesLeft);
	checkIfWon();
}

setup()
{
	self endon("minesweep_gameover");
	self endon("disconnect");

	self.minesLeft = self.mines;
	self.numOfClicks = 0;
	self.mode = "mine";
	self.ms_timestarted = false;

	self SetClientDvar("minesweeper_mode", "Mode: " + self.mode);
}

startTimer()
{
	self endon("minesweeper_timerstop");
	self endon("minesweep_gameover");
	self endon("disconnect");

	self.ms_timestarted = true;
	self.ms_time = 0;
	string  = "";

	while (self.ms_time < 998)
	{
		self.ms_time++;
		if (self.ms_time < 10)
			string = "00" + self.ms_time;
		else if (self.ms_time < 100)
			string = "0" + self.ms_time;
		else
			string = "" + self.ms_time;

		self SetClientDvar("minesweeper_timer", string);
		wait 1;
	}
}

revealBoard(xpos, ypos)
{
	for (x = 0; x < 9; x++)
	{
		for (y = 0; y < 9; y++)
		{
			if (self.type[x][y] == "mine")
			{
				if (x == xpos && y == ypos)
					self SetClientDvar("minesweeper_cellshader" + x + "_" + y, "minesweeper_minered");
				else
					self SetClientDvar("minesweeper_cellshader" + x + "_" + y, "minesweeper_mine");
			}
		}
	}
}

checkIfWon()
{
	count = 0;
	for (x = 0; x < 9; x++)
	{
		for (y = 0; y < 9; y++)
		{
			if (self.type[int(x)][int(y)] == "flag")
			{
				if (self.oldtype[int(x)][int(y)] != "mine")
					continue;
			}
			if (self.hidden[int(x)][int(y)])
				count++;
		}
	}
	if (count  == 81 - self.mines)
	{
		self SetClientDvar("minesweeper_face", "minesweeper_glasses");
		self updateScore();
	}
}

updateScore()
{
	info = [];
	info["name"] = self.name;
	info["time"] = self.ms_time;
	info["clicks"] = self.numOfClicks;

	current = "^2Last Game:\n^7" + info["name"] + "\n" + info["time"] + " Seconds\n" + info["clicks"] + " Clicks";

	if (!isDefined(self.ms_personalbest["time"]))
		self.ms_personalbest = info;
	else
	{
		if (self.ms_personalbest["time"] > info["time"])
			self.ms_personalbest = info;
	}

	pb = "^2Person Best:\n^7" + self.ms_personalbest["name"] + "\n" + self.ms_personalbest["time"] + " Seconds\n" + self.ms_personalbest["clicks"] + " Clicks";

	self SetClientDvar("minesweeper_stats", current + "\n \n \n" + pb);
}

openSurroundingMines(x, y)
{
	self endon("minesweep_gameover");
	self endon("disconnect");

	oldX = x;
	oldY = y;
	wait 0.05;

	for (i = -1; i < 2; i++)
	{
	    x = i + oldX;
	    for (j = -1; j < 2; j++)
	    {
	        y = j + oldY;
	        if (x > -1 && x < 9 && y < 9 && y > -1 && self.type[x][y] != "mine" && !self.hidden[int(x)][int(y)])
			{
				self SetClientDvar("hideminebutton" + x + "_" + y, "true");
				self.hidden[int(x)][int(y)] = true;
				if (self.type[x][y] == "0")
					thread openSurroundingMines(x,y);
			}
	    }
	}
}

getSurroundingMines(x, y)
{
	surroundingMines = 0;

	oldX = x;
	oldY = y;

	for (i = -1; i < 2; i++)
	{
	    x = i + oldX;
	    for (j = -1; j < 2; j++)
	    {
	        y = j + oldY;
	        if (x <= 8 && x >= 0 && y <=8 && y >= 0)
			{
				if (self.type[x][y] == "mine")
					surroundingMines++;
			}
	    }
	}
	return surroundingMines;
}

setStringColour(mines)
{
	string = "";
	if (mines == 1)
		string = "^4" + mines;
	if (mines == 2)
		string = "^2" + mines;
	if (mines == 3)
		string = "^1" + mines;
	if (mines == 4)
		string = "^0" + mines;
	if (mines == 5)
		string = "^9" + mines;
	if (mines == 6)
		string = "^5" + mines;
	if (mines == 7)
		string = "^3" + mines;
	if (mines == 8)
		string = "^6" + mines;
	return string;
}
