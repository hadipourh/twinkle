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

int: RD;

constraint assert(RD >= 0, "Invalid value for RD: " ++ 
                           "RD must be greater than or equal to 0");

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
% constraints for EU

array[0..RD, 0..3, 0..3, 0..79] of var -1..1: xu; % state before s-box
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: yu; % state after s-box
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: zu; % state after the lane-rotation0
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: wu; % state after the mixslice
% the state after the lane-rotation1 is xu[round + 1, *, *, *]

% s-box
constraint forall(round in 0..(RD - 1), y in 0..3, z in 0..79)
(
    sbox(xu[round, 0, y, z], xu[round, 1, y, z], xu[round, 2, y, z], xu[round, 3, y, z],
         yu[round, 0, y, z], yu[round, 1, y, z], yu[round, 2, y, z], yu[round, 3, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RD - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zu[round, x, y, z] = yu[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RD - 1), z in 0..79) (
        let {
            array[0..15] of var -1..1: fzu = array1d(0..15, [zu[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var -1..1: fwu = array1d(0..15, [wu[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor9(
                fzu[mixslice_linear_forward[i, 0]],
                fzu[mixslice_linear_forward[i, 1]],
                fzu[mixslice_linear_forward[i, 2]],
                fzu[mixslice_linear_forward[i, 3]],
                fzu[mixslice_linear_forward[i, 4]],
                fzu[mixslice_linear_forward[i, 5]],
                fzu[mixslice_linear_forward[i, 6]],
                fzu[mixslice_linear_forward[i, 7]],
                fzu[mixslice_linear_forward[i, 8]], 
                fwu[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RD - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xu[round + 1, x, y, z] = wu[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);

% exclude the trivial solution
constraint sum(x in 0..3, y in 0..3, z in 0..79)(xu[0, x, y, z]) != 0;

% limit the input space
constraint forall(x in 0..3, y in 0..3, z in 0..79)(xu[0, x, y, z] in {0, -1});

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                    _                _         _           __                _____  _     
%  / ___| ___   _ __   ___ | |_  _ __  __ _ (_) _ __  | |_  ___   / _|  ___   _ __  | ____|| |    
% | |    / _ \ | '_ \ / __|| __|| '__|/ _` || || '_ \ | __|/ __| | |_  / _ \ | '__| |  _|  | |    
% | |___| (_) || | | |\__ \| |_ | |  | (_| || || | | || |_ \__ \ |  _|| (_) || |    | |___ | |___ 
%  \____|\___/ |_| |_||___/ \__||_|   \__,_||_||_| |_| \__||___/ |_|   \___/ |_|    |_____||_____|
% constraints for EL

array[0..RD, 0..3, 0..3, 0..79] of var -1..1: xl; % state before s-box
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: yl; % state after s-box
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: zl; % state after the lane-rotation0
array[0..(RD - 1), 0..3, 0..3, 0..79] of var -1..1: wl; % state after the mixslice
% the state after the lane-rotation1 is xl[round + 1, *, *, *]

% s-box
constraint forall(round in 0..(RD - 1), y in 0..3, z in 0..79)
(
    sbox_inv(yl[round, 0, y, z], yl[round, 1, y, z], yl[round, 2, y, z], yl[round, 3, y, z],
             xl[round, 0, y, z], xl[round, 1, y, z], xl[round, 2, y, z], xl[round, 3, y, z])
);

% lane-rotation0
constraint forall(round in 0..(RD - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        zl[round, x, y, z] = yl[round, x, y, (z + lane_rotation[0, x + 4*y] + 80) mod 80]
    )
);

% mixslice
constraint 
    forall(round in 0..(RD - 1), z in 0..79) (
        let {
            array[0..15] of var -1..1: flz = array1d(0..15, [zl[round, x, y, z] | y in 0..3, x in 0..3]),
            array[0..15] of var -1..1: flw = array1d(0..15, [wl[round, x, y, z] | y in 0..3, x in 0..3])
        } in
        forall(i in 0..15) (
            xor3(
                flw[mixslice_linear_backward[i, 0]],
                flw[mixslice_linear_backward[i, 1]],
                flw[mixslice_linear_backward[i, 2]],
                flz[i]
            )
        )
    );

% lane-rotation1
constraint forall(round in 0..(RD - 1), x in 0..3, y in 0..3)
(
    forall(z in 0..79)(
        xl[round + 1, x, y, z] = wl[round, x, y, (z + lane_rotation[1, x + 4*y] + 80) mod 80]
    )
);
% exclude the trivial solution
constraint sum(x in 0..3, y in 0..3, z in 0..79)(xl[RD, x, y, z]) != 0;

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%   ____                                   _                _    _              ____               _                    _  _        _    _               
%  / ___| _   _   __ _  _ __  __ _  _ __  | |_  ___   ___  | |_ | |__    ___   / ___| ___   _ __  | |_  _ __  __ _   __| |(_)  ___ | |_ (_)  ___   _ __  
% | |  _ | | | | / _` || '__|/ _` || '_ \ | __|/ _ \ / _ \ | __|| '_ \  / _ \ | |    / _ \ | '_ \ | __|| '__|/ _` | / _` || | / __|| __|| | / _ \ | '_ \ 
% | |_| || |_| || (_| || |  | (_| || | | || |_|  __/|  __/ | |_ | | | ||  __/ | |___| (_) || | | || |_ | |  | (_| || (_| || || (__ | |_ | || (_) || | | |
%  \____| \__,_| \__,_||_|   \__,_||_| |_| \__|\___| \___|  \__||_| |_| \___|  \____|\___/ |_| |_| \__||_|   \__,_| \__,_||_| \___| \__||_| \___/ |_| |_|
%                                                                                                                                        |___/                              
% constraints for the meeting point
array[0..RD, 0..3, 0..3, 0..79] of var 0..1: contradict_x;
array[0..(RD - 1), 0..3, 0..3, 0..79] of var 0..1: contradict_y;
constraint forall(round in 0..RD, x in 0..3, y in 0..3, z in 0..79)(
    contradict_x[round, x, y, z] = bool2int(xu[round, x, y, z] + xl[round, x, y, z] == 1)
);
constraint forall(round in 0..(RD - 1),  x in 0..3, y in 0..3, z in 0..79)(
    contradict_y[round, x, y, z] = bool2int(yu[round, x, y, z] + yl[round, x, y, z] == 1)
);
constraint sum(round in 0..RD, x in 0..3, y in 0..3, z in 0..79)(contradict_x[round, x, y, z]) +
           sum(round in 0..(RD - 1), x in 0..3, y in 0..3, z in 0..79)(contradict_y[round, x, y, z]) >= 1;

var 0..1280: num_non_fixed_input_bits; 
constraint num_non_fixed_input_bits = sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xu[0, x, y, z] == -1));
var 0..1280: num_non_fixed_output_bits; 
constraint num_non_fixed_output_bits = sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xl[RD, x, y, z] == -1));

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
    int_search([yl[RD - 1, x, y, z] | z in 0..79, y in 0..3, x in 0..3], indomain_median, complete),
    int_search([xl[RD, x, y, z] | z in 0..79, y in 0..3, x in 0..3], indomain_median, complete)]);

% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%  ____          _             
% / ___|   ___  | |__   __ ___ 
% \___ \  / _ \ | |\ \ / // _ \
%  ___) || (_) || | \ V /|  __/
% |____/  \___/ |_|  \_/  \___|

% some artificial constraints to control the input and output masks
% constraint sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xu[0, x, y, z] != 0)) == 1;
% constraint sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xl[RD, x, y, z] != 0)) == 1;
% solve satisfy;

% artificial constraints to control the output mask
% constraint sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xl[RD, x, y, z] == 1)) == 1;
% solve maximize sum(x in 0..3, y in 0..3, z in 0..79)(bool2int(xu[0, x, y, z] == -1));
solve minimize sum(x in 0..3, y in 0..3, z in 0..79)(xu[0, x, y, z] == 0);

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
    (if r < RD then
        "yu_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(yu[r, x, y, z]) = -1 then "?" else show(fix(yu[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
    endif)
    | r in 0..RD];

output [
    if r = 0 then "\n\n" endif ++
    "xl_" ++ show(r) ++ ": \n" ++
    join("\n", [join("", [if fix(xl[r, x, y, z]) = -1 then "?" else show(fix(xl[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n" ++
    (if r < RD then
        "yl_" ++ show(r) ++ ": \n" ++
        join("\n", [join("", [if fix(yl[r, x, y, z]) = -1 then "?" else show(fix(yl[r, x, y, z])) endif | z in 0..79]) | y in 0..3, x in 0..3]) ++ "\n"
    endif)
    | r in 0..RD];

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

predicate xor3(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: b0) = 
    if exists([a0 == -1, a1 == -1, a2 == -1]) then b0 = -1
    else b0 = (sum([a0, a1, a2]) mod 2) endif;

predicate xor9(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, var -1..1: a4, 
               var -1..1: a5, var -1..1: a6, var -1..1: a7, var -1..1: a8, var -1..1: b0) =
    if exists([a0 == -1, a1 == -1, a2 == -1, a3 == -1, a4 == -1, a5 == -1, a6 == -1, a7 == -1, a8 == -1]) then b0 = -1
    else b0 = (sum([a0, a1, a2, a3, a4, a5, a6, a7, a8]) mod 2) endif;

predicate sbox(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, 
               var -1..1: b0, var -1..1: b1, var -1..1: b2, var -1..1: b3) = 
    if (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = 0 /\ b1 = 0 /\ b2 = 0 /\ b3 = 0)
    elseif (a0 == 0 /\ a1 == 0 /\ a2 == 1 /\ a3 == 0) then (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = 1)
    elseif (a0 == 1 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = -1 /\ b1 = 1 /\ b2 = -1 /\ b3 = 1)
    elseif (a0 == 1 /\ a1 == 0 /\ a2 == 1 /\ a3 == 0) then (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = 0)
    else (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    endif;

predicate sbox_inv(var -1..1: a0, var -1..1: a1, var -1..1: a2, var -1..1: a3, 
                   var -1..1: b0, var -1..1: b1, var -1..1: b2, var -1..1: b3) =
    if (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 0) then (b0 = 0 /\ b1 = 0 /\ b2 = 0 /\ b3 = 0)
    elseif (a0 == 0 /\ a1 == 0 /\ a2 == 0 /\ a3 == 1) then (b0 = 1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    elseif (a0 == 0 /\ a1 == 1 /\ a2 == 0 /\ a3 == 0) then (b0 = -1 /\ b1 = -1 /\ b2 = 1 /\ b3 = -1)
    else (b0 = -1 /\ b1 = -1 /\ b2 = -1 /\ b3 = -1)
    endif;