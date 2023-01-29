# Proxmox VE simple tools
Bundle of bash scripts to automate tasks in Proxmox VE.

## pveAutoSnap.sh ## 
Script for crontab, it must be appended with arguments of auto snapshot period and scope of virtual objects.

### Syntax: ###
/path/to/script/pveAutoSnap.sh **$timePeiod** **$scope**

Where:

**$timePeiod** can be *15min*, *hourly*, *4hours*, *daily*

**$scope** can be only *running* or *all*

### Example of usage: ###
```
0,15,30,45 *    *    *     *  /opt/scripts/pveAutoSnap.sh 15min running >> /var/log/pve-autosnap.log 2>&1
5      *    *    *     *    /opt/scripts/pveAutoSnap.sh hourly all >> /var/log/pve-autosnap.log 2>&1
```

## pveSnapRemovalTool.sh ##
Interactive script to mass remove snapshots in Proxmox VE.

Script can limit scope of virtual objects by running, stopped or all VMs and containters.

You can select ALL virtual objects in scope or pick by ID.
