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
-- dofile("../lua/Connector.lua") --Arquivo deve ser colocado no HOME

DISABLE_CELL_STOCK_LIMIT = true
_DELTA_T = nil
_COLLECTIONS_SYCHRONIZED = nil

-- Flow use guide
-- Add in terraMe: dofile("Flow_Public_Version_5.lua")
-- Create: Cell, CellularSpace, Trajectory or createNeighborhood;
-- Create: timer = Timer{};
-- Call Flows: NON_Connector_Flow(funcRisingWater, 1, finalTime, 1, trajNascente, "water", nil, scGround, "water", nil, model)
-- Finish the model   end } -- END MODEL
-- Run model: MODEL:run()

-- Implements the Euler (Euler-Cauchy) Method to integrate ordinary differential equations.
--  @arg df The differential equantion.
--  @arg initCond The initial condition that must be satisfied.
--  @arg a The value of 'a' in the interval [a,b[.
--  @arg b The value of 'b' of in the interval [a,b[.
--  @arg delta The step of the independent variable.
--  @arg initCondSecundary he initial condition of a secundary variabale that must be satisfied.
-- @usage -- DONTRUN
--  source_FlowintegrationEuler(df, initCond, a, b, delta, initCondSecundary).
local function source_FlowintegrationEuler(df, initCond, a, b, delta, initCondSecundary, initCond3, initCond4)
    local numInitCondituions = 1
    if (initCondSecundary ~= nil) then
        numInitCondituions = numInitCondituions + 1
    end
    if (initCond3 ~= nil) then
        numInitCondituions = numInitCondituions + 1
    end
    if (initCond4 ~= nil) then
        numInitCondituions = numInitCondituions + 1
    end

    --print ("numInitCondituions = ", numInitCondituions)

    if numInitCondituions == 1 then
        if type(df) == "function" then
            local Flow = 0
            local y = initCond
            local x = a
            local bb = b - delta
            for x = a, bb, delta do
                Flow = Flow + delta * df(x, y)
                y = y - delta * df(x, y)
            end
            return Flow
        else
            --local i = 0
            local y = initCond
            local x = a
            local bb = b - delta
            local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
            for x = a, bb, delta do
                for i = 1, #df do
                    values[i] = df[i](x, y)
                end
                for i = 1, #df do
                    Flow = Flow + delta * values[i]
                    y[i] = y[i] - delta * values[i]
                end
            end

            return Flow
        end
    elseif numInitCondituions == 2 then
        if type(df) == "function" then
            local Flow = 0
            local y = initCond
            local z = initCondSecundary
            local x = a
            local bb = b - delta
            for x = a, bb, delta do
                Flow = Flow + delta * df(x, y, z)
                y = y - delta * df(x, y, z)
            end
            return Flow
        else
            --local i = 0
            local y = initCond
            local z = initCondSecundary
            local x = a
            local bb = b - delta
            local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
            for x = a, bb, delta do
                for i = 1, #df do
                    values[i] = df[i](x, y, z)
                end
                for i = 1, #df do
                    Flow = Flow + delta * values[i]
                    y[i] = y[i] - delta * values[i]
                end
            end

            return Flow
        end
    elseif numInitCondituions == 3 then
        if type(df) == "function" then
            local Flow = 0
            local y = initCond
            local z = initCondSecundary
            local w = initCond3
            local x = a
            local bb = b - delta
            for x = a, bb, delta do
                Flow = Flow + delta * df(x, y, z, w)
                y = y - delta * df(x, y, z, w)
            end
            return Flow
        else
            --local i = 0
            local y = initCond
            local z = initCondSecundary
            local w = initCond3
            local x = a
            local bb = b - delta
            local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
            for x = a, bb, delta do
                for i = 1, #df do
                    values[i] = df[i](x, y, z, w)
                end
                for i = 1, #df do
                    Flow = Flow + delta * values[i]
                    y[i] = y[i] - delta * values[i]
                end
            end

            return Flow
        end
    elseif numInitCondituions == 4 then
        if type(df) == "function" then
            local Flow = 0
            local y = initCond
            local z = initCondSecundary
            local w = initCond3
            local t = initCond4
            local x = a
            local bb = b - delta
            for x = a, bb, delta do
                Flow = Flow + delta * df(x, y, z, w, t)
                y = y - delta * df(x, y, z, w, t)
            end
            return Flow
        else
            --local i = 0
            local y = initCond
            local z = initCondSecundary
            local w = initCond3
            local t = initCond4
            local x = a
            local bb = b - delta
            local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
            for x = a, bb, delta do
                for i = 1, #df do
                    values[i] = df[i](x, y, z, w, t)
                end
                for i = 1, #df do
                    Flow = Flow + delta * values[i]
                    y[i] = y[i] - delta * values[i]
                end
            end

            return Flow
        end
    end
end

--[[ --TODO
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
			y4 = df(x + delta, y + delta* y3)
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
end]]

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
-- BehavioralRule(1, 10, 1, nil, nil, nil, nil, nil, nil, nil, nil)
local function BehavioralRule(f, time, delta,
iterator1, iterator1_stock, iterator1_stock2, neight1,
iterator2, iterator2_stock, iterator2_stock2, neight2,
feedbackLoop)
    -- LOCAL OR ZONAL - Each cell in a collection transfers part of its attribute stock at
    -- a rate defined by f (t, y) to the spatially corresponding cell attribute of another collection.
    -- Example: precipitation of cloud water to ground.

    if (iterator1 ~= nil and iterator2 ~= nil) then

        --
        -- BLOCO BehavioralRule
        --
        if neight1 == nil and neight2 == nil then
            local findId0 = false;
            forEachCell(iterator1, function(cell)
                --print('::cell:getId()', cell:getId())
                --print('::tonumber(cell:getId())', tonumber(cell:getId()))
                local UpdPointer = tonumber(cell:getId()) -- +1 --UPDATE DO CABEÇA DE BOI
                if UpdPointer == 0 or findId0 then
                    findId0 = true
                    UpdPointer = UpdPointer + 1
                end
                local initCond = cell.past[iterator1_stock]
                local a = time
                local b = time + delta
                local tempFlow
                --print("feedbackLoop", feedbackLoop)
                if iterator1_stock2 ~= nil then
                    --print("iterator1_stock2 ~= nil")
                    --local initCond2 = cell.past[iterator1_stock2]
                    --tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                    if feedbackLoop == true then
                        --print("iterator1_stock2 ~= nil AND feedbackLoop == true")
                        if iterator2_stock ~= nil then
                            --print("cell", cell)
                            --print("cell.past[iterator1_stock2]", cell.past[iterator1_stock2])
                            local initCond2 = cell.past[iterator1_stock2]
                            --print("iterator2.cells[UpdPointer].past[iterator2_stock]", iterator2.cells[UpdPointer].past[iterator2_stock])
                            local initCondIterator2_stock = iterator2.cells[UpdPointer].past[iterator2_stock]
                            if iterator2_stock2 ~= nil then
                                --print("iterator2.cells[UpdPointer].past[iterator2_stock2]", iterator2.cells[UpdPointer].past[iterator2_stock2])
                                local initCondIterator2_stock2 = iterator2.cells[UpdPointer].past[iterator2_stock2]
                                tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2, initCondIterator2_stock, initCondIterator2_stock2)
                            else
                                tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2, initCondIterator2_stock)
                            end
                        else
                            customError("FeedbackLoop can't be calculate without a attribute. Add at least on attirbute to target.")
                        end
                    else
                        local initCond2 = cell.past[iterator1_stock2]
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                    end

                elseif feedbackLoop == true then
                    --print("iterator1_stock2 == nil AND feedbackLoop == true")
                    --print("iterator1_stock2 ~= nil AND feedbackLoop == true")
                    if iterator2_stock ~= nil then
                        --print("iterator1_stock2 == nil AND feedbackLoop == true AND iterator2_stock ~= nil")
                        --print("iterator2.cells[UpdPointer].past[iterator2_stock]", iterator2.cells[UpdPointer].past[iterator2_stock])
                        local initCondIterator2_stock = iterator2.cells[UpdPointer].past[iterator2_stock]
                        if iterator2_stock2 ~= nil then
                            --print("iterator1_stock2 == nil AND feedbackLoop == true AND iterator2_stock ~= nil AND terator2_stock2 ~= nil")
                            --print("iterator2.cells[UpdPointer].past[iterator2_stock2]", iterator2.cells[UpdPointer].past[iterator2_stock2])
                            local initCondIterator2_stock2 = iterator2.cells[UpdPointer].past[iterator2_stock2]
                            tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCondIterator2_stock, initCondIterator2_stock2)
                        else
                            --print("initCond = ", initCond, "initCondIterator2_stock = ", initCondIterator2_stock)
                            tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCondIterator2_stock)
                            --print("tempFlow", tempFlow)
                        end
                    else
                        customError("FeedbackLoop can't be calculate without a attribute. Add at least on attirbute to target.")
                    end
                else
                    --print("Flow Padrão!!")
                    tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta)
                end
                --Flow subtraction
                --Flow limiter to the stock in the cell
                if iterator2.cells[UpdPointer] ~= nil then --TRAJECTORY COORETION
                    if cell[iterator1_stock] > tempFlow or DISABLE_CELL_STOCK_LIMIT then
                        --print('::iterator1_stock', iterator1_stock, '::cell[iterator1_stock]',cell[iterator1_stock], '::tempFlow',tempFlow)
                        --print('::UpdPointer', UpdPointer, '::iterator2_stock',iterator2_stock, '::iterator1',iterator1, '::tempFlow', tempFlow)
                        cell[iterator1_stock] = cell[iterator1_stock] - tempFlow
                        --Flow sum
                        --print('::UpdPointer', UpdPointer, '::iterator2_stock',iterator2_stock, '::iterator2',iterator2, '::tempFlow', tempFlow)
                        --print('::cell', cell)
                        --print('::iterator2.cells[UpdPointer]', iterator2.cells[1])
                        --print('::iterator2.cells[UpdPointer][iterator2_stock]', iterator2.cells[1][iterator2_stock])
                        --print('::iterator2.cells[UpdPointer]', iterator2.cells[2])
                        --print('::iterator2.cells[UpdPointer][iterator2_stock]', iterator2.cells[2][iterator2_stock])
                        iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    else
                        tempFlow = cell[iterator1_stock]
                        cell[iterator1_stock] = 0
                        --Soma do Flow
                        iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    end
                end
            end)

            -- FOCAL OR ZONAL - Each cell in a collection transfers part of its attribute stock at
            -- a rate defined by f (t, y) to the attributes of cells in the
            -- neighborhood of the spatially corresponding cell of another collection
            -- Example: Heat dispersion in fire propagation modeling.
        elseif neight1 == nil and neight2 ~= nil then
            local findId0 = false;
            forEachCell(iterator1, function(cell)
                --print('::cell', cell)
                --print('::cell:getId()', cell:getId())
                local UpdPointer = tonumber(cell:getId()) -- +1 --UPDATE DO CABEÇA DE BOI
                if UpdPointer == 0 or findId0 then
                    findId0 = true
                    UpdPointer = UpdPointer + 1
                end
                local initCond = cell.past[iterator1_stock]
                local a = time
                local b = time + delta
                --print('::iterator1.cells[UpdPointer]', iterator1.cells[UpdPointer])
                --print('::iterator2.cells[UpdPointer]', iterator2.cells[UpdPointer])
                --print('::iterator1.cells[UpdPointer]', iterator1.cells[UpdPointer + 1])
                --print('::iterator2.cells[UpdPointer]', iterator2.cells[UpdPointer + 1])
                local neighborhoodDestiny = iterator2.cells[UpdPointer]:getNeighborhood(neight2)
                local sizeNeighborhoodDestiny = #neighborhoodDestiny
                local sumWeightNeighborhoodDestiny = 0
                if sizeNeighborhoodDestiny ~= 0 then
                    local tempFlow
                    if iterator1_stock2 ~= nil then
                        local initCond2 = cell.past[iterator1_stock2]
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                    else
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta)
                    end
                    --Flow subtraction - current time
                    --Flow limiter to the stock in the cell
                    if cell[iterator1_stock] > tempFlow or DISABLE_CELL_STOCK_LIMIT then
                        cell[iterator1_stock] = cell[iterator1_stock] - tempFlow
                    else
                        tempFlow = cell[iterator1_stock]
                        cell[iterator1_stock] = 0
                    end
                    forEachNeighbor(iterator2.cells[UpdPointer], neight2, function(_, weight)
                        sumWeightNeighborhoodDestiny = sumWeightNeighborhoodDestiny + weight
                    end)
                    --weighted average
                    forEachNeighbor(iterator2.cells[UpdPointer], neight2, function(neighbor, weight)
                        neighbor[iterator2_stock] = neighbor[iterator2_stock] + tempFlow * weight / sumWeightNeighborhoodDestiny
                    end)
                end
            end)

            -- FOCAL OR ZONAL - Each cell from neighborhood of a collection space transfers part of its attribute stock
            -- at a rate defined by f (t, y) to the cell attribute spatially corresponding to the central cell of the
            -- neighborhood of another collection. Example: Condensation of water in clouds.
        elseif neight1 ~= nil and neight2 == nil then
            local findId0 = false;
            forEachCell(iterator1, function(cell)
                local UpdPointer = tonumber(cell:getId()) -- +1 --UPDATE DO CABEÇA DE BOI
                if UpdPointer == 0 or findId0 then
                    findId0 = true
                    UpdPointer = UpdPointer + 1
                end
                local a = time
                local b = time + delta
                local neighborhoodOrigin = cell:getNeighborhood(neight1)
                local sizeNeighborhoodOrigin = #neighborhoodOrigin
                if sizeNeighborhoodOrigin ~= 0 then
                    forEachNeighbor(cell, neight1, function(neighbor, weight)
                        local initCond = neighbor.past[iterator1_stock]
                        local tempFlow
                        if iterator1_stock2 ~= nil then
                            local initCond2 = neighbor.past[iterator1_stock2]
                            tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                        else
                            tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta)
                        end
                        --local tempFlow = source_FlowintegrationEuler(f,initCond, a, b, delta)
                        --Flow limiter to the stock in the cell
                        if neighbor[iterator1_stock] > tempFlow * weight or DISABLE_CELL_STOCK_LIMIT then
                            neighbor[iterator1_stock] = neighbor[iterator1_stock] - tempFlow * weight
                            iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow * weight
                        else
                            tempFlow = neighbor[iterator1_stock]
                            neighbor[iterator1_stock] = 0
                            iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow * weight
                        end
                    end)
                end
            end)
        elseif neight1 ~= nil and neight2 ~= nil then
            customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
        else
            customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
        end

        --
        -- END BLOCO BehavioralRule
        --
    else
        if (iterator1 == nil and iterator2 == nil) then
            --print ('iterator1 == nil and iterator2 == nil', iterator1, iterator2)
            -- TODO Nada to Nada
            customError("Flow from nothing to nothing not implemented! At least one iterator1 is necessary. Add a iterator1 to Flow call.")

            -- BLOCO BehavioralRule
            --
            if neight1 == nil and neight2 == nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            elseif neight1 == nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            elseif neight1 ~= nil and neight2 == nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            elseif neight1 ~= nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            else
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            end

            --
            -- END BLOCO BehavioralRule
            --

        elseif (iterator1 == nil) then
            --print ('iterator1 == nil', iterator1)
            -- TODO Nada to Collection -- Geracional
            --
            -- BLOCO BehavioralRule
            --
            if neight1 == nil and neight2 == nil then
                forEachCell(iterator2, function(cell)
                    --local UpdPointer = tonumber(cell:getId()) -- +1 --UPDATE DO CABEÇA DE BOI
                    local initCond = cell.past[iterator2_stock]
                    local a = time
                    local b = time + delta
                    local tempFlow
                    --local tempFlow = source_FlowintegrationEuler(f,initCond, a, b, delta)
                    if iterator2_stock2 ~= nil then
                        local initCond2 = cell.past[iterator2_stock2]
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                    else
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta)
                    end
                    --Flow subtraction --IGNORA
                    --Flow limiter to the stock in the cell
                    --if cell[iterator1_stock] > tempFlow then
                    --cell[iterator1_stock] = cell[iterator1_stock] - tempFlow
                    --Flow sum
                    --iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    --else
                    --tempFlow = cell[iterator1_stock]
                    --cell[iterator1_stock] = 0
                    --Soma do Flow
                    --iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    --end
                    cell[iterator2_stock] = cell[iterator2_stock] + tempFlow
                end)

            elseif neight1 == nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            elseif neight1 ~= nil and neight2 == nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            elseif neight1 ~= nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            else
                customErrorMsg("Msg: Operation not yet implemented " .. type(neight2) .. ".", 3)
            end

            --
            -- END BLOCO BehavioralRule
            --

        else
            --print ('iterator2 == nil', iterator2)
            -- TODO Collection to Nada -- Morte
            --
            -- BLOCO BehavioralRule
            --
            if neight1 == nil and neight2 == nil then
                forEachCell(iterator1, function(cell)
                    --local UpdPointer = tonumber(cell:getId()) -- +1 --UPDATE DO CABEÇA DE BOI
                    local initCond = cell.past[iterator1_stock]
                    local a = time
                    local b = time + delta
                    local tempFlow
                    --local tempFlow = source_FlowintegrationEuler(f,initCond, a, b, delta)
                    if iterator1_stock2 ~= nil then
                        local initCond2 = cell.past[iterator1_stock2]
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta, initCond2)
                    else
                        tempFlow = source_FlowintegrationEuler(f, initCond, a, b, delta)
                    end
                    --Flow subtraction
                    --Flow limiter to the stock in the cell
                    if cell[iterator1_stock] > tempFlow then
                        cell[iterator1_stock] = cell[iterator1_stock] - tempFlow
                        --Flow sum - IGNORA A SOMA
                        --iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    else
                        --tempFlow = cell[iterator1_stock]
                        cell[iterator1_stock] = 0
                        --Soma do Flow -- IGNORA A SOMA
                        --iterator2.cells[UpdPointer][iterator2_stock] = iterator2.cells[UpdPointer][iterator2_stock] + tempFlow
                    end
                end)

                -- FOCAL OR ZONAL - Each cell in a collection transfers part of its attribute stock at
                -- a rate defined by f (t, y) to the attributes of cells in the
                -- neighborhood of the spatially corresponding cell of another collection
                -- Example: Heat dispersion in fire propagation modeling.



            elseif neight1 == nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. neight2 .. ".", 3)
            elseif neight1 ~= nil and neight2 == nil then
                customErrorMsg("Msg: Operation not yet implemented " .. neight2 .. ".", 3)
            elseif neight1 ~= nil and neight2 ~= nil then
                customErrorMsg("Msg: Operation not yet implemented " .. neight2 .. ".", 3)
            else
                customErrorMsg("Msg: Operation not yet implemented " .. neight2 .. ".", 3)
            end

            --
            -- END BLOCO BehavioralRule
            --
        end
    end
