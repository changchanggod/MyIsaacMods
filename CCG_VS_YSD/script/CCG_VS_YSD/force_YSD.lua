local mod=CCG_VS_YSD
local taunt={
    [1]="逃避虽然可耻 但是没用",
    [2]="略鸭不完全 相当于完全不略鸭",
    [3]="亚波伦对你使用了虚空"
}
local taunt_enable=false
local taunt_countDown=-1
local donation_machine_variant=8
local greed_donation_machine_variant=11

local function avoid_donation_machine()
    for _,slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT,-1,-1,false,false)) do
        if slot.Variant==donation_machine_variant
        or slot.Variant==greed_donation_machine_variant then
            slot:Remove()
        end
    end
end

local function players_has_item(item_id)
    local ind=0
    local checked={}
    while true do
        local player=Isaac.GetPlayer(ind)
        if checked[player.Index] then
            break
        end
        checked[player.Index]=true
        if player:HasCollectible(item_id,true) then
            return true
        end
        ind=ind+1
    end
    return false
end
function mod:avoid_Isaac_Satan_end()
    local level=Game():GetLevel()

    if level:GetStage()==LevelStage.STAGE5 then
        if (level:GetStageType()==0 and not players_has_item(328)) 
        or (level:GetStageType()==1 and not players_has_item(327)) then
            Game():StartStageTransition(false,3,Isaac.GetPlayer())
            taunt_enable=true
            return false
        end
    end
    return nil
end
function mod:taunt_enable()
    if taunt_enable then
        taunt_countDown=30
        taunt_enable=false
    end
end
function mod:taunt()
    if taunt_countDown<=-1 then
        return
    end
    if taunt_countDown==0 then
        local rand=Random()
        Game():GetHUD():ShowFortuneText(taunt[rand%#taunt+1])
    end
    taunt_countDown=taunt_countDown-1
    
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION,mod.avoid_Isaac_Satan_end,PickupVariant.PICKUP_BIGCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION,mod.avoid_Isaac_Satan_end,PickupVariant.PICKUP_TROPHY)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,mod.taunt_enable)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,mod.taunt)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,avoid_donation_machine)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,avoid_donation_machine)
