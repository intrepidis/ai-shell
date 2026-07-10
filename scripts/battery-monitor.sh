#!/usr/bin/env bash
set -euo pipefail

LOW_BATTERY_WARN=${LOW_BATTERY_WARN:-20}
LOW_BATTERY_CRIT=${LOW_BATTERY_CRIT:-10}
LOW_BATTERY_URGENT=${LOW_BATTERY_URGENT:-5}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
SOUND_FILE=${SOUND_FILE:-/usr/share/sounds/freedesktop/stereo/dialog-warning.oga}

last_notified_level=""

get_battery_percent() {
    upower -d 2>/dev/null | awk '/percentage:/ {gsub(/%/, ""); print $NF; exit}'
}

get_battery_state() {
    upower -d 2>/dev/null | awk '/state:/ {print $NF; exit}'
}

notify() {
    local urgency=$1
    local percent=$2
    local msg=$3
    notify-send --urgency="$urgency" --expire-time=0 \
        "Battery at ${percent}%" "$msg"
    canberra-gtk-play --file="$SOUND_FILE" 2>/dev/null || true
}

echo "Battery monitor started. Checking every ${CHECK_INTERVAL}s."

while true; do
    percent=$(get_battery_percent)
    state=$(get_battery_state)

    if [[ "$state" == "charging" || "$state" == "fully-charged" ]]; then
        last_notified_level=""
        sleep "$CHECK_INTERVAL"
        continue
    fi

    level="ok"

    if (( percent <= LOW_BATTERY_URGENT )); then
        level="urgent"
    elif (( percent <= LOW_BATTERY_CRIT )); then
        level="critical"
    elif (( percent <= LOW_BATTERY_WARN )); then
        level="warn"
    fi

    if [[ "$level" != "ok" && "$last_notified_level" != "$level" ]]; then
        case "$level" in
            urgent)
                notify "critical" "$percent" "CRITICAL! Battery very low. Plug in now!"
                SOUND_FILE=/usr/share/sounds/freedesktop/stereo/suspend-error.oga
                CHECK_INTERVAL=30
                ;;
            critical)
                notify "critical" "$percent" "Battery critically low. Please charge."
                CHECK_INTERVAL=60
                ;;
            warn)
                notify "normal" "$percent" "Battery is running low. Consider charging."
                CHECK_INTERVAL=120
                ;;
        esac
        last_notified_level="$level"
    fi

    sleep "$CHECK_INTERVAL"
done