
require("pgfplots.binary.lua")

-- all classes/globals will be added to this table:
pgfplots = {}
require("pgfplots.util.lua")

require("pgfplots.plothandler.lua")
require("pgfplots.colormap.lua")

-- hm. perhaps this here should become a separate module:
require("pgfplots.texio.lua")
