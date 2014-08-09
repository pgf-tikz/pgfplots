
require("pgfplots.binary")

-- all classes/globals will be added to this table:
pgfplots = {}
require("pgfplots.util")
-- FIXME : solve dependencies when releasing this pgfplots version...
pgfplots.pgfluamathparser = require("pgfluamath.parser")
pgfplots.pgfluamathfunctions = require("pgfluamath.functions")

require("pgfplots.plothandler")
require("pgfplots.meshplothandler")
require("pgfplots.colormap")
require("pgfplots.streamer")

-- hm. perhaps this here should become a separate module:
require("pgfplots.texio")
