//Sharpening Filter
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/highgui.hpp>
#include <iostream>
#include <string>
#include <stdio.h>
#include <windows.h>

int MAX_KERNEL_LENGTH = 9;     

using namespace std;
using namespace cv;
LARGE_INTEGER t1, t2, frequency;

extern "C" void sharpeningFilter_CPU(const cv::Mat & input, cv::Mat & output)
{
    Point anchor = Point(-1, -1);
    double delta = 0;
    int ddepth = -1;
    int kernel_size;

    QueryPerformanceFrequency(&frequency);
    QueryPerformanceCounter(&t1);

    kernel_size = 3;

    cv::Mat kernel = (Mat_<double>(kernel_size, kernel_size) << -1, -1, -1, -1, 9, -1, -1, -1, -1);

    filter2D(input, output, ddepth, kernel, anchor, delta, BORDER_DEFAULT);

    output.convertTo(output, CV_32F, 1.0 / 255, 0);
    output *= 255;

    QueryPerformanceCounter(&t2);

    double secs = static_cast<double>(t2.QuadPart - t1.QuadPart) / frequency.QuadPart;

    cout << "\nProcessing time on CPU (ms): " << secs * 1000 << "\n";

}














