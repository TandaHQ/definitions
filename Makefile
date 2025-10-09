default: test

validate:
	bundle exec ruby lib/validation/run.rb

test: validate
	bundle exec rspec

.PHONY: validate,test
