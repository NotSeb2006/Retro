local isRacing = false
local usedItemId, usedItemSlot, usedItemMetadata

local function openAliasTextbox()
  exports['np-ui']:openApplication('textbox', {
    callbackUrl = 'np-ui:racing:input:alias',
    key = 1,
    items = {{icon = "pencil-alt", label = "Alias", name = "alias"}},
    show = true
  })
end

AddEventHandler("np-inventory:itemUsed", function(item, metadata, inventoryName, slot)
  if item ~= "racingusb2" then return end
  usedItemId = item
  usedItemSlot = slot
  usedItemMetadata = json.decode(metadata)

  local characterId = exports["isPed"]:isPed("cid")
  if characterId ~= usedItemMetadata.characterId then
    TriggerEvent("DoLongHudText", "You don't own this usb!", 2)
    return
  end

  if usedItemMetadata.Alias then
    TriggerEvent("DoLongHudText", "Alias can't be changed for this usb!", 2)
    return
  end

  openAliasTextbox()
end)

RegisterUICallback("np-ui:racing:input:alias", function(data, cb)
  cb({data = {}, meta = {ok = true, message = ''}})
  exports['np-ui']:closeApplication('textbox')
  local alias = data.values.alias

  if usedItemMetadata.Alias then return end

  if not alias then
    TriggerEvent("DoLongHudText", "No alias entered!", 2)
    return
  end

  local success, msg = RPC.execute("np-racing:setAlias", usedItemId, usedItemSlot, usedItemMetadata, alias)
  if success then
    exports["np-ui"]:sendAppEvent("phone", {
      action = "racing-alias-set",
      title = "From the PM",
      text = "Welcome to the underground, " .. alias .. ".",
    })
  else
    TriggerEvent("DoLongHudText", msg or "Alias could not be set.", 2)
    if msg == "Alias already taken!" then
      openAliasTextbox()
    end
  end
end)

AddEventHandler("mkr_racing:api:raceStarted", function(race)
  if race.shouldSendRecklessDrivingCall then
    local cid = exports["isPed"]:isPed("cid")
    if cid == race.owner then AlertReckless() end
  end
end)

RegisterNetEvent("np-racing:kickedFromRace")
AddEventHandler("np-racing:kickedFromRace", function(errorMessage)
  TriggerEvent("DoLongHudText", "Kicked from race: " .. errorMessage, 2)
end)

AddEventHandler("mkr_racing:api:currentRace", function(currentRace)
  isRacing = currentRace ~= nil
  if isRacing then
    exports["mkr-racing"]:resetHudPosition()
  end
end)

AddEventHandler("phone:hasNotificationChanged", function(lastHasNotification, hasNotification, topOfPhone)
  if not isRacing then return end

  if hasNotification then
    exports["mkr-racing"]:setHudPosition({
      top = nil,
      bottom = tostring(topOfPhone + 25) .. "px",
      left = nil,
      right = '25px'
    })
  else
    exports["mkr-racing"]:resetHudPosition()
  end
end)
