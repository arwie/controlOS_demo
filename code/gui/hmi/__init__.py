import web


import web.use.bootstrap
import web.use.fontawesome


web.document.imports.append('hmi')

import hmi.programs
web.document.imports.append('hmi/teach')


import system

import diag.log
web.document.imports.append('diag/watch')
import diag.issue
