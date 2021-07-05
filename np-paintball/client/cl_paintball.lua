local inArena = false

local function isNpa()
  local cid = exports["isPed"]:isPed("cid")
  local isEmployedAtNpa = RPC.execute("IsEmployedAtBusiness", { character = { id = cid }, business = { id = "npa"} })
  if not isEmployedAtNpa then
    TriggerEvent("DoLongHudText", "They don't recognize you", 2)
  end
  return isEmployedAtNpa
end

local function removeGuns()
  local qty = exports["np-inventory"]:getQuantity("-2009644972")
  if qty and qty > 0 then
    TriggerEvent("inventory:removeItem", "-2009644972", qty)
  end
  if GetSelectedPedWeapon(PlayerPedId()) == -2009644972 then
    SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
  end
end

AddEventHandler("np-paintball:getPaintballGun", function()
  if not isNpa() then return end
  TriggerEvent("player:receiveItem", "-2009644972", 1)
end)

AddEventHandler("np-paintball:getPaintballAmmo", function()
  if not isNpa() then return end
  TriggerEvent("player:receiveItem", "paintballs", 20)
end)

AddEventHandler("np-polyzone:enter", function(zone)
  if zone ~= "paintball_arena" then return end
  inArena = true
end)
AddEventHandler("np-polyzone:exit", function(zone)
  if zone ~= "paintball_arena" then return end
  inArena = false
  removeGuns()
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(60000)
    if not inArena then
      removeGuns()
    end
  end
end)
