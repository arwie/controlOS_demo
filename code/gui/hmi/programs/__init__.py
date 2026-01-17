from pathlib import Path
import web


@web.handler
class programs(web.ModuleHandler):
	async def export_default(self):
		return sorted(f.stem for f in Path('/usr/lib/app/programs').glob('*.py') if not f.match('_*'))


web.files.glob('hmi/programs/*.jpg')

web.document.imports.append('hmi/programs')

web.document.imports.append('hmi/programs/calib_robot')
web.document.imports.append('hmi/programs/cnc_paint')
web.document.imports.append('hmi/programs/io_wave')
