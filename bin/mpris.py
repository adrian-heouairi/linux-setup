#!/bin/python3

# We always use unique dbus bus names in the current_service variable like ":1.67" and never well-known names such as "org.mpris.MediaPlayer2.gmusicbrowser"

import os

from pathlib import Path; home = str(Path.home()); mpris_bookmarks_dir = home + "/D/Shared-ST-apho/Music/mpris-bookmarks"
if not os.path.exists(mpris_bookmarks_dir): os.makedirs(mpris_bookmarks_dir, exist_ok=True)

my_service = "py.mpris"
my_object_name = "/py/mpris"
progress_bar_precision = 17
progress_bar_full_char = "█"
progress_bar_empty_char = "░"
progress_bar_bookmark_char = "|"

import dbus, dbus.service, re, urllib.parse
from gi import require_version
require_version("Notify", "0.7")
require_version("Gtk", "3.0")
from gi.repository import Notify, Gtk, GLib
from dbus.mainloop.glib import DBusGMainLoop

Notify.init("mpris.py")

statusicon = Gtk.StatusIcon.new_from_icon_name("black-white")
statusicon.set_visible(False)
#statusicon.set_from_icon_name(icon_default)

DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
mpris_service_regex = re.compile("^org\.mpris\.MediaPlayer2\..+")

current_service = ""
alive_services = []
#===============================================================================
def ellipsize_string(string):
    if len(string.encode("utf_8")) > 200:
        while len(string.encode("utf_8")) > 195:
            middle_position = len(string) // 2
            string = string[:middle_position] + string[middle_position + 1:]
        
        middle_position = len(string) // 2
        string = string[:middle_position] + " ... " + string[middle_position:]
    
    return string

def windows_illegal_chars_to_fullwidth(string):
    string.replace('|', '｜')
    string.replace('<', '＜')
    string.replace('>', '＞')
    string.replace('?', '？')
    string.replace('"', '＂')
    string.replace('*', '＊')
    string.replace(':', '：')
    string.replace('\\', '＼')
    string.replace('/', '／')
    return string

def remove_newlines_from_string(string):
    string.replace("\n", "＼n")
    string.replace("\r", "＼r")
    return string

def prepare_filename(filename):
    filename = windows_illegal_chars_to_fullwidth(filename)
    filename = remove_newlines_from_string(filename)
    return ellipsize_string(filename)
#===============================================================================
def get_object():
    return bus.get_object(current_service, "/org/mpris/MediaPlayer2")

def get_property(prop):
    dbus_interface = dbus.Interface(get_object(), "org.freedesktop.DBus.Properties")
    return dbus_interface.Get("org.mpris.MediaPlayer2", prop)

def get_property_player(prop):
    dbus_interface = dbus.Interface(get_object(), "org.freedesktop.DBus.Properties")
    return dbus_interface.Get("org.mpris.MediaPlayer2.Player", prop)

def get_property2(prop, service_name):
    dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
    dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
    return dbus_interface.Get("org.mpris.MediaPlayer2", prop)

def get_property_player2(prop, service_name):
    dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
    dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
    return dbus_interface.Get("org.mpris.MediaPlayer2.Player", prop)

# Returns an int or None
def get_length():
    metadata = get_property_player("Metadata")
    if "mpris:length" in metadata: return metadata["mpris:length"]
    return None
#===============================================================================
def get_bookmark_fullpaths():
    metadata = get_property_player("Metadata")
    
    if "xesam:url" in metadata:
        decoded_url = urllib.parse.unquote(metadata["xesam:url"])
        if re.match("^file://", decoded_url):
            bookmark_filename_from_url = re.match(".+/(.+)", decoded_url).group(1)
            # COMMENT THESE TWO LINES TO HAVE FILENAME EXTENSIONS NOT REMOVED
            #match = re.match("(.+)\..{3,4}$", bookmark_filename_from_url)
            #if match: bookmark_filename_from_url = match.group(1)
            # END
        else: bookmark_filename_from_url = decoded_url
        bookmark_filename_from_url = prepare_filename(bookmark_filename_from_url)
        return [mpris_bookmarks_dir + "/" + bookmark_filename_from_url + ".txt"]
    return []
    
#     if "xesam:title" in metadata and "xesam:artist" in metadata:
#         if metadata["xesam:title"] and metadata["xesam:artist"][0]:
#             bookmark_filename_from_tags = metadata["xesam:artist"][0] + " - " + metadata["xesam:title"]
#     elif "xesam:title" in metadata: bookmark_filename_from_tags = metadata["xesam:title"]
#     bookmark_filename_from_tags = bookmark_filename_from_tags.replace("/", "／").replace("\n", "\\n")
#     if bookmark_filename_from_tags: bookmark_fullpath_from_tags = mpris_bookmarks_dir + "/" + ellipsize_filename(bookmark_filename_from_tags)
#     
#     if bookmark_fullpath_from_url == bookmark_fullpath_from_tags:
#         if bookmark_fullpath_from_url: return [bookmark_fullpath_from_url]
#         else: return []
#     else:
#         list_to_return = []
#         if bookmark_fullpath_from_url: list_to_return.append(bookmark_fullpath_from_url)
#         if bookmark_filename_from_tags: list_to_return.append(bookmark_fullpath_from_tags)
#         return list_to_return

