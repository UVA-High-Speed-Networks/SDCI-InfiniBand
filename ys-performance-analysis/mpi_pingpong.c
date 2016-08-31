#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include <unistd.h>

#include <mpi.h>

#if __WORDSIZE == 64 // getcpu(2) is implemented as a vsyscall on x86_64
	#include <asm/vsyscall.h>

	typedef int (*getcpu_t)(unsigned *cpu, unsigned *node, void *reserved);

	int getcpu(unsigned *cpu, unsigned *node, void *reserved) {
		getcpu_t __getcpu = (getcpu_t) VSYSCALL_ADDR(__NR_vgetcpu);

		return __getcpu(cpu, node, reserved);
	}
#else // on x86 it's a real syscall
	#include <sys/syscall.h>

	int getcpu(unsigned *cpu, unsigned *node, void *reserved) {
		return syscall(SYS_getcpu, cpu, node, reserved);
	}
#endif

#define MSG_SIZE 512
#define HOSTNAME_LEN 256

static int rank, size;

static inline double pingpong_test(int src, int dest, int iterations, int size) {
	uint8_t buf[size];

	MPI_Request send_req, recv_req;
	MPI_Status status;
	
#ifdef MPI_PERSISTENT
	if (rank == src) {
		MPI_Send_init(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &send_req);
		MPI_Recv_init(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &recv_req);
	} else {
		MPI_Send_init(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &send_req);
		MPI_Recv_init(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &recv_req);
	}

	// warming up
	int warm_up = 10;
	while (warm_up--) {
		if (rank == src) {
			MPI_Start(&recv_req);
			MPI_Start(&send_req);
			MPI_Wait(&send_req, &status);
			MPI_Wait(&recv_req, &status);
		} else {
			MPI_Start(&recv_req);
			MPI_Wait(&recv_req, &status);
			MPI_Start(&send_req);
			MPI_Wait(&send_req, &status);
		}
	}
#else
	// warming up
	int warm_up = 10;
	while (warm_up--) {
		if (rank == src) {
			MPI_Irecv(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &recv_req);
			MPI_Isend(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &send_req);
			MPI_Wait(&send_req, &status);
			MPI_Wait(&recv_req, &status);
		} else {
			MPI_Irecv(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &recv_req);
			MPI_Wait(&recv_req, &status);
			MPI_Isend(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &send_req);
			MPI_Wait(&send_req, &status);
		}
	}
#endif

	double start = MPI_Wtime();

	int run = iterations;

	while (run--) {
#ifdef MPI_PERSISTENT
		if (rank == src) {
			MPI_Start(&recv_req);
			MPI_Start(&send_req);
			MPI_Wait(&send_req, &status);
			MPI_Wait(&recv_req, &status);
		} else {
			MPI_Start(&recv_req);
			MPI_Wait(&recv_req, &status);
			MPI_Start(&send_req);
			MPI_Wait(&send_req, &status);
		}
#else
		if (rank == src) {
			MPI_Irecv(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &recv_req);
			MPI_Isend(buf, size, MPI_BYTE, dest, 0, MPI_COMM_WORLD, &send_req);
			MPI_Wait(&send_req, &status);
			MPI_Wait(&recv_req, &status);
		} else {
			MPI_Irecv(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &recv_req);
			MPI_Wait(&recv_req, &status);
			MPI_Isend(buf, size, MPI_BYTE, src, 0, MPI_COMM_WORLD, &send_req);
			MPI_Wait(&send_req, &status);
		}
#endif
	}

	double end = MPI_Wtime();

#ifdef MPI_PERSISTENT
	MPI_Request_free(&send_req);
	MPI_Request_free(&recv_req);
#endif

	return (end - start) / iterations * 1e6 / 2;
}

int main(int argc, char **argv) {
	if (argc < 3) {
		fprintf(stderr, "Usage: %s <number of iterations> <size of message in bytes>\n", argv[0]);
		return -1;
	}
	MPI_Init(&argc, &argv);

	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	char hostname[HOSTNAME_LEN];
	gethostname(hostname, HOSTNAME_LEN);

	char hostnames[size][HOSTNAME_LEN];
	MPI_Allgather(hostname, HOSTNAME_LEN, MPI_CHAR, hostnames, HOSTNAME_LEN, MPI_CHAR, MPI_COMM_WORLD);

	unsigned int cpu, node;

	// here we refer to a physical chip as a "CPU",
	// the getcpu call refers to each core as a "CPU" and each chip as a NUMA "node"
	if (getcpu(&cpu, &node, NULL) < 0) {
		perror("getcpu: ");
		return -1;
	}

	int cpus[size];
	MPI_Allgather(&node, 1, MPI_INT, cpus, 1, MPI_INT, MPI_COMM_WORLD);

	MPI_Barrier(MPI_COMM_WORLD);

	int iterations = atoi(argv[1]);
	int msg_size = atoi(argv[2]);
	bool concurrent = atoi(argv[3]);

	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			if (rank == i || rank == j) {
				double delay = pingpong_test(i, j, iterations, msg_size);
				if (rank == i) {
					printf("%d,%d,%d,%s,%s,%s.%d,%s.%d,%f\n", msg_size, i, j, hostnames[i], hostnames[j],
														   hostnames[i], cpus[i],
														   hostnames[j], cpus[j],
														   delay);
					fflush(stdout);
				}
			}

			if (!concurrent) {
				MPI_Barrier(MPI_COMM_WORLD);
			}
		}
	}

	MPI_Finalize();
}

