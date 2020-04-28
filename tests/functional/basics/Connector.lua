-- Test file for FlowVerticalLocal.lua
-- Author: Amâncio, André Fonseca

return {
    Connector = function(unitTest)
        local emptyCell = Cell {
            stock = 0
         }
        local fullCell = Cell {
            stock = 100
        }
        local cs = CellularSpace {
            xdim = 10,
            instance = fullCell
        }
        local cs2 = CellularSpace {
            xdim = 10,
            instance = emptyCell
        }
        local cs_localCnt = Connector {
            collection = cs,
            attribute = "stock"
        }
        unitTest:assertEquals(cs_localCnt.type, "Connector")
        local cs2_localCnt = Connector {
            collection = cs2,
            attribute = "stock"
        }
        unitTest:assertEquals(cs2_localCnt.type, "Connector")
        end;
}