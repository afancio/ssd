-- @example Implementation of a simple vertical local Flow.
-- Each cell in a cellular space transfers part of its attribute stock
-- at a rate defined by f (t, y) to the spatially corresponding cell
-- attribute of another cellular space.
-- @image ssdLocalLocal.png

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

emptyCell = Cell {
    stock = 10
}
cs2 = CellularSpace {
    xdim = 3,
    instance = emptyCell
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

--------------------------------------------------------------
-- verticalDispersion_ruleR2 = function(t, nil, tgtCell)
-- verticalDispersion_ruleR2 = function(t, neightCell, cell) --concentrção:Focal --> local
-- verticalDispersion_ruleR2 = function(t, cell, neightCell) --difuão:local --> Focal
-- verticalDispersion_ruleR2 = function(t, srcCell, tgtCell)
-- return K*(desiredValue-tgtCell.stockR2)
-- end



----------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neightSourceCell, neighborTargetCell)
verticalDispersion_rate = 0.5
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * sourceCell.stock
end
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
    --delta = 1/2,
    rule = verticalDispersion_rule,
    source = cs_localCnt,
    target = cs2_localCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION


forEachCell(cs, function(cell)
    print("cs", cell.stock)
end)
forEachCell(cs2, function(cell)
    print("cs2",cell.stock)
end)

timer:run(2)

forEachCell(cs, function(cell)
    print("cs",cell.stock)
end)
forEachCell(cs2, function(cell)
    print("cs2",cell.stock)
end)

--os.exit(0)
