
-- @example Implementation of a simple firespread model using stocatisca data.
-- @image ssdFireSpread.bmp

import("ssd")
---------------------------------------------------------------
randomRate = Random{seed = 10}
randomBoolean = Random{true, false}
---------------------------------------------------------------
-- MODEL
cell = Cell{
    biomass = Random{0, 1, 2},
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
cs = CellularSpace{
    xdim = 50,
    instance = cell,
}
--ETAPA 2
cs:createNeighborhood{
    name = "neightHeat",
    --strategy = "vonneumann"
    strategy = "mxn",
    --m = 3,
    --selrule = false,
}
cellSample = cs:sample()
cellSample.state = "burning"
cellSample.heat = 1

summary = Cell{
    step = 0,
    Biomass_TOTAL_STEP0 = 0,
    Biomass_GROUND_TOTAL = 0,
    Biomass_GROUND_MAX = 0,
    Biomass_GROUND_MIN = 999,
    start = false
}

mapCsHeat = Map{
    title = "Heat Propagation",
    target = cs,
    select = "heat_state",
    value = {"NO_HEAT", "HEAT"},
    color = {"green", "red"}
}
chartHeat = Chart{
    target = cs,
    select = "heat_state",
    value = {"NO_HEAT", "HEAT"},
    color = {"green", "red"}
}
--ETAPA 2 FIM
timer = Timer{
    Event{start = 0,
        --period = 1,
        priority = 9,
        action = cs},
    --Event{action = mapCsBiomass_stade},
    --Event{action = chartsummary},
    Event{action = mapCsHeat},
    Event{action = chartHeat},
    --SUMMARY DATA MODEL EVENT
    Event{start = 0,
        --period = 1,
        priority = 9,
        action = function(event)
            --print("\n")
            print('=========================================================================================================== ')
            print("BIOMASS VALITDATION STEP: ".. event:getTime())
            summary.Biomass_GROUND_TOTAL = 0
            summary.step = event:getTime()
            --BIOMASS SUMMARY
            forEachCell(cs, function(cell)
                --if (cell.biomass > summary.Biomass_GROUND_MAX) then summary.Biomass_GROUND_MAX = cell.biomass end
                --if (cell.biomass < summary.Biomass_GROUND_MIN) then summary.Biomass_GROUND_MIN = cell.biomass end
                summary.Biomass_GROUND_TOTAL = summary.Biomass_GROUND_TOTAL + cell.biomass
            end)
            if (summary.start == false) then
                summary.Biomass_TOTAL_STEP0 = summary.Biomass_GROUND_TOTAL
                summary.start = true
            end
            print ('TIME:', summary.step ,'summary.Biomass_TOTAL_STEP0', summary.Biomass_TOTAL_STEP0)
            print ( 'summary.Biomass_GROUND_TOTAL:', summary.Biomass_GROUND_TOTAL)
            --print ( 'summary.Biomass_GROUND_MAX:', summary.Biomass_GROUND_MAX)
            --print ( 'summary.Biomass_GROUND_MIN:', summary.Biomass_GROUND_MIN)
            print ('----------------------------------------------------------------------------------------------------------')
            return true
        end},
    --SAVE MAP AT BEGGIN OF THE SIMULATION
    --[[
    Event{start = 1,
        period = 1,
        priority = 8,
        action = function(event)
            mapCsBiomass_stade:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            mapCsHeat:save("SAVES/"..EXPERIMENT_NAME.."/FS1M2_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 1) then return false end
        end},
    --SAVE MAP DURING THE SIMULATION
    Event{start = SIMULATION_PERIOD,
        period = SIMULATION_PERIOD,
        priority = 8,
        action = function(event)
            mapCsBiomass_stade:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            mapCsHeat:save("SAVES/"..EXPERIMENT_NAME.."/FS1M2_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end },
    --SAVE MAP AT END OF THE SIMULATION
    Event{start = SIMULATION_TIME,
        period = 1,
        priority = 8,
        action = function(event)
            chartsummary:save("SAVES/"..EXPERIMENT_NAME.."/GFS1C1_" .. event:getTime() .. ".bmp")
            chartHeat:save("SAVES/"..EXPERIMENT_NAME.."/GFS1C2_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end}
        ]]
}
--[[
GENERATE_MAPS{
    experimentName = "FlowFocalFireSpread", --chartsummary2:save("SAVES/"..EXPERIMENT_NAME.."/
    mapInitialTime = 1,
    mapFinalTime = 100,
    mapPeriod = 5,
    beggin_saveList = {mapCsHeat},
    during_saveList = {mapCsHeat},
    end_saveList = {chartHeat}
}
]]--
-------------------------------------------------------------------
-- CHANGE RATES AND RULES
heatdispersion_rate     = 0.99
funcHeatDisper = function (t,stock) return heatdispersion_rate * stock end
---------------------------------------------------------------
eachHeatGroundCell = Connector{
    collection = cs,
    attribute = "heat"
}
neightOfEachHeatGroundCell = Connector{
    collection = cs,
    attribute = "heat",
    neight = "neightHeat"
}
Flow{
    rule = funcHeatDisper,
    source = eachHeatGroundCell,
    target = neightOfEachHeatGroundCell,
    timer = timer
}
--ETAPA 2 FIM
timer:run(100)