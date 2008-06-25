build: project-build changelog

clean: project-clean
	rm -rf dist.d changelog

dist: dist.d
	cp -a dist.d /tmp/${PROJECT}
	tar -C /tmp -cjf ${PROJECT}-$$(echo ${VERSION} | sed -e 's/\./_/g').tar.bz2 ${PROJECT}
	rm -rf /tmp/${PROJECT}

dist.d: build
	[ -d dist.d ] && rm -rf dist.d || true
	mkdir dist.d
	cp -a $$(cat manifest) dist.d

changelog: .always_generate_changelog
	git log -n1 --pretty='format:%H%n%n' > changelog
	git log --pretty='format:[%ai] - %an <%ae>: %s%n%b' >> changelog

.always_generate_changelog:
