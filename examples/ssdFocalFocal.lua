-- @example Implementation of a simple vertical Focal to Focal Flow (funnel effect).
-- Each cell from neighborhood ("neight3x3") of a cell in a cellular space (9x9) transfers
-- part of its attribute stock at a rate defined by f (t, y) to the
-- cell attribute spatially corresponding to the central cell of the
-- neighborhood of another cellular space.
-- @image ssdFocalFocal.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
randomRate = Random { seed = 1 }
randomBoolean = Random { true, false }

fullCell = Cell {
    stock = Random { 0, 20, 50, 100 }
}
cs = CellularSpace {
    xdim = 9,
    instance = fullCell
}
cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn"
}
emptyCell = Cell {
    stock = 0
}
cs2 = CellularSpace {
    xdim = 9,
    instance = emptyCell
}
cs2:createNeighborhood {
    name = "neight3x32",
    strategy = "mxn"
}
mapCs = Map {
    target = cs,
    select = "stock",
    min = 0,
    max = 100,
    slices = 10,
    color = "Blues"
}
mapCs2 = Map {
    target = cs2,
    select = "stock",
    min = 0,
    max = 100,
    slices = 10,
    color = "Blues"
}
---------------------------------------------------------------
-- Timer DECLARATION
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
    Event { action = mapCs },
    Event { action = mapCs2 }
}


----------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    neight = "neight3x3"
}
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock",
    neight = "neight3x32"
}
----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.05
--verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * neighborSourceCell.stock
end
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_focalCnt,
    target = cs2_focalCnt
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
--ssdGlobals = nil

forEachCell(cs, function(cell)
    print(cell.stock)
end)
forEachCell(cs2, function(cell)
    print(cell.stock)
end)