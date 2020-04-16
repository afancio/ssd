-- @example Implementation of a simple firespread model using a Emas map data.

import("ssd")
--dofile("../lua/Flow.lua") --Arquivo deve ser colocado no HOME
--dofile("../lua/Connector.lua") --Arquivo deve ser colocado no HOME

---------------------------------------------------------------
-- EXPERIMENT DEFINITIONS
--EXPERIMENT_NAME = "FIRE_SPREAD_EMAS_STAGE1"
--SIMULATION_TIME = 35
--SIMULATION_PERIOD = 5
--DIM_CS = 50
--randomRate = Random{seed = 1}
--randomBoolean = Random{true, false }

-- automaton states
NODATA     = 0
BIOMASS1   = 1
BIOMASS2   = 2
BIOMASS3   = 3
BIOMASS4   = 4
BIOMASS5   = 5
RIVER      = 6
FIREBREAK  = 7
BURNING    = 8
BURNED     = 9

-- probability matrix according to the levels of forest
-- I[X][Y] is the probability of a burning cell with BIOMASSX
-- to spread fire to a cell with BIOMASSY
I =	{{0.100, 0.250, 0.261, 0.273, 0.285},
    {0.113, 0.253, 0.264, 0.276, 0.288},
    {0.116, 0.256, 0.267, 0.279, 0.291},
    {0.119, 0.259, 0.270, 0.282, 0.294},
    {0.122, 0.262, 0.273, 0.285, 0.297}}

randomObj = Random{seed = 800 }

