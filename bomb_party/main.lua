local mod = RegisterMod("bomb party", 1)
local myRNG = RNG()
myRNG:SetSeed(Random()%1000000000+1,1)
local grid_indexs,g={},1
local new_room=false
function mod:spawnBombRock()
    if new_room then
        local room = Game():GetRoom()
        new_room=false
        for k, v in pairs(grid_indexs) do
            Isaac.GridSpawn (GridEntityType.GRID_ROCK_BOMB,0,room:GetGridPosition(v),true)
        end
    end
end
function mod:changeToBombRock()
    new_room=true
    grid_indexs,g={},1
    local room = Game():GetRoom()
    local grid_total_num=room:GetGridHeight( )*room:GetGridWidth()
    for i = 1,grid_total_num , 1 do
        local grid=room:GetGridEntity(i)
        if grid then
            if 
            (grid:GetType()==GridEntityType.GRID_ROCK and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCKB and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCKT and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_ALT and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_LOCK and grid.State~=1) or
            (grid:GetType()==GridEntityType.GRID_ROCK_SS and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_SPIKED and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_ALT2 and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_GOLD and grid.State~=2 )
            then
                grid_indexs[g]=grid:GetGridIndex()
                room:RemoveGridEntity(grid_indexs[g],0,false)
                g=g+1
            end
        end
    end
    if g>1 then
        room:Update()
        mod:spawnBombRock()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.changeToBombRock)

function mod:changToPolty(EntNPC)
    if EntNPC==nil then
        return
    end
    if EntNPC.Type~=816 and EntNPC.Type~=33 and EntNPC.Type~=17 then
        if myRNG:RandomInt(100)<=80 then
            EntNPC:Morph(816,0,0,5)
        else
            EntNPC:Morph(816,1,0,5)
        end 
        EntNPC.HitPoints=EntNPC.MaxHitPoints
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.changToPolty)

function mod:initPlayer2891(isC)
    if isC then
        return
    end
    local game = Game() 
    local player = Isaac.GetPlayer(0) 
    local oldChallenge = Isaac.GetChallenge() 
    game.Challenge = 6 
    player:UpdateCanShoot() 
    player:AddNullCostume(NullItemID.ID_BLINDFOLD)
    game.Challenge = oldChallenge
    player:AddCollectible(334)
    player:AddCollectible(334)
    player:AddCollectible(334)
    player:AddCollectible(334)
    player:AddCollectible(593)
    player:AddCollectible(635)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.initPlayer2891)