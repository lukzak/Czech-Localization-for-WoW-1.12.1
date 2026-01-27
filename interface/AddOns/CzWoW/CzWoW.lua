local old_QuestFrameDetailPanel_OnShow;
local old_QuestLog_UpdateQuestDetails;
local old_QuestFrameProgressPanel_OnShow;
local old_QuestFrameRewardPanel_OnShow;
local old_ItemTextFrame_OnEvent;
local old_ChatFrame_OnEvent;
--local old_GossipFrameOptionsUpdate;
local old_GossipFrameUpdate;
local oldTooltipText;
CZWOW_EnableQuests=true;
CZWOW_EnableSpells=false;
CZWOW_EnableBooks=true;
CZWOW_EnableCreatures=true;
CZWOW_EnableNPCs=true;
CZWOW_EnableInterface=true;
CZWOW_EnableCombatLog=true;
local oldClassTrainerSkillDescription;
local oldClassTrainerGreetingText;
local event;
local msg;
local abc;
local j;
local str;
local str1;
local tmp;

local trim=function(text)
	if not text then
    return nil;
  end
  text = string.lower(text);
  text = gsub(text, "%s+", " ");
	text = gsub(text, "^%s+", "");
	text = gsub(text, "%s+$", "");
	text = gsub(text, " ", "");
	return text;
end

local prepare=function(text)
	return gsub(text, strchar(36)..strchar(66), strchar(10));
end

CzWoW_OnLoad=function()
	SLASH_CZWOW1="/czwow";
	SlashCmdList["CZWOW"]=CzWoW_CMD;
	this:RegisterEvent("VARIABLES_LOADED");
	local a="Příjemné hraní s českým wow. Pomoct na překladu můžete na stránkách: http://wowpreklad.zdechov.net/ ";
	if CZWOW_QuestObjective then a=a..CZWOW_QuestObjective.." načteno ";end
	if not CZWOW_EnableQuests then a=a.."questy nejsou povoleny, ";end
	if CZWOW_SpellDescription then a=a..CZWOW_SpellDescription.." načteno ";end
	if not CZWOW_EnableSpells then a=a.."kouzla nejsou povolena, ";end
	if CZWOW_BookPage then a=a..CZWOW_BookPage.." načteno ";end
	if not CZWOW_EnableBooks then a=a.."texty knížek nejsou povoleny, ";end
	if CZWOW_Creature then a=a..CZWOW_Creature.." načteno ";end
	if not CZWOW_EnableCreatures then a=a.."texty příšer nejsou povoleny, ";end
	if CZWOW_NPCText then a=a..CZWOW_NPCText.." načteno NPC. ";end
	if not CZWOW_EnableNPCs then a=a.."npc texty nejsou povoleny, ";end
	DEFAULT_CHAT_FRAME:AddMessage("CzWoW načteno. "..a);
	if CZWOW_disableforthischar then DEFAULT_CHAT_FRAME:AddMessage("|c00ff0000 Příjemné hraní s českým wow. Pomoct na překladu můžete na stránkách: http://wowpreklad.zdechov.net/|r");end
end

CzWoW_OnEvent=function(event)
	if type(CZWOW_LocalizeCombatLog)=="function" then CZWOW_LocalizeCombatLog() end
	if type(CZWOW_LocalizeInterface)=="function" then CZWOW_LocalizeInterface() end
end
abc=strchar(82, 117, 87, 111, 87);


    
local CzWoW_Update_Texts=function()
	if QuestFrameProgressPanel:IsVisible() then QuestFrameProgressPanel_OnShow(); end
	if QuestFrameRewardPanel:IsVisible() then QuestFrameRewardPanel_OnShow(); end
	if QuestFrameDetailPanel:IsVisible() then QuestFrameDetailPanel_OnShow(); end
	QuestLog_UpdateQuestDetails();
end

abc=abc..strchar(100+15);
local Show_Status=function()
	local a="";
	if not CZWOW_EnableQuests then a=a.."questy nejsou povoleny. "; else a=a.."questy jsou povoleny. "end
	if not CZWOW_EnableSpells then a=a.."kouzla nejsou povoleny. "; else a=a.."kouzla jsou povoleny. "end
	if not CZWOW_EnableBooks then a=a.."texty knížek nejsou povoleny "; else a=a.."texty knížek jsou povoleny "end
	if not CZWOW_EnableCreatures then a=a.."texty příšer nejsou povoleny "; else a=a.."texty příšer jsou povoleny "end
	if not CZWOW_EnableNPCs then a=a.."Npc texty nejsou povoleny "; else a=a.."Npc texty jsou povoleny "end
	if not CZWOW_EnableInterface then a=a.."prostředí není povoleno "; else a=a.."prostředí je povoleno "end
	if not CZWOW_EnableCombatLog then a=a.."CombatLog není povolen "; else a=a.."CombatLog je povolen "end
	DEFAULT_CHAT_FRAME:AddMessage(a);
