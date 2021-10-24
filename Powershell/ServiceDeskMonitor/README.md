# ServiceDeskMonitor
Possibly my largest script and written over several iterations, the primary goal of this script was to be a monitoring webpage for the largest supplier for a previous company I'd worked for. It would take readings of different metrics for every site and output them all in an HTML formatted page to all of the involved support staff to monitor in real-time.

This would also resolve common faults and even log calls for any issues found, this was probably one of the best things implemented in my time at my previous job.

Changes below:
- [x]    v1.0            PButler        28/05/2019          Test version using 172.16.4.111.: 
- [x]    v1.1            PButler        29/05/2019          Adding HTML conditional formatting     
- [x]    v1.2            PButler        29/05/2019          Added try{} catch{} for service checker.  
- [x]    v1.3            PButler	       31/05/2019	       Added clean up of functions etc (general housekeeping)	
- [x]    v1.4            PButler        03/05/2019          Adding Invoke-sqlcmd commandlet for shift 11 issue. **not working**
- [x]    v1.5            PButler        04/06/2019          Slowly adding in service restarts:
- [x]    v1.6            PButler        11/06/2019          Adding service checkers for powershell CLI - removed for now 
- [x]    v1.7            Pbutler        07/11/2019          Added call logging feature 
