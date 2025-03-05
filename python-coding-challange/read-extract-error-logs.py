# Problem 1: Read and Extract Error Logs
# Explanation:
# Why? In CloudOps, logs contain system errors, and filtering logs is important for debugging.
# What we do? Read a log file and extract only the lines containing "ERROR".
# How? Read file → Check each line → Print "ERROR" lines.

# Solution:

# Read a log file
with open ('logs.txt', 'r') as file:
    logs = file.readlines()
    #print(logs)

# Extract only the lines containing "ERROR" camel case or lower case
    # Read each line
    for line in logs:
# Check if the line contains "ERROR" camlecase or lowercase
        if 'ERROR' in line or 'error' in line:
            # Print the line
           print(line)