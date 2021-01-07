import numpy as np
import cv2 as cv
import glob, json, sys


def show(img, time=0):
	cv.namedWindow('image', cv.WINDOW_NORMAL)
	cv.resizeWindow('image', 900,900)
	cv.imshow('image', img)
	cv.waitKey(time)


def calibrateHomography(img):
	points = np.mgrid[0:13, 0:9].T.reshape(-1, 2) * 100 + [100, 100]
	
	gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
	ret,corners = cv.findChessboardCorners(gray, (13,9))
	corners = cv.cornerSubPix(gray, corners, (10,10), (-1,-1), (cv.TERM_CRITERIA_EPS+cv.TERM_CRITERIA_COUNT, 30, 0.01))
	corners = corners[::-1]
	
	homography,status = cv.findHomography(corners, points)
	
	#cv.drawChessboardCorners(img, (13,9), corners, ret)
	#show(img)
	
	return homography


# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((7*8,3), np.float32)
objp[:,:2] = np.mgrid[0:8,0:7].T.reshape(-1,2)

# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.

images = glob.glob('Image_*.png')
for fname in images:
	img = cv.imread(fname)
	
	gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
	#show(img, 500)
	
	ret, corners = cv.findChessboardCorners(gray, (8,7), None)
	if ret:
		objpoints.append(objp)
		corners = cv.cornerSubPix(gray, corners, (11,11), (-1,-1), (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 30, 0.001))
		imgpoints.append(corners)
		
		cv.drawChessboardCorners(img, (8,7), corners, ret)
		show(img, 100)
	else:
		print("rejected: "+fname)

cv.destroyAllWindows() 


ret, mtx, dist, rvecs, tvecs = cv.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)



img = cv.imread('trigger.png')

h,w = img.shape[:2]
print(h,w)
newcameramtx, roi = cv.getOptimalNewCameraMatrix(mtx, dist, (w,h), 1, (w,h))
print(newcameramtx)
img = cv.undistort(img, mtx, dist, None, newcameramtx)
show(img)

h = calibrateHomography(img)
img = cv.warpPerspective(img, h, (1400,1000))
show(img)



json.dump({
	'm':	mtx.tolist(),
	'd':	dist.tolist(),
	'h':	h.tolist(),
}, sys.stdout)
print()


#{"m": [[4426.628456070167, 0.0, 586.286817678153], [0.0, 4441.817619859583, 450.23923705670006], [0.0, 0.0, 1.0]], "d": [[0.6816792488504552, 13.163809587701673, -0.0030967100410058254, -0.009383985136120576, -278.2028681797848]], "h": [[-1.134127831694609, -0.0022365285204225633, 1424.0015425889146], [0.005937869210278502, -1.1433504013529034, 1050.2621853650708], [6.476014545996702e-06, 1.0637922360192212e-06, 1.0]]}
