local mod=CCGChallenges45768
local Utils={}
function Utils.GetChallengeSafe(challengeName)
    local cId = Isaac.GetChallengeIdByName(challengeName)
    if cId == -1 then
        Isaac.ConsoleOutput(string.format("[CCG][Error]: Challenge \"%s\" load failed, missing challenge\n", challengeName))
        return nil
    end
    return cId
end
function Utils.GetItemSafe(itemName)
    local tId=Isaac.GetItemIdByName(itemName)
    if tId== -1 then
        Isaac.ConsoleOutput(string.format("[CCG][Error]: item \"%s\" load failed, missing item\n", itemName))
        return nil
    end
    return tId
end

function Utils.getMCMDes(MCM,key)
    local lan = Options.Language
    lan = MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not (zhMCM) and lan == "zh" then
        lan = "en"
    end
    return MCM[lan] and MCM[lan][key]
end


local RECOMMENDED_SHIFT_IDX = 35
local game = Game()
local seeds = game:GetSeeds()
local startSeed = seeds:GetStartSeed()
local myRNG = RNG()
myRNG:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
function mod:setMyRNG(isC)
    if isC then
        return
    end
    game = Game()
    seeds = game:GetSeeds()
    startSeed = seeds:GetStartSeed()
    myRNG:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.setMyRNG)
function Utils.getRNG()
    return myRNG
end



local ChallengesSP={}
function Utils.allowChallengeSecretPath(cId,isEnd13)
    ChallengesSP[cId]=isEnd13
end
local lastListInd=nil
local shouldSpawnSecretPath=true
local function allowSecretPath(_,_,_)
    if ChallengesSP[Game().Challenge]~=nil then 
        local level = Game():GetLevel()
        local roomDescriptor = level:GetCurrentRoomDesc()
        local room=Game():GetRoom()
        if shouldSpawnSecretPath and room:IsCurrentRoomLastBoss() and room:IsClear() and roomDescriptor.ListIndex~=lastListInd then
            room:TrySpawnSecretExit(true,true)
            lastListInd=roomDescriptor.ListIndex
        end
    end
end
local function allowSecretPath2(_)
    if ChallengesSP[Game().Challenge]~=nil then 
        local room=Game():GetRoom()
        if shouldSpawnSecretPath and room:IsCurrentRoomLastBoss() and room:IsClear() then
            room:TrySpawnSecretExit(false,true)
        end
    end
end
local function allowSecretPath3(_)
    if ChallengesSP[Game().Challenge]~=nil then 
        lastListInd=nil
        local level = Game():GetLevel()
        local stage=level:GetStage()
        local stageT=level:GetStageType()
        if ChallengesSP[Game().Challenge] then
            shouldSpawnSecretPath=(stageT<=2 or stage==LevelStage.STAGE1_2) and stage~=LevelStage.STAGE3_1
        else
            shouldSpawnSecretPath=stageT<=2 or stage==LevelStage.STAGE2_2 or stage==LevelStage.STAGE1_2
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,allowSecretPath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,allowSecretPath2)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,allowSecretPath3)
return Utils