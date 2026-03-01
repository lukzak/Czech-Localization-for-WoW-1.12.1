-- Handle character list loading for autologin system
function Autologin_OnCharactersLoad()
    Autologin_Load()
    local selected = Autologin_Table[Autologin_SelectedIdx]
    
    if not selected then
        AutologinSaveCharacterButton:Hide()
        return
    end

    AutologinSaveCharacterButton:Show()
    
    -- If no character is saved, don't auto-select
    if selected.character == '-' then 
        return 
    end

    -- Auto-select and enter world with the saved character
    -- Note: Using character index instead of name for reliability
    SelectCharacter(tonumber(selected.character))
    EnterWorld()
end

-- Handle entering world with autologin character saving
function Autologin_EnterWorld()
    -- Update autologin character if save checkbox is checked
    if Autologin_SelectedIdx and AutologinSaveCharacterButton:GetChecked() then
        -- Save the currently selected character index
        Autologin_Table[Autologin_SelectedIdx].character = CharacterSelect.selectedIndex
        Autologin_Save()
    end

    EnterWorld()
end

-- ==================================================
-- Vanilla WoW Character Select Code
-- ==================================================

-- Character rotation and selection constants
CHARACTER_SELECT_ROTATION_START_X = nil
CHARACTER_SELECT_INITIAL_FACING = nil
CHARACTER_ROTATION_CONSTANT = 0.6

-- Character display limits
MAX_CHARACTERS_DISPLAYED = 10
MAX_CHARACTERS_PER_REALM = 10

-- Initialize the character select frame
function CharacterSelect_OnLoad()
    this:SetSequence(0)
    this:SetCamera(0)

    -- Initialize character selection state
    this.createIndex = 0
    this.selectedIndex = 0
    this.selectLast = 0
    this.currentModel = ""
    
    -- Register for character-related events
    this:RegisterEvent("ADDON_LIST_UPDATE")
    this:RegisterEvent("CHARACTER_LIST_UPDATE")
    this:RegisterEvent("UPDATE_SELECTED_CHARACTER")
    this:RegisterEvent("SELECT_LAST_CHARACTER")
    this:RegisterEvent("SELECT_FIRST_CHARACTER")
    this:RegisterEvent("SUGGEST_REALM")
    this:RegisterEvent("FORCE_RENAME_CHARACTER")

    -- Set default character model and lighting
    CharacterSelect:SetModel("Interface\\Glues\\Models\\UI_Orc\\UI_Orc.mdx")

    -- Apply fog settings for the Orc model
    local fogInfo = CharModelFogInfo["ORC"]
    CharacterSelect:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b)
    CharacterSelect:SetFogNear(0)
    CharacterSelect:SetFogFar(fogInfo.far)

    SetCharSelectModelFrame("CharacterSelect")
    
    -- Character lighting setup (commented out in original)
    -- CharSelectModel:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8)

    -- Apply backdrop colors to character frame
    local backdropColor = DEFAULT_TOOLTIP_COLOR
    CharacterSelectCharacterFrame:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    CharacterSelectCharacterFrame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6], 0.85)
end

