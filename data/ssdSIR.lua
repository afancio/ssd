
---------------------------------------------------------------
-- PACKAGES
---------------------------------------------------------------

import("gis")
--import("ssd")
dofile("../lua/Flow.lua")
dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- PARAMETER
---------------------------------------------------------------
POPULATION					= 200000000
CONTACTS_PER_INFECTION_DAY	= 3
CONTAGION_STRENGTH			= 0.4
INFECTIOUS_PERIOD			= 7
INCUBATION_PERIOD			= 3
timeStep 					= 0.25 -- (1 = one day)
dt							= timeStep/1	-- integration interval
INTEGRATION_METHOD = integrationHeun    --#Integration Method {please, vary it: ("integrationHeun"and 0.25), "integrationRungeKutta" and 0.03125, "integrationEuler" and 0.03125}

---------------------------------------------------------------
-- GLOBAL VARIABLES & FUNCTIONS
---------------------------------------------------------------
infectionRate	= 0 
incubationRate	= 0		
recoveryRate	= 0
R0				= 0

function calcParameters ( )
	infectionRate 	= CONTACTS_PER_INFECTION_DAY * CONTAGION_STRENGTH / POPULATION
	incubationRate 	= 1 / INCUBATION_PERIOD
	recoveryRate	= 1 / INFECTIOUS_PERIOD
	R0 				= (infectionRate * POPULATION) / recoveryRate
	print ("R0   = ", R0)
end 

---------------------------------------------------------------
-- BUILDING SPATIAL STRUCTURE
---------------------------------------------------------------

inputLayerName  = "brasil"
outputLayerName = "brasilCells_500x500"
proj = Project{
    file = "covid_brasil_terrame.tview",
}

brasilCells = Layer{
	project = proj, 
	name = outputLayerName
}

--brasilCells:fill{
--	operation = "sum",
--	layer = inputLayerName,
--	attribute = "population",
--	select = "agreount_",
--	area = true
--}

cell = Cell{
	clean = true,
	susceptible = 0, 
	infected = 0,
	recovered = 0,
    logpop = function(self)
        return math.log(self.population)
    end
}       
    
cs = CellularSpace{
    project = proj,
    layer = outputLayerName,
    instance = cell
}

--cs = CellularSpace{
--	xdim = 100,
--    instance = cell
--}

cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn"
}

-- copy population attribute
forEachCell( cs, function(cell) 
	cell.susceptible = cell.x
end)
cs:synchronize();

--forEachCell(cs, function(cell)
--    print(cell.x, cell.y, cell.susceptible, #cell:getNeighborhood("neight3x3") )
--end)

--os.exit()
---------------------------------------------------------------
-- VISUALIZATION
---------------------------------------------------------------

map = Map{
    target = cs,
    select = "susceptible",
    slices = 10,
    color = "Purples"
}

---------------------------------------------------------------
-- MODEL
---------------------------------------------------------------

-- scheduler 
t1 = Timer{
--	Event {
--        action = function()
--            cs:synchronize()
--            return false
--        end
--    },
	Event{action = cs },
	Event{action = map },
	Event{action = function(ev) 
		print(ev:getTime()) 
		-- comente este proximo forEach Andre
		--forEachCell( cs, function(cell) 
		--	cell.susceptible = cell.past.susceptible * 0.9
		--end)
	end }
}

-- change rate and rule
dispersionRate = 0.9
--dispersionRule = function(t, stock) return 0.1 end
dispersionRule = function(t, stock) return dispersionRate * stock end

-- spatial connectors
cs_localCnt = Connector {
    collection = cs,
    attribute = "susceptible"
}
cs_focalCnt = Connector {
    collection = nil,
    attribute = "susceptible",
    neight = "neight3x3"
}

-- e imediatamente, descomente este fluxo; Tente executar. Oq está errado?
-- flows of change
local_Flow = Flow{
    rule = dispersionRule,
    source = cs_localCnt,
    target = cs_focalCnt,
    timer = t1
}


---------------------------------------------------------------
-- SIMULATION
---------------------------------------------------------------

-- Calculate values of global constants from parameters
calcParameters()

--print("provide any value")
--io.read(1)

t1:run(100)