-- @example nil -> focal - Exponential Growth archetype.

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
random = Random()
random:reSeed(123456789)

totalInitialStockCs = 100
rate = 0.1

emptyCell = Cell {
    stock = 0,
    logstock = function(cell)
        if cell.stock < 0.1 then
            return 0
        else
            return math.log(cell.stock)
        end
    end
}
cs = CellularSpace {
    xdim = 10,
    instance = emptyCell,
    init = function()
        --
    end
}

while totalInitialStockCs > 0 do
    forEachCell(cs, function(cell)
        local change = random:number()
        if (totalInitialStockCs > change) then
            totalInitialStockCs = totalInitialStockCs - change
        else
            change = totalInitialStockCs
            totalInitialStockCs = 0
        end
        --print (change)
        cell.stock = cell.stock + change
    end)
end

--test random cs
--forEachCell(cs, function(cell)
--    print(cell.stock)
--end)

cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn"--,
    --self = false
}
mapCs = Map {
    title = "Initial Stock levels (Randon) and Sum Stock Levels = 100",
    target = cs,
    select = "logstock",
    min = 0,
    max = 17, --15000, --4000000,
    slices = 10,
    color = "Blues"
}
emptyCell2 = Cell {
    stock = 0,
    logstock = function(cell)
        if cell.stock < 0.1 then
            return 0
        else
            return math.log(cell.stock)
        end
    end
}
cs2 = CellularSpace {
    xdim = 10,
    instance = emptyCell2,
    init = function()
        --self:get(5, 5).stock = 100
    end
}
cs2:get(5, 5).stock = 100

cs2:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn"--,
    --self = false
}

mapCs2 = Map {
    title = "Initial Stock levels (0) and 5x5 positon = 100",
    target = cs2,
    select = "logstock",
    min = 0,
    max = 17,--15000, --4000000,
    slices = 10,
    color = "Blues"
}
summaryAg = Agent {
    --linearGrouwth = 100,
    exponentialGrouwth = 100,
    --logisticalGrowth = 100,
    totalStockCs = 100,
    totalStockCsCentral = 100,
    --maxStockCs = 1,
    --minStockCs = 100,
    execute = function(self, ev)
        --local rate = 0.4
        --local carryCapacity = 500
        --        local fLinear = function(rate, stock)
        --            return rate
        --        end
        --        INTEGRATION_METHOD = integrationEuler
        --        self.linearGrouwth = d {
        --            function(t, q)
        --                return fLinear(rate, q)
        --            end, self.linearGrouwth, 0, 1, 1
        --        }

        local fExponential = function(rate, stock)
            return rate * -stock
        end
        --INTEGRATION_METHOD = integrationEuler
        self.exponentialGrouwth = d {
            function(t, q)
                return fExponential(rate, q)
            end, self.exponentialGrouwth, 0, 1, 1
        }

        --        local fLogistical = function(rate, stock)
        --            return rate * stock * (1 - stock / carryCapacity)
        --        end
        --        INTEGRATION_METHOD = integrationEuler
        --        self.logisticalGrowth = d {
        --            function(t, q)
        --                return fLogistical(rate, q)
        --            end, self.logisticalGrowth, 0, 1, 1
        --        }
    end
}

chartSummaryAg = Chart { target = summaryAg }

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
    Event { action = mapCs2 },
    Event { action = summaryAg },
    Event { action = chartSummaryAg },
    --SUMMARY DATA MODEL EVENT
    Event {
        --start = 0,
        priority = 9,
        action = function(event)
            print("---Stock validation step: " .. event:getTime())
            summaryAg.totalStockCs = 0
            local maxStockCs = 0
            local minStockCs = 9999999999
            --stock summary
            forEachCell(cs, function(cell)
                if (cell.stock > maxStockCs) then maxStockCs = cell.stock end
                if (cell.stock < minStockCs) then minStockCs = cell.stock end
                summaryAg.totalStockCs = summaryAg.totalStockCs + cell.stock
            end)
            --print('summaryAg.linearGrouwth:', summaryAg.linearGrouwth)
            print('summaryAg.exponentialGrouwth:', summaryAg.exponentialGrouwth)
            --print('summaryAg.logisticalGrowth:', summaryAg.logisticalGrowth)
            print('summaryAg.totalStockCs:', summaryAg.totalStockCs)
            print('maxStockCs:', maxStockCs, "math.log(maxStockC)", math.log(maxStockCs))
            print('minStockCs:', minStockCs)

            summaryAg.totalStockCsCentral = 0
            local maxStockCs2 = 0
            local minStockCs2 = 9999999999
            --stock summary
            forEachCell(cs2, function(cell)
                if (cell.stock > maxStockCs2) then maxStockCs2 = cell.stock end
                if (cell.stock < minStockCs2) then minStockCs2 = cell.stock end
                summaryAg.totalStockCsCentral = summaryAg.totalStockCsCentral + cell.stock
            end)
            --print('summaryAg.linearGrouwth:', summaryAg.linearGrouwth)
            --print('summaryAg.exponentialGrouwth:', summaryAg.exponentialGrouwth)
            --print('summaryAg.logisticalGrowth:', summaryAg.logisticalGrowth)
            print('summaryAg.totalStockCsCentral:', summaryAg.totalStockCsCentral)
            print('maxStockCs2:', maxStockCs2, "math.log(maxStockCs2)", math.log(maxStockCs2))
            print('minStockCs2:', minStockCs2)


            print('------------------------------------------------------------------')
            return true
        end
    },
    Event {action = function(event)
        --mapCs:save("SAVES/exponential/ExponentialMapCs" .. event:getTime() .. ".bmp")
        --mapCs2:save("SAVES/exponential/ExponentialMapCsCentral" .. event:getTime() .. ".bmp")
        --chartSummaryAg:save("SAVES/exponential/ExponentialChartSummaryAg" .. event:getTime() .. ".bmp")
    end},
}


----------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    neight = "neight3x3"
}
----------------------------------------------------------------------
-- CHANGE RATES AND RULES
--verticalDispersion_rate = 0.4
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return rate * sourceCell.stock
end
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    rule = verticalDispersion_rule,
    source = cs_focalCnt,
    target = nil
}
----------------------------------------------------------------------
-- ConnectorS
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock",
    neight = "neight3x3"
}
----------------------------------------------------------------------
-- CHANGE RATES AND RULES
--verticalDispersion_rate = 0.4
verticalDispersion_rule2 = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return rate * sourceCell.stock
    end
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow2 = Flow {
    rule = verticalDispersion_rule2,
    source = cs2_focalCnt,
    target = nil
}
--------------------------------------------------------------
-- MODEL EXECUTION

timer:run(60)
