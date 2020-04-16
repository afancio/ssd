-- @example Implementation of a simple horizontal local Flow.
-- @image ssdFlowHorizontalFocal.png

import("ssd")

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
----------------------------------------------------------------------
-- TIMER INSTANTIATION
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
verticalDispersion_rate = 0.9
verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
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
    rule = verticalDispersion_rule,
    source = cs_localCnt,
    target = cs_focalCnt,
    timer = timer
}
--------------------------------------------------------------
-- MODEL EXECUTION

forEachCell(cs, function(cell)
    print(cell.stock)
end)

timer:run(1)

forEachCell(cs, function(cell)
    print(cell.stock)
end)

--os.exit(0)