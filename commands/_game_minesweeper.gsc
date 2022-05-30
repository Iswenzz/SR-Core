#include sr\sys\_admins;
#include sr\game\_minesweeper;

main()
{
    cmd("player", "mine", ::cmd_Minesweeper);
}

cmd_Minesweeper()
{
    open();
}
