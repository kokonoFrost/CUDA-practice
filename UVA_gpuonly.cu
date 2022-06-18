#include <sys/time.h>
#include <stdio.h>
#include <math.h>
#define rowx 1000
#define colx 800
#define rowy 800
#define coly 600
#define blocks 32

__global__ void matrix_multi_gpu(int *M, int *N, int *P) {
	__shared__ int shareA[blocks][blocks];
	__shared__ int shareB[blocks][blocks];
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	int maxx = ceil((double)colx / blocks);
	int sum = 0;
	for (int step = 0; step < maxx; step++) {
		if (i < rowx && (threadIdx.y + blockDim.y * step) < colx)
			shareA[threadIdx.x][threadIdx.y] = M[i * colx + (threadIdx.y + blockDim.y * step)];
		else
			shareA[threadIdx.x][threadIdx.y] = 0;
		if ((threadIdx.x + blockDim.y * step) < rowy && j < coly)
			shareB[threadIdx.y][threadIdx.x] = N[(threadIdx.x + blockDim.y * step) * coly + j];
		else
			shareB[threadIdx.y][threadIdx.x] = 0;
		__syncthreads();
		for (int k = 0; k < blocks; k++)
			sum += shareA[threadIdx.x][k] * shareB[threadIdx.y][k];
		__syncthreads();
	}
	if (i < rowx && j < coly)
		P[i * coly + j] = sum;
}
int main(int argc, char const *argv[]) {
	int *A, *B, *C;
	cudaMallocManaged(&A, sizeof(int) * rowx * colx);
	cudaMallocManaged(&B, sizeof(int) * rowy * coly);
    cudaMallocManaged(&C, sizeof(int) * rowx * coly);
    srand((unsigned)time(NULL));
	for (int i = 0; i < rowx * colx; i++)
		A[i] = rand() % 100 + 1;
	for (int i = 0; i < rowy * coly; i++)
		B[i] = rand() % 100 + 1;
	dim3 block_size(blocks, blocks);
	int maxr = rowx > rowy ? rowx : rowy, maxc = colx > coly ? colx : coly;
	int gridx = ceil((double)maxr / block_size.x), gridy = ceil((double)maxc / block_size.y);
	dim3 grid_size(gridx, gridy);
	matrix_multi_gpu <<< grid_size, block_size >>> (A, B, C);
	cudaDeviceSynchronize();
	cudaFree(A);
	cudaFree(B);
	cudaFree(C);
	return 0;
}