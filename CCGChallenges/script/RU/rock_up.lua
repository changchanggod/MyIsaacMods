local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="rock up"
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
    mod.Data.RUSetting = {
        moveSpeedChange=-1,
        damageChange=-1,
        fireDelayChange=-1,
        rangeChange=-1,
        shotSpeedChange=-1,
        luckChange=-1,
    }
    setting = mod.Data.RUSetting
end
if mod.Data and mod.Data.RUSetting then
    setting = mod.Data.RUSetting
else
    reset()
end

local fixPlayerState={
    ["moveSpeed"]=1,
    ["damage"]=1,
    ["fireDelay"]=1,
    ["range"]=1,
    ["shotSpeed"]=1,
    ["luck"]=1,
}

---@param EntP EntityPlayer
---@param flag CacheFlag
local function rockUp(_,EntP,flag)
    local game = Game()
    if game.Challenge ~= challengeId or not setting then
        return
    end
    local cfg = setting
    local state = fixPlayerState

    -- 1. 移速 CACHE_SPEED
    if flag & CacheFlag.CACHE_SPEED > 0 then
        if (EntP.MoveSpeed - state.moveSpeed) * cfg.moveSpeedChange > 0 then
            state.moveSpeed = EntP.MoveSpeed
        else
            EntP.MoveSpeed = state.moveSpeed
        end
    end

    -- 2. 伤害 CACHE_DAMAGE
    if flag & CacheFlag.CACHE_DAMAGE > 0 then
        if (EntP.Damage - state.damage) * cfg.damageChange > 0 then
            state.damage = EntP.Damage
        else
            EntP.Damage = state.damage
        end
    end

    -- 3. 射速 CACHE_FIREDELAY
    if flag & CacheFlag.CACHE_FIREDELAY > 0 then
        print(EntP.MaxFireDelay)
        if -(EntP.MaxFireDelay - state.fireDelay) * cfg.fireDelayChange > 0 then --Fire Delay is negatively correlated with fire rate.
            state.fireDelay = EntP.MaxFireDelay
        else
            EntP.MaxFireDelay = state.fireDelay
        end
    end

    -- 4. 弹速 CACHE_SHOTSPEED
    if flag & CacheFlag.CACHE_SHOTSPEED > 0 then
        if (EntP.ShotSpeed - state.shotSpeed) * cfg.shotSpeedChange > 0 then
            state.shotSpeed = EntP.ShotSpeed
        else
            EntP.ShotSpeed = state.shotSpeed
        end
    end

    -- 5. 射程 CACHE_RANGE
    if flag & CacheFlag.CACHE_RANGE > 0 then
        if (EntP.TearRange - state.range) * cfg.rangeChange > 0 then
            state.range = EntP.TearRange
        else
            EntP.TearRange = state.range
        end
    end

    -- 6. 幸运 CACHE_LUCK
    if flag & CacheFlag.CACHE_LUCK > 0 then
        if (EntP.Luck - state.luck) * cfg.luckChange > 0 then
            state.luck = EntP.Luck
        else
            EntP.Luck = state.luck
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,rockUp)
---@param EntP EntityPlayer
local function initState(_,EntP)
    if Game().Challenge==challengeId then
        fixPlayerState["moveSpeed"]=EntP.MoveSpeed
        fixPlayerState["damage"]=EntP.Damage
        fixPlayerState["fireDelay"]=EntP.MaxFireDelay
        fixPlayerState["range"]=EntP.TearRange
        fixPlayerState["shotSpeed"]=EntP.ShotSpeed
        fixPlayerState["luck"]=EntP.Luck
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,initState)