/*
 * this is a special header for the SL extension API!!!
 * <copyright>
 * Copyright (c) 2017-2020 CODESYS Development GmbH, Copyright (c) 1994-2016 3S-Smart Software Solutions GmbH. All rights reserved.
 * </copyright>
 */

#ifndef __RTSSTD_H__
#define __RTSSTD_H__


#if defined(__amd64__)
	#define TRG_X64
	#define TRG_64BIT
#elif defined(__arm__)
	#define TRG_ARM	
#elif defined(__aarch64__)
	#define TRG_ARM	
	#define TRG_64BIT
#elif defined(i386)
	#error "32 bit X86 is not supported!"
#else
	#error "Unknown architecture!"
#endif 

#define LINUX

#define CDECL
#define __cdecl CDECL /*necessary for sqlite in CmpCAAStorage*/
#define STDCALL 
#define HUGEPTR

/****** OS *****/
#define SYSTARGET_OS_LINUX

/*** types ***/
#ifndef STDINT_H_UINTPTR_T_DEFINED
	#define STDINT_H_UINTPTR_T_DEFINED
#endif
typedef unsigned short RTS_WCHAR;
#define RTS_WCHAR_DEFINED

#define INTEL_BYTE_ORDER


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stddef.h>
#include <ctype.h>
#include <math.h>



/**
 * set default register width
 */
#ifndef RTS_REGISTER_WIDTH
    #if defined(TRG_C16X) || defined(TRG_DSP)
        #define RTS_REGISTER_WIDTH 16
    #elif defined(TRG_64BIT) || defined(TRG_IA64)
        #define RTS_REGISTER_WIDTH 64
    #else
        #define RTS_REGISTER_WIDTH 32
    #endif
#endif

#if RTS_REGISTER_WIDTH == 64 && !defined (SIZEOF_LONG)
	#if defined (SYSTARGET_OS_WINDOWS) || defined (SYSTARGET_OS_WINDOWS_RTE) || defined (SYSTARGET_OS_WINDOWS_CE)
		#define SIZEOF_LONG	4
	#else
		#define SIZEOF_LONG	8
	#endif
#endif

#include <stdint.h>

/**
 * Redefine UINT32_C(), INT16_C, ...,
 * as many compilers are defining this in a bad way. They
 * are using type-casts to get the correct data-width. This
 * makes it impossible to use for some pedantic C-Compilers.
 */
#ifdef INT64_C
	#undef INT64_C
#endif
#ifdef UINT64_C
	#undef UINT64_C
#endif
#ifdef INT32_C
	#undef INT32_C
#endif
#ifdef UINT32_C
	#undef UINT32_C
#endif
#ifdef INT16_C
	#undef INT16_C
#endif
#ifdef UINT16_C
	#undef UINT16_C
#endif
#ifdef INT8_C
	#undef INT8_C
#endif
#ifdef UINT8_C
	#undef UINT8_C
#endif

#define INT64_C(x)		(RTS_I64_CONST(x))
#define UINT64_C(x)		(RTS_UI64_CONST(x))
#define INT32_C(x)		(x ## L)
#define UINT32_C(x)		(x ## UL) 
#define INT16_C(x)		(x)
#define UINT16_C(x)		(x ## U)
#define INT8_C(x)		(x)
#define UINT8_C(x)		(x ## U)

#define RTS_IEC_BOOL_C(x)	(x)
#define RTS_IEC_BYTE_C(x)	(UINT8_C(x))
#define RTS_IEC_SINT_C(x)	(INT8_C(x))
#define RTS_IEC_USINT_C(x)	(UINT8_C(x))
#define RTS_IEC_INT_C(x)	(INT16_C(x))
#define RTS_IEC_UINT_C(x)	(UINT16_C(x))
#define RTS_IEC_DINT_C(x)	(INT32_C(x))
#define RTS_IEC_UDINT_C(x)	(UINT32_C(x))
#define RTS_IEC_LINT_C(x)	(INT64_C(x))
#define RTS_IEC_ULINT_C(x)	(UINT64_C(x))
#define RTS_IEC_WORD_C(x)	(UINT16_C(x))
#define RTS_IEC_DWORD_C(x)	(UINT32_C(x))
#define RTS_IEC_LWORD_C(x)	(UINT64_C(x))
#define RTS_IEC_REAL_C(x)	(x)
#define RTS_IEC_LREAL_C(x)	(x)
#ifdef TRG_64BIT
#define RTS_IEC_XINT_C(x)		(INT64_C(x))
#define RTS_IEC_UXINT_C(x)		(UINT64_C(x))
#define RTS_IEC_XWORD_C(x)		(UINT64_C(x))
#else
#define RTS_IEC_XINT_C(x)		(INT32_C(x))
#define RTS_IEC_UXINT_C(x)		(UINT32_C(x))
#define RTS_IEC_XWORD_C(x)		(UINT32_C(x))
#endif

