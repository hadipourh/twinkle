/*
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
*/

int: RU; 
int: RM;
int: RL;
int: WU;
int: WM;
int: WL;

constraint assert(RU >= 0, "Invalid value for RU: RU must be greater than or equal to 0");
constraint assert(RM >= 0, "Invalid value for RM: RM must be greater than or equal to 0");
constraint assert(RL >= 0, "Invalid value for RL: RL must be greater than or equal to 0");

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%  ____          __  _                _                   _                    _____       _      _            
% |  _ \   ___  / _|(_) _ __    ___  | |     ___    ___  | | __ _   _  _ __   |_   _|__ _ | |__  | |  ___  ___ 
% | | | | / _ \| |_ | || '_ \  / _ \ | |    / _ \  / _ \ | |/ /| | | || '_ \    | | / _` || '_ \ | | / _ \/ __|
% | |_| ||  __/|  _|| || | | ||  __/ | |___| (_) || (_) ||   < | |_| || |_) |   | || (_| || |_) || ||  __/\__ \
% |____/  \___||_|  |_||_| |_| \___| |_____|\___/  \___/ |_|\_\ \__,_|| .__/    |_| \__,_||_.__/ |_| \___||___/
%                                                                     |_|                                      
% define lookup tables
array[0..1, 0..15] of int: lane_rotation = array2d(0..1, 0..15,
        [
        20, 24, 38, 77, 49, 66, 30, 40, 76, 15, 46, 50, 17, 18, 61, 62,
        63, 45, 34, 39, 32, 43, 60, 66, 54, 26, 55, 36, 61, 12, 15, 35
        ]
    );

array[0..15, 0..2] of int: mixslice_differential_forward = array2d(0..15, 0..2,
        [
        0, 4, 11, 
        1, 5, 12, 
        2, 6, 13, 
        3, 7, 14, 
        4, 8, 15, 
        0, 5, 9, 
        1, 6, 10, 
        2, 7, 11, 
        3, 8, 12, 
        4, 9, 13, 
        5, 10, 14, 
        6, 11, 15, 
        0, 7, 12, 
        1, 8, 13, 
        2, 9, 14, 
        3, 10, 15
        ]
    );

array[0..15, 0..8] of int: mixslice_differential_backward = array2d(0..15, 0..8,
        [
        0, 4, 5, 7, 8, 10, 12, 14, 15, 
        0, 1, 5, 6, 8, 9, 11, 13, 15, 
        0, 1, 2, 6, 7, 9, 10, 12, 14, 
        1, 2, 3, 7, 8, 10, 11, 13, 15, 
        0, 2, 3, 4, 8, 9, 11, 12, 14, 
        1, 3, 4, 5, 9, 10, 12, 13, 15, 
        0, 2, 4, 5, 6, 10, 11, 13, 14, 
        1, 3, 5, 6, 7, 11, 12, 14, 15, 
        0, 2, 4, 6, 7, 8, 12, 13, 15, 
        0, 1, 3, 5, 7, 8, 9, 13, 14, 
        1, 2, 4, 6, 8, 9, 10, 14, 15, 
        0, 2, 3, 5, 7, 9, 10, 11, 15, 
        0, 1, 3, 4, 6, 8, 10, 11, 12, 
        1, 2, 4, 5, 7, 9, 11, 12, 13, 
        2, 3, 5, 6, 8, 10, 12, 13, 14, 
        3, 4, 6, 7, 9, 11, 13, 14, 15
        ]
    );

array[0..15, 0..8] of int: mixslice_linear_forward = array2d(0..15, 0..8,
        [
        0, 1, 2, 4, 6, 8, 9, 11, 12, 
        1, 2, 3, 5, 7, 9, 10, 12, 13, 
        2, 3, 4, 6, 8, 10, 11, 13, 14, 
        3, 4, 5, 7, 9, 11, 12, 14, 15, 
        0, 4, 5, 6, 8, 10, 12, 13, 15, 
        0, 1, 5, 6, 7, 9, 11, 13, 14, 
        1, 2, 6, 7, 8, 10, 12, 14, 15, 
        0, 2, 3, 7, 8, 9, 11, 13, 15, 
        0, 1, 3, 4, 8, 9, 10, 12, 14, 
        1, 2, 4, 5, 9, 10, 11, 13, 15, 
        0, 2, 3, 5, 6, 10, 11, 12, 14, 
        1, 3, 4, 6, 7, 11, 12, 13, 15, 
        0, 2, 4, 5, 7, 8, 12, 13, 14, 
        1, 3, 5, 6, 8, 9, 13, 14, 15, 
        0, 2, 4, 6, 7, 9, 10, 14, 15, 
        0, 1, 3, 5, 7, 8, 10, 11, 15
        ]
    );

array[0..15, 0..2] of int: mixslice_linear_backward = array2d(0..15, 0..2,
        [
        0, 5, 12, 
        1, 6, 13, 
        2, 7, 14, 
        3, 8, 15, 
        0, 4, 9, 
        1, 5, 10, 
        2, 6, 11, 
        3, 7, 12, 
        4, 8, 13, 
        5, 9, 14, 
        6, 10, 15, 
        0, 7, 11, 
        1, 8, 12, 
        2, 9, 13, 
        3, 10, 14, 
        4, 11, 15
        ]
    );

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                    _                _         _           __                _____  _   _ 
%  / ___| ___   _ __   ___ | |_  _ __  __ _ (_) _ __  | |_  ___   / _|  ___   _ __  | ____|| | | |
% | |    / _ \ | '_ \ / __|| __|| '__|/ _` || || '_ \ | __|/ __| | |_  / _ \ | '__| |  _|  | | | |
% | |___| (_) || | | |\__ \| |_ | |  | (_| || || | | || |_ \__ \ |  _|| (_) || |    | |___ | |_| |
%  \____|\___/ |_| |_||___/ \__||_|   \__,_||_||_| |_| \__||___/ |_|   \___/ |_|    |_____| \___/ 
% Constraints for EU                                                                                                
array[0..RU, 0..3, 0..3, 0..79] of var 0..1: xu; % state before s-box
array[0..(RU - 1), 0..3, 0..3, 0..79] of var 0..1: yu; % state after s-box
array[0..(RU - 1), 0..3, 0..3, 0..79] of var 0..1: zu; % state after the lane-rotation0
array[0..(RU - 1), 0..3, 0..3, 0..79] of var 0..1: wu; % state after the mixslice
array[0..(RU - 1), 0..2, 0..3, 0..79] of var 0..1: pu; % probability of transition over the s-box(-log2)
% the state after the lane-rotation1 is xu[round + 1, *, *, *]
% s-box
constraint forall(round in 0..(RU - 1), y in 0..3, z in 0..79)
(
    sbox_difference_forward_probabilistic(xu[round, 0, y, z], xu[round, 1, y, z], xu[round, 2, y, z], xu[round, 3, y, z],
                                          yu[round, 0, y, z], yu[round, 1, y, z], yu[round, 2, y, z], yu[round, 3, y, z],
                                          pu[round, 0, y, z], pu[round, 1, y, z], pu[round, 2, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RU - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zu[round, x, y, z] = yu[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RU - 1), z in 0..79) (
        let {
            array[0..15] of var 0..1: fzu = array1d(0..15, [zu[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var 0..1: fwu = array1d(0..15, [wu[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor3_probabilistic(
                fzu[mixslice_differential_forward[i, 0]],
                fzu[mixslice_differential_forward[i, 1]],
                fzu[mixslice_differential_forward[i, 2]],
                fwu[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RU - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xu[round + 1, x, y, z] = wu[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);

% exclude trivial solutions
constraint sum(x in 0..3, y in 0..3, z in 0..79)(xu[0, x, y, z]) != 0;

% accumulative probability for EU (multiplied by 10 skipping the fractional part)
% exact objective function: 3.0000 p0 + 2.0000 p1 + 1.4150 p2
% we work with the scaled (and approximated) version of the objective function: 30.0000 p0 + 20.0000 p1 + 14.00 p2
var 0..102400: PU;
constraint PU = sum(round in 0..(RU - 1), y in 0..3, z in 0..79)(
    30*pu[round, 0, y, z] +
    20*pu[round, 1, y, z] +
    14*pu[round, 2, y, z]
);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                    _                _         _           __                _____  __  __  _   _ 
%  / ___| ___   _ __   ___ | |_  _ __  __ _ (_) _ __  | |_  ___   / _|  ___   _ __  | ____||  \/  || | | |
% | |    / _ \ | '_ \ / __|| __|| '__|/ _` || || '_ \ | __|/ __| | |_  / _ \ | '__| |  _|  | |\/| || | | |
% | |___| (_) || | | |\__ \| |_ | |  | (_| || || | | || |_ \__ \ |  _|| (_) || |    | |___ | |  | || |_| |
%  \____|\___/ |_| |_||___/ \__||_|   \__,_||_||_| |_| \__||___/ |_|   \___/ |_|    |_____||_|  |_| \___/ 
% Constraints for EMU                                                                                                     

array[0..RM, 0..3, 0..3, 0..79] of var -1..1: xmu; % state before s-box
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: ymu; % state after s-box
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: zmu; % state after the lane-rotation0
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: wmu; % state after the mixslice
% the state after the lane-rotation1 is xmu[round + 1, *, *, *]

% connect the end of EU to the beginning of EMU
constraint forall(x in 0..3, y in 0..3, z in 0..79)(
    xmu[0, x, y, z] = xu[RU, x, y, z]
);

% s-box
constraint forall(round in 0..(RM - 1), y in 0..3, z in 0..79)
(
    sbox_difference_forward_deterministic(
         xmu[round, 0, y, z], xmu[round, 1, y, z], xmu[round, 2, y, z], xmu[round, 3, y, z],
         ymu[round, 0, y, z], ymu[round, 1, y, z], ymu[round, 2, y, z], ymu[round, 3, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RM - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zmu[round, x, y, z] = ymu[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RM - 1), z in 0..79) (
        let {
            array[0..15] of var -1..1: fzmu = array1d(0..15, [zmu[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var -1..1: fwmu = array1d(0..15, [wmu[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor3_deterministic(
                fzmu[mixslice_differential_forward[i, 0]],
                fzmu[mixslice_differential_forward[i, 1]],
                fzmu[mixslice_differential_forward[i, 2]],
                fwmu[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RM - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xmu[round + 1, x, y, z] = wmu[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                    _                _         _           __                _____  __  __  _     
%  / ___| ___   _ __   ___ | |_  _ __  __ _ (_) _ __  | |_  ___   / _|  ___   _ __  | ____||  \/  || |    
% | |    / _ \ | '_ \ / __|| __|| '__|/ _` || || '_ \ | __|/ __| | |_  / _ \ | '__| |  _|  | |\/| || |    
% | |___| (_) || | | |\__ \| |_ | |  | (_| || || | | || |_ \__ \ |  _|| (_) || |    | |___ | |  | || |___ 
%  \____|\___/ |_| |_||___/ \__||_|   \__,_||_||_| |_| \__||___/ |_|   \___/ |_|    |_____||_|  |_||_____|
% Constraints for EML
 
array[0..RM, 0..3, 0..3, 0..79] of var -1..1: xml; % state before s-box
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: yml; % state after s-box
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: zml; % state after the lane-rotation0
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: wml; % state after the mixslice
% the state after the lane-rotation1 is xml[round + 1, *, *, *]

% s-box
constraint forall(round in 0..(RM - 1), y in 0..3, z in 0..79)
(
    sbox_linear_backward_deterministic(
             yml[round, 0, y, z], yml[round, 1, y, z], yml[round, 2, y, z], yml[round, 3, y, z],
             xml[round, 0, y, z], xml[round, 1, y, z], xml[round, 2, y, z], xml[round, 3, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RM - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zml[round, x, y, z] = yml[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RM - 1), z in 0..79) (
        let {
            array[0..15] of var -1..1: fzml = array1d(0..15, [zml[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var -1..1: fwml = array1d(0..15, [wml[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor3_deterministic(
                fwml[mixslice_linear_backward[i, 0]],
                fwml[mixslice_linear_backward[i, 1]],
                fwml[mixslice_linear_backward[i, 2]],
                fzml[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RM - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xml[round + 1, x, y, z] = wml[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                    _                _         _           __                _____  _     
%  / ___| ___   _ __   ___ | |_  _ __  __ _ (_) _ __  | |_  ___   / _|  ___   _ __  | ____|| |    
% | |    / _ \ | '_ \ / __|| __|| '__|/ _` || || '_ \ | __|/ __| | |_  / _ \ | '__| |  _|  | |    
% | |___| (_) || | | |\__ \| |_ | |  | (_| || || | | || |_ \__ \ |  _|| (_) || |    | |___ | |___ 
%  \____|\___/ |_| |_||___/ \__||_|   \__,_||_||_| |_| \__||___/ |_|   \___/ |_|    |_____||_____|
% Constraints for EL                                                                                                

array[0..RL, 0..3, 0..3, 0..79] of var 0..1: xl; % state before s-box
array[0..(RL - 1), 0..3, 0..3, 0..79] of var 0..1: yl; % state after s-box
array[0..(RL - 1), 0..3, 0..3, 0..79] of var 0..1: zl; % state after the lane-rotation0
array[0..(RL - 1), 0..3, 0..3, 0..79] of var 0..1: wl; % state after the mixslice
array[0..(RL - 1), 0..1, 0..3, 0..79] of var 0..1: cl; % squared correlation of transition over the s-box (-log2)
% the state after the lane-rotation1 is xl[round + 1, *, *, *]

% connect the beginning of EL to the end of EML
constraint forall(x in 0..3, y in 0..3, z in 0..79)(
    xl[0, x, y, z] = xml[RM, x, y, z]
);

% s-box
constraint forall(round in 0..(RL - 1), y in 0..3, z in 0..79)
(
    sbox_linear_backward_probabilistic(yl[round, 0, y, z], yl[round, 1, y, z], yl[round, 2, y, z], yl[round, 3, y, z],
                                       xl[round, 0, y, z], xl[round, 1, y, z], xl[round, 2, y, z], xl[round, 3, y, z],
                                       cl[round, 0, y, z], cl[round, 1, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RL - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zl[round, x, y, z] = yl[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RL - 1), z in 0..79) (
        let {
            array[0..15] of var 0..1: fzl = array1d(0..15, [zl[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var 0..1: fwl = array1d(0..15, [wl[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor3_probabilistic(
                fwl[mixslice_linear_backward[i, 0]],
                fwl[mixslice_linear_backward[i, 1]],
                fwl[mixslice_linear_backward[i, 2]],
                fzl[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RL - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xl[round + 1, x, y, z] = wl[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);

% exclude trivial solutions
constraint sum(x in 0..3, y in 0..3, z in 0..79)(xl[RL, x, y, z]) != 0;

% accumulative squared correlation for EL (multiplied by 10)
% exact objective function: 4.0000 p0 + 2.0000 p1
% we work with the scaled version of the objective function: 40.0000 p0 + 20.0000 p1
var 0..96000: CL; 
constraint CL = sum(round in 0..(RL - 1), y in 0..3, z in 0..79)(
    40*cl[round, 0, y, z] +
    20*cl[round, 1, y, z]
);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%  __  __                                       _    _              ___                     _               
% |  \/  |  ___   __ _  ___  _   _  _ __  ___  | |_ | |__    ___   / _ \ __   __ ___  _ __ | |  __ _  _ __  
% | |\/| | / _ \ / _` |/ __|| | | || '__|/ _ \ | __|| '_ \  / _ \ | | | |\ \ / // _ \| '__|| | / _` || '_ \ 
% | |  | ||  __/| (_| |\__ \| |_| || |  |  __/ | |_ | | | ||  __/ | |_| | \ V /|  __/| |   | || (_| || |_) |
% |_|  |_| \___| \__,_||___/ \__,_||_|   \___|  \__||_| |_| \___|  \___/   \_/  \___||_|   |_| \__,_|| .__/ 
%                                                                                                    |_|    
% Measure the overlap between the difference and linear propagations through EM 

array[0..RM, 0..3, 0..3, 0..79] of var -1..1: overlap_before_sbox; % state before s-box
array[0..(RM - 1), 0..3, 0..3, 0..79] of var -1..1: overlap_after_sbox; % state after s-box
var 0..640000: CM; % accumulative overlap for EM

% constraint CM = 10*sum(round in 0..(RM - 1), x in 0..3, y in 0..3, z in 0..79)(
%                 bool2int(xmu[round, x, y, z] = -1 /\ xml[round, x, y, z] = -1)
%                 +
%                 bool2int(xmu[round, x, y, z] = -1 /\ xml[round, x, y, z] = 1)
%                 +                 
%                 bool2int(xmu[round, x, y, z] = 1 /\ xml[round, x, y, z] = -1));

constraint CM = 10*sum(round in 0..(RM - 1), x in 0..3, y in 0..3, z in 0..79)(
                bool2int(ymu[round, x, y, z] = -1 /\ yml[round, x, y, z] = -1)
                +
                bool2int(ymu[round, x, y, z] = -1 /\ yml[round, x, y, z] = 1)
                +
                bool2int(ymu[round, x, y, z] = 1 /\ yml[round, x, y, z] = -1));

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%  ____                           _       ____   _                _                      
% / ___|   ___   __ _  _ __  ___ | |__   / ___| | |_  _ __  __ _ | |_  ___   __ _  _   _ 
% \___ \  / _ \ / _` || '__|/ __|| '_ \  \___ \ | __|| '__|/ _` || __|/ _ \ / _` || | | |
%  ___) ||  __/| (_| || |  | (__ | | | |  ___) || |_ | |  | (_| || |_|  __/| (_| || |_| |
% |____/  \___| \__,_||_|   \___||_| |_| |____/  \__||_|   \__,_| \__|\___| \__, | \__, |
%                                                                           |___/  |___/ 
% Search strategy
ann: search_ann;
search_ann = seq_search([
    int_search([xml[RM, x, y, z] | z in 0..79, y in 0..3, x in 0..3], indomain_median, complete),]);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ___   _      _              _    _               _____                     _    _               
%  / _ \ | |__  (_)  ___   ___ | |_ (_)__   __ ___  |  ___|_   _  _ __    ___ | |_ (_)  ___   _ __  
% | | | || '_ \ | | / _ \ / __|| __|| |\ \ / // _ \ | |_  | | | || '_ \  / __|| __|| | / _ \ | '_ \ 
% | |_| || |_) || ||  __/| (__ | |_ | | \ V /|  __/ |  _| | |_| || | | || (__ | |_ | || (_) || | | |
%  \___/ |_.__/_/ | \___| \___| \__||_|  \_/  \___| |_|    \__,_||_| |_| \___| \__||_| \___/ |_| |_|
%             |__/                                                                                  
% Objective function 

% some artificial constraints to control the input and output masks
% constraint sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xu[0, x, y, z] != 0)) == 1;
% constraint sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xl[RM, x, y, z] != 0)) == 1;
% solve satisfy;

solve minimize WU*PU + WM*CM + WL*CL;

% solve :: restart_constant(10000)
%       :: search_ann minimize sum(x in 0..3, y in 0..3, z in 0..79)(xu[0, x, y, z]);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%  ____         _         _     ____          _         _    _               
% |  _ \  _ __ (_) _ __  | |_  / ___|   ___  | | _   _ | |_ (_)  ___   _ __  
% | |_) || '__|| || '_ \ | __| \___ \  / _ \ | || | | || __|| | / _ \ | '_ \ 
% |  __/ | |   | || | | || |_   ___) || (_) || || |_| || |_ | || (_) || | | |
% |_|    |_|   |_||_| |_| \__| |____/  \___/ |_| \__,_| \__||_| \___/ |_| |_|
% print the results

output [
    if r = 0 then "\n\n" endif ++
    "xu_" ++ show(r) ++ ": \n" ++
    join("\n", [join("", [if fix(xu[r, x, y, z]) = -1 then "?" else show(fix(xu[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n" ++
    (if r < RU then
        "yu_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(yu[r, x, y, z]) = -1 then "?" else show(fix(yu[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
    endif)
    | r in 0..RU];

output [
    if r = 0 then "\n\n" endif ++
    "xmu_" ++ show(r) ++ ": \n" ++
    join("\n", [join("", [if fix(xmu[r, x, y, z]) = -1 then "?" else show(fix(xmu[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n" ++
    (if r < RM then
        "ymu_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(ymu[r, x, y, z]) = -1 then "?" else show(fix(ymu[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
    endif)
    | r in 0..RM];

    output [
        if r = 0 then "\n\n" endif ++
        "xml_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(xml[r, x, y, z]) = -1 then "?" else show(fix(xml[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n" ++
        (if r < RM then
            "yml_" ++ show(r) ++ ": \n" ++
            join("\n", [join("", [if fix(yml[r, x, y, z]) = -1 then "?" else show(fix(yml[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
        endif)
        | r in 0..RM];
    

output [
    if r = 0 then "\n\n" endif ++
    "xl_" ++ show(r) ++ ": \n" ++
    join("\n", [join("", [if fix(xl[r, x, y, z]) = -1 then "?" else show(fix(xl[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n" ++
    (if r < RL then
        "yl_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(yl[r, x, y, z]) = -1 then "?" else show(fix(yl[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
    endif)
    | r in 0..RL];

    output [
        "\nPU: ", show(PU div 10), 
        "\nCM: ", show(CM div 10), 
        "\nCL: ", show(CL div 10), 
        "\nObjective Function Value: ", show((PU + CM + CL) div 10), "\n"
    ];

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%     _                 _  _  _                       _____                     _    _                    
%    / \   _   _ __  __(_)| |(_)  __ _  _ __  _   _  |  ___|_   _  _ __    ___ | |_ (_)  ___   _ __   ___ 
%   / _ \ | | | |\ \/ /| || || | / _` || '__|| | | | | |_  | | | || '_ \  / __|| __|| | / _ \ | '_ \ / __|
%  / ___ \| |_| | >  < | || || || (_| || |   | |_| | |  _| | |_| || | | || (__ | |_ | || (_) || | | |\__ \
% /_/   \_\\__,_|/_/\_\|_||_||_| \__,_||_|    \__, | |_|    \__,_||_| |_| \___| \__||_| \___/ |_| |_||___/
%                                             |___/       
% auxiliary functions

predicate xor3_deterministic(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: b0) = 
    if exists([a0 == -1, a1 == -1, a2 == -1]) then b0 = -1
    else b0 = (sum([a0, a1, a2]) mod 2) endif;

predicate xor9_deterministic(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, var -1..1: a4, 
               var -1..1: a5, var -1..1: a6, var -1..1: a7, var -1..1: a8, var -1..1: b0) =
    if exists([a0 == -1, a1 == -1, a2 == -1, a3 == -1, a4 == -1, a5 == -1, a6 == -1, a7 == -1, a8 == -1]) then b0 = -1
    else b0 = (sum([a0, a1, a2, a3, a4, a5, a6, a7, a8]) mod 2) endif;

predicate xor3_probabilistic(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: b0) = 
    b0 = (a0 + a1 + a2) mod 2;

predicate xor9_probabilistic(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: a4, 
                             var 0..1: a5, var 0..1: a6, var 0..1: a7, var 0..1: a8, var 0..1: b0) =
    b0 = (a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8) mod 2;

predicate sbox_difference_forward_deterministic(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, 
               var -1..1: b0, var -1..1: b1, var -1..1: b2, var -1..1: b3) = 
    % Encoded by SboxAnalyzer: https://github.com/hadipourh/sboxanalyzer
    if (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = 0 /\ b1 = 0 /\ b2 = 0 /\ b3 = 0)
    elseif (a0 == 0 /\ a1 == 0 /\ a2 == 1 /\ a3 == 0) then (b0 = -1 /\ b1 = 1 /\ b2 = -1 /\ b3 = -1)
    elseif (a0 == 0 /\ a1 == 1 /\ a2 == 0 /\ a3 == 1) then (b0 = -1 /\ b1 = 1 /\ b2 = -1 /\ b3 = 1)
    elseif (a0 == 0 /\ a1 == 1 /\ a2 == 1 /\ a3 == 1) then (b0 = -1 /\ b1 = 0 /\ b2 = -1 /\ b3 = -1)
    elseif (a0 == 1 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = 1)
    elseif (a0 == 1 /\ a1 == 1 /\ a2 == 0 /\ a3 == 1) then (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = 0)
    else (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    endif;
    
predicate sbox_linear_backward_deterministic(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, 
                   var -1..1: b0, var -1..1: b1, var -1..1: b2, var -1..1: b3) =
    % Encoded by SboxAnalyzer: https://github.com/hadipourh/sboxanalyzer
    if (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = 0 /\ b1 = 0 /\ b2 = 0 /\ b3 = 0)
    elseif (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 1) then (b0 = 1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    elseif (a0 == 0 /\ a1 == 1 /\ a2 == 0 /\ a3 == 0) then (b0 = -1 /\ b1 = -1 /\ b2 = 1 /\ b3 = -1)
    else (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    endif;

predicate sbox_difference_forward_probabilistic(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, 
                                                var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3,
                                                var 0..1: p0, var 0..1: p1, var 0..1: p2) =
    % Encoded by SboxAnalyzer: https://github.com/hadipourh/sboxanalyzer
    % Input: a0||a1||a2||a3; msb: a0
    % Output: b0||b1||b2||b3; msb: b0
    % Weight: 3.0000 p0 + 2.0000 p1 + 1.4150 p2
    - p0 - p1 >= -1
    /\
    b1 - p2 >= 0
    /\
    - p0 - p2 >= -1
    /\
    - p1 - p2 >= -1
    /\
    a0 + a1 - a3 + p0 >= 0
    /\
    - a1 + a2 + a3 + p0 >= 0
    /\
    b0 + b1 - b2 + p0 >= 0
    /\
    a1 - b0 + b2 + p0 >= 0
    /\
    a1 - a3 - b0 - p1 >= -2
    /\
    a1 + a2 + b0 - p1 >= 0
    /\
    a0 - a2 + p0 + p1 >= 0
    /\
    - a0 + a2 + p0 + p1 >= 0
    /\
    a0 - a1 + a2 - a3 + b1 >= -1
    /\
    - a0 - a2 - b0 + b1 - b2 >= -3
    /\
    - a0 - a1 + a2 + b0 - b3 >= -2
    /\
    - a2 - b0 - b1 - b2 - b3 >= -4
    /\
    - a0 + a2 - a3 + b2 - b3 >= -2
    /\
    - a0 + b0 - b1 + b2 - b3 >= -2
    /\
    a0 - a1 - a3 - b1 + b3 >= -2
    /\
    a2 - b0 - b1 - b2 + b3 >= -2
    /\
    a0 + a1 + a2 + a3 - p0 >= 0
    /\
    a1 + a3 - b0 - b2 - p0 >= -2
    /\
    a1 + a2 + a3 + b3 - p0 >= 0
    /\
    a0 + b0 + b2 + b3 - p0 >= 0
    /\
    a0 + a1 + a2 - b1 + p0 >= 0
    /\
    - a2 + a3 - b0 + b1 + p0 >= -1
    /\
    - a0 - a1 - b0 - b3 + p0 >= -3
    /\
    - a2 - b1 - b2 - b3 + p0 >= -3
    /\
    - a2 + a3 + b0 + b3 + p0 >= 0
    /\
    - a1 - b1 - b2 + b3 + p0 >= -2
    /\
    - a3 + b1 + b2 + b3 + p0 >= 0
    /\
    a0 - a1 - a2 + b2 - p1 >= -2
    /\
    - a3 - b0 + b2 + b3 - p1 >= -2
    /\
    - a1 - a3 - b1 - b3 + p1 >= -3
    /\
    - a0 + a1 - a2 + a3 - b1 - b3 >= -3
    /\
    - a0 - a1 - a2 - a3 + b1 + b3 >= -3
    /\
    - a1 - a3 - b0 + b1 - b2 + p1 >= -3
    /\
    a1 + a3 + b0 + b2 - b3 + p1 >= 0
    /\
    - a0 + a1 - b0 - b1 + b3 + p2 >= -2
    /\
    - a1 - a2 + b0 - b1 + b3 + p2 >= -2
    /\
    - a0 + a1 + a3 + b1 + b3 + p2 >= 0
    /\
    - a0 + a3 - b1 - b2 + b3 + p2 >= -2
    /\
    - a2 - a3 - b1 + b2 + b3 + p2 >= -2
    /\
    b0 + b1 + b2 - p0 + p1 + p2 >= 0
    /\
    - a1 + a2 + b0 - b1 - b2 - b3 - p0 >= -4
    /\
    a0 - a1 - b0 - b1 + b2 - b3 - p0 >= -4
    /\
    a2 - a3 - b0 - b1 + b2 - b3 - p0 >= -4
    /\
    - a0 + a1 - a2 - a3 + b1 - b3 + p1 >= -3
    /\
    a0 - a3 + b0 - b1 - b2 - b3 + p1 >= -3
    /\
    - a0 + a1 - a2 - a3 - b1 + b3 + p1 >= -3
    /\
    - a0 - a2 - b0 - b1 + b2 + b3 + p1 >= -3
    /\
    - a0 - a1 - a3 + b0 + b2 + p1 + p2 >= -2
    /\
    - a0 - a1 - a2 + a3 + b1 - b3 + p1 + p2 >= -3
    /\
    - a0 + a2 + a3 + b1 + b2 + b3 >= 0
    /\
    - a0 + a1 + a2 + b0 + b1 + b3 >= 0
    /\
    a0 + a2 - b0 + b1 - b2 >= -1
    /\
    a0 - a2 + a3 + b1 + b2 >= 0
    /\
    a0 + a1 - a2 + b0 + b1 >= 0;

predicate sbox_linear_backward_probabilistic(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, 
                                             var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3,
                                             var 0..1: p0, var 0..1: p1) =
    % Encoded by SboxAnalyzer:  https://github.com/hadipourh/sboxanalyzer
    % Input: a0||a1||a2||a3; msb: a0
    % Output: b0||b1||b2||b3; msb: b0
    % Weight: 4.0000 p0 + 2.0000 p1
    - p0 - p1 >= -1
    /\
    - a0 + p0 + p1 >= 0
    /\
    a0 - a2 - b3 + p0 >= -1
    /\
    - a0 - b1 + b3 - p1 >= -2
    /\
    a0 + a2 - b1 + p1 >= 0
    /\
    - a1 + a2 + b1 + p1 >= 0
    /\
    a2 - b0 + b1 + p1 >= 0
    /\
    a2 + b1 - b2 + p1 >= 0
    /\
    a0 - a2 + b3 + p1 >= 0
    /\
    b1 + b3 - p0 + p1 >= 0
    /\
    a1 - a3 - b0 + b1 + b3 >= -1
    /\
    - a3 + b0 + b1 + b2 + b3 >= 0
    /\
    a0 + a1 + a2 + a3 - p1 >= 0
    /\
    a0 + a1 + a2 + b0 - p1 >= 0
    /\
    - a0 - a1 - a3 - b1 - p1 >= -4
    /\
    - a0 + a1 - a2 + b1 - p1 >= -2
    /\
    - a1 - a3 - b0 - b2 - p1 >= -4
    /\
    a0 + a2 + b0 + b2 - p1 >= 0
    /\
    a1 + a2 - b1 - b3 - p1 >= -2
    /\
    a2 + a3 - b1 - b3 - p1 >= -2
    /\
    a3 + b0 + b1 + b3 - p1 >= 0
    /\
    a1 + b0 + b2 + b3 - p1 >= 0
    /\
    a3 + b1 + b2 + b3 - p1 >= 0
    /\
    - a0 - a2 - b1 - b3 + p1 >= -3
    /\
    a1 + a2 + b0 + b1 + b2 - b3 >= 0
    /\
    - a0 + a1 - a3 - b0 + b1 - p1 >= -3
    /\
    - a0 - a1 - a2 - b0 - b2 - p1 >= -5
    /\
    a0 - a1 - a2 + b0 - b2 - p1 >= -3
    /\
    - a0 + a1 + b0 - b1 - b2 - p1 >= -3
    /\
    - a0 + a1 - a2 - b0 + b2 - p1 >= -3
    /\
    - a0 - a1 - a2 + b0 + b2 - p1 >= -3
    /\
    - a1 - a3 + b1 - b2 - b3 - p1 >= -4
    /\
    - a0 + a3 + b1 - b2 - b3 - p1 >= -3
    /\
    - a1 - b0 + b1 + b2 - b3 - p1 >= -3
    /\
    a1 - a2 - a3 - b0 + b3 - p1 >= -3
    /\
    - a0 - a1 + a2 + b0 + b3 - p1 >= -2
    /\
    a0 + a2 + a3 + b1 + b3 - p1 >= 0
    /\
    - a1 - a3 - b1 - b2 + b3 - p1 >= -4
    /\
    - a2 + a3 - b1 - b2 + b3 - p1 >= -3
    /\
    - a1 - b0 - b1 + b2 + b3 - p1 >= -3;