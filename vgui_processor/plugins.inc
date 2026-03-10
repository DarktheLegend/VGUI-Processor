#include <vgui_processor>

typeset StringMapEntriesCB {
	function void(char[] key, any value);
	function void(char[] key, any value, any payload);
}

void HandleToString(Handle handle, char[] result, int resultLength) {
	IntToString(view_as<int>(handle), result, resultLength);
}

void StringMapEntries(StringMap stringMap, StringMapEntriesCB ObjectPredicate, any payload = 0) {
	if (stringMap.Size == 0) {
		return;
	}
	
	StringMapSnapshot objectSnapshot = stringMap.Snapshot();
	int length = objectSnapshot.Length;
	for (int i = 0; i < length; i += 1) {
		int keyLength = objectSnapshot.KeyBufferSize(i);
		char[] key = new char[keyLength];
		objectSnapshot.GetKey(i, key, keyLength);
		
		Call_StartFunction(null, ObjectPredicate);
		Call_PushString(key);
		any value;
		stringMap.GetValue(key, value);
		Call_PushCell(value);
		Call_PushCell(payload);
		Call_Finish();
	}
	
	delete objectSnapshot;
}

void RemoveTextEntityPredicate(char[] textName, StringMap text) {
	int entity;
	
	if (text.GetValue("entity", entity) && IsValidEntity(entity)) {
		RemoveEntity(entity);
		text.Remove("entity");
	}
}

static void RemoveTextPredicate(char[] textName, StringMap text) {
	if (text == null) {
		return;
	}
	
	RemoveTextEntityPredicate(textName, text);
	
	delete text;
}

static void RemovePluginPredicate(char[] plugin, StringMap pluginTexts) {
	if (pluginTexts == null || pluginTexts.Size == 0) {
		delete pluginTexts;
		return;
	}
	
	StringMapEntries(pluginTexts, RemoveTextPredicate);
	
	delete pluginTexts;
}

methodmap VGUIPlugins < StringMap {
	public VGUIPlugins() {
		VGUIPlugins self = view_as<VGUIPlugins>(new StringMap());
		return self;
	}
	
	property StringMap Super {
		public get() {
			return view_as<StringMap>(this);
		}
	}
	
	public bool AddText(Handle plugin, char[] textName, VGUIParams params) {
		char szPlugin[16];
		HandleToString(plugin, szPlugin, sizeof szPlugin);
		
		if (!this.ContainsKey(szPlugin)) {
			this.SetValue(szPlugin, new StringMap());
		}
		
		StringMap pluginTexts;
		this.GetValue(szPlugin, pluginTexts);
		if (pluginTexts.ContainsKey(textName)) {
			return false;
		}
		
		StringMap pluginText = new StringMap();
		pluginTexts.SetValue(textName, pluginText);
		pluginText.SetValue("params", params);
		
		return true;
	}
	
	public bool RemoveText(Handle plugin, char[] textName) {
		char szPlugin[16];
		HandleToString(plugin, szPlugin, sizeof szPlugin);
		
		if (!this.ContainsKey(szPlugin)) {
			return false;
		}
		
		StringMap pluginTexts;
		this.GetValue(szPlugin, pluginTexts);
		if (!pluginTexts.ContainsKey(textName)) {
			return false;
		}
		
		StringMap pluginText;
		pluginTexts.GetValue(textName, pluginText);
		delete pluginText;
		pluginTexts.Remove(textName);
		
		if (pluginTexts.Size == 0) {
			this.RemovePlugin(plugin);
		}
	}
	
	public bool ExistsText(Handle plugin, char[] textName) {
		char szPlugin[16];
		HandleToString(plugin, szPlugin, sizeof szPlugin);
		
		if (!this.ContainsKey(szPlugin)) {
			return false;
		}
		
		StringMap pluginTexts;
		this.GetValue(szPlugin, pluginTexts);
		return pluginTexts.ContainsKey(textName);
	}
	
	public bool RemovePlugin(Handle plugin) {
		char szPlugin[16];
		HandleToString(plugin, szPlugin, sizeof szPlugin);
		
		if (!this.ContainsKey(szPlugin)) {
			return false;
		}
		
		StringMap pluginTexts;
		this.GetValue(szPlugin, pluginTexts);
		
		RemovePluginPredicate(szPlugin, pluginTexts);
		
		this.Remove(szPlugin);
		
		return true;
	}
	
	public void RemoveAllPlugins() {
		if (this.Size == 0) {
			return;
		}
		
		StringMapEntries(this, RemovePluginPredicate);
	}
	
	public void IterateToPlugins(StringMapEntriesCB PluginPredicate, any payload) {
		if (this.Size == 0) {
			return;
		}
		
		StringMapEntries(this, PluginPredicate, payload);
	}
	
	public void IterateToTexts(char[] plugin, StringMapEntriesCB TextPredicate, any payload) {
		if (!this.ContainsKey(plugin)) {
			return;
		}
		
		StringMap pluginsTexts;
		this.GetValue(plugin, pluginsTexts);
		
		if (pluginsTexts.Size == 0) {
			return;
		}
		
		StringMapEntries(pluginsTexts, TextPredicate, payload);
	}
}