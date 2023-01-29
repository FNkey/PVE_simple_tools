#!/bin/bash

# Variable from argument-1 with time period of autosnapshotting.
timePeriod=$1

# Variable from argument-2 to set scope of virtual objects (running or all).
filterObj=$2

# Variable of rotation period.
snapRotate=0

# Counter
snapCounter=0

# Check arguments consistency and set rotate limit.
if [[ $timePeriod == "15min" ]] || [[ $timePeriod == "hourly" ]] || [[ $timePeriod == "4hours" ]] || [[ $timePeriod == "daily" ]]
then    {
        if [[ $timePeriod == "15min" ]]
                then snapRotate=4
        elif [[ $timePeriod == "hourly" ]]
                then snapRotate=24
        elif [[ $timePeriod == "4hours" ]]
                then snapRotate=6
        elif [[ $timePeriod == "daily" ]]
                then snapRotate=8
        fi
        }
else    {
        echo "Wrong timePriod parameter: $timePeriod"
        exit
        }
fi

if [[ $filterObj == "running" ]]
        then filterObj="running"
elif [[ $filterObj == "all" ]]
        then filterObj="running|stopped"
else    {
        echo "Wrong filterObj parameter: $filterObj"
        exit
        }
fi

# Fill arrays with IDs of virtual objects
declare -a pctList=($(pct list | grep -E "$filterObj" | awk '{ print $1 }'))
declare -a qmList=($(qm list | grep -E "$filterObj" | awk '{ print $1 }'))

# Run snapshotting
for i in "${pctList[@]}"
        do
        pct snapshot $i auto_"$timePeriod"_$(date +"%Y-%m-%d_%H-%M-%S") --description "Auto Snapshot LXC ($i) from cron job."
        done

for i in "${qmList[@]}"
        do
        qm snapshot $i auto_"$timePeriod"_$(date +"%Y-%m-%d_%H-%M-%S") --description "Auto Snapshot KVM ($j) from cron job."
        done

# Run purging old snapshots
for i in "${pctList[@]}"
do
  let snapCounter=($(pct listsnapshot $i | grep "auto_$timePeriod" | wc -l)-$snapRotate)
  if [[ "$snapCounter" -gt 0 ]]
  then  {
  pct listsnapshot $i | grep "auto_$timePeriod" | awk -F ">" '{ print $2 }' | awk '{ print $1 }' | head -n $snapCounter | xargs -n 1 pct delsnapshot $i
  }
  fi
done

for i in "${qmList[@]}"
do
  let snapCounter=($(qm listsnapshot $i | grep "auto_$timePeriod" | wc -l)-$snapRotate)
  if [[ "$snapCounter" -gt 0 ]]
  then  {
  qm listsnapshot $i | grep "auto_$timePeriod" | awk -F ">" '{ print $2 }' | awk '{ print $1 }' | head -n $snapCounter | xargs -n 1 qm delsnapshot $i
  }
  fi
done
