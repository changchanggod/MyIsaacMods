local mod=CCG_VS_YSD

local RC_room_seed=-1
local RC_room_index=-1

local RC_tear_to_projectile_flag={
    { TearFlags.TEAR_HOMING,ProjectileFlags.SMART },
    { TearFlags.TEAR_SLOW,ProjectileFlags.SLOWED },
    { TearFlags.TEAR_WIGGLE,ProjectileFlags.WIGGLE },
    { TearFlags.TEAR_BOOMERANG,ProjectileFlags.BOOMERANG },
    { TearFlags.TEAR_EXPLOSIVE,ProjectileFlags.EXPLODE },
    { TearFlags.TEAR_BOUNCE,ProjectileFlags.BOUNCE },
    { TearFlags.TEAR_CONTINUUM,ProjectileFlags.CONTINUUM },
    { TearFlags.TEAR_SHIELDED,ProjectileFlags.SHIELDED },
    { TearFlags.TEAR_GLOW,ProjectileFlags.GODHEAD },
    { TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.ACID_GREEN },
   -- { TearFlags.TEAR_ACID,ProjectileFlags.ACID_GREEN },
    --{ TearFlags.TEAR_LASERSHOT,ProjectileFlags.LASER_SHOT },
    { TearFlags.TEAR_HYDROBOUNCE,ProjectileFlags.BOUNCE_FLOOR },
    --{ TearFlags.TEAR_BURSTSPLIT,ProjectileFlags.BURSTSPLIT },
    { TearFlags.TEAR_FREEZE,ProjectileFlags.FREEZE },
    { TearFlags.TEAR_ICE,ProjectileFlags.FREEZE },
    { TearFlags.TEAR_TURN_HORIZONTAL,ProjectileFlags.TURN_HORIZONTAL },
    { TearFlags.TEAR_ACCELERATE,ProjectileFlags.ACCELERATE },
    { TearFlags.TEAR_DECELERATE,ProjectileFlags.DECELERATE }
}

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
    data.RC_last_position=EntT.Position
    data.RC_scale=EntT.Scale
    data.RC_height=EntT.Height
    data.RC_falling_speed=EntT.FallingSpeed
    data.RC_falling_acceleration=EntT.FallingAcceleration
    data.RC_color=EntT.Color
    data.RC_spectral=EntT:HasTearFlags(TearFlags.TEAR_SPECTRAL)
    data.RC_projectile_flags={}
    for _,flag in pairs(RC_tear_to_projectile_flag) do
        if EntT:HasTearFlags(flag[1]) then
            table.insert(data.RC_projectile_flags,flag[2])
        end
    end
end

---@param EntT EntityTear
local function RC_update_tear(_,EntT)
    local data=EntT:GetData()
    if not data.RC_echo_source then
        return
    end
    if not data.RC_spectral and Game():GetRoom():GetGridCollisionAtPos(EntT.Position)==GridCollisionClass.COLLISION_NONE then
        data.RC_last_position=EntT.Position
    end
end

---@param data table
---@param EntP EntityProjectile
local function RC_copy_projectile_flags(data,EntP)
    if data.RC_spectral then
        EntP:AddProjectileFlags(ProjectileFlags.GHOST)
        EntP:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
    end
    for _,flag in pairs(data.RC_projectile_flags) do
        EntP:AddProjectileFlags(flag)
    end
end

---@param EntT EntityTear
local function RC_spawn_echo(EntT)
    local data=EntT:GetData()
    local velocity=data.RC_velocity
    if velocity:Length()<0.1 then
        return
    end
    local position=EntT.Position
    if not data.RC_spectral and Game():GetRoom():GetGridCollisionAtPos(position)~=GridCollisionClass.COLLISION_NONE then
        position=data.RC_last_position-velocity:Normalized()*4
    end
    local echo=Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_TEAR,0,position,velocity*-1,nil):ToProjectile()
    echo.Damage=1
    echo.Scale=data.RC_scale
    echo.Height=data.RC_height
    echo.FallingSpeed=data.RC_falling_speed
    echo.FallingAccel=data.RC_falling_acceleration
    echo.Color=data.RC_color
    RC_copy_projectile_flags(data,echo)
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
    mod:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo,EntityType.ENTITY_TEAR)
    RC_set_room_info()
end

function mod:RC_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
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
