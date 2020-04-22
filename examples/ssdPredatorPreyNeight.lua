-- @example Based on: TerraME Prey-Predator dynamic model based on differental equations.
-- Especially for these model que use the "delta = 0.0625" flow pharameter.
-- It changes de interval off integration and alow a better vizualization of predator prey model.
-- Spatial Modelation: Each predator in a cellular space preadates the preys of cells in the neighborhood ("neight3x3")
-- of the spatially corresponding cell of another cellular space.
-- @image ssdPredatorNeight.png

import("ssd")

---------------------------------------------------------------
-- EXPERIMENT DEFINITIONS
--timeStep = 1 / 64 --1/16--1/512--1/256--0.03125 -- See the effects of 0.25, 0.125, 0.0625, and 0.03125
PREYS = 100
PREDATORS = 10
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    preys = Random{10, 50, 100},-- PREYS, --Random{10, 50, 100},
    predators = PREDATORS, --Random{0, 1, 10, 20},
    preysDeath = 0,
    predatorsDeath = 0
}

csField = CellularSpace {
    xdim = 10,
    instance = cell
}

csField:createNeighborhood{
    name = "neight3x3",
    strategy = "mxn",
    filter = function(cell)
        return cell.preys > 0
    end
}

map = Map {
    target = csField,
    select = "preys",
    min = 0,
    max = 2000,
    slices = 10,
    color = "Greens"
}

map2 = Map {
    target = csField,
    select = "predators",
    min = 0,
    max = 600,
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

---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            csField:synchronize()
            return false
        end
    },
    Event { action = csField },
    Event { action = map },
    Event { action = map2 },
    Event { action = chartsummary },


    --SUMMARY DATA MODEL EVENT
    Event {
        start = 0,
        --period = 1,
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

birthPreyRate = 0.2
funcBirthPrey = function(t, stock) return birthPreyRate * stock end

csField_local_prey = Connector {
    collection = csField,
    attribute = "preys"
}

BirthPrey = Flow {
    delta = 1,
    rule = funcBirthPrey,
    source = nil,
    target = csField_local_prey
}

--Flow(funcPredation, 1,  finalTime, timeStep,  csField, "preys", nil,  csField, "preysDeath", nil, model)
predationRate = 0.01 -- death prey rate
funcPredation = function(t, stock, stock2) return predationRate * stock * stock2 end

csField_local_preysPredators = Connector {
    delta = 0.0625,
    collection = csField,
    attribute = "preys",
    secundaryAttribute = "predators",
    neight = "neight3x3"
}

csField_local_preysDeath = Connector {
    collection = csField,
    attribute = "preysDeath"
}

Predation = Flow {
    delta = 0.0625,
    rule = funcPredation,
    source = csField_local_preysPredators,
    target = csField_local_preysDeath
}
--Flow(funcBirthPredatorPerPrey, 1,  finalTime, timeStep, nil, nil, nil,  csField, "predators", nil, model)

birthPredatorPerPreyRate = 0.01 -- birth predator rate
funcBirthPredatorPerPrey = function(t, stock, stock2) return birthPredatorPerPreyRate * stock * stock2 end

csField_local_predatorsPreys = Connector {
    collection = csField,
    attribute = "predators",
    secundaryAttribute = "preys"
}

BirthPredatorPerPrey = Flow {
    delta = 0.0625,
    rule = funcBirthPredatorPerPrey,
    source = nil,
    target = csField_local_predatorsPreys
}
--Flow(funcDeathPredator, 1,  finalTime, timeStep,  csField, "predators", nil,  csField, "predatorsDeath", nil, model)

deathPredatorRate = 0.1 -- death prey rate
funcDeathPredator = function(t, stock) return deathPredatorRate * stock end

csField_local_predators = Connector {
    collection = csField,
    attribute = "predators"
}

DeathPredator = Flow {
    delta = 0.0625,
    rule = funcDeathPredator,
    source = csField_local_predators,
    target = nil
}

timer:run(2000)

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


