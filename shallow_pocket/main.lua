local mod = RegisterMod("shallow_pocket", 1)
local maxCoins=15
local maxCoinsWithDeepPocket=30
function mod:maxCoins()
    local player=Isaac.GetPlayer()
    if player:GetPlayerType()==PlayerType.PLAYER_KEEPER_B then
        local limit=maxCoins
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
            limit=maxCoinsWithDeepPocket
        end
        if player:GetNumCoins()>limit then
            player:AddCoins(limit-player:GetNumCoins())
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.maxCoins)
function mod:setIsaacMaxCoins()
    local limit=maxCoins
    local player=Isaac.GetPlayer()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
        limit=maxCoinsWithDeepPocket
    end
    return limit
end
mod:AddCallback("setIsaacMaxCoins820", mod.setIsaacMaxCoins)
if EID then
    EID:addCollectible(416,
    "#{{Coin}} 若清理房间没有奖励，则生成1-3硬币"..
    "#{{Coin}} 提高硬币上限至30" ,
    "深口袋",
    "zh_cn")
end