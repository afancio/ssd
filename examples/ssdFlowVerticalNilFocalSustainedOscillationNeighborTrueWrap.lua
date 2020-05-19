-- @example nil -> focal - Sustained oscilation archetype.

import("ssd")
--dofile("../lua/Flow.lua")
--dofile("../lua/Connector.lua")

---------------------------------------------------------------
-- # SPACE # Creation
random = Random()
random:reSeed(123456789)

carryCapacity = 10000
periodicity = 10
tranlationX = 0
tranlationXR2 = 10
tranlationY = 0

--delta = 1/64--1/32--1/16
--delta = 0.015625--0.03125--0,0625

timeStep = 1 / 512 -- 0.03125 / 16 --1
delta = 1 / 512 --0.03125 / 16 --0.03125/4--0.03125/32

desiredValue = 0
K = 0.04
--gap = desiredValue-R1
--R1 = 30
--R1 = eR1
--eR1 = R2
--R2 = 10
--eR2 = K*gap


rate = 1 --0.001 --0.4--0.1--0.4
totalInitialStockCs = 100

emptyCell = Cell {
    stockR1 = 0,
    stockR2 = 0,
    logstockR1 = function(cell)
        if cell.stockR1 < 0.1 then
            return 0
        else
            return math.log(cell.stockR1)
        end
    end,
    logstockR2 = function(cell)
        if cell.stockR2 < 0.1 then
            return 0
        else
            return math.log(cell.stockR2)
        end
    end
}
cs = CellularSpace {
    xdim = 11,
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
        cell.stockR1 = cell.stockR1 + change
        cell.stockR2 = cell.stockR2 + change
    end)
end

--Exchange values of Random cs
for i = 10, 1, -1
do
    cellSample = cs:sample()
    cellSample2 = cs:sample()
    cellSample2.stockR1 = cellSample2.stockR1 + cellSample.stockR1
    cellSample.stockR1 = 0
    cellSample2.stockR2 = cellSample2.stockR2 + cellSample.stockR2
    cellSample.stockR2 = 0
end

--Test random cs
--forEachCell(cs, function(cell)
--print(cell.stockR1, cell.stockR2)
--end)
--print("cell.stockR2, cell.stockR2")
--forEachCell(cs, function(cell)
--print(cell.stockR2, cell.stockR2)
--end)

cs:createNeighborhood {
    name = "neight3x3",
    strategy = "mxn",
    wrap = true,
    --self = true
}
mapCsR1 = Map {
    title = "Initial StockR1 levels (Randon) and Sum Stock Levels = 100",
    target = cs,
    select = "stockR1",
    min = -150,
    max = 150, --15000, --4000000,
    slices = 10,
    --color = "Blues"
    color = "Greys",
    invert = true
}
mapCsR2 = Map {
    title = "Initial StockR2 levels (Randon) and Sum Stock Levels = 100",
    target = cs,
    select = "stockR2",
    min = -150,
    max = 150, --15000, --4000000,
    slices = 10,
    --color = "Blues"
    color = "Greys",
    invert = true
}
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
    xdim = 11,
    instance = emptyCell2,
    init = function()
        --self:get(5, 5).stock = 100
    end
}
cs2:get(5, 5).stockR1 = 99.901
cs2:get(5, 5).stockR2 = 99.901

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
CCcell = carryCapacity / #cs
summaryAg = Agent {
    --linearGrouwth = 100,
    --exponentialGrouwth = 100,
    --logisticalGrowth = 100,
    sustainedOscillationR1 = 100, --100,
    sustainedOscillationR2 = 100, --100,
    totalStockCsRandomR1 = 100,
    totalStockCsCentralR1 = 100,
    totalStockCsRandomR2 = 100,
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
            0, timeStep, delta / 8
        }
        --self.fR1 =  self.sustainedOscillationR1--*9*100
        --self.fR2 =  self.sustainedOscillationR2--*9*100
    end
}

--[[summaryAg = Agent {
    --linearGrouwth = 100,
    --exponentialGrouwth = 100,
    --logisticalGrowth = 100,
    sustainedOscillationR1 = 100,--100,
    sustainedOscillationR2 = 100,--100,
    totalStockCsRandomR1 = 100,
    totalStockCsCentralR1 = 100,
    totalStockCsRandomR2 = 100,
    totalStockCsCentralR2 = 100,
    execute = function(self, ev)

        local R2Past = self.sustainedOscillationR2
        local R1Past = self.sustainedOscillationR1
        local fSustainedOscillationR1 = function(rate, stock)
            return R2Past*9*100
        end
        INTEGRATION_METHOD = integrationEuler
        self.sustainedOscillationR1 = d {
            function(t, q)
                return fSustainedOscillationR1(rate, q)
            --end, self.sustainedOscillationR1, 0, 1, 1
            end, self.sustainedOscillationR1, 0, 0.03125/128,  0.03125/128
        }
        local tranlationYR2 = 0
        local fSustainedOscillationR2 = function(rate, stock)
            return K*((desiredValue*100)-R1Past)*9*100

        end
        INTEGRATION_METHOD = integrationEuler
        self.sustainedOscillationR2 = d {
            function(t, q)
                return fSustainedOscillationR2(rate, q)
            --end, self.sustainedOscillationR2, 0, 1, 1
            end, self.sustainedOscillationR2, 0, 0.03125/128,  0.03125/128
        }
    end
}]]


