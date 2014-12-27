
function assertEquals(actual, expected, msg)
	local errorValue = math.abs(actual - expected)
	if errorValue > 1e-4 then
		error(msg .. " expected " .. tostring(expected) .. " but was " .. tostring(actual))
	end
end

--- ATTENTION:
-- you can use http://pbil.univ-lyon1.fr/Rweb/ to compute a reference in R
--
-- R code:  quantile(x <- c(1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9), c(0.25, 0.75, 0.5), type = 5)

do
-- This is the case which was shipped and tested with pgfplots:
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("legacy"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7, "0.5 with " .. tostring(request.estimator))
end

do
-- R1
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R1"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7, "0.5 with " .. tostring(request.estimator))
end

do
-- R2
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R2"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 3, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end

do
-- R3
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R3"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7, "0.5 with " .. tostring(request.estimator))
end

do
-- R4
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R4"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7, "0.5 with " .. tostring(request.estimator))
end

do
-- R5
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R5"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 3, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end

do
-- R6
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R6"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2.5, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end

do
-- R7 (excel)
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R7"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 3.5, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end

do
-- R8
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R8"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2.833333, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end

do
-- R9
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R9"));
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 2.875, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
end


-------- Test border cases: 

local candidates = { "legacy", "R1","R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9" }

-- Array of length 1:
for i = 1,#candidates do
	local request =
		pgfplots.BoxPlotRequest.new( 
			"0.25",
			"0.75",
			"1.5",
			pgfplots.getPercentileEstimator(candidates[i]));
	local data ={42 };
	local response = pgfplots.boxPlotCompute(request, data)

	assertEquals(response.lowerQuartile, 42, "lowerQuartile " .. tostring(request.estimator))
	assertEquals(response.upperQuartile, 42, "upperQuartiel " .. tostring(request.estimator))
	assertEquals(response.median, 42, "median " .. tostring(request.estimator))
end

-- Array of length 2:
do
-- This is the case which was shipped and tested with pgfplots:
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("legacy"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 46, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 42, "0.5 with " .. tostring(request.estimator))
end

do
-- R1
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R1"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 42, "0.5 with " .. tostring(request.estimator))
end

do
-- R2
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R2"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end

do
-- R3
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R3"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 42, "0.5 with " .. tostring(request.estimator))
end

do
-- R4
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R4"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 46, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 42, "0.5 with " .. tostring(request.estimator))
end

do
-- R5
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R5"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end

do
-- R6
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R6"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end

do
-- R7 (excel)
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R7"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 44, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 48, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end

do
-- R8
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R8"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end

do
-- R9
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R9"));
local data = {42, 50}
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 42, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 50, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 46, "0.5 with " .. tostring(request.estimator))
end


-------------
--
-- Proof of concept of "morePercentiles"
do
-- R7 (excel)
local request =
	pgfplots.BoxPlotRequest.new( 
		"0.25",
		"0.75",
		"1.5",
		pgfplots.getPercentileEstimator("R7"),
		{ 0.1, 0.95 } );
local data ={1, 2, 1, 5, 4, 10, 7, 10, 9, 8, 9, 9, };
local response = pgfplots.boxPlotCompute(request, data)

assertEquals(response.lowerQuartile, 3.5, "0.25 with " .. tostring(request.estimator))
assertEquals(response.upperQuartile, 9, "0.75 with " .. tostring(request.estimator))
assertEquals(response.median, 7.5, "0.5 with " .. tostring(request.estimator))
assertEquals(#response.morePercentiles, 2, "got unexpected number of morePercentiles")
assertEquals(response.morePercentiles[1], 1.1, "0.1 with " .. tostring(request.estimator))
assertEquals(response.morePercentiles[2], 10, "0.95 with " .. tostring(request.estimator))
end
