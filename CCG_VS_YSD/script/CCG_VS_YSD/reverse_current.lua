local mod=CCG_VS_YSD
local challenge_name="reverse current"

local RC_room_seed=-1
local RC_room_index=-1

-- 仅映射敌方投射物存在对应行为的泪弹特效
local RC_tear_to_projectile_flag={
    { TearFlags.TEAR_HOMING,ProjectileFlags.SMART },
    { TearFlags.TEAR_EXPLOSIVE,ProjectileFlags.EXPLODE },
    { TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.ACID_GREEN },
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.GOO }, --无对应
    --{ TearFlags.TEAR_SPECTRAL,ProjectileFlags.GHOST }, --特判
    --{ TearFlags.TEAR_WIGGLE,ProjectileFlags.WIGGLE },  --被MEGA_WIGGLE覆盖
    --{ TearFlags.TEAR_BOOMERANG,ProjectileFlags.BOOMERANG }, --未见效果
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.HIT_ENEMIES }, --无意义
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.ACID_RED }, --无对应
    { TearFlags.TEAR_GREED_COIN,ProjectileFlags.GREED },
    { TearFlags.TEAR_COIN_DROP,ProjectileFlags.GREED },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.RED_CREEP},--无对应
    --{ TearFlags.TEAR_BOUNCE,ProjectileFlags.	ORBIT_CW}, --TODO
    --{ TearFlags.TEAR_BOUNCE,ProjectileFlags.	ORBIT_CWW}, --TODO
    --{ TearFlags.TEAR_SPECTRAL,ProjectileFlags.NO_WALL_COLLIDE }, --特判
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.CREEP_BROWN},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.FIRE},--未见效果
    { TearFlags.TEAR_QUADSPLIT,ProjectileFlags.BURST},
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ANY_HEIGHT_ENTITY_HIT},--已包括
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.CURVE_LEFT},--TODO
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.CURVE_RIGHT},--TODO
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.TURN_HORIZONTAL},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SINE_VELOCITY},--无对应
    { TearFlags.TEAR_WIGGLE,ProjectileFlags.MEGA_WIGGLE },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SAWTOOTH_WIGGLE},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SLOWED},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.TRIANGLE},--无对应
    --{ TearFlags.TEAR_BOOMERANG,ProjectileFlags.MOVE_TO_PARENT}, --未见效果
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ACCELERATE},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.DECELERATE},--无对应
    --{ TearFlags.TEAR_BOOMERANG,ProjectileFlags.BURST3}, --未见效果
    { TearFlags.TEAR_CONTINUUM,ProjectileFlags.CONTINUUM },
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.CANT_HIT_PLAYER }, --无意义
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT }, --无意义
    --{ TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT }, --无意义
    --{ TearFlags.TEAR_BOUNCE,ProjectileFlags.	STASIS}, --TODO 反重力
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.FIRE_WAVE},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.FIRE_WAVE_X},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ACCELERATE_EX},--无对应
    { TearFlags.TEAR_ABSORB,ProjectileFlags.BURST8},
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.FIRE_SPAWN},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ANTI_GRAVITY},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.TRACTOR_BEAM},--未见效果
    { TearFlags.TEAR_BOUNCE,ProjectileFlags.BOUNCE },
    { TearFlags.TEAR_BOUNCE_WALLSONLY,ProjectileFlags.BOUNCE },
    { TearFlags.TEAR_HYDROBOUNCE,ProjectileFlags.BOUNCE_FLOOR },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SHIELDED},--未见效果
    { TearFlags.TEAR_SHIELDED,ProjectileFlags.SHIELDED },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.BLUE_FIRE_SPAWN},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.LASER_SHOT},--未见效果
    { TearFlags.TEAR_LASERSHOT,ProjectileFlags.LASER_SHOT },
    { TearFlags.TEAR_GLOW,ProjectileFlags.GODHEAD },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SMART_PERFECT},--无对应
    { TearFlags.TEAR_BURSTSPLIT,ProjectileFlags.BURSTSPLIT },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.WIGGLE_ROTGUT},--无对应
    { TearFlags.TEAR_FREEZE,ProjectileFlags.FREEZE },
    { TearFlags.TEAR_ICE,ProjectileFlags.FREEZE },
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ACCELERATE_TO_POSITION},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.BROCCOLI},--未见效果
    {TearFlags.TEAR_SPLIT, ProjectileFlags.BACKSPLIT},
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.SIDEWAVE},--无对应
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.ORBIT_PARENT},--未见效果
    --{ TearFlags.TEAR_COIN_DROP,ProjectileFlags.FADEOUT},--无对应
    { TearFlags.TEAR_TURN_HORIZONTAL,ProjectileFlags.TURN_HORIZONTAL },
    { TearFlags.TEAR_ACCELERATE,ProjectileFlags.ACCELERATE },
    { TearFlags.TEAR_DECELERATE,ProjectileFlags.DECELERATE }
}

