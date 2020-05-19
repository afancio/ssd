-- @example Implementation of focal -> nil flow.
-- @image ssdFocalNil.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")
---------------------------------------------------------------
-- # SPACE # Creation
fullCell = Cell {
    stock = 100
}
cs = CellularSpace {
    xdim = 3,
    instance = fullCell
}

cs:createNeighborhood {
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

---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            --cs:init()
            cs:synchronize()
            --cs2:init()
            --cs2:synchronize()
            return false
        end
    },
    Event { action = mapCs },
    --Event { action = mapCs2 }
}

--------------------------------------------------------------
-- verticalDispersion_ruleR2 = function(t, nil, tgtCell)
-- verticalDispersion_ruleR2 = function(t, neightCell, cell) --concentrção:Focal --> local
-- verticalDispersion_ruleR2 = function(t, cell, neightCell) --difuão:local --> Focal
-- verticalDispersion_ruleR2 = function(t, srcCell, tgtCell)
-- return K*(desiredValue-tgtCell.stockR2)
-- end



----------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
verticalDispersion_rate = 0.1
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * neighborSourceCell.stock
end
----------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    neight = "neight3x3"
}

---------------------------------------------------------------
-- Flow OPERATORS
local_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_focalCnt,
    target = nil
}
--------------------------------------------------------------
-- MODEL EXECUTION


forEachCell(cs, function(cell)
    print("cs", cell.stock)
end)

timer:run(1)

forEachCell(cs, function(cell)
    print("cs",cell.stock)
end)


--os.exit(0)
