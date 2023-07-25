--function activate()
--    activate = true
--end

--mp.register_event("file-loaded", activate)

function show_sign(property_name, value)
    --if not activate then return end
    
    if value then
        os.execute("sleep .05")
        mp.command('show-text "${osd-ass-cc/0}{\\\\fs70}{\\\\bord2.2}⏸"') -- ne marche pas avec mp.commandv
        -- Window icon
        --os.execute('id=$(wmctrl -lp | awk \'$3 == "\'$PPID\'" { print $1 }\'); [ "$id" ] && xseticon -id "$id" ~/Documents/xseticon/mpv_pause.png')
        -- Window icon end
    else
        mp.command('show-text "${osd-ass-cc/0}{\\\\fs70}{\\\\bord2.2}⏵"')
        -- Window icon
        --os.execute('id=$(wmctrl -lp | awk \'$3 == "\'$PPID\'" { print $1 }\'); [ "$id" ] && xseticon -id "$id" ~/Documents/xseticon/mpv.png')
        -- Window icon end
    end
end

mp.observe_property("pause", "bool", show_sign)
