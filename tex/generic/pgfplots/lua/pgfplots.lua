
require("pgfplots.binary")

-- all classes/globals will be added to this table:
pgfplots = {}
require("pgfplots.util")
pgfplots.pgfluamathparser = require("pgfplotsoldpgf_luamath.parser")
pgfplots.pgfluamathfunctions = require("pgfplotsoldpgf_luamath.functions")

require("pgfplots.plothandler")
require("pgfplots.colormap")
require("pgfplots.streamer")

-- hm. perhaps this here should become a separate module:
require("pgfplots.texio")
