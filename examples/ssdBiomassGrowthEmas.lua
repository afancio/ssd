-- @example Implementation of a simple Biomass Growth  model using a Emas map data.
-- The data comes from TerraME firespread model that was proposed by Almeida, Rodolfo M., et al. (in portuguese)
--  'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de
--  Geoinfoamatica (2008).
-- A simple spread model that uses geospatial data. It simulates a fire in Parque Nacional das Emas, in Goias state,
-- Brazil. The biomass growth has a constant growth rate of the biomass stored in each cell that changes the
-- biomass stats to BIOMASS1, BIOMASS2, BIOMASS3, BIOMASS4 and then BIOMASS5.
-- @image ssdBiomassGrowthEmas.png

import("ssd")

-- automaton states
NODATA = 0
BIOMASS1 = 1
BIOMASS2 = 2
BIOMASS3 = 3
BIOMASS4 = 4
BIOMASS5 = 5
RIVER = 6
FIREBREAK = 7
BURNING = 8
BURNED = 9

-- probability matrix according to the levels of forest
-- I[X][Y] is the probability of a burning cell with BIOMASSX
-- to spread fire to a cell with BIOMASSY
I = {
    { 0.100, 0.250, 0.261, 0.273, 0.285 },
    { 0.113, 0.253, 0.264, 0.276, 0.288 },
    { 0.116, 0.256, 0.267, 0.279, 0.291 },
    { 0.119, 0.259, 0.270, 0.282, 0.294 },
    { 0.122, 0.262, 0.273, 0.285, 0.297 }
}

randomObj = Random { seed = 800 }

---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
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
cs = CellularSpace {
    file = filePath("emas.shp"),
    instance = cell,
    as = {
        accumulation = "maxcover" -- test also with "mincover"
    }
}

map2 = Map {
    target = cs,
    select = "state2",
    color = { "white", "lightGreen", "lightGreen", "green", "darkGreen", "darkGreen", "blue", "brown", "red", "black" },
    value = { NODATA, BIOMASS1, BIOMASS2, BIOMASS3, BIOMASS4, BIOMASS5, RIVER, FIREBREAK, BURNING, BURNED },
    label = { "NoData", "Biomass1", "Biomass2", "Biomass3", "Biomass4", "Biomass5", "River", "Firebreak", "Burning", "Burned" }
}

cs:createNeighborhood()

forest = Trajectory {
    target = cs,
    select = function(cell) return (cell.state >= BIOMASS1 and cell.state < BIOMASS5) end
}
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            forest:execute()
            forest:rebuild()
            cs:execute()
        end
    },
    Event { action = map2 },
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
growthRate = 0.1
funcGrouwth = function(t, stock) return growthRate end
---------------------------------------------------------------
-- ConnectorS
outOfSystem = Connector {
    collection = nil,
}
eachBiomassGroundCell = Connector {
    collection = forest,
    attribute = "state"
}
---------------------------------------------------------------
-- Flow OPERATORS
Flow {
    rule = funcGrouwth,
    source = outOfSystem,
    target = eachBiomassGroundCell
}
timer:run(100)