/**
 * Define some more exotic types, which are missing
 * in many versions of stdint.h.
 */
#if !defined(STDINT_H_UINTPTR_T_DEFINED)
/* Note: If your compiler complains about a "redefinition"
 *       or s.th. similar here, you may set the defines
 *       _UINTPTR_T, _PTRDIFF_T, ... in your sysdefines.h.
 */
	#ifndef  _UINTPTR_T
		typedef uint32_t uintptr_t;
		#define _UINTPTR_T
	#endif
	#ifndef  _PTRDIFF_T
		typedef int32_t ptrdiff_t;
		#define _PTRDIFF_T
	#endif
	#ifndef  _INTPTR_T
		typedef ptrdiff_t intptr_t;
		#define _INTPTR_T
	#endif
	#define STDINT_H_UINTPTR_T_DEFINED
#endif	/*!defined(STDINT_H_UINTPTR_T_DEFINED)*/

/* Format modifiers for integral types */
#ifndef ULONG_MAX
#	include <limits.h>
#	ifndef ULONG_MAX
#		error ULONG_MAX does not exist in limits.h!
#	endif
#endif

/*
 * Some basic definitions 
 */

#ifndef NULL
#	define NULL 0L
#endif

#ifndef TRUE
#	define TRUE 1
#endif

#ifndef FALSE
#	define FALSE 0
#endif

/*lint -e666 -e506 */
#ifndef MIN
#	define MIN(x,y)	((x)<(y)?(x):(y))
#endif

#ifndef MAX
#	define MAX(x,y)	((x)>(y)?(x):(y))
#endif

#ifndef RTS_SETRESULT
#	define RTS_SETRESULT(p,r)		do { if(p) *(p)=r; } while(0)
#endif

#ifndef RTS_GETRESULT
#	define RTS_GETRESULT(Return,Result)		(Result == ERR_OK ? (Return) : ((Return) ? Result : Result))
#endif

#ifndef LOWWORD
#	define LOWWORD(p)		((uint16_t)((uint32_t)(p) & 0x0000FFFF))
#endif

#ifndef HIGHWORD
#	define HIGHWORD(p)		((uint16_t)(((uint32_t)(p)>>16) & 0x0000FFFF))
#endif


/* Operations on flags */
#ifndef RTS_SETFLAGS
	#define RTS_SETFLAGS(value, flags)			(value |= (flags))
#endif
#ifndef RTS_SETFLAG
	#define RTS_SETFLAG(value, flag)			RTS_SETFLAGS(value, flag)
#endif

#ifndef RTS_RESETFLAGS
	#define RTS_RESETFLAGS(value, flags)		(value &= ~(flags))
#endif
#ifndef RTS_RESETFLAG
	#define RTS_RESETFLAG(value, flag)			RTS_RESETFLAGS(value, flag)
#endif

#ifndef RTS_HASFLAGS
	#define RTS_HASFLAGS(value, flags)			((value & (flags)) == (flags))
#endif
#ifndef RTS_HASFLAG
	#define RTS_HASFLAG(value, flag)			(value & (flag))
#endif



#ifndef ALIGN_MEMORY
#	define ALIGN_MEMORY(pMemory)	((void *)(((((uintptr_t)(pMemory) + sizeof(void*) - 1) / sizeof(void*)) * sizeof(void*))))
#endif

#ifndef ALIGN_MEMORY_SIZE
#	define ALIGN_MEMORY_SIZE(pMemory, iSize)	((iSize) - (((((uintptr_t)(pMemory) + sizeof(void*) - 1) / sizeof(void*)) * sizeof(void*)) - (uintptr_t)(pMemory)))
#endif

