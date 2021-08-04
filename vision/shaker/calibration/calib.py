import numpy as np
import cv2 as cv
import glob, json, sys


def show(img, time=0):
	cv.namedWindow('image', cv.WINDOW_NORMAL)
	cv.resizeWindow('image', 900,900)
	cv.imshow('image', img)
	cv.waitKey(time)


def calibrateHomography(img):
	points = np.mgrid[0:16, 0:11].T.reshape(-1, 2) * 100 + [100, 100]
	
	gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
	ret,corners = cv.findChessboardCorners(gray, (16,11))
	corners = cv.cornerSubPix(gray, corners, (10,10), (-1,-1), (cv.TERM_CRITERIA_EPS+cv.TERM_CRITERIA_COUNT, 30, 0.01))
	#corners = corners[::-1]
	
	homography,status = cv.findHomography(corners, points)
	
	cv.drawChessboardCorners(img, (16,11), corners, ret)
	show(img)
	
	return homography


# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((12*13,3), np.float32)
objp[:,:2] = np.mgrid[0:13,0:12].T.reshape(-1,2)

# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.

images = glob.glob('Image_*.png')
for fname in images:
	img = cv.imread(fname)
	
	gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
	#show(img, 500)
	
	ret, corners = cv.findChessboardCorners(gray, (13,12), None)
	if ret:
		objpoints.append(objp)
		corners = cv.cornerSubPix(gray, corners, (11,11), (-1,-1), (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 30, 0.001))
		imgpoints.append(corners)
		
		cv.drawChessboardCorners(img, (13,12), corners, ret)
		show(img, 100)
	else:
		print("rejected: "+fname)

cv.destroyAllWindows() 


ret, mtx, dist, rvecs, tvecs = cv.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)



img = cv.imread('calib.png')

h,w = img.shape[:2]
print(h,w)
newcameramtx, roi = cv.getOptimalNewCameraMatrix(mtx, dist, (w,h), 1, (w,h))
print(newcameramtx)
img = cv.undistort(img, mtx, dist, None, newcameramtx)
show(img)
cv.imwrite('results/undistort.png', img)

hom = calibrateHomography(img)
img = cv.warpPerspective(img, hom, (1900,1250))
show(img)
cv.imwrite('results/warpPerspective.png', img)



img = cv.imread('test.png')
img = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
h,w = img.shape[:2]
newcameramtx, roi = cv.getOptimalNewCameraMatrix(mtx, dist, (w,h), 1, (w,h))
img = cv.undistort(img, mtx, dist, None, newcameramtx)
img = cv.warpPerspective(img, hom, (1900,1250))
show(img)
cv.imwrite('results/test.png', img)



json.dump({
	'm':	mtx.tolist(),
	'd':	dist.tolist(),
	'h':	hom.tolist(),
}, sys.stdout)
print()

#{"m": [[3234.353607049094, 0.0, 611.797303174998], [0.0, 3228.3250731952035, 444.8457414925399], [0.0, 0.0, 1.0]], "d": [[-0.396674204429899, -0.1236262457444551, 0.0021836229802438237, 0.0014893041223838412, -17.27379626830661]], "h": [[1.547217951783606, 0.0220367282693701, -51.33825262123481], [-0.018098092535880534, 1.5494509890559192, -121.89146858373576], [5.76343017816441e-06, 2.077412533814354e-06, 1.0]]}
