function map_sync.draw_tools.get_rooms_to_annotate()
    local rooms_to_annotate = {}
    if amap.curr.id then
        table.insert(rooms_to_annotate, amap.curr.id)
    end

    local current_map_selection = getMapSelection()

    if current_map_selection and current_map_selection["rooms"] then
        for _, v in pairs(current_map_selection["rooms"]) do
            table.insert(rooms_to_annotate, v)
        end
    end

    return rooms_to_annotate
end

function map_sync.draw_tools.button_color_listener(color)
    if not color then
        error("wrong input in map_sync.draw_tools.button_color_listener")
        return
    end

    local rooms_to_color = map_sync.draw_tools.get_rooms_to_annotate()
    for _, v in pairs(rooms_to_color) do
        setRoomEnv(v, color)
    end
end

function map_sync.draw_tools.button_symbol_listener(symbol)
    if not symbol then
        error("wrong input in map_sync.draw_tools.button_symbol_listener")
        return
    end

    local rooms_to_symbol = map_sync.draw_tools.get_rooms_to_annotate()
    for _, v in pairs(rooms_to_symbol) do
        setRoomChar(v, symbol)
    end
end

