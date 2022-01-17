#include <sourcemod>
#include <cstrike>
#include <vgui_processor>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

#define LoopPlayers(%0) for (int %0 = 1; %0 <= MaxClients; %0++) if (IsClientInGame(%0) && !IsFakeClient(%0))

public Plugin myinfo =  {
	name = "VGUI example",
	author = "Dark",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

VGUIParams params;
VGUIParams speedParams;

bool showSpeed = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	if (GetEngineVersion() != Engine_CSGO) {
		SetFailState("This plugin was made for use with Counter-Strike: Global Offensive only.");
	}
} 

public void OnPluginStart() {
	RegConsoleCmd("sm_settext", Command_SetText);
	RegConsoleCmd("sm_colortext", Command_ColorText);
	RegConsoleCmd("sm_deletetext", Command_DeleteText);
	RegConsoleCmd("sm_speedtext", Command_SpeedText);
}

public Action Command_SetText(int client, int args) {
	char text[256];
	GetCmdArg(1, text, sizeof(text));
	if (VGUI_ExistText(client, "exampletext")) {
		params.SetText(text, sizeof(text));
		VGUI_ChangeText(client, "exampletext", params);
	} else {
		params = new VGUIParams();
		params.SetText(text, sizeof(text));
		VGUI_CreateText(client, "exampletext", params);
	}
	return Plugin_Handled;
}

public Action Command_ColorText(int client, int args) {
	char text[256];
	char buff[4][4];
	int color[4];
	GetCmdArg(1, text, sizeof(text));
	ExplodeString(text, " ", buff, 4, 4);
	for (int i = 0; i < sizeof(buff[]); i++) {
		color[i] = StringToInt(buff[i]);
	}
	if (VGUI_ExistText(client, "exampletext")) {
		params.SetColor(color);
		VGUI_ChangeText(client, "exampletext", params);
	}
	return Plugin_Handled;
}

public Action Command_DeleteText(int client, int args) {
	if (VGUI_ExistText(client, "exampletext")) {
		VGUI_DeleteText(client, "exampletext");
		params.Close();
		params = null;
	}
	return Plugin_Handled;
}

public Action Command_SpeedText(int client, int args) {
	showSpeed = !showSpeed;
	if (showSpeed && !VGUI_ExistText(client, "speedtext")) {
		if (speedParams == null)speedParams = new VGUIParams();
		speedParams.SetYaxis(-2.0);
		VGUI_CreateText(client, "speedtext", speedParams);
	} else {
		VGUI_DeleteText(client, "speedtext");
	}
	return Plugin_Handled;
}

public void OnGameFrame() {
	static char speed[16];
	static float fSpeed;
	LoopPlayers(client) {
		if (showSpeed && GetGameTickCount() % 6 == 0 && VGUI_ExistText(client, "speedtext")) {
			fSpeed = GetSpeed(client);
			FloatToString(fSpeed, speed, sizeof(speed));
			if (fSpeed <= 250.0)speedParams.SetColor({255, 255, 255, 255});
			else if (fSpeed <= 270.0)speedParams.SetColor({87, 207, 45, 255});
			else if (fSpeed <= 300.0)speedParams.SetColor({227, 225, 31, 255});
			else speedParams.SetColor({218, 83, 16, 255});
			speedParams.SetText(speed, sizeof(speed));
			VGUI_ChangeText(client, "speedtext", speedParams);
		}
	}
}

stock float GetSpeed(int client) {
	float vel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
	float speed = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0));
	return speed;
}