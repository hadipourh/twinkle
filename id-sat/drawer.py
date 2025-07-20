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

import sys

def trim(docstring):
    if not docstring:
        return ''
    # Convert tabs to spaces (following the normal Python rules)
    # and split into a list of lines:
    lines = docstring.expandtabs().splitlines()
    # Determine minimum indentation (first line doesn't count):
    indent = sys.maxsize
    for line in lines[1:]:
        stripped = line.lstrip()
        if stripped:
            indent = min(indent, len(line) - len(stripped))
    # Remove indentation (first line is special):
    trimmed = [lines[0].strip()]
    if indent < sys.maxsize:
        for line in lines[1:]:
            trimmed.append(line[indent:].rstrip())
    # Strip off trailing and leading blank lines:
    while trimmed and not trimmed[-1]:
        trimmed.pop()
    while trimmed and not trimmed[0]:
        trimmed.pop(0)
    # Return a single string:
    return '\n'.join(trimmed)

class DrawDL():
    """
    Draw the shape of a given differential-linear distinguisher
    """

    def __init__(self, dlobject, output_file_name="output.tex"):
        self.result = dlobject.result
        self.RD = dlobject.RD
        self.output_file_name = output_file_name
        self.upper_trail = dlobject.upper_trail
        self.lower_trail = dlobject.lower_trail
        self.attack_summary = dlobject.attack_summary
        self.color_map = {-1: "tuggreen", 1: "tugred", 0: "white"}

    def generate_distinguisher_shape(self):
        """
        Draw the figure of the Rectangle distinguisher
        """

        contents = ""
        # head lines
        contents += trim(r"""
                    \documentclass[varwidth=100cm]{standalone}
                    \usepackage{twinkle}
                    \usepackage{comment}
                    \begin{document}
                    \begin{tikzpicture}
                    
                    \coordinate (here) at (0,0);""") + "\n\n"
        # draw EU
        for r in range(self.RD):
            fillcolor_x = []
            fillcolor_x_next = []
            for y in range(4):
                for x in range(4):
                    for z in range(80):
                        row = x + 4*y
                        column = z
                        selected_color = self.color_map[self.upper_trail["x"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_x.append(r"""\TFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
                        selected_color = self.color_map[self.lower_trail["x"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_x.append(r"""\BFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
                        selected_color = self.color_map[self.upper_trail["x"][r+1][x][y][z]]
                        if selected_color != "white":
                            fillcolor_x_next.append(r"""\TFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
                        selected_color = self.color_map[self.lower_trail["x"][r+1][x][y][z]]
                        if selected_color != "white":
                            fillcolor_x_next.append(r"""\BFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
            fillcolor_x = ",".join(fillcolor_x)
            fillcolor_x_next = ",".join(fillcolor_x_next)
            fillcolor_y = []
            fillcolor_z = []
            fillcolor_w = []
            for x in range(4):
                for y in range(4):
                    for z in range(80):
                        row = x + 4*y
                        column = z
                        selected_color = self.color_map[self.upper_trail["y"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_y.append(r"""\TFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
                        selected_color = self.color_map[self.upper_trail["z"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_z.append(r"""\TFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")                            
                        selected_color = self.color_map[self.upper_trail["w"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_w.append(r"""\TFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")                            
                        selected_color = self.color_map[self.lower_trail["y"][r][x][y][z]] 
                        if selected_color != "white":
                            fillcolor_y.append(r"""\BFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")                            
                        selected_color = self.color_map[self.lower_trail["z"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_z.append(r"""\BFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")
                        selected_color = self.color_map[self.lower_trail["w"][r][x][y][z]]
                        if selected_color != "white":
                            fillcolor_w.append(r"""\BFillCell""" + f"[{selected_color}]" + f"{{{row}}}{{{column}}}\n")                            
            fillcolor_y = ",".join(fillcolor_y)
            fillcolor_z = ",".join(fillcolor_z)
            fillcolor_w = ",".join(fillcolor_w)
            if r != self.RD - 1:
                contents += trim(
                    r"""\drawRoundC{""" + "\n" + 
                        fillcolor_x +
                        r"""}{""" +
                        fillcolor_y +
                        r"""}{""" +
                        fillcolor_z +
                        r"""}{""" +
                        fillcolor_w +
                        r"""}{""" + 
                        "" +
                        r"""}""" +
                        f"{{$S$}}" +
                        f"{{$\\texttt{{LaneRotation}}_0$}}" +
                        f"{{$\\texttt{{MixSlice}}$}}" + 
                        f"{{$\\texttt{{LaneRotation}}_1$}}") + ";\n"           
            else:
                contents += trim(
                    r"""\drawRoundC{""" + "\n" + 
                        fillcolor_x +
                        r"""}{""" +
                        fillcolor_y +
                        r"""}{""" +
                        fillcolor_z +
                        r"""}{""" +
                        fillcolor_w +
                        r"""}{""" + 
                        fillcolor_x_next +
                        r"""}""" +
                        f"{{$S$}}" +
                        f"{{$\\texttt{{LaneRotation}}_0$}}" +
                        f"{{$\\texttt{{MixSlice}}$}}" + 
                        f"{{$\\texttt{{LaneRotation}}_1$}}") + ";\n"
        contents += "\n\n" + r"""\begin{comment}""" + "\n"
        contents += self.attack_summary
        contents += r"""\end{comment}""" + "\n"
        contents += r"""\end{tikzpicture}""" + "\n"
        contents += trim(r"""\end{document}""")
        with open(self.output_file_name, "w") as output_file:
            output_file.write(contents)
