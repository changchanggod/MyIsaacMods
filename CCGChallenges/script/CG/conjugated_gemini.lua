local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeId = utils.GetChallengeSafe("conjugated gemini")
if challengeId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId,false)

local rLeft = false
local rRight = false
local rUp = false
local rDown = false
local rShootLeft = false
local rShootRight = false
local rShootUp = false
local rShootDown = false
local function getPlayerAction(_,_)
    if Game().Challenge == challengeId then
        if Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) then
            rShootLeft = true
        else
            rShootLeft = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) then
            rShootRight = true
        else
            rShootRight = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_UP, 0) then
            rShootUp = true
        else
            rShootUp = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0) then
            rShootDown = true
        else
            rShootDown = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) then
            rLeft = true
        else
            rLeft = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) then
            rRight = true
        else
            rRight = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) then
            rUp = true
        else
            rUp = false
        end
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) then
            rDown = true
        else
            rDown = false
        end
    end
end

local function JudgePlayerAction(_,Ent, InputH, ButtonA)
    if Ent == nil then
        return nil
    end
    if Game().Challenge == challengeId then
        if Ent:ToPlayer():GetPlayerType() == PlayerType.PLAYER_ESAU then
            if InputH == InputHook.IS_ACTION_PRESSED then
                if ButtonA == ButtonAction.ACTION_SHOOTLEFT then
                    if rShootLeft then
                        return true
                    else
                        return false
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTRIGHT then
                    if rShootRight then
                        return true
                    else
                        return false
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTUP then
                    if rShootUp then
                        return true
                    else
                        return false
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTDOWN then
                    if rShootDown then
                        return true
                    else
                        return false
                    end
                end
            elseif InputH == InputHook.GET_ACTION_VALUE then
                if ButtonA == ButtonAction.ACTION_LEFT then
                    if rLeft then
                        return 1.0
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_RIGHT then
                    if rRight then
                        return 1.0
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_UP then
                    if rUp then
                        return 1.0
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_DOWN then
                    if rDown then
                        return 1.0
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTLEFT then
                    if rShootLeft then
                        return 1
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTRIGHT then
                    if rShootRight then
                        return 1
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTUP then
                    if rShootUp then
                        return 1
                    else
                        return 0
                    end
                end
                if ButtonA == ButtonAction.ACTION_SHOOTDOWN then
                    if rShootDown then
                        return 1
                    else
                        return 0
                    end
                end
            end
        end
        return nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER,getPlayerAction)
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, JudgePlayerAction)

--l local room=Game():GetRoom() room:TrySpawnSecretExit(true)
--l local room=Game():GetRoom() print(room:IsCurrentRoomLastBoss ())
--l Game():Spawn(5,20,Vector(350,280),Vector.Zero,1,123)