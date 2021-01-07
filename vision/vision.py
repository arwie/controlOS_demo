#!/usr/bin/python -Bu

import numpy as np
import cv2 as cv
import time



cap = cv.VideoCapture('/dev/video0', cv.CAP_V4L2)

cap.set(cv.CAP_PROP_BUFFERSIZE, 1)
cap.set(cv.CAP_PROP_FOURCC, cv.VideoWriter_fourcc('Y','U','Y','V'))
cap.set(cv.CAP_PROP_CONVERT_RGB, 0)
cap.set(cv.CAP_PROP_FORMAT, -1)
cap.set(cv.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv.CAP_PROP_FRAME_HEIGHT, 960)
cap.set(cv.CAP_PROP_SHARPNESS, 0)
cap.set(cv.CAP_PROP_AUTOFOCUS, 0)
cap.set(cv.CAP_PROP_FOCUS, 60)
cap.set(cv.CAP_PROP_AUTO_EXPOSURE, 1)
cap.set(cv.CAP_PROP_EXPOSURE, 3)

print("ready to capture")



homography = np.array([[-2.77567915e+00, -1.00764105e-01, 2.69350242e+03],[1.03750041e-02, -2.88806990e+00, 1.89610723e+03],[7.45911550e-06, -1.08313725e-04, 1.00000000e+00]])

def robotPoint(imageX, imageY):
	return (-imageY/10+85-50, imageX/10-90)



def getRaw():
	cap.grab()	#clear buffer
	ret,frame = cap.read()
	return cv.cvtColor(frame, cv.COLOR_YUV2GRAY_YUYV)

def getImage():
	img = getRaw()
	return cv.warpPerspective(img, homography, (1800,1800))


def show(img):
	cv.namedWindow('image', cv.WINDOW_NORMAL)
	cv.resizeWindow('image', 900,900)
	cv.imshow('image', img)
	cv.waitKey(0)


def calibrateHomography():
	points = np.mgrid[0:7, 0:5].T.reshape(-1, 2) * 200 + [900-3*200, 850-2*200]
	
	gray = getRaw()
	
	ret,corners = cv.findChessboardCorners(gray, (7,5))
	corners = cv.cornerSubPix(gray, corners, (10,10), (-1,-1), (cv.TERM_CRITERIA_EPS+cv.TERM_CRITERIA_COUNT, 30, 0.01))
	
	homography,status = cv.findHomography(corners, points)
	
	cv.drawChessboardCorners(gray, (7,5), corners, ret)
	show(gray)
	img = cv.warpPerspective(gray, homography, (1800,1800))
	show(img)
	
	return homography


def findObjects():
	gray = getImage()
	
	img = cv.GaussianBlur(gray, (25, 25), 0)
	ret,img = cv.threshold(img, 0, 255, cv.THRESH_BINARY_INV+cv.THRESH_OTSU)
	
	contours,h = cv.findContours(img, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
	
	for c in contours:
		(x,y),r	= cv.minEnclosingCircle(c)
		a		= cv.contourArea(c)
		print(robotPoint(x, y), r, a)
		
		cv.circle(gray, (int(x), int(y)), 7, (255, 255, 255), -1)


	cv.drawContours(gray, contours, -1, (0, 255, 0), 2)
	show(gray)



#show(getRaw())
#print(calibrateHomography())
#show(getImage())
findObjects()

cap.release()
cv.destroyAllWindows()
