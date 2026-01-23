# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from collections import defaultdict
from shared.conf import Conf
from shared import log



def _defaultdict():
	return defaultdict(_defaultdict)

setup = _defaultdict()


try:
	conf = Conf('/etc/app/setup.conf')
except FileNotFoundError:
	conf = None


try:
	import shared.setups #type:ignore optional package
except ModuleNotFoundError:
	pass
except Exception:
	log.exception('application setup failed')


if conf and conf.has_section('setup'):
	for path,value in conf.items('setup'):
		path = path.split('/')
		item = setup
		for key in path[:-1]:
			item = item[key]
		item[path[-1]] = value
