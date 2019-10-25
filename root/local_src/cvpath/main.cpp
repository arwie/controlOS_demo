#include <iostream>
#include "opencv2/opencv.hpp"

using namespace std;
using namespace cv;

int main(int argc, char** argv)
{
	cout << "cvpath" << endl;
	
	VideoCapture cap("/dev/video0");
	
	if(!cap.isOpened()) {
		cout << "error: cannot open camera" << endl;
		return 1;
	}

	Mat frame;
	cap >> frame;
	if(frame.empty()) {
		cout << "error: cannot read frame" << endl;
		return 2;
	}
	
	imwrite("/tmp/cvpath.webp", frame);

	return 0;
}
