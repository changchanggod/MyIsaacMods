local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="ultra hard greed"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
local myRNG=utils.getRNG()

local championWeight={
    [0]=20,
    [1]=20,
    [2]=20,
    [3]=10,
    [4]=10,
    [5]=20,
    [6]=1,
    [7]=20,
    [8]=2,
    [9]=2,
    [10]=20,
    [11]=2,
    [12]=10,
    [13]=20,
    [14]=5,
    [15]=5,
    [16]=5,
    [17]=5,
    [18]=5,
    [19]=5,
    [20]=2,
    [21]=2,
    [22]=2,
    [23]=2,
    [24]=2,
    [25]=1,
}
local prefix = {}
local total = 0
for key, v in pairs(championWeight) do
    total = total + v
    table.insert(prefix, {sum = total, data = key})
end

local champion={}
---@param entN EntityNPC
local function turnIntoChampion(_,entN)
    if Game().Challenge==challengeId then
        if entN.SpawnerEntity then
            print(entN.Type,entN.Variant,entN.SubType)
        end
        if entN:IsBoss() or entN:IsChampion() or champion[utils.TypeToNum(entN.Type,entN.Variant,entN.SubType)]==nil then
            return
        end
        local rand=myRNG:RandomInt(total)+1
        for _, p in ipairs(prefix) do
            if rand <= p.sum then
                entN:MakeChampion(Game():GetSeeds():GetStartSeed(),p.data,true)
                entN.HitPoints=entN.MaxHitPoints
                break
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT,turnIntoChampion)