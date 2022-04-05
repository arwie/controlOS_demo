
navs  = []
pages = []
def addPage(page, nav):
	pages.append(page)
	navs.append(nav)


from pathlib import Path
__all__ = [m.stem for m in Path(__file__).parent.glob('*.py') if not m.match('__*__.py')]
from . import *
