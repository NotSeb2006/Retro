local vehicleList = {
  { name = "Boat Trailer", model = "boattrailer", price = 500 },

  { name = "Bison", model = "bison", price = 500 },

  { name = "Futo", model = "Futo", price = 600 },
  { name = "Buccaneer", model = "buccaneer", price = 625 },
  -- { name = "Sultan", model = "sultan", price = 700 },
  -- { name = "Buffalo S", model = "buffalo2", price = 725 },
  
  { name = "Coach", model = "coach", price = 800 },
  { name = "Shuttle Bus", model = "rentalbus", price = 800 },
  { name = "Tour Bus", model = "tourbus", price = 800 },
  { name = "Taco Truck", model = "nptaco", price = 800 },
  { name = "Limo", model = "stretch", price = 1500 },
  { name = "Hearse", model = "romero", price = 1500 },
  { name = "Clown Car", model = "speedo2", price = 5000 },
  { name = "Festival Bus", model = "pbus2", price = 10000 },
}

local function showVehicleMenu()
  local data = {}
  for _, vehicle in pairs(vehicleList) do
    data[#data + 1] = {
      title = vehicle.name,
      description = "$" .. vehicle.price .. ".00",
      -- image = vehicle.image,
      key = vehicle.model,
      children = {
          { title = "Confirm Purchase", action = "np-ui:rentalPurchase", key = vehicle.model },
      },
    }
  end
  exports["np-ui"]:showContextMenu(data)
end

RegisterUICallback("np-ui:rentalPurchase", function(data, cb)
  if IsAnyVehicleNearPoint(117.84, -1079.95, 29.23, 3.0) then
    TriggerEvent("DoLongHudText", "Vehicle in the way.", 2)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    return
  end
  local d = nil
  for _, v in pairs(vehicleList) do
    if d == nil and v.model == data.key then
      d = v
    end
  end
  d.character = data.character
  local success, message = RPC.execute("rentals:purchaseVehicle", d)
  if not success then
      cb({ data = {}, meta = { ok = success, message = message } })
      return
  end
  local model = data.key
  -- DoScreenFadeOut(200)

  local rentalInfo = RPC.execute("np:vehicles:rentalSpawn", model, { x = 117.84, y = -1079.95, z = 29.23 }, 355.92)

  local timeout = 10
  while not NetworkDoesEntityExistWithNetworkId(rentalInfo.netId) and timeout > 0 do
      timeout = timeout - 1
      Wait(1000)
  end
  
  local veh = NetworkGetEntityFromNetworkId(rentalInfo.netId)

  if not DoesEntityExist(veh) then 
    TriggerEvent("DoLongHudText", "Could not find rental vehicle.")
    cb({ data = {}, meta = { ok = true, message = "done" } })
    return 
  end
  
  local plateText = GetVehicleNumberPlateText(veh)
  
  local metaData = json.encode({
    Plate = plateText,
    netId = rentalInfo.netId,
    _hideKeys = {'netId'},
  })
  TriggerEvent('player:receiveItem', 'rentalpapers', 1, false, {}, metaData)

  -- RequestModel(model)
  -- while not HasModelLoaded(model) do
  --     Citizen.Wait(0)
  -- end
  -- SetModelAsNoLongerNeeded(model)

  -- local veh = CreateVehicle(model, vector4(117.84,-1079.95,29.23,355.92), true, false)

  -- Citizen.Wait(100)

  -- SetEntityAsMissionEntity(veh, true, true)
  -- SetModelAsNoLongerNeeded(model)
  -- SetVehicleOnGroundProperly(veh)

  -- TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

  -- DoScreenFadeIn(2000)

  cb({ data = {}, meta = { ok = true, message = "done" } })
end)

RegisterNetEvent("np-npcs:ped:vehiclekeeper")
AddEventHandler("np-npcs:ped:vehiclekeeper", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
  if GetHashKey("npc_veh_rental") == DecorGetInt(pEntity, "NPC_ID") then
    showVehicleMenu()
  end
end)

AddEventHandler("np-inventory:itemUsed", function(item, info)
  if item == "rentalpapers" then
      data = json.decode(info)
      local ent = NetworkGetEntityFromNetworkId(data.netId)

      local vin = exports["np-vehicles"]:GetVehicleIdentifier(ent)
      local isRental = vin ~= nil and string.sub(vin, 2, 3) == "RN"
      if isRental then
        RPC.execute("rentals:getVehicleKey", vin)
        TriggerEvent("DoLongHudText", "You received keys to the rental.")
      else
        TriggerEvent("DoLongHudText", "That rental does not exist.")
      end
  end
end)
