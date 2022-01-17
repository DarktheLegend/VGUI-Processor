/*
**
*/
#if defined _vgui_processor_included
 #endinput
#endif
#define _vgui_processor_included


#include <json>

#if !defined REQUIRE_PLUGIN
public __pl_vgui_processor_SetNTVOptional()
{
	MarkNativeAsOptional("VGUI_CreateText");
	MarkNativeAsOptional("VGUI_ChangeText");
	MarkNativeAsOptional("VGUI_DeleteText");
	MarkNativeAsOptional("VGUI_ExistText");
}
#endif

public SharedPlugin __pl_vgui_processor =
{
	name = "vgui_processor",
	file = "vgui_processor.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

native bool VGUI_CreateText(int client, const char[] name, VGUIParams params);

native bool VGUI_ChangeText(int client, const char[] name, VGUIParams params);

native bool VGUI_DeleteText(int client, const char[] name);

native bool VGUI_ExistText(int client, const char[] name);

native void VGUI_PluginUnload();

methodmap VGUIParams < JSON_Object {
	public void SetColor(const int color[4]) {
		static char szColor[16];
		FormatEx(szColor, sizeof(szColor), "%d %d %d %d", color[0], color[1], color[2], color[3]);
		this.SetString("color", szColor);
	}
	
	public void SetColorString(const char[] color) {
		this.SetString("color", color);
	}
	
	public void SetXaxis(float Xaxis) {
		this.SetFloat("x-axis", Xaxis);
		this.GetXaxis(Xaxis);
	}
	
	public void SetYaxis(float Yaxis) {
		this.SetFloat("y-axis", Yaxis);
		this.GetYaxis(Yaxis);
	}
	
	public void SetText(const char[] text, const int maxlen) {
		this.SetString("text", text);
		this.SetInt("textlen", maxlen);
	}
	
	public bool GetColor(int color[4]) {
		if (this.HasKey("color")) {
			static char szColor[16], temp[4][4];
			this.GetString("color", szColor, sizeof(szColor));
			ExplodeString(szColor, " ", temp, sizeof(temp), sizeof(temp[]));
			for (int i = 0; i < sizeof(temp[]); i++) {
				color[i] = StringToInt(temp[i]);
			}
			return true;
		}
		return false;
	}
	
	public bool GetXaxis(float& Xaxis) {
		if (this.HasKey("x-axis")) {
			Xaxis = this.GetFloat("x-axis", 0.0);
			return true;
		}
		return false;
	}
	
	public bool GetYaxis(float& Yaxis) {
		if (this.HasKey("y-axis")) {
			Yaxis = this.GetFloat("y-axis", 0.0);
			return true;
		}
		return false;
	}
	
	public int GetTextLength() {
		return this.GetInt("textlen");
	}
	
	public bool GetText(char[] text, int textlen) {
		if (this.HasKey("text")) {
			this.GetString("text", text, textlen);
			return true;
		}
		return false;
	}
	
	public void Clean() {
		json_cleanup(this);
	}
	
	public VGUIParams() {
		VGUIParams self = view_as<VGUIParams>(new JSON_Object());
		return self;
	}
}