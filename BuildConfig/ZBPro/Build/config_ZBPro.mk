###############################################################################
#
# MODULE:   config_ZBPro.mk
#
# DESCRIPTION: ZBPro stack configuration. Defines tool, library and
#              header file details for building an app using the ZBPro stack
#
###############################################################################
# This software is owned by NXP B.V. and/or its supplier and is protected
# under applicable copyright laws. All rights are reserved. We grant You,
# and any third parties, a license to use this software solely and
# exclusively on NXP products [NXP Microcontrollers such as JN514x, JN516x, JN517x].
# You, and any third parties must reproduce the copyright and warranty notice
# and any other legend of ownership on each  copy or partial copy of the software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Copyright NXP B.V. 2015-2019,2022-2023. All rights reserved
#
###############################################################################

###############################################################################
# Tools

WWAH ?= 0
LEGACY ?= 0
R23_UPDATES ?= 0
ifeq ($(R23_UPDATES),1)
ifeq ($(LEGACY),0)
    R22PLUS = _R23
else
    $(info ***** Conflicting R23 settings, probably building the GU *****)
endif
endif
OTA ?= 0
OTA_INTERNAL_STORAGE ?= 0

ifeq ($(ZIGBEE_PLAT),K32W1)
    SDK_DEVICE_FAMILY   ?= K32W1480
    SDK_BOARD           ?= k32w148evk
else
ifeq ($(ZIGBEE_PLAT),K32W0)
    SDK_DEVICE_FAMILY   ?= JN5189
    SDK_BOARD           ?= jn5189dk6
endif
endif

PDM_NONE            ?= 0
SELOVERIDE          ?= 0
FRAMEWORK_SWITCH    ?= 0

# Currently the stack should be compiled with JENNIC_CHIP_FAMILY == JN518x
# in order to enable code guarded by JN518x on all platforms.
JENNIC_CHIP_FAMILY  ?= JN518x
JENNIC_CHIP         ?= JN5189
SELOTA              ?= NONE
HEAP_SIZE           ?= 2000
STACK_SIZE          ?= 2000
SDK_BASE_DIR        ?=  ../../../../../..
# SDK2_BASE_DIR is used in K32W0 builds
SDK2_BASE_DIR        ?= $(SDK_BASE_DIR)

ZIGBEE_BASE_DIR      ?= $(SDK_BASE_DIR)/middleware/wireless/zigbee
ZIGBEE_COMMON_SRC    ?= $(ZIGBEE_BASE_DIR)/ZigbeeCommon/Source
TOOL_BASE_DIR        ?= $(ZIGBEE_BASE_DIR)/tools
PDUMCONFIG            = $(TOOL_BASE_DIR)/PDUMConfig/Source/PDUMConfig
ZPSCONFIG             = $(TOOL_BASE_DIR)/ZPSConfig/Source/ZPSConfig
# Used by ZCL
STACK_BASE_DIR       ?= $(ZIGBEE_BASE_DIR)/BuildConfig

FRAMEWORK_BASE_DIR   ?= $(SDK_BASE_DIR)/middleware/wireless/framework

CHIP_STARTUP_SRC     ?= $(SDK_BASE_DIR)/devices/$(SDK_DEVICE_FAMILY)/gcc
CHIP_SYSTEM_SRC      ?= $(SDK_BASE_DIR)/devices/$(SDK_DEVICE_FAMILY)
BOARD_LEVEL_SRC      ?= $(SDK_BASE_DIR)/boards/$(SDK_BOARD)
FSL_COMPONENTS       ?= $(SDK_BASE_DIR)/components

# OSA Config
include $(SDK_BASE_DIR)/middleware/wireless/zigbee/BuildConfig/ZBPro/Build/config_OSA.mk

# Platform specific configs
include $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/build/device.mk
include $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/build/platform.mk

###############################################################################
# Common part (all platforms)

# Zigbee Common Sources
APPSRC += ZQueue.c
APPSRC += ZTimer.c
APPSRC += app_zps_link_keys.c
APPSRC += appZdpExtraction.c
APPSRC += appZpsBeaconHandler.c
APPSRC += appZpsExtendedDebug.c
ifeq ($(R23_UPDATES),1)
    APPSRC += tlv.c
endif

# Zigbee Common Includes
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/SerialMAC/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/ZPSMAC/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/ZPSNWK/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/ZPSTSV/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/ZigbeeCommon/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/ZPSAPL/Include
INCFLAGS += -I$(ZIGBEE_BASE_DIR)/platform

ifeq ($(TRACE), 1)
    CFLAGS  += -DDBG_ENABLE
    CFLAGS  += -DDEBUG_ENABLE
    $(info Building trace version ...)
endif

