FILE_OpenMod(path)
{
    return FILE_Open(PathJoin(getDvar("fs_game"), path));
}
