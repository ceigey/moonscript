LUA      ?= lua5.1
LUAROCKS ?= luarocks

ifneq ($(LUA),lua)
	LUA_VERSION = $(shell echo $(LUA) | sed -e "s/lua\(.*\)/\1/")
	LUAROCKS = luarocks-$(LUA_VERSION)
	LUA_PATH_MAKE = $(shell echo "${LUA_PATH}" | sed -e "s/[0-9]\.[0-9]/$(LUA_VERSION)/g")
	LUA_CPATH_MAKE = $(shell echo "${LUA_CPATH}" | sed -e "s/[0-9]\.[0-9]/$(LUA_VERSION)/g")
endif

ifeq ($(LUA),luajit)
	LUAROCKS = luarocks-5.1
endif


.PHONY: test local compile watch lint test_safe

test:
	busted -p "_spec.moon$$"

test_safe:
	busted -p "_spec.lua$$"

local: compile
	LUA_PATH=$(LUA_PATH_MAKE) LUA_CPATH=$(LUA_CPATH_MAKE) $(LUAROCKS) make --local moonscript-dev-1.rockspec

global:
	sudo LUA_PATH=$(LUA_PATH_MAKE) LUA_CPATH=$(LUA_CPATH_MAKE) $(LUAROCKS) make moonscript-dev-1.rockspec

compile: init
	LUA_PATH=$(LUA_PATH_MAKE) LUA_CPATH=$(LUA_CPATH_MAKE) $(LUA) bin/moonc moon/ moonscript/
	echo "#!/usr/bin/env lua" > bin/moon
	$(LUA) bin/moonc -p bin/moon.moon >> bin/moon
	echo "-- vim: set filetype=lua:" >> bin/moon

watch:
	moonc moon/ moonscript/ && moonc -w moon/ moonscript/

lint:
	moonc -l moonscript moon bin
