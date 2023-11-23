autoloop = true

function loop()
    if autoloop then
        duration = mp.get_property_native("duration")
        if not duration then return end
        if duration < 600 then
            mp.set_property("loop-file", "yes")
        else
            mp.set_property("loop-file", "no")
        end
    end
end

mp.register_event("file-loaded", loop)

function toggle_autoloop()
    autoloop = not autoloop
    if autoloop then
        mp.command('set loop-file inf')
        mp.command('show-text "Auto-loop short files: yes (also set loop-file to inf)"')
    else
        mp.command('set loop-file no')
        mp.command('show-text "Auto-loop short files: no (also set loop-file to no)"')
    end
end
-- 
-- function disable_autoloop()
--     autoloop = false
--     mp.command('show-text "Set loop file at load if duration < 15:10: no"')
-- end
-- 
-- function enable_autoloop()
--     autoloop = true
--     mp.command('show-text "Set loop file at load if duration < 15:10: yes"')
-- end
-- 
mp.add_key_binding(nil, 'lua-autoloop-toggle', toggle_autoloop)
-- mp.add_key_binding(nil, 'lua-autoloop-disable', disable_autoloop)
-- mp.add_key_binding(nil, 'lua-autoloop-enable', enable_autoloop)
