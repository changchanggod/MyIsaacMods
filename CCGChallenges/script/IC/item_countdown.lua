local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="item countdown"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId,true)

local itemConfig=Isaac.GetItemConfig()
local invalidItem={[59]=true }
local frameInterval=300
local itemTotalNum=732
local function getNextItem(i,change)
    local nextItemId=i
    local config=nil
    repeat
        nextItemId=nextItemId+change
        if invalidItem[nextItemId] then
            nextItemId=nextItemId+change
        end
        config=itemConfig:GetCollectible(nextItemId)
        if nextItemId<=0 or nextItemId>itemTotalNum then
            break
        end
    until config~=nil
    return config,nextItemId
end
local function itemCountDown()
    if Game().Challenge==challengeId then
        if Game():GetFrameCount()% frameInterval==0 then
            local player=Isaac.GetPlayer()
            local change=Game():GetLevel():IsAscent() and 1 or -1
            for i=1,itemTotalNum do
                if player:HasCollectible(i,true) then
                    local config=itemConfig:GetCollectible(i)
                    local nextItemId=i
                    local isActive=config.Type==ItemType.ITEM_ACTIVE
                    local config2=nil
                    repeat
                        config2,nextItemId=getNextItem(nextItemId,change)
                        if config2 == nil then
                            break
                        end
                        if isActive == (config2.Type == ItemType.ITEM_ACTIVE) then
                            break
                        end
                    until nextItemId<=0 or nextItemId>itemTotalNum
                    while player:HasCollectible(i,true) do
                        player:RemoveCollectible(i,true)
                        if nextItemId>0 and nextItemId<=itemTotalNum then
                            player:AddCollectible(nextItemId,0,false)
                        end
                    end
                end
            end
        end
    end
    
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,itemCountDown)