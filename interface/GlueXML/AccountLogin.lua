-- Autologin Table and State Variables
Autologin_Table = {}
Autologin_SelectedIdx = nil
Autologin_CurrentPage = 0
Autologin_PageSize = 4
Autologin_LimitReached = false

-- Load saved account information from the saved variables
function Autologin_Load()
    Autologin_Table = {}
    local val = GetSavedAccountName()
    
    -- Parse saved account string format: "name password character;"
    for n, p, c in string.gfind(val, "(%S+) (%S+) *(%d*);") do
        if c == "" then 
            c = "-" 
        end

        -- Decompress duplicate passwords (referenced by ~index)
        if string.find(p, "~%d") == 1 then
            local refIndex = tonumber(string.sub(p, 2, 3))
            p = Autologin_Table[refIndex].password
        end

        table.insert(Autologin_Table, { 
            name = n, 
            password = p, 
            character = c 
        })
    end
end

-- Save account name and password to the table and serialize to saved variables
function Autologin_Save(name, password)
    -- Add or update name and password in table
    if name ~= nil and name ~= "" and password ~= nil and password ~= "" then
        local exists = false
        for i = 1, table.getn(Autologin_Table) do
            if Autologin_Table[i].name == name then
                exists = true
                Autologin_Table[i].password = password
                break
            end
        end
        
        if not exists then
            table.insert(Autologin_Table, { 
                name = name, 
                password = password, 
                character = "-" 
            })
        end
    end

    -- If table is empty, reset saved variable
    if table.getn(Autologin_Table) == 0 then
        SetSavedAccountName('')
        return
    end

    -- Serialize table to saved variable with password compression
    local savedVar = ""
    for i = 1, table.getn(Autologin_Table) do
        local record = Autologin_Table[i]

        -- Compress duplicate passwords by referencing earlier entries
        local passwordToSave = record.password
        for j = 1, i - 1 do
            if Autologin_Table[j].password == record.password then 
                passwordToSave = '~' .. j 
                break
            end
        end

        savedVar = savedVar .. record.name .. ' ' .. passwordToSave
        if record.character == "-" then
            savedVar = savedVar .. ";"
        else
            savedVar = savedVar .. ' ' .. record.character .. ';'
        end
    end

    -- Check if we're approaching the 128 character limit
    Autologin_LimitReached = string.len(savedVar) > 128
    SetSavedAccountName(savedVar)
end

-- Select an account from the current page and populate login fields
function Autologin_SelectAccount(idx)
    local tableIndex = Autologin_CurrentPage * Autologin_PageSize + idx
    local account = Autologin_Table[tableIndex]
    
    AccountLoginAccountEdit:SetText(account.name)
    AccountLoginPasswordEdit:SetText(account.password)
end

-- Update UI when account name changes in the input field
function Autologin_OnNameUpdate(name)
    Autologin_SelectedIdx = nil
    
    -- Find the account in our table
    for i = 1, table.getn(Autologin_Table) do
        if Autologin_Table[i].name == name then 
            Autologin_SelectedIdx = i
            break
        end
    end
    
    -- Update current page to show the selected account
    if Autologin_SelectedIdx then
        Autologin_CurrentPage = math.floor((Autologin_SelectedIdx - 1) / Autologin_PageSize)
    end
    
    Autologin_UpdateUI()
end

-- Update the UI display of account buttons and pagination
function Autologin_UpdateUI()
    local skip = Autologin_CurrentPage * Autologin_PageSize
    
    -- Update each account button on the current page
    for i = 1, Autologin_PageSize do
        local button = getglobal("AutologinAccountButton" .. i)
        button:UnlockHighlight()
        
        local tableIndex = skip + i
        if tableIndex > table.getn(Autologin_Table) then
            button:Hide()
        else
            local record = Autologin_Table[tableIndex]
            button:Show()
            
            -- Set account name
            getglobal("AutologinAccountButton" .. i .. "ButtonTextName"):SetText(record.name)
            
            -- Set masked password display
            local maskedPassword = 'Password: ' .. string.rep("*", string.len(record.password))
            getglobal("AutologinAccountButton" .. i .. "ButtonTextPassword"):SetText(maskedPassword)

            -- Set character info
            if record.character == '-' then
                getglobal("AutologinAccountButton" .. i .. "ButtonTextCharacter"):SetText("")
            else
                getglobal("AutologinAccountButton" .. i .. "ButtonTextCharacter"):SetText('Character: ' .. record.character)
            end

            -- Highlight the selected account
            if Autologin_SelectedIdx == tableIndex then
                button:LockHighlight()
            end
        end
    end

    -- Show/hide size warning if approaching character limit
    local sizeWarning = getglobal("AutologinSizeWarning")
    if Autologin_LimitReached then
        sizeWarning:Show()
    else
        sizeWarning:Hide()
    end
