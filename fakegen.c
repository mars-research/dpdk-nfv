#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MTU 1500
#define CPU_FREQ 3800000000
	
size_t batch_size = 32;

static const char PACKET_TEMPLATE[] = {
	0x3c, 0xfd, 0xfe, 0xb4, 0xf9, 0xff, 0x3c, 0xfd, 0xfe, 0xb4, 0xfb, 0xdc, 0x08, 0x00, 0x45, 0x00,
	0x00, 0x32, 0xa8, 0x2e, 0x00, 0x00, 0x40, 0x11, 0xb8, 0x76, 0x39, 0x55, 0x63, 0x02, 0x0a, 0x0a,
	0x03, 0x01, 0x15, 0xb3, 0x15, 0xb3, 0x00, 0x1e, 0x90, 0x00, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70,
	0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35
};

uint64_t clock_gettime_latency = 0;
uint64_t fake_delay = 250;
uint64_t fake_per_delay = 625;
long int counter;

/// Receive packets from the synthetic generator.
size_t receive_packets(void *buf, size_t batch_size,void **buf_ptr) {
	for (size_t i = 0; i < batch_size; ++i) {
		char * pkt = (char*)buf + i * MTU;
		buf_ptr[i] = pkt;
		memcpy(pkt, PACKET_TEMPLATE, sizeof(PACKET_TEMPLATE));
		pkt[26] = counter%(1<<20);
		counter++;
		for (size_t i = 0; i < fake_per_delay; ++i) {
			asm volatile("nop");
		}
	}
	for (size_t i = 0; i < fake_delay; ++i) {
		asm volatile("nop");
	}
	return batch_size;
}

/// Reads the processor cycle counter.
uint64_t rdtsc() {
	uint32_t hi, lo;
	__asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
	return ((uint64_t)lo | (uint64_t)hi << 32);
}

/// Calibrates the latency of clock_gettime().
void calibrate_clock_gettime_latency() {
	fprintf(stderr, "** Calibrating clock_gettime() latency... ");
	fflush(stderr);

	size_t iterations = 10000000;
	uint64_t start = rdtsc();

	struct timespec ts;
	for (size_t i = 0; i < iterations; ++i) {
		clock_gettime(CLOCK_MONOTONIC, &ts);
	}

	uint64_t cycles = rdtsc() - start;

	clock_gettime_latency = cycles / iterations;
	fprintf(stderr, "%zu cycles\n", clock_gettime_latency);
}

/// Runs the receive loop.
void run_receive_loop() {
	size_t iterations = 1000000;

	void *packets = malloc(MTU * batch_size);
	void *packets_ptr[batch_size];

	struct timespec start_ts, end_ts;

	clock_gettime(CLOCK_MONOTONIC, &start_ts);
	uint64_t start = rdtsc();

	for (size_t i = 0; i < iterations; ++i) {
		receive_packets(packets, batch_size,packets_ptr);
	}

	clock_gettime(CLOCK_MONOTONIC, &end_ts);
	uint64_t cycles = rdtsc() - start;
	uint64_t millis = (end_ts.tv_sec - start_ts.tv_sec) * 1000 + (end_ts.tv_nsec - start_ts.tv_nsec) / 1000000;
	uint64_t ppms = iterations * batch_size / millis;

	printf("packets received = %zu\n", iterations * batch_size);
	printf("    total cycles = %zu\n", cycles);
	printf("      throughput = %zu pps\n", ppms * 1000);
}

int main() {
	calibrate_clock_gettime_latency();
	run_receive_loop();
}
