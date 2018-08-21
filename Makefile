#
# Makefile for perfsonar-git-hooks
#

default:
	@echo Nothing to do here.

clean:
	find . -name "*~" -print0 | xargs -0 rm -f
	rm -rf $(TO_CLEAN)
