//SOBEL
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/highgui.hpp>
#include <iostream>
#include <string>

using namespace std;

extern "C" bool sobelFilter_GPU_wrapper(const cv::Mat & input, cv::Mat & output);
extern "C" bool sobelFilter_CPU(const cv::Mat & input, cv::Mat & output);

int main(int argc, char** argv) {
    string image_name = "sample";

    string input_file = image_name + ".jpg";
    string output_file_cpu = image_name + "_cpu.jpg";
    string output_file_gpu = image_name + "_gpu.jpg";

    cv::Mat srcImage = cv::imread(input_file, cv::IMREAD_UNCHANGED);
    if (srcImage.empty()) {
        std::cout << "Image Not Found: " << input_file << std::endl;
        return -1;
    }

    cout << "\ninput image size (cols:rows:channels): " << srcImage.cols << " " << srcImage.rows << " " << srcImage.channels() << "\n";

    cv::cvtColor(srcImage, srcImage, cv::COLOR_BGR2GRAY);

    cv::Mat dstImage(srcImage.size(), srcImage.type());

    sobelFilter_GPU_wrapper(srcImage, dstImage);

    dstImage.convertTo(dstImage, CV_32F, 1.0 / 255, 0);
    dstImage *= 255;

    imwrite(output_file_gpu, dstImage);

    sobelFilter_CPU(srcImage, dstImage);

    imwrite(output_file_cpu, dstImage);

    return 0;
}
