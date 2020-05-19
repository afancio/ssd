-- @example Based on: TerraME Prey-Predator dynamic model based on differental equations.
-- Especially for these model que use the "delta = 0.015625" flow pharameter.
-- It changes de interval off integration and alow a better vizualization of predator prey model.
-- Spatial Modelation: Each predator in a cellular space preadates and grow based on the preys
-- of cells in the neighborhood ("neight3x3")
-- of the spatially corresponding cell of another cellular space.
-- @image ssdPredatorPreyFeedbacklLoopFocalLocalRandomField.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- EXPERIMENT DEFINITIONS
-- timeStep = 1 / 64 --1/16--1/512--1/256--0.03125 -- See the effects of 0.25, 0.125, 0.0625, and 0.03125
PREYS = 20 --100
PREDATORS = 40 --10
delta = 1 / 64 --1/32--1/16
--delta = 0.015625--0.03125--0,0625

totalInitialStockCs = PREYS * 100
random = Random()
random:reSeed(123456789)
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    preys = 0, -- PREYS, --Uncoment to unifirm fiel
    predators = PREDATORS,
    preysDeath = 0,
    predatorsDeath = 0
}

csField = CellularSpace {
    xdim = 10,
    instance = cell
}

--Coment to have a uniforme field
while totalInitialStockCs > 0 do
    forEachCell(csField, function(cell)
        local change = random:number()
        if (totalInitialStockCs > change) then
            totalInitialStockCs = totalInitialStockCs - change
        else
            change = totalInitialStockCs
            totalInitialStockCs = 0
        end
        --print (change)
        cell.preys = cell.preys + change
    end)
end

--Exchange values of Random cs
for i = 10, 1, -1
do
    cellSample = csField:sample()
    cellSample2 = csField:sample()
    cellSample2.preys = cellSample2.preys + cellSample.preys
    cellSample.preys = 0
end
--coment until here


csField:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn",
    wrap = true,
    --self = true,
    filter = function(cell)
        return cell.preys > 0
    end
}

mapPreys = Map {
    target = csField,
    select = "preys",
    min = 0,
    max = 108,
    slices = 10,
    color = "Greens"
}

mapPredators = Map {
    target = csField,
    select = "predators",
    min = 0,
    max = 133,
    slices = 10,
    color = "Reds"
}

summary = Cell {
    step = 0,
    inititalPreys = 0,
    totalPreys = 0,
    maxPreysInCell = 0,
    minPreysInCell = 8051690,
    inititalPredators = 0,
    totalPredators = 0,
    maxPredatorsInCell = 0,
    minPredatorsInCell = 8051690,
    densityPreyPredator = 0,
    totalPredators500 = 0,
    totalPreys500 = 0,
    start = false
}
chartsummary = Chart {
    target = summary,
    width = 3,
    select = { "totalPreys", "totalPredators", "densityPreyPredator" },
    label = { "totalPreys", "totalPredators", "densityPreyPredator" },
    style = "lines",
    color = { "green", "red", "blue" },
    title = "Amount of preys and preators in the feild (CellularSpace)"
}

chartPhaseSpace = Chart {
    target = summary,
    width = 3,
    xAxis = "totalPreys",
    select = { "totalPredators" },
    label = { "totalPredators" },
    style = "lines",
    color = { "red" },
    title = "Phase space"
}

