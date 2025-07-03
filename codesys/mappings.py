from __future__ import print_function
from itertools import chain
from scriptengine import projects	#type:ignore



def mapping(template, devices, match, index=1):
	for dev in chain(*(projects.primary.find(name, True) for name in devices)):
		for param in dev.connectors[0].host_parameters:
			if param.io_mapping and match in param.section + param.name:
				variable = template.format(index)
				print('mapping {}:{}:{} -> {}'.format(dev.get_name(), param.section, param.name, variable))
				param.io_mapping.variable = variable
				index += 1



mapping(
	"Application.app.fbk.io[{}]",
	['XI110116'],
	"Channel"
)
mapping(
	"Application.app.cmd.io[{}]",
	['XI211116'],
	"Channel"
)



print('All done!')
