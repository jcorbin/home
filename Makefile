REF = HEAD
VERSION = $(shell git describe --always $(REF))

ARCHIVE = vim-gorilla-script-$(VERSION).zip
ARCHIVE_DIRS = after compiler doc ftdetect ftplugin indent syntax

# Don't do anything by default.
all:

# Make vim.org zipball.
archive:
	git archive $(REF) -o $(ARCHIVE) -- $(ARCHIVE_DIRS)

# Remove zipball.
clean:
	-rm -f $(ARCHIVE)

# Build the list of syntaxes for @coffeeAll.
gorillaAll:
	@grep -E 'syn (match|region)' syntax/gorilla.vim |\
	 grep -v 'contained' |\
	 awk '{print $$3}' |\
	 uniq

.PHONY: all archive clean hash gorillaAll