#ifndef ALIGN_MEMORY2
#	define ALIGN_MEMORY2(pMemory, Modulo)	((void *)((((uintptr_t)(pMemory) + (Modulo) - 1) / (uintptr_t)(Modulo)) * (uintptr_t)(Modulo)))
#endif

#ifndef ALIGN_MEMORY2_BACK
#	define ALIGN_MEMORY2_BACK(pMemory, Modulo)	((void *)(((uintptr_t)(pMemory) / (uintptr_t)(Modulo)) * (uintptr_t)(Modulo)))
#endif

#ifndef ALIGN_MEMORY_SIZE2
#	define ALIGN_MEMORY_SIZE2(pMemory, iSize, Modulo)	((iSize) - (((((uintptr_t)(pMemory) + (Modulo) - 1) / sizeof(void*)) * (Modulo)) - (uintptr_t)(pMemory)))
#endif

#ifndef ALIGN_SIZE
/* NOTE: it seems like this operation can be made without a comparison:									*/
/* #define ALIGN_SIZE(Size, Modulo) (( (Size) + ((Modulo) - 1) ) / (Modulo)) * (Modulo)	*/
#	define ALIGN_SIZE(Size, Modulo)		/*lint -e{506} */(((Size) % (Modulo)) ? ((Size) + ((Modulo) - ((Size) % (Modulo)))) : (Size))
#endif

#ifndef RTS_VSNPRINTF
	#if defined(RTS_VSNPRINTF_NOT_AVAILABLE)
		#define RTS_VSNPRINTF(s,len,format,arglist)	vsprintf(s,format,arglist)
	#else
		#define RTS_VSNPRINTF(s,len,format,arglist) vsnprintf(s,len,format,arglist)
	#endif
#endif

#ifndef va_copy
	#define va_copy(destination, source) ((destination) = (source))
#endif


#define CONCAT(x,y) x##y

/* Some preprocessors do not allow to place such a macro within other macros	*/
/* and/or pragmas.																															*/
#define ____QUOTE____(x) #x
#define QUOTE(x) ____QUOTE____(x)

#ifdef INTEL_BYTE_ORDER
#	define SWAP16u(x) (x)
#	define SWAP16s(x) (x)
#	define SWAP32u(x) (x)
#	define SWAP32s(x) (x)
#elif defined(MOTOROLA_BYTE_ORDER)
#	define SWAP16u(x) ( (uint16_t)((((x) & 0xFF)<<8) | (((x) & 0xFF00) >> 8)) )
#	define SWAP16s(x) ( (int16_t)((((x) & 0xFF)<<8) | (((x) & 0xFF00) >> 8)) )
#	define SWAP32u(x) ( (uint32_t)((((x) & 0xff000000) >> 24) | (((x) & 0x00ff0000) >> 8) | (((x) & 0x0000ff00) << 8) | (((x) & 0x000000ff) << 24)) )
#	define SWAP32s(x) ((int32_t)((((uint32_t)(x)) & 0xff000000) >> 24) | (((x) & 0x00ff0000) >> 8) | (((x) & 0x0000ff00) << 8) | (((x) & 0x000000ff) << 24))
#else
	#error "No byte order defined for the current target"
#endif



#include "CmpErrors.h"

#define CAL_CMGETAPI(name) ERR_OK
#define CAL_CMEXPAPI(name) ERR_OK

typedef void HUGEPTR(CDECL *RTS_VOID_FCTPTR)(void);


/*
 * Runtime system basic typedefinitions.
 * Defines some types with special meaning. Systems not using standard type sizes 
 * must redefine this types in sysdefines.h and set BASETYPES_DEFINED
 */

#ifndef RTS_I64_CONST
	#define RTS_I64_CONST(a)	(a##LL)
#endif
#ifndef RTS_UI64_CONST
	#define RTS_UI64_CONST(a)	(a##ULL)
#endif

#ifndef BASETYPES_DEFINED
#	define BASETYPES_DEFINED

	typedef int8_t				RTS_I8;		/* Signed 8 bit value */
	typedef int16_t				RTS_I16;	/* Signed 16 bit value */
#ifndef RTS_I32_DEFINED
	#define RTS_I32_DEFINED
	typedef int32_t				RTS_I32; 	/* Signed 32 bit value */
#endif

	typedef uint8_t				RTS_UI8;	/* Unsigned 8 bit value */
#	define	RTS_UI8_MAX			(RTS_UI8)(~((RTS_UI8)0))

	typedef uint16_t			RTS_UI16;	/* Unsigned 16 bit value */
