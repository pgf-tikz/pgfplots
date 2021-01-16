#!/usr/bin/luatex

--[[

prepcontour [Lua variant] - prepare contour lines (for pgfplots)

Version:  0.8 (2021-01-10)

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

-- class creation function
function FpolyCreateClass()
    local newclass = {}   -- this table is the created class (which will act
                          -- as metatable for the instantiated objects)

    newclass.__index = newclass   -- set the __index metamethod (so that
                                  -- members missing from objects are searched
                                  -- for in the class)

    newclass.new = function (...)   -- member function that will be used to
                                    -- instantiate a new object of this class
        local object = setmetatable({}, newclass)   -- a table with this class
                                                    -- set as metatable

        if object.init then
            object:init(...)   -- run the init method, if present
        end

        return object
    end

    return newclass
end

-- class for the coordinates (and meta value) of a point in 3D space
Coord = FpolyCreateClass()

function Coord:init()
    self.x = { nil, nil, nil }  -- point x,y,z coordinates
    self.meta = nil             -- point meta value
end

-- class for a 2D mesh of points in 3D space
PrepcMesh = FpolyCreateClass()

function PrepcMesh:init(yvaries, nblocks, nlines, copylines,
                        input, output)
    if yvaries then
        self.ni = nblocks - 1  -- number of cells in the i direction
        self.nj = nlines  - 1  -- number of cells in the j direction
    else
        self.ni = nlines  - 1  -- number of cells in the i direction
        self.nj = nblocks - 1  -- number of cells in the j direction
    end
    self.st = self.nj + 1  -- stride (number of nodes in the j direction)
    self.si = self.nj + 1  -- stride for done_i
    self.sj = self.nj      -- stride for done_j
    local cl = tonumber(copylines) or 0
    self.is =  input or io.stdin
    self.os = output or io.stdout

    self.debug = false

    local st = self.st    -- shorter name

    self.coords = {}  -- mesh of nodes
                      -- use single-index table for efficiency
                      -- (i,j) will be mapped to [i*st+j]
    --[[
        The mesh of nodes represented by this table is:

            nj    o  o  o  o  o  o  o  o  o  o  o  o

              ^   o  o  o  o  o  o  o  o  o  o  o  o
              |
             2|   o  o  o  o  o  o  o  o  o  o  o  o
              |
             1|   o  o  o  o  o  o  o  o  o  o  o  o
              |
           j=0+   o  o  o  o  o  o  o  o  o  o  o  o

                  +----------------------------->
                i=0  1  2                          ni
    --]]

    -- copy the first "cl" text lines from self.is to self.os
    for l = 1, cl do
        self.os:write(self.is:read('L'))
    end

    -- read all the nodes
    for bl = 0, nblocks - 1 do
        if bl > 0 then
            self.is:read('L')  -- this text line should be empty
        end
        for ln = 0, nlines - 1 do
            if yvaries then
                i, j = bl, ln
            else
                i, j = ln, bl
            end
            n = Coord.new()
            n.x[1], n.x[2], n.x[3], n.meta = self.is:read('n', 'n', 'n', 'n')
            self.coords[i*st+j] = n
        end
    end
end


--[[ begin core of the program logic ]]--

-- build N contour lines between meta_min and meta_max
function PrepcMesh:autocontour(N, meta_min, meta_max, tolerance)
    -- subdivide the meta_min÷meta_max interval into N equal sub-intervals
    -- and pick the midpoints of those sub-intervals
    meta_min = tonumber(meta_min)
    meta_max = tonumber(meta_max)
    local step     = (meta_max - meta_min)/N
    local meta_mid = (meta_max + meta_min)/2
    local n_mid    = (N + 1)/2
    for n = 1, N do
        local isoval = meta_mid + (n - n_mid)*step
        self:contour(isoval, tolerance)
    end
end

-- build contour lines for meta==isoval
function PrepcMesh:contour(isoval, tolerance)
    -- set relative tolerance
    local tol = tolerance or 1e-5

    -- short names
    local st = self.st
    local si = self.si
    local sj = self.sj

    if self.done_i == nil then
        self.done_i = {}  -- table of markers for i-sides
                          -- again single-index table
                          -- (i,j) will be mapped to [i*si+j]
        --[[
            The corresponding i-sides are:

                nj    o--o--o--o--o--o--o--o--o--o--o--

                  ^   o--o--o--o--o--o--o--o--o--o--o--
                  |
                 2|   o--o--o--o--o--o--o--o--o--o--o--
                  |
                 1|   o--o--o--o--o--o--o--o--o--o--o--
                  |
               j=0+   o--o--o--o--o--o--o--o--o--o--o--

                      +-------------------------->
                    i=0  1  2                      ni-1
        --]]
    end

    if self.done_j == nil then
        self.done_j = {}  -- table of markers for j-sides
                          -- again single-index table
                          -- (i,j) will be mapped to [i*sj+j]
        --[[
            The corresponding j-sides are:

                      |  |  |  |  |  |  |  |  |  |  |  |
              nj-1    o  o  o  o  o  o  o  o  o  o  o  o
                      |  |  |  |  |  |  |  |  |  |  |  |
                  ^   o  o  o  o  o  o  o  o  o  o  o  o
                  |   |  |  |  |  |  |  |  |  |  |  |  |
                 1|   o  o  o  o  o  o  o  o  o  o  o  o
                  |   |  |  |  |  |  |  |  |  |  |  |  |
               j=0+   o  o  o  o  o  o  o  o  o  o  o  o

                      +----------------------------->
                    i=0  1  2                          ni
        --]]
    end

    if self.newcoords == nil then
        self.newcoords = {}  -- nodes for contour lines will be placed here
    end

    -- scan all the i-sides, searching for
    -- intersections with the level surface
    for i = 0, self.ni - 1 do
        for j = 0, self.nj do
            self.done_i[i*si+j] = ((self.coords[    i*st+j].meta > isoval) ==
                                   (self.coords[(i+1)*st+j].meta > isoval))
            --[[
                This is equivalent to testing the two nodes of the i-side:

                    j o-----o
                      i    i+1

                If meta > isoval in both nodes, or in none of them, then
                set done_i to true (never look again at this i-side).
                Otherwise, set done_i to false (we have not finished with
                this i-side, since it contains one point of a contour line).
           --]]
        end
    end

    -- scan all the j-sides, searching for
    -- intersections with the level surface
    for i = 0, self.ni do
        for j = 0, self.nj - 1 do
            self.done_j[i*sj+j] = ((self.coords[i*st+j  ].meta > isoval) ==
                                   (self.coords[i*st+j+1].meta > isoval))
            --[[
                This is equivalent to testing the two nodes of the j-side:

                  j+1 o
                      |
                      |
                    j o
                      i

                Similarly, set done_j accordingly...
           --]]
        end
    end

    if self.debug then
        self:show_sides(isoval)
    end

    --[[
        We now have all the sides containing points of the meta==isoval
        contour lines. We need to connect the points into distinct lines.

        First of all, scan all the boundary sides, searching for sides
        with done==false. For each boundary side with done==false, set
        its done to true and build one contour line, starting from
        the side itself and the real cell adjacent to it.

        How can we specify a cell and one of its sides?
        We can specify cell (i,j) and a side (South, West, North, East)

                       N
                 j o-------o
                   |       |
                 W | (i,j) | E
                   |       |
               j-1 o-------o
                  i-1  S   i
    --]]

    j = 0  -- i-sides with j=0
    for i = 0, self.ni - 1 do
        if not self.done_i[i*si+j] then
            self.done_i[i*si+j] = true
            self:build_line(isoval, tol, i+1, j+1, 'S')
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    i = 0  -- j-sides with i=0
    for j = 0, self.nj - 1 do
        if not self.done_j[i*sj+j] then
            self.done_j[i*sj+j] = true
            self:build_line(isoval, tol, i+1, j+1, 'W')
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    j = self.nj  -- i-sides with j=nj
    for i = 0, self.ni - 1 do
        if not self.done_i[i*si+j] then
            self.done_i[i*si+j] = true
            self:build_line(isoval, tol, i+1, j  , 'N')
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    i = self.ni  -- j-sides with i=ni
    for j = 0, self.nj - 1 do
        if not self.done_j[i*sj+j] then
            self.done_j[i*sj+j] = true
            self:build_line(isoval, tol, i  , j+1, 'E')
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    --[[
        Finally, scan all the internal sides, again searching for sides
        with done==false. For each internal side with done==false, do _not_
        alter its done value and build one contour line, starting from
        the side itself and one of the two real cells adjacent to it.
    --]]

    -- i-sides with j=1,...,nj-1  (i-sides with j=0 are already done)
    -- j-sides with i=1,...,ni-1  (j-sides with i=0 are already done)
    for j = 0, self.nj - 1 do
        for i = 0, self.ni - 1 do
            if not self.done_i[i*si+j] then
                self:build_line(isoval, tol, i+1, j+1, 'S')
                if self.debug then
                    self:show_sides(isoval)
                end
            end
            if not self.done_j[i*sj+j] then
                self:build_line(isoval, tol, i  , j+1, 'E')
                if self.debug then
                    self:show_sides(isoval)
                end
            end
        end
    end
end

-- build a single contour line
function PrepcMesh:build_line(isoval, tol, ic, jc, side)
    -- short names
    local st = self.st
    local si = self.si
    local sj = self.sj

    while true do
        --[[
            Start from cell (ic,jc) and its South, West, North, or East side

                             b              a    N    b              b
               o-------o      o-------o      o-*-----o      o-------o
               |       |      |       |      |       |      |       *
               |   c   |    W |   c   |      |   c   |      |   c   | E
               |       |      *       |      |       |      |       |
               o----*--o      o-------o      o-------o      o-------o
              a    S    b    a                                       a
        --]]

        -- compute the intersection point between the side
        -- and the meta==isoval level surface
        if side == 'E' then ia = ic     else ia = ic - 1 end
        if side == 'N' then ja = jc     else ja = jc - 1 end
        if side == 'W' then ib = ic - 1 else ib = ic     end
        if side == 'S' then jb = jc - 1 else jb = jc     end
        if ia < 0 or ib > self.ni or ja < 0 or jb > self.nj then
            self.newcoords[#self.newcoords + 1] = Coord.new()
            break  -- out of range: abort
        end
        na = self.coords[ia*st+ja]                   -- node a
        nb = self.coords[ib*st+jb]                   -- node b

        wa = (isoval - nb.meta)/(na.meta - nb.meta)  -- weights
        wb = 1 - wa

        pt = Coord.new()
        for k = 1, 3 do
            pt.x[k] = wa*na.x[k] + wb*nb.x[k]        -- intersection point
        end
        pt.meta = isoval
        -- add the intersection point to the contour line
        self.newcoords[#self.newcoords + 1] = pt

        -- check the cell: if it is a phantom cell, then stop
        if ic < 1 or ic > self.ni or jc < 1 or jc > self.nj then
            self.newcoords[#self.newcoords + 1] = Coord.new()
            break  -- the contour line is finished
        end

        -- look at the other three sides of the cell:
        -- how many of them have done==false ?
        count = 0
        if side ~= 'S' and not self.done_i[(ic-1)*si+(jc-1)] then
            count = count + 1
            next_side = 'N'  -- next side could be the North side of the
                             -- adjacent south cell
        end
        if side ~= 'W' and not self.done_j[(ic-1)*sj+(jc-1)] then
            count = count + 1
            next_side = 'E'  -- next side could be the East side of the
                             -- adjacent west cell
        end
        if side ~= 'N' and not self.done_i[(ic-1)*si+ jc   ] then
            count = count + 1
            next_side = 'S'  -- next side could be the South side of the
                             -- adjacent north cell
        end
        if side ~= 'E' and not self.done_j[ ic   *sj+(jc-1)] then
            count = count + 1
            next_side = 'W'  -- next side could be the West side of the
                             -- adjacent east cell
        end

        --[[
            if zero other sides have done==false, then stop

                 o     o
                 |
                 *
                 o     o
        --]]
        if count == 0 then
            self.newcoords[#self.newcoords + 1] = Coord.new()
            break  -- the contour line is finished
        end

        --[[
            if exactly one other side has done==false, then
            next_side already specifies the next side to start from

                 o     o
                 |   ..*
                 *'''  |
                 o     o

            nothing to be done for the time being...
        --]]

        --[[
            if two or three other sides have done==false, then
            choose the next side

                     ?
                 o---*-o
                 |     * ?
                 *     |
                 o-*---o
                   ?
        --]]
        if count >= 2 then
            -- how can we choose the next side?
            -- on the basis of the arithmetic mean of the four meta values
            meta_NW   =  self.coords[(ic-1)*st+ jc   ].meta
            meta_NE   =  self.coords[ ic   *st+ jc   ].meta
            meta_SW   =  self.coords[(ic-1)*st+(jc-1)].meta
            meta_SE   =  self.coords[ ic   *st+(jc-1)].meta
            meta_mean = (meta_NW + meta_NE + meta_SW + meta_SE)/4

            -- compute absolute tolerance (maximum distance from the
            -- arithmetic mean, multiplied by relative tolerance)
            max_dist = math.max(math.abs(meta_NW - meta_mean),
                                math.abs(meta_NE - meta_mean),
                                math.abs(meta_SW - meta_mean),
                                math.abs(meta_SE - meta_mean))
            abs_tol = math.abs(tol*max_dist)

            if math.abs(meta_mean - isoval) <= abs_tol then
                --[[
                        b
                         L---*-H
                         |     | n
                         |  ..'* e
                         *''   | x
                         H-*---L t
                        a

                    choose the opposite side
                --]]
                next_side = side
            else -- meta_mean < isoval - abs_tol or
                 -- meta_mean > isoval + abs_tol
                --[[
                    if meta_mean < isoval - abs_tol then

                        b
                         L---*-H
                         |     |
                         |  L  *
                         *.    |
                         H-*---L
                        a  next

                    choose the side adjacent to the node with meta > isoval

                    if meta_mean > isoval + abs_tol then

                        b  next
                         L---*-H
                         | .'  |
                         |' H  *
                         *     |
                         H-*---L
                        a

                    choose the side adjacent to the node with meta <= isoval
                --]]
                back = ((meta_mean > isoval) == (nb.meta > isoval))
                if side == 'S' or side == 'N' then
                    if back then next_side = 'E' else next_side = 'W' end
                else
                    if back then next_side = 'N' else next_side = 'S' end
                end
            end
        end

        -- point to done value for the next side and
        -- determine indexes for the next cell
        -- (the other cell adjacent to the next side)
        if next_side == 'W' then ic = ic + 1 end
        if next_side == 'S' then jc = jc + 1 end
        if next_side == 'N' or next_side == 'S' then
            next_done = self.done_i
            next_done_idx = (ic-1)*si+(jc-1)
        else
            next_done = self.done_j
            next_done_idx = (ic-1)*sj+(jc-1)
        end
        if next_side == 'E' then ic = ic - 1 end
        if next_side == 'N' then jc = jc - 1 end

        -- if next side is already done, then stop
        if next_done[next_done_idx] then
            self.newcoords[#self.newcoords + 1] = Coord.new()
            break  -- the contour line is finished
        end

        -- set next side done to true and
        -- iterate starting from this new side and the next cell
        next_done[next_done_idx] = true
        side = next_side
    end
end

--[[ end core of the program logic ]]--


-- print out all the contour lines
function PrepcMesh:printcontours()
    for n = 1, #self.newcoords do
        if self.newcoords[n].x[1] then
            self.os:write(string.format("%14.6g%14.6g%14.6g%14.6g\n",
                          self.newcoords[n].x[1],
                          self.newcoords[n].x[2],
                          self.newcoords[n].x[3],
                          self.newcoords[n].meta))
        else
            self.os:write('\n')
        end
    end
end

-- print a debug representation of mesh and not-done sides
function PrepcMesh:show_sides(isoval)
    -- short names
    local st = self.st
    local si = self.si
    local sj = self.sj

    self.os:write(string.format("# contour level = %.6g \n#\n", isoval))
    for j = self.nj, 0, -1 do
        if j <= self.nj - 1 then
            self.os:write("#    ")
            for i = 0, self.ni do
                if self.done_j[i*sj+j] then
                    self.os:write("  ")
                else
                    self.os:write(" *")
                end
            end
            self.os:write("\n")
        end
        self.os:write("#     ")
        for i = 0, self.ni do
            if self.coords[i*st+j].meta > isoval then
                self.os:write("•")
            else
                self.os:write("o")
            end
            if i <= self.ni - 1 then
                if self.done_i[i*si+j] then
                    self.os:write(" ")
                else
                    self.os:write("*")
                end
            end
        end
        self.os:write("\n")
    end
    self.os:write("#\n")
end

