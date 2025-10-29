#include <amxmodx>
#include <amxmisc>
#include <json>
#include <fakemeta>

#define PLUGIN "weapon menu enhanced"
#define VERSION "1.0"
#define AUTHOR "frax"

#define ARRAYLEN 35

enum _:e_WeaponSlot
{
    Primary = 1,
    Secondary
}

 enum _:e_Weapons
 {
    WeaponClassName[ARRAYLEN],
    WeaponAmxxFile[ARRAYLEN],
    WeaponCallbackFunction[ARRAYLEN],
    WeaponSlot[e_WeaponSlot]

 }

new Array:g_aWeapons


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_concmd("amx_show_weapons", "print_array")
    register_forward(FM_ChangeLevel, "level_end", 1)

    //Dynamic array init
    new dummy[e_Weapons]
    g_aWeapons = ArrayCreate(sizeof(dummy))
    readJsonFile()
}

public print_array(id)
{
    new weapon[e_Weapons]

    console_print(id, "-----------------------------")
    console_print(id, "")
    console_print(id, "Number of weapons: %d", ArraySize(g_aWeapons))

    for(new i = 0; i < ArraySize(g_aWeapons); i++)
    {
        ArrayGetArray(g_aWeapons, i, weapon)

        console_print(id, "Weapon Classname: %s, weapon amxx file: %s, weapon's give function: %s, Weapon slot: %d", weapon[WeaponClassName], weapon[WeaponAmxxFile], weapon[WeaponCallbackFunction], weapon[WeaponSlot])
    }
    console_print(id, "")
    console_print(id, "-----------------------------")
    return PLUGIN_HANDLED
}

public readJsonFile()
{
    new JSON:jConfigsFile = json_parse("addons/amxmodx/data/weaponmenu.txt", true, true)
    if(jConfigsFile == Invalid_JSON)
    {
        server_print("failed to load a file")
        return PLUGIN_HANDLED
    }
    json_free(jConfigsFile)
    return
}

public level_end()
{
    ArrayDestroy(g_aWeapons)
}