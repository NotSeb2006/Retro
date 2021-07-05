Citizen.CreateThread(function()
  exports["np-polyzone"]:AddBoxZone("gallery_appraisals", vector3(-468.79, 31.6, 46.23), 1.2, 2.2, {
    heading=355,
    minZ=45.03,
    maxZ=47.43,
    data = {
      id = "gallery_appraisals",
    },
  })

  exports["np-polytarget"]:AddBoxZone("gallery_gemcraft", vector3(-457.81, -47.03, 49.36), 1.4, 0.6, {
    heading=85,
    minZ=48.96,
    maxZ=49.56,
    data = {
      id = "gallery_gemcraft",
    },
  })

  exports['np-interact']:AddPeekEntryByPolyTarget('gallery_gemcraft', {{
    event = "np-gallery:gemCraft",
    id = "gallery_gemcraft",
    icon = "box-open",
    label = "Gem Crafting"
  }}, { distance = { radius = 3.5 } })
end)