#	define	RTS_UI16_MAX		(RTS_UI16)(~((RTS_UI16)0))

#ifndef RTS_UI32_DEFINED
	#define RTS_UI32_DEFINED
	typedef uint32_t			RTS_UI32;	/* Unsigned 32 bit value */
#endif	
#	define	RTS_UI32_MAX		(RTS_UI32)(~((RTS_UI32)0))

#ifndef IEEE754TYPES_DEFINED
#	define IEEE754TYPES_DEFINED
	typedef float				RTS_REAL32;		/* 32 bit floating point value */
	typedef double				RTS_REAL64;		/* 64 bit floating point value */
	#define RTS_REAL32_MAX		3.4028234e+38
	#define RTS_REAL64_MAX		1.7976931348623157e+308
#endif

	typedef void*				RTS_HANDLE;		/* Handle for files, semaphores, ... Usually the native integer type of the platform*/
	#define RTS_INVALID_HANDLE	((RTS_HANDLE)(~((uintptr_t)0)))

	typedef RTS_UI32			RTS_RESULT;		/* Result type for most functions. At least 16 bit. Should be the natural integer of a platform. */

	typedef uintptr_t			RTS_UINTPTR;	/* Unsigned integral type that can hold a pointer */
	#define RTS_UINTPTR_MAX		(RTS_UINTPTR)(~((RTS_UINTPTR)0))

	typedef intptr_t			RTS_INTPTR;		/* Signed integral type that can hold a pointer */
	#define RTS_INTPTR_MAX		(RTS_INTPTR)(~((RTS_INTPTR)0))

	typedef ptrdiff_t			RTS_PTRDIFF;	/* Signed integral type that can hold an array index */
	#define RTS_PTRDIFF_MAX		(RTS_PTRDIFF)(~((RTS_PTRDIFF)0))

#ifndef RTS_SIZE_DEFINED
	#define RTS_SIZE_DEFINED
	typedef size_t				RTS_SIZE;	/* Unsigned integral type that can hold a buffer offset */
#endif
	#define RTS_SIZE_MAX		(RTS_SIZE)(~((RTS_SIZE)0))

/* Type definition of RTS_SSIZE should be changed to standard datatype ssize_t, if available on any target! */
#ifndef RTS_SSIZE_DEFINED
	#define RTS_SSIZE_DEFINED
	typedef intptr_t	RTS_SSIZE;			/* integral type that can hold a buffer offset */
#endif
	#define RTS_SSIZE_MAX		(RTS_SSIZE)(~((RTS_SSIZE)0))

	typedef RTS_UINTPTR	RTS_TIME;			/* Coordinated Universal Time (UTC) */

	typedef int					RTS_INT;	/* Data type has no constant size, so be careful in sharing shuch datatypes with IEC! */
	typedef int					RTS_BOOL;	/* Boolean value (TRUE or FALSE). For best performance use platform specific int.
											   Data type has no constant size, so be carful in sharing shuch datatypes with IEC! */
#if defined(RTS_DISABLE_64BIT_SUPPORT) && !defined(SYSINTERNAL_DISABLE_64BIT)
	#define SYSINTERNAL_DISABLE_64BIT
#endif

#if !defined(BASE64BITTYPES_DEFINED) && !defined(SYSINTERNAL_DISABLE_64BIT)
#	define	BASE64BITTYPES_DEFINED
	typedef uint64_t			RTS_UI64;
	typedef int64_t				RTS_I64;
	#define RTS_UI64_MAX		(RTS_UI64)(~((RTS_UI64)0))
	#define RTS_I64_MAX			(RTS_I64)(~((RTS_I64)0))
#endif

	typedef char				RTS_CSTRING;
	typedef char				RTS_UTF8STRING;

#	ifndef RTS_WCHAR_DEFINED
#		define RTS_WCHAR_DEFINED
		typedef wchar_t			RTS_WCHAR;	/* wide character value. We expect 2 bytes unicode here! */
#	endif	/*RTS_WCHAR_DEFINED*/

#	ifndef RTS_CWCHAR_DEFINED
#		define RTS_CWCHAR_DEFINED
#		ifdef RTS_UNICODE
			typedef RTS_WCHAR	RTS_CWCHAR;
#		else
			typedef RTS_CSTRING	 RTS_CWCHAR;