chartPhaseSpaceNew = Chart {
    target = summary,
    width = 3,
    xAxis = "totalPreys500",
    select = { "totalPredators500" },
    label = { "totalPredators500" },
    style = "lines",
    color = { "red" },
    title = "Phase space start 500"
}
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        --start = 0,
        action = function()
            csField:synchronize()
            return false
        end
    },
    Event { period = delta, action = csField },
    Event { period = delta, action = mapPreys },
    Event { period = delta, action = mapPredators },
    Event { period = delta, action = chartsummary },
    Event { period = delta, action = chartPhaseSpace },
    Event { period = delta, action = chartPhaseSpaceNew },


    --SUMMARY DATA MODEL EVENT
    Event {
        period = delta,
        --start = 0,
        ----period = 1,
        priority = 9,
        action = function(event)
            --            print('=========================================================================================================== ')
            print("PREY PREDATOR VALITDATION STEP: " .. event:getTime())
            summary.totalPreys = 0
            summary.totalPredators = 0
            summary.step = event:getTime()
            --csField SUMMARY
            forEachCell(csField, function(cell)
                if (cell.preys > summary.maxPreysInCell) then summary.maxPreysInCell = cell.preys end
                if (cell.preys < summary.minPreysInCell) then summary.minPreysInCell = cell.preys end
                summary.totalPreys = summary.totalPreys + cell.preys
                if (cell.predators > summary.maxPredatorsInCell) then summary.maxPredatorsInCell = cell.predators end
                if (cell.predators < summary.minPredatorsInCell) then summary.minPredatorsInCell = cell.predators end
                summary.totalPredators = summary.totalPredators + cell.predators
            end)
            if (summary.start == false) then
                summary.inititalPreys = summary.totalPreys
                summary.inititalPredators = summary.totalPredators
                summary.start = true
            end
            if (event:getTime() > 500) then
                summary.totalPredators500 = summary.totalPredators
                summary.totalPreys500 = summary.totalPreys
            end

            summary.densityPreyPredator = (summary.totalPreys / summary.totalPredators) * 2000
            --print('TIME:', summary.step, 'summary.inititalGroundcsField', summary.inititalGroundcsField)
            print('preys:     initial:', summary.inititalPreys, 'total: ', summary.totalPreys, 'MAX: ', summary.maxPreysInCell)
            print('predators: initial:', summary.inititalPredators, 'total: ', summary.totalPredators, 'MAX: ', summary.maxPredatorsInCell)
            --
            --            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    },
    Event {
        period = 10,
        action = function(event)
            mapPreys:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPreys" .. event:getTime() .. ".bmp")
            mapPredators:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPredators" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 100) then return false
            end
        end
    },
    Event {
        period = 50,
        action = function(event)
            mapPreys:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPreys" .. event:getTime() .. ".bmp")
            mapPredators:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPredators" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 2000) then return false
            end
        end
    },
    Event {
        --start = 10,
        period = 100,
        action = function(event)
            --mapPreys:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPreys-" .. event:getTime() .. ".bmp")
            --mapPredators:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/mapPredators" .. event:getTime() .. ".bmp")
            chartsummary:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/chartsummary" .. event:getTime() .. ".bmp")
            chartPhaseSpace:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/chartPhaseSpace" .. event:getTime() .. ".bmp")
            chartPhaseSpaceNew:save("SAVES/ssdPredatorPreyFeedbacklLoopFocalLocalRandomField/chartPhaseSpaceNew" .. event:getTime() .. ".bmp")
            if (event:getTime() >= 2000) then return false end
        end
    },
}



---------------------------------------------------------------
-- INTEGRATION FUNCTION AND CHANGE RATES
---------------------------------------------------------------

