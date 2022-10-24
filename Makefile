DIR_LIB:=lib
include $(DIR_LIB)/make-pal/pal.mak
DIR_SRC:=src
DIR_INCLUDE:=include
DIR_BUILD:=build
CC:=gcc

MAIN_NAME:=appname
MAIN_SRC:=$(wildcard $(DIR_SRC)/*.c)
MAIN_OBJ:=$(MAIN_SRC:$(DIR_SRC)/%.c=$(DIR_BUILD)/$(MAIN_NAME)/%.o)
MAIN_DEP:=$(MAIN_OBJ:%.o=%.d)

# Add these lines to link with a library:
# -I$(DIR_LIB)/libsomename/include
# -L$(DIR_LIB)/libsomename/build
# -lsomename
MAIN_CC_FLAGS:=\
	-W \
	-Wall \
	-Wextra \
	-Werror \
	-Wno-unused-parameter \
	-Wconversion \
	-Wshadow \
	-O2 \
	-I$(DIR_INCLUDE) \
	-isystem$(DIR_LIB)/tau
# Select the target to build for a library here.
# MAIN_LIBSOMENAME_TARGET:=main

TEST_NAME:=test
TEST_SRC:=$(wildcard $(TEST_NAME)/$(DIR_SRC)/*.c)
TEST_OBJ:=$(TEST_SRC:$(TEST_NAME)/$(DIR_SRC)/%.c=$(DIR_BUILD)/$(TEST_NAME)/%.o)
TEST_DEP:=$(TEST_OBJ:%.o=%.d)
TEST_CC_FLAGS:=$(MAIN_CC_FLAGS)

all: main test
.PHONY: all

main: $(DIR_BUILD) $(DIR_BUILD)/$(MAIN_NAME) $(DIR_BUILD)/$(MAIN_NAME).$(EXT_BIN)
# If a different library target should be build in debug mode.
# main-dbg: MAIN_LIBSOMENAME_TARGET:=main-dbg-clr
main-dbg: MAIN_CC_FLAGS+=-g -DDEBUG -fsanitize=address
main-dbg: main
.PHONY: main main-dbg

test: $(DIR_BUILD) $(DIR_BUILD)/$(TEST_NAME) $(DIR_BUILD)/$(TEST_NAME).$(EXT_BIN)
test-dbg: TEST_CC_FLAGS+=-g -DDEBUG -fsanitize=address
test-dbg: test
.PHONY: test test-dbg

# To depend on a library add something like:
# $(DIR_LIB)/somename/build/$(LIB_PREFIX)somename.$(EXT_LIB_STATIC)
# Build app.
$(DIR_BUILD)/$(MAIN_NAME).$(EXT_BIN): $(MAIN_OBJ)
	$(CC) $(^) -o $(@) $(MAIN_CC_FLAGS)
# Build tests.
$(DIR_BUILD)/$(TEST_NAME).$(EXT_BIN): $(TEST_OBJ)
	$(CC) $(^) -o $(@) $(TEST_CC_FLAGS)

# Build somename library.
# $(DIR_LIB)/somename/build/$(LIB_PREFIX)somename.$(EXT_LIB_STATIC):
# 	cd $(DIR_LIB)/somename && $(MAKE) $(MAIN_LIBSOMENAME_TARGET)

# Compile source files to object files.
$(DIR_BUILD)/$(MAIN_NAME)/%.o: $(DIR_SRC)/%.c
	$(CC) $(<) -o $(@) $(MAIN_CC_FLAGS) -c -MMD
$(DIR_BUILD)/$(TEST_NAME)/%.o: $(TEST_NAME)/$(DIR_SRC)/%.c
	$(CC) $(<) -o $(@) $(TEST_CC_FLAGS) -c -MMD

# Recompile source files after a header they include changes.
-include $(MAIN_DEP)
-include $(TEST_DEP)

$(DIR_BUILD) $(DIR_BUILD)/$(MAIN_NAME) $(DIR_BUILD)/$(TEST_NAME):
	$(call pal_mkdir,$(@))

# To clean up the compiler output inside the library dirs:
# cd $(DIR_LIB)/swicc && $(MAKE) clean
clean:
	$(call pal_rmdir,$(DIR_BUILD))
.PHONY: clean
