DAYS := $(shell find . -type d -name "day*" | sort)
TESTS := $(addsuffix _test, $(DAYS))

.PHONY: all
all: $(DAYS)

.PHONY: test
test: $(TESTS)

define test_day_template =
$(1)_test: export LUA_PATH = ./?.lua;./?/init.lua
$(1)_test: $(1)/*.*
	luajit $(1)/solution_test.lua

endef

define run_day_template =
$(1): export LUA_PATH = ./?.lua;./?/init.lua
$(1): $(1)/*.*
	luajit $(1)/main.lua

endef

$(foreach day,$(DAYS),$(eval $(call test_day_template,$(day))))
$(foreach day,$(DAYS),$(eval $(call run_day_template,$(day))))
