#include sr\sys\_admins;
#include sr\game\minigames\_main;
#include sr\game\minigames\_minesweeper;

main()
{
    cmd("player", "mine", ::cmd_Minesweeper);
}

cmd_Minesweeper(args)
{
    open();
}
