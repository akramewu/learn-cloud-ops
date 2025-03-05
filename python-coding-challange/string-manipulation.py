# formatting cloud logs

from ipaddress import ip_address
from sqlite3.dbapi2 import Timestamp


raw_log = "2023-10-27 10:00:00 ERROR Server failed to respond. IP:192.168.1.10"

# split the log into parts
parts = raw_log.split()
print("Split parts:", parts)

# extract the specific parts
timestamp = parts[0] + " " + parts[1]
print("Timestamp:", Timestamp)
error_level = parts[2]
print("Error Level:", error_level)
ip_address_check = parts[-1].split(":")[-1]
print("IP Address:", ip_address_check)