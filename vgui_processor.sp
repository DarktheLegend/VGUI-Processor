#pragma semicolon 1

#define DEBUG 0

#define PLUGIN_AUTHOR "Dark"
#define PLUGIN_VERSION "0.2"
#define LoopPlayers(%0) for (int %0 = 1; %0 <= MaxClients; %0++) if (IsClientInGame(%0) && !IsFakeClient(%0))

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <vgui_processor>
#include <json>

#pragma newdecls required

JSON_Object VGUIText[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "VGUI Processor",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "bamigos.ru"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max) {
	CreateNative("VGUI_CreateText", Native_CreateText);
	CreateNative("VGUI_ChangeText", Native_ChangeText);
	CreateNative("VGUI_DeleteText", Native_DeleteText);
	CreateNative("VGUI_ExistText", Native_ExistText);
	CreateNative("VGUI_PluginUnload", Native_PluginUnload);
	RegPluginLibrary("vgui_processor");
	return APLRes_Success;
}

public void OnPluginStart() {
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerTeam);
	LoopPlayers(client) {
		VGUIText[client] = new JSON_Object();
		SDKHook(client, SDKHook_Spawn, Hook_Spawn);
	}
}

public void OnPluginEnd() {
	LoopPlayers(client) {
		if (VGUIText[client] != null && VGUIText[client].Size) {
			char key[64];
			int ent;
			JSON_Object json;
			StringMapSnapshot snapPlugins = VGUIText[client].Snapshot();
			StringMapSnapshot snapTexts;
			for (int i = 0; i < snapPlugins.Length; i++) {
				snapPlugins.GetKey(i, key, sizeof(key));
				if (json_is_meta_key(key))continue;
				json = VGUIText[client].GetObject(key);
				snapTexts = json.Snapshot();
				for (int j = 0; j < snapTexts.Length; j++) {
					snapTexts.GetKey(j, key, sizeof(key));
					if (json_is_meta_key(key))continue;
					ent = json.GetObject(key).GetInt("entity");
					if (IsValidEntity(ent) && ent) {
						RemoveEntity(ent);
					}
				}
				snapTexts.Close();
			}
			snapPlugins.Close();
		}
	}
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_Spawn, Hook_Spawn);
	if (VGUIText[client] != null)json_cleanup_and_delete(VGUIText[client]);
	VGUIText[client] = new JSON_Object();
}

public void OnClientDisconnect(int client) {
	SDKUnhook(client, SDKHook_Spawn, Hook_Spawn);
	if (VGUIText[client] != null) {
		if (VGUIText[client].Size) {
			char key[64];
			int ent;
			JSON_Object json;
			StringMapSnapshot snapPlugins = VGUIText[client].Snapshot();
			StringMapSnapshot snapTexts;
			for (int i = 0; i < snapPlugins.Length; i++) {
				snapPlugins.GetKey(i, key, sizeof(key));
				if (json_is_meta_key(key))continue;
				json = VGUIText[client].GetObject(key);
				snapTexts = json.Snapshot();
				for (int j = 0; j < snapTexts.Length; j++) {
					snapTexts.GetKey(j, key, sizeof(key));
					if (json_is_meta_key(key))continue;
					ent = json.GetObject(key).GetInt("entity");
					if (IsValidEntity(ent) && ent) {
						RemoveEntity(ent);
					}
				}
				snapTexts.Close();
			}
			snapPlugins.Close();
		}
		json_cleanup_and_delete(VGUIText[client]);
	}
}

