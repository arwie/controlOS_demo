import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.VirtualKeyboard 2.2
import QtWebEngine 1.7

Window {
	visible: true
	
	Item {
		anchors.centerIn: parent
		rotation: 90
		width: parent.height
		height: parent.width
		
		WebEngineView {
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: inputPanel.visible ? inputPanel.top : parent.bottom
			url: "http://sys"
			zoomFactor: 1.0
			
			onContextMenuRequested: function(request) { request.accepted = true; }
		}
		
		InputPanel {
			id: inputPanel
			visible: Qt.inputMethod.visible
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
		}
	}
}
