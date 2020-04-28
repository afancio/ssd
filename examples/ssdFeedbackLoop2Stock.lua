-- @example Implementation of a simple vertical local Flow that uses tree stocks (source.attribute,
--  source.secundaryAttribute and  target.attribute) to compose the flow rule. The differential equation that describes,
--  the rate of change (point derivative) of energy f (t, stock, stock2) at time t, where t is the simulation current
--  instant time, and stock is the past value of stock and stock2. The order of stocks, if they are used, are
--  source.attribute, source.secundaryAttribute, target.attribute and target.secundaryAttribute. The model makes a flow
--  from a product of all stocks involved and stores it in the source.
-- @image ssdFeedbackLoop2Stock.png

import("ssd")
---------------------------------------------------------------
-- # SPACE # Creation
fullCell = Cell {
    stock = 0,
    stock2 = 0
}
cs = CellularSpace {
    xdim = 3,
    instance = fullCell,
    init = function(self)
        self:get(0, 0).stock = 100
        self:get(0, 0).stock2 = 1
        self:get(0, 1).stock = 100
        self:get(0, 1).stock2 = 1
        self:get(0, 2).stock = 100
        self:get(0, 2).stock2 = 1
        self:get(1, 0).stock = 100
        self:get(1, 0).stock2 = 0
    end
}
emptyCell = Cell {
    stock = 0
}
cs2 = CellularSpace {
    xdim = 3,
    instance = emptyCell,
    init = function(self)
        self:get(0, 0).stock = 1
        self:get(0, 1).stock = 0
        self:get(0, 2).stock = 1
        self:get(1, 0).stock = 1
    end
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
            cs2:init()
            cs2:synchronize()
            return false
        end
    },
    Event { action = mapCs },
    Event { action = mapCs2 }
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.1
verticalDispersion_rule = function(t, stock, stock2, stock3) return verticalDispersion_rate * stock * stock2 * stock3 end
----------------------------------------------------------------------
-- ConnectorS
cs_localCnt = Connector {
    collection = cs,
    attribute = "stock",
    secundaryAttribute = "stock2"
}
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_localCnt,
    target = cs2_focalCnt,
    feedbackLoop = true
}
--------------------------------------------------------------
-- MODEL EXECUTION
print("Before Run")
print("cs")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)

timer:run(1)
--ssdGlobals = nil

print("After Run")
print("cs")
forEachCell(cs, function(cell)
    print(cell.stock)
end)
print("cs2")
forEachCell(cs2, function(cell)
    print(cell.stock)
end)
