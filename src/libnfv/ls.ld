PHDRS
{
   headers PT_PHDR PHDRS ;
   interp PT_INTERP ;
   text PT_LOAD FILEHDR PHDRS ;
   data PT_LOAD ;
   dynamic PT_DYNAMIC ;
}
SECTIONS
{
   . = SIZEOF_HEADERS;
   .interp : { *(.interp) } :text :interp
   .text : {
          . = ALIGN(2 * 1024 * 1024 * 1024);
       _domain_start = .;
        *(.text) } :text

   .rodata : { *(.rodata) } /* defaults to :text */
    .bss : { *(.bss) }
       . = . + 0x1000; /* move to a new page in memory */
   .data : { *(.data) } :data
   .dynamic : { *(.dynamic) } :data :dynamic
    .domain_B : 
  {
    _domain_b_start = .;
     *(.domain_B*)
     . = ALIGN(4096);
      *(.domain_b*)
     . = ALIGN(4096);
      *(.text_B*)
     . = ALIGN(4096);
      *(.bss_B*)
     . = ALIGN(4096);
      *(.rodata_B*)
     . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_b_end = .;
  }

    .domain_C : 
  {
      . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_c_start = .;
     *(.domain_C*)
     . = ALIGN(4096);
      *(.domain_c*)
     . = ALIGN(4096);
      *(.text_C*)
     . = ALIGN(4096);
      *(.bss_C*)
     . = ALIGN(4096);
      *(.rodata_C*)
     . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_c_end = .;
  }

      .domain_D : 
  {
      . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_d_start = .;
     *(.domain_D*)
     . = ALIGN(4096);
    *(.domain_d*)
     . = ALIGN(4096);
      *(.text_D*)
     . = ALIGN(4096);
      *(.bss_D*)
     . = ALIGN(4096);
      *(.rodata_D*)
     . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_d_end = .;
  }
     .domain_A : 
  {
      . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_a_start = .;
     *(.domain_A*)
     . = ALIGN(4096);
    *(.domain_a*)
     . = ALIGN(4096);
      *(.text_A*)
     . = ALIGN(4096);
      *(.bss_A*)
     . = ALIGN(4096);
      *(.rodata_A*)
     . = ALIGN(2 * 1024 * 1024 * 1024);
    _domain_a_end = .;
  }
  _domain_end = .;
}

