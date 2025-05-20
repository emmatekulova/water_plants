#!/bin/bash

declare -A SHORT_TO_NAME 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_FILE="$SCRIPT_DIR/plants.log"
PLANTS_JSON="$SCRIPT_DIR/plants.json"
declare -A SHORT_TO_NAME
readarray -t PLANTS < <(jq -r '.[].name' "$PLANTS_JSON")
declare exit_status=0
# Read watering days per plant into variables
while read -r plant_json; do
    name=$(echo "$plant_json" | jq -r '.name')
    watering_days=$(echo "$plant_json" | jq -r '."watering days"')
    short_name=$(echo "$plant_json" | jq -r '."short_name"')

    # sanitize name to a valid variable name by replacing spaces with underscores
    safe_name=$(echo "$name" | tr ' ' '_')

    declare "${safe_name}_watering_days=$watering_days"
    declare "${safe_name}_short_name=$short_name"
    SHORT_TO_NAME["$short_name"]="$name"

done < <(jq -c '.[]' "$PLANTS_JSON")

touch "$LOG_FILE"

echo "----- Watering Status -----"
for plant in "${PLANTS[@]}"
do
    safe_plant=$(echo "$plant" | tr ' ' '_')
    watering_days_var="${safe_plant}_watering_days"
    watering_days=${!watering_days_var}

    last_date=$(grep "^$plant:" "$LOG_FILE" | tail -n 1 | cut -d ':' -f2-)
    if [ -n "$last_date" ]; then
        last_time=$(date -d "$last_date" +%s)
        now=$(date +%s)
        diff_days=$(( (now - last_time) / 86400 ))

        if [ "$diff_days" -gt "$watering_days" ]; then
            echo "⚠️ Plant $plant has not been watered for $diff_days days! (Needs watering every $watering_days days)"
        else
            echo "🌱 Plant $plant was watered $diff_days days ago."
        fi
    else
        echo "🌱 Plant $plant has never been watered."
    fi
done

while [[ "$exit_status" -ne 1 ]]
do
    echo "Do you want to water a plant (w) or add a new plant (a) or exit (e)?"
    read -p "Enter your choice: " choice
    if [[ "$choice" == "a" ]]; then
        read -p "Enter plant name: " new_plant_name
        read -p "Enter watering days: " new_watering_days
        read -p "Enter short name: " new_short_name

        tmpfile=$(mktemp)
        jq ". += [{\"name\":\"$new_plant_name\",\"watering days\":$new_watering_days,\"short_name\":\"$new_short_name\"}]" "$PLANTS_JSON" > "$tmpfile" && mv "$tmpfile" "$PLANTS_JSON"

        echo "✅ Added new plant $new_plant_name with watering days $new_watering_days and short name $new_short_name."
        exit_status=0
    elif [[ "$choice" == "e" ]]; then
        echo "Exiting..."
        exit_status=1

    elif [[ "$choice" == "w" ]]; then
        echo
        echo "Which plant do you want to water? Options: ${!SHORT_TO_NAME[*]}"
        read -p "Enter plant short name: " short_choice

        full_name="${SHORT_TO_NAME[$short_choice]}"

        if [[ -n "$full_name" ]]; then
            now=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$full_name:$now" >> "$LOG_FILE"
            echo "✅ You watered plant $full_name on $now."
        else
            echo "❌ Invalid choice. Please choose from: ${!SHORT_TO_NAME[*]}"
        fi
    fi
done
