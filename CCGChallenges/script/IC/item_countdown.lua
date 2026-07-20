local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="item countdown"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId,false)

local setting = nil
local resetting = false
local function reset()
    if type(mod.Data) ~= "table" then
        mod.Data = {}
    end
    mod.Data.ICSetting = {
        frameInterval=300,
        idChangeNum=-1,
        activePassiveDif=true
    }
    setting = mod.Data.ICSetting
end
if mod.Data and mod.Data.ICSetting then
    setting = mod.Data.ICSetting
else
    reset()
end

local itemConfig=Isaac.GetItemConfig()
local invalidItem={[59]=true }
local itemTotalNum=732
local function getNextItem(i,change)
    local nextItemId=i
    local config=nil
    repeat
        
        nextItemId=nextItemId+change
        if invalidItem[nextItemId] then
            nextItemId=nextItemId+change
        end
        config=itemConfig:GetCollectible(nextItemId)
        
        if nextItemId<=0 or nextItemId>itemTotalNum then
            break
        end
    until config~=nil
    return config,nextItemId
end
local function itemCountDown()
    if Game().Challenge==challengeId and setting then
        if setting.idChangeNum==0 then
            return
        end
        if Game():GetFrameCount()% setting.frameInterval==0 then
            local player=Isaac.GetPlayer()
            local change=Game():GetLevel():IsAscent() and -setting.idChangeNum or setting.idChangeNum
            local charges={}
            for i=0,3 do
                charges[i]=player:GetActiveCharge(i)+player:GetBatteryCharge(i)            
            end
            local startN,endN,stepN=1,itemTotalNum,1
            if change>0 then
                startN,endN,stepN=itemTotalNum,1,-1
            end
            for i=startN,endN,stepN do
                if player:HasCollectible(i,true) then
                    local config=itemConfig:GetCollectible(i)
                    local nextItemId=i
                    local isActive=config.Type==ItemType.ITEM_ACTIVE
                    local config2=nil
                    repeat
                        config2,nextItemId=getNextItem(nextItemId,change)
                        if config2 == nil then
                            break
                        end
                        if isActive == (config2.Type == ItemType.ITEM_ACTIVE) or not setting.activePassiveDif then
                            break
                        end
                    until nextItemId<=0 or nextItemId>itemTotalNum
                    while player:HasCollectible(i,true) do
                        player:RemoveCollectible(i,true)
                        if nextItemId>0 and nextItemId<=itemTotalNum then
                            player:AddCollectible(nextItemId,0,false)
                        end
                    end
                end
            end
            for i=0,3 do
                player:SetActiveCharge(charges[i],i)              
            end
        end
    end
    
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,itemCountDown)

------------------------------------------------------------------------------------

local IC_MCM = {
    zh = {
        MN = "CCG挑战合集",
        ST = "道计时",
        T0 = "对应挑战："..challengeName,
        T1 = "道计时设置",
        N0 = "道具变化时间间隔:",
        N00 =" 秒",
        K0 = "每经过一段时间，所有道具将按设定进行变化",
        N1 = "道具id变化设定:",
        K1 = "每经过一段时间，所有道具将按设定进行变化",
        N2 = "区分主动被动:",
        K2 = "如果设为True，主动道具将一直变化直到下一个道具是主动道具，或因超出范围而消失。被动道具同理",
        N3 = "重置",
        K3 = "将所有设置重置回默认值",
    },
    en = {
        MN = "CCG Challenge Collection",  -- 保持不变，符合命名规范
        ST = challengeName,       -- 道计时 → 道具轮换计时器（游戏术语）
        --T0 = "Corresponding Challenge: "..challengeName,  -- 补全中文对应的翻译
        T1 = "Settings",    -- 道计时设置 → 道具轮换设置
        N0 = "Item Rotation Interval:",   -- 道具变化时间间隔
        N00 =" s",
        K0 = "All items will change according to settings at specified time intervals",  -- 准确对应中文描述
        N1 = "Item ID Rotation Rules:",   -- 道具id变化设定
        K1 = "All items will change according to the configured rules at specified time intervals",  -- 准确对应中文描述
        N2 = "Separate Active/Passive:",  -- 区分主动被动（游戏标准术语）
        K2 = "If set to True, Active Items will keep rotating until the next item is also Active, or disappears when exceeding ID range. Same logic applies to Passive Items",  -- 精准对应中文，使用游戏术语Active/Passive Items
        N3 = "RESET ALL SETTINGS",                     -- 重置（简洁大写符合游戏菜单风格）
        K3 = "RESET ALL SETTINGS TO DEFAULT",  -- 准确对应中文描述
    }
}
if ModConfigMenu and setting ~= nil then
    local MN = utils.getMCMDes(IC_MCM, "MN")
    local ST = utils.getMCMDes(IC_MCM, "ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    if utils.getMCMDes(IC_MCM, "T0") then
        ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(IC_MCM, "T0"))
        ModConfigMenu.AddSpace(MN, ST)
    end
    ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(IC_MCM, "T1"))
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.frameInterval/30
        end,
        Minimum = 1,
        Maximum = 300,
        Display = function()
            return utils.getMCMDes(IC_MCM, "N0") .. (setting.frameInterval/30)..utils.getMCMDes(IC_MCM, "N00")
        end,
        OnChange = function(n)
            setting.frameInterval = n*30
        end,
        Info = { utils.getMCMDes(IC_MCM, "K0") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.idChangeNum
        end,
        Minimum = -50,
        Maximum = 50,
        Display = function()
            return utils.getMCMDes(IC_MCM, "N1") ..setting.idChangeNum
        end,
        OnChange = function(n)
            setting.idChangeNum=n
        end,
        Info = { utils.getMCMDes(IC_MCM, "K1") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return setting.activePassiveDif
        end,
        Display = function()
            return utils.getMCMDes(IC_MCM, "N2") .. tostring(setting.activePassiveDif)
        end,
        OnChange = function(n)
            setting.activePassiveDif = n
        end,
        Info = { utils.getMCMDes(IC_MCM, "K2") }
    })
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return resetting
        end,
        Display = function()
            return utils.getMCMDes(IC_MCM, "N3")
        end,
        OnChange = function(boolean)
            resetting = boolean
            reset()
        end,
        Info = { utils.getMCMDes(IC_MCM, "K3") }
    })
end