end

-- @usage synchronizedOptimization(data)
local function synchronizedOptimization(data)
    -- print ("_DELTA_T = ",_DELTA_T)
    if _DELTA_T == nil then
        _DELTA_T = data.eventTime
        if (#data.collection.cells > 0) then
            data.collection:synchronize()
            _COLLECTIONS_SYCHRONIZED = { next = _COLLECTIONS_SYCHRONIZED, value = data.collection }
        end
    elseif _DELTA_T < data.eventTime then
        _DELTA_T = data.eventTime
        if (#data.collection.cells > 0) then
            data.collection:synchronize()
            _COLLECTIONS_SYCHRONIZED = nil
            _COLLECTIONS_SYCHRONIZED = { next = _COLLECTIONS_SYCHRONIZED, value = data.collection }
        end
    elseif _DELTA_T == data.eventTime then
        local alreadySynchronized = false
        local l = _COLLECTIONS_SYCHRONIZED
        while l do
            if _COLLECTIONS_SYCHRONIZED.value == data.collection then
                alreadySynchronized = true
            end
            l = l.next
        end
        if not alreadySynchronized then
            -- print (data.eventTime, "_DELTA_T == data.eventTime SYNK")
            if (#data.collection.cells > 0) then
                data.collection:synchronize()
                _COLLECTIONS_SYCHRONIZED = { next = _COLLECTIONS_SYCHRONIZED, value = data.collection }
            end
            --else
            -- print (data.eventTime, "Collection already synchronized()")
        end
    else
        customError("Erro synchronize optimization.")
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
    if data.timer == nil then -- Não é quando ele não foi criado, mas sim quando ele não foi informado.
        --data.timer =  Timer() --Solução Pedro
        data.timer = ___userDefinedTimer
        --data.timer =  _env.timer --Tentei, mas não deu certo.
        --customError("Atrribute timer is necessary. Add a timer to Flow call.") --PEDRO - versao ssd estão atualmente assim
    end
    if (___userDefinedTimer == nil) then
        customError("A Timer mshould declare a Timer before declaring any FLOW.")
        return false
    end
    --    if data.finalTime == nil then
    --        data.finalTime = 5000
    --    end
    --print ("data.feedbackLoop", data.feedbackLoop)
    if data.feedbackLoop == nil then
        data.feedbackLoop = false
    elseif data.feedbackLoop == true then
        --print ("data.feedbackLoop", data.feedbackLoop)
        --print ("data.source", data.source)
        if data.source == nil then
            customError("Source is necessary. Add a source to Flow call.")
        elseif data.source.collection == nil then
            customError("Collection is nil. FeedbackLoop flow only work with two collections.")
        end
        --print ("data.target", data.target)
        if data.target == nil then
            customError("Target is necessary. Add a target to Flow call.")
        elseif data.target.collection == nil then
            customError("Collection is nil. FeedbackLoop flow only work with two collections.")
        end
    end
    -- Integration interval and steps - AUTO SET
    if data.a == nil then
        data.a = 1
    end
    if data.b == nil then
        --data.b = 5000
    end
    if data.delta == nil then
        data.delta = 1
    end

    --"euler","rungekutta" and "heun"
    if data.method == nil then --TODO implementar os demais métodos
        method = "euler"
    end
    -- fazer chamada assim
    --local result = switch(attrs, "method"):caseof {
    --		euler = function() return integrationEuler(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
    --		rungekutta = function() return integrationRungeKutta(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
    --		heun = function() return integrationHeun(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end
    --	}
end

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
            if (event:getTime() >= 0) then return false end
        end
    })
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
            BehavioralRule(data.rule, event:getTime(), data.delta,
                data.source.collection, data.source.attribute, data.source.secundaryAttribute, data.source.neight,
                data.target.collection, data.target.attribute, data.target.secundaryAttribute, data.target.neight,
                data.feedbackLoop)
            --print ("event:getTime()", event:getTime(), "data.b", data.b)
            if (data.b ~= nil) then
                if (event:getTime() >= data.b) then return false end
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
        -- após o ultimo Flow ser calculado.
        priority = 9,
        action = function(event)
            io.flush()
            if (data.source ~= nil) then
                if (data.source.collection ~= nil) then
                    synchronizedOptimization({ collection = data.source.collection, eventTime = event:getTime() })
                end
            end
            if (data.target ~= nil) then
                if (data.target.collection ~= nil) then
                    synchronizedOptimization({ collection = data.target.collection, eventTime = event:getTime() })
                end
            end
            if (data.b ~= nil) then
                if (event:getTime() >= data.b) then return false end
            end
        end
    })
end

-- TESTE DE FUNCIONAMENTO 1 -- OK--- A Flow operation represents continuous transference of energy between two spatial Connectors.
-- Flow rum creates a Environment and add local timer and global _flowTimer to it and run until finalTime.
-- @arg data.timer local timer.
-- @arg data.finalTime total time of simulation.
-- function FlowRun(data)
-- env = Environment {
-- data.timer,
-- _flowTimerfinalTime
-- }
-- env:run(data.finalTime)
-- end

--END

--TEST 2 -- ADD NO Timer.Lua
--[[runFlow = function(self, finalTime)
        mandatoryArgument(1, "number", finalTime)

        print("#timer:self", #self)
        if finalTime < self.time then
            local msg = "Simulating until a time (" .. finalTime ..
                    ") before the current simulation time (" .. self:getTime() .. ")."
            customWarning(msg)
        end

        print("#_flowTimer", #_flowTimer)
        if #_flowTimer < 1 then
            local msg = "No events on _flowTimer."
            customWarning(msg)
            local flowEnvironment = Environment {
                self
            }
            flowEnvironment:run(finalTime)
        else
            local flowEnvironment = Environment {
                self,
                _flowTimer
            }
            flowEnvironment:run(finalTime)
        end
    end,]]
--


--DONT running
--[[
Timer_ = {
    super = {Timer},
    runFlow = function(self, finalTime)
        mandatoryArgument(1, "number", finalTime)

        print("#timer:self", #self)
        if finalTime < self.time then
            local msg = "Simulating until a time (" .. finalTime ..
                    ") before the current simulation time (" .. self:getTime() .. ")."
            customWarning(msg)
        end

        print("#_flowTimer", #_flowTimer)
        if #_flowTimer < 1 then
            local msg = "No events on _flowTimer."
            customWarning(msg)
            local flowEnvironment = Environment {
                self
            }
            flowEnvironment:run(finalTime)
        else
            local flowEnvironment = Environment {
                self,
                _flowTimer
            }
            flowEnvironment:run(finalTime)
        end
    end,
}]]


-- To overload Timer factory keeping compatibility with previows models, it is necessary to save the original Timer factory before
--- Creates a global timer where the flow events will be storeged ___userDefinedTimer.
___oldTimerFactory = Timer
--print("Timer", Timer, type(Timer))  -- uncomment this line to understand what I am doing
--- Creates a global timer where the flow events will be storeged ___userDefinedTimer.
-- @arg eventsTable A set of Events.
-- @usage timer = Timer{
-- Event{action = function()
-- print("each time step")
-- end},
-- Event{period = 2, action = function()
-- print("each two time steps")
-- end},
-- Event{priority = "high", period = 4, action = function()
-- print("each four time steps")
-- end}
-- }
--
-- timer:run(10)
Timer = function(self, eventsTable) -- overloading

    -- save in a global variable the user defined Timer
    -- NOTE: it will always save the last user define Timer
    ___userDefinedTimer = ___oldTimerFactory(self, eventsTable)

    return ___userDefinedTimer
end