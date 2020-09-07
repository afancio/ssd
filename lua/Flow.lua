-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------
-- dofile("../lua/Connector.lua") --Arquivo deve ser colocado na pasta Lua

DISABLE_CELL_STOCK_LIMIT = true
--RULE_CELL_LEVEL_BIGGER_THAN_0 = false --notUsed

ssdGlobals = {}
ssdGlobals.__deltaT = nil
ssdGlobals.__CollectionSynchonized = nil
ssdGlobals.__ssdTimer = Timer()
ssdGlobals.__debugMode = false

--[[
-- Implements the Heun (Euler Second Order) Method to integrate ordinary differential equations.
-- It is a method of type Predictor-Corrector.
-- @arg df The differential equation.
-- @arg initCond The initial condition that must be satisfied.
-- @arg a The value of 'a' in the interval [a,b[.
-- @arg b The value of 'b' of in the interval [a,b[.
-- @arg delta The step of the independent variable.
-- @usage f = function(x) return x^3 end
-- v = integrationHeun(f, 0, 0, 3, 0.1)
function integrationHeun(df, initCond, a, b, delta)
    if type(df) == "function" then
        local y = initCond
        local y1
        local val
        local bb = b - delta
        for x = a, bb, delta do
            val = df(x, y)
            y1 = y + delta * val
            y = y + 0.5 * delta * (val + df(x + delta, y1))
        end

        return y
    else
        local y = initCond
        local bb = b - delta
        local sizeDF = #df
        for x = a, bb, delta do
            local val = {}
            local y1 = {}
            for i = 1, sizeDF do
                val[i] = df[i](x, y)
                y1[i] = y[i] + delta * val[i]
            end

            local values = {}
            for i = 1, sizeDF do
                values[i] = df[i](x + delta, y1)
            end

            for i = 1, sizeDF do
                y[i] = y[i] + 0.5 * delta * (val[i] + values[i])
            end
        end

        return y
    end
end
]]

--[[

-- Implements the Runge-Kutta Method (Fourth Order) to integrate ordinary differential equations.
-- @arg df The differential equation.
-- @arg initCond The initial condition that must be satisfied.
-- @arg a The value of 'a' in the interval [a,b[.
-- @arg b The value of 'b' of in the interval [a,b[.
-- @arg delta The step of the independent variable.
-- @usage f = function(x) return x^3 end
-- v = integrationRungeKutta(f, 0, 0, 3, 0.1)
function integrationRungeKutta(df, initCond, a, b, delta)
    if type(df) == "function" then
        local y = initCond
        local y1
        local y2
        local y3
        local y4
        local bb = b - delta
        local midDelta = 0.5 * delta
        for x = a, bb, delta do
            y1 = df(x, y)
            y2 = df(x + midDelta, y + midDelta * y1)
            y3 = df(x + midDelta, y + midDelta * y2)
            y4 = df(x + delta, y + delta * y3)
            y = y + delta * (y1 + 2 * y2 + 2 * y3 + y4) / 6
        end

        return y
    else
        local y = initCond
        local y1
        local y2
        local y3
        local y4
        local bb = b - delta
        local midDelta = 0.5 * delta
        local sizeDF = #df
        for x = a, bb, delta do
            local yTemp = {}
            local values = {}
            for i = 1, sizeDF do
                yTemp[i] = y[i]
            end

            for i = 1, sizeDF do
                y1 = df[i](x, y)
                yTemp[i] = y[i] + midDelta * y1
                y2 = df[i](x + midDelta, yTemp)
                yTemp[i] = y[i] + midDelta * y2
                y3 = df[i](x + midDelta, yTemp)
                yTemp[i] = y[i] + delta * y3
                y4 = df[i](x + delta, yTemp)
                values[i] = y[i] + delta * (y1 + 2 * y2 + 2 * y3 + y4) / 6
            end

            for i = 1, sizeDF do
                y[i] = values[i]
            end
        end

        return y
    end
end
]]

-- Implements the Euler (Euler-Cauchy) Method to integrate ordinary differential equations.
--  @arg df The differential equantion.
--  @arg initCond The initial condition that must be satisfied.
--  @arg a The value of 'a' in the interval [a,b[.
--  @arg b The value of 'b' of in the interval [a,b[.
--  @arg delta The step of the independent variable.
--  @arg initCondSecundary he initial condition of a secundary variabale that must be satisfied.
-- @usage -- DONTRUN
--  source_FlowintegrationEuler(df, initCond, a, b, delta, initCondSecundary).
--cell.past, data.target.collection.past)--, neighbor.past
local function newFlowintegrationEulerStep(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
    if type(df) == "function" then
        local Flow = 0
        --local y = initCond
        local x = a -- = data.eventTime,
        local bb = b - delta -- data.eventTime + data.delta  - data.delta = data.eventTime
        -- o controle da granularidade fica no evento que vai repetir para cada intervalo
        -- por isso que a frequencia estava baixa... pois a cada intervalo o valor era * 0.0125/64
        -- logo, na chama do flow eu já paticionei o cálculo em data.eventTime/data.delta computações
        for x = a, bb, delta do -- sempre uma única vez logo não precisa do att Y
            Flow = Flow + delta * df(x, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            --não precisa
            --y = y - delta * df(x, cellPast, cellTargetPast, neighborPast, centralNeightCellPast)
        end
        return Flow
    else
        --local i = 0
        local y = initCond
        --local z = initCondSecundary
        --local w = initCond3
        local x = a
        local bb = b - delta
        local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
        for x = a, bb, delta do
            for i = 1, #df do
                values[i] = df[i](x, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            end
            for i = 1, #df do
                Flow = Flow + delta * values[i]
                y[i] = y[i] - delta * values[i]
            end
        end

        return Flow
    end
end

--SEMANTICS (LOCAL -> LOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~=nil) then
--          change = flowIntegration (df, cell.past,
--           targetCell.past)
--          source.cell -=  change
--          targetCell += change
--     end
--end)
local function LocalToLocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, data.target.collection.cells[cellTargetPastId].past, nil, nil)

            cell[data.source.attribute] = cell[data.source.attribute] - change
            data.target.collection.cells[cellTargetPastId][data.target.attribute] =
            data.target.collection.cells[cellTargetPastId][data.target.attribute] + change
        end
    end)
end

--SEMANTICS (LOCAL -> FOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~=nil) then
--         change = flowIntegration (df, cell.past,
--         targetCell.past)
--         source.cell -=  change
--         -- weighted arithmetic mean
--         forEachNeighbor(
--targetCell.neighborhood,
--function(_, weight)
--                 weightNeighborhoodDestiny +=
--                  weight
--         end)
--         forEachNeighbor(
--              targetCell.neighborhood,
--              function(neighbor, weight)
--     	     targetCell += change * weight
--                  /weightNeighborhoodDestiny
--         end)
--     end
--end)
local function LocalToFocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, data.target.collection.cells[cellTargetPastId].past, nil, nil)

            cell[data.source.attribute] = cell[data.source.attribute] - change

            local sizeNeighborhoodDestiny = #data.target.neight
            if sizeNeighborhoodDestiny ~= 0 then
                local sumWeightNeighborhoodDestiny = 0
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight, function(_, weight)
                    sumWeightNeighborhoodDestiny = sumWeightNeighborhoodDestiny + weight
                end)
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight,
                    function(neighbor, weight)
                        neighbor[data.target.attribute] = neighbor[data.target.attribute]
                                + change * weight / sumWeightNeighborhoodDestiny
                    end)
            end
        end
    end)
end


--SEMANTICS (LOCAL -> ZONAL)
--forEachCell(target, function(cell)
--     sourceCell = source[cel.x, cell.y]
--     if (sourceCell ~= nil) then
--          	change = flowIntegration (df, sourceCell.past,
--             cell.past)
--          	sourceCell -=  change
--          	cell  += change
--     end
--end)
local function LocalToZonal(data)
    --print (":::::::::::::::::::::::::::::::LocalToZonal TEST")
    local findId0 = false; --Database collection corretion

    forEachCell(data.target.collection, function(cell) --danger (inverted souce and target)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.source.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                data.source.collection.cells[cellTargetPastId].past, cell.past, nil, nil) -- (inverted souce and target)

            data.source.collection.cells[cellTargetPastId][data.source.attribute] =
            data.source.collection.cells[cellTargetPastId][data.source.attribute]
                    - change --danger (inverted source and target)

            cell[data.target.attribute] = cell[data.target.attribute] + change --danger (inverted souce and target)
        end
    end)
end

--SEMANTICS (FOCAL -> LOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~= nil) then
--        forEachNeighbor(cell.neighborhood,   	function(neighbor, weight)
--         	    change = flowIntegration (df, cell.past,
--                 targetCell.past)
--                 cell -= change * weight
--                 sumNeightChange += change *
--                 weight
--         end)
--         targetCell += sumNeightChange
--     end
--end)
local function FocalToLocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            local sumNeightChange = 0
            forEachNeighbor(cell, data.source.neight, function(neighbor, weight)

                --                local neighborTargetPastId = tonumber(cell:getId())
                --                if neighborTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
                --                    findId0, neighborTargetPastId = true, neighborTargetPastId + 1
                --                end

                --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
                --Events ocur for each delta... one single euler step must be calculated
                --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
                local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                    cell.past, data.target.collection.cells[cellTargetPastId].past,
                    neighbor.past, nil) --data.target.collection.cells[neighborTargetPastId].past) --???

                neighbor[data.source.attribute] = neighbor[data.source.attribute] - change * weight
                sumNeightChange = sumNeightChange + change * weight
            end)

            data.target.collection.cells[cellTargetPastId][data.target.attribute] =
            data.target.collection.cells[cellTargetPastId][data.target.attribute] + sumNeightChange
        end
    end)
end

--SEMANTICS (FOCAL -> FOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~= nil) then
--          forEachNeighbor(cell.neighborhood,
--              function(neighbor, weight)
--                  change = flowIntegration (df, cell.past,
--                  targetCell.past)
--                   cell -= change * weight
--                   sumNeightChange += change * weight
--         end)
--          -- weighted arithmetic mean
--         forEachNeighbor( targetCell.neighborhood,
--             function(_, weight))
--                 weightNeighborhoodDestiny += weight
--         end)
--         forEachNeighbor(targetCell.neighborhood,
--              function(neighbor, weight)
--                   targetCell += sumNeightChange * weight
--                   /weightNeighborhoodDestiny
--          end)
--     end
--end)
local function FocalToFocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            local sumNeightChange = 0
            forEachNeighbor(cell, data.source.neight, function(neighbor, weight)

                local neighborTargetPastId = tonumber(cell:getId())
                if neighborTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
                    findId0, neighborTargetPastId = true, neighborTargetPastId + 1
                end
                --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
                --Events ocur for each delta... one single euler step must be calculated
                --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
                local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                    cell.past, data.target.collection.cells[cellTargetPastId].past,
                    neighbor.past, data.target.collection.cells[neighborTargetPastId].past)

                neighbor[data.source.attribute] = neighbor[data.source.attribute] - change * weight
                sumNeightChange = sumNeightChange + change * weight
            end)

            local sizeNeighborhoodDestiny = #data.target.neight
            if sizeNeighborhoodDestiny ~= 0 then
                local sumWeightNeighborhoodDestiny = 0
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight, function(_, weight)
                    sumWeightNeighborhoodDestiny = sumWeightNeighborhoodDestiny + weight
                end)
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight,
                    function(neighbor, weight)
                        neighbor[data.target.attribute] = neighbor[data.target.attribute]
                                + sumNeightChange * weight / sumWeightNeighborhoodDestiny
                    end)
            end
        end
    end)
