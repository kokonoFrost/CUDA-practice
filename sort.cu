#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <stdlib.h>

void bsort(int *A, const int len) {
	for (int i = 0; i < len; i++)
		for (int j = 0; j < len - i - 1; j++)
			if (A[j] > A[j + 1]) {
				int temp = A[j];
				A[j] = A[j + 1];
				A[j + 1] = temp;
			}
}

__global__ void oddsort(int *A, const int len) {
	int tid = threadIdx.x;
	__shared__ int tag1;
	__shared__ int tag2;
	tag1 = 1; tag2 = 1;
	while (tag1 || tag2) {
		tag1 = 0; tag2 = 0;
		if ((2 * tid + 1) < len) {
			if (A[2 * tid] > A[2 * tid + 1]) {
				int temp = A[2 * tid];
				A[2 * tid] = A[2 * tid + 1];
				A[2 * tid + 1] = temp;
				tag1 = 1;
			}
		}
		__syncthreads();
		if ((2 * tid + 2) < len) {
			if (A[2 * tid + 1] > A[2 * tid + 2]) {
				int temp = A[2 * tid + 1];
				A[2 * tid + 1] = A[2 * tid + 2];
				A[2 * tid + 2] = temp;
				tag2 = 1;
			}
		}
		__syncthreads();
	}

}

int main(int argc, char const *argv[]) {
	srand((unsigned)time(NULL));
	if (argc < 2) {
		printf("INPUT ERROR\n");
		return 0;
	}
	int n = atoi(argv[1]);
	int *A, *B;
	B = (int *)malloc(sizeof(int) * n);
	cudaMallocManaged(&A, sizeof(int) * n);
	for (int i = 0; i < n; i++) {
		A[i] = rand() % 100;
		B[i] = A[i];
	}
	struct timeval start1, end1;
	gettimeofday(&start1, NULL);
	bsort(B, n);
	gettimeofday(&end1, NULL);
	struct timeval start2, end2;
	gettimeofday(&start2, NULL);
	oddsort <<< 1, n / 2 >>> (A, n);
	cudaDeviceSynchronize();
	gettimeofday(&end2, NULL);
	int timeuse1 = 1000000 * (end1.tv_sec - start1.tv_sec) + end1.tv_usec - start1.tv_usec;
	int timeuse2 = 1000000 * (end2.tv_sec - start2.tv_sec) + end2.tv_usec - start2.tv_usec;
	for (int i = 0; i < n; i++)
		if (A[i] != B[i]) {
			printf("SORT ERROR\n");
			break;
		}
	printf("CPU程序运行时间为%lfs\n", (double)timeuse1 / 1000000);
	printf("GPU程序运行时间为%lfs\n", (double)timeuse2 / 1000000);
	cudaFree(A);
	free(B);
	return 0;
}