-- @example Based on: TerraME Prey-Predator dynamic model based on differental equations.
-- Especially for these model que use the "delta = 0.0625" flow pharameter.
-- It changes de interval off integration and alow a better vizualization of predator prey model.
-- @image ssdPredatorPreyFeedbacklLoopLocalLocal.png

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
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    preys = PREYS,
    predators = PREDATORS,
    preysDeath = 0,
    predatorsDeath = 0
}

csField = CellularSpace {
    xdim = 1,
    instance = cell
}

chart = Chart {
    target = csField,
    width = 3,
    select = { "predators", "preys" },
    label = { "predators", "preys" },
    style = "lines",
    color = { "green", "red" },
    title = "Predator Prey"
}

chartPhaseSpace = Chart {
    target = csField,
    width = 3,
    xAxis = "preys",
    select = { "predators" },
    label = { "predators" },
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
    Event { period = delta, action = chart },
    Event { period = delta, action = chartPhaseSpace },
    --Event{action = chart2},

    --SAVE MODEL EVENT
--[[    Event {
        start = finalTime,
        ----period = 1,
        priority = 8,
        action = function(event)
            chart:save("../images/ssdPredatorPreyChart.bmp")
            chartPhaseSpace:save("../images/ssdPredatorPreyChartPhaseSpace.bmp")
            if (event:getTime() > finalTime) then return false end
        end
    }]]
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
funcBirthPrey = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return birthPreyRate * targetCell.preys
end
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
    --secundaryAttribute = "predators"
}
csField_local_preysDeath = Connector {
    collection = csField,
    attribute = "preysDeath"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
predationRate = 0.01 -- death prey rate
funcPredation = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return predationRate * sourceCell.preys * sourceCell.predators
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
    secundaryAttribute = "preys"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
birthPredatorPerPreyRate = 0.01 -- birth predator rate
funcBirthPredatorPerPrey = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return birthPredatorPerPreyRate * targetCell.predators * targetCell.preys
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
funcDeathPredator = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return deathPredatorRate * sourceCell.predators
end
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


