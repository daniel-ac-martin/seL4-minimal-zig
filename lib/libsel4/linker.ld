ENTRY(_start)

SECTIONS
{
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.text)
    }

    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata)
    }

    .data BLOCK(4K) : ALIGN(4K)
    {
        *(.data)
    }

    .tdata BLOCK(4K) : ALIGN(4K)
    {
        _tdata_start = . ;
        *(.tdata)
        _tdata_end = . ;
    }

    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }

    .tbss BLOCK(4K) : ALIGN(4K)
    {
        _tbss_start = . ;
        *(.tbss)
        *(.tcommon)
        _tbss_end = . ;
    }
}
