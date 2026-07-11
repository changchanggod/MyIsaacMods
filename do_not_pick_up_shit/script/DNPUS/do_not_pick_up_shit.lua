local mod= CCGChallenges45768

local CHALLENGE_NAME = "don't pick up shit"
---@type number
local challengeId = Isaac.GetChallengeIdByName(CHALLENGE_NAME)

if challengeId == -1 then
    Isaac.ConsoleOutput(string.format("[CCG][Error]: Challenge \"%s\" load failed, missing challenge\n", CHALLENGE_NAME))
    return nil
end