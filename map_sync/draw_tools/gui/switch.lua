function map_sync.draw_tools.draw_tools_on()
    if map_sync.draw_tools.draw_tools_turned_on == nil then
        map_sync.draw_tools.init_main_icons()
        map_sync.draw_tools.init_tools()
    else
        map_sync.draw_tools.uiDefs.toolsContainer:show()
    end
end

function map_sync.draw_tools.draw_tools_off()
    map_sync.draw_tools.uiDefs.toolsContainer:hide()
end

function map_sync.draw_tools.draw_tools_switch()
    if not map_sync.draw_tools.draw_tools_turned_on then
        map_sync.draw_tools.draw_tools_on()
        map_sync.draw_tools.draw_tools_turned_on = true
    else
        map_sync.draw_tools.draw_tools_off()
        map_sync.draw_tools.draw_tools_turned_on = false
    end
end

