" Vim syntax file
" Language:	Pawn
" URL:		https://github.com/mcnelson/vim-pawn
" Forked from https://github.com/withgod/vim-sourcepawn

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" A bunch of useful C keywords
syn keyword	cStatement	goto break return continue assert state sleep exit
syn keyword	cLabel		case default
syn keyword	cConditional	if else switch
syn keyword	cRepeat		while for do

syn keyword	cTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredicatable and should be avoided.
syn match	cBadContinuation contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	cCommentGroup	contains=cTodo,cBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match	cSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syn match	cSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif
if exists("c_no_cformat")
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,@Spell
else
  if !exists("c_no_c99") " ISO C99
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syn match	cFormat		display "%%" contained
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
endif

syn match	cCharacter	"L\='[^\\]'"
syn match	cCharacter	"L'[^']*'" contains=cSpecial
if exists("c_gnu")
  syn match	cSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syn match	cSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syn match	cSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	cSpecialCharacter display "'\\x\x\{1,2}'"
syn match	cSpecialCharacter display "L'\\x\x\+'"

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syn match	cSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syn match	cSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match cCurlyError "}"
  syntax region	cBlock		start="{" end="}" contains=ALLBUT,cCurlyError,@cParenGroup,cErrInParen,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell fold
else
  syntax region	cBlock		start="{" end="}" transparent fold
endif

