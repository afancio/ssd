-- @example Implementation of a simple vertical Zonal Flow.
-- Each cell in a trajectory transfers part of its attribute stock at a
-- rate defined by f (t, y) to the spatially corresponding cell attribute
-- of another cellular space.
-- @image ssdLocalZonal.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
emptyCell = Cell {
    stock = 10
}
cs2 = CellularSpace {
    xdim = 3,
    instance = emptyCell
}
fullCell = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 3,
    instance = fullCell,
    init = function(self)
        self:get(1, 1).stock = 100
    end
}
zona_tj = Trajectory {
    target = cs,
    select = function(cell) return cell.stock > 0
    end
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
    Event {
        action = function(event)
            zona_tj:rebuild()
            zona_tj:filter()
            if (event:getTime() >= 5000) then
                return false
            end
        end
    },
    Event { action = mapCs },
    Event { action = mapCs2 }
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.1
--verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * sourceCell.stock
end
----------------------------------------------------------------------
-- ConnectorS
tj_zocalCnt = Connector {
    collection = zona_tj,
    attribute = "stock"
}
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock"
}
---------------------------------------------------------------
-- Flow OPERATORS
zonal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs2_focalCnt,
    target = tj_zocalCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION
forEachCell(cs, function(cell)
    print("cs1", cell.stock)
end)
forEachCell(cs2, function(cell)
    print("cs2", cell.stock)
end)

timer:run(1)

forEachCell(cs, function(cell)
    print("cs1", cell.stock)
end)
forEachCell(cs2, function(cell)
    print("cs2", cell.stock)
end)

--os.exit(0)