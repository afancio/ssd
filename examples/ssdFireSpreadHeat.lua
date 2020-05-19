-- @example Implementation of an simple model heat spread model using stochastic data.
-- The Heat propagation that propagates from each cell to his neights (3x3 moore) that has state GRASS, FOREST and
--  DENSE_FOREST and a stochastic chance of burning.
-- @image ssdFireSpreadHeat.bmp

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")
---------------------------------------------------------------
randomRate = Random { seed = 10 }
randomBoolean = Random { true, false }
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    biomass = Random { 0, 1, 2 },
    biomass_state = "FOREST",
    heat = 0,
    heat_state = "NO_HEAT",
    state = "forest",
    execute = function(self)
        if self.biomass <= 0 then
            self.biomass_state = "ROCK"
            --elseif self.biomass == 0 then
        elseif self.biomass > 0 and self.biomass <= 0.1 then
            self.biomass_state = "BURNED"
        elseif self.biomass > 0 and self.biomass <= 1 then
            self.biomass_state = "GRASS"
        elseif self.biomass > 2 and self.biomass <= 3 then
            self.biomass_state = "FOREST"
        elseif self.biomass > 3 then
            self.biomass_state = "DENSE_FOREST"
        end
        --ETAPA 2
        if self.heat == 0 then
            self.heat_state = "NO_HEAT"
        elseif self.heat > 0 then
            self.heat_state = "HEAT"
        end
        --ETAPA 2 FIM
    end
}
cs = CellularSpace {
    xdim = 50,
    instance = cell,
}
--ETAPA 2
cs:createNeighborhood {
    name = "neightHeat",
    --strategy = "vonneumann"
    strategy = "mxn"
}
cellSample = cs:sample()
cellSample.state = "burning"
cellSample.heat = 1

summary = Cell {
    step = 0,
    Biomass_TOTAL_STEP0 = 0,
    Biomass_GROUND_TOTAL = 0,
    Biomass_GROUND_MAX = 0,
    Biomass_GROUND_MIN = 999,
    start = false
}

mapCsHeat = Map {
    title = "Heat Propagation",
    target = cs,
    select = "heat_state",
    value = { "NO_HEAT", "HEAT" },
    color = { "green", "red" }
}
chartHeat = Chart {
    title = "Number of cells with heat x with no heat",
    target = cs,
    select = "heat_state",
    value = { "NO_HEAT", "HEAT" },
    color = { "green", "red" }
}
--ETAPA 2 FIM
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        --start = 0,
        priority = 9,
        action = cs
    },
    Event { action = mapCsHeat },
    Event { action = chartHeat },
    --SUMMARY DATA MODEL EVENT
    Event {
        --start = 0,
        priority = 9,
        action = function(event)
            print('=========================================================================================================== ')
            print("BIOMASS VALITDATION STEP: " .. event:getTime())
            summary.Biomass_GROUND_TOTAL = 0
            summary.step = event:getTime()
            --BIOMASS SUMMARY
            forEachCell(cs, function(cell)
                summary.Biomass_GROUND_TOTAL = summary.Biomass_GROUND_TOTAL + cell.biomass
            end)
            if (summary.start == false) then
                summary.Biomass_TOTAL_STEP0 = summary.Biomass_GROUND_TOTAL
                summary.start = true
            end
            print('TIME:', summary.step, 'summary.Biomass_TOTAL_STEP0', summary.Biomass_TOTAL_STEP0)
            print('summary.Biomass_GROUND_TOTAL:', summary.Biomass_GROUND_TOTAL)
            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    },
    --SAVE MAP DURING THE SIMULATION
    --    Event{action = function(event)
    --            mapCsHeat:save("SAVES/FS1M2_" .. event:getTime() .. ".bmp")
    --            if (event:getTime() >= 100) then return false end
    --        end },
}
---------------------------------------------------------------
-- Connectors and Flow OPERATORS
eachHeatGroundCell = Connector {
    collection = cs,
    attribute = "heat"
}
neightOfEachHeatGroundCell = Connector {
    collection = cs,
    attribute = "heat",
    neight = "neightHeat"
}
-------------------------------------------------------------------
-- CHANGE RATES AND RULES
heatdispersion_rate = 0.99
--funcHeatDisper = function(t, stock) return heatdispersion_rate * stock end
funcHeatDisper = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return heatdispersion_rate * sourceCell.heat
end
---------------------------------------------------------------
-- Flow OPERATORS
Flow {
    rule = funcHeatDisper,
    source = eachHeatGroundCell,
    target = neightOfEachHeatGroundCell
}
timer:run(50)