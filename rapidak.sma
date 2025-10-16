#include <amxmodx>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "ak test"
#define VERSION "1.0"
#define AUTHOR "frax"

new players[33]
new VIEW_MODEL[] = "models/v_rapidak.mdl"
new pcKnockBack;

public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR)
    //hook a weapon that is shot from (post 0 or 1 depends on what are you trying to achieve)
    pcKnockBack = create_cvar("amx_knockbackforce", "1.0", FCVAR_NONE, "knockback force", true, 0.0, false)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPre", 0)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPost", 1)
    RegisterHam(Ham_TakeDamage, "player", "fw_takeDamage", 1)
    RegisterHam(Ham_Item_Deploy, "weapon_ak47", "WeaponDeploy", 1)
    RegisterHam(Ham_Player_PostThink, "player", "Ham_PostThink")
}

public plugin_precache(){
    precache_model(VIEW_MODEL)
}

public player_getrapidak(id){
    players[id] = 1
}

public player_droprapidak(id){
    players[id] = 0
}

public Ham_PostThink(id){
    if(!is_user_alive(id))
        return HAM_IGNORED
    new weaponid = get_pdata_cbase(weaponid, 373)
    new Float:weaponidle = get_pdata_float(weaponid, 48, 4)
    client_print(id, print_chat, "m_flTimeWeaponIdle: %.5f", weaponidle)
    return HAM_IGNORED
}
public fw_takeDamage(victim, inflictor, attacker, Float:damage, damage_bits){
    new knockback = get_pcvar_float(pcKnockBack)

    if (!is_user_alive(attacker) || attacker == victim )
        return HAM_IGNORED
    
    new Float:attacker_velocity[3]
    velocity_by_aim(attacker, knockback, attacker_velocity) // direction with knockback multiplier
    attacker_velocity[2] = 0.0

    new Float:victim_velocity[3]
    get_user_velocity(victim, victim_velocity)

    new Float:victim_new_velocity[3]
    victim_new_velocity[0] = attacker_velocity[0] + victim_velocity[0]
    victim_new_velocity[1] = attacker_velocity[1] + victim_velocity[1]
    victim_new_velocity[2] = attacker_velocity[2] + victim_velocity[2]

    set_user_velocity(victim, victim_new_velocity)

    return HAM_IGNORED
}

public WeaponDeploy(weaponid){
    new id = get_pdata_cbase(weaponid, 41, 4)

    if(!players[id])
        return HAM_IGNORED

    set_pev(id, pev_viewmodel2, VIEW_MODEL)
    return HAM_IGNORED
}

public PrimaryAttackPre(weaponid){
    new id = get_pdata_cbase(weaponid, 41, 4)

    if(!players[get_pdata_cbase(weaponid, 41, 4)])
        return HAM_IGNORED

    //m_flAccuracy
    set_pdata_float(weaponid, 62, 0.0, 4)

    //shotsfired
    set_pdata_int(weaponid, 64, 0, 4)
    return HAM_IGNORED
}

public PrimaryAttackPost(weaponid){
    new id = get_pdata_cbase(weaponid, 41, 4)
    if(!players[id])
        return HAM_IGNORED

    //punchangle
    new Float:zero[3] = {0.0, 0.0, 0.0}
    set_pev(id, pev_punchangle, zero)

    //fire rate
    set_pdata_float(weaponid, 46, 0.05, 4)

    return HAM_IGNORED
}
