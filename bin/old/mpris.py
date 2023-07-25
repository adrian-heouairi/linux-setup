#!/bin/python3

# We always use unique dbus bus names in the service_name variable like ":1.67" and never well-known names such as "org.mpris.MediaPlayer2.gmusicbrowser"

import os

from pathlib import Path; home = str(Path.home()); mpris_bookmarks_dir = home + "/Documents/mpris_bookmarks"
if not os.path.exists(mpris_bookmarks_dir): os.mkdir(mpris_bookmarks_dir)
player_service_well_known_name = "org.mpris.MediaPlayer2.gmusicbrowser"
excluded_services_identity = ["gmusicbrowser"]
icon_default = "multimedia-audio-player"
my_service_name = "py.mpris"
my_object_name = "/py/mpris"
progress_bar_precision = 20
progress_bar_full_char = "█"
progress_bar_empty_char = "░"
progress_bar_bookmark_char = "|"
playback_status_symbols = {"Playing": "⏵", "Paused": "⏸", "Stopped": "⏹"}

import dbus, dbus.service, re, urllib.parse
from gi import require_version
require_version("Notify", "0.7")
require_version("Gtk", "3.0")
from gi.repository import Notify, Gtk, GLib # GLib
from dbus.mainloop.glib import DBusGMainLoop

Notify.init("mpris.py")
#notification = Notify.Notification.new("")
#notification.set_timeout(2000)

##statusicon = Gtk.StatusIcon.new_from_icon_name(icon_default)

service_in_memory = ""
DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
mpris_service_regex = re.compile("^org\.mpris\.MediaPlayer2\..+")
alive_services = {}
notifications_disabled = False
keyboard_shortcut = False
keyboard_shortcut_timeout_id = None

def microseconds_to_minutes_seconds(microseconds):
    microseconds_in_seconds = microseconds / 1000000
    floor = int(microseconds_in_seconds)
    decimal_part = microseconds_in_seconds - floor
    minutes = int(floor / 60)
    seconds = floor % 60
    return str(minutes) + ":" + format(seconds, "02d") + format(decimal_part, ".2f")[1:]

def ellipsize_filename(filename):
    if len(filename.encode("utf_8")) > 200:
        while len(filename.encode("utf_8")) > 195:
            middle_position = len(filename) // 2
            filename = filename[:middle_position] + filename[middle_position + 1:]
        
        middle_position = len(filename) // 2
        filename = filename[:middle_position] + " ... " + filename[middle_position:]
    
    return filename

def get_bookmark_fullpaths(service_name):
    bookmark_filename_from_url = ""
    bookmark_filename_from_tags = ""
    bookmark_fullpath_from_url = ""
    bookmark_fullpath_from_tags = ""
    
    dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
    metadata = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Metadata", dbus_interface="org.freedesktop.DBus.Properties")
    
    if "xesam:url" in metadata:
        decoded_url = urllib.parse.unquote(metadata["xesam:url"])
        if re.match("^file://", decoded_url):
            bookmark_filename_from_url = re.match(".+/(.+)", decoded_url).group(1)
            match = re.match("(.+)\..{3,4}$", bookmark_filename_from_url)
            if match: bookmark_filename_from_url = match.group(1)
        else: bookmark_filename_from_url = decoded_url.replace("/", "／")
        bookmark_filename_from_url = bookmark_filename_from_url.replace("\n", "\\n")
        if bookmark_filename_from_url: bookmark_fullpath_from_url = mpris_bookmarks_dir + "/" + ellipsize_filename(bookmark_filename_from_url)
    
    if "xesam:title" in metadata and "xesam:artist" in metadata:
        if metadata["xesam:title"] and metadata["xesam:artist"][0]:
            bookmark_filename_from_tags = metadata["xesam:artist"][0] + " - " + metadata["xesam:title"]
    elif "xesam:title" in metadata: bookmark_filename_from_tags = metadata["xesam:title"]
    bookmark_filename_from_tags = bookmark_filename_from_tags.replace("/", "／").replace("\n", "\\n")
    if bookmark_filename_from_tags: bookmark_fullpath_from_tags = mpris_bookmarks_dir + "/" + ellipsize_filename(bookmark_filename_from_tags)
    
    if bookmark_fullpath_from_url == bookmark_fullpath_from_tags:
        if bookmark_fullpath_from_url: return [bookmark_fullpath_from_url]
        else: return []
    else:
        list_to_return = []
        if bookmark_fullpath_from_url: list_to_return.append(bookmark_fullpath_from_url)
        if bookmark_filename_from_tags: list_to_return.append(bookmark_fullpath_from_tags)
        return list_to_return

