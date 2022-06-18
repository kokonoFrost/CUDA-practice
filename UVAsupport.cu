#include <stdio.h>
int main(int argc, char const *argv[]) {
	int deviceCount;
	cudaGetDeviceCount(&deviceCount);
	int device;
	for (device = 0; device < deviceCount; ++device) {
		cudaDeviceProp deviceProp;
		cudaGetDeviceProperties(&deviceProp, device);
		printf("Device %d has compute capability %d.%d,unifiedAddressing = %d\n",
		       device, deviceProp.major, deviceProp.minor, deviceProp.unifiedAddressing);
	}
}