end

--SEMANTICS (FOCAL -> ZONAL)
--forEachCell(target, function(cell)
--     sourceCell = source[cel.x, cell.y]
--     if (sourceCell ~= nil) then
--          forEachNeighbor(sourceCell.neihborhood,
--              function(neighbor, weight))
--                  change = flowIntegration (df,
--                  sourceCell.past, cell.past)
--                  sourceCell -= change * weight
--                  sumNeightChange += change * weight
--          end)
--          cell += sumNeightChange
--    end
--end
local function FocalToZonal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.target.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId()) --TODO X AND Y
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.source.collection.cells[cellTargetPastId] ~= nil) then
            local sumNeightChange = 0
            forEachNeighbor(data.source.collection.cells[cellTargetPastId], data.source.neight, function(neighbor, weight)

                --                local neighborTargetPastId = tonumber(cell:getId())
                --                if neighborTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
                --                    findId0, neighborTargetPastId = true, neighborTargetPastId + 1
                --                end

                --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
                --Events ocur for each delta... one single euler step must be calculated
                --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
                local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                    data.source.collection.cells[cellTargetPastId].past, cell.past,
                    neighbor.past, nil)

                neighbor[data.source.attribute] = neighbor[data.source.attribute] - change * weight
                sumNeightChange = sumNeightChange + change * weight
            end)

            cell[data.target.attribute] = cell[data.target.attribute] + sumNeightChange
        end
    end)
