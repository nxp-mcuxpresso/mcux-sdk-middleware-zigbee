/*
 * Copyright 2023 NXP
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "RNG_Interface.h"
#include "zb_platform.h"

uint8_t zbPlatCryptoRandomInit(void)
{
    return RNG_Init();
}

uint32_t zbPlatCryptoRandomGet(uint32_t u32Min, uint32_t u32Max)
{
    return RND_u32GetRand(u32Min, u32Max);
}

uint32_t zbPlatCryptoRandom256Get(void)
{
    return RND_u32GetRand256();
}
