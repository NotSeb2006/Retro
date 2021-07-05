Housing.currentOwned = {}
Housing.currentKeys = {}
Housing.currentlyEditing = false
Housing.currentHousingInteractions = nil
Housing.currentlyInsideBuilding = false

Housing.currentHousingLocks = {}
Housing.currentHousingLockdown = {}
Housing.currentAccess = nil

Housing.hasEditedOrigin = false


function Housing.func.findClosestProperty()

    local playerCoords = GetEntityCoords(PlayerPedId())
    
    local zone = GetZoneAtCoords(playerCoords)
    local zoneName = GetNameOfZone(playerCoords)


    if Housing.zone[zoneName] == nil then return false,"No zone found",nil end
    local closest = nil
    local closestDist = 9999

    for k,v in pairs(Housing.zone[zoneName].locations) do
        local distance = #(playerCoords - v)
        if distance <= closestDist then
            closestDist = distance
            closest = k
        end
    end
    return true,closest,closestDist,zoneName
end

function Housing.func.calculatePropertyPrice(propertyId,zone)

    local basePrice = Housing.zoningPrices[zone].baseSellPrice
    local housingType = Housing.info[propertyId].model

    local percent = Housing.typeInfo[housingType].percentage

    if Housing.zoningPrices[zone][housingType] ~= nil then
        percent = percent + Housing.zoningPrices[zone][housingType]
    end
    
    return basePrice + ((basePrice*percent)/100)
end



function Housing.func.getPropertyIdFromName(propertyName)
    local housingID = 0
    for i=1,#Housing.info do
        if propertyName == Housing.info[i].Street then
            housingID = i
            break;
        end
    end
    return housingID
end

function Housing.func.getPropertyZoneFromID(propertyID)
    local zoneName = GetNameOfZone(Housing.info[propertyID][1])
    return zoneName
end


function Housing.func.enterBuilding(propertyID,enterOverride,counterPart)
    Housing.currentlyInsideBuilding = true
    DoScreenFadeOut(1)

    TriggerEvent("inhotel",true)

    local finished,housingInformation,currentHousingLocks,isResult,housingLockdown,housingRobbed,robTargets,robLocations,alarm,currentAccess = RPC.execute("getCurrentSelected",propertyID)

    if type(housingLockdown) == "table" then
        Housing.currentHousingLockdown = housingLockdown
    end
    
    if type(currentHousingLocks) == "table" then
        Housing.currentHousingLocks = currentHousingLocks
    end
    

    if type(housingRobbed) == "table" then
        Housing.housingBeingRobbedClient = housingRobbed
    end


    if type(robTargets) == "table" then
        Housing.housingRobTargets = robTargets
    end

    if type(robLocations) == "table" then
        Housing.robPosLocations = robLocations
    end
        
    if type(housingInformation) == "table" then
        Housing.currentHousingInteractions = housingInformation
        Housing.currentHousingInteractions.id = propertyID
    end

    if type(currentAccess) == "table" then
        Housing.currentAccess = currentAccess
    end

    


    if counterPart then
        Housing.alarm = alarm

        local finished,destroyedTable = RPC.execute("getDestroyedTable",propertyID)
        if type(destroyedTable) == "table" then
            Housing.destroyedObjects = destroyedTable
        end
    end

    

    local model = Housing.info[propertyID].model
    local oldModel = nil
    if counterPart then
        local info = Housing.typeInfo[model]
        if info.robberyCounterpart == nil then return end
        oldModel = model
        model = info.robberyCounterpart
    end

    local spawnBuildingLocation = vector3(Housing.info[propertyID][1].x,Housing.info[propertyID][1].y,Housing.info[propertyID][1].z-60.0)
    if not counterPart then
        if Housing.currentHousingInteractions ~= nil and Housing.currentHousingInteractions.origin_offset ~= vector3(0.0,0.0,0.0) and type(Housing.currentHousingInteractions.origin_offset) == "vector3" then
            local off = Housing.currentHousingInteractions.origin_offset
            spawnBuildingLocation =  vector3(Housing.info[propertyID][1].x+off.x,Housing.info[propertyID][1].y+off.y,Housing.info[propertyID][1].z-60.0)
        end
    end
    local isBuiltCoords,objects = exports["np-build"]:getModule("func").buildRoom(model,spawnBuildingLocation,false,Housing.destroyedObjects,enterOverride,true)
    if counterPart and Housing.staticObjectRobPoints == nil then
        Housing.staticObjectRobPoints = exports["np-build"]:getModule("func").getRobLocationsForObjects(model,spawnBuildingLocation,Housing.housingRobTargets.static)
        buildRobLocations(model,propertyID)
    end

    if isBuiltCoords then

        --DoScreenFadeIn(100)
        SetEntityInvincible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(),false)

        TriggerEvent('InteractSound_CL:PlayOnOne','DoorClose', 0.7)
        DoScreenFadeIn(500)
        Housing.currentlyInsideBuilding = true
        if counterPart then 
            model = oldModel
        end
        Housing.func.loadInteractions(model,counterPart,counterPart)

        if not counterPart then
            TriggerEvent("np-editor:buildName" ,"housing-"..propertyID,objects)
        end

    else
        Housing.currentHousingInteractions = nil
        Housing.currentlyInsideBuilding = false
        Housing.currentAccess = nil
    end