end

--SEMANTICS (ZONAL -> LOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~=nil) then
--          change = flowIntegration (df, cell.past,
--          targetCell.past)
--          source.cell -=  change
--          targetCell += change
--     end
--end)
local function ZonalToLocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, data.target.collection.cells[cellTargetPastId].past, nil, nil)

            cell[data.source.attribute] = cell[data.source.attribute] - change
            data.target.collection.cells[cellTargetPastId][data.target.attribute] =
            data.target.collection.cells[cellTargetPastId][data.target.attribute] + change
        end
    end)
end

--SEMANTICS (ZONAL -> FOCAL)
--forEachCell(source, function(cell)
--     targetCell = target[cel.x, cell.y]
--     if (targetCell ~=nil) then
--          change = flowIntegration (df, cell.past,
--          targetCell.past)
--          source.cell -=  change
--         -- weighted arithmetic mean
--         forEachNeighbor(targetCell.neighborhood,
--              function(_, weight))
--                 weightNeighborhoodDestiny +=
--                 weight
--         end)
--         forEachNeighbor(targetCell.neighborhood,
--              function(neighbor, weight))
--                  targetCell += change * weight
--                  /weightNeighborhoodDestiny
--          end)
--     end
--end)
local function ZonalToFocal(data)
    local findId0 = false; --Database collection corretion

    forEachCell(data.source.collection, function(cell)

        local cellTargetPastId = tonumber(cell:getId())
        if cellTargetPastId == 0 or findId0 then --Database collection corretion --TODO based on dcoumentation
            findId0, cellTargetPastId = true, cellTargetPastId + 1
        end

        if (data.target.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, data.target.collection.cells[cellTargetPastId].past, nil, nil)

            cell[data.source.attribute] = cell[data.source.attribute] - change


            local sizeNeighborhoodDestiny = #data.target.neight
            if sizeNeighborhoodDestiny ~= 0 then
                local sumWeightNeighborhoodDestiny = 0
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight, function(_, weight)
                    sumWeightNeighborhoodDestiny = sumWeightNeighborhoodDestiny + weight
                end)
                forEachNeighbor(data.target.collection.cells[cellTargetPastId], data.target.neight,
                    function(neighbor, weight)
                        neighbor[data.target.attribute] = neighbor[data.target.attribute]
                                + change * weight / sumWeightNeighborhoodDestiny
                    end)
            end
        end
    end)
