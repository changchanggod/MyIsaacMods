local mod= CCGChallenges45768
local utils=require("script.CCG_utils")
---@type integer|nil
local challengeId=utils.GetChallengeSafe("don't pick up shit")
---@type integer|nil
local shitId=utils.GetItemSafe("bad shit")
if challengeId==nil or shitId==nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId,false)

local setting=nil
local resetting=false
local function reset()
    if type(mod.Data)~=table then
        mod.Data={}
    end
    mod.Data.DNPUSSetting={
        shitNum=1,
        autoIncrease=1,
        RoomSizeConsider=true,
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
    if game.Challenge==challengeId then
        local room=game:GetRoom()
        if setting and setting.RoomSizeConsider then
            local shape=room:GetRoomShape()
            if shape==RoomShape.ROOMSHAPE_1x2 or shape==RoomShape.ROOMSHAPE_2x1 then
                num=num*2
            elseif shape==RoomShape.ROOMSHAPE_LTL or shape==RoomShape.ROOMSHAPE_LTR or shape==RoomShape.ROOMSHAPE_LBL or shape==RoomShape.ROOMSHAPE_LBR then
                num=num*3
            elseif shape==RoomShape.ROOMSHAPE_2x2 then
                num=num*4
            elseif shape==RoomShape.ROOMSHAPE_IH or shape==RoomShape.ROOMSHAPE_IV then
                num=num/2
            end
        end
        for i = 1, num, 1 do
            local pos=Isaac.GetRandomPosition()
            game:Spawn(5,100,room:FindFreePickupSpawnPosition(pos,10,true,true),Vector(0, 0),nil,shitId,room:GetSpawnSeed())
        end
    end

end
local function perRoomSpawnShit(_)
    local game=Game()
    if game.Challenge==challengeId then
        local room=game:GetRoom()
        if room:IsClear() then
            return
        end
        if not setting then
            return
        end
        spawnShit(setting.shitNum)
    end

end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,perRoomSpawnShit)
local function ifHasBadShit(_)
    if Game().Challenge==challengeId then
        local player=Isaac.GetPlayer()
        if player:HasCollectible(shitId) then
            player:TakeDamage(1,DamageFlag.DAMAGE_INVINCIBLE|DamageFlag.DAMAGE_NO_PENALTIES,EntityRef(nil),0)
            player:RemoveCollectible(shitId)
        end
    end
end 
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,ifHasBadShit)
local function increaseShitNumPerLevel(_)
    if Game().Challenge==challengeId and setting then
        setting.shitNum=setting.shitNum+setting.autoIncrease
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,increaseShitNumPerLevel)
local function resetShitNumPerGame(_,isC)
    if Game().Challenge==challengeId and setting and not isC then
        setting.shitNum=1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,resetShitNumPerGame)