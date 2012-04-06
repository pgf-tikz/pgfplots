-- Takes a table containing an arbitrary number of integers in the range 0..255 and converts it 
-- into a binary stream of the corresponding binary chars.
--
-- @param charIndices a table containing 0...N arguments; each in the range 0..255
--
-- @return a string containing binary content, one byte for each input integer.
function pgfplotsGetLuaBinaryStringFromCharIndices(charIndices)
	-- unpack extracts only the indices (we can't provide a table to string.char).
	-- note that pdf.immediateobj has been designed to avoid sanity checking for invalid UTF strings -
	-- in other words: it accepts binary strings.
	--
	-- unfortunately, this here fails for huge input tables:
	--   pgfplotsretval=string.char(unpack(charIndices));
	-- we have to create it incrementally using chunks:
	local len = #charIndices;
	local chunkSize = 7000;
	local buf = {};
	-- ok, append all full chunks of chunkSize first:
	local numFullChunks = math.floor(len/chunkSize);
	for i = 0, numFullChunks-1, 1 do
		table.insert(buf, string.char(unpack(charIndices, 1+i*chunkSize, (i+1)*chunkSize)));
	end
	-- append the rest:
	table.insert(buf, string.char(unpack(charIndices, 1+numFullChunks*chunkSize)));
	return table.concat(buf);
end

