#!/usr/bin/luatex

--[[

prepcontour [Lua variant] - prepare contour lines (for pgfplots)

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
function PrepcMesh:autocontour(N, meta_min, meta_max, corners, tolerance)
    -- subdivide the meta_min÷meta_max interval into N equal sub-intervals
    -- and pick the midpoints of those sub-intervals
    meta_min = tonumber(meta_min)
    meta_max = tonumber(meta_max)
    local step     = (meta_max - meta_min)/N
    local meta_mid = (meta_max + meta_min)/2
    local n_mid    = (N + 1)/2
    for n = 1, N do
        local isoval = meta_mid + (n - n_mid)*step
        self:contour(isoval, corners, tolerance)
    end
end

-- build contour lines for meta==isoval
function PrepcMesh:contour(isoval, corners, tolerance)
    -- set relative tolerance
    local tol = tolerance or 1e-3

    -- short names
    local st = self.st
    local si = self.si
    local sj = self.sj

    -- local variables
    local i, j

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
            self:build_line(isoval, tol, i+1, j+1, 'S', corners)
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    i = 0  -- j-sides with i=0
    for j = 0, self.nj - 1 do
        if not self.done_j[i*sj+j] then
            self.done_j[i*sj+j] = true
            self:build_line(isoval, tol, i+1, j+1, 'W', corners)
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    j = self.nj  -- i-sides with j=nj
    for i = 0, self.ni - 1 do
        if not self.done_i[i*si+j] then
            self.done_i[i*si+j] = true
            self:build_line(isoval, tol, i+1, j  , 'N', corners)
            if self.debug then
                self:show_sides(isoval)
            end
        end
    end

    i = self.ni  -- j-sides with i=ni
    for j = 0, self.nj - 1 do
        if not self.done_j[i*sj+j] then
            self.done_j[i*sj+j] = true
            self:build_line(isoval, tol, i  , j+1, 'E', corners)
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
                self:build_line(isoval, tol, i+1, j+1, 'S', corners)
                if self.debug then
                    self:show_sides(isoval)
                end
            end
            if not self.done_j[i*sj+j] then
                self:build_line(isoval, tol, i  , j+1, 'E', corners)
                if self.debug then
                    self:show_sides(isoval)
                end
            end
        end
    end
end

-- build a single contour line
function PrepcMesh:build_line(isoval, tol, ic, jc, side, corners)
    -- short names
    local st = self.st
    local si = self.si
    local sj = self.sj

    -- local variables
    local ia, ja, na, wa
    local ib, jb, nb, wb
    local ie, je, ne
    local id, jd, nd
    local pt, k, count, next_side
    local cc, xi_k, eta_k, ck, above, sign_ck
    local xi_v, eta_v, xi_0, xi_1, eta_0, eta_1
    local next_done, next_done_idx

    while true do
        --[[
            Start from cell (ic,jc) and its South, West, North, or East side

              e         d    b         d    a    N    b    d         b
               o-------o      o-------o      o-*-----o      o-------o
               |       |      |       |      |       |      |       *
               |   c   |    W |   c   |      |   c   |      |   c   | E
               |       |      *       |      |       |      |       |
               o----*--o      o-------o      o-------o      o-------o
              a    S    b    a         e    e         d    e         a
        --]]

        -- find nodes a and b
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

        -- compute the intersection point between the side
        -- and the meta==isoval level surface
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

        -- find nodes e and d
        if side == 'W' then ie = ic     else ie = ic - 1 end
        if side == 'S' then je = jc     else je = jc - 1 end
        if side == 'E' then id = ic - 1 else id = ic     end
        if side == 'N' then jd = jc - 1 else jd = jc     end
        ne = self.coords[ie*st+je]                   -- node e
        nd = self.coords[id*st+jd]                   -- node d

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


                 o---*-o
        --]]
        if count == 0 then
            self.newcoords[#self.newcoords + 1] = Coord.new()
            break  -- the contour line is finished
        end

        --[[
            if exactly one other side has done==false, then
            next_side already specifies the next side to start from

                 o-*---o
                   |
                    \
                 o---*-o

            nothing to be done for the time being...
        --]]

        --[[
            the surface inside the cell is thought as the bilinear
            interpolation of the four nodes and hence mapped onto
            a unit square in the xi,eta plane:

               eta ^
                   |               pt.x[k] = (1-xi)*(1-eta)*na.x[k] +
                  1+------+                     xi *(1-eta)*nb.x[k] +
                   |e    d|                  (1-xi)*   eta *ne.x[k] +
                   |      |                     xi *   eta *nd.x[k]
                   |a    b|
                  0+------+------>
                   0      1      xi

            the equation of the contour line is therefore:
            cc*xi*eta - eta_k*xi - xi_k*eta == ck
        --]]
        cc    = na.meta - nb.meta + nd.meta - ne.meta
        eta_k = na.meta - nb.meta
        xi_k  = na.meta - ne.meta
        ck    = isoval  - na.meta

        if math.abs(cc) <=
           math.max(math.abs(tol*eta_k), math.abs(tol*xi_k)) then
            --[[
                cc is negligible and the contour line is
                basically a straight line:
                eta_k*xi + xi_k*eta + ck == 0
            --]]
            cc = 0
        else
            --[[
                cc is non-zero (and non-negligible) and we can divide
                both sides of the equation by cc:
                xi*eta - (eta_k/cc)*xi - (xi_k/cc)*eta == ck/cc
            --]]
            xi_k  = xi_k /cc        -- let's rename the coefficients
            eta_k = eta_k/cc
            ck    = xi_k*eta_k + ck/cc
            --[[
                the contour line is an equilateral hyperbola (in the
                xi,eta plane) with asymptotes xi == xi_k and eta == eta_k
                and constant product ck:
                (xi - xi_k)*(eta - eta_k) == ck
            --]]
            if math.abs(ck) <= math.abs(tol/2) then
                --[[
                    ck is negligible and the hyperbola basically
                    degenerates into its asymptotes
                --]]
                ck = 0
            end
        end

        --[[
            if two or three other sides have done==false, then
            choose the next side

                   ?
                 o-*---o
                 |     * ?
               ? *     |
                 o---*-o

        --]]
        if count >= 2 then
            -- how can we choose the next side?
            --[[
                if there's more than one side to choose from, cc is
                necessarily non-zero (a straight line could not cross
                more than two sides of the unit square) and the
                center k of the hyperbola is necessarily inside the
                cell (otherwise one hyperbola branch would be completely
                outside the cell and the other branch could not cross
                more than two sides)

                hence, choose the next side by checking the quadrant
                where the hyperbola branch crossing side a-b lies

                   eta ^
                       |  :
                      1+--:---+
                       |e :  d|
                    ······+k······
                       |a :  b|
                      0+--:---+------>
                       0  :   1      xi
            --]]
            if ck == 0 then      -- math.abs(ck) <= math.abs(tol/2)
                -- choose side e-d
                next_side = side
            elseif ck < 0 then   -- ck < -tol/2
                -- choose side b-d
                if side == 'N' or side == 'S' then
                    next_side = 'W'
                else
                    next_side = 'S'
                end
            else                 -- ck > +tol/2
                -- choose side a-e
                if side == 'N' or side == 'S' then
                    next_side = 'E'
                else
                    next_side = 'N'
                end
            end
        end

        if corners then   -- enhanced corner algorithm

            --[[
                if, within the cell, the contour line is not straight
                we can improve its representation by computing an
                additional point: the vertex v of the hyperbola branch,
                as long as it lies inside the cell
            --]]
            if cc ~= 0 then
                -- depending on where the center k is, consider the
                -- vertex above or below k
                if eta_k < 0 then above = 1 else above = -1 end
                -- also check the sign of ck
                if ck < 0 then sign_ck = -1 else sign_ck = 1 end
                -- compute the vertex v
                xi_v  =  xi_k + sign_ck*above*math.sqrt(math.abs(ck))
                eta_v = eta_k +         above*math.sqrt(math.abs(ck))

                --[[
                    the vertex will be considered inside the cell, as long as
                    xi_0 <= xi_v <= xi_1   and    eta_0 <= eta_v <= eta_1
                --]]
                xi_0  =   - math.abs(tol/10)
                xi_1  = 1 + math.abs(tol/10)
                eta_0 =     math.abs(tol)
                eta_1 = 1 + math.abs(tol/10)
                -- eta_0 is meant to reject a vertex too close to side a-b
                -- (which already has a contour line point!)
                -- we should also reject a vertex too close to the next side
                if next_side == side then
                  -- next side is e-d
                  eta_1 = 1 - math.abs(tol)
                elseif next_side == 'W' or next_side == 'S' then
                  -- next side is b-d
                  xi_1  = 1 - math.abs(tol)
                else  -- next_side == 'E' or next_side == 'N'
                  -- next side is a-e
                  xi_0  =     math.abs(tol)
                end

                if xi_0  <= xi_v  and xi_v  <= xi_1  and
                   eta_0 <= eta_v and eta_v <= eta_1 then
                    -- v is inside the cell: compute its actual coordinates
                    pt = Coord.new()
                    for k = 1, 3 do
                        pt.x[k] = (1-xi_v)*(1-eta_v)*na.x[k] +
                                     xi_v *(1-eta_v)*nb.x[k] +
                                  (1-xi_v)*   eta_v *ne.x[k] +
                                     xi_v *   eta_v *nd.x[k]
                    end
                    pt.meta = isoval
                    -- add the vertex to the contour line
                    self.newcoords[#self.newcoords + 1] = pt
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

