import os

# Read input from a file or stdin
file_path = os.path.join(os.path.dirname(__file__), "data.txt")
with open(file_path) as f:
    lines = [line.strip() for line in f if line.strip()]

print("[16] = {")
for line in lines:
    print(f'    "{line}",')
print("};")
