from gurobipy import *

import time

"""
x_roundNumber_rowNumber_columnNumber_LaneNumber

"""

class Twinkle:
    def __init__(self, rounds, activebits):
        self.rounds = rounds
        self.activebits = activebits.copy()
        self.blocksize = 1280
        self.rowsize = 4
        self.colsize = 4
        self.lanesize = 80

        self.filename_model = "./lp/Twinkle_round:" + str(self.rounds) + "_activebits:" + str(len(self.activebits)) + ".lp"
        self.filename_result = "./results/result_round" + str(self.rounds) + "_activebits:" + str(len(self.activebits)) + ".txt"
        fileobj = open(self.filename_model, "w")
        fileobj.close()
        fileboj = open(self.filename_result, "w")
        fileobj.close()

    # Linear inequalities for the TWINKLE Sbox
    S_T = [[1, 1, 1, 1, -1, -1, -1, -1, 0],\
        [-3, -6, -3, -5, 1, 1, 2, 3, 10],\
        [1, 1, 0, 0, -3, -2, 2, -2, 3],\
        [1, 0, 0, 1, 2, -2, -3, -2, 3],\
        [-3, -1, -5, -2, 6, 1, 5, 3, 4],\
        [-1, 0, -1, 0, -2, 1, -2, 1, 4],\
        [-1, -1, 0, -1, 2, 2, 2, 1, 0],\
        [-2, -2, -1, 0, -3, 2, -1, 1, 6],\
        [0, 1, 1, 0, -2, -2, 1, -1, 2],\
        [-2, 0, -1, -2, -1, 2, -3, 1, 6],\
        [0, 0, 1, 1, 1, -2, -2, -1, 2],\
        [1, 0, 2, 0, -1, 0, -1, -1, 1],\
        [0, -1, 0, -1, 1, -1, 0, 1, 2]]
    NUMBER = 9

    @staticmethod
    def CreateVariables1(n):
        """
        The variables before s-box.
        """
        array = []
        for k in range(80):
            for j in range(4):
                for i in range(4):
                    array.append("x" + "_" + str(n) + "_" + str(i) + "_" + str(j) + "_" + str(k))
        return array

    @staticmethod
    def CreateVariables2(n):
        """
        The variables after s-box.
        """
        array = []
        for k in range(80):
            for j in range(4):
                for i in range(4):
                    array.append("y" + "_" + str(n) + "_" + str(i) + "_" + str(j) + "_" + str(k))
        return array

    @staticmethod
    def CreateVariables3(n):
        """
        The variables after Copy Operation.
        """
        array = []
        for k in range(80):
            for j in range(4):
                for i in range(4):
                    array.append("z" + "_" + str(n) + "_" + str(i) + "_" + str(j) + "_" + str(k))
        return array

    @staticmethod
    def CreateVariables4(n):
        """
        The variables after Copy Operation.
        """
        array = []
        for k in range(80):
            for j in range(4):
                for i in range(4):
                    array.append("w" + "_" + str(n) + "_" + str(i) + "_" + str(j) + "_" + str(k))
        return array

    @staticmethod
    def CreateVariables5(n):
        """
        The variables after Copy Operation.
        """
        array = []
        for k in range(80):
            for j in range(4):
                for i in range(4):
                    array.append("p" + "_" + str(n) + "_" + str(i) + "_" + str(j) + "_" + str(k))
        return array


    #@staticmethod
    #def CreateVariables(n, s):
    #    """
    #    Generate the variables used in the model.
    #    """
    #    array = ["%s_%d_%d_%d_%d" % (s, n, i, j, k)
    #              for k in range(80) for j in range(4) for i in range(4)]

    #    return array


    def CreateObjectiveFunction(self):
        """
        Create objective function of the MILP model
        """
        fileobj = open(self.filename_model, "a")
        fileobj.write("Minimize\n")
        eqn = []
        for i in range(0, self.rowsize):
            for j in range(0, self.colsize):
                for k in range(0, self.lanesize):
                    eqn.append("x" + "_" + str(self.rounds) + "_" + str(i) + "_" + str(j) + "_" + str(k))

        temp = " + ".join(eqn)
        fileobj.write(temp)
        fileobj.write("\n")
        fileobj.close()
        

    def sbox(self, variable1, variable2):
        """
        Generate the constraints by Sbox layer.
        """
        fileobj = open(self.filename_model, "a")

        for j in range(0, self.colsize):
            for k in range(0, self.lanesize):
                for coff in Twinkle.S_T:
                    temp = []
                    for u in range(0, self.rowsize):
                        temp.append(str(coff[u]) + " " + variable1[u + 4*j + 16*k])
                    for v in range(0, self.rowsize):
                        temp.append(str(coff[4 + v]) + " " + variable2[v + 4*j + 16*k])
                    temp1 = " + ".join(temp)
                    temp1 = temp1.replace("+ -", "- ")
                    s = str(-coff[Twinkle.NUMBER - 1])
                    s = s.replace("--", "")
                    temp1 += " >= " + s
                    fileobj.write(temp1)
                    fileobj.write("\n")
        fileobj.close()


    def lr(self, inp, rot_idx):
        # lr0 and lr1 rotation parameters depending upon lr_offset[idx]
        lr_offset = [   [20, 24, 38, 77, 49, 66, 30, 40, 76, 15, 46, 50, 17, 18, 61, 62],\
                        [63, 45, 34, 39, 32, 43, 60, 66, 54, 26, 55, 36, 61, 12, 15, 35]]

        out = inp.copy()

        for k in range(self.lanesize):
            for j in range(self.colsize):
                for i in range(self.rowsize):
                    # k-th lane var = i +4*j + 16*k. Rotate towards LSB, so k-lr[0][i +4*j]. "+80" and "%80" to make
                    # k-lr[0][i +4*j] >0
                    out[i + 4*j + 16*k] = inp[i +4*j +16*(((k +lr_offset[rot_idx][i +4*j]) +80)%80)]
        return out


    def Constraints_by_threeway_fork(self, x, x1, x2, x3):
        """
        Generate the constraints by threeway fork
        x ---> (x1, x2, x3)
        """
        fileobj = open(self.filename_model, "a")
        temp = [x, x1, x2, x3]
        s = " - ".join(temp) + " = 0\n"
        fileobj.write(s)
        fileobj.close()

    def Constraints_by_threeway_xor(self, x1, x2, x3, x):
        """
        Generate the constraints by 4-bit threeway xor
        x1 + x2 + x3 = x
        """
        fileobj = open(self.filename_model, "a")
        temp = [x, x1, x2, x3]
        s = " - ".join(temp) + " = 0\n"
        fileobj.write(s)
        fileobj.close()


    def mixslice(self, n, variable1, variable2):
        fileobj = open(self.filename_model, "a")
        variableout1 = Twinkle.CreateVariables3(n)
        variableout2 = Twinkle.CreateVariables4(n)
        variableout3 = Twinkle.CreateVariables5(n)
        for i in range(self.rowsize):
            for j in range(self.colsize):
                for k in range(self.lanesize):
                    self.Constraints_by_threeway_fork(variable1[i + 4*j + 16*k], variableout1[i + 4*j + 16*k], variableout2[i + 4*j + 16*k], variableout3[i + 4*j + 16*k])
                
        for k in range(self.lanesize):
            for i in range(16):
                self.Constraints_by_threeway_xor(variableout1[i + 16*k], variableout2[(i + 11)%16 + 16*k],\
                         variableout3[(i + 4)%16 + 16*k], variable2[i + 16*k])
           
        fileobj.close()


    # Variables declaration
    def VariableBinary(self):
        """
        Specify the variables type.
        """
        fileobj = open(self.filename_model, "a")
        fileobj.write("Binary\n")
        for n in range(self.rounds + 1):
            for i in range(self.rowsize):
                for j in range(self.colsize):
                    for k in range(self.lanesize):
                            fileobj.write("x_%d_%d_%d_%d\n" % (n, i, j, k))

        for n in range(self.rounds):
            for i in range(self.rowsize):
                for j in range(self.colsize):
                    for k in range(self.lanesize):
                            fileobj.write("y_%d_%d_%d_%d\n" % (n, i, j, k))



        for n in range(self.rounds):
            for i in range(self.rowsize):
                for j in range(self.colsize):
                    for k in range(self.lanesize):
                            fileobj.write("z_%d_%d_%d_%d\n" % (n, i, j, k))


        for n in range(self.rounds):
            for i in range(self.rowsize):
                for j in range(self.colsize):
                    for k in range(self.lanesize):
                            fileobj.write("w_%d_%d_%d_%d\n" % (n, i, j, k))


        for n in range(self.rounds):
                for i in range(self.rowsize):
                    for j in range(self.colsize):
                        for k in range(self.lanesize):
                                fileobj.write("p_%d_%d_%d_%d\n" % (n, i, j, k))	
                    
        fileobj.write("END")
        fileobj.close()


    def print_lane_wise(self, s, var):
        print(s)

        # printing rowwise first
        for k in range(self.lanesize):
            for i in range(16):
                print(var[i +16*k], end = ' ')
            print("\n")


    def Constraint(self):
        """
        Generate the constraints used in the MILP model.
        """
        assert(self.rounds >= 1)
        fileobj = open(self.filename_model, "a")
        fileobj.write("Subject To\n")
        fileobj.close()

        variablein = Twinkle.CreateVariables1(0)

        for i in range(0, self.rounds):
            variableout = Twinkle.CreateVariables2(i)
            self.sbox(variablein, variableout)
            variableout = self.lr(variableout, 0)

            variablein  = Twinkle.CreateVariables1(i+1)
            self.mixslice(i, variableout, variablein)
            variablein = self.lr(variablein, 1)


    def Init(self):
        """
        Generate the constraints introduced by the initial division property.
        """
        variableout = Twinkle.CreateVariables1(0)
        fileobj = open(self.filename_model, "a")
        temp = []
        for i in range(0, 1280):
            if (i in self.activebits):
                temp = variableout[i] + " = 1"
            else:
                temp = variableout[i] + " = 0"
            fileobj.write(temp)
            fileobj.write("\n")

        fileobj.close()

    def MakeModel(self):
        """
        Generate the MILP model of Twinkle given the round number and activebits.
        """
        self.CreateObjectiveFunction()
        self.Constraint()
        self.Init()
        self.VariableBinary()


    def WriteObjective(self, obj):
        """
        Write the objective value into filename_result.
        """
        fileobj = open(self.filename_result, "a")
        fileobj.write("The objective value = %d\n" %obj.getValue())
        eqn1 = []
        eqn2 = []
        for i in range(0, self.blocksize):
            u = obj.getVar(i)
            if u.getAttr("x") != 0:
                eqn1.append(u.getAttr('VarName'))
                eqn2.append(u.getAttr('x'))
        length = len(eqn1)
        for i in range(0,length):
            s = eqn1[i] + "=" + str(eqn2[i])
            fileobj.write(s)
            fileobj.write("\n")
        fileobj.close()

    def SolveModel(self):
        """
        Solve the MILP model to search the integral distinguisher of Twinkle.
        """
        time_start = time.time()
        m = read(self.filename_model)
        m.Params.Threads = 32
        counter = 0
        set_zero = []
        global_flag = False
        while counter < self.blocksize:
            m.optimize()
            # Gurobi syntax: m.Status == 2 represents the model is feasible.
            if m.Status == 2:
                obj = m.getObjective()
                if obj.getValue() > 1:
                    global_flag = True
                    break
                else:
                    fileobj = open(self.filename_result, "a")
                    fileobj.write("************************************COUNTER = %d\n" % counter)
                    fileobj.close()
                    self.WriteObjective(obj)
                    for i in range(0, self.blocksize):
                        u = obj.getVar(i)
                        temp = u.getAttr('x')
                        if round(temp) == 1:
                            set_zero.append(u.getAttr('VarName'))
                            u.ub = 0
                            m.update()
                            counter += 1
                            break
            # Gurobi syntax: m.Status == 3 represents the model is infeasible.
            elif m.Status == 3:
                global_flag = True
                break
            else:
                # print "Unknown error!"
                print("Unknown error!")

        fileobj = open(self.filename_result, "a")		
        if global_flag:
            fileobj.write("\nIntegral Distinguisher Found!\n\n")
            # print "Integral Distinguisher Found!\n"
            print("Integral Distinguisher Found!\n")
        else:
            fileobj.write("\nIntegral Distinguisher do NOT exist\n\n")
            # print "Integral Distinguisher do NOT exist\n"
            print("Integral Distinguisher do NOT exist\n")

        fileobj.write("Those are the coordinates set to zero: \n")
        for u in set_zero:
            fileobj.write(u)
            fileobj.write("\n")
        fileobj.write("\n")
        time_end = time.time()
        fileobj.write(("Time used = " + str(time_end - time_start)))
        fileobj.close()