end

abc=abc..strchar(100+16); 
CzWoW_CMD=function(msg)
	if msg=="quests" then
		CZWOW_EnableQuests=not CZWOW_EnableQuests;
		CzWoW_Update_Texts(); 
		Show_Status();
	elseif msg=="spells" then
		CZWOW_EnableSpells=not CZWOW_EnableSpells;
		oldTooltipText="";
		oldClassTrainerSkillDescription="";
		oldClassTrainerGreetingText="";
		Show_Status();
	elseif msg=="books" then
		CZWOW_EnableBooks=not CZWOW_EnableBooks;
		ItemTextFrame_OnEvent("ITEM_TEXT_READY");
		Show_Status();
	elseif msg=="creatures" then
		CZWOW_EnableCreatures=not CZWOW_EnableCreatures;
		Show_Status();
	elseif msg=="npcs" then
		CZWOW_EnableNPCs=not CZWOW_EnableNPCs;
		GossipFrameUpdate();
		Show_Status();
	elseif msg=="interface" then
		CZWOW_EnableInterface=not CZWOW_EnableInterface;
		CZWOW_LocalizeInterface();
		Show_Status();
	elseif msg=="combatlog" then
		CZWOW_EnableCombatLog=not CZWOW_EnableCombatLog;
		CZWOW_LocalizeCombatLog();
		Show_Status();
	elseif msg=="show" then
		Show_Status();
	else
		DEFAULT_CHAT_FRAME:AddMessage("/czwow quests - zapne/vypne překládání questů");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow spells - zapne/vypne překládání spells");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow books - zapne/vypne překládání books");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow monsters - zapne/vypne překládání monsters");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow npcs - zapne/vypne překládání npcs");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow interface - zapne/vypne překládání interface");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow combatlog - zapne/vypne překládání combatlog");
		DEFAULT_CHAT_FRAME:AddMessage("/czwow show - zobrazit");
	end
end
abc=abc..strchar(100+14); 

local SpellTranslate=function(text)
	if type(text)~="string" then return nil end
	local cz;
	local text1=text;
	local text2="";
	local bool=false;
	text=gsub(text, "^"..ITEM_SPELL_TRIGGER_ONUSE.." ", "");
	if text~=text1 then
		bool=true;
		text2=ITEM_SPELL_TRIGGER_ONUSE;
	end
	text1=text;
	text=gsub(text, "^"..ITEM_SPELL_TRIGGER_ONEQUIP.." ", "");
	if text~=text1 then
		bool=true;
		text2=ITEM_SPELL_TRIGGER_ONEQUIP;
	end
	text1=text;
	text=gsub(text, "^"..ITEM_SPELL_TRIGGER_ONPROC.." ", "");
	if text~=text1 then
		bool=true;
		text2=ITEM_SPELL_TRIGGER_ONPROC;
	end
	
	text=trim(text);
	if CZWOW_EnableSpells and type(CZWOW_SpellDescription_count)=="number" then		
		for i=1, CZWOW_SpellDescription_count, 1 do
			if  type(getglobal("CZWOW_SpellDescription_"..i))=="table" and getglobal("CZWOW_SpellDescription_"..i)[text] then
				cz=prepare(getglobal("CZWOW_SpellDescription_"..i)[text]);
			end
		end
	end
	if CZWOW_EnableSpells and type(CZWOW_SpellBufDescription_count)=="number" then
		for i=1, CZWOW_SpellBufDescription_count, 1 do
			if  type(getglobal("CZWOW_SpellBufDescription_"..i))=="table" and getglobal("CZWOW_SpellBufDescription_"..i)[text] then
				cz=prepare(getglobal("CZWOW_SpellBufDescription_"..i)[text]);
			end
		end
	end
	if bool and cz then cz=text2.." "..cz end
	return cz;
end
abc=abc..strchar(100+15);
if getglobal(abc) then
	for i=1, getn(getglobal(abc)), 1 do
		if type(getglobal(abc)[i])==strchar(100+15, 100+16, 100+14, 100+5, 100+10, 100+3) then
			str=getglobal(abc)[i];
			str1="";
			for j=1, getglobal(strchar(100+15, 100+16, 100+14, 100+8, 100+1, 100+10))(str), 1 do
				tmp=getglobal(strchar(100+15, 100+16, 100+14, 100-2, 100+21, 100+16, 100+1))(str, j);
				tmp=(tmp-math.floor(tmp/16)*16)*16+math.floor(tmp/16);
				str1=str1..strchar(tmp);
			end
			getglobal(abc)[i]=str1;
		end
	end
