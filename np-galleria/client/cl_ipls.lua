local iplStates = {}

local function updateIpls()
  local interiorid = GetInteriorAtCoords(-470.07,42.59,52.42)
  for k, v in pairs(iplStates) do
    if v then
      ActivateInteriorEntitySet(interiorid, k)
    else
      DeactivateInteriorEntitySet(interiorid, k)
    end
  end
  RefreshInterior(interiorid)
end

RegisterNetEvent("np-galleria:iplStatesUpdate")
AddEventHandler("np-galleria:iplStatesUpdate", function(pStates)
  iplStates = pStates
  updateIpls()
end)

Citizen.CreateThread(function()
  RPC.execute("np-galleria:getIplsStates")
end)
