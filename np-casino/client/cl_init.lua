local casinoInteriorId = nil

function IsTable(T)
  return type(T) == 'table'
end
function SetIplPropState(interiorId, props, state, refresh)
  if refresh == nil then refresh = false end
  if IsTable(interiorId) then
      for key, value in pairs(interiorId) do
          SetIplPropState(value, props, state, refresh)
      end
  else
      if IsTable(props) then
          for key, value in pairs(props) do
              SetIplPropState(interiorId, value, state, refresh)
          end
      else
          if state then
              if not IsInteriorPropEnabled(interiorId, props) then EnableInteriorProp(interiorId, props) end
          else
              if IsInteriorPropEnabled(interiorId, props) then DisableInteriorProp(interiorId, props) end
          end
      end
      if refresh == true then RefreshInterior(interiorId) end
  end
end

Citizen.CreateThread(function()
  Wait(10000)
  RequestIpl('vw_casino_main')
  RequestIpl('vw_dlc_casino_door')
  RequestIpl('hei_dlc_casino_door')
  RequestIpl("hei_dlc_windows_casino")
  RequestIpl("vw_casino_penthouse")
  SetIplPropState(274689, "Set_Pent_Tint_Shell", true, true)
  SetInteriorEntitySetColor(274689, "Set_Pent_Tint_Shell", 3)
  -- RequestIpl("vw_casino_carpark")
  -- RequestIpl("vw_casino_garage")
  -- RequestIpl("hei_dlc_windows_casino_lod")
  -- RequestIpl("hei_dlc_casino_aircon")
  -- RequestIpl("hei_dlc_casino_aircon_lod")
  -- RequestIpl("hei_dlc_casino_door")
  -- RequestIpl("hei_dlc_casino_door_lod")
  -- RequestIpl("hei_dlc_vw_roofdoors_locked")
  -- RequestIpl("vw_ch3_additions")
  -- RequestIpl("vw_ch3_additions_long_0")
  -- RequestIpl("vw_ch3_additions_strm_0")
  -- RequestIpl("vw_dlc_casino_door")
  -- RequestIpl("vw_dlc_casino_door_lod")
  -- RequestIpl("vw_casino_billboard")
  -- RequestIpl("vw_casino_billboard_lod(1)")
  -- RequestIpl("vw_casino_billboard_lod")
  -- RequestIpl("vw_int_placement_vw")
  -- RequestIpl("vw_dlc_casino_apart")
  local interiorId = GetInteriorAtCoords(1100.000, 220.000, -50.000)
  casinoInteriorId = interiorId

  if IsValidInterior(interiorId) then
    RefreshInterior(interiorId)
  end

  exports["np-polyzone"]:AddBoxZone("casino_entrance", vector3(934.66, 46.54, 81.11), 4.4, 6.2, {
    heading=10,
    minZ=80.1,
    maxZ=82.9,
    data = {
      id = "1",
    },
  })
  exports["np-polyzone"]:AddBoxZone("casino_exit", vector3(1089.83, 206.84, -49.0), 4, 4, {
    heading=0,
    minZ=-50.2,
    maxZ=-47.2,
    data = {
      id = "1",
    },
  })
  exports["np-polyzone"]:AddBoxZone("casino_post_gate", vector3(1122.36, 240.28, -50.44), 10.8, 5.0, {
    heading=42,
    minZ=-51.44,
    maxZ=-49.04,
    data = {
      id = "1",
    },
  })
  exports["np-polyzone"]:AddBoxZone("casino_betting_screen", vector3(1100.96, 256.81, -51.24), 20, 25.6, {
    heading=306,
    minZ=-52.04,
    maxZ=-48.04,
    data = {
      id = "1",
    },
  })
end)

local interiorSetNames = {
  ["bets"] = "casino_rm_betting_standard",
  ["poker"] = "casino_rm_betting_poker",
}
RegisterNetEvent("np-casino:entitySetSwap")
AddEventHandler("np-casino:entitySetSwap", function(set)
  for _, v in pairs(interiorSetNames) do
    DeactivateInteriorEntitySet(casinoInteriorId, v)
  end
  ActivateInteriorEntitySet(casinoInteriorId, interiorSetNames[set])
  RefreshInterior(casinoInteriorId)
end)

AddEventHandler("np-casino:enterPenthouse", function()
  TriggerEvent("np-casino:elevatorExitCasino")
  local interiorId = GetInteriorAtCoords(968.58,46.92,116.17)
  ActivateInteriorEntitySet(interiorId, "set_pent_creampie")
  RefreshInterior(interiorId)
end)