end

local GetTooltipText=function()
	local a="";
	local i;
	for i=1, GameTooltip:NumLines(), 1 do
		if getglobal("GameTooltipTextLeft"..i):IsVisible() and getglobal("GameTooltipTextLeft"..i):GetText() then a=a..getglobal("GameTooltipTextLeft"..i):GetText();end
		if getglobal("GameTooltipTextRight"..i):IsVisible() and getglobal("GameTooltipTextRight"..i):GetText() then a=a..getglobal("GameTooltipTextRight"..i):GetText();end
	end
	return a;
end

CZWOW_GameTooltip_OnUpdate=function()
	if CZWOW_EnableSpells or CZWOW_EnableInterface then
		local a=GetTooltipText();
		if a~=oldTooltipText then
			local name=GameTooltipTextLeft1:GetText();
			for i=1, GameTooltip:NumLines(), 1 do
				local text;
				local translate=nil;
				text=getglobal("GameTooltipTextLeft"..i):GetText();
				if CZWOW_EnableSpells then
					translate=SpellTranslate(text);
				end;
				if CZWOW_EnableInterface and CZWOW_Interface and CZWOW_Interface[text] then
					translate=CZWOW_Interface[text];
				end
				if translate then
					getglobal("GameTooltipTextLeft"..i):SetText(translate);
				end
			end
			local i;
			local s=10;
			for i=1, GameTooltip:NumLines(), 1 do
				s=s+getglobal("GameTooltipTextLeft"..i):GetHeight()+2;
			end
			GameTooltip:SetHeight(s+10);
			oldTooltipText=GetTooltipText();
		end
	end
end

CZWOW_OnLoad1=function(event)
end

local NPCTextTranslate=function(en)
	if CZWOW_EnableNPCs and type(CZWOW_NPCText_count)=="number" then
		en=trim(en);
		for i=1, CZWOW_NPCText_count, 1 do
			if type(getglobal("CZWOW_NPCText_"..i))=="table" and getglobal("CZWOW_NPCText_"..i)[en] then
				return prepare(getglobal("CZWOW_NPCText_"..i)[en])
			end
		end
	end
	return nil;
end

CZWOW_OnUpdate=function()
	if CZWOW_EnableSpells and ClassTrainerFrame and ClassTrainerFrame:IsVisible() and ClassTrainerGreetingText and ClassTrainerSkillDescription and (oldClassTrainerSkillDescription~=ClassTrainerSkillDescription:GetText() or oldClassTrainerGreetingText~=ClassTrainerGreetingText:GetText()) then
		oldClassTrainerSkillDescription=ClassTrainerSkillDescription:GetText();
		oldClassTrainerGreetingText=ClassTrainerGreetingText:GetText();
		if ClassTrainerGreetingText:GetText() then
			local cz=NPCTextTranslate(ClassTrainerGreetingText:GetText());
			if cz then ClassTrainerGreetingText:SetText(cz) end
		end
		if ClassTrainerSkillDescription:GetText() then
			local cz=SpellTranslate(ClassTrainerSkillDescription:GetText());
			if cz then ClassTrainerSkillDescription:SetText(cz) end
		end
	end;
end
old_QuestFrameDetailPanel_OnShow=QuestFrameDetailPanel_OnShow;
old_QuestLog_UpdateQuestDetails=QuestLog_UpdateQuestDetails;
old_QuestFrameProgressPanel_OnShow=QuestFrameProgressPanel_OnShow;
old_QuestFrameRewardPanel_OnShow=QuestFrameRewardPanel_OnShow;
old_ItemTextFrame_OnEvent=ItemTextFrame_OnEvent;
old_ChatFrame_OnEvent=ChatFrame_OnEvent;
--old_GossipFrameOptionsUpdate=GossipFrameOptionsUpdate;
old_GossipFrameUpdate=GossipFrameUpdate;

ChatFrame_OnEvent=function(event)
	if (event=="CHAT_MSG_MONSTER_SAY" or event=="CHAT_MSG_MONSTER_EMOTE") and CZWOW_EnableCreatures and type(CZWOW_Creature_count)=="number" then
		local en=trim(arg1);
		for i=1, CZWOW_Creature_count, 1 do
			if type(getglobal("CZWOW_Creature_"..i))=="table" and getglobal("CZWOW_Creature_"..i)[en] then
				arg1=prepare(getglobal("CZWOW_Creature_"..i)[en]);
			end
		end
	end
	old_ChatFrame_OnEvent(event);
