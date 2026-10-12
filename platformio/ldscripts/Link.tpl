ENTRY( Reset_Handler )

__stack_size = #stack_size;

PROVIDE( _stack_size = __stack_size );


MEMORY
{
	FLASH (rx) : ORIGIN = #flash_start, LENGTH = #flash
	RAM (xrw) : ORIGIN = 0x20000000, LENGTH = #ram
}


SECTIONS
{

	.isr_vector :
	{
		. = ALIGN(4);
		KEEP(*(.isr_vector))
		. = ALIGN(4);
	} >FLASH AT>FLASH

	.text :
	{
		. = ALIGN(4);
		*(.text)
		*(.text.*)
		*(.glue_7)
		*(.glue_7t)
		*(.rodata)
		*(.rodata*)
		*(.gnu.linkonce.t.*)
		*(.gnu.linkonce.r.*)
		/* sections of the prebuilt libraries compiled by ARM Compiler 5 */
		*(i.*)
		*(.revsh_text)
		*(.rev16_text)
		*(.constdata*)
		*(.conststring*)
		KEEP(*(.init))
		KEEP(*(.fini))
		/* only needed for RT-Thread, goes unused by other frameworks. Only litte flash overhhead. */
		 /* section information for finsh shell */
		. = ALIGN(4);
		__fsymtab_start = .;
		KEEP(*(FSymTab))
		__fsymtab_end = .;
		. = ALIGN(4);
		__vsymtab_start = .;
		KEEP(*(VSymTab))
		__vsymtab_end = .;
		. = ALIGN(4);

		/* section information for initial. */
		. = ALIGN(4);
		__rt_init_start = .;
		KEEP(*(SORT(.rti_fn*)))
		__rt_init_end = .;
		. = ALIGN(4);

		/* section information for modules */
		. = ALIGN(4);
		__rtmsymtab_start = .;
		KEEP(*(RTMSymTab))
		__rtmsymtab_end = .;
		. = ALIGN(4);
	} >FLASH AT>FLASH

	.ARM.extab :
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} >FLASH AT>FLASH

	.ARM.exidx :
	{
		PROVIDE_HIDDEN (__exidx_start = .);
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
		PROVIDE_HIDDEN (__exidx_end = .);
	} >FLASH AT>FLASH

	.preinit_array  :
	{
	  PROVIDE_HIDDEN (__preinit_array_start = .);
	  KEEP (*(.preinit_array))
	  PROVIDE_HIDDEN (__preinit_array_end = .);
	} >FLASH AT>FLASH

	.init_array     :
	{
	  PROVIDE_HIDDEN (__init_array_start = .);
	  KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
	  KEEP (*(.init_array .ctors))
	  PROVIDE_HIDDEN (__init_array_end = .);
	} >FLASH AT>FLASH

	.fini_array     :
	{
	  PROVIDE_HIDDEN (__fini_array_start = .);
	  KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
	  KEEP (*(.fini_array .dtors))
	  PROVIDE_HIDDEN (__fini_array_end = .);
	} >FLASH AT>FLASH

	PROVIDE( _etext = . );

	.data :
	{
		. = ALIGN(4);
		PROVIDE( _data_vma = . );
		/* code to run from RAM, copied from flash together with the data,
		   e.g. the BLE library and __HIGH_CODE functions of the CH32F208 EVT */
		*(highcode)
		*(.highcode .highcode.*)
		*(.data .data.*)
		*(.gnu.linkonce.d.*)
		. = ALIGN(4);
		PROVIDE( _edata = . );
	} >RAM AT>FLASH

	PROVIDE( _data_lma = LOADADDR(.data) );

	.bss (NOLOAD) :
	{
		. = ALIGN(4);
		PROVIDE( _sbss = . );
		*(.bss*)
		*(.gnu.linkonce.b.*)
		*(COMMON*)
		. = ALIGN(4);
		PROVIDE( _ebss = . );
	} >RAM

	PROVIDE( _end = _ebss );
	PROVIDE( end = . );

	.stack ORIGIN(RAM) + LENGTH(RAM) - __stack_size (NOLOAD) :
	{
		PROVIDE( _heap_end = . );
		. = ALIGN(4);
		PROVIDE( _susrstack = . );
		. = . + __stack_size;
		PROVIDE( _eusrstack = . );
	} >RAM

	.ARM.attributes 0 : { *(.ARM.attributes) }
}
