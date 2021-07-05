local spawnedRamp
RegisterCommand("stunts:spawnCasino", function()
  RequestModel("stt_prop_ramp_jump_xl")
  while not HasModelLoaded("stt_prop_ramp_jump_xl") do
    Wait(0)
  end
  spawnedRamp = CreateObject(`stt_prop_ramp_jump_xl`, vector3(951.3,129.62,79.96), 1, 0, 1)
  SetEntityHeading(spawnedRamp, 140.96 + 100.0)
end, false)

RegisterCommand("stunts:deleteCasino", function()
  DeleteObject(spawnedRamp)
end, false)

RegisterCommand("stunts:spawnPrac", function()
  RequestModel("stt_prop_ramp_jump_xl")
  while not HasModelLoaded("stt_prop_ramp_jump_xl") do
    Wait(0)
  end
  spawnedRamp = CreateObject(`stt_prop_ramp_jump_xl`, vector3(-812.59,-3216.31,12.95), 1, 0, 1)
  SetEntityHeading(spawnedRamp, 258.21 + 90.0)
end, false)

RegisterCommand("stunts:deletePrac", function()
  DeleteObject(spawnedRamp)
end, false)
