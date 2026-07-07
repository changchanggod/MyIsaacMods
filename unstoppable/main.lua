local mod = RegisterMod("unstoppable", 1)
local rLeft = false
local rRight = false
local rUp = false
local rDown = false
local lastDir=-1
function mod:getPlayerAction(_)
    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) then
        rLeft = true
    else
        rLeft = false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) then
        rRight = true
    else
        rRight=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_UP, 0) then
        rUp = true
    else
        rUp=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0) then
        rDown = true
    else
        rDown=false
    end
end
function mod:JudgePlayerAction(Ent, InputH, ButtonA)
    if Ent == nil then
        return nil
    end
    if InputH == InputHook.GET_ACTION_VALUE then
        if ButtonA == ButtonAction.ACTION_LEFT then
            if not rLeft and not rRight and not rUp and not rDown then
                if lastDir>=3 and lastDir <=5 then
                    return 1.0
                end
                return 0
            elseif rLeft then
                if rUp then
                    lastDir=3
                elseif rDown then
                    lastDir=5
                else
                    lastDir=4
                end
                return 1.0
            else
                return 0
            end
        end
        if ButtonA == ButtonAction.ACTION_RIGHT then
            if not rLeft and not rRight and not rUp and not rDown then
                if lastDir==1 or lastDir==0 or lastDir==7 then
                    return 1.0
                end
                return 0
            elseif rRight then
                if rUp then
                    lastDir=1
                elseif rDown then
                    lastDir=7
                else
                    lastDir=0
                end
                return 1.0
            else
                return 0
            end
        end
        if ButtonA == ButtonAction.ACTION_UP then
            if not rLeft and not rRight and not rUp and not rDown then
                if lastDir>=1 and lastDir <=3 then
                    return 1.0
                end
                return 0
            elseif rUp then
                if rLeft then
                    lastDir=3
                elseif rRight then
                    lastDir=1
                else
                    lastDir=2
                end
                return 1.0
            else
                return 0
            end
        end
        if ButtonA == ButtonAction.ACTION_DOWN then
            if not rLeft and not rRight and not rUp and not rDown then
                if lastDir>=5 and lastDir <=7 then
                    return 1.0
                end
                return 0
            elseif rDown then
                if rLeft then
                    lastDir=5
                elseif rRight then
                    lastDir=7
                else
                    lastDir=6
                end
                return 1.0
            else
                return 0
            end
        end
    end
    return nil
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.getPlayerAction)
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.JudgePlayerAction)