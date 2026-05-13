--Create Frame for events
local frame = CreateFrame("Frame")

--Variable to track xp, enemy name, and addon state
local lastXP = 0
local lastKillXP = 0
local lastEnemyName =nil
local addonEnabled = true 

--Handle Chat Commands
SLASH_KILLCOUNT1 ="/kc" --Creates the /kc command hopefully
SlashCmdList["KILLCOUNT"] = function(msg)
    if msg == "on" then
        addonEnabled = true
        print("KillCountDown Enabled")
    elseif msg == "off" then
            addonEnabled =false
            print("KillCountDown Disabled.")
    else
            print("USEAGE: /kc on- Enables KillCountDown, /kc off - Disable KillCountDown")
    end
end

-- Event Handling
local function OnEvent(self, event, ...)
    if not addonEnabled then return end --exit if addon is disabled

    if event == "PLAYER_LOGIN" then
        local playerName = UnitName("player") --Gets player name
        local currentXP = UnitXP("player") --Gets current xp
        local maxXP = UnitXPMax("player") -- gets max xp from current level
        lastXP = currentXP -- initializing lastXP from login

        --Calculate XP remaining
        local xpRemaining = maxXP - currentXP

        --Print the greeting and XP info
        print("Welcome back," .. playerName .. "! You currently have " .. currentXP .. "/" .. maxXP .. "XP.")
        print("You need " .. xpRemaining .. " more XP to level up!")
        print("KillCountDown by Siethex Version: 1.0")
    elseif event == "PLAYER_XP_UPDATE" then
        local currentXP = UnitXP("player") --Get current XP
        local maxXP = UnitXPMax("player") -- Get max XP for the current level

        --Calculate the XP gained since the last update
        local xpGained = currentXP - lastXP
        lastXP = currentXP --Update lastXP for the next calculation

        --some redundant math to ensure we process only positive xp gain..
        if xpGained > 0 then
            lastKillXP =xpGained --Save the XP gained for the last kill
            local xpRemaining = maxXP - currentXP

            --Calculate the number of kills required to level up
            local killsNeeded = math.ceil(xpRemaining / lastKillXP)

            --Print XP gained, enemy name, and kills needed
            if lastEnemyName then
                print("You killed " .. lastEnemyName .. "and gained " .. xpGained .. "XP!")
                else
                    print("You gained " .. xpGained .. "XP!")
            end
            print("Remaining XP to level: " ..xpRemaining)
            print("You need to kill approximately " .. killsNeeded.. "more enemies to level up.")
        end
    elseif  event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        --Track the enemy name you killed
        if subevent == "UNIT_DIED" then
            lastEnemyName = destName -- Save the name of the last killed enemy
        end
    end
end

--Register Events
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", OnEvent)