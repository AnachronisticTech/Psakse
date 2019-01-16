import sys

gridsize = 5

try:
	gridsize = int(sys.argv[1])
except:
	gridsize = 5

def checker(position, gridsize):
	if position < gridsize:
		if position == 0:
			print("Corner")
		elif position == (gridsize - 1):
			print("Corner")
		else:
			print("Edge")
	elif position % gridsize == 0:
		if position == gridsize * (gridsize - 1):
			print("Corner")
		else:
			print("Edge")
	elif position % gridsize == gridsize - 1:
		if position == (gridsize * gridsize) - 1:
			print("Corner")
		else:
			print("Edge")
	elif position > gridsize * (gridsize - 1):
		print("Edge")
	else:
		print("Centre")

for i in range(0, (gridsize * gridsize)):
    checker(i, gridsize)