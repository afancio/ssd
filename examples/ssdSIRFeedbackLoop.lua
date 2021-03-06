-- @example A simple Susceptible-Infected-Recovered (SIR) model.
-- We implement a simple disease spread model, commonly known as an SIR
-- (susceptible-infected-recovered populations) model (Sterman, 2000)
-- Sterman J. 2000. Business Dynamics: Systems Thinking and Modeling for a Complex World.
-- Irwin/ McGraw-Hill: New York.
-- This model represents a given disease that propagates over a fixed population with only three compartments:
-- susceptible, S (t); infected, I (t), and recovered, R (t).
-- It starts with a small number of infected that passes the disease to the susceptible ones.
-- After some time, infected become recovered, which cannot be infected again.
-- For mode details visit http://en.wikipedia.org/wiki/Epidemic_model.
-- @image ssdSIRFeedBackLoop.bmp

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- PARAMETER
---------------------------------------------------------------
TOTAL = 1000
INITIAL_INFECTED = 1
CONTACTS_PER_INFECTION_DAY = 1
CONTAGION_STRENGTH = 0.4
INFECTIOUS_PERIOD = 4
---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    susceptible = TOTAL - INITIAL_INFECTED,
    infected = INITIAL_INFECTED,
    recovered = 0,
    R0 = 0
}

csCity = CellularSpace {
    xdim = 1,
    instance = cell
}

chart = Chart {
    target = csCity,
    width = 3,
    select = { "susceptible", "infected", "recovered" },
    label = { "susceptible", "infected", "recovered" },
    style = "lines",
    color = { "blue", "red", "green" },
    title = "SIR"
}
---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event { action = csCity },
    Event { action = chart },
}

---------------------------------------------------------------
-- INTEGRATION FUNCTION AND CHANGE RATES
---------------------------------------------------------------




R0 = ((CONTACTS_PER_INFECTION_DAY * CONTAGION_STRENGTH / TOTAL) * TOTAL) / (1 / INFECTIOUS_PERIOD)

---------------------------------------------------------------
-- Connectors
csCity_local_susceptible = Connector {
    collection = csCity,
    attribute = "susceptible"
}
csCity_local_infected = Connector {
    collection = csCity,
    attribute = "infected"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
infectionRate = CONTACTS_PER_INFECTION_DAY * CONTAGION_STRENGTH / TOTAL
funcInfect = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return infectionRate * sourceCell.susceptible * targetCell.infected
end
---------------------------------------------------------------
-- Flow OPERATORS
infect = Flow {
    rule = funcInfect,
    source = csCity_local_susceptible,
    target = csCity_local_infected,
    feedbackLoop = true
}

---------------------------------------------------------------
-- Connectors
csCity_local_recovered = Connector {
    collection = csCity,
    attribute = "recovered"
}
---------------------------------------------------------------
-- CHANGE RATES AND RULES
recoverRate = 1 / INFECTIOUS_PERIOD
funcRecover = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return recoverRate * sourceCell.infected
end
---------------------------------------------------------------
-- Flow OPERATORS
recover = Flow {
    rule = funcRecover,
    source = csCity_local_infected,
    target = csCity_local_recovered,
}

timer:run(100)
--ssdGlobals = nil
print("R0",R0)
--[[
--ORIGINAL MODEL
-- Lesson: SIR model - Simulating communicable disease transmission through individual
--         and finite resources limit the system growth.
-- Authors:  Tiago Carneiro & Gilberto Camara

---------------------------------------------------------------
-- PARAMETER
---------------------------------------------------------------
TOTAL                     = 1000
CONTACTS_PER_INFECTION_DAY  = 1
CONTAGION_STRENGTH        = 0.4
INFECTIOUS_PERIOD         = 4

---------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------
infectionRate = 0
recoveryRate  = 0
R0        = 0

---------------------------------------------------------------
-- MODEL
system = Agent {
  susceptible = 999,
  infected = 1,
  recovered = 0,
  execute = function( self )
      local change_infected  = infectionRate*self.susceptible*self.infected

      local change_recovered = recoveryRate*self.infected

      if change_infected > self.susceptible then
        change_infected = self.susceptible
      end

      self.susceptible  = self.susceptible  - change_infected
      self.infected   = self.infected     + change_infected - change_recovered
      self.recovered    = self.recovered    + change_recovered
  end
}


function calcParameters ( )

  infectionRate = CONTACTS_PER_INFECTION_DAY * CONTAGION_STRENGTH / TOTAL

  recoveryRate = 1 / INFECTIOUS_PERIOD

  R0 = (infectionRate * TOTAL) / recoveryRate

  print ("R0   = ", R0)
end

---------------------------------------------------------------
-- SIMULATION
---------------------------------------------------------------
chart = Observer {
  subject       = system,
  attributes    = {"susceptible",  "infected", "recovered"},
  curveLabels = {"susceptible",  "infected", "recovered"},
  title         = "SIR model",
  xLabel        = "days",
  yLabel        = "people",
  type = "chart"
}

timer = Timer {
  Event{time = 1, --period = 1, action = function(ev)
    system:execute()
    system:notify(ev:getTime())
  end}
}

-- Calculate values of global constants from parameters
calcParameters (model)

timer:execute (100)




]]

