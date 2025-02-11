if not lib.checkDependency('stevo_lib', '1.7.4') then
    error('stevo_lib version 1.7.4 is required for stevo_communityservice to work!')
    return
end

local stevo_lib = exports['stevo_lib']:import()
local config = require('config')
local isSentenced = false
local actions = 0 
local currentArea = nil 
local showText = false
local taskActive = false
local taskPoint = false
local taskFinished = false 
local escaped = false 
local progress = lib.progressBar
lib.locale()

local function showSentencingMenu()
    local sentenceMenu = lib.inputDialog("Sentence Player", {
        { type = 'number', label = locale('input.playerIdTitle'), description = locale('input.playerId'), required = true, min = 1, max = 5 },
        { type = 'number', label = locale('input.actionsTitle'), description = locale("input.actions"), required = true, min = 1, max = 15 },
    })

    if not sentenceMenu then 
        return 
    end 

    local localId = GetPlayerServerId(PlayerId())
    local playerId = sentenceMenu[1]
    local sentence = sentenceMenu[2]

    if playerId == localId then
        stevo_lib.Notify(locale("notify.jailYourself"), 'warning', 3000)
        return
    end

    TriggerServerEvent('stevo_communityservice:sentencePlayer', playerId, sentence)
end 

local function createTask(taskName, taskLocation, taskAnimation, taskScenario, taskProp, taskDuration)
    taskActive = true
    taskFinished = false 

    taskPoint = lib.points.new({ 
        coords = vec3(taskLocation.x, taskLocation.y, taskLocation.z + 0.5), 
        distance = 25, 
        nearby = function(point)
            currentArea = point 
            local color = config.interaction.markerColor
            DrawMarker(21, point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, color.r, color.g, color.b, color.a, false, true, 2, true, false, false, false)

            if point.isClosest and point.currentDistance <= 1.5 then
                if not showText then
                    showText = true
                    lib.showTextUI(locale('textUI.startTask'), { position = config.interaction.textUI.position })
                end
                if IsControlJustPressed(0, 38) and not taskFinished then  
                    lib.hideTextUI()

                    if taskAnimation then 
                        lib.requestAnimDict(taskAnimation.dict)
                        TaskPlayAnim(cache.ped, taskAnimation.dict, taskAnimation.clip, 1.0, 1.0, taskDuration, 50, 1.0, false, false, false) 
                    elseif taskScenario then 
                        TaskStartScenarioAtPosition(cache.ped, taskScenario, taskLocation.x, taskLocation.y, taskLocation.z, GetEntityHeading(cache.ped), 0, false, false)
                    end 

                    if taskProp and taskProp.model then 
                        lib.requestModel(taskProp.model)
                        if progress({ 
                            duration = taskDuration, 
                            label = taskName,
                            useWhileDead = false,
                            canCancel = false,
                            disable = { car = true },
                            prop = {
                                model = GetHashKey(taskProp.model),
                                pos = vec3(0.03, 0.03, 0.02),
                                rot = vec3(0.0, 0.0, -1.5)
                            },
                        }) then 
                            ClearPedTasksImmediately(cache.ped)
                            taskFinished = true 
                            taskPoint:remove()
                        end
                    else 
                        if progress({ 
                            duration = taskDuration, 
                            label = taskName,
                            useWhileDead = false,
                            canCancel = false,
                            disable = { car = true }
                        }) then 
                            ClearPedTasksImmediately(cache.ped)
                            taskFinished = true 
                            taskPoint:remove()
                        end
                    end 
                end
            elseif showText then
                showText = false
                lib.hideTextUI()
            end
        end, 
        onExit = function()
            lib.hideTextUI()
            ClearPedTasks(cache.ped)
            taskPoint:remove() 
        end
    })

    return true
end

local function assignTasks()
    if actions < 0 then 
        return 
    end 

    local taskCount = #config.tasks
    LocalPlayer.state:set('stevo_comserv', actions, true)

    CreateThread(function()
        local tasksCompleted = 0
        while actions > 0 do 
            tasksCompleted = tasksCompleted + 1
            local taskIndex = (tasksCompleted - 1) % taskCount + 1
            local task = config.tasks[taskIndex]
            local taskName = task.name
            local taskLocation = task.coords
            local taskAnimation = task.animation
            local taskScenario = task.scenario
            local taskProp = task.prop
            local taskDuration = task.duration or 7000

            currentArea = { coords = vec3(taskLocation.x, taskLocation.y, taskLocation.z + 0.5) }

            createTask(taskName, taskLocation, taskAnimation, taskScenario, taskProp, taskDuration)
            
            while not taskFinished do 
                Wait(500) 
            end
            
            actions = actions - 1 
            LocalPlayer.state:set('stevo_comserv', actions, true)
        
            if actions > 0 then 
                stevo_lib.Notify(locale("notify.finishedTask", actions), "warning", 3000)
            else 
                stevo_lib.Notify(locale("notify.finished"), "success", 3000)
                isSentenced = false 
                TriggerServerEvent('stevo_communityservice:finishedService')

                if config.teleportBack then 
                    SetEntityCoords(cache.ped, config.returnLocation.x, config.returnLocation.y, config.returnLocation.z, true, false, false, false)
                end

                if config.switchOutfit then 
                    stevo_lib.SetOutfit(false)
                end
            end 
        end 
    end)
