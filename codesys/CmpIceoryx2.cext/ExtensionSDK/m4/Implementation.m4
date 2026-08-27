divert(-1)
% -----------------------------------
% Copyright:		Copyright CODESYS Development GmbH
% -----------------------------------
# The following lines ("DO NOT MODIFY...") generate a message in the destination file.
# This comment is not aimed at this file.
divert`'dnl
/***********************************************************************
 * DO NOT MODIFY!
 * This is a generated file. Do not modify it's contents directly
 ***********************************************************************/
include(`Util.m4')
divert(-1)

changecom(`%')
% -----------------------------
% Define some diverts that gather information about some special features
% and initialize those diversions
% -----------------------------
define(DIVERT_USE,3)
define(DIVERT_USEIMPORT,4)
define(DIVERT_USEEXTERN,5)
define(DIVERT_INIT,6)
define(DIVERT_RENAME_ENTRYFUN,9)
define(DIVERT_BEGINCLASSDEF,10)
define(DIVERT_CLASSDEF,11)
define(DIVERT_CLASSMEMBERS,12)
define(DIVERT_ENDCLASSDEF,13)
define(DIVERT_ENDMETHODDEF,15)
define(DIVERT_URTS_DEFS, 20)
define(DIVERT_ENDFILE,100)

define(`REF_ITF', `GEN_INCLUDE($1)')

