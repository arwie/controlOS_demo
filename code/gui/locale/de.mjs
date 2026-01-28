export default {
	hmi: {
		programs: {
			title: "Programme",
			list: "Programmauswahl",
		},
		calib_robot: {
			title: "Kalibrierung der Roboterachsen",
			calibPos: "Tatsächliche Achsposition für Kalibrierung",
			encoder: "Geberposition des Antriebs",
			offset: "Offset der Achsposition",
			savedOffset: "Gespeicherter offset",
		},
		cnc_paint: {
			title: "CNC-Zeichnen",
			description: "CODESYS SoftMotion CNC mit kontinuierlicher Pfadinterpolation",
			prompt: "Sag Claude {model}, was es zeichnen soll",
			model: "Claude Modell",
			thinking: "Nachdenken",
		},
		conv_pick_virt: {
			title: "Förderbandverfolgung mit virtuellen Objekten",
			description: "CODESYS SoftMotion Förderbandverfolgung. Virtuelle Objekte werden zufällig auf dem Förderband platziert und vom Roboter aufgenommen.",
		},
		robot_motion: {
			title: "Grundlegende Roboterbewegung",
			description: "Einfaches Bewegungsprogramm mit direkter, linearer und CNC-Interpolation.",
		},
		teach: {
			title: "Teachen",
			tool: "Greifer",
			grip: "Greifen",
			pos: "Aktuelle Position",
			snap: "Einrasten auf Position",
			speed: "Geschwindigkeit",
			conv: "Förderband",
			tool_none: "Kein Greifer",
			tool_magnet: "Magnet",
			tool_vacuum: "Vakuum",
			tool_laser: "Laser-Pointer",
			tool_probe: "Sonde",
		},
	}
}