end

local function assignTasks()
    if actions < 0 then 
        return 
    end 

    local taskCount = #config.tasks
    LocalPlayer.state:set('stevo_comserv', actions, true)

    CreateThread(function()
        local tasksCompleted = 0
        while actions > 0 do 
            tasksCompleted = tasksCompleted + 1
            local taskIndex = (tasksCompleted - 1) % taskCount + 1
            local task = config.tasks[taskIndex]
            local taskName = task.name
            local taskLocation = task.coords
            local taskAnimation = task.animation
            local taskScenario = task.scenario
            local taskProp = task.prop
            local taskDuration = task.duration

            currentArea = { coords = vec3(taskLocation.x, taskLocation.y, taskLocation.z + 0.5) }

            createTask(taskName, taskLocation, taskAnimation, taskScenario, taskProp, taskDuration)

            -- Wait until task is finished
            while not taskFinished do 
                Wait(500)  -- Wait while the task is active
            end
            
            actions = actions - 1 
            LocalPlayer.state:set('stevo_comserv', actions, true)
        
            if actions > 0 then 
                stevo_lib.Notify(locale("notify.finishedTask", actions), "warning", 3000)
            else 
                stevo_lib.Notify(locale("notify.finished"), "success", 3000)
                isSentenced = false 
                TriggerServerEvent('stevo_communityservice:finishedService')

                if config.teleportBack then 
                    SetEntityCoords(cache.ped, config.returnLocation.x, config.returnLocation.y, config.returnLocation.z, true, false, false, false)
                end

                if config.switchOutfit then 
                    stevo_lib.SetOutfit(false)
                end
            end 
        end 
    end)
end


local function teleportToCommunityService()
    SetEntityCoords(cache.ped, config.coords.x, config.coords.y, config.coords.z, true, false, false, false)

    if config.switchOutfit then 
        local sex = stevo_lib.GetSex()
        local outfit = config.Uniforms[sex]
        stevo_lib.SetOutfit(outfit)
    end

    assignTasks()
end

local function loadCommunityService()
    local fetchedActions = lib.callback.await('stevo_communityservice:fetchSentence')

    if fetchedActions then 
        teleportToCommunityService()

        stevo_lib.Notify(locale('notify.sentenced', fetchedActions), 'warning', 3000)
        isSentenced = true 
        actions = tonumber(fetchedActions)
        LocalPlayer.state:set('stevo_comserv', actions, true)
    
        CreateThread(function()
            while isSentenced do
                Wait(2000)
    
                if currentArea and actions > 0 then
                    local pedCoords = GetEntityCoords(cache.ped)
                    local distance = #(pedCoords - currentArea.coords)
    
                    if distance > 50 then 
                        SetEntityCoords(cache.ped, currentArea.coords.x, currentArea.coords.y, currentArea.coords.z, true, false, false, false)
                        stevo_lib.Notify(locale("notify.sentBack"), 'error', 3000)
                        actions = actions + 1
                        LocalPlayer.state:set('stevo_comserv', actions, true)
                    end 
                end
            end
        end)
    end
end

RegisterCommand(locale('commands.sentence'), function(source, args)
    local job = stevo_lib.GetPlayerGroups()

    if job ~= config.policeJob then 
        stevo_lib.Notify(locale("notify.notPolice"), 'error', 3000) 
        return 
    end

    showSentencingMenu()
end)

RegisterNetEvent('stevo_communityservice:sentencePlayer')
AddEventHandler('stevo_communityservice:sentencePlayer', function(sentence)
    if isSentenced then 
        return 
    end

    teleportToCommunityService()
    stevo_lib.Notify('You have been sent to community service', 'warning', 3000)
    stevo_lib.Notify(locale('notify.sentenced', sentence), 'warning', 3000)
    
    isSentenced = true 
    actions = sentence 
    LocalPlayer.state:set('stevo_comserv', actions, true)

    CreateThread(function()
        while isSentenced do
            Wait(2000)

            if currentArea and actions > 0 then
                local pedCoords = GetEntityCoords(cache.ped)
                local distance = #(pedCoords - currentArea.coords)

                if distance > 50 then 
                    SetEntityCoords(cache.ped, currentArea.coords.x, currentArea.coords.y, currentArea.coords.z, true, false, false, false)
                    stevo_lib.Notify(locale("notify.sentBack"), 'error', 3000)
                end 
            end
        end
    end)
end)

RegisterNetEvent('stevo_communityservice:notifyPlayer')
AddEventHandler('stevo_communityservice:notifyPlayer', function(message, type)
    stevo_lib.Notify(message, type)
end)

AddEventHandler('stevo_lib:playerLoaded', function()
    loadCommunityService()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then 
        return 
    end
    loadCommunityService()
end)