chartPhaseSpaceCs = Chart {
    target = summaryAg,
    width = 3,
    xAxis = "totalStockCsRandomR1",
    select = { "totalStockCsRandomR2" },
    label = { "totalStockCsRandomR2" },
    style = "lines",
    color = { "red" },
    title = "Phase space cs1 (Random)"
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

maxStockCsR1 = -999999999999999999999999999999999
minStockCsR1 = 999999999999999999999999999999999999
maxStockCsR2 = -999999999999999999999999999999999
minStockCsR2 = 999999999999999999999999999999999999
maxStockCs2R1 = -999999999999999999999999999999999
minStockCs2R1 = 999999999999999999999999999999999
maxStockCs2R2 = -999999999999999999999999999999999
minStockCs2R2 = 999999999999999999999999999999999

timer = Timer {
    Event {
        --start = 0,
        action = function()
            --cs:init()
            cs:synchronize()
            --cs2:init()
            cs2:synchronize()
            return false
        end
    },
    Event { period = timeStep, action = mapCsR1 },
    Event { period = timeStep, action = mapCsR2 },
    Event { period = timeStep, action = mapCs2R1 },
    Event { period = timeStep, action = mapCs2R2 },
    Event { period = timeStep, action = summaryAg },
    Event { period = timeStep, action = chartSummaryAg },
    Event { period = timeStep, action = chartPhaseSpaceCs },
    Event { period = timeStep, action = chartPhaseSpaceCs2 },
    Event { period = timeStep, action = chartPhaseSpaceSummary },
    --SUMMARY DATA MODEL EVENT
    Event {
        --start = 0,
        period = timeStep,
        priority = 9,
        action = function(event)
            print("-------------------------------------------------------------------step: " .. event:getTime())
            summaryAg.totalStockCsRandomR1 = 0
            summaryAg.totalStockCsRandomR2 = 0
            summaryAg.totalStockCsCentralR1 = 0
            summaryAg.totalStockCsCentralR2 = 0

            --stock summary
            forEachCell(cs, function(cell)
                if (cell.stockR1 > maxStockCsR1) then maxStockCsR1 = cell.stockR1
                end
                if (cell.stockR1 < minStockCsR1) then minStockCsR1 = cell.stockR1
                end
                summaryAg.totalStockCsRandomR1 = summaryAg.totalStockCsRandomR1 + cell.stockR1
                if (cell.stockR2 > maxStockCsR2) then maxStockCsR2 = cell.stockR2
                end
                if (cell.stockR2 < minStockCsR2) then minStockCsR2 = cell.stockR2
                end
                summaryAg.totalStockCsRandomR2 = summaryAg.totalStockCsRandomR2 + cell.stockR2
            end)


            print('GLOBAL: R1:', summaryAg.sustainedOscillationR1)
            print('GLOBAL: R2:', summaryAg.sustainedOscillationR2)
            print('CsRandom', 'R1:', summaryAg.totalStockCsRandomR1,
                'MAXR1:', maxStockCsR1, 'MINR1:', minStockCsR1)
            print('CsRandom', 'R2:', summaryAg.totalStockCsRandomR2,
                'MAXR2:', maxStockCsR2, 'MINR2:', minStockCsR2)

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

            --            print('------------------------------------------------------------------')
            return true
        end
    },
    --    Event {period = 1/2,
    --        action = function(event)
    --            mapCsR1:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsRandomR1-" .. event:getTime() .. ".bmp")
    --            mapCsR2:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsRandomR2-" .. event:getTime() .. ".bmp")
    --            mapCs2R1:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsCentralR1-" .. event:getTime() .. ".bmp")
    --            mapCs2R2:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsCentralR2-" .. event:getTime() .. ".bmp")
    --            if (event:getTime() >= 10) then return false
    --            end
    --        end
    --    },
    --    Event {start = 10,
    --        --period = 50,
    --        action = function(event)
    --            mapCsR1:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsRandomR1-" .. event:getTime() .. ".bmp")
    --            mapCsR2:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsRandomR2-" .. event:getTime() .. ".bmp")
    --            mapCs2R1:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsCentralR1-" .. event:getTime() .. ".bmp")
    --            mapCs2R2:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationMapCsCentralR2-" .. event:getTime() .. ".bmp")
    --            chartSummaryAg:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationChartSummaryAg" .. event:getTime() .. ".bmp")
    --            chartPhaseSpaceCs:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationChartPhaseSpaceCs" .. event:getTime() .. ".bmp")
    --            chartPhaseSpaceCs2:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationChartPhaseSpaceCs2" .. event:getTime() .. ".bmp")
    --            chartPhaseSpaceSummary:save("SAVES/sustainedOscillationPendulo2/sustainedOscillationChartPhaseSpaceSummary" .. event:getTime() .. ".bmp")
    --            if (event:getTime() >= 10) then return false end
    --        end
    --    },
}

-- [12:00, 5/5/2020] Tiago Senna Carneiro: Eu gostaria de ver o oscilador! Mostrar 3 gráficos.
--[12:01, 5/5/2020] Tiago Senna Carneiro: 1. Os estoques R1 e R2 no tempo
--[12:02, 5/5/2020] Tiago Senna Carneiro: 2. Estudo de fase: R1 versus  R2
--[12:03, 5/5/2020] Tiago Senna Carneiro: 3. Mapas R1 e R2 para cs central e cs Random
--[12:04, 5/5/2020] Tiago Senna Carneiro: Vc precisará de 2 fluxos de entrada nil-->focal,
-- um para cada estoque
--[12:05, 5/5/2020] Tiago Senna Carneiro: E 2 fluxos de saída focal-->nil
--[12:08, 5/5/2020] Tiago Senna Carneiro: 4  seria legal cada vizinho oscilar com a célula central em
-- um quarto gráfico no tempo para estudar feedback
--
--5. Mapas dos feedbacks

--------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell, centralSourceCell)
neighR1Growth = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    return neighborTargetCell.stockR2
end
------------------------------------------------------------------
-- ConnectorS
cs_focalCnt = Connector {
    collection = cs,
    attribute = "stockR1",
    neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_Flow = Flow {
    delta = delta, --0.03125/16,
    rule = neighR1Growth,
    source = nil,
    target = cs_focalCnt
}
--------------------------------------------------------------
-- verticalDispersion_ruleR2 = function(t, nil, tgtCell)
-- verticalDispersion_ruleR2 = function(t, neightCell, cell) --concentração:Focal --> local
-- verticalDispersion_ruleR2 = function(t, cell, neightCell) --difusão:local --> Focal
-- verticalDispersion_ruleR2 = function(t, srcCell, tgtCell)
--------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neightSourceCell, neighborTargetCell, centralSourceCell, centralTargetCell)
neighR2Growth = function(t, sourceCell, targetCell, neightSourceCell, neighborTargetCell)
    return K * (desiredValue - neighborTargetCell.stockR1)
