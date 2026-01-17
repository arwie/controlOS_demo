import web


import web.use.bootstrap
import web.use.fontawesome


web.document.imports.append('hmi')

import hmi.programs
web.document.imports.append('hmi/teach')


import system

import diag.log
import diag.issue