end

--SEMANTICS (ZONAL -> ZONAL)
--target.begin()
--forEachCell(source,  function(cell)
--     if (sourceCell ~=nil and targetCell ~=nil) then
--          change = flowIntegration (df, cell.past,
--          targetCell.past)
--          source.cell -=  change
--          targetCell += change
--     else
--           return false
--     end
--     targetCell = target.next();
--end)
local function ZonalToZonal(data)

    local cellTargetPastId = 1
    targetCell = data.target.collection.cells[cellTargetPastId]

    forEachCell(data.source.collection, function(cell)

        if (cell ~= nil and data.target.collection.cells[cellTargetPastId] ~= nil) then
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, data.target.collection.cells[cellTargetPastId].past, nil, nil)

            cell[data.source.attribute] = cell[data.source.attribute] - change
            data.target.collection.cells[cellTargetPastId][data.target.attribute] =
            data.target.collection.cells[cellTargetPastId][data.target.attribute] + change
        else
            return false
        end

        cellTargetPastId = cellTargetPastId + 1
        targetCell = data.target.collection.cells[cellTargetPastId]
    end)
end


local function NilToLocal(data)

    forEachCell(data.target.collection, function(cell)
        --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
        --Events ocur for each delta... one single euler step must be calculated
        -- (df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
        local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
            nil, cell.past, nil, nil)
        cell[data.target.attribute] = cell[data.target.attribute] + change
    end)
end

local function NilToFocal(data)

    forEachCell(data.target.collection, function(cell)

        forEachNeighbor(cell, data.target.neight, function(neighbor, weight)
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                nil, cell.past, nil, neighbor.past)
            neighbor[data.target.attribute] = neighbor[data.target.attribute] + change * weight
        end)
    end)
end

local function NilToZonal(data)

    forEachCell(data.target.collection, function(cell)
        --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
        --Events ocur for each delta... one single euler step must be calculated
        --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
        local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
            nil, cell.past, nil, nil)
        cell[data.target.attribute] = cell[data.target.attribute] + change
    end)
