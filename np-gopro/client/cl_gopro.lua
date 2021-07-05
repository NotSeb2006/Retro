local activeDashcams = {}
local currentVehicleNetId = 0
local clonedPedNetId = 0
local currentCoords = nil
local currentDashcam = nil
local goProActivated = false
local staticCam = nil
local goProCameraItems = {
  ["dashcamracing"] = { name = "dashcamracing", type = "racing" },
  ["dashcampd"] = { name = "dashcampd", type = "pd" },
}

RegisterUICallback("np-ui:goProRegisterCar", function(data, cb)
  cb({ data = {}, meta = { ok = true, message = "done" } })
  exports['np-ui']:closeApplication('textbox')
  local name = data.values.name or ""
  if string.len(name) < 3 then
    TriggerEvent("DoLongHudText", "Name too short.", 2)
    return
  end
  RPC.execute("np-gopro:registerCarForFootage", currentVehicleNetId, name, currentDashcam)
  TriggerEvent("inventory:removeItem", currentDashcam.name, 1)
  TriggerEvent("np-menu:dashCamAttached", currentVehicleNetId, true)
  currentVehicleNetId = 0
  currentDashcam = nil
end)

AddEventHandler("np-gopro:removeDashCam", function()
  local veh = GetVehiclePedIsIn(PlayerPedId())
  local netId = NetworkGetNetworkIdFromEntity(veh)
  local foundDashCam
  for _, v in pairs(activeDashcams) do
    if v.netId == netId then
      foundDashCam = v
    end
  end
  if not foundDashCam then
    TriggerEvent("DoLongHudText", "Dashcam not found.", 2)
    return
  end
  RPC.execute("np-gopro:removeCarForFootage", netId)
  TriggerEvent("np-menu:dashCamAttached", netId, false)
  TriggerEvent("player:receiveItem", "dashcam" .. foundDashCam.type, 1)
end)

AddEventHandler("np-inventory:itemUsed", function(item)
  if not goProCameraItems[item] then return end
  local veh = GetVehiclePedIsIn(PlayerPedId())
  if not veh or veh == 0 then return end
  currentVehicleNetId = NetworkGetNetworkIdFromEntity(veh)
  currentDashcam = goProCameraItems[item]
  exports['np-ui']:openApplication('textbox', {
    callbackUrl = 'np-ui:goProRegisterCar',
    key = 1,
    items = {
      {
        icon = "pencil-alt",
        label = "Dashcam Stream Name",
        name = "name",
      },
    },
    show = true,
  })
end)

local myPreChairCoords = nil
local myDuringChairCoords = nil
AddEventHandler("np-gopro:activateVRChair", function(pArgs, pEntity, pContext)
  -- pContext.model, pContext.flags (isGoProVRChair)
  DoScreenFadeOut(1000)
  Wait(800)
  exports["np-ui"]:sendAppEvent("hud", { display = false })
  local selectedType = (pArgs and pArgs.type) and pArgs.type or "racing"
  exports["np-ui"]:openApplication("gopros", { selectedType = selectedType, switchingViews = true })
  Wait(200)
  TriggerEvent("np-casino:inVRHeadset", true)
  local entCoords = GetEntityCoords(pEntity)
  local heading = GetEntityHeading(pEntity)

  local offsetCoords = GetOffsetFromEntityInWorldCoords(pEntity, 0.0, 0.0, 0.5)

  local clonedPed = ClonePed(PlayerPedId(), heading, 1, 1)
  clonedPedNetId = NetworkGetNetworkIdFromEntity(clonedPed)
  while clonedPed == 0 or clonedPedNetId == 0 do
    Wait(0)
  end
  SetEntityInvincible(clonedPed, true)
  SetEntityCollision(clonedPed, false, false)
  TaskSetBlockingOfNonTemporaryEvents(clonedPed, true)
  ClearPedTasksImmediately(clonedPed)
  TaskStartScenarioAtPosition(
    clonedPed,
    "PROP_HUMAN_SEAT_ARMCHAIR",
    offsetCoords,
    GetEntityHeading(pEntity) - 180.0,
    0,
    true,
    true
  )

  myPreChairCoords = GetEntityCoords(PlayerPedId())
  FreezeEntityPosition(PlayerPedId(), true)
  SetEntityCollision(PlayerPedId(), false, false)
  myDuringChairCoords = vector3(myPreChairCoords.x, myPreChairCoords.y, myPreChairCoords.z - 20.0)
  SetEntityCoords(PlayerPedId(), myDuringChairCoords)
  DoScreenFadeIn(0)
end)

