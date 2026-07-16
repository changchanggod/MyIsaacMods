local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="ultra hard greed"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
local championIgnore={}
---@param entN EntityNPC
local function turnIntoChampion(_,entN)
    if entN:IsChampion() or championIgnore[utils.TypeToNum(entN.Type,entN.Variant,entN.SubType)] then
        return
    end
    entN:MakeChampion(Game():GetSeeds():GetStartSeed(),-1,true)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT,turnIntoChampion)