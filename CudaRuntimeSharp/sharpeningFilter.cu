//Sharpening Filter
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/highgui.hpp>
#include <iostream>
#include <string>
#include <stdio.h>
#include <cuda.h>
#include "cuda_runtime.h"
#include <device_launch_parameters.h>

#define BLOCK_SIZE      16 //MAX 1024
#define FILTER_WIDTH    3       
#define FILTER_HEIGHT   3       

using namespace std;

__global__ void sharpeningFilter(unsigned char* srcImage, unsigned char* dstImage, unsigned int width, unsigned int height, int channel)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    float kernel[FILTER_WIDTH][FILTER_HEIGHT] = { -1, -1, -1, -1, 9, -1, -1, -1, -1 };
    if ((x >= FILTER_WIDTH / 2) && (x < (width - FILTER_WIDTH / 2)) && (y >= FILTER_HEIGHT / 2) && (y < (height - FILTER_HEIGHT / 2)))
    {
        for (int c = 0; c < channel; c++)
        {
            float sum = 0;
            for (int ky = -FILTER_HEIGHT / 2; ky <= FILTER_HEIGHT / 2; ky++) {
                for (int kx = -FILTER_WIDTH / 2; kx <= FILTER_WIDTH / 2; kx++) {
                    float fl = srcImage[((y + ky) * width + (x + kx)) * channel + c];
                    sum += fl * kernel[ky + FILTER_HEIGHT / 2][kx + FILTER_WIDTH / 2];
                }
            }
            sum = fmin(255.0f, fmax(0.0f, sum));
            dstImage[(y * width + x) * channel + c] = sum;
        }
    }
}


extern "C" void sharpeningFilter_GPU_wrapper(const cv::Mat& input, cv::Mat& output)
{
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        int channel = input.step/input.cols; 

        const int inputSize = input.cols * input.rows * channel;
        const int outputSize = output.cols * output.rows * channel;
        unsigned char *d_input, *d_output;
        
        cudaMalloc<unsigned char>(&d_input,inputSize);
        cudaMalloc<unsigned char>(&d_output,outputSize);

        cudaMemcpy(d_input,input.ptr(),inputSize,cudaMemcpyHostToDevice);

        const dim3 block(BLOCK_SIZE,BLOCK_SIZE);

        const dim3 grid((output.cols + block.x - 1)/block.x, (output.rows + block.y - 1)/block.y);

        cudaEventRecord(start);

        sharpeningFilter<<<grid,block>>>(d_input, d_output, output.cols, output.rows, channel);

        cudaEventRecord(stop);

        cudaMemcpy(output.ptr(),d_output,outputSize,cudaMemcpyDeviceToHost);

        cudaFree(d_input);
        cudaFree(d_output);

        cudaEventSynchronize(stop);
        float milliseconds = 0;
        
        cudaEventElapsedTime(&milliseconds, start, stop);
        cout<< "\nProcessing time on GPU (ms): " << milliseconds << "\n";
}













