# Breaking the Twinkle Authenticated Encryption Scheme

This repository includes the source code of the tools we utilized in our paper entitled [Breaking the Twinkle Authentication Scheme and Analyzing Its Underlying Permutation](https://ia.cr/2025/1339) accepted in [SAC 2025](https://sacworkshop.org/SAC25/).

## Abstract

[Twinkle](https://cic.iacr.org/p/1/2/20) is a low-latency authenticated encryption scheme designed by researchers affiliated with [Huawei](https://www.huawei.com/eu/) and [Hisilicon Technologies](https://www.hisilicon.com/en). 
In our analysis, we show that several versions of Twinkle authenticated encryption (Twinkle-AE), which use a 1024- or 512-bit key for authentication and provide a tag of 64 or 128 bits, can be broken with only $O(2^{t})$ decryption queries, with "t" being the tag length. Specifically, the authentication key can be efficiently recovered, enabling universal forgery of ciphertexts for any plaintext. This highlights vulnerabilities in chosen-ciphertext scenarios when confidentiality is higher than integrity. 
In addition, we applied the method proposed at [CRYPTO 2024](https://eprint.iacr.org/2024/255) to derive differential-linear distinguishers for up to 6 rounds of the underlying permutation in the Twinkle scheme. 
We note that Twinkle-AE-b and Twinkle-PA remain secure, and the versions we attacked would also be secure if the claimed confidentiality level matched the integrity level. 

## From ASK 2024 (India) to SAC 2025 (Canada)

We started this work at ASK 2024 in India. 
We would also like to thank the organizers of ASK 2024. 
This is a joint work with [Yu Sasaki](https://dblp.org/pid/46/2899.html), [Mostafizar Rahman](https://dblp.org/pid/234/4855.html), Prathamesh Ram, Debasmita Chakraborty, Anup Kumar Kundu, Dilip Sau, and Aman Sinha.


- [Breaking the Twinkle Authenticated Encryption Scheme](#breaking-the-twinkle-authenticated-encryption-scheme)
  - [Abstract](#abstract)
  - [From ASK 2024 (India) to SAC 2025 (Canada)](#from-ask-2024-india-to-sac-2025-canada)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Structure of Our Tool](#structure-of-our-tool)
  - [Usage](#usage)
  - [Impossible Differential Distinguishers](#impossible-differential-distinguishers)
  - [Zero-Correlation Linear and ZC-based Integral Distinguishers](#zero-correlation-linear-and-zc-based-integral-distinguishers)
  - [Division-Property-Based Integral Distinguishers](#division-property-based-integral-distinguishers)
  - [Differential-Linear Distinguishers](#differential-linear-distinguishers)
  - [Experimental Verification](#experimental-verification)
  - [License](#license)

## Requirements

Our tool requires the following software:

- [Python 3](https://www.python.org/downloads/) 
- [MiniZinc](https://www.minizinc.org/) to compile and solve our CP models.
- [latexmk](https://www.latex-project.org/) to build the `.tex` files and generate the shapes of our attacks (you can also use `lualatex` directly).
- [OR-Tools](https://developers.google.com/optimization) to solve our CP models.
- [Gurobi](https://www.gurobi.com/downloads/gurobi-software/) to solve our CP models, specifically for the division property tool.


## Installation

Many CP solvers are bundled with MiniZinc and can be used without any further installation. 
We use Or-Tools as the CP solver. 
Fortunately, `OR Tools CP-SAT` is bundled with MiniZinc after version 2.8.0. Thus, by installing the latest version of MiniZinc, one can use `OR Tools CP-SAT` without any further installation.
Additionally, we need the Python package named `minizinc` to work with MiniZinc in Python. 
To install the required software in Ubuntu, one can use the following commands:

```bash
#!/bin/bash

# Update and upgrade system packages
sudo apt update -y
sudo apt upgrade -y

# Install system dependencies
sudo apt install -y python3-full python3-pip python3-venv git wget curl

# Create a working directory
mkdir -p "$HOME/minizinc_install"
cd "$HOME/minizinc_install"

# Download and extract the latest MiniZinc release
LATEST_MINIZINC_VERSION=$(curl -s https://api.github.com/repos/MiniZinc/MiniZincIDE/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
wget "https://github.com/MiniZinc/MiniZincIDE/releases/download/$LATEST_MINIZINC_VERSION/MiniZincIDE-$LATEST_MINIZINC_VERSION-bundle-linux-x86_64.tgz"
tar -xvzf MiniZincIDE-$LATEST_MINIZINC_VERSION-bundle-linux-x86_64.tgz
mv MiniZincIDE-$LATEST_MINIZINC_VERSION-bundle-linux-x86_64 "$HOME/minizinc"
rm MiniZincIDE-$LATEST_MINIZINC_VERSION-bundle-linux-x86_64.tgz

# Clean up the created folders
rm -rf "$HOME/minizinc_install"

# Add MiniZinc to system PATH
sudo ln -sf "$HOME/minizinc/bin/minizinc" /usr/local/bin/minizinc

# Create a Python virtual environment
python3 -m venv "$HOME/zerovenv"
source "$HOME/zerovenv/bin/activate"

# Install Python packages
pip install --upgrade pip
pip install minizinc
```

To install and activate Gurobi on Linux, we refer to [GrabGurobi](https://github.com/hadipourh/grabgurobi). 

## Structure of Our Tool

Our tool's main components are the CP models saved in `.mzn` format, built using the methods explained in our paper. You can solve these `.mzn` files independently with MiniZinc.

To make using our tool even more convenient, we have included a Python interface for each application. Thus, you'll discover `.mzn` files for each application, along with some handy Python tools.

## Usage

Using our tool is straightforward. Simply specify the number of attacked rounds or the length of the distinguisher and choose the solver. Our tool will then identify the attack and visualize its shape.

For a quick guide on each application, run the following command:

```bash
python3 <application_name>.py --help
```

## Impossible Differential Distinguishers

- For positive model navigate into [id-sat](./id-sat) folder and run the following command:

```bash
python3 attack.py -RD <number_of_rounds> -p 8
```

where `-RD` is the number of attacked rounds and `-p` is the number of threads to be used.

- For negative model navigate into [id-sat](./id-sat) folder and run the following command:

```bash
python3 attack.py
```
You can adjust the number of rounds within the script. 

We mostly use the positive model to find impossible differential distinguishers.
After successfully running the positive model, it produces the LaTex file of the attack shape in the `output.tex` file. 
To generate the shape, run the following command:

```bash
latexmk -lualatex output.tex
```
This will create a PDF file named `output.pdf` in the same directory, which contains the shape of the impossible differential distinguisher.
For example, the 6-round impossible differential distinguisher looks like this:

![id-sat/results/twinkle_id_6r_v1.svg](id-sat/results/twinkle_id_6r_v1.svg)

## Zero-Correlation Linear and ZC-based Integral Distinguishers

- For positive model navigate into [zc-sat](./zc-sat) folder and run the following command:

```bash
python3 attack.py -RD <number_of_rounds> -p 8
```

where `-RD` is the number of attacked rounds and `-p` is the number of threads to be used.

- For negative model navigate into [zc-sat](./zc-sat) folder and run the following command:

```bash
python3 attack.py
```
You can adjust the number of rounds within the script.
We mostly use the positive model to find zero-correlation linear distinguishers.
After successfully running the positive model, it produces the LaTex file of the attack shape in the `output.tex` file.
To generate the shape, run the following command:

```bash
latexmk -lualatex output.tex
```
This will create a PDF file named `output.pdf` in the same directory, which contains the shape of the zero-correlation linear distinguisher.
For example, the 6-round zero-correlation linear distinguisher looks like this:
![zc-sat/results/twinkle_zc_6r_v0.svg](zc-sat/results/twinkle_zc_6r_v0.svg)

## Division-Property-Based Integral Distinguishers

To find division-property-based integral distinguishers, navigate into the [division/algorithm 3](./division/algorithm 3) folder and run the following command:

```bash
python3 main.py
```

You can adjust the number of rounds within the script. 

## Differential-Linear Distinguishers

To find differential-linear (DL) distinguishers navigate into the [difflin](./difflin) folder and run the following command:
```bash
python3 attack.py -RU <number_of_rounds_for_Ed> -RM <number_of_rounds_for_Em> -RL <number_of_rounds_for_El> -WU <weight_of_transition_over_Ed> -WM <weight_of_transition_over_Em> -WL <weight_of_transition_over_Ed> -p 8
```
where `-RU`, `-RM`, and `-RL` are the number rounds covered by `Ed`, `Em`, and `Ed` respectively, and `-WU`, `-WM`, and `-WL` are the weights of the transitions over `Ed`, `Em`, and `Ed` respectively.
After successfully running the positive model, it produces the LaTex file of the attack shape in the `output.tex` file.
To generate the shape, run the following command:
```bash
latexmk -lualatex output.tex
```
This will create a PDF file named `output.pdf` in the same directory, which contains the shape of the differential-linear distinguisher.
For example, the 6-round differential-linear distinguisher looks like this:
![difflin/results/twinkle_dl_6r_v3.svg](difflin/results/twinkle_dl_6r_v3.svg)

## Experimental Verification

We have provided several script to experimentally verify our practical distinguishers. 
You can find the scripts within [verification](./verification) folder.

## License
[![GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This project is licensed under the GNU General Public License v3.0 (GPLv3).  
See [LICENSE](./LICENSE) for details.


