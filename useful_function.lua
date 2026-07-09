local rLeft=false
local rRight=false
local rUp=false
local rDown=false
local rShootLeft=false
local rShootRight=false
local rShootUp=false
local rShootDown=false
function mod:getPlayerAction(_)
    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) then
        rLeft=true
    else
        rLeft=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) then
        rRight=true
    else 
        rRight=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_UP, 0) then
        rUp=true
    else 
        rUp=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0) then
        rDown=true
    else 
        rDown=false
    end
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
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.getPlayerAction)

------------------------------------------------------------------------------------------------------------

local RECOMMENDED_SHIFT_IDX = 35
local game = Game()
local seeds = game:GetSeeds()
local startSeed = seeds:GetStartSeed()
local myRNG = RNG()
myRNG:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
function mod:setMyRNG(isC)
    if isC then
        return
    end
    game = Game()
    seeds = game:GetSeeds()
    startSeed = seeds:GetStartSeed()
    myRNG:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.setMyRNG)

------------------------------------------------------------------------------------------------------------