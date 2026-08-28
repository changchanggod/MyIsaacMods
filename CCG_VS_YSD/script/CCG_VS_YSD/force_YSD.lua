local mod=CCG_VS_YSD
local taunt={
    [1]="逃避虽然可耻 但是没用",
    [2]="略鸭不完全 相当于完全不略鸭",
    [3]="亚波伦对你使用了虚空"
}
local taunt_enable=false
local taunt_countDown=-1
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