local isStageActive = false
local isPerforming = false
local isInTavern = false
local isSignedOn = false
--local hasTeaBuffActive = false
-- local nightTime = false

-- local numTavernPatrons = 0

local activePurchases = {}
local serverCode = "wl"

Citizen.CreateThread(function()
    serverCode = exports["np-config"]:GetServerCode()
    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_ingredients', {{
        event = "np-roostersrest:openIngredientStorage",
        id = "roosters_rest_ingredients",
        icon = "box-open",
        label = "open"
    }}, { distance = { radius = 3.5 } })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_counter_drinks', {{
        event = "np-roostersrest:openDrinkCrafting",
        id = "roosters_rest_drink_crafting",
        icon = "wine-bottle",
        label = "make drinks"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_takeout', {{
        event = "np-roostersrest:getTakeout",
        id = "roosters_rest_takeout",
        icon = "shopping-bag",
        label = "get container"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_takeout', {{
        event = "np-roostersrest:getCockBox",
        id = "roosters_rest_cockbox",
        icon = "box-open",
        label = "get cock box"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_cooking', {{
        event = "np-roostersrest:openCooking",
        id = "roosters_rest_cooking",
        icon = "temperature-high",
        label = "make food"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_stage', {{
        event = "np-roostersrest:stageSignOn",
        id = "roosters_rest_stage_signon",
        icon = "circle",
        label = "start performing"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return not isStageActive end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:tavern_stage', {{
        event = "np-roostersrest:stageSignOff",
        id = "roosters_rest_stage_signoff",
        icon = "circle",
        label = "stop performing"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isPerforming end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:register_pay', {{
        event = "np-roostersrest:registerPurchasePrompt",
        id = "roosters_rest_register_customer_1",
        icon = "cash-register",
        label = "make payment",
        parameters = {registerId = 1}
    }}, { distance = { radius = 3.5 } })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:register_charge', {{
        event = "np-roostersrest:registerChargePrompt",
        id = "roosters_rest_register_worker_1",
        icon = "credit-card",
        label = "charge customer",
        parameters = {registerId = 1}
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:register_2', {{
        event = "np-roostersrest:registerPurchasePrompt",
        id = "roosters_rest_register_customer_2",
        icon = "cash-register",
        label = "make payment",
        parameters = {registerId = 1}
    }}, { distance = { radius = 3.5 } })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:register_2', {{
        event = "np-roostersrest:registerChargePrompt",
        id = "roosters_rest_register_worker_2",
        icon = "credit-card",
        label = "charge customer",
        parameters = {registerId = 1}
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:signOn', {{
        event = "np-roostersrest:signOnPrompt",
        id = "rooster_sign_on",
        icon = "clock",
        label = "Clock In"
    }}, { distance = { radius = 3.5 }  , isEnabled = function(pEntity, pContext) return not isSignedOn end })

    exports['np-interact']:AddPeekEntryByPolyTarget('np-roostersrest:signOn', {{
        event = "np-roostersrest:signOffPrompt",
        id = "rooster_sign_off",
        icon = "clock",
        label = "Clock Out"
    }}, { distance = { radius = 3.5 }, isEnabled = function(pEntity, pContext) return isSignedOn end })
end)

AddEventHandler('np-roostersrest:openDrinkCrafting', function(pParameters, pEntity, pContext)
    -- if not nightTime then
    --     TriggerEvent("DoLongHudText", "You can only cook at night.")
    --     return
    -- end
    TriggerEvent("server-inventory-open", "31", "Craft")
end)

AddEventHandler('np-roostersrest:openCooking', function(pParameters, pEntity, pContext)
    -- if not nightTime then 
    --     TriggerEvent("DoLongHudText", "You can only cook at night.")
    --     return
    -- end
    local finished = exports["np-taskbar"]:taskBar(5000, "Preparing Food")
    if finished == 100 then
        pos = GetEntityCoords(PlayerPedId(), false)
        if(Vdist(-173.1, 291.99, 99.2, pos.x, pos.y, pos.z) < 2.0) then
            TriggerEvent("server-inventory-open", "42071", "Craft")
            Wait(1000)
        end
    end
end)