def get_bookmarks():
    bookmark_fullpaths = get_bookmark_fullpaths()
    for bookmark_fullpath in bookmark_fullpaths:
        if os.path.isfile(bookmark_fullpath):
            with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
            if file_contents: return file_contents
    return ""

def refresh_bookmarks_statusicon():
    if get_bookmarks(): statusicon.set_visible(True)
    else: statusicon.set_visible(False)
#===============================================================================
def emit_notification(notification_body=None, position=None):
    notification_title = get_property("Identity")
    
    progress_bar = ""
    length = get_length()
    if length:
        if length > 0:
            if position == None:
                try: position = get_property_player("Position")
                except: position = 0
            if position < 0: position = 0
            
            progress_step = round(position * progress_bar_precision / length)
            progress_bar = progress_bar_full_char * progress_step + progress_bar_empty_char * (progress_bar_precision - progress_step)
            
            bookmarks = get_bookmarks()
            if bookmarks:
                bookmarks_int_list = list(map(int, bookmarks.split(" ")))
                progress_bar_list = list(progress_bar)
                progress_bar_counter = 0
                for i in bookmarks_int_list:
                    bookmark_bar_position = round(i * progress_bar_precision / length) + progress_bar_counter
                    progress_bar_list.insert(bookmark_bar_position, progress_bar_bookmark_char)
                    progress_bar_counter += 1
                progress_bar = "".join(progress_bar_list)
    
    real_notification_body = progress_bar
    if notification_body: real_notification_body = real_notification_body + "\n" + notification_body
    
    notification = Notify.Notification.new("")
    notification.set_timeout(1000)
    notification.update(notification_title, real_notification_body, get_property("DesktopEntry"))
    notification.show()
#===============================================================================
def set_current_service(service):
    global current_service
    current_service = service
    
    if service: refresh_bookmarks_statusicon()

# interface_name is the name of the interface of the properties
# signature is ignored
# service_name looks like :1.67
def properties_changed_callback(interface_name, properties, signature, service_name):
    if "PlaybackStatus" in properties:
        if properties["PlaybackStatus"] == "Playing": set_current_service(service_name)
        elif properties["PlaybackStatus"] == "Paused" or properties["PlaybackStatus"] == "Stopped":
            refresh_alive_services()
            
    if service_name == current_service: refresh_bookmarks_statusicon()

def look_for_playing_service():
    for service_name in alive_services:
        if get_property_player2("PlaybackStatus", service_name) == "Playing":
            print("look_for_playing_service: Found a playing service: ", service_name)
            set_current_service(service_name)
            return True
    return False

def look_for_any_service():
    if alive_services:
        set_current_service(alive_services[0])
        return True
    return False

def refresh_alive_services(*args):
    global alive_services, current_service
    
    for service_name in alive_services:
        try: bus.get_object(service_name, "/org/mpris/MediaPlayer2").Ping(dbus_interface="org.freedesktop.DBus.Peer")
        except:
            print("refresh_alive_services: Disconnecting from " + service_name)
            alive_services.remove(service_name)
            if service_name == current_service: set_current_service("")
    
    for service_well_known_name in list(filter(mpris_service_regex.match, bus.list_names())):
        service_name = bus.get_name_owner(service_well_known_name)
        if service_name not in alive_services:
            print("refresh_alive_services: Connecting to " + service_well_known_name + " (" + service_name + ")")
            alive_services.append(service_name)
            dbus_object = bus.get_object(service_name, "/org/mpris/MediaPlayer2")
            dbus_interface = dbus.Interface(dbus_object, "org.freedesktop.DBus.Properties")
            dbus_interface.connect_to_signal("PropertiesChanged", properties_changed_callback, sender_keyword="service_name")
            
        if get_property_player2("PlaybackStatus", service_name) == "Playing":
            set_current_service(service_name)
            
    if not current_service: look_for_any_service()

    return True

