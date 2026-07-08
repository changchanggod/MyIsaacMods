local mod= CCGChallenges45768
---@type number
local challengeId = Isaac.GetChallengeIdByName("all_you_see_is_money")
if challengeId == -1 then
    Isaac.ConsoleOutput("[Error]:challenge all_you_see_is_money load failed")
    return nil
end


local PennyScale = 5
local DoublePennyScale = 7
local NickelScale = 9
local LuckyPennyScale = 10
local StickyNickelScale = 9
local DimeScale = 15
local GoldenPennyScale = 20
---@param EntPick EntityPickup
local function enlargeTheMoney(_, EntPick)
    if Game().Challenge==challengeId then
        if EntPick.Type == EntityType.ENTITY_PICKUP and EntPick.Variant == 20 then
            local scale = 1
            if EntPick.SubType == 1 then
                scale = PennyScale
            elseif EntPick.SubType == 2 then
                scale = NickelScale
            elseif EntPick.SubType == 3 then
                scale = DimeScale
            elseif EntPick.SubType == 4 then
                scale = DoublePennyScale
            elseif EntPick.SubType == 5 then
                scale = LuckyPennyScale
            elseif EntPick.SubType == 6 then
                scale = StickyNickelScale
            elseif EntPick.SubType == 7 then
                scale = GoldenPennyScale
            end
            EntPick.SpriteScale=Vector.One*scale
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, enlargeTheMoney)
