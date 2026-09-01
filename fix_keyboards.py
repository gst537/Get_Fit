import os

directory = "/Users/tarungs/PERSONAL/Get_Fit/GetFit/Views/"

for filename in os.listdir(directory):
    if filename.endswith(".swift"):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r') as file:
            content = file.read()
        
        # Replace .numberPad and .decimalPad
        content = content.replace(".keyboardType(.numberPad)", ".keyboardType(.numbersAndPunctuation)\n                    .submitLabel(.done)")
        content = content.replace(".keyboardType(.decimalPad)", ".keyboardType(.numbersAndPunctuation)\n                    .submitLabel(.done)")
        
        with open(filepath, 'w') as file:
            file.write(content)

print("Keyboards updated.")
