-- @example Implementation of an integration of two model rain, runoff and flood models using geospatial data
-- (applied in the mountains of the Cabeça de Boi region of the Serra do Cipó National Park with Serra do Lobo,
--  in Brazil.
-- Integrated to it, the model has two flows:
-- 1 - The semantics of the rain flow operator will work by transferring water from the cell’s selection of the
-- Trajectory clouds_tj of atmophere_cs for each cell of ground_cs in fractions calculated by
-- precipitation_rule at each simulation instant. It becomes clear the water transfer between CellularSpace’s
-- cs_atmosphere and cs_ground until simulation time 140.
-- 2 - The phenomenon of runoff with a Flow Focal operator, results from the runoff of water from
-- higher terrain for terrain of the same elevation or less elevated. The semantics of the flow operator
-- will work by transferring water from each cell’s of the ground_cs in fractions calculated by dispersion_rule to
-- each simulation instant divided in equal fractions among the lowest elevation neighbors.
-- @image ssdWaterCicle3recipitationAndRumOff.png

import("ssd")

---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    water = 0,
    waterColumnHeight = 0,
    init = function(cell)
        cell.water = 0
    end,
    rain = function(cell)
        if cell.height > 200 then
            cell.water = cell.water + 200
        end
    end,
    logwater = function(cell)
        if cell.water < 1 then
            return 0
        else
            return math.log(cell.water)
        end
    end,
    logAtmosphereWater = function(cell)
        if cell.water < 1 then
            return 0
        else
            return math.log(cell.atmosphereWater)
        end
    end,
    flood_area = function(cell)
        if cell.water > cell.waterColumnHeight * 100000 then
            return 1
        else
            return 0
        end
    end
}
ground_cs = CellularSpace {
    file = filePath("cabecadeboi.shp"), -- also try cabecadeboi800.shp
    instance = cell,
    preeProcessamento2 = function()
        forEachCell(ground_cs, function(cell)
            forEachNeighbor(cell, function(neighbor)
                local difHeight = neighbor.height - cell.height
                if cell.waterColumnHeight < difHeight then cell.waterColumnHeight = difHeight end
            end)
            --Correção da declividade
            if cell.waterColumnHeight > 100 then
                local sumNeighborHeight = 0
                local sizeNeighborhoodDestiny = #cell:getNeighborhood()
                forEachNeighbor(cell, function(neighbor)
                    sumNeighborHeight = sumNeighborHeight + neighbor.height
                end)
                cell.height = sumNeighborHeight / sizeNeighborhoodDestiny
                cell.waterColumnHeight = 0
            end
        end)
    end,
    preeProcessamentoPosDeclividade = function()
        forEachCell(ground_cs, function(cell)
            forEachNeighbor(cell, function(neighbor)
                local difHeight = neighbor.height - cell.height
                if cell.waterColumnHeight < difHeight then cell.waterColumnHeight = difHeight end
            end)
        end)

        forEachCell(ground_cs, function(cell)
            if cell.waterColumnHeight > 150 then
                print('second', cell.waterColumnHeight)
            end
        end)
    end
}
ground_cs:createNeighborhood()
ground_cs:preeProcessamento2()
ground_cs:preeProcessamentoPosDeclividade()

ground_cs:createNeighborhood {
    name = "neighGround",
    strategy = "mxn",
    --m = 3,
    filter = function(cell, cell2)
        return cell.height >= cell2.height
    end
}

atmosphere_cell = Cell {
    --200milimetros, ceach cell 100x100m total de 8100 cells 2012 acima 200m = 80.516,89
    atmosphereWater = 0, -- 8051689.86,
    init = function()
        --cell.atmosphereWater = 0
    end,
    logAtmosphereWater = function(cell)
        if cell.atmosphereWater < 1 then
            return 0
        else
            return math.log(cell.atmosphereWater)
        end
    end,
    rainning_area = function(cell)
        if cell.atmosphereWater > 2051689 then --4051689 then
            return 1
        else
            return 0
        end
    end
}
atmosphere = CellularSpace {
    file = filePath("cabecadeboi.shp"),
    instance = atmosphere_cell,
    createFirstClouds = function()
        forEachCell(atmosphere, function(cell)
            if cell.height > 200 then
                cell.atmosphereWater = 8051689.86
            end
        end)
    end
}

atmosphere:createFirstClouds()

clouds_tj = Trajectory {
    target = atmosphere,
    select = function(cell)
        return cell.atmosphereWater > 2051689
    end
}

