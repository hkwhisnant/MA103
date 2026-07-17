SRC_DIR   := src
BUILD_DIR := build
LATEX     := pdflatex -interaction=nonstopmode -halt-on-error

LESSON_DIRS := $(wildcard $(SRC_DIR)/*)

ifdef LESSON
LESSON_DIRS := $(wildcard $(SRC_DIR)/$(LESSON)-*)
ifeq ($(LESSON_DIRS),)
$(error No lesson directory matching: $(SRC_DIR)/$(LESSON)-*)
endif
endif

LESSONS := $(notdir $(LESSON_DIRS))
PDFS    := $(foreach l,$(LESSONS),$(BUILD_DIR)/$(l)/$(l).pdf)

.PHONY: all clean

all: $(PDFS)

# Generates one rule per lesson so the output pdf can be named after the
# lesson folder rather than the .tex file it was built from.
#   $(1) = lesson name   $(2) = path to that lesson's main .tex file
define LESSON_RULE
$(BUILD_DIR)/$(1)/$(1).pdf: $(2)
	@mkdir -p $(BUILD_DIR)/$(1)
	cd $(SRC_DIR)/$(1) && $(LATEX) -output-directory=$(CURDIR)/$(BUILD_DIR)/$(1) $(notdir $(2))
	mv $(BUILD_DIR)/$(1)/$(basename $(notdir $(2))).pdf $(BUILD_DIR)/$(1)/$(1).pdf
	@find $(BUILD_DIR)/$(1) -maxdepth 1 -type f ! -name '$(1).pdf' -delete
endef

$(foreach l,$(LESSONS),$(if $(wildcard $(SRC_DIR)/$(l)/*.tex),$(eval $(call LESSON_RULE,$(l),$(firstword $(wildcard $(SRC_DIR)/$(l)/*.tex)))),))

clean:
	rm -rf $(BUILD_DIR)
