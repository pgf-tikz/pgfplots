
function assertEquals(actual, expected, msg)
	local errorValue = math.abs(actual - expected)
	if errorValue > 1e-4 then
		error(msg .. " expected " .. tostring(expected) .. " but was " .. tostring(actual))
	end
end

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

assertEquals(response.lowerQuartile, 2, "lowerQuartile")
assertEquals(response.upperQuartile, 9, "upperQuartiel")
assertEquals(response.median, 7, "median")
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

assertEquals(response.lowerQuartile, 2, "lowerQuartile")
assertEquals(response.upperQuartile, 9, "upperQuartiel")
assertEquals(response.median, 7, "median")
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

assertEquals(response.lowerQuartile, 3.5, "lowerQuartile")
assertEquals(response.upperQuartile, 9, "upperQuartiel")
assertEquals(response.median, 7.5, "median")
end
