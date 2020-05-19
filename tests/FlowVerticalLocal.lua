-- Test file for FlowVerticalLocal.lua
-- Author: Amâncio, André Fonseca

return {
    FlowVerticalLocal = function(unitTest)
        --Flow LOCAL cs->cs
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

       local mapCs = Map {
            target = cs,
            select = "stock",
            min = 0,
            max = 100,
            slices = 10,
            color = "Blues"
        }
        local mapCs2 = Map {
            target = cs2,
            select = "stock",
            min = 0,
            max = 100,
            slices = 10,
            color = "Blues"
        }
        ----------------------------------------------------------------------
        -- TIMER INSTANTIATION
        local timer = Timer {
            Event {
                action = function()
                    cs:synchronize()
                    cs2:synchronize()
                    return false
                end
            },
            Event {action = mapCs },
            Event {action = mapCs2 }
        }

        ----------------------------------------------------------------------
        -- CHANGE RATES AND RULES
        local verticalDispersion_rate = 0.5
        local verticalDispersion_rule = function(t, sourceCell, targetCell, neighborSourceCell, neighborTargetCell)
            return verticalDispersion_rate * sourceCell.stock
        end
        ----------------------------------------------------------------------
        -- ConnectorS
        local cs_localCnt = Connector {
            collection = cs,
            attribute = "stock"
        }
        local cs2_localCnt = Connector {
            collection = cs2,
            attribute = "stock"
        }
        ---------------------------------------------------------------
        -- Flow OPERATORS
       local_Flow = Flow {
            rule = verticalDispersion_rule,
            source = cs_localCnt,
            target = cs2_localCnt
        }
        --------------------------------------------------------------
        -- MODEL EXECUTION

        unitTest:assertEquals(cs:get(1, 1).stock, 100, 0.01)
        unitTest:assertEquals(cs:get(5, 5).stock, 100, 0.01)

        timer:run(1)

        --unitTest:assertEquals(cs:get(1, 1).stock, 50, 0.01)
        --unitTest:assertEquals(cs:get(5, 5).stock, 50, 0.01)

        --unitTest:assertEquals(cs2:get(1, 1).stock, 50, 0.01)
        --:assertEquals(cs2:get(5, 5).stock, 50, 0.01)
        --timer:clean()
        --collectgarbage("collect")

        --unitTest:assertSnapshot(fvl.mapCs, "FlowVerticalLocal_mapCs.png", 0.05)
        --unitTest:assertSnapshot(fvl.mapCs2, "FlowVerticalLocal_mapCs2.png", 0.05)
    end
}