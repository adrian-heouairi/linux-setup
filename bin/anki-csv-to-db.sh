#!/bin/bash

# Launch Anki at least once before this
# Anki can be launched or not when launching this script
# The first column in the CSV should not contain double quote
# The Anki DB should not contain notes whose front contains double quote
# The notes can be in any deck, all notes not in the CSV will be deleted including in other decks
# The CSV is semicolon-separated: front;back, newlines are not supported, if front; the card is imported, if front the card is not imported
# In the Anki DB, there can be multiple cards (front back and back front for example) for one note. The note is what contains the question and answer text.

csv_deck_fullpath=~/Downloads/Phone/Langues/Japonais/My-anki-deck.txt

anki &

sleep 2

anki "$csv_deck_fullpath"

notify-send -- "$0" "Please close Anki after importing"

while pidof -x anki &>/dev/null; do sleep .5; done

db_fronts=$(sqlite3 ~/.local/share/Anki2/"User 1"/collection.anki2 'SELECT sfld FROM notes;' | LC_ALL=C sort) # It is assumed that this is a superset of $my_fronts at this point
my_fronts=$(sed 's/;.*//' "$csv_deck_fullpath" | LC_ALL=C sort)

grep '"' <<< "$my_fronts"$'\n'"$db_fronts" && exit 1

to_delete_from_db=$(grep -Fxv -- "$my_fronts" <<< "$db_fronts")

IFS=$'\n'
for i in $to_delete_from_db; do
    sqlite3 ~/.local/share/Anki2/"User 1"/collection.anki2 "DELETE FROM notes WHERE sfld = \"$i\";"
done

sqlite3 ~/.local/share/Anki2/"User 1"/collection.anki2 'DELETE FROM cards WHERE id IN (SELECT id FROM cards WHERE nid NOT IN (SELECT id FROM notes));' # Delete cards that are referring to a deleted note

new_db_fronts=$(sqlite3 ~/.local/share/Anki2/"User 1"/collection.anki2 'SELECT sfld FROM notes;' | LC_ALL=C sort)
[ "$my_fronts" = "$new_db_fronts" ] && notify-send -- "$0" "Successfully synchronized decks" || { notify-send -- "$0" "Error, the decks are not synchronized"; diff <(printf %s "$my_fronts") <(printf %s "$new_db_fronts"); }
