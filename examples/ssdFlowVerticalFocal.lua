-- @example Implementation of a simple vertical local Flow.
-- Each cell in a cellular space (9x9) transfers part of its attribute stock at
-- a rate defined by f (t, y) (dispersion_rule) to the attributes of cells in the neighborhood ("neight3x3")
-- of the spatially corresponding cell of another cellular space.
-- @image ssdFlowVerticalFocal.png

import("ssd")

---------------------------------------------------------------
-- # SPACE # Creation
emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 9,
    instance = fullCell,
    init = function(self)
        self:get(4, 4).stock = 100
    end
}
cs2 = CellularSpace {
    xdim = 9,
    instance = emptyCell
}
cs2:createNeighborhood {
    name = "neight3x3",
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
            cs:init()
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
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.9
verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
----------------------------------------------------------------------
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock"
}
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock",
    neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_localCnt,
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

timer:run(1)

forEachCell(cs, function(cell)
    print(cell.stock)
end)
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

--os.exit(0)