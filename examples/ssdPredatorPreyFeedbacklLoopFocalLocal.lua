-- @example Based on: TerraME Prey-Predator dynamic model based on differental equations.
-- Especially for these model que use the "delta = 0.015625" flow pharameter.
-- It changes de interval off integration and alow a better vizualization of predator prey model.
-- Spatial Modelation: Each predator in a cellular space preadates and grow based on the preys
-- of cells in the neighborhood ("neight3x3")
-- of the spatially corresponding cell of another cellular space.
-- @image ssdPredatorPreyFeedbacklLoopFocalLocal.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- EXPERIMENT DEFINITIONS
--timeStep = 1 / 64 --1/16--1/512--1/256--0.03125 -- See the effects of 0.25, 0.125, 0.0625, and 0.03125
PREYS = 100
PREDATORS = 10
--delta = 1/64--1/32--1/16
delta = 0.015625--0.03125--0,0625

totalInitialStockCs = PREYS*100
random = Random()
random:reSeed(123456789)
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    preys = PREYS,  --0, -- PREYS, --Uncoment to unifirm fiel
    predators = PREDATORS,
    preysDeath = 0,
    predatorsDeath = 0
}

csField = CellularSpace {
    xdim = 10,
    instance = cell
}

--Coment to have a uniforme field
--[[
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
]]
--coment until here


csField:createNeighborhood{
    name = "neight3x3",
    strategy = "mxn",
    wrap = true,
    --self = true,
    filter = function(cell)
        return cell.preys > 0
    end
}

map = Map {
    target = csField,
    select = "preys",
    min = 0,
    max = 805,
    slices = 10,
    color = "Greens"
}

map2 = Map {
    target = csField,
    select = "predators",
    min = 0,
    max = 1011,
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
    start = false
}
chartsummary = Chart {
    target = summary,
    width = 3,
    select = { "totalPreys", "totalPredators" },
    label = { "totalPreys", "totalPredators" },
    style = "lines",
    color = { "green", "red" },
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
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            csField:synchronize()
            return false
        end
    },
    Event { period = delta, action = csField },
    Event { period = delta, action = map },
    Event { period = delta, action = map2 },
    Event { period = delta, action = chartsummary },
    Event { period = delta, action = chartPhaseSpace },


    --SUMMARY DATA MODEL EVENT
    Event {
        period = delta,
        --start = 0,
        ----period = 1,
        priority = 9,
        action = function(event)
            print('=========================================================================================================== ')
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
            print('TIME:', summary.step, 'summary.inititalGroundcsField', summary.inititalGroundcsField)
            print('preys:     initial:', summary.inititalPreys,     'total: ', summary.totalPreys,      'MAX: ', summary.maxPreysInCell)
            print('predators: initial:', summary.inititalPredators, 'total: ', summary.totalPredators,  'MAX: ', summary.maxPredatorsInCell)

            print('----------------------------------------------------------------------------------------------------------')
            return true
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
predationRate = 0.01/9 -- death prey rate
--(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
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
birthPredatorPerPreyRate = 0.01/9 -- birth predator rate
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


