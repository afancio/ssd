
-- @example Implementation of a simple vertical local Flow.
-- @image ssdFlowVerticalFuncaoFeedbackLoop.png

import("ssd")
--dofile("../lua/Flow.lua") --Arquivo deve ser colocado no HOME
--dofile("../lua/Connector.lua") --Arquivo deve ser colocado no HOME

emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 3,
    instance = fullCell,
    init = function(self)
                self:get(0,0).stock = 100
                self:get(0,1).stock = 100
            end
}
cs2 = CellularSpace {
    xdim = 3,
    instance = emptyCell,
    init = function(self)
                self:get(0,0).stock = 1
                self:get(0,1).stock = 0
            end
}
cs2:createNeighborhood{
    name = "neight3x3",
    strategy = "mxn"
}
mapCs = Map{
	target = cs,
	select = "stock",
	min = 0,
	max = 100,
	slices = 10,
	color = "Blues"
}
mapCs2 = Map{
	target = cs2,
	select = "stock",
	min = 0,
	max = 100,
	slices = 10,
	color = "Blues"
}
----------------------------------------------------------------------
-- TIMER INSTANTIATION
timer = Timer {
    Event {
        action = function()
            cs:init()
            cs:synchronize()
            cs2:init()
            cs2:synchronize()
            return false
        end
    },
    Event{action = mapCs},
    Event{action = mapCs2}
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.1
verticalDispersion_rule = function(t, stock, stock2) return verticalDispersion_rate * stock * stock2 end
----------------------------------------------------------------------
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock"
}
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock"--,
    --neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_localCnt,
    target = cs2_focalCnt,
    feedbackLoop = true,
    timer = timer
}
--------------------------------------------------------------
-- MODEL EXECUTION
print("Before Run")
print("cs")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

timer:run(1)

print("After Run")
print("cs")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

print("verticalDispersion_rule", verticalDispersion_rule)

--os.exit(0)