export default {
	hmi: {
		programs: {
			title: "Programs",
			list: "Program selection",
		},
		calib_robot: {
			title: "Robot axes calibration",
			calibPos: "Real axis position for calibration",
			encoder: "Drive encoder position",
			offset: "Axis position offset",
			savedOffset: "Saved offset",
		},
		cnc_paint: {
			title: "CNC Paint",
			description: "CODESYS SoftMotion CNC continuous path interpolation",
		},
		conv_pick_virt: {
			title: "Conveyor tracking with virtual items",
			description: "CODESYS SoftMotion conveyor tracking example. Virtual items are randomly placed on the conveyor and picked by the robot."
		},
		robot_motion: {
			title: "Basic robot motion",
			description: "Simple motion program with direct, linear and CNC interpolation."
		},
		teach: {
			title: "Teach",
			tool: "Gripper",
			grip: "Grip",
			pos: "Current position",
			snap: "Snap to position",
			speed: "Speed",
			conv: "Conveyor",
			tool_none: "No gripper",
			tool_magnet: "Magnet",
			tool_vacuum: "Vacuum",
			tool_laser: "Laser pointer",
			tool_probe: "Probe",
		},
	}
}