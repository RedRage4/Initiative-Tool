#SingleInstance off

IniRead, PartyMembers, InitiativeTool.ini, Settings, Party, %A_Space%
CurrEnc = Encounter
EncList = Encounter
EncIndex = 1

Menu, FileMenu, Add, New &Encounter, NewEncounter
Menu, FileMenu, Add, New &Campaign, NewCampaign
Menu, FileMenu, Add
Menu, FileMenu, Add, &Open Campaign, OpenCampaign
Menu, FileMenu, Add, &Save Campaign, SaveCampaign
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose
Menu, EncounterList, Add, Change Name..., EditEncounter
Menu, EncounterList, Add
Menu, EncounterList, Add, Encounter, OpenEncounter
Menu, EncounterList, Disable, Encounter
Menu, CombatantMenu, Add, &Party, OrgParty
Menu, CombatantMenu, Add, &Encounter, OrgEncounter

Menu, MenuBar, Add, &File, :FileMenu
Menu, MenuBar, Add, &Encounter, :EncounterList
Menu, MenuBar, Add, &Combatants, :CombatantMenu
Gui, Menu, MenuBar

Gui, Add, ListView, AltSubmit gListClick Checked Count15 R12 Grid LV0x10 -Multi NoSortHdr, Init|Name
LV_ModifyCol(1, "40 Integer Center")

Gui, Add, Edit, vInit W30 Center Disabled Number -WantReturn
Gui, Add, Button, Hidden x+10 gButtonInit vButtonInit,
Gui, Add, Button, Hidden xp vButtonBack gButtonBack, <&Back
Gui, Add, Button, Hidden x+10 yp vButtonNext gButtonNext, &Next>
Gui, Add, Button, xm vButtonStart, &Start
Gui, Add, Button, Hidden xp vButtonEnd, &End

Gui, Show,, Initiative Tool
return


NewEncounter:
Gui, 1:+Disabled
Gui, 2:+owner1
Gui, 2:Add, Text, ym+3, Encounter Name:
Gui, 2:Add, Edit, vEncName ym w200, Encounter%EncIndex%
Gui, 2:Add, Button, gNameEncounter Default x+-36 y+7, Ok
Gui, 2:Add, Button, gButtonCancel xp-55, Cancel
Gui, 2:Show,, New Encounter
return


NameEncounter:
if (CurrEnc = "Encounter" && %CurrEnc% = "") {
	Menu, EncounterList, Delete, Encounter
	EncList =
}
else
	Menu, EncounterList, Enable, %CurrEnc%

Gui, 2:Submit, NoHide

CurrEnc = %EncName%
if EncList =
	EncList = %CurrEnc%
else
	EncList .= "|" . CurrEnc

if CurrEnc = Encounter%EncIndex%
	EncIndex++
	
Menu, EncounterList, Add, %CurrEnc%, OpenEncounter
Menu, EncounterList, Disable, %CurrEnc%

Gui, 1:-Disabled
Gui, 2:Destroy
Gui, 1:Default
LV_Delete()
return


EditEncounter:
Gui +Disabled
Gui, 2:+owner1
Gui, 2:Add, Text, ym+3, Encounter Name:
Gui, 2:Add, Edit, vNewMember ym w200, %CurrEnc%
Gui, 2:Add, Button, gChangeEncounter Default x+-36 y+7, Ok
Gui, 2:Add, Button, gButtonCancel xp-55, Cancel
Gui, 2:Show,, Edit Encounter
return


ChangeEncounter:
Gui, 2:Submit, NoHide

StringReplace, NewMember, NewMember, %A_Space%, _, 1

Menu, EncounterList, Rename, %CurrEnc%, %NewMember%
StringReplace, EncList, EncList, %CurrEnc%, %NewMember%

if (CurrEnc = "Encounter" . EncIndex - 1)
	EncIndex--

%CurrEnc% =
CurrEnc = %NewMember%

Gui, 1:-Disabled
Gui, 2:Destroy
return


OpenEncounter:
Menu, EncounterList, Enable, %CurrEnc%
Menu, EncounterList, Disable, %A_ThisMenuItem%

CurrEnc = %A_ThisMenuItem%

LV_Delete()
Loop, Parse, %CurrEnc%, |
{
	LV_Add("", %CurrEnc%Init%A_Index%, A_LoopField)
}
LV_ModifyCol(1, "SortDesc")
return


