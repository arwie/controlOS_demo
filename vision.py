#!/usr/bin/python -Bu

import numpy as np
import cv2 as cv
import time



cap = cv.VideoCapture('/dev/video0', cv.CAP_V4L2)

cap.set(cv.CAP_PROP_FOURCC, cv.VideoWriter_fourcc('Y','U','Y','V'))
cap.set(cv.CAP_PROP_CONVERT_RGB, 0)
cap.set(cv.CAP_PROP_FORMAT, -1)
cap.set(cv.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv.CAP_PROP_FRAME_HEIGHT, 960)
cap.set(cv.CAP_PROP_SHARPNESS, 0)
cap.set(cv.CAP_PROP_AUTOFOCUS, 0)
cap.set(cv.CAP_PROP_FOCUS, 0)
cap.set(cv.CAP_PROP_AUTO_EXPOSURE, 1)
cap.set(cv.CAP_PROP_EXPOSURE, 30)




def getRaw():
	ret,frame = cap.read()
	return cv.cvtColor(frame, cv.COLOR_YUV2GRAY_YUYV)

def getImage():
	homography = np.array([[2.83307306e+00, -1.55534698e-01, -3.19332024e+02],[6.07683410e-03, 2.73114832e+00, -9.71618468e+01],[5.79265182e-06, -1.04055238e-04, 1.00000000e+00]])
	img = getRaw()
	return cv.warpPerspective(img, homography, (3000,2000))


def show(img):
	cv.namedWindow('image', cv.WINDOW_NORMAL)
	cv.resizeWindow('image', 900,900)
	cv.imshow('image', img)
	cv.waitKey(0)



def calibrateHomography():
	points = np.mgrid[0:9, 0:7].T.reshape(-1, 2) * 200 + [1500-4*200, 1000-3*200]
	
	gray = getRaw()
	
	ret,corners = cv.findChessboardCorners(gray, (9,7))
	corners = cv.cornerSubPix(gray, corners, (10,10), (-1,-1), (cv.TERM_CRITERIA_EPS+cv.TERM_CRITERIA_COUNT, 30, 0.01))
	
	homography,status = cv.findHomography(corners, points)
	
	cv.drawChessboardCorners(gray, (9,7), corners, ret)
	show(gray)
	img = cv.warpPerspective(gray, homography, (3000,2000))
	show(img)
	
	return homography


def robotPoint(imageX, imageY):
	return (+imageY/10-100-50, -imageX/10+150)



def findObjects():
	gray = getImage()
	
	img = cv.GaussianBlur(gray, (25, 25), 0)
	ret,img = cv.threshold(img, 0, 255, cv.THRESH_BINARY+cv.THRESH_OTSU)
	
	contours,h = cv.findContours(img, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
	
	for c in contours:
		M = cv.moments(c)
		cX = int(M["m10"] / M["m00"])
		cY = int(M["m01"] / M["m00"])
		print(robotPoint(cX, cY))
		
		cv.circle(gray, (cX, cY), 7, (255, 255, 255), -1)


	cv.drawContours(gray, contours, -1, (0, 255, 0), 2)
	show(gray)



#print(calibrateHomography())
#show(getImage())
findObjects()

cap.release()
cv.destroyAllWindows()
