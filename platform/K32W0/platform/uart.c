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
#include "fsl_usart.h"
#include "usart_dma_rxbuffer.h"

bool zbPlatUartInit(void)
{
    /* Debug console pins are initialized by BOARD_InitHardware */
    USART_DMA_Init();

    return true;
}

bool zbPlatUartSetBaudRate(uint32_t baud)
{
    bool result = true;

    if (kStatus_Success != USART_SetBaudRate(UART, baud, CLOCK_GetFreq(kCLOCK_Fro32M)))
    {
        result = false;
    }

    return result;
}

bool zbPlatUartCanTransmit()
{
    return ((kUSART_TxFifoEmptyFlag | kUSART_TxFifoNotFullFlag) & USART_GetStatusFlags(UART));
}

bool zbPlatUartTransmit(uint8_t ch)
{
    USART_WriteByte(UART, ch);
    /* Wait to finish transfer */
    while (!(UART->FIFOSTAT & USART_FIFOSTAT_TXEMPTY_MASK))
    {
    }

    return true;
}

bool zbPlatUartReceive(uint8_t *ch)
{
    bool result = true;
    if (USART_DMA_ReadBytes(ch, 1) == 0)
    {
        result = false;
    }
    return result;
}

