
TESTS=$(wildcard *.lua)

TEST_RESULTS=$(TESTS:.lua=.result)

LUA_PATH:=$(LUA_PATH);./framework/?.lua;./framework/luaunit/?.lua;../../../../../tex/generic/pgfplots/lua/?.lua;;
LUA?=texlua

run: $(TEST_RESULTS)


%.result: %.lua
	@echo 'export LUA_PATH="$(LUA_PATH)" && $(LUA) $<'
	@export LUA_PATH="$(LUA_PATH)" && $(LUA) $< > $@ && echo "$< PASSED" || ( cat $@; exit 1 )
