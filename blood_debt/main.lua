local mod = RegisterMod("blood_debt", 1)
local tId=Isaac.GetItemIdByName("blood debt")
if tId== -1 then
    Isaac.ConsoleOutput(string.format("[Error]: item \"%s\" load failed, missing item\n","blood_debt"))
    return nil
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_,isC)
    if isC then
        return
    end
    local game = Game()
    local room = game:GetRoom()
    game:Spawn(5, 100, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 10, true, true), Vector(0, 0), nil, tId,
                room:GetSpawnSeed())
end)

local lastSpawnerInd=-1
function mod:blood_debt()
    if Isaac.RunCallback("yourBloodDebt820")==nil then
        local player=Isaac.GetPlayer()
        if player:GetPlayerType()==PlayerType.PLAYER_KEEPER_B then
            if player:GetNumCoins()>0 then
                player:AddCoins(-1)
            else
                player:TakeDamage (2,DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG, EntityRef(nil), 2)
                player:ResetDamageCooldown(0)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.blood_debt)
function mod:harvestCoins(EntP)
    if EntP.Type==EntityType.ENTITY_PICKUP 
    and EntP.SubType==1
    and EntP.SpawnerEntity
    and EntP.SpawnerEntity.Index~=lastSpawnerInd then
        EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,4)
        lastSpawnerInd=EntP.SpawnerEntity.Index
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.harvestCoins,PickupVariant.PICKUP_COIN)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    lastSpawnerInd=-1
end)

if EID then
    EID:addCollectible(tId,
        "敌人死亡时扣一块钱"..
        "#{{Heart}} 没钱时，受到一次伤害" ..
        "#敌人掉落的钱增加".. 
        "#略鸭专属，里店特供版"..
        "#此为第二版，难度上升，故不再强求百变怪终点",
        "死债",
        "zh_cn")
end

-- l local player=Isaac.GetPlayer() player:TakeDamage (2.0,DamageFlag.DAMAGE_IV_BAG |	DamageFlag.DAMAGE_NOKILL , EntityRef(nil),30)
-- l local player=Isaac.GetPlayer() print(player:GetLastDamageFlags ( ))
-- l local player=Isaac.GetPlayer() local ref=player:GetLastDamageSource() local ent=ref.Entity print(ent==nil)