import json
# load json config file and parse it
try:
    with open('config.json', 'r') as file:
        data = json.load(file) # this parses the json file
        print(data)
        
except FileNotFoundError:
    print("File not found")
    exit(1)
# Now, 'data' is a Python dictionary representing the JSON structure
#print("Loaded JSON data:", data)

# extract specific key value from json data
app_name = data['application']['name']
database_name = data['application']['database']['host']

print("Application Name:", app_name)
print("Database Name:", database_name)