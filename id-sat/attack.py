#!/usr/env/bin python3
#-*- coding: UTF-8 -*-

"""
Copyright (C) 2025 
Contact: hsn.hadipour@gmail.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

In case you use this tool please include the above copyright 
information (name, contact, license)
"""

import logging
logging.basicConfig(filename="minizinc-python.log", level=logging.DEBUG)
import time
import minizinc
import datetime
from argparse import ArgumentParser, RawTextHelpFormatter
from drawer import DrawDL

class Attack:
    DL_counter = 0

    def __init__(self, param) -> None:
        Attack.DL_counter += 1
        self.id = Attack.DL_counter
        self.name = "Attack" + str(self.id)
        self.type = "Attack"
        self.RD = param["RD"]
        self.cp_solver_name = param["solver"]
        self.num_of_threads = param["threads"]
        self.cp_solver = minizinc.Solver.lookup(self.cp_solver_name)
        self.time_limit = param["timelimit"]
        self.mzn_file_name = None
        self.output_file_name = param["output"]
        self.mzn_file_name = "attack.mzn"
    
    #############################################################################################################################################
    #############################################################################################################################################    
    #  ____                           _        __                        ____   _       _    _                       _       _                 
    # / ___|   ___   __ _  _ __  ___ | |__    / _|  ___   _ __    __ _  |  _ \ (_) ___ | |_ (_) _ __    __ _  _   _ (_) ___ | |__    ___  _ __ 
    # \___ \  / _ \ / _` || '__|/ __|| '_ \  | |_  / _ \ | '__|  / _` | | | | || |/ __|| __|| || '_ \  / _` || | | || |/ __|| '_ \  / _ \| '__|
    #  ___) ||  __/| (_| || |  | (__ | | | | |  _|| (_) || |    | (_| | | |_| || |\__ \| |_ | || | | || (_| || |_| || |\__ \| | | ||  __/| |   
    # |____/  \___| \__,_||_|   \___||_| |_| |_|   \___/ |_|     \__,_| |____/ |_||___/ \__||_||_| |_| \__, | \__,_||_||___/|_| |_| \___||_|   
    #                                                                                                  |___/                                   
    # Search for a distinguisher using MiniZinc

    def search(self):
        """
        Search for a distinguisher
        """

        if self.time_limit != -1:
            time_limit = datetime.timedelta(seconds=self.time_limit)
        else:
            time_limit = None
    
        start_time = time.time()
        #############################################################################################################################################
        print(f"Searching for {self.RD}-round distinguisher for TWINKLE permutation ...")
        self.cp_model = minizinc.Model()
        self.cp_model.add_file(self.mzn_file_name)
        self.cp_inst = minizinc.Instance(solver=self.cp_solver, model=self.cp_model)
        self.cp_inst["RD"] = self.RD        
        self.cp_inst["offset"] = 0
        self.result = self.cp_inst.solve(timeout=time_limit, 
                                         processes=self.num_of_threads)
                                        #  verbose=False, 
                                        #  debug_output=Path("./debug_output.txt",
                                        #  intermediate_solutions=True),
                                        #  random_seed=randint(0, 100),
                                        #  optimisation_level=1) # 0: Disable optimisation
                                        #                        # 1: Single pass optimisation (default)
                                        #                        # 2: Flatten twice to improve flattening decisions
                                        #                        # 3: Perform root-node-propagation
                                        #                        # 4: Probe bounds of all variables at the root node
                                        #                        # 5: Probe values of all variables at the root node
        #############################################################################################################################################
        elapsed_time = time.time() - start_time
        print("Time used to find a distinguisher: {:0.02f} seconds".format(elapsed_time))
        print(f"Solver status: {self.result.status}")
        if minizinc.Status.has_solution(self.result.status) or self.result.status == minizinc.Status.ERROR:
            self.attack_summary, self.upper_trail, self.lower_trail = self.parse_solution()
            print(self.attack_summary)
            self.attack_summary += "Time used to find a distinguisher: {:0.2f} seconds\n".format(elapsed_time)
            draw = DrawDL(self, output_file_name=self.output_file_name)
            draw.generate_distinguisher_shape()  
        elif self.result.status == minizinc.Status.UNSATISFIABLE:
            print("Model is unsatisfiable") 
        elif self.result.status == minizinc.Status.UNKNOWN:
            print("Unknown error!")
        else:
            print("Solving process was interrupted")

    #############################################################################################################################################
    #############################################################################################################################################
    #  ____                           _    _             ____          _         _    _               
    # |  _ \  __ _  _ __  ___   ___  | |_ | |__    ___  / ___|   ___  | | _   _ | |_ (_)  ___   _ __  
    # | |_) |/ _` || '__|/ __| / _ \ | __|| '_ \  / _ \ \___ \  / _ \ | || | | || __|| | / _ \ | '_ \ 
    # |  __/| (_| || |   \__ \|  __/ | |_ | | | ||  __/  ___) || (_) || || |_| || |_ | || (_) || | | |
    # |_|    \__,_||_|   |___/ \___|  \__||_| |_| \___| |____/  \___/ |_| \__,_| \__||_| \___/ |_| |_|
    # Parse the solution and print the distinguisher's specifications

    def parse_solution(self):
        """
        Parse the solution and print the distinguisher's specifications
        """
        
        upper_trail = {"x": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD + 1)],
                       "y": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)],
                       "z": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)],
                       "w": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)]}
        for r in range(self.RD + 1):
            for z in range(80):
                for y in range(4):
                    for x in range(4):         
                        upper_trail["x"][r][x][y][z] = self.result["xu"][r][x][y][z]
                        if r < self.RD:
                            upper_trail["y"][r][x][y][z] = self.result["yu"][r][x][y][z]
                            upper_trail["z"][r][x][y][z] = self.result["zu"][r][x][y][z]
                            upper_trail["w"][r][x][y][z] = self.result["wu"][r][x][y][z]
        lower_trail = {"x": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD + 1)],
                       "y": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)],
                       "z": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)],
                       "w": [[[[0 for _ in range(80)] for _ in range(4)] for _ in range(4)] for _ in range(self.RD)]}
        for r in range(self.RD + 1):
            for z in range(80):
                for y in range(4):
                    for x in range(4):         
                        lower_trail["x"][r][x][y][z] = self.result["xl"][r][x][y][z]
                        if r < self.RD:
                            lower_trail["y"][r][x][y][z] = self.result["yl"][r][x][y][z]
                            lower_trail["z"][r][x][y][z] = self.result["zl"][r][x][y][z]
                            lower_trail["w"][r][x][y][z] = self.result["wl"][r][x][y][z]
        input_diff = ""
        for y in range(4):
            for x in range(4):
                input_diff += "".join(list(map(str, self.result["xu"][0][x][y]))).replace("-1", "?") + "\n"
        output_mask = ""
        for y in range(4):
            for x in range(4):
                output_mask += "".join(list(map(str, self.result["xl"][self.RD][x][y]))).replace("-1", "?") + "\n"
        
        num_non_fixed_input_bits = self.result["num_non_fixed_input_bits"]
        num_non_fixed_output_bits = self.result["num_non_fixed_output_bits"]

        attack_summary = f"Attack summary:\n"
        attack_summary += f"Setting: RD: {self.RD}\n"
        attack_summary += "#"*50 + "\n"
        attack_summary += f"input:  \n{input_diff}"
        attack_summary += "#"*50 + "\n"
        attack_summary += f"output: \n{output_mask}"
        attack_summary += "#"*50 + "\n"
        attack_summary += f"Number of non-fixed input bits: {num_non_fixed_input_bits}\n"
        attack_summary += f"Number of non-fixed output bits: {num_non_fixed_output_bits}\n"        
        return attack_summary, upper_trail, lower_trail

