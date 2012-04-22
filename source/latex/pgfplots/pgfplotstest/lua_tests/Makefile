
TESTS=$(wildcard *.lua)

TEST_RESULTS=$(TESTS:.lua=.result)

LUA_PATH:=$(LUA_PATH);./framework/?.lua;./framework/luaunit/?.lua;../../../../../scripts/lua/pgfplots/?.lua;;

run: $(TEST_RESULTS)


%.result: %.lua
	@echo 'export LUA_PATH="$(LUA_PATH)" && lua $<'
	@export LUA_PATH="$(LUA_PATH)" && lua $< > $@ && echo "$< PASSED" || ( cat $@; exit 1 )
