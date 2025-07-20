from reducelin import Reduce

if __name__ == "__main__":

	cipher = "TWINKLE"
	sbox = [0x0, 0x3, 0x5, 0xd, 0x6, 0xf, 0xa, 0x8, 0xb, 0x4, 0xe, 0x2, 0x9, 0xc, 0x7, 0x1]

	filename = cipher + "_Inequalities.txt"

	twinkle = Reduce(filename, sbox)

	rine = twinkle.InequalitySizeReduce()

	filename_result = cipher + "_Reduce_Inequalities.txt"

	fileobj = open(filename_result, "w")
	for l in rine:
		fileobj.write(str(l) + "\n")
	fileobj.close()
