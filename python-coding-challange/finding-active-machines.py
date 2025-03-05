#Problem 5: Filter Running Instances
#Explanation:
#Why? In CloudOps, we need to find running cloud instances.
#What we do? Filter Running instances from a list.
#How? Loop through list → Keep only "Running" instances.

# list of instances
instances = [
    {"id": 1, "state": "Running"},
    {"id": 2, "state": "Stopped"},
    {"id": 3, "state": "Running"},
    {"id": 4, "state": "Terminated"},
    {"id": 5, "state": "Running"},
]

# Filter Running instances
for instance in instances:
    if instance["state"] == "Running":
        print(instance)