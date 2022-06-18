#include "device_launch_parameters.h"
#include <stdio.h>

int main() {
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    for (int i = 0; i < deviceCount; i++) {
        cudaDeviceProp dveProp;
        cudaGetDeviceProperties(&dveProp, i);
        printf("显卡设备%d:%s\n", i, dveProp.name);
        printf("全局内存总量:%lfMB\n", dveProp.totalGlobalMem / 1024.0f / 1024.0f);
        printf("SM数量:%d\n", dveProp.multiProcessorCount);
        printf("每个线程块的共享内存大小:%lfKB\n", dveProp.sharedMemPerBlock / 1024.0f);
        printf("每个线程块的最大线程数:%d\n", dveProp.maxThreadsPerBlock);
        printf("设备上一个线程块可用的32位寄存器数量:%d\n", dveProp.regsPerBlock);
        printf("每个EM的最大线程数:%d\n", dveProp.maxThreadsPerMultiProcessor);
        printf("每个Em的最大线程束数:%d\n", dveProp.maxThreadsPerMultiProcessor / 32);
        printf("设备上多处理器的数量:%d\n", dveProp.multiProcessorCount);
        printf("==================================================================\n");
    }
    return 0;
}