end

RegisterNetEvent("housing:playerSpawned")
AddEventHandler("housing:playerSpawned", function(housingName)
    local propertyID = Housing.func.getPropertyIdFromName(housingName)
    if propertyID == 0 then return end

    Housing.currentHousingLockdown = RPC.execute("getCurrentLockdown")
    if not Housing.currentHousingLockdown[propertyID] then
        Housing.func.enterBuilding(propertyID)
    end

    local cid = exports["isPed"]:isPed("cid")
    
    TriggerEvent("np-spawn:characterSpawned", cid)
end)


function defaultStart()
    ClearPedTasks(PlayerPedId())
    DoScreenFadeIn(100)
    Wait(3000)
    gatherPlayerInfo()
end

function gatherPlayerInfo()
    Housing.currentOwned = RPC.execute("getCurrentOwned")
    Housing.currentKeys = RPC.execute("currentKeys")
    Housing.currentHousingLockdown = RPC.execute("getCurrentLockdown")
    updateBuisnessLocations(RPC.execute("getBuisnessLocations"))
end


function updateBuisnessLocations(data)
    local assigned = {}

    for i=1,#Housing.info do
        if Housing.info[i].assigned then
            assigned[Housing.info[i].assigned] = i
        end
    end

    for k,v in pairs(data) do
        local c = v.coords
        Housing.info[assigned[v.buisness]][1] = vector4(c.x,c.y,c.z,0.0)
    end
end

RegisterNetEvent("housing:informPlayerToRenewServerInfo")
AddEventHandler("housing:informPlayerToRenewServerInfo", function(locks)
    
    if locks then
        local currentHousingLocks = RPC.execute("getCurrentLocks")
        if type(currentHousingLocks) == "table" then
            Housing.currentHousingLocks = currentHousingLocks
        end
        return
    end
    gatherPlayerInfo()
    if Housing.currentlyInsideBuilding and Housing.currentHousingInteractions ~= nil then
        Housing.func.loadInteractions(Housing.info[Housing.currentHousingInteractions.id].model)
    end
end)

RegisterNetEvent("character:finishedLoadingChar")
AddEventHandler("character:finishedLoadingChar", function()
    gatherPlayerInfo()
end)

function isNearHousingClothing()

    if Housing.currentlyInsideBuilding and Housing.currentHousingInteractions ~= nil then
        if Housing.currentOwned[Housing.currentHousingInteractions.id] == nil and Housing.currentKeys[Housing.currentHousingInteractions.id] == nil then return false end
        if Housing.currentHousingInteractions.charChanger_offset == nil then return false end
        if Housing.currentHousingInteractions.charChanger_offset == vector3(0.0,0.0,0.0) then return false end
        
        local playerCoords = GetEntityCoords(PlayerPedId())

        local buildingVector = exports["np-build"]:getModule("func").currentBuildingVector()
        local vector = (Housing.currentHousingInteractions.charChanger_offset + buildingVector)

        local distance = #(playerCoords - vector)
        if distance < 2.0 then
            return true
        end
    end

    return false
end


function setInventory()

    if Housing.currentlyEditing == false then return false,"Not in edit mode" end
    if Housing.currentOwned[Housing.currentlyEditing] == nil then return false, "you do not own this property" end

    if Housing.currentlyInsideBuilding then
        

        local buildingVector = exports["np-build"]:getModule("func").currentBuildingVector()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vector = (playerCoords - buildingVector)
        if not canPlaceInteractionPoint("inventory_offset",vector) then return false,"Invalid placement" end
        Housing.currentHousingInteractions.inventory_offset = vector
        Housing.currentHousingInteractions.crafting_offset = vector3(0.0,0.0,0.0)
        Housing.func.loadInteractions(Housing.info[Housing.currentHousingInteractions.id].model)
        RPC.execute("property:hasSwapped",Housing.currentHousingInteractions.id)
        local finished = RPC.execute("updateCurrentSelected",Housing.currentlyEditing,Housing.currentHousingInteractions,Housing.hasEditedOrigin)
        return true,"Moved Inventory"
    else
        return false,"not inside house"
    end

end

