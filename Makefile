format:
	clang-format -style=google -i src/*.cpp src/*.hpp src/*.c src/*.h

papi_setup:
	sudo sh -c 'echo -1 >/proc/sys/kernel/perf_event_paranoid'

papi_avail:
	papi_avail