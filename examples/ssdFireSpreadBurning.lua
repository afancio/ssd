-- @example Implementation of an integration of two simple models biomass growth and fire spread model using stochastic data.
-- A simple spread model that uses geospatial data. It simulates a fire in Parque Nacional das Emas, in Goias state, Brazil.
-- The biomass growth has a constant growth rate of the biomass stored in each cell that changes the selected biomass stats
-- of GRASS, FOREST and DENSE_FOREST to GRASS, FOREST and DENSE_FOREST.
-- Integrated to it, the fire spread model has two flows:
-- 1) Heat propagation that propagates from each cell to his neights (3x3 moore) that has state GRASS, FOREST and
--  DENSE_FOREST and a stochastic chance of burning.
-- 2) Biomass burns that change the biomass stats to BURNED.
-- @image ssdFireSpreadBiomassGrowAndBurning.bmp

import("ssd")
--dofile("../lua/Flow.lua") --Arquivo deve ser colocado no HOME
--dofile("../lua/Connector.lua") --Arquivo deve ser colocado no HOME
---------------------------------------------------------------
-- EXPERIMENT DEFINITIONS
--EXPERIMENT_NAME = "FIRE_SPREAD_STAGE4"
--SIMULATION_TIME = 45
--SIMULATION_PERIOD = 5
--DIM_CS = 50
randomRate = Random{seed = 1}
randomBoolean = Random{true, false}
---------------------------------------------------------------
-- MODEL
cell = Cell{
    biomass = Random{0.0, 1.0, 2.0},
    biomass_state = "FOREST",
    heat = 0,
    heat_state = "NO_HEAT",
    state = "forest",
    execute = function(self)
        if self.biomass <= 0.0 then
            self.biomass_state = "ROCK"
            --elseif self.biomass == 0 then
        elseif self.biomass > 0.0 and self.biomass <= 0.1 then
            self.biomass_state = "BURNED"
        elseif self.biomass > 0.0 and self.biomass <= 1 then
            self.biomass_state = "GRASS"
        elseif self.biomass > 2 and self.biomass <= 3 then
            self.biomass_state = "FOREST"
        elseif self.biomass > 3 then
            self.biomass_state = "DENSE_FOREST"
        end
        --ETAPA 2
        if self.heat == 0.0 then
            self.heat_state = "NO_HEAT"
        elseif self.heat > 0.0 then
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
    strategy = "vonneumann"}
cellSample = cs:sample()
cellSample.state = "burning"
cellSample.heat = 1
--ETAPA 2 FIM
--ETAPA 2
cs:createNeighborhood{
    name = "neighGroundBiomass",
    --strategy = "vonneumann",
    strategy = "mxn",
    --m = 3,
    --selrule = false,
    filter = function(cell, cell2)
        return cell2.biomass > 0.0
    end
}
--ETAPA 2 FIM
--ETAPA 3
--[[
    cellSample2 = cs:sample()
    cellSample2.state = "burning"
    cellSample2.heat = 1
    cellSample2.heat_state = "HEAT"
    cellSample3 = cs:sample()
    cellSample3.state = "burning"
    cellSample3.heat = 1
    cellSample3.heat_state = "HEAT"
    ]]--
