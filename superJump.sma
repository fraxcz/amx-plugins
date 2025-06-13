#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#define PLUGIN "super Jump"
#define VERSION "1.0"
#define AUTHOR "frax"

new forwardForce;
new upForce;
new cooldown;
new Float:players[32];
public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR)
    forwardForce = create_cvar("amx_superjump_forward_force", "1.0", FCVAR_NONE, "Sets forward force boost.", false, 0.0, false)
    upForce = create_cvar("amx_superjump_up_force", "1.0", FCVAR_NONE, "Sets up force boost.", false, 0.0, false)
    cooldown = create_cvar("amx_superjump_cooldown", "1.0", FCVAR_NONE, "A cooldown for superjump", true, 0.0, false)
    register_impulse(100, "superjump");
}

public client_disconnected(id){
    players[id] = 0.0
}

public client_putinserver(id){
    players[id] = get_gametime();
}


public superjump(id){
    if(players[id] > get_gametime()){
        return PLUGIN_HANDLED
    }

    new Float:angles[3]; //pitch, yaw, roll
    new Float:vector[3];
    pev(id, pev_v_angle, angles);
    vector[0] = floatcos(angles[1], degrees) * floatcos(angles[0], degrees) * get_pcvar_float(forwardForce)
    vector[1] = floatsin(angles[1], degrees) * floatcos(angles[0], degrees) * get_pcvar_float(forwardForce)
    vector[2] = get_pcvar_float(upForce)
    set_pev(id, pev_velocity, vector)
    players[id] = get_gametime() + get_pcvar_float(cooldown);
    return PLUGIN_HANDLED
}