#		endif
#	endif	/*RTS_CWCHAR_DEFINED*/

#ifdef RTS_DEFINE_MODE_T
	typedef unsigned short mode_t;
#endif
#ifdef RTS_DEFINE_GID_T
	typedef short gid_t;
#endif
#ifdef RTS_DEFINE_UID_T
	typedef short uid_t;
#endif
#ifdef RTS_DEFINE_ID_T
	typedef intptr_t id_t;
#endif
#ifdef RTS_DEFINE_PID_T
	typedef uintptr_t pid_t;
#endif
#ifdef RTS_DEFINE_OFF_T
	typedef uintptr_t off_t;
#endif
#ifdef RTS_DEFINE_NLINK_T
	typedef	short nlink_t;
#endif

	

#endif /*BASETYPES_DEFINED*/

typedef enum
{
    RTSTYPE_I8,
    RTSTYPE_I16,
    RTSTYPE_I32,
    RTSTYPE_UI8,
    RTSTYPE_UI16,
    RTSTYPE_UI32,
    RTSTYPE_REAL32,
    RTSTYPE_REAL64,
    RTSTYPE_HANDLE,
    RTSTYPE_RESULT,
    RTSTYPE_UINTPTR,
    RTSTYPE_INTPTR,
    RTSTYPE_SIZE,
    RTSTYPE_PTRDIFF,
    RTSTYPE_INT,
    RTSTYPE_BOOL,
    RTSTYPE_UI64,
    RTSTYPE_I64,
    RTSTYPE_CSTRING,
    RTSTYPE_WCHAR,
    RTSTYPE_CWCHAR
}RTS_TYPECLASS;

typedef union
{
    RTS_I8          i8Value;
    RTS_I16         i16Value;
    RTS_I32         i32Value;
    RTS_UI8         ui8Value;
    RTS_UI16        ui16Value;
    RTS_UI32        ui32Value;
    RTS_REAL32      real32Value;
    RTS_REAL64      real64Value;
    RTS_HANDLE      handleValue;
    RTS_RESULT      resultValue;
    RTS_UINTPTR     uintptrValue;
    RTS_INTPTR      intptrValue;
    RTS_SIZE        sizeValue;
    RTS_PTRDIFF     ptrdiffValue;
    RTS_INT         intValue;
    RTS_BOOL        boolValue;
    RTS_UI64        ui64Value;
    RTS_I64         i64Value;
    RTS_CSTRING     *cstringValue;
    RTS_WCHAR       *wstringValue;
    RTS_CWCHAR      *cwstringValue;
}RTS_VALUE;

typedef struct
{
    RTS_TYPECLASS typeClass;
    RTS_VALUE value;
}RTS_TYPEDVALUE;


/*
 * IEC basic typedefinitions.
 * Defines all datatypes used in IEC programs. Datatypes must match to CoDeSys compiler.
 * Systems that overloads standard types must redefine this types in sysdefines.h and set IECBASETYPES_DEFINED
 */

typedef void HUGEPTR(CDECL *RTS_VOID_FCTPTR)(void);

#ifndef IECBASETYPES_DEFINED
#define IECBASETYPES_DEFINED

#	define RTS_IEC_VOID_FCTPTR		RTS_VOID_FCTPTR
	typedef void*			RTS_IEC_VOIDPTR;

	typedef RTS_I8			RTS_IEC_BOOL;
	typedef RTS_I8			RTS_IEC_SINT;
	typedef RTS_UI8			RTS_IEC_USINT;
	typedef RTS_UI8			RTS_IEC_BYTE;
	typedef RTS_I16			RTS_IEC_INT;
	typedef RTS_UI16		RTS_IEC_UINT;
	typedef RTS_UI16		RTS_IEC_WORD;
	typedef RTS_I32			RTS_IEC_DINT;
	typedef RTS_UI32		RTS_IEC_UDINT;
	typedef RTS_UI32		RTS_IEC_DWORD;

	typedef RTS_UI32		RTS_IEC_TIME;
	typedef RTS_UI32		RTS_IEC_TIME_OF_DAY;
	typedef RTS_UI32		RTS_IEC_TOD;
	typedef RTS_UI32		RTS_IEC_DATE_AND_TIME;
	typedef RTS_UI32		RTS_IEC_DT;
	typedef RTS_UI32		RTS_IEC_DATE;
	
	typedef RTS_I64			RTS_IEC_LINT;
	typedef RTS_UI64		RTS_IEC_ULINT;
	typedef RTS_UI64		RTS_IEC_LWORD;
	typedef RTS_UI64		RTS_IEC_LTIME;

	typedef RTS_SIZE		RTS_IEC_XWORD;
	typedef RTS_UINTPTR		RTS_IEC_UXINT;
	typedef RTS_PTRDIFF		RTS_IEC_XINT;

	typedef RTS_REAL32		RTS_IEC_REAL;
	typedef RTS_REAL64		RTS_IEC_LREAL;

	typedef RTS_CSTRING		RTS_IEC_STRING;
