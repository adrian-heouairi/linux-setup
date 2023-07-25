-- To bind in input.conf: Ctrl+a script-binding cut-audio

title = 'mpv-cut.lua'

--utils = require("mp.utils")

function notify(text)
    mp.osd_message(title .. ": " .. text, 3600)
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
    if not (path:match('^/')) then
        notify("Error: The currently playing file is not local")
        return false
    end
    --[[dir, filename = utils.split_path(path)
    if #dir == 0 then
        notify("Error: The current file is not local")
        return false
    end]]--
    
    start_time = mp.get_property_native("ab-loop-a")
    end_time = mp.get_property_native("ab-loop-b")
    
    if start_time == 'no' then start_time = 0 end
    if start_time < 0 then start_time = 0 end
    
    command = { "cut.sh", '--choose-fullpath', '--choose-title', '--no-open', '--audio-track', get_current_audio_track_index(), '--subtitle-track', get_current_subtitle_track_index() }
    for _, v in ipairs(arguments) do
        table.insert(command, v)
    end
    --[[if file_type == "audio" then
        command = { "cut.sh", '--choose-fullpath', '--no-open', '--directory', default_directory, '--audio-track', get_current_audio_track_index(), '--', path, tostring(start_time) }
    elseif file_type == "video" then
        command = { "cut.sh", '--choose-fullpath', '--no-open', '--video', '--directory', default_directory, '--audio-track', get_current_audio_track_index(), '--subtitle-track', get_current_subtitle_track_index(), '--', path, tostring(start_time) }
    else
        return false
    end--]]
    
    table.insert(command, '--')
    table.insert(command, path)
    table.insert(command, tostring(start_time))
    
    if end_time ~= 'no' then table.insert(command, tostring(end_time)) end
    --notify("Cutting with command: " .. utils.to_string(command))
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

--[[
function cut_gif()
    process = utils.subprocess({ args = { "sh", "-c", 'ffmpeg -n -ss "$2" -to "$3" -i "$1" -filter_complex "fps=10,scale=240:-1:flags=lanczos,split [o1] [o2];[o1] palettegen [p]; [o2] fifo [o3];[o3] [p] paletteuse" "$4" 2>&1', "sh", path, start_time2, end_time2, fullpath_to_write_to }, cancellable = false })
end
--if path:match('.+[.]mp3$') then
--utils.subprocess_detached({ args = { 'mpv', '--loop-file', '--pause', '--force-window', '--window-minimized', '--', process.stdout:gsub("\n$", "") }, cancellable = false })
]]--
--directory_to_write_to = utils.subprocess({ args = { "zenity", "--title=mpv cut", "--file-selection", "--directory", "--filename=" .. default_directory }, cancellable = false }).stdout:gsub("\n$", "")
    --[[directory_to_write_to = tostring(mp.command_native({ name = 'subprocess', args = { "kdialog", "--title=" .. title, "--getexistingdirectory", "--", default_directory }, playback_only = false, capture_stdout = true }).stdout:gsub("\n$", ""))
    if directory_to_write_to == "" or directory_to_write_to == nil then
        notify("Cancelled")
        return false
    end]]--
    --fullpath_to_write_to = utils.join_path(directory_to_write_to, filename_to_write_to)

--function cut_best_quality_mp3()
--    cut_common("/tmp", { '--format', 'mp3,default', '--ffmpeg-options', '-q:a 0' })
--end
--function cut_custom_aac()
--    cut_common("/tmp", { '--format', 'aac,default', '--ffmpeg-options', '-b:a 256k' }) -- 256 kbps instead of the default 128 kbps (doesn't change quality whatsoever)
--end

--[[function cut_mp3()
    cut_common("/home/abc/Downloads/Phone/Music/Musique", { '--format', 'mp3,default' })
end
function cut_h264()
    cut_common("/home/abc/D/My_videos", { '--format', 'mp4,aac,h264' })
end
function cut_webm()
    cut_common("/home/abc/D/My_videos", { '--format', 'webm,default,default', '--ffmpeg-options', '-metadata title=' })
end
function cut_hevc()
    cut_common("/home/abc/D/My_videos", { '--format', 'mp4,aac,hevc' })
end
mp.add_key_binding("Ctrl+Shift+m", 'cut-audio', cut_mp3)
mp.add_key_binding("Ctrl+Shift+$", 'cut-video', cut_h264)
mp.add_key_binding("Ctrl+Shift+w", 'cut-webm', cut_webm)
mp.add_key_binding("Ctrl+Shift+%", 'cut-hevc', cut_hevc)--]]

--[[function on_script_message(event)
    if (event.args)[1] == 'mpv-cut' then
        cut_common("/tmp", ) -- Second argument should be event.args without its first element
    end
end
mp.register_event('client-message', on_script_message)--]]
function script_message_callback(...)
    cut_common({ ... })
end
mp.register_script_message('mpv-cut', script_message_callback)
mp.register_script_message('cut', script_message_callback)
