/*
 * this is a special header for the SL extension API!!!
 * <copyright>
 * Copyright (c) 2017-2020 CODESYS Development GmbH, Copyright (c) 1994-2016 3S-Smart Software Solutions GmbH. All rights reserved.
 * </copyright>
 */

#ifndef __CMPITF_H__
#define __CMPITF_H__

#include <stdio.h>

#if defined(WIN32) || defined(_WIN32_WCE)
	#ifdef _USRDLL
		#define DLL_DECL _declspec(dllexport)
	#endif
#endif
#if defined(LINUX) || defined(QNX)
	#ifdef _USRDLL
		#define DLL_DECL __attribute__ ((visibility ("default")))
	#endif
#endif

#if !defined(DLL_DECL)
	#define DLL_DECL
#endif

#ifndef CDECL
	#define CDECL
#endif

#ifndef CDECL_EXT
	#define CDECL_EXT
#endif

#ifndef STDCALL
	#define STDCALL __stdcall
#endif

#if defined(__cplusplus)
	extern "C" {
#endif 


typedef	RTS_UI32	CMPID;		/* Component ID to specify a component. Has the vendor ID as a prefix! */
typedef	RTS_UI32	CLASSID;	/* Class ID to specify a specific class (C or C++) */
typedef	RTS_UI32	OBJID;		/* Object ID, typically the instance index starting with 0 */
typedef	RTS_UI32	ITFID;		/* Interface ID to specify a specific interface (C or C++) */

#define RTS_VENDORID_3S							0x0000
#define RTS_ADDVENDORID(VendorID, ID)			(((RTS_UI32)(VendorID) << 16 & UINT32_C(0xFFFF0000)) + (ID))
#define ADDVENDORID								RTS_ADDVENDORID
#define RTS_GETVENDORID(ID)						((RTS_UI32)(ID) >> 16 & UINT32_C(0x0000FFFF))
#ifdef TRG_64BIT
	#define RTSITF_GET_SIGNATURE(sign32bit, sign64bit)		sign64bit
#else
	#define RTSITF_GET_SIGNATURE(sign32bit, sign64bit)		sign32bit
#endif


/* Function that can be used for all CAL_ macros to return ERR_NOTIMPLEMENTED */
RTS_RESULT CDECL FUNCTION_NOTIMPLEMENTED(unsigned long dummy,...);
RTS_RESULT CDECL FUNCTION_NOTIMPLEMENTED2(void *dummy,...);

/* Structure to handle a mapping of an ID and a name */
typedef struct RTS_ID_TO_NAME_
{
	RTS_UI32 id;
	char *pszName;
} RTS_ID_TO_NAME;


struct tagIBase;

typedef struct
{
	/*pointer to virtual function table*/
	void* __VFTABLEPOINTER;
} instance_struct;

typedef struct
{
	instance_struct *pInstance;
	RTS_IEC_DWORD dwCount;
} addref_struct;

typedef struct
{
	instance_struct *pInstance;
	RTS_IEC_DWORD dwCount;
} release_struct;

typedef struct
{
	instance_struct *pInstance;
	RTS_IEC_DWORD iid;
	RTS_IEC_RESULT *pResult;
	instance_struct **ppInterface;
} queryinterface_struct;

typedef unsigned long (CDECL *PF_ADDREF)(struct tagIBase *pIBase);
typedef unsigned long (CDECL *PF_RELEASE)(struct tagIBase *pIBase);
typedef void *(CDECL *PF_QUERYINTERFACE)(struct tagIBase *pIBase, ITFID iid, RTS_RESULT *pResult);

typedef void (CDECL *PF_IEC_ADDREF)(void);
typedef void (CDECL *PF_IEC_RELEASE)(void);
typedef void (CDECL *PF_IEC_QUERYINTERFACE)(void);

/* <SIL2/> */
typedef struct tagIBase
{
	int bIEC;
	int iRefCount;
	RTS_HANDLE hInstance;
	PF_ADDREF AddRef;
	PF_RELEASE Release;
	PF_QUERYINTERFACE QueryInterface;
	CLASSID ClassId;
} IBase_C;

typedef struct tagIBase_IEC
{
	int bIEC;
	int iRefCount;
	RTS_HANDLE hInstance;
	PF_IEC_ADDREF *AddRef;
	PF_IEC_RELEASE *Release;
	PF_IEC_QUERYINTERFACE *QueryInterface;
} IBase_IEC;


#ifndef STATICITF
	#define STATICITF		static
#endif

#ifndef STATICITF_DEF
	#define STATICITF_DEF
#endif

#if defined(CPLUSPLUS) && defined(__cplusplus)
	class IBase
	{
		public:
			virtual	unsigned long AddRef(IBase *pIBase = NULL) =0;
			virtual	unsigned long Release(IBase *pIBase = NULL) =0;
			virtual	void *QueryInterface(IBase *pIBase = NULL, ITFID iid = 0, RTS_RESULT *pResult = NULL) =0;
			virtual ~IBase() { };
	};

	#define DECLARE_ADDREF()\
	virtual unsigned long AddRef(IBase *pIBase = NULL);

	#define IMPLEMENT_ADDREF()\
	virtual unsigned long AddRef(IBase *pIBase = NULL)\
	{\
		iRefCount++;\
		return iRefCount;\
	}

	#define DECLARE_RELEASE()\
	virtual unsigned long Release(IBase *pIBase = NULL);

	#define IMPLEMENT_RELEASE()\
	virtual unsigned long Release(IBase *pIBase = NULL)\
	{\
		iRefCount--;\
		if (iRefCount == 0)\
		{\
			delete this;\
			return 0;\
		}\
		return iRefCount;\
	}

	#define IMPLEMENT_RELEASE_NODELETE()\
	virtual unsigned long Release(IBase *pIBase = NULL)\
	{\
		iRefCount--;\
		if (iRefCount == 0)\
		{\
			return 0;\
		}\
		return iRefCount;\
	}
#else
	#define DECLARE_ADDREF\
	static unsigned long CDECL AddRef(struct tagIBase *pIBase);

	#define IMPLEMENT_ADDREF\
	static unsigned long CDECL AddRef(struct tagIBase *pIBase)\
	{\
		return (pIBase ? ++pIBase->iRefCount : 0);\
	}

	#define DECLARE_RELEASE\
	static unsigned long CDECL Release(struct tagIBase *pIBase);

	#define IMPLEMENT_RELEASE\
	static unsigned long CDECL Release(struct tagIBase *pIBase)\
	{\
		return (pIBase ? --pIBase->iRefCount : 0);\
	}

	#define DECLARE_QUERYINTERFACE\
	static void *CDECL QueryInterface(IBase *pBase, ITFID iid, RTS_RESULT *pResult);
	
	typedef IBase_C		IBase;
#endif

/* Global function pointer declarations */
typedef int (CDECL *PF_EXPORT_FUNCTIONS)(void);
typedef int (CDECL *PF_IMPORT_FUNCTIONS)(void);
typedef RTS_UI32 (CDECL *PF_GET_VERSION)(void);
typedef RTS_RESULT (CDECL *PF_HOOK_FUNCTION)(RTS_UI32 ulHook, RTS_UINTPTR ulParam1, RTS_UINTPTR ulParam2);
/* typedef RTS_RESULT (CDECL *PF_REGISTER_API)(const char *pszAPIName, RTS_VOID_FCTPTR pfAPIFunction, int bExternalLibrary, RTS_UI32 ulSignatureID); */
typedef RTS_RESULT (CDECL *PF_REGISTER_API)(const CMP_EXT_FUNCTION_REF *pExpTable, RTS_UINTPTR dummy, int bExternalLibrary, RTS_UI32 cmpId);
typedef RTS_RESULT (CDECL *PF_GET_API)(char *pszAPIName, RTS_VOID_FCTPTR *ppfAPIFunction, RTS_UI32 ulSignatureID);
typedef RTS_RESULT (CDECL *PF_REGISTER_API2)(const char *pszAPIName, RTS_VOID_FCTPTR pfAPIFunction, int bExternalLibrary, RTS_UI32 ulSignatureID, RTS_UI32 ulVersion);
typedef RTS_RESULT (CDECL *PF_GET_API2)(char *pszAPIName, RTS_VOID_FCTPTR *ppfAPIFunction, int bExternalLibrary, RTS_UI32 ulSignatureID, RTS_UI32 ulVersion);
typedef RTS_RESULT (CDECL *PF_CALL_HOOK)(RTS_UI32 ulHook, RTS_UINTPTR ulParam1, RTS_UINTPTR ulParam2, int bReverse);
typedef IBase* (CDECL *PF_CREATEINSTANCE)(CLASSID cid, RTS_RESULT *pResult);
typedef RTS_RESULT (CDECL *PF_DELETEINSTANCE)(IBase *pIBase);
typedef RTS_HANDLE (CDECL *PF_REGISTER_CLASS)(CMPID CmpId, CLASSID ClassId);
typedef RTS_RESULT (CDECL *PF_DELETEINSTANCE2)(CLASSID ClassId, IBase *pIBase);

typedef struct tagINIT_STRUCT
{
	/* Exported by Component */
	CMPID CmpId;
#ifdef TRG_64BIT
	RTS_UI32 aligndummy;
#endif
	PF_EXPORT_FUNCTIONS pfExportFunctions;
	PF_IMPORT_FUNCTIONS pfImportFunctions;
	PF_GET_VERSION pfGetVersion;
	PF_CREATEINSTANCE pfCreateInstance;
	PF_DELETEINSTANCE pfDeleteInstance;
	PF_HOOK_FUNCTION pfHookFunction;
	
	/* Import from CM */
	PF_REGISTER_API pfCMRegisterAPI;
	PF_GET_API pfCMGetAPI;
	PF_CALL_HOOK pfCMCallHook;
	PF_REGISTER_CLASS pfCMRegisterClass;
	PF_CREATEINSTANCE pfCMCreateInstance;
	PF_REGISTER_API2 pfCMRegisterAPI2;
	PF_GET_API2 pfCMGetAPI2;
	PF_DELETEINSTANCE2 pfCMDeleteInstance2;
} INIT_STRUCT;

#define COMPONENT_ENTRY_NAME	"ComponentEntry"

#if defined(CPLUSPLUS) && defined(__cplusplus)
extern "C" {
#endif

#if !defined(STATIC_LINK) && !defined(MIXED_LINK) && !defined(DYNAMIC_LINK) && !defined(CPLUSPLUS_STATIC_LINK)
	DLL_DECL int CDECL ComponentEntry(INIT_STRUCT *pInitStruct);
#endif
typedef int (CDECL *PF_COMPONENT_ENTRY)(INIT_STRUCT *pInitStruct);

#if defined(CPLUSPLUS) && defined(__cplusplus)
}
#endif


/* Functions exported from main */
RTS_RESULT CDECL MainLoadComponent(char *pszName, char *pszPath, RTS_HANDLE *phModule, PF_COMPONENT_ENTRY* ppfComponentEntry);
RTS_RESULT CDECL MainUnloadComponent(char *pszName, RTS_HANDLE hModule);


/* The following functions are always offered by the component manager */
int CDECL MainExitLoop(RTS_UINTPTR ulPar);
typedef int (CDECL *PFMAINEXITLOOP)(RTS_UINTPTR ulPar);
#ifdef STATIC_LINK
	#define USE_CMExitLoop		extern int CDECL MainExitLoop(RTS_UINTPTR ulPar);
	#define EXT_CMExitLoop		extern int CDECL MainExitLoop(RTS_UINTPTR ulPar);
	#define GET_CMExitLoop		ERR_OK
	#define CAL_CMExitLoop		MainExitLoop
	#define CHK_CMExitLoop		TRUE
	#define EXP_CMExitLoop		TRUE
#else /* DYNAMIC_LINK */
	#define USE_CMExitLoop		PFMAINEXITLOOP pfMainExitLoop;
	#define EXT_CMExitLoop		extern PFMAINEXITLOOP pfMainExitLoop;
	#define GET_CMExitLoop		s_pfGetAPI("CMExitLoop", (void **)&pfMainExitLoop, 0)
	#define CAL_CMExitLoop		pfMainExitLoop
	#define CHK_CMExitLoop		(pfMainExitLoop != NULL)
	#define EXP_CMExitLoop		s_pfRegisterAPI("CMExitLoop", MainExitLoop, 1, 0)
#endif

/**
 * <description>Hook definitions to inform all components with a broadcast via HookFunction() ([0..10000] reserved for core components):
 * <ul>
 *		<li>CH_INIT_XXX Hooks: Used for initialization of all components.
 *							Future range, not yet defined! = [1..1000]</li>
 *		<li>CH_EXIT_XXX Hooks: Used for deinitialization of all components.
 *							Future range, not yet defined! = [2000..3000]</li>
 *		<li>CH_XXX Hooks: Used for broadcast commands (e.g. cyclic operations).
 *							Future range, not yet defined! = [4000..5000]</li>
 * </ul>
 *	IMPLEMENTATION NOTE:
 *	Future hooks should be defined in the appropriate range above!
 * </description>
 */

/*
	 CH_INIT_XXX Hooks: Used for initialization of all components.
 */
#define CH_INIT_SYSTEM						1
/*	First call at system startup to initialize all system components.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_SYSTEM2						8
/*	Second call at system startup to initialize all system components.
    (used to resolve dependencies between core components)
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT								2
/*	First call at system startup. Compontents should initialize all local variables.
	ulParam1: Pointer to int. Parameter name=pbDontCallInitHooksFromCMInit. Content can be set as followed:
			0 [Default]: CMInitEnd() is called at the end of CMInit().
			1: CMInitEnd (calling hooks from CH_INIT2 to CH_INIT_COMM) can be called asynchronously by your own
			   component and is not called in the context of CMInit()!
	ulParam2: Not used
*/

#define CH_POST_INIT						200
/*	Called right after CH_INIT. Use this hook to run initialization between 
 	highly related components (e.g. Register backends or providers to the corresponding components.).

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_PRE_INIT2						250
/*	Called right before CH_INIT2. Use this hook to finish initialization of a component that is highly
	related to an other components. E.g. finish initialization after the providers have registered.

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT2							3
/*	Called after CH_INIT. All components are initialized. Other components can be used.

	NOTE:
	Events must be created of the provider in this init step!

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_DONE						CH_INIT2
/* Backward compatibility */

#define CH_PRE_INIT3						7
/*	Called after CH_INIT2 and before CH_INIT3. All components are initialized. Other components can be used.
	ulParam1: Not used
	ulParam2: Not used
*/
#define CH_INIT201							CH_PRE_INIT3
/* Backward compatibility */

#define CH_INIT3							4
/*	Called after CH_INIT201. All components are initialized. Other components can be used.

	NOTE:
	Event callbacks must be registered by the consumer in this init step! Events are created in CH_INIT2.

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_SYSTEM_TASKS				500
/*	Called after CH_INIT3. Tasks can be started that are relevant for the IEC applications.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_TASKS						5
/*	Called after CH_INIT_SYSTEM_TASKS. All components should start their tasks.

	NOTE:
	The IEC bootprojects are loaded here!

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_COMM						6
/*	Called after CH_INIT_TASKS. Communication can be started at this point, because all
	components are ready and running.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_INIT_FINISHED					1000
/*	Called at the end of the complete initialization sequence. This is called after CH_INIT_COMM and right before the runtime system
	fall into the cyclic CH_COMM_CYCLE state.

	NOTE:
	The IEC bootprojects are started here!

	ulParam1: Not used
	ulParam2: Not used
*/

/*
	CH_EXIT_XXX Hooks: Used for deinitialization of all components.
*/

#define CH_EXIT_COMM						10
/*	Called at the beginning of the shutdown sequence to disable all communication channels!
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT_TASKS						11
/*	Called before CH_EXIT_SYSTEM_TASKS to stop and remove all tasks that are not needed by the IEC application.

	NOTE:
	IEC applications are unloaded here.

	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT_SYSTEM_TASKS				2200
/*	Called before CH_EXIT3 to stop and remove all running tasks, because at CH_EXIT3 all objects are released and
	so no task must run after this point.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT3							12
/*	Called before CH_EXIT2 to store data (e.g. retain data).
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT2							13
/*	Called before CH_EXIT to store data (e.g. retain data).
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_PRE_EXIT							CH_EXIT2
/* Backward compatibility */

#define CH_EXIT								14
/*	Here all memory of the components should be released.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT_SYSTEM2						17
/*	Counter part to CH_INIT_SYSTEM2.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT_SYSTEM						15
/*	Called at the end of the shutdown process for the system components to release memory.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_EXIT_GARBAGEMEMORY				16
/*	This is the final call for the garbage collector to check, if heap memory was not released.
	ulParam1: Not used
	ulParam2: Not used
*/

/*
	CH_XXX Hooks: Used for broadcast commands (e.g. cyclic operations). 
 */
#define CH_COMM_CYCLE						20
/*	Called every main cycle period. Can be used for background executions.
	ulParam1: Not used
	ulParam2: Not used
*/

#define CH_ON_IMPORT						23
/*	Called for components to import new functions from a new loaded component
	ulParam1: char *: Pointer to component name
	ulParam2: Not used
*/

#define CH_ON_IMPORT_RELEASE				24
/*	Called for components to release imported functions from a component that will be unloaded
	ulParam1: char *: Pointer to component name
	ulParam2: Not used
*/

#define CH_ON_LOAD_COMPONENT				25
/*	Called after loading a new component
	ulParam1: char *: Pointer to component name
	ulParam2: Not used
*/

#define CH_ON_UNLOAD_COMPONENT				26
/*	Called before unloading a component
	ulParam1: char *: Pointer to component name
	ulParam2: Not used
*/

#define CH_ON_REGISTER_INSTANCE				27
/*	Called after register a new instance
	ulParam1: CLASSID: ClassId of instance
	ulParam2: IBase *: Pointer to IBase
*/

#define CH_ON_UNREGISTER_INSTANCE			28
/*	Called before unregister a new instance
	ulParam1: CLASSID: ClassId of instance
	ulParam2: IBase *: Pointer to IBase
*/

#define CH_ON_LICENSE_FCTS_REGISTERED		29
/*
	Called after the functionpointers from the license-library 
	have been registered to the runtime.
*/

#define CH_ON_LICENSE_FCTS_REGISTERED2		290
/*
	Called after CH_ON_LICENSE_FCTS_REGISTERED.
*/

#define CH_ON_LICENSE_FCTS_LEGACY_REGISTERED 30
/*
	Called after the functionpointers from the license-library 
	have been registered to the runtime.
*/

#define CH_SAFEMODE							4000
/*
	Called when a component fails to resolve its required import functions during startup of the runtime system. In this case, the system is not stable any more.
	Every component should check safety.
	After entering the safemode, at least the communication should work and so for example a service engineer can investigate the reason for this error.
	The logger should work too.

	IMPORTANT NOTE:
	It is important, that the IEC-application(s) are not loaded or at least are not started after entering the safemode! This is still implemented in the CmpApp component.
	
	ulParam1: Not used
	ulParam2: Not used
*/

/**
* <category>Hook table</category>
* <description>
*	This is the table of all hooks with its corresponding name (see CM_HOOK_TABLE).
*
*	NOTE:
*	The init and exit hooks are defined here in the order they are executed during startup and shutdown!
*
* </description>
*/
#define CM_INIT_HOOK_TABLE				{ CH_INIT_SYSTEM,  "CH_INIT_SYSTEM" },\
										{ CH_INIT_SYSTEM2, "CH_INIT_SYSTEM2" },\
										{ CH_INIT, "CH_INIT" },\
										{ CH_POST_INIT, "CH_POST_INIT" },\
										{ CH_PRE_INIT2, "CH_PRE_INIT2" },\
										{ CH_INIT2, "CH_INIT2" },\
										{ CH_PRE_INIT3, "CH_PRE_INIT3" },\
										{ CH_INIT3, "CH_INIT3" },\
										{ CH_INIT_SYSTEM_TASKS, "CH_INIT_SYSTEM_TASKS" },\
										{ CH_INIT_TASKS, "CH_INIT_TASKS" },\
										{ CH_INIT_COMM, "CH_INIT_COMM" },\
										{ CH_INIT_FINISHED, "CH_INIT_FINISHED" }

#define CM_COMM_CYCLE_HOOK				{ CH_COMM_CYCLE, "CH_COMM_CYCLE" }

#define CM_EXIT_HOOK_TABLE				{ CH_EXIT_COMM, "CH_EXIT_COMM" },\
										{ CH_EXIT_TASKS, "CH_EXIT_TASKS" },\
										{ CH_EXIT_SYSTEM_TASKS, "CH_EXIT_SYSTEM_TASKS" },\
										{ CH_EXIT3, "CH_EXIT3" },\
										{ CH_EXIT2, "CH_EXIT2" },\
										{ CH_EXIT, "CH_EXIT" },\
										{ CH_EXIT_SYSTEM2, "CH_EXIT_SYSTEM2" },\
										{ CH_EXIT_SYSTEM, "CH_EXIT_SYSTEM" },\
										{ CH_EXIT_GARBAGEMEMORY, "CH_EXIT_GARBAGEMEMORY" }

#define CM_EXTENDED_HOOK_TABLE			{ CH_ON_IMPORT, "CH_ON_IMPORT" }, \
										{ CH_ON_IMPORT_RELEASE, "CH_ON_IMPORT_RELEASE" }, \
										{ CH_ON_LOAD_COMPONENT, "CH_ON_LOAD_COMPONENT" }, \
										{ CH_ON_UNLOAD_COMPONENT, "CH_ON_UNLOAD_COMPONENT" }, \
										{ CH_ON_REGISTER_INSTANCE, "CH_ON_REGISTER_INSTANCE" }, \
										{ CH_ON_UNREGISTER_INSTANCE, "CH_ON_UNREGISTER_INSTANCE" }, \
										{ CH_ON_LICENSE_FCTS_REGISTERED, "CH_ON_LICENSE_FCTS_REGISTERED" }, \
										{ CH_ON_LICENSE_FCTS_REGISTERED2, "CH_ON_LICENSE_FCTS_REGISTERED2" }, \
										{ CH_ON_LICENSE_FCTS_LEGACY_REGISTERED, "CH_ON_LICENSE_FCTS_LEGACY_REGISTERED" }, \
										{ CH_SAFEMODE, "CH_SAFEMODE" } \

#define CM_HOOK_TABLE					{\
											CM_INIT_HOOK_TABLE,\
											CM_COMM_CYCLE_HOOK,\
											CM_EXIT_HOOK_TABLE,\
											CM_EXTENDED_HOOK_TABLE\
										}

