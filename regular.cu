#include <stdio.h>
#include <sys/time.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#define M_SIZE 10000000
#define threadnum 1024
const int blocknum = (M_SIZE + threadnum - 1) / threadnum;

__global__ void reduce(int *g_idata, int *g_odata) {
	unsigned int i = threadIdx.x + blockDim.x * blockIdx.x;
	unsigned int tid = threadIdx.x;
	__shared__ int C[threadnum];
	C[tid] = g_idata[i];
	__syncthreads();
	for (int j = blockDim.x / 2; j > 0; j /= 2) {
		if (tid < j) {
			C[tid] += C[tid + j];
		}
		__syncthreads();
	}
	if (tid == 0) {
		g_odata[blockIdx.x] = C[0];
	}
}

int main(int argc, char const *argv[]) {
	int *A = (int *)malloc(sizeof(int) * M_SIZE);
	int *B = (int *)malloc(sizeof(int) * blocknum);
	thrust::host_vector<int> A1(M_SIZE);
	int *d_dataA, *d_dataB;
	cudaMalloc((void **)&d_dataA, sizeof(int) * M_SIZE);
	cudaMalloc((void **)&d_dataB, sizeof(int) * blocknum);
	srand((unsigned)time(NULL));
	for (int i = 0; i < M_SIZE; i++) {
		A[i] = rand() % 100;
		A1[i] = A[i];
	}
	struct timeval start_1, end_1;
	gettimeofday(&start_1, NULL);
	cudaMemcpy(d_dataA, A, sizeof(int) * M_SIZE, cudaMemcpyHostToDevice);
	reduce <<< blocknum, threadnum >>>(d_dataA, d_dataB);
	cudaMemcpy(B, d_dataB, sizeof(int) * blocknum, cudaMemcpyDeviceToHost);
	int sum = 0;
	for (int i = 0; i < blocknum; i++) {
		sum += B[i];
	}
	printf("sum = %d\n", sum);
	gettimeofday(&end_1, NULL);
	int timeuse = 1000000 * (end_1.tv_sec - start_1.tv_sec) + end_1.tv_usec - start_1.tv_usec;


	struct timeval start_2, end_2;
	gettimeofday(&start_2, NULL);
	thrust::device_vector<int> D = A1;
	int thrustsum = thrust::reduce(D.begin(), D.end(), (int) 0, thrust::plus<int>());
	printf("thrustsum = %d\n", thrustsum);
	gettimeofday(&end_2, NULL);
	int timeuse_2 = 1000000 * (end_2.tv_sec - start_2.tv_sec) + end_2.tv_usec - start_2.tv_usec;


	printf("Time consume = %lfms\n", (double)timeuse / 1000000);
	printf("thrust::reduce Time consume = %lfms\n", (double)timeuse_2 / 1000000);
	cudaFree(d_dataA);
	cudaFree(d_dataB);
	free(A);
	free(B);
	return 0;
}