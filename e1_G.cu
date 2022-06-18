//矩阵大小为2048*2048，运行时间为0.033265s
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <sys/time.h>
#include <stdio.h>
#include <math.h>
#define Max_array 2048

__global__ void matrix_multi_gpu(int *M, int *N, int *P, int width) {
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	int sum = 0;
	for (int k = 0; k < width; k++) {
		int a = M[j * width + k];
		int b = N[k * width + i];
		sum += a * b;
	}
	P[j * width + i] = sum;
}

int main() {
	struct timeval start, end;
	int *A = (int *)malloc(sizeof(int) * Max_array * Max_array);
	int *B = (int *)malloc(sizeof(int) * Max_array * Max_array);
	int *C = (int *)malloc(sizeof(int) * Max_array * Max_array);
	int *d_dataA, *d_dataB, *d_dataC;
	cudaMalloc((void **)&d_dataA, sizeof(int)*Max_array * Max_array);
	cudaMalloc((void **)&d_dataB, sizeof(int)*Max_array * Max_array);
	cudaMalloc((void **)&d_dataC, sizeof(int)*Max_array * Max_array);
	srand((unsigned)time(NULL));
	for (int i = 0; i < Max_array * Max_array; i++) {
		A[i] = rand() % 100;
		B[i] = rand() % 100;
	}
	gettimeofday(&start, NULL);
	cudaMemcpy(d_dataA, A, sizeof(int)*Max_array * Max_array, cudaMemcpyHostToDevice);
	cudaMemcpy(d_dataB, B, sizeof(int)*Max_array * Max_array, cudaMemcpyHostToDevice);
	dim3 threadPerBlock(32, 32);
	dim3 blockNumber((Max_array + threadPerBlock.x - 1) / threadPerBlock.x, (Max_array + threadPerBlock.y - 1) / threadPerBlock.y);
	matrix_multi_gpu << <blockNumber, threadPerBlock >> >(d_dataA, d_dataB, d_dataC, Max_array);
	cudaMemcpy(C, d_dataC, sizeof(int) *Max_array * Max_array, cudaMemcpyDeviceToHost);
	gettimeofday(&end, NULL);
	printf("matrixA = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", A[i * j + j]);
		printf("\n");
	}
	printf("matrixB = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", B[i * j + j]);
		printf("\n");
	}
	printf("matrixC = matrixA * matrixB = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", C[i * j + j]);
		printf("\n");
	}
	free(A);
	free(B);
	free(C);
	cudaFree(d_dataA);
	cudaFree(d_dataB);
	cudaFree(d_dataC);
	int timeuse = 1000000 * (end.tv_sec - start.tv_sec) + end.tv_usec - start.tv_usec;
	printf("运行时间为%lfs\n", (double)timeuse / (double)1000000);
	return 0;
}