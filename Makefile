.PHONY: fmt

fmt:
	stylua -s awesome/.config/awesome

pre-commit:
	stylua -c -s awesome/.config/awesome
