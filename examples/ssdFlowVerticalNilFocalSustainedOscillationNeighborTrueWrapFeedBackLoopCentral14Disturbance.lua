-- @example Sustained oscilation archetype. 51x51 central.

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
random = Random()
random:reSeed(123456789)

timeStep = 1 / 512 -- 0.03125 / 16 --1
delta = 1 / 512 --0.03125 / 16 --0.03125/4--0.03125/32

K = 0.04
desiredValue = 0

rate = 0.001 --0.4--0.1--0.4
totalInitialStockCs = 100

emptyCell2 = Cell {
    stockR1 = 0.001,
    stockR2 = 0.001,
    logstockR1 = function(cell)
        if cell.stockR1 < 0.001 then
            return 0
        else
            return math.log(cell.stockR1)
        end
    end,
    logstockR2 = function(cell)
        if cell.stockR2 < 0.001 then
            return 0
        else
            return math.log(cell.stockR2)
        end
    end
}
cs2 = CellularSpace {
    xdim = 51,
    instance = emptyCell2,
    init = function()
        --self:get(5, 5).stock = 100
    end
}
cs2:get(25, 25).stockR1 = 99.901
cs2:get(25, 25).stockR2 = 99.901

cs2:createNeighborhood {
    name = "neight3x3cs2",
    strategy = "mxn",
    wrap = true,
    --self = true
}

mapCs2R1 = Map {
    title = "Initial StockR1 (Central)",
    target = cs2,
    select = "stockR1",
    min = -150,
    max = 150, --15000, --4000000,
    slices = 10,
    --color = "Blues"
    color = "Greys",
    invert = true
}
mapCs2R2 = Map {
    title = "Initial StockR2 (Central)",
    target = cs2,
    select = "stockR2",
    min = -150,
    max = 150, --15000, --4000000,
    slices = 10,
    --color = "Blues"
    color = "Greys", --PiYG
    invert = true
}
summaryAg = Agent {
    --linearGrouwth = 100,
    --exponentialGrouwth = 100,
    --logisticalGrowth = 100,
    sustainedOscillationR1 = 100, --100,
    sustainedOscillationR2 = 100, --100,
    --totalStockCsRandomR1 = 100,
    totalStockCsCentralR1 = 100,
    --totalStockCsRandomR2 = 100,
    totalStockCsCentralR2 = 100,
    --fR1 = 100,
    --fR2 = 100,

    execute = function(self, ev)

        --local R2Past = self.sustainedOscillationR2
        --local R1Past = self.sustainedOscillationR1
        local fSustainedOscillationR1 = function(rate, stock)
            --return R2Past*9*100
            return stock[2]
        end
        local fSustainedOscillationR2 = function(rate, stock)
            --return K*((desiredValue*100)-R1Past)*9*100
            return K * (desiredValue - stock[1])
        end
        --INTEGRATION_METHOD = integrationRungeKutta
        --INTEGRATION_METHOD = integrationHeun
        self.sustainedOscillationR1, self.sustainedOscillationR2 = d {
            {
                function(t, q)
                    --self:notify(t)
                    return fSustainedOscillationR1(rate, q)
                    --end, self.sustainedOscillationR1, 0, 1, 1
                end,
                function(t, q)
                    return fSustainedOscillationR2(rate, q)
                    --end, self.sustainedOscillationR2, 0, 1, 1
                end
            },
            {
                self.sustainedOscillationR1,
                self.sustainedOscillationR2
            },
            --0, timeStep, 0.03125/16
            --0, timeStep/13, delta -- deu bem proximo com isso  --refletir
            0, timeStep, delta
        }
        --self.fR1 =  self.sustainedOscillationR1--*9*100
        --self.fR2 =  self.sustainedOscillationR2--*9*100
    end
}

chartPhaseSpaceCs2 = Chart {
    target = summaryAg,
    width = 3,
    xAxis = "totalStockCsCentralR1",
    select = { "totalStockCsCentralR2" },
    label = { "totalStockCsCentralR2" },
    style = "lines",
    color = { "red" },
    title = "Phase space cs2 (Central)"
}
chartPhaseSpaceSummary = Chart {
    target = summaryAg,
    width = 3,
    xAxis = "sustainedOscillationR1",
    select = { "sustainedOscillationR2" },
    label = { "sustainedOscillationR2" },
    style = "lines",
    color = { "red" },
    title = "Phase space (d)"
}
chartSummaryAg = Chart { target = summaryAg }
---------------------------------------------------------------
-- Timer DECLARATION
chartSummaryAg:update(0)

maxStockCs2R1 = -999999999999999999999999999999999
minStockCs2R1 = 999999999999999999999999999999999
maxStockCs2R2 = -999999999999999999999999999999999
minStockCs2R2 = 999999999999999999999999999999999

