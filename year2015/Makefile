DAYS := $(shell find . -type d -name "day*" | sort)

.PHONY: all
all: $(DAYS)

.PHONY: test
test:
	go test ./...

define run_day_template = 
$(1): $(1)/*.*
	go run $(1)

endef

$(foreach day,$(DAYS),$(eval $(call run_day_template,$(day))))
