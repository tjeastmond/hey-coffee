test:
	./node_modules/.bin/mocha ./test/tests.coffee;

cat:
	./node_modules/.bin/mocha ./test/tests.coffee --reporter nyan;

clear:
	rm -rf ./test/blog;

.PHONY: test cat