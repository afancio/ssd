-- @example Implementation of a simple precipitation from out off sistem using geospatial data.
-- @image ssdWaterCicle1Precipitation.bmp

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/GENERATE_MAPS.lua")

----------------------------------------------------------------
-- MODEL
cell = Cell {
    water = 0,
    waterColumnHeight = 0,
    init = function(cell)
        cell.water = 0
    end,
    logwater = function(cell)
        if cell.water < 1 then
            return 0
        else
            return math.log(cell.water)
        end
    end
}
ground_cs = CellularSpace {
    file = filePath("cabecadeboi.shp"),
    instance = cell,
    preeProcessamento2 = function()
        forEachCell(ground_cs, function(cell)
            forEachNeighbor(cell, function(neighbor)
                local difHeight = neighbor.height - cell.height
                if cell.waterColumnHeight < difHeight then cell.waterColumnHeight = difHeight end
            end)
            --Correção da declividade
            if cell.waterColumnHeight > 100 then
                --print('cell.height', cell.height)
                --print('cell.waterColumnHeight', cell.waterColumnHeight)
                local sumNeighborHeight = 0
                local sizeNeighborhoodDestiny = #cell:getNeighborhood()
                --print('sizeNeighborhoodDestiny', sizeNeighborhoodDestiny)
                forEachNeighbor(cell, function(neighbor)
                    --print('neighbor.height', neighbor.height)
                    sumNeighborHeight = sumNeighborHeight + neighbor.height
                end)
                --print('old', cell.height)
                --print('sumNeighborHeight', sumNeighborHeight)
                cell.height = sumNeighborHeight / sizeNeighborhoodDestiny
                cell.waterColumnHeight = 0
                --print('new', cell.height)
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

--[[
map1 = Map{
	target = ground_cs,
	select = "height",
	min = 0,
	max = 260,
	slices = 11,
	color = "Spectral",
	invert = true
}
]] --
map2 = Map {
    target = ground_cs,
    select = "logwater",
    min = 0,
    max = 16,
    slices = 15,
    color = "Blues"
}
summary = Cell {
    step = 0,
    inititalGroundWater = 0,
    totalGroundWater = 0,
    maxGroundWater = 0,
    minGroundWater = 9999,
    start = false
}
chartsummary = Chart {
    target = summary,
    width = 3,
    select = { "totalGroundWater" },
    --labels = {"totalGroundWater"},
    style = "lines",
    color = { "blue" },
    title = "Amount of water in the system (CellularSpace)"
}
--[[
chartsummary2 = Chart{
    target = summary,
    width = 3,
    select = {"maxGroundWater"},
    labels   = {"maxGroundWater"},
    style = "lines",
    color = {"darkBlue"},
    title = "Upper limit of water in cell"
}
]] --
timer = Timer {
    Event {
        action = function()
            ground_cs:init()
            --ground_cs:rain()
            ground_cs:synchronize()
            return false
        end
    },
    -- COMMENT TO Flow
    --[[
        Event{action = function()
            ground_cs:synchronize()
            ground_cs:init()
            ground_cs:runoff()
        end},
    ]] --
    --Event{action = map1},
    Event { action = map2 },
    Event { action = chartsummary },
    --Event{period = 10, action = chartsummary2},
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
            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    }
}
--[[
GENERATE_MAPS{
    experimentName = "WATER_CICLE_STAGE1", --chartsummary2:save("SAVES/"..EXPERIMENT_NAME.."/
    mapInitialTime = 1,
    mapFinalTime = 5000,
    mapPeriod = 10,
    beggin_saveList = {map2, map1},
    during_saveList = {map2},
    end_saveList = {chartsummary, chartsummary2}
}
]] --
-------------------------------------------------------------------
-- CHANGE RATES AND RULES
linear_precipitation_rate = 400
linear_precipitation_rule = function(t, stock) return linear_precipitation_rate end
-------------------------------------------------------------------
-- ConnectorS
fromEnvironment_nilCnt = Connector {
    collection = nil,
}
ground_localCnt = Connector {
    collection = ground_cs,
    attribute = "water"
}
-------------------------------------------------------------------
-- Flow OPERATORS
precipitation_Flow = Flow {
    rule = linear_precipitation_rule,
    source = fromEnvironment_nilCnt,
    target = ground_localCnt,
    timer = timer
}
--------------------------------------------------------------
-- MODEL EXECUTION
timer:run(100)
--os.exit(0)