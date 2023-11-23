title = 'cut.lua'

--utils = require("mp.utils")

function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end


function notify(text)
    mp.osd_message(title .. ": " .. text, 15)
end

function get_current_track_index(type)
    for _, track in pairs(mp.get_property_native("track-list")) do
        if track["selected"] and track["type"] == type then
            return tostring(track['ff-index'])
        end
    end
    return 'no'
end

function get_current_audio_track_index()
    return get_current_track_index('audio')
end

function get_current_subtitle_track_index()
    if mp.get_property_native('sub-visibility') == false then return 'no' end
    
    for _, track in pairs(mp.get_property_native("track-list")) do
        if track["selected"] and track["type"] == 'sub' then
            return tostring(track['ff-index']) .. ',' .. tostring(track['id'] - 1)
        end
    end
    return 'no'
end

function cut_common(arguments)
    path = mp.get_property("path", "")
    if not file_exists(path) then
        notify("Error: The currently playing file is not local")
        return false
    end
    
    start_time = mp.get_property_native("ab-loop-a")
    end_time = mp.get_property_native("ab-loop-b")
    if start_time ~= 'no' and start_time < 0 then start_time = 0 end
    
    command = { "cut.sh", '--choose-fullpath', '--choose-title', '--audio-track', get_current_audio_track_index(), '--subtitle-track', get_current_subtitle_track_index() }
    for _, v in ipairs(arguments) do
        table.insert(command, v)
    end
    
    table.insert(command, '--')
    table.insert(command, path)
    
    if start_time ~= 'no' and end_time ~= 'no' then
        table.insert(command, tostring(start_time))
        table.insert(command, tostring(end_time))
    elseif start_time ~= 'no' and end_time == 'no' then
        table.insert(command, tostring(start_time))
    elseif start_time == 'no' and end_time ~= 'no' then
        table.insert(command, '0')
        table.insert(command, tostring(end_time))
    end
    
    notify("Cutting with command: " .. '{ "' .. table.concat(command, '", "') .. '" }')
    
    process = mp.command_native({ name = 'subprocess', args = command, playback_only = false, capture_stdout = true })
    if process.status ~= 0 then
        notify('Cut aborted')
        return false
    end
    notify('Finished, file opened with mpv')
    
    mp.command_native({ 'run', 'sh', '-c', 'cd -- "$(dirname -- "$1")"; mpv --loop-file --pause --force-window --window-minimized -- "$1" & disown', 'sh', tostring(process.stdout:gsub("\n$", "")) })
    
    return true
end

--[[function cut_gif()
    process = utils.subprocess({ args = { "sh", "-c", 'ffmpeg -n -ss "$2" -to "$3" -i "$1" -filter_complex "fps=10,scale=240:-1:flags=lanczos,split [o1] [o2];[o1] palettegen [p]; [o2] fifo [o3];[o3] [p] paletteuse" "$4" 2>&1', "sh", path, start_time2, end_time2, fullpath_to_write_to }, cancellable = false })
end]]--

function script_message_callback(...)
    cut_common({ ... })
end
mp.register_script_message('cut', script_message_callback)
