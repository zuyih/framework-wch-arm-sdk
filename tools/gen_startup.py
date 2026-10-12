"""Convert a WCH MDK-ARM (armasm) startup file into a GNU assembler startup file.

The vector table (order, reserved slots and handler names) is taken verbatim
from the DCD entries of the Keil file; the reset sequence mirrors the
PlatformIO RISC-V startup files of framework-wch-noneos-sdk. It only uses
Thumb-1 instructions, so it runs on ARMv6-M (Cortex-M0) and ARMv7-M.

Usage: python3 gen_startup.py <EVT>/EXAM/SRC/Startup/startup_xxx.s Startup/startup_xxx.S [cpu]
       cpu defaults to cortex-m3
"""
import os
import re
import sys

src, dst = sys.argv[1], sys.argv[2]
cpu = sys.argv[3] if len(sys.argv) > 3 else "cortex-m3"
text = open(src, encoding="ascii").read().replace("\r", "")
name = os.path.basename(dst)

# the leading comment block of the Keil file
header_lines = []
for line in text.splitlines():
    if not line.startswith(";"):
        break
    header_lines.append(re.sub(r"^;", "", line))
header = "\n".join(header_lines)

if "File Name" in header:
    # keep the WCH copyright header, adapt file name and description
    header = re.sub(r"(File Name\s*:\s*)\S+", r"\g<1>" + name, header)
    header = re.sub(r"for MDK-ARM toolchain\.[ \t]*\n",
                    "for GNU toolchain.\n*                      Converted from the MDK-ARM startup file of the WCH EVT.\n",
                    header)
    assert "for GNU toolchain." in header, header
else:
    # e.g. the CMSIS template of ARM: keep its notice, drop the Keil
    # configuration wizard markers
    kept = [l for l in header_lines if "Configuration Wizard" not in l and l.strip() not in ("/*", "*/")]
    body = "\n".join(kept).replace("*/", "* /").replace("/*", "/ *")
    header = ("/* {} for GNU toolchain.\n * Converted from the MDK-ARM startup file {} of the WCH EVT.\n"
              " * Notice of the original file:\n{}\n */").format(name, os.path.basename(src), body)

vectors = []
in_table = False
for line in text.splitlines():
    code = line.split(";", 1)[0]
    if code.startswith("__Vectors"):
        in_table = True
    if in_table:
        m = re.match(r"^(?:__Vectors)?\s+DCD\s+(\S+)", code)
        if m:
            vectors.append(m.group(1))
        elif code.startswith("__Vectors_End"):
            break
assert vectors[0] == "__initial_sp" and vectors[1] == "Reset_Handler", vectors[:2]
vectors[0] = "_eusrstack"

handlers = []
for v in vectors[2:]:
    if v != "0" and v not in handlers:
        handlers.append(v)

out = []
out.append(header.rstrip())
out.append("""
    .syntax unified
    .cpu {cpu}
    .thumb

/*******************************************************************************
 * Vector Table Mapped to Address 0 at Reset
 *******************************************************************************/
    .section .isr_vector, "a", %progbits
    .align 2
    .global __Vectors
    .type __Vectors, %object
__Vectors:""".replace("{cpu}", cpu))
for v in vectors:
    out.append("    .word {}".format(v))
out.append("""    .size __Vectors, . - __Vectors

/*******************************************************************************
 * Reset Handler
 *******************************************************************************/
    .section .text.Reset_Handler, "ax", %progbits
    .weak Reset_Handler
    .type Reset_Handler, %function
Reset_Handler:
    ldr r0, =_eusrstack
    mov sp, r0
/* Load data section from flash to RAM */
    ldr r0, =_data_lma
    ldr r1, =_data_vma
    ldr r2, =_edata
    b 2f
1:
    ldr r3, [r0]
    str r3, [r1]
    adds r0, r0, #4
    adds r1, r1, #4
2:
    cmp r1, r2
    blo 1b
/* Clear bss section */
    ldr r0, =_sbss
    ldr r1, =_ebss
    movs r2, #0
    b 2f
1:
    str r2, [r0]
    adds r0, r0, #4
2:
    cmp r0, r1
    blo 1b

#if defined(__PIO_CPP_SUPPORT__)
    /* register fini (destructor array) call at exit if wanted (bloats up RAM+Flash) */
    #if defined(__PIO_CPP_CALL_FINI__)
    ldr r0, =__libc_fini_array
    bl atexit
    #endif
    /* call into C++ constructors now */
    bl __libc_init_array
#endif
    bl SystemInit
#if defined(__PIO_BUILD_RT_THREAD__)
    /* RT-Thread has special entry point, it will call our main() later */
    bl entry
#else
    bl main
#endif
    b .
    .size Reset_Handler, . - Reset_Handler

/*******************************************************************************
 * Dummy Exception Handlers (infinite loops which can be modified)
 *******************************************************************************/
    .section .text.Default_Handler, "ax", %progbits
    .weak Default_Handler
    .type Default_Handler, %function
Default_Handler:
    b .
    .size Default_Handler, . - Default_Handler
""")
for h in handlers:
    out.append("    .weak {0}\n    .thumb_set {0}, Default_Handler".format(h))
out.append("")
open(dst, "w", encoding="ascii").write("\n".join(out))
print("{}: {} vectors, {} handlers".format(name, len(vectors), len(handlers)))
