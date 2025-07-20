# Algorithm 2

This folder implements an algorithm to select a set of linear inequalities from the H-representation of a set of points.

## Files

- **cipher_Inequalities.txt**  
    Contains the H-representation of a given set of points, represented as a set of linear inequalities returned by Sage software.  
    Each inequality has the form:  
    $$(a_1, a_2, \ldots, a_n) \cdot x^T + b \geq 0$$  
    and is stored in the file as:  
    $$(a_1, a_2, \ldots, a_n, b)$$  
    This file lists all linear inequalities from the H-representation of the division trails of the TWINKLE S-box, with each line representing a single inequality.

- **cipher_Reduced_Inequalities.txt**  
    Contains the reduced set of inequalities.

