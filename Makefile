# This Makefile is used to generate the releases and the archive with only the files changed since previous release.
# it is tested to make work on GNU/Linux fr generating releases.
# It needs the «dos2unix» and «awk» commands installed.
#
# To create a release, use «make release && make diff» BEFORE tagging the release, or the diff will not be created properly.


LATEST_TAG=`git describe --tags --abbrev=0`
VERSION=`awk 'NR==2' pp-readme.txt |dos2unix|cut -f2 -d ' '`

release:
	git archive --format=zip -o pnp-$(VERSION).zip HEAD

diff:
	git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT HEAD $(LATEST_TAG)|grep -v "`cat .diff-exclude`"|xargs zip -q fix-$(VERSION).zip
	git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT HEAD v4.22.3|grep -v "`cat .diff-exclude`"|xargs zip -q fix.zip
