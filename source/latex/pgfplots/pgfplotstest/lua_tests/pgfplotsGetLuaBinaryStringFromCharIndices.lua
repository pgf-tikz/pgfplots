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

    function TestPgfplotsGetLuaBinaryStringFromCharIndices:testChunkedNoRestOneChunk()
		pgfplotsGetLuaBinaryStringFromCharIndicesChunkSize = 5
		result = pgfplotsGetLuaBinaryStringFromCharIndices({1,2,3,4,5})
        assertEquals( type(result), 'string' )
        assertEquals( #result, 5 )
        assertEquals( result, string.char(1,2,3,4,5) )
    end

    function TestPgfplotsGetLuaBinaryStringFromCharIndices:testChunkedNoRestTwoChunks()
		pgfplotsGetLuaBinaryStringFromCharIndicesChunkSize = 5
		result = pgfplotsGetLuaBinaryStringFromCharIndices({1,2,3,4,5,6,7,8,9,10})
        assertEquals( type(result), 'string' )
        assertEquals( #result, 10 )
        assertEquals( result, string.char(1,2,3,4,5,6,7,8,9,10) )
    end

    function TestPgfplotsGetLuaBinaryStringFromCharIndices:testChunkedWithRest()
		pgfplotsGetLuaBinaryStringFromCharIndicesChunkSize = 5
		result = pgfplotsGetLuaBinaryStringFromCharIndices({1,2,3,4,5,6,7})
        assertEquals( type(result), 'string' )
        assertEquals( #result, 7 )
        assertEquals( result, string.char(1,2,3,4,5,6,7) )
    end
-- class 

PgfplotsTest:runTest()
