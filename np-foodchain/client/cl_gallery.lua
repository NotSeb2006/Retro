Citizen.CreateThread(function()
  -- drinks place
  exports["np-polytarget"]:AddBoxZone("gallery_drinks", vector3(-491.66, 37.7, 52.41), 1.4, 0.6, {
    heading=357,
    minZ=52.41,
    maxZ=53.41,
    data = {
      id = "gallery_drinks",
    },
  })
  exports['np-interact']:AddPeekEntryByPolyTarget("gallery_drinks", {{
      event = "np-stripclub:peekAction",
      id = "galleryDrinks",
      icon = "circle",
      label = "Open",
      parameters = { action = "openFridge" },
  }}, { distance = { radius = 3.5 }  })
end)