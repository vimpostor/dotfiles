#!/usr/bin/env bash

# if no battery, exit
if ! [ -d "/sys/class/power_supply/BAT1" ]; then
	exit 0
fi

HEART='♥'

current_charge=$(cat /sys/class/power_supply/BAT1/energy_now)
total_charge=$(cat /sys/class/power_supply/BAT1/energy_full)

charged_slots=$(echo "(($current_charge/$total_charge)*10)" | bc -l | cut -d '.' -f 1)
if [[ $charged_slots -gt 10 ]]; then
  charged_slots=10
fi

echo -n '#[fg=red]'
for i in `seq 1 $charged_slots`; do echo -n "$HEART"; done

if [[ $charged_slots -lt 10 ]]; then
  echo -n '#[fg=white]'
  for i in `seq 1 $(echo "10-$charged_slots" | bc)`; do echo -n "$HEART"; done
fi