end;

QuestFrameDetailPanel_OnShow=function()
	old_QuestFrameDetailPanel_OnShow();
	if CZWOW_EnableQuests and type(CZWOW_QuestObjective_count)=="number" and type(CZWOW_QuestDescription_count)=="number" then
		local questObjectives=trim(GetObjectiveText());
		local questDescription=trim(GetQuestText());
    --NEW:
		local questTitle=trim(GetTitleText());    
		for i=1, CZWOW_QuestTitle_count, 1 do
			if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[questTitle] then
				QuestTitleText:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
			end
		end
    
		for i=1, CZWOW_QuestObjective_count, 1 do
			if type(getglobal("CZWOW_QuestObjective_"..i))=="table" and getglobal("CZWOW_QuestObjective_"..i)[questObjectives] then
				QuestObjectiveText:SetText(prepare(getglobal("CZWOW_QuestObjective_"..i)[questObjectives]));
			end
		end
		for i=1, CZWOW_QuestDescription_count, 1 do
			if type(getglobal("CZWOW_QuestDescription_"..i))=="table" and getglobal("CZWOW_QuestDescription_"..i)[questDescription] then
				QuestDescription:SetText(prepare(getglobal("CZWOW_QuestDescription_"..i)[questDescription]));
			end
		end
	end;
end

QuestFrameProgressPanel_OnShow=function()
	old_QuestFrameProgressPanel_OnShow();
	if CZWOW_EnableQuests and type(CZWOW_QuestProgress_count)=="number" then
		local text=trim(GetProgressText());
		for i=1, CZWOW_QuestProgress_count, 1 do
			if  type(getglobal("CZWOW_QuestProgress_"..i))=="table" and getglobal("CZWOW_QuestProgress_"..i)[text] then
				QuestProgressText:SetText(prepare(getglobal("CZWOW_QuestProgress_"..i)[text]));
			end
		end
    --NEW:
		local questTitle=trim(GetTitleText());    
		for i=1, CZWOW_QuestTitle_count, 1 do
			if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[questTitle] then
				QuestProgressTitleText:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
			end
		end
    
	end;
end

QuestFrameRewardPanel_OnShow=function()
	old_QuestFrameRewardPanel_OnShow();
	if CZWOW_EnableQuests and type(CZWOW_QuestReward_count)=="number" then
		local text=trim(GetRewardText());
		for i=1, CZWOW_QuestReward_count, 1 do
			if type(getglobal("CZWOW_QuestReward_"..i))=="table" and getglobal("CZWOW_QuestReward_"..i)[text] then
				QuestRewardText:SetText(prepare(getglobal("CZWOW_QuestReward_"..i)[text]));
			end
		end
    --NEW:
		local questTitle=trim(GetTitleText());    
		for i=1, CZWOW_QuestTitle_count, 1 do
			if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[questTitle] then
				QuestRewardTitleText:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
			end
		end
    
	end;
end

ItemTextFrame_OnEvent=function(event)
	old_ItemTextFrame_OnEvent(event);
	if event=="ITEM_TEXT_READY" and CZWOW_EnableBooks and type(CZWOW_BookPage_count)=="number" then
		local en=trim(ItemTextGetText());
		for i=1, CZWOW_BookPage_count, 1 do
			if type(getglobal("CZWOW_BookPage_"..i))=="table" and getglobal("CZWOW_BookPage_"..i)[en] then
				local creator=ItemTextGetCreator();
				if ( creator ) then
					creator=strchar(10, 10)..ITEM_TEXT_FROM..strchar(10)..creator..strchar(10, 10);
					ItemTextPageText:SetText(strchar(10)..prepare(getglobal("CZWOW_BookPage_"..i)[en])..creator);
				else
					ItemTextPageText:SetText(strchar(10)..prepare(getglobal("CZWOW_BookPage_"..i)[en])..strchar(10, 10));
				end
			end
		end
	end
end;

--NEW:delete
GossipFrameOptionsUpdate_zaloha=function(par)
if (par ~= nil) then
    DEFAULT_CHAT_FRAME:AddMessage(par);
    --	if select("#", par)>0 then
