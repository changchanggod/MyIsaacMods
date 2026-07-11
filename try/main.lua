local mod=RegisterMod("try", 1)
---@param EntP EntityPickup
function mod:try(EntP)
    if  EntP.Timeout>0
    and EntP.FrameCount==0
    and EntP.SubType~=8
    and EntP.SubType~=4 then
        if Random()%100>50 then
            EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,8)
            print(EntP.FrameCount)
        else
            EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,4)
            print(EntP.FrameCount)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.try,PickupVariant.PICKUP_HEART)