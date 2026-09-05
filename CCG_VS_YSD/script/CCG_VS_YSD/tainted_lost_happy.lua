local mod=CCG_VS_YSD
local challenge_name="tainted lost happy"
---@param EntNPC EntityNPC
local function TLH_enemy_champion13(_,EntNPC)
    EntNPC:MakeChampion (EntNPC.InitSeed,13,true)
    EntNPC.HitPoints=EntNPC.MaxHitPoints
end

local grid_indexs,g={},1
local new_room=false
local function TLH_spawn_spiked_sock()
    if new_room then
        local room = Game():GetRoom()
        new_room=false
        for k, v in pairs(grid_indexs) do
            Isaac.GridSpawn (GridEntityType.GRID_ROCK_SPIKED,0,room:GetGridPosition(v),true)
        end
    end
end
local function TLH_change_to_spiked_sock()
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
        TLH_spawn_spiked_sock()
    end
end


---@param EntP EntityPlayer
local function TLH_force_the_lost_B(_,EntP)
    if EntP:GetPlayerType()~=PlayerType.PLAYER_THELOST_B then
        EntP:ChangePlayerType(PlayerType.PLAYER_THELOST_B)
        Game():GetHUD():ShowFortuneText("万变不离其宗")
    end
end
function mod:TLH_on()
    mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, TLH_enemy_champion13)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,TLH_force_the_lost_B)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TLH_change_to_spiked_sock)
end
function mod:TLH_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, TLH_enemy_champion13)
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,TLH_force_the_lost_B)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, TLH_change_to_spiked_sock)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data[challenge_name]==nil then
    mod.Data[challenge_name]=false
end

local function reset_active()
    if mod.Data[challenge_name] then
        mod:TLH_on()
    else
        mod:TLH_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data[challenge_name]
        end,
        Display = function()
            return "里罗快乐挑战:"..tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name]~=boolean then
                mod.Data[challenge_name]=boolean
                reset_active()
            end
            
        end,
        Info = { "所有怪物为八向血泪变异，所有石头为刺石头" }
    })
end