end


local function LocalToNil(data)
    forEachCell(data.source.collection, function(cell)
        --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
        --Events ocur for each delta... one single euler step must be calculated
        --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
        local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
            cell.past, nil, nil, nil)
        cell[data.source.attribute] = cell[data.source.attribute] - change
    end)
end

local function FocalToNil(data)
    forEachCell(data.source.collection, function(cell)
        forEachNeighbor(cell, data.source.neight, function(neighbor, weight)
            --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
            --Events ocur for each delta... one single euler step must be calculated
            --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
                cell.past, nil, neighbor.past, nil)

            neighbor[data.source.attribute] = neighbor[data.source.attribute] - change * weight
        end)
    end)
end

local function ZonalToNil(data)
    forEachCell(data.source.collection, function(cell)
        --Change is computed from the current eventTime to (eventTime + delta) to garanty de value synchronize
        --Events ocur for each delta... one single euler step must be calculated
        --(df, a, b, delta, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
        local change = newFlowintegrationEulerStep(data.rule, data.eventTime, data.eventTime + data.delta, data.delta,
            cell.past, nil, nil, nil)

        cell[data.source.attribute] = cell[data.source.attribute] - change
    end)
end

-- TODO - Rewrite based in the new implementation
-- Flow Execution or Behavioral rules (BehavioralRules) are executed, that is,
-- TerraME iterates over all cells of the involved collections, applying the differential
-- equations (Flows) defined by the modeler that receive the temporary values as
-- parameters, the results of the equations are written directly on the attributes of cells;
-- Flow operations are classified as local, focal and zonal and their semantics depend on the parameters
-- reported at the moment they are invoked.
--  @arg f f(): Differential equation that describes, as a function of one or two parameters,
--  the rate of change (point derivative) of energy f (t, y) at time t, where t is the simulation current instant time,
--  and y is the past value of the rate of change f ().
-- @arg time b.
-- @arg delta stpe.
-- @arg iterator1 Cellular Space or Trajectory - A collection of cells that will be used to calculate and subtract Flow source.
-- @arg iterator1_stock String - Name of the attribute of the cells contained in the collections of the energy Flow.
-- @arg iterator1_stock2 String - Name of the attribute of the cells contained in the collections of the energy Flow.
-- @arg neight1 vizinhnça.
-- @arg iterator2 Cellular Space or Trajectory - A collection of cells that will be used to calculate and subtract Flow source.
-- @arg iterator2_stock String - Name of the attribute of the cells contained in the collections of the energy Flow.
-- @arg iterator2_stock2 String - Name of the attribute of the cells contained in the collections of the energy Flow.
-- @arg neight2 vizinhnça.
--  a: Number - Beginning of the integration interval.
--  b: Number - End of integration interval.
--  step: Number - An infinitesimal time interval used in numerical integration.
--  Collection1: Cellular Space or Trajectory - A collection of cells that will be used to calculate and subtract Flow source.
--  Attribute1: String - Name of the attribute of the cells contained in the collections over which the Flow will operate.
--  Neight1: Neighborhood - Neighborhood name defined on the source collection of the energy Flow. Optional.
--  Collection2: Cellular Space or Trajectory - Target collection of energy Flow.
--  Attribute2: String - Name of the attribute of the cells contained in the collections of the energy Flow.
--  Neight2: Neighborhood - Neighborhood name defined over the recipient collection of the energy Flow. Optional.
-- @usage import("ssd")
-- BehavioralRule(data)
local function NewBehavioralRule(data)
    if (data.source.collection ~= nil and data.target.collection ~= nil) then
        if type(data.source.collection) == "CellularSpace" and type(data.target.collection) == "CellularSpace" then
            if data.source.neight == nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "LocalToLocal(data)") end -- TESTED (ssdLocalLocal.lua)
                LocalToLocal(data)
            elseif data.source.neight == nil and data.target.neight ~= nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "LocalToFocal(data)") end -- TESTED (ssdFireSpreadHeat.lua)
                LocalToFocal(data)
            elseif data.source.neight ~= nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "FocalToLocal(data)") end -- TESTED (ssdFocalLocal.lua)
                FocalToLocal(data)
            elseif data.source.neight ~= nil and data.target.neight ~= nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "FocalToFocal(data)") end --TESTED (ssdFocalFocal.lua)
                FocalToFocal(data)
            end
        elseif type(data.source.collection) == "CellularSpace" and type(data.target.collection) == "Trajectory" then
            if data.source.neight == nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "LocalToZonal(data)") end --TESTED (ssdLocalZonal.lua)
                LocalToZonal(data)
            elseif type(data.source.neight) ~= nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "FocalToZonal(data)") end --TESTED (ssdFocalZonal.lua)
                FocalToZonal(data)
            end
        elseif type(data.source.collection) == "Trajectory" and type(data.target.collection) == "CellularSpace" then
            if data.source.neight == nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "ZonalToLocal(data)") end --TESTED (ssdZonalLocal.lua)
                ZonalToLocal(data)
            elseif data.source.neight == nil and data.target.neight ~= nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "ZonalToFocal(data)") end --TESTED (ssdZonalFocal.lua)
                ZonalToFocal(data)
            end
        elseif type(data.source.collection) == "Trajectory" and type(data.target.collection) == "Trajectory" then
            if data.source.neight == nil and data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "ZonalToZonal(data)") end --TESTED (ssdZonalZonal.lua)
                ZonalToZonal(data)
            end
        end
    elseif (data.source.collection == nil and data.target.collection ~= nil) then
        if type(data.target.collection) == "CellularSpace" then
            if data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "NilToLocal(data)") end --TESTED (ssdBiomassGrowth.lua)
                NilToLocal(data)
            elseif data.target.neight ~= nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "NilToFocal(data)") end --TESTED (ssdFlowVerticalNilFocalSustainedOscillationPendulumNeigthTrueWrapFeedBackLoop2.lua)
                NilToFocal(data)
            end
        elseif type(data.target.collection) == "Trajectory" then
            if data.target.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "NilToZonal(data)") end --TESTED (ssdBiomassGrowthEmas.lua)
                NilToZonal(data)
            end
        end
    elseif (data.source.collection ~= nil and data.target.collection == nil) then
        if type(data.source.collection) == "CellularSpace" then
            if data.source.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "LocalToNil(data)") end --TESTED (ssdLocalNil.lua)
                LocalToNil(data)
            elseif type(data.source.neight) ~= nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "FocalToNil(data)") end --TESTED (ssdFocalNil.lua)
                FocalToNil(data)
            end
        elseif type(data.source.collection) == "Trajectory" then
            if data.source.neight == nil then
                if ssdGlobals.__debugMode then print(data.eventTime, "ZonalToNil(data)") end -- TESTED (ssdFireSpreadBurning.lua)
                ZonalToNil(data)
            end
        end
    end
