COFFEE = ./node_modules/.bin/coffee
COFFEELINT = ./node_modules/.bin/coffeelint
BROWSERIFY = ./node_modules/.bin/browserify
MOCHA = ./node_modules/.bin/mocha
TARGET = test
UGLIFY = ./node_modules/.bin/uglifyjs
COVERALLS = ./node_modules/.bin/coveralls
REPORTER = spec
MOCHA_OPTS = --colors --growl --bail --check-leaks --require blanket

test: lint build
	@cd test/fixture && npm i
	$(MOCHA) --compilers coffee:coffee-script/register --reporter $(REPORTER) $(MOCHA_OPTS) $(TARGET)

bench: lint build
	@cd test/fixture && npm i
	$(MOCHA) --compilers coffee:coffee-script/register --reporter $(REPORTER) $(MOCHA_OPTS) --timeout 0 test/benchmark  $(TARGET)

coverage: lint build
	@cd test/fixture && npm i
	$(MOCHA) --compilers coffee:coffee-script/register --reporter mocha-lcov-reporter $(MOCHA_OPTS) $(TARGET) | $(COVERALLS)

lint:
	$(COFFEELINT) -f ./etc/coffeelint.json --reporter coffeelint-stylish src test

build:
	@rm -rf lib
	@test -d lib/core || mkdir -p lib/core
	$(COFFEE) -o lib -c src
	$(BROWSERIFY) lib/gauntlet.js > lib/core/gauntlet.js
	$(UGLIFY) lib/core/gauntlet.js -o lib/core/gauntlet.min.js --source-map lib/core/gauntlet.map --source-map-url gauntlet.map -p 5 -m -c warnings=false
	@echo "========Report\n`du -h lib/*.js lib/core/*.js`\n========"


.PHONY: test bench coverage lint

