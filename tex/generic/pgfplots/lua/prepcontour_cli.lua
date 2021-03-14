#!/usr/bin/luatex

--[[

prepcontour_cli [Lua variant] - prepare contour lines (for pgfplots)

Version:  1.4 (2021-02-22)

Copyright (C) 2020-2021  Francesco Poli <invernomuto@paranoici.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]

-- directory separator ('\' for Windows, '/' for all other OSes)
dsep = package.config:sub(1, 1)
-- directory where the script lives
mydir = arg[0]:match("(.*" .. dsep .. ")")
-- add mydir to the search path for Lua loaders
package.path = package.path .. ";" .. mydir .. "?.lua"
-- load the module
require "prepcontour"

-- main program
usage = "Usage: " .. arg[0] .. [[
 CL NB NL {x|y} [VAL]... < IN > OUT

where:
CL  number of text lines to be copied from the input beginning to the output
NB  number of text blocks to be read from the input
NL  number of text lines included in each input block
x|y ordering ('x' if x varies, 'y' if y varies)
VAL level for contour lines or
    min:n:max for n levels between min and max or
    corners=true  to enable enhanced corner algorithm or
    corners=false to disable it (this is the default initial state)
IN  input file
OUT output file
]]
    
-- simplistic command-line argument parsing
-- TODO: use a better approach (argparse? some other library?)
if arg[4] == nil then
    io.stderr:write(arg[0] .. ": too few arguments\n" .. usage)
    os.exit(1)
end
copylines = tonumber(arg[1])
nblocks   = tonumber(arg[2])
nlines    = tonumber(arg[3])
if copylines == nil or nblocks == nil or nlines == nil then
    io.stderr:write(arg[0] .. ": failed to parse arguments\n" .. usage)
    os.exit(2)
end
yvaries = arg[4]:sub(1, 1)
if yvaries ~= 'x' and yvaries ~= 'y' then
    io.stderr:write(arg[0] .. ": failed to parse argument '"
                 .. arg[4] .. "'!\n" .. usage)
    os.exit(3)
end
yvaries = (yvaries == 'y')

mesh = PrepcMesh.new(yvaries, nblocks, nlines, copylines)
corners = false
for n = 5, #arg do
    if arg[n] == 'corners=true' then
        corners = true
    elseif arg[n] == 'corners=false' then
        corners = false
    else
        level = tonumber(arg[n])
        if level then
            mesh:contour(level, corners)
        else
            lmin, nlevels, lmax = arg[n]:match('([^%:]+)%:([^%:]+)%:([^%:]+)')
            nlevels = math.tointeger(tonumber(nlevels))
            lmin = tonumber(lmin)
            lmax = tonumber(lmax)
            if nlevels and lmin and lmax then
                mesh:autocontour(nlevels, lmin, lmax, corners)
            end
        end
    end
end

mesh:printcontours()
