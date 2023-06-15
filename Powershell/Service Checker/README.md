# Service Checker
This was a small script written to output a dashboard which could be monitored to check if services were running as some were not starting on boot. I'd rather have added a start process in, but we wanted to have a record of each down.

Process:
- [x] Put all relevant services into a ```$services``` variable
- [x] Runs through each service with a ```forEach``` loop
- [x] Outputs each line of data into a HTML table
- [x] Finally, outputs ```$HTML``` variable data to file 