NewCampaign:
Run %A_ScriptDir%\InitiativeTool.ahk
WinWait, Initiative Tool ahk_class AutoHotkeyGUI,, 2
if ErrorLevel = 1
	Run %A_ScriptDir%\InitiativeTool.exe
return


OpenCampaign:
FileSelectFile, SaveName, 1,, Open Campaign, INI (*.ini)
MakeIni(SaveName)
	
IniRead, PartyMembers, %SaveName%, Settings, Party, %A_Space%
IniRead, CurrEnc, %SaveName%, Settings, CurrEnc, %A_Space%
IniRead, EncList, %SaveName%, Settings, EncList, %A_Space%
IniRead, EncIndex, %SaveName%, Settings, EncIndex, %A_Space%

Gui, Menu
Menu, EncounterList, DeleteAll
Menu, EncounterList, Add, Change Name..., EditEncounter
Menu, EncounterList, Add
Gui, Menu, MenuBar

Loop, Parse, EncList, |
{
	NewMember = %A_LoopField%
	IniRead, %A_LoopField%, %SaveName%, %A_LoopField%, Combatants
	Menu, EncounterList, Add, %A_LoopField%, OpenEncounter
	Loop, Parse, %A_LoopField%, |
	{
		IniRead, %NewMember%Init%A_Index%, %SaveName%, %NewMember%, %A_LoopField%, %A_Space%
	}
}

Menu, EncounterList, Disable, %CurrEnc%

LV_Delete()
Loop, Parse, %CurrEnc%, |
{
	LV_Add("", %CurrEnc%Init%A_Index%, A_LoopField)
}
LV_ModifyCol(1, "SortDesc")

NewMember =
return


SaveCampaign:
FileSelectFile, SaveName, S24, Campaign.ini, Save Campaign, INI (*.ini)
MakeIni(SaveName)

IniWrite, %PartyMembers%, %SaveName%, Settings, Party
IniWrite, %CurrEnc%, %SaveName%, Settings, CurrEnc
IniWrite, %EncList%, %SaveName%, Settings, EncList
IniWrite, %EncIndex%, %SaveName%, Settings, EncIndex

Loop, Parse, EncList, |
{
	NewMember = %A_LoopField%
	IniWrite,% VarCon(%A_LoopField%), %SaveName%, %A_LoopField%, Combatants
	Loop, Parse, %A_LoopField%, |
	{
		if (%NewMember%Init%A_Index% != "")
			IniWrite,% VarCon(%NewMember%Init%A_Index%), %SaveName%, %NewMember%, %A_LoopField%
	}
}

NewMember =
return


ButtonStart:
GuiControl, Hide, ButtonStart
GuiControl, Show, ButtonEnd
GuiControl, Show, ButtonBack
GuiControl, Show, ButtonNext

LV_Modify(1, "Check")
Highlighted = 1
LV_GetText(Curr, 1, 2)
LV_GetText(Next, 2, 2)

;Gui, 3:Font, s12, Old English Text MT
Gui, 3:+AlwaysOnTop +owner1 -SysMenu
Gui, 3:Add, Text, w140, Current: %Curr%
Gui, 3:Add, Text, w140, Next: %Next%
Gui, 3:Show, w150
return


ButtonBack:
LV_Modify(Highlighted, "-Check")

if Highlighted = 1
{
	LV_GetText(Next, 1, 2)
	Loop
	{
		LV_GetText(NewMember, LV_GetCount() - A_Index - 1, 1)
		if (NewMember != "") {
			Highlighted := LV_GetCount() - A_Index - 1
			break
		}
	}
}
else {
	LV_GetText(Next, Highlighted, 2)
	Highlighted--
}

LV_Modify(Highlighted, "Check")
LV_GetText(Curr, Highlighted, 2)
GuiControl, 3:, Static1, Current: %Curr%
GuiControl, 3:, Static2, Next: %Next%
return


ButtonNext:
LV_Modify(Highlighted, "-Check")

LV_GetText(NewMember, ++Highlighted, 1)
if (NewMember = "") {
	Highlighted = 1
	LV_GetText(Next, 2, 2)
}
else {
	LV_GetText(NewMember, Highlighted + 1, 1)
	if (NewMember = "")
		LV_GetText(Next, 1, 2)
	else
		LV_GetText(Next, Highlighted + 1, 2)
}
LV_GetText(Curr, Highlighted, 2)