end

local function verifyFlowData(data)
    if data.rule == nil then
        customError("Atrribute rule is necessary. Add f = f(x) to Flow call.")
    end
    if data.source == nil then
        data.source = Connector { collection = nil }
    elseif data.source.type ~= "Connector" then
        customError("Invalid type. Flow only work with Connector, got " .. type(data.source.type) .. ".")
    end
    if data.target == nil then
        data.target = Connector { collection = nil }
    elseif data.target.type ~= "Connector" then
        customError("Invalid type. Flow only work with Connector, got " .. type(data.target.type) .. ".")
    end
    if data.timer == nil then
        data.timer = ssdGlobals.__ssdTimer --Solução Andre
    end
    --    if data.finalTime == nil then
    --        data.finalTime = 5000
    --    end
    if data.a == nil then
        data.a = 1
    end
    --if data.b == nil then
    --data.b = 5000
    --end
    if data.delta == nil then
        data.delta = 1
    end
    --"euler","rungekutta" and "heun"
    if data.method == nil then --TODO implementar os demais métodos
        data.method = "euler"
    end
    -- fazer chamada assim
    --local result = switch(attrs, "method"):caseof {
    --		euler = function() return integrationEuler(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
    --		rungekutta = function() return integrationRungeKutta(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
    --		heun = function() return integrationHeun(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end
    --	}
end


Flow_ = {
    type_ = "Flow"
}
metaTableFlow_ = {
    __index = Flow_,
    __tostring = _Gtme.tostring
}
--- A Flow operation represents continuous transference of energy between two spatial Connectors.
-- The differential equation supplied as the first operator parameter determines the amount of energy.
-- transferred between regions. (Pre Stage) At the beginning of the simulation, all collections created by the
-- modeler are synchronized through the TerraME's synchronize() function.
-- @arg data.rule : Differential equation that describes, as a function up to four parameters, the rate of change
--  (point derivative) of energy f (t, stock) at time t, where t is the simulation current instant time, and stock is
--  the past value of the rate of change f (). To one stock uses: f (t, stock), to two stock uses: f (t, stock, stock2),
--  to tree stock uses: f (t, stock, stock2, stock3) and to tree stock uses: f (t, stock, stock2, stock3, stock4).
-- The order of stocks, if they are used, are source.attribute, source.secundaryAttribute, target.attribute
--  and target.secundaryAttribute.
-- @arg data.source : Connector that defines the collection of cells that will be used to calculate the Flow the source.
-- @arg data.target : Connector that defines the collection of cells that will be used to target the calculated Flow
-- from the Flow the source.
-- @arg data.feedbackLoop : boolean control. If true, the souce attributes will be included to flow rule.
-- @usage DONTRUN
-- import("ssd")
-- ---------------------------------------------------------------
-- -- # SPACE # Creation
-- emptyCell = Cell {
-- stock = 0
-- }
-- fullCell = Cell {
-- stock = 100
-- }
-- cs = CellularSpace {
-- xdim = 9,
-- instance = fullCell
-- }
-- cs2 = CellularSpace {
-- xdim = 9,
-- instance = emptyCell
-- }
--
-- mapCs = Map {
-- target = cs,
-- select = "stock",
-- min = 0,
-- max = 100,
-- slices = 10,
-- color = "Blues"
-- }
-- mapCs2 = Map {
-- target = cs2,
-- select = "stock",
-- min = 0,
-- max = 100,
-- slices = 10,
-- color = "Blues"
-- }
-----------------------------------------------------------------
-- -- Timer DECLARATION
-- timer = Timer {
-- Event {
-- action = function()
-- cs:synchronize()
-- cs2:synchronize()
-- return false
-- end
-- },
-- Event { action = mapCs },
-- Event { action = mapCs2 }
-- }
--
-- ----------------------------------------------------------------------
-- -- CHANGE RATES AND RULES
-- verticalDispersion_rate = 0.5
-- verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
-- ----------------------------------------------------------------------
-- -- ConnectorS
-- cs_localCnt = Connector {
-- collection = cs,
-- attribute = "stock"
-- }
-- cs2_localCnt = Connector {
-- collection = cs2,
-- attribute = "stock"
-- }
-- ---------------------------------------------------------------
-- -- Flow OPERATORS
-- local_Flow = Flow {
-- rule = verticalDispersion_rule,
-- source = cs_localCnt,
-- target = cs2_localCnt
-- }
-- timer:run(1)
-- ssdGlobals = nil
function Flow(data)
    data.type = "Flow"
    verifyFlowData(data)
    --print ("data:", data)

    data.timer:add(Event {
        start = 0, -- para dar o sink inicial
        --period = data.delta,
        --priority = 0,
        action = function(event)
            io.flush()
            if (data.source ~= nil) then
                if (data.source.collection ~= nil) then
                    if (data.source.collection.cells[1] ~= nil) then
                        if (data.source.collection.cells[1].past[data.source.attribute] == nil) then
                            data.source.collection:synchronize()
                        end
                    end
                end
            end
            if (data.target ~= nil) then
                if (data.target.collection ~= nil) then
                    if (data.target.collection.cells[1] ~= nil) then
                        if (data.target.collection.cells[1].past[data.target.attribute] == nil) then
                            data.target.collection:synchronize()
                        end
                    end
                end
            end
            if (event:getTime() >= 0) then return false
            end
        end
    })

    if data.delta ~= 1 then

        -- (Stage 1) Flow Execution - Behavioral rules (BehavioralRules) are executed, that is,
        -- TerraME iterates over all cells of the involved collections, applying the differential
        -- equations (Flows) defined by the modeler that receive the temporary values as
        -- parameters, the results of the equations are written directly on the attributes of cells;
        data.timer:add(Event {
            --start = data.a,  --Argument 'start' could be removed as it is the default value (1).
            period = data.delta,
            priority = 1,
            action = function(event)
                io.flush()
                data.eventTime = event:getTime()
                NewBehavioralRule(data)
                if (data.b ~= nil) then
                    if (event:getTime() >= data.b) then return false
                    end
                end
            end
        })
        -- (Stage 2) Synchronization - Temporary copies of the cells of the collections affected by the Flow
        -- are updated instantly, causing the changes to be persisted and to be noticed by the next
        -- computations. All events present in the algorithm remain re-queued until the end time of
        -- the simulation is reached (timer.currentTime == finalSimulationTime).
        data.timer:add(Event {
            --start = data.a, --Argument 'start' could be removed as it is the default value (1).
            period = data.delta, --TODO menor granularidade entre os Flows, assim garante que so haverá sincronização
            priority = 9, --Garatnti that will computed only after every flow of the event time
            action = function(event)
                io.flush()
                if (data.source ~= nil) then
                    if (data.source.collection ~= nil) then
                        --synchronizedOptimization({ collection = data.source.collection, eventTime = event:getTime() })
                        if (#data.source.collection.cells > 0) then
                            data.source.collection:synchronize()
                        end
                    end
                end
                if (data.target ~= nil) then
                    if (data.target.collection ~= nil) then
                        --synchronizedOptimization({ collection = data.target.collection, eventTime = event:getTime() })
                        if (#data.target.collection.cells > 0) then
                            data.target.collection:synchronize()
                        end
                    end
                end
                if (data.b ~= nil) then
                    if (event:getTime() >= data.b) then return false
                    end
                end
            end
        })

    else

        -- (Stage 1) Flow Execution - Behavioral rules (BehavioralRules) are executed, that is,
        -- TerraME iterates over all cells of the involved collections, applying the differential
        -- equations (Flows) defined by the modeler that receive the temporary values as
        -- parameters, the results of the equations are written directly on the attributes of cells;
        data.timer:add(Event {
            --start = data.a,  --Argument 'start' could be removed as it is the default value (1).
            --period = data.delta,
            priority = 1,
            action = function(event)
                io.flush()
                data.eventTime = event:getTime()
                NewBehavioralRule(data)
                if (data.b ~= nil) then
                    if (event:getTime() >= data.b) then return false
                    end
                end
            end
        })
        -- (Stage 2) Synchronization - Temporary copies of the cells of the collections affected by the Flow
        -- are updated instantly, causing the changes to be persisted and to be noticed by the next
        -- computations. All events present in the algorithm remain re-queued until the end time of
        -- the simulation is reached (timer.currentTime == finalSimulationTime).
        data.timer:add(Event {
            --start = data.a, --Argument 'start' could be removed as it is the default value (1).
            --period = data.delta, --TODO menor granularidade entre os Flows, assim garante que so haverá sincronização
            priority = 9, --Garatnti that will computed only after every flow of the event time
            action = function(event)
                io.flush()
                if (data.source ~= nil) then
                    if (data.source.collection ~= nil) then
                        --synchronizedOptimization({ collection = data.source.collection, eventTime = event:getTime() })
                        if (#data.source.collection.cells > 0) then
                            data.source.collection:synchronize()
                        end
                    end
                end
                if (data.target ~= nil) then
                    if (data.target.collection ~= nil) then
                        --synchronizedOptimization({ collection = data.target.collection, eventTime = event:getTime() })
                        if (#data.target.collection.cells > 0) then
                            data.target.collection:synchronize()
                        end
                    end
                end
                if (data.b ~= nil) then
                    if (event:getTime() >= data.b) then return false
                    end
                end
            end
        })
    end
    setmetatable(data, metaTableFlow_)
end

--[[
oldTimer_ = Timer_ --store old
Timer_.run = function(self, finalTime) --overwrite the old function

    addFlowEvents(self)

    mandatoryArgument(1, "number", finalTime)

    if finalTime < self.time then
        local msg = "Simulating until a time (" .. finalTime ..
                ") before the current simulation time (" .. self:getTime() .. ")."
        customWarning(msg)
    end

    while true do
        if getn(self.events) == 0 then return
        end

        local ev = self.events[1]
        if ev.time > finalTime then
            self.time = finalTime
            return
        end

        self.time = ev.time

        table.remove(self.events, 1)

        local result = ev.action(ev, self)

        if result == false or ev.period == 0 then
            ev.parent = nil
        else
            ev.time = ev.time + ev.period

            local floor = math.floor(ev.time)
            local ceil = math.ceil(ev.time)

            if math.abs(ev.time - floor) < sessionInfo().round then
                ev.time = floor
            elseif math.abs(ev.time - ceil) < sessionInfo().round then
                ev.time = ceil
            end
            self:add(ev)
        end
    end
end
]]