-- Handle showing the character select screen
function CharacterSelect_OnShow()
    CurrentGlueMusic = "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3"

    UpdateAddonButton()

    -- Display server information
    local serverName, isPVP, isRP = GetServerName()
    local connected = IsConnectedToServer()
    local serverType = ""
    
    if serverName then
        -- Add disconnection status if not connected
        if not connected then
            serverName = serverName .. "\n(" .. TEXT(SERVER_DOWN) .. ")"
        end
        
        -- Determine server type label
        if isPVP then
            if isRP then
                serverType = RPPVP_PARENTHESES
            else
                serverType = PVP_PARENTHESES
            end
        elseif isRP then
            serverType = RP_PARENTHESES
        end
        
        CharSelectRealmName:SetText(serverName .. " " .. serverType)
        CharSelectRealmName:Show()
    else
        CharSelectRealmName:Hide()
    end

    -- Update character list based on connection status
    if connected then
        GetCharacterListUpdate()
    else
        UpdateCharacterList()
    end

    -- Handle gameroom billing display (Korea and China only)
    if SHOW_GAMEROOM_BILLING_FRAME then
        local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan()
        
        if paymentPlan == 0 then
            -- No payment plan
            GameRoomBillingFrame:Hide()
        else
            local billingTimeLeft = GetBillingTimeRemaining()
            local billingText = getglobal("BILLING_TEXT" .. paymentPlan)
            
            -- Customize billing text based on payment plan
            if paymentPlan == 1 then
                -- Recurring account
                billingTimeLeft = ceil(billingTimeLeft / (60 * 24))
                if billingTimeLeft == 1 then
                    billingText = BILLING_TIME_LEFT_LAST_DAY
                end
            elseif paymentPlan == 2 then
                -- Free account
                if billingTimeLeft < (24 * 60) then
                    local timeText = billingTimeLeft .. " " .. GetText("MINUTES_ABBR", nil, billingTimeLeft)
                    billingText = format(BILLING_FREE_TIME_EXPIRE, timeText)
                end
            elseif paymentPlan == 3 then
                -- Fixed but not recurring
                if isGameRoom == 1 then
                    if billingTimeLeft <= 30 then
                        billingText = BILLING_GAMEROOM_EXPIRE
                    else
                        billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1))
                    end
                else
                    -- Personal fixed plan
                    if billingTimeLeft < (24 * 60) then
                        billingText = BILLING_FIXED_LASTDAY
                    else
                        billingText = format(billingText, MinutesToTime(billingTimeLeft))
                    end
                end
            elseif paymentPlan == 4 then
                -- Usage plan
                if isGameRoom == 1 then
                    -- Game room usage plan
                    if billingTimeLeft <= 600 then
                        billingText = BILLING_GAMEROOM_EXPIRE
                    else
                        billingText = BILLING_IGR_USAGE
                    end
                else
                    -- Personal usage plan
                    if billingTimeLeft <= 30 then
                        billingText = BILLING_TIME_LEFT_30_MINS
                    else
                        billingText = format(billingText, billingTimeLeft)
                    end
                end
            end
            
            -- Add fallback payment method notice if applicable
            if hasFallBackBillingMethod == 1 then
                billingText = billingText .. "\n\n" .. BILLING_HAS_FALLBACK_PAYMENT
            end
            
            GameRoomBillingFrameText:SetText(billingText)
            GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26)
            GameRoomBillingFrame:Show()
        end
    end

    -- Fade in the character select UI
    GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)
end

-- Handle hiding the character select screen
function CharacterSelect_OnHide()
    CharacterDeleteDialog:Hide()
    CharacterRenameDialog:Hide()
end

-- Handle keyboard input on character select screen
function CharacterSelect_OnKeyDown()
    if arg1 == "ESCAPE" then
        CharacterSelect_Exit()
    elseif arg1 == "ENTER" then
        CharacterSelect_EnterWorld()
    elseif arg1 == "PRINTSCREEN" then
        Screenshot()
    elseif arg1 == "UP" or arg1 == "LEFT" then
        -- Navigate to previous character
        local numChars = GetNumCharacters()
        if numChars > 1 then
            if this.selectedIndex > 1 then
                CharacterSelect_SelectCharacter(this.selectedIndex - 1)
            else
                CharacterSelect_SelectCharacter(numChars)
            end
        end
    elseif arg1 == "DOWN" or arg1 == "RIGHT" then
        -- Navigate to next character
        local numChars = GetNumCharacters()
        if numChars > 1 then
            if this.selectedIndex < GetNumCharacters() then
                CharacterSelect_SelectCharacter(this.selectedIndex + 1)
            else
                CharacterSelect_SelectCharacter(1)
            end
        end
    end
end

-- Handle various character select events
function CharacterSelect_OnEvent()
    if event == "ADDON_LIST_UPDATE" then
        UpdateAddonButton()
    elseif event == "CHARACTER_LIST_UPDATE" then
        UpdateCharacterList()
        CharSelectCharacterName:SetText(GetCharacterInfo(this.selectedIndex))
        
        -- Trigger autologin character loading
        Autologin_OnCharactersLoad()
    elseif event == "UPDATE_SELECTED_CHARACTER" then
        if arg1 == 0 then
            CharSelectCharacterName:SetText("")
        else
            CharSelectCharacterName:SetText(GetCharacterInfo(arg1))
            this.selectedIndex = arg1
        end
        UpdateCharacterSelection()
    elseif event == "SELECT_LAST_CHARACTER" then
        this.selectLast = 1
    elseif event == "SELECT_FIRST_CHARACTER" then
        CharacterSelect_SelectCharacter(1, 1)
    elseif event == "SUGGEST_REALM" then
        local name = GetRealmInfo(arg1, arg2)
        RealmWizard.suggestedRealmName = name
        RealmWizard.suggestedCategory = arg1
        RealmWizard.suggestedID = arg2
        GlueDialog_Show("SUGGEST_REALM")
    elseif event == "FORCE_RENAME_CHARACTER" then
        CharacterRenameDialog:Show()
        CharacterRenameText1:SetText(getglobal(arg1))
    end
