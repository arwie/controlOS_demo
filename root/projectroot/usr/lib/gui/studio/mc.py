import mc

import studio
studio.addPage('mc/mc.html',	'''<pageLink params="path:'mc'"></pageLink>''')
studio.addPage('mc/debug.html',	'''<pageLink params="path:'debug', visibleState:'mc@debug'"></pageLink>''')
studio.addPage('mc/simio.html',	'''<pageLink params="path:'simio', visibleState:'mc@simio'"></pageLink>''')