"catch errors caused by wrong parenthesis and brackets
" also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syn cluster	cParenGroup	contains=cParenError,cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom
if exists("c_no_curly_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "^[{}]\|^<%\|^%>"
elseif exists("c_no_bracket_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "[{}]\|<%\|%>"
else
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
  syn match	cParenError	display "[\])]"
  syn match	cErrInParen	display contained "[\]{}]\|<%\|%>"
  syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@cParenGroup,cErrInParen,cCppParen,cCppBracket,cCppString,@Spell
  " cCppBracket: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@cParenGroup,cErrInParen,cParen,cBracket,cString,@Spell
  syn match	cErrInBracket	display contained "[);{}]\|<%\|%>"
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	cNumbers	display transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctalError,cOctal
" Same, but without octal error (for comments)
syn match	cNumbersCom	display contained transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctal
syn match	cNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	cNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	cOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=cOctalZero
syn match	cOctalZero	display contained "\<0"
syn match	cFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	cFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	cFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	cFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	cFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	cFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	cOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain cString, cCharacter and cNumber.
  " But a "*/" inside a cString in a cComment DOES end the comment!  So we
  " need to use a special type of cString: cCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	cCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syntax region cCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,cCommentSkip
  syntax region cComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syntax region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell extend
  else
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell fold extend
  endif
else
  syn region	cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell extend
  else
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syntax match	cCommentError	display "\*/"
syntax match	cCommentStartError display "/\*"me=e-1 contained

syn keyword	cOperator	sizeof tagof state defined char

syn keyword	cTag 		any bool Fixed Float String Function

syn keyword	cStructure	enum
syn keyword	cStorageClass	static const stock native forward

" Constants
" ======
syn keyword 	cConstant 	cellbits cellmax cellmin charbits charmax charmin ucharmax __Pawn debug
syn keyword 	cConstant 	true false

" admin.inc
syn keyword	cFunction	DumpAdminCache AddCommandOverride GetCommandOverride UnsetCommandOverride
syn keyword	cFunction	CreateAdmGroup FindAdmGroup SetAdmGroupAddFlag GetAdmGroupAddFlag
syn keyword	cFunction	GetAdmGroupAddFlags SetAdmGroupImmunity GetAdmGroupImmunity SetAdmGroupImmuneFrom
syn keyword	cFunction	GetAdmGroupImmuneCount GetAdmGroupImmuneFrom AddAdmGroupCmdOverride GetAdmGroupCmdOverride
syn keyword	cFunction	RegisterAuthIdentType CreateAdmin GetAdminUsername BindAdminIdentity
syn keyword	cFunction	SetAdminFlag GetAdminFlag GetAdminFlags AdminInheritGroup
syn keyword	cFunction	GetAdminGroupCount GetAdminGroup SetAdminPassword GetAdminPassword
syn keyword	cFunction	FindAdminByIdentity RemoveAdmin FlagBitsToBitArray FlagBitArrayToBits
syn keyword	cFunction	FlagArrayToBits FlagBitsToArray FindFlagByName FindFlagByChar
syn keyword	cFunction	FindFlagChar ReadFlagString CanAdminTarget CreateAuthMethod
syn keyword	cFunction	SetAdmGroupImmunityLevel GetAdmGroupImmunityLevel SetAdminImmunityLevel GetAdminImmunityLevel
syn keyword	cFunction	FlagToBit BitToFlag
syn keyword	cConstant	Admin_Reservation Admin_Generic Admin_Kick Admin_Ban
syn keyword	cConstant	Admin_Unban Admin_Slay Admin_Changemap Admin_Convars
syn keyword	cConstant	Admin_Config Admin_Chat Admin_Vote Admin_Password
syn keyword	cConstant	Admin_RCON Admin_Cheats Admin_Root Admin_Custom1
syn keyword	cConstant	Admin_Custom2 Admin_Custom3 Admin_Custom4 Admin_Custom5
syn keyword	cConstant	Admin_Custom6 AdminFlags_TOTAL ADMFLAG_RESERVATION ADMFLAG_GENERIC
syn keyword	cConstant	ADMFLAG_KICK ADMFLAG_BAN ADMFLAG_UNBAN ADMFLAG_SLAY
syn keyword	cConstant	ADMFLAG_CHANGEMAP ADMFLAG_CONVARS ADMFLAG_CONFIG ADMFLAG_CHAT
syn keyword	cConstant	ADMFLAG_VOTE ADMFLAG_PASSWORD ADMFLAG_RCON ADMFLAG_CHEATS
syn keyword	cConstant	ADMFLAG_ROOT ADMFLAG_CUSTOM1 ADMFLAG_CUSTOM2 ADMFLAG_CUSTOM3
syn keyword	cConstant	ADMFLAG_CUSTOM4 ADMFLAG_CUSTOM5 ADMFLAG_CUSTOM6 AUTHMETHOD_STEAM
syn keyword	cConstant	AUTHMETHOD_IP AUTHMETHOD_NAME Override_Command Override_CommandGroup
syn keyword	cConstant	Command_Deny Command_Allow Immunity_Default Immunity_Global
syn keyword	cConstant	INVALID_GROUP_ID INVALID_ADMIN_ID Access_Real Access_Effective
syn keyword	cConstant	AdminCache_Overrides AdminCache_Groups AdminCache_Admins
syn keyword	cTag		AdminFlag OverrideType OverrideRule ImmunityType
syn keyword	cTag		GroupId AdminId AdmAccessMode AdminCachePart
syn keyword	cForward	OnRebuildAdminCache

" adminmenu.inc
syn keyword	cFunction	GetAdminTopMenu AddTargetsToMenu AddTargetsToMenu2 RedisplayAdminMenu
syn keyword	cConstant	ADMINMENU_PLAYERCOMMANDS ADMINMENU_SERVERCOMMANDS ADMINMENU_VOTINGCOMMANDS
syn keyword	cForward	OnAdminMenuCreated OnAdminMenuReady

" adt.inc

" adt_array.inc
syn keyword	cFunction	ByteCountToCells CreateArray ClearArray CloneArray
syn keyword	cFunction	ResizeArray GetArraySize PushArrayCell PushArrayString
syn keyword	cFunction	PushArrayArray GetArrayCell GetArrayString GetArrayArray
syn keyword	cFunction	SetArrayCell SetArrayString SetArrayArray ShiftArrayUp
syn keyword	cFunction	RemoveFromArray SwapArrayItems FindStringInArray FindValueInArray

" adt_stack.inc
syn keyword	cFunction	CreateStack PushStackCell PushStackString PushStackArray
syn keyword	cFunction	PopStackCell PopStackString PopStackArray IsStackEmpty
syn keyword	cFunction	PopStack

" adt_trie.inc
syn keyword	cFunction	CreateTrie SetTrieValue SetTrieArray SetTrieString
syn keyword	cFunction	GetTrieValue GetTrieArray GetTrieString RemoveFromTrie
syn keyword	cFunction	ClearTrie GetTrieSize

" banning.inc
syn keyword	cFunction	BanClient BanIdentity RemoveBan
syn keyword	cConstant	BANFLAG_AUTO BANFLAG_IP BANFLAG_AUTHID BANFLAG_NOKICK
syn keyword	cForward	OnBanClient OnBanIdentity OnRemoveBan

" basecomm.inc
syn keyword	cFunction	BaseComm_IsClientGagged BaseComm_IsClientMuted BaseComm_SetClientGag BaseComm_SetClientMute
syn keyword	cForward	BaseComm_OnClientMute BaseComm_OnClientGag

" bitbuffer.inc
syn keyword	cFunction	BfWriteBool BfWriteByte BfWriteChar BfWriteShort
syn keyword	cFunction	BfWriteWord BfWriteNum BfWriteFloat BfWriteString
syn keyword	cFunction	BfWriteEntity BfWriteAngle BfWriteCoord BfWriteVecCoord
syn keyword	cFunction	BfWriteVecNormal BfWriteAngles BfReadBool BfReadByte
syn keyword	cFunction	BfReadChar BfReadShort BfReadWord BfReadNum
syn keyword	cFunction	BfReadFloat BfReadString BfReadEntity BfReadAngle
syn keyword	cFunction	BfReadCoord BfReadVecCoord BfReadVecNormal BfReadAngles
syn keyword	cFunction	BfGetNumBytesLeft

" clientprefs.inc
syn keyword	cFunction	RegClientCookie FindClientCookie SetClientCookie GetClientCookie
syn keyword	cFunction	SetAuthIdCookie AreClientCookiesCached SetCookiePrefabMenu SetCookieMenuItem
syn keyword	cFunction	ShowCookieMenu GetCookieIterator ReadCookieIterator GetCookieAccess
syn keyword	cFunction	GetClientCookieTime
syn keyword	cConstant	CookieAccess_Public CookieAccess_Protected CookieAccess_Private CookieMenu_YesNo
syn keyword	cConstant	CookieMenu_YesNo_Int CookieMenu_OnOff CookieMenu_OnOff_Int CookieMenuAction_DisplayOption
syn keyword	cConstant	CookieMenuAction_SelectOption
syn keyword	cTag		CookieAccess CookieMenu CookieMenuAction CookieMenuHandler
syn keyword	cForward	OnClientCookiesCached

" clients.inc
syn keyword	cFunction	GetMaxClients GetMaxHumanPlayers GetClientCount GetClientName
syn keyword	cFunction	GetClientIP GetClientAuthString GetSteamAccountID GetClientUserId
syn keyword	cFunction	IsClientConnected IsClientInGame IsClientInKickQueue IsPlayerInGame
syn keyword	cFunction	IsClientAuthorized IsFakeClient IsClientSourceTV IsClientReplay
syn keyword	cFunction	IsClientObserver IsPlayerAlive GetClientInfo GetClientTeam
syn keyword	cFunction	SetUserAdmin GetUserAdmin AddUserFlags RemoveUserFlags
syn keyword	cFunction	SetUserFlagBits GetUserFlagBits CanUserTarget RunAdminCacheChecks
syn keyword	cFunction	NotifyPostAdminCheck CreateFakeClient SetFakeClientConVar GetClientHealth
syn keyword	cFunction	GetClientModel GetClientWeapon GetClientMaxs GetClientMins
syn keyword	cFunction	GetClientAbsAngles GetClientAbsOrigin GetClientArmor GetClientDeaths
syn keyword	cFunction	GetClientFrags GetClientDataRate IsClientTimingOut GetClientTime
syn keyword	cFunction	GetClientLatency GetClientAvgLatency GetClientAvgLoss GetClientAvgChoke
syn keyword	cFunction	GetClientAvgData GetClientAvgPackets GetClientOfUserId KickClient
syn keyword	cFunction	KickClientEx ChangeClientTeam GetClientSerial GetClientFromSerial
syn keyword	cConstant	NetFlow_Outgoing NetFlow_Incoming NetFlow_Both MAXPLAYERS
syn keyword	cConstant	MAX_NAME_LENGTH MaxClients
syn keyword	cTag		NetFlow
syn keyword	cForward	OnClientConnect OnClientConnected OnClientPutInServer OnClientDisconnect
syn keyword	cForward	OnClientDisconnect_Post OnClientCommand OnClientSettingsChanged OnClientAuthorized
syn keyword	cForward	OnClientPreAdminCheck OnClientPostAdminFilter OnClientPostAdminCheck

" commandfilters.inc
syn keyword	cFunction	ProcessTargetString ReplyToTargetError AddMultiTargetFilter RemoveMultiTargetFilter
syn keyword	cConstant	MAX_TARGET_LENGTH COMMAND_FILTER_ALIVE COMMAND_FILTER_DEAD COMMAND_FILTER_CONNECTED
syn keyword	cConstant	COMMAND_FILTER_NO_IMMUNITY COMMAND_FILTER_NO_MULTI COMMAND_FILTER_NO_BOTS COMMAND_TARGET_NONE
syn keyword	cConstant	COMMAND_TARGET_NOT_ALIVE COMMAND_TARGET_NOT_DEAD COMMAND_TARGET_NOT_IN_GAME COMMAND_TARGET_IMMUNE
syn keyword	cConstant	COMMAND_TARGET_EMPTY_FILTER COMMAND_TARGET_NOT_HUMAN COMMAND_TARGET_AMBIGUOUS
syn keyword	cTag		MultiTargetFilter

" console.inc
syn keyword	cFunction	ServerCommand ServerCommandEx InsertServerCommand ServerExecute
syn keyword	cFunction	ClientCommand FakeClientCommand FakeClientCommandEx PrintToServer
syn keyword	cFunction	PrintToConsole ReplyToCommand GetCmdReplySource SetCmdReplySource
syn keyword	cFunction	IsChatTrigger ShowActivity2 ShowActivity ShowActivityEx
syn keyword	cFunction	FormatActivitySource RegServerCmd RegConsoleCmd RegAdminCmd
syn keyword	cFunction	GetCmdArgs GetCmdArg GetCmdArgString CreateConVar
syn keyword	cFunction	FindConVar HookConVarChange UnhookConVarChange GetConVarBool
syn keyword	cFunction	SetConVarBool GetConVarInt SetConVarInt GetConVarFloat
syn keyword	cFunction	SetConVarFloat GetConVarString SetConVarString ResetConVar
syn keyword	cFunction	GetConVarDefault GetConVarFlags SetConVarFlags GetConVarBounds
syn keyword	cFunction	SetConVarBounds GetConVarName QueryClientConVar GetCommandIterator
syn keyword	cFunction	ReadCommandIterator CheckCommandAccess CheckAccess IsValidConVarChar
syn keyword	cFunction	GetCommandFlags SetCommandFlags FindFirstConCommand FindNextConCommand
syn keyword	cFunction	SendConVarValue AddServerTag RemoveServerTag AddCommandListener
syn keyword	cFunction	RemoveCommandListener
syn keyword	cConstant	INVALID_FCVAR_FLAGS ConVarBound_Upper ConVarBound_Lower QUERYCOOKIE_FAILED
syn keyword	cConstant	SM_REPLY_TO_CONSOLE SM_REPLY_TO_CHAT ConVarQuery_Okay ConVarQuery_NotFound
syn keyword	cConstant	ConVarQuery_NotValid ConVarQuery_Protected FCVAR_NONE FCVAR_UNREGISTERED
syn keyword	cConstant	FCVAR_LAUNCHER FCVAR_GAMEDLL FCVAR_CLIENTDLL FCVAR_MATERIAL_SYSTEM
syn keyword	cConstant	FCVAR_PROTECTED FCVAR_SPONLY FCVAR_ARCHIVE FCVAR_NOTIFY
syn keyword	cConstant	FCVAR_USERINFO FCVAR_PRINTABLEONLY FCVAR_UNLOGGED FCVAR_NEVER_AS_STRING
syn keyword	cConstant	FCVAR_REPLICATED FCVAR_CHEAT FCVAR_STUDIORENDER FCVAR_DEMO
syn keyword	cConstant	FCVAR_DONTRECORD FCVAR_PLUGIN FCVAR_DATACACHE FCVAR_TOOLSYSTEM
syn keyword	cConstant	FCVAR_FILESYSTEM FCVAR_NOT_CONNECTED FCVAR_SOUNDSYSTEM FCVAR_ARCHIVE_XBOX
syn keyword	cConstant	FCVAR_INPUTSYSTEM FCVAR_NETWORKSYSTEM FCVAR_VPHYSICS FEATURECAP_COMMANDLISTENER
syn keyword	cTag		ConVarBounds QueryCookie ReplySource ConVarQueryResult
syn keyword	cTag		SrvCmd ConCmd ConVarChanged ConVarQueryFinished
syn keyword	cTag		CommandListener
syn keyword	cForward	OnClientSayCommand OnClientSayCommand_Post

" core.inc
syn keyword	cFunction	VerifyCoreVersion MarkNativeAsOptional
syn keyword	cConstant	SOURCEMOD_PLUGINAPI_VERSION Plugin_Continue Plugin_Changed Plugin_Handled
syn keyword	cConstant	Plugin_Stop Identity_Core Identity_Extension Identity_Plugin
syn keyword	cConstant	Plugin_Running Plugin_Paused Plugin_Error Plugin_Loaded
syn keyword	cConstant	Plugin_Failed Plugin_Created Plugin_Uncompiled Plugin_BadLoad
syn keyword	cConstant	PlInfo_Name PlInfo_Author PlInfo_Description PlInfo_Version
syn keyword	cConstant	PlInfo_URL NULL_VECTOR NULL_STRING
syn keyword	cTag		PlVers Function Action Identity
syn keyword	cTag		PluginStatus PluginInfo Extension SharedPlugin

" cstrike.inc
syn keyword	cFunction	CS_RespawnPlayer CS_SwitchTeam CS_DropWeapon CS_TerminateRound
syn keyword	cFunction	CS_GetTranslatedWeaponAlias CS_GetWeaponPrice CS_GetClientClanTag CS_SetClientClanTag
syn keyword	cFunction	CS_GetTeamScore CS_SetTeamScore CS_GetMVPCount CS_SetMVPCount
syn keyword	cFunction	CS_GetClientContributionScore CS_SetClientContributionScore CS_GetClientAssists CS_SetClientAssists
syn keyword	cFunction	CS_AliasToWeaponID CS_WeaponIDToAlias CS_IsValidWeaponID CS_UpdateClientModel
syn keyword	cConstant	CS_TEAM_NONE CS_TEAM_SPECTATOR CS_TEAM_T CS_TEAM_CT
syn keyword	cConstant	CS_SLOT_PRIMARY CS_SLOT_SECONDARY CS_SLOT_GRENADE CS_SLOT_C4
syn keyword	cConstant	CSRoundEnd_TargetBombed CSRoundEnd_VIPEscaped CSRoundEnd_VIPKilled CSRoundEnd_TerroristsEscaped
syn keyword	cConstant	CSRoundEnd_CTStoppedEscape CSRoundEnd_TerroristsStopped CSRoundEnd_BombDefused CSRoundEnd_CTWin
syn keyword	cConstant	CSRoundEnd_TerroristWin CSRoundEnd_Draw CSRoundEnd_HostagesRescued CSRoundEnd_TargetSaved
syn keyword	cConstant	CSRoundEnd_HostagesNotRescued CSRoundEnd_TerroristsNotEscaped CSRoundEnd_VIPNotEscaped CSRoundEnd_GameStart
syn keyword	cConstant	CSRoundEnd_TerroristsSurrender CSRoundEnd_CTSurrender CSWeapon_NONE CSWeapon_P228
syn keyword	cConstant	CSWeapon_GLOCK CSWeapon_SCOUT CSWeapon_HEGRENADE CSWeapon_XM1014
syn keyword	cConstant	CSWeapon_C4 CSWeapon_MAC10 CSWeapon_AUG CSWeapon_SMOKEGRENADE
syn keyword	cConstant	CSWeapon_ELITE CSWeapon_FIVESEVEN CSWeapon_UMP45 CSWeapon_SG550
syn keyword	cConstant	CSWeapon_GALIL CSWeapon_FAMAS CSWeapon_USP CSWeapon_AWP
syn keyword	cConstant	CSWeapon_MP5NAVY CSWeapon_M249 CSWeapon_M3 CSWeapon_M4A1
syn keyword	cConstant	CSWeapon_TMP CSWeapon_G3SG1 CSWeapon_FLASHBANG CSWeapon_DEAGLE
syn keyword	cConstant	CSWeapon_SG552 CSWeapon_AK47 CSWeapon_KNIFE CSWeapon_P90
syn keyword	cConstant	CSWeapon_SHIELD CSWeapon_KEVLAR CSWeapon_ASSAULTSUIT CSWeapon_NIGHTVISION
syn keyword	cConstant	CSWeapon_GALILAR CSWeapon_BIZON CSWeapon_MAG7 CSWeapon_NEGEV
syn keyword	cConstant	CSWeapon_SAWEDOFF CSWeapon_TEC9 CSWeapon_TASER CSWeapon_HKP2000
syn keyword	cConstant	CSWeapon_MP7 CSWeapon_MP9 CSWeapon_NOVA CSWeapon_P250
syn keyword	cConstant	CSWeapon_SCAR17 CSWeapon_SCAR20 CSWeapon_SG556 CSWeapon_SSG08
syn keyword	cConstant	CSWeapon_KNIFE_GG CSWeapon_MOLOTOV CSWeapon_DECOY CSWeapon_INCGRENADE
syn keyword	cConstant	CSWeapon_DEFUSER
syn keyword	cTag		CSRoundEndReason CSWeaponID
syn keyword	cForward	CS_OnBuyCommand CS_OnCSWeaponDrop CS_OnGetWeaponPrice CS_OnTerminateRound

" datapack.inc
syn keyword	cFunction	CreateDataPack WritePackCell WritePackFloat WritePackString
syn keyword	cFunction	ReadPackCell ReadPackFloat ReadPackString ResetPack
syn keyword	cFunction	GetPackPosition SetPackPosition IsPackReadable

" dbi.inc
syn keyword	cFunction	SQL_Connect SQL_DefConnect SQL_ConnectCustom SQLite_UseDatabase
syn keyword	cFunction	SQL_ConnectEx SQL_CheckConfig SQL_GetDriver SQL_ReadDriver
syn keyword	cFunction	SQL_GetDriverIdent SQL_GetDriverProduct SQL_GetAffectedRows SQL_GetInsertId
syn keyword	cFunction	SQL_GetError SQL_EscapeString SQL_QuoteString SQL_FastQuery
syn keyword	cFunction	SQL_Query SQL_PrepareQuery SQL_FetchMoreResults SQL_HasResultSet
syn keyword	cFunction	SQL_GetRowCount SQL_GetFieldCount SQL_FieldNumToName SQL_FieldNameToNum
syn keyword	cFunction	SQL_FetchRow SQL_MoreRows SQL_Rewind SQL_FetchString
syn keyword	cFunction	SQL_FetchFloat SQL_FetchInt SQL_IsFieldNull SQL_FetchSize
syn keyword	cFunction	SQL_BindParamInt SQL_BindParamFloat SQL_BindParamString SQL_Execute
syn keyword	cFunction	SQL_LockDatabase SQL_UnlockDatabase SQL_IsSameConnection SQL_TConnect
syn keyword	cFunction	SQL_TQuery
syn keyword	cConstant	DBVal_Error DBVal_TypeMismatch DBVal_Null DBVal_Data
syn keyword	cConstant	DBBind_Int DBBind_Float DBBind_String DBPrio_High
syn keyword	cConstant	DBPrio_Normal DBPrio_Low
syn keyword	cTag		DBResult DBBindType DBPriority SQLTCallback

" entity.inc
syn keyword	cFunction	GetMaxEntities GetEntityCount IsValidEntity IsValidEdict
syn keyword	cFunction	IsEntNetworkable CreateEdict RemoveEdict GetEdictFlags
syn keyword	cFunction	SetEdictFlags GetEdictClassname GetEntityNetClass ChangeEdictState
syn keyword	cFunction	GetEntData SetEntData GetEntDataFloat SetEntDataFloat
syn keyword	cFunction	GetEntDataEnt SetEntDataEnt GetEntDataEnt2 SetEntDataEnt2
syn keyword	cFunction	GetEntDataVector SetEntDataVector GetEntDataString SetEntDataString
syn keyword	cFunction	FindSendPropOffs FindSendPropInfo FindDataMapOffs GetEntSendPropOffs
syn keyword	cFunction	GetEntProp SetEntProp GetEntPropFloat SetEntPropFloat
syn keyword	cFunction	GetEntPropEnt SetEntPropEnt GetEntPropVector SetEntPropVector
syn keyword	cFunction	GetEntPropString SetEntPropString GetEntPropArraySize GetEntDataArray
syn keyword	cFunction	SetEntDataArray GetEntityAddress GetEntityClassname
syn keyword	cConstant	Prop_Send Prop_Data FL_EDICT_CHANGED FL_EDICT_FREE
syn keyword	cConstant	FL_EDICT_FULL FL_EDICT_FULLCHECK FL_EDICT_ALWAYS FL_EDICT_DONTSEND
syn keyword	cConstant	FL_EDICT_PVSCHECK FL_EDICT_PENDING_DORMANT_CHECK FL_EDICT_DIRTY_PVS_INFORMATION FL_FULL_EDICT_CHANGED
syn keyword	cConstant	PropField_Unsupported PropField_Integer PropField_Float PropField_Entity
syn keyword	cConstant	PropField_Vector PropField_String PropField_String_T
syn keyword	cTag		PropType PropFieldType

" entity_prop_stocks.inc
syn keyword	cFunction	GetEntityFlags SetEntityFlags GetEntityMoveType SetEntityMoveType
syn keyword	cFunction	GetEntityRenderMode SetEntityRenderMode GetEntityRenderFx SetEntityRenderFx
syn keyword	cFunction	SetEntityRenderColor GetEntityGravity SetEntityGravity SetEntityHealth
syn keyword	cFunction	GetClientButtons
syn keyword	cConstant	MOVETYPE_NONE MOVETYPE_ISOMETRIC MOVETYPE_WALK MOVETYPE_STEP
syn keyword	cConstant	MOVETYPE_FLY MOVETYPE_FLYGRAVITY MOVETYPE_VPHYSICS MOVETYPE_PUSH
syn keyword	cConstant	MOVETYPE_NOCLIP MOVETYPE_LADDER MOVETYPE_OBSERVER MOVETYPE_CUSTOM
syn keyword	cConstant	RENDER_NORMAL RENDER_TRANSCOLOR RENDER_TRANSTEXTURE RENDER_GLOW
syn keyword	cConstant	RENDER_TRANSALPHA RENDER_TRANSADD RENDER_ENVIRONMENTAL RENDER_TRANSADDFRAMEBLEND
syn keyword	cConstant	RENDER_TRANSALPHAADD RENDER_WORLDGLOW RENDER_NONE RENDERFX_NONE
syn keyword	cConstant	RENDERFX_PULSE_SLOW RENDERFX_PULSE_FAST RENDERFX_PULSE_SLOW_WIDE RENDERFX_PULSE_FAST_WIDE
syn keyword	cConstant	RENDERFX_FADE_SLOW RENDERFX_FADE_FAST RENDERFX_SOLID_SLOW RENDERFX_SOLID_FAST
syn keyword	cConstant	RENDERFX_STROBE_SLOW RENDERFX_STROBE_FAST RENDERFX_STROBE_FASTER RENDERFX_FLICKER_SLOW
syn keyword	cConstant	RENDERFX_FLICKER_FAST RENDERFX_NO_DISSIPATION RENDERFX_DISTORT RENDERFX_HOLOGRAM
syn keyword	cConstant	RENDERFX_EXPLODE RENDERFX_GLOWSHELL RENDERFX_CLAMP_MIN_SCALE RENDERFX_ENV_RAIN
syn keyword	cConstant	RENDERFX_ENV_SNOW RENDERFX_SPOTLIGHT RENDERFX_RAGDOLL RENDERFX_PULSE_FAST_WIDER
syn keyword	cConstant	RENDERFX_MAX IN_ATTACK IN_JUMP IN_DUCK
syn keyword	cConstant	IN_FORWARD IN_BACK IN_USE IN_CANCEL
syn keyword	cConstant	IN_LEFT IN_RIGHT IN_MOVELEFT IN_MOVERIGHT
syn keyword	cConstant	IN_ATTACK2 IN_RUN IN_RELOAD IN_ALT1
syn keyword	cConstant	IN_ALT2 IN_SCORE IN_SPEED IN_WALK
syn keyword	cConstant	IN_ZOOM IN_WEAPON1 IN_WEAPON2 IN_BULLRUSH
syn keyword	cConstant	IN_GRENADE1 IN_GRENADE2 IN_ATTACK3 FL_ONGROUND
syn keyword	cConstant	FL_DUCKING FL_WATERJUMP FL_ONTRAIN FL_INRAIN
syn keyword	cConstant	FL_FROZEN FL_ATCONTROLS FL_CLIENT FL_FAKECLIENT
syn keyword	cConstant	PLAYER_FLAG_BITS FL_INWATER FL_FLY FL_SWIM
syn keyword	cConstant	FL_CONVEYOR FL_NPC FL_GODMODE FL_NOTARGET
syn keyword	cConstant	FL_AIMTARGET FL_PARTIALGROUND FL_STATICPROP FL_GRAPHED
syn keyword	cConstant	FL_GRENADE FL_STEPMOVEMENT FL_DONTTOUCH FL_BASEVELOCITY
syn keyword	cConstant	FL_WORLDBRUSH FL_OBJECT FL_KILLME FL_ONFIRE
syn keyword	cConstant	FL_DISSOLVING FL_TRANSRAGDOLL FL_UNBLOCKABLE_BY_PLAYER FL_FREEZING
syn keyword	cConstant	FL_EP2V_UNKNOWN1
syn keyword	cTag		MoveType RenderMode RenderFx

" events.inc
syn keyword	cFunction	HookEvent HookEventEx UnhookEvent CreateEvent
syn keyword	cFunction	FireEvent CancelCreatedEvent GetEventBool SetEventBool
syn keyword	cFunction	GetEventInt SetEventInt GetEventFloat SetEventFloat
syn keyword	cFunction	GetEventString SetEventString GetEventName SetEventBroadcast
syn keyword	cConstant	EventHookMode_Pre EventHookMode_Post EventHookMode_PostNoCopy
syn keyword	cTag		EventHookMode EventHook

" files.inc
syn keyword	cFunction	BuildPath OpenDirectory ReadDirEntry OpenFile
syn keyword	cFunction	DeleteFile ReadFileLine ReadFile ReadFileString
syn keyword	cFunction	WriteFile WriteFileString WriteFileLine ReadFileCell
syn keyword	cFunction	WriteFileCell IsEndOfFile FileSeek FilePosition
syn keyword	cFunction	FileExists RenameFile DirExists FileSize
syn keyword	cFunction	FlushFile RemoveDir CreateDirectory GetFileTime
syn keyword	cFunction	LogToOpenFile LogToOpenFileEx
syn keyword	cConstant	FileType_Unknown FileType_Directory FileType_File FileTime_LastAccess
syn keyword	cConstant	FileTime_Created FileTime_LastChange PLATFORM_MAX_PATH SEEK_SET
syn keyword	cConstant	SEEK_CUR SEEK_END Path_SM FPERM_U_READ
syn keyword	cConstant	FPERM_U_WRITE FPERM_U_EXEC FPERM_G_READ FPERM_G_WRITE
syn keyword	cConstant	FPERM_G_EXEC FPERM_O_READ FPERM_O_WRITE FPERM_O_EXEC
syn keyword	cTag		FileType FileTimeMode PathType

" float.inc
syn keyword	cFunction	float FloatMul FloatDiv FloatAdd
syn keyword	cFunction	FloatSub FloatFraction RoundToZero RoundToCeil
syn keyword	cFunction	RoundToFloor RoundToNearest FloatCompare SquareRoot
syn keyword	cFunction	Pow Exponential Logarithm Sine
syn keyword	cFunction	Cosine Tangent FloatAbs ArcTangent
syn keyword	cFunction	ArcCosine ArcSine ArcTangent2 RoundFloat
syn keyword	cFunction	DegToRad RadToDeg GetURandomInt GetURandomFloat
syn keyword	cFunction	SetURandomSeed SetURandomSeedSimple
syn keyword	cConstant	FLOAT_PI

" functions.inc
syn keyword	cFunction	GetFunctionByName CreateGlobalForward CreateForward GetForwardFunctionCount
syn keyword	cFunction	AddToForward RemoveFromForward RemoveAllFromForward Call_StartForward
syn keyword	cFunction	Call_StartFunction Call_PushCell Call_PushCellRef Call_PushFloat
syn keyword	cFunction	Call_PushFloatRef Call_PushArray Call_PushArrayEx Call_PushString
syn keyword	cFunction	Call_PushStringEx Call_Finish Call_Cancel CreateNative
syn keyword	cFunction	ThrowNativeError GetNativeStringLength GetNativeString SetNativeString
syn keyword	cFunction	GetNativeCell GetNativeCellRef SetNativeCellRef GetNativeArray
syn keyword	cFunction	SetNativeArray FormatNativeString
syn keyword	cConstant	SP_PARAMFLAG_BYREF Param_Any Param_Cell Param_Float
syn keyword	cConstant	Param_String Param_Array Param_VarArgs Param_CellByRef
syn keyword	cConstant	Param_FloatByRef ET_Ignore ET_Single ET_Event
syn keyword	cConstant	ET_Hook SM_PARAM_COPYBACK SM_PARAM_STRING_UTF8 SM_PARAM_STRING_COPY
syn keyword	cConstant	SM_PARAM_STRING_BINARY SP_ERROR_NONE SP_ERROR_FILE_FORMAT SP_ERROR_DECOMPRESSOR
syn keyword	cConstant	SP_ERROR_HEAPLOW SP_ERROR_PARAM SP_ERROR_INVALID_ADDRESS SP_ERROR_NOT_FOUND
syn keyword	cConstant	SP_ERROR_INDEX SP_ERROR_STACKLOW SP_ERROR_NOTDEBUGGING SP_ERROR_INVALID_INSTRUCTION
syn keyword	cConstant	SP_ERROR_MEMACCESS SP_ERROR_STACKMIN SP_ERROR_HEAPMIN SP_ERROR_DIVIDE_BY_ZERO
syn keyword	cConstant	SP_ERROR_ARRAY_BOUNDS SP_ERROR_INSTRUCTION_PARAM SP_ERROR_STACKLEAK SP_ERROR_HEAPLEAK
syn keyword	cConstant	SP_ERROR_ARRAY_TOO_BIG SP_ERROR_TRACKER_BOUNDS SP_ERROR_INVALID_NATIVE SP_ERROR_PARAMS_MAX
syn keyword	cConstant	SP_ERROR_NATIVE SP_ERROR_NOT_RUNNABLE SP_ERROR_ABORTED
syn keyword	cTag		ParamType ExecType NativeCall

" geoip.inc
syn keyword	cFunction	GeoipCode2 GeoipCode3 GeoipCountry

" halflife.inc
syn keyword	cFunction	LogToGame SetRandomSeed GetRandomFloat GetRandomInt
syn keyword	cFunction	IsMapValid IsDedicatedServer GetEngineTime GetGameTime
syn keyword	cFunction	GetGameTickCount GetGameDescription GetGameFolderName GetCurrentMap
syn keyword	cFunction	PrecacheModel PrecacheSentenceFile PrecacheDecal PrecacheGeneric
syn keyword	cFunction	IsModelPrecached IsDecalPrecached IsGenericPrecached PrecacheSound
syn keyword	cFunction	IsSoundPrecached CreateDialog GuessSDKVersion GetEngineVersion
syn keyword	cFunction	PrintToChat PrintToChatAll PrintCenterText PrintCenterTextAll
syn keyword	cFunction	PrintHintText PrintHintTextToAll ShowVGUIPanel CreateHudSynchronizer
syn keyword	cFunction	SetHudTextParams SetHudTextParamsEx ShowSyncHudText ClearSyncHud
syn keyword	cFunction	ShowHudText ShowMOTDPanel DisplayAskConnectBox EntIndexToEntRef
syn keyword	cFunction	EntRefToEntIndex MakeCompatEntRef
syn keyword	cConstant	SOURCE_SDK_UNKNOWN SOURCE_SDK_ORIGINAL SOURCE_SDK_DARKMESSIAH SOURCE_SDK_EPISODE1
syn keyword	cConstant	SOURCE_SDK_EPISODE2 SOURCE_SDK_BLOODYGOODTIME SOURCE_SDK_EYE SOURCE_SDK_CSS
syn keyword	cConstant	SOURCE_SDK_EPISODE2VALVE SOURCE_SDK_LEFT4DEAD SOURCE_SDK_LEFT4DEAD2 SOURCE_SDK_ALIENSWARM
syn keyword	cConstant	SOURCE_SDK_CSGO MOTDPANEL_TYPE_TEXT MOTDPANEL_TYPE_INDEX MOTDPANEL_TYPE_URL
syn keyword	cConstant	MOTDPANEL_TYPE_FILE DialogType_Msg DialogType_Menu DialogType_Text
syn keyword	cConstant	DialogType_Entry DialogType_AskConnect Engine_Unknown Engine_Original
syn keyword	cConstant	Engine_SourceSDK2006 Engine_SourceSDK2007 Engine_Left4Dead Engine_DarkMessiah
syn keyword	cConstant	Engine_Left4Dead2 Engine_AlienSwarm Engine_BloodyGoodTime Engine_EYE
syn keyword	cConstant	Engine_Portal2 Engine_CSGO Engine_CSS Engine_DOTA
syn keyword	cConstant	Engine_HL2DM Engine_DODS Engine_TF2 Engine_NuclearDawn
syn keyword	cConstant	INVALID_ENT_REFERENCE
syn keyword	cTag		DialogType EngineVersion

" handles.inc
syn keyword	cFunction	CloseHandle CloneHandle IsValidHandle
syn keyword	cConstant	INVALID_HANDLE
syn keyword	cTag		Handle

" helpers.inc
syn keyword	cFunction	FormatUserLogText FindPluginByFile SearchForClients FindTarget
syn keyword	cFunction	LoadMaps

" keyvalues.inc
syn keyword	cFunction	CreateKeyValues KvSetString KvSetNum KvSetUInt64
syn keyword	cFunction	KvSetFloat KvSetColor KvSetVector KvGetString
syn keyword	cFunction	KvGetNum KvGetFloat KvGetColor KvGetUInt64
syn keyword	cFunction	KvGetVector KvJumpToKey KvJumpToKeySymbol KvGotoFirstSubKey
syn keyword	cFunction	KvGotoNextKey KvSavePosition KvDeleteKey KvDeleteThis
syn keyword	cFunction	KvGoBack KvRewind KvGetSectionName KvSetSectionName
syn keyword	cFunction	KvGetDataType KeyValuesToFile FileToKeyValues KvSetEscapeSequences
syn keyword	cFunction	KvNodesInStack KvCopySubkeys KvFindKeyById KvGetNameSymbol
syn keyword	cFunction	KvGetSectionSymbol
syn keyword	cConstant	KvData_None KvData_String KvData_Int KvData_Float
syn keyword	cConstant	KvData_Ptr KvData_WString KvData_Color KvData_UInt64
syn keyword	cConstant	KvData_NUMTYPES
syn keyword	cTag		KvDataTypes

" lang.inc
syn keyword	cFunction	LoadTranslations SetGlobalTransTarget GetClientLanguage GetServerLanguage
syn keyword	cFunction	GetLanguageCount GetLanguageInfo SetClientLanguage GetLanguageByCode
syn keyword	cFunction	GetLanguageByName
syn keyword	cConstant	LANG_SERVER

" logging.inc
syn keyword	cFunction	LogMessage LogMessageEx LogToFile LogToFileEx
syn keyword	cFunction	LogAction LogError AddGameLogHook RemoveGameLogHook
syn keyword	cTag		GameLogHook
syn keyword	cForward	OnLogAction

" mapchooser.inc
syn keyword	cFunction	NominateMap RemoveNominationByMap RemoveNominationByOwner GetExcludeMapList
syn keyword	cFunction	GetNominatedMapList CanMapChooserStartVote InitiateMapChooserVote HasEndOfMapVoteFinished
syn keyword	cFunction	EndOfMapVoteEnabled
syn keyword	cConstant	Nominate_Added Nominate_Replaced Nominate_AlreadyInVote Nominate_InvalidMap
syn keyword	cConstant	Nominate_VoteFull MapChange_Instant MapChange_RoundEnd MapChange_MapEnd
syn keyword	cTag		NominateResult MapChange
syn keyword	cForward	OnNominationRemoved OnMapVoteStarted

" menus.inc
syn keyword	cFunction	CreateMenu DisplayMenu DisplayMenuAtItem AddMenuItem
syn keyword	cFunction	InsertMenuItem RemoveMenuItem RemoveAllMenuItems GetMenuItem
syn keyword	cFunction	GetMenuSelectionPosition GetMenuItemCount SetMenuPagination GetMenuPagination
syn keyword	cFunction	GetMenuStyle SetMenuTitle GetMenuTitle CreatePanelFromMenu
syn keyword	cFunction	GetMenuExitButton SetMenuExitButton GetMenuExitBackButton SetMenuExitBackButton
syn keyword	cFunction	SetMenuNoVoteButton CancelMenu GetMenuOptionFlags SetMenuOptionFlags
syn keyword	cFunction	IsVoteInProgress CancelVote VoteMenu VoteMenuToAll
syn keyword	cFunction	SetVoteResultCallback CheckVoteDelay IsClientInVotePool RedrawClientVoteMenu
syn keyword	cFunction	GetMenuStyleHandle CreatePanel CreateMenuEx GetClientMenu
syn keyword	cFunction	CancelClientMenu GetMaxPageItems GetPanelStyle SetPanelTitle
syn keyword	cFunction	DrawPanelItem DrawPanelText CanPanelDrawFlags SetPanelKeys
syn keyword	cFunction	SendPanelToClient GetPanelTextRemaining GetPanelCurrentKey SetPanelCurrentKey
syn keyword	cFunction	RedrawMenuItem InternalShowMenu GetMenuVoteInfo IsNewVoteAllowed
syn keyword	cConstant	MenuStyle_Default MenuStyle_Valve MenuStyle_Radio MenuAction_Start
syn keyword	cConstant	MenuAction_Display MenuAction_Select MenuAction_Cancel MenuAction_End
syn keyword	cConstant	MenuAction_VoteEnd MenuAction_VoteStart MenuAction_VoteCancel MenuAction_DrawItem
syn keyword	cConstant	MenuAction_DisplayItem MENU_ACTIONS_DEFAULT MENU_ACTIONS_ALL MENU_NO_PAGINATION
syn keyword	cConstant	MENU_TIME_FOREVER ITEMDRAW_DEFAULT ITEMDRAW_DISABLED ITEMDRAW_RAWLINE
syn keyword	cConstant	ITEMDRAW_NOTEXT ITEMDRAW_SPACER ITEMDRAW_IGNORE ITEMDRAW_CONTROL
syn keyword	cConstant	MENUFLAG_BUTTON_EXIT MENUFLAG_BUTTON_EXITBACK MENUFLAG_NO_SOUND MENUFLAG_BUTTON_NOVOTE
syn keyword	cConstant	VOTEINFO_CLIENT_INDEX VOTEINFO_CLIENT_ITEM VOTEINFO_ITEM_INDEX VOTEINFO_ITEM_VOTES
syn keyword	cConstant	VOTEFLAG_NO_REVOTES MenuSource_None MenuSource_External MenuSource_Normal
syn keyword	cConstant	MenuSource_RawPanel
syn keyword	cTag		MenuStyle MenuAction MenuSource MenuHandler
syn keyword	cTag		VoteHandler

" nextmap.inc
syn keyword	cFunction	SetNextMap GetNextMap ForceChangeLevel GetMapHistorySize
syn keyword	cFunction	GetMapHistory

" profiler.inc
syn keyword	cFunction	CreateProfiler StartProfiling StopProfiling GetProfilerTime

" protobuf.inc
syn keyword	cFunction	PbReadInt PbReadFloat PbReadBool PbReadString
syn keyword	cFunction	PbReadColor PbReadAngle PbReadVector PbReadVector2D
syn keyword	cFunction	PbGetRepeatedFieldCount PbReadRepeatedInt PbReadRepeatedFloat PbReadRepeatedBool
syn keyword	cFunction	PbReadRepeatedString PbReadRepeatedColor PbReadRepeatedAngle PbReadRepeatedVector
syn keyword	cFunction	PbReadRepeatedVector2D PbSetInt PbSetFloat PbSetBool
syn keyword	cFunction	PbSetString PbSetColor PbSetAngle PbSetVector
syn keyword	cFunction	PbSetVector2D PbAddInt PbAddFloat PbAddBool
syn keyword	cFunction	PbAddString PbAddColor PbAddAngle PbAddVector
syn keyword	cFunction	PbAddVector2D PbReadMessage PbReadRepeatedMessage PbAddMessage
syn keyword	cConstant	PB_FIELD_NOT_REPEATED

" regex.inc
syn keyword	cFunction	CompileRegex MatchRegex GetRegexSubString SimpleRegexMatch
syn keyword	cConstant	PCRE_CASELESS PCRE_MULTILINE PCRE_DOTALL PCRE_EXTENDED
syn keyword	cConstant	PCRE_UNGREEDY PCRE_UTF8 PCRE_NO_UTF8_CHECK REGEX_ERROR_NONE
syn keyword	cConstant	REGEX_ERROR_NOMATCH REGEX_ERROR_NULL REGEX_ERROR_BADOPTION REGEX_ERROR_BADMAGIC
syn keyword	cConstant	REGEX_ERROR_UNKNOWN_OPCODE REGEX_ERROR_NOMEMORY REGEX_ERROR_NOSUBSTRING REGEX_ERROR_MATCHLIMIT
syn keyword	cConstant	REGEX_ERROR_CALLOUT REGEX_ERROR_BADUTF8 REGEX_ERROR_BADUTF8_OFFSET REGEX_ERROR_PARTIAL
syn keyword	cConstant	REGEX_ERROR_BADPARTIAL REGEX_ERROR_INTERNAL REGEX_ERROR_BADCOUNT REGEX_ERROR_DFA_UITEM
syn keyword	cConstant	REGEX_ERROR_DFA_UCOND REGEX_ERROR_DFA_UMLIMIT REGEX_ERROR_DFA_WSSIZE REGEX_ERROR_DFA_RECURSE
syn keyword	cConstant	REGEX_ERROR_RECURSIONLIMIT REGEX_ERROR_NULLWSLIMIT REGEX_ERROR_BADNEWLINE
syn keyword	cTag		RegexError

" sdkhooks.inc
syn keyword	cFunction	SDKHook SDKHookEx SDKUnhook SDKHooks_TakeDamage
syn keyword	cFunction	SDKHooks_DropWeapon
syn keyword	cConstant	DMG_GENERIC DMG_CRUSH DMG_BULLET DMG_SLASH
syn keyword	cConstant	DMG_BURN DMG_VEHICLE DMG_FALL DMG_BLAST
syn keyword	cConstant	DMG_CLUB DMG_SHOCK DMG_SONIC DMG_ENERGYBEAM
syn keyword	cConstant	DMG_PREVENT_PHYSICS_FORCE DMG_NEVERGIB DMG_ALWAYSGIB DMG_DROWN
syn keyword	cConstant	DMG_PARALYZE DMG_NERVEGAS DMG_POISON DMG_RADIATION
syn keyword	cConstant	DMG_DROWNRECOVER DMG_ACID DMG_SLOWBURN DMG_REMOVENORAGDOLL
syn keyword	cConstant	DMG_PHYSGUN DMG_PLASMA DMG_AIRBOAT DMG_DISSOLVE
syn keyword	cConstant	DMG_BLAST_SURFACE DMG_DIRECT DMG_BUCKSHOT DMG_CRIT
syn keyword	cConstant	SDKHook_EndTouch SDKHook_FireBulletsPost SDKHook_OnTakeDamage SDKHook_OnTakeDamagePost
syn keyword	cConstant	SDKHook_PreThink SDKHook_PostThink SDKHook_SetTransmit SDKHook_Spawn
syn keyword	cConstant	SDKHook_StartTouch SDKHook_Think SDKHook_Touch SDKHook_TraceAttack
syn keyword	cConstant	SDKHook_TraceAttackPost SDKHook_WeaponCanSwitchTo SDKHook_WeaponCanUse SDKHook_WeaponDrop
syn keyword	cConstant	SDKHook_WeaponEquip SDKHook_WeaponSwitch SDKHook_ShouldCollide SDKHook_PreThinkPost
syn keyword	cConstant	SDKHook_PostThinkPost SDKHook_ThinkPost SDKHook_EndTouchPost SDKHook_GroundEntChangedPost
syn keyword	cConstant	SDKHook_SpawnPost SDKHook_StartTouchPost SDKHook_TouchPost SDKHook_VPhysicsUpdate
syn keyword	cConstant	SDKHook_VPhysicsUpdatePost SDKHook_WeaponCanSwitchToPost SDKHook_WeaponCanUsePost SDKHook_WeaponDropPost
syn keyword	cConstant	SDKHook_WeaponEquipPost SDKHook_WeaponSwitchPost SDKHook_Use SDKHook_UsePost
syn keyword	cConstant	SDKHook_Reload SDKHook_ReloadPost SDKHook_GetMaxHealth Use_Off
syn keyword	cConstant	Use_On Use_Set Use_Toggle
syn keyword	cTag		SDKHookType UseType SDKHookCB
syn keyword	cForward	OnEntityCreated OnEntityDestroyed OnGetGameDescription OnLevelInit

" sdktools.inc
syn keyword	cFunction	StartPrepSDKCall PrepSDKCall_SetVirtual PrepSDKCall_SetSignature PrepSDKCall_SetFromConf
syn keyword	cFunction	PrepSDKCall_SetReturnInfo PrepSDKCall_AddParameter EndPrepSDKCall SDKCall
syn keyword	cFunction	GetPlayerResourceEntity
syn keyword	cConstant	SDKCall_Static SDKCall_Entity SDKCall_Player SDKCall_GameRules
syn keyword	cConstant	SDKCall_EntityList SDKCall_Raw SDKLibrary_Server SDKLibrary_Engine
syn keyword	cConstant	SDKConf_Virtual SDKConf_Signature SDKType_CBaseEntity SDKType_CBasePlayer
syn keyword	cConstant	SDKType_Vector SDKType_QAngle SDKType_PlainOldData SDKType_Float
syn keyword	cConstant	SDKType_Edict SDKType_String SDKType_Bool SDKPass_Pointer
syn keyword	cConstant	SDKPass_Plain SDKPass_ByValue SDKPass_ByRef VDECODE_FLAG_ALLOWNULL
syn keyword	cConstant	VDECODE_FLAG_ALLOWNOTINGAME VDECODE_FLAG_ALLOWWORLD VDECODE_FLAG_BYREF VENCODE_FLAG_COPYBACK
syn keyword	cTag		SDKCallType SDKLibrary SDKFuncConfSource SDKType
syn keyword	cTag		SDKPassMethod

" sdktools_client.inc
syn keyword	cFunction	InactivateClient ReconnectClient

" sdktools_engine.inc
syn keyword	cFunction	SetClientViewEntity SetLightStyle GetClientEyePosition
syn keyword	cConstant	MAX_LIGHTSTYLES

" sdktools_entinput.inc
syn keyword	cFunction	AcceptEntityInput SetVariantBool SetVariantString SetVariantInt
syn keyword	cFunction	SetVariantFloat SetVariantVector3D SetVariantPosVector3D SetVariantColor
syn keyword	cFunction	SetVariantEntity

" sdktools_entoutput.inc
syn keyword	cFunction	HookEntityOutput UnhookEntityOutput HookSingleEntityOutput UnhookSingleEntityOutput
syn keyword	cTag		EntityOutput

" sdktools_functions.inc
syn keyword	cFunction	RemovePlayerItem GivePlayerItem GetPlayerWeaponSlot IgniteEntity
syn keyword	cFunction	ExtinguishEntity TeleportEntity ForcePlayerSuicide SlapPlayer
syn keyword	cFunction	FindEntityByClassname GetClientEyeAngles CreateEntityByName DispatchSpawn
syn keyword	cFunction	DispatchKeyValue DispatchKeyValueFloat DispatchKeyValueVector GetClientAimTarget
syn keyword	cFunction	GetTeamCount GetTeamName GetTeamScore SetTeamScore
syn keyword	cFunction	GetTeamClientCount SetEntityModel GetPlayerDecalFile GetServerNetStats
syn keyword	cFunction	EquipPlayerWeapon ActivateEntity SetClientInfo

" sdktools_gamerules.inc
syn keyword	cFunction	GameRules_GetProp GameRules_SetProp GameRules_GetPropFloat GameRules_SetPropFloat
syn keyword	cFunction	GameRules_GetPropEnt GameRules_SetPropEnt GameRules_GetPropVector GameRules_SetPropVector
syn keyword	cFunction	GameRules_GetPropString GameRules_SetPropString GameRules_GetRoundState
syn keyword	cConstant	RoundState_Init RoundState_Pregame RoundState_StartGame RoundState_Preround
syn keyword	cConstant	RoundState_RoundRunning RoundState_TeamWin RoundState_Restart RoundState_Stalemate
syn keyword	cConstant	RoundState_GameOver RoundState_Bonus RoundState_BetweenRounds
syn keyword	cTag		RoundState

" sdktools_hooks.inc
syn keyword	cConstant	FEATURECAP_PLAYERRUNCMD_11PARAMS
syn keyword	cForward	OnPlayerRunCmd

" sdktools_sound.inc
syn keyword	cFunction	PrefetchSound GetSoundDuration EmitAmbientSound FadeClientVolume
syn keyword	cFunction	StopSound EmitSound EmitSentence GetDistGainFromSoundLevel
syn keyword	cFunction	AddAmbientSoundHook AddNormalSoundHook RemoveAmbientSoundHook RemoveNormalSoundHook
syn keyword	cFunction	EmitSoundToClient EmitSoundToAll ATTN_TO_SNDLEVEL
syn keyword	cConstant	SOUND_FROM_PLAYER SOUND_FROM_LOCAL_PLAYER SOUND_FROM_WORLD SNDVOL_NORMAL
syn keyword	cConstant	SNDPITCH_NORMAL SNDPITCH_LOW SNDPITCH_HIGH SNDATTN_NONE
syn keyword	cConstant	SNDATTN_NORMAL SNDATTN_STATIC SNDATTN_RICOCHET SNDATTN_IDLE
syn keyword	cTag		AmbientSHook NormalSHook

" sdktools_stocks.inc
syn keyword	cFunction	FindTeamByName

" sdktools_stringtables.inc
syn keyword	cFunction	FindStringTable GetNumStringTables GetStringTableNumStrings GetStringTableMaxStrings
syn keyword	cFunction	GetStringTableName FindStringIndex ReadStringTable GetStringTableDataLength
syn keyword	cFunction	GetStringTableData SetStringTableData AddToStringTable LockStringTables
syn keyword	cFunction	AddFileToDownloadsTable
syn keyword	cConstant	INVALID_STRING_TABLE INVALID_STRING_INDEX

" sdktools_tempents.inc
syn keyword	cFunction	AddTempEntHook RemoveTempEntHook TE_Start TE_IsValidProp
syn keyword	cFunction	TE_WriteNum TE_ReadNum TE_WriteFloat TE_ReadFloat
syn keyword	cFunction	TE_WriteVector TE_ReadVector TE_WriteAngles TE_WriteFloatArray
syn keyword	cFunction	TE_Send TE_WriteEncodedEnt TE_SendToAll TE_SendToClient
syn keyword	cTag		TEHook

" sdktools_tempents_stocks.inc
syn keyword	cFunction	TE_SetupSparks TE_SetupSmoke TE_SetupDust TE_SetupMuzzleFlash
syn keyword	cFunction	TE_SetupMetalSparks TE_SetupEnergySplash TE_SetupArmorRicochet TE_SetupGlowSprite
syn keyword	cFunction	TE_SetupExplosion TE_SetupBloodSprite TE_SetupBeamRingPoint TE_SetupBeamPoints
syn keyword	cFunction	TE_SetupBeamLaser TE_SetupBeamRing TE_SetupBeamFollow
syn keyword	cConstant	TE_EXPLFLAG_NONE TE_EXPLFLAG_NOADDITIVE TE_EXPLFLAG_NODLIGHTS TE_EXPLFLAG_NOSOUND
syn keyword	cConstant	TE_EXPLFLAG_NOPARTICLES TE_EXPLFLAG_DRAWALPHA TE_EXPLFLAG_ROTATE TE_EXPLFLAG_NOFIREBALL
syn keyword	cConstant	TE_EXPLFLAG_NOFIREBALLSMOKE FBEAM_STARTENTITY FBEAM_ENDENTITY FBEAM_FADEIN
syn keyword	cConstant	FBEAM_FADEOUT FBEAM_SINENOISE FBEAM_SOLID FBEAM_SHADEIN
syn keyword	cConstant	FBEAM_SHADEOUT FBEAM_ONLYNOISEONCE FBEAM_NOTILE FBEAM_USE_HITBOXES
syn keyword	cConstant	FBEAM_STARTVISIBLE FBEAM_ENDVISIBLE FBEAM_ISACTIVE FBEAM_FOREVER
syn keyword	cConstant	FBEAM_HALOBEAM

" sdktools_trace.inc
syn keyword	cFunction	TR_GetPointContents TR_GetPointContentsEnt TR_TraceRay TR_TraceHull
syn keyword	cFunction	TR_TraceRayFilter TR_TraceHullFilter TR_TraceRayEx TR_TraceHullEx
syn keyword	cFunction	TR_TraceRayFilterEx TR_TraceHullFilterEx TR_GetFraction TR_GetEndPosition
syn keyword	cFunction	TR_GetEntityIndex TR_DidHit TR_GetHitGroup TR_GetPlaneNormal
syn keyword	cFunction	TR_PointOutsideWorld
syn keyword	cConstant	CONTENTS_EMPTY CONTENTS_SOLID CONTENTS_WINDOW CONTENTS_AUX
syn keyword	cConstant	CONTENTS_GRATE CONTENTS_SLIME CONTENTS_WATER CONTENTS_MIST
syn keyword	cConstant	CONTENTS_OPAQUE LAST_VISIBLE_CONTENTS ALL_VISIBLE_CONTENTS CONTENTS_TESTFOGVOLUME
syn keyword	cConstant	CONTENTS_UNUSED5 CONTENTS_UNUSED6 CONTENTS_TEAM1 CONTENTS_TEAM2
syn keyword	cConstant	CONTENTS_IGNORE_NODRAW_OPAQUE CONTENTS_MOVEABLE CONTENTS_AREAPORTAL CONTENTS_PLAYERCLIP
syn keyword	cConstant	CONTENTS_MONSTERCLIP CONTENTS_CURRENT_0 CONTENTS_CURRENT_90 CONTENTS_CURRENT_180
syn keyword	cConstant	CONTENTS_CURRENT_270 CONTENTS_CURRENT_UP CONTENTS_CURRENT_DOWN CONTENTS_ORIGIN
syn keyword	cConstant	CONTENTS_MONSTER CONTENTS_DEBRIS CONTENTS_DETAIL CONTENTS_TRANSLUCENT
syn keyword	cConstant	CONTENTS_LADDER CONTENTS_HITBOX MASK_ALL MASK_SOLID
syn keyword	cConstant	MASK_PLAYERSOLID MASK_NPCSOLID MASK_WATER MASK_OPAQUE
syn keyword	cConstant	MASK_OPAQUE_AND_NPCS MASK_VISIBLE MASK_VISIBLE_AND_NPCS MASK_SHOT
syn keyword	cConstant	MASK_SHOT_HULL MASK_SHOT_PORTAL MASK_SOLID_BRUSHONLY MASK_PLAYERSOLID_BRUSHONLY
syn keyword	cConstant	MASK_NPCSOLID_BRUSHONLY MASK_NPCWORLDSTATIC MASK_SPLITAREAPORTAL RayType_EndPoint
syn keyword	cConstant	RayType_Infinite
syn keyword	cTag		RayType TraceEntityFilter

" sdktools_voice.inc
syn keyword	cFunction	SetClientListeningFlags GetClientListeningFlags SetClientListening GetClientListening
syn keyword	cFunction	SetListenOverride GetListenOverride IsClientMuted
syn keyword	cConstant	VOICE_NORMAL VOICE_MUTED VOICE_SPEAKALL VOICE_LISTENALL
syn keyword	cConstant	VOICE_TEAM VOICE_LISTENTEAM Listen_Default Listen_No
syn keyword	cConstant	Listen_Yes
syn keyword	cTag		ListenOverride

" sorting.inc
syn keyword	cFunction	SortIntegers SortFloats SortStrings SortCustom1D
syn keyword	cFunction	SortCustom2D SortADTArray SortADTArrayCustom
syn keyword	cConstant	Sort_Ascending Sort_Descending Sort_Random
syn keyword	cTag		SortOrder SortType SortFunc1D SortFunc2D
syn keyword	cTag		SortFuncADTArray

" sourcemod.inc
syn keyword	cFunction	GetMyHandle GetPluginIterator MorePlugins ReadPlugin
syn keyword	cFunction	GetPluginStatus GetPluginFilename IsPluginDebugging GetPluginInfo
syn keyword	cFunction	FindPluginByNumber SetFailState ThrowError GetTime
syn keyword	cFunction	FormatTime LoadGameConfigFile GameConfGetOffset GameConfGetKeyValue
syn keyword	cFunction	GameConfGetAddress GetSysTickCount AutoExecConfig RegPluginLibrary
syn keyword	cFunction	LibraryExists GetExtensionFileStatus ReadMapList SetMapListCompatBind
syn keyword	cFunction	CanTestFeatures GetFeatureStatus RequireFeature LoadFromAddress
syn keyword	cFunction	StoreToAddress
syn keyword	cConstant	APLRes_Success APLRes_Failure APLRes_SilentFailure myinfo
syn keyword	cConstant	MAPLIST_FLAG_MAPSFOLDER MAPLIST_FLAG_CLEARARRAY MAPLIST_FLAG_NO_DEFAULT FeatureType_Native
syn keyword	cConstant	FeatureType_Capability FeatureStatus_Available FeatureStatus_Unavailable FeatureStatus_Unknown
syn keyword	cTag		Plugin APLRes FeatureType FeatureStatus
syn keyword	cTag		NumberType Address
syn keyword	cForward	OnPluginStart AskPluginLoad AskPluginLoad2 OnPluginEnd
syn keyword	cForward	OnPluginPauseChange OnGameFrame OnMapStart OnMapEnd
syn keyword	cForward	OnConfigsExecuted OnAutoConfigsBuffered OnServerCfg OnAllPluginsLoaded
syn keyword	cForward	OnLibraryAdded OnLibraryRemoved OnClientFloodCheck OnClientFloodResult

" string.inc
syn keyword	cFunction	strlen StrContains strcmp strncmp
syn keyword	cFunction	StrCompare StrEqual strcopy StrCopy
syn keyword	cFunction	Format FormatEx VFormat StringToInt
syn keyword	cFunction	StringToIntEx IntToString StringToFloat StringToFloatEx
syn keyword	cFunction	FloatToString BreakString StrBreak TrimString
syn keyword	cFunction	SplitString ReplaceString ReplaceStringEx GetCharBytes
syn keyword	cFunction	IsCharAlpha IsCharNumeric IsCharSpace IsCharMB
syn keyword	cFunction	IsCharUpper IsCharLower StripQuotes CharToUpper
syn keyword	cFunction	CharToLower FindCharInString StrCat ExplodeString
syn keyword	cFunction	ImplodeStrings

" textparse.inc
syn keyword	cFunction	SMC_CreateParser SMC_ParseFile SMC_GetErrorString SMC_SetParseStart
syn keyword	cFunction	SMC_SetParseEnd SMC_SetReaders SMC_SetRawLine
syn keyword	cConstant	SMCParse_Continue SMCParse_Halt SMCParse_HaltFail SMCError_Okay
syn keyword	cConstant	SMCError_StreamOpen SMCError_StreamError SMCError_Custom SMCError_InvalidSection1
syn keyword	cConstant	SMCError_InvalidSection2 SMCError_InvalidSection3 SMCError_InvalidSection4 SMCError_InvalidSection5
syn keyword	cConstant	SMCError_InvalidTokens SMCError_TokenOverflow SMCError_InvalidProperty1
syn keyword	cTag		SMCResult SMCError SMC_ParseStart SMC_ParseEnd
syn keyword	cTag		SMC_NewSection SMC_KeyValue SMC_EndSection SMC_RawLine

" tf2.inc
syn keyword	cFunction	TF2_IgnitePlayer TF2_RespawnPlayer TF2_RegeneratePlayer TF2_AddCondition
syn keyword	cFunction	TF2_RemoveCondition TF2_SetPlayerPowerPlay TF2_DisguisePlayer TF2_RemovePlayerDisguise
syn keyword	cFunction	TF2_StunPlayer TF2_MakeBleed TF2_GetResourceEntity TF2_GetClass
syn keyword	cFunction	TF2_IsPlayerInDuel
syn keyword	cConstant	TF_STUNFLAG_SLOWDOWN TF_STUNFLAG_BONKSTUCK TF_STUNFLAG_LIMITMOVEMENT TF_STUNFLAG_CHEERSOUND
syn keyword	cConstant	TF_STUNFLAG_NOSOUNDOREFFECT TF_STUNFLAG_THIRDPERSON TF_STUNFLAG_GHOSTEFFECT TF_STUNFLAGS_LOSERSTATE
syn keyword	cConstant	TF_STUNFLAGS_GHOSTSCARE TF_STUNFLAGS_SMALLBONK TF_STUNFLAGS_NORMALBONK TF_STUNFLAGS_BIGBONK
syn keyword	cConstant	TFClass_Unknown TFClass_Scout TFClass_Sniper TFClass_Soldier
syn keyword	cConstant	TFClass_DemoMan TFClass_Medic TFClass_Heavy TFClass_Pyro
syn keyword	cConstant	TFClass_Spy TFClass_Engineer TFTeam_Unassigned TFTeam_Spectator
syn keyword	cConstant	TFTeam_Red TFTeam_Blue TFCond_Slowed TFCond_Zoomed
syn keyword	cConstant	TFCond_Disguising TFCond_Disguised TFCond_Cloaked TFCond_Ubercharged
syn keyword	cConstant	TFCond_TeleportedGlow TFCond_Taunting TFCond_UberchargeFading TFCond_Unknown1
syn keyword	cConstant	TFCond_CloakFlicker TFCond_Teleporting TFCond_Kritzkrieged TFCond_Unknown2
syn keyword	cConstant	TFCond_TmpDamageBonus TFCond_DeadRingered TFCond_Bonked TFCond_Dazed
syn keyword	cConstant	TFCond_Buffed TFCond_Charging TFCond_DemoBuff TFCond_CritCola
syn keyword	cConstant	TFCond_InHealRadius TFCond_Healing TFCond_OnFire TFCond_Overhealed
syn keyword	cConstant	TFCond_Jarated TFCond_Bleeding TFCond_DefenseBuffed TFCond_Milked
syn keyword	cConstant	TFCond_MegaHeal TFCond_RegenBuffed TFCond_MarkedForDeath TFCond_NoHealingDamageBuff
syn keyword	cConstant	TFCond_SpeedBuffAlly TFCond_HalloweenCritCandy TFCond_CritCanteen TFCond_CritHype
syn keyword	cConstant	TFCond_CritOnFirstBlood TFCond_CritOnWin TFCond_CritOnFlagCapture TFCond_CritOnKill
syn keyword	cConstant	TFCond_RestrictToMelee TFCond_Reprogrammed TFCond_CritMmmph TFCond_DefenseBuffMmmph
syn keyword	cConstant	TFCond_FocusBuff TFCond_DisguiseRemoved TFCond_MarkedForDeathSilent TFCond_DisguisedAsDispenser
syn keyword	cConstant	TFCond_Sapped TFCond_UberchargedHidden TFCond_UberchargedCanteen TFCond_HalloweenBombHead
syn keyword	cConstant	TFCond_HalloweenThriller TFCond_RadiusHealOnDamage TFCond_CritOnDamage TFCond_UberchargedOnTakeDamage
syn keyword	cConstant	TFCond_UberBulletResist TFCond_UberBlastResist TFCond_UberFireResist TFCond_SmallBulletResist
syn keyword	cConstant	TFCond_SmallBlastResist TFCond_SmallFireResist TFHoliday_Birthday TFHoliday_Halloween
syn keyword	cConstant	TFHoliday_Christmas TFHoliday_ValentinesDay TFHoliday_MeetThePyro TFHoliday_FullMoon
syn keyword	cConstant	TFHoliday_HalloweenOrFullMoon TFHoliday_HalloweenOrFullMoonOrValentines TFObject_CartDispenser TFObject_Dispenser
syn keyword	cConstant	TFObject_Teleporter TFObject_Sentry TFObject_Sapper TFObjectMode_None
syn keyword	cConstant	TFObjectMode_Entrance TFObjectMode_Exit
syn keyword	cTag		TFClassType TFTeam TFCond TFHoliday
syn keyword	cTag		TFObjectType TFObjectMode
syn keyword	cForward	TF2_CalcIsAttackCritical TF2_OnGetHoliday TF2_OnIsHolidayActive TF2_OnConditionAdded
syn keyword	cForward	TF2_OnConditionRemoved TF2_OnWaitingForPlayersStart TF2_OnWaitingForPlayersEnd TF2_OnPlayerTeleport

" tf2_stocks.inc
syn keyword	cFunction	TF2_GetPlayerClass TF2_SetPlayerClass TF2_GetPlayerResourceData TF2_SetPlayerResourceData
syn keyword	cFunction	TF2_RemoveWeaponSlot TF2_RemoveAllWeapons TF2_GetPlayerConditionFlags TF2_IsPlayerInCondition
syn keyword	cFunction	TF2_GetObjectType TF2_GetObjectMode
syn keyword	cConstant	TF_CONDFLAG_NONE TF_CONDFLAG_SLOWED TF_CONDFLAG_ZOOMED TF_CONDFLAG_DISGUISING
syn keyword	cConstant	TF_CONDFLAG_DISGUISED TF_CONDFLAG_CLOAKED TF_CONDFLAG_UBERCHARGED TF_CONDFLAG_TELEPORTGLOW
syn keyword	cConstant	TF_CONDFLAG_TAUNTING TF_CONDFLAG_UBERCHARGEFADE TF_CONDFLAG_CLOAKFLICKER TF_CONDFLAG_TELEPORTING
syn keyword	cConstant	TF_CONDFLAG_KRITZKRIEGED TF_CONDFLAG_DEADRINGERED TF_CONDFLAG_BONKED TF_CONDFLAG_DAZED
syn keyword	cConstant	TF_CONDFLAG_BUFFED TF_CONDFLAG_CHARGING TF_CONDFLAG_DEMOBUFF TF_CONDFLAG_CRITCOLA
syn keyword	cConstant	TF_CONDFLAG_INHEALRADIUS TF_CONDFLAG_HEALING TF_CONDFLAG_ONFIRE TF_CONDFLAG_OVERHEALED
syn keyword	cConstant	TF_CONDFLAG_JARATED TF_CONDFLAG_BLEEDING TF_CONDFLAG_DEFENSEBUFFED TF_CONDFLAG_MILKED
syn keyword	cConstant	TF_CONDFLAG_MEGAHEAL TF_CONDFLAG_REGENBUFFED TF_CONDFLAG_MARKEDFORDEATH TF_DEATHFLAG_KILLERDOMINATION
syn keyword	cConstant	TF_DEATHFLAG_ASSISTERDOMINATION TF_DEATHFLAG_KILLERREVENGE TF_DEATHFLAG_ASSISTERREVENGE TF_DEATHFLAG_FIRSTBLOOD
syn keyword	cConstant	TF_DEATHFLAG_DEADRINGER TF_DEATHFLAG_INTERRUPTED TF_DEATHFLAG_GIBBED TF_DEATHFLAG_PURGATORY
syn keyword	cConstant	TFResource_Ping TFResource_Score TFResource_Deaths TFResource_TotalScore
syn keyword	cConstant	TFResource_Captures TFResource_Defenses TFResource_Dominations TFResource_Revenge
syn keyword	cConstant	TFResource_BuildingsDestroyed TFResource_Headshots TFResource_Backstabs TFResource_HealPoints
syn keyword	cConstant	TFResource_Invulns TFResource_Teleports TFResource_ResupplyPoints TFResource_KillAssists
syn keyword	cConstant	TFResource_MaxHealth TFResource_PlayerClass
syn keyword	cTag		TFResourceType

" timers.inc
syn keyword	cFunction	CreateTimer KillTimer TriggerTimer GetTickedTime
syn keyword	cFunction	GetMapTimeLeft GetMapTimeLimit ExtendMapTimeLimit GetTickInterval
syn keyword	cFunction	IsServerProcessing CreateDataTimer
syn keyword	cConstant	TIMER_REPEAT TIMER_FLAG_NO_MAPCHANGE TIMER_HNDL_CLOSE TIMER_DATA_HNDL_CLOSE
syn keyword	cTag		Timer
syn keyword	cForward	OnMapTimeLeftChanged

" topmenus.inc
syn keyword	cFunction	CreateTopMenu LoadTopMenuConfig AddToTopMenu GetTopMenuInfoString
syn keyword	cFunction	GetTopMenuObjName RemoveFromTopMenu DisplayTopMenu FindTopMenuCategory
syn keyword	cConstant	TopMenuAction_DisplayOption TopMenuAction_DisplayTitle TopMenuAction_SelectOption TopMenuObject_Category
syn keyword	cConstant	TopMenuObject_Item TopMenuPosition_Start TopMenuPosition_LastRoot TopMenuPosition_LastCategory
syn keyword	cConstant	INVALID_TOPMENUOBJECT
syn keyword	cTag		TopMenuAction TopMenuObjectType TopMenuPosition TopMenuObject
syn keyword	cTag		TopMenuHandler

" usermessages.inc
syn keyword	cFunction	GetUserMessageType GetUserMessageId GetUserMessageName StartMessage
syn keyword	cFunction	StartMessageEx EndMessage HookUserMessage UnhookUserMessage
syn keyword	cFunction	StartMessageAll StartMessageOne
syn keyword	cConstant	INVALID_MESSAGE_ID UM_BitBuf UM_Protobuf USERMSG_RELIABLE
syn keyword	cConstant	USERMSG_INITMSG USERMSG_BLOCKHOOKS
syn keyword	cTag		UserMsg UserMessageType MsgHook MsgPostHook

" vector.inc
syn keyword	cFunction	GetVectorLength GetVectorDistance GetVectorDotProduct GetVectorCrossProduct
syn keyword	cFunction	NormalizeVector GetAngleVectors GetVectorAngles GetVectorVectors
syn keyword	cFunction	AddVectors SubtractVectors ScaleVector NegateVector
syn keyword	cFunction	MakeVectorFromPoints

" version.inc
syn keyword	cConstant	SOURCEMOD_V_TAG SOURCEMOD_V_REV SOURCEMOD_V_CSET SOURCEMOD_V_MAJOR
syn keyword	cConstant	SOURCEMOD_V_MINOR SOURCEMOD_V_RELEASE SOURCEMOD_VERSION

" version_auto.inc
syn keyword	cConstant	SOURCEMOD_V_TAG SOURCEMOD_V_REV SOURCEMOD_V_CSET SOURCEMOD_V_MAJOR
syn keyword	cConstant	SOURCEMOD_V_MINOR SOURCEMOD_V_RELEASE SOURCEMOD_VERSION
" Accept %: for # (C99)
syn region      cPreCondit      start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$"  keepend contains=cComment,cCommentL,cCppString,cCharacter,cCppParen,cParenError,cNumbers,cCommentError,cSpaceError
syn match	cPreCondit	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  if !exists("c_no_if0_fold")
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2 fold
  else
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
  endif
  syn region	cCppOut2	contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cSpaceError,cCppSkip
  syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppSkip
endif
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
"syn match cLineSkip	"\\$"
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cErrInParen,cErrInBracket,cUserLabel,cSpecial,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cString,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cParen,cBracket,cMulti
syn region	cDefine		start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
syn region	cPreProc	start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell

" Highlight User Labels
syn cluster	cMultiGroup	contains=cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cCppParen,cCppBracket,cCppString
syn region	cMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@cMultiGroup,@Spell
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	cLabelGroup	contains=cUserLabel
syn match	cUserCont	display "^\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display "^\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup

syn match	cUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	cBitField	display "^\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType
syn match	cBitField	display ";\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cFormat		cSpecial
hi def link cCppString		cString
hi def link cCommentL		cComment
hi def link cCommentStart	cComment
hi def link cLabel		Label
hi def link cUserLabel		Label
hi def link cConditional	Conditional
hi def link cRepeat		Repeat
hi def link cCharacter		Character
hi def link cSpecialCharacter	cSpecial
hi def link cNumber		Number
hi def link cOctal		Number
hi def link cOctalZero		PreProc	 " link this to Error if you want
hi def link cFloat		Float
hi def link cOctalError		cError
hi def link cParenError		cError
hi def link cErrInParen		cError
hi def link cErrInBracket	cError
hi def link cCommentError	cError
hi def link cCommentStartError	cError
hi def link cSpaceError		cError
hi def link cSpecialError	cError
hi def link cCurlyError		cError
hi def link cOperator		Operator
hi def link cStructure		Structure
hi def link cStorageClass	StorageClass
hi def link cInclude		Include
hi def link cPreProc		PreProc
hi def link cDefine		Macro
hi def link cIncluded		cString
hi def link cError		Error
hi def link cStatement		Statement
hi def link cPreCondit		PreCondit
hi def link cType		Type
hi def link cConstant		Constant
hi def link cCommentString	cString
hi def link cComment2String	cString
hi def link cCommentSkip	cComment
hi def link cString		String
hi def link cComment		Comment
hi def link cSpecial		SpecialChar
hi def link cTodo		Todo
hi def link cBadContinuation	Error
hi def link cCppSkip		cCppOut
hi def link cCppOut2		cCppOut
hi def link cCppOut		Comment

hi def link cFunction   	Function
hi def link cForward    	Function

let b:current_syntax = "pawn"

let &cpo = s:cpo_save
unlet s:cpo_save