end

-- Handle login button click - save credentials and proceed with login
function Autologin_OnLogin()
    local name = AccountLoginAccountEdit:GetText()
    local password = AccountLoginPasswordEdit:GetText()

    -- Save the entered credentials to autologin
    Autologin_Save(name, password)
    Autologin_OnNameUpdate(name)
    
    -- Proceed with the actual login
    DefaultServerLogin(name, password)
    
    -- Refresh UI after login attempt
    Autologin_Load()
    Autologin_UpdateUI()
end

-- Account button click handler
function AutologinAccountButton_OnClick() 
    Autologin_SelectAccount(this:GetID()) 
end

-- Account button double-click handler - select and login immediately
function AutologinAccountButton_OnDoubleClick()
    Autologin_SelectAccount(this:GetID())
    AccountLogin_Login()
end

-- Remove the currently selected account from the list
function Autologin_RemoveAccount()
    if not Autologin_SelectedIdx then 
        return 
    end

    table.remove(Autologin_Table, Autologin_SelectedIdx)
    Autologin_Save()
    
    -- Clear the input fields
    AccountLoginAccountEdit:SetText("")
    AccountLoginPasswordEdit:SetText("")

    -- Adjust current page if we removed the last item on the page
    local totalAccounts = table.getn(Autologin_Table)
    if Autologin_CurrentPage > 0 and Autologin_CurrentPage * Autologin_PageSize > totalAccounts - 1 then
        Autologin_CurrentPage = Autologin_CurrentPage - 1
    end

    Autologin_UpdateUI()
end

-- Navigate to next page of accounts
function Autologin_NextPage()
    local totalAccounts = table.getn(Autologin_Table)
    if (Autologin_CurrentPage + 1) * Autologin_PageSize > totalAccounts - 1 then 
        return 
    end
    
    Autologin_CurrentPage = Autologin_CurrentPage + 1
    Autologin_UpdateUI()
end

-- Navigate to previous page of accounts
function Autologin_PrevPage()
    if Autologin_CurrentPage == 0 then 
        return 
    end
    
    Autologin_CurrentPage = Autologin_CurrentPage - 1
    Autologin_UpdateUI()
end

-- ==================================================
-- Vanilla WoW Account Login Code
-- ==================================================

FADE_IN_TIME = 2
DEFAULT_TOOLTIP_COLOR = { 0.8, 0.8, 0.8, 0.09, 0.09, 0.09 }
MAX_PIN_LENGTH = 10

-- Initialize the account login frame
function AccountLogin_OnLoad()
    this:SetSequence(0)
    this:SetCamera(0)

    TOSFrame.noticeType = "EULA"

    this:RegisterEvent("SHOW_SERVER_ALERT")
    this:RegisterEvent("SHOW_SURVEY_NOTIFICATION")

    -- Set version information display
    local versionType, buildType, version, internalVersion, date = GetBuildInfo()
    local versionText = format(TEXT(VERSION_TEMPLATE), versionType, version, internalVersion, buildType, date)
    AccountLoginVersion:SetText(versionText)

    -- Color edit box backdrops with default tooltip colors
    local backdropColor = DEFAULT_TOOLTIP_COLOR
    AccountLoginAccountEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    AccountLoginAccountEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
    AccountLoginPasswordEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    AccountLoginPasswordEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
    VirtualKeypadText:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    VirtualKeypadText:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
end

