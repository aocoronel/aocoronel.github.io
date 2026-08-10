WEBSITE_DIR := _website
SCRIPT_DIR  := scripts
BUILD_PAGES := ./scripts/build-pages.py

POST_SOURCES := $(shell find _posts/ -type f -name "*.md" | sort)
PAGE_SOURCES := $(shell find _pages/ -type f -name "*.md" | sort)
CODE_SOURCES := $(shell find _code/ -type f -name "*.md" | sort)

CODE_READMES := $(filter %/README.md,$(CODE_SOURCES))
CODE_OTHER   := $(filter-out %/README.md,$(CODE_SOURCES))
CODE_HTML_READMES := $(patsubst _code/%/README.md,$(WEBSITE_DIR)/%/index.html,$(CODE_READMES))
CODE_HTML_OTHERS := $(patsubst _code/%.md,$(WEBSITE_DIR)/%.html,$(CODE_OTHER))

CODE_HTML := $(CODE_HTML_READMES) $(CODE_HTML_OTHERS)
POST_HTML    := $(patsubst _posts/%.md,$(WEBSITE_DIR)/%.html,$(POST_SOURCES))
PAGE_HTML    := $(patsubst _pages/%.md,$(WEBSITE_DIR)/%.html,$(PAGE_SOURCES))

CSS_SOURCES := $(shell find _style/ -type f -name "*.css" | sort)
CSS_OUTPUTS := $(patsubst _style/%.css,$(WEBSITE_DIR)/%.css,$(CSS_SOURCES))

STATIC_HTML  := $(WEBSITE_DIR)/index.html $(WEBSITE_DIR)/archive.html

RSS_FEED     := $(WEBSITE_DIR)/feed.xml
SITEMAP      := $(WEBSITE_DIR)/sitemap.xml

all: posts code index css feed sitemap

_website:
	@mkdir -p $(WEBSITE_DIR)

index: $(PAGE_SOURCES) $(POST_HTML)
	@python3 scripts/makeindex.py

posts: $(POST_HTML)

$(WEBSITE_DIR)/%.html: _posts/%.md | $(WEBSITE_DIR)
	@python3 $(BUILD_PAGES) --post "$<"

$(WEBSITE_DIR)/%.html: _pages/%.md | $(WEBSITE_DIR)
	@python3 $(BUILD_PAGES) --basic "$<"

code: $(CODE_HTML)

$(WEBSITE_DIR)/%/index.html: _code/%/README.md | $(WEBSITE_DIR)
	@python3 $(BUILD_PAGES) --code "$<"

$(WEBSITE_DIR)/%.html: _code/%.md | $(WEBSITE_DIR)
	@python3 $(BUILD_PAGES) --code "$<"

css: $(CSS_OUTPUTS)

$(WEBSITE_DIR)/%.css: _style/%.css | $(WEBSITE_DIR)
	@rsync -azPl --update "$<" $(WEBSITE_DIR)/

feed: $(RSS_FEED)

$(RSS_FEED): $(POST_HTML)
	@python3 scripts/rss_gen.py

sitemap: $(SITEMAP)

$(SITEMAP): $(POST_HTML) $(PAGE_HTML) $(CODE_HTML) $(STATIC_HTML)
	@python3 scripts/sitemap_gen.py

serve:
	@cd _website && python3 -m http.server

clean:
	rm -rf $(WEBSITE_DIR)/*

.PHONY: all serve clean posts code index css feed sitemap
