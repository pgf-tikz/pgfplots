require('luaunit')
USE_EXPECTED_ACTUAL_IN_ASSERT_EQUALS = false
require('pgfplots')

PgfplotsTest = {} -- class
function PgfplotsTest:runTest()
	numFailures = LuaUnit:run()
	print("exit code " .. numFailures );
	os.exit(numFailures)
	-- local ok, err_or_result = xpcall(LuaUnit:run(), debug.traceback)
	-- code = 0;
    --if not ok then
    --    print (err_or_result)
--		code = 1;
  --  end
	--print("exiting with code " .. code);
	--os.exit(code);
end
