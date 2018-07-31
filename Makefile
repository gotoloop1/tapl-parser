NAME := sasago

CXX      := g++
CXXFLAGS := -g2 -Wextra
LIBS     :=

LEX  := flex
YACC := bison

SOURCE_DIR := src
LIB_DIR    := lib
BUILD_DIR  := build
TMP_DIR    := build/src_tmp

SOURCE_NAMES := $(notdir $(wildcard $(SOURCE_DIR)/*.cpp)) \
								$(NAME).yacc.cpp $(NAME).lex.cpp \
								json11.cpp
HEADER_NAMES := $(notdir $(wildcard $(SOURCE_DIR)/*.hpp)) \
								$(NAME).yacc.hpp \
								json11.hpp
TMP_SOURCES  := $(addprefix $(TMP_DIR)/,$(SOURCE_NAMES))
TMP_HEADERS  := $(addprefix $(TMP_DIR)/,$(HEADER_NAMES))
OBJS         := $(addprefix $(BUILD_DIR)/,$(SOURCE_NAMES:.cpp=.o))
DEPENDS      := $(addprefix $(BUILD_DIR)/,$(SOURCE_NAMES:.cpp=.depend))

all: $(DEPENDS) $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $(NAME) $^

$(BUILD_DIR)/%.o: $(TMP_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(LIBS) -c -o $@ $^

$(TMP_DIR)/%.cpp: $(SOURCE_DIR)/%.cpp
	@mkdir -p $(TMP_DIR)
	@cp $< $@
$(TMP_DIR)/%.hpp: $(SOURCE_DIR)/%.hpp
	@mkdir -p $(TMP_DIR)
	@cp $< $@

$(TMP_DIR)/$(NAME).yacc.cpp: $(SOURCE_DIR)/$(NAME).yy
	@mkdir -p $(TMP_DIR)
	$(YACC) -o $@ $^
$(TMP_DIR)/$(NAME).yacc.hpp: $(SOURCE_DIR)/$(NAME).yy
	@mkdir -p $(TMP_DIR)
	$(YACC) -o $(TMP_DIR)/$(NAME).yacc.cpp $^
$(TMP_DIR)/$(NAME).lex.cpp: $(SOURCE_DIR)/$(NAME).ll
	@mkdir -p $(TMP_DIR)
	$(LEX) -o$@ $^

$(TMP_DIR)/json11.cpp: $(LIB_DIR)/json11/json11.cpp
	@mkdir -p $(TMP_DIR)
	@cp $< $@
$(TMP_DIR)/json11.hpp: $(LIB_DIR)/json11/json11.hpp
	@mkdir -p $(TMP_DIR)
	@cp $< $@

$(BUILD_DIR)/%.depend: $(TMP_DIR)/%.cpp $(TMP_HEADERS)
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(LIBS) -MM $< > $@
ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPENDS)
endif

.PHONY: clean
clean:
	rm -rf $(TMP_DIR)
	rm -rf $(BUILD_DIR)
	rm -f $(NAME)
