DAYS := $(shell find . -type d -name "day*" | grep -v "build" | sort)
TESTS := $(addsuffix _test, $(DAYS))

.PHONY: all
all: $(DAYS)

.PHONY: test
test: $(TESTS)

define clib_day_template =
$(1)_clib: $(1)/*.c
	@mkdir -p build/$(1)
	@gcc -fPIC -shared -o build/$(1)/libsolution.so $$^

endef

define test_day_template =
$(1)_test: export LUA_PATH = ./?.lua;./?/init.lua;
$(1)_test: export LD_LIBRARY_PATH = ./build/$(1);$LD_LIBRARY_PATH;
$(1)_test: $(1)_clib $(1)/*.lua
	luajit $(1)/solution_test.lua

endef

define run_day_template =
$(1): export LUA_PATH = ./?.lua;./?/init.lua;
$(1): export LD_LIBRARY_PATH = ./build/$(1);$LD_LIBRARY_PATH;
$(1): $(1)_clib $(1)/*.lua
	luajit $(1)/main.lua

endef

$(foreach day,$(DAYS),$(eval $(call clib_day_template,$(day))))
$(foreach day,$(DAYS),$(eval $(call test_day_template,$(day))))
$(foreach day,$(DAYS),$(eval $(call run_day_template,$(day))))
