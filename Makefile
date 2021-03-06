BIN = $(PWD)/node_modules/.bin/
SASSDOC = $(PWD)/bin/sassdoc

all: lint dist test

# Compile ES6 from `src` to ES5 in `dist`
# =======================================

dist:
	rm -rf $@
	$(BIN)babel src -d $@

# Code quality
# ============

lint:
	$(BIN)eslint bin/sassdoc index.js src test

test: test/data/expected.stream.json dist
	$(BIN)mocha test/**/*.test.js
	$(SASSDOC) --parse test/data/test.scss | diff - test/data/expected.json
	$(SASSDOC) --parse - < test/data/test.scss | diff - test/data/expected.stream.json
	rm -rf sassdoc && $(SASSDOC) test/data/test.scss && [ -d sassdoc ]
	rm -rf sassdoc && $(SASSDOC) - < test/data/test.scss && [ -d sassdoc ]
	rm -rf sassdoc && $(SASSDOC) -c test/config.yaml test/data/test.scss && [ -d sassdoc ]
	rm -rf sassdoc test/custom-sassdoc && $(SASSDOC) -c test/config-dest.yaml test/data/test.scss && [ -d test/custom-sassdoc ]

test/data/expected.stream.json: test/data/expected.json
	test/data/stream $< > $@

cover:
	rm -rf coverage
	$(BIN)nyc $(BIN)mocha test/**/*.test.js

cover-browse: dist
	rm -rf coverage
	$(BIN)nyc --reporter=html $(BIN)mocha test/**/*.test.js
	$(BIN)opn coverage/index.html

coveralls:
	($(BIN)nyc report --reporter=text-lcov | $(BIN)coveralls) || exit 0


# Development
# ===========

develop:
	$(BIN)babel-node $@

# Publish package to npm
# @see npm/npm#3059
# =======================

publish: all
	npm publish

# Release, publish
# ================

# "patch", "minor", "major", "prepatch",
# "preminor", "premajor", "prerelease"
VERS ?= "patch"
TAG  ?= "latest"

release: all
	npm version $(VERS) -m "Release %s"
	npm publish --tag $(TAG)
	git push --follow-tags

# Tools
# =====

rebuild:
	rm -rf node_modules
	npm install

.PHONY: dist test develop
.SILENT: dist develop cover view-cover travis
