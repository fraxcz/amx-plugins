#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <cstrike>
#include <fun>

/* Models */

#define MDL_VIEW "models/v_hk.mdl" // View model (What you see when holding the weapon)
#define MDL_WORLD "models/w_hk.mdl" // World model (What you see when SOMEONE is holding the weapon)

/* Sounds */

#define SOUND_SHOOT1 "weapons/hk-1.wav" // Weapon sound 1
#define SOUND_SHOOT2 "weapons/hk-2.wav" // Weapon sound 2

/* Properties */

new Float:WAIT_TIME = 0.2 // Delay (MAY BE VEEEERY BUGGY)
new Float:WAIT_TIME_SCOPE = 0.25 // Scope delay

new bool:g_bCantShoot[33] // We will use this in order to check/delay every shoot
new bool:g_bDidShoot[33] // We will use this in order to check/delay sounds

new bool:g_bCantScope[33] // We will use this in order to check/delay zooming

new bool:g_bMagSet[33]

/* Other stuff */

new explosion_sprite

#define CSW_HK CSW_GALIL
#define HK_MAXAMMO 50

public plugin_init()
{
	register_plugin(random(1) ? "H&K Weapon" : "Weapon modifying tutorial","","thEsp (4D1)")

	register_forward(FM_UpdateClientData,"fwUpdateClientDataPost",1) // Hooks client-side changes
	register_forward(FM_SetModel,"fwSetModelPost",1)
	
	RegisterHam(Ham_Weapon_PrimaryAttack,"weapon_galil","hamShotPre",0) // Hooks shooting
	RegisterHam(Ham_Weapon_PrimaryAttack,"weapon_galil","hamShotPost",1) // Hooks shooting
	/* 
		Both forwards above CANNOT be reigstered from "player"(s)
		Elsewise server MAY even crash or plugin might not work completely
	*/
	RegisterHam(Ham_Item_PostFrame,"weapon_galil","hamScopePre",0) // Hooks secondary attack
	RegisterHam(Ham_Weapon_Reload,"weapon_galil","hamReloadPre",0) // Hooks weapon reload
	RegisterHam(Ham_Item_PreFrame,"weapon_galil","hamGalilUsagePre",1) // Hooks clip size
	
	register_event("CurWeapon","evWeaponChanged","be","1=1") // Hooks weapon changing/switching
}

public plugin_precache()
{
	// Precaches models,sounds and sprites (If not did so, server will crash upon start)
	precache_model(MDL_VIEW)
	precache_model(MDL_WORLD)
	precache_sound(SOUND_SHOOT1)
	precache_sound(SOUND_SHOOT2)
	
	explosion_sprite = precache_model("sprites/zerogxplode.spr")
}

public fwUpdateClientDataPost(id,sendweapons,cd_handle) // Special thanks to EFFx
{
	if(!g_bCantShoot[id]) return PLUGIN_CONTINUE // Returns if player CAAAAN shoot
	set_cd(cd_handle,CD_flNextAttack,WAIT_TIME)  // Blocks shooting for some time
	return FMRES_HANDLED
}

public fwSetModelPost(entity,const model[])
{
	if(pev_valid(entity) && equal(model,"models/w_galil.mdl"))
	{
		new id = entity_get_edict(entity,EV_ENT_owner) // Gets entity(galil)'s owner index
		entity_set_string(entity,EV_SZ_model,MDL_WORLD)
		g_bMagSet[id] = false
		return FMRES_SUPERCEDE
	}
	return -0 // Nothing
}

public hamShotPre(galil)
{
	if(WAIT_TIME<=0.1) return HAM_HANDLED // Returns if there's no delay
	new id = entity_get_edict(galil,EV_ENT_owner) // Gets entity(galil)'s owner index
	
	if(!g_bCantShoot[id])
	{
		g_bCantShoot[id] = true // Declare that player CAN'T shoot (Delay)
		g_bDidShoot[id] = true // Declare that player DID shoot
		set_task(WAIT_TIME,"tskSetShotAvailability",id)
	}else 
	{
		g_bDidShoot[id]=false // Declare that player DIDN'T shoot
		return HAM_SUPERCEDE // If player can't shoot because of delay, returns and blocks shooting
	}
	return HAM_IGNORED // Returns once again in the end so compiler doesn't throw a warning (AFAIK 1.9+)
}