-- 会将主攻击改为非普通泪弹，或额外叠加非泪弹主攻击的道具
local RC_remove_attack_item={
    CollectibleType.COLLECTIBLE_MOMS_KNIFE,
    CollectibleType.COLLECTIBLE_BRIMSTONE,
    CollectibleType.COLLECTIBLE_TECHNOLOGY,
    CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    CollectibleType.COLLECTIBLE_TECH_5,
    CollectibleType.COLLECTIBLE_TECH_X,
    CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE,
    CollectibleType.COLLECTIBLE_RED_CANDLE,
    CollectibleType.COLLECTIBLE_CANDLE,
    CollectibleType.COLLECTIBLE_DR_FETUS,
    CollectibleType.COLLECTIBLE_EPIC_FETUS,
    CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
    CollectibleType.COLLECTIBLE_C_SECTION,
    CollectibleType.COLLECTIBLE_SULFUR,
    CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID,
    CollectibleType.COLLECTIBLE_REVELATION,
    CollectibleType.COLLECTIBLE_SALVATION,
    CollectibleType.COLLECTIBLE_URN_OF_SOULS,
    CollectibleType.COLLECTIBLE_BERSERK,
    CollectibleType.COLLECTIBLE_DARK_ARTS,
    CollectibleType.COLLECTIBLE_MEGA_BLAST,
    CollectibleType.COLLECTIBLE_LARYNX,
    CollectibleType.COLLECTIBLE_ANTI_GRAVITY,
    CollectibleType.COLLECTIBLE_AKELDAMA,
    CollectibleType.COLLECTIBLE_TAURUS,

}

local function RC_remove_attack_item_from_pool()
    local item_pool=Game():GetItemPool()
    for _,item_id in pairs(RC_remove_attack_item) do
        item_pool:RemoveCollectible(item_id)
    end
end

local function RC_set_room_info()
    local room=Game():GetRoom()
    RC_room_seed=room:GetSpawnSeed()
    RC_room_index=Game():GetLevel():GetCurrentRoomIndex()
end

local function RC_tear_can_pass_grid(position)
    local collision=Game():GetRoom():GetGridCollisionAtPos(position)
    return collision~=GridCollisionClass.COLLISION_SOLID
        and collision~=GridCollisionClass.COLLISION_WALL
        and collision~=GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
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
    data.RC_tiny_planet=EntT:HasTearFlags(TearFlags.TEAR_ORBIT)
        or EntT:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED)
    data.RC_orbit_curve_flag=ProjectileFlags.CURVE_LEFT
    local owner=EntT.SpawnerEntity and EntT.SpawnerEntity:ToPlayer()
    if owner then
        data.RC_owner_index=owner.Index
    end
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
    if data.RC_tiny_planet and data.RC_owner_index then
        local owner=Isaac.GetPlayer(data.RC_owner_index)
        local offset=EntT.Position-owner.Position
        local rotate_direction=offset.X*EntT.Velocity.Y-offset.Y*EntT.Velocity.X
        if rotate_direction>0 then
            data.RC_orbit_curve_flag=ProjectileFlags.CURVE_LEFT
        elseif rotate_direction<0 then
            data.RC_orbit_curve_flag=ProjectileFlags.CURVE_RIGHT
        end
    end
    if not data.RC_spectral and RC_tear_can_pass_grid(EntT.Position) then
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

---@param position Vector
---@param velocity Vector
---@param data table
---@param curve_flag ProjectileFlags|nil
local function RC_spawn_one_echo(position,velocity,data,curve_flag)
    local echo=Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_TEAR,0,position,velocity*-1,nil):ToProjectile()
    if echo~=nil then
        echo.Damage=1
        echo.Scale=data.RC_scale
        echo.Height=data.RC_height
        echo.FallingSpeed=data.RC_falling_speed
        echo.FallingAccel=data.RC_falling_acceleration
        echo.Color=data.RC_color
        echo:AddProjectileFlags(ProjectileFlags.ANY_HEIGHT_ENTITY_HIT)
        RC_copy_projectile_flags(data,echo)
        if curve_flag then
            echo:AddProjectileFlags(curve_flag)
        end
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
    if not data.RC_spectral and not RC_tear_can_pass_grid(position) then
        position=data.RC_last_position
    end
    if data.RC_tiny_planet then
        RC_spawn_one_echo(position,velocity,data,data.RC_orbit_curve_flag)
    else
        RC_spawn_one_echo(position,velocity,data,nil)
    end
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
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,RC_remove_attack_item_from_pool)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,RC_remove_attack_item_from_pool)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo,EntityType.ENTITY_TEAR)
    RC_set_room_info()
end

function mod:RC_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,RC_remove_attack_item_from_pool)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,RC_set_room_info)
    mod:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,RC_mark_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,RC_update_tear)
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,RC_tear_become_echo)
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
        mod:RC_on()
    else
        mod:RC_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data[challenge_name]
        end,
        Display = function()
            return "逆流而上:"..tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name]~=boolean then
                mod.Data[challenge_name]=boolean
                reset_active()
            end
            
        end,
        Info = { "泪弹命中或落地后，会反向变成回声弹" }
    })
end

reset_active()
