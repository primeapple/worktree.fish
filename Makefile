SHELL := /usr/bin/env fish

.PHONY: all
all: fmt lint test

.PHONY: fmt
fmt:
	@fish_indent --write **.fish

.PHONY: lint
lint:
	@for file in **.fish; fish --no-execute $$file; end

littlecheck.py:
	@curl -sL https://raw.githubusercontent.com/ridiculousfish/littlecheck/HEAD/littlecheck/littlecheck.py -o littlecheck.py

.PHONY: test
test: littlecheck.py
	@fish_function_path=(pwd)/functions python3 littlecheck.py --progress tests/**.test.fish

.PHONY: clean
clean:
	@rm littlecheck.py
