import server, asyncio
import numpy as np
import cv2 as cv


def scan():
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
	cap.set(cv.CAP_PROP_EXPOSURE, 60)
	ret,img = cap.read()
	cap.release()
	
	homography = np.array([[2.83307306e+00, -1.55534698e-01, -3.19332024e+02],[6.07683410e-03, 2.73114832e+00, -9.71618468e+01],[5.79265182e-06, -1.04055238e-04, 1.00000000e+00]])
	img = cv.cvtColor(img, cv.COLOR_YUV2GRAY_YUYV)
	img = cv.warpPerspective(img, homography, (3000,2000))
	
	scan = cv.GaussianBlur(img, (25, 25), 0)
	ret,scan = cv.threshold(scan, 0, 255, cv.THRESH_BINARY+cv.THRESH_OTSU)
	contours,h = cv.findContours(scan, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
	
	objects = []
	for c in contours:
		M = cv.moments(c)
		cX = int(M["m10"] / M["m00"])
		cY = int(M["m01"] / M["m00"])
		objects.append({'x':+cY/10-100-50, 'y':-cX/10+150, 'z':0, 'r':0})
		
		cv.circle(img, (cX, cY), 7, (255, 255, 255), -1)
		cv.drawContours(img, [c], -1, (0, 255, 0), 2)
	
	cv.imwrite('/tmp/shaker.jpg', img)
	return objects



class Handler(server.RequestHandler):
	
	def get(self):
		self.set_header('Content-Type', 'image/jpeg')
		with open('/tmp/shaker.jpg', 'rb') as f:
			self.write(f.read())
	
	async def post(self):
		self.writeJson(scan())



server.addAjax(__name__, Handler)