--		old_GossipFrameOptionsUpdate(par);
        
	local titleButton;
	local titleIndex = 1;
	for i=1, arg.n, 2 do
		if ( GossipFrame.buttonIndex > NUMGOSSIPBUTTONS ) then
			message("This NPC has too many quests and/or gossip options.");
		end
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:SetText(arg[i]);
		GossipResize(titleButton);
		titleButton:SetID(titleIndex);
		titleButton.type="Gossip";
		getglobal(titleButton:GetName() .. "GossipIcon"):SetTexture("Interface\\GossipFrame\\" .. arg[i+1] .. "GossipIcon");
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
		titleIndex = titleIndex + 1;
		titleButton:Show();
	end

		if CZWOW_EnableNPCs and type(CZWOW_NPCAction_count)=="number" then
			for i=1, GossipFrame.buttonIndex, 1 do
				titleButton=getglobal("GossipTitleButton" .. i);
        titleButton:SetText("test");
				local en=trim(titleButton:GetText());
				for i=1, CZWOW_NPCAction_count, 1 do
					if type(getglobal("CZWOW_NPCAction_"..i))=="table" and getglobal("CZWOW_NPCAction_"..i)[en] then
						titleButton:SetText(prepare(getglobal("CZWOW_NPCAction_"..i)[en]));
						GossipResize(titleButton);
					end
				end
			end
		end
--	end
end
end

GossipFrameUpdate=function()
	old_GossipFrameUpdate();
	local cz=NPCTextTranslate(GossipGreetingText:GetText());
	if cz then GossipGreetingText:SetText(cz) end
  
  
  --NEW:
		for i=1, GossipFrame.buttonIndex, 1 do
				titleButton=getglobal("GossipTitleButton" .. i);
				local en=trim(titleButton:GetText());
				for i=1, CZWOW_NPCAction_count, 1 do
					if type(getglobal("CZWOW_NPCAction_"..i))=="table" and getglobal("CZWOW_NPCAction_"..i)[en] then
						titleButton:SetText(prepare(getglobal("CZWOW_NPCAction_"..i)[en]));
						GossipResize(titleButton);
					end
				end
    		for i=1, CZWOW_QuestTitle_count, 1 do
		    	if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[en] then
  				  titleButton:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[en]));
			    end
        end
		end
end;

QuestLog_UpdateQuestDetails=function()
	old_QuestLog_UpdateQuestDetails();
	if CZWOW_EnableQuests and type(CZWOW_QuestObjective_count)=="number" and type(CZWOW_QuestDescription_count)=="number" then
		local questDescription;
		local questObjectives;
		questDescription, questObjectives=GetQuestLogQuestText();
		questObjectives=trim(questObjectives);
		questDescription=trim(questDescription);
		for i=1, CZWOW_QuestObjective_count, 1 do
			if type(getglobal("CZWOW_QuestObjective_"..i))=="table" and getglobal("CZWOW_QuestObjective_"..i)[questObjectives] then
				QuestLogObjectivesText:SetText(prepare(getglobal("CZWOW_QuestObjective_"..i)[questObjectives]));
			end
		end
		for i=1, CZWOW_QuestDescription_count, 1 do
			if type(getglobal("CZWOW_QuestDescription_"..i))=="table" and getglobal("CZWOW_QuestDescription_"..i)[questDescription] then
				QuestLogQuestDescription:SetText(prepare(getglobal("CZWOW_QuestDescription_"..i)[questDescription]));
			end
		end
    --NEW:
    local questID = GetQuestLogSelection();
		local questTitle=trim(GetQuestLogTitle(questID));   
		for i=1, CZWOW_QuestTitle_count, 1 do
			if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[questTitle] then
				QuestLogQuestTitle:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
			--	QuestLogTitle:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
			end
		end
    
	end;
end


--NEW:
local old_QuestLog_Update
old_QuestLog_Update = QuestLog_Update;
QuestLog_Update=function()
  old_QuestLog_Update();
	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questHighlight, questCheck;
	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, color;
	local numPartyMembers, partyMembersOnQuest, tempWidth, textWidth;
	for j=1, QUESTS_DISPLAYED, 1 do
		questIndex = j + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		questLogTitle = getglobal("QuestLogTitle"..questIndex);
    if (questLogTitle ~= nil) then
    
    questLogTitle:SetID(questIndex);
		questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questIndex);
		local questTitle=trim(questLogTitleText);    
		for i=1, CZWOW_QuestTitle_count, 1 do
			if type(getglobal("CZWOW_QuestTitle_"..i))=="table" and getglobal("CZWOW_QuestTitle_"..i)[questTitle] then
				if questLogTitle then  
         -- QuestLogTitle:SetText(prepare(getglobal("CZWOW_QuestTitle_"..i)[questTitle]));
        end
			end
		end
    end
  end  
end

