
-- ==================== BYPASS ENGINE (copied from Roxz_gaming) ====================
if _G._BYPASS_LOADED then return end
_G._BYPASS_LOADED = true

local noop = function() return true end
local retFalse = function() return false end
local retZero = function() return 0 end
local retEmpty = function() return {} end
local retTrue = function() return true end
local retEmptyString = function() return "" end
local safe_require = function(path) local ok, mod = pcall(require, path); return ok and mod or nil end
local isValid = slua.isValid

-- modulePatches (full table from Roxz_gaming)
local modulePatches = {
    ["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"] = {
        methods = {
            ControlMHActive = noop, Tick = noop, OnTick = noop, ReceiveTick = noop, MHActiveLogic = noop,
            TriggerAvatarCheck = noop, StartAvatarCheck = noop, ReportItemID = noop, OnReportItemID = noop,
            ReceiveAnyDamage = noop, OnWeaponHitRecord = noop, ShowSecurityAlert = noop, StaticShowSecurityAlertInDev = noop,
            SendHisarData = noop, OnLogin = noop, ValidateSecurityData = noop, CheckMemoryIntegrity = noop,
            ReportAbnormalMemory = noop, OnMemoryScanComplete = noop, SendDetectionResult = noop, TriggerClientScan = noop,
            SendAntiDataFlow = noop, SendHitFireBtnFlow = noop, SkipAlertServer = function() end,
            CheckWeaponIntegrity = retTrue, CheckAvatarIntegrity = retTrue, CheckBulletIntegrity = retTrue,
            OnGameModeType = noop,
        },
        fields = { bMHActive = false, mHActive = 0 },
        retvals = { GetNetAvatarItemIDs = retEmpty, GetCurWeaponSkinID = retZero, GetDetectionResult = retEmpty },
        custom = function(m)
            if m.__inner_impl then
                local i = m.__inner_impl
                i.SendAntiDataFlow = noop; i.SendHitFireBtnFlow = noop; i.OnBattleResult = noop; i.SendHisarData = noop
            end
            if m.BlackList then for k in pairs(m.BlackList) do m.BlackList[k] = nil end end
            if m.SkipAlertServer then pcall(m.SkipAlertServer, m) end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Security.SafetyDetectionSubsystem"] = {
        methods = { DetectAbnormal = noop, ReportAbnormal = noop, OnDetectionResult = noop, TriggerSafetyScan = noop },
        retvals = { GetScanResults = retEmpty, IsAnomalyDetected = retFalse },
    },
    _G_AvatarCheckCallback = {
        table = "_G.AvatarCheckCallback",
        methods = {
            StartAvatarCheck = noop, OnReportItemID = noop,
            PostPlayerControllerLoginInit = function(pc)
                pcall(function()
                    if pc and pc.HiggsBosonComponent then
                        pc.HiggsBosonComponent:ControlMHActive(0)
                        pc.HiggsBosonComponent.bMHActive = false
                    end
                end)
            end
        }
    },
    ["GameLua.Mod.BaseMod.Common.Security.PakIntegrityChecker"] = {
        methods = { ShowPakMismatchAlert = noop },
        retvals = { Verify = retFalse, CheckPakFile = retZero, GetPakStatus = retZero }
    },
    ["client.slua.logic.pak.logic_pak_verify"] = {
        retvals = { Verify = retFalse, CheckPakFile = retZero, GetPakStatus = retZero }
    },
    _G_STExtra = {
        table = "_G.STExtraBlueprintFunctionLibrary",
        retvals = { CheckFileIntegrity = retFalse, VerifySignature = retFalse, CheckGameLuaIntegrity = retFalse }
    },
    _G_TssSDK = {
        table = "_G.TssSDK",
        methods = {
            ReportData = noop, SendToServer = noop, SetUserInfo = noop,
            Init = noop, Start = noop, Verify = retTrue, CheckIntegrity = retTrue, Check = retTrue,
        },
        retvals = { GetSignature = function() return "BYPASSED" end }
    },
    _G_TssSDKHelper = { table = "_G.TssSDKHelper", methods = { ReportData = noop } },
    _G_Bugly = { table = "_G.Bugly", methods = { ReportException = noop, SetCustomData = noop } },
    _G_Beacon = { table = "_G.Beacon", methods = { Report = noop } },
    _G_CrashSight = { table = "_G.CrashSight", methods = { ReportException = noop, SetCustomData = noop, Log = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"] = {
        methods = {
            ClientRPC_SyncBanID = noop, ClientRPC_StrongTips = noop, ClientRPC_NormalTips = noop, Notify = noop,
            ClientRPC_NotifyBan = noop, ClientRPC_NotifyPunish = noop, ClientRPC_NotifyIllegalProgram = noop
        },
        custom = function(m) if m.__inner_impl then m.__inner_impl.SyncBanInfo = noop end end,
    },
    ["client.slua.logic.ban.ClientBanLogic"] = {
        methods = {
            OnSyncBanInfo = noop, OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop, OnVoiceBanSuccess = noop,
            OnSyncMicSuspicious = noop, OnSyncMicPreFilter = noop, OnNotifyWarningTips = noop, ReqBanInfo = noop
        },
    },
    ["client.slua.logic.ban.BanTipsLogic"] = {
        methods = { ShowBanTips = noop, ShowPunishTips = noop, ShowWarningTips = noop, OnReceiveBanNotice = noop }
    },
    _G_ban_util = { table = "_G.ban_util", retvals = { CheckBanStatus = retFalse, GetBanTime = retZero, IsBanForever = retFalse } },
    _G_logic_tt_ban = {
        table = "_G.logic_tt_ban",
        methods = { CheckIfCanCreateRole = noop },
        retvals = { JumpAppealURL = retFalse, GetCarrierInfo = function() return '[{"mcc":"000"}]' end }
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"] = {
        methods = {
            _OnHawkSync = noop, _OnHawkReportSuccess = noop, _StartExitGameTimer = noop,
            _OnRecvInspectorBroadcastCount = noop, SendReportTLog = noop, ReportCheat = noop,
            _OnHawkFlag = noop, ReportPlayerFlag = noop, RequestFlagPlayer = noop, SendFlagReport = noop,
            RequestImprison = noop, IsDuringHawkEyePatrol = retFalse, HasReported = retTrue,
            _InitHawkEyePatrolSubsystem = noop, _CollectBeWatchedPlayerInfo = noop, ServerRPC_HawkReportCheat = noop,
        },
        retvals = { CanInspectorBroadcast = retFalse },
        custom = function(mod)
            if mod.__inner_impl then
                local i = mod.__inner_impl
                i._OnHawkSync = noop; i._OnHawkReportSuccess = noop; i.TryShowReportedTips = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem"] = {
        custom = function(mod)
            if mod.__inner_impl then
                local i = mod.__inner_impl
                i._OnHawkSync = noop; i._OnHawkReportSuccess = noop; i.TryShowReportedTips = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem"] = {
        custom = function(m)
            if m.OnSpectatorReplayChanged then
                local o = m.OnSpectatorReplayChanged
                m.OnSpectatorReplayChanged = function(...)
                    _G.IsBeingWatched = true
                    return o(...)
                end
            end
        end,
    },
    _G_ServerDataMgr = {
        table = "_G.ServerDataMgr",
        custom = function(m)
            if m.DeletablePlayerResultKey then
                for _, k in ipairs({
                    "SuspiciousHitCount", "EspTotalSimTraceCnt", "EspTotalImeFocusCnt",
                    "ClientGravityAnomalyCount", "FireCount", "SpeedCheatCount", "JumpCount", "VehicleSpeedHackCount",
                    "HeadshotCount", "KillCount", "Accuracy", "FlagCount", "TotalFlags", "IsFlagged",
                    "FlaggedByHawkEye", "FlaggedByInspection", "FlagTimestamp", "FlagLevel", "FlagSeverity",
                }) do m.DeletablePlayerResultKey[k] = true end
            end
            if m.FlagCount then m.FlagCount = 0 end
            if m.TotalFlags then m.TotalFlags = 0 end
            if m.IsFlagged then m.IsFlagged = false end
            if m.FlaggedByHawkEye then m.FlaggedByHawkEye = false end
            if m.FlaggedByInspection then m.FlaggedByInspection = false end
            if m.FlagTimestamp then m.FlagTimestamp = 0 end
            if m.FlagLevel then m.FlagLevel = 0 end
            if m.FlagSeverity then m.FlagSeverity = 0 end
        end
    },
    ["client.slua.logic.report.ToolReportUtil"] = {
        retvals = { IsReleaseVersion = retFalse, IsWhite = retFalse, GetReportSwitch = retFalse }
    },
    _G_ClientToolsReport = { table = "_G.ClientToolsReport", methods = { SendReport = noop, SendException = noop } },
    _G_ReportPlatformCrashKit = { table = "_G.ReportPlatformCrashKit", methods = { Send = noop, ForceSend = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem"] = {
        methods = {
            CheckHitIntegrity = noop, InitSession = noop, OnBattleEnd = noop,
            LuaFunc1 = retTrue, LuaFunc4 = retFalse, LuaFunc5 = retFalse,
            LuaFunc6 = retFalse, LuaFunc7 = retFalse, LuaFunc8 = retFalse,
            LuaFunc9 = noop,
        }
    },
    ["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"] = {
        methods = { OnHandleBehaviorScore = noop, AIPerceptionScore = noop, ReportBehavior = noop },
        retvals = { CalcFinalScore = retZero }
    },
    _G_AntiAddictionHandler = {
        table = "_G.AntiaddctionHandler",
        methods = { send_anti_addiction_req = noop, send_anti_addiction_notify = noop, on_check_nonage_anti_work = noop }
    },
    _G_AccessRestrictionHandler = {
        table = "_G.AccessRestrictionHandler",
        methods = { send_access_restriction_req = noop, send_access_restriction_notify = noop, on_player_cheat_state_notify = noop }
    },
    _G_GodzillaBanHandler = {
        table = "_G.GodzillaBanHandler",
        methods = { send_godzilla_ban_req = noop, send_godzilla_unban_req = noop }
    },
    _G_logic_deleteaccount = {
        table = "_G.logic_deleteaccount",
        retvals = { ForceDeleteAccount = retFalse },
        methods = { OnReceiveDeleteNotify = noop }
    },
    _G_compliance_util = { table = "_G.compliance_util", methods = { CheckCompliance = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"] = {
        methods = {
            OnInit = noop, _OnPlayerKilledOtherPlayer = noop, _RecordFatalDamager = noop,
            _OnDeathReplayDataWhenFatalDamaged = noop, _RecordMurdererFromDeathReplayData = noop,
            _RecordTeammatePlayerInfo = noop, _OnBattleResult = noop, _OnShowQuickReportMutualExclusiveUI = noop,
            GetFatalDamagerMap = retEmpty, GetCachedTeammateName2InfoMap = retEmpty,
            GetTeammateName2InfoMapDuringBattle = retEmpty, GetCurrentNotInTeamHistoricalTeammateMap = retEmpty,
            GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end,
            ReportSuspiciousPlayer = noop, SubmitReport = noop, ProcessReport = noop,
            ClientRPC_SyncFatalDamagerMap = noop,
        },
        custom = function(m)
            if m.__inner_impl then
                m.__inner_impl._OnSyncFatalDamage = noop
                m.__inner_impl._OnPlayerKilledOtherPlayer = noop
                m.__inner_impl._SyncBattleResult = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Security.DSReportPlayerSubsystem"] = {
        methods = {
            OnInit = noop, _OnNearDeathOrRescued = noop, _OnCharacterDied = noop, _OnTeammateDamage = noop,
            _OnPlayerSettlementStart = noop, _AddKnockDownerToBattleResult = noop, _AddKillerToBattleResult = noop,
            _AddTeammateMurderToBattleResult = noop, _AddFatalDamagerMapToBattleResult = noop,
            _AddMLKillerUIDToBattleResult = noop, _SaveHistoricalTeammateInfo = noop, _RecordFatalDamager = noop,
            _RecordTeammateMurderer = noop,
            _AddEnemyMapToBattleResult = noop, _AddTeammateMapToBattleResult = noop, _SubmitAbnormalData = noop,
            _tUID2InfoMap = retEmpty, ds2history = retEmpty,
        },
    },
    ["GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils"] = {
        retvals = { GetBotType = retZero, IsCharacterDeliverAI = retFalse },
        methods = { RecordFatalDamager = noop, IsUsingHistoricalTeammateInfo = retFalse },
    },
    ["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"] = {
        methods = { ExtractPlayerBasicInfo = retEmpty, LogIf = retFalse },
        custom = function(m)
            if m.EStrategyTypeInReplay then
                m.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
                m.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
                m.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
                m.EStrategyTypeInReplay.FlyingErrorCnt = 0
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate"] = {
        methods = { OnShowMutualExclusiveUI = noop, OnHideMutualExclusiveUI = noop,
            MaliciousTeammateReceiveWarningTips = noop, MaliciousTeammateVictimReceiveTips = noop },
    },
    _G_ClientTlogHandler = { table = "_G.ClientTlogHandler", methods = { send_report_lobby_common_tlog = noop } },
    _G_LoginAndWinTlogHandler = { table = "_G.LoginAndWinTlogHandler", methods = { on_cloud_game_event_notify = noop } },
    _G_tlog_report_utils = { table = "_G.tlog_report_utils", methods = { ReportTLogEvent = noop, ReportImmediate = noop } },
    _G_BasicDataTLogReport = {
        table = "_G.BasicDataTLogReport",
        methods = { OnSendBatchReqMsg = noop, OnImmediateReqMsg = noop, OnMergeReqMsg = noop, send_report_event_duration_log = noop, SendTlog = noop, ReportEvent = noop },
        retvals = { _GetParamData = retEmpty }
    },
    _G_BasicDataClientReport = {
        table = "_G.BasicDataClientReport",
        methods = { ReportImmediate = noop, ReportDelay = noop, OnSendBatchReqMsg = noop, OnImmediateReqMsg = noop, OnMergeReqMsg = noop },
        retvals = { _IsCanReport = retFalse }
    },
    _G_BasicDataReport = {
        table = "_G.BasicDataReport",
        methods = { ReportImmediate = noop, ReportDelay = noop, OnMergeReqMsg = noop, OnImmediateReqMsg = noop, OnSendBatchReqMsg = noop, _BatchReqMsg = noop }
    },
    _G_puffer_tlog = { table = "_G.puffer_tlog", methods = { report_download_tlog = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem"] = { methods = { SendICExceptionTLog = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"] = {
        methods = { ReportFightData = noop, ReportPlayerWeapon = noop },
        retvals = { GetSimpleFightData = retEmpty }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"] = {
        methods = {
            _OnReportServerJumpFlow = noop, _OnReportTeleportFlow = noop, _OnReportSpeedHackFlow = noop,
            ReportServerJumpFlow = noop, CollectJumpData = noop,
        },
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"] = { methods = { HandleKillTlog = noop } },
    _G_ClientErrorReportHandler = {
        table = "_G.ClientErrorReportHandler",
        methods = { send_client_error_report = noop, send_client_crash_report = noop, send_client_tools_batch_report_req = noop }
    },
    _G_BattleReportHandler = {
        table = "_G.BattleReportHandler",
        methods = {
            send_battle_report = noop, send_battle_result = noop, send_vod_game_report_req = noop,
            send_batch_get_vod_info_req = noop, send_get_game_report_req = noop, send_batch_get_game_report_req = noop,
            send_get_game_report_by_uid_req = noop
        }
    },
    _G_BugHandler = { table = "_G.BugHandler", methods = { send_report_bug_info = noop, send_report_bug_feedback = noop } },
    _G_LobbyPingReportHandler = { table = "_G.LobbyPingReportHandler", methods = { send_lobby_ping_report = noop, send_ingame_ping_report = noop } },
    _G_WeekRportHandler = { table = "_G.WeekRportHandler", methods = { send_week_report = noop, send_week_detail = noop } },
    _G_logic_complaint = {
        table = "_G.logic_complaint",
        methods = { SendComplaintReq = noop, Submit = noop, ReportPlayer = noop, ShowComplaint = noop, ShowHandle = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.EscapeBattleResultShowOBResultLogic"] = {
        methods = { OnBattleResult = noop, OnResultProcessStart = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowOBResultLogic"] = {
        methods = { OnBattleResult = noop, OnResultProcessStart = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowResultLogic"] = {
        methods = {
            OnBattleResult = noop, OnResultProcessStart = noop, OnResultProcessContinue = noop,
            ReceiveData = noop, SendEndFlow = noop, OnReport = noop, ShowResult = noop, ShowResultInternal = noop,
            StopResultProcess = noop
        }
    },
    _G_EmulatorHandler = { table = "_G.EmulatorHandler", methods = { send_emulator_info = noop } },
    _G_emulator_scanner = {
        table = "_G.emulator_scanner",
        methods = { StartScan = noop, ReportScanResult = noop },
        retvals = { GetScanResult = retFalse }
    },
    _G_LoginVerifyHandler = { table = "_G.LoginVerifyHandler", methods = { send_login_verify_req = noop, send_device_verify_req = noop } },
    _G_logic_ds_monitor = { table = "_G.logic_ds_monitor", methods = { OnRecordMsg = noop, OnReportMsg = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"] = {
        methods = { StartToCheck = noop, OnReceiveRTT = noop, OnReceiveJitter = noop, ReportAbnormal = noop, ResetData = noop }
    },
    ["GameLua.Dev.Subsystem.ShootVerifySubSystemClient"] = { methods = { OnShootVerifyFailed = noop, SendVerifyData = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker"] = { methods = { CheckFuncUpgradedWeaponKill = noop } },
    _G_logic_chat_voice_report = { table = "_G.logic_chat_voice_report", methods = { ReportVoiceData = noop, ReportVoiceText = noop } },
    _G_logic_chat_voice_doctor = { table = "_G.logic_chat_voice_doctor", methods = { UploadVoiceLog = noop, UploadVoiceException = noop } },
    _G_logic_home_audit_state = { table = "_G.logic_home_audit_state", methods = { SendAuditState = noop, ReportAuditResult = noop } },
    _G_logic_home_report = { table = "_G.logic_home_report", methods = { ReportHomeData = noop, ReportHomeVisitor = noop, ShowInGameReportUI = noop, SendReport = noop } },
    _G_gem_report_utils = {
        table = "_G.gem_report_utils",
        methods = { ReportGemData = noop, ReportGemPurchase = noop, ReportEventImmediate = noop },
    },
    _G_ChatHandler = { table = "_G.ChatHandler", methods = { send_report_info = noop, send_report_info_mic = noop } },
    _G_ClientReplayDataReporter = { table = "_G.ClientReplayDataReporter", methods = { ReportIntArrayData = noop, ReportFloatArrayData = noop, ReportUInt8ArrayData = noop } },
    ["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"] = {
        custom = function(m)
            if m.uCompletePlayBack then
                m.uCompletePlayBack.AddRecordMLAIInfo = noop
                m.uCompletePlayBack.StopRecording = noop
            end
            if m.ReportAllPlayerInfo then m.ReportAllPlayerInfo = noop end
            if m.ReportFrameData then m.ReportFrameData = noop end
            if m.ReportPlayerInput then m.ReportPlayerInput = noop end
        end,
    },
    _G_GameSafeCallbacks = {
        table = "_G.GameSafeCallbacks",
        methods = {
            PostPlayerControllerLoginInit = noop, OnDSGlueHiaInit = noop, CharacterReceiveBeginPlay = noop,
            DoAttackFlowStrategy = noop, RecordStrategyTimestampInReplay = noop, EditorIncreaseTotalStatisticCnt = noop
        },
        retvals = { GetScriptReportContent = function() return "" end }
    },
    ["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"] = {
        methods = { ReportException = noop, ReplayReportData = noop, ReportGameException = noop },
        retvals = { BugglyPostExceptionFull = retFalse, CheckCanBugglyPostException = retFalse }
    },
    _G_NetUtil = { table = "_G.NetUtil", methods = { SendTss = noop, SendToServer = noop, SendToDS = noop } },
    ["UnrealNet"] = {
        global = true,
        custom = function(m)
            if not m then return end
            if m.FilterNetworkException then
                local o = m.FilterNetworkException
                m.FilterNetworkException = function(et, em)
                    if em and type(em) == "string" then
                        local le = em:lower()
                        if le:find("cheatdetected") or le:find("idipban") or le:find("dataerror") or le:find("datamismatch")
                           or le:find("security") or le:find("integrity") or le:find("hashfail") or le:find("flag") then
                            return false
                        end
                    end
                    return o(et, em)
                end
            end
            m.HandleNetworkExceptionReport = noop
            m.HandleNetworkConnectionClosed = noop
            m.HandleSpectateException = noop
        end
    },
    ["GameLua.Mod.BaseMod.Client.Security.Gokuba"] = {
        custom = function(m)
            if m.ForwardFeature then
                m.ForwardFeature = function() return {0, 0, 0, 0, 0} end
            end
            if m.TimerHandle then
                pcall(function()
                    local time_ticker = require("common.time_ticker")
                    time_ticker.RemoveTimer(m.TimerHandle)
                end)
                m.TimerHandle = nil
            end
        end
    },
    ["GameLua.Mod.BaseMod.Common.Security.CoronaUploader"] = { methods = { Upload = noop, Flush = noop } },
    ["GameLua.Mod.BaseMod.Client.Login.LoginLock"] = { methods = { Lock = noop, OnLoginBan = noop }, retvals = { CheckBan = retFalse } },
    ["GameLua.Mod.BaseMod.GamePlay.Battle.BattleResultUploader"] = { methods = { Upload = noop } },
    ["client.slua.logic.ClientAppStat"] = { methods = { Report = noop, Flush = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.DeviceFingerprint"] = {
        methods = { Collect = noop, Sync = noop, GetHash = function() return "unknown" end }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSDeviceCheck"] = { methods = { VerifyClientDevice = retTrue, ReportMismatch = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.IntegrityCheck"] = { methods = { Run = noop, Verify = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.APKIntegrity"] = { methods = { CheckSignature = retTrue, CheckInstallSource = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.LibCheck"] = {
        methods = { Verify = retTrue, Check = retTrue, Scan = noop, Report = noop },
        retvals = { IsLibValid = retTrue, GetTamperedLibs = retEmpty }
    },
    _G_TDataMaster = {
        table = "_G.TDataMaster",
        methods = { Report = noop, ReportDeviceInfo = noop, SendHardwareHash = noop, CollectTelemetry = noop, SendData = noop, Sync = noop, Flush = noop },
        custom = function(m)
            if m then for k, v in pairs(m) do if type(v) == "function" then m[k] = noop end end end
        end,
    },
    _G_DeviceInfo = {
        table = "_G.DeviceInfo",
        methods = { GetDeviceID = function() return "unknown" end, GetIMEI = function() return "000000000000000" end, CollectSysInfo = noop }
    },
    ["client.slua.logic.platform.platform_db"] = { methods = { Scan = noop, CheckIntegrity = retFalse, ReportCorruption = noop } },
    ["xunyou_cache_scan"] = { methods = { StartScan = noop, GetResult = retEmpty } },
    _G_SecurityTlogQueue = { table = "_G.SecurityTlogQueue", methods = { Flush = noop, Add = noop } },
    _G_PufferDownloadReport = { table = "_G.PufferDownloadReport", methods = { ReportDownload = noop, ReportError = noop } },
    _G_ReplayRecordSecurity = { table = "_G.ReplayRecordSecurity", methods = { InjectMeta = noop, Validate = noop } },
    _G_GameServerHeartbeat = { table = "_G.GameServerHeartbeat", methods = { ReportMissedBeat = noop, CheckAlive = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.AntiDebug"] = { methods = { Check = retFalse, Report = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.SecureBootCheck"] = { methods = { VerifyBoot = retTrue } },
    ["GameLua.Mod.BaseMod.DS.Security.DSPlayerValidCheck"] = { methods = { Validate = retTrue, ReportSuspicious = noop } },
    ["client.slua.logic.common.logic_common_legal_msg"] = {
        custom = function(m)
            if m.ShowOnePopUI then
                local o = m.ShowOnePopUI
                m.ShowOnePopUI = function(self, params)
                    if params and params.title and params.title:find("SECURITY") then return end
                    return o(self, params)
                end
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"] = {
        methods = {
            AskForInspector = noop, ReportEnemy = noop, KickOutOneTeam = noop,
            OnReceiveInspectCmd = noop, ClientReportData = noop, SendReportToInspector = noop,
            SendKickOutOneTeam = noop, ClientNotifyInspectorImplementation = noop, RecvNotifyInspector = noop,
        },
    },
    ["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"] = {
        methods = {
            ServerKickOutOneTeamByPlayerImplementation = noop, AddReportedCount = noop,
            AddInspectionRecord = noop, BanPlayerByInspection = noop,
            BroadCastToAllInspector = noop, ServerReportToInspectorImplementation = noop,
            InitPlayerInspectionInfo = noop,
        },
        fields = { MAX_ASK_FOR_INSPECTOR_TIME = 0, ASK_FOR_INSPECTOR_INTERVAL = 99999 },
        custom = function(m)
            if m.__inner_impl then
                m.__inner_impl.IsGameModeAllowed = retTrue
            end
        end,
    },
    ["client.slua.logic.CustomerService.LogicSafeStation"] = {
        methods = { UploadVideoEvidence = noop, ReportPlayerBehavior = noop },
    },
    ["client.slua.logic.CustomerService.LogicCustomerService"] = {
        methods = { SendComplaint = noop, SendFeedback = noop },
    },
    ["GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.AmphibiousBoatTLogFeature"] = {
        methods = { RecordMovement = noop, StartRecordMovement = noop },
    },
    ["client.logic.data.profile_report_cfg"] = { methods = { SendReport = noop } },
    ["GameLua.Mod.BaseMod.Client.ClientInGameCreditLogic"] = {
        methods = {
            _SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice = noop,
            ShowReturnLobbyIfFirstExitTeamBeforeBoarding = retFalse,
            OnReceiveCreditScoreChange = noop,
            _IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = retFalse,
            SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = noop,
        },
    },
    ["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem"] = { methods = { IsDebugPanelEnalbedCli = noop } },
    ["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeModeDeathRecordSubsystem"] = { methods = { OnPlayerKilled = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem"] = {
        methods = {
            HandleEnterFighting = noop, InitializePlayerInputInfo = noop,
            AddOneAFKInfo = noop, SetPlayerAFKState = noop,
            ResetPlayerInputInfo = noop, PlayerHaveAction = noop, ReportAFK = noop,
            CheckAFK = retFalse,
        },
    },
    ["GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"] = { methods = { SendAFKTips = noop, OnHandleLostConnection = noop } },
    ["GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"] = {
        methods = {
            RealLogoutTimer = noop, AddToLogQue = noop, DoPrint = noop,
            OnAIPawnDied = noop, OnAIPawnReceiveDamage = noop, OnAIPawnEnemyChange = noop,
        },
        fields = { LogQueue = {} },
    },
    ["client.slua.logic.data.data_mgr"] = { retvals = { GetWeaponSkinSoundVolumeInfoByGroup = retZero } },
    ["TApmHelper"] = { methods = { postEvent = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.LuaIntegrityCheck"] = { methods = { Run = noop, Verify = retTrue, Check = retTrue } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientDeviceCheckSubsystem"] = {
        methods = { StartCheck = noop, ReportResult = noop },
        retvals = { IsDeviceSafe = retTrue },
    },
    ["GameLua.Mod.BaseMod.Client.Security.SpectatorAndReplaySubsystem"] = { methods = { SendReport = noop } },
    ["client.slua.logic.login.logic_version_update"] = {
        methods = { CheckVersion = noop, CheckUpdate = noop, IsNeedUpdate = retFalse, GetVersion = function() return "4.4.0" end, ShowUpdateDialog = noop }
    },
    ["client.slua.logic.version.logic_update"] = { methods = { CheckUpdate = noop, ForceUpdate = noop, IsForceUpdate = retFalse } },
    ["client.slua.logic.ban.logic_ban"] = {
        methods = { GetBanEndTime = function() return 0 end, IsInBanTime = retFalse, CheckBanStatus = retFalse, GetBanReason = retEmpty, GetBanTime = retZero }
    },
    ["client.slua.logic.login.logic_login_ban"] = {
        methods = { CheckCanLogin = retTrue, GetBanInfo = function() return { end_time = 0 } end, IsBanned = retFalse, IsSecurityBan = retFalse }
    },
    ["GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"] = { methods = { DelayKickOutPlayer = noop, ActiveKickNotify = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientFlagSubsystem"] = {
        methods = {
            EvaluateFlags = noop,
            GetFlagLevel = retZero,
            GetFlagBanDuration = retZero,
            IsFlagged = retFalse,
            ReportFlag = noop,
            SyncFlagStatus = noop,
            IncreaseFlagCount = noop,
            ResetFlags = noop,
        },
        retvals = { IsFlagged = retFalse },
        fields = { FlagCount = 0, FlagLevel = 0, FlagSeverity = 0 },
    },
    ["client.slua.logic.ban.logic_flag_ban"] = {
        methods = {
            GetFlagBanEndTime = function() return 0 end,
            IsFlagBanned = retFalse,
            GetFlagBanDuration = retZero,
            CheckFlagBan = retFalse,
        }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem"] = {
        methods = { _UpdateTTKRecords = noop, _UpdateOperatingFrequency = noop }
    },
    ["GameLua.Mod.Borderland.Gameplay.Subsystem.TLogSubsystem"] = { methods = { OnInit = noop } },
    _G_TLogSubsystem = { table = "_G.TLogSubsystem", methods = { OnInit = noop } },
    ["client.slua.logic.download.report.logic_mini_pak_gem"] = {
        methods = { StartReport = noop, ReportGemLog = noop, SetCurDownloadSize = noop }
    },
    ["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogManager"] = {
        methods = {
            OnReceiveBattleResults = noop,
            AddValTLog = noop,
            SetValTLog = noop,
            SendReportLobby = noop,
        },
        fields = { ClientTlogData = {} },
    },
    ["GameLua.Mod.SocialIsland.DS.Battle.RacingAntiCheatLogic"] = {
        methods = {
            StartDetectTimer = noop, StopDetectTimer = noop,
            DetectVehicleFloating = noop, HandleFloatingCheat = noop,
            HandleSpeedCheat = noop, HandlePlayerPassCheckBelt = noop,
        },
    },
    ["GameLua.Dev.ClientCloudGM"] = { methods = { HandleCloudGMCMDStr = noop } },
    ["GameLua.Mod.BaseMod.Client.Dev.ClientCloudGM"] = { methods = { HandleCloudGMCMDStr = noop } },
    ["GameLua.Mod.BaseMod.Common.RealTimeBan.RealTimeBan"] = {
        methods = {
            OnPlayerWithRealTimeBan = noop,
            ShowAlias = noop,
            HandleEnterGameModeFightingState = noop,
            GetTipsID = retZero,
        },
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeDistanceUI"] = {
        methods = { _RefreshUI = noop, _IsShouldShow = retFalse }
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeNextPatrolWindow"] = {
        methods = { OnShow = noop }
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeReportWindow"] = {
        methods = { _OnClickSubmit = noop, _RefreshWindow = noop, RegistEvents = noop }
    },
    ["GameLua.Mod.BaseMod.Client.Security.SecurityClientUtils"] = {
        methods = {
            HasOtherTeammateOffline = retFalse,
            HasOtherHealthyOnlineTeammate = retFalse,
            IsMyHealthStatusHealthy = retTrue,
            IsMyHealthStatusAlive = retTrue,
            GetMyHealthStatus = function() return 1 end,
        }
    },
    ["GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic"] = {
        methods = {
            OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop,
            OnSyncBanInfo = noop, OnNotifyWarningTips = noop,
            VoiceBanEndTime = 0, bEnableVoiceReport = false,
        },
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientBanLogic"] = {
        methods = {
            OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop,
            OnSyncBanInfo = noop, OnNotifyWarningTips = noop,
        },
    },
    ["ScreenshotMaker"] = {
        custom = function(m)
            if not m then return end
            m.MakePicture = function() return "" end
            m.ReMakePicture = function() return "" end
            m.HasCaptured = function() return true end
        end,
    },
    ["client.slua.logic.ugc.UGCNewTLogReport"] = {
        methods = { SendExposeReq = noop, SendInteractionReq = noop, TLogReport = noop }
    },
    ["client.slua.logic.ugc.logic_ugc_tlog"] = {
        methods = { SendModTLog = noop, ReportStay = noop }
    },
    ["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil"] = {
        methods = { ReportGeneralCountByBRPhase = noop, ReportCommonTLogDataByBRPhase = noop }
    },
    ["ReportCrashKitFeature"] = {
        custom = function(m) if m and m.ReportCharacterAttachedOnVehicleException then m.ReportCharacterAttachedOnVehicleException = noop end end,
    },
    ["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportSubsystemReporter"] = {
        custom = function(m)
            if m then
                m.ReportIntArrayData = noop
                m.ReportUInt8ArrayData = noop
                m.ReportFloatArrayData = noop
            end
        end,
    },

    -- ===== New patches from Roxz_gaming =====
    ["SkillAction_GrenadeThrowReport"] = {
        methods = {
            ReportGrenadeThrow = noop,
            CheckGrenadeAnimationState = retTrue,
            ValidateThrow = retTrue,
            OnGrenadeThrow = noop,
        },
    },
    ["BanMacro"] = {
        methods = {
            DetectInputVariance = retTrue,
            CheckClickTiming = retFalse,
            AnalyzeClickPattern = retEmpty,
            ReportMacro = noop,
            CheckAllBanTypes = retTrue,
        },
    },
    ["NGActionBanSprint"] = {
        methods = {
            ValidateSprintSpeed = retTrue,
            CheckSpeedHack = retFalse,
            ReportSprintViolation = noop,
        },
    },
    ["ReportGrenadeThrow"] = {
        methods = {
            SendGrenadeReport = noop,
            ReportGrenadeData = noop,
        },
    },
    ["InputVarianceChecker"] = {
        methods = {
            CalculateVariance = retZero,
            IsHumanLike = retTrue,
        },
    },
    ["SpeedhackValidator"] = {
        methods = {
            ValidateSpeed = retTrue,
            IsSpeedhack = retFalse,
            ReportSpeedhack = noop,
        },
    },
    ["HawkEyeSpectatorState"] = {
        methods = {
            OnSpectatorStateChange = noop,
            TrackAimMovement = noop,
            ReportSuspiciousAim = noop,
        },
    },
    ["EmulatorSystem"] = {
        fields = { EmulatorTestMark = true },
        methods = { IsEmulator = retFalse, GetEmulatorName = function() return "NoEmulator" end },
    },
    ["logic_emulator"] = {
        methods = { find_emulator = retFalse, IsSpecialEmulator = retFalse },
    },
    ["VoiceReportSubsystem"] = {
        methods = {
            PLAYER_BAN_GLOBAL_MI = noop,
            ReportSuspicious = noop,
            PreFilterAI = noop,
        },
    },
    ["BugglyReportRecord"] = {
        methods = { Report = noop, Record = noop },
        retvals = { GetProbability = retZero },
    },
    ["PatrollerModule"] = {
        methods = { UpdateStats = noop, GetRank = retZero, AddInspectionRecord = noop },
    },
    ["DSQuickReportMaliciousTeammate"] = {
        methods = {
            _HandleCarrybackFallingDamage = noop,
            _HandleGrenadeDamage = noop,
            _HandleVehicleExplosionDamage = noop,
            ReportMaliciousTeammate = noop,
        },
    },
    ["ClientQuickReportMaliciousTeammate"] = {
        methods = {
            RPC_Client_MaliciousTeammateReceiveWarningTips = noop,
            ShowQuickReportDialog = noop,
            OnDeath = noop,
        },
    },
    ["InspectionSystemKickPlayerConfirm"] = {
        methods = {
            OnConfirmTyped = retTrue,
            CheckConfirmText = retTrue,
        },
    },
    ["RockBandActor"] = {
        custom = function(m)
            if m then
                m._G.IsEditor = false
                m._G.IsTesting = false
            end
        end,
    },
    ["ban_reddot_system"] = {
        methods = {
            EnterSafeStation = noop,
            UpdateRedDot = noop,
            OnBanUpdate = noop,
        },
    },
    ["ban_reddot_data"] = {
        methods = {
            LoadBanRedDotData = noop,
            UpdateBanRedDot = noop,
        },
    },
    ["DSPlayerDataReportSubsystem"] = {
        methods = {
            TrackRescue = noop,
            TrackDieWithoutRevive = noop,
            HandleBattleResult = noop,
            _HandleRescue = noop,
            _HandleDieWithoutRevive = noop,
        },
        custom = function(m)
            if m then
                m.DieWithoutReviveTime = 99999
                if m._OnGameEnd then m._OnGameEnd = noop end
            end
        end,
    },
    ["UGC_AiCopilot_Report"] = {
        methods = {
            ReportContent = noop,
            ReportLowQuality = noop,
            SendReport = noop,
        },
    },
    ["gem_report_utils"] = {
        methods = {
            ReportEventDelay = noop,
            ReportImmediate = noop,
        },
    },
    ["gem_report_config"] = {
        methods = {
            OnNetworkEvent = noop,
            OnBanEvent = noop,
        },
    },
    ["net"] = {
        global = true,
        custom = function(m)
            if m then
                m.DumpPropertySerializationStats = noop
            end
        end,
    },
}

-- Hook require/import
local originalRequire = require
local function hookedRequire(name)
    local mod = originalRequire(name)
    if modulePatches[name] then
        local cfg = modulePatches[name]
        if cfg.custom then pcall(cfg.custom, mod)
        elseif not cfg.global then
            if cfg.methods then for k, v in pairs(cfg.methods) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.retvals then for k, v in pairs(cfg.retvals) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.fields then for k, v in pairs(cfg.fields) do if mod[k] ~= nil then mod[k] = v end end end
        end
    end
    return mod
end
if require ~= hookedRequire then require = hookedRequire end

local originalImport = import
local function hookedImport(name)
    local mod = originalImport(name)
    if modulePatches[name] then
        local cfg = modulePatches[name]
        if cfg.custom then pcall(cfg.custom, mod)
        elseif not cfg.global then
            if cfg.methods then for k, v in pairs(cfg.methods) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.retvals then for k, v in pairs(cfg.retvals) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.fields then for k, v in pairs(cfg.fields) do if mod[k] ~= nil then mod[k] = v end end end
        end
    end
    return mod
end
if import ~= hookedImport then import = hookedImport end

-- ===== Existing bypass functions (copied) =====
local function TssSdkBypass()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"] or package.loaded["client.slua.logic.tss_sdk"]
        if not TssSdk then
            local ok, mod = pcall(require, "TssSdk")
            if ok then TssSdk = mod end
        end
        if not TssSdk then return end

        local bypassFuncs = {
            "GetSdkAntiData", "GameScreenshot", "GameScreenshot2", "IsEmulator",
            "QueryOpts", "GetCommLibValueByKey", "GetShellDyMagicCode", "AddMTCJTask",
            "SetToken", "EnableDisableItem", "InvokeCrashFromShell", "ReInitMrpcs",
            "GetUserTag", "QueryTssLibcAddr", "RegistLibcSendListener", "RegistLibcRecvListener",
            "RegistLibcConnectListener", "RegistLibcCloseListener", "GetMrpcsData2Ptr",
            "GetTPChannelVer", "SetGameChannelIp", "SetValueByKey", "SetChannelHost",
            "SetChannelBuiltinIp", "RecvSecSignature", "PushAntiData3", "QueryRemainsAntiDataCount",
            "GetAntiData3", "DelAntiData3", "SetSecToken", "GetThreadsInfo", "AddTouchEvent",
            "InitSwitchStr", "SetCDNHost", "SetEnabledConnector", "QueryHookInfo", "SetCSLicense",
            "AddAnoTouchEvent", "GetObjVMFuncAddr", "ScanMemory", "ScanSo", "ScanFile",
            "GetRiskFlag", "VerifyFileHash", "CheckKernel", "VerifyBoot", "GetAntiDataQueue",
            "ReportAntiData", "SendAntiData", "ReportSdkData", "SendSdkData", "OnRecvData"
        }
        for _, funcName in ipairs(bypassFuncs) do
            if TssSdk[funcName] then
                TssSdk[funcName] = function(...) return true, "BYPASSED" end
            end
        end

        if TssSdk.antiDataQueue then
            TssSdk.antiDataQueue = {}
            TssSdk.antiDataQueue.push = function() end
            TssSdk.antiDataQueue.pop = function() return nil end
            TssSdk.antiDataQueue.size = function() return 0 end
            TssSdk.antiDataQueue.clear = function() end
        end

        if TssSdk.IsEmulator then TssSdk.IsEmulator = function() return false end end
        if TssSdk.InvokeCrashFromShell then TssSdk.InvokeCrashFromShell = function() return false end end
        if TssSdk.QueryHookInfo then TssSdk.QueryHookInfo = function() return {} end end
        if TssSdk.PushAntiData3 then TssSdk.PushAntiData3 = function() return true end end
        if TssSdk.QueryRemainsAntiDataCount then TssSdk.QueryRemainsAntiDataCount = function() return 0 end end
        if TssSdk.GetAntiData3 then TssSdk.GetAntiData3 = function() return nil end end
        if TssSdk.DelAntiData3 then TssSdk.DelAntiData3 = function() return true end end
        if TssSdk.AddTouchEvent then TssSdk.AddTouchEvent = function() return true end end
        if TssSdk.SetEnabledConnector then TssSdk.SetEnabledConnector = function() return true end end
        if TssSdk.SetCSLicense then TssSdk.SetCSLicense = function() return true end end
        if TssSdk.GetObjVMFuncAddr then TssSdk.GetObjVMFuncAddr = function() return 0 end end
    end)
end

local function EnhancedAntiCheatBypass()
    if _G.BYPASS_STATE and _G.BYPASS_STATE.ANTI_CHEAT_MANAGER_DISABLED then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end

        local AntiCheatMgr = nil
        if pc.PlayerAntiCheatManager then
            AntiCheatMgr = pc.PlayerAntiCheatManager
        elseif pc.AntiCheatManager then
            AntiCheatMgr = pc.AntiCheatManager
        end

        if not slua.isValid(AntiCheatMgr) then
            local PlayerAntiCheatManagerClass = import("PlayerAntiCheatManager")
            if PlayerAntiCheatManagerClass then
                local comps = pc:GetComponentsByClass(PlayerAntiCheatManagerClass)
                if comps and comps:Num() > 0 then
                    AntiCheatMgr = comps:Get(0)
                end
            end
        end

        if not slua.isValid(AntiCheatMgr) then return end

        local counterFields = {
            "AutoAimFailedCnt", "TrackingFailedCnt", "AreaDamageFailedCnt", "JumpHeightFailedCnt",
            "JumpFarFailedCnt", "VehicleFlyingFailedCnt", "ShootVerifyTimes", "SpeedUpValue",
            "ClientTimeTotalAcc", "ServerAccumulateErrors", "ServerAvgErrors", "ServerCorrectTimes",
            "PlayerBadPingTimes", "VehicleSpeedZDeltaTotal", "VehicleSpeedZDeltaOver10Times",
            "PVSInCityKillCount", "PVSNotInCityKillCount", "PVSCellHidePercent", "PVSTotalHidePercent",
            "ServerMoveParameterVerifyCount", "ServerMoveParameterVerifyFailedCount",
            "StuckGroundPunishCount", "ContinueMoveBurstCount", "RecordContinueMoveBurstCount",
            "TrialBaseDiffCount", "InclusiveBegin", "InclusiveEnd"
        }
        for _, field in ipairs(counterFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 0 end
            end)
        end

        local boolFields = {
            "bReportFeedBack","bOpenDetailDataCollect","bOpenBaseDiffCheck","bUploadStuckGroundCount",
            "bStuckGroundCapsule","bImpactOtherAfterBurst","bGiveupPickupWhenBrust",
            "bOpenPickupWhenBrustCheck","bMustStrictContinue"
        }
        for _, field in ipairs(boolFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "boolean" then AntiCheatMgr[field] = false end
            end)
        end

        local maxFields = {
            "MaxShootPointPassWall", "MaxMuzzleHeightTime", "MaxLocusFailTime",
            "MaxBulletVictimClientPassWallTimes", "MaxGunPosErrorTimes",
            "MaxAllowVehicleTimeSpeedRawTime", "MaxAllowVehicleTimeSpeedConvTime",
            "MaxAllowVehicleAccTime", "MaxSingleShotDamage", "MaxFallingSustainTime",
            "MaxCustomMoveModeSustainTime", "MaxMoveDistance2DPerSecond",
            "MaxCharMoveDist2DPerSecond", "MaxDistanceToGround", "MaxContinueMoveBurstXY",
            "ContinueMoveBurstInterval", "BaseDiffRegion", "BaseDiffVel", "BaseDiffTime",
            "MinImpactOtherInterval", "MinBurstToPickupInterval", "MaxPlayerDisSquaredForPickup",
            "ContinueMoveBurstTolerant", "MultiStuckGroundScale", "StuckTypePunishSet",
            "StuckGroundPunishType"
        }
        for _, field in ipairs(maxFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 999999 end
            end)
        end

        local paraFields = {
            "ParachuteStartTime","ParachuteOpenTime","ParachuteCloseTime",
            "ParachuteStartHight","ParachuteOpenHight","ParachuteCloseHight"
        }
        for _, field in ipairs(paraFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 0 end
            end)
        end

        pcall(function() AntiCheatMgr.DSProperty = nil end)

        local verifySwitchFields = {
            "VsNoHitDetail","VsMuzzleRangeCircle","VsMuzzleRangeUp",
            "VsHitBoneNameNone","VsHitBoneHitMissMatch","VsBulletID",
            "VsVehicleTimeStampError","VsWatchTimeStampError",
            "VsShootRpgShootTimeVerify","VsShootLockShootTimeVerify",
            "VsShootRpgHitNewVerify","VsShootTimeConDelta",
            "VsServerNoOldShoot","VsClientNotConnectShoot",
            "VsShootRpgShootIntervalVerify","VsImpactPointAndBulletDisBig",
            "VsShootVerifyInvalid","VsImpactActorPosWithNoHisPos",
            "VsShootAngleInVaild","VsMuzzleAndTailPosInVaild",
            "VsMuzzleAndImpactPassWall","VsMuzzleAndTailPassWall",
            "VsImpactActorPosOffsetBig","VsImpactPointChangeSmall",
            "VsImpactBulletPosOffsetBig","VsTotalImactCharacterNum",
            "VsBoneInfo","VsJumpMaxHeight","VsJumpMaxHeight15","VsJumpMaxHeight2",
            "SpeedQuickCheck","BulletDirError","WalkSpeedFailedCnt",
            "DSSpeedOver10FailedCnt","DSSpeedOver15FailedCnt","DSSpeedOver20FailedCnt",
            "DSFallingSpeedFailCount","DSFallingHeightFailCount",
            "SwitchMuzzleLocusError","SwitchMuzzleLocusErrorX","SwitchMuzzleLocusErrorY","SwitchMuzzleLocusErrorZ",
            "Gun2ShooterPosError1","SwitchHeadLocusError3","SwitchMuzzleLocusErrorLength",
            "SwitchShootPosHistoryLocusError3","SwitchHitComponentUnvalid","SwitchHitNoRender",
            "SwitchHitOutCollisionBox","HeadOverShootPos","SwitchMuzzleImpactDirSkipPunish1",
            "SwitchInvalidBulletNumInBarrel","SwitchShooterMovementError2","GunTailPosError",
            "SwitchMuzzleImpactDirSkipPunish2","SwitchMuzzleImpactDirError1","SwitchMuzzleImpactDirError2",
            "ShooterHead2PosBlock","SwitchShootPosHistoryLocusError2","Head2GunTailPosError1",
            "SwitchShootDirExcepation1","SwitchShootDirExcepation2","SwitchCamerModeException",
            "SwitchShootPosHistoryLocusError4","SwitchMuzzleImpactDirError3",
            "CharacterMoveException1","CharacterMoveException2","CharacterMoveException3",
            "CharacterMoveException4","CharacterMoveException5","CharacterMoveException6",
            "VehicleSpeedZDeltaOver10TimesWhenNoXY","VehicleVelZCheck1","VehicleVelZCheck2",
            "VehicleMaxSpeedCheck","VehicleHitMuzzleCheck","VehicleHitImpactPointCheck",
            "VehicleHitBlockWall","VehicleSidesway1","VehicleSidesway2",
            "FarShootInMidAirVehicleExceedThreshold","FarShootInMidAirVehicleEnemyDistanceTrial",
            "FarShootInMidAirVehicleEnemyDistanceFurtherTrial","FarShootInMidAirVehicleHeightTrial",
            "FarShootInMidAirVehicleHeightFurtherTrial","FarShootInMidAirPawnExceedThreshold",
            "FarShootInMidAirPawnEnemyDistanceTrial","FarShootInMidAirPawnEnemyDistanceFurtherTrial",
            "FarShootInMidAirPawnHeightTrial","FarShootInMidAirPawnHeightFurtherTrial",
            "NonGunADSFarShootCount","NonGunADSFarShootFromClientBulletDataCount",
            "NonGunADSFarShootFromClientBulletDataEnemyDistanceTrialCount",
            "NonGunADSFarShootFromClientBulletDataEnemyDistanceFurtherTrialCount",
            "ClientUploadFuzzyObjectVerifyFail","ClientMoveTimeStampResetFrequencyExceedThreshold",
            "ShootBirdNonGunADSExceedThreshold","ShootBirdNonGunADSDistanceTrial",
            "ShootBirdNonGunADSDistanceFurtherTrial","FarShootInHighTangentMoveSpeedExceedThreshold",
            "FarShootInHighTangentMoveSpeedEnemyDistanceTrial","FarShootInHighTangentMoveSpeedEnemyDistanceFurtherTrial",
            "FarShootInHighTangentMoveSpeedSpeedTrial","FarShootInHighTangentMoveSpeedSpeedFurtherTrial",
            "IllegalTeamUpNearbyButNoFireAfterKill","IllegalTeamUpNearbyButNoFireAfterKillDistanceTrial",
            "IllegalTeamUpNearbyButNoFireAfterKillTimeTrial","IllegalTeamUpNearbyButNoFireAfterKillMaxTime",
            "IllegalTeamUpNearbyButNoFirePickUpItem","IllegalTeamUpNearbyButNoFirePickUpItemDistanceTrial",
            "IllegalTeamUpNearbyButNoFirePickUpItemTimeTrial","IllegalTeamUpNearbyButNoFirePickUpItemMaxTime",
            "IllegalTeamUpNearbyButNoFireNotKill","IllegalTeamUpNearbyButNoFireNotKillDistanceTrial",
            "IllegalTeamUpNearbyButNoFireNotKillTimeTrial","IllegalTeamUpNearbyButNoFireNotKillMaxTime",
            "IllegalTeamUpNearbyButNoFireOnVehicle","IllegalTeamUpNearbyButNoFireOnVehicleDistanceTrial",
            "IllegalTeamUpNearbyButNoFireOnVehicleTimeTrial","IllegalTeamUpNearbyButNoFireOnVehicleMaxTime",
            "IllegalTeamUpNearbyButNoFireSameVehicle","IllegalTeamUpNearbyButNoFireSameVehicleTimeTrial",
            "IllegalTeamUpNearbyButNoFireSameVehicleMaxTime","IllegalTeamUpUseObjectTogether",
            "IllegalTeamUpGetOnEnemyVehicleCount","IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFoot",
            "IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFootDistanceTrial","IllegalTeamUpStayOnEnemyVehicle",
            "KillBird","ShooterCapsuleCollided","ParachuteLandingSecondsExceedThreshold",
            "ParachuteObliqueLandingSecondsExceedThreshold","SmallActorTimeDilationCount",
            "LargeRotateLockShooting","SmallRotateLockShooting","OneClipShootCount","ClientWeaponFastReload",
            "UndergroundCount","MoveDistance2DPerSecondAnomaly","CharMoveDist2DPerSecondAnomaly",
            "CharMoveDist2DPerSecondCount","DistanceToGroundAnomaly","SingleShotDamageAnomaly","BandaCount",
            "DSCheckClientTimeMoveDistance2D","DSCheckClientTimeMoveDistance2DTrial",
            "DSCheckClientTimeMoveDistance2DFurther","DSCheckClientTimeMoveDistanceZ",
            "DSCheckClientTimeMoveDistanceZTrial","DSCheckClientTimeMoveDistanceZFurther",
            "ReplayMaxFallingSustainTime","ReplayMaxCustomMoveModeSustainTime","ReplayMaxSingleShotDamage",
            "CharMoveAccumDist2D_DS","CharMoveAccumDist3D_DS","CharMoveAccumDist2D_Client",
            "CharMoveAccumDist3D_Client","CharMoveAccumDist2D_ClientAll","CharMoveAccumDist3D_ClientAll",
            "MetroEnterRadiationTime","MetroEnterRadiationTimeTrial","MetroLeaveBornObstacle",
            "VsPetJumpHeightLimiter","VsPetMoveSpeedLimiter","VsBioVehicleMoveSpeedLimiter",
            "VsBioVehicleJumpHeightLimiter","VsPterosaurFlyVehicleSpeed","VsBioVehicleGravityLimiter",
            "ServerMoveCacheCountOver","ServerMoveCacheCountOver3d","ServerMoveBurst","ImpactOtherAfterBurst",
            "KillOtherAfterBurst","PickupAfterBurst","ContinueMoveBurst","ServerMoveTimeStamp",
            "ServerMoveAccel","ServerMoveClientLoc","ServerMoveCompressedMoveFlags","ServerMoveClientRoll",
            "ServerMoveView","ServerMoveClientMovementBase","ServerMoveClientBaseBoneName",
            "ServerMoveClientMovementMode","VerifySwitchCameraRotation","VerifySwitchPeekShootThroughWall",
            "VerifySwitchCameraLocation","VerifySwitchAutoAimByLockView","VerifySwitchControlRotation",
            "VerifySwitchRecoilFaildCount","VerifySwitchMarcoPolo","VerifySwitchMarcoPolo2",
            "VerifySwitchMarcoPolo3","VerifySwitchMeshScaleDiff","VerifySwitchOfflineMove",
            "VerifySwitchFastAimShootHit","VerifySwitchNoRecoilOnWeaponShoot","VerifySwitchLessRecoilOnWeaponShoot",
            "VerifySwitchNoRecoilOnKickBack","VerifySwitchLessRecoilOnKickBack","VerifySwitchDivingBoost",
            "VerifySwitchRecoilCurveFailed","PlayerQuickProne","BaseDiffSample",
            "VsTeammateRescue","VsTeammateRescueVictim","VsTeammateRecall","VsTeammateRecallVictim",
            "VsAutoClicker","VsAbnormalShootingRotation","PlayerInstantHeightDiff","Player2SecHeightDiff",
            "CheatStateData2TotalCheatTimes","MoveCheatAntiStrategy3TotalCheatTimes","ServerAccumulateErrorReplay"
        }
        for _, fieldName in ipairs(verifySwitchFields) do
            pcall(function()
                local vs = AntiCheatMgr[fieldName]
                if vs and type(vs) == "table" then
                    vs.bActive = false
                    vs.MaxCount = 99999
                    vs.CurrentCount = 0
                    vs.TrialCount = 0
                    vs.TrialMaxCount = 99999
                    vs.PunishType = 0
                end
            end)
        end

        local burstFields = {
            "ServerAccumulateErrorBurst","DSSpeedOver10BurstCount",
            "ParachuteSpeedBurst","ClientTimestampBurst","ClientTimestampBurstTrial"
        }
        for _, fieldName in ipairs(burstFields) do
            pcall(function()
                local bvs = AntiCheatMgr[fieldName]
                if bvs and type(bvs) == "table" then
                    bvs.bActive = false
                    bvs.MaxCount = 99999
                    bvs.CurrentCount = 0
                end
            end)
        end

        pcall(function()
            if AntiCheatMgr.ReportMiscMap then AntiCheatMgr.ReportMiscMap:Clear() end
        end)

        local methodFields = {
            "ReportAntiCheatDetailData","PushWeaponAntiData","OnRecoverOnServer",
            "OnPreReconnectOnServer","ExitParachute","EnterParachute","EnterJumping",
            "Cofey","Cofew","SetTrialRegion","GetSoftString","GetCheckMoveStr2",
            "GetCheckMoveStr1","GetAACString","GetAACCountByID"
        }
        for _, method in ipairs(methodFields) do
            pcall(function()
                if AntiCheatMgr[method] and type(AntiCheatMgr[method]) == "function" then
                    AntiCheatMgr[method] = function(...)
                        if method == "GetSoftString" then return 0 end
                        if method == "GetCheckMoveStr1" or method == "GetCheckMoveStr2" then return "" end
                        if method == "GetAACString" then return "" end
                        if method == "GetAACCountByID" then return 0 end
                        if method == "Cofey" then return 0 end
                        return true
                    end
                end
            end)
        end

        pcall(function()
            local catchData = AntiCheatMgr.CatchReportAntiCheatDetailData
            if catchData and type(catchData) == "table" then
                catchData.bActive = false
                catchData.CurrentCount = 0
                catchData.MaxCount = 99999
            end
        end)

        _G.BYPASS_STATE = _G.BYPASS_STATE or {}
        _G.BYPASS_STATE.ANTI_CHEAT_MANAGER_DISABLED = true
    end)
end

local function MemoryBypass()
    pcall(function()
        local funcs = {"__aeabi_memset","__strncpy_chk","memmove_chk","memset_chk","memcpy","malloc","calloc","realloc","free","close","dup2","listen"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function TimeBypass()
    pcall(function()
        if _G.gmtime then _G.gmtime = function() return os.date("!*t") end end
        if _G.gettimeofday then _G.gettimeofday = function() return os.time() end end
        if _G.mktime then _G.mktime = function(t) return os.time(t) end end
        if _G.imp_time then _G.imp_time = function() return os.time() end end
    end)
end

local function NetworkBypass()
    pcall(function()
        local funcs = {"sys_read","sys_open","nanosleep","imp_recv","imp_send","socket"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function ReportBypass()
    pcall(function()
        local funcs = {"report","COREREPORT","tdm_report","android_log_print","__android_log_print"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function StrBypass()
    pcall(function()
        if _G.strstr then _G.strstr = function() return "" end end
        if _G.strcpy then _G.strcpy = function() return "" end end
        if _G.strlen then _G.strlen = function() return 0 end end
        if _G.strncpy then _G.strncpy = function() return "" end end
    end)
end

local function ProcessBypass()
    pcall(function()
        if _G.getpid then _G.getpid = function() return 0 end end
        if _G.getppid then _G.getppid = function() return 0 end end
        if _G.gettid then _G.gettid = function() return 0 end end
    end)
end

local function AntiDebugBypass()
    pcall(function()
        if _G.ptrace then _G.ptrace = function() return 0 end end
        if _G.monitor then _G.monitor = function() return true end end
    end)
end

local function DLCmdBypass()
    pcall(function()
        if _G.dlopen then _G.dlopen = function() return 0 end end
        if _G.cmd then _G.cmd = function() return "" end end
        if _G.name then _G.name = function() return "" end end
    end)
end

local function AnoSDKBypass()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            if TssSdk.AnoSDKDelReportData then TssSdk.AnoSDKDelReportData = function() return true end end
            if TssSdk.AnoSDKDelReportData3 then TssSdk.AnoSDKDelReportData3 = function() return true end end
            if TssSdk.AnoSDKDelReportData4 then TssSdk.AnoSDKDelReportData4 = function() return true end end
            if TssSdk.AnoSDKGetReportData then TssSdk.AnoSDKGetReportData = function() return nil end end
            if TssSdk.AnoSDKGetReportData2 then TssSdk.AnoSDKGetReportData2 = function() return nil end end
            if TssSdk.AnoSDKGetReportData3 then TssSdk.AnoSDKGetReportData3 = function() return nil end end
            if TssSdk.AnoSDKGetReportData4 then TssSdk.AnoSDKGetReportData4 = function() return nil end end
        end
    end)
end

local function MprotectBypass()
    pcall(function()
        if _G.mprotect then _G.mprotect = function() return 0 end end
        if _G.munmap then _G.munmap = function() return 0 end end
    end)
end

-- ===== New bypass functions (Roxz_gaming) =====
local function InitializeSLUABypass()
  pcall(function()
    if slua and slua.getSignature then
      slua.getSignature = function() return 0xDEADBEEF end
    end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
      loader.verifyBytecode = retTrue
      loader.checkIntegrity = retTrue
      if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
    end
    local slua_serialize = package.loaded["slua.serialize"]
    if slua_serialize then
      slua_serialize.check = retTrue
      slua_serialize.verify = retTrue
    end
    if jit and jit.attach then
      jit.attach(function() end, "bc")
    end
    if _G.slua_verify then _G.slua_verify = retTrue end
    if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
  end)
end

local function InitializeMD5Bypass()
  pcall(function()
    local console = import("KismetSystemLibrary")
    if console then
      console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
      console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
      console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
      console.ExecuteConsoleCommand(nil, "sig.Check 0")
      console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
    end
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    if CreativeModeBlueprintLibrary then
      CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "00000000000000000000000000000000" end
      CreativeModeBlueprintLibrary.MD5HashFile = function() return "00000000000000000000000000000000" end
      CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
      CreativeModeBlueprintLibrary.VerifyFileIntegrity = retTrue
    end
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    if _G.CRC32 then _G.CRC32 = function() return 0 end end
    if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
    local FileHashChecker = package.loaded["common.file_hash_checker"]
    if FileHashChecker then
      FileHashChecker.CheckFileMD5 = retTrue
      FileHashChecker.VerifyAll = retTrue
      FileHashChecker.GetHash = function() return "BYPASS" end
    end
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
      TssSdk.GetFileMD5 = function() return "BYPASS" end
      TssSdk.VerifyFileSignature = retTrue
    end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if STExtraBlueprintFunctionLibrary then
      STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
      STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
      STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
    end
  end)
end

local function InitializeSkinBypass()
  pcall(function()
    local puffer_tlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if puffer_tlog then
      puffer_tlog.ReportEvent = noop
      puffer_tlog.ReportDownloadResult = noop
      puffer_tlog.ReportODPTDError = noop
      puffer_tlog.ReportSkinError = noop
    end
    local AvatarUtils = package.loaded["AvatarUtils"]
    if AvatarUtils then
      AvatarUtils.CheckIsWeaponInBlackList = retFalse
      AvatarUtils.IsValidAvatar = retTrue
      AvatarUtils.CheckAvatarIntegrity = retTrue
      AvatarUtils.ReportInvalidAvatar = noop
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local fileCheckSubsystem = SubsystemMgr and SubsystemMgr:Get("FileCheckSubsystem")
    if fileCheckSubsystem then
      fileCheckSubsystem.StartCheck = noop
      fileCheckSubsystem.ReportAbnormalFile = noop
      fileCheckSubsystem.StopCheck = noop
    end
    local equipmentException = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
    if equipmentException then
      equipmentException.Report = noop
      equipmentException.SendException = noop
    end
  end)
end

local function InitializeLogBlocker()
  pcall(function()
    local ScreenshotMTDer = import("ScreenshotMTDer")
    if ScreenshotMTDer then
      ScreenshotMTDer.MTDePicture = function() return "" end
      ScreenshotMTDer.ReMTDePicture = function() return "" end
      ScreenshotMTDer.HasCaptured = retTrue
      ScreenshotMTDer.TakeScreenshot = noop
    end
    local TLog = package.loaded["TLog"] or _G.TLog
    if TLog then
      TLog.Info = noop; TLog.Warning = noop; TLog.Error = noop
      TLog.Debug = noop; TLog.Report = noop; TLog.Send = noop
      TLog.Flush = noop
    end
    local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
    if CrashSight then
      CrashSight.ReportException = noop
      CrashSight.SetCustomData = noop
      CrashSight.Log = noop
      CrashSight.SendCrash = noop
      CrashSight.ReportUserException = noop
    end
    local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
    if GameReportUtils then
      GameReportUtils.BugglyPostExceptionFull = retFalse
      GameReportUtils.CheckCanBugglyPostException = retFalse
      GameReportUtils.ReplayReportData = noop
      GameReportUtils.ReportGameException = noop
      GameReportUtils.PostException = noop
    end
    local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
    if ClientToolsReport then
      ClientToolsReport.SendReport = noop
      ClientToolsReport.SendException = noop
      ClientToolsReport.UploadLog = noop
    end
    local TLogReportUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"]
    if TLogReportUtils then
      TLogReportUtils.ReportTLogEvent = noop
      TLogReportUtils.FlushEvents = noop
    end
    for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
      local s = _G[sdk]
      if s then
        s.logEvent = noop; s.trackEvent = noop; s.setEnabled = retFalse
        s.sendEvent = noop; s.report = noop
      end
    end
  end)
end

local function InitializeScannerBlocker()
  pcall(function()
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local subsystems = {
        "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem",
        "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem",
        "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"
      }
      for _, name in ipairs(subsystems) do
        local sub = SubsystemMgr:Get(name)
        if sub then
          for k, v in pairs(sub) do
            if type(v) == "function" and (
              k:find("Report") or k:find("Send") or k:find("Upload") or
              k:find("Verify") or k:find("Check") or k:find("Validate") or
              k:find("Scan") or k:find("Detect")
            ) then
              pcall(function() sub[k] = noop end)
            end
          end
          if sub.ReportPingDelayTimer then
            sub:RemoveGameTimer(sub.ReportPingDelayTimer)
            sub.ReportPingDelayTimer = nil
          end
          sub.DelayCount = 0
        end
      end
    end
    local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
    if AvatarExceptionPlayerInst then
      AvatarExceptionPlayerInst.CheckAvatarException = noop
      AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = noop
      AvatarExceptionPlayerInst.ReportAvatarException = noop
      AvatarExceptionPlayerInst.CheckSlotMeshVisible = retFalse
      AvatarExceptionPlayerInst.CheckPawnVisible = retFalse
      AvatarExceptionPlayerInst.CheckCanBugglyPostException = retFalse
    end
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
      local originalOnRecvData = TssSdk.OnRecvData
      TssSdk.OnRecvData = function(data)
        if type(data) == "string" and (
          string.find(data, "report") or string.find(data, "exception") or
          string.find(data, "cheat") or string.find(data, "violation") or
          string.find(data, "hack") or string.find(data, "verify")
        ) then
          return
        end
        if originalOnRecvData then originalOnRecvData(data) end
      end
      TssSdk.SendReportInfo = noop
      TssSdk.ScanMemory = retTrue
      TssSdk.IsEmulator = retFalse
      TssSdk.GetTssSdkReportInfo = retEmptyString
      TssSdk.CheckEnvironment = retTrue
      TssSdk.VerifyProcess = retTrue
    end
  end)
end

local function InitializeReplayTelemetryBlocker()
  pcall(function()
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local replaySystems = {
        "RescueBtnReplayTraceSubsystem", "GameReportSubsystem", "ReplaySubsystem"
      }
      for _, name in ipairs(replaySystems) do
        local sub = SubsystemMgr:Get(name)
        if sub then
          for k, v in pairs(sub) do
            if type(v) == "function" and (
              k:find("Report") or k:find("Trace") or k:find("Replay") or
              k:find("Record") or k:find("Save")
            ) then
              pcall(function() sub[k] = noop end)
            end
          end
        end
      end
    end
    local logic_report_replay = package.loaded["client.slua.logic.replay.logic_report_replay"]
    if logic_report_replay then
      logic_report_replay.ReportReplay = noop
      logic_report_replay.SendReportReq = noop
      logic_report_replay.UploadReplay = noop
    end
  end)
end

local function InitializeReportFlowBlocker()
  pcall(function()
    local reportFlows = {
      "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
      "ReportHurtFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
      "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate",
      "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition",
      "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData",
      "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP",
      "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
      "ReportDSNetRate", "ReportCircleFlow", "ReportPlayerKillFlow",
      "ReportMrpcsFlow", "ReportSecMrpcsFlow"
    }
    for _, funcName in ipairs(reportFlows) do
      if _G[funcName] then _G[funcName] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
        _G.GameplayCallbacks[funcName] = noop
      end
    end
    local checkFuncs = {"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}
    for _, funcName in ipairs(checkFuncs) do
      if _G[funcName] then _G[funcName] = retFalse end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
        _G.GameplayCallbacks[funcName] = retFalse
      end
    end
    local enableFlags = {
      "IsEnableReportPlayerKillFlow", "IsEnableReportMrpcsInCircleFlow",
      "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow",
      "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"
    }
    for _, flag in ipairs(enableFlags) do
      if _G[flag] then _G[flag] = retFalse end
    end
  end)
end

local function InitializePlayerSecurityBypass()
  pcall(function()
    local securityCollectors = {
      "PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector",
      "ClientSecurityCollector", "PlayerAntiCheatCollector"
    }
    for _, collector in ipairs(securityCollectors) do
      if _G[collector] then
        for k, v in pairs(_G[collector]) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Collect") or k:find("Send") or
            k:find("Upload") or k:find("Record")
          ) then
            _G[collector][k] = noop
          end
        end
      end
    end
    local SecuritySubsystem = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
    if SecuritySubsystem then
      SecuritySubsystem.ReportData = noop
      SecuritySubsystem.CheckCheat = retFalse
      SecuritySubsystem.ValidatePlayer = retTrue
      SecuritySubsystem.CollectData = noop
      SecuritySubsystem.SendToServer = noop
    end
    if _G.PlayerSecurityInfo then
      _G.PlayerSecurityInfo.ReportCheat = noop
      _G.PlayerSecurityInfo.ReportSuspicious = noop
      _G.PlayerSecurityInfo.SendSecurityData = noop
      _G.PlayerSecurityInfo.CollectSecurityInfo = noop
    end
  end)
end

local function InitializeClientFlowBypass()
  pcall(function()
    local flowSubsystems = {
      "ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem",
      "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"
    }
    for _, name in ipairs(flowSubsystems) do
      local sub = package.loaded[name] or _G[name]
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Send") or k:find("Flow") or
            k:find("Record") or k:find("Process")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
      end
    end
    local CircleFlow = require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
    if CircleFlow then
      CircleFlow.ReportCircleFlow = noop
      CircleFlow.SendCircleData = noop
      CircleFlow.ReportPlayerPosition = noop
      CircleFlow.ReportCircleData = noop
    end
    if _G.ReportPlayerKillFlow then _G.ReportPlayerKillFlow = noop end
    if _G.ClientSecPlayerKillFlow then _G.ClientSecPlayerKillFlow = noop end
  end)
end

local function InitializeHeartbeatBypass()
  pcall(function()
    local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
    for _, func in ipairs(heartbeatFuncs) do
      if _G[func] then _G[func] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
        _G.GameplayCallbacks[func] = noop
      end
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local heartbeatSub = SubsystemMgr:Get("HeartbeatSubsystem")
      if heartbeatSub then
        if heartbeatSub.timer then heartbeatSub:RemoveGameTimer(heartbeatSub.timer) end
        heartbeatSub.SendHeartbeat = noop
        heartbeatSub.StartHeartbeat = noop
      end
    end
  end)
end

local function InitializeSwiftHawkBypass()
  pcall(function()
    local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
    for _, func in ipairs(swiftFuncs) do
      if _G[func] then _G[func] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
        _G.GameplayCallbacks[func] = noop
      end
    end
    local SwiftHawkSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
    if SwiftHawkSubsystem then
      SwiftHawkSubsystem.ReportData = noop
      SwiftHawkSubsystem.SendReport = noop
      SwiftHawkSubsystem.CollectTelemetry = noop
    end
  end)
end

local function InitializeCoronaLabBypass()
  pcall(function()
    if _G.CoronaLab then
      _G.CoronaLab.ReportData = noop
      _G.CoronaLab.SendData = noop
      _G.CoronaLab.CollectData = noop
      _G.CoronaLab.Telemetry = noop
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local corona = SubsystemMgr:Get("CoronaLabSubsystem")
      if corona then
        corona.ReportData = noop
        corona.SendToServer = noop
        corona.CollectTelemetry = noop
        corona.StopCollection = noop
      end
    end
  end)
end

local function InitializeModifierExceptionBypass()
  pcall(function()
    if _G.bReportedModifierException then
      _G.bReportedModifierException = false
    end
    local ModifierSubsystem = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
    if ModifierSubsystem then
      ModifierSubsystem.ReportException = noop
      ModifierSubsystem.CheckModifier = retTrue
      ModifierSubsystem.ValidateModifier = retTrue
      ModifierSubsystem.ReportModifierError = noop
    end
  end)
end

local function InitializeSimulateCharacterLocationBypass()
  pcall(function()
    local SimulateSubsystem = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
    if SimulateSubsystem then
      SimulateSubsystem.ReportLocation = noop
      SimulateSubsystem.SendLocationData = noop
      SimulateSubsystem.VerifyLocation = retTrue
    end
  end)
end

local function InitializeShootVerificationBypass()
  pcall(function()
    local ShootVerify = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if ShootVerify then
      ShootVerify.OnShootVerifyFailed = noop
      ShootVerify.SendVerifyData = noop
      ShootVerify.ReportBulletHit = noop
      ShootVerify.UploadHitInfo = noop
      ShootVerify.VerifyShot = retTrue
    end
    if _G.BulletHitInfoUploadData then
      _G.BulletHitInfoUploadData.Report = noop
      _G.BulletHitInfoUploadData.Send = noop
      _G.BulletHitInfoUploadData.Upload = noop
    end
  end)
end

local function InitializeNetworkPacketBlock()
  pcall(function()
    if NetUtil and NetUtil.SendPacket then
      local originalSend = NetUtil.SendPacket
      local blockedPackets = {
        ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
        ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
        ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
        ["ReportPlayerPosition"] = 1, ["ReportSecVehicleMoveFlow"] = 1, ["report_parachute_data"] = 1,
        ["on_tss_sdk_anti_data"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
        ["ReportCircleFlow"] = 1, ["report_players_ping"] = 1, ["report_player_ip"] = 1,
        ["report_net_saturate"] = 1, ["report_speed_hack"] = 1, ["report_wall_hack"] = 1,
        ["report_aim_bot"] = 1, ["report_esp_usage"] = 1, ["report_modded_files"] = 1,
        ["detect_cheat"] = 1, ["ban_player"] = 1, ["client_anti_cheat_report"] = 1,
        ["ReportPlayerKillFlow"] = 1, ["ClientSecPlayerKillFlow"] = 1,
        ["ReportMrpcsFlow"] = 1, ["ClientSecMrpcsFlow"] = 1, ["MrpcsData"] = 1,
        ["CheckReportSecAttackFlow"] = 1, ["CheckReportSecAttackFlowWithAttackFlow"] = 1,
        ["RPC_ClientCoronaLab"] = 1, ["CoronaLabReport"] = 1, ["CoronaLabData"] = 1,
        ["PlayerSecurityInfo"] = 1, ["ReportSecurityInfo"] = 1, ["SendSecurityData"] = 1,
        ["ClientCircleFlow"] = 1, ["IsEnableReportPlayerKillFlow"] = 1,
        ["IsEnableReportMrpcsInCircleFlow"] = 1, ["IsEnableReportMrpcsInPartCircleFlow"] = 1,
        ["bReportedModifierException"] = 1, ["ReportModifierException"] = 1,
        ["RPC_Server_ReportSimulateCharacterLocation"] = 1, ["ReportSimulateCharacterLocation"] = 1,
        ["RPC_Client_ShootVertifyRes"] = 1, ["BulletHitInfoUploadData"] = 1,
        ["ShootVerifyFailed"] = 1, ["report_unrealnet_exception"] = 1, ["tss_sdk_report"] = 1,
        ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1, ["ServerHeartbeat"] = 1,
        ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["ClientSwiftHawkWithParams"] = 1,
        ["SwiftHawkReport"] = 1, ["SwiftHawkData"] = 1,
        ["AntiCheatReport"] = 1, ["CheatDetection"] = 1, ["ViolationReport"] = 1,
        ["SecurityViolation"] = 1, ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1,
        ["1162992962"] = 1, ["242463958"] = 1, ["224639039"] = 1, ["816081779"] = 1,
        ["224943158"] = 1, ["516985564"] = 1,
        ["inspection_system_report_to_inspector"] = 1,
        ["ingame_voice_ban_notify"] = 1,
        ["inspection_system_notify_inspector"] = 1,
      }
      NetUtil.SendPacket = function(packetName, ...)
        if blockedPackets[packetName] then
          return nil
        end
        return originalSend(packetName, ...)
      end
      NetUtil.IsBypassed = true
    end
    if _G.SendRPC then
      local originalSendRPC = _G.SendRPC
      local blockedRPCs = {
        "RPC_Server_ReportPlayerKillFlow", "RPC_Server_ClientSecMrpcsFlow",
        "RPC_Server_Heartbeat", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams",
        "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes",
        "RPC_ClientCoronaLab",
        "RPC_Server_HawkReportCheat",
      }
      _G.SendRPC = function(rpcName, ...)
        for _, blocked in ipairs(blockedRPCs) do
          if rpcName == blocked then return nil end
        end
        return originalSendRPC(rpcName, ...)
      end
    end
  end)
end

local function InitializeAntiCheatHooks()
  pcall(function()
    local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
      HiggsBosonComponent.StaticShowSecurityAlertInDev = noop
    end
    if HiggsBosonComponent and HiggsBosonComponent.BlackList then
      for k in pairs(HiggsBosonComponent.BlackList) do HiggsBosonComponent.BlackList[k] = nil end
    end
  end)
  _G.BlackList = {}
  
  pcall(function()
    _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
    _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
    if not getmetatable(_G.GlobalPlayerCoronaData) then
      local mt = { __newindex = function() end }
      setmetatable(_G.GlobalPlayerCoronaData, mt)
    end
  end)
  
  if _G.AvatarCheckCallback then
    _G.AvatarCheckCallback.StartAvatarCheck = noop
    _G.AvatarCheckCallback.OnReportItemID = noop
    _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
      if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then
        PlayerController.HiggsBosonComponent:ControlMHActive(0)
        PlayerController.HiggsBosonComponent.bMHActive = false
      end
    end
  end
end

local function InitializeAntiReport()
  pcall(function()
    local paths = {
      "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
      "Client.Security.ClientReportPlayerSubsystem",
      "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"
    }
    for _, path in ipairs(paths) do
      local sub = package.loaded[path]
      if not sub then
        local success, reqModule = pcall(require, path)
        if success and reqModule then sub = reqModule end
      end
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Record") or k:find("Send") or
            k:find("Upload") or k:find("Notify")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
      end
    end
  end)
end

local function InitializeGameplayBypass()
  pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end
    local GC = _G.GameplayCallbacks
    local reportFuncs = {
      "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow", "ReportFireArms",
      "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt",
      "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute",
      "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow",
      "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow",
      "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
      "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
      "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta",
      "ReportCircleFlow", "ReportPlayerKillFlow", "ClientSecMrpcsFlow", "Heartbeat",
      "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"
    }
    for _, funcName in ipairs(reportFuncs) do
      GC[funcName] = noop
    end
    GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
    GC.CheckReportSecAttackFlow = retFalse
    local originalDSPlayerState = GC.OnDSPlayerStateChanged
    GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
      local stateStr = InPlayerState and string.lower(tostring(InPlayerState)) or ""
      local blockedStates = {
        ["cheatdetected"] = true, ["connectionlost"] = true, ["connectiontimeout"] = true,
        ["connectionexception"] = true, ["netdrivererror"] = true, ["banned"] = true,
        ["kicked"] = true, ["suspended"] = true, ["violationdetected"] = true,
        ["integrityfailure"] = true, ["securityviolation"] = true
      }
      if blockedStates[stateStr] then return end
      if originalDSPlayerState then pcall(originalDSPlayerState, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
    end
    GC.OnPlayerNetConnectionClosed = noop
    GC.OnPlayerActorChannelError = noop
    GC.OnPlayerRPCValidateFailed = noop
    GC.OnPlayerSpectateException = noop
    GC.OnShutdownAfterError = noop
    GC.IsBypassed = true
  end)
end

local function InitializeKillAllSubsystems()
  pcall(function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not subMgr then return end
    local subsystemsToKill = {
      "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
      "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
      "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
      "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem",
      "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem",
      "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
      "AvatarExceptionSubsystem", "GameReportSubsystem", "RescueBtnReplayTraceSubsystem",
      "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "PlayerKillFlowSubsystem",
      "CircleFlowSubsystem", "SwiftHawkSubsystem", "HeartbeatSubsystem",
      "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
      "MD5CheckSubsystem", "PakVerifySubsystem"
    }
    for _, name in ipairs(subsystemsToKill) do
      local sub = subMgr:Get(name)
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Send") or k:find("Upload") or
            k:find("Verify") or k:find("Check") or k:find("Validate") or
            k:find("Scan") or k:find("Detect") or k:find("Collect") or
            k:find("Flow") or k:find("Heartbeat")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
        if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
        if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
        if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
      end
    end
  end)
end

local function InitializeFinalProtection()
  pcall(function()
    local globalFlags = {
      "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY",
      "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"
    }
    for _, flag in ipairs(globalFlags) do
      if _G[flag] then _G[flag] = false end
    end
    local originalRequire = require
    local blockedModules = {
      "HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
      "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient",
      "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"
    }
    _G.require = function(module)
      for _, blocked in ipairs(blockedModules) do
        if module:find(blocked) then
          return {}
        end
      end
      return originalRequire(module)
    end
  end)
end

local function ApplyNewBypasses()
  pcall(function()
    InitializeSLUABypass()
    InitializeMD5Bypass()
    InitializeSkinBypass()
    InitializeLogBlocker()
    InitializeScannerBlocker()
    InitializeReplayTelemetryBlocker()
    InitializeReportFlowBlocker()
    InitializePlayerSecurityBypass()
    InitializeClientFlowBypass()
    InitializeHeartbeatBypass()
    InitializeSwiftHawkBypass()
    InitializeCoronaLabBypass()
    InitializeModifierExceptionBypass()
    InitializeSimulateCharacterLocationBypass()
    InitializeShootVerificationBypass()
    InitializeNetworkPacketBlock()
    InitializeAntiCheatHooks()
    InitializeAntiReport()
    InitializeGameplayBypass()
    InitializeKillAllSubsystems()
    InitializeFinalProtection()
  end)
end

-- ==================== NETWORK BLOCKER ====================
local BLACKLIST_HOSTS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
    "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
    "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
    "cdn.club","gpubgm","graph.facebook","calendarpushsubscription","googleads","doubleclick",
    "firebaselogging","firebaseremoteconfig","fonts.googleapis","abs.twimg","dl.listdl",
    "igame.gcloudcs","bugly","beacon","helpshift","tdm","apm","safeguard","weiyun","qzone",
    "tencent-cloud","myapp","idqqimg","gtimg","qqmail","tcdn","cloudctrl","sdkostrace",
    "103.134.189.146","mbgame","csoversea","igame","pubgmobile","down.anticheatexpert.com",
    "asia.csoversea.mbgame.anticheatexpert.com","log.tav.qq","syzsdk.qq","logiservice.qcloud",
    "opensdk.tencent","exp.helpshift","loginsdkapi.zingplay","firebase","googleapis","facebook","gvoice"
}
local BLACKLIST_PORTS = {
    "10334","11045","12221","13331","8011","8015","9001","20000","20001","20002","20003","20004",
    "20005","19700","1670","19900","14545","10213","8700","25177","10685","10336","10262","27000",
    "27040","27015","27030","10706","10095","12401","11008","10309","11075","10157","24798","10709",
    "6667","10087","31113","20371","10120","10664","13728","10769","10761","5061","5062","18081",
    "15692","9030","8080","8086","8088"
}
local FILE_KEYWORDS = {
    "tlog","crash","bugly","report","beacon","wetest","analytics","telemetry","trace","dump",
    "exception","feedback","aps_log","mtp_detect","network_loss","client_error","ue4crash","tdm","gcloud"
}

local function isBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = str:lower()
    for _, kw in ipairs(BLACKLIST_HOSTS) do if low:find(kw,1,true) then return true end end
    for _, port in ipairs(BLACKLIST_PORTS) do if low:find(":"..port) or low:find("/"..port) then return true end end
    return false
end

local function applyNetworkBlocker()
    pcall(function()
        if _G.HttpRequest then
            local orig = _G.HttpRequest
            _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
        end
        if _G.FHttpModule and _G.FHttpModule.CreateRequest then
            local orig = _G.FHttpModule.CreateRequest
            _G.FHttpModule.CreateRequest = function(...)
                local url = select(1,...)
                if isBlacklisted(url) then return nil end
                return orig(...)
            end
        end
        local netMods = {
            "client.slua.logic.network.logic_network","client.slua.logic.download.report.puffer_tlog",
            "client.slua.data.BasicData.BasicDataClientReport","GameLua.GameCore.Module.Network.NetworkManager",
            "client.network.Protocol.ClientTlogHandler","client.network.Protocol.BattleReportHandler",
            "client.network.Protocol.ClientErrorReportHandler"
        }
        for _, mp in ipairs(netMods) do
            local mod = package.loaded[mp]
            if mod then
                for k, v in pairs(mod) do
                    if type(v) == "function" and (k:find("Http") or k:find("Request") or k:find("Send") or k:find("Upload") or k:find("Post") or k:find("Get") or k:find("Report")) then
                        local origf = v
                        mod[k] = function(...)
                            local args = {...}
                            for _, arg in ipairs(args) do if type(arg)=="string" and isBlacklisted(arg) then return nil end end
                            return pcall(origf, ...)
                        end
                    end
                end
            end
        end
    end)

    local orig_io_open = io.open
    io.open = function(path, mode)
        if type(path) == "string" then
            local lp = path:lower()
            for _, kw in ipairs(FILE_KEYWORDS) do
                if lp:find(kw) then
                    if mode and (mode == "w" or mode == "a" or mode == "w+" or mode == "a+") then
                        return nil, "Blocked"
                    end
                end
            end
            if lp:find("tdm") or lp:find("gcloud") or lp:find("beacon") then
                if mode and (mode == "w" or mode == "a" or mode == "w+") then return nil end
            end
        end
        return orig_io_open(path, mode)
    end

    if _G.UnrealEngine and _G.UnrealEngine.CrashContext then
        _G.UnrealEngine.CrashContext = nil
        _G.UnrealEngine.CrashContext = { SetCrashContext = noop, ReportCrash = noop, AddCrashData = noop }
    end
end

local function killGlobalFunctions()
    local globalFuncs = {
        "ReportTLogEvent","SendTlog","SendClientStats","ReportHitFlow","ReportAvatarException",
        "SendComplaintReq","SubmitReport","ReportSuspiciousPlayer","SendPacket","OnSyncBanInfo",
        "OnVoiceBanNotify","SendSecTLog","MarkSuspiciousPlayer","ReportPlayerBehaviorData",
        "CheckCompliance","ReportIllegalProgram","UploadVoiceLog","ReportCheat","ReportPlayer",
        "ShowReportUI","OpenReportPanel","OnClickReport","ReportCheatDetected"
    }
    for _, fn in ipairs(globalFuncs) do
        if type(_G[fn]) == "function" then _G[fn] = noop end
        _G[fn] = nil
    end
end

-- ==================== CRC FAKER ====================
local function deepHook(obj, depth)
    if depth > 4 then return end
    if type(obj) ~= "table" then return end
    for k, v in pairs(obj) do
        if type(k) == "string" then
            local lk = k:lower()
            if lk:find("crc") or lk:find("verify") or lk:find("integrity") or lk:find("hash") or lk:find("paksign") then
                if type(v) == "function" then
                    obj[k] = function(...) if lk:find("crc") or lk:find("hash") then return 0 end; return true end
                end
            end
        end
        if type(v) == "table" and v ~= obj then deepHook(v, depth + 1) end
    end
end

local function applyFullCRCFaker()
    if _G.__CRCFakerDone then return end
    pcall(function()
        if not slua_GameFrontendHUD then return end
        if Client then
            if Client.VerifyPakFile then Client.VerifyPakFile = retTrue end
            if Client.CheckFileCRC then Client.CheckFileCRC = retZero end
            if Client.GetFileHash then Client.GetFileHash = function() return "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" end end
            if Client.VerifySignature then Client.VerifySignature = retTrue end
            if Client.CheckGameLuaIntegrity then Client.CheckGameLuaIntegrity = retTrue end
            if Client.VerifyFileIntegrity then Client.VerifyFileIntegrity = retTrue end
            if Client.VerifyAllPaks then Client.VerifyAllPaks = retTrue end
        end
        for _, mod in pairs(package.loaded) do if type(mod) == "table" then deepHook(mod, 0) end end
        _G.__CRCFakerDone = true
    end)
end

-- ==================== ADVANCED PATCHES ====================
local function applyAdvancedPatches()
    pcall(function()
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local function patchSub(name, methods, retvals, fields)
                local inst = SubsystemMgr:Get(name)
                if inst then
                    if methods then for k, v in pairs(methods) do if type(inst[k]) == "function" then inst[k] = v end end end
                    if retvals then for k, v in pairs(retvals) do if type(inst[k]) == "function" then inst[k] = v end end end
                    if fields then for k, v in pairs(fields) do inst[k] = v end end
                end
            end
            patchSub("AFKReportorSubsystem", {PlayerHaveAction = noop, ReportAFK = noop})
            patchSub("ClientDataStatistcsSubsystem", nil, nil, {DelayCount = 0})
            patchSub("AvatarExceptionSubsystem", {ReportException = noop, BindPlayerCharacter = noop, CheckAvatarValid = retTrue})
            patchSub("ShootVerifySubSystemClient", {ReportVerifyFail = noop, OnVerifyFailed = noop})
            patchSub("RescueBtnReplayTraceSubsystem", {ReportTrace = noop, StartTickMonitor = noop, TickMonitorCheck = noop, ReportTickMonitorHeartbeat = noop})
            patchSub("GameReportSubsystem", {ReplayReportData = retFalse, CheckCanBugglyPostException = retFalse, BugglyPostExceptionFull = retFalse, GetClientReplayDataReporter = function() return nil end})
            patchSub("FileCheckSubsystem", {StartCheck = noop, ReportAbnormalFile = noop})
            patchSub("ReplaySubsystem", {SendReport = noop, Upload = noop})
            patchSub("ClientFlagSubsystem", {EvaluateFlags = noop, GetFlagLevel = retZero, GetFlagBanDuration = retZero, IsFlagged = retFalse})
            patchSub("DSAITLogSubsystem", {_UpdateTTKRecords = noop, _UpdateOperatingFrequency = noop})
            patchSub("TLogSubsystem", {OnInit = noop})
            local gameReportSub = SubsystemMgr:Get("GameReportSubsystem")
            if gameReportSub and gameReportSub.Reporter then
                gameReportSub.Reporter.ReportIntArrayData = noop
                gameReportSub.Reporter.ReportUInt8ArrayData = noop
                gameReportSub.Reporter.ReportFloatArrayData = noop
            end
        end
    end)
    pcall(function()
        local CreativeMode = import("CreativeModeBlueprintLibrary")
        if CreativeMode then
            CreativeMode.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeMode.GetContentDiffData = function() return true, "BYPASSED" end
        end
    end)
    pcall(function()
        local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvatarExceptionPlayerInst then
            AvatarExceptionPlayerInst.CheckAvatarException = noop
            AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = noop
            AvatarExceptionPlayerInst.ReportAvatarException = noop
            AvatarExceptionPlayerInst.CheckSlotMeshVisible = retFalse
            AvatarExceptionPlayerInst.CheckPawnVisible = retFalse
            AvatarExceptionPlayerInst.CheckCanBugglyPostException = retFalse
        end
    end)
    pcall(function()
        local AvatarChecker = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if AvatarChecker then AvatarChecker.CheckAvatar = retTrue; AvatarChecker.ReportException = noop end
    end)
    pcall(function()
        local MemoryWarning = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if MemoryWarning then MemoryWarning.OnMemoryWarning = noop; MemoryWarning.ReportMemoryWarning = noop end
    end)
    pcall(function()
        local StoreInterface = package.loaded["client.slua.logic.store.logic_store_game_interface"]
        if StoreInterface then StoreInterface.IsStoreGameSupported = retTrue; StoreInterface.NotifyGetPGSLoginInfo = noop end
    end)
    pcall(function()
        local VoiceSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Voice.VoiceChatSubsystem"]
        if VoiceSubsystem then VoiceSubsystem.OnPlayerSubmitComplaint = noop end
    end)
    pcall(function()
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local orig = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (data:find("report") or data:find("exception")) then return end
                if orig then orig(data) end
            end
            TssSdk.SendReportInfo = noop
            TssSdk.ScanMemory = retTrue
            TssSdk.IsEmulator = retFalse
            TssSdk.GetTssSdkReportInfo = function() return "" end
        end
    end)
    pcall(function()
        local logicReplayReport = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logicReplayReport then logicReplayReport.ReportReplay = noop; logicReplayReport.SendReportReq = noop end
    end)
    pcall(function()
        local PufferTlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if PufferTlog then PufferTlog.ReportEvent = noop; PufferTlog.ReportDownloadResult = noop; PufferTlog.ReportODPAKError = noop end
    end)
    pcall(function()
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue end
    end)
    pcall(function()
        local EquipmentExceptionReport = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if EquipmentExceptionReport then EquipmentExceptionReport.Report = noop end
    end)
    pcall(function()
        local TLog = _G.TLog or package.loaded["TLog"]
        if TLog then TLog.Info = noop; TLog.Warning = noop; TLog.Error = noop; TLog.Debug = noop; TLog.Report = noop end
    end)
    pcall(function()
        local pc = (slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController())
        if pc and pc.HiggsBosonComponent then
            pc.HiggsBosonComponent.bMHActive = false
            pc.HiggsBosonComponent:ControlMHActive(0)
        end
    end)
    pcall(function() _G.BlackList = {} end)
end

-- ==================== SELF-HEAL ====================
local function safeSelfHeal()
    pcall(function()
        local TM = safe_require("GameLua.Mod.BaseMod.Common.TickManager")
        if TM and TM.AddLoopTimer then
            TM.AddLoopTimer(120, function()
                pcall(function()
                    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                    if pc and pc.HiggsBosonComponent then
                        pc.HiggsBosonComponent.bMHActive = false
                        pc.HiggsBosonComponent:ControlMHActive(0)
                    end
                    if slua.isValid(pc) then
                        local pawn = pc:GetCurPawn()
                        if slua.isValid(pawn) then
                            pcall(function()
                                local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
                                if Higgs then
                                    Higgs.ControlMHActive = noop; Higgs.TriggerAvatarCheck = noop; Higgs.StartAvatarCheck = noop
                                    Higgs.ReportItemID = noop; Higgs.OnReportItemID = noop; Higgs.ReceiveAnyDamage = noop
                                    Higgs.OnWeaponHitRecord = noop; Higgs.ShowSecurityAlert = noop; Higgs.ServerReportAvatar = noop
                                    Higgs.ClientReportNetAvatar = noop; Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero
                                end
                                if _G.AvatarCheckCallback then _G.AvatarCheckCallback.StartAvatarCheck = noop; _G.AvatarCheckCallback.OnReportItemID = noop end
                            end)
                        end
                    end
                end)
                local modules = {"client.slua.logic.ban.ClientBanLogic","client.common.ban_util","client.logic.login.logic_tt_ban","client.slua.logic.ban.BanTipsLogic"}
                for _, modName in ipairs(modules) do
                    local mod = package.loaded[modName]
                    if mod then
                        for k, v in pairs(mod) do
                            if type(k) == "string" and (k:find("Ban") or k:find("Flag")) and type(v) == "function" then
                                mod[k] = retFalse
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== EXTRA BYPASS: GOKUBA LOGIC ====================
pcall(function()
    local Gokuba = _G.GokubaLogic or package.loaded["GokubaLogic"]
    if Gokuba then
        Gokuba.ForwardFeature = function() return end
        Gokuba.InitGokubaLogic = function() return end
    end
    if _G.NetUtil and _G.NetUtil.SendPkg then
        local origSendPkg = _G.NetUtil.SendPkg
        _G.NetUtil.SendPkg = function(packetName, ...)
            if packetName == "battle_client_sync_allstar_auth_check_result_req" then
                return
            end
            return origSendPkg(packetName, ...)
        end
    end
end)

-- ==================== EXTRA BYPASS: HOSTED PROTO ====================
pcall(function()
    local HostedProto = _G.HostedProtoConfig or package.loaded["HostedProtoConfig"]
    if HostedProto and HostedProto.Proto then
        if HostedProto.Proto.NationalEsportsSecurityCheck then
            HostedProto.Proto.NationalEsportsSecurityCheck.func = "noop"
        end
    end
end)

-- ==================== EXTRA BYPASS: ANTI-CHEAT SUBSYSTEM ====================
pcall(function()
    local AC_Subsystem = _G.AntiCheatSubsystem or package.loaded["GameLua.Mod.BaseMod.Client.Security.AntiCheatSubsystem"]
    if AC_Subsystem then
        AC_Subsystem.OnInit = function() return end
        AC_Subsystem.OnTick = function() return end
        AC_Subsystem.CheckAbnormalStatus = function() return false end
        AC_Subsystem.ReportSecurityData = function() return end
        AC_Subsystem.OnDetectionResult = function() return end
        AC_Subsystem.TriggerSafetyScan = function() return end
    end
end)

-- ==================== END OF BYPASS ENGINE ====================