/**
 * <category>Single import of interface functions</category>
 * <description>
 *	These macros are used by the System-Components to import single interface functions without modifying
 *	the global SysXXXDep.m4 files.
 *
 *	ATTENTION:
 *	With usage of these macros, the RtsConfiguration cannot resolve this dependency anymore!!!
 *	So use these macros only in Sys-Components and not in standard or customer components!
 *
 *	Usage:
 *		#include "<Interface>Itf.h"
 *		USE_SINGLE_ITF(<Interface>) or USE_SINGLE_ITF(<Class>, <Interface>)
 *		USE_SINGLE_FUNCTION(<Function>)
 *	
 *		static int CDECL ImportFunctions(void)
 *		{
 *			IMPORT_SINGLE_ITF(<Interface>);
 *			IMPORT_SINGLE_FUNCTION(<Function>);
 *			return ERR_OK;
 *		}
 * </description>
 */
#ifdef CPLUSPLUS
	#define USE_SINGLE_ITF(Interface_)				ITF_##Interface_

	#define IMPORT_SINGLE_ITF(Interface_) \
	{\
		IBase *pIBase_;\
		RTS_RESULT Result_;\
		if (pI##Interface_ == NULL && s_pfCMCreateInstance != NULL) \
		{ \
			pIBase_ = (IBase *)s_pfCMCreateInstance(CLASSID_C##Interface_, &Result_); \
			if (pIBase_ != NULL) \
			{\
				pI##Interface_ = (I##Interface_ *)pIBase_->QueryInterface(pIBase_, ITFID_I##Interface_, &Result_); \
				pIBase_->Release(pIBase_); \
			}\
		} \
	}

	#define EXIT_SINGLE_ITF(Interface_) \
	{\
        IBase *pIBase_;\
        RTS_RESULT exitResult_;\
        if (pI##Interface_ != NULL) \
        { \
            pIBase_ = (IBase *)pI##Interface_->QueryInterface(pI##Interface_, ITFID_IBase, &exitResult_); \
            if (pIBase_ != NULL && exitResult_ == ERR_OK) \
            { \
                 pIBase_->Release(pIBase_); \
                 if (pIBase_->Release(pIBase_) == 0) /* The object will be deleted here! */ \
                    pI##Interface_ = NULL; \
            } \
        } \
	}

	#define IMPORT_SINGLE_ITF2(Class_, Interface_) \
	{\
		IBase *pIBase_;\
		RTS_RESULT Result_;\
		if (pI##Interface_ == NULL && s_pfCMCreateInstance != NULL) \
		{ \
			pIBase_ = (IBase *)s_pfCMCreateInstance(CLASSID_C##Class_, &Result_); \
			if (pIBase_ != NULL) \
			{\
				pI##Interface_ = (I##Interface_ *)pIBase_->QueryInterface(pIBase_, ITFID_I##Interface_, &Result_); \
				pIBase_->Release(pIBase_); \
			}\
		} \
	}

	#define EXIT_SINGLE_ITF2(Class_, Interface_) \
	{\
        IBase *pIBase_;\
        RTS_RESULT exitResult_;\
        if (pI##Interface_ != NULL) \
        { \
            pIBase_ = (IBase *)pI##Interface_->QueryInterface(pI##Interface_, ITFID_IBase, &exitResult_); \
            if (pIBase_ != NULL && exitResult_ == ERR_OK) \
            { \
                 pIBase_->Release(pIBase_); \
                 if (pIBase_->Release(pIBase_) == 0) /* The object will be deleted here! */ \
                    pI##Interface_ = NULL; \
            } \
        } \
	}
#else
	#define USE_SINGLE_ITF(Interface_)
	#define IMPORT_SINGLE_ITF(Interface_)
	#define EXIT_SINGLE_ITF(Interface_)
	#define IMPORT_SINGLE_ITF2(Class_, Interface_)
	#define EXIT_SINGLE_ITF2(Class_, Interface_)
#endif

#define USE_SINGLE_FUNCTION(Function)			USE_##Function
#define IMPORT_SINGLE_FUNCTION(Function)		GET_##Function(0)
#define EXIT_SINGLE_FUNCTION(Function)


#if defined(__cplusplus)
}
#endif 

#endif	/*__CMPITF_H__*/