AddEventHandler('np-roostersrest:openIngredientStorage', function(pParameters, pEntity, pContext)
    TriggerEvent("server-inventory-open", "1", "RR_Tavern_Storage-" .. serverCode)
end)

AddEventHandler('np-roostersrest:registerPurchasePrompt', function(pParameters, pEntity, pContext)
    local activeRegisterId = pParameters.registerId
    local activeRegister = activePurchases[activeRegisterId]
    if not activeRegister or activeRegister == nil then
        TriggerEvent("DoLongHudText", "No purchase active.")
        return
    end
    local priceWithTax = RPC.execute("PriceWithTaxString", activeRegister.cost, "Goods")
    local acceptContext = {{
        title = "Accept Purchase",
        description = "$" .. priceWithTax.text .. " | " .. activeRegister.comment,
        action = "np-roostersrest:finishPurchasePrompt",
        key = {cost = activeRegister.cost, comment = activeRegister.comment, registerId = pParameters.registerId, charger = activeRegister.charger},
        disabled = false
    }}
    exports['np-ui']:showContextMenu(acceptContext)
end)

AddEventHandler('np-roostersrest:registerChargePrompt', function(pParameters, pEntity, pContext)
    exports['np-ui']:openApplication('textbox', {
        callbackUrl = 'np-ui:roostersrest:charge',
        key = pParameters.registerId,
        items = {
          {
            icon = "dollar-sign",
            label = "Cost",
            name = "cost",
          },
          {
            icon = "pencil-alt",
            label = "Comment",
            name = "comment",
          },
        },
        show = true,
    })
end)

AddEventHandler('np-roostersrest:stageSignOn', function(pParameters, pEntity, pContext)
    -- if not nightTime then
    --     TriggerEvent("DoLongHudText", "You can only perform at night.")
    --     return
    -- end
    if not isStageActive then
        local success = RPC.execute("np-roostersrest:startPerforming")
        if success then
            isPerforming = true
            TriggerEvent("DoLongHudText", "Performance started... break a leg!")
        elseif success ~= nil then
            TriggerEvent("DoLongHudText", "A performer is already active.")
        end
    end
end)

AddEventHandler('np-roostersrest:getTakeout', function(pParameters, pEntity, pContext)
    local genId = tostring(math.random(1000, 99999999))
    local invId = "container-" .. genId .. "-roosters rest takeout"
    local metaData = json.encode({
        inventoryId = invId,
        slots = 4,
        weight = 4,
        _hideKeys = {'inventoryId', 'slots', 'weight'},
    })
    TriggerEvent('player:receiveItem', 'roostertakeout', 1, false, {}, metaData)
end)

AddEventHandler('np-roostersrest:getCockBox', function(pParameters, pEntity, pContext)
    RPC.execute("np-roostersrest:getCockBox")
end)

RegisterNetEvent('np-roostersrest:stageSignOff')
AddEventHandler('np-roostersrest:stageSignOff', function(pParameters, pEntity, pContext)
    local success = RPC.execute("np-roostersrest:stopPerforming")
    if success then
        isPerforming = false
        TriggerEvent("DoLongHudText", "Thank you for performing.")
    else
        TriggerEvent("DoLongHudText", "You're not currently performing.")
    end
end)

--Add to purchases at registerId pos
RegisterNetEvent('np-roostersrest:activePurchase')
AddEventHandler("np-roostersrest:activePurchase", function(data)
    activePurchases[data.registerId] = data
end)

--Remove at registerId pos
RegisterNetEvent('np-roostersrest:closePurchase')
AddEventHandler("np-roostersrest:closePurchase", function(data)
    activePurchases[data.registerId] = nil
end)

-- RegisterNetEvent('np-roostersrest:updatePatrons')
-- AddEventHandler("np-roostersrest:updatePatrons", function(data)
--     numTavernPatrons = data
-- end)

RegisterNetEvent('np-roostersrest:startPerformance')
AddEventHandler("np-roostersrest:startPerformance", function()
    isStageActive = true
end)

RegisterNetEvent('np-roostersrest:stopPerformance')
AddEventHandler("np-roostersrest:stopPerformance", function()
    isStageActive = false
end)

