<?
includeLib('APP.LIB');
includeLib('DATA.LIB');

includeLib('DUPLO.LIB');
includeLib('CVPATH.LIB');
includeLib('TRACKING.LIB');
includeLib('PROG.LIB');
includeLib('TEACH.LIB');


includeLib('DELTA1.LIB');
includeLib('DELTA1A.LIB', 'DELTA1ABC.LIB');
includeLib('DELTA1B.LIB', 'DELTA1ABC.LIB');
includeLib('DELTA1C.LIB', 'DELTA1ABC.LIB');
includeLib('DELTA1R.LIB');

includeLib('CONV.LIB');


device_order(['delta1a','delta1b','delta1c','delta1r']);
