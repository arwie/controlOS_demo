from shared.utils import import_all_in_package



navs  = []
pages = []

def add_page(page:str, nav:str):
	pages.append(page)
	navs.append(nav)


import_all_in_package(__file__, __name__)
