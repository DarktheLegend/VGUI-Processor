/*
**
*/
#if defined _vgui_processor_included
 #endinput
#endif
#define _vgui_processor_included

#if !defined REQUIRE_PLUGIN
public __pl_vgui_processor_SetNTVOptional()
{
	MarkNativeAsOptional("VGUI_CreateText");
	MarkNativeAsOptional("VGUI_UpdateText");
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

native bool VGUI_UpdateText(int client, const char[] name);

native bool VGUI_DeleteText(int client, const char[] name);

native bool VGUI_ExistText(int client, const char[] name);

native void VGUI_PluginUnload();

methodmap VGUIParams < StringMap {
	public void SetColorString(const char[] color) {
		char oldColor[16];
		if (!this.GetString("color", oldColor, sizeof oldColor) || strcmp(oldColor, color) != 0) {
			this.SetValue("color_changed", true);
		}
		this.SetString("color", color);
	}
	public void SetColor(const int color[4]) {
		static char szColor[16];
		FormatEx(szColor, sizeof(szColor), "%d %d %d %d", color[0], color[1], color[2], color[3]);
		this.SetColorString(szColor);
	}
	public void SetXaxis(float x) {
		this.SetValue("x-axis", x);
		this.SetValue("x-axis_changed", true);
	}
	
	public void SetYaxis(float y) {
		this.SetValue("y-axis", y);
		this.SetValue("y-axis_changed", true);
	}
	
	public void SetText(const char[] text, const int maxlen) {
		int oldMaxLen;
		if (this.GetValue("textlen", oldMaxLen)) {
			char[] old = new char[oldMaxLen];
			if (!this.GetString("text", old, oldMaxLen)) {
				this.SetValue("text_changed", true);
			} else if (strcmp(text, old) != 0) {
				this.SetValue("text_changed", true);
			}
		} else {
			this.SetValue("text_changed", true);
		}
		
		this.SetString("text", text);
		this.SetValue("textlen", maxlen);
	}
	
	public bool GetColor(int color[4]) {
		char szColor[16];
		if (this.GetString("color", szColor, sizeof szColor)) {
			char szSplitColor[4][4];
			ExplodeString(szColor, " ", szSplitColor, sizeof szSplitColor, sizeof szSplitColor[]);
			for (int i = 0; i < sizeof szSplitColor[]; i += 1) {
				color[i] = StringToInt(szSplitColor[i]);
			}
			return true;
		}
		return false;
	}
	
	public bool HasColorChanges() {
		return this.ContainsKey("color_changed");
	}
	
	public bool GetXaxis(float& x) {
		return this.GetValue("x-axis", x);
	}
	
	public bool HasXaxisChanges() {
		return this.ContainsKey("x-axis_changed");
	}
	
	public bool GetYaxis(float& y) {
		return this.GetValue("y-axis", y);
	}
	
	public bool HasYaxisChanges() {
		return this.ContainsKey("y-axis_changed");
	}
	
	public int GetTextLength() {
		int textlen;
		this.GetValue("textlen", textlen);
		return textlen;
	}
	
	public bool GetText(char[] text, int textlen) {
		return this.GetString("text", text, textlen);
	}
	
	public bool HasTextChanges() {
		return this.ContainsKey("text_changed");
	}
	
	public void ClearChanged() {
		this.Remove("color_changed");
		this.Remove("x-axis_changed");
		this.Remove("y-axis_changed");
		this.Remove("text_changed");
	}
	
	public void Clean() {
		this.Clear();
	}
	
	public VGUIParams() {
		VGUIParams self = view_as<VGUIParams>(new StringMap());
		return self;
	}
}