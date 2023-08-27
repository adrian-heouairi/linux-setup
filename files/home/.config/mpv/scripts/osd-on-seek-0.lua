function callback()
    pos = mp.get_property_native("time-pos")
    if pos > -0.5 and pos < 0.5 then
        mp.command('show-text "Seeked to 0"')
    end
end

mp.register_event("seek", callback)