end
------------------------------------------------------------------
-- ConnectorS
cs_focalCntR2 = Connector {
    collection = cs,
    attribute = "stockR2",
    neight = "neight3x3"
}
---------------------------------------------------------------
-- Flow OPERATORS
focal_FlowR2 = Flow {
    delta = delta, --0.03125/16,
    rule = neighR2Growth,
    source = nil,
    target = cs_focalCntR2
}






--------------------------------------------------------------------
-- CHANGE RATES AND RULES
-- (df, a, b, delta, sourceCell, targetCell, neightSourceCell, neighborTargetCell, centralSourceCell, centralTargetCell)
neighR1Growth2 = function(t, sourceCell, targetCell, neightSourceCell, neighborTargetCell)
    return neighborTargetCell.stockR2
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
-- (df, a, b, delta, sourceCell, targetCell, neightSourceCell, neighborTargetCell, centralSourceCell, centralTargetCell)
neighR2Growth2 = function(t, sourceCell, targetCell, neightSourceCell, neighborTargetCell)
    return K * (desiredValue - neighborTargetCell.stockR1)
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



--[[
----novo reste
verticalDispersion_ruleR2 = function(t, stock)-- end, stock2)
    return math.sin((2 * math.pi * t) / periodicity + tranlationX) * ((CCcell) / 2) + tranlationY
end

cs_localCntR1 = Connector {
    collection = cs,
    attribute = "stockR1",
    --secundaryAttribute = "stockR2",
    --neight = "neight3x3"
}

cs_localCntR2 = Connector {
    collection = cs,
    attribute = "stockR2",
    --secundaryAttribute = "stockR2",
    --neight = "neight3x3"
}

local_local_flowR1toR2 = {
    rule = verticalDispersion_ruleR2,
    source = cs_localCntR1,
    target = cs_localCntR2
}
]]


-- MODEL EXECUTION

timer:run(10)
--timer:run(1000)
--timer:run(400)
