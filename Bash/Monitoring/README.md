# Monitoring scripts
I've created a slew of monitoring scripts that monitor various processes, these are then output to a file, which is read in by a monitoring service and displayed and alerted upon.

### 1. mems_nodestatus.sh
This was created to check the status of a node using the node admin status command, which is output to a file and then grep'd to confirm the status
### 2. mems_clusterfailover.sh
This was created to check the status of a node to see which host has the virtual IP, these were then output to a file.
### 3. mems_sftpsync.sh
This was created to Monitored to see if files have synced across both node instances
### 4. mems_node.sh
This was created to check the Apache access logs to see if additional traffic manager IP ranges were being used we had not white listed.
