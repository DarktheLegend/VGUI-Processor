#pragma semicolon 1

#define DEBUG 0

#define PLUGIN_AUTHOR "Dark"
#define PLUGIN_VERSION "1.0.0"
#define LoopPlayers(%0) for (int %0 = 1; %0 <= MaxClients; %0++) if (IsClientInGame(%0) && !IsFakeClient(%0))

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <vgui_processor>

#include "vgui_processor/plugins.inc"

#pragma newdecls required

VGUIPlugins g_hPlugins[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "VGUI Processor",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "bamigos.ru"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max) {
	CreateNative("VGUI_CreateText", Native_CreateText);
	CreateNative("VGUI_UpdateText", Native_UpdateText);
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
		SDKHook(client, SDKHook_Spawn, Hook_Spawn);
		g_hPlugins[client] = new VGUIPlugins();
	}
}

public void OnPluginEnd() {
	LoopPlayers(client) {
		g_hPlugins[client].RemoveAllPlugins();
		
		delete g_hPlugins[client];
	}
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_SpawnPost, Hook_Spawn);
}

public void OnClientConnected(int client) {
	delete g_hPlugins[client];
	g_hPlugins[client] = new VGUIPlugins();
}

public void OnClientDisconnect(int client) {
	SDKUnhook(client, SDKHook_Spawn, Hook_Spawn);
	g_hPlugins[client].RemoveAllPlugins();
	
	delete g_hPlugins[client];
}

void CreateTextEntityPredicate(char[] name, StringMap textObject, int client) {
	int ent = CreateEntityByName("vgui_world_text_panel");
	int viewModelEnt = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	
	if (ent == -1 || viewModelEnt == -1 || !textObject.ContainsKey("params")) {
		return;
	}
	
	RemoveTextEntityPredicate(name, textObject);
	
	int entRef = EntIndexToEntRef(ent);
	textObject.SetValue("entity", entRef, true);
	VGUIParams params;
	textObject.GetValue("params", params);
	
	int textLen = params.GetTextLength();
	char[] text = new char[textLen];
	params.GetText(text, textLen);
	
	int color[4] = { 255, 255, 255, 255 };
	params.GetColor(color);
	char szColor[16];
	FormatEx(szColor, sizeof szColor, "%d %d %d %d", color[0], color[1], color[2], color[3]);
	
	DispatchKeyValue(ent, "displaytext", text);
	DispatchKeyValue(ent, "textcolor", szColor);
	DispatchKeyValue(ent, "font", "MissionSelectLarge");
	DispatchKeyValue(ent, "height", "4");
	DispatchKeyValue(ent, "width", "4");
	DispatchKeyValue(ent, "textpanelwidth", "1024");
	DispatchKeyValue(ent, "enabled", "1");
	DispatchSpawn(ent);
	
	TeleportText(client, textObject);
	
	params.ClearChanged();
}

void UpdateText(Handle plugin, char[] textName, int client) {
	char szPlugin[16];
	HandleToString(plugin, szPlugin, sizeof szPlugin);
	
	StringMap pluginTexts;
	if (!g_hPlugins[client].GetValue(szPlugin, pluginTexts)) {
		return;
	}
	
	StringMap text;
	if (!pluginTexts.GetValue(textName, text)) {
		return;
	}
	
	int entity;
	if (!text.GetValue("entity", entity) || !IsValidEntity(entity)) {
		return;
	}
	
	VGUIParams params;
	if (!text.GetValue("params", params)) {
		return;
	}
	
	if (params.HasColorChanges()) {
		RemoveTextEntityPredicate(textName, text);
		CreateTextEntityPredicate(textName, text, client);
	} else {
		if (params.HasXaxisChanges() || params.HasYaxisChanges()) {
			TeleportText(client, text);
		}
		
		if (params.HasTextChanges()) {
			int newTextLength = params.GetTextLength();
			char[] newText = new char[newTextLength];
			params.GetText(newText, newTextLength);
			
			SetEntPropString(entity, Prop_Send, "m_szDisplayText", newText);
		}
	}
	params.ClearChanged();
}

