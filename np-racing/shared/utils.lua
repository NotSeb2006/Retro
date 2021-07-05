function isLocalVehicle(vin)
  return vin == nil or string.sub(vin or "", 1, 1) == "1"
end

function isRentalVehicle(vin)
  return vin ~= nil and string.sub(vin or "", 2, 3) == "RN"
end

function isLocalOrRentalVehicle(vin)
  return vin and (isLocalVehicle(vin) or isRentalVehicle(vin))
end
