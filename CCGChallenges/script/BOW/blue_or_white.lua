local mod=CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeId=utils.GetChallengeSafe("blue or white")
local myRNG=utils.getRNG()
if not challengeId then
    return nil
end
utils.allowChallengeSecretPath(challengeId, false)

local setting = nil
local resetting = false
local function reset()
    if type(mod.Data) ~= "table" then
        mod.Data = {}
    end
    mod.Data.BOWSetting = {
        soulHeartChance = 80
    }
    setting = mod.Data.BOWSetting
end
if mod.Data and mod.Data.BOWSetting then
    setting = mod.Data.BOWSetting
else
    reset()
end

function mod:try(EntP)
    if Game().Challenge==challengeId and setting then
        if  EntP.Timeout>0
        and EntP.FrameCount==0
        and EntP.SubType~=8
        and EntP.SubType~=4 then
            local rand=myRNG:RandomInt(100)
            if rand<setting.soulHeartChance then
                EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,8)
                print(EntP.FrameCount)
            else
                EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,4)
                print(EntP.FrameCount)
            end
        end 
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.try,PickupVariant.PICKUP_HEART)