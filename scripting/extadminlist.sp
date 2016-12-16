#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <ccc>
#define REQUIRE_PLUGIN

ConVar cMethod;
ConVar cOffline;
ConVar cOnline;
ConVar cHide;

#define MAXADMINS 40
StringMap steamidMap;
char adminTag[MAXADMINS][32];
char adminTagColor[MAXADMINS][32];
char adminName[MAXADMINS][32];
char adminNameColor[MAXADMINS][32];
bool adminHidden[MAXADMINS][32];
int adminCount;

bool hidden[MAXPLAYERS+1];

Menu menuAdminList;
ArrayList stringBuilder;

bool ccc;

#define PLUGIN_NAME    "Extended Admin List"
#define PLUGIN_VERSION "1.0.0"
public Plugin myinfo = {
	name        = PLUGIN_NAME,
	author      = "Mitch",
	description = "Allows users to see online admins and offline admins",
	version     = PLUGIN_VERSION,
	url         = "mtch.tech"
};

public OnPluginStart() {
	CreateConVar("sm_extadminlist_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cMethod =  CreateConVar("sm_extadminlist_method", "1", "0 - Disabled, 1 - Menu/Chat, 2 - Chat, 3 - Menu");
	cOffline = CreateConVar("sm_extadminlist_offline", "1", "Display offline admins in the list");
	cOnline =  CreateConVar("sm_extadminlist_onlinefirst", "1", "Display the online admins on the top of the list");
	cHide =    CreateConVar("sm_extadminlist_allowhide", "1", "Allow admins to hide on the list dynamically");
	AutoExecConfig(true, "extadminlist");

	RegConsoleCmd("sm_admins", Command_Admins);

	clearPlayerVars(0);
	
	regenerateDisplay();
}

public void OnClientAuthorized(int client, const char[] auth) {
	regenerateDisplay();
}

public Action Command_Admins(client, args) {
	if(!client || !IsClientInGame(client)) {
		return Plugin_Handled;
	}
	displayAdminList(client);
	return Plugin_Handled;
}

public void regenerateDisplay() {
	//This function is used to generate the text and menu output for when a user wants to see the admin list.
	if(stringBuilder == null) {
		stringBuilder = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	} else {
		stringBuilder.Clear();
	}
}

public bool shouldRegenerateList() {
	int iMethod = cMethod.IntValue;
	bool regnerate = false;
	if(iMethod == 1 || iMethod == 2) {
		//check chat display
		regnerate = (stringBuilder == null || stringBuilder.Length < 1);
	} 
	if(iMethod == 1 || iMethod == 3) {
		//check menu display
		regnerate = (menuAdminList == null);
	}
	return regnerate;
}

public void displayAdminList(int client) {
	if(shouldRegenerateList()) {
		regenerateDisplay();
	}
}

public void clearPlayerVars(int client) {
	if(client == 0) {
		for(int i = 1; i <= MaxClients; i++) {
			clearPlayerVars(i);
		}
		return;
	}
	hidden[client] = false;
}

public bool getPlayerTag(int client, char[] output, int size) {
	
	return false;
}



public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	__pl_ccc_SetNTVOptional();
	return APLRes_Success;
}
 
public void OnAllPluginsLoaded() {
	ccc = LibraryExists("ccc");
}
 
public void OnLibraryRemoved(const char[] name) {
	if (StrEqual(name, "ccc")) {
		ccc = false;
	}
}
 
public void OnLibraryAdded(const char[] name) {
	if (StrEqual(name, "ccc")) {
		ccc = true;
	}
}