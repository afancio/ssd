
-- @example Implementation of usage.

import("ssd")

cell = Cell {
    stock = 100
}
cell2 = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 3,
    instance = cell
}
cs2 = CellularSpace {
    xdim = 3,
    instance = cell2
}
timer = Timer {
    Event {
        action = function()
            cs:synchronize()
            cs2:synchronize()
            return false
        end
    },
}
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock"
}
cs2_localCnt = Connector {
    collection = cs2,
    attribute = "stock"
}
-- Flow OPERATORS
vertical_local_Flow = Flow {
    rule = function(t, stock) return 0.5 * stock end,
    source = cs_localCnt,
    target = cs2_localCnt,
    timer = timer
}
-- MODEL EXECUTION
timer:run(1)