#	ifdef RTS_UNICODE
		typedef RTS_WCHAR	RTS_IEC_WSTRING;
#	else
		typedef RTS_UI16	RTS_IEC_WSTRING;
#	endif
	typedef RTS_CWCHAR		RTS_IEC_CWCHAR;

	typedef RTS_SIZE		RTS_IEC_SIZE;
	typedef RTS_HANDLE		RTS_IEC_HANDLE;
	typedef RTS_IEC_UDINT	RTS_IEC_RESULT;
#endif	/*IECBASETYPES_DEFINED*/


#ifndef RTS_MEM_REGION_DEFINED
#define RTS_MEM_REGION_DEFINED

/**
 *	<description>
 *	 Abstract Memory Region.
 *	</description>
 */  
typedef struct tagRTS_MEM_REGION
{
	/* base address of the region */
	RTS_UINTPTR base;

	/* region size */
	RTS_SIZE		size;

} RTS_MEM_REGION;
#endif

#ifndef EXT_FUNCT_REF_DEFINED
#define EXT_FUNCT_REF_DEFINED
/**
 *	Exported function descriptor
 */
typedef struct tagCMP_EXT_FUNCTION_REF
{
	/* pointer to an exported function */
	RTS_VOID_FCTPTR	pfExtCall;

	/* name of an exported function */
	const char*			pszExtCallName;

	/* signature */
	RTS_UI32				signature;

	/* version */
	RTS_UI32				version;

} CMP_EXT_FUNCTION_REF;
#endif

/* The CMGetAPI2/CMGetAPI3 importOptions parameter flag which specifies an import */
/* as a required function (error if it is unresolved) */
#define CM_IMPORT_REQUIRED_FUNCTION			0

/* The CMGetAPI2/CMGetAPI3 importOptions parameter flag which specifies an import */
/* as an external libray function */
#define CM_IMPORT_EXTERNAL_LIB_FUNCTION		1

/* The CMGetAPI2/CMGetAPI3 importOptions parameter flag which specifies an import */
/* as an optional function */
#define CM_IMPORT_OPTIONAL_FUNCTION			2

/* Imported function belongs to an external libray */
#define ImportIsExternalLibFunction(par) (0 != ((par) & CM_IMPORT_EXTERNAL_LIB_FUNCTION))

/* Imported function is optional */
#define ImportIsOptionalFunction(par) (0 != ((par) & CM_IMPORT_OPTIONAL_FUNCTION))

#define RTS_SIZEOF						sizeof
#define RTS_GET_WORD_OFFSET(typesize)	(typesize)
#define RTS_GET_WORD_SIZE				RTS_GET_WORD_OFFSET
#define RTS_GET_BYTE_OFFSET(offset)		(offset)
#define RTS_GET_BYTE_SIZE(size)			(size)
#define RTS_MEMSET						memset
#define RTS_ALIGN_4BYTES				4
#define RTS_BITS_IN_BYTE				8

#define RTS_EMPTY_STRING			""
#define RTS_IS_EMPTY_STRING(s)		((char *)s == NULL || strcmp((char *)s, RTS_EMPTY_STRING) == 0)

#define RTS_TIMEOUT_INFINITE	(~(RTS_UI32)0)
#define RTS_TIMEOUT_DEFAULT		(RTS_UI32)(-2)
#define RTS_TIMEOUT_NO_WAIT		(0)

#define RTS_INVALID_FILETRANSFER	(RTS_UI32)(-1)

#include "CmpItf.h"


#ifndef  COMPONENT_NAME_POSTFIX
	#define COMPONENT_NAME_POSTFIX
#endif

#endif /*__RTSSTD_H__*/
