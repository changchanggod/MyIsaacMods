local mod = RegisterMod("create_maze", 1)
function mod:create_maze()
    local room = Game():GetRoom()
    local grid_count,grid_total_num=0,room:GetGridHeight( )*room:GetGridWidth()
    local grid_total_count=grid_total_num
    for i = 1,grid_total_num , 1 do
        local grid=room:GetGridEntity(i)
        if grid then
            if 
            (grid:GetType()==GridEntityType.GRID_ROCK and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCKB and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCKT and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_BOMB and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_ALT and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_LOCK and grid.State~=1) or
            (grid:GetType()==GridEntityType.GRID_TNT and grid.State~=4 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_SS and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_PILLAR and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_SPIKED and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_ALT2 and grid.State~=2 ) or
            (grid:GetType()==GridEntityType.GRID_ROCK_GOLD and grid.State~=2 )
            then
                grid_count=grid_count+1
            elseif 
            grid:GetType()==GridEntityType.GRID_PIT or
            grid:GetType()==GridEntityType.GRID_SPIKES or
            grid:GetType()==GridEntityType.GRID_SPIKES_ONOFF or
            grid:GetType()==GridEntityType.GRID_SPIDERWEB or
            grid:GetType()==GridEntityType.GRID_POOP or
            grid:GetType()==GridEntityType.GRID_WALL or
            grid:GetType()==GridEntityType.GRID_DOOR or
            grid:GetType()==GridEntityType.GRID_TRAPDOOR or
            grid:GetType()==GridEntityType.GRID_STAIRS or
            grid:GetType()==GridEntityType.GRID_PRESSURE_PLATE or
            grid:GetType()==GridEntityType.GRID_STATUE or    
            grid:GetType()==GridEntityType.GRID_TELEPORTER then
                grid_total_count=grid_total_count-1
            end
        end
    end
    if grid_count==0 or grid_total_count/grid_count>2 then
        Isaac.GetPlayer():UseCard(Card.CARD_REVERSE_TOWER,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.create_maze)