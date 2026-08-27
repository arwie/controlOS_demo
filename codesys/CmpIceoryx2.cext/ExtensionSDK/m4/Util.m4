divert(-1)
changecom(`%')
%
% Copyright:		Copyright CODESYS Development GmbH
%

define(`_CONCAT',`ifelse($#,0,`',$#,1,`$1',$#,2,`$1$2',`_CONCAT(`$1$2',`_CONCAT(shift(shift($@)))')')')
define(`_UPPERCASE', `translit($1, `a-z', `A-Z')')
define(`_TRIM',`regexp(`$1',`^[	 ]*\(.*[^	 ]\)[ 	]*$',`\1')')
define(`_TRIMCMPPREFIX',`regexp(`$1',`...\(.*\)$',`\1')')
define(`_TRIMPOINTERPARAM', `ifelse(regexp(`$1',`[^,]\*',`RTS_HANDLE'),-1,0,1)')
define(`_TRIMVARPARAMLIST', `ifelse(regexp(`$1',`\.\.\.'),-1,0,1)')

define(`_FUN_PTR', _FUN_PTR1(`_UPPERCASE(`$1')'))
define(`_FUN_PTR_IEC', _FUN_PTR1(`_UPPERCASE(`$1')'_IEC))
define(`_FUN_PTR1', `PF'$1)

define( _CHKSUM, 0)

define(`_EXTRACTFIRSTPARAMTYPE',`_EXTRACTTYPE(_EXTRACTPARAMS(`$1'))')
define(`_EXTRACTTYPE',`regexp(`$1',`\([\w_]*[^ ]*\)',`\1')')
define(`_EXTRACTFIRSTPARAMTYPEPOINTER',`_EXTRACTTYPEPOINTER(_EXTRACTPARAMS(`$1'))')
define(`_EXTRACTTYPEPOINTER',`regexp(`$1',`\([\*]\)',`\1')')
define(`_EXTRACTFIRSTPARAMTYPERTS',`_EXTRACTTYPERTS(_EXTRACTPARAMS(`$1'))')
define(`_EXTRACTTYPERTS',`regexp(`$1',`\(RTS_\)',`\1')')

define(`_EXTRACTPARAMS',`regexp(`$1',`^[	 ]*(\(.*\))[ 	]*$',`\1')')
define(`_EXTRACTPARAMNAME',`regexp(`$1',`\([a-zA-Z0-9_]+\)$',`\1')')
define(`_HAS_VARIABLEPARAMETER',`regexp(`$1',`\.\.\.')')
define(`_EXTRACT_VARIABLEPARAMETER_FORMAT',`regexp(`$1',` \*?\([a-zA-Z0-9_]+\), \.\.\.',`\1')')

%
% Extract the parameter out of a parameter list.
% 
% _EXTRACT_PARAM_LIST(`(int nCount, char *pBuf)') => `nCount,pBuf'
% _EXTRACT_PARAM_LIST(`(void)') => `'
%
define(_EXTRACT_PARAM_LIST_RECURSIVE,`ifelse($#,1,`_EXTRACTPARAMNAME(`$1')',`_EXTRACTPARAMNAME(`$1')`',_EXTRACT_PARAM_LIST_RECURSIVE(shift($@))')')
define(_EXTRACT_PARAM_LIST_,`ifelse(_TRIM(`$1'),`',`',_TRIM(`$1'),`void',`',`_EXTRACT_PARAM_LIST_RECURSIVE($@)')')
define(_EXTRACT_PARAM_LIST,`_EXTRACT_PARAM_LIST_(_EXTRACTPARAMS(`$1'))')

define(_EXTRACT_PARAM_LIST_HANDLE_RECURSIVE,`ifelse($#,1,`,_EXTRACTPARAMNAME(`$1')',`,_EXTRACTPARAMNAME(`$1')`'_EXTRACT_PARAM_LIST_HANDLE_RECURSIVE(shift($@))')')
define(_EXTRACT_PARAM_LIST_HANDLE_,`ifelse(_TRIM(`$1'),`',`',_TRIM(`$1'),`void',`',`_EXTRACT_PARAM_LIST_HANDLE_RECURSIVE($@)')')
define(_EXTRACT_PARAM_LIST_HANDLE,`_EXTRACT_PARAM_LIST_HANDLE_(shift(_EXTRACTPARAMS(`$1')))')

%
% Creates a parameter list for a macro call "(p1, p2, p3)", with one parameter for each parameter
% in the c parameterlist provided as parameter. If the provided parameterlist contains only `void'
% then it is treated as if it was empty.
% 
% _MAKE_DUMMYPARAMLIST(`(int nCount, char *pBuf)') => `p0,p1'
% _MAKE_DUMMYPARAMLIST(`(void)') => `'
%
define(_MAKE_DUMMYPARAMLIST1,`ifelse($#,1,`',$#,2,`p$1',`p$1,_MAKE_DUMMYPARAMLIST1(incr($1),shift(shift($@)))')')
define(_MAKE_DUMMYPARAMLIST_,`ifelse(_TRIM(`$1'),`',`',_TRIM(`$1'),`void',`',`_MAKE_DUMMYPARAMLIST1(0,$@)')')
define(_MAKE_DUMMYPARAMLIST_WITHVOID_,`ifelse(_TRIM(`$1'),`',`',`_MAKE_DUMMYPARAMLIST1(0,$@)')')
define(_MAKE_DUMMYPARAMLIST,`_MAKE_DUMMYPARAMLIST_(_EXTRACTPARAMS(`$1'))')

%
% Creates a parameter list for a macro call "(p1, p2, p3)", with one parameter for each parameter
% in the c parameterlist provided as parameter. If the provided parameterlist contains only `void'
% then it is treated as if it had exactly one parameter.
% 
% _MAKE_DUMMYPARAMLIST(`(int nCount, char *pBuf)') => `p0,p1'
% _MAKE_DUMMYPARAMLIST(`(void)') => `p0'
%
define(_MAKE_DUMMYPARAMLIST_WITHVOID,`_MAKE_DUMMYPARAMLIST_WITHVOID_(_EXTRACTPARAMS(`$1'))')

%
% Same as _MAKE_DUMMYPARAMLIST, but drops the first parameter
% 
% _MAKE_HANDLE_DUMMYPARAMLIST(`(RTS_HANDLE, hHandle, int nCount, char *pBuf)') => `p1,p2'
%
define(_MAKE_HANDLE_DUMMYPARAMLIST,`shift(_MAKE_DUMMYPARAMLIST(`$1'))')

%
% Same as _MAKE_DUMMYPARAMLIST, but drops the first n parameter
% 
% _MAKE_HANDLE_DUMMYPARAMLIST2(`(RTS_HANDLE hHandle, int nCount, char *pBuf, int nValue)', 2) => `p2,p3'
%
define(nshift, `ifelse($2, 0, `$1', `nshift(`shift($1)', decr($2))')')
define(_MAKE_HANDLE_DUMMYPARAMLIST2,`nshift(`_MAKE_DUMMYPARAMLIST(`$1')', $2)')


define(_MAKE_PARAMLIST2,`ifelse(_TRIM($@),`',`',`, $1`'_MAKE_PARAMLIST2(shift($@))')')
define(_MAKE_PARAMLIST1,`ifelse(_TRIM($@),`',`',`$1`'_MAKE_PARAMLIST2(shift($@))')')
define(_MAKE_HANDLEITF_PARAMLIST,`ifelse(_TRIM(shift($@)),`',`void',_TRIM(shift($@)),`void',`void',`_MAKE_PARAMLIST1(shift($@))')')
define(_MAKE_ITF_PARAMLIST,      `ifelse(_TRIM($@),`',`void',_TRIM($@),`void',`void',`_MAKE_PARAMLIST1($@)')')
define(_MAKE_CREATEITF_PARAMLIST,`ifelse(_TRIM($@),`',`void',_TRIM($@),`void',`void',`_MAKE_PARAMLIST1($@)')')

%
% Ieration over some string elements
% 
define(`_FOREACH', `ifelse(1,$#,` ',`$1($2)
ifelse(2,$#, ,`_FOREACH(`$1',shift(shift($@)))')')')

%
% Split component version number
%
%	Example:
%	$1 = "0x03020104"
%	_VERSION_MAJOR	=> 3
%	_VERSION_SUB0	=> 2
%	_VERSION_SUB1	=> 1
%	_VERSION_SUB2	=> 4
% 
define(`_TRIMLEFT_ZERO', `regexp(`$1', `^0*\(.+\)', `\1')')
define(`_VERSION_MAJOR',`_TRIMLEFT_ZERO(regexp(`$1',`^0x\([0-9a-fA-F][0-9a-fA-F]\)', `eval(0x\1)'))')
define(`_VERSION_SUB0',`_TRIMLEFT_ZERO(regexp(`$1',`^0x[0-9a-fA-F][0-9a-fA-F]\([0-9a-fA-F][0-9a-fA-F]\)', `eval(0x\1)'))')
define(`_VERSION_SUB1',`_TRIMLEFT_ZERO(regexp(`$1',`^0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]\([0-9a-fA-F][0-9a-fA-F]\)', `eval(0x\1)'))')
define(`_VERSION_SUB2',`_TRIMLEFT_ZERO(regexp(`$1',`^0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]\([0-9a-fA-F][0-9a-fA-F]\)', `eval(0x\1)'))')

divert`'dnl
