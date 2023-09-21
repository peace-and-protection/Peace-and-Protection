# This Makefile is used to generate the releases and the archive with only the files changed since previous release.
# it is tested to make it work on GNU/Linux for generating releases.
# It needs the «dos2unix» and «awk» commands installed.
#
# To create a release, use «make» BEFORE tagging the release, or the diff will not be created properly.


LATEST_TAG=$(shell git describe --tags --abbrev=0)
VERSION=$(shell awk 'NR==2' pp-readme.txt |dos2unix|cut -f2 -d ' ')

all: release diff

release:
	git archive --format=zip -o pnp-$(VERSION).zip HEAD

diff:
	git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT HEAD $(LATEST_TAG)|grep -v "`cat .diff-exclude`"|xargs zip -FSq fix-$(VERSION).zip
	git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT HEAD v4.22.3|grep -v "`cat .diff-exclude`"|xargs zip -FSq fix.zip

upload:
	rsync -avh pnp-$(VERSION).zip ${HOME}/Dokumenter/Mine_dokumenter/oppdrag/pnp/pnp/dl/
	rsync -avh fix-$(VERSION).zip fix.zip ${HOME}/Dokumenter/Mine_dokumenter/oppdrag/pnp/fix/
	rsync -avh pp-faq.txt pp-readme.txt quits.txt whatsnew.txt ${HOME}/Dokumenter/Mine_dokumenter/oppdrag/pnp/pnp/

git-tag:
	git tag -s v$(VERSION) -m "Version $(VERSION)"