refresh_alive_services()
GLib.timeout_add_seconds(1, refresh_alive_services)
#=============================================================================== My D-Bus service
class MyDBusService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(my_service, bus=bus)
        dbus.service.Object.__init__(self, bus_name, my_object_name)
    
    @dbus.service.method(my_service)
    def ShowNotification(self):
        if not(current_service): return
        
        emit_notification()
    
    @dbus.service.method(my_service)
    def AddBookmarkHere(self):
        if not(current_service): return
        
        bookmark_fullpaths = get_bookmark_fullpaths()
        if not(bookmark_fullpaths): return
        #print("Debug: Writing bookmark to: ", bookmark_fullpaths)
        
        try: position = get_property_player("Position")
        except: return
        if position < 0: position = 0
        position_str = str(position)
        
        for bookmark_fullpath in bookmark_fullpaths:
            bookmarks = []
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents: bookmarks = file_contents.split(" ")
            if position_str in bookmarks: continue
            bookmarks = bookmarks + [position_str]
            bookmarks = sorted(bookmarks, key=int)
            with open(bookmark_fullpath, "w") as f: f.write(" ".join(bookmarks))
            
        refresh_bookmarks_statusicon()
        emit_notification()
    
    @dbus.service.method(my_service)
    def SeekToPreviousBookmark(self):
        if not(current_service): return
        
        bookmark_fullpaths = get_bookmark_fullpaths()
        if not(bookmark_fullpaths): return
        bookmarks = []
        for bookmark_fullpath in bookmark_fullpaths:
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents:
                    bookmarks = file_contents.split(" ")
                    break
        if not(bookmarks):
            #emit_notification(current_service, notification_body="There are no bookmarks")
            return
        bookmarks_int = list(map(int, bookmarks))
        
        try: position = get_property_player("Position")
        except: position = 0
        if position < 0: position = 0
        position_tmp = position - 5000000
        
        bookmark_to_seek_to = bookmarks_int[-1]
        for bookmark in reversed(bookmarks_int):
            if position_tmp > bookmark:
                bookmark_to_seek_to = bookmark
                break
        
        metadata = get_property_player("Metadata")
        dbus_interface = dbus.Interface(get_object(), "org.mpris.MediaPlayer2.Player")
        dbus_interface.Pause() # Workaround for Audacious
        dbus_interface.SetPosition(metadata["mpris:trackid"], bookmark_to_seek_to)
        dbus_interface.Play()
        
        emit_notification(position=bookmark_to_seek_to)
    
    @dbus.service.method(my_service)
    def SeekToNextBookmark(self):
        if not(current_service): return
        
        bookmark_fullpaths = get_bookmark_fullpaths()
        if not(bookmark_fullpaths): return
        bookmarks = []
        for bookmark_fullpath in bookmark_fullpaths:
            if os.path.isfile(bookmark_fullpath):
                with open(bookmark_fullpath, 'r') as f: file_contents = f.read()
                if file_contents:
                    bookmarks = file_contents.split(" ")
                    break
        if not(bookmarks):
            #emit_notification(current_service, notification_body="There are no bookmarks")
            return
        bookmarks_int = list(map(int, bookmarks))
        
        try: position = get_property_player("Position")
        except: position = 0
        if position < 0: position = 0
        position_tmp = position + 5000000
        
        bookmark_to_seek_to = bookmarks_int[0]
        for bookmark in bookmarks_int:
            if position_tmp < bookmark:
                bookmark_to_seek_to = bookmark
                break
        
        metadata = get_property_player("Metadata")
        dbus_interface = dbus.Interface(get_object(), "org.mpris.MediaPlayer2.Player")
        dbus_interface.Pause() # Workaround for Audacious
        dbus_interface.SetPosition(metadata["mpris:trackid"], bookmark_to_seek_to)
        dbus_interface.Play()
        
        emit_notification(position=bookmark_to_seek_to)
    
    @dbus.service.method(my_service)
    def RemoveBookmark(self):
        if not(current_service): return
        
        bookmark_fullpaths = get_bookmark_fullpaths()
        if not(bookmark_fullpaths): return
    
        try: position = get_property_player("Position")
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
        
        refresh_bookmarks_statusicon()
        if wrote_bookmarks:
            #refresh_bookmarks(current_service)
            emit_notification(notification_body="Bookmark removed") #, wrote to:\n" + str(bookmark_fullpaths))
        else: emit_notification(notification_body="No bookmark removed")
    
    @dbus.service.method(my_service)
    def GetFullpath(self):
        if not(current_service): return
        
        metadata = get_property_player("Metadata")
        
        if "xesam:url" in metadata:
            match = re.match("^file://(/.+)", metadata["xesam:url"])
            if match: return urllib.parse.unquote(match.group(1))
    
    @dbus.service.method(my_service)
    def GetMetadataField(self, metadata_field):
        if not(current_service): return
        
        metadata = get_property_player("Metadata")
        
        if metadata_field in metadata: return metadata[metadata_field]

    @dbus.service.method(my_service)
    def GetProperty(self, mpris_property):
        if not(current_service): return
        
        try: return get_object().Get("org.mpris.MediaPlayer2.Player", mpris_property, dbus_interface="org.freedesktop.DBus.Properties")
        except: pass

my_dbus_service_instance = MyDBusService()
#======================================== My D-Bus service end

Gtk.main()
