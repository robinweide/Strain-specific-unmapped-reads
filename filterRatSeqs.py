import sys
# Script to quickly remove handles of mouse-matching
# seqences from the total heap of handles. The remaining
# handles are Rat-specific.
# Arg 1: list of all handles
# Arg 2: list of mouse-matching handles
# Arg 3: filename to write to
# STDout = summary stats

ALL = open(sys.argv[1],'r')
MOUSE = open(sys.argv[2],'r')
RAT = open(sys.argv[3],'w')

allList = []
mouseList = []
ratList = []
for line in ALL:
    allList.append(line.rstrip())

for line in MOUSE:
    mouseList.append(line.rstrip())

for handle in allList:
    if handle not in mouseList:
        ratList.append(handle)

ALL.close()
MOUSE.close()

print(str("# All: ") + str(len(allList)))
print(str("# Mouse: ") + str(len(mouseList)))
print(str("# Rat: ") + str(len(ratList)))

for handle in ratList:
    RAT.write(str(handle) + "\n")

RAT.close()
