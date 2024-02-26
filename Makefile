PHONY: test test-python

default: test

test: test-python

test-python:
	docker buildx build .
