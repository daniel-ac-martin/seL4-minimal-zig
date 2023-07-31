/*
 * Linker script for root-tasks
 *
 * The root-task requires:
 * 1. A special entry-point
 * 2. An explicitly defined stack
 */

ENTRY(_boot)

STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x1000;

SECTIONS
{
    .stack (NOLOAD):
    {
        . = ALIGN(16) ;
        _stack = . ;
        __stack_base = . ;
        . = . + STACK_SIZE ;
        . = ALIGN(16) ;
        __stack_top = . ;
        _stack_end = . ;
    } :data
}
INSERT AFTER .tbss;

/* INCLUDE ./linker.ld */

PHDRS
{
    headers PT_PHDR PHDRS ;
    text PT_LOAD FILEHDR PHDRS ;
    rodata PT_LOAD ;
    data PT_LOAD ;
    gnu_stack PT_GNU_STACK ;
}

SECTIONS
{
    . = SIZEOF_HEADERS;

    .text : ALIGN(4K)
    {
        _text = . ;
        *(.text .text.*)
        _text_end = . ;
    } :text

    .rodata : ALIGN(4K)
    {
        _rodata = . ;
        *(.rodata .rodata.*)
        _rodata_end = . ;
    } :rodata

    .data : ALIGN(4K)
    {
        _data = . ;
        *(.data .data.*)
        _data_end = . ;
    } :data

    .tdata : ALIGN(4K)
    {
        _tdata = . ;
        *(.tdata .tdata.*)
        _tdata_end = . ;
    } :data

    .bss : ALIGN(4K)
    {
        _bss = . ;
        *(COMMON)
        *(.bss .bss.*)
        _bss_end = . ;
    } :data

    .tbss : ALIGN(4K)
    {
        _tbss = . ;
        *(.tbss .tbss.*)
        *(.tcommon .tcommon.*)
        _tbss_end = . ;
    } :data

    .note.GNU-stack (NOLOAD):
    {
         *(.note.GNU-stack)
    } : gnu-stack
}

