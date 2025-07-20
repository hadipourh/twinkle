# !/usr/bin/env python3
# -*- coding: utf-8 -*-

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
"""

from sage.all import *
from sboxanalyzer import *
import re

def replace_symbols(expression):
    replacements = {
        "\\(": "[",
        "\\)": "]",
        " \\| ": ", ",
        " & ": ",\n",
        "~": "-",
        "a0": "1",
        "a1": "2",
        "a2": "3",
        "a3": "4",
        "b0": "5",
        "b1": "6",
        "b2": "7",
        "b3": "8"
    }
    
    # Use regex to replace all occurrences
    for key, value in replacements.items():
        expression = re.sub(key, value, expression)
    
    return expression

lookuptable = [0, 3, 5, 0xd, 6, 0xf, 0xa, 8, 0xb, 4, 0xe, 2, 9, 0xc, 7, 1]
sa = SboxAnalyzer(lookuptable)
cnf, milp, cp = sa.minimized_linear_constraints(subtable='star')
# Input string
input_string = cnf
# Apply replacements
output_string = replace_symbols(input_string)
# Print the modified string
print("Sbox constraints:\n", output_string)

####################################################################################################
####################################################################################################
####################################################################################################

def replace_symbols_for_xor(expression):
    replacements = {
        "\\(": "[",
        "\\)": "]",
        " \\| ": ", ",
        " & ": ",\n",
        "~": "-",
        "a0": "1",
        "a1": "2",
        "b0": "3",
    }
    # Use regex to replace all occurrences
    for key, value in replacements.items():
        expression = re.sub(key, value, expression)
    
    return expression

xor = [0, 1, 1, 0]
sxor = SboxAnalyzer(xor)
cnf, milp, cp = sxor.minimized_linear_constraints(subtable='star')
# Input string
input_string = cnf
# Apply replacements
output_string = replace_symbols_for_xor(input_string)
# Print the modified string
print("Xor constraints:\n", output_string)

####################################################################################################
####################################################################################################
####################################################################################################


def replace_symbols_for_xor_3(expression):
    replacements = {
        "\\(": "[",
        "\\)": "]",
        " \\| ": ", ",
        " & ": ",\n",
        "~": "-",
        "a0": "1",
        "a1": "2",
        "a2": "3",
        "b0": "4",
    }
    # Use regex to replace all occurrences
    for key, value in replacements.items():
        expression = re.sub(key, value, expression)
    
    return expression

xor_3 = [0, 1, 1, 0, 1, 0, 0, 1]
sxor_3 = SboxAnalyzer(xor_3)
cnf, milp, cp = sxor_3.minimized_linear_constraints(subtable='star')
# Input string
input_string = cnf
# Apply replacements
output_string = replace_symbols_for_xor_3(input_string)
# Print the modified string
print("Xor_3 constraints:\n", output_string)

####################################################################################################
####################################################################################################
####################################################################################################

def replace_symbols_for_fork(expression):
    replacements = {
        "\\(": "[",
        "\\)": "]",
        " \\| ": ", ",
        " & ": ",\n",
        "~": "-",
        "a0": "1",
        "b0": "2",
        "b1": "3"
    }
    # Use regex to replace all occurrences
    for key, value in replacements.items():
        expression = re.sub(key, value, expression)
    
    return expression

# We know that a0 = b0 xor b1. 
# So, we first derive the truth table of the its characteristic Boolean function whose inputs are a0||b0||b1 and output is either 0 or 1 based on whether a0 = b0 xor b1 or not. 
def fork_as_boolean_function(a0, b0, b1):
    return int(a0 == b0 ^ b1)
fork_as_boolean_function = [fork_as_boolean_function(a0, b0, b1) for a0 in [0, 1] for b0 in [0, 1] for b1 in [0, 1]]
cnf, milp, cp = SboxAnalyzer.encode_boolean_function(fork_as_boolean_function, input_variables=['a0', 'b0', 'b1'])
# Apply replacements
output_string = replace_symbols_for_fork(cnf)
# Print the modified string
print("Fork constraints:\n", output_string)

fork_as_lookup_table = [0, 3]
sa = SboxAnalyzer(fork_as_lookup_table)
cnf, milp, cp = sa.minimized_linear_constraints(subtable='star')
