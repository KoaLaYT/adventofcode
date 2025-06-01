DAYS := $(shell find . -type d -name "day*" | sort)
TESTS := $(addsuffix _test, $(DAYS))

.PHONY: all
all: $(DAYS)

.PHONY: test
test: $(TESTS)

define test_day_template =
$(1)_test: $(1)/*.*
	@bun test $(1)/solution_test.ts

endef

define run_day_template = 
$(1): $(1)/*.*
	@echo $(1)
	@bun run $(1)/main.ts

endef

$(foreach day,$(DAYS),$(eval $(call test_day_template,$(day))))
$(foreach day,$(DAYS),$(eval $(call run_day_template,$(day))))
