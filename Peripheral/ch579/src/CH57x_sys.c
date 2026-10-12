/********************************** (C) COPYRIGHT *******************************
 * File Name          : CH57x_SYS.c
 * Author             : WCH
 * Version            : V1.0
 * Date               : 2018/12/15
 * Description 
 *********************************************************************************
 * Copyright (c) 2021 Nanjing Qinheng Microelectronics Co., Ltd.
 * Attention: This software (modified or not) and binary are used for 
 * microcontroller manufactured by Nanjing Qinheng Microelectronics.
 *******************************************************************************/

#include "CH57x_common.h"


/*******************************************************************************
* Function Name  : SYS_GetInfoSta
* Description    : 获取当前系统信息状态
* Input          : i: 
					refer to SYS_InfoStaTypeDef
* Return         : DISABLE  -  关闭
				   ENABLE   -  开启
*******************************************************************************/
UINT8 SYS_GetInfoSta( SYS_InfoStaTypeDef i )
{
    if(i == STA_SAFEACC_ACT)		
        return (R8_SAFE_ACCESS_SIG & RB_SAFE_ACC_ACT);
    else  
        return (R8_GLOB_CFG_INFO&(1<<i));
}

/*******************************************************************************
* Function Name  : SYS_ResetExecute
* Description    : 执行系统软件复位
* Input          : None
* Return         : None
*******************************************************************************/
void SYS_ResetExecute( void )
{
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;		
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
    R8_RST_WDOG_CTRL |= RB_SOFTWARE_RESET;
    R8_SAFE_ACCESS_SIG = 0;
}

/*******************************************************************************
* Function Name  : SYS_DisableAllIrq
* Description    : 关闭所有中断，并保留当前中断值
* Input          : pirqv：当前保留中断值
* Return         : None
*******************************************************************************/
void SYS_DisableAllIrq( PUINT32 pirqv)
{
	*pirqv = NVIC->ISER[0];
	NVIC->ICER[0] = 0xffffffff;
}

/*******************************************************************************
* Function Name  : SYS_RecoverIrq
* Description    : 恢复之前关闭的中断值
* Input          : irq_status：当前保留中断值
* Return         : None
*******************************************************************************/
void SYS_RecoverIrq( UINT32 irq_status )
{
	NVIC->ISER[0] = irq_status;
}

/*******************************************************************************
* Function Name  : SYS_GetSysTickCnt
* Description    : 获取当前系统(SYSTICK)计数值
* Input          : None
* Return         : 当前计数值
*******************************************************************************/
uint32_t SYS_GetSysTickCnt( void )
{
	return(SysTick->VAL );
}

/*******************************************************************************
* Function Name  : WWDG_ITCfg
* Description    : 看门狗定时器溢出中断使能
* Input          : DISABLE-溢出不中断      ENABLE-溢出中断
* Return         : None
*******************************************************************************/
void  WWDG_ITCfg( UINT8 s )
{
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;		
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
	if(s == DISABLE)		R8_RST_WDOG_CTRL&=~RB_WDOG_INT_EN;
	else 					R8_RST_WDOG_CTRL|=RB_WDOG_INT_EN;
	R8_SAFE_ACCESS_SIG = 0;	
}

/*******************************************************************************
* Function Name  : WWDG_ResetCfg
* Description    : 看门狗定时器复位功能
* Input          : DISABLE-溢出不复位      ENABLE-溢出系统复位
* Return         : None
*******************************************************************************/
void WWDG_ResetCfg( UINT8 s )
{
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;		
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
	if(s == DISABLE)		R8_RST_WDOG_CTRL&=~RB_WDOG_RST_EN;
	else 					R8_RST_WDOG_CTRL|=RB_WDOG_RST_EN;
	R8_SAFE_ACCESS_SIG = 0;	
}

/*******************************************************************************
* Function Name  : WWDG_ClearFlag
* Description    : 清除看门狗中断标志，重新加载计数值也可清除
* Input          : None
* Return         : None
*******************************************************************************/
void WWDG_ClearFlag( void )
{
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;		
	R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
	R8_RST_WDOG_CTRL |= RB_WDOG_INT_FLAG;
	R8_SAFE_ACCESS_SIG = 0;	
}


