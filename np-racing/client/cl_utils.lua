function getCardinalDirectionFromHeading()
  local heading = GetEntityHeading(PlayerPedId())
  if heading >= 315 or heading < 45 then
      return "North Bound"
  elseif heading >= 45 and heading < 135 then
      return "West Bound"
  elseif heading >=135 and heading < 225 then
      return "South Bound"
  elseif heading >= 225 and heading < 315 then
      return "East Bound"
  end
end

function AlertReckless()
  local ped = PlayerPedId()
  local plyPos = GetEntityCoords(ped)
  local zone = GetLabelText(GetNameOfZone(plyPos))
  local dir = getCardinalDirectionFromHeading()

  local s1, s2 = GetStreetNameAtCoord(plyPos.x, plyPos.y, plyPos.z)
  local firstStreet = GetStreetNameFromHashKey(s1) .. ", " .. zone
  local secondStreet = GetStreetNameFromHashKey(s2) .. " " .. dir
  if s2 == 0 then
    secondStreet = " " .. dir
  end

  TriggerServerEvent("dispatch:svNotify", { dispatchCode = "10-94", firstStreet = firstStreet, secondStreet = secondStreet } )
end
