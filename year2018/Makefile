COMPILE_FLAG := -g -Wall -Wextra

LIB_SRC := $(shell find ./lib -name "*.c")
LIB_OBJ := $(LIB_SRC:%=obj/%.o)
DAYS := $(shell find . -mindepth 1 -maxdepth 1 -name "day*" | sort)
TESTS := $(addsuffix _test, $(DAYS))

.PHONY: all
all: $(DAYS)

.PHONY: test
test: $(TESTS)

define run_day_template =
$(1): lib
	@gcc $(COMPILE_FLAG) -o bin/$(1) $(LIB_OBJ) $(1)/main.c
	@./bin/$(1) $(1)/input.txt

endef

define test_day_template =
$(1)_test: lib
	@gcc $(COMPILE_FLAG) -o bin/$(1)_test $(LIB_OBJ) $(1)/solution_test.c
	@echo "tests $(1)"
	@./bin/$(1)_test

endef

$(foreach day,$(DAYS),$(eval $(call run_day_template,$(day))))
$(foreach day,$(DAYS),$(eval $(call test_day_template,$(day))))

.PHONY: lib
lib: scaffold $(LIB_OBJ)

.PHONY: scaffold
scaffold: 
	@mkdir -p obj/lib

obj/%.c.o: %.c
	@gcc $(COMPILE_FLAG) -c -o $@ $<
