
-- @example Implementation of a simple vertical local Flow.
-- @image ssdFlowVerticalLocal.png

import("ssd")

emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = 100
}
cs = CellularSpace {
    xdim = 9,
    instance = fullCell
}
cs2 = CellularSpace {
    xdim = 9,
    instance = emptyCell
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
verticalDispersion_rate = 0.5
verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
----------------------------------------------------------------------
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock"
}
cs2_localCnt = Connector {
    collection = cs2,
    attribute = "stock"
}
---------------------------------------------------------------
-- Flow OPERATORS
local_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_localCnt,
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

timer:run(1)

forEachCell(cs, function(cell)
    print(cell.stock)
end)
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

--os.exit(0)