def refresh_bookmarks(service_name):
    global alive_services
    
    bookmark_fullpaths = get_bookmark_fullpaths(service_name)
    for bookmark_fullpath in bookmark_fullpaths:
        if os.path.isfile(bookmark_fullpath):
            with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
            if file_contents:
                alive_services[service_name]["bookmarks"] = file_contents
                return
    
    alive_services[service_name]["bookmarks"] = ""

def refresh_metadata_history(service_name, metadata, notify=False):
    global alive_services
    
    notify2 = False
    title_changed = False
    
    media_title = ""
    if "xesam:title" in metadata: media_title = metadata["xesam:title"]
    if media_title == "" and "xesam:url" in metadata:
        media_title = urllib.parse.unquote(metadata["xesam:url"])
        if re.match("^file://", media_title): media_title = re.match(".+/(.*)", media_title).group(1)
    if media_title == "": media_title = "<Unknown title>" # '<' and not '&lt;' because otherwise the escaping would be done twice
    media_title = media_title.replace("&", "&amp;").replace("<", "&lt;") # replace '&' first or else it would hinder my '&lt;'
    if "title" in alive_services[service_name]:
        if alive_services[service_name]["title"] != media_title:
            alive_services[service_name]["title_old"] = alive_services[service_name]["title"]
            notify2 = True
            title_changed = True
    else: notify2 = True
    alive_services[service_name]["title"] = media_title
    if "title_old" not in alive_services[service_name]: alive_services[service_name]["title_old"] = ""
    
    media_artist = ""
    if "xesam:artist" in metadata:
        media_artist = metadata["xesam:artist"][0]
        media_artist = media_artist.replace("&", "&amp;").replace("<", "&lt;")
    if "artist" in alive_services[service_name]:
        if alive_services[service_name]["artist"] != media_artist or title_changed:
            alive_services[service_name]["artist_old"] = alive_services[service_name]["artist"]
            notify2 = True
    else: notify2 = True
    alive_services[service_name]["artist"] = media_artist
    if "artist_old" not in alive_services[service_name]: alive_services[service_name]["artist_old"] = ""
    
    if "mpris:length" in metadata: alive_services[service_name]["length"] = metadata["mpris:length"]
    elif "length" in alive_services[service_name]: del alive_services[service_name]["length"]
    
    refresh_bookmarks(service_name)
    
    #if notify and notify2: emit_notification(service_name)

def put_service_in_memory(service_name):
    print("put_service_in_memory: Launched")
    global service_in_memory
    
    service_in_memory = service_name
    
    if service_name:
        print("put_service_in_memory: Putting the service '" + service_name + "' in memory and setting the icon to " + alive_services[service_name]["desktop_entry"])
        ##statusicon.set_from_icon_name(alive_services[service_name]["desktop_entry"])
    else:
        print("put_service_in_memory: Emptying the service in memory and changing the icon back to default")
        ##statusicon.set_from_icon_name(icon_default)