-- Handle showing the account login screen
function AccountLogin_OnShow()
    CurrentGlueMusic = "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3"

    -- Try to show the EULA or Terms of Service
    AccountLogin_ShowUserAgreements()

    -- Display server name and status
    local serverName = GetServerName()
    if serverName then
        AccountLoginRealmName:SetText(serverName)
    else
        AccountLoginRealmName:Hide()
    end

    -- Initialize autologin system
    Autologin_Load()
    if table.getn(Autologin_Table) ~= 0 then 
        Autologin_SelectAccount(1) 
    end
    Autologin_UpdateUI()

    -- Set focus to appropriate field
    if GetSavedAccountName() == "" then
        AccountLogin_FocusAccountName()
    else
        AccountLogin_FocusPassword()
    end
end

-- Set focus to password field
function AccountLogin_FocusPassword() 
    AccountLoginPasswordEdit:SetFocus() 
end

-- Set focus to account name field
function AccountLogin_FocusAccountName() 
    AccountLoginAccountEdit:SetFocus() 
end

-- Handle character input (currently unused)
function AccountLogin_OnChar() end

-- Handle key press events
function AccountLogin_OnKeyDown()
    if arg1 == "ESCAPE" then
        if ConnectionHelpFrame:IsVisible() then
            ConnectionHelpFrame:Hide()
            AccountLoginUI:Show()
        elseif SurveyNotificationFrame:IsVisible() then
            -- Do nothing for survey notification
        else
            AccountLogin_Exit()
        end
    elseif arg1 == "ENTER" then
        if not TOSAccepted() then
            return
        elseif TOSFrame:IsVisible() or ConnectionHelpFrame:IsVisible() then
            return
        elseif SurveyNotificationFrame:IsVisible() then
            AccountLogin_SurveyNotificationDone(1)
        else
            AccountLogin_Login()
        end
    elseif arg1 == "PRINTSCREEN" then
        Screenshot()
    end
end

-- Handle various events
function AccountLogin_OnEvent(event)
    if event == "SHOW_SERVER_ALERT" then
        ServerAlertText:SetText(arg1)
        ServerAlertScrollFrame:UpdateScrollChildRect()
        ServerAlertFrame:Show()
    elseif event == "SHOW_SURVEY_NOTIFICATION" then
        AccountLogin_ShowSurveyNotification()
    end
end

-- Handle login button click
function AccountLogin_Login()
    PlaySound("gsLogin")
    Autologin_OnLogin()
end

-- Open account management website
function AccountLogin_ManageAccount()
    PlaySound("gsLoginNewAccount")
    LaunchURL(AUTH_NO_TIME_URL)
end

-- Open community website
function AccountLogin_LaunchCommunitySite()
    PlaySound("gsLoginNewAccount")
    LaunchURL(COMMUNITY_URL)
end

-- Show credits screen
function AccountLogin_Credits()
    if not GlueDialog:IsVisible() then
        PlaySound("gsTitleCredits")
        SetGlueScreen("credits")
    end
end

-- Show cinematics screen
function AccountLogin_Cinematics()
    if not GlueDialog:IsVisible() then
        PlaySound("gsTitleIntroMovie")
        SetGlueScreen("movie")
    end
end

-- Open options menu
function AccountLogin_Options() 
    PlaySound("gsTitleOptions") 
end

-- Exit the game
function AccountLogin_Exit()
    PlaySound("gsTitleQuit")
    QuitGame()
end

-- Show survey notification dialog
function AccountLogin_ShowSurveyNotification()
    GlueDialog:Hide()
    AccountLoginUI:Hide()
    SurveyNotificationAccept:Enable()
    SurveyNotificationDecline:Enable()
    SurveyNotificationFrame:Show()
end

-- Handle survey notification response
function AccountLogin_SurveyNotificationDone(accepted)
    SurveyNotificationFrame:Hide()
    SurveyNotificationAccept:Disable()
    SurveyNotificationDecline:Disable()
    SurveyNotificationDone(accepted)
    AccountLoginUI:Show()
end