map1 = Map {
    target = ground_cs,
    select = "height",
    min = 0,
    max = 260,
    slices = 11,
    color = "Spectral",
    invert = true
}
map2 = Map {
    target = ground_cs,
    select = "logwater",
    min = 0,
    max = 25,
    slices = 15,
    color = "Blues"
}
map4 = Map {
    target = atmosphere,
    select = "logAtmosphereWater",
    min = 0,
    max = 25,
    slices = 15,
    color = "Blues"
}
summary = Cell {
    step = 0,
    inititalGroundWater = 0,
    totalGroundWater = 0,
    maxGroundWater = 0,
    minGroundWater = 8051690,
    totalAtmosphereWater_STEP0 = 0,
    totalAtmosphereWater = 0,
    Water_ATMOSPHERE_MAX = 0,
    Water_ATMOSPHERE_MIN = 8051690,
    start = false
}
chartsummary = Chart {
    target = summary,
    width = 3,
    select = { "totalGroundWater", "totalAtmosphereWater" },
    label = { "totalGroundWater", "totalAtmosphereWater" },
    style = "lines",
    color = { "blue", "darkBlue" },
    title = "Amount of water in the system (CellularSpace)"
}
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            ground_cs:init()
            ground_cs:synchronize()
            atmosphere:init()
            atmosphere:synchronize()
            return false
        end
    },
    Event { period = 1000, action = map1 },
    --Event{period = 1000, action = mapwaterColumnHeight},
    Event { action = map2 },
    --Event{period = 100, action = map3},
    Event { action = map4 },
    --Event{period = 100, action = map5},
    Event { action = chartsummary },
    --Event{period = 10, action = chartsummary2},
    Event {
        --start = 1,
        --period = 1,
        --priority = 0,
        action = function(event)
            clouds_tj:rebuild()
            clouds_tj:filter()
            if (event:getTime() >= 5000) then
                return false
            end
        end
    },
    --SUMMARY DATA MODEL EVENT
    Event {
        start = 0,
        --period = 1,
        priority = 9,
        action = function(event)
            print('=========================================================================================================== ')
            print("WATER VALITDATION STEP: " .. event:getTime())
            summary.totalGroundWater = 0
            summary.maxGroundWater = 0
            summary.minGroundWater = 999
            summary.step = event:getTime()
            --WATER SUMMARY
            forEachCell(ground_cs, function(cell)
                if (cell.water > summary.maxGroundWater) then summary.maxGroundWater = cell.water end
                if (cell.water < summary.minGroundWater) then summary.minGroundWater = cell.water end
                summary.totalGroundWater = summary.totalGroundWater + cell.water
            end)
            if (summary.start == false) then
                summary.inititalGroundWater = summary.totalGroundWater
                summary.start = true
            end
            print('TIME:', summary.step, 'summary.inititalGroundWater', summary.inititalGroundWater)
            print('summary.totalGroundWater:', summary.totalGroundWater)
            print('summary.maxGroundWater:', summary.maxGroundWater)
            print('log summary.maxGroundWater:', math.log(summary.maxGroundWater))
            print('summary.minGroundWater:', summary.minGroundWater)




            print("WATER ATMOSPHERE VALITDATION STEP: " .. event:getTime())
            summary.totalAtmosphereWater = 0
            summary.Water_ATMOSPHERE_MAX = 0
            summary.Water_ATMOSPHERE_MIN = 999
            summary.step = event:getTime()
            --WATER SUMMARY
            forEachCell(atmosphere, function(cell)
                if (cell.atmosphereWater > summary.Water_ATMOSPHERE_MAX) then summary.Water_ATMOSPHERE_MAX = cell.atmosphereWater end
                if (cell.atmosphereWater < summary.Water_ATMOSPHERE_MIN) then summary.Water_ATMOSPHERE_MIN = cell.atmosphereWater end
                summary.totalAtmosphereWater = summary.totalAtmosphereWater + cell.atmosphereWater
            end)
            if (summary.start == false) then
                summary.totalAtmosphereWater_STEP0 = summary.totalAtmosphereWater
                summary.start = true
            end
            print('TIME:', summary.step, 'summary.inititalGroundWater', summary.inititalGroundWater)
            print('summary.totalAtmosphereWater:', summary.totalAtmosphereWater)
            print('summary.Water_ATMOSPHERE_MAX:', summary.Water_ATMOSPHERE_MAX)
            print('log summary.Water_ATMOSPHERE_MAX:', math.log(summary.Water_ATMOSPHERE_MAX))
            print('summary.Water_ATMOSPHERE_MIN:', summary.Water_ATMOSPHERE_MIN)

            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    },
}
----------------------------------------------------------------------
-- CHANGE RATES AND RULES
precipitation_rate = 0.01
precipitation_rule = function(t, stock) return precipitation_rate * stock end
dispersion_rate = 0.5
dispersion_rule = function(t, stock) return dispersion_rate * stock end
----------------------------------------------------------------------
-- ConnectorS
ground_localCnt = Connector {
    collection = ground_cs,
    attribute = "water"
}
clouds_zonalCnt = Connector {
    collection = clouds_tj,
    attribute = "atmosphereWater"
}
aroundTheGround_focalCnt = Connector {
    collection = ground_cs,
    attribute = "water",
    neight = "neighGround"
}
---------------------------------------------------------------
-- Flow OPERATORS
precipitation_Flow = Flow {
    rule = precipitation_rule,
    source = clouds_zonalCnt,
    target = ground_localCnt
}
runOff_Flow = Flow {
    rule = dispersion_rule,
    source = ground_localCnt,
    target = aroundTheGround_focalCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION
timer:run(200)