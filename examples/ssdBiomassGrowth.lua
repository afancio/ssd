-- @example Implementation of a simple biomass growth model using stocatisca data. The biomass growth has a
--  constant growth rate of the biomass stored in each cell that changes the selected biomass stats of GRASS,
--  FOREST and DENSE_FOREST to GRASS, FOREST and DENSE_FOREST.
-- @image ssdBiomassGrowth.bmp

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    biomass = Random { 0, 1, 2 },
    biomass_state = "FOREST",
    heat = 0,
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
    end
}
cs = CellularSpace {
    xdim = 50,
    instance = cell,
}
mapCsBiomass_stade = Map {
    title = "Biomass",
    target = cs,
    select = "biomass_state",
    value = { "ROCK", "BURNED", "GRASS", "FOREST", "DENSE_FOREST" },
    color = { "gray", "brown", "yellow", "green", "darkGreen" }
}
summary = Cell {
    step = 0,
    Biomass_TOTAL_STEP0 = 0,
    Biomass_GROUND_TOTAL = 0,
    Biomass_GROUND_MAX = 0,
    Biomass_GROUND_MIN = 999,
    start = false
}
chartsummary = Chart {
    target = summary,
    width = 3,
    select = { "Biomass_GROUND_TOTAL" },
    --labels = {"Total Biomass"},
    style = "lines",
    color = { "green" },
    title = "Amount of biomass in the system"
}
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        start = 0,
        --period = 1,
        priority = 9,
        action = cs
    },
    Event { action = mapCsBiomass_stade },
    Event { action = chartsummary },
    --SUMMARY DATA MODEL EVENT
    Event {
        start = 0,
        --period = 1,
        priority = 9,
        action = function(event)
            print('=========================================================================================================== ')
            print("BIOMASS VALITDATION STEP: " .. event:getTime())
            summary.Biomass_GROUND_TOTAL = 0
            summary.step = event:getTime()
            --BIOMASS SUMMARY
            forEachCell(cs, function(cell)
                if (cell.biomass > summary.Biomass_GROUND_MAX) then summary.Biomass_GROUND_MAX = cell.biomass end
                if (cell.biomass < summary.Biomass_GROUND_MIN) then summary.Biomass_GROUND_MIN = cell.biomass end
                summary.Biomass_GROUND_TOTAL = summary.Biomass_GROUND_TOTAL + cell.biomass
            end)
            if (summary.start == false) then
                summary.Biomass_TOTAL_STEP0 = summary.Biomass_GROUND_TOTAL
                summary.start = true
            end
            print('TIME:', summary.step, 'summary.Biomass_TOTAL_STEP0', summary.Biomass_TOTAL_STEP0)
            print('summary.Biomass_GROUND_TOTAL:', summary.Biomass_GROUND_TOTAL)
            print('summary.Biomass_GROUND_MAX:', summary.Biomass_GROUND_MAX)
            print('summary.Biomass_GROUND_MIN:', summary.Biomass_GROUND_MIN)
            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    },
    --SAVE MAP AT BEGGIN OF THE SIMULATION
    --[[
    Event{start = 1,
        period = 1,
        priority = 8,
        action = function(event)
            mapCsBiomass_stade:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 1) then return false end
        end},
    --SAVE MAP DURING THE SIMULATION
    Event{start = SIMULATION_PERIOD,
        period = SIMULATION_PERIOD,
        priority = 8,
        action = function(event)
            mapCsBiomass_stade:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end },
    --SAVE MAP AT END OF THE SIMULATION
    Event{start = SIMULATION_TIME,
        period = 1,
        priority = 8,
        action = function(event)
            chartsummary:save("SAVES/"..EXPERIMENT_NAME.."/GFS1C1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end}
        ]]
}
--GENERATE_MAPS{
--    experimentName = "FlowBiomassgrowth", --chartsummary2:save("SAVES/"..EXPERIMENT_NAME.."/
--   mapInitialTime = 1,
--    mapFinalTime = 100,
--    mapPeriod = 5,
--    beggin_saveList = {mapCsBiomass_stade},
--    during_saveList = {mapCsBiomass_stade},
--    end_saveList = {chartsummary}
--}
-------------------------------------------------------------------
-- CHANGE RATES AND RULES
growthRate = 0.01
funcGrouwth = function(t, stock) return stock * growthRate end
---------------------------------------------------------------
-- ConnectorS
-- outOfSystem = Connector{
-- collection = nil,
-- }
eachBiomassGroundCell = Connector {
    collection = cs,
    attribute = "biomass"
}
---------------------------------------------------------------
-- Flow OPERATORS
-- ETAPA 1 - Biomass growth
BiomassGrowth = Flow {
    rule = funcGrouwth,
    --source = outOfSystem, --similar implementation
    source = nil,
    target = eachBiomassGroundCell
}
--print("#timer", #timer)
--print("#ssdGlobals.__ssdTimer", #ssdGlobals.__ssdTimer)

--Solução sendo testada -- não consigo fazer a sobrecarga
--[[

forEachOrderedElement(ssdGlobals.__ssdTimer:getEvents(), function(idx, value, mtype)
    if mtype == "Event" then
        timer:add(value)
    else
        incompatibleTypeError(idx, "Event", value)
    end
end)
ssdGlobals.__ssdTimer:clear()
ssdGlobals.__ssdTimer:reset()

print("#timer", #timer)
print("#ssdGlobals.__ssdTimer", #ssdGlobals.__ssdTimer)
]]

timer:run(60)
--timer:runTest()
--print("#timer", #timer)
--print("#ssdGlobals.__ssdTimer", #ssdGlobals.__ssdTimer)

----ssdGlobals = nil
--collectgarbage("collect")

--print ("ssdGlobals.___oldTimerFactory")
--print (ssdGlobals.___oldTimerFactory)
--print ("ssdGlobals.___userDefinedTimer")
--print (ssdGlobals.___userDefinedTimer)
--ssdGlobals.___oldTimerFactory = nil
--ssdGlobals.___userDefinedTimer = nil
--___userDefinedTimer:clear()
--___userDefinedTimer:reset()
--timer:clear()
--timer:reset()
--collectgarbage("collect")