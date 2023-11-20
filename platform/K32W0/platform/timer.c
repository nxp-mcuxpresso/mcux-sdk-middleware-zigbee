/*
* Copyright 2023 NXP
* All rights reserved.
*
* SPDX-License-Identifier: BSD-3-Clause
*/
#include <stdint.h>
#include <stdbool.h>
#include "EmbeddedTypes.h"
#include "board.h"
#include "app.h"
#include "fsl_os_abstraction.h"

uint32_t zbPlatGetTime(void)
{
    return OSA_TimeGetMsec();
}