public Action Hook_Spawn(int client) {
	if (VGUIText[client] != null && VGUIText[client].Size) {
		char plugin[16], name[64];
		JSON_Object json;
		StringMapSnapshot snapPlugins = VGUIText[client].Snapshot();
		StringMapSnapshot snapTexts;
		for (int i = 0; i < snapPlugins.Length; i++) {
			snapPlugins.GetKey(i, plugin, sizeof(plugin));
			if (json_is_meta_key(plugin))continue;
			json = VGUIText[client].GetObject(plugin);
			snapTexts = json.Snapshot();
			for (int j = 0; j < snapTexts.Length; j++) {
				snapTexts.GetKey(j, name, sizeof(name));
				if (json_is_meta_key(name))continue;
				CreateText(client, plugin, name, view_as<VGUIParams>(json.GetObject(name)), true);
			}
			snapTexts.Close();
		}
		snapPlugins.Close();
	}
	return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VGUIText[client] != null && VGUIText[client].Size) {
		char key[64];
		int ent;
		JSON_Object json;
		StringMapSnapshot snapPlugins = VGUIText[client].Snapshot();
		StringMapSnapshot snapTexts;
		for (int i = 0; i < snapPlugins.Length; i++) {
			snapPlugins.GetKey(i, key, sizeof(key));
			if (json_is_meta_key(key))continue;
			json = VGUIText[client].GetObject(key);
			snapTexts = json.Snapshot();
			for (int j = 0; j < snapTexts.Length; j++) {
				snapTexts.GetKey(j, key, sizeof(key));
				if (json_is_meta_key(key))continue;
				ent = json.GetObject(key).GetInt("entity");
				if (IsValidEntity(ent) && ent) {
					RemoveEntity(ent);
				}
			}
			snapTexts.Close();
		}
		snapPlugins.Close();
	}
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VGUIText[client] != null && VGUIText[client].Size) {
		char key[64];
		int ent;
		JSON_Object json;
		StringMapSnapshot snapPlugins = VGUIText[client].Snapshot();
		StringMapSnapshot snapTexts;
		for (int i = 0; i < snapPlugins.Length; i++) {
			snapPlugins.GetKey(i, key, sizeof(key));
			if (json_is_meta_key(key))continue;
			json = VGUIText[client].GetObject(key);
			snapTexts = json.Snapshot();
			for (int j = 0; j < snapTexts.Length; j++) {
				snapTexts.GetKey(j, key, sizeof(key));
				if (json_is_meta_key(key))continue;
				ent = json.GetObject(key).GetInt("entity");
				if (IsValidEntity(ent) && ent) {
					RemoveEntity(ent);
				}
			}
			snapTexts.Close();
		}
		snapPlugins.Close();
	}
}

void CreateText(int client, const char[] plugin, const char[] name, VGUIParams params, bool jsonobject = false) {
	if (!jsonobject && CheckName(client, plugin, name))return;
	int ent = CreateEntityByName("vgui_world_text_panel");
	if (ent == -1)return;
	int textLen = params.GetTextLength();
	bool validText;
	char[] text = new char[textLen];
	if (!(validText = params.GetText(text, textLen))) {
		textLen = 1;
	}
	float Xaxis, Yaxis;
	if (!params.GetXaxis(Xaxis))Xaxis = 0.0;
	if (!params.GetYaxis(Yaxis))Yaxis = 0.0;
	int color[4];
	if (!params.GetColor(color))color = { 255, 255, 255, 255 };
	static char buff[32];
	DispatchKeyValue(ent, "displaytext", validText ? text : "");
	DispatchKeyValue(ent, "font", "MissionSelectLarge");
	DispatchKeyValue(ent, "height", "4");
	DispatchKeyValue(ent, "width", "4");
	IntToString(RoundToNearest(Pow(16.0, 2.0)), buff, sizeof(buff));
	DispatchKeyValue(ent, "textpanelwidth", "1024");
	Format(buff, sizeof(buff), "%d %d %d %d", color[0], color[1], color[2], color[3]);
	DispatchKeyValue(ent, "textcolor", buff);
	DispatchKeyValue(ent, "enabled", "1");
	JSON_Object json;
	if (jsonobject) {
		json = view_as<JSON_Object>(params);
	} else {
		json = new JSON_Object();
	}
	json.SetInt("entity", EntIndexToEntRef(ent));
	json.SetString("text", validText ? text : "");
	json.SetInt("textlen", textLen);
	if (!VGUIText[client].HasKey(plugin))VGUIText[client].SetObject(plugin, new JSON_Object());
	VGUIText[client].GetObject(plugin).SetObject(name, json);
	TeleportText(client, plugin, name, Xaxis, Yaxis);
	DispatchSpawn(ent);
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));
}

