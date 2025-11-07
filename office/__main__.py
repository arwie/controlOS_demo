# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import asyncio
import signal
import web


web.document.importmap.update({
	'vue':			'https://unpkg.com/vue@3.5/dist/vue.esm-browser.prod.js',
	'vue/router':	'https://unpkg.com/vue-router@4.5/dist/vue-router.esm-browser.prod.js',
	'vue/i18n':		'https://unpkg.com/vue-i18n@11.1.11/dist/vue-i18n.esm-browser.prod.js',
})

web.document.importmap.update({
	'bootstrap':		'https://unpkg.com/bootstrap@5.3/dist/js/bootstrap.bundle.min.js',
	'bootstrap/vue':	'https://unpkg.com/bootstrap-vue-next@0.30.4/dist/bootstrap-vue-next.mjs',
})
web.document.stylesheets.extend([
	'https://unpkg.com/bootstrap@5.3/dist/css/bootstrap.min.css',
	'https://unpkg.com/bootstrap-vue-next@0.30.4/dist/bootstrap-vue-next.css',
])
web.document.imports.append('web/use/bootstrap')

web.document.stylesheets.append('https://unpkg.com/@fortawesome/fontawesome-free@6.7/css/all.min.css')


web.document.imports.append('office')


import extlog



async def main():

	server = web.server()
	server.listen(8000)

	print('Office server address:', 'http://localhost:8000')

	exit_event = asyncio.Event()

	for sig in (signal.SIGINT, signal.SIGTERM):
		asyncio.get_running_loop().add_signal_handler(sig, exit_event.set)

	await exit_event.wait()


asyncio.run(main())
