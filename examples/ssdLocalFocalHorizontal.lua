-- @example Implementation of a simple horizontal local Flow.
-- Each cell in a cellular space (9x9) transfers part of its attribute stock at
-- a rate defined by f (t, y) (dispersion_rule) to the attributes of its cells in the neighborhood ("neight3x3").
-- @image ssdLocalFocalHorizontal.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
emptyCell = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 9,
    instance = emptyCell,
    init = function(self)
        self:get(4, 4).stock = 1000
    end
}
cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn"
}
mapCs = Map {
    target = cs,
    select = "stock",
    min = 0,
    max = 1000,
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
            return false
        end
    },
    Event { action = mapCs }
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
dispersion_rate = 0.9
--dispersion_rule = function(t, stock) return dispersion_rate * stock end
dispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return dispersion_rate * sourceCell.stock
end
----------------------------------------------------------------------
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock"
}
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
local_Flow = Flow {
    rule = dispersion_rule,
    source = cs_localCnt,
    target = cs_focalCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION

forEachCell(cs, function(cell)
    print(cell.stock)
end)

timer:run(1)
--ssdGlobals = nil

forEachCell(cs, function(cell)
    print(cell.stock)
end)

--os.exit(0)