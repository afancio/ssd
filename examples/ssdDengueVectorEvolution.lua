-- @example The model shows changes in the number of mosquitoes per stage of life: Eggs, Larvas, Pulps and Mosquitos.
--  Each cell has the temperature (based on cell position (x+y*5) = 0 to 40) parameters that control the
--  evolution of each stage.
-- Stage changes and mortality rates are described through the interpretation of the equations [Lana et. al 2011] and
-- are based on the temperature parameter.
-- Reference: Lana, R. M., T. G. Carneiro, N. A. Honório, and C. T. Codeço. (2011) “Multiscale Analysis and Modelling
-- of Aedes aegyti Population Spatial Dynamics”. Journal of Information and Data Management 2 (2): 211.
-- @image ssdDengueVectorEvolution4Graphs.png

import("ssd")

---------------------------------------------------------------
-- # SPACE # Creation
cell = Cell {
    temperature = 30,
    eggs = 600, --random:integer(0, 600),--600,--random:integer(0, 600),
    m1 = 0,
    larvas = 0,
    m2 = 0,
    pulps = 0,
    m3 = 0,
    mosquitos = 0,
    m4 = 0
}

csField = CellularSpace {
    xdim = 4,
    instance = cell,
    step = 0,
    init = function()
        forEachCell(csField, function(cell)
            cell.temperature = (cell.x + cell.y) * 5
        end)
    end
}

csField:init()

summary = Cell {
    xdim = 5,
    step = 0,
    eggsTotal = 0,
    larvasTotal = 0,
    pulpsTotal = 0,
    mosquitosTotal = 0,
    m1TotalEggsDeath = 0,
    m2TotalLarvasDeath = 0,
    m3TotalPulpsDeath = 0,
    m4TotalMosquitosDeath = 0
}

mapTemperature = Map {
    title = "Temperature by cell",
    target = csField,
    select = "temperature",
    min = 0,
    max = 45,
    slices = 10,
    color = "Spectral",
    invert = true
}

mapMosquitos = Map {
    title = "Total mosquitos by cell",
    target = csField,
    select = "mosquitos",
    min = 0,
    max = 110,
    slices = 10,
    color = "Reds"
}

chartSummary = Chart {
    target = summary,
    select = { "eggsTotal", "larvasTotal", "pulpsTotal", "mosquitosTotal" },
    label = { "eggsTotal", "larvasTotal", "pulpsTotal", "mosquitosTotal" },
    title = "Total by dengue vector stage",
    xLabel = "Step",
    yLabel = "Amount"
}

chartSummaryM = Chart {
    target = summary,
    select = { "m1TotalEggsDeath", "m2TotalLarvasDeath", "m3TotalPulpsDeath", "m4TotalMosquitosDeath" },
    label = { "m1TotalEggsDeath", "m2TotalLarvasDeath", "m3TotalPulpsDeath", "m4TotalMosquitosDeath" },
    title = "Total deaths by dengue vector stage",
    xLabel = "Step",
    yLabel = "Amount"
}

---------------------------------------------------------------
-- Timer DECLARATION
timer = Timer {
    Event {
        action = function()
            --csField:init()
            csField:synchronize()
            return false
        end
    },
    Event { action = summary },
    Event { action = mapTemperature },
    Event { action = mapMosquitos },
    Event { action = chartSummary },
    Event { action = chartSummaryM },

    Event {
        --time = 1,
        --period = 1,
        priority = 9,
        action = function(event)
            --delay_s(DELAY)
            summary.eggsTotal = 0
            summary.larvasTotal = 0
            summary.pulpsTotal = 0
            summary.mosquitosTotal = 0
            summary.m1TotalEggsDeath = 0
            summary.m2TotalLarvasDeath = 0
            summary.m3TotalPulpsDeath = 0
            summary.m4TotalMosquitosDeath = 0
            summary.step = event:getTime()
            --SUMMARY
            forEachCell(csField, function(cell)
                summary.eggsTotal = summary.eggsTotal + cell.eggs
                summary.larvasTotal = summary.larvasTotal + cell.larvas
                summary.pulpsTotal = summary.pulpsTotal + cell.pulps
                summary.mosquitosTotal = summary.mosquitosTotal + cell.mosquitos
                summary.m1TotalEggsDeath = summary.m1TotalEggsDeath + cell.m1
                summary.m2TotalLarvasDeath = summary.m2TotalLarvasDeath + cell.m2
                summary.m3TotalPulpsDeath = summary.m3TotalPulpsDeath + cell.m3
                summary.m4TotalMosquitosDeath = summary.m4TotalMosquitosDeath + cell.m4
            end)

            print('TIME:', summary.step)
            print('summary.eggsTotal:', summary.eggsTotal)
            print('summary.m1TotalEggsDeath:', summary.m1TotalEggsDeath)
            print('summary.larvasTotal:', summary.larvasTotal)
            print('summary.m2TotalLarvasDeath:', summary.m2TotalLarvasDeath)
            print('summary.pulpsTotal:', summary.pulpsTotal)
            print('summary.m3TotalPulpsDeath:', summary.m3TotalPulpsDeath)
            print('summary.mosquitosTotal', summary.mosquitosTotal)
            print('summary.m4TotalMosquitosDeath:', summary.m4TotalMosquitosDeath)

            return true
        end
    },
}

