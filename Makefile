test:
	./node_modules/.bin/mocha;

cat:
	./node_modules/.bin/mocha --reporter nyan;

.PHONY: test cat