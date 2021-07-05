AddEventHandler("np-casino:wheel:toggleEnable", function()
  local characterId = exports["isPed"]:isPed("cid")
  local jobAccess = RPC.execute("IsEmployedAtBusiness", { character = { id = characterId }, business = { id = "casino" } })
  if not jobAccess then
    TriggerEvent("DoLongHudText", "You cannot do that", 2)
    return
  end
  RPC.execute("np-casino:wheel:toggleEnabled")
end)

AddEventHandler("np-casino:wheel:spinWheel", function()
  if not hasMembership(false) then
    TriggerEvent("DoLongHudText", "You must have a membership", 2)
    return
  end
  -- local jobAccess = RPC.execute("IsEmployedAtBusiness", { character = { id = characterId }, business = { id = "casino" } })
  -- if jobAccess then
  --   TriggerEvent("DoLongHudText", "You cannot do that", 2)
  --   return
  -- end
  RPC.execute("np-casino:wheel:spinWheel")
end)
