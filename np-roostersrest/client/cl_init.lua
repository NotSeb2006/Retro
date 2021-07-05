Citizen.CreateThread(function()
    exports["np-polyzone"]:AddBoxZone("np-roostersrest:tavern_main", vector3(-163.7, 300.98, 99.42), 23.6, 21.45, {
        heading=179,
        minZ=97.42,
        maxZ=102.02
    })

    exports["np-polyzone"]:AddBoxZone("np-roostersrest:tavern_near", vector3(-160.79, 303.37, 105.87), 28.6, 46.8, {
        heading=0,
        minZ=89.67,
        maxZ=103.67,
        zoneEvents={"np-roostersrest:activePurchase", "np-roostersrest:closePurchase"}
    })

    exports["np-polyzone"]:AddBoxZone("np-roostersrest:tavern_stage", vector3(-163.56, 311.17, 99.11), 2.6, 5.35, {
        heading=179,
        minZ=98.11,
        maxZ=101.11
    })

    -- exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_counter", vector3(-170.95, 302.43, 98.52), 1.6, 1.0, {
    --     heading=0,
    --     minZ=98.52,
    --     maxZ=98.92
    -- })

    -- exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_counter_upper", vector3(-171.36, 291.72, 99.2), 3.4, 1, {
    --     heading=0,
    --     minZ=99.0,
    --     maxZ=99.6
    -- })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_ingredients", vector3(-171.38, 296.13, 99.2), 2.0, 1, {
        heading=0,
        minZ=98.2,
        maxZ=99.6
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_takeout", vector3(-172.62, 289.58, 99.2), 1.0, 1.6, {
        heading=0,
        minZ=98.4,
        maxZ=100.0
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_counter_drinks", vector3(-171.28, 303.53, 98.52), 2.2, 0.4, {
        heading=0,
        minZ=97.52,
        maxZ=98.52
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_checkin", vector3(-141.69, 302.5, 98.47), 3.2, 1, {
        heading=0,
        minZ=98.27,
        maxZ=99.07
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:tavern_cooking", vector3(-173.83, 291.56, 99.2), 3.4, 1, {
        heading=0,
        minZ=99.0,
        maxZ=99.8
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:register_charge", vector3(-173.94, 304.69, 98.53), 1.4, 0.6, {
        heading=0,
        minZ=98.48,
        maxZ=99.08
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:register_pay", vector3(-171.01, 304.21, 98.52), 1.4, 0.6, {
        heading=0,
        minZ=98.52,
        maxZ=99.12
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:register_2", vector3(-171.05, 300.79, 98.52), 1.2, 1.0, {
        heading=0,
        minZ=98.52,
        maxZ=98.92
    })

    exports["np-polytarget"]:AddBoxZone("np-roostersrest:signOn", vector3(-162.25, 327.26, 98.48), 0.6, 1, {
        heading=0,
        minZ=98.08,
        maxZ=98.68
    })
end)
