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

In case you use this tool please include the above copyright information (name, contact, license)

In this program, we find ZC distinguishers for TWINKLE permutation 
that will be converted to integral distinguishers afterwards.
"""

import os
import time
from itertools import combinations
from pysat import solvers
from pysat import formula
from argparse import ArgumentParser, RawTextHelpFormatter
from rich.progress import Progress
import uuid

class Attack:
    count = 0
    def __init__(self, nrounds=10, solver_name=solvers.SolverNames.cadical195, output_file_name="result.txt"):
        Attack.count += 1
        self.nrounds = nrounds
        self.sat_solver_name = solver_name
        self.supported_sat_solvers = [solver for solver in solvers.SolverNames.__dict__.keys() if not solver.startswith('__')]
        if self.sat_solver_name not in self.supported_sat_solvers:
            raise ValueError(f"Unsupported SAT solver: {self.sat_solver_name}")
        self.sat_solver = solvers.Solver(name=self.sat_solver_name)

        self.cnf_formula = formula.CNF()
        self.solver = solvers.Solver(name=self.sat_solver_name)
        self.variables_dictionary = dict()
        self.top_variable_identifier_so_far = 0
        unique_id = uuid.uuid4().hex
        self.cnf_file_name = f"attack_nr_{self.nrounds}_{unique_id}.cnf"
        self.output_file_name = output_file_name
        self.lane_rotation_0 = [20, 24, 38, 77, 49, 66, 30, 40, 76, 15, 46, 50, 17, 18, 61, 62]
        self.lane_rotation_1 = [63, 45, 34, 39, 32, 43, 60, 66, 54, 26, 55, 36, 61, 12, 15, 35]
        # 1: msb of input
        # 5: msb of output
        # input bits: 1, 2, 3, 4
        # output bits: 5, 6, 7, 8
        # We encode the S-box using the S-box Analyzer
        # S-box lookup table: [0, 3, 5, 0xd, 6, 0xf, 0xa, 8, 0xb, 4, 0xe, 2, 9, 0xc, 7, 1]
        self.sbox_cnf_pattern = [[1, 3, 5, -6, 7],
                                [-1, 2, -3, 4, -8],
                                [1, 2, 3, 4, -8],
                                [2, 3, 4, 6, -8],
                                [1, 5, 6, 7, -8],
                                [-1, 2, 3, 4, 8],
                                [1, 2, 4, -5, 8],
                                [1, 2, 4, -7, 8],
                                [2, 4, -5, -7, 8],
                                [-1, 3, 5, 7, 8],
                                [1, -2, 3, 4, 5, 6],
                                [-1, -2, 4, 5, -6, -7],
                                [1, -3, 4, 5, -6, -7],
                                [1, 2, -3, -5, -6, 7],
                                [-1, 2, -4, -5, -6, 7],
                                [1, 2, 3, -4, 6, 7],
                                [-2, -4, -5, -6, -7, -8],
                                [-1, 4, 5, 6, -7, -8],
                                [-1, -3, 5, -6, 7, -8],
                                [2, -4, 5, -6, 7, -8],
                                [-2, 4, 5, -6, 7, -8],
                                [-1, 2, -5, 6, 7, -8],
                                [-2, -3, 4, 5, 6, 8],
                                [2, -3, 4, 5, 7, 8],
                                [2, -3, -4, 6, 7, 8],
                                [-1, -2, -3, -4, -5, -6, -7],
                                [-1, -2, 3, -4, -5, 6, -7],
                                [1, -2, 3, -4, -5, -6, -7],
                                [1, -2, -3, -4, -5, 6, -7],
                                [-2, -4, 5, 7, 8],
                                [2, 4, -5, 6, -7],
                                [-2, -4, 5, 6, 7]]

        # xor inputs: 1, 2
        # xor output: 3
        self.xor_cnf_template = [[1, -2], [2, -3], [-1, 3]]
        # xor3 inputs: 1, 2, 3
        # xor3 output: 4
        self.xor3_cnf_template = [[1, -2], [2, -3], [3, -4], [-1, 4]]
        # fork inputs: 1
        # fork outputs: 2, 3
        self.fork_cnf_template = [[-1, 2, 3], [1, -2, 3], [1, 2, -3], [-1, -2, -3]]
        # 3fork inputs: 1
        # 3fork outputs: 2, 3, 4
        self.fork3_cnf_template = [[-1, 2, 3, 4], [1, -2, 3, 4], [1, 2, -3, 4], [-1, -2, -3, 4], [1, 2, 3, -4], [-1, -2, 3, -4], [-1, 2, -3, -4], [1, -2, -3, -4]]
    
    def generate_sbox_constraint(self, input_bits, output_bits):
        substitution_list = [self.variables_dictionary[x] for x in input_bits + output_bits]
        for sl in self.sbox_cnf_pattern:
            temp = []
            for index in sl:
                if index > 0:
                    temp.append(substitution_list[index - 1])
                else:
                    temp.append(-substitution_list[abs(index) - 1])
            self.cnf_formula.append(temp)

    def update_variables_dictionary(self, new_vars):
        """
        This method is used to update variables' dictionary
        """
        
        for nv in new_vars:
            if nv not in self.variables_dictionary.keys():
                self.top_variable_identifier_so_far += 1
                self.variables_dictionary[nv] = self.top_variable_identifier_so_far

    @staticmethod
    def flatten_state(lst):
        """
        Recursively flattens a nested list.
        """
        
        if not isinstance(lst, list):
            return [lst]
        flattened = []
        for item in lst:
            flattened.extend(Attack.flatten_state(item))
        return flattened
    
    def generate_state_variables(self, rn, prefix="x"):
        """
        Generate the state variables of rn'th round
        """
        
        x = [[[f"{prefix}_{rn}_{x}_{y}_{z}" for z in range(80)] for y in range(4)] for x in range(4)]
        self.update_variables_dictionary(self.flatten_state(x))
        return x

    def generate_slice_variables(self, rn, prefix="sl", z=0):
        """
        Generate the lane variables
        """
        
        slice = [[f"{prefix}_{rn}_{x}_{y}_{z}" for y in range(4)] for x in range(4)]
        self.update_variables_dictionary(self.flatten_state(slice))
        return slice
        
    def constraints_by_fork(self, a, b1, b2):
        """
        a ---fork---> (b1, b2)
        """
        
        self.cnf_formula.append([-self.variables_dictionary[a],\
                                self.variables_dictionary[b1],\
                                self.variables_dictionary[b2]])
        self.cnf_formula.append([-self.variables_dictionary[b1], self.variables_dictionary[a]])
        self.cnf_formula.append([-self.variables_dictionary[b2], self.variables_dictionary[a]])

    def constraints_by_xor(self, a1, a2, b):
        """
        a1, a2 ---> b = a1 + a2
        """
        
        substitution_list = [self.variables_dictionary[x] for x in  [a1, a2, b]]
        for sl in self.xor_cnf_template:
            temp = []
            for index in sl:
                if index > 0:
                    temp.append(substitution_list[index - 1])
                else:
                    temp.append(-substitution_list[abs(index) - 1])
            self.cnf_formula.append(temp)
    
    def constraints_by_3xor(self, a1, a2, a3, b, constant=0):
        """
        a1, a2, a3 ---> b = a1 + a2 + a3
        or
        a1, a2, a3 ---> b = a1 + a2 + a3 + 1
        """
        
        if constant not in [0, 1]:
            raise ValueError("The constant must be either 0 or 1.")
        substitution_list = [self.variables_dictionary[x] for x in  [a1, a2, a3, b]]
        for sl in self.xor3_cnf_template :
            temp = []
            for index in sl:
                if index > 0:
                    temp.append(substitution_list[index - 1])
                else:
                    temp.append(-substitution_list[abs(index) - 1])
            self.cnf_formula.append(temp)
        
    def constraints_by_fork(self, a0, b0, b1):
        """
        a0 ---fork---> (b0, b1)
        """
        
        substitution_list = [self.variables_dictionary[x] for x in  [a0, b0, b1]]
        for sl in self.fork_cnf_template:
            temp = []
            for index in sl:
                if index > 0:
                    temp.append(substitution_list[index - 1])
                else:
                    temp.append(-substitution_list[abs(index) - 1])
            self.cnf_formula.append(temp)
        
    def constraints_by_3fork(self, a0, b0, b1, b2):
        """
        a0 ---3fork---> (b0, b1, b2)
        """
        
        substitution_list = [self.variables_dictionary[x] for x in  [a0, b0, b1, b2]]
        for sl in self.fork3_cnf_template:
            temp = []
            for index in sl:
                if index > 0:
                    temp.append(substitution_list[index - 1])
                else:
                    temp.append(-substitution_list[abs(index) - 1])
            self.cnf_formula.append(temp)

    def generate_constraints(self):
        """
        Generate the constraints for each round (the core of the program)
        """
        
        for rn in range(self.nrounds):
            input_state = self.generate_state_variables(rn, prefix="x")
            state_after_sbox = self.generate_state_variables(rn, prefix="y")
            output_state = self.generate_state_variables(rn + 1, prefix="x")  
            # model the s-box layer
            for z in range(80):
                for y in range(4):
                    sbox_input = [input_state[x][y][z] for x in range(4)]
                    sbox_output = [state_after_sbox[x][y][z] for x in range(4)]
                    self.generate_sbox_constraint(sbox_input, sbox_output)
            # model the lane_rotation_0
            for x in range(4):
                for y in range(4):
                    state_after_sbox[x][y] = [state_after_sbox[x][y][(z - self.lane_rotation_0[x + 4*y]) % 80] for z in range(80)]
            # model the fork 
            for z in range(80):
                slice_z_0 = self.generate_slice_variables(rn, prefix="slice_lr0", z=z)
                slice_z_5 = self.generate_slice_variables(rn, prefix="slice_lr5", z=z)
                slice_z_12 = self.generate_slice_variables(rn, prefix="slice_lr12", z=z)
                # fork the slices
                for x in range(4):
                    for y in range(4):
                        self.constraints_by_3fork(state_after_sbox[x][y][z], slice_z_0[x][y], slice_z_5[x][y], slice_z_12[x][y])
                # flatten slice_z_0, slice_z_5, slice_z_12
                slice_z_0_flat = [slice_z_0[x][y] for y in range(4) for x in range(4)]
                slice_z_5_flat = [slice_z_5[x][y] for y in range(4) for x in range(4)]
                slice_z_12_flat = [slice_z_12[x][y] for y in range(4) for x in range(4)]
                # rotate slice_z_0 to the left by 0 bits
                slice_z_0_flat = slice_z_0_flat[-0:] + slice_z_0_flat[:-0]
                # rotate slice_z_5 to the left by 5 bits
                slice_z_5_flat = slice_z_5_flat[-5:] + slice_z_5_flat[:-5]
                # rotate slice_z_12 to the left by 12 bits
                slice_z_12_flat = slice_z_12_flat[-12:] + slice_z_12_flat[:-12]
                # reshape the slices into 4x4
                slice_z_0 = [[slice_z_0_flat[y + 4*x] for y in range(4)] for x in range(4)]
                slice_z_5 = [[slice_z_5_flat[y + 4*x] for y in range(4)] for x in range(4)]
                slice_z_12 = [[slice_z_12_flat[y + 4*x] for y in range(4)] for x in range(4)]
                # model the XOR in mixslice
                for x in range(4):
                    for y in range(4):
                        self.constraints_by_3xor(slice_z_0[x][y], slice_z_5[x][y], slice_z_12[x][y], output_state[x][y][(z + self.lane_rotation_1[x + 4*y]) % 80])

    def generate_sat_model(self):
        self.generate_constraints()
        self.cnf_formula.to_file(self.cnf_file_name)
        self.sat_solver.append_formula(self.cnf_formula)

    def check_iopattern(self, active_indices=[(0, 0, 0)], target_output_bits = range(1280)):
        input_vars = self.generate_state_variables(0, prefix="x")
        output_vars = self.flatten_state(self.generate_state_variables(self.nrounds - 1, prefix="y"))

        input_active_pattern = []
        for z in range(80):
            for y in range(4):
                for x in range(4):
                    if (x, y, z) in active_indices:
                        input_active_pattern.append(self.variables_dictionary[input_vars[x][y][z]])
                    else:
                        input_active_pattern.append(-self.variables_dictionary[input_vars[x][y][z]])
        
        balanced_bits = []
        not_checked_bits = []
        start_time = time.time()    
        for output_bit in target_output_bits:
            output_active_pattern = []
            for i in range(1280):
                if i != output_bit:
                    output_active_pattern.append(-self.variables_dictionary[output_vars[i]])
                else:
                    output_active_pattern.append(self.variables_dictionary[output_vars[i]])
            assumptions = input_active_pattern + output_active_pattern
            result = self.sat_solver.solve(assumptions=assumptions)
            if result == True:
                # print("Output bit number {:03d} may NOT be key-independent :-(".format(output_bit))
                pass
            elif result == False:
                balanced_bits.append(output_bit)
                # print("Output bit number {:03d} is key-independent ;-)".format(output_bit))
            else:
                not_checked_bits.append(output_bit)
                # print("Output bit number {:03d} was not checked!".format(output_bit))
        elapsed_time = time.time() - start_time
        number_of_balanced_bits = len(balanced_bits)
        # print(f"Number of key-independent bits: {number_of_balanced_bits}")
        # print(f"Key-Independent bits:\n{balanced_bits}")
        # print(f"Not-Checked bits:{not_checked_bits}\n")
        # print("Time used to solve: {:0.02f}".format(elapsed_time))        
        ######################### Save results in output file ##############################
        with open(self.output_file_name, "a") as outputfile:
            separator_line = "#"*100 + "\n"
            outputfile.write(separator_line)
            outputfile.write(f"Fixed input positions: {active_indices}\n")
            outputfile.write(f"Key-independent output positions: {balanced_bits}\n")
            outputfile.write(f"Number of key-independent bits: {number_of_balanced_bits}\n")
        ####################################################################################
        return balanced_bits

def parse_args():
    """
    Parse input parameters
    """
    parser = ArgumentParser(description="This tool derives and solves the SAT "
                                        "model corresponding to ZC/Integral analysis of TWINKLE.\n",
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument("-nr", "--nrounds", default=6, type=int, help="number of rounds\n")
    parser.add_argument("-sl", "--solver", default="cadical195", type=str,
                        choices=[solver for solver in solvers.SolverNames.__dict__.keys() if not solver.startswith('__')],
                        help="choose a SAT solver\n")
    parser.add_argument("-f", "--active_indices", default=[0, 32, 64, 96], type=int, nargs="*", help="list of fixed indices\n")
    parser.add_argument("-o", "--output", default="result.txt", type=str, help="output file name\n")
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    separator_line = "#"*77
    attack_instance = Attack(nrounds=args.nrounds, solver_name=args.solver, output_file_name=args.output)
    with open(attack_instance.output_file_name, "w") as outputfile:
        outputfile.write(f"Results of applying attack to {attack_instance.nrounds} rounds of TWINKLE permutation\n")
    mp_dict = dict()
    attack_instance.generate_sat_model()
    print(separator_line)
    print(f"Searching for key-independent bits after {args.nrounds} rounds of TWINKLE permutation ...")    
    all_output_bits_after_last_sbox_layer_are_balanced = True
    start_time = time.time() 
    list_of_selected_slices = [0, 10, 54, 79]
    with Progress() as progress:
        task = progress.add_task("Checking output bits", total=len(list_of_selected_slices)*4)
        for z in list_of_selected_slices:
            for y in range(4):
                active_indices = [(x, y, z) for x in range(4)]
                # check all of the subsets of active_indices                
                for i in range(1, 2): # range(1, len(active_indices) + 1):
                    for subset in combinations(active_indices, i):
                        balanced_bits = attack_instance.check_iopattern(active_indices=subset)
                        if len(balanced_bits) != 1280:
                            all_output_bits_after_last_sbox_layer_are_balanced = False                            
                progress.update(task, advance=1)
    elapsed_time = time.time() - start_time                    
    os.remove(attack_instance.cnf_file_name)    
    print(f"Time used to check all output bits: {elapsed_time:.2f} seconds")    
    if all_output_bits_after_last_sbox_layer_are_balanced:
        print("All output bits after the last S-box layer are key-independent")
    else:
        print("Some output bits after the last S-box layer are not key-independent")
    print("Attack finished!")
    print(f"Results are saved in {attack_instance.output_file_name}")
    print(separator_line)
    

