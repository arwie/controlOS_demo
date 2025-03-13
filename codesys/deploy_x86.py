from __future__ import print_function
from deploy import project, deploy


deploy(project.active_application, plc_logic='PlcLogic.x86')
print('All done!')
