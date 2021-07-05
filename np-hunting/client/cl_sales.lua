local carcasses = {
    { name = "huntingcarcass1", price = 60, illegal = false },
    { name = "huntingcarcass2", price = 350, illegal = false },
    { name = "huntingcarcass3", price = 1050, illegal = false },
    { name = "huntingcarcass4", price = 25, illegal = true },
}
local nightTime = false

local function sellAnimals()
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and veh ~= 0 then
      local vehModel = GetEntityModel(veh)
      if IsThisModelABike(vehModel) or IsThisModelAQuadbike(vehModel) or IsThisModelABicycle(vehModel) then
        DeleteEntity(veh)
      end
      return
    end
    local totalCash = 0
    local totalBMarketCash = 0

    for _, carcass in pairs(carcasses) do
        local qty = exports["np-inventory"]:getQuantity(carcass.name, true)

        if qty > 0 then
            if not carcass.illegal then
                totalCash = totalCash + (carcass.price * qty)
                TriggerEvent("inventory:removeItem", carcass.name, qty)
            elseif nightTime then
                totalBMarketCash = totalBMarketCash + (carcass.price * qty)
                TriggerEvent("inventory:removeItem", carcass.name, qty)
            end
        end
    end

    if totalCash == 0 and totalBMarketCash == 0 then
        TriggerEvent("DoLongHudText", "Nothing to sell, dummy.", 2)
    end
    
    if totalCash > 0 then
        RPC.execute("np-financials:giveJobPay", "hunting_sales", totalCash)
        TriggerEvent("DoLongHudText", "Added to bank!")
    end

    if totalBMarketCash > 0 then
        local payoutFactor = exports["np-config"]:GetModuleConfig("main").payoutFactor
        TriggerEvent("player:receiveItem", "band", math.floor(totalBMarketCash * payoutFactor))
    end
end

AddEventHandler("np-hunting:makeSales", sellAnimals)

RegisterNetEvent("timeheader")
AddEventHandler("timeheader", function(pHour, pMinutes)
    if pHour > 19 or pHour < 5 then
        nightTime = true
    else
        nightTime = false
    end
end)