function placeBench(dropInventory)


    local buildingVector = exports["np-build"]:getModule("func").currentBuildingVector()
    local isPublic = exports["np-config"]:IsPublic()
    if dropInventory and not isPublic then
        local invVector = Housing.currentHousingInteractions.inventory_offset
        if invVector == nil then return false, "No vector found" end


        local vector = (buildingVector + invVector)

        local propertyID = Housing.currentHousingInteractions.id
        local cat = getHousingCatFromPropertID(propertyID)

        local vec = {x=vector.x,y=vector.y,z=vector.z}

        RPC.execute("property:dropInventory",vec,cat.."-"..propertyID ,propertyID)
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local objFound = GetClosestObjectOfType(playerCoords, 10.0, `gr_prop_gr_bench_02b`, 0, 0, 0)

    if objFound and objFound ~= 0 then
        if Housing.currentlyInsideBuilding then


            local objectCoords = GetEntityCoords(objFound)
            objectCoords = vector3(objectCoords.x,objectCoords.y,playerCoords.z)

            local vector = (objectCoords - buildingVector)

            if not canPlaceInteractionPoint("crafting_offset",vector) then return false,"Invalid placement" end

            Housing.currentHousingInteractions.crafting_offset = vector
            if not isPublic then
                Housing.currentHousingInteractions.inventory_offset = vector3(0.0,0.0,0.0)
            end
            Housing.func.loadInteractions(Housing.info[Housing.currentHousingInteractions.id].model)
            RPC.execute("property:hasSwapped",Housing.currentHousingInteractions.id)
            local finished = RPC.execute("updateCurrentSelected",Housing.currentlyEditing,Housing.currentHousingInteractions,Housing.hasEditedOrigin)
            return true,"Moved Crafting"
        else
            return false,"not inside house"
        end
    else
        return false,"Crafting Table not found"
    end


end

function buildFurnitureData(propertyID)

    local zoneData = Housing.typeInfo[Housing.info[propertyID].model].zone
    local off = zoneData.offset
    local center = vector3(Housing.info[propertyID][1].x+off.x,Housing.info[propertyID][1].y+off.y,Housing.info[propertyID][1].z+off.z-60.0)
    local isPublic = exports["np-config"]:IsPublic()

    if not isPublic then
        local progressionData = exports["np-progression"]:GetProgression("crafting:guns")
        local hasProgression = progressionData ~= nil and progressionData > 0
    end

    local specials = {}
    if hasProgression or isPublic then specials[#specials+1] = "gr_prop_gr_bench_02b" end

    local data = {
        name = "housing-"..propertyID,
        special = specials,
        autosave = true,
        zone = {
            pos = center,
            length = zoneData.length,
            width = zoneData.width,
            minZ = zoneData.minZ,
            maxZ = zoneData.maxZ,
            heading = zoneData.heading
        },
        modules = {
            "objects",
        },
    }

    TriggerServerEvent("CheckFurniture",data,propertyID)
end

RegisterNetEvent('housing:crafting')
AddEventHandler('housing:crafting', function()
    local propertyID = Housing.currentHousingInteractions.id
    if Housing.currentOwned[propertyID] == nil then  TriggerEvent("DoLongHudText","Only the owner can use this.",2) return end

    local isPublic = exports["np-config"]:IsPublic()
    if isPublic then
        TriggerEvent("server-inventory-open", "42079", "Craft");
        return
    end

    local progressionData = exports["np-progression"]:GetProgression("crafting:guns")
    if progressionData == nil or progressionData < 1 then return false, "you do not have the knowledge for this" end 

    local index = 1

    if progressionData >= 1 and progressionData <= 2000 then index = 1 end
    if progressionData >= 2001 and progressionData <= 7500 then index = 2 end
    if progressionData >= 7501 and progressionData <= 14000 then index = 3 end
    if progressionData >= 14001 then index = 4 end

    local craftingIndex = {
        [1] = "38",
        [2] = "39",
        [3] = "40",
        [4] = "41",
    }

    TriggerEvent("server-inventory-open", craftingIndex[index], "Craft-"..index);
end)

RegisterNetEvent('hotel:outfit')
AddEventHandler('hotel:outfit', function(args,sentType)

    if isNearHousingClothing() then
		if sentType == 1 then
			local id = args[2]
			table.remove(args, 1)
			table.remove(args, 1)
			strng = ""
			for i = 1, #args do
				strng = strng .. " " .. args[i]
			end
			TriggerEvent("raid_clothes:outfits", sentType, id, strng)
		elseif sentType == 2 then
			local id = args[2]
			TriggerEvent("raid_clothes:outfits", sentType, id)
		elseif sentType == 3 then
			local id = args[2]
			TriggerEvent('item:deleteClothesDna')
			TriggerEvent('InteractSound_CL:PlayOnOne','Clothes1', 0.6)
			TriggerEvent("raid_clothes:outfits", sentType, id)
		else
			TriggerServerEvent("raid_clothes:list_outfits")
		end
	end
end)

RegisterNetEvent('housing:toggleClosestLock')
AddEventHandler('housing:toggleClosestLock', function()
    local isComplete, propertyID, dist, zone = Housing.func.findClosestProperty()

    if isComplete and dist <= 3.0 then 
        if Housing.currentOwned[propertyID] == nil and Housing.currentHousingLocks[propertyID] == nil then 
            return
        end

        if Housing.currentHousingLocks[propertyID] == false then
            lock(Housing.info[propertyID].Street)
        else
            unlock(Housing.info[propertyID].Street)
        end
    end
    return
end)