end

-- Update character model animation
function CharacterSelect_UpdateModel()
    UpdateSelectionCustomizationScene()
    this:AdvanceTime()
end

-- Update visual selection highlight on character buttons
function UpdateCharacterSelection()
    -- Clear all character button highlights
    for i = 1, MAX_CHARACTERS_DISPLAYED do
        getglobal("CharSelectCharacterButton" .. i):UnlockHighlight()
    end

    -- Highlight the selected character button
    local index = this.selectedIndex
    if index > 0 and index <= MAX_CHARACTERS_DISPLAYED then
        getglobal("CharSelectCharacterButton" .. index):LockHighlight()
    end
end

-- Update the display of all character buttons
function UpdateCharacterList()
    local numChars = GetNumCharacters()
    local buttonIndex = 1
    
    -- Populate character buttons with character information
    for i = 1, numChars do
        local name, race, class, level, zone, fileString, gender, ghost = GetCharacterInfo(i)
        
        -- Convert gender number to string
        if gender == 0 then
            gender = "MALE"
        else
            gender = "FEMALE"
        end
        
        local button = getglobal("CharSelectCharacterButton" .. buttonIndex)
        
        if not name then
            button:SetText("ERROR - Tell Jeremy")
        else
            if not zone then 
                zone = "" 
            end
            
            -- Set character name
            getglobal("CharSelectCharacterButton" .. buttonIndex .. "ButtonTextName"):SetText(name)
            
            -- Set character info (level, class, ghost status)
            local infoText
            if ghost then
                infoText = format(TEXT(CHARACTER_SELECT_INFO_GHOST), level, class)
            else
                infoText = format(TEXT(CHARACTER_SELECT_INFO), level, class)
            end
            getglobal("CharSelectCharacterButton" .. buttonIndex .. "ButtonTextInfo"):SetText(infoText)
            
            -- Set character location
            getglobal("CharSelectCharacterButton" .. buttonIndex .. "ButtonTextLocation"):SetText(zone)
        end
        
        button:Show()
        buttonIndex = buttonIndex + 1
        
        if buttonIndex > MAX_CHARACTERS_DISPLAYED then 
            break 
        end
    end

    -- Enable/disable buttons based on character availability
    if numChars == 0 then
        CharacterSelectDeleteButton:Disable()
        CharSelectEnterWorldButton:Disable()
    else
        CharacterSelectDeleteButton:Enable()
        CharSelectEnterWorldButton:Enable()
    end

    -- Handle character creation button placement
    CharacterSelect.createIndex = 0
    CharSelectCreateCharacterButton:Hide()

    local connected = IsConnectedToServer()
    for i = buttonIndex, MAX_CHARACTERS_DISPLAYED do
        local button = getglobal("CharSelectCharacterButton" .. i)
        
        -- Show create character button if we have room and are connected
        if CharacterSelect.createIndex == 0 and numChars < MAX_CHARACTERS_PER_REALM then
            CharacterSelect.createIndex = i
            if connected then
                CharSelectCreateCharacterButton:SetID(i)
                CharSelectCreateCharacterButton:Show()
            end
        end
        
        button:Hide()
    end

    -- Handle character selection state
    if numChars == 0 then
        CharacterSelect.selectedIndex = 0
        return
    end

    -- Select last character if requested
    if CharacterSelect.selectLast == 1 then
        CharacterSelect.selectLast = 0
        CharacterSelect_SelectCharacter(numChars, 1)
        return
    end

    -- Ensure we have a valid selection
    if CharacterSelect.selectedIndex == 0 or CharacterSelect.selectedIndex > numChars then
        CharacterSelect.selectedIndex = 1
    end
    
    CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1)
end

-- Handle character input (currently unused)
function CharacterSelect_OnChar() end

-- Handle character button single click
function CharacterSelectButton_OnClick()
    local id = this:GetID()
    if id ~= CharacterSelect.selectedIndex then
        CharacterSelect_SelectCharacter(id)
    end
