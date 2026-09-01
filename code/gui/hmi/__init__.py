import web


import web.use.bootstrap
import web.use.fontawesome


web.document.imports.append('hmi')

from . import robot
from . import programs

import diag.log
import diag.watch
import diag.issue
import system
