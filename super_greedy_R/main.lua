local mod = RegisterMod("super_greedy", 1)

local RECOMMENDED_SHIFT_IDX = 35
local game = Game()
local seeds = game:GetSeeds()
local startSeed = seeds:GetStartSeed()
local myRNG = RNG()
myRNG:SetSeed(startSeed~=0 and startSeed or 1 , RECOMMENDED_SHIFT_IDX)
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


local goldenCoinSuccess = 0.9077
function mod:spawnGoldenCoins()
    if myRNG:RandomFloat() <= goldenCoinSuccess then
        local room = game:GetRoom()
        local grid_total_num=room:GetGridHeight( )*room:GetGridWidth()
        local emptyPos,emptyPosCount={},0
        local pos,posCount={},0
        for i = 1,grid_total_num , 1 do
            local grid=room:GetGridEntity(i)
            if grid then
                if 
                    (grid:GetType()==GridEntityType.GRID_ROCK and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCKB and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCKT and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCK_ALT and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_LOCK and grid.State==1) or
                    (grid:GetType()==GridEntityType.GRID_ROCK_SS and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCK_SPIKED and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCK_ALT2 and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_ROCK_GOLD and grid.State==2 ) or
                    (grid:GetType()==GridEntityType.GRID_SPIKES_ONOFF ) or
                    (grid:GetType()==GridEntityType.GRID_SPIDERWEB) or
                    (grid:GetType()==GridEntityType.GRID_POOP) or
                    (grid:GetType()==GridEntityType.GRID_PRESSURE_PLATE ) or
                    (grid:GetType()==GridEntityType.GRID_TELEPORTER)
                then
                    pos[posCount]=i
                    posCount=posCount+1
                end
            else
                emptyPos[emptyPosCount]=i
                emptyPosCount=emptyPosCount+1
            end
        end
        local finalPos=nil
        if emptyPosCount>0 then
            finalPos=emptyPos[myRNG:RandomInt(emptyPosCount)]
        elseif posCount>0 then
            finalPos=pos[myRNG:RandomInt(posCount)]
        end
        if finalPos then
            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, room:GetGridPosition(finalPos), Vector.Zero, nil,7,startSeed)
        else
            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN,Isaac.GetRandomPosition(), Vector.Zero, nil,7,startSeed)
        end
        
    end
end

function mod:ButtPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY)
    EntP:UseActiveItem ( CollectibleType.COLLECTIBLE_BEAN)
end
function mod:BloodyPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_BLOODY_PENNY)
    local probability=1-(math.max(0.25*(4- trinketCount),0))^orgValue
    if myRNG:RandomFloat()<=probability then
        game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,Isaac.GetFreeNearPosition(EntPick.Position,1), Vector.Zero, nil,2,startSeed)
    end
end
function mod:BurntPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_BURNT_PENNY)
    local probability=1-(math.max(0.25*(4- trinketCount),0))^orgValue
    if myRNG:RandomFloat()<=probability then
        game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.	PICKUP_BOMB,Isaac.GetFreeNearPosition(EntPick.Position,1), Vector.Zero, nil,0,startSeed)
    end
end
function mod:FlatPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_PENNY)
    local probability=1-(math.max(0.25*(4- trinketCount),0))^orgValue
    if myRNG:RandomFloat()<=probability then
        game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY,Isaac.GetFreeNearPosition(EntPick.Position,1), Vector.Zero, nil,0,startSeed)
    end
end
function mod:RottenPennyFix(EntP,EntPick)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) --TODO REP+ fix
    EntP:AddBlueFlies(1,EntPick.Position,EntP)
end
function mod:BlessedPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_BLESSED_PENNY)
    local probability=1-(5/6)^orgValue  --TODO REP+ fix
    if myRNG:RandomFloat()<=probability then
        game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,Isaac.GetFreeNearPosition(EntPick.Position,1), Vector.Zero, nil,8,startSeed)
    end
