import re
import pandas as pd
import matplotlib.pyplot as plt
import sys



size_avg = int(sys.argv[1])
num_lines = int(sys.argv[2])


# Regular expression to match the lines in the log file
#pattern = r"output i: (\d+) k: (\w+) p:  BMU: [\d\s]+d: (\d+\.\d+)"
pattern = r"output i: (\d+) k: (\w+) p: [\d\s]*(?:BMU: [\d\s]+d: (\d+\.\d+))?"
# Initialize a dictionary to hold the parsed data
data = {'i': [], 'k': [], 'd': []}

# Open the log file and parse it line by line
lines = []
with open('log.txt', 'r') as file:
#with open('/FULL_PATH_TO_SKETCH/log.txt', 'r') as file:
    for line in file:
        # Skip if line is empty
        if line.strip() != "":
            lines.append(line)

    
for line in lines:
        match = re.search(pattern, line)
        if match:
            # If the line matches the pattern, extract the i, k, and d values
            i, k, d = match.groups()
            if k[:2] == "Ki":
                k = "Kini"
            print(i, k, d)
            data['i'].append(int(i))
            data['k'].append(k[:3])  # only keep the first three characters of k
            data['d'].append(float(d))

# Convert the data to a DataFrame
df = pd.DataFrame(data)


# Calculate the moving average over the last 300 values
df['d_avg'] = df.groupby('k')['d'].transform(lambda x: x.rolling(size_avg, 1).mean())

# Plot the moving average d values for each k value
plt.figure(figsize=(10,6))
plt.title('Average Quantization Error per Feature (T:'+str(size_avg)+')')
plt.grid('on')
#step = int(num_lines / 2000)
#print("step:", step)
#print("nPt", num_lines)
for k in df['k'].unique():
    subset = df[df['k'] == k] #the end result of subset = df[df['k'] == k] 
            # is a new DataFrame that only includes the rows of df where the 'k' 
            # column equals the current k value. This allows us to create a 
            # separate line in the plot for each unique 'k' value.
    subset = subset[size_avg:num_lines]
    plt.plot(subset['i'], subset['d_avg'], label=k)

plt.xlabel('i')
plt.ylabel('d_avg')
plt.legend(loc='upper right')
plt.show()




