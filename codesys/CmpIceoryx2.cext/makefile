##############################################################################
#	CmpIceoryx2 runtime extension component
#	based on the ExtensionSDK makefile_template
##############################################################################

# set versions of your shared object
# must be single digit, decimal
MAJORVER=0
MINORVER=1

# set a component version (must match your IEC library version)
# must be 4 bytes, hexadecimal
CMPVERSION=0x00010000

# set a component ID
# must be 2 bytes >= 0x2000 and hexadecimal and can be used to differentiate different components
CMPID=0x2000

# set your tools
DOS2UNIX = sed -i 's/\r$$//'
M4 = m4

# set a compiler
CC ?= gcc

LDLIBS += -liceoryx2_ffi_c -lpthread

# include of the SDK makefiles
SDKDIR=$(abspath ExtensionSDK)
include ${SDKDIR}/makefile

# override the SDK
CFLAGS += -O2 -g0
