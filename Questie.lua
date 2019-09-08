Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
_Questie = {...}
local L = LibStub("AceLocale-3.0"):GetLocale("QuestieLocale")
if not QuestieConfigCharacter then
    QuestieConfigCharacter = {}
end

local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")
local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local HBDMigrate = LibStub("HereBeDragonsQuestie-Migrate")

DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"


-- get option value
local function GetGlobalOptionLocal(info)
    return Questie.db.global[info[#info]]
end

-- set option value
local function SetGlobalOptionLocal(info, value)
    if debug and Questie.db.global[info[#info]] ~= value then
        Questie:Debug(DEBUG_SPAM, "DEBUG: global option "..info[#info].." changed from '"..tostring(Questie.db.global[info[#info]]).."' to '"..tostring(value).."'")
    end
    Questie.db.global[info[#info]] = value
end

local _optionsTimer = nil;
local _QuestieOptions = {...};
_QuestieOptions.configFrame = nil;

-- Initialize LangNameLookup & LangQuestLookup
LangNameLookup = LangNameLookup[GetLocale()] or {}
LangQuestLookup = LangQuestLookup[GetLocale()] or {}

function _QuestieOptions:AvailableQuestRedraw()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
end

function _QuestieOptions:ClusterRedraw()
    --Redraw clusters here
end

function _QuestieOptions:Delay(time, func, message)
    if(_optionsTimer) then
        Questie:CancelTimer(_optionsTimer)
        _optionsTimer = nil;
    end
    _optionsTimer = Questie:ScheduleTimer(function()
        func()
        Questie:Debug(DEBUG_DEVELOP, message)
    end, time)
end

function _QuestieOptions:Spacer(o)
    return {
        type = "description",
        order = o,
        name = " ",
        fontSize = "large",
    }
end

function _QuestieOptions:OpenConfigWindow()

    if not _QuestieOptions.configFrame then
        _QuestieOptions.configFrame = AceGUI:Create("Frame");
        _QuestieOptions.configFrame:Hide();

        _G["QuestieConfigFrame"] = _QuestieOptions.configFrame.frame;
        table.insert(UISpecialFrames, "QuestieConfigFrame");
    end

    if not _QuestieOptions.configFrame:IsShown() then
        PlaySound(882);
        LibStub("AceConfigDialog-3.0"):Open("Questie", _QuestieOptions.configFrame)
    else
        _QuestieOptions.configFrame:Hide();
    end
end

_QuestieOptions.defaults = {
    global = {
      maxLevelFilter = 7,
      minLevelFilter = 5, --Raised the default to allow more quests to be shown
      clusterLevel = 1,
      availableScale = 1.3,
      eventScale = 1.35,
      lootScale = 1,
      monsterScale = 1,
      objectScale = 1,
      globalScale = 0.7,
      globalMiniMapScale = 0.7,
      fadeLevel = 1.5,
      fadeOverPlayer = true,
      fadeOverPlayerLevel = 0.5,
      fadeOverPlayerDistance = 0.2,
      debugEnabled = false,
      debugEnabledPrint = false,
      debugLevel = 4,
      nameplateX = -17,
      nameplateY = -7,
      nameplateScale = 1,
      nameplateEnabled = true,
      minimapCoordinatesEnabled = false,
      mapCoordinatesEnabled = true,
      mapCoordinatePrecision = 1,
      mapShowHideEnabled = true,
      nameplateTargetFrameEnabled = false,
      nameplateTargetFrameX = -30,
      nameplateTargetFrameY = 25,
      nameplateTargetFrameScale = 1.7,
      questieLocale = 'enUS',
      questieLocaleDiff = false,
      alwaysGlowMap = false,
      alwaysGlowMinimap = false,
      enableObjectives = true,
      enableTurnins = true,
      enableAvailable = true,
      enableTooltips = true,
      enableMapIcons = true,
      enableMiniMapIcons = true,
    },
      char = {
          complete = {},
          hidden = {},
          enabled = true,
          lowlevel = false,
          journey = {},
          searchType = 1,
          --autoaccept = false,
          --autocomplete = false
      },
      profile = {
          minimap = {
              hide = false,
          },
      },
  }


local options = {
    name = "Questie",
    handler = Questie,
    type = "group",
    childGroups = "tab",
    args = {
        general_tab = {
            name = function() return L['Options'] end,
            type = "group",
            order = 10,
            args = {
                questie_header = {
                    type = "header",
                    order = 1,
                    name = function() return L['Questie Options'] end,
                },
                enabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return L['Enable Icons'] end,
                    desc = function() return L['Enable or disable Questie icons'] end,
                    width = "full",
                    get =    function ()
                                return Questie.db.char.enabled
                            end,
                    set =    function (info, value)
                                QuestieQuest:ToggleNotes(value);
                                Questie.db.char.enabled = value
                            end,
                },
                iconTypes = {
                    type = "group",
                    order = 4,
                    inline = true,
                    name = function() return L['Icon Types'] end,
                    args = {
                        enableMapToggle = {
                            type = "toggle",
                            order = 1,
                            name = function() return L['Enable Map Icons'] end,
                            desc = function() return L['Show/hide all icons from the main map'] end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableMapIcons;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableMapIcons = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableMiniMapToggle = {
                            type = "toggle",
                            order = 2,
                            name = function() return L['Enable Minimap Icons'] end,
                            desc = function() return L['Show/hide all icons from the minimap'] end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableMiniMapIcons;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableMiniMapIcons = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        seperatingHeader = {
                            type = "header",
                            order = 3,
                            name = "",
                        },
                        enableObjectivesToggle = {
                            type = "toggle",
                            order = 4,
                            name = function() return L['Enable Objective Icons'] end,
                            desc = function() return L['When this is enabled, quest objective icons will be shown on the map/minimap'] end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableObjectives;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableObjectives = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableTurninsToggle = {
                            type = "toggle",
                            order = 5,
                            name = function() return L['Enable Completed Quest Icons'] end,
                            desc = function() return L['When this is enabled, the quest turn-in locations will be shown on the map/minimap'] end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableTurnins;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableTurnins = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableAvailableToggle = {
                            type = "toggle",
                            order = 6,
                            name = function() return L['Enable Available Quest Icons'] end,
                            desc = function() return L['When this is enabled, the available quest locations will be shown on the map/minimap'] end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableAvailable;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableAvailable = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                    },
                },
                iconEnabled = {
                    type = "toggle",
                    order = 5,
                    name = function() return L['Enable Minimap Button'] end,
                    desc = function() return L['Enable or disable the Questie minimap button. You can still access the options menu with /questie'] end,
                    width = "full",
                    get =    function ()
                                return not Questie.db.profile.minimap.hide;
                            end,
                    set =    function (info, value)
                                Questie.db.profile.minimap.hide = not value;

                                if value then
                                    Questie.minimapConfigIcon:Show("MinimapIcon");
                                else
                                    Questie.minimapConfigIcon:Hide("MinimapIcon");
                                end
                            end,
                },
                instantQuest = {
                    type = "toggle",
                    order = 6,
                    name = function() return L['Enable Instant Quest Text'] end,
                    desc = function() return L['Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface'] end,
                    width = "full",
                    get =    function ()
                                if GetCVar("instantQuestText") == '1' then return true else return false end;
                            end,
                    set =    function (info, value)
                                if value then
                                    SetCVar("instantQuestText", 1);
                                else
                                    SetCVar("instantQuestText", 0);
                                end
                            end,
                },
                enableTooltipsToggle = {
                    type = "toggle",
                    order = 7,
                    name = function() return L['Enable Tooltips'] end,
                    desc = function() return L['When this is enabled, quest info will be added to relevant mob/item tooltips'] end,
                    width = "full",
                    get =    function ()
                                return Questie.db.global.enableTooltips;
                            end,
                    set =    function (info, value)
                                Questie.db.global.enableTooltips = value
                            end,
                },
                --Spacer_A = _QuestieOptions:Spacer(9),
                quest_options = {
                    type = "header",
                    order = 8,
                    name = function() return L['Quest Level Options'] end,
                },
                Spacer_B = _QuestieOptions:Spacer(9),
                gray = {
                    type = "toggle",
                    order = 10,
                    name = function() return L['Show All Quests below range (Low level quests)'] end,
                    desc = function() return L['Enable or disable showing of showing low level quests on the map.'] end,
                    width = 200,
                    get =    function ()
                                return Questie.db.char.lowlevel
                            end,
                    set =    function (info, value)
                                Questie.db.char.lowlevel = value
                                _QuestieOptions.AvailableQuestRedraw();
                                Questie:debug(DEBUG_DEVELOP, L['DEBUG_LOWLEVEL'], value)
                            end,
                },
                minLevelFilter = {
                    type = "range",
                    order = 11,
                    name = function() return L['< Show below level'] end,
                    desc = function() return string.format(L['How many levels below your character to show. ( Default: %s )'], _QuestieOptions.defaults.global.minLevelFilter) end,
                    width = "normal",
                    min = 1,
                    max = 10,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, string.format(L['DEBUIG_MINLEVEL'], value))
                            end,
                },
                maxLevelFilter = {
                    type = "range",
                    order = 12,
                    name = function() return L['Show above level >'] end,
                    desc = function() return string.format(L['How many levels above your character to show. ( Default: %s )'], _QuestieOptions.defaults.global.maxLevelFilter) end,
                    width = "normal",
                    min = 1,
                    max = 10,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, string.format(L['DEBUG_MAXLEVEL'], value))
                            end,
                },
                clusterLevel = {
                  type = "range",
                  order = 13,
                  name = function() return L['Objective icon cluster amount  (Not yet implemented)'] end,
                  desc = function() return L['How much objective icons should cluster.'] end,
                  width = "double",
                  min = 0.02,
                  max = 5,
                  step = 0.01,
                  get = GetGlobalOptionLocal,
                  set = function (info, value)
                        _QuestieOptions:Delay(0.5, _QuestieOptions.ClusterRedraw, string.format(L['DEBUG_CLUSTER'], value))
                        QUESTIE_NOTES_CLUSTERMUL_HACK = value;
                        SetGlobalOptionLocal(info, value)
                        end,
                },
            },
        },

        minimap_tab = {
            name = function() return L['Minimap Options'] end,
            type = "group",
            order = 11,
            args = {
                minimap_options = {
                    type = "header",
                    order = 1,
                    name = function() return L['Mini-Map Note Options'] end,
                },
                alwaysGlowMinimap = {
                    type = "toggle",
                    order = 1.7,
                    name = function() return L['Always glow behind minimap icons'] end,
                    desc = function() return L['Draw a glow texture behind minimap icons, colored unique to each quest'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateGlowConfig(true, value)
                    end,
                },
                Spacer_A = _QuestieOptions:Spacer(2),
                globalMiniMapScale = {
                    type = "range",
                    order = 3,
                    name = function() return L['Global Scale for Mini-Map Icons'] end,
                    desc = function() return string.format(L['How large the Mini-Map icons are. ( Default: %s )'], _QuestieOptions.defaults.global.globalMiniMapScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                fadeLevel = {
                    type = "range",
                    order = 12,
                    name = function() return L['Fade objective distance'] end,
                    desc = function() return string.format(L['How much objective icons should fade depending on distance. ( Default: %s )'], _QuestieOptions.defaults.global.fadeLevel) end,
                    width = "double",
                    min = 0.01,
                    max = 5,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                          SetGlobalOptionLocal(info, value)
                          end,
                },
                Spacer_D = _QuestieOptions:Spacer(13),
                fadeOverPlayer = {
                    type = "toggle",
                    order = 14,
                    name = function() return L['Fade Icons over Player'] end,
                    desc = function() return L['Fades icons on the minimap when your player walks near them.'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        end,
                },
                fadeOverPlayerDistance = {
                    type = "range",
                    order = 15,
                    name = function() return L['Fade over Player Distance'] end,
                    desc = function() return string.format(L['How far from player should icons start to fade. ( Default: %s )'], _QuestieOptions.defaults.global.fadeOverPlayerDistance) end,
                    width = "double",
                    min = 0.1,
                    max = 0.5,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    disabled = function() return (not Questie.db.global.fadeOverPlayer) end,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                    end,
                },
                fadeOverPlayerLevel = {
                    type = "range",
                    order = 16,
                    name = function() return L['Fade over Player Amount'] end,
                    desc = function() return string.format(L['How much should the icons around the player fade. ( Default: %s )'], _QuestieOptions.defaults.global.fadeOverPlayerLevel) end,
                    width = "double",
                    min = 0.1,
                    max = 1,
                    step = 0.1,
                    disabled = function() return (not Questie.db.global.fadeOverPlayer) end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                    end,
                },
                Spacer_E = _QuestieOptions:Spacer(20),
                fade_options = {
                    type = "header",
                    order = 21,
                    name = function() return L['Mini-Map Coordinates'] end,
                },
                Spacer_F = _QuestieOptions:Spacer(22),
                minimapCoordinatesEnabled = {
                    type = "toggle",
                    order = 23,
                    name = function() return L['Player Coordinates on Minimap'] end,
                    desc = function() return L['Place the Player\'s coordinates on the Minimap title.'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)

                        if not value then
                            QuestieCoords.ResetMinimapText();
                        end
                    end,
                },
            },
        },

        map_tab = {
            name = function() return L['Map Options'] end,
            type = "group",
            order = 13,
            args = {
                map_options = {
                    type = "header",
                    order = 1,
                    name = function() return L['Map Options'] end,
                },
                mapShowHideEnabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return L['Show Questie Map Button'] end,
                    desc = function() return L['Enable or disable the Show/Hide Questie Button on Map (May fix some Map Addon interactions)'] end,
                    width = "full",
                    get =    GetGlobalOptionLocal,
                    set =    function (info, value)
                                SetGlobalOptionLocal(info, value)

                                if value then
                                    Questie_Toggle:Show();
                                else
                                    Questie_Toggle:Hide();
                                end
                            end,
                },
                alwaysGlowMap = {
                    type = "toggle",
                    order = 3.1,
                    name = function() return L['MAP_ALWAYS_GLOW_TOGGLE'] end,
                    desc = function() return L['MAP_ALWAYS_GLOW_TOGGLE_DESC'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateGlowConfig(false, value)
                    end,
                },
                Spacer_A = _QuestieOptions:Spacer(6),
                mapnote_options = {
                    type = "header",
                    order = 7,
                    name = function() return L['Map Note Options'] end,
                },
                Spacer_B = _QuestieOptions:Spacer(8),
                globalScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['Global Scale for Map Icons'] end,
                    desc = function() return string.format(L['MAP_GLOBAL_SCALE_DESC'], _QuestieOptions.defaults.global.globalScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                availableScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['AVAILABLE_ICON_SCALE'] end,
                    desc = function() return string.format(L['AVAILABLE_ICON_SCALE_DESC'], _QuestieOptions.defaults.global.availableScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                eventScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['EVENT_ICON_SCALE'] end,
                    desc = function() return string.format(L['EVENT_ICON_SCALE_DESC'], _QuestieOptions.defaults.global.eventScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                lootScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['LOOT_ICON_SCALE'] end,
                    desc = function() return string.format(L['LOOT_ICON_SCALE_DESC'], _QuestieOptions.defaults.global.lootScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                monsterScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['MONSTER_ICON_SCALE'] end,
                    desc = function() return string.format(L['MONSTER_ICON_SCALE_DESC'], _QuestieOptions.defaults.global.monsterScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                objectScale = {
                    type = "range",
                    order = 9,
                    name = function() return L['OBJECT_ICON_SCALE'] end,
                    desc = function() return string.format(L['OBJECT_ICON_SCALE_DESC'], _QuestieOptions.defaults.global.objectScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                Spacer_C = _QuestieOptions:Spacer(20),
                fade_options = {
                    type = "header",
                    order = 21,
                    name = function() return L['MAP_COORDS'] end,
                },
                Spacer_D = _QuestieOptions:Spacer(22),
                mapCoordinatesEnabled = {
                    type = "toggle",
                    order = 23,
                    name = function() return L['ENABLE_MAP_COORDS'] end,
                    desc = function() return L['ENABLE_MAP_COORDS_DESC'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)

                        if not value then
                            QuestieCoords.ResetMapText();
                        end
                    end,
                },
                mapCoordinatePrecision = {
                    type = "range",
                    order = 24,
                    name = function() return L['MAP_COORDS_PRECISION'] end,
                    desc = function() return string.format(L['MAP_COORDS_PRECISION_DESC'], _QuestieOptions.defaults.global.mapCoordinatePrecision) end,
                    width = "double",
                    min = 1,
                    max = 5,
                    step = 1,
                    disabled = function() return not Questie.db.global.mapCoordinatesEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                            end,
                }
            },
        },

        nameplate_tab = {
            name = function() return L['NAMEPLATE_TAB'] end,
            type = "group",
            order = 14,
            args = {
                nameplate_options = {
                    type = "header",
                    order = 1,
                    name = function() return L['NAMEPLATE_HEAD'] end,
                },
                nameplateEnabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return L['NAMEPLATE_TOGGLE'] end,
                    desc = function() return L['NAMEPLATE_TOGGLE_DESC'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)

                                -- on false, hide current nameplates
                                if not value then
                                    QuestieNameplate:HideCurrentFrames();
                                end
                            end,
                },
                Spacer_A = _QuestieOptions:Spacer(4),
                nameplateX = {
                    type = "range",
                    order = 5,
                    name = function() return L['NAMEPLATE_X'] end,
                    desc = function() return string.format(L['NAMEPLATE_X_DESC'], _QuestieOptions.defaults.global.nameplateX ) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateY = {
                    type = "range",
                    order = 5,
                    name = function() return L['NAMEPLATE_Y'] end,
                    desc = function() return string.format(L['NAMEPLATE_Y_DESC'], _QuestieOptions.defaults.global.nameplateY) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateScale = {
                    type = "range",
                    order = 6,
                    name = function() return L['NAMEPLATE_SCALE'] end,
                    desc = function() return string.format(L['NAMEPLATE_SCALE_DESC'], _QuestieOptions.defaults.global.nameplateScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                QuestieNameplate:redrawIcons()
                            end,

                },
                Spacer_B = _QuestieOptions:Spacer(7),
                nameplateReset = {
                    type = "execute",
                    order = 8,
                    name = function() return L['NAMEPLATE_RESET_BTN'] end,
                    desc = function() return L['NAMEPLATE_RESET_BTN_DESC'] end,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    func = function (info, value)
                        Questie.db.global.nameplateX = _QuestieOptions.defaults.global.nameplateX;
                        Questie.db.global.nameplateY = _QuestieOptions.defaults.global.nameplateY;
                        Questie.db.global.nameplateScale = _QuestieOptions.defaults.global.nameplateScale;
                        QuestieNameplate:redrawIcons();
                    end,
                },
                Spacer_C = _QuestieOptions:Spacer(9),
                targetframe_header = {
                    type = "header",
                    order = 20,
                    name = function() return L['TARGET_HEAD'] end,
                },
                Spacer_D = _QuestieOptions:Spacer(21),
                nameplateTargetFrameEnabled = {
                    type = "toggle",
                    order = 22,
                    name = function() return L['TARGET_TOGGLE'] end,
                    desc = function() return L['TARGET_TOGGLE_DESC'] end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)

                                -- on false, hide current nameplates
                                if not value then
                                    QuestieNameplate:HideCurrentTargetFrame();
                                else
                                    QuestieNameplate:DrawTargetFrame();
                                end
                            end,
                },
                Spacer_E = _QuestieOptions:Spacer(23),
                nameplateTargetFrameX  = {
                    type = "range",
                    order = 24,
                    name = function() return L['TARGET_X'] end,
                    desc = function() return string.format(L['TARGET_X_DESC'], _QuestieOptions.defaults.global.nameplateTargetFrameX) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateTargetFrameY  = {
                    type = "range",
                    order = 24,
                    name = function() return L['TARGET_Y'] end,
                    desc = function() return string.format(L['TARGET_Y_DESC'], _QuestieOptions.defaults.global.nameplateTargetFrameY) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateTargetFrameScale  = {
                    type = "range",
                    order = 25,
                    name = function() return L['TARGET_SCALE'] end,
                    desc = function() return string.format(L['TARGET_SCALE_DESC'], _QuestieOptions.defaults.global.nameplateTargetFrameScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                QuestieNameplate:redrawFrameIcon()
                            end,

                },
                Spacer_F = _QuestieOptions:Spacer(26),
                targetFrameReset = {
                    type = "execute",
                    order = 27,
                    name = function() return L['TARGET_RESET_BTN'] end,
                    desc = function() return L['TARGET_RESET_BTN_DESC'] end,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    func = function (info, value)
                        Questie.db.global.nameplateTargetFrameX = _QuestieOptions.defaults.global.nameplateTargetFrameX;
                        Questie.db.global.nameplateTargetFrameY = _QuestieOptions.defaults.global.nameplateTargetFrameY;
                        Questie.db.global.nameplateTargetFrameScale = _QuestieOptions.defaults.global.nameplateTargetFrameScale;
                        QuestieNameplate:redrawFrameIcon();
                    end,
                },
            },
        },

        Advanced_tab = {
            name = function() return L['ADV_TAB'] end,
            type = "group",
            order = 15,
            args = {
                map_options = {
                    type = "header",
                    order = 1,
                    name = function() return L['DEV_OPTIONS'] end,
                },
                debugEnabled = {
                    type = "toggle",
                    order = 4,
                    name = function() return L['ENABLE_DEBUG'] end,
                    desc = function() return L['ENABLE_DEBUG_DESC'] end,
                    width = "full",
                    get =    function ()
                                return Questie.db.global.debugEnabled
                            end,
                    set =    function (info, value)
                                Questie.db.global.debugEnabled = value
                            end,
                },
                debugLevel = {
                    type = "range",
                    order = 5,
                    name = function() return L['DEBUG_LEVEL'] end,
                    desc = function() return string.format(L['DEBUG_LEVEL_DESC'], "\nDEBUG_CRITICAL = 1\nDEBUG_ELEVATED = 2\nDEBUG_INFO = 3\nDEBUG_DEVELOP = 4\nDEBUG_SPAM = 5") end,
                    width = "normal",
                    min = 1,
                    max = 5,
                    step = 1,
                    disabled = function() return not Questie.db.global.debugEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                            end,
                },

                Spacer_A = _QuestieOptions:Spacer(10),
                locale_header = {
                    type = "header",
                    order = 11,
                    name = function() return L['LOCALE'] end,
                },
                Spacer_B = _QuestieOptions:Spacer(12),
                locale_dropdown = {
                    type = "select",
                    order = 13,
                    values = {
                        ['enUS'] = 'English',
                        ['esES'] = 'Español',
                        ['ptBR'] = 'Português',
                        ['frFR'] = 'Français',
                        ['deDE'] = 'Deutsch',
                        ['ruRU'] = 'русский',
                        ['zhCN'] = '简体中文',
                        ['zhTW'] = '正體中文',
                        ['koKR'] = '한국어',
                    },
                    style = 'dropdown',
                    name = function() return L['LOCALE_DROP'] end,
                    get = function() return QuestieLocale:GetUILocale(); end,
                    set = function(input, lang)
                        QuestieLocale:SetUILocale(lang);
                        Questie.db.global.questieLocale = lang;
                        Questie.db.global.questieLocaleDiff = true;
                    end,
                },
                Spacer_C = _QuestieOptions:Spacer(20),
                reset_header = {
                    type = "header",
                    order = 21,
                    name = function() return L['RESET_QUESTIE'] end,
                },
                Spacer_D = _QuestieOptions:Spacer(22),
                reset_text = {
                    type = "description",
                    order = 23,
                    name = function() return L['RESET_QUESTIE_DESC'] end,
                    fontSize = "medium",
                },
                questieReset = {
                    type = "execute",
                    order = 24,
                    name = function() return L['RESET_QUESTIE_BTN'] end,
                    desc = function() return L['RESET_QUESTIE_BTN_DESC'] end,
                    func = function (info, value)
                        -- update all values to default
                        for k,v in pairs(_QuestieOptions.defaults.global) do
                           Questie.db.global[k] = v
                        end

                        -- only toggle questie if it's off (must be called before resetting the value)
                        if not Questie.db.char.enabled then
                            QuestieQuest:ToggleNotes();
                        end

                        Questie.db.char.enabled = _QuestieOptions.defaults.char.enabled;
                        Questie.db.char.lowlevel = _QuestieOptions.defaults.char.lowlevel;

                        Questie.db.profile.minimap.hide = _QuestieOptions.defaults.profile.minimap.hide;

                        -- update minimap icon to default
                        if not Questie.db.profile.minimap.hide then
                            Questie.minimapConfigIcon:Show("MinimapIcon");
                        else
                            Questie.minimapConfigIcon:Hide("MinimapIcon");
                        end

                        -- update map / minimap coordinates reset
                        if not Questie.db.global.minimapCoordinatesEnabled then
                            QuestieCoords.ResetMinimapText();
                        end

                        if not Questie.db.global.mapCoordinatesEnabled then
                            QuestieCoords.ResetMapText();
                        end

                        -- Reset the show/hide on map
                        if Questie.db.global.mapShowHideEnabled then
                            Questie_Toggle:Show();
                        else
                            Questie_Toggle:Hide();
                        end

                        _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, "minLevelFilter and maxLevelFilter reset to defaults");

                        QuestieNameplate:redrawIcons();
                        QuestieMap:rescaleIcons();

                    end,
                },
                Spacer_C = _QuestieOptions:Spacer(30),
                github_text = {
                    type = "description",
                    order = 31,
                    name = function() return Questie:Colorize(L['QUESTIE_DEV_MESSAGE'], 'purple') end,
                    fontSize = "medium",
                },

            },
        }
    }
}


local minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapIcon", {
    type = "data source",
    text = "Questie",
    icon = ICON_TYPE_COMPLETE,

    OnClick = function (self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                QuestieQuest:ToggleNotes();

                -- CLose config window if it's open to avoid desyncing the Checkbox
                if _QuestieOptions.configFrame and _QuestieOptions.configFrame:IsShown() then
                    _QuestieOptions.configFrame:Hide();
                end
                return;
            elseif IsControlKeyDown() then
                QuestieQuest:SmoothReset()
                return
            end

            _QuestieOptions.OpenConfigWindow()

            if QuestieJourney:IsShown() then
                QuestieJourney.toggleJourneyWindow();
            end
            return;

        elseif button == "RightButton" then
            if not IsModifierKeyDown() then
                -- CLose config window if it's open to avoid desyncing the Checkbox
                if _QuestieOptions.configFrame and _QuestieOptions.configFrame:IsShown() then
                    _QuestieOptions.configFrame:Hide();
                end

                QuestieJourney.toggleJourneyWindow();
                return;
            elseif IsControlKeyDown() then
                Questie.db.profile.minimap.hide = true;
                Questie.minimapConfigIcon:Hide("MinimapIcon");
                return;
            end
        end
    end,

    OnTooltipShow = function (tooltip)
        tooltip:AddLine("Questie", 1, 1, 1);
        tooltip:AddLine (Questie:Colorize(L['ICON_LEFT_CLICK'] , 'gray') .. ": ".. L['ICON_TOGGLE']);
        tooltip:AddLine (Questie:Colorize(L['ICON_SHIFTLEFT_CLICK'] , 'gray') .. ": ".. L['ICON_TOGGLE_QUESTIE']);
        tooltip:AddLine (Questie:Colorize(L['ICON_RIGHT_CLICK'] , 'gray') .. ": ".. L['ICON_JOURNEY']);
        tooltip:AddLine (Questie:Colorize(L['ICON_CTRLRIGHT_CLICK'] , 'gray') .. ": ".. L['ICON_HIDE']);
        tooltip:AddLine (Questie:Colorize(L['ICON_CTRLLEFT_CLICK'],   'gray') .. ": ".. L['ICON_RELOAD']);
    end,
});


function Questie:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("QuestieConfig", _QuestieOptions.defaults, true)

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        QuestieLocale:SetUILocale(Questie.db.global.questieLocale);
    else
        QuestieLocale:SetUILocale(GetLocale());
    end

    Questie:Debug(DEBUG_CRITICAL, "Questie addon loaded")
    Questie:RegisterEvent("PLAYER_ENTERING_WORLD", QuestieEventHandler.PLAYER_ENTERING_WORLD)

    --Accepted Events
    Questie:RegisterEvent("QUEST_ACCEPTED", QuestieEventHandler.QUEST_ACCEPTED)
    Questie:RegisterEvent("QUEST_WATCH_UPDATE", QuestieEventHandler.QUEST_WATCH_UPDATE);
    Questie:RegisterEvent("QUEST_TURNED_IN", QuestieEventHandler.QUEST_TURNED_IN)
    Questie:RegisterEvent("QUEST_REMOVED", QuestieEventHandler.QUEST_REMOVED)
    Questie:RegisterEvent("PLAYER_LEVEL_UP", QuestieEventHandler.PLAYER_LEVEL_UP);
    Questie:RegisterEvent("QUEST_LOG_UPDATE", QuestieEventHandler.QUEST_LOG_UPDATE);
    Questie:RegisterEvent("MODIFIER_STATE_CHANGED", QuestieEventHandler.MODIFIER_STATE_CHANGED);

    --TODO: QUEST_QUERY_COMPLETE Will get all quests the character has finished, need to be implemented!

    -- Nameplate / Tar5get Frame Objective Events
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated);
    Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed);
    Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame);

    -- Initialize Coordinates
    QuestieCoords.Initialize();

    -- Initialize questiecomms
    --C_ChatInfo.RegisterAddonMessagePrefix("questie")
    -- JoinTemporaryChannel("questie")
    --Questie:RegisterEvent("CHAT_MSG_ADDON", QuestieComms.MessageReceived)

    -- Initialize Journey Window
    QuestieJourney.Initialize();


    -- Register Slash Commands
    Questie:RegisterChatCommand("questieclassic", "QuestieSlash")
    Questie:RegisterChatCommand("questie", "QuestieSlash")

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", options)
    self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Questie", "Questie");

    --Initialize the DB settings.
    Questie:debug(DEBUG_DEVELOP, string.format(L['DEBUG_CLUSTER'], Questie.db.global.clusterLevel))
    QUESTIE_NOTES_CLUSTERMUL_HACK = Questie.db.global.clusterLevel;


    -- Creating the minimap config icon
    Questie.minimapConfigIcon = LibStub("LibDBIcon-1.0");
    Questie.minimapConfigIcon:Register("MinimapIcon", minimapIconLDB, Questie.db.profile.minimap);

    -- Update the default text on the map show/hide button for localization
    if Questie.db.char.enabled then
        Questie_Toggle:SetText(L['QUESTIE_MAP_BUTTON_HIDE']);
    else
        Questie_Toggle:SetText(L['QUESTIE_MAP_BUTTON_SHOW']);
        QuestieQuest:ToggleNotes(false)
    end

    -- Update status of Map button on hide between play sessions
    if Questie.db.global.mapShowHideEnabled then
        Questie_Toggle:Show();
    else
        Questie_Toggle:Hide();
    end
end

function Questie:OnUpdate()

end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end

function Questie:QuestieSlash(input)

    input = string.trim(input, " ");

    -- /questie
    if input == "" or not input then
        _QuestieOptions.OpenConfigWindow();

        if QuestieJourney:IsShown() then
            QuestieJourney.toggleJourneyWindow();
        end
        return ;
    end

    -- /questie help || /questie ?
    if input == "help" or input == "?" then
        print(Questie:Colorize(L['SLASH_HEAD'], 'yellow'));
        print(Questie:Colorize(L['SLASH_CONFIG'], 'yellow'));
        print(Questie:Colorize(L['SLASH_TOGGLE_QUESTIE'], 'yellow'));
        print(Questie:Colorize(L['SLASH_MINIMAP'], 'yellow'));
        print(Questie:Colorize(L['SLASH_JOURNEY'], 'yellow'));
        return;
    end

    -- /questie toggle
    if input == "toggle" then
        QuestieQuest:ToggleNotes();

        -- CLose config window if it's open to avoid desyncing the Checkbox
        if _QuestieOptions.configFrame and _QuestieOptions.configFrame:IsShown() then
             _QuestieOptions.configFrame:Hide();
        end
        return;
    end

    if input == "reload" then
        QuestieQuest:SmoothReset()
        return
    end

    -- /questie minimap
    if input == "minimap" then
        Questie.db.profile.minimap.hide = not Questie.db.profile.minimap.hide;

        if Questie.db.profile.minimap.hide then
            Questie.minimapConfigIcon:Hide("MinimapIcon");
        else
            Questie.minimapConfigIcon:Show("MinimapIcon");
        end
        return;
    end

    -- /questie journey
    if input == "journey" then
        QuestieJourney.toggleJourneyWindow();

        if _QuestieOptions.configFrame and _QuestieOptions.configFrame:IsShown() then
            _QuestieOptions.configFrame:Hide();
       end
        return;
    end

    print(Questie:Colorize("[Questie] :: ", 'yellow') .. string.format(L['SLASH_INVALID'] .. Questie:Colorize('/questie help', 'yellow')));
end

function Questie:Colorize(str, color)
    local c = '';

    if color == 'red' then
        c = '|cffff0000';
    elseif color == 'gray' then
        c = '|cFFCFCFCF';
    elseif color == 'purple' then
        c = '|cFFB900FF';
    elseif color == 'blue' then
        c = '|cB900FFFF';
    elseif color == 'yellow' then
        c = '|cFFFFB900';
    end

    return c .. str .. "|r"
end

function Questie:GetClassColor(class)

    class = string.lower(class);

    if class == 'druid' then
        return '|cFFFF7D0A';
    elseif class == 'hunter' then
        return '|cFFABD473';
    elseif class == 'mage' then
        return '|cFF69CCF0';
    elseif class == 'paladin' then
        return '|cFFF58CBA';
    elseif class == 'priest' then
        return '|cFFFFFFFF';
    elseif class == 'rogue' then
        return '|cFFFFF569';
    elseif class == 'shaman' then
        return '|cFF0070DE';
    elseif class == 'warlock' then
        return '|cFF9482C9';
    elseif class == 'warrior' then
        return '|cFFC79C6E';
    else
        return '|cffff0000'; -- error red
    end
end

function Questie:Error(...)
    Questie:Print("|cffff0000[ERROR]|r", ...)
end

function Questie:error(...)
    Questie:Error(...)
end

--debuglevel = 5 --1 Critical, 2 ELEVATED, 3 Info, 4, Develop, 5 SPAM THAT SHIT YO
--DEBUG_CRITICAL = "1DEBUG"
--DEBUG_ELEVATED = "2DEBUG"
--DEBUG_INFO = "3DEBUG"
--DEBUG_DEVELOP = "4DEBUG"
--DEBUG_SPAM = "5DEBUG"

function Questie:Debug(...)
    if(Questie.db.global.debugEnabled) then
        if(Questie.db.global.debugLevel < 5 and select(1, ...) == DEBUG_SPAM)then return; end
        if(Questie.db.global.debugLevel < 4 and select(1, ...) == DEBUG_DEVELOP)then return; end
        if(Questie.db.global.debugLevel < 3 and select(1, ...) == DEBUG_INFO)then return; end
        if(Questie.db.global.debugLevel < 2 and select(1, ...) == DEBUG_ELEVATED)then return; end
        if(Questie.db.global.debugLevel < 1 and select(1, ...) == DEBUG_CRITICAL)then return; end
        --Questie:Print(...)
        if not Questie.debugSession then
            Questie.debugSession = GetTime()
            if not QuestieConfigCharacter.log then QuestieConfigCharacter.log = {} end
            QuestieConfigCharacter.log[Questie.debugSession] = {};
        end
        local entry = {}
        entry.time = GetTime()
        entry.data = {...}
        table.insert(QuestieConfigCharacter.log[Questie.debugSession], entry)
        if Questie.db.global.debugEnabledPrint then
            Questie:Print(...)
        end
    end
end

function Questie:debug(...)
    Questie:Debug(...)
end
