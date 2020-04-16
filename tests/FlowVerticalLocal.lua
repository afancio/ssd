-- Test file for FlowVerticalLocal.lua
-- Author: Amâncio, André Fonseca

return {
    FlowVerticalLocal = function(unitTest)
        --Flow LOCAL cs->cs
        emptyCell = Cell {
            stock = 0
        }
        fullCell = Cell {
            stock = 100
        }
        cs = CellularSpace {
            xdim = 10,
            instance = fullCell
        }
        cs2 = CellularSpace {
            xdim = 10,
            instance = emptyCell
        }

        mapCs = Map {
            target = cs,
            select = "stock",
            min = 0,
            max = 100,
            slices = 10,
            color = "Blues"
        }
        mapCs2 = Map {
            target = cs2,
            select = "stock",
            min = 0,
            max = 100,
            slices = 10,
            color = "Blues"
        }
        ----------------------------------------------------------------------
        -- TIMER INSTANTIATION
        timer = Timer {
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
        verticalDispersion_rate = 0.5
        verticalDispersion_rule = function(t, stock) return verticalDispersion_rate * stock end
        ----------------------------------------------------------------------
        -- ConnectorS
        cs_localCnt = Connector {
            collection = cs,
            attribute = "stock"
        }
        cs2_localCnt = Connector {
            collection = cs2,
            attribute = "stock"
        }
        ---------------------------------------------------------------
        -- Flow OPERATORS
        local_Flow = Flow {
            rule = verticalDispersion_rule,
            source = cs_localCnt,
            target = cs2_localCnt,
            timer = timer
        }
        --------------------------------------------------------------
        -- MODEL EXECUTION

        unitTest:assertEquals(cs:get(1, 1).stock, 100, 0.01)
        unitTest:assertEquals(cs:get(5, 5).stock, 100, 0.01)

        timer:run(1)

        unitTest:assertEquals(cs:get(1, 1).stock, 50, 0.01)
        unitTest:assertEquals(cs:get(5, 5).stock, 50, 0.01)

        unitTest:assertEquals(cs2:get(1, 1).stock, 50, 0.01)
        unitTest:assertEquals(cs2:get(5, 5).stock, 50, 0.01)

        --unitTest:assertSnapshot(fvl.mapCs, "FlowVerticalLocal_mapCs.png", 0.05)
        --unitTest:assertSnapshot(fvl.mapCs2, "FlowVerticalLocal_mapCs2.png", 0.05)
    end
}