void CreateAllTextEntities(char[] plugin, StringMap pluginTexts, int client) {
	if (pluginTexts.Size == 0) {
		return;
	}
	
	g_hPlugins[client].IterateToTexts(plugin, CreateTextEntityPredicate, client);
}

void RemoveAllTextEntities(char[] plugin, StringMap pluginTexts, int client) {
	if (pluginTexts.Size == 0) {
		return;
	}
	
	g_hPlugins[client].IterateToTexts(plugin, RemoveTextEntityPredicate, client);
}

public Action Hook_Spawn(int client) {
	g_hPlugins[client].IterateToPlugins(CreateAllTextEntities, client);
	
	return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	g_hPlugins[client].IterateToPlugins(RemoveAllTextEntities, client);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	g_hPlugins[client].IterateToPlugins(RemoveAllTextEntities, client);
}

void PrepareCoordinates(float pos[3], float ang[3], float x, float y) {
	pos[0] += 12.0 * Cosine(DegToRad(ang[1])) - (y / 10.0 * Cosine(DegToRad(ang[1]))); //Вглубь экрана (дальше, меньше шрифт)
	pos[1] += 12.0 * Sine(DegToRad(ang[1])) - (y / 10.0 * Sine(DegToRad(ang[1]))); //Вглубь экрана (дальше, меньше шрифт)
	pos[0] += (3.0 - x) * Sine(-DegToRad(ang[1])); // Влево экрана (спавнится по дефолту справа экрана, 128 - середина)
	pos[1] += (3.0 - x) * Cosine(-DegToRad(ang[1])); // Влево экрана (спавнится по дефолту справа экрана, 128 - середина)
	pos[2] += y + 2.0; // Вверх экрана (-32 - внизу, середина рук)
	ang[0] = 0.0; // Поворот по горизонту
	ang[1] -= 90.0; // Поворот по вертикали (-90 - развернуть лицом к игроку)
	ang[2] = 90.0; // Поворот как в титры в StarWars (уходящая в даль стена)
}

void TeleportText(int client, StringMap text) {
	if (text == null) {
		return;
	}
	
	int entity;
	if (!text.GetValue("entity", entity) || !IsValidEntity(entity)) {
		return;
	}
	
	VGUIParams params;
	if (!text.GetValue("params", params)) {
		return;
	}
	
	AcceptEntityInput(entity, "SetParent");
	
	float pos[3], ang[3];
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
	float x, y;
	params.GetXaxis(x);
	params.GetYaxis(y);
	PrepareCoordinates(pos, ang, x, y);
	TeleportEntity(entity, pos, ang);
	
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));
}

public int Native_CreateText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	PrintToServer("Create text %i %i", client, g_hPlugins[client]);
	if (g_hPlugins[client] == null) {
		return view_as<int>(false);
	}
	char name[64];
	GetNativeString(2, name, sizeof name);
	bool result = g_hPlugins[client].AddText(plugin, name, GetNativeCell(3));
	return view_as<int>(result);
}

public int Native_UpdateText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	char name[64];
	GetNativeString(2, name, sizeof(name));
	UpdateText(plugin, name, client);
	return view_as<int>(true);
}

public int Native_DeleteText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (g_hPlugins[client] == null) {
		return view_as<int>(false);
	}
	char name[64];
	GetNativeString(2, name, sizeof(name));
	bool result = g_hPlugins[client].RemoveText(plugin, name);
	return view_as<int>(result);
}

public int Native_ExistText(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (g_hPlugins[client] == null) {
		return view_as<int>(false);
	}
	char name[64];
	GetNativeString(2, name, sizeof(name));
	bool result = g_hPlugins[client].ExistsText(plugin, name);
	return view_as<int>(result);
}

public int Native_PluginUnload(Handle plugin, int numParams) {
	LoopPlayers(client) {
		if (g_hPlugins[client] == null) {
			continue;
		}
		g_hPlugins[client].RemovePlugin(plugin);
	}
	return 0;
}