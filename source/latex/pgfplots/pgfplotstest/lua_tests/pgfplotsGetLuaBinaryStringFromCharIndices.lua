-- Unit testing starts
require('pgfplotstest')

TestPgfplotsGetLuaBinaryStringFromCharIndices = {} --class
    function TestPgfplotsGetLuaBinaryStringFromCharIndices:testEmpty()
		result = pgfplotsGetLuaBinaryStringFromCharIndices({})
        assertEquals( type(result), 'string' )
        assertEquals( #result, 0 )
    end

    function TestPgfplotsGetLuaBinaryStringFromCharIndices:testSmall()
		result = pgfplotsGetLuaBinaryStringFromCharIndices({1,2,3})
        assertEquals( type(result), 'string' )
        assertEquals( #result, 3 )
        assertEquals( result, string.char(1,2,3) )
    end

-- class 

PgfplotsTest:runTest()
