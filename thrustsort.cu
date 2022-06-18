#include <stdio.h>
#include <sys/time.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sort.h>

#define M_SIZE 10000000

int main(int argc, char const *argv[]) {
	thrust::host_vector<int> A(M_SIZE);
	thrust::generate(A.begin(), A.end(), rand);
	thrust::device_vector<int> B = A;

	struct timeval start_1, end_1;
	gettimeofday(&start_1, NULL);
	thrust::sort(A.begin(), A.end());
	gettimeofday(&end_1, NULL);
	int timeuse = 1000000 * (end_1.tv_sec - start_1.tv_sec) + end_1.tv_usec - start_1.tv_usec;

	struct timeval start_2, end_2;
	gettimeofday(&start_2, NULL);
	thrust::sort(B.begin(), B.end());
	gettimeofday(&end_2, NULL);
	int timeuse_2 = 1000000 * (end_2.tv_sec - start_2.tv_sec) + end_2.tv_usec - start_2.tv_usec;

	printf("host Time consume = %lfms\n", (double)timeuse / 1000000);
	printf("device Time consume = %lfms\n", (double)timeuse_2 / 1000000);
	return 0;
}