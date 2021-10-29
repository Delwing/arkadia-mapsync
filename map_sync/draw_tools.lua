img_path = string.gsub("/Users/tomasz/Downloads/projekt-mapper/images/", "\\", "/")

map_sync["draw_tools"] = map_sync["draw_tools"] or {
    ["uniButtonsTable"] = {},
    ["uniWindowsTable"] = {},
    ["uniIconsTable"] = {},
    ["uiDefs"] = {},
    ["draw_tools_turned_on"] = nil -- nil if not initialized, false if turned off, true if turned on
}
