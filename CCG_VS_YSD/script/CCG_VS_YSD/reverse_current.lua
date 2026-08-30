local mod=CCG_VS_YSD

local RC_room_seed=-1
local RC_room_index=-1

local function RC_set_room_info()
    local room=Game():GetRoom()
    RC_room_seed=room:GetSpawnSeed()
    RC_room_index=Game():GetLevel():GetCurrentRoomIndex()
end

---@param EntT EntityTear
local function RC_mark_tear(_,EntT)
    local data=EntT:GetData()
    data.RC_echo_source=true
    data.RC_room_seed=RC_room_seed
    data.RC_room_index=RC_room_index
    data.RC_velocity=EntT.Velocity
end

---@param EntT EntityTear
local function RC_spawn_echo(EntT)
    local data=EntT:GetData()
    local velocity=data.RC_velocity
    if velocity:Length()<0.1 then
        return
    end
    local echo=Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_TEAR,0,EntT.Position,velocity*-1,nil):ToProjectile()
    echo.Damage=1
    echo.Scale=EntT.Scale
    echo.Color=Color(0.55,0.3,0.9,1,0,0,0)
end

---@param Ent Entity
local function RC_tear_become_echo(_,Ent)
    local EntT=Ent:ToTear()
    if not EntT then
        return
    end
    local data=EntT:GetData()
    if not data.RC_echo_source then
        return
    end
    if data.RC_room_seed~=RC_room_seed or data.RC_room_index~=RC_room_index then
        return
    end
    RC_spawn_echo(EntT)
end

function mod:RC_on()
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo,EntityType.ENTITY_TEAR)
    RC_set_room_info()
end

function mod:RC_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data.RC_on==nil then
    mod.Data.RC_on=false
end

local function reset_active()
    if mod.Data.RC_on then
        mod:RC_on()
    else
        mod:RC_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data.RC_on
        end,
        Display = function()
            return "逆流而上:"..tostring(mod.Data.RC_on)
        end,
        OnChange = function(boolean)
            if mod.Data.RC_on~=boolean then
                mod.Data.RC_on=boolean
                reset_active()
            end
            
        end,
        Info = { "泪弹命中或落地后，会反向变成回声弹" }
    })
end

reset_active()
