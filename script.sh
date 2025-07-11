#!/usr/bin/env bash

#TODO
# 1. Make input clear after exiting alt screen
# 2. Make something so DEVICE_ID is alwats correct if possible
# 3. fix not displaying box on start sometimes
# 4. Fix offset if KILL_COUNTER >= 100
# 5. More modularity (options about e.g. Tooltip, width etc.)
# 6. echo -> printf in draw_box()

DEVICE_ID=9 # keyboard

KEY_0="19"       # reset
KEY_MINUS="20"   # - to kill counter
KEY_PLUS="21"    # + to kill counter
KEY_DELETE="119" # exit program
########### ALT'S ########### 
KEY_R="27"       # alt to 0
KEY_S="39"       # alt to MINUS
KEY_A="38"       # alt to PLUS
KEY_Q="24"       # alt to DELETE

KILL_COUNTER=0

# set up
tput smcup #alt screen
tput civis #no cursor

repeat_delay=$(xset q | grep "repeat delay:" | awk '{print $4}')
repeat_rate=$(xset q  | grep "repeat rate:"  | awk '{print $7}')
xset r rate 600 10 # repeat prevention

# Monitor input events
xinput test $DEVICE_ID | while read line; do

    draw_box() {
     clear

     local RED=$(tput setaf 1; echo "   ")
     local WHITE=$(tput setaf 7)
     local YELLOW=$(tput setaf 3)

     # Can't have negative kills (shut up Napstablook)
     if (( $KILL_COUNTER < 0 )); then
          KILL_COUNTER=0
     fi

     # Bigger number offset
     if (( $KILL_COUNTER >= 10 )); then
         local RED=$(tput setaf 1; echo "  ")
    
     #Doesn't work
    # elif (( $KILL_COUNTER >= 100 )); then
    #    local RED=$(tput setaf 1; echo " ")
     fi

     echo "┌────────────────────────┐"
     echo "│  Kills: $RED $KILL_COUNTER $WHITE         │"
     echo "│                        │"
     echo "│  To Exit: $YELLOW DEL$WHITE         │"
     echo "│ Up: $YELLOW+$WHITE Down: $YELLOW-$WHITE Reset:$YELLOW 0$WHITE │" # Tooltip
     echo "└────────────────────────┘"
}

trap 'cleanup' SIGINT SIGTERM

    cleanup() {
     xset r rate "$repeat_delay" "$repeat_rate" # restore key delay speed 
     tput rmcup # exit alt screen
     tput cnorm # make cursor visible again
	 clear
}

    if echo "$line" | grep -q "key press"; then
        # Extract key code
        KEYCODE=$(echo "$line" | awk '{print $3}')

          case $KEYCODE in

               $KEY_DELETE | $KEY_Q)
                       cleanup
                       exit 1
                       ;;

               $KEY_PLUS | $KEY_A)
                       (( KILL_COUNTER += 1 ))
                       ;;

               $KEY_MINUS | $KEY_S)
                       (( KILL_COUNTER -= 1 ))
                       ;;

               $KEY_0 | $KEY_R)
                       KILL_COUNTER=0
                       ;;
        esac
    fi
        draw_box
done
