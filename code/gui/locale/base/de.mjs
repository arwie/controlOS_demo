// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

export default {
	title: "controlOS",

	help: "Hilfe",
	save: "Speichern",
	apply: "Anwenden",
	execute: "Ausführen",
	connect: "Verbinden",
	disconnect: "Trennen",
	download: "Herunterladen",

	diag: {
		title: "Diagnose",
		log: {
			title: "Log",
			follow: "Neuen Meldungen folgen",
			priority: "Priorität",
			priority_0: "Notfall",
			priority_1: "Alarm",
			priority_2: "Kritisch",
			priority_3: "Fehler",
			priority_4: "Warnung",
			priority_5: "Hinweis",
			priority_6: "Info",
			priority_7: "Debug",
			identifier: "Kennung",
			host: "Host",
			date: "Datum",
			grep: "Freitextsuche",
			filter: "Filter",
			pinned: "Festgehalten",
			extendNewer: "Neuere laden",
			extendOlder: "Ältere laden",
			empty: "Keine Einträge vorhanden",
			extlogImport: "Datei importieren",
		},
		issue: {
			title: "Problembericht",
			description: "Beschreibung des Problems",
			contact: "Kontaktperson",
			contactEmail: "E-Mail-Adresse",
			contactTelephone: "Telefonnummer",
			download: "Herunterladen (mittels externem Emailprogramm senden)",
			send: "An Hersteller senden",
			sendSuccess: "Problembericht wurde erfolgreich an den Hersteller gesendet.",
			sendFail: "Problembericht konnte nicht gesendet werden. Bitte herunterladen und manuell versenden.",
		},
	},

	system: {
		title: "System",
		poweroff: "Ausschalten",
		update: {
			title: "Update",
			version: "Aktuelle Version",
			versionName: "Version",
			buildDate: "Erstellungsdatum",
			file: "Update von Datei",
			revert: "Update widerrufen",
			revertDate: "Datum des letzten Updates",
		},
		backup: {
			title: "Backup",
			download: "Backup herunterladen",
			restore: "Backup wiederherstellen",
		},
		remote: {
			title: "Fernzugriff",
			active: "Fernzugriff ist aktiviert!",
			port: "Service-Port-Nummer",
			enable: "Aktivieren",
			disable: "Deaktivieren",
		},
		network: {
			title: "Netzwerk",
			status: "Netzwerkstatus",
			syswlan: "Drahtloser Zugangspunkt",
			lan: "LAN",
			wlan: "WLAN",
			dhcp: "Automatische Netzwerkkonfiguration (DHCP)",
			manual: "Manuelle Netzwerkkonfiguration",
			hostname: "Hostname",
			address: "Netzwerkadresse",
			gateway: "Gateway",
			dns: "DNS",
			enabled: "Aktiviert",
			ssid: "Netzwerkname (SSID)",
			password: "Passwort",
			channel: "Frequenzkanal",
			country: "Landeskennung (DE,US,..)",
			smtp: "SMTP",
			ssl: "Sichere Verbindung (SSL)",
			starttls: "Unsichere Verbindung (PLAIN/STARTTLS)",
			host: "Host",
			port: "Port",
			user: "Benutzer",
		},
	},

	studio: {
		title: "{site} - Studio",
		simio: {
			title: "SimIO",
			cls_Input: "Eingänge",
			cls_Output: "Ausgänge",
			type: "Typ",
			value: "Wert",
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