end
function mod:ChargedPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_CHARGED_PENNY)
    local probability=1-(5/6)^orgValue  
    if myRNG:RandomFloat()<=probability then
        --local itemConfig=Isaac.GetItemConfig()
        for i = 0,3  do
            local item=EntP:GetActiveItem(i)
            if item~=0 and EntP:NeedsCharge(i) then  --itemConfig:GetCollectible(item).ChargeType~=2 maybe unnecessary
                EntP:SetActiveCharge(EntP:GetActiveCharge(i)+EntP:GetBatteryCharge(i)+1,i)--TODO REP+ fix     The Battery fix
                break
            end
        end
    end
end
function mod:CursedPennyFix(EntP,EntPick,orgValue)
    if EntP:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        return
    end
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_CURSED_PENNY)
    game:MoveToRandomRoom(true,Random(),EntP) --TODO Rep+ fixed
end
function mod:CounterfeitPennyFix(EntP,EntPick,orgValue)
    local trinketCount=EntP:GetTrinketMultiplier(TrinketType.TRINKET_COUNTERFEIT_PENNY)
    local probability=1-0.5^orgValue
    if myRNG:RandomFloat()<=probability then
        return orgValue+trinketCount
    end
end

function mod:addCoinFirst(EntPick, EntP)
    if EntP.Type ~= EntityType.ENTITY_PLAYER then
        return nil
    end
    EntP = EntP:ToPlayer()
    if EntP:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        local maxCoins = Isaac.RunCallback("setIsaacMaxCoins820")
        if maxCoins == nil then
            if EntP:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
                maxCoins = 999
            else
                maxCoins = 99
            end
        end
        if EntP:GetHearts() == EntP:GetMaxHearts() then
            return nil
        elseif EntP:GetNumCoins() >= maxCoins then
            return nil
        else
            local coinCount = EntPick:GetCoinValue()
            if EntPick.SubType == 5 then
                EntP:DonateLuck(1)
            elseif EntPick.SubType == 6 then
                return nil
            elseif EntPick.SubType == 7 then
                mod:spawnGoldenCoins()
            end
            if EntP:HasTrinket(TrinketType.TRINKET_BUTT_PENNY) then
                mod:ButtPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_BLOODY_PENNY) then
                mod:BloodyPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_BURNT_PENNY) then
                mod:BurntPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_FLAT_PENNY) then
                mod:FlatPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_ROTTEN_PENNY) then
                mod:RottenPennyFix(EntP,EntPick)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_BLESSED_PENNY) then
                mod:BlessedPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_CHARGED_PENNY) then
                mod:ChargedPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) then
                mod:CursedPennyFix(EntP,EntPick,coinCount)
            end
            if EntP:HasTrinket(TrinketType.TRINKET_COUNTERFEIT_PENNY) then
                coinCount=mod:CounterfeitPennyFix(EntP,EntPick,coinCount)
            end
            local overFlowCoins = math.max(0, EntP:GetNumCoins() + coinCount - maxCoins)
            local dif = EntP:GetMaxHearts() - EntP:GetHearts()
            EntP:AddCoins(dif / 2)
            EntP:AddCoins(coinCount)
            EntP:AddHearts(-dif)
            EntP:AddCoins(overFlowCoins)
            EntPick.Velocity = Vector.Zero
            EntPick:PlayPickupSound()
            EntPick:GetSprite():Play("Collect")
            EntPick:Die()
            return true
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.addCoinFirst, PickupVariant.PICKUP_COIN)

function mod:myBloodDebt()
    local player = Isaac.GetPlayer()
    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        if player:GetHearts() > 2 or player:GetNumCoins() == 0 then
            player:TakeDamage(2, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag
            .DAMAGE_IV_BAG, EntityRef(nil), 2)
            player:ResetDamageCooldown(0)
        else
            player:AddCoins(-1)
        end
        return 1
    end
end

mod:AddCallback("yourBloodDebt820", mod.myBloodDebt)

-- l local player=Isaac.GetPlayer() print(player:GetHearts())
-- l local player=Isaac.GetPlayer() print(player:GetMaxHearts())
-- l local player=Isaac.GetPlayer() player:AddCoins(1)
-- l local player=Isaac.GetPlayer() player:AddHearts(1)
