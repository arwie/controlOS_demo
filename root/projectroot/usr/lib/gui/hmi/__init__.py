import web


web.document.imports.add('bootstrap')
web.document.stylesheets.append('bootstrap/bootstrap.css')

web.document.stylesheets.append('fontawesome/css/all.css')


web.document.imports.add('hmi')

web.document.imports.add('hmi/teach')
web.document.imports.add('hmi/paint')


import system

import diag.log
import diag.issue