define(`COMPONENT_VERSION',`#define CMP_VERSION         UINT32_C(`$1')
#define CMP_VERSION_STRING "_VERSION_MAJOR(`$1')._VERSION_SUB0(`$1')._VERSION_SUB1(`$1')._VERSION_SUB2(`$1')"
#define CMP_VERSION_RC      _VERSION_MAJOR(`$1'),_VERSION_SUB0(`$1'),_VERSION_SUB1(`$1'),_VERSION_SUB2(`$1')')
define(`COMPONENT_VENDORID',`#define CMP_VENDORID       $1

#ifndef WIN32_RESOURCES')

divert(DIVERT_USE)dnl
#define USE_STMT \
    /*lint -save --e{528} --e{551} */ \
    static volatile PF_REGISTER_API s_pfCMRegisterAPI; \
    static volatile PF_REGISTER_API2 s_pfCMRegisterAPI2; \
    static volatile PF_GET_API s_pfCMGetAPI; \
    static volatile PF_GET_API2 s_pfCMGetAPI2; \
    static volatile PF_REGISTER_CLASS s_pfCMRegisterClass; \
    static volatile PF_CREATEINSTANCE s_pfCMCreateInstance; \
    static volatile PF_CALL_HOOK s_pfCMCallHook; \
    static const CMP_EXT_FUNCTION_REF s_ExternalsTable[] =\
    {\
        EXPORT_EXTREF_STMT\
        EXPORT_EXTREF2_STMT\
        { ((RTS_VOID_FCTPTR)(void *)0), "", 0, 0 }\
    };\
    static const CMP_EXT_FUNCTION_REF s_ItfTable[] = EXPORT_CMPITF_STMT; \
    /*lint -restore */  \
    static int CDECL ExportFunctions(void); \
    static int CDECL ImportFunctions(void); \
    static IBase* CDECL CreateInstance(CLASSID cid, RTS_RESULT *pResult); \
    static RTS_RESULT CDECL DeleteInstance(IBase *pIBase); \
    static RTS_UI32 CDECL CmpGetVersion(void); \
    static RTS_RESULT CDECL HookFunction(RTS_UI32 ulHook, RTS_UINTPTR ulParam1, RTS_UINTPTR ulParam2); \
    dnl
divert(-1)


divert(DIVERT_USEIMPORT)
#define USEIMPORT_STMT \
    /*lint -save --e{551} */ \
    static volatile PF_REGISTER_API s_pfCMRegisterAPI; \
    static volatile PF_REGISTER_API2 s_pfCMRegisterAPI2; \
    static volatile PF_GET_API s_pfCMGetAPI; \
    static volatile PF_GET_API2 s_pfCMGetAPI2; \
    static volatile PF_REGISTER_CLASS s_pfCMRegisterClass; \
    static volatile PF_CREATEINSTANCE s_pfCMCreateInstance; \
    static volatile PF_CALL_HOOK s_pfCMCallHook; \
    /*lint -restore */  \
    dnl
divert(-1)



divert(DIVERT_USEEXTERN)
#define USEEXTERN_STMT \
    dnl
divert(-1)

divert(DIVERT_RENAME_ENTRYFUN)
#ifndef COMPONENT_NAME
    #error COMPONENT_NAME is not defined. This prevents the component from being linked statically. Use `SET_COMPONENT_NAME'(<name_of_your_component>) to set the name of the component in your .m4 component description.
#endif
divert(-1)

divert(DIVERT_BEGINCLASSDEF)
#ifdef CPLUSPLUS
divert(-1)

divert(DIVERT_ENDMETHODDEF)
#endif /*CPLUSPLUS*/
divert(-1)

divert(DIVERT_ENDFILE)
`#endif /*WIN32_RESOURCES*/'
`#endif /*_DEP_H_*/'
divert(-1)')


% ---------------------------
% The SET_COMPONENT_NAME directive should reside at the top of each "Itf" file.
% ---------------------------

define(`SET_COMPONENT_NAME',
`define(_COMPONENT_NAME,`$1')dnl
`#ifndef _'_UPPERCASE(_COMPONENT_NAME)`DEP_H_'
`#define _'_UPPERCASE(_COMPONENT_NAME)`DEP_H_'

#define COMPONENT_NAME "$1" COMPONENT_NAME_POSTFIX
#define COMPONENT_ID    ADDVENDORID(CMP_VENDORID, CMPID_$1)
#define COMPONENT_NAME_UNQUOTED $1

divert(DIVERT_RENAME_ENTRYFUN)

divert(DIVERT_RENAME_ENTRYFUN)

#if defined(STATIC_LINK) || defined(MIXED_LINK) || defined(DYNAMIC_LINK) || defined(CPLUSPLUS_STATIC_LINK)
    #define ComponentEntry $1`'__Entry
#endif

divert

divert(DIVERT_URTS_DEFS)dnl

divert
')

% -----------------------------
% The COMPONENT_SOURCES and COMPONENT_SYSSOURCES macros are to be ignored. They
% are used by the configuration tool only.
% -----------------------------
define(`COMPONENT_SOURCES',`dnl')
define(`EXTERNAL_SOURCES',`dnl')
define(`EXTERNAL_INCLUDES',`dnl')
define(`COMPONENT_INCLUDES',`dnl')
define(`COMPONENT_SYSSOURCES',`dnl')
define(`CONTRIB_SOURCES',`dnl')
define(`CONTRIB_INCLUDES',`dnl')
')

% -----------------------------
% The CATEGORY macro is to be ignored. It
% is used by the configuration tool only.
% -----------------------------
define(`CATEGORY',`dnl')
')

% -----------------------------
% After all input is read, some macros have to be created
% -----------------------------
define(`ADD_IMPORTS',`ifdef(`__IMPORTS',`__IMPORTS popdef(`__IMPORTS') ADD_IMPORTS')')
define(`CREATE_IMPORT_STMT', dnl
`ifdef(`__IMPORTS',`#if defined(STATIC_LINK)
    #define IMPORT_STMT
#else
    #define IMPORT_STMT \
    {\
        RTS_RESULT importResult = ERR_OK;\
        RTS_RESULT TempResult = ERR_OK;\
        INIT_STMT   \
        TempResult = GET_LogAdd(CM_IMPORT_OPTIONAL_FUNCTION); \
        TempResult = GET_CMUtlMemCpy(CM_IMPORT_OPTIONAL_FUNCTION); \
        ADD_IMPORTS \
        /* To make LINT happy */\
        TempResult = TempResult;\
        if (ERR_OK != importResult) return importResult;\
    }
#endif
',`#define IMPORT_STMT      INIT_STMT')
')

% -----------------------------
% This function emits all export statements inside the macro EXPORT_STMT (one after another)
% -----------------------------
define(`ADD_EXPORTS',`ifdef(`__EXPORTS',`__EXPORTS popdef(`__EXPORTS') ADD_EXPORTS')')
define(`ADD_EXTREF_EXPORTS',`ifdef(`__EXPORTS_EXTREF',`__EXPORTS_EXTREF popdef(`__EXPORTS_EXTREF') ADD_EXTREF_EXPORTS')')
define(`ADD_EXTREF_EXPORTS2',`ifdef(`__EXPORTS_EXTREF2',`__EXPORTS_EXTREF2 popdef(`__EXPORTS_EXTREF2') ADD_EXTREF_EXPORTS2')')
define(`ADD_EXPORTS_CPLUSPLUS_ONLY',`ifdef(`__EXPORTS_CPLUSPLUS_ONLY',`__EXPORTS_CPLUSPLUS_ONLY popdef(`__EXPORTS_CPLUSPLUS_ONLY') ADD_EXPORTS_CPLUSPLUS_ONLY')')

% -----------------------------
% Define the EXPORT_STMT macro. the content is filled out by ADD_EXPORTS.
% -----------------------------
define(`CREATE_EXPORT_STMT',dnl
`ifdef(`__EXPORTS_EXTREF',dnl
`#ifndef _UPPERCASE(_COMPONENT_NAME)_DISABLE_EXTREF
#define EXPORT_EXTREF_STMT \
        ADD_EXTREF_EXPORTS
#else
#define EXPORT_EXTREF_STMT
#endif',`#define EXPORT_EXTREF_STMT')
'dnl
`ifdef(`__EXPORTS_EXTREF2',dnl
`#ifndef _UPPERCASE(_COMPONENT_NAME)_DISABLE_EXTREF2
#define EXPORT_EXTREF2_STMT \
        ADD_EXTREF_EXPORTS2
#else
#define EXPORT_EXTREF2_STMT
#endif',`#define EXPORT_EXTREF2_STMT')
'dnl
`ifdef(`__EXPORTS',dnl
`#if !defined(_UPPERCASE(_COMPONENT_NAME)_DISABLE_CMPITF) && !defined(STATIC_LINK) && !defined(CPLUSPLUS) && !defined(CPLUSPLUS_ONLY)
#define EXPORT_CMPITF_STMT \
    {\
        ADD_EXPORTS\
        { ((RTS_VOID_FCTPTR)(void *)0), "", 0, 0 }\
    }
#else
#define EXPORT_CMPITF_STMT \
    {\
        { ((RTS_VOID_FCTPTR)(void *)0), "", 0, 0 }\
    }
#endif',`#define EXPORT_CMPITF_STMT {{ ((RTS_VOID_FCTPTR)(void *)0), "", 0, 0 }}')
'dnl
`ifdef(`__EXPORTS_CPLUSPLUS_ONLY', `
#define EXPORT_CPP_STMT \
    {\
        ADD_EXPORTS_CPLUSPLUS_ONLY \
    }
',`#define EXPORT_CPP_STMT')
'dnl
)

% -----------------------------
% This function emits all init statements inside the macro INIT_STMT (one after another)
% -----------------------------
define(`ADD_INITS',`ifdef(`__INITS',`__INITS popdef(`__INITS') ADD_INITS')')
define(`ADD_INIT_LOCALS',`ifdef(`__INIT_LOCALS',`__INIT_LOCALS popdef(`__INIT_LOCALS') ADD_INIT_LOCALS')')
define(`ADD_EXITS',`ifdef(`__EXITS',`__EXITS popdef(`__EXITS') ADD_EXITS')')

% -----------------------------
% Define the INIT_STMT macro.
% -----------------------------
define(`CREATE_INIT_STMT', dnl
`ifdef(`__INITS',``
#ifdef CPLUSPLUS
    #define INIT_STMT' \
    {\
        IBase *pIBase;\
        RTS_RESULT initResult;\
        if (pICmpLog == NULL && s_pfCMCreateInstance != NULL) \
        { \
            pIBase = (IBase *)s_pfCMCreateInstance(CLASSID_CCmpLog, &initResult); \
            if (pIBase != NULL) \
            { \
                pICmpLog = (ICmpLog *)pIBase->QueryInterface(pIBase, ITFID_ICmpLog, &initResult); \
                pIBase->Release(pIBase); \
            } \
        } \
        if (pICMUtils == NULL && s_pfCMCreateInstance != NULL) \
        { \
            pIBase = (IBase *)s_pfCMCreateInstance(CLASSID_CCMUtils, &initResult); \
            if (pIBase != NULL) \
            { \
                pICMUtils = (ICMUtils *)pIBase->QueryInterface(pIBase, ITFID_ICMUtils, &initResult); \
                pIBase->Release(pIBase); \
            } \
        } \
        ADD_INITS \
    }
    #define INIT_LOCALS_STMT \
    {\
        pICmpLog = NULL; \
        pICMUtils = NULL; \
        ADD_INIT_LOCALS \
    }
    #define EXIT_STMT \
    {\
        IBase *pIBase;\
        RTS_RESULT exitResult;\
        if (pICmpLog != NULL) \
        { \
            pIBase = (IBase *)pICmpLog->QueryInterface(pICmpLog, ITFID_IBase, &exitResult); \
            if (pIBase != NULL) \
            { \
                 pIBase->Release(pIBase); \
                 if (pIBase->Release(pIBase) == 0) /* The object will be deleted here! */ \
                    pICmpLog = NULL; \
            } \
        } \
        if (pICMUtils != NULL) \
        { \
            pIBase = (IBase *)pICMUtils->QueryInterface(pICMUtils, ITFID_IBase, &exitResult); \
            if (pIBase != NULL) \
            { \
                 pIBase->Release(pIBase); \
                 if (pIBase->Release(pIBase) == 0) /* The object will be deleted here! */ \
                    pICMUtils = NULL; \
            } \
        } \
        ADD_EXITS \
    }
#else
    #define INIT_STMT
    #define INIT_LOCALS_STMT
    #define EXIT_STMT
#endif
',`#ifdef CPLUSPLUS
    #define INIT_STMT \
    {\
        IBase *pIBase;\
        RTS_RESULT initResult;\
        if (pICmpLog == NULL && s_pfCMCreateInstance != NULL) \
        { \
            pIBase = (IBase *)s_pfCMCreateInstance(CLASSID_CCmpLog, &initResult); \
            if (pIBase != NULL) \
            { \
                pICmpLog = (ICmpLog *)pIBase->QueryInterface(pIBase, ITFID_ICmpLog, &initResult); \
                pIBase->Release(pIBase); \
            } \
        } \
        if (pICMUtils == NULL && s_pfCMCreateInstance != NULL) \
        { \
            pIBase = (IBase *)s_pfCMCreateInstance(CLASSID_CCMUtils, &initResult); \
            if (pIBase != NULL) \
            { \
                pICMUtils = (ICMUtils *)pIBase->QueryInterface(pIBase, ITFID_ICMUtils, &initResult); \
                pIBase->Release(pIBase); \
            } \
        } \
    }
    #define INIT_LOCALS_STMT \
    {\
        pICmpLog = NULL; \
        pICMUtils = NULL; \
        ADD_INIT_LOCALS \
    }   
    #define EXIT_STMT \
    {\
        IBase *pIBase;\
        RTS_RESULT exitResult;\
        if (pICmpLog != NULL) \
        { \
            pIBase = (IBase *)pICmpLog->QueryInterface(pICmpLog, ITFID_IBase, &exitResult); \
            if (pIBase != NULL) \
            { \
                 pIBase->Release(pIBase); \
                 if (pIBase->Release(pIBase) == 0) /* The object will be deleted here! */ \
                    pICmpLog = NULL; \
            } \
        } \
        if (pICMUtils != NULL) \
        { \
            pIBase = (IBase *)pICMUtils->QueryInterface(pICMUtils, ITFID_IBase, &exitResult); \
            if (pIBase != NULL) \
            { \
                 pIBase->Release(pIBase); \
                 if (pIBase->Release(pIBase) == 0) /* The object will be deleted here! */ \
                    pICMUtils = NULL; \
            } \
        } \
    }
#else
    #define INIT_STMT
    #define INIT_LOCALS_STMT
    #define EXIT_STMT
#endif')
')


% -----------------------------
% The next lines causes the CREATE_IMPORT_STMT, CREATE_EXPORT_STMT
% and CREATE_INIT_STMT function to be called after all input has been read
% -----------------------------
m4wrap(`
CREATE_EXPORT_STMT

#if defined(STATIC_LINK)
    #define EXPORT_STMT\
    {\
        RTS_RESULT ExpResult;\
        if (NULL == s_pfCMRegisterAPI)\
            return ERR_NOTINITIALIZED;\
        ExpResult = s_pfCMRegisterAPI(s_ExternalsTable, 0, 1, COMPONENT_ID);\
        if (ERR_OK != ExpResult)\
            return ExpResult;\
    }
#else
    #define EXPORT_STMT\
    {\
        RTS_RESULT ExpResult;\
        if (NULL == s_pfCMRegisterAPI)\
            return ERR_NOTINITIALIZED;\
        ExpResult = s_pfCMRegisterAPI(s_ExternalsTable, 0, 1, COMPONENT_ID);\
        if (ERR_OK != ExpResult)\
            return ExpResult;\
        ExpResult = s_pfCMRegisterAPI(s_ItfTable, 0, 0, COMPONENT_ID);\
        if (ERR_OK != ExpResult)\
            return ExpResult;\
    }
#endif

')
m4wrap(`
CREATE_IMPORT_STMT
')
m4wrap(`
CREATE_INIT_STMT
')


% -----------------------------
% Generate an "#include " directive, 
% replacing the extension ".m4" with ".h"
% -----------------------------
define(`GET_INCLUDE_FILE', `ifelse(`-1',regexp(`$1',`\.m4$'),`error(`m4:'__file__`('__line__`):The first parameter "'$1`" is not a .m4 file')',dnl
`/**
 * \file 'patsubst(`$1',`\.m4$',`\.h')`
 */')')

define(`GEN_INCLUDE', dnl
`ifelse(`-1',regexp(`$1',`\.m4$'), dnl
        `error(`m4:'__file__`('__line__`):The first parameter "'$1`" is not a .m4 file
              ')',dnl
$1,`CmpLogItf.m4', `/*Obsolete include: CmpLogItf.m4*/',dnl
$1,`CMUtilsItf.m4', `/*Obsolete include: CMUtilsItf.m4*/',dnl
`#include "patsubst(`$1',`\.m4$',`\.h')"')')

define(`GEN_INIT_STMT', `pushdef(`__INITS',ifelse($1,`CMUtils',`/*Obsolete include CMUtils*/ \
		',
		$1,`CmpLog',`/*Obsolete include CmpLog*/ \
		',
`if (pI$1 == NULL && s_pfCMCreateInstance != NULL) \
        { \
            pIBase = (IBase *)s_pfCMCreateInstance(CLASSID_C$1, &initResult); \
            if (pIBase != NULL) \
            { \
                pI$1 = (I$1 *)pIBase->QueryInterface(pIBase, ITFID_I$1, &initResult); \
                pIBase->Release(pIBase); \
            } \
        } \
        '))')
        
define(`GEN_INIT_LOCALS_STMT', `pushdef(`__INIT_LOCALS',`ifelse($1,`CMUtils',`/*Obsolete include CMUtils*/ \
		',
$1,`CmpLog',`/*Obsolete include CmpLog*/ \
		',
`pI$1 = NULL; \
        ')')')
        
define(`GEN_EXIT_STMT', `pushdef(`__EXITS',`ifelse($1,`CMUtils',`/*Obsolete include CMUtils*/ \
		',
$1,`CmpLog',`/*Obsolete include CmpLog*/ \
		',
`if (pI$1 != NULL) \
        { \
            pIBase = (IBase *)pI$1->QueryInterface(pI$1, ITFID_IBase, &exitResult); \
            if (pIBase != NULL) \
            { \
                 pIBase->Release(pIBase); \
                 if (pIBase->Release(pIBase) == 0) /* The object will be deleted here! */ \
                    pI$1 = NULL; \
            } \
        } \
        ')')')

define(`GEN_USED_INTERFACES', dnl
`ifelse(`-1',regexp(`$1',`\.m4$'), dnl
		`error(`m4:'__file__`('__line__`):The first parameter "'$1`" is not a .m4 file
              ')',dnl
`GEN_INCLUDE($1)'dnl
`GEN_INIT_STMT(`'patsubst(`$1',`\Itf.m4$',`'))'dnl
`GEN_INIT_LOCALS_STMT(`'patsubst(`$1',`\Itf.m4$',`'))'dnl
`GEN_EXIT_STMT(`'patsubst(`$1',`\Itf.m4$',`'))')dnl
')

% -----------------------------
% All variations of DEF_*_API
% Depending on the Variable DEF_CPP,
% we are adding them to __EXPORTS or __EXPORTS_CPP.
% -----------------------------
define(`PUSH_ITF', dnl
`ifdef(`DEF_CPP', dnl
`pushdef(`__EXPORTS_CPLUSPLUS_ONLY',`       \
        if (ERR_OK != EXP_`'_COMPONENT_NAME`'$3) \
        {\
            if (CHK_LogAdd)\
                (void)CAL_LogAdd(STD_LOGGER, COMPONENT_ID, LOG_ERROR, ERR_FAILED, 0, "Export of ApiFunction [$3] failed\n"); \
            return ERR_FAILED;\
        }')'
, dnl
`pushdef(`__EXPORTS_EXTREF',`ifelse(`$5',1,`ifelse(`$8',1,`', `{ (RTS_VOID_FCTPTR)$3, "$3", ifelse(eval($#>5),1,$6,0), ifelse(eval($#>6),1,$7,0) },\
        ')',`')')' dnl
`pushdef(`__EXPORTS_EXTREF2',`ifelse(`$8',1,`{ (RTS_VOID_FCTPTR)$3, "$3", $6, $7 }, \
        ',`')')' dnl
`pushdef(`__EXPORTS',`ifelse(`$5',1,`',`{ (RTS_VOID_FCTPTR)$3, "$3", 0, 0 },\
        ')')' dnl
)' dnl
)

define(`PUSH_CLASS_ITF', dnl
`ifdef(`DEF_CPP', dnl
`pushdef(`__EXPORTS_CPLUSPLUS_ONLY',`       \
        if (ERR_OK != EXP_`'_COMPONENT_NAME`'$3) \
        {\
            if (CHK_LogAdd)\
                (void)CAL_LogAdd(STD_LOGGER, COMPONENT_ID, LOG_ERROR, ERR_FAILED, 0, "Export of ApiFunction [$3] failed\n"); \
            return ERR_FAILED;\
        }')'
, dnl
`pushdef(`__EXPORTS_EXTREF',`ifelse(`$5',1,`ifelse(`$8',1,`',`{ (RTS_VOID_FCTPTR)$3, "$3",ifelse(eval($#>5),1,$6,0),ifelse(eval($#>6),1,$7,0)},\
        ')',`')')' dnl
`pushdef(`__EXPORTS_EXTREF2',`ifelse(`$8',1,`{ (RTS_VOID_FCTPTR)$3, "$3", $6, $7 }, \
        ',`')')' dnl
`pushdef(`__EXPORTS',`')' dnl
)' dnl
)



define(`DEF_API', dnl
`PUSH_ITF($@)' dnl
)

define(`DEF_STATIC_API',
`PUSH_ITF($@)' dnl
)

define(`DEF_CREATEITF_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_DELETEITF_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_HANDLEITF_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_HANDLEITF_API2',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_HANDLEITF_API_OWNCPP',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_CREATECLASSITF_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_CREATECLASSITF2_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_PRODUCECLASSITF_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_PRODUCECLASSITF_API_OWNCPP',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_DELETECLASSITF_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_DELETECLASSITF2_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_CLASSITF_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_RETURNHANDLECLASSITF_API',
`PUSH_CLASS_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_HANDLEITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_STATICITF_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        static $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_ITF_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_ITF_API_OWNCPP',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_ITF_API2',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)

define(`DEF_ITF_GLOBAL_API',
`PUSH_ITF($@)' dnl
`divert(DIVERT_CLASSMEMBERS)        virtual $1 $2 `I'$3(_CONCAT(`_MAKE_ITF_PARAMLIST',_TRIM(`$4')));
divert(-1)'
)



define(`SET_INTERFACE_NAME',`
    ifdef(`_IN_IMPLEMENT',`
        pushdef(`_INTERFACE_LIST', `$1')
        pushdef(`_INTERFACECAST_LIST',`
            else if (iid == ITFID_`I'$1)
                pItf = dynamic_cast<`I'$1 *>(this);')',
	`ifelse($1,`CMUtils',`divert(DIVERT_USE)\
	/*obsolete entry ITF_$1*/ dnl divert(-1)',
	$1,`CmpLog',`divert(DIVERT_USE)\
	/*obsolete entry ITF_$1*/ dnl divert(-1)',
	`divert(DIVERT_USE)\
	`ITF_'`$1'dnl')
     ifelse($1,`CMUtils',`divert(DIVERT_USEIMPORT)\
	/*obsolete entry ITF_$1*/ dnl divert(-1)',
	$1,`CmpLog',`divert(DIVERT_USEIMPORT)\
	/*obsolete entry ITF_$1*/ dnl divert(-1)',
	`divert(DIVERT_USEIMPORT)\
	`ITF_'`$1'dnl')	
    ifelse($1,`CMUtils',`divert(DIVERT_USEEXTERN)\
	/*obsolete entry EXTITF_$1*/ dnl divert(-1)',
	$1,`CmpLog',`divert(DIVERT_USEEXTERN)\
	/*obsolete entry EXTITF_$1*/ dnl divert(-1)',
	`divert(DIVERT_USEEXTERN)\
	`EXTITF_'`$1'dnl')
    divert(-1)')
')

define(`WRITE_INTERFACE_LIST2',`ifdef(`_INTERFACE_LIST',`, public `I'_INTERFACE_LIST popdef(`_INTERFACE_LIST')WRITE_INTERFACE_LIST2')')
define(`WRITE_INTERFACE_LIST',`ifdef(`_INTERFACE_LIST',`define(`_FIRST_INTERFACE_NAME',_INTERFACE_LIST)public `I'_INTERFACE_LIST popdef(`_INTERFACE_LIST')WRITE_INTERFACE_LIST2')')

define(`WRITE_INTERFACE_CASTS',`ifdef(`_INTERFACECAST_LIST',`_INTERFACECAST_LIST popdef(`_INTERFACECAST_LIST')WRITE_INTERFACE_CASTS')')


define(`TASK',`#ifndef RTS_TASKNAME_`'_UPPERCASE($1)
    #define RTS_TASKNAME_`'_UPPERCASE($1)           "$1"
#endif
#ifndef RTS_TASKPRIO_`'_UPPERCASE($1)
    #define RTS_TASKPRIO_`'_UPPERCASE($1)           $2
#endif
ifelse($3,`',`', `#ifndef RTS_TASKGROUP_`'_UPPERCASE($1)
	#define RTS_TASKGROUP_`'_UPPERCASE($1)          $3
#endif')
')

define(`TASKPREFIX',`#ifndef RTS_TASKPREFIX_`'_UPPERCASE($1)
    #define RTS_TASKPREFIX_`'_UPPERCASE($1)         "$1"
#endif
#ifndef RTS_TASKPRIO_`'_UPPERCASE($1)
    #define RTS_TASKPRIO_`'_UPPERCASE($1)           $2
#endif
ifelse($3,`',`', `#ifndef RTS_TASKGROUP_`'_UPPERCASE($1)
	#define RTS_TASKGROUP_`'_UPPERCASE($1)          $3
#endif')
')

define(`TASKPLACEHOLDER',`#ifndef RTS_TASKPLACEHOLDER_`'_UPPERCASE($1)
    #define RTS_TASKPLACEHOLDER_`'_UPPERCASE($1)    ""
#endif
#ifndef RTS_TASKPRIO_`'_UPPERCASE($1)
    #define RTS_TASKPRIO_`'_UPPERCASE($1)           $2
#endif
ifelse($3,`',`', `#ifndef RTS_TASKGROUP_`'_UPPERCASE($1)
	#define RTS_TASKGROUP_`'_UPPERCASE($1)          $3
#endif')
')


% -----------------------------
% Get all interfaces, which are implemented by this component.
% Differentiate between C++ and C Interfaces.
% -----------------------------
define(`DO_IMPLEMENT_ITF',`
GET_INCLUDE_FILE($1)
GEN_INCLUDE($1)
ifelse(`$#',1,`',`DO_IMPLEMENT_ITF(shift($@))')
divert(-1)
include($1)
divert
')


define(`IMPLEMENT_QUERY_INTERFACE',`define(`QUERY_INTERFACE', `$1')')

define(`IMPLEMENT_ITF',dnl
`undefine(`DEF_CPP')'dnl
`IMPLEMENT_ITF_AS(``C'_COMPONENT_NAME', $@)'
)
define(`IMPLEMENT_CPP_ITF', 
`define(`DEF_CPP')'
`undefine(`_INTERFACE_LIST')undefine(`_INTERFACECAST_LIST')undefine(`_FIRST_INTERFACE_NAME')define(`_IN_IMPLEMENT')define(`_INTERFACE_LIST_INIT')'
`DO_IMPLEMENT_ITF($@)'
)
define(`IMPLEMENT_ITF_AS',
`ifdef(`_INTERFACE_LIST_INIT', `',
`undefine(`_INTERFACE_LIST')undefine(`_INTERFACECAST_LIST')undefine(`_FIRST_INTERFACE_NAME')'
)'
`define(`_IN_IMPLEMENT')define(`_INTERFACE_LIST_INIT')'
`
DO_IMPLEMENT_ITF(shift($@))
divert(DIVERT_CLASSDEF)
class $1 : WRITE_INTERFACE_LIST
{
    public:
        $1`() : h'_COMPONENT_NAME`'(RTS_INVALID_HANDLE), iRefCount(0)
        {
        }
        virtual ~$1`()'
        {
        }
        virtual unsigned long AddRef(IBase *pIBase = NULL)
        {
            iRefCount++;
            return iRefCount;
        }
        virtual unsigned long Release(IBase *pIBase = NULL)
        {
            iRefCount--;
            if (iRefCount == 0)
            {
                delete this;
                return 0;
            }
            return iRefCount;
        }

        ifdef(`QUERY_INTERFACE', `QUERY_INTERFACE', `
        virtual void* QueryInterface(IBase *pIBase, ITFID iid, RTS_RESULT *pResult)
        {
            void *pItf;
            if (iid == ITFID_IBase)
                pItf = dynamic_cast<IBase *>((`I'_FIRST_INTERFACE_NAME *)this);dnl
            WRITE_INTERFACE_CASTS
            else
            {
                if (pResult != NULL)
                    *pResult = ERR_NOTIMPLEMENTED;
                return NULL;
            }
            if (pResult != (RTS_RESULT *)1)
                (reinterpret_cast<IBase *>(pItf))->AddRef();
            if (pResult != NULL && pResult != (RTS_RESULT *)1)
                *pResult = ERR_OK;
            return pItf;
        }')
divert(DIVERT_ENDCLASSDEF)
    public:
        RTS_HANDLE h`'_COMPONENT_NAME;
        int iRefCount;
};
divert(-1)
define(`DIVERT_CLASSDEF',eval(DIVERT_CLASSDEF+3))
define(`DIVERT_CLASSMEMBERS',eval(DIVERT_CLASSMEMBERS+3))
define(`DIVERT_ENDCLASSDEF',eval(DIVERT_ENDCLASSDEF+3))
undefine(`_IN_IMPLEMENT')
divert
')

%define(`IMPLEMENT_ITF', `
%divert(-1)
%include($1)
%divert')

define(`GENERATE_ITF_MACRO', `divert(DIVERT_USE)\
    `ITF_'`$1' dnl
divert(-1)')

define(`USE_ITF', `GEN_USED_INTERFACES($1)
divert(-1)
pushdef(`DEF_API',`')
pushdef(`DEF_STATIC_API',`')
pushdef(`DEF_CREATEITF_API',`')
pushdef(`DEF_DELETEITF_API',`')
pushdef(`DEF_HANDLEITF_API',`')
pushdef(`DEF_HANDLEITF_API2',`')
pushdef(`DEF_HANDLEITF_API_OWNCPP',`')
pushdef(`DEF_CREATECLASSITF_API',`')
pushdef(`DEF_CREATECLASSITF2_API',`')
pushdef(`DEF_PRODUCECLASSITF_API',`')
pushdef(`DEF_PRODUCECLASSITF_API_OWNCPP',`')
pushdef(`DEF_DELETECLASSITF_API',`')
pushdef(`DEF_DELETECLASSITF2_API',`')
pushdef(`DEF_CLASSITF_API',`')
pushdef(`DEF_RETURNHANDLECLASSITF_API',`')
pushdef(`DEF_STATICITF_API',`')
pushdef(`DEF_ITF_API',`')
pushdef(`DEF_ITF_API_OWNCPP',`')
pushdef(`DEF_ITF_API2',`')
pushdef(`DEF_ITF_GLOBAL_API',`')
include($1)
popdef(`DEF_API')
popdef(`DEF_STATIC_API')
popdef(`DEF_CREATEITF_API')
popdef(`DEF_DELETEITF_API')
popdef(`DEF_HANDLEITF_API')
popdef(`DEF_HANDLEITF_API_OWNCPP')
popdef(`DEF_HANDLEITF_API2')
popdef(`DEF_CREATECLASSITF_API')
popdef(`DEF_CREATECLASSITF2_API')
popdef(`DEF_PRODUCECLASSITF_API')
popdef(`DEF_PRODUCECLASSITF_API_OWNCPP')
popdef(`DEF_DELETECLASSITF_API')
popdef(`DEF_DELETECLASSITF2_API')
popdef(`DEF_RETURNHANDLECLASSITF_API')
popdef(`DEF_CLASSITF_API')
popdef(`DEF_STATICITF_API')
popdef(`DEF_ITF_API2')
popdef(`DEF_ITF_API')
popdef(`DEF_ITF_API_OWNCPP')
popdef(`DEF_ITF_GLOBAL_API')
divert
')

define(`DOUSE', `divert(DIVERT_USE) \
    ifelse($1,`CMUtlMemCpy',`/*obsolete USE_$1*/',
	$1,`LogAdd',`/*obsolete USE_$1*/',
	USE_$1) dnl
    divert(DIVERT_USEIMPORT) \
    ifelse($1,`CMUtlMemCpy',`/*obsolete USE_$1*/',
	$1,`LogAdd',`/*obsolete USE_$1*/',
	USE_$1) dnl
    divert(DIVERT_USEEXTERN) \
    ifelse($1,`CMUtlMemCpy',`/*obsolete USE_$1*/',
	$1,`LogAdd',`/*obsolete EXT_$1*/',
	EXT_$1) dnl
divert')


define(`DOIMPORT_REQ', `pushdef(`__IMPORTS',`ifelse($1,`LogAdd', `/*Obsolete required include LogAdd*/ \
		',dnl
$1,`CMUtlMemCpy', `/*Obsolete required include CMUtlMemCpy*/ \
		',
`if (ERR_OK == importResult ) importResult = GET_$1(0);\
        ')')')


define(`DOIMPORT_OPT', `pushdef(`__IMPORTS',`ifelse($1,`LogAdd', `/*Obsolete optional include LogAdd*/ \
		',dnl
$1,`CMUtlMemCpy', `/*Obsolete optional include CMUtlMemCpy*/ \
		',
`if (ERR_OK == importResult ) TempResult = GET_$1(CM_IMPORT_OPTIONAL_FUNCTION);\
        ')')')



define(`REQUIRED_IMPORTS', dnl
    `ifelse($1,`', `', dnl
    `_FOREACH(`DOIMPORT_REQ', $@)dnl
     _FOREACH(`DOUSE', $@)dnl
     ')
')
    
define(`OPTIONAL_IMPORTS', dnl
    `ifelse($1,`', `', dnl
    `_FOREACH(`DOIMPORT_OPT', $@) dnl
     _FOREACH(`DOUSE', $@) dnl
     ')
')
changecom(`/*', `*/')
divert