CFLAGS += -DENABLE_RAM_VECTOR_TABLE
CFLAGS += -DSDK_DEVICE_FAMILY=$(SDK_DEVICE_FAMILY)
CFLAGS += -DPDM_USER_SUPPLIED_ID
CFLAGS += -DPDM_NO_RTOS

ifeq ($(FRAMEWORK_SWITCH),1)
CFLAGS  += -DZIGBEE_USE_FRAMEWORK=1
endif

##################################################################################
## LIBS

ifneq ($(SELOTA),NONE)
    APPLIBS += Selective_OTA
endif

ifneq ($(SELOTA),APP0)
    APPLIBS += ZPSTSV
    APPLIBS += PDUM
    ifeq ($(WWAH),0)
        ifeq ($(LEGACY),0)
            APPLIBS += ZPSAPL$(R22PLUS)
        else
            APPLIBS += ZPSAPL_LEGACY
            CFLAGS += -DLEGACY_SUPPORT
        endif
    else
        APPLIBS += ZPSAPL_WWAH
    endif

    $(info MAC is Mini MAC shim )
    MAC_PLATFORM ?= SOC
    ###############################################################################
    # Determine correct MAC library for platform

    ifeq ($(MAC_PLATFORM),SOC)
        $(info MAC_PLATFORM is SOC)
        APPLIBS += ZPSMAC_Mini_SOC
    else
    ifeq ($(MAC_PLATFORM),SERIAL)
        $(info MAC_PLATFORM is SERIAL)
        APPLIBS += ZPSMAC_Mini_SERIAL
        APPLIBS += SerialMiniMacUpper
    else
    ifeq ($(MAC_PLATFORM),MULTI)
        $(info MAC_PLATFORM is MULTI)
        APPLIBS += ZPSMAC_Mini_MULTI
        APPLIBS += SerialMiniMacUpper
    endif
    endif
    endif

    ifeq ($(OPTIONAL_STACK_FEATURES),1)
        ifneq ($(ZBPRO_DEVICE_TYPE), ZED)
            APPLIBS += ZPSIPAN
        else
            APPLIBS += ZPSIPAN_ZED
        endif
    endif

    ifeq ($(OPTIONAL_STACK_FEATURES),2)
        ifneq ($(ZBPRO_DEVICE_TYPE), ZED)
            APPLIBS += ZPSGP
        else
            APPLIBS += ZPSGP_ZED
        endif
    endif

    ifeq ($(OPTIONAL_STACK_FEATURES),3)
        ifneq ($(ZBPRO_DEVICE_TYPE), ZED)
            APPLIBS += ZPSGP
            APPLIBS += ZPSIPAN
        else
            APPLIBS += ZPSGP_ZED
            APPLIBS += ZPSIPAN_ZED
        endif
    endif

    ifeq ($(ZBPRO_DEVICE_TYPE), ZCR)
        ifeq ($(WWAH),0)
            APPLIBS += ZPSNWK$(R22PLUS)
        else
            APPLIBS += ZPSNWK_WWAH
        endif
    else
        ifeq ($(ZBPRO_DEVICE_TYPE), ZED)
            ifeq ($(WWAH),0)
                APPLIBS += ZPSNWK_ZED$(R22PLUS)
            else
                APPLIBS += ZPSNWK_WWAH_ZED
            endif
        else
            $(error ZBPRO_DEVICE_TYPE must be set to either ZCR or ZED)
        endif
    endif
endif

# Set ZPS_NWK_LIB and ZPS_APL_LIB path
ifeq ($(ZBPRO_DEVICE_TYPE), ZCR)
    ifeq ($(WWAH),0)
        ZPS_NWK_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSNWK$(R22PLUS).a
    else
        ZPS_NWK_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSNWK_WWAH.a
    endif
endif

ifeq ($(ZBPRO_DEVICE_TYPE), ZED)
    ifeq ($(WWAH),0)
        ZPS_NWK_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSNWK_ZED$(R22PLUS).a
    else
        ZPS_NWK_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSNWK_WWAH_ZED.a
    endif
endif

ifeq ($(WWAH),0)
    ifeq ($(LEGACY),0)
        ZPS_APL_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSAPL$(R22PLUS).a
    else
        ZPS_APL_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSAPL_LEGACY.a
    endif
else
    ZPS_APL_LIB = $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs/libZPSAPL_WWAH.a
endif

vector_table_size    ?= 512
__ram_vector_table__ ?= 1

LDFLAGS += -Wl,--defsym,vector_table_size=$(vector_table_size)
LDFLAGS += -Wl,--defsym,__ram_vector_table__=$(__ram_vector_table__)

LDFLAGS += -L $(ZIGBEE_BASE_DIR)/platform/$(ZIGBEE_PLAT)/libs
LDFLAGS += --specs=nosys.specs

###############################################################################