timer = Timer {
    Event {
        --start = 0,
        action = function()
            --cs:init()
            --cs:synchronize()
            --cs2:init()
            cs2:synchronize()
            return false
        end
    },
    Event { --start = 0,
        period = timeStep, action = mapCs2R1 },
    Event { --start = 0,
        period = timeStep, action = mapCs2R2 },
    Event { --start = 0,
        period = timeStep, action = summaryAg },
    Event { --start = 0,
        period = timeStep, action = chartSummaryAg },
    Event { --start = 0,
        period = timeStep, action = chartPhaseSpaceCs2 },
    Event { --start = 0,
        period = timeStep, action = chartPhaseSpaceSummary },
    --SUMMARY DATA MODEL EVENT
    Event {
        --start = 0,
        period = timeStep,
        priority = 9,
        action = function(event)
            print("step: " .. event:getTime())
            summaryAg.totalStockCsCentralR1 = 0
            summaryAg.totalStockCsCentralR2 = 0

            summaryAg.totalStockCsCentral = 0

            --stock summary
            forEachCell(cs2, function(cell)
                if (cell.stockR1 > maxStockCs2R1) then maxStockCs2R1 = cell.stockR1
                end
                if (cell.stockR1 < minStockCs2R1) then minStockCs2R1 = cell.stockR1
                end
                summaryAg.totalStockCsCentralR1 = summaryAg.totalStockCsCentralR1 + cell.stockR1
                if (cell.stockR2 > maxStockCs2R2) then maxStockCs2R2 = cell.stockR2
                end
                if (cell.stockR2 < minStockCs2R2) then minStockCs2R2 = cell.stockR2
                end
                summaryAg.totalStockCsCentralR2 = summaryAg.totalStockCsCentralR2 + cell.stockR2
            end)

            print('CsCentral', 'R1:', summaryAg.totalStockCsCentralR1,
                'MAXR1:', maxStockCs2R1, 'MINR1:', minStockCs2R1)
            print('CsCentral:', 'R2:', summaryAg.totalStockCsCentralR2,
                'MAXR2:', maxStockCs2R2, 'MINR2:', minStockCs2R2)

            return true
        end
    },
    --Disturbance time 14
    Event {
        start = 2,
        action = function(event)
            cs2:get(10, 40).stockR1 = 99.901
            cs2:get(10, 40).stockR2 = 99.901
            return false
        end
    },
--    Event {
--        start = 0,
--        period = 1 / 4,
--        action = function(event)
--            mapCs2R1:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOMapCsCentralR1-" .. event:getTime() .. ".bmp")
--            mapCs2R2:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOMapCsCentralR2-" .. event:getTime() .. ".bmp")
--            if (event:getTime() >= 70) then return false
--            end
--        end
--    },
--    Event {
--        start = 0,
--        --period = 1,
--        action = function(event)
--            mapCs2R1:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOMapCsCentralR1-" .. event:getTime() .. ".bmp")
--            mapCs2R2:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOMapCsCentralR2-" .. event:getTime() .. ".bmp")
--            chartSummaryAg:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOChartSummaryAg" .. event:getTime() .. ".bmp")
--            chartPhaseSpaceCs2:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOChartPhaseSpaceCs2" .. event:getTime() .. ".bmp")
--            chartPhaseSpaceSummary:save("SAVES/ssdFlowVerticalNilFocalSustainedOscillationNeighborTrueWrapFeedBackLoopCentral14Disturbance/SOChartPhaseSpaceSummary" .. event:getTime() .. ".bmp")
--            if (event:getTime() >= 70) then return false end
--        end
--    },
}

--------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
neighR1Growth2 = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return targetCell.stockR2
end
----------------------------------------------------------------------
-- ConnectorS
cs2_focalCnt = Connector {
    collection = cs2,
    attribute = "stockR1",
    neight = "neight3x3cs2"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow2 = Flow {
    delta = delta, --0.03125/16,
    rule = neighR1Growth2,
    source = nil,
    target = cs2_focalCnt
}

--------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
neighR2Growth2 = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return K * (desiredValue - targetCell.stockR1)
end
----------------------------------------------------------------------
-- ConnectorS
cs2_focalCntR2 = Connector {
    collection = cs2,
    attribute = "stockR2",
    neight = "neight3x3cs2"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_FlowR2 = Flow {
    delta = delta, --0.03125/16 ,
    rule = neighR2Growth2,
    source = nil,
    target = cs2_focalCntR2
}
--------------------------------------------------------------
-- MODEL EXECUTION
timer:run(4)
--timer:run(1000)
--timer:run(400)
