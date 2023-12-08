from __future__ import print_function


cmd = "Application.app.cmd.io[{}]"
fbk = "Application.app.fbk.io[{}]"

XI211116 = projects.primary.find('XI211116', True)[0]	#outputs
XI110116 = projects.primary.find('XI110116', True)[0]	#inputs


for dev, templ in [(XI211116, cmd), (XI110116, fbk)]:
	idx = 0
	for p in dev.connectors.by_id(1).host_parameters:
		if p.io_mapping:
			variable = templ.format(idx)
			print('mapping {}'.format(variable))
			p.io_mapping.variable = variable
			idx += 1
