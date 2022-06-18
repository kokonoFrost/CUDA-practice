#include <sys/time.h>
#include <stdio.h>
#include <math.h>
#define rowx 1000
#define colx 800
#define rowy 800
#define coly 600
#define blocks 32

void matrix_multi_cpu(int *a, int *b, int *c) {
	for (int x = 0; x < rowx; x++) {
		for (int y = 0; y < coly; y++) {
			int s = 0;
			for (int i = 0; i < colx; i++) {
				s += a[x * colx + i] * b[i * coly + y];
			}
			c[x * coly + y] = s;
		}
	}
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
    matrix_multi_cpu(A, B, C);
    cudaFree(A);
	cudaFree(B);
	cudaFree(C);
	return 0;
}