#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <fakemeta>
#include <nvault>

new const PLUGIN[] = "KnifeMenu Skin Changer"
new const VERSION[] = "1.8.1b"
new const AUTHOR[] = "Nightmare"

#define MAXPLAYERS 32

new const KnifeNames[][] = {
	
	"Podstawowy",
	"Crisom Web",
	"Doppler",
	"Fade",
	"\r[PREMIUM]\w Shadow Daggers",
	"\r[PREMIUM]\w Deepspace"
}
new const KnifeModels[][] = {
	
	"models/v_knife.mdl",
	"models/knifes/crimsonweb.mdl",
	"models/knifes/dopplerphase4.mdl",
	"models/knifes/fade.mdl",
	"models/knifes/dagger.mdl",
	"models/knifes/deepspace.mdl"
}
new FlagsKnife[] = {
	
	0,
	0,
	0,
	0,
	ADMIN_LEVEL_H,
	ADMIN_LEVEL_H
}

new player_knife[MAXPLAYERS+1]
new g_vault

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	register_clcmd("say /knife", "Knife")
	register_clcmd("say /kosy", "Knife")
	
	g_vault = nvault_open("KnifeBase");
	
	register_dictionary("knifemenu.txt")
}
public plugin_precache() {
	
	for (new i = 0; i < sizeof KnifeModels; i++)
	precache_model(KnifeModels[i]);
	
}
public client_connect(id) {
	player_knife[id] = 0;
	LoadKnife(id);
}
public client_disconnect(id)
{
	player_knife[id] = 0;
}
public Knife(id) {
	
	static title[80], info[80];
	formatex(title, 79 , "[Knife Skin Changer] %L", LANG_PLAYER, "MENU_TITLE");
	formatex(info, 79 , "%L", LANG_PLAYER, "MENU_INFO");
	
	new menu = menu_create(title, "Callback")
	
	for(new i = 0; i < sizeof(KnifeNames); i++){
		menu_additem(menu , KnifeNames[i], "", FlagsKnife[i], -1);
	}
	menu_addtext(menu, info, 0)
	menu_display(id, menu);
}
public Callback(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(FlagsKnife[item] == 0){
		player_knife[id] = item
		ColorChat(id, GREEN, "[Knife Skin Changer] %L", LANG_PLAYER, "KNIFE_SELECT", KnifeNames[player_knife[id]]);
		Set_Model(id);
		SaveKnife(id);
	}
	else if(FlagsKnife[item] > 0 && get_user_flags(id) & FlagsKnife[item]){
		player_knife[id] = item
		ColorChat(id, GREEN, "[Knife Skin Changer] %L", LANG_PLAYER, "KNIFE_SELECT", KnifeNames[player_knife[id]]);
		Set_Model(id);
		SaveKnife(id);
	}
	return PLUGIN_CONTINUE;
}
public LoadKnife(id){
	
	new g_name[33][64];
	new vaultkey[64],vaultdata[128];
	get_user_name(id, g_name[id], 63);
	formatex(vaultkey,63,"%s", g_name[id]);
	
	if(nvault_get(g_vault,vaultkey,vaultdata,127)) { // pobieramy dane
		new knifeid[16];
		parse(vaultdata, knifeid, 15);
		player_knife[id] = str_to_num(knifeid);
	}
	return PLUGIN_CONTINUE;
	
}
public SaveKnife(id){
	
	new g_name[33][64];
	new vaultkey[64],vaultdata[128];
	get_user_name(id, g_name[id], 63);
	formatex(vaultkey,63,"%s", g_name[id]);
	
	formatex(vaultdata,127," %i", player_knife[id]);
	nvault_set(g_vault,vaultkey,vaultdata);
	
	return PLUGIN_CONTINUE;
}
public Set_Model(id) {
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo)
	
	if (Weapon != CSW_KNIFE)
	return PLUGIN_HANDLED
	
	if (Weapon == CSW_KNIFE) {
		
		set_pev(id, pev_viewmodel2, KnifeModels[player_knife[id]]);
	}
	return PLUGIN_CONTINUE;
	
}
public CurWeapon(id) {
	if (!is_user_alive(id)) {
		return PLUGIN_CONTINUE;
	}
	new weapon = read_data(2);
	
	switch (weapon) {
		case CSW_KNIFE: {
			Set_Model(id)
		}
	}
	return PLUGIN_CONTINUE;
}
