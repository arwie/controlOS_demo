// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

export default {
	title: "controlOS",

	help: "Help",
	save: "Save",
	apply: "Apply",
	execute: "Execute",
	connect: "Connect",
	disconnect: "Disconnect",
	download: "Download",
	send: "Send",

	diag: {
		title: "Diagnostics",
		log: {
			title: "Log",
			follow: "Follow new messages",
			priority: "Priority",
			priority_0: "Emergency",
			priority_1: "Alert",
			priority_2: "Critical",
			priority_3: "Error",
			priority_4: "Warning",
			priority_5: "Notice",
			priority_6: "Info",
			priority_7: "Debug",
			identifier: "Identifier",
			host: "Host",
			date: "Date",
			grep: "Pattern search",
			filter: "Filter",
			pinned: "Pinned",
			extendNewer: "Load newer",
			extendOlder: "Load older",
			empty: "No messages available",
			extlogImport: "Import file",
		},
		issue: {
			title: "Issue report",
			description: "Issue description",
			contact: "Contact person",
			contactEmail: "Email address",
			contactTelephone: "Telephone number",
			download: "Download (send via external email client)",
			send: "Send to manufacturer",
			sendSuccess: "Issue was sent successfully to the manufacturer.",
			sendFail: "Issue could not be sent. Please download and send manually.",
		},
	},

	system: {
		title: "System",
		poweroff: "Power Off",
		update: {
			title: "Update",
			version: "Current version",
			versionName: "Version",
			buildDate: "Build date",
			file: "Update from file",
			revert: "Revert last update",
			revertDate: "Date of last update",
		},
		backup: {
			title: "Backup",
			download: "Download backup",
			restore: "Restore backup",
		},
		remote: {
			title: "Remote access",
			active: "Remote access is activated!",
			port: "Service port number",
			enable: "Activate",
			disable: "Deactivate",
		},
		network: {
			title: "Network",
			status: "Network status",
			syswlan: "Wireless access point",
			lan: "Wired LAN",
			wlan: "Wireless LAN",
			dhcp: "Automatic network configuration (DHCP)",
			manual: "Manual network configuration",
			hostname: "Hostname",
			address: "Network address",
			gateway: "Gateway",
			dns: "DNS",
			enabled: "Enabled",
			ssid: "Network name (SSID)",
			password: "Password",
			channel: "Wireless frequency channel",
			country: "Country code (DE,US,..)",
			smtp: "SMTP",
			ssl: "Secure connection (SSL)",
			starttls: "Insecure connection (PLAIN/STARTTLS)",
			host: "Host",
			port: "Port",
			user: "User",
		},
		timedate: {
			title: "Date / Time",
			status: "System clock status on the controller",
			timezone: "Timezone on the controller",
			timeSync: "The system clock on the controller is not synchronized!\nShould the device time {time} UTC be sent to the controller?",
		},
	},

	studio: {
		title: "{site} - Studio",
		simio: {
			title: "SimIO",
			cls_Input: "Inputs",
			cls_Output: "Outputs",
			type: "Type",
			value: "Value",
			override: "Override",
		},
		setup: {
			title: "Setup",
		},
		sim: {
			title: "Simulation"
		}
	},

};