end

-- Handle character button double click
function CharacterSelectButton_OnDoubleClick()
    local id = this:GetID()
    if id ~= CharacterSelect.selectedIndex then
        CharacterSelect_SelectCharacter(id)
    end
    CharacterSelect_EnterWorld()
end

-- Resize tab buttons based on text width
function CharacterSelect_TabResize()
    local buttonMiddle = getglobal(this:GetName() .. "Middle")
    local buttonMiddleDisabled = getglobal(this:GetName() .. "MiddleDisabled")
    local width = this:GetTextWidth() - 8
    local leftWidth = getglobal(this:GetName() .. "Left"):GetWidth()
    
    buttonMiddle:SetWidth(width)
    buttonMiddleDisabled:SetWidth(width)
    this:SetWidth(width + (2 * leftWidth))
end

-- Select a character or show character creation
function CharacterSelect_SelectCharacter(id, noCreate)
    if id == CharacterSelect.createIndex then
        if not noCreate then
            PlaySound("gsCharacterSelectionCreateNew")
            SetGlueScreen("charcreate")
        end
    else
        local name, race, class, level, zone, fileString = GetCharacterInfo(id)

        -- Update background model if character model changed
        if fileString ~= CharacterSelect.currentModel then
            CharacterSelect.currentModel = fileString
            SetBackgroundModel(CharacterSelect, fileString)
        end
        
        SelectCharacter(id)
    end
end

-- Show character deletion confirmation dialog
function CharacterDeleteDialog_OnShow()
    local name, race, class, level = GetCharacterInfo(CharacterSelect.selectedIndex)
    local deleteText = format(TEXT(CONFIRM_CHAR_DELETE), name, level, class)
    CharacterDeleteText1:SetText(deleteText)
    
    -- Calculate dialog height based on content
    local totalHeight = 16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 
                       23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16
    CharacterDeleteBackground:SetHeight(totalHeight)
    CharacterDeleteButton1:Disable()
end

-- Enter the world with selected character
function CharacterSelect_EnterWorld()
    PlaySound("gsCharacterSelectionEnterWorld")
    Autologin_EnterWorld()
end

-- Exit character select and return to login
function CharacterSelect_Exit()
    PlaySound("gsCharacterSelectionExit")
    DisconnectFromServer()
    SetGlueScreen("login")
end

-- Open account options (placeholder)
function CharacterSelect_AccountOptions()
    PlaySound("gsCharacterSelectionAcctOptions")
end

-- Open technical support website
function CharacterSelect_TechSupport()
    PlaySound("gsCharacterSelectionAcctOptions")
    LaunchURL(TEXT(TECH_SUPPORT_URL))
end

-- Show character deletion dialog
function CharacterSelect_Delete()
    PlaySound("gsCharacterSelectionDelCharacter")
    if CharacterSelect.selectedIndex > 0 then 
        CharacterDeleteDialog:Show() 
    end
end

-- Show realm selection screen
function CharacterSelect_ChangeRealm()
    PlaySound("gsLoginChangeRealmSelect")
    RequestRealmList(1)
end

-- Handle mouse down for character rotation
function CharacterSelectFrame_OnMouseDown(button)
    if button == "LeftButton" then
        CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition()
        CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing()
    end
end

-- Handle mouse up for character rotation
function CharacterSelectFrame_OnMouseUp(button)
    if button == "LeftButton" then 
        CHARACTER_SELECT_ROTATION_START_X = nil 
    end
end

-- Handle character rotation during mouse drag
function CharacterSelectFrame_OnUpdate()
    if CHARACTER_SELECT_ROTATION_START_X then
        local x = GetCursorPosition()
        local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT
        CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition()
        SetCharacterSelectFacing(GetCharacterSelectFacing() + diff)
    end
end

-- Handle right rotation button
function CharacterSelectRotateRight_OnUpdate()
    if this:GetButtonState() == "PUSHED" then
        SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT)
    end
end

-- Handle left rotation button
function CharacterSelectRotateLeft_OnUpdate()
    if this:GetButtonState() == "PUSHED" then
        SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT)
    end
end

-- Open account management website
function CharacterSelect_ManageAccount()
    PlaySound("gsCharacterSelectionAcctOptions")
    LaunchURL(TEXT(AUTH_NO_TIME_URL))
end