---------------------------------------------------------------
-- PARAMETER
---------------------------------------------------------------
growthRate     = 0.1
---------------------------------------------------------------
-- CHANGE RATES AND RULES
---------------------------------------------------------------
--ETAPA 1
funcGrouwth = function (t,stock) return growthRate end
---------------------------------------------------------------
-- MODEL
--[[        cell = Cell{
            biomass = Random{0, 1, 2},
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
        cs = CellularSpace{
            xdim = dim,
            instance = cell,
        }]]

cell = Cell{
    state2 = 0,
    execute = function(cell)
        if cell.state >= BIOMASS1 and cell.state < BIOMASS2 then
            cell.state2 = BIOMASS1
        elseif cell.state >= BIOMASS2 and cell.state < BIOMASS3 then
            cell.state2 = BIOMASS2
        elseif cell.state >= BIOMASS3 and cell.state < BIOMASS4 then
            cell.state2 = BIOMASS3
        elseif cell.state >= BIOMASS4 and cell.state < BIOMASS5 then
            cell.state2 = BIOMASS4
        elseif cell.state >= BIOMASS5 and cell.state < RIVER then
            cell.state2 = BIOMASS5
        else cell.state2 = cell.state
        end
        --[[forEachNeighbor(cell, function(neigh)
            if neigh.state <= BIOMASS5 then
                local p = randomObj:number()
                if p < I[cell.accumulation][neigh.accumulation] then
                    neigh.state = BURNING
                end
            end
        end)

        cell.state = BURNED]]
    end,
    init = function(cell)
        if cell.firebreak == 1 then
            cell.state = FIREBREAK
        elseif cell.river == 1 then
            cell.state = RIVER
        else
            cell.state = cell.accumulation
        end
    end
}
cs = CellularSpace{
    file = filePath("emas.shp"),
    instance = cell,
    as = {
        accumulation = "maxcover" -- test also with "mincover"
    }
}

-- cells initially burning
-- note that the y values are inverted
-- using the maximum y (107)
--cs:get(35, cs.yMax - 82).state = BURNING
--cs:get(19, cs.yMax - 62).state = BURNING

--[[
    map = Map{
        target = cs,
        select = "state",
        color = {"white",  "lightGreen", "lightGreen", "green",    "darkGreen", "darkGreen", "blue",  "brown",     "red",     "black"},
        value = {NODATA,   BIOMASS1,     BIOMASS2,     BIOMASS3,   BIOMASS4,    BIOMASS5,    RIVER,   FIREBREAK,   BURNING,   BURNED},
        label = {"NoData", "Biomass1",   "Biomass2",   "Biomass3", "Biomass4",  "Biomass5",  "River", "Firebreak", "Burning", "Burned"}
    }
    ]]

map2 = Map{
    target = cs,
    select = "state2",
    color = {"white",  "lightGreen", "lightGreen", "green",    "darkGreen", "darkGreen", "blue",  "brown",     "red",     "black"},
    value = {NODATA,   BIOMASS1,     BIOMASS2,     BIOMASS3,   BIOMASS4,    BIOMASS5,    RIVER,   FIREBREAK,   BURNING,   BURNED},
    label = {"NoData", "Biomass1",   "Biomass2",   "Biomass3", "Biomass4",  "Biomass5",  "River", "Firebreak", "Burning", "Burned"}
}


--[[mapCsBiomass_stade = Map{
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
    select = {"Biomass_TOTAL_STEP0","Biomass_GROUND_TOTAL"},
    labels = {"Initial Biomass", "Total Biomass"},
    style = "lines",
    color = {"gray", "green"},
    title = "Amount of biomass in the system"
}
timer = Timer{
    Event{start = 0,
        period = 1,
        priority = 9,
        action = cs},
    Event{action = mapCsBiomass_stade},
    Event{action = chartsummary},
    --SUMMARY DATA MODEL EVENT
    Event{start = 0,
        period = 1,
        priority = 9,
        action = function(event)
            print('=========================================================================================================== ')
            print("BIOMASS VALITDATION STEP: ".. event:getTime())
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
            print ('TIME:', summary.step ,'summary.Biomass_TOTAL_STEP0', summary.Biomass_TOTAL_STEP0)
            print ( 'summary.Biomass_GROUND_TOTAL:', summary.Biomass_GROUND_TOTAL)
            print ( 'summary.Biomass_GROUND_MAX:', summary.Biomass_GROUND_MAX)
            print ( 'summary.Biomass_GROUND_MIN:', summary.Biomass_GROUND_MIN)
            print ('----------------------------------------------------------------------------------------------------------')
            return true
        end},

}]]

cs:createNeighborhood()

itrule = Trajectory{
    target = cs,
    select = function(cell) return cell.state == BURNING end
}

forest = Trajectory{
    target = cs,
    select = function(cell) return (cell.state >= BIOMASS1 and cell.state < BIOMASS5) end
}

timer = Timer{
    Event{action = function()
        --itF:execute()
        --itF:rebuild()
        forest:execute()
        forest:rebuild()
        cs:execute()
    end},
    --Event{action = map},
    Event{action = map2},

    --SAVE MAP AT BEGGIN OF THE SIMULATION
--[[    Event{--start = 1,
        --period = 1,
        priority = 8,
        action = function(event)
            map2:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 1) then return false end
        end},
    --SAVE MAP DURING THE SIMULATION
    Event{start = SIMULATION_PERIOD,
        period = SIMULATION_PERIOD,
        priority = 8,
        action = function(event)
            --map2:save("SAVES/"..EXPERIMENT_NAME.."/FS1M1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end },
    --SAVE MAP AT END OF THE SIMULATION
    Event{start = SIMULATION_TIME,
        --period = 1,
        priority = 8,
        action = function(event)
            --chartsummary:save("SAVES/"..EXPERIMENT_NAME.."/GFS1C1_" .. event:getTime() .. ".bmp")
            if (event:getTime() >= SIMULATION_TIME) then return false end
        end}]]
}

---------------------------------------------------------------
-- ConnectorS
--ETAPA 1
outOfSystem = Connector{
    collection = nil,
}
eachBiomassGroundCell = Connector{
    collection = forest,
    attribute = "state"
}
---------------------------------------------------------------
-- Flow OPERATORS
--ETAPA 1 - Biomass Grow
Flow{
    rule = funcGrouwth,
    source = outOfSystem,
    target = eachBiomassGroundCell,
    timer = timer
}
timer:run(100)