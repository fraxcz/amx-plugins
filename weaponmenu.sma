#include <amxmodx>
#include <fun>
#define PLUGIN "super Jump"
#define VERSION "1.0"
#define AUTHOR "frax"

public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("amx_weapons", "PrimaryMenu")
}

public PrimaryMenu(id){
    new menu = menu_create("Primary weapon menu", "menu_handler")
    menu_additem(menu, "\w AK-47", "P", 0)
    menu_additem(menu, "\w m4a1-s", "P", 0)
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) //this is redundant, but we can actually set this to not be able to exit the menu
    menu_display(id, menu, 0)
}

public SecondaryMenu(id)
{
    new menu = menu_create("Secondary weapon menu", "menu_handler")
    menu_additem(menu, "\w usp-s", "S", 0)
    menu_additem(menu, "\w glock-18", "S", 0)
    menu_display(id, menu, 0)
}

public menu_handler(id, menu, item){
    if (item == MENU_EXIT){
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    new data[6], name[64]
    new item_access, item_callback

    menu_item_getinfo(menu, item, item_access, data, charsmax(data), name, charsmax(name), item_callback)

    switch(data[0]){
        case 'P':
        {
            switch(item){
                case 0:
                {
                    give_item(id, "weapon_ak47")
                }
                case 1:
                {
                    give_item(id, "weapon_m4a1")
                }
            }
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
