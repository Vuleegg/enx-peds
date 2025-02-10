Points = {}
local textUI = false
local cache = {}

local function RemovePoints()
    for k, v in pairs(Points) do
        Points[k] = nil
    end
end

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        RemovePoints()
        for i = 1, #cache do 
            DeletePed(cache[i].peds)
        end
    end
end)

local function SetNuiFocusState(focus)
    SetNuiFocus(focus, focus)  
end

function GetOffsetFromCoordsAndHeading(coords, heading, offsetX, offsetY, offsetZ)
    local headingRad = math.rad(heading)
    local x = offsetX * math.cos(headingRad) - offsetY * math.sin(headingRad)
    local y = offsetX * math.sin(headingRad) + offsetY * math.cos(headingRad)
    local z = offsetZ

    local worldCoords = vector4(
        coords.x + x,
        coords.y + y,
        coords.z + z,
        heading
    )
    
    return worldCoords
end

function CamCreate(coords, hed)
	cam = CreateCam('DEFAULT_SCRIPTED_CAMERA')
	local coordsCam = GetOffsetFromCoordsAndHeading(coords, hed, 0.0, 0.6, 1.60)
	SetCamCoord(cam, coordsCam)
	PointCamAtCoord(cam, coords.x, coords.y, coords.z + 1.60)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 500, true, true)
end

function DestroyCamera()
    RenderScriptCams(false, true, 500, 1, 0)
    DestroyCam(cam, false)
end

local function nearby(point)
    if point.currentDistance < point.distance then
        if IsControlJustPressed(0, 38) then  
            local playerCoords = GetEntityCoords(point.entity)
            local heading = GetEntityHeading(point.entity)

            CamCreate(vec3(playerCoords.x, playerCoords.y, playerCoords.z - 1), heading)

            TaskLookAtEntity(cache.ped, point.entity, -1, 0, 2, 0)

            DisableTextUi()

            local validOptions = {}
            for _, option in ipairs(point.options) do
                local canInteract = true
                if option.canInteract then
                    canInteract = option.canInteract(point.entity)
                end

                if canInteract then
                    table.insert(validOptions, option)
                end
            end

            SendNUIMessage({
                action = "pedUIshow",
                name = point.name,
                label = point.label,
                description = point.description, 
                entity = point.entity,
                options = validOptions, 
            })

            SetNuiFocusState(true)
        end
    end
end

Create = function(index, data)
    if not data then return end 

    lib.requestModel(data.model)
    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z -1, data.heading, false, true)
    SetEntityAsMissionEntity(ped, true, true) 
    FreezeEntityPosition(ped, true)  
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    cache[#cache + 1] = {
        peds = ped
    }

    if data.animation then 
        TriggerEvent("enx-peds:client:animation", ped, data.animation)
    end

    data.entity = ped

    for i, option in ipairs(data.options) do
        option.id = string.format("option_%d_%d", index, i)  
        option.canInteractId = string.format("canInteract_%d_%d", index, i)

        Points[option.id] = option.onClick  
        Points[option.canInteractId] = option.canInteract 
    end

    Points[#Points + 1] = lib.points.new({
        index = index, 
        coords = data.coords,
        heading = data.heading,
        distance = data.distance,
        nearby = nearby,
        model = data.model, 
        name = data.name,
        label = data.label,
        description = data.description,
        options = data.options or {},
        entity = ped,  
    })
    
end

exports("Create", Create)

CreateThread(function()
    while true do
        local point = lib.points.getClosestPoint()

        if point then
            if point.currentDistance < 3.0 then
                if not textUI then
                    textUI = true
                    showTextUi(point.label)
                end
            else
                if textUI then
                    textUI = false
                    DisableTextUi()
                end
            end
        end

        Wait(300)
    end
end)

RegisterNUICallback("close", function(data)
    SetNuiFocusState(false)  
    DestroyCamera()
end)

RegisterNUICallback("action", function(data, cb)
    if not data then return end 
    local optionId = data.optionId
    local actionType = data.actionType
    local args = data.args

    if actionType == "serverEvent" then
        TriggerServerEvent(data.eventName, args)
    elseif actionType == "event" then
        TriggerEvent(data.eventName, args)
    elseif actionType == "onClick" then
        local func = Points[optionId]
        if func then
            func()
        else
            print(string.format("^1[Quantum Peds] Option ID %s not found.^0", optionId))
        end
    end

    if data.close then
        SetNuiFocusState(false)
        DestroyCamera()
    end

    cb({ success = true })
end)

AddEventHandler("enx-peds:client:animation", function(entity, data)
    if not entity then return end 
    if not data then return end 

    if data.clip and data.dict then
        lib.requestAnimDict(data.dict)
        TaskPlayAnim(entity, data.dict, data.clip, 8.0, -8.0, -1, 2, 0, false, false, false)
    end

    if data.scenario and not (data.clip or data.dict) then
        TaskStartScenarioInPlace(entity, data.scenario, 0, true)
    end
end)