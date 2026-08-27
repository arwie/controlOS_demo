include(`Util.m4') dnl
divert(-1)
% -----------------------------------
% Copyright:		Copyright CODESYS Development GmbH
% -----------------------------------
changecom(`%')
% -----------------------------
% Define some diverts that gather information about some special features
% and initialize those diversions
% -----------------------------
define(DIVERT_INTERFACEDEF_C,3)
define(DIVERT_ENDINTERFACEDEF_C,4)
define(DIVERT_INTERFACEDEF,5)
define(DIVERT_ENDINTERFACEDEF,6)
define(DIVERT_ENTRYFUN,7)
define(DIVERT_ENDFILE,100)


% -----------------------------
% The SET_PLACEHOLDER_NAME macro is to be ignored. It
% is used by the delivery manager only.
% -----------------------------
define(`SET_PLACEHOLDER_NAME',`dnl')
')

define(`GEN_INCLUDE', dnl
`ifelse(`-1',regexp(`$1',`\.m4$'), dnl
		`error(`m4:'__file__`('__line__`):The first parameter "'$1`" is not a .m4 file
			  ')',dnl
`#include "patsubst(`$1',`\.m4$',`\.h')"')')

define(`REF_ITF', `GEN_INCLUDE($1)')

% Mark safety relevant component, from which the IBase is used
% in a safety critical manner.
define(`INTERFACEDEF', 
`divert(DIVERT_INTERFACEDEF)
#ifdef CPLUSPLUS
class `I'$1 : public IBase
{
	public:
divert 
divert(DIVERT_INTERFACEDEF_C)

ifelse($1,`CmpIoDrv',`/* <SIL2/> */')dnl
ifelse($1,`CmpIoDrvC',`/* <SIL2/> */')dnl
ifelse($1,`CmpIoDrvIec',`/* <SIL2/> */')
typedef struct
{
	IBase_C *pBase;
divert')

define(`ENDINTERFACEDEF', 
`divert(DIVERT_ENDINTERFACEDEF)dnl
};
	#ifndef `ITF_'$1
		#define `ITF_'$1 static `I'$1 *`pI'$1 = NULL;
	#endif
	#define `EXTITF_'$1
#else	/*CPLUSPLUS*/
	typedef `I'$1_C		`I'$1;
	#ifndef `ITF_'$1
		#define `ITF_'$1
	#endif
	#define `EXTITF_'$1
#endif
divert 
divert(DIVERT_ENDINTERFACEDEF_C)dnl
} `I'$1_C;
divert')

define(`SET_INTERFACE_NAME', 
	`define(CMP_NAME, $1)'
	`define(ITFNOTDEFINED,_UPPERCASE(_TRIM($1))_NOTIMPLEMENTED)'
	`define(ITFEXTERNAL,_UPPERCASE(_TRIM($1))_EXTERNAL)
`#ifndef _'_UPPERCASE(_TRIM($1))`ITF_H_'
`#define _'_UPPERCASE(_TRIM($1))`ITF_H_'
`
#include "CmpStd.h"'
define(`_INTERFACE_NAME',`I$1')
INTERFACEDEF($1)
ENDINTERFACEDEF($1)
divert(DIVERT_ENDFILE)
`#ifdef CPLUSPLUS_ONLY'
`  #undef CPLUSPLUS_ONLY'
`#endif'

`#endif /*_'_UPPERCASE(_TRIM($1))`ITF_H_*/'
divert
')


%
% Call the DEF_API Makro with the following parameters:
% DEF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`REGISTER_API2', `s_pfCMRegisterAPI2( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), ifelse($6,1,_CHKSUM($1, $2, $4),$6), ifelse(eval($# < 7),1,0,$7))' )'dnl
`define(`GET_API', `s_pfCMGetAPI( "$3", (RTS_VOID_FCTPTR *)&pf$3, _CHKSUM($1, $2, $4))' )'dnl
`define(`GET_API2', `s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, ifelse(EXTERNAL,1,1,0), ifelse($6,0,_CHKSUM($1, $2, $4),$6), ifelse(eval($# < 7),1,0,$7))' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6),`1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($5, `1',`typedef $1 ($2 CDECL_EXT* _FUN_PTR_IEC($3)) $4;',`typedef $1 ($2 * _FUN_PTR($3)) $4;'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) ifelse(_TRIM($1),`void',`',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,ifelse(eval($# < 7),`1',REGISTER_API,REGISTER_API2),CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(eval($# < 7),`1',REGISTER_API,REGISTER_API2)'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3  $3'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ifelse(EXTERNAL,1,ifelse(eval($# < 7),`1',REGISTER_API,REGISTER_API2),ERR_OK)'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,ifelse(eval($# < 7),`1',REGISTER_API,REGISTER_API2),CAL_EXPAPI)'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6),`1',`_FUN_PTR($3)',`_FUN_PTR_IEC($3)') pf$3;'
	`#define EXT_'$3  `extern ifelse(eval($# < 6),`1',`_FUN_PTR($3)',`_FUN_PTR_IEC($3)') pf$3';
	`#define GET_$3(fl)  ifelse(eval($# < 7),1, `s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), ifelse(eval($# < 6),1,0,`ifelse($6,0,_CHKSUM($1, $2, $4),$6)'), ifelse(eval($# < 7),1,0,$7))',`s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl) | CM_IMPORT_EXTERNAL_LIB_FUNCTION, ifelse($6,0,_CHKSUM($1, $2, $4),$6), ifelse(eval($# < 7),1,0,$7))')'
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3   ifelse(eval($# < 7),`1',REGISTER_API, REGISTER_API2)'
`#endif'
)

%
% Call the DEF_STATIC_API Makro with the following parameters:
% DEF_STATIC_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_STATIC_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_STATIC_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6),`1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3  $3'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ifelse(EXTERNAL,1,REGISTER_API,ERR_OK)'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `_FUN_PTR($3) pf$3;'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4),0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
)

%
% Call the DEF_CREATEITF_API Makro with the following parameters:
% DEF_CREATEITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_CREATEITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_CREATEITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3  ``((I'CMP_NAME`*)s_pfCMCreateInstance(CLASSID_C'CMP_NAME'`, NULL))->I'$3
	`#define CHK_`'CMP_NAME`'$3	(s_pfCMCreateInstance != NULL && pI`'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3  ``((I'CMP_NAME`*)s_pfCMCreateInstance(CLASSID_C'CMP_NAME'`, NULL))->I'$3
	`#define CHK_$3	(s_pfCMCreateInstance != NULL && pI`'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_CREATEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_DELETEITF_API Makro with the following parameters:
% DEF_DELETEITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_DELETEITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_DELETEITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4')) ifelse(_TRIM($1),`void',`',``(((RTS_HANDLE)p0 == NULL || (RTS_HANDLE)p0 == RTS_INVALID_HANDLE) ? ERR_PARAMETER : ((I'CMP_NAME`*)p0)'->I'$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4'))))'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) ifelse(_TRIM($1),`void',`',``(((RTS_HANDLE)p0 == NULL || (RTS_HANDLE)p0 == RTS_INVALID_HANDLE) ? ERR_PARAMETER : ((I'CMP_NAME`*)p0)'->I'$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4'))))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_HANDLEITF_API Makro with the following parameters:
% DEF_HANDLEITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_HANDLEITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_HANDLEITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)p0)->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)p0)->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_HANDLEITF_API2 Makro with the following parameters:
% DEF_HANDLEITF_API2(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_HANDLEITF_API2(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_HANDLEITF_API2',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)(((IBase*)p0)->QueryInterface((IBase *)p0, ITFID_I`'CMP_NAME, (RTS_RESULT *)1)))->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)(((IBase*)p0)->QueryInterface((IBase *)p0, ITFID_I`'CMP_NAME, (RTS_RESULT *)1)))->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_HANDLEITF_API_OWNCPP Makro with the following parameters:
% DEF_HANDLEITF_API_OWNCPP(<return type>, <calling convention>, <function name>, <parameters>)
%
% NOTE:
% Identical to DEF_HANDLEITF_API except, that in the C++ wrapper you can use your own implementation.
%
% Example:
% DEF_HANDLEITF_API_OWNCPP(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_HANDLEITF_API_OWNCPP',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)p0)->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? pI`'CMP_NAME->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) : ((I`'CMP_NAME*)p0)->I'`$3(_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  (pI`'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)


%
% Call the DEF_CREATECLASSITF_API Makro with the following parameters:
% DEF_CREATECLASSITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_CREATECLASSITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_CREATECLASSITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`p0 = (IBase *)s_pfCMCreateInstance(p1, NULL);\
											((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`p0 = (IBase *)s_pfCMCreateInstance(p1, NULL);\
											((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))	`p0 = (IBase *)s_pfCMCreateInstance(p1, NULL);\
											((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))'
	`#define CHK_`'CMP_NAME`'$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`p0 = (IBase *)s_pfCMCreateInstance(p1, NULL);\
											((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))'
	`#define CHK_$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`p0 = (IBase *)s_pfCMCreateInstance(p1, NULL);\
											((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_CREATEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_CREATECLASSITF2_API Makro with the following parameters:
% DEF_CREATECLASSITF2_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_CREATECLASSITF2_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_CREATECLASSITF2_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == CLASSID_INVALID ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == CLASSID_INVALID ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))	`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_`'CMP_NAME`'$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == CLASSID_INVALID ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, NULL)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_CREATEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

define(`NUMPARAMS_xxx',`$#') 
define(`NUMPARAMS',`NUMPARAMS_xxx(_EXTRACTPARAMS($1))')
define(`MINPARAMS',`eval(NUMPARAMS(`$1') >= $2)')

%
% Call the DEF_PRODUCECLASSITF_API Makro with the following parameters:
% DEF_PRODUCECLASSITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_PRODUCECLASSITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_PRODUCECLASSITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_`'CMP_NAME`'$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_CREATEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_PRODUCECLASSITF_API_OWNCPP Makro with the following parameters:
% DEF_PRODUCECLASSITF_API_OWNCPP(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_PRODUCECLASSITF_API_OWNCPP(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_PRODUCECLASSITF_API_OWNCPP',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_`'CMP_NAME`'$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									((I'CMP_NAME`*)((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_'_INTERFACE_NAME`, (RTS_RESULT *)1)')->I$3(_MAKE_DUMMYPARAMLIST(`$4'))\
								)\
							)'
	`#define CHK_$3  (s_pfCMCreateInstance != NULL)'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		`\
							(\
								(p0 = (IBase *)s_pfCMCreateInstance(p1, NULL)) == NULL ? RTS_INVALID_HANDLE : \
								(\
									(((IBase *)p0)->ClassId = p1) == 0 ? RTS_INVALID_HANDLE :\
									(\
										(((IBase *)p0)->hInstance = ((I'CMP_NAME`*)p2)'->I$3(p2, p1, ((I`'CMP_NAME*)p2)->pBase->hInstance, _MAKE_HANDLE_DUMMYPARAMLIST2(`$4', 3))) == RTS_INVALID_HANDLE ? (s_pfCMDeleteInstance2(p1, (IBase *)p0) ? RTS_INVALID_HANDLE : RTS_INVALID_HANDLE) : \
										(\
											((IBase *)p0)->QueryInterface((IBase *)p0, ITFID_`'_INTERFACE_NAME`, NULL)'\
										)\
									)\
								)\
							)'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_CREATEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_DELETECLASSITF_API Makro with the following parameters:
% DEF_DELETECLASSITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_DELETECLASSITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_DELETECLASSITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) 	(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) 	(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))	 (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	 (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	 (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_DELETECLASSITF2_API Makro with the following parameters:
% DEF_DELETECLASSITF2_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_DELETECLASSITF2_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_DELETECLASSITF2_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) 		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) != ERR_OK ? \
														ERR_FAILED :\
														s_pfCMDeleteInstance2(((I`'CMP_NAME*)p0)->pBase->ClassId, ((I`'CMP_NAME*)p0)->pBase))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) 	 	(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) != ERR_OK ? \
														ERR_FAILED :\
														s_pfCMDeleteInstance2(((I`'CMP_NAME*)p0)->pBase->ClassId, ((I`'CMP_NAME*)p0)->pBase))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))	 (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))	 (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))			(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')) != ERR_OK ? \
														ERR_FAILED :\
														s_pfCMDeleteInstance2(((I`'CMP_NAME*)p0)->pBase->ClassId, ((I`'CMP_NAME*)p0)->pBase))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_CLASSITF_API Makro with the following parameters:
% DEF_CLASSITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_CLASSITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_CLASSITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_RETURNHANDLECLASSITF_API Makro with the following parameters:
% DEF_RETURNHANDLECLASSITF_API(<return type>, <calling convention>, <function name>, <parameters>)
% 
% Example:
% DEF_RETURNHANDLECLASSITF_API(`RTS_HANDLE',`CDECL', `MyApiFunction', `(RTS_HANDLE hObject, int nX, void *pData)')
% ==>	((IMyInterface*)p0)->IMyInterfaceFunction(((IMyInterface*)p0)->pBase->hInstance,p1,p2,p3))
%
define(`DEF_RETURNHANDLECLASSITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`STATICITF_DEF $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : ((('I`'CMP_NAME*)p0)->pBase->hInstance = ((I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4'))))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : ((('I`'CMP_NAME*)p0)->pBase->hInstance = ((I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4'))))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`'$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4'))		(p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : (('I`'CMP_NAME*)p0)->I$3(`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4')))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#else /* DYNAMIC_LINK */'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_OK'
	`#define CAL_$3(_MAKE_DUMMYPARAMLIST(`$4')) (p0 == RTS_INVALID_HANDLE || p0 == NULL ? `'ifelse(_TRIM($1),`RTS_RESULT',`($1)ERR_PARAMETER',ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`0'))` : ((('I`'CMP_NAME*)p0)->pBase->hInstance = ((I`'CMP_NAME*)p0)->I$3(((I`'CMP_NAME*)p0)->pBase->hInstance`'ifelse(MINPARAMS(`$4',2),`1',`,',`')`'_MAKE_HANDLE_DUMMYPARAMLIST(`$4'))))'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ERR_OK'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_STATICITF_API Makro with the following parameters:
% DEF_STATICITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_STATICITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_STATICITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3 ``C'CMP_NAME::I'$3
	`#define CHK_`'CMP_NAME`'$3  TRUE'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3 ``C'CMP_NAME::I'$3
	`#define CHK_$3  TRUE'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		static $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_ITF_API Makro with the following parameters:
% DEF_ITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_ITF_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_ITF_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',ifelse(_TRIM($1),`void *',`($1)(RTS_SIZE)ERR_NOTIMPLEMENTED',`($1)ERR_NOTIMPLEMENTED')))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3 ``pI'CMP_NAME->I'$3
	`#define CHK_`'CMP_NAME`''$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3 ``pI'CMP_NAME->I'$3
	`#define CHK_'$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_ITF_API Makro with the following parameters:
% DEF_ITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_ITF_API_OWNCPP(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_ITF_API_OWNCPP',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',ifelse(_TRIM($1),`void *',`($1)(RTS_SIZE)ERR_NOTIMPLEMENTED',`($1)ERR_NOTIMPLEMENTED')))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3 ``pI'CMP_NAME->I'$3
	`#define CHK_`'CMP_NAME`''$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3 ``pI'CMP_NAME->I'$3
	`#define CHK_'$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_ITF_API Makro with the following parameters:
% DEF_ITF_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_ITF_API2(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_ITF_API2',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`$1 $2 CDECL_EXT $3$4;',`$1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',ifelse(_TRIM($1),`void *',`($1)(RTS_SIZE)ERR_NOTIMPLEMENTED',`($1)ERR_NOTIMPLEMENTED')))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3 ``pI'CMP_NAME->I'$3
	`#define CHK_`'CMP_NAME`''$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3 ``pI'CMP_NAME->I'$3
	`#define CHK_'$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)

%
% Call the DEF_ITF_GLOBAL_API Makro with the following parameters:
% DEF_ITF_GLOBAL_API(<return type>, <calling convention>, <function name>, <parameters>)
%
% Example:
% DEF_ITF_GLOBAL_API(`int',`CDECL', `MyApiFunction', `(int nX, void *pData)')
%
define(`DEF_ITF_GLOBAL_API',
`ifelse(eval($# < 5),`0',`define(`EXTERNAL',_TRIM(`$5'))',`define(`EXTERNAL',0)')'dnl
`define(`REGISTER_API', `s_pfCMRegisterAPI( (const CMP_EXT_FUNCTION_REF*)"$3", (RTS_UINTPTR)$3, ifelse(EXTERNAL,1,1,0), _CHKSUM($1, $2, $4))' )'dnl
`define(`FCT_NOTIMPLEMENTED', `ifelse(_EXTRACTFIRSTPARAMTYPE(`$4'), `RTS_HANDLE', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPEPOINTER(`$4'), `*', `FUNCTION_NOTIMPLEMENTED2',`ifelse(_EXTRACTFIRSTPARAMTYPERTS(`$4'), `RTS_', `FUNCTION_NOTIMPLEMENTED',`FUNCTION_NOTIMPLEMENTED2')')')' )'dnl
`define(`CAL_GETAPI', `CAL_CMGETAPI( "$3" )' )'dnl
`define(`CAL_EXPAPI', `CAL_CMEXPAPI( "$3" )' )'dnl
`ifelse(_TRIM(`$5'),1,`DLL_DECL $1 $2 CDECL_EXT $3$4;',`DLL_DECL $1 $2 $3$4;')'
`ifelse(eval($# < 6), `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;', ifelse($6, `1',`typedef $1 ($2 * _FUN_PTR($3)) $4;',`'))'
`#if ifdef(`ITFNOTDEFINED',`defined(ITFNOTDEFINED) || ')defined(_UPPERCASE(_TRIM(`$3'))_NOTIMPLEMENTED)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  ERR_NOTIMPLEMENTED'
	`#define CAL_$3`'ifelse(_TRIMVARPARAMLIST($4),1,`',`(_MAKE_DUMMYPARAMLIST(`$4'))')  ifelse(_TRIM($1),`void',`', ifelse(_TRIM($4), `void',`($1)ERR_NOTIMPLEMENTED',ifelse(_TRIMVARPARAMLIST($4),1,FCT_NOTIMPLEMENTED,ifelse(_TRIM($1),`RTS_HANDLE',`($1)RTS_INVALID_HANDLE',`($1)ERR_NOTIMPLEMENTED'))))'
	`#define CHK_$3  FALSE'
	`#define EXP_$3  ERR_OK'
`#elif defined(STATIC_LINK)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  ifelse(EXTERNAL,1,REGISTER_API,CAL_EXPAPI)'
`#elif defined(MIXED_LINK) && !defined(ITFEXTERNAL)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_$3  $3'
	`#define CHK_$3  TRUE'
	`#define EXP_$3  REGISTER_API'
`#elif defined(CPLUSPLUS_ONLY)'
	`#define USE_`'CMP_NAME`'$3'
	`#define EXT_`'CMP_NAME`'$3'
	`#define GET_`'CMP_NAME`'$3  ERR_OK'
	`#define CAL_`'CMP_NAME`''$3 ``pI'CMP_NAME->I'$3
	`#define CHK_`'CMP_NAME`''$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_`'CMP_NAME`'$3  ERR_OK'
`#elif defined(CPLUSPLUS)'
	`#define USE_$3'
	`#define EXT_$3'
	`#define GET_$3(fl)  CAL_GETAPI'
	`#define CAL_'$3 ``pI'CMP_NAME->I'$3
	`#define CHK_'$3 ``(pI'CMP_NAME != NULL)'
	`#define EXP_$3  CAL_EXPAPI'
`#else /* DYNAMIC_LINK */'
	`#define USE_'$3  `ifelse(eval($# < 6), `1',`_FUN_PTR($3) pf$3;', ifelse($6, `1', `_FUN_PTR($3) pf$3;'))'
	`#define EXT_'$3  `extern _FUN_PTR($3) pf$3';
	`#define GET_'$3(fl)  s_pfCMGetAPI2( "$3", (RTS_VOID_FCTPTR *)&pf$3, (fl), _CHKSUM($1, $2, $4), 0)
	`#define CAL_'$3  pf$3
	`#define CHK_'$3  (pf$3 != NULL)
	`#define EXP_$3  REGISTER_API'
`#endif'
`divert(DIVERT_INTERFACEDEF)		virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4'))) =0;
divert'
`divert(DIVERT_INTERFACEDEF_C)	_FUN_PTR($3) `I'$3;
 divert'
)
divert