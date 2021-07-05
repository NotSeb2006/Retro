function generateMetaData()
  local meta = {}

  -- location
  meta[#meta + 1] = { label = "Location", json = json.encode({ coords = GetEntityCoords(PlayerPedId()) }) }

  return meta
end

RegisterUICallback("np-ui:bugAction", function(data, cb)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
  data.meta = generateMetaData()
  RPC.execute("np-ui:bugApiRequest", data)
end)

local crashReportTimeout = 0
RegisterUICallback("np-ui:crashAction", function(data, cb)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
  if crashReportTimeout ~= 0 and crashReportTimeout + (60000 * 5) > GetGameTimer() then return end
  crashReportTimeout = GetGameTimer()
  data.meta = generateMetaData()
  -- disable until needed
  -- RPC.execute("np-ui:crashReportRequest", data)
end)

--
-- tx support, remove after api
--

RegisterUICallback("np-ui:generateTransactionHistory", function(data, cb)
  local result = RPC.execute("np-financials:generateTransactionHistory", data)
  cb({ data = result, meta = { ok = true, message = result } })
end)