/*******************************************************************************
* Function Name  : mDelayuS
* Description    : uS 延时
* Input          : t: 时间参数
* Return         : None
*******************************************************************************/
void mDelayuS( UINT16 t )
{
    UINT16 i, j;

    for(j=0; j<t; j++)
    {

#if     (FREQ_SYS == 40000000)	
    for(i=0; i<4; i++)		__nop();

#elif       (FREQ_SYS == 32000000)		
    i = 2;
    while(i--)	{ __nop();	__nop(); }		

#elif       (FREQ_SYS == 24000000)		
    i = 1;
    while(i--)	{ __nop();	__nop(); }

 #elif       (FREQ_SYS == 20000000)		
    for(i=0; i<1; i++)		__nop();

 #elif       (FREQ_SYS == 16000000)			
    __nop(); __nop();	__nop(); __nop();
    __nop(); __nop();   __nop(); __nop(); __nop();

#elif       (FREQ_SYS == 8000000)		
    __nop(); __nop();
    
#endif			
    
    }	
}

/*******************************************************************************
* Function Name  : mDelaymS
* Description    : mS 延时
* Input          : t: 时间参数
* Return         : None
*******************************************************************************/
void mDelaymS( UINT16 t )
{
    UINT16 i;

    for(i=0; i<t; i++)
        mDelayuS(1000);
}


#if( defined  DEBUG)
/*******************************************************************************
* Function Name  : _write
* Description    : Support Printf Function
* Input          : *buf: UART send Data.
*                  size: Data length
* Return         : size: Data length
*******************************************************************************/
__attribute__((used))
int _write(int fd, char *buf, int size)
{
  int i;

  for(i = 0; i < size; i++)
  {
#if  DEBUG == Debug_UART0
    while( R8_UART0_TFC == UART_FIFO_SIZE );
    R8_UART0_THR = *buf++;
#elif DEBUG == Debug_UART1
    while( R8_UART1_TFC == UART_FIFO_SIZE );
    R8_UART1_THR = *buf++;
#elif DEBUG == Debug_UART2
    while( R8_UART2_TFC == UART_FIFO_SIZE );
    R8_UART2_THR = *buf++;
#elif DEBUG == Debug_UART3
    while( R8_UART3_TFC == UART_FIFO_SIZE );
    R8_UART3_THR = *buf++;
#endif
  }

  return size;
}
#endif

#include <stddef.h>
#include <sys/stat.h>
#include <sys/types.h>

/*******************************************************************************
* Function Name  : _sbrk
* Description    : Change the spatial position of data segment.
* Return         : the old end of the heap
*******************************************************************************/
__attribute__((used))
void *_sbrk(ptrdiff_t incr)
{
  extern char _end[];
  extern char _heap_end[];
  static char *curbrk = _end;

  if ((curbrk + incr < _end) || (curbrk + incr > _heap_end))
    return (void *)-1;

  curbrk += incr;
  return curbrk - incr;
}

/*******************************************************************************
* Function Name  : _close, _fstat, _isatty, _lseek, _read
* Description    : The other system calls of the C library: stdin, stdout and
*                  stderr are the debug UART, there is no file system. Without
*                  them the stubs of libnosys, which always fail, are linked and
*                  the linker warns about them whenever stdio is used. They are
*                  weak, so the application can implement them, e.g. _read for
*                  stdin.
*******************************************************************************/
__attribute__((weak, used))
int _close(int fd)
{
  (void)fd;
  return -1;
}

__attribute__((weak, used))
int _fstat(int fd, struct stat *st)
{
  (void)fd;
  st->st_mode = S_IFCHR;
  return 0;
}

__attribute__((weak, used))
int _isatty(int fd)
{
  (void)fd;
  return 1;
}

__attribute__((weak, used))
off_t _lseek(int fd, off_t offset, int whence)
{
  (void)fd;
  (void)offset;
  (void)whence;
  return 0;
}

__attribute__((weak, used))
int _read(int fd, char *buf, int size)
{
  (void)fd;
  (void)buf;
  (void)size;
  return 0;
}
