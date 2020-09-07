-- @example Implementation of an integration of two simple models biomass growth and fire spread model using Emas map data.
-- The data comes from TerraME firespread model that was proposed by Almeida, Rodolfo M., et al. (in portuguese)
--  'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de
--  Geoinfoamatica (2008).
-- A simple spread model that uses geospatial data. It simulates a fire in Parque Nacional das Emas, in Goias state, Brazil.
-- The biomass growth has a constant growth rate of the biomass stored in each cell that changes the biomass stats
--  to BIOMASS1, BIOMASS2, BIOMASS3, BIOMASS4 and then BIOMASS5.
-- Integrated to it, the fire spread model has two flows:
-- 1) Heat propagation that propagates from each cell to his neights (3x3 moore) that has state BIOMASS(1, 2, 3, 4 and 5).
-- 2) Biomass burn that changes the biomass stats to BURNING and then BURNED.
-- @image ssdFireSpreadEmas.bmp

--import("ssd")
dofile("../lua/Flow.lua")
dofile("../lua/Connector.lua")
dofile("../lua/Timer.lua")
dofile("../lua/GENERATE_MAPS.lua")

-- automaton states
NODATA = 0
BURNED = 0.01
BURNING = 0.1
BIOMASS1 = 1
BIOMASS2 = 2
BIOMASS3 = 3
BIOMASS4 = 4
BIOMASS5 = 5
RIVER = 6
FIREBREAK = 7


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

---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    state2 = 0,
    heat = 0,
    heat_state = "NO_HEAT",
    execute = function(cell)
        if cell.state > NODATA and cell.state < BURNING then
            cell.state2 = BURNED
        elseif cell.state >= BURNING and cell.state < BIOMASS1 then
            cell.state2 = BURNING
        elseif cell.state >= BIOMASS1 and cell.state < BIOMASS2 then
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

        if cell.heat == 0.0 then
            cell.heat_state = "NO_HEAT"
        elseif cell.heat > 0.0 then
            cell.heat_state = "HEAT"
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

-- cells initially burning
-- note that the y values are inverted
cs:get(35, cs.yMax - 82).state = BURNING
cs:get(35, cs.yMax - 82).heat = 1
cs:get(19, cs.yMax - 62).state = BURNING
cs:get(19, cs.yMax - 62).heat = 1

--mapCsHeat = Map {
--    title = "Heat Propagation",
--    target = cs,
--    select = "heat_state",
--    value = { "NO_HEAT", "HEAT" },
--    color = { "green", "red" }
--}

map2 = Map {
    title = "Biomass state",
    target = cs,
    select = "state2",
    color = { "white", "lightGreen", "lightGreen", "green", "darkGreen", "darkGreen", "blue", "brown", "red", "black" },
    value = { NODATA, BIOMASS1, BIOMASS2, BIOMASS3, BIOMASS4, BIOMASS5, RIVER, FIREBREAK, BURNING, BURNED },
    label = { "NoData", "Biomass1", "Biomass2", "Biomass3", "Biomass4", "Biomass5", "River", "Firebreak", "Burning", "Burned" }
}

cs:createNeighborhood()

cs:createNeighborhood {
    name = "neighGroundBiomass",
    --strategy = "moore",
    --strategy = "vonneumann",
    strategy = "mxn",
    filter = function(cell, cell2)
        return cell2.state >= BIOMASS1 and cell2.state < RIVER
    end
}

forest = Trajectory {
    target = cs,
    select = function(cell) return ((cell.state >= BIOMASS1) and (cell.state < BIOMASS5)) end
}

fireBorder = Trajectory {
    target = cs,
    select = function(cell) return cell.heat > 0 end
}

---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            fireBorder:execute()
            fireBorder:rebuild()
            forest:execute()
            forest:rebuild()
            cs:execute()
        end
    },
    Event { action = map2 },
    --SAVE MAP DURING THE SIMULATION
    --    Event {start = 1,
    --        period = 1,
    --        priority = 8,
    --        action = function(event)
    --            map2:save("SAVES/FS1M1_" .. event:getTime() .. ".bmp")
    --            if (event:getTime() >= 60) then return false end
    --        end
    --    },
}

GENERATE_MAPS{
	experimentName = "FIRESPREADEMAS", --chartsummary2:save("SAVES/"..EXPERIMENT_NAME.."/
	mapInitialTime = 1,
	mapFinalTime = 50,
	mapPeriod = 1,
	beggin_saveList = {map2},
	during_saveList = {map2},
	end_saveList = {map2}
}

---------------------------------------------------------------
-- Connectors and Flow OPERATORS
outOfSystem = Connector {
    collection = nil,
}
eachBiomassCell_Trajectory = Connector {
    collection = forest,
    attribute = "state"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
growthRate = 0.1
funcGrouwth = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return growthRate * targetCell.state
end
---------------------------------------------------------------
-- Flow OPERATORS
Flow {
    rule = funcGrouwth,
    source = outOfSystem,
    target = eachBiomassCell_Trajectory
}
--ETAPA 2 - Focal Fire Spread
---------------------------------------------------------------
-- Connectors and Flow OPERATORS
eachHeatGroundCell = Connector {
    collection = cs,
    attribute = "heat"
}
neightOfEachHeatGroundCell = Connector {
    collection = cs,
    attribute = "heat",
    neight = "neighGroundBiomass"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
heatdispersion_rate = 0.99
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
--ETAPA 2 FIM
--ETAPA 3 - Condicional Focal Fire Spread adn Biomass Burn
---------------------------------------------------------------
-- Connectors and Flow OPERATORS
eachStateFireborderTrajectory = Connector {
    collection = fireBorder,
    attribute = "state"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
biomassBurnRate = 0.9
--funcBiomassBurn = function(t, stock) return biomassBurnRate end
funcBiomassBurn = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return biomassBurnRate * sourceCell.state
end
---------------------------------------------------------------
-- Flow OPERATORS
Flow {
    rule = funcBiomassBurn,
    source = eachStateFireborderTrajectory,
    target = nil
}
timer:run(50)
--ssdGlobals = nil