-- @example Implementation of a simple precipitation from out off sistem using geospatial data.
-- Each cell in a cellular space suffer an energy variation in its attribute
-- stock (water) at a rate defined by f (t, y) (linear_precipitation_rule),
-- @image ssdWaterCicle1Precipitation.png

import("ssd")

---------------------------------------------------------------
-- # SPACE # Creation
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
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            ground_cs:init()
            --ground_cs:rain()
            ground_cs:synchronize()
            return false
        end
    },
    Event { action = map2 },
    Event { action = chartsummary },
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
    target = ground_localCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION
timer:run(100)