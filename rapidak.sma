#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "super Jump"
#define VERSION "1.0"
#define AUTHOR "frax"

public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR)
    //hook a weapon that is shot from (post 0 or 1 depends on what are you trying to achieve)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPre", 0)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "PrimaryAttackPost", 1)
}

public PrimaryAttackPre(weaponid){

    //m_flAccuracy
    set_pdata_float(weaponid, 62, 0.0, 4)

    //shotsfired
    set_pdata_int(weaponid, 64, 0, 4)
    return HAM_IGNORED
}

public PrimaryAttackPost(weaponid){
    new m_iClip
    new id = get_pdata_cbase(weaponid, 41, 4)
    //get a value from entity (ak47) private data
    m_iClip = get_pdata_int(weaponid, 51, 4)
    set_pdata_int(weaponid, 51, m_iClip + 1, 4)

    //punchangle
    new Float:zero[3] = {0.0, 0.0, 0.0}
    set_pev(id, pev_punchangle, zero)

    return HAM_IGNORED
}
