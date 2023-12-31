ControllerMod = {}

S_BUTTON = nil;

BINDING_HEADER_CONTROLLERMOD = "Controller Mod"
BINDING_NAME_START = "Start"
BINDING_NAME_INTERACT = "Interact"
BINDING_NAME_BACK = "Back"
BINDING_NAME_BUTTON_A = "Button A"
BINDING_NAME_BUTTON_B = "Button B"
BINDING_NAME_LEFT = "Left"
BINDING_NAME_RIGHT = "Right"
BINDING_NAME_UP = "Up"
BINDING_NAME_DOWN = "Down"

StaticPopupDialogs["POPUP_EXTENSIONS"] = {
    text = "Couldn\'t load |cffFF8800Extensions.dll|r.\n\nPlease visit |cffFF8800https://github.com/ElementoBorzi/WoW-Controller-3.3.5|r for more details.",
    button1 = "Exit Game",
    OnAccept = function()
        ForceQuit();
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function CloseMenus()
    CloseGossip();
    CloseQuest();
end

-- @iElementoBorzi: button helpers
function ClickButton()
    if S_BUTTON == nil then
        return false
    elseif S_BUTTON:GetName() == "CharacterMicroButton" then
        ToggleCharacter("PaperDollFrame");
        return true
    end

    S_BUTTON:Click();
    return true
end

function ClearButton()
    S_BUTTON = nil;
	SetCursorPosition(0.5, 0.25);
end

function SetButton(button)
    if button == nil then return end
    MoveCursor(button)
    S_BUTTON = button
end

function SetButtonIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();
	local buttonIndex
    for idx in string.gmatch (buttonName, "%d+") do
        buttonIndex = idx
    end
	
    if buttonIndex == nil then
        return false
    end

    local newButtonName = string.gsub(buttonName, buttonIndex .. "$", buttonIndex + index);
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
		return true
    end
	
    return false
end

function SetBagIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();

    local bagIndex, itemIndex;
    local i = 1;
    for idx in string.gmatch(buttonName, "%d+") do
        if i == 1 then bagIndex = tonumber(idx) end
        if i == 2 then itemIndex = tonumber(idx) end
        i = i + 1;
    end 

    if bagIndex == nil or itemIndex == nil then
        return false
    end

    local numSlots = GetContainerNumSlots(bagIndex - 1);
    if ( itemIndex + index ) > GetContainerNumSlots(bagIndex - 1) then
        if bagIndex < 5 then
            bagIndex = bagIndex + 1;
            itemIndex = GetContainerNumSlots(bagIndex - 1) + ( itemIndex + index );
        end
    elseif ( itemIndex + index ) < 1 then
        if bagIndex < 5 then
            bagIndex = bagIndex - 1;
            itemIndex = ( itemIndex + index ) % numSlots;
        end
    else
        itemIndex = itemIndex + index;
    end

    local newButtonName = "ContainerFrame" .. bagIndex .. "Item" .. itemIndex;
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
        return true
    end

    return false
end

FRAME_BUTTONS =
{
    QuestLogFrame =
    { 
        "QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "QuestLogFrameCancelButton"
    },
}

function SetFrameLRIndex(frame, index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();

    local buttonIndex = 0;
    for i, v in ipairs(FRAME_BUTTONS[frame:GetName()]) do
        if v == buttonName then
            buttonIndex = i;
            break;
        end
    end

    if index > 0 then
        for i = ( buttonIndex + index ), #FRAME_BUTTONS[frame:GetName()] do
            local newButton = _G[FRAME_BUTTONS[frame:GetName()][i]];
            if newButton and newButton:IsEnabled() == 1 then
                SetButton(_G[FRAME_BUTTONS[frame:GetName()][i]]);
                return
            end
        end
    else
        for i = ( buttonIndex + index ), 1, index do
            local newButton = _G[FRAME_BUTTONS[frame:GetName()][i]];
            if newButton and newButton:IsEnabled() == 1 then
                SetButton(_G[FRAME_BUTTONS[frame:GetName()][i]]);
                return
            end
        end
    end
end

function QuestLogFrame_Right()
    if CursorHasItem() then
        ClearCursor();
    else
        ClearButton();
        CloseAllBags();
    end
end


-- @iElementoBorzi: micro button helpers
MICRO_BUTTONS = { "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "SocialsMicroButton", "PVPMicroButton", "LFDMicroButton", "MainMenuMicroButton", "HelpMicroButton" };
function SetMicroButton(button)
    if S_BUTTON == nil then
		SetButton(button);
    else
        ClearButton();
        CloseMenus();
    end
end

function SetMicroButtonIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();
    for i, v in ipairs(MICRO_BUTTONS) do
        if v == buttonName then
            if _G[MICRO_BUTTONS[i + index]] then
                SetButton(_G[MICRO_BUTTONS[i + index]]);
            end
        end
    end
end


function MoveCursor(button)
    if button:IsVisible() then
        x, y = GetNormalizedPosition(button);
        SetCursorPosition(x, y);
    end
end

function GetNormalizedPosition(frame)
    if GetCVar("gxMaximize") ~= 1 then
        print("ControllerMod: Windowed Mode (Maximized = 0) is not supported yet!");
    end

    local w, h = GetScreenWidth(), GetScreenHeight()
    local x, y = frame:GetCenter()
    return x/w, y/h
end

-- @iElementoBorzi: event handlers (https://wowpedia.fandom.com/wiki/Events)
EVENT_HANDLERS =
{
    GOSSIP_SHOW     = { SetButton, "GossipTitleButton1" },
    GOSSIP_CLOSED   = { ClearButton },

    QUEST_GREETING  = { SetButton, "QuestTitleButton1" },
    QUEST_DETAIL    = { SetButton, "QuestFrameAcceptButton" },
    QUEST_FINISHED  = { ClearButton },
}

-- @iElementoBorzi: binding handlers (Esc -> Key Bindings -> ControllerMod)
-- sorted by priority
BINDING_HANDLERS =
{
    GossipFrame =
    {
        Button_A = { ClickButton },
        Button_B = { CloseGossip },
        Left = { SetButton, "GossipTitleButton1" },
        Right = { SetButton, "GossipFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameGreetingPanel =
    {
        Interact = { ClickButton },
        Button_B = { CloseQuest },
        Left = { SetButton, "QuestTitleButton1" },
        Right = { SetButton, "QuestFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameDetailPanel =
    {
        Button_A = { ClickButton },
        Button_B = { CloseQuest },
        Left = { SetButton, "QuestFrameAcceptButton" },
        Right = { SetButton, "QuestFrameDeclineButton" },
        Up = { ClickButton, "QuestDetailScrollFrameScrollBarScrollUpButton"  },
        Down = { ClickButton, "QuestDetailScrollFrameScrollBarScrollDownButton"  },
    },
	
	QuestLogFrame =
    {
        Button_A = { ClickButton },
        Button_B = { ClickButton, "QuestLogFrameCloseButton" },
        Left = { SetFrameLRIndex, -1 },
        Right = { SetFrameLRIndex, 1 },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

	
	ContainerFrame1 =
    {
        Button_A = { ClickButton },
        Left = { SetBagIndex, 1 },
        Right = { SetBagIndex, -1 },
        Up = { SetBagIndex, 4 },
        Down = { SetBagIndex, -4 },
    },
	
    WorldFrame =
    {
        Start = { ClickButton, "MainMenuBarBackpackButton"},
        Back = { SetMicroButton, "CharacterMicroButton" },
        Button_A = { ClickButton },
        Left = { SetMicroButtonIndex, -1 },
        Right = { SetMicroButtonIndex, 1 },
    },
}

QuestLogFrame:HookScript("OnShow", function(self)
    SetButton(_G["QuestLogScrollFrameButton1"]);
end)

QuestLogFrame:HookScript("OnHide", function(self)
    ClearButton();
end)


ContainerFrame1:HookScript("OnShow", function(self)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end
	
    SetButton(_G["ContainerFrame1Item16"]);
    _G["CharacterBag0Slot"]:Click();
    _G["CharacterBag1Slot"]:Click();
    _G["CharacterBag2Slot"]:Click();
    _G["CharacterBag3Slot"]:Click();
end)

ContainerFrame1:HookScript("OnHide", function(self)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end
	
    ClearButton();
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

-- @iElementoBorzi: register event listeners
if CheckDLL() then
    for event, _ in pairs(EVENT_HANDLERS) do
        frame:RegisterEvent(event);
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
   if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end
	
	 if event == "ADDON_LOADED" then
        SetCVar("autoLootDefault", 1);
    end

    handler = EVENT_HANDLERS[event];
    if handler then
         ControllerMod_Handle(handler);
    end
end)

-- @iElementoBorzi: check if DLL lua API is injected
function CheckDLL(self)
    return InteractNearest and SetCursorPosition;
end

-- @iElementoBorzi: Bindings.xml handlers
function ControllerMod_Start()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Start"] then
            ControllerMod_Handle(_G[frame], handler["Start"]);
            return
        end
    end
end

function ControllerMod_Back()
    if _G[frame] and _G[frame]:IsVisible() and handler["Back"] then
            if ControllerMod_Handle(_G[frame], handler["Back"]) then
                return
            end
        end
    end
end

function ControllerMod_Button_A()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_A"] then
            if ControllerMod_Handle(_G[frame], handler["Button_A"]) then
                print("Return")
                return
            end
        end
    end

function ControllerMod_Button_B()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_B"] then
            ControllerMod_Handle(_G[frame], handler["Button_B"]);
        end
    end    
end

function ControllerMod_Left()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Left"] then
            ControllerMod_Handle(_G[frame], handler["Left"]);
        end
    end   
end

function ControllerMod_Right()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Right"] then
            ControllerMod_Handle(_G[frame], handler["Right"]);
        end
    end   
end

function ControllerMod_Up()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Up"] then
            ControllerMod_Handle(_G[frame], handler["Up"]);
        end
    end  
end

function ControllerMod_Down()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Down"] then
            ControllerMod_Handle(_G[frame], handler["Down"]);
        end
    end  
end

function ControllerMod_Handle(frame, handle)
    local fn = handle[1];
    if fn == nil then
        return false
    end

    -- @iElementoBorzi: handle fn parameter parsing
    if fn == SetButton or fn == SetMicroButton then
        return fn(_G[handle[2]]);
    elseif fn == ClickButton then
        if handle[2] then
            _G[handle[2]]:Click();
        else
            return ClickButton(S_BUTTON);
        end
    elseif fn == SetButtonIndex or fn == SetMicroButtonIndex or fn == SetBagIndex then
        return fn(handle[2]);
	elseif fn == SetFrameLRIndex then
        return fn(frame, handle[2])
    else
        return fn();
    end
	
    return false
end