def emit_notification(service_name, notification_body=None, position=None):
    if notifications_disabled: return
    
    notification_title = alive_services[service_name]["identity"]
    
    progress_bar = ""
    if "length" in alive_services[service_name]:
        length = alive_services[service_name]["length"]
        if length > 0:
            if position == None:
                dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
                position = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Position", dbus_interface="org.freedesktop.DBus.Properties")
            if position < 0: position = 0
            
            #print("Debug: sending notification with position " + str(position))
            
            progress_step = round(position * progress_bar_precision / length)
            progress_bar = progress_bar_full_char * progress_step + progress_bar_empty_char * (progress_bar_precision - progress_step)
            
            bookmarks = alive_services[service_name]["bookmarks"]
            if bookmarks:
                bookmarks_int_list = list(map(int, bookmarks.split(" ")))
                progress_bar_list = list(progress_bar)
                progress_bar_counter = 0
                for i in bookmarks_int_list:
                    bookmark_bar_position = round(i * progress_bar_precision / length) + progress_bar_counter
                    progress_bar_list.insert(bookmark_bar_position, progress_bar_bookmark_char)
                    progress_bar_counter += 1
                progress_bar = "".join(progress_bar_list)
            
            progress_bar = progress_bar + "\n"
            
            position_in_seconds = round(position / 1000000)
            length_in_seconds = round(length / 1000000)
            progression = "[" + str(int(position_in_seconds / 60)) + ":" + format(position_in_seconds % 60, "02d") + "/" + str(int(length_in_seconds / 60)) + ":" + format(length_in_seconds % 60, "02d") + "]"
            notification_title = progression + " — " + notification_title
    
    if notification_body == None:
        notification_body = "<b>" + alive_services[service_name]["title"] + "</b>"
        
        #======================================== LoopStatus and Shuffle, it is safe to wholly delete this block
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        
        loop_status_symbols = {"None": "∅", "Track": "🔂", "Playlist": "≣"}
        try: loop_status = dbus_object.Get("org.mpris.MediaPlayer2.Player", "LoopStatus", dbus_interface="org.freedesktop.DBus.Properties")
        except: pass
        else: notification_body = loop_status_symbols[loop_status] + " " + notification_body
        
        try: shuffle = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Shuffle", dbus_interface="org.freedesktop.DBus.Properties")
        except: pass
        else:
            if shuffle: shuffle_symbol = "🔀"
            else: shuffle_symbol = "🠯"
            notification_body = shuffle_symbol + " " + notification_body
        #======================================== LoopStatus and Shuffle end
        
        if alive_services[service_name]["artist"]: notification_body += "\n" + alive_services[service_name]["artist"]
        #if alive_services[service_name]["title_old"]:
            #notification_body += "\n" + "─" * 20 + "\n<b>⏮ " + alive_services[service_name]["title_old"] + "</b>"
            #if alive_services[service_name]["artist_old"]: notification_body += "\n" + alive_services[service_name]["artist_old"]
    
    #notification_title = playback_status_symbols[alive_services[service_name]["playback_status"]] + " " + notification_title
    
    notification_body = progress_bar + notification_body
    
    notification = Notify.Notification.new("")
    notification.set_timeout(1000)
    notification.update(notification_title, notification_body, alive_services[service_name]["desktop_entry"])
    notification.show()

def property_change(interface_name, properties, signature, service_name): # interface_name is the name of the interface of the properties
    #print("Debug:", properties)
    
    if "PlaybackStatus" in properties: alive_services[service_name]["playback_status"] = properties["PlaybackStatus"]
    if "Metadata" in properties: refresh_metadata_history(service_name, properties["Metadata"], notify=True)
    
    if keyboard_shortcut:
        notification_body = ""
        if "Rate" in properties: notification_body = "Speed: " + format(properties["Rate"], ".2f")
        #elif "Volume" in properties: notification_body = "Volume: " + str(round(properties["Volume"] * 100)) + " %"
        elif "Volume" in properties: notification_body = "Volume: " + format(properties["Volume"] * 100, ".2f") + " %"
        #elif "LoopStatus" in properties: notification_body = "Loop status: " + properties["LoopStatus"]
        #elif "Shuffle" in properties:
            #if properties["Shuffle"]: shuffle_tmp = "True"
            #else: shuffle_tmp = "False"
            #notification_body = "Shuffle: " + shuffle_tmp
        #if notification_body: emit_notification(service_name, notification_body=notification_body)
        
        #if "PlaybackStatus" in properties: emit_notification(service_name)
        #if "PlaybackStatus" in properties or "LoopStatus" in properties or "Shuffle" in properties: emit_notification(service_name)
    
    if "PlaybackStatus" in properties:
        if alive_services[service_name]["identity"] not in excluded_services_identity:
            if properties["PlaybackStatus"] == "Playing" and service_in_memory != service_name: put_service_in_memory(service_name)
            elif properties["PlaybackStatus"] == "Paused" or properties["PlaybackStatus"] == "Stopped":
                refresh_alive_services()
                look_for_playing_service()

