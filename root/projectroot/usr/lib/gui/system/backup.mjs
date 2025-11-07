// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { url } from 'web/utils'
import { ButtonBar, FileButton, feedback } from 'web/widgets'
import { systemIndex } from 'system'



systemIndex.addPage('backup', {
	setup() {

		function restore(file, element) {
			feedback(element, url('system.backup.restore').put(file));
		}

		return { url, restore }
	},
	components: { ButtonBar, FileButton },
	template: //html
	`
	<ButtonBar>
		<a :href="url('', 8100)" target="_blank" class="btn btn-primary">{{ $t('system.backup.download') }}</a>
		<FileButton @file="restore" class="btn-warning">{{ $t('system.backup.restore') }}</FileButton>
	</ButtonBar>
	`
})
