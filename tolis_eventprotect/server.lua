local tlCfg = {
    frameWork = "ESX", --or QBCORE
    getSharedObject = "esx:getSharedObject",
    hook = "",

    jobLockedEvents = {
        {eventName = "esx_policejob:handcuff", authorizedJobs = {"police","sheriff"}},
        {eventName = "esx_alljobs:addjob", authorizedJobs = {"police","admin"}},
    }
}

local function logToDiscord(source,eventName,currentJob)
    local source,eventName,currentJob = source,eventName,currentJob
    local embedContent = {
        ["color"] = 3447003,
        ["type"] = "rich",
        ['description'] = "",
        ["fields"] = {
            {
                ["name"] = "**A Player Tried To Trigger A Locked Event:**",
                ["value"] = "```"..
                    "Player Name: ".. GetPlayerName(source) .."\n"..
                    "Server ID: ".. tostring(source) .."\n"..
                    "\n"..
                    "Event Name: ".. eventName.."\n"..
                    "Player Job: ".. currentJob.."\n"..
                    "\n"..
                    "Date: ".. os.date("%A, %d %B %Y - %X") .."\n"
                .."```",
                ["inline"] = false,
            }
        },
    }

    PerformHttpRequest(tlCfg.hook,
        function(err, text, headers)end,
        "POST",
        json.encode({embeds = {embedContent}}),
        {["Content-Type"] = "application/json"}
    )

end

CreateThread(function()

    if tlCfg.frameWork == "ESX" then
        while ESX == nil do
            TriggerEvent(tlCfg.getSharedObject, function(obj)
                ESX = obj
            end)
            Wait(10)
        end
        tlCfg.getJobName = function(source)
            return ESX.GetPlayerFromId(source).job.name
        end
    elseif tlCfg.frameWork == "QBCORE" then
        QBCore = exports['qb-core']:GetCoreObject()
        if QBCore == nil then
            while QBCore == nil do
                TriggerEvent(tlCfg.getSharedObject, function(obj)
                    QBCore = obj
                end)
                Wait(10)
            end
        end
        tlCfg.getJobName = function(source)
            return QBCore.Functions.GetPlayer(source).PlayerData.job.name
        end
    end

    for i = 1, #tlCfg.jobLockedEvents do

        AddEventHandler(tlCfg.jobLockedEvents[i].eventName, function()

            local source = source
            local playerJob = tlCfg.getJobName(source)

            for _,job in pairs(tlCfg.jobLockedEvents[i].authorizedJobs) do
                if playerJob == job then
                    return
                end
            end

            logToDiscord(source,tlCfg.jobLockedEvents[i].eventName,playerJob)

        end)
    end
end)
