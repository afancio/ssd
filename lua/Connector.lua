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
------------------------------------------------------------------------------------------- g
local function verifyConnectorData(data)
    if data.collection ~= nil then
        if type(data.collection) == "CellularSpace" or type(data.collection) == "Trajectory" then
            if data.attribute == nil then
                customError("Atrribute is necessary once a collection is definided. Add attribute = 'attribute name' to Connector definition.")
            end
        else
            customError("Invalid type. Flow only work with CellularSpace, Trajectory got " .. type(data.target) .. ".")
        end

        if data.neight ~= nil then
            --if data.collection == nil then
            --    customError("Collection is necessary once a neight is definided. Add collection = 'collection name' to Connector definition.")
            --end
            if data.attribute == nil then
                customError("Atrribute is necessary once a neight is definided. Add attribute = 'attribute name' to Connector definition.")
            end
        end

        if data.secundaryAttribute ~= nil then
            --if data.collection == nil then
            --    customError("Collection is necessary once a neight is definided. Add collection = 'collection name' to Connector definition.")
            --end
            if data.attribute == nil then
                customError("Atrribute is necessary once a neight is definided. Add attribute = 'attribute name' to Connector definition.")
            end
        end
    else
        data.attribute = nil
        data.secundaryAttribute = nil
        data.neight = nil
    end
    --print("verifyConnectorData::data.collection", data.collection)
    --print("verifyConnectorData::data.attribute", data.attribute)
    --print("verifyConnectorData::data.neight", data.neight)
end


--- A Connector operation represents an target ou source of nergy, information or matter of a spatial region.
-- @arg data.collection : Cellular Space or Trajectory - A collection of cells that will be used to calculate the Flow source or target.
-- @arg data.attribute : String - Name of the attribute of the cells contained in the collections over which the Flow will operate.
-- @arg data.secundaryAttribute : String - Name of the attribute of the cells contained in the collections over which the Flow will operate. Optional.
-- @arg data.neight : Neighborhood - Neighborhood name defined on the collection of the energy Flow. Optional.
-- @usage -- DONTRUN
-- import("ssd")
-- cell = Cell {
-- stock = 100
-- }
-- cell2 = Cell {
-- stock = 0
-- }
-- cs = CellularSpace {
-- xdim = 3,
-- instance = cell
-- }
-- cs2 = CellularSpace {
-- xdim = 3,
-- instance = cell2
-- }
-- timer = Timer {
-- Event {
-- action = function()
-- cs:synchronize()
-- cs2:synchronize()
-- return false
-- end
-- },
-- }
-- -- ConnectorS
-- cs_localCnt = Connector {
-- collection = cs,
-- attribute = "stock"
-- }
-- cs2_localCnt = Connector {
-- collection = cs2,
-- attribute = "stock"
-- }
-- -- Flow OPERATORS
-- vertical_local_Flow = Flow {
-- rule = function(t, stock) return 0.5 * stock end,
-- source = cs_localCnt,
-- target = cs2_localCnt,
-- timer = timer
-- }
-- -- MODEL EXECUTION
-- timer:run(1)
function Connector(data)
    data.type = "Connector"
    verifyConnectorData(data)
    return data
end