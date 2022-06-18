//矩阵大小为2048*2048，运行时间为29.895698s
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define Max_array 2048

int main() {
	int *a = (int *)malloc(sizeof(int) * Max_array * Max_array);
	int *b = (int *)malloc(sizeof(int) * Max_array * Max_array);
	int *c = (int *)malloc(sizeof(int) * Max_array * Max_array);
	//矩阵赋随机数初值
	srand((unsigned)time(NULL));
	for (int i = 0; i < Max_array * Max_array; i++) {
		a[i] = rand() % 100;
		b[i] = rand() % 100;
		c[i] = 0;
	}
	clock_t start = clock(), duration;
	int r;
	for (int i = 0; i < Max_array; i++)
		for (int k = 0; k < Max_array; k++) {
			r = a[i * k + k];
			for (int j = 0; j < Max_array; j++)
				c[i * j + j] += r * b[k * j + j];
		}
	duration = clock() - start;
	printf("matrixA = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", a[i * j + j]);
		printf("\n");
	}
	printf("matrixB = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", b[i * j + j]);
		printf("\n");
	}
	printf("matrixC = matrixA * matrixB = \n");
	for (int i = 0; i < Max_array; i++) {
		for (int j = 0; j < Max_array; j++)
			printf("%d ", c[i * j + j]);
		printf("\n");
	}
	printf("运行时间为%lfs\n", (double)duration / CLOCKS_PER_SEC);
	return 0;
}