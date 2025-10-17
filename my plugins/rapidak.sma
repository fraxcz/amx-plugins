#include <amxmodx>
#include <engine>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "fast ak-47"
#define VERSION "1.0"
#define AUTHOR "frax"

new Array:g_iWeaponIds
new VIEW_MODEL[] = "models/v_rapidak.mdl"
new g_pcvar_knockback;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_pcvar_knockback = create_cvar("amx_knockbackforce", "10.0", FCVAR_NONE, "knockback force", true, 0.0, false)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPre", 0)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPost", 1)
    RegisterHam(Ham_TakeDamage, "player", "fw_takeDamage", 1)
    RegisterHam(Ham_Item_Deploy, "weapon_ak47", "WeaponDeploy", 1)
    register_event("HLTV", "Event_HLTV_New_Round_phase", "a", "1=0", "2=0")
    register_forward(FM_ChangeLevel, "Level_end", 1)
    g_iWeaponIds = ArrayCreate(1)
}


public plugin_precache()
{
    precache_model(VIEW_MODEL)
}


public give_player_rapidak(id){
        engclient_cmd(id, "drop", "weapon_ak47")
        new weaponid =  give_item(id, "weapon_ak47")
        ArrayPushCell(g_iWeaponIds, weaponid)
}

public remove_rapidak(weaponid)
{
    new weapon_array_index = ArrayFindValue(g_iWeaponIds, weaponid)

    if(weapon_array_index != -1)
        ArrayDeleteItem(g_iWeaponIds, weapon_array_index)
}

public Level_end()
{
    ArrayDestroy(g_iWeaponIds)
}

public Event_HLTV_New_Round_phase()
{
    set_task(0.1, "Event_HLTV_New_Round")
}

public Event_HLTV_New_Round()
{
    clean_ak47_ids()
}

public clean_ak47_ids()
{
    new Array:newWeaponIds = ArrayCreate(1)
    new size = ArraySize(g_iWeaponIds)

    if(size == 0)
        return PLUGIN_CONTINUE

    for (new i = 0; i < size; i++)
    {
        new ent = ArrayGetCell(g_iWeaponIds, i)

        if (is_valid_ent(ent))
            ArrayPushCell(newWeaponIds, ent)
    }

    ArrayDestroy(g_iWeaponIds)
    g_iWeaponIds = newWeaponIds
    return PLUGIN_CONTINUE
}

public fw_takeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{
    new Float:knockback = get_pcvar_float(g_pcvar_knockback)

    if (!is_user_alive(attacker) || attacker == victim || ArrayFindValue(g_iWeaponIds, cs_get_user_weapon_entity(attacker)) == -1)
    {
        return HAM_IGNORED
    }

    
    new Float:attacker_velocity[3]
    velocity_by_aim(attacker, 1, attacker_velocity)

    new Float:victim_velocity[3]
    get_user_velocity(victim, victim_velocity)

    victim_velocity[0] += attacker_velocity[0] * knockback
    victim_velocity[1] += attacker_velocity[1] * knockback

    set_user_velocity(victim, victim_velocity)
    return HAM_IGNORED
}

public WeaponDeploy(weaponid)
{
    if (ArrayFindValue(g_iWeaponIds, weaponid) == -1)
        return HAM_IGNORED

    new id = get_pdata_cbase(weaponid, 41, 4)

    set_pev(id, pev_viewmodel2, VIEW_MODEL)
    return HAM_IGNORED
}

public PrimaryAttackPre(weaponid)
{
    if (ArrayFindValue(g_iWeaponIds, weaponid) == -1)
        return HAM_IGNORED

    //m_flAccuracy
    set_pdata_float(weaponid, 62, 0.0, 4)

    //shotsfired
    set_pdata_int(weaponid, 64, 0, 4)
    return HAM_IGNORED
}

public PrimaryAttackPost(weaponid)
{
    if (ArrayFindValue(g_iWeaponIds, weaponid) == -1)
        return HAM_IGNORED

    new id = get_pdata_cbase(weaponid, 41, 4)

    //punchangle
    new Float:zero[3] = {0.0, 0.0, 0.0}
    set_pev(id, pev_punchangle, zero)

    //fire rate
    new clip
    get_user_weapon(id, clip)

    if(clip > 0)
        set_pdata_float(weaponid, 46, 0.05, 4)

    return HAM_IGNORED
}