void TeleportText(int client, const char[] plugin, const char[] name, float Xaxis = 0.0, float Yaxis = 0.0) {
	JSON_Object json = VGUIText[client].GetObject(plugin).GetObject(name);
	if (!json) {
		LogError("Teleport text failure: invalid id of text %s", name);
		#if DEBUG == 1
			PrintToChat(client, "Teleport text failure: invalid id of text %s", name);
		#endif
		return;
	}
	float pos[3], ang[3];
	int ent = json.GetInt("entity");
	if (!IsValidEntity(ent) && IsPlayerAlive(client)) {
		int maxlen = json.GetInt("textlen");
		char[] text = new char[maxlen];
		json.GetString("text", text, maxlen);
		char font[64];
		json.GetString("font", font, sizeof(font));
		CreateText(client, plugin, name, view_as<VGUIParams>(json));
		return;
	}
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
	pos[0] += 12.0 * Cosine(DegToRad(ang[1])) - (Yaxis / 10.0 * Cosine(DegToRad(ang[1]))); //Вглубь экрана (дальше, меньше шрифт)
	pos[1] += 12.0 * Sine(DegToRad(ang[1])) - (Yaxis / 10.0 * Sine(DegToRad(ang[1]))); //Вглубь экрана (дальше, меньше шрифт)
	pos[0] += (3.0 - Xaxis) * Sine(-DegToRad(ang[1])); // Влево экрана (спавнится по дефолту справа экрана, 128 - середина)
	pos[1] += (3.0 - Xaxis) * Cosine(-DegToRad(ang[1])); // Влево экрана (спавнится по дефолту справа экрана, 128 - середина)
	pos[2] += Yaxis + 2.0; // Вверх экрана (-32 - внизу, середина рук)
	ang[0] = 0.0; // Поворот по горизонту
	ang[1] -= 90.0; // Поворот по вертикали (-90 - развернуть лицом к игроку)
	ang[2] = 90.0; // Поворот как в титры в StarWars (уходящая в даль стена)
	if (IsValidEntity(ent)) {
		AcceptEntityInput(ent, "SetParent");
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	}
	json.SetFloat("x-axis", Xaxis);
	json.SetFloat("y-axis", Yaxis);
}

void ChangeText(int client, const char[] plugin, const char[] name, VGUIParams params) {
	if (!CheckName(client, plugin, name)) {
		LogError("Change: The text name %s does not exist", name);
		#if DEBUG == 1
			PrintToChat(client, "Change: The text name %s does not exist", name);
		#endif
		return;
	}
	JSON_Object json = VGUIText[client].GetObject(plugin).GetObject(name);
	int ent = json.GetInt("entity");
	if (!IsValidEntity(ent)) {
		if (IsPlayerAlive(client)) {
			LogError("Change: The text entity %i does not exist", ent);
			#if DEBUG == 1
				PrintToChat(client, "Change: The text entity %i does not exist", ent);
			#endif
			return;
		}
	} else {
		static char buff[64];
		GetEntityClassname(ent, buff, sizeof(buff));
		if (strcmp(buff, "vgui_world_text_panel") && IsPlayerAlive(client)) {
			LogError("Change: Invalid text entity %i", ent);
			#if DEBUG == 1
				PrintToChat(client, "Change: Invalid text entity %i", ent);
			#endif
			return;
		}
	}
	float newXaxis, newYaxis;
	int textlen = params.GetTextLength();
	char[] newText = new char[textlen];
	int maxlen = json.GetInt("textlen");
	char[] text = new char[maxlen];
	if (params.GetText(newText, textlen)) {
		//change text
		json.GetString("text", text, maxlen);
		if (strcmp(newText, text)) {
			if (IsPlayerAlive(client))SetEntPropString(ent, Prop_Send, "m_szDisplayText", newText);
			json.SetString("text", newText);
			json.SetInt("textlen", textlen);
		}
	}
	if (params.GetXaxis(newXaxis) || params.GetYaxis(newYaxis)) {
		params.GetYaxis(newYaxis);
		//float vec[3], ang[3];
		float Xaxis, Yaxis;
		view_as<VGUIParams>(json).GetXaxis(Xaxis);
		view_as<VGUIParams>(json).GetYaxis(Yaxis);
		if (Xaxis != newXaxis || Yaxis != newYaxis) {
			TeleportText(client, plugin, name, newXaxis, newYaxis);
		}
	}
	static int newColor[4], color[4];
	if (params.GetColor(newColor)) {
		//change color
		view_as<VGUIParams>(json).GetColor(color);
		if (!ColorCompare(newColor, color)) {
			static char szColor[16];
			FormatEx(szColor, sizeof(szColor), "%i %i %i %i", newColor[0], newColor[1], newColor[2], newColor[3]);
			json.SetString("color", szColor);
			if (IsPlayerAlive(client)) {
				DeleteText(client, plugin, name, false);
				CreateText(client, plugin, name, view_as<VGUIParams>(json), true);
			}
		}
	}
}