def seeked(new_position, service_name):
    if keyboard_shortcut: emit_notification(service_name, position=new_position)

def look_for_playing_service():
    #print("look_for_playing_service: Launched")
    for service_name in list(alive_services):
        if alive_services[service_name]["playback_status"] == "Playing" and alive_services[service_name]["identity"] not in excluded_services_identity:
            print("look_for_playing_service: Found a playing service: ", service_name)
            put_service_in_memory(service_name)
            return True
    
    #print("look_for_playing_service: Found no playing service")
    return False

def look_for_any_service():
    print("look_for_any_service: Launched")
    if look_for_playing_service(): return

    for service_name in list(alive_services):
        if alive_services[service_name]["identity"] not in excluded_services_identity:
            print("look_for_any_service: Found a non-playing service: ", service_name)
            put_service_in_memory(service_name)
            return
    
    print("look_for_any_service: Found no service, emptying memory")
    put_service_in_memory("")

def refresh_alive_services(*args):
    global alive_services
    
    for service_name in list(alive_services):
        try: bus.get_object(service_name, "/org/mpris/MediaPlayer2").Ping(dbus_interface="org.freedesktop.DBus.Peer")
        except:
            print("refresh_alive_services: Disconnecting from " + service_name)
            del alive_services[service_name]
    
    for service_well_known_name in list(filter(mpris_service_regex.match, bus.list_names())):
        service_name = bus.get_name_owner(service_well_known_name)
        if service_name not in alive_services:
            print("refresh_alive_services: Connecting to " + service_well_known_name + " (" + service_name + ")")
            
            dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
            dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
            
            alive_services[service_name] = {}
            alive_services[service_name]["identity"] = dbus_interface.Get("org.mpris.MediaPlayer2", "Identity")
            if not(alive_services[service_name]["identity"]): alive_services[service_name]["identity"] = "Unknown player"
            try: alive_services[service_name]["desktop_entry"] = dbus_interface.Get("org.mpris.MediaPlayer2", "DesktopEntry")
            except: alive_services[service_name]["desktop_entry"] = "unknown"
            else:
                if not(alive_services[service_name]["desktop_entry"]): alive_services[service_name]["desktop_entry"] = "unknown"
            alive_services[service_name]["playback_status"] = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus")
            metadata = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")
            refresh_metadata_history(service_name, metadata)
            
            dbus_interface.connect_to_signal("PropertiesChanged", property_change, sender_keyword="service_name")
            dbus_interface2 = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
            dbus_interface2.connect_to_signal("Seeked", seeked, sender_keyword="service_name")
            
            if alive_services[service_name]["identity"] not in excluded_services_identity:
                if alive_services[service_name]["playback_status"] == "Playing": put_service_in_memory(service_name)
                elif service_in_memory == "": put_service_in_memory(service_name)
    
    if service_in_memory:
        try: bus.get_object(service_in_memory, "/org/mpris/MediaPlayer2").Ping(dbus_interface="org.freedesktop.DBus.Peer")
        except:
            print("refresh_alive_services: The service currently in memory (" + service_in_memory + ") died, looking for another one")
            look_for_any_service()

    return True