public hamShotPost(galil)
{
	new id = entity_get_edict(galil,EV_ENT_owner) // Gets index of player who is holding the gun

	static clip,ammo
	get_user_ammo(id,get_user_weapon(id),clip,ammo)
	
	/*
		Code below CHECKS if player just shooted AND has bullets in clip 
		If second check isn't performed, player(s) will still be able to hear gun shots
		
		Variable "sound" is a random number from 1 to 2
		It will be used to allocate random gunshot sound VIA switch statement
		
		The third/fourth statement CHECKS if variable WAIT_TIME is less or equal to 0.1
		It will be used to check if there is no delay
		If this is not performed, weapon(galil) will be bugged, as well as the game

	*/
	
	if(g_bDidShoot[id] && clip!=0 || WAIT_TIME<=0.1 && clip!=0) 
	{
		new sound = random_num(1,2) // Random number for 1 to 2
		switch(sound)
		{
			case 1: emit_sound(id,CHAN_AUTO,SOUND_SHOOT1,1.0,ATTN_NORM,0,PITCH_NORM) // First gunshot
			case 2: emit_sound(id,CHAN_AUTO,SOUND_SHOOT2,1.0,ATTN_NORM,0,PITCH_NORM) // Second gunshot
		}
			
		new aim_position[3]; get_user_origin(id,aim_position,3) // Gets aiming position
		te_create_explosion(aim_position,explosion_sprite) // Makes an explosion effect at aiming position
		
		//RadiusDamage(aim_position,50,10)
	}
	return HAM_SUPERCEDE // Probably unnecessary 
}

public hamScopePre(galil)
{
	new id = entity_get_edict(galil,EV_ENT_owner) // Gets index of player who is holding the gun

	new buttons = entity_get_int(id,EV_INT_button)

	if(buttons & IN_ATTACK2)
	{
		if(!g_bCantScope[id])
		{
			if(!(cs_get_user_zoom(id) & CS_SET_AUGSG552_ZOOM))
			{
				cs_set_user_zoom(id,CS_SET_AUGSG552_ZOOM,1) // Sets zooming
				g_bCantScope[id] = true
				set_task(WAIT_TIME_SCOPE,"tskSetScopeAvailability",id)
			}else
			{
				cs_set_user_zoom(id,CS_RESET_ZOOM,1) // Removes zooming
				g_bCantScope[id] = true // Declares that player CAAAN zoom
				set_task(WAIT_TIME_SCOPE,"tskSetScopeAvailability",id)
			}
		}
	}
}

public hamReloadPre(galil)
{
	new id = entity_get_edict(galil,EV_ENT_owner) // Gets index of player who is holding the gun
	
	static clip,ammo
	get_user_ammo(id,get_user_weapon(id),clip,ammo) // Gets clip and ammo number
	
	if(clip == HK_MAXAMMO) return HAM_SUPERCEDE // Returns if weapon has as much bullets as prechanged value is 
	
	cs_set_user_zoom(id,CS_RESET_ZOOM,1)
	g_bCantScope[id] = false // Declares that player CAAAN scope
	set_task(2.7,"tskChangeAmmo",id) // Sets a task to reset availability for reloading
	
	return HAM_HANDLED
}

public hamGalilUsagePre(galil)
{
	new id = entity_get_edict(galil,EV_ENT_owner) // Gets index of player who is holding the gun
	
	if(!g_bMagSet[id])
	{
		#define fm_cs_set_weapon_ammo(%1,%2) set_pdata_int(%1, 51, %2, 4)
		fm_cs_set_weapon_ammo(get_pdata_cbase(id,373),HK_MAXAMMO)
		g_bMagSet[id] = true
	}
}

public evWeaponChanged(id)
{
	new weapon = read_data(2) // Gets weapon index (Could also be removed and replaced with read_data(2) )
	if(weapon == CSW_HK) // Checks if changed weapon is Hk
	{
		entity_set_string(id,EV_SZ_viewmodel,MDL_VIEW) // Sets players view model 
	}
}

public tskSetShotAvailability(id)
{
	g_bCantShoot[id] = false // Declare that player CAAAN shoot
}

public tskSetScopeAvailability(id)
{
	g_bCantScope[id] = false // Declare that player CAAAN shoot
}

public tskChangeAmmo(id)
{
	g_bMagSet[id] = false
}

/* Stock below taken from OciXCrom's message stocks header */
stock te_create_explosion(position[3],sprite,scale=10,framerate=30,flags=TE_EXPLFLAG_NONE,receiver=0)
{
	if(receiver && !is_user_connected(receiver))
		return 0
	message_begin(MSG_ALL,SVC_TEMPENTITY,_,receiver)
	write_byte(TE_EXPLOSION)
	write_coord(position[0])
	write_coord(position[1])
	write_coord(position[2])
	write_short(sprite)
	write_byte(scale)
	write_byte(framerate)
	write_byte(flags)
	message_end()
	return 1
}


/* For intermediate coders :

	The reason I had to also use engine is because some pev/set_pev functions don't work properly
	And what I found "crazy" is that I simply couldn't even chagne viewmodel using fakemeta

	Seems that engine is far superior to fakemeta (?)
*/
