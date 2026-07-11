local mod= CCGChallenges45768
local utils=require("script.CCG_utils")
---@type integer|nil
local challengeId=utils.GetChallengeSafe("don't pick up shit")
---@type integer|nil
local shitId=utils.GetItemSafe("bad shit")
if challengeId==nil or shitId==nil then
    return nil
end

local setting=nil
local resetting=false
local function reset()
    if type(mod.Data)~=table then
        mod.Data={}
    end
    mod.Data.DNPUSSetting={
        shitNum=1,
        autoIncrease=1,
        bigRoomSpecial=true,
        avoidDoorKill=true
    }
    setting=mod.Data.DNPUSSetting
end
if mod.Data and mod.Data.DNPUSSetting then
    setting=mod.Data.DNPUSSetting
else
    reset()
end

utils.allowChallengeSecretPath(challengeId,false)
local function spawnShit(num)
    local game=Game()
    local room=game:GetRoom()
    for i = 1, num, 1 do
        local pos=room:GetRandomPosition(1)
        game:Spawn(5,100,pos,Vector(0, 0),nil,shitId,room:GetSpawnSeed())
    end
end
local function perRoomSpawnShit(_)
    local game=Game()
    local room=game:GetRoom()
    if room:IsClear() then
        return
    end
    if not setting then
        return
    end
    spawnShit(setting.shitNum)
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,perRoomSpawnShit)