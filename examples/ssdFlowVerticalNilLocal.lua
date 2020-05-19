-- @example nil -> Local.


import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
emptyCell = Cell {
    stock = 0
}
fullCell = Cell {
    stock = 1
}
cs = CellularSpace {
    xdim = 10,
    instance = fullCell,
    init = function()
        --    self:get(4, 4).stock = 100
    end
}
cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn",
    --self = true
}
mapCs = Map {
    target = cs,
    select = "stock",
    min = 0,
    max = 30,
    slices = 10,
    color = "Blues"
}
summaryAg = Agent {
    linearGrouwth = 100,
    exponentialGrouwth = 100,
    logisticalGrowth = 100,
    totalStockCs = 100,
    maxStockCs = 1,
    minStockCs = 100,
    execute = function(self, ev)
        local rate = 0.4
        local carryCapacity = 500
        local fLinear = function(rate, stock)
            return rate
        end
        --INTEGRATION_METHOD = integrationEuler
        self.linearGrouwth = d {
            function(t, q)
                return fLinear(rate, q)
            end, self.linearGrouwth, 0, 1, 1
        }

        local fExponential = function(rate, stock)
            return rate * stock
        end
        --INTEGRATION_METHOD = integrationEuler
        self.exponentialGrouwth = d {
            function(t, q)
                return fExponential(rate, q)
            end, self.exponentialGrouwth, 0, 1, 1
        }

        local fLogistical = function(rate, stock)
            return rate * stock * (1 - stock / carryCapacity)
        end
        --INTEGRATION_METHOD = integrationEuler
        self.logisticalGrowth = d {
            function(t, q)
                return fLogistical(rate, q)
            end, self.logisticalGrowth, 0, 1, 1
        }
    end
}

chartSummaryAg = Chart { target = summaryAg }

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
    Event { action = mapCs },
    Event { action = summaryAg },
    Event { action = chartSummaryAg },
    --SUMMARY DATA MODEL EVENT
    Event {
        --start = 0,
        priority = 9,
        action = function(event)
            print("---Stock validation step: " .. event:getTime())
            summaryAg.totalStockCs = 0
            summaryAg.maxStockCs = 0
            summaryAg.minStockCs = 9999999999
            --stock summary
            forEachCell(cs, function(cell)
                if (cell.stock > summaryAg.maxStockCs) then summaryAg.maxStockCs = cell.stock end
                if (cell.stock < summaryAg.minStockCs) then summaryAg.minStockCs = cell.stock end
                summaryAg.totalStockCs = summaryAg.totalStockCs + cell.stock
            end)
            print('summaryAg.linearGrouwth:', summaryAg.linearGrouwth)
            print('summaryAg.exponentialGrouwth:', summaryAg.exponentialGrouwth)
            print('summaryAg.logisticalGrowth:', summaryAg.logisticalGrowth)
            print('summaryAg.totalStockCs:', summaryAg.totalStockCs)
            print('summaryAg.maxStockCs:', summaryAg.maxStockCs)
            print('summaryAg.minStockCs:', summaryAg.minStockCs)

            print('----------------------------------------------------------------------------------------------------------')
            return true
        end
    }
}

----------------------------------------------------------------------
-- CHANGE RATES AND RULES
verticalDispersion_rate = 0.4
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return verticalDispersion_rate * targetCell.stock
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
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = nil,
    target = cs_localCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION

timer:run(10)
