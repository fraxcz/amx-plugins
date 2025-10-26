#include <amxmodx>
#include <fun>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN "give weapons to bots"
#define VERSION "1.0"
#define AUTHOR "frax"

new g_pcGiveWeaponsToBots;
new g_weaponPrimaryClassnames[][] = {"ak47", "m4a1", "famas", "galil", "aug", "sg552", "m249", "awp", "scout", "g3sg1", "sg550", "xm1014", "m3", "mp5navy", "p90", "ump45", "tmp", "mac10"}

new g_weaponSecondaryClassnames[][] = {"glock18" ,"usp", "p228", "deagle", "fiveseven", "elite"}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_pcGiveWeaponsToBots = create_cvar("amx_give_weapons_to_bots", "1.0", FCVAR_NONE, "Gives weapons to bots.", true, 0.0, true, 1.0)
    RegisterHamPlayer(Ham_Spawn, "give_weapon_to_bots", 1)
}

public give_weapon_to_bots(id)
{
    if(is_user_bot(id))
    {
        strip_user_weapons(id)
        give_item(id, "weapon_knife")
    }

    if(get_pcvar_num(g_pcGiveWeaponsToBots) == 0 || !is_user_bot(id) || get_user_team(id) == 1)
        return HAM_IGNORED

    strip_user_weapons(id)
    new primWeapon[20]
    new secWeapon[20]
    formatex(primWeapon, 20, "weapon_%s", g_weaponPrimaryClassnames[random_num(0, 17)])
    formatex(secWeapon, 20, "weapon_%s", g_weaponSecondaryClassnames[random_num(0, 5)])

    give_item(id, primWeapon)
    give_item(id, secWeapon)
    return HAM_IGNORED
}