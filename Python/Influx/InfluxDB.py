# import non-influxdb modules
from datetime import datetime
import random
import time
import psutil

# import influxdb modules
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

# influx org/token variables
token = "TOKEN"
org = "ORG"
bucket = "BUCKET"
URL = "http://localhost:8086"

# cpu/mem data
MemPercent =    [26.43234543,29.43234543,28.43234543,26.43204543,21.43234543,20.43234543]
cpuTemp =       [70, 65, 68, 55, 75, 90]
hdd = psutil.disk_usage('/')

# run until it's stopped
while 1:
    # make random choice
    memChoice = random.choice(MemPercent)   # make a random choice from mem number list
    cpuChoice = random.choice(cpuTemp)      # make a random choice from cpu number list

    # write data to influxClient
    with InfluxDBClient(url=URL, token=token, org=org) as client:
        write_api = client.write_api(write_options=SYNCHRONOUS)

        # populate data for memoryUsage
        try:
            data = f"mem,host=host1 used_percent={memChoice}" # mem % data
            write_api.write(bucket, org, data)
            print(f'Writing to Influx: used_percent(Mem): {memChoice}')
        except:
            print('Mem failed to write to InfluxDb')

        # populate data for cpuTemp
        try:
            data = f"cpu,host=host1 cpu_temp={cpuChoice}" # cpu temp data
            write_api.write(bucket, org, data)
            print(f'Writing to Influx: cpu_temp: {cpuChoice}')
        except:
            print('CPU failed to write to InfluxDb')

        # populate data for hdd freespace
        try:
            data = f"hdd,host=host1 disk_percent_used={hdd[3]}" # cpu temp data
            write_api.write(bucket, org, data)
            print(f'Writing to Influx: disk_percent_used: {hdd[3]}')
        except:
            print('disk_percent_used failed to write to InfluxDb')
    
    time.sleep(60) # sleep for 1 minute