-- Show appropriate user agreements (EULA, TOS, etc.)
function AccountLogin_ShowUserAgreements()
    -- Hide all agreement scroll frames initially
    TOSScrollFrame:Hide()
    EULAScrollFrame:Hide()
    ScanningScrollFrame:Hide()
    ContestScrollFrame:Hide()
    TOSText:Hide()
    EULAText:Hide()
    ScanningText:Hide()
    
    -- Check which agreements need to be shown in order of priority
    if not EULAAccepted() then
        if ShowEULANotice() then
            TOSNotice:SetText(EULA_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "EULA"
        TOSFrameTitle:SetText(EULA_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth() + 310)
        EULAScrollFrame:Show()
        EULAText:Show()
        TOSFrame:Show()
    elseif not TOSAccepted() then
        if ShowTOSNotice() then
            TOSNotice:SetText(TOS_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "TOS"
        TOSFrameTitle:SetText(TOS_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth() + 310)
        TOSScrollFrame:Show()
        TOSText:Show()
        TOSFrame:Show()
    elseif not ScanningAccepted() and SHOW_SCANNING_AGREEMENT then
        if ShowScanningNotice() then
            TOSNotice:SetText(SCANNING_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "SCAN"
        TOSFrameTitle:SetText(SCAN_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth() + 310)
        ScanningScrollFrame:Show()
        ScanningText:Show()
        TOSFrame:Show()
    elseif not ContestAccepted() and SHOW_CONTEST_AGREEMENT then
        if ShowContestNotice() then
            TOSNotice:SetText(CONTEST_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "CONTEST"
        TOSFrameTitle:SetText(CONTEST_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth() + 310)
        ContestScrollFrame:Show()
        ContestText:Show()
        TOSFrame:Show()
    else
        -- All agreements accepted, show main login UI
        AccountLoginUI:Show()
        TOSFrame:Hide()
    end
end

-- ==================================================
-- Virtual Keypad Functions (for additional security)
-- ==================================================

local buttonText = {}

-- Handle virtual keypad events
function VirtualKeypadFrame_OnEvent(event)
    if event == "PLAYER_ENTER_PIN" then
        -- Store the randomized button text for each keypad button
        for i = 1, 10 do
            buttonText[i] = getglobal("arg" .. i)
        end
    end
    
    -- Randomize keypad position to prevent location-based hacking
    local xPadding = 5
    local yPadding = 10
    local maxX = GlueParent:GetWidth() - VirtualKeypadFrame:GetWidth() - xPadding
    local maxY = GlueParent:GetHeight() - VirtualKeypadFrame:GetHeight() - yPadding
    local xPos = random(xPadding, maxX)
    local yPos = random(yPadding, maxY)
    
    -- Position is commented out in original code
    --VirtualKeypadFrame:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", xPos, -yPos)

    VirtualKeypadFrame:Show()
    VirtualKeypad_UpdateButtons()
end

-- Handle virtual keypad button clicks
function VirtualKeypadButton_OnClick()
    local currentText = VirtualKeypadText:GetText()
    if not currentText then
        currentText = ""
    end
    
    -- Append the button ID to the PIN
    VirtualKeypadFrame.PIN = VirtualKeypadFrame.PIN .. this:GetID()
    VirtualKeypadText:SetText(VirtualKeypadFrame.PIN)
    VirtualKeypad_UpdateButtons()
end

-- Handle virtual keypad OK button click
function VirtualKeypadOkayButton_OnClick()
    local PIN = VirtualKeypadText:GetNumber()
    local numNumbers = strlen(PIN)
    local pinNumber = {}
    
    -- Convert the displayed PIN back to the actual button values
    for i = 1, MAX_PIN_LENGTH do
        if i <= numNumbers then
            pinNumber[i] = nil
            local digit = tonumber(strsub(PIN, i, i))
            for j = 1, 10 do
                if tonumber(buttonText[j]) == digit then
                    pinNumber[i] = j - 1
                    break
                end
            end
        else
            pinNumber[i] = nil
        end
    end
    
    -- Submit the PIN with all 10 possible positions
    PINEntered(pinNumber[1], pinNumber[2], pinNumber[3], pinNumber[4], pinNumber[5], 
               pinNumber[6], pinNumber[7], pinNumber[8], pinNumber[9], pinNumber[10])
    VirtualKeypadFrame:Hide()
end

-- Update virtual keypad button states (currently empty)
function VirtualKeypad_UpdateButtons()
end