RegisterNetEvent('np-roostersrest:checkTime')
AddEventHandler("np-roostersrest:checkTime", function(forceLeave)
    -- if not nightTime then
    --     TriggerEvent("DoLongHudText", "Cocked out for the day.")
    --     RPC.execute("np-roostersrest:leaveJob")
    --     isSignedOn = false
    --     return
    -- end
    if forceLeave then
        TriggerEvent("DoLongHudText", "You went too far away. Cocked out from Roosters")
        RPC.execute("np-roostersrest:leaveJob")
        isSignedOn = false
    end
end)

-- RegisterNetEvent("timeheader")
-- AddEventHandler("timeheader", function(pHour, pMinutes)
--     if pHour > 18 or pHour < 6 then
--         nightTime = true
--     else
--         nightTime = false
--     end
-- end)

RegisterUICallback('np-roostersrest:finishPurchasePrompt', function (data, cb)
    cb({ data = {}, meta = { ok = true, message = '' } })
    local success = RPC.execute("np-roostersrest:completePurchase", data.key)
    if not success then
        TriggerEvent("DoLongHudText", "The purchase could not be completed.")
    end
end)

RegisterUICallback("np-ui:roostersrest:charge", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = '' } })
    exports['np-ui']:closeApplication('textbox')
    local cost = tonumber(data.values.cost)
    local comment = data.values.comment
    --check if cost is actually a number
    if cost == nil or not cost then return end
    if comment == nil then comment = "" end

    if cost < 5 then cost = 5 end --Minimum $5

    --Send event to everyone indicating a purchase is ready at specified register
    RPC.execute("np-roostersrest:startPurchase", {cost = cost, comment = comment, registerId = data.key})
end)

AddEventHandler('np-roostersrest:signOnPrompt', function(pParameters, pEntity, pContext)
    isSignedOn = RPC.execute("np-roostersrest:tryJoinJob")
    if isSignedOn then
        TriggerEvent("DoLongHudText", "Cocked in")
    else
        TriggerEvent("DoLongHudText", "You can't take this job right now!")
    end
end)

AddEventHandler('np-roostersrest:signOffPrompt', function(pParameters, pEntity, pContext)
    TriggerEvent("DoLongHudText", "Cocked out.")
    isSignedOn = false
    RPC.execute("np-roostersrest:leaveJob")
end)

AddEventHandler("np-inventory:itemUsed", function(item, info)
    if item == "roostertakeout" or item == "cockbox" then
        data = json.decode(info)
        TriggerEvent("inventory-open-container", data.inventoryId, data.slots, data.weight)
    end
    if item == "cockegg" then
        local finished = exports["np-taskbar"]:taskBar(1000, "Opening")
        if finished == 100 then
            TriggerServerEvent('loot:useItem', item)
            TriggerEvent("inventory:removeItem", item, 1)
        end
    end
end)

RegisterNetEvent("np-roostersrest:drinkTea")
AddEventHandler("np-roostersrest:drinkTea", function()
    local success = RPC.execute("np-roostersrest:giveBonus")
    if success then
        TriggerEvent("DoLongHudText", "You feel healthy, productive and charismatic.")
    else
        TriggerEvent("DoLongHudText", "You already feel productive. Try again later.")
    end
end)

AddEventHandler("np-polyzone:enter", function(zone, data)
    if zone == "np-roostersrest:tavern_near" then
        RPC.execute("np-roostersrest:enterTavern")
        isInTavern = true
    end
    if zone == "np-roostersrest:tavern_stage" then
      TriggerEvent('np:voice:proximity:override', 'roostersrest-stage', 3, 15.0, 3)
    end
end)

AddEventHandler("np-polyzone:exit", function(zone)
    if zone == "np-roostersrest:tavern_near" then
        RPC.execute("np-roostersrest:leaveTavern")
        isInTavern = false
    end

    if zone == "np-roostersrest:tavern_main" and isPerforming then
        TriggerEvent("np-roostersrest:stageSignOff")
    end

    if zone == "np-roostersrest:tavern_stage" then
      TriggerEvent('np:voice:proximity:override', 'roostersrest-stage', 3, -1, -1)
    end
end)