void DeleteText(int client, const char[] plugin, const char[] name, bool cleanup = true) {
	if (!CheckName(client, plugin, name)) {
		LogError("Delete: The text name %s does not exist", name);
		#if DEBUG == 1
			PrintToChat(client, "Delete: The text name %s does not exist", name);
		#endif
		return;
	}
	JSON_Object json = VGUIText[client].GetObject(plugin).GetObject(name);
	int ent = json.GetInt("entity");
	if (IsValidEntity(ent) && ent) {
		RemoveEntity(ent);
	}
	if (cleanup) {
		json_cleanup_and_delete(json);
		json = view_as<JSON_Object>(VGUIText[client].GetObject(plugin));
		json.Remove(name);
		if (json.Size == 0)VGUIText[client].Remove(plugin);
	}
}

bool CheckClient(int client) {
	if (!(0 < client <= MaxClients) || !IsClientInGame(client)) {
		LogError("Invalid client index %i or client isn't in game", client);
		#if DEBUG == 1
			PrintToChat(client, "Invalid client index %i or client isn't in game", client);
		#endif
		return false;
	} return true;
}

bool CheckName(int client, const char[] plugin, const char[] name) {
	if (name[0] != '\0' && (VGUIText[client].GetObject(plugin) != null && VGUIText[client].GetObject(plugin).HasKey(name))) {
		return true;
	}
	return false;
}

public int Native_CreateText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!CheckClient(client))return view_as<int>(false);
	static char name[64];
	GetNativeString(2, name, sizeof(name));
	VGUIParams params = GetNativeCell(3);
	static char szPlugin[16];
	IntToString(view_as<int>(plugin), szPlugin, sizeof(szPlugin));
	CreateText(client, szPlugin, name, params);
	return view_as<int>(true);
}

public int Native_ChangeText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!CheckClient(client))return view_as<int>(false);
	static char name[64];
	GetNativeString(2, name, sizeof(name));
	VGUIParams params = GetNativeCell(3);
	static char szPlugin[16];
	IntToString(view_as<int>(plugin), szPlugin, sizeof(szPlugin));
	ChangeText(client, szPlugin, name, params);
	return view_as<int>(true);
}

public int Native_DeleteText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!CheckClient(client))return view_as<int>(false);
	static char name[64];
	GetNativeString(2, name, sizeof(name));
	static char szPlugin[16];
	IntToString(view_as<int>(plugin), szPlugin, sizeof(szPlugin));
	DeleteText(client, szPlugin, name);
	return view_as<int>(true);
}

public int Native_ExistText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!CheckClient(client))return view_as<int>(false);
	static char name[64];
	GetNativeString(2, name, sizeof(name));
	static char szPlugin[16];
	IntToString(view_as<int>(plugin), szPlugin, sizeof(szPlugin));
	return view_as<int>(CheckName(client, szPlugin, name));
}

public int Native_PluginUnload(Handle plugin, int numParams) {
	JSON_Object json;
	char szPlugin[32], text[64];
	int ent;
	StringMapSnapshot snap;
	FormatEx(szPlugin, sizeof(szPlugin), "%i", plugin);
	LoopPlayers(client) {
		json = VGUIText[client];
		if (json == null || json.GetObject(szPlugin) == null)continue;
		json = json.GetObject(szPlugin);
		snap = json.Snapshot();
		for (int i = 0; i < snap.Length; i++) {
			snap.GetKey(i, text, sizeof(text));
			if (json_is_meta_key(text))continue;
			ent = json.GetObject(text).GetInt("entity");
			if (IsValidEntity(ent) && ent) {
				RemoveEntity(ent);
			}
		}
		snap.Close();
		json.Cleanup();
		VGUIText[client].Remove(szPlugin);
	}
	return 0;
}

static int ColorCompare(const int color1[4], const int color2[4]) {
	for (int i = 0; i < 4; i++) {
		if (color1[i] != color2[i])return false;
	}
	return true;
}