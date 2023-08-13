#!/bin/bash

csv_deck_fullpath=~/Downloads/Phone/Langues/Japonais/My-anki-deck.txt
db_fullpath=~/.local/share/Anki2/"User 1"/collection.anki2

full=$(sqlite3 -separator ';' "$db_fullpath" 'SELECT sfld, flds FROM notes;' | LC_ALL=C sort)
fronts=$(sed 's/;.*//' <<< "$full")
backs=$(sed 's/.*;//' <<< "$full")

for i in $(seq $(grep -c . <<< "$full")); do
    number_of_chars=$(sed -n ${i}p <<< "$fronts" | wc --chars)
    backs=$(sed -E ${i}"s/^.{$number_of_chars}//" <<< "$backs")
done

cp -f "$csv_deck_fullpath" "$csv_deck_fullpath".bak &&
paste -d ';' <(printf %s "$fronts") <(printf %s "$backs") > "$csv_deck_fullpath"
