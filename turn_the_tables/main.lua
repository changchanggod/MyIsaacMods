local mod = RegisterMod("turn_the_tables", 1)
local relative_motion=false
local origin_Friction_P=0
local force_pos=Vector.Zero
local Ent_Ptr=nil
local motion_V=8
local last_dir=Vector.Zero

local rShootLeft=false
local rShootRight=false
local rShootUp=false
local rShootDown=false
function mod:getPlayerAction(_)
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) then
        rShootLeft=true
    else
        rShootLeft=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        rShootRight=true
    else 
        rShootRight=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) then
        rShootUp=true
    else 
        rShootUp=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) then
        rShootDown=true
    else 
        rShootDown=false
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.getPlayerAction)
function mod:judgePlayerAction(Ent)
    if Ent==nil then
        return
    end
    if Ent.Type~=3 or Ent.Variant~=240 or Ent.SubType~=0 then
        return
    end 
    local player=Isaac.GetPlayer()
    if player.Velocity:Length()<=2.0 and relative_motion then
        player.Friction=origin_Friction_P        
        relative_motion=false
    end
    if Ent_Ptr~=nil and Ent_Ptr.Ref~=nil and (rShootDown or rShootLeft or rShootRight or rShootUp ) then
        local dir=Ent_Ptr.Ref.Position-player.Position
        local acceleration=0
        local dis=Ent_Ptr.Ref.Position:Distance(player.Position)
        dir:Normalize()
        if dis>170 then
            acceleration=(dis-170)*0.1
        elseif dis<170 then
            acceleration=(dis-170)*0.1
        end
        Ent_Ptr.Ref.Velocity=Vector.Zero
        Ent_Ptr.Ref.Position=force_pos
        if acceleration~=0 then
            player.Velocity=player.Velocity+acceleration*dir
        end 
    end
    print(player.Velocity)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.judgePlayerAction)
function mod:relative_motion(Ent)
    if Ent==nil then
        return 
    end
    if Ent.Type==3 and Ent.Variant==240 and Ent.SubType==0 then
        local player=Isaac.GetPlayer()
        local motion_dir_fix=1
        if Game():GetRoom():IsMirrorWorld() then
            motion_dir_fix=-1
        end
        Ent.Velocity=Vector.Zero
        force_pos=player.Position
        relative_motion=true
        Ent_Ptr=EntityPtr(Ent)
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) then
            player.Velocity=Vector(player.Velocity.X,motion_V)
            origin_Friction_P=player.Friction
            player.Friction=3
            last_dir=Vector(0,-1)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) then
            player.Velocity=Vector(player.Velocity.X,-motion_V)
            origin_Friction_P=player.Friction
            player.Friction=3
            last_dir=Vector(0,1)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) then
            player.Velocity=Vector(motion_V*motion_dir_fix,player.Velocity.Y)
            origin_Friction_P=player.Friction
            player.Friction=3
            last_dir=Vector(- motion_dir_fix,0)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) then
            player.Velocity=Vector(-motion_V*motion_dir_fix,player.Velocity.Y)
            origin_Friction_P=player.Friction
            player.Friction=3
            last_dir=Vector(motion_dir_fix,0)
        else
            relative_motion=false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,mod.relative_motion)
function mod:resetForcePos()
    local player=Isaac.GetPlayer()
    local dir=last_dir
    if dir:Length()==0 then
        dir=Vector.One
    end
    dir:Normalize()
    force_pos=player.Position+170*dir
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,mod.resetForcePos)