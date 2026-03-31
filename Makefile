.PHONY: test integration-test build clean

NIM_TEST_FLAGS ?= --hints:off --warnings:off

nim.cfg: nimby.lock
	nimby sync -g nimby.lock

build: nim.cfg

test: nim.cfg
	@files=$$(ls tests/test_*.nim 2>/dev/null); \
	if [ -z "$$files" ]; then \
		echo "No unit tests found"; exit 0; \
	fi; \
	fail=0; pids=""; \
	for f in $$files; do \
		( nim r $(NIM_TEST_FLAGS) "$$f" 2>&1 | sed "s|^|[$$f] |" ) & \
		pids="$$pids $$!"; \
	done; \
	for pid in $$pids; do wait $$pid || fail=1; done; \
	exit $$fail

integration-test: nim.cfg
	@files=$$(ls tests/integration_*.nim 2>/dev/null); \
	if [ -z "$$files" ]; then \
		echo "No integration tests found"; exit 0; \
	fi; \
	fail=0; pids=""; \
	for f in $$files; do \
		( nim r $(NIM_TEST_FLAGS) "$$f" 2>&1 | sed "s|^|[$$f] |" ) & \
		pids="$$pids $$!"; \
	done; \
	for pid in $$pids; do wait $$pid || fail=1; done; \
	exit $$fail

clean:
	rm -rf nimcache