---------------------------------------------------------------
-- CHANGE RATES AND RULES
txO1 = 0.01 -- 0,0003333333
funcO1 = function(t, stock, stock2) return txO1 * stock * stock2 end

txO2 = 0.0042424242 -- 0,0001388889
funcO2 = function(t, stock, stock2) return txO2 * stock * stock2 end

txO3 = 0.0104848485 --0,0003588889
funcO3 = function(t, stock, stock2) return txO3 * stock * stock2 end

txM1 = 1 / 100
funcFlowM1 = function(t, stock) return txM1 * stock end
txM2 = 1 / 3
funcFlowM2 = function(t, stock) return txM2 * stock end
txM3 = 1 / 70
funcFlowM3 = function(t, stock) return txM3 * stock end
txM4 = 1 / 17.5
funcFlowM4 = function(t, stock) return txM4 * stock end

---------------------------------------------------------------
-- Connectors and Flow OPERATORS

--Flow (funcFlowM1, 1, 20, 1, csField, "eggs", nil, csField, "m1", nil)
eachEggs = Connector {
    collection = csField,
    attribute = "eggs"
}

eachDeadEggs = Connector {
    collection = csField,
    attribute = "m1"
}
eggsDeath = Flow {
    rule = funcFlowM1,
    source = eachEggs,
    target = eachDeadEggs
}

--Flow (funcO1, 1, 20, 1, csField, "eggs", nil, csField, "larvas", nil)
eachEggsAndTemperature = Connector {
    collection = csField,
    attribute = "eggs",
    secundaryAttribute = "temperature"
}

eachLarvas = Connector {
    collection = csField,
    attribute = "larvas"
}

eggsToLarvas = Flow {
    rule = funcO1,
    source = eachEggsAndTemperature,
    target = eachLarvas
}

--Flow (funcFlowM2, 1, 20, 1, csField, "larvas", nil, csField, "m2", nil)
eachDeadLarvas = Connector {
    collection = csField,
    attribute = "m2"
}

larvasDeath = Flow {
    rule = funcFlowM2,
    source = eachLarvas,
    target = eachDeadLarvas
}

--Flow (funcO2, 1, 20, 1, csField, "larvas", nil, csField, "pulps", nil)
eachLarvasAndTemperature = Connector {
    collection = csField,
    attribute = "larvas",
    secundaryAttribute = "temperature"
}

eachPulps = Connector {
    collection = csField,
    attribute = "pulps"
}

larvasTopulps = Flow {
    rule = funcO2,
    source = eachLarvasAndTemperature,
    target = eachPulps
}

--Flow (funcFlowM3, 1, 20, 1, csField, "pulps", nil, csField, "m3", nil)
eachDeadPulps = Connector {
    collection = csField,
    attribute = "m3"
}

pulpsDeath = Flow {
    rule = funcFlowM3,
    source = eachPulps,
    target = eachDeadPulps
}

--Flow (funcO3, 1, 20, 1, csField, "pulps", nil, csField, "mosquitos", nil)
eachPulpsAndTemperature = Connector {
    collection = csField,
    attribute = "pulps",
    secundaryAttribute = "temperature"
}

eachMosquitos = Connector {
    collection = csField,
    attribute = "mosquitos"
}

pulpsToMosquitos = Flow {
    rule = funcO3,
    source = eachPulpsAndTemperature,
    target = eachMosquitos
}

--Flow (funcFlowM4, 1, 20, 1, csField, "mosquitos", nil, csField, "m4", nil)

pulpsDeath = Flow {
    rule = funcFlowM4,
    source = eachMosquitos,
    target = nil
}

timer:run(40)
--ssdGlobals = nil
