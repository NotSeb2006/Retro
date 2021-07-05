local jobs = {
  ["police"] = true,
  ["doctor"] = true,
  ["district attorney"] = true,
  ["judge"] = true,
  ["defender"] = true,
}
function hasMdwAccess()
  local cj = exports["police"]:getCurrentJob()
  return jobs[cj] == true
end

function LoadAnimationDic(dict)
  if not HasAnimDictLoaded(dict) then
      RequestAnimDict(dict)

      while not HasAnimDictLoaded(dict) do
          Citizen.Wait(0)
      end
  end
end

local function playAnimation()
  LoadAnimationDic("amb@code_human_in_bus_passenger_idles@female@tablet@base")
  TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
  TriggerEvent("attachItemPhone", "tablet01")
end

RegisterUICallback("np-ui:mdtAction", function(data, cb)
  local result = RPC.execute("np-ui:mdtApiRequest", data)
  cb({ data = result.message, meta = { ok = result.success, message = result.message } })
end)

RegisterUICallback("np-mdt:getVehiclesByCharacterId", function(data, cb)
  local data = RPC.execute("np:vehicles:getPlayerVehiclesByCharacterId", data.character.id, true)
  cb({ data = data, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-mdt:getPlayerOnlineStatus", function(data, cb)
  local data = RPC.execute("np-mdt:isPlayerOnline", data.character.id, true)
  cb({ data = data, meta = { ok = true, message = 'done' } })
end)

AddEventHandler("np-ui:openMDW", function(data)
  if not hasMdwAccess() and not data.fromCmd and not data.publicApp then return end
  playAnimation()
  exports["np-ui"]:openApplication("mdt", { publicApp = data.publicApp or false })
end)

AddEventHandler("np-ui:application-closed", function(name)
  if name ~= "mdt" then return end
  StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0)
  TriggerEvent("destroyPropPhone")
  SetPlayerControl(PlayerId(), 1, 0)
end)

RegisterUICallback("np-ui:getHousingInformation", function(data, cb)
  local result = RPC.execute("housing:search", nil, data.profile.id)
  cb({ data = result or {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-mdt:getUnitInformation", function (data, cb)
  local result = RPC.execute("np-dispatch:getDispatchUnits")
  cb({ data = result, meta = { ok = true, message = 'done' } })
end)

-- Citizen.CreateThread(function()
--   -- SetPedCanHeadIk(PlayerPedId(), false)
--   while true do
--     SetPedCanHeadIk(PlayerPedId(), false)
--     Citizen.Wait(0)
--   end
-- end)

-- Citizen.CreateThread(function()
--   local ped = PlayerPedId()
--   local interior = GetInteriorFromEntity(ped)
--   print(interior)
--   local roomHash = GetRoomKeyFromEntity(ped)
--   print(roomHash)
--   ForceRoomForEntity(ped, 139265, 913797866)
--   ForceRoomForGameViewport(139265, 913797866)
-- end)

-- Citizen.CreateThread(function()
--   while true do
--     local ped = PlayerPedId()
--     local interior = GetInteriorFromEntity(ped)
--     print(interior)
--     local roomHash = GetRoomKeyFromEntity(ped)
--     print(roomHash)
--     -- ForceRoomForEntity(ped, 139265, 913797866)
--     -- ForceRoomForGameViewport(139265, 913797866)
--     Citizen.Wait(5000)
--   end
-- end)

-- RegisterCommand("tint", function(_, args)
--   local ped = PlayerPedId()
--   local _, curweap = GetCurrentPedWeapon(ped)

--   SetPedWeaponTintIndex(ped, curweap, tonumber(args[1]))
-- end, false)

-- Citizen.CreateThread(function()
--   TriggerServerEvent("np-doors:request-lock-state")
-- end)

-- <data name="minimap"        	alignX="L"	alignY="B"	posX="-0.0045"		posY="0.002"		sizeX="0.150"		sizeY="0.188888" /> <!-- WARNING! Feed MUST match sizeX -->
-- <data name="minimap_mask"   	alignX="L"	alignY="B"	posX="0.020"		posY="0.032" 	 	sizeX="0.111"		sizeY="0.159" />
-- <data name="minimap_blur"   	alignX="L"	alignY="B"	posX="-0.03"		posY="0.022"		sizeX="0.266"		sizeY="0.237" />
-- Citizen.CreateThread(function()
--   local function setPosLB(type, posX, posY, sizeX, sizeY)
--     SetMinimapComponentPosition(type, "L", "B", posX, posY, sizeX, sizeY)
--   end
--   local offsetX = -0.018
--   local offsetY = 0.025

--   local defaultX = -0.0045
--   local defaultY = 0.002

--   local maskDiffX = 0.020 - defaultX
--   local maskDiffY = 0.032 - defaultY
--   local blurDiffX = -0.03 - defaultX
--   local blurDiffY = 0.022 - defaultY

--   local defaultMaskDiffX = 0.0245
--   local defaultMaskDiffY = 0.03

--   local defaultBlurDiffX = 0.0255
--   local defaultBlurDiffY = 0.02

--   setPosLB("minimap",       -0.0045,  0.006,  0.150, 0.15)
--   setPosLB("minimap_mask",  0.020,    0.022,  0.111, 0.159)
--   setPosLB("minimap_blur",  -0.03,    0.002,  0.266, 0.200)
-- end)

-- local createdDuis = {}
-- Citizen.CreateThread(function()
--   Citizen.Wait(5000)
--   local duiCount = 0
--   while duiCount < 13 do
--     duiCount = duiCount + 1
--     local crDui = CreateDui("https://i.imgur.com/ZVANiUy.png", 1024, 1024)
--     createdDuis[#createdDuis + 1] = crDui
--     while not IsDuiAvailable(crDui) do
--       Wait(100)
--     end
--     Citizen.Wait(1000)
--   end
--   print('finished loading duis')
-- end)
-- exports('getDuiObject', function(id, newObj)
--   if newObj then
--     createdDuis[id] = CreateDui("https://i.imgur.com/ZVANiUy.png", 1024, 1024)
--     while not IsDuiAvailable(createdDuis[id]) do
--       Wait(100)
--     end
--   end
--   return createdDuis[id]
-- end)
-- local dictCreated = {}
-- exports('getTxd', function(id)
--   local txd
--   if not dictCreated[id] then
--     txd = CreateRuntimeTxd(id)
--     dictCreated[id] = txd
--   else
--     txd = dictCreated[id]
--   end
--   return txd
-- end)
-- Citizen.CreateThread(function()
--   SetPlayerParachuteModelOverride(PlayerId(), `p_parachute1_mp_dec`) -- p_parachute1_mp_s
--   print(1)
-- end)

-- Citizen.CreateThread(function()
--   local veh = GetVehiclePedIsIn(PlayerPedId())
--   print(GetVehicleNumberPlateText(veh))
-- end)

-- Citizen.CreateThread(function()
--   while true do
--     SetStaticEmitterEnabled("LOS_SANTOS_AMMUNATION_GUN_RANGE", false)
--     Citizen.Wait(60000)
--   end
-- end)

-- local tvCoords = vector3(-524.97, -180.9, 37.73)
-- local tvReplaced = false
-- Citizen.CreateThread(function()
--   while true do
--     if not tvReplaced and #(tvCoords - GetEntityCoords(PlayerPedId())) < 10.0 then
--       local duiObj = CreateDui('https://dummyimage.com/600x400/000/fff&text=8', 600, 400)
--       local dui = GetDuiHandle(duiObj)
--       local txd = CreateRuntimeTxd('duiTxdTVinCityHall')
--       local tx = CreateRuntimeTextureFromDuiHandle(txd, 'duiTexTVinCityHall', dui)
--       tvReplaced = true
--       AddReplaceTexture('prop_cs_tv_stand', 'script_rt_tvscreen', 'duiTxdTVinCityHall', 'duiTexTVinCityHall')
--     elseif tvReplaced and #(tvCoords - GetEntityCoords(PlayerPedId())) > 10.0 then
--       RemoveReplaceTexture('prop_cs_tv_stand', 'script_rt_tvscreen')
--       tvReplaced = false
--     end
--     Citizen.Wait(1000)
--   end
-- end)

-- local females = {
--   "a_f_m_beach_01",
--   "a_f_m_bevhills_01",
--   "a_f_m_bevhills_01",
--   "a_f_m_bevhills_02",
--   "a_f_m_bevhills_02",
--   "a_f_m_bodybuild_01",
--   "a_f_m_bodybuild_01",
--   "a_f_m_business_02",
--   "a_f_m_business_02",
--   "a_f_m_downtown_01",
--   "a_f_m_downtown_01",
--   "a_f_m_eastsa_01",
--   "a_f_m_eastsa_01s",
--   "a_f_m_eastsa_02",
--   "a_f_m_eastsa_02s",
--   "a_f_m_fatbla_01",
--   "a_f_m_fatbla_01s",
--   "a_f_m_fatcult_01",
--   "a_f_m_fatcult_01",
--   "a_f_m_fatwhite_01",
--   "a_f_m_fatwhite_01",
--   "a_f_m_ktown_01",
--   "a_f_m_ktown_01s",
--   "a_f_m_ktown_02",
--   "a_f_m_ktown_02",
--   "a_f_m_prolhost_01",
--   "a_f_m_prolhost_01",
--   "a_f_m_salton_01",
--   "a_f_m_salton_01s",
--   "a_f_m_skidrow_01",
--   "a_f_m_skidrow_01",
--   "a_f_m_soucent_01",
--   "a_f_m_soucent_01s",
--   "a_f_m_soucent_02",
--   "a_f_m_soucent_02",
--   "a_f_m_soucentmc_01",
--   "a_f_m_soucentmc_01s",
--   "a_f_m_tourist_01",
--   "a_f_m_tourist_01",
--   "a_f_m_tramp_01",
--   "a_f_m_tramp_01",
--   "a_f_m_trampbeac_01",
--   "a_f_m_trampbeac_01",
--   "a_f_o_genstreet_01",
--   "a_f_o_genstreet_01",
--   "a_f_o_indian_01",
--   "a_f_o_indian_01",
--   "a_f_o_ktown_01",
--   "a_f_o_ktown_01",
--   "a_f_o_salton_01",
--   "a_f_o_salton_01",
--   "a_f_o_soucent_01",
--   "a_f_o_soucent_01",
--   "a_f_o_soucent_02",
--   "a_f_o_soucent_02s",
--   "a_f_y_beach_01",
--   "a_f_y_beach_01s",
--   "a_f_y_bevhills_01",
--   "a_f_y_bevhills_01",
--   "a_f_y_bevhills_02",
--   "a_f_y_bevhills_02",
--   "a_f_y_bevhills_03",
--   "a_f_y_bevhills_03",
--   "a_f_y_bevhills_04",
--   "a_f_y_bevhills_04",
--   "a_f_y_business_01",
--   "a_f_y_business_01",
--   "a_f_y_business_02",
--   "a_f_y_business_02",
--   "a_f_y_business_03",
--   "a_f_y_business_03",
--   "a_f_y_business_04",
--   "a_f_y_business_04",
--   "a_f_y_clubcust_01",
--   "a_f_y_clubcust_01s",
--   "a_f_y_clubcust_02",
--   "a_f_y_clubcust_02s",
--   "a_f_y_clubcust_03",
--   "a_f_y_clubcust_03s",
--   "a_f_y_eastsa_01",
--   "a_f_y_eastsa_01s",
--   "a_f_y_eastsa_02",
--   "a_f_y_eastsa_02s",
--   "a_f_y_eastsa_03",
--   "a_f_y_eastsa_03",
--   "a_f_y_epsilon_01",
--   "a_f_y_epsilon_01",
--   "a_f_y_femaleagent",
--   "a_f_y_femaleagent",
--   "a_f_y_fitness_01",
--   "a_f_y_fitness_01",
--   "a_f_y_fitness_02",
--   "a_f_y_fitness_02",
--   "a_f_y_genhot_01",
--   "a_f_y_genhot_01",
--   "a_f_y_golfer_01",
--   "a_f_y_golfer_01s",
--   "a_f_y_hiker_01",
--   "a_f_y_hiker_01",
--   "a_f_y_hippie_01",
--   "a_f_y_hippie_01",
--   "a_f_y_hipster_01",
--   "a_f_y_hipster_01s",
--   "a_f_y_hipster_02",
--   "a_f_y_hipster_02",
--   "a_f_y_hipster_03",
--   "a_f_y_hipster_03",
--   "a_f_y_hipster_04",
--   "a_f_y_hipster_04s",
--   "a_f_y_indian_01",
--   "a_f_y_indian_01",
--   "a_f_y_juggalo_01",
--   "a_f_y_juggalo_01",
--   "a_f_y_runner_01",
--   "a_f_y_runner_01",
--   "a_f_y_rurmeth_01",
--   "a_f_y_rurmeth_01",
--   "a_f_y_scdressy_01",
--   "a_f_y_scdressy_01s",
--   "a_f_y_skater_01",
--   "a_f_y_skater_01s",
--   "a_f_y_soucent_01",
--   "a_f_y_soucent_01",
--   "a_f_y_soucent_02",
--   "a_f_y_soucent_02",
--   "a_f_y_soucent_03",
--   "a_f_y_soucent_03",
--   "a_f_y_tennis_01",
--   "a_f_y_tennis_01s",
--   "a_f_y_topless_01",
--   "a_f_y_topless_01",
--   "a_f_y_tourist_01",
--   "a_f_y_tourist_01s",
--   "a_f_y_tourist_02",
--   "a_f_y_tourist_02",
--   "a_f_y_vinewood_01",
--   "a_f_y_vinewood_01",
--   "a_f_y_vinewood_02",
--   "a_f_y_vinewood_02",
--   "a_f_y_vinewood_03",
--   "a_f_y_vinewood_03s",
--   "a_f_y_vinewood_04",
--   "a_f_y_vinewood_04s",
--   "a_f_y_yoga_01",
--   "a_f_y_yoga_01",
--   "a_f_y_gencaspat_01",
--   "a_f_y_gencaspat_01s",
--   "a_f_y_smartcaspat_01",
--   "a_f_y_smartcaspat_01s",
-- }

-- local male = {
--   "a_m_m_acult_01",
--   "a_m_m_acult_01",
--   "a_m_m_afriamer_01",
--   "a_m_m_afriamer_01s",
--   "a_m_m_beach_01",
--   "a_m_m_beach_01s",
--   "a_m_m_beach_02",
--   "a_m_m_beach_02",
--   "a_m_m_bevhills_01",
--   "a_m_m_bevhills_01s",
--   "a_m_m_bevhills_02",
--   "a_m_m_bevhills_02s",
--   "a_m_m_business_01",
--   "a_m_m_business_01",
--   "a_m_m_eastsa_01",
--   "a_m_m_eastsa_01s",
--   "a_m_m_eastsa_02",
--   "a_m_m_eastsa_02s",
--   "a_m_m_farmer_01",
--   "a_m_m_farmer_01s",
--   "a_m_m_fatlatin_01",
--   "a_m_m_fatlatin_01s",
--   "a_m_m_genfat_01",
--   "a_m_m_genfat_01s",
--   "a_m_m_genfat_02",
--   "a_m_m_genfat_02s",
--   "a_m_m_golfer_01",
--   "a_m_m_golfer_01",
--   "a_m_m_hasjew_01",
--   "a_m_m_hasjew_01s",
--   "a_m_m_hillbilly_01",
--   "a_m_m_hillbilly_01",
--   "a_m_m_hillbilly_02",
--   "a_m_m_hillbilly_02s",
--   "a_m_m_indian_01",
--   "a_m_m_indian_01s",
--   "a_m_m_ktown_01",
--   "a_m_m_ktown_01s",
--   "a_m_m_malibu_01",
--   "a_m_m_malibu_01s",
--   "a_m_m_mexcntry_01",
--   "a_m_m_mexcntry_01s",
--   "a_m_m_mexlabor_01",
--   "a_m_m_mexlabor_01",
--   "a_m_m_og_boss_01",
--   "a_m_m_og_boss_01s",
--   "a_m_m_paparazzi_01",
--   "a_m_m_paparazzi_01",
--   "a_m_m_polynesian_01",
--   "a_m_m_polynesian_01s",
--   "a_m_m_prolhost_01",
--   "a_m_m_prolhost_01",
--   "a_m_m_rurmeth_01",
--   "a_m_m_rurmeth_01",
--   "a_m_m_salton_01",
--   "a_m_m_salton_01",
--   "a_m_m_salton_02",
--   "a_m_m_salton_02s",
--   "a_m_m_salton_03",
--   "a_m_m_salton_03s",
--   "a_m_m_salton_04",
--   "a_m_m_salton_04s",
--   "a_m_m_skater_01",
--   "a_m_m_skater_01s",
--   "a_m_m_skidrow_01",
--   "a_m_m_skidrow_01s",
--   "a_m_m_socenlat_01",
--   "a_m_m_socenlat_01s",
--   "a_m_m_soucent_01",
--   "a_m_m_soucent_01s",
--   "a_m_m_soucent_02",
--   "a_m_m_soucent_02s",
--   "a_m_m_soucent_03",
--   "a_m_m_soucent_03s",
--   "a_m_m_soucent_04",
--   "a_m_m_soucent_04s",
--   "a_m_m_stlat_02",
--   "a_m_m_stlat_02s",
--   "a_m_m_tennis_01",
--   "a_m_m_tennis_01s",
--   "a_m_m_tourist_01",
--   "a_m_m_tourist_01s",
--   "a_m_m_tramp_01",
--   "a_m_m_tramp_01",
--   "a_m_m_trampbeac_01",
--   "a_m_m_trampbeac_01",
--   "a_m_m_tranvest_01",
--   "a_m_m_tranvest_01",
--   "a_m_m_tranvest_02",
--   "a_m_m_tranvest_02",
--   "a_m_o_acult_01",
--   "a_m_o_acult_01s",
--   "a_m_o_acult_02",
--   "a_m_o_acult_02s",
--   "a_m_o_beach_01",
--   "a_m_o_beach_01s",
--   "a_m_o_genstreet_01",
--   "a_m_o_genstreet_01s",
--   "a_m_o_ktown_01",
--   "a_m_o_ktown_01s",
--   "a_m_o_salton_01",
--   "a_m_o_salton_01s",
--   "a_m_o_soucent_01",
--   "a_m_o_soucent_01s",
--   "a_m_o_soucent_02",
--   "a_m_o_soucent_02s",
--   "a_m_o_soucent_03",
--   "a_m_o_soucent_03s",
--   "a_m_o_tramp_01",
--   "a_m_o_tramp_01",
--   "a_m_y_acult_01",
--   "a_m_y_acult_01",
--   "a_m_y_acult_02",
--   "a_m_y_acult_02",
--   "a_m_y_beach_01",
--   "a_m_y_beach_01s",
--   "a_m_y_beach_02",
--   "a_m_y_beach_02s",
--   "a_m_y_beach_03",
--   "a_m_y_beach_03s",
--   "a_m_y_beachvesp_01",
--   "a_m_y_beachvesp_01s",
--   "a_m_y_beachvesp_02",
--   "a_m_y_beachvesp_02s",
--   "a_m_y_bevhills_01",
--   "a_m_y_bevhills_01s",
--   "a_m_y_bevhills_02",
--   "a_m_y_bevhills_02s",
--   "a_m_y_breakdance_01",
--   "a_m_y_breakdance_01s",
--   "a_m_y_busicas_01",
--   "a_m_y_busicas_01",
--   "a_m_y_business_01",
--   "a_m_y_business_01",
--   "a_m_y_business_02",
--   "a_m_y_business_02",
--   "a_m_y_business_03",
--   "a_m_y_business_03",
--   "a_m_y_clubcust_01",
--   "a_m_y_clubcust_01s",
--   "a_m_y_clubcust_02",
--   "a_m_y_clubcust_02s",
--   "a_m_y_clubcust_03",
--   "a_m_y_clubcust_03s",
--   "a_m_y_cyclist_01",
--   "a_m_y_cyclist_01s",
--   "a_m_y_dhill_01",
--   "a_m_y_dhill_01s",
--   "a_m_y_downtown_01",
--   "a_m_y_downtown_01s",
--   "a_m_y_eastsa_01",
--   "a_m_y_eastsa_01s",
--   "a_m_y_eastsa_02",
--   "a_m_y_eastsa_02s",
--   "a_m_y_epsilon_01",
--   "a_m_y_epsilon_01",
--   "a_m_y_epsilon_02",
--   "a_m_y_epsilon_02",
--   "a_m_y_gay_01",
--   "a_m_y_gay_01s",
--   "a_m_y_gay_02",
--   "a_m_y_gay_02s",
--   "a_m_y_genstreet_01",
--   "a_m_y_genstreet_01s",
--   "a_m_y_genstreet_02",
--   "a_m_y_genstreet_02s",
--   "a_m_y_golfer_01",
--   "a_m_y_golfer_01s",
--   "a_m_y_hasjew_01",
--   "a_m_y_hasjew_01s",
--   "a_m_y_hiker_01",
--   "a_m_y_hiker_01s",
--   "a_m_y_hippy_01",
--   "a_m_y_hippy_01s",
--   "a_m_y_hipster_01",
--   "a_m_y_hipster_01s",
--   "a_m_y_hipster_02",
--   "a_m_y_hipster_02s",
--   "a_m_y_hipster_03",
--   "a_m_y_hipster_03s",
--   "a_m_y_indian_01",
--   "a_m_y_indian_01",
--   "a_m_y_jetski_01",
--   "a_m_y_jetski_01",
--   "a_m_y_juggalo_01",
--   "a_m_y_juggalo_01s",
--   "a_m_y_ktown_01",
--   "a_m_y_ktown_01s",
--   "a_m_y_ktown_02",
--   "a_m_y_ktown_02s",
--   "a_m_y_latino_01",
--   "a_m_y_latino_01s",
--   "a_m_y_methhead_01",
--   "a_m_y_methhead_01",
--   "a_m_y_mexthug_01",
--   "a_m_y_mexthug_01s",
--   "a_m_y_motox_01",
--   "a_m_y_motox_01s",
--   "a_m_y_motox_02",
--   "a_m_y_motox_02s",
--   "a_m_y_musclbeac_01",
--   "a_m_y_musclbeac_01s",
--   "a_m_y_musclbeac_02",
--   "a_m_y_musclbeac_02s",
--   "a_m_y_polynesian_01",
--   "a_m_y_polynesian_01s",
--   "a_m_y_roadcyc_01",
--   "a_m_y_roadcyc_01s",
--   "a_m_y_runner_01",
--   "a_m_y_runner_01s",
--   "a_m_y_runner_02",
--   "a_m_y_runner_02",
--   "a_m_y_salton_01",
--   "a_m_y_salton_01s",
--   "a_m_y_skater_01",
--   "a_m_y_skater_01s",
--   "a_m_y_skater_02",
--   "a_m_y_skater_02s",
--   "a_m_y_soucent_01",
--   "a_m_y_soucent_01s",
--   "a_m_y_soucent_02",
--   "a_m_y_soucent_02s",
--   "a_m_y_soucent_03",
--   "a_m_y_soucent_03s",
--   "a_m_y_soucent_04",
--   "a_m_y_soucent_04s",
--   "a_m_y_stbla_01",
--   "a_m_y_stbla_01",
--   "a_m_y_stbla_02",
--   "a_m_y_stbla_02s",
--   "a_m_y_stlat_01",
--   "a_m_y_stlat_01s",
--   "a_m_y_stwhi_01",
--   "a_m_y_stwhi_01s",
--   "a_m_y_stwhi_02",
--   "a_m_y_stwhi_02",
--   "a_m_y_sunbathe_01",
--   "a_m_y_sunbathe_01s",
--   "a_m_y_surfer_01",
--   "a_m_y_surfer_01",
--   "a_m_y_vindouche_01",
--   "a_m_y_vindouche_01",
--   "a_m_y_vinewood_01",
--   "a_m_y_vinewood_01s",
--   "a_m_y_vinewood_02",
--   "a_m_y_vinewood_02",
--   "a_m_y_vinewood_03",
--   "a_m_y_vinewood_03s",
--   "a_m_y_vinewood_04",
--   "a_m_y_vinewood_04s",
--   "a_m_y_yoga_01",
--   "a_m_y_yoga_01s",
--   "a_m_m_mlcrisis_01",
--   "a_m_m_mlcrisis_01s",
--   "a_m_y_gencaspat_01",
--   "a_m_y_gencaspat_01s",
--   "a_m_y_smartcaspat_01",
--   "a_m_y_smartcaspat_01s",
-- }

-- function doStuff(v)
--   print(v)
--   RequestModel(v)
--   while not HasModelLoaded(v) do
--     Wait(0)
--   end
--   local ped = CreatePed(5, GetHashKey(v), GetEntityCoords(PlayerPedId()), 0.0, 0, 0);
--   while not DoesEntityExist(ped) do
--     Wait(0)
--   end
--   local lc = 0
--   while lc < 1000 do
--     SetPedRandomComponentVariation(ped, true)
--     lc = lc + 1
--     Wait(0)
--   end
-- end
-- Citizen.CreateThread(function()
--   for _, v in pairs(females) do
--     doStuff(v)
--   end
-- end)

-- Citizen.CreateThread(function()
--   while true do
--     local pos = GetEntityCoords(PlayerPedId(),  true)
--     TriggerServerEvent("dispatch:svNotify", {
--       dispatchCode = "10-13B",
--       firstStreet = "W/E",
--       callSign = "111",
--       cid = exports["isPed"]:isPed("cid"),
--       origin = {
--         x = pos.x,
--         y = pos.y,
--         z = pos.z
--       }
--     })
--     Wait(250)
--   end
-- end)

-- Citizen.CreateThread(function()
--   RequestModel(`ch_prop_gold_trolly_empty`)
--   while not HasModelLoaded(`ch_prop_gold_trolly_empty`) do
--     print('wait')
--     Wait(0)
--   end
--   CreateObject(`ch_prop_gold_trolly_empty`, GetEntityCoords(PlayerPedId()), 1, 1, 1)
-- end)
-- Citizen.CreateThread(function()
--   while true do
--     print(IsFlashLightOn(PlayerPedId()))
--     Wait(1000)
--   end
  
-- end)

-- Citizen.CreateThread(function (arg1, arg2, arg3)
--   RequestIpl('vw_dlc_casino_door')
  
--   local interiorID = GetInteriorAtCoords(1100.000, 220.000, -50.000)
  
--   if IsValidInterior(interiorID) then
--       RefreshInterior(interiorID)
--   end
-- end)

-- experimenting with shooting back of vehicle
-- AddEventHandler("gameEventTriggered", function(name, ...)
--   print(name, json.encode(...))
-- end)

-- Citizen.CreateThread(function()
--   while true do
--     local entity = exports["np-target"]:GetEntityPlayerIsLookingAt(80, 5, 12)
--     print(entity)
--     local damage = GetWeaponDamage(`WEAPON_VINTAGEPISTOL`)
--     print(damage)
--     Wait(250)
--   end
-- end)
-- function RayCast(origin, target, options, ignoreEntity, radius)
--   local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius, options, ignoreEntity, 0)
--   return GetShapeTestResult(handle)
-- end
-- function GetForwardVector(rotation)
--   local rot = (math.pi / 180.0) * rotation
--   return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
-- end
-- Citizen.CreateThread(function()
--   while true do
--     local shooting = IsPedShooting(PlayerPedId())
--     if shooting then
--       PlayerPed = PlayerPedId()
--       PlayerCoords = GetPedBoneCoords(PlayerPed, 31086)
--       ForwardVectors = GetForwardVector(GetGameplayCamRot(2))
--       ForwardCoords = PlayerCoords + (ForwardVectors * 50.0)

--       local _, hit, targetCoords, _, targetEntity = RayCast(PlayerCoords, ForwardCoords, 286, PlayerPed, 0.2)

--       if hit and GetEntityType(targetEntity) == 2 then
--         -- local _, hit1, targetCoords, _, targetEntity1 = RayCast(PlayerCoords, ForwardCoords, 12, PlayerPed, 0.2)

--         local seats = GetVehicleModelNumberOfSeats(GetEntityModel(targetEntity))
        
--         -- local boneID = GetEntityBoneIndexByName(targetEntity, "boot")
--         -- local boneCoords = GetWorldPositionOfEntityBone(targetEntity, boneID)
--         -- print(boneID, boneCoords, PlayerCoords)
--         local radi = math.abs(GetEntityHeading(targetEntity) - GetEntityHeading(PlayerPedId()))
--         local m = math.fmod(radi, 360.0)
--         local angle = m > 180.0 and 360.0 - m or m

--         if angle < 28.0 then

--           local loop = -1
--           while loop < seats - 1 do
--             local ped = GetPedInVehicleSeat(targetEntity, loop)
--             local damage = GetWeaponDamage(GetSelectedPedWeapon(PlayerPedId()))
--             local damageMod = math.ceil(damage * 0.5)
--             print(damage, damageMod)
--             if ped ~= 0 then
--               -- ApplyDamageToPed(ped, 1000, true)
--               TriggerServerEvent(
--                 "np-sync:executeSyncNative",
--                 "0x697157CED63F18D4",
--                 NetworkGetNetworkIdFromEntity(ped),
--                 { entity = { 1 } },
--                 { NetworkGetNetworkIdFromEntity(ped), damageMod, true }
--               )
--             end
--             loop = loop + 1
--           end
  
--         end
--       end
--     end
--     Wait(0)
--   end
-- end)

-- Citizen.CreateThread(function()
--   local i = 1
--   while i < 8 do
--     print(i, GetSelectedPedWeapon(PlayerPedId()))
--     SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), i)
--     i = i + 1
--     Citizen.Wait(1000)
--   end
-- end)

-- function angleBetween(p1, p2)
--   local p = {}
--   p.x = p2.x-p1.x
--   p.y = p2.y-p1.y

--   local r = math.atan2(p.y,p.x)*180/math.pi
--   return r
-- end

-- RegisterCommand("fly", function()
--   local start = vector3(620.22, -738.04, 12.05)
--   local destination = vector3(597.83, -835.69, 42.53)
--   local difference = #(start - destination)
--   print('difference', difference)
--   print('starting in 3...')
--   local m = PlayerPedId()
--   SetEntityCoords(m, start)
--   FreezeEntityPosition(PlayerPedId(), false)
--   local ger = GetEntityRotation(PlayerPedId(), 2)
--   print('rotate', json.encode(ger))

--   -- while true do
--   --   DrawLine(start.x, start.y, start.z, destination.x, destination.y, destination.z, 100, 100, 100, 1.0)
--   --   Wait(0)
--   -- end

--   print('angle', angleBetween(start, destination))

--   -- local x = 0.0
--   -- while x < 360 do
--   --   x = x + 1.0
--   --   SetEntityRotation(PlayerPedId(), x, 0.0, 0.0, 2, true)
--   --   print(x)
--   --   Wait(500)
--   -- end
--   RequestModel("adder")

--   Wait(1000)
--   print('2...')
--   Wait(1000)
--   print('1...')
--   Wait(1000)

--   local diffX = (start.x - destination.x) / 60
--   local dirX = 'plus'
--   if start.x > 0 and destination.x < start.x then
--     dirX = 'minus'
--   end

--   local diffY = (destination.y - start.y) / 60
--   local dirY = 'plus'
--   if start.y < 0 and destination.y < start.y then
--     dirX = 'minus'
--   end

--   local diffZ = (destination.z - start.z) / 60
--   local dirZ = 'plus'
--   if start.z < 0 and destination.z < start.z then
--     dirX = 'minus'
--   end

--   local mapped = {}
--   local count = 0

--   while count < 60 do
--     count = count + 1
--     local x, y, z = 0
--     if dirX == 'plus' then
--       x = start.x + (count * diffX)
--     else
--       x = start.x - (count * diffX)
--     end
--     if dirY == 'plus' then
--       y = start.y + (count * diffY)
--     else
--       y = start.y - (count * diffY)
--     end
--     if dirZ == 'plus' then
--       z = start.z + (count * diffZ)
--     else
--       z = start.z - (count * diffZ)
--     end
--     mapped[count] = vector3(x, y, z)
--   end
  

--   SetEntityInvincible(PlayerPedId(), true)
--   -- FreezeEntityPosition(PlayerPedId(), true)
--   RopeLoadTextures()

--   while not RopeAreTexturesLoaded() do
--     Wait(0)
--   end
--   local ped = GetPlayerPed(PlayerId())
--   local pedPos = GetEntityCoords(ped, false)
  

-- --   float angleX = Vector3.Angle(new Vector3(camera_position.x, 0, 0), new Vector3(enemy_position.x, 0, 0));
-- -- float angleY = Vector3.Angle(new Vector3(0, camera_position.y, 0), new Vector3(0, enemy_position.y, 0));
-- -- -- float angleZ = Vector3.Angle(new Vector3(0, 0, camera_position.z), new Vector3(0, 0, enemy_position.z));

-- --   local ropeX = angleBetween(vector3(pedPos.x, 0.0, 0.0), vector3(destination.x, 0.0, 0.0))
-- --   local ropeY = angleBetween(vector3(0.0, pedPos.y, 0.0), vector3(0.0, destination.y, 0.0))
-- --   local ropeZ = angleBetween(vector3(0.0, 0.0, pedPos.z), vector3(0.0, 0.0, destination.z))

 
--   local veh = CreateVehicle(`adder`, destination, 0.0, 1, 1)
--   FreezeEntityPosition(veh, true)
--   SetEntityInvincible(veh, true)
--   SetEntityVisible(veh, 0, 0)
--   SetEntityCollision(veh, false, false)

--   local rope = AddRope(
--     start,
--     0.0,
--     0.0,
--     0.0,
--     difference,
--     4, -- type
--     difference, -- maxlen
--     1.0, -- minlen
--     0, -- winding speed
--     0, -- p11
--     0, -- p12
--     0, -- rigid
--     0, -- p14
--     0 -- breakwhenshot
--     )
--     AttachEntitiesToRope(rope, ped, veh, start, destination, difference, 0, 0, 0, 0)

--   for _, coords in pairs(mapped) do
--     SetEntityCoords(PlayerPedId(), coords)
--     SetEntityRotation(PlayerPedId(), math.abs(angleBetween(start, destination)), 0.0, 0.0, 2, true)
--     Wait(0)
--   end

--   SetEntityInvincible(PlayerPedId(), false)
--   FreezeEntityPosition(PlayerPedId(), false)

--   Wait(1000)
--   DeleteChildRope(rope)
--   DeleteRope(rope)
--   DeleteEntity(veh)
-- end)
