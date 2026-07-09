local mod = CCGChallenges45768
---@type number
local challengeId = Isaac.GetChallengeIdByName("turn the tables")
if challengeId == -1 then
    Isaac.ConsoleOutput('[Error]:challenge "turn the tables" load failed')
    return nil
end

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
local function getPlayerAction(_,_)
    if Game().Challenge==challengeId then
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
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, getPlayerAction)
local function judgePlayerAction(_,Ent)
    if Game().Challenge==challengeId then
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
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, judgePlayerAction)
local function relative_motionF(_,Ent)
    if Ent==nil then
        return 
    end
    if Game().Challenge==challengeId then
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
    
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,relative_motionF)
local function resetForcePos(_)
    if Game().Challenge==challengeId then
        local player=Isaac.GetPlayer()
        local dir=last_dir
        if dir:Length()==0 then
            dir=Vector.One
        end
        dir:Normalize()
        force_pos=player.Position+170*dir
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,resetForcePos)