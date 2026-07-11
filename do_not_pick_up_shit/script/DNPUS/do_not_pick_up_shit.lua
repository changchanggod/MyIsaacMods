local mod= CCGChallenges45768

local function GetChallengeSafe(challengeName)
    local cId = Isaac.GetChallengeIdByName(challengeName)
    if cId == -1 then
        Isaac.ConsoleOutput(string.format("[CCG][Error]: Challenge \"%s\" load failed, missing challenge\n", challengeName))
        return nil
    end
    return cId
end

local challengeId=GetChallengeSafe()

local function spawnShit(num)
    for i = 1, 10, 1 do
        
    end
end