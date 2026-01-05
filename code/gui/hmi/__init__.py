import web


import web.use.bootstrap
import web.use.fontawesome


web.document.imports.append('hmi')

web.document.imports.append('hmi/teach')

web.document.imports.append('hmi/paint')
web.document.imports.append('hmi/io_wave')


import system

import diag.log
import diag.issue
