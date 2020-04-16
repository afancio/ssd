
-- @example Implementation of a simple vertical local Flow.
-- @image ssdFlowVerticalFocalLocal.png

import("ssd")
--dofile("../lua/Flow.lua") --Arquivo deve ser colocado no HOME
--dofile("../lua/Connector.lua") --Arquivo deve ser colocado no HOME
randomRate = Random{seed = 1}
randomBoolean = Random{true, false}
emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = Random{0, 20, 50, 100}
}
cs = CellularSpace {
    xdim = 9,
    instance = fullCell--,
    --init = function(self)
     --           self:get(4,4).stock = 100
    --        end
}
cs2 = CellularSpace {
    xdim = 9,
    instance = emptyCell
}
cs:createNeighborhood{
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
            --cs:init()
            cs:synchronize()
            --cs2:init()
            cs2:synchronize()
            return false
        end
    },
    Event{action = mapCs},
    Event{action = mapCs2}
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.05
verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
----------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    neight = "neight3x3"
}
cs2_localCnt = Connector {
    collection = cs2,
    attribute = "stock",

}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_focalCnt,
    target = cs2_localCnt,
    timer = timer
}
--------------------------------------------------------------
-- MODEL EXECUTION

forEachCell(cs, function(cell)
    print(cell.stock)
end)
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

timer:run(10)

forEachCell(cs, function(cell)
    print(cell.stock)
end)
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

--os.exit(0)