fireBorder = Trajectory{
    target = cs,
    select = function(cell) return  cell.heat > 0
            and cell.biomass >=1
        and randomBoolean:sample() --usar para queimar aleatório -- Tiago que adicionou
    end
}
--ETAPA 3 FIM
mapCsBiomass_stade = Map{
    title = "Biomass",
    target = cs,
    select = "biomass_state",
    value = {"ROCK", "BURNED", "GRASS", "FOREST", "DENSE_FOREST"},
    color = {"gray","brown","yellow", "green", "darkGreen"}
}
summary = Cell{
    step = 0,
    Biomass_TOTAL_STEP0 = 0,
    Biomass_GROUND_TOTAL = 0,
    Biomass_GROUND_MAX = 0,
    Biomass_GROUND_MIN = 999,
    start = false
}
chartsummary = Chart{
    target = summary,
    width = 3,
    select = {"Biomass_GROUND_TOTAL"},
    --labels = {"Total Biomass"},
    style = "lines",
    color = {"green"},
    title = "Amount of biomass in the system"
}
--ETAPA 2
--chartHeat = Chart{
--    target = cs,
--    select = "heat_state",
--    value = {"NO_HEAT", "HEAT"},
--    color = {"green", "red"}
--}
--mapCsHeat = Map{
--    title = "Heat Propagation",
--    target = cs,
--    select = "heat_state",
--    value = {"NO_HEAT", "HEAT"},
--    color = {"green", "red"}
--}
--ETAPA 2 FIM
timer = Timer{
    Event{start = 0,
        --period = 1,
        priority = 9,
        action = cs},
    Event{action = mapCsBiomass_stade},
    Event{action = chartsummary},
    --Event{action = mapCsHeat},
    --Event{action = chartHeat},
    --SUMMARY DATA MODEL EVENT
    --ETAPA 3
    Event{--	start = 1,
        --period = 1,
        --priority = 0,
        action = function(event)
            --print('Fire BOrder', fireBorder)
            --if (#fireBorder.cells > 0) then
                fireBorder:rebuild()
                fireBorder:filter()
            --end

            if (event:getTime() >= 1000) then
                return false
            end
        end},
    --ETAPA 3 FIM
    Event{start = 0,
        --period = 1,
        priority = 9,
        action = function(event)
            --print("\n")
            print('========================================================================================= ')
            print("BIOMASS VALITDATION STEP: ".. event:getTime())
            summary.Biomass_GROUND_TOTAL = 0
            summary.step = event:getTime()
            --BIOMASS SUMMARY
            forEachCell(cs, function(cell)
                if (cell.biomass > summary.Biomass_GROUND_MAX) then
                    summary.Biomass_GROUND_MAX = cell.biomass
                end
                if (cell.biomass < summary.Biomass_GROUND_MIN) then
                    summary.Biomass_GROUND_MIN = cell.biomass
                end
                summary.Biomass_GROUND_TOTAL = summary.Biomass_GROUND_TOTAL + cell.biomass
            end)
            if (summary.start == false) then
                summary.Biomass_TOTAL_STEP0 = summary.Biomass_GROUND_TOTAL
                summary.start = true
            end
            print ('TIME:', summary.step ,'summary.Biomass_TOTAL_STEP0',
                summary.Biomass_TOTAL_STEP0)
            print ( 'summary.Biomass_GROUND_TOTAL:', summary.Biomass_GROUND_TOTAL)
            print ( 'summary.Biomass_GROUND_MAX:', summary.Biomass_GROUND_MAX)
            print ( 'summary.Biomass_GROUND_MIN:', summary.Biomass_GROUND_MIN)
            print ('-----------------------------------------------------------------------------------------')

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
        ]]--
}

--[[
GENERATE_MAPS{
    experimentName = "FlowZonalFireSpreadAndBiomassGrowAndBurning", --chartsummary2:save("SAVES/"..EXPERIMENT_NAME.."/
    mapInitialTime = 1,
    mapFinalTime = 100,
    mapPeriod = 5,
    beggin_saveList = {mapCsBiomass_stade},
    during_saveList = {mapCsBiomass_stade},
    end_saveList = {chartsummary}
}
]]--
-------------------------------------------------------------------
-- CHANGE RATES AND RULES
growthRate     = 0.01
heatdispersion_rate     = 0.99
biomassBurnRate     = 1
funcGrouwth = function (t,stock) return stock * growthRate end
funcHeatDisper = function (t,stock)	return heatdispersion_rate * stock end
funcBiomassBurn = function (t,stock) return biomassBurnRate * stock end
---------------------------------------------------------------
-- ConnectorS
--ETAPA 1
outOfSystem = Connector{
    collection = nil,
}
eachBiomassGroundCell = Connector{
    collection = cs,
    attribute = "biomass"
}
--ETAPA 2
eachHeatGroundCell = Connector{
    collection = cs,
    attribute = "heat"
}
--ETAPA 2 FIM
--ETAPA 2_2
neightOfEachHeatGroundCell = Connector{
    collection = cs,
    attribute = "heat",
    neight = "neighGroundBiomass"
}
--ETAPA 2_2 FIM
--ETAPA 3
eachHeatFireborderTrajectory = Connector{
    collection = fireBorder,
    attribute = "biomass"
}
--ETAPA 3 FIM
---------------------------------------------------------------
-- Flow OPERATORS
--ETAPA 1 - Biomass Grow
Flow{
    rule = funcGrouwth,
    source = outOfSystem,
    target = eachBiomassGroundCell,
    timer = timer
}
--ETAPA 2 - Focal Fire Spread
Flow{
    rule = funcHeatDisper,
    source = eachHeatGroundCell,
    target = neightOfEachHeatGroundCell,
    timer = timer
}
--ETAPA 2 FIM
--ETAPA 3 - Condicional Focal Fire Spread adn Biomass Burn
Flow{
    rule = funcBiomassBurn,
    source = eachHeatFireborderTrajectory,
    target = outOfSystem,
    timer = timer
}
--ETAPA 3 FIM
timer:run(100)