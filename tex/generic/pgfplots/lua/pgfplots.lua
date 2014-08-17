
require("pgfplots.binary")

-- all classes/globals will be added to this table:
pgfplots = {}

require("pgfplots.util")

-- see pgfrcs.code.tex -- all versions after 3.0.0 (excluding 3.0.0) will set this version:
if not pgf or not pgf.pgfversion then
	pgfplots.log("log", "pgfplots.lua: loading complementary lua code for your pgf version...\n")
	pgfplots.pgfluamathfunctions = require("pgfplotsoldpgfsupp_pgfluamath.functions")
	pgfplots.pgfluamathparser = require("pgfplotsoldpgfsupp_pgfluamath.parser")
else
	pgfplots.pgfluamathparser = require("pgfluamath.parser")
	pgfplots.pgfluamathfunctions = require("pgfluamath.functions")
end
pgfplots.pgftonumber = pgfplots.pgfluamathfunctions.tonumber
pgfplots.tostringfixed = pgfplots.pgfluamathfunctions.tostringfixed
pgfplots.toTeXstring = pgfplots.pgfluamathfunctions.toTeXstring


require("pgfplots.plothandler")
require("pgfplots.meshplothandler")
require("pgfplots.colormap")
require("pgfplots.streamer")

-- hm. perhaps this here should become a separate module:
require("pgfplots.texio")
