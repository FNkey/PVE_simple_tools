#!/bin/bash

# Clean arrays and variables
virtID=()
delAllSnaps=0
handledObj=0

# Limit scope of handling.
# Limit scope of handling.
read -r -p "Do you want to handle only running[1], stopped[2] or both[3] VMs and containers? (enter number only) " response1
echo "Gathering VMs and containers IDs..."

filterObj=0

if [[ "$response1" == 1 ]]
        then filterObj="running"
elif [[ "$response1" == 2 ]]
        then filterObj="stopped"
elif [[ "$response1" == 3 ]]
        then filterObj="running|stopped"
else {
        echo "Wrong input. Exiting..."
        exit
     }
fi

declare -a pctList=($(pct list | grep -E "$filterObj" | awk '{ print $1 }'))
declare -a qmList=($(qm list | grep -E "$filterObj" | awk '{ print $1 }'))

echo -e "\n"
echo "Scope of selected virtual objects:"
echo "LXC: ${pctList[@]}"
echo "KVM: ${qmList[@]}"
echo -e "\n"
echo "Input numerical ID of KVM/LXC to delete snapshots or"
echo "put word \"ALL\" to select all IDs (empty line stops input):"
while IFS= read -r -p "Next ID: " line; do
    [[ $line ]] || break
    # Clean array if "ALL" was selected and append all IDs in scope.
    if [[ $line == "ALL" ]]
        then {
                virtID=()
                virtID+=(${pctList[@]})
                virtID+=(${qmList[@]})
                delAllSnaps=1
                break 2
        }
    else virtID+=("$line")
    fi
done

if [[ $delAllSnaps == 1 ]]
        then {
                echo "Snapshots of these objects will be purged: ${virtID[@]}"
                read -r -p "Are you sure want to delete ALL snapshots? (y/N) " response2
                if [[ "$response2" =~ ^([yY][eE][sS])$ ]] || [[ "$response2" =~ ^([yY])$ ]]
                      then break
                else exit
                fi
        }
fi

# Exit on zero input
if [[ ${#virtID[@]} -eq 0 ]]
        then {
                echo "Zero input, exiting..."
                exit
        }
fi

# Compare virtual object IDs in loop and run appropriate commands.
for j in "${virtID[@]}"
  do
    for i in "${pctList[@]}"
        do
          if [[ $j == $i ]]
          then  {
                ((handledObj++))
                echo "Removing snapshots for LXC $(pct config $i | grep hostname) ($i)..."
                pct listsnapshot $i | grep -v current | awk -F ">" '{ print $2 }' | awk '{ print $1 }' | xargs -n 1 pct delsnapshot $i
                }
          fi
        done

    for i in "${qmList[@]}"
        do
          if [[ $j == $i ]]
          then  {
                ((handledObj++))
                echo "Removing snapshots for KVM $(qm config $i | grep name) ($i)..."
                qm listsnapshot $i | grep -v current | awk -F ">" '{ print $2 }' | awk '{ print $1 }' | xargs -n 1 qm delsnapshot $i
                }
          fi
        done
  done

if [[ $handledObj -eq 0 ]]
        then echo -e "\nThere is no snapshots to handle. Exiting..."
fi
