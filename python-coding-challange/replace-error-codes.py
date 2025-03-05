#Problem 4: Replace Error Codes in Logs
#Explanation:
#Why? Instead of error codes, replacing them with descriptions is useful.
#What we do? Replace "ERROR-500" with "Server Down".
#How? Use .replace().

log_text = "EC2-1 encountered ERROR-500"

# replace error code with description
cleaned_log = log_text.replace("ERROR-500", "Server Down")
print("Cleaned Log:", cleaned_log)