LV_Modify(Highlighted, "Check")
GuiControl, 3:, Static1, Current: %Curr%
GuiControl, 3:, Static2, Next: %Next%
return


ButtonEnd:
GuiControl, Show, ButtonStart
GuiControl, Hide, ButtonEnd
GuiControl, Hide, ButtonBack
GuiControl, Hide, ButtonNext
Gui, 3:Destroy
return


ListClick:
if A_GuiEvent = Normal
{
	Row = %A_EventInfo%
	GuiControl, Enable, Edit1
	GuiControl, Focus, Edit1
	GuiControl, +Default, ButtonInit
}
return


ButtonInit:
GUI, Submit, NoHide
LV_Modify(Row, "", Init)
LV_GetText(Name, Row, 2)
Loop, Parse, %CurrEnc%, |
{
	if (Name = A_LoopField) {
		%CurrEnc%Init%A_Index% := Init
	}
}

GuiControl,, Edit1,
GuiControl, Disable, Edit1
LV_ModifyCol(1, "SortDesc")
GuiControl, +Default, Start7
return


OrgParty:
GUI +Disabled
GUI, 2:-Sysmenu +owner1

GUI, 2:Add, Text,, Add Party Member:
GUI, 2:Add, Edit, vNewMember W180
GUI, 2:Add, Button, Default x160 gPartyAdd, &Add

GUI, 2:Add, Text, xm, Party Members:
GUI, 2:Add, ListBox, R8 W180 vRemove, %PartyMembers%

GUI, 2:Add, Button, gClearPartyList, &Clear
GUI, 2:Add, Button, x+93 yp gPartyRemove, &Remove
GUI, 2:Add, Button, w50 gPartyOk, &Ok
GUI, 2:Show,, Party Members
return


PartyAdd:
Add(PartyMembers)
return


ClearPartyList:
GuiControl, 2:, ListBox1, |
PartyMembers =
return


PartyRemove:
Remove(PartyMembers)
return


OrgEncounter:
if %CurrEnc% =
{
	%CurrEnc% = %PartyMembers%
	Loop, Parse, %CurrEnc%, |
	{
		LV_Add("", "", A_LoopField)
	}
}

Gui +Disabled
Gui, 2:-Sysmenu +owner1

Gui, 2:Add, Text,, Add Combatant:
Gui, 2:Add, Edit, vNewMember w180
Gui, 2:Add, Button, Default x160 gCombatantAdd, &Add

Gui, 2:Add, Text, xm, Combatants:
GUI, 2:Add, ListBox, R12 W180 vRemove,% VarCon(%CurrEnc%)

Gui, 2:Add, Button, gClearCombatantList, &Clear
Gui, 2:Add, Button, x+93 yp gCombatantRemove, &Remove
Gui, 2:Add, Button, w50 gCombatantOk, &Ok
Gui, 2:Show,, Encounter Combatants
return


CombatantAdd:
Add(%CurrEnc%)
Gui, 1:Default
LV_Add("", "", NewMember)
return


ClearCombatantList:
GuiControl, 2:, ListBox1, |
%CurrEnc% =
return


CombatantRemove:
Remove(%CurrEnc%)

Gui, 1:Default
Loop {
	LV_GetText(Name, A_Index, 2)
	if (Remove = Name) {
		Row = %A_Index%
		break
	}
}
LV_Delete(Row)
return


2GuiClose:
ButtonCancel:
PartyOk:
CombatantOk:
GUI, 1:-Disabled
GUI, 2:Destroy
return


MakeIni(ByRef SaveName) {
	StringRight, Check, SaveName, 4
	if Check != .ini
		SaveName .= .ini
}

Add(ByRef List) {
	global NewMember
	
	GUI, 2:Submit, NoHide
	if List =
		List = %NewMember%
	else
		List = %List%|%NewMember%
	GuiControl, 2:, ListBox1, %NewMember%
	GuiControl, 2:, Edit1
	GuiControl, Focus, Edit1
}

Remove(ByRef List) {
	global Remove
	
	GUI, 2:Submit, NoHide
	StringReplace, List, List, %Remove%
	StringReplace, List, List, ||, |
	if ErrorLevel = 1
	{
		StringLeft, Tempv, List, 1
		if Tempv = |
			StringTrimLeft, List, List, 1
		else
			StringTrimRight, List, List, 1
	}
	GuiControl, 2:, ListBox1, |%List%
}

VarCon(Var) {
	return %Var%
}

GuiClose:
ExitApp