refresh_alive_services()
GLib.timeout_add_seconds(1, refresh_alive_services)
#======================================== My D-Bus service
def keyboard_shortcut_set_to_false(*args):
    global keyboard_shortcut, keyboard_shortcut_timeout_id
    keyboard_shortcut = False
    keyboard_shortcut_timeout_id = None

def keyboard_shortcut_pressed():
    global keyboard_shortcut, keyboard_shortcut_timeout_id

    keyboard_shortcut = True

    if keyboard_shortcut_timeout_id != None: GLib.source_remove(keyboard_shortcut_timeout_id)
    keyboard_shortcut_timeout_id = GLib.timeout_add(500, keyboard_shortcut_set_to_false)

def service_alias_to_unique_name(service_name_alias):
    if service_name_alias == "other_players": return service_in_memory
    elif service_name_alias == "player":
        try: return bus.get_name_owner(player_service_well_known_name)
        except: return ""
    else:
        try: bus.get_object(service_name_alias, "/org/mpris/MediaPlayer2").Ping(dbus_interface="org.freedesktop.DBus.Peer")
        except: return ""
        if re.match("^:[0-9]+\.[0-9]+$", service_name_alias): return service_name_alias
        else: return bus.get_name_owner(service_name_alias)

class MyDBusService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(my_service_name, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, my_object_name)

    #@dbus.service.method(my_service_name) # TODO
    #def GetServiceInMemory(self): return service_in_memory

    #@dbus.service.method(my_service_name)
    #def ToggleNotifications(self):
        #global notifications_disabled
        #notifications_disabled = not(notifications_disabled)
    
    #@dbus.service.method(my_service_name)
    #def ShowCustomNotification(self, service_name_alias, notification_body):
        #service_name = service_alias_to_unique_name(service_name_alias)
        #if not(service_name): return
    
        #emit_notification(service_name, notification_body=notification_body)
    
    @dbus.service.method(my_service_name)
    def ShowNotification(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        emit_notification(service_name)
    
    @dbus.service.method(my_service_name)
    def RunMethod(self, service_name_alias, method_name):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        dbus_interface.get_dbus_method(method_name)()
    
    @dbus.service.method(my_service_name)
    def ChainRunMethods(self, service_name_alias, method_names):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        for method_name in method_names.split(" "): dbus_interface.get_dbus_method(method_name)()
    
    @dbus.service.method(my_service_name)
    def Seek(self, service_name_alias, microseconds):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        
        identity = dbus_object.Get("org.mpris.MediaPlayer2", "Identity", dbus_interface="org.freedesktop.DBus.Properties")
        if identity == "Firefox Web Browser":
            metadata = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Metadata", dbus_interface="org.freedesktop.DBus.Properties")
            position = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Position", dbus_interface="org.freedesktop.DBus.Properties")
            position_new = position + int(microseconds)
            if position_new < 0: position_new = 0
            dbus_interface.SetPosition(metadata["mpris:trackid"], position_new)
        else:
            position = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Position", dbus_interface="org.freedesktop.DBus.Properties")
            if position + int(microseconds) < 0:
                metadata = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Metadata", dbus_interface="org.freedesktop.DBus.Properties")
                dbus_interface.SetPosition(metadata["mpris:trackid"], 0)
            else: dbus_interface.Seek(microseconds)
    
    @dbus.service.method(my_service_name)
    def Restart(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        metadata = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        dbus_interface.SetPosition(metadata["mpris:trackid"], 0)
        dbus_interface.Play()
        
        GLib.timeout_add(180, lambda: emit_notification(service_name)) # SetPosition 0 → Seeked signal with position 0 (good), but the Position property may be updated a bit later → if the player was paused, as this method does Play, after SetPosition, a second notification is emitted because PlaybackStatus changed, but because the Position property is queried → notification with the position before launching Restart
    
    @dbus.service.method(my_service_name)
    def MultiplySpeed(self, service_name_alias, multiplicator):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        speed = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Rate")
        dbus_interface.Set("org.mpris.MediaPlayer2.Player", "Rate", speed * float(multiplicator))
    
    @dbus.service.method(my_service_name)
    def SetSpeed(self, service_name_alias, speed):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        dbus_interface.Set("org.mpris.MediaPlayer2.Player", "Rate", float(speed))
    
    @dbus.service.method(my_service_name)
    def AddVolume(self, service_name_alias, volume_to_add):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        volume = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Volume")
        
        volume_new = volume + float(volume_to_add)
        if volume_new < 0.0: volume_new = 0.0
        elif volume < 1.0 and 1.0 < volume_new: volume_new = 1.0
        
        dbus_interface.Set("org.mpris.MediaPlayer2.Player", "Volume", volume_new)
    
    @dbus.service.method(my_service_name)
    def CycleLoopStatus(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        loop_status = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "LoopStatus")
        if loop_status == "None": dbus_interface.Set("org.mpris.MediaPlayer2.Player", "LoopStatus", "Track")
        elif loop_status == "Track": dbus_interface.Set("org.mpris.MediaPlayer2.Player", "LoopStatus", "Playlist")
        elif loop_status == "Playlist": dbus_interface.Set("org.mpris.MediaPlayer2.Player", "LoopStatus", "None")
    
    @dbus.service.method(my_service_name)
    def ToggleTrackLooping(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        loop_status = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "LoopStatus")
        if loop_status == "Track" and "loop_status_old" in alive_services[service_name]:
            dbus_interface.Set("org.mpris.MediaPlayer2.Player", "LoopStatus", alive_services[service_name]["loop_status_old"])
        if loop_status == "None" or loop_status == "Playlist":
            alive_services[service_name]["loop_status_old"] = loop_status
            dbus_interface.Set("org.mpris.MediaPlayer2.Player", "LoopStatus", "Track")
    
    @dbus.service.method(my_service_name)
    def ToggleShuffle(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        shuffle = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Shuffle")
        dbus_interface.Set("org.mpris.MediaPlayer2.Player", "Shuffle", not(shuffle))
    
    @dbus.service.method(my_service_name)
    def AddBookmarkHere(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        
        bookmark_fullpaths = get_bookmark_fullpaths(service_name)
        if not(bookmark_fullpaths): return
        #print("Debug: Writing bookmark to: ", bookmark_fullpaths)
        
        try: position = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Position")
        except: return
        if position < 0: position = 0
        position_str = str(position)
        
        wrote_bookmarks = False
        for bookmark_fullpath in bookmark_fullpaths:
            bookmarks = []
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents: bookmarks = file_contents.split(" ")
            if position_str in bookmarks: continue
            bookmarks = bookmarks + [position_str]
            bookmarks = sorted(bookmarks, key=int)
            with open(bookmark_fullpath, "w") as f: f.write(" ".join(bookmarks))
            wrote_bookmarks = True
        if wrote_bookmarks:
            refresh_bookmarks(service_name)
            emit_notification(service_name, notification_body="Bookmark added at position " + microseconds_to_minutes_seconds(position)) #+ "\nWrote to " + str(bookmark_fullpaths))
        else: emit_notification(service_name, notification_body="No bookmark written")
    
    @dbus.service.method(my_service_name)
    def SeekToPreviousBookmark(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        
        bookmark_fullpaths = get_bookmark_fullpaths(service_name)
        if not(bookmark_fullpaths): return
        bookmarks = []
        for bookmark_fullpath in bookmark_fullpaths:
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents:
                    bookmarks = file_contents.split(" ")
                    break
        if not(bookmarks):
            emit_notification(service_name, notification_body="There are no bookmarks")
            return
        bookmarks_int = list(map(int, bookmarks))
        
        try: position = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Position")
        except: position = 0
        if position < 0: position = 0
        position_tmp = position - 5000000
        
        bookmark_to_seek_to = bookmarks_int[-1]
        for bookmark in reversed(bookmarks_int):
            if position_tmp > bookmark:
                bookmark_to_seek_to = bookmark
                break
        
        metadata = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        dbus_interface.Pause() # Workaround for Audacious
        dbus_interface.SetPosition(metadata["mpris:trackid"], bookmark_to_seek_to)
        dbus_interface.Play()
    
    @dbus.service.method(my_service_name)
    def SeekToNextBookmark(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        keyboard_shortcut_pressed()
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        
        bookmark_fullpaths = get_bookmark_fullpaths(service_name)
        if not(bookmark_fullpaths): return
        bookmarks = []
        for bookmark_fullpath in bookmark_fullpaths:
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents:
                    bookmarks = file_contents.split(" ")
                    break
        if not(bookmarks):
            emit_notification(service_name, notification_body="There are no bookmarks")
            return
        bookmarks_int = list(map(int, bookmarks))
        
        try: position = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Position")
        except: position = 0
        if position < 0: position = 0
        position_tmp = position + 5000000
        
        bookmark_to_seek_to = bookmarks_int[0]
        for bookmark in bookmarks_int:
            if position_tmp < bookmark:
                bookmark_to_seek_to = bookmark
                break
        
        metadata = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")
        dbus_interface = dbus.Interface(dbus_object, "org.mpris.MediaPlayer2.Player")
        dbus_interface.Pause() # Workaround for Audacious
        dbus_interface.SetPosition(metadata["mpris:trackid"], bookmark_to_seek_to)
        dbus_interface.Play()
    
    @dbus.service.method(my_service_name)
    def RemoveBookmark(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
        
        bookmark_fullpaths = get_bookmark_fullpaths(service_name)
        if not(bookmark_fullpaths): return
    
        try: position = dbus_interface.Get("org.mpris.MediaPlayer2.Player", "Position")
        except: return
        if position < 0: position = 0
        
        wrote_bookmarks = False
        for bookmark_fullpath in bookmark_fullpaths:
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if not(file_contents): continue
                bookmarks_int = list(map(int, file_contents.split(" ")))
                bookmark_to_delete_found = False
                for bookmark in list(bookmarks_int):
                    if position <= bookmark:
                        bookmarks_int.remove(bookmark)
                        bookmark_to_delete_found = True
                        break
                if not(bookmark_to_delete_found): del bookmarks_int[0]
                bookmarks = list(map(str, bookmarks_int))
                if bookmarks:
                    with open(bookmark_fullpath, "w") as f: f.write(" ".join(bookmarks))
                else: os.remove(bookmark_fullpath)
                wrote_bookmarks = True
        
        if wrote_bookmarks:
            refresh_bookmarks(service_name)
            emit_notification(service_name, notification_body="Bookmark removed") #, wrote to:\n" + str(bookmark_fullpaths))
        else: emit_notification(service_name, notification_body="No bookmark removed")
    
    @dbus.service.method(my_service_name)
    def GetFullpath(self, service_name_alias):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        metadata = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Metadata", dbus_interface="org.freedesktop.DBus.Properties")
        
        if "xesam:url" in metadata:
            match = re.match("^file://(/.+)", metadata["xesam:url"])
            if match: return urllib.parse.unquote(match.group(1))
    
    @dbus.service.method(my_service_name)
    def GetMetadataField(self, service_name_alias, metadata_field):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        
        metadata = dbus_object.Get("org.mpris.MediaPlayer2.Player", "Metadata", dbus_interface="org.freedesktop.DBus.Properties")
        if metadata_field in metadata: return metadata[metadata_field]

    @dbus.service.method(my_service_name)
    def GetProperty(self, service_name_alias, mpris_property):
        service_name = service_alias_to_unique_name(service_name_alias)
        if not(service_name): return
        
        dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
        
        try: return dbus_object.Get("org.mpris.MediaPlayer2.Player", mpris_property, dbus_interface="org.freedesktop.DBus.Properties")
        except: pass

my_dbus_service_instance = MyDBusService()
#======================================== My D-Bus service end
Gtk.main()