#############################################################################################################################################
#############################################################################################################################################
#############################################################################################################################################
#  _   _                    ___         _                __                   
# | | | | ___   ___  _ __  |_ _| _ __  | |_  ___  _ __  / _|  __ _   ___  ___ 
# | | | |/ __| / _ \| '__|  | | | '_ \ | __|/ _ \| '__|| |_  / _` | / __|/ _ \
# | |_| |\__ \|  __/| |     | | | | | || |_|  __/| |   |  _|| (_| || (__|  __/
#  \___/ |___/ \___||_|    |___||_| |_| \__|\___||_|   |_|   \__,_| \___|\___|
                                                                            
def loadparameters(args):
    '''
    Extract parameters from the argument list and input file
    '''

    # Load default values
    params = {"RD": 2,              
              "tl"  : -1,
              "solver"  : "cp-sat",
              "num_of_threads" : 8,
              "output"  : "output.tex"}

    # Override parameters if they are set on command line
    if args.RD is not None:
        params["RD"] = args.RD    
    if args.timelimit is not None:
        params["timelimit"] = args.timelimit
    if args.solver is not None:
        params["solver"] = args.solver
    if args.p is not None:
        params["threads"] = args.p
    if args.output is not None:
        params["output"] = args.output

    return params

def main():
    '''
    Parse the arguments and start the request functionality with the provided
    parameters.
    '''
    
    parser = ArgumentParser(description="This tool finds the impossible-differential distinguisher for TWINKLE permutation.\n",
                            formatter_class=RawTextHelpFormatter)
    
    parser.add_argument("-RD", type=int, default=2, help="Number of rounds for distinguisher")    
    parser.add_argument("-tl", "--timelimit", type=int, default=43200, help="Time limit in seconds")
    # Fetch available solvers from MiniZinc
    available_solvers = [solver_name for solver_name in minizinc.default_driver.available_solvers().keys()]
    parser.add_argument("-sl", "--solver", default="cp-sat", type=str,
                        choices=available_solvers,
                        help="Choose a CP solver") 
    parser.add_argument("-p", default=8, type=int, help="number of threads for solvers supporting multi-threading\n")    
    parser.add_argument("-o", "--output", default="output.tex", type=str, help="Output file name")

    # Parse command line arguments and construct parameter list
    args = parser.parse_args()
    params = loadparameters(args)
    dld = Attack(params)
    dld.search()

if __name__ == "__main__":
    main()
