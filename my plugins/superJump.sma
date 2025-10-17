#include <amxmodx>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "super Jump"
#define VERSION "1.0"
#define AUTHOR "frax"

new forwardForce;
new upForce;
new cooldown;
new Float:players[32];
public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR)
    forwardForce = create_cvar("amx_superjump_forward_force", "500.0", FCVAR_NONE, "Sets forward force boost.", false, 0.0, false)
    upForce = create_cvar("amx_superjump_up_force", "270.0", FCVAR_NONE, "Sets up force boost.", false, 0.0, false)
    cooldown = create_cvar("amx_superjump_cooldown", "1.0", FCVAR_NONE, "A cooldown for superjump", true, 0.0, false)
    RegisterHam(Ham_Player_Jump, "player", "superjump", 1)
}

public client_disconnected(id){
    players[id] = 0.0
}

public client_putinserver(id){
    players[id] = get_gametime();
}


public superjump(id){
    new player_flags = pev(id, pev_flags)
    if(players[id] > get_gametime() || cs_get_user_team(id) == CS_TEAM_CT || (player_flags & FL_ONGROUND) == 0 || (player_flags & FL_DUCKING) == 0){
        return PLUGIN_CONTINUE
    }

    new Float:vector[3];
    new Float:f_forwardForce = get_pcvar_float(forwardForce)

    velocity_by_aim(id, 1, vector)
    vector[0] *= f_forwardForce
    vector[1] *= f_forwardForce
    vector[2] = get_pcvar_float(upForce)

    set_user_velocity(id, vector)

    players[id] = get_gametime() + get_pcvar_float(cooldown);
    return PLUGIN_HANDLED
}