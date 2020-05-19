-- @example nil -> focal - Logistic Growth archetype. feedback.

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
random = Random()
random:reSeed(123456789)

carryCapacity = 10000
rate = 0.1 --0.4--0.1--0.4
totalInitialStockCs = 100

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

--Exchange values of Random cs
for i = 10, 1, -1
do
    cellSample = cs:sample()
    cellSample2 = cs:sample()
    cellSample2.stock = cellSample2.stock + cellSample.stock
    cellSample.stock = 0
end

--Test random cs
--forEachCell(cs, function(cell)
--print(cell.stock)
--end)

cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn",
    wrap = true,
    --self = true
}
mapCs = Map {
    title = "Initial Stock levels (Randon) and Sum Stock Levels = 100",
    target = cs,
    select = "logstock",
    min = 0,
    max = 5, --15000, --4000000,
    slices = 10,
    color = "Blues"
}
emptyCell2 = Cell {
    stock = 0.001,
    logstock = function(cell)
        if cell.stock < 0.001 then
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
cs2:get(5, 5).stock = 99.901

cs2:createNeighborhood {
    name = "neight3x3Cs2",
    strategy = "mxn",
    wrap = true,
    --self = true
}

mapCs2 = Map {
    title = "Initial Stock levels (0) and 5x5 positon = 100",
    target = cs2,
    select = "logstock",
    min = 0,
    max = 5, --15000, --4000000,
    slices = 10,
    color = "Blues"
}
summaryAg = Agent {
    --linearGrouwth = 100,
    --exponentialGrouwth = 100,
    logisticalGrowth = 100,
    totalStockCsRandom = 100,
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

        --        local fExponential = function(rate, stock)
        --            return rate * stock
        --        end
        --        INTEGRATION_METHOD = integrationEuler
        --        self.exponentialGrouwth = d {
        --            function(t, q)
        --                return fExponential(rate, q)
        --            end, self.exponentialGrouwth, 0, 1, 1
        --        }

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
            summaryAg.totalStockCsRandom = 0
            local maxStockCs = 0
            local minStockCs = 9999999999
            --stock summary
            forEachCell(cs, function(cell)
                if (cell.stock > maxStockCs) then maxStockCs = cell.stock end
                if (cell.stock < minStockCs) then minStockCs = cell.stock end
                summaryAg.totalStockCsRandom = summaryAg.totalStockCsRandom + cell.stock
            end)
            --print('summaryAg.linearGrouwth:', summaryAg.linearGrouwth)
            --print('summaryAg.exponentialGrouwth:', summaryAg.exponentialGrouwth)
            print('summaryAg.logisticalGrowth:', summaryAg.logisticalGrowth)
            print('CsRandom')
            print('totalStock:', summaryAg.totalStockCsRandom)
            print('maxStock:', maxStockCs, "math.log(maxStockC)", math.log(maxStockCs))
            print('minStock:', minStockCs)

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
            print('CsCentral')
            print('totalStock:', summaryAg.totalStockCsCentral)
            print('maxStock:', maxStockCs2, "math.log(maxStockCs2)", math.log(maxStockCs2))
            print('minStock:', minStockCs2)


            print('------------------------------------------------------------------')
            return true
        end
    },
--    Event {
--        action = function(event)
--            mapCs:save("SAVES/logisticNeightTrueFeedBackLoopWrap/WrapLogiticoMapCs" .. event:getTime() .. ".bmp")
--            mapCs2:save("SAVES/logisticNeightTrueFeedBackLoopWrap/WrapLogiticoMapCsCentral" .. event:getTime() .. ".bmp")
--            chartSummaryAg:save("SAVES/logisticNeightTrueFeedBackLoopWrap/WrapLogiticoChartSummaryAg" .. event:getTime() .. ".bmp")
--            if (event:getTime() >= 400) then return false end
--        end
--    },
--    Event {
--        period = 50,
--        action = function(event)
--            mapCs:save("SAVES/logisticNeightTrueFeedBackLoop/WrapLogiticoMapCs" .. event:getTime() .. ".bmp")
--            mapCs2:save("SAVES/logisticNeightTrueFeedBackLoop/WrapLogiticoMapCsCentral" .. event:getTime() .. ".bmp")
--            chartSummaryAg:save("SAVES/logisticNeightTrueFeedBackLoop/WrapLogiticoChartSummaryAg" .. event:getTime() .. ".bmp")
--            --return false
--        end
--    }
}

--[09:55, 4/30/2020] Tiago Senna Carneiro: O comportamento logístico deveria se feito com relação a essa discrepância. É assim que se implementa o feedback! Calcula-se a discrepância entre dois estoques.
--cell = taxa × cell.past  × ABS(cell.past - neigh.past)/CC × (1  - cell.past/CC)
--[09:56, 4/30/2020] Tiago Senna Carneiro: Acredito que com essa fórmula você consiga usar dt maiores e taxas maiores sem problema
--[09:58, 4/30/2020] Tiago Senna Carneiro: Anos pq esses estabilizando em valores tão grandes? Se comparado à curva vermelha?
----------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- forEachNeighbor
-- sumFlow = taxa × neigh.past  × (1  - neigh.past/CC)
-- cell = summFlow
-- verticalDispersion_rule = function(t, stock)
-- return rate * stock * (1 - stock / carryCapacity)
-- end
-- forEachNeighbor
-- sumFlow = taxa × cell.past × ABS(cell.past - neigh.past)/CC × (1  - cell.past/CC)
-- cell = summFlow
-- verticalDispersion_rule = function(t, stock, stock2)
-- return rate * stock2 * math.abs(stock2 - stock)/carryCapacity * (1 - stock2 / carryCapacity)
-- end

--forEachCell
--    CCcell = carryCapacity/#cs
--    forEachNeighbor
--         neighbor= taxa × neigh.past × (cell.past/CCcell) × (1 - neigh.past/CCcell)
--    end
--end
CCcell = carryCapacity / #cs
verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return rate * neighborTargetCell.stock * (targetCell.stock / CCcell) * (1 - neighborTargetCell.stock / CCcell)
end
----------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stock",
    --secundaryAttribute = "neightCenter",
    neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    --delta = 0.0625,
    rule = verticalDispersion_rule,
    source = nil,
    target = cs_focalCnt
}
----------------------------------------------------------------------
-- ConnectorS
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stock",
    secundaryAttribute = "neightCenter",
    neight = "neight3x3Cs2"
}
verticalDispersion_rule2 = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return rate * neighborTargetCell.stock * (targetCell.stock / CCcell) * (1 - neighborTargetCell.stock / CCcell)
end
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow2 = Flow {
    --delta = 0.0625,
    rule = verticalDispersion_rule2,
    source = nil,
    target = cs2_focalCnt
}
--------------------------------------------------------------
-- MODEL EXECUTION

timer:run(400)
--timer:run(500)
