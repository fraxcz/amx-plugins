#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#define PLUGIN "weapon menu"
#define VERSION "1.0"
#define AUTHOR "frax"

new g_iPlayers[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("amx_weapons", "primaryMenu")
    RegisterHamPlayer(Ham_Spawn, "fw_hamSpawn", 1)
}

public fw_hamSpawn(id)
{

    g_iPlayers[id] = 0

    if(is_user_alive(id))
    {
        strip_user_weapons(id)
        give_item(id, "weapon_knife")
    }
    else
        return PLUGIN_HANDLED
    
    if(cs_get_user_team(id) == CS_TEAM_CT)
    {
        g_iPlayers[id] = 1
    }

    primaryMenu(id)
    
    return PLUGIN_HANDLED
}

public primaryMenu(id)
{

    if(g_iPlayers[id] == 0 && !(get_user_flags(id) & ADMIN_RCON))
        return PLUGIN_HANDLED

    new menu = menu_create("Primary weapon menu", "menu_handler")

    menu_additem(menu, "\w AK-47", "P", 0)
    menu_additem(menu, "\w m4a1-s", "P", 0)
    menu_additem(menu, "\w super ak-47", "P")
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) //this is redundant, but we can actually set this to not be able to exit the menu
    menu_display(id, menu, 0)

    return PLUGIN_HANDLED
}

public SecondaryMenu(id)
{
    new menu = menu_create("Secondary weapon menu", "menu_handler")

    menu_additem(menu, "\w usp-s", "S", 0)
    menu_additem(menu, "\w glock-18", "S", 0)
    menu_display(id, menu, 0)

    return PLUGIN_HANDLED
}

public menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)

        return PLUGIN_HANDLED
    }

    new data[6], name[64]
    new item_access, item_callback

    menu_item_getinfo(menu, item, item_access, data, charsmax(data), name, charsmax(name), item_callback)

    switch(data[0])
    {
        case 'P':
        {
            switch(item)
            {
                case 0:
                {
                    give_item(id, "weapon_ak47")
                }
                case 1:
                {
                    give_item(id, "weapon_m4a1")
                }
                case 2:
                {
                    callfunc_begin("give_player_rapidak", "rapidak.amxx")
                    callfunc_push_int(id)
                    callfunc_end()
                }
            }

            g_iPlayers[id] = 0

            SecondaryMenu(id)
        }
        
        case 'S':
        {
            switch(item)
            {
                case 0:
                {
                    give_item(id, "weapon_usp")
                }
                case 1:
                {
                    give_item(id, "weapon_glock18")
                }
            }
        }
    }

    menu_destroy(menu)

    return PLUGIN_HANDLED
}