RegisterNetEvent("np-gopros:updateRegisteredCams")
AddEventHandler("np-gopros:updateRegisteredCams", function(pDashcams)
  activeDashcams = pDashcams
  exports["np-ui"]:sendAppEvent("gopros", { dashcams = activeDashcams })
end)
AddEventHandler("playerSpawned", function()
  Wait(5550)
  RPC.execute("np-gopros:playerSpawnedSendCams")
end)

RegisterUICallback("np-ui:goproChangeSelectedPov", function(data, cb)
  cb({ data = {}, meta = { ok = true, message = 'done' }})
  local activateGoPro = activateGoPro(tonumber(data.netId))
  Wait(600)
  exports["np-ui"]:sendAppEvent("gopros", { switchingViews = false })
end)

AddEventHandler("np-ui:application-closed", function(name)
  if name ~= "gopros" then return end
  DoScreenFadeOut(400)
  Wait(400)
  TriggerEvent("np-casino:inVRHeadset", false)
  deactivateGoPro()
  SetEntityCoords(PlayerPedId(), myDuringChairCoords)
  local clonedPed = 0
  while clonedPed == 0 do
    clonedPed = NetworkGetEntityFromNetworkId(clonedPedNetId)
    Wait(100)
  end
  Sync.DeleteEntity(clonedPed)
  FreezeEntityPosition(PlayerPedId(), false)
  SetEntityCollision(PlayerPedId(), true, true)
  SetEntityCoords(PlayerPedId(), myPreChairCoords)
  exports["np-ui"]:sendAppEvent("hud", { display = true })
  DoScreenFadeIn(1000)
end)

function prepareCameraSelf(activating, coords)
  local me = PlayerPedId()
  DetachEntity(me, 1, 1)
  SetEntityCollision(me, not activating, not activating)
  SetEntityInvincible(me, activating)
  -- SetEntityAlpha(me, activating and 0 or 255, 0)
  if activating then
    NetworkFadeOutEntity(me, activating, false)
  else
    NetworkFadeInEntity(me, 0, false)
  end
  SetEntityCoords(me, coords)
end

function activateGoPro(netId)
  local alreadyActive = goProActivated
  goProActivated = true
  local coords = RPC.execute("np-gopro:getRegisteredDashcamData", netId)
  coords = vector3(coords.x, coords.y, coords.z - 10.0)
  if not alreadyActive then
    staticCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    currentCoords = GetEntityCoords(PlayerPedId())
  end
  Wait(0)
  prepareCameraSelf(true, coords)
  local veh = 0
  local vehLoopCount = 0
  while veh == 0 and vehLoopCount < 10 do
    veh = NetworkGetEntityFromNetworkId(netId)
    vehLoopCount = vehLoopCount + 1
    if veh == 0 then Wait(250) end
  end
  if veh == 0 then
    prepareCameraSelf(false, currentCoords)
    TriggerEvent("DoLongHudText", "Vehicle not found", 2)
    return false
  end
  AttachEntityToEntity(PlayerPedId(), veh, 0, 0.0, 0.0, -40.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0)
  local vehModel = GetEntityModel(veh)
  local camX, camY, camZ = 0.35, -0.5, 0.6
  if RHD_VEHICLES[vehModel] then
    camX = -0.35
  end
  SetCamFov(staticCam, 60.0)
  DetachCam(staticCam)
  Wait(0)
  AttachCamToVehicleBone(
    staticCam,
    veh,
    GetEntityBoneIndexByName(veh, "seat_dside_f"),
    1, 0.0, 0.0, 0.0, camX, camY, camZ, 1)
  if not alreadyActive then
    RenderScriptCams(true, false, 0, 1, 0)
  end
  return true
end

function deactivateGoPro()
  if not goProActivated then return end
  goProActivated = false
  prepareCameraSelf(false, currentCoords)
  RenderScriptCams(false, false, 0, 1, 0)
end

-- RegisterCommand("activategopro", function(src, args)
--   local netId = tonumber(args[1])
--   print(netId, src, json.encode(args))
--   activateGoPro(netId)
-- end, false)
-- RegisterCommand("deactivategopro", function()
--   deactivateGoPro()
-- end)
