-- @example Implementation of a simple vertical Zonal Flow.
-- Each cell in a trajectory transfers part of its attribute stock at a
-- rate defined by f (t, y) to the next cell attribute of a trajectory.
-- @image ssdZonalZonal.png

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")
---------------------------------------------------------------
-- # SPACE # Creation
emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = 0
}
cs = CellularSpace {
    xdim = 3,
    instance = fullCell,
    init = function()
        --self:get(1, 1).stock = 100
    end
}
cs:get(0, 0).stock = 50
cs:get(1, 1).stock = 100
cs:get(2, 2).stock = 10
zona_tj = Trajectory {
    target = cs,
    select = function(cell) return cell.stock > 0
    end
}
cs2 = CellularSpace {
    xdim = 3,
    instance = emptyCell,
    init = function()
        --self:get(2, 2).stock = 100
    end
}
cs2:get(2, 2).stock = 100
cs2:get(1, 2).stock = 100

zona_tj2 = Trajectory {
    target = cs2,
    select = function(cell) return cell.stock > 0
    end
}
mapCs = Map {
    target = cs,
    select = "stock",
    min = 0,
    max = 200,
    slices = 10,
    color = "Blues"
}
mapCs2 = Map {
    target = cs2,
    select = "stock",
    min = 0,
    max = 200,
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
            zona_tj2:rebuild()
            zona_tj2:filter()
        end
    },
    Event { action = mapCs },
    Event { action = mapCs2 }
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.1
--verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * sourceCell.stock
end
----------------------------------------------------------------------
-- ConnectorS
tj_zocalCnt = Connector {
    collection = zona_tj,
    attribute = "stock"
}
tj2_zocalCnt = Connector {
    collection = zona_tj2,
    attribute = "stock"
}
---------------------------------------------------------------
-- Flow OPERATORS
zonalZonal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = tj_zocalCnt,
    target = tj2_zocalCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION
print ("cs1")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print ("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

timer:run(1)
--ssdGlobals = nil
print ("cs1")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print ("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

--os.exit(0)