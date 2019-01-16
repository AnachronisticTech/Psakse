gridsize = 5

for i in range(0, ((gridsize * gridsize) - 1)):
    xCoord = (i % gridsize) + 1
    yCoord = int((i / gridsize) + 1)
    print(yCoord)