---------------------------------------------------------------
-- Connectors and Flow OPERATORS
csField_local_prey = Connector {
    collection = csField,
    attribute = "preys"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
birthPreyRate = 0.2
funcBirthPrey = function(t, sourcecell, targetCell) return birthPreyRate * targetCell.preys end
---------------------------------------------------------------
-- Flow OPERATORS
BirthPrey = Flow {
    delta = delta,
    rule = funcBirthPrey,
    source = nil,
    target = csField_local_prey
}

--Flow(funcPredation, 1,  finalTime, timeStep,  csField, "preys", nil,  csField, "preysDeath", nil, model)
---------------------------------------------------------------
-- Connectors
csField_local_preysPredators = Connector {
    collection = csField,
    attribute = "preys",
    --secundaryAttribute = "predators",
    neight = "neight3x3"
}
csField_local_preysDeath = Connector {
    collection = csField,
    attribute = "preysDeath"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
predationRate = 0.01 / 9 -- death prey rate
funcPredation = function(t, sourcecell, targetCell, neighborSourceCell)
    return predationRate * neighborSourceCell.preys * sourcecell.predators
end
---------------------------------------------------------------
-- Flow OPERATORS
Predation = Flow {
    delta = delta,
    rule = funcPredation,
    source = csField_local_preysPredators,
    target = csField_local_preysDeath
}
--Flow(funcBirthPredatorPerPrey, 1,  finalTime, timeStep, nil, nil, nil,  csField, "predators", nil, model)
---------------------------------------------------------------
-- Connectors and Flow OPERATORS
csField_local_predatorsPreys = Connector {
    collection = csField,
    attribute = "predators",
    --secundaryAttribute = "preys"
    neight = "neight3x3"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
birthPredatorPerPreyRate = 0.01 / 9 -- birth predator rate
--(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell,centralSourceCell, centralTargetCell)
funcBirthPredatorPerPrey = function(t, sourcecell, targetCell, neighborSourceCell, neighborTargetCell)
    return birthPredatorPerPreyRate * targetCell.predators * neighborTargetCell.preys
end
---------------------------------------------------------------
-- Flow OPERATORS
BirthPredatorPerPrey = Flow {
    delta = delta,
    rule = funcBirthPredatorPerPrey,
    source = nil,
    target = csField_local_predatorsPreys
}

--Flow(funcDeathPredator, 1,  finalTime, timeStep,  csField, "predators", nil,  csField, "predatorsDeath", nil, model)
---------------------------------------------------------------
-- Connectors
csField_local_predators = Connector {
    collection = csField,
    attribute = "predators"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
deathPredatorRate = 0.1 -- death prey rate
funcDeathPredator = function(t, sourceCell) return deathPredatorRate * sourceCell.predators end
---------------------------------------------------------------
-- Flow OPERATORS
DeathPredator = Flow {
    delta = delta,
    rule = funcDeathPredator,
    source = csField_local_predators,
    target = nil
}

timer:run(200)


--ssdGlobals = nil

--[[ ORIGINAL MODEL

-- ##### TerraLAB - www.terralab.ufop.br
-- Computer Science Departament, Federal Univeristy of Ouro Preto
-- TerraME Prey-Predator dynamic model based on differental equations
-- Tiago Garcia de Senna Carneiro - 07/2012
-------------
-- Lesson: Observe the phase space. You can use it to choose the proper integration method.
-------------

--#PARAMETERS
timeStep =  0.5 -- See the effects of 0.25, 0.125, 0.0625, and 0.03125
birthPreyRate = 0.2
predationRate = 0.01 -- death prey rate
birthPredatorPerPreyRate = 0.01 -- birth predator rate
deathPredatorRate =  0.1 -- death prey rate

--#Integration Method (please, vary it: ("integrationHeun"and 0.25), "integrationRungeKutta" and 0.03125, "integrationEuler" and 0.03125)
INTEGRATION_METHOD =  integrationEuler


--#BEHAVIORAL MODEL
ag = Agent{ preys = 100, predators = 10 }

--#OBSERVERS
 Observer{ subject = ag, type = "chart", attributes={"predators"}, xAxis = "preys",
        title="phase space", curveLabels={"preys x predators"}, xLabel="#preys", yLabel="#predators" }

Observer{ subject = ag, type = "chart",attributes={"preys","predators"},
        title="Preys x Time", curveLabels={"preys", "predators"}, yLabel="#preys", xLabel="time" }


--#RULES
for t = 0, 10000, timeStep do

  ag.preys, ag.predators = d{
    {
      function( t, q )
        return q[1]*birthPreyRate - q[1]*q[2]*predationRate
      end ,

      function( t, q )
        return q[2]*q[1]*birthPredatorPerPreyRate - q[2]*deathPredatorRate
      end
    },
    { ag.preys, ag.predators },
    0, timeStep, 0.03125
  }

  print(t)
  ag:notify(t)

end

print("Model outcome: ", ag.preys, ag.predators )

]]


