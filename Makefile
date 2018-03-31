# This Makefile is used to generate the releases and the archive with only the files changed since previous release.
# It needs the «dos2unix» utillity installed.

LATEST_TAG=`git describe --tags --abbrev=0`
VERSION=`awk 'NR==2' pp-readme.txt |dos2unix|cut -f2 -d ' '`

release:
	git archive --format=zip -o pnp-$(VERSION).zip HEAD

diff:
	git diff-tree -r --no-commit-id --name-only HEAD $(LATEST_TAG)|xargs zip fix-$(VERSION).zip -q -
