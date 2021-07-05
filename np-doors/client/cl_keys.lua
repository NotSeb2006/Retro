AddEventHandler("np-inventory:itemUsed", function(item, info)
  if item ~= "methlabkey" then return end
  if not info then return end
  RPC.execute("np-doors:useDoorKey", NetworkGetNetworkIdFromEntity(PlayerPedId()), info)
end)