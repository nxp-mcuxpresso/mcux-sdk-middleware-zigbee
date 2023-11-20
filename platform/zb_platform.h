/*
* Copyright 2023 NXP
* All rights reserved.
*
* SPDX-License-Identifier: BSD-3-Clause
*/

/* ZB Platform and board dependent functions */

#ifndef ZB_PLATFORM_H
#define ZB_PLATFORM_H

#include <stdint.h>
#include <stdbool.h>

/* Button related functions */
typedef void (*button_cb)(uint8_t button);

bool zbPlatButtonInit(uint8_t num_buttons, button_cb cb);
uint32_t zbPlatButtonGetState(void);

/* Led related functions */
bool zbPlatLedInit(uint8_t num_leds);
void zbPlatLedSetState(uint8_t led, uint8_t state);
uint8_t zbPlatLedGetStates();

/* Uart related functions */
bool zbPlatUartInit(void);
bool zbPlatUartSetBaudRate(uint32_t baud);
bool zbPlatUartCanTransmit(void);
bool zbPlatUartTransmit(uint8_t ch);
bool zbPlatUartReceive(uint8_t *ch);

/* Time related functions */
uint32_t zbPlatGetTime(void);

#endif
