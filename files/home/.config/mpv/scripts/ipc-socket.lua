sockets_dir = "/tmp/mpv-sockets"

utils = require("mp.utils")

socket = sockets_dir .. "/" .. mp.get_property("pid")

utils.subprocess({ args = { "mkdir", "-p", "--", sockets_dir }, cancellable = false })
mp.set_property('input-ipc-server', socket)

function remove_socket(event)
    utils.subprocess({ args = { "rm", "--", socket }, cancellable = false })
end

mp.register_event("shutdown", remove_socket)
