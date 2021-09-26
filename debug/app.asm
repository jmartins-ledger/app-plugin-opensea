
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *) &libcall_params);
}

// Weird low-level black magic.
__attribute__((section(".boot"))) int main(int arg0) {
c0d00000:	b5b0      	push	{r4, r5, r7, lr}
c0d00002:	b090      	sub	sp, #64	; 0x40
c0d00004:	4604      	mov	r4, r0
    // Low-level black magic, don't touch.
    // exit critical section
    __asm volatile("cpsie i");
c0d00006:	b662      	cpsie	i

    // Low-level black magic, don't touch.
    // ensure exception will work as planned
    os_boot();
c0d00008:	f001 fa3a 	bl	c0d01480 <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY {
        TRY {
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f004 fe26 	bl	c0d04c60 <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f002 fcce 	bl	c0d029bc <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f002 fc89 	bl	c0d02938 <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f002 fcac 	bl	c0d02988 <os_sched_exit>
c0d00030:	2001      	movs	r0, #1
c0d00032:	0201      	lsls	r1, r0, #8
            // Low-level black magic. Don't touch.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0) {
c0d00034:	2c00      	cmp	r4, #0
c0d00036:	d017      	beq.n	c0d00068 <main+0x68>
            } else {
                // not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *) arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE`, we can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE) {
c0d00038:	6820      	ldr	r0, [r4, #0]
c0d0003a:	31ff      	adds	r1, #255	; 0xff
c0d0003c:	4288      	cmp	r0, r1
c0d0003e:	d002      	beq.n	c0d00046 <main+0x46>
                    dispatch_plugin_calls(args[0], (void *) args[1]);
c0d00040:	6861      	ldr	r1, [r4, #4]
c0d00042:	f001 f9b5 	bl	c0d013b0 <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f002 fc93 	bl	c0d02970 <os_lib_end>
            }
        }
        FINALLY {
c0d0004a:	f002 fcab 	bl	c0d029a4 <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f002 fcb1 	bl	c0d029bc <try_context_set>
c0d0005a:	a801      	add	r0, sp, #4
        }
    }
    END_TRY;
c0d0005c:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d0005e:	2800      	cmp	r0, #0
c0d00060:	d10b      	bne.n	c0d0007a <main+0x7a>
c0d00062:	2000      	movs	r0, #0

    // Will not get reached.
    return 0;
}
c0d00064:	b010      	add	sp, #64	; 0x40
c0d00066:	bdb0      	pop	{r4, r5, r7, pc}
    libcall_params[2] = RUN_APPLICATION;
c0d00068:	900f      	str	r0, [sp, #60]	; 0x3c
    libcall_params[1] = 0x100;
c0d0006a:	910e      	str	r1, [sp, #56]	; 0x38
    libcall_params[0] = (unsigned int) "Ethereum";
c0d0006c:	4804      	ldr	r0, [pc, #16]	; (c0d00080 <main+0x80>)
c0d0006e:	4478      	add	r0, pc
c0d00070:	900d      	str	r0, [sp, #52]	; 0x34
c0d00072:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *) &libcall_params);
c0d00074:	f002 fc6e 	bl	c0d02954 <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f001 fa07 	bl	c0d0148c <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	000055e3 	.word	0x000055e3

c0d00084 <cx_hash_get_size>:
CX_TRAMPOLINE _NR_cx_groestl_get_output_size               cx_groestl_get_output_size
CX_TRAMPOLINE _NR_cx_groestl_init_no_throw                 cx_groestl_init_no_throw
CX_TRAMPOLINE _NR_cx_groestl_update                        cx_groestl_update
CX_TRAMPOLINE _NR_cx_hash_final                            cx_hash_final
CX_TRAMPOLINE _NR_cx_hash_get_info                         cx_hash_get_info
CX_TRAMPOLINE _NR_cx_hash_get_size                         cx_hash_get_size
c0d00084:	b403      	push	{r0, r1}
c0d00086:	4801      	ldr	r0, [pc, #4]	; (c0d0008c <cx_hash_get_size+0x8>)
c0d00088:	e011      	b.n	c0d000ae <cx_trampoline_helper>
c0d0008a:	0000      	.short	0x0000
c0d0008c:	0000002f 	.word	0x0000002f

c0d00090 <cx_hash_no_throw>:
CX_TRAMPOLINE _NR_cx_hash_init                             cx_hash_init
CX_TRAMPOLINE _NR_cx_hash_init_ex                          cx_hash_init_ex
CX_TRAMPOLINE _NR_cx_hash_no_throw                         cx_hash_no_throw
c0d00090:	b403      	push	{r0, r1}
c0d00092:	4801      	ldr	r0, [pc, #4]	; (c0d00098 <cx_hash_no_throw+0x8>)
c0d00094:	e00b      	b.n	c0d000ae <cx_trampoline_helper>
c0d00096:	0000      	.short	0x0000
c0d00098:	00000032 	.word	0x00000032

c0d0009c <cx_keccak_init_no_throw>:
CX_TRAMPOLINE _NR_cx_hmac_sha384_init                      cx_hmac_sha384_init
CX_TRAMPOLINE _NR_cx_hmac_sha512                           cx_hmac_sha512
CX_TRAMPOLINE _NR_cx_hmac_sha512_init_no_throw             cx_hmac_sha512_init_no_throw
CX_TRAMPOLINE _NR_cx_hmac_update                           cx_hmac_update
CX_TRAMPOLINE _NR_cx_init                                  cx_init
CX_TRAMPOLINE _NR_cx_keccak_init_no_throw                  cx_keccak_init_no_throw
c0d0009c:	b403      	push	{r0, r1}
c0d0009e:	4801      	ldr	r0, [pc, #4]	; (c0d000a4 <cx_keccak_init_no_throw+0x8>)
c0d000a0:	e005      	b.n	c0d000ae <cx_trampoline_helper>
c0d000a2:	0000      	.short	0x0000
c0d000a4:	00000044 	.word	0x00000044

c0d000a8 <cx_swap_uint64>:
CX_TRAMPOLINE _NR_cx_shake128_init_no_throw                cx_shake128_init_no_throw
CX_TRAMPOLINE _NR_cx_shake256_init_no_throw                cx_shake256_init_no_throw
CX_TRAMPOLINE _NR_cx_swap_buffer32                         cx_swap_buffer32
CX_TRAMPOLINE _NR_cx_swap_buffer64                         cx_swap_buffer64
CX_TRAMPOLINE _NR_cx_swap_uint32                           cx_swap_uint32
CX_TRAMPOLINE _NR_cx_swap_uint64                           cx_swap_uint64
c0d000a8:	b403      	push	{r0, r1}
c0d000aa:	4802      	ldr	r0, [pc, #8]	; (c0d000b4 <cx_trampoline_helper+0x6>)
c0d000ac:	e7ff      	b.n	c0d000ae <cx_trampoline_helper>

c0d000ae <cx_trampoline_helper>:

.thumb_func
cx_trampoline_helper:
  ldr  r1, =_cx_trampoline
c0d000ae:	4902      	ldr	r1, [pc, #8]	; (c0d000b8 <cx_trampoline_helper+0xa>)
  bx   r1
c0d000b0:	4708      	bx	r1
c0d000b2:	0000      	.short	0x0000
CX_TRAMPOLINE _NR_cx_swap_uint64                           cx_swap_uint64
c0d000b4:	0000006f 	.word	0x0000006f
  ldr  r1, =_cx_trampoline
c0d000b8:	00120001 	.word	0x00120001

c0d000bc <semihosted_printf>:
        "svc      0xab\n" ::"r"(buf)
        : "r0", "r1");
}

// Special printf function using the `debug_write` function.
int semihosted_printf(const char *format, ...) {
c0d000bc:	b083      	sub	sp, #12
c0d000be:	b510      	push	{r4, lr}
c0d000c0:	b0a3      	sub	sp, #140	; 0x8c
c0d000c2:	4604      	mov	r4, r0
c0d000c4:	a825      	add	r0, sp, #148	; 0x94
c0d000c6:	c00e      	stmia	r0!, {r1, r2, r3}
c0d000c8:	ab25      	add	r3, sp, #148	; 0x94
    char buf[128 + 1];

    va_list args;
    va_start(args, format);
c0d000ca:	9301      	str	r3, [sp, #4]
c0d000cc:	a802      	add	r0, sp, #8
c0d000ce:	2180      	movs	r1, #128	; 0x80

    int ret = vsnprintf(buf, sizeof(buf) - 1, format, args);
c0d000d0:	4622      	mov	r2, r4
c0d000d2:	f001 fe93 	bl	c0d01dfc <vsnprintf_>
c0d000d6:	4602      	mov	r2, r0
    asm volatile(
c0d000d8:	4b09      	ldr	r3, [pc, #36]	; (c0d00100 <semihosted_printf+0x44>)
c0d000da:	447b      	add	r3, pc
c0d000dc:	2004      	movs	r0, #4
c0d000de:	0019      	movs	r1, r3
c0d000e0:	dfab      	svc	171	; 0xab

    va_end(args);

    debug_write("semi-hosting: ");
    if (ret > 0) {
c0d000e2:	2a01      	cmp	r2, #1
c0d000e4:	db05      	blt.n	c0d000f2 <semihosted_printf+0x36>
c0d000e6:	ab02      	add	r3, sp, #8
c0d000e8:	2000      	movs	r0, #0
        buf[ret] = 0;
c0d000ea:	5498      	strb	r0, [r3, r2]
    asm volatile(
c0d000ec:	2004      	movs	r0, #4
c0d000ee:	0019      	movs	r1, r3
c0d000f0:	dfab      	svc	171	; 0xab
        debug_write(buf);
    }

    return ret;
c0d000f2:	4610      	mov	r0, r2
c0d000f4:	b023      	add	sp, #140	; 0x8c
c0d000f6:	bc10      	pop	{r4}
c0d000f8:	bc02      	pop	{r1}
c0d000fa:	b003      	add	sp, #12
c0d000fc:	4708      	bx	r1
c0d000fe:	46c0      	nop			; (mov r8, r8)
c0d00100:	00004c82 	.word	0x00004c82

c0d00104 <print_bytes>:
    'f',
};

// %.*H doesn't work with semi-hosted printf, so here's a utility function to print bytes in hex
// format.
void print_bytes(const uint8_t *bytes, uint16_t len) {
c0d00104:	b570      	push	{r4, r5, r6, lr}
c0d00106:	b081      	sub	sp, #4
c0d00108:	460a      	mov	r2, r1
c0d0010a:	4603      	mov	r3, r0
c0d0010c:	4668      	mov	r0, sp
c0d0010e:	2100      	movs	r1, #0
    unsigned char nibble1, nibble2;
    char str[] = {0, 0, 0};
c0d00110:	7081      	strb	r1, [r0, #2]
c0d00112:	8001      	strh	r1, [r0, #0]
    asm volatile(
c0d00114:	4c12      	ldr	r4, [pc, #72]	; (c0d00160 <print_bytes+0x5c>)
c0d00116:	447c      	add	r4, pc
c0d00118:	2004      	movs	r0, #4
c0d0011a:	0021      	movs	r1, r4
c0d0011c:	dfab      	svc	171	; 0xab

    debug_write("GPIRIOU bytes: ");
    for (uint16_t count = 0; count < len; count++) {
c0d0011e:	2a00      	cmp	r2, #0
c0d00120:	d016      	beq.n	c0d00150 <print_bytes+0x4c>
c0d00122:	4c10      	ldr	r4, [pc, #64]	; (c0d00164 <print_bytes+0x60>)
c0d00124:	447c      	add	r4, pc
c0d00126:	4d10      	ldr	r5, [pc, #64]	; (c0d00168 <print_bytes+0x64>)
c0d00128:	447d      	add	r5, pc
        nibble1 = (bytes[count] >> 4) & 0xF;
c0d0012a:	7818      	ldrb	r0, [r3, #0]
c0d0012c:	210f      	movs	r1, #15
        nibble2 = bytes[count] & 0xF;
c0d0012e:	4001      	ands	r1, r0
        str[0] = G_HEX[nibble1];
        str[1] = G_HEX[nibble2];
c0d00130:	5c61      	ldrb	r1, [r4, r1]
c0d00132:	466e      	mov	r6, sp
c0d00134:	7071      	strb	r1, [r6, #1]
        nibble1 = (bytes[count] >> 4) & 0xF;
c0d00136:	0900      	lsrs	r0, r0, #4
        str[0] = G_HEX[nibble1];
c0d00138:	5c20      	ldrb	r0, [r4, r0]
c0d0013a:	7030      	strb	r0, [r6, #0]
    asm volatile(
c0d0013c:	2004      	movs	r0, #4
c0d0013e:	0031      	movs	r1, r6
c0d00140:	dfab      	svc	171	; 0xab
c0d00142:	2004      	movs	r0, #4
c0d00144:	0029      	movs	r1, r5
c0d00146:	dfab      	svc	171	; 0xab
    for (uint16_t count = 0; count < len; count++) {
c0d00148:	1e52      	subs	r2, r2, #1
c0d0014a:	1c5b      	adds	r3, r3, #1
c0d0014c:	2a00      	cmp	r2, #0
c0d0014e:	d1ec      	bne.n	c0d0012a <print_bytes+0x26>
    asm volatile(
c0d00150:	4a06      	ldr	r2, [pc, #24]	; (c0d0016c <print_bytes+0x68>)
c0d00152:	447a      	add	r2, pc
c0d00154:	2004      	movs	r0, #4
c0d00156:	0011      	movs	r1, r2
c0d00158:	dfab      	svc	171	; 0xab
        debug_write(str);
        debug_write(" ");
    }
    debug_write("\n");
c0d0015a:	b001      	add	sp, #4
c0d0015c:	bd70      	pop	{r4, r5, r6, pc}
c0d0015e:	46c0      	nop			; (mov r8, r8)
c0d00160:	00004c55 	.word	0x00004c55
c0d00164:	00004c57 	.word	0x00004c57
c0d00168:	00004c41 	.word	0x00004c41
c0d0016c:	00004cac 	.word	0x00004cac

c0d00170 <getEthAddressStringFromBinary>:
#include "eth_internals.h"

void getEthAddressStringFromBinary(uint8_t *address,
                                   uint8_t *out,
                                   cx_sha3_t *sha3Context,
                                   chain_config_t *chain_config) {
c0d00170:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00172:	b093      	sub	sp, #76	; 0x4c
c0d00174:	9203      	str	r2, [sp, #12]
c0d00176:	9105      	str	r1, [sp, #20]
c0d00178:	4605      	mov	r5, r0
    } locals_union;

    uint8_t i;
    bool eip1191 = false;
    uint32_t offset = 0;
    switch (chain_config->chainId) {
c0d0017a:	68db      	ldr	r3, [r3, #12]
c0d0017c:	2101      	movs	r1, #1
c0d0017e:	4618      	mov	r0, r3
c0d00180:	9102      	str	r1, [sp, #8]
c0d00182:	4388      	bics	r0, r1
c0d00184:	2700      	movs	r7, #0
        case 30:
        case 31:
            eip1191 = true;
            break;
    }
    if (eip1191) {
c0d00186:	281e      	cmp	r0, #30
c0d00188:	4638      	mov	r0, r7
c0d0018a:	d109      	bne.n	c0d001a0 <getEthAddressStringFromBinary+0x30>
c0d0018c:	ae06      	add	r6, sp, #24
c0d0018e:	2133      	movs	r1, #51	; 0x33
        snprintf((char *) locals_union.tmp,
c0d00190:	4a2b      	ldr	r2, [pc, #172]	; (c0d00240 <getEthAddressStringFromBinary+0xd0>)
c0d00192:	447a      	add	r2, pc
c0d00194:	4630      	mov	r0, r6
c0d00196:	f001 f987 	bl	c0d014a8 <snprintf>
                 sizeof(locals_union.tmp),
                 "%d0x",
                 chain_config->chainId);
        offset = strlen((char *) locals_union.tmp);
c0d0019a:	4630      	mov	r0, r6
c0d0019c:	f004 fd7a 	bl	c0d04c94 <strlen>
c0d001a0:	a906      	add	r1, sp, #24
c0d001a2:	9004      	str	r0, [sp, #16]
    }
    for (i = 0; i < 20; i++) {
c0d001a4:	1808      	adds	r0, r1, r0
c0d001a6:	4e27      	ldr	r6, [pc, #156]	; (c0d00244 <getEthAddressStringFromBinary+0xd4>)
c0d001a8:	447e      	add	r6, pc
        uint8_t digit = address[i];
c0d001aa:	5de9      	ldrb	r1, [r5, r7]
c0d001ac:	240f      	movs	r4, #15
        locals_union.tmp[offset + 2 * i] = HEXDIGITS[(digit >> 4) & 0x0f];
c0d001ae:	090a      	lsrs	r2, r1, #4
        locals_union.tmp[offset + 2 * i + 1] = HEXDIGITS[digit & 0x0f];
c0d001b0:	4021      	ands	r1, r4
c0d001b2:	5c71      	ldrb	r1, [r6, r1]
c0d001b4:	7041      	strb	r1, [r0, #1]
        locals_union.tmp[offset + 2 * i] = HEXDIGITS[(digit >> 4) & 0x0f];
c0d001b6:	5cb1      	ldrb	r1, [r6, r2]
c0d001b8:	7001      	strb	r1, [r0, #0]
    for (i = 0; i < 20; i++) {
c0d001ba:	1c80      	adds	r0, r0, #2
c0d001bc:	1c7f      	adds	r7, r7, #1
c0d001be:	2f14      	cmp	r7, #20
c0d001c0:	d1f3      	bne.n	c0d001aa <getEthAddressStringFromBinary+0x3a>
c0d001c2:	9802      	ldr	r0, [sp, #8]
c0d001c4:	0201      	lsls	r1, r0, #8
c0d001c6:	9f03      	ldr	r7, [sp, #12]
 */
cx_err_t cx_keccak_init_no_throw(cx_sha3_t *hash, size_t size);

static inline int cx_keccak_init ( cx_sha3_t * hash, size_t size )
{
  CX_THROW(cx_keccak_init_no_throw(hash, size));
c0d001c8:	4638      	mov	r0, r7
c0d001ca:	f7ff ff67 	bl	c0d0009c <cx_keccak_init_no_throw>
c0d001ce:	2800      	cmp	r0, #0
c0d001d0:	d134      	bne.n	c0d0023c <getEthAddressStringFromBinary+0xcc>
c0d001d2:	2020      	movs	r0, #32
 */
cx_err_t cx_hash_no_throw(cx_hash_t *hash, uint32_t mode, const uint8_t *in, size_t len, uint8_t *out, size_t out_len);

static inline int cx_hash ( cx_hash_t * hash, int mode, const unsigned char * in, unsigned int len, unsigned char * out, unsigned int out_len )
{
  CX_THROW(cx_hash_no_throw(hash, mode, in, len, out, out_len));
c0d001d4:	9001      	str	r0, [sp, #4]
c0d001d6:	aa06      	add	r2, sp, #24
c0d001d8:	9200      	str	r2, [sp, #0]
c0d001da:	9b04      	ldr	r3, [sp, #16]
    }
    cx_keccak_init(sha3Context, 256);
    cx_hash((cx_hash_t *) sha3Context,
            CX_LAST,
            locals_union.tmp,
            offset + 40,
c0d001dc:	3328      	adds	r3, #40	; 0x28
c0d001de:	2101      	movs	r1, #1
c0d001e0:	4638      	mov	r0, r7
c0d001e2:	9104      	str	r1, [sp, #16]
c0d001e4:	f7ff ff54 	bl	c0d00090 <cx_hash_no_throw>
c0d001e8:	2800      	cmp	r0, #0
c0d001ea:	d127      	bne.n	c0d0023c <getEthAddressStringFromBinary+0xcc>
  return cx_hash_get_size(hash);
c0d001ec:	4638      	mov	r0, r7
c0d001ee:	f7ff ff49 	bl	c0d00084 <cx_hash_get_size>
c0d001f2:	2000      	movs	r0, #0
            locals_union.hashChecksum,
            32);
    for (i = 0; i < 40; i++) {
        uint8_t digit = address[i / 2];
        if ((i % 2) == 0) {
c0d001f4:	4602      	mov	r2, r0
c0d001f6:	9904      	ldr	r1, [sp, #16]
c0d001f8:	400a      	ands	r2, r1
        uint8_t digit = address[i / 2];
c0d001fa:	0843      	lsrs	r3, r0, #1
c0d001fc:	5ce9      	ldrb	r1, [r5, r3]
        if ((i % 2) == 0) {
c0d001fe:	2a00      	cmp	r2, #0
c0d00200:	d001      	beq.n	c0d00206 <getEthAddressStringFromBinary+0x96>
c0d00202:	4021      	ands	r1, r4
c0d00204:	e000      	b.n	c0d00208 <getEthAddressStringFromBinary+0x98>
c0d00206:	0909      	lsrs	r1, r1, #4
            digit = (digit >> 4) & 0x0f;
        } else {
            digit = digit & 0x0f;
        }
        if (digit < 10) {
c0d00208:	2909      	cmp	r1, #9
c0d0020a:	d801      	bhi.n	c0d00210 <getEthAddressStringFromBinary+0xa0>
            out[i] = HEXDIGITS[digit];
c0d0020c:	5c71      	ldrb	r1, [r6, r1]
c0d0020e:	e00a      	b.n	c0d00226 <getEthAddressStringFromBinary+0xb6>
c0d00210:	af06      	add	r7, sp, #24
        } else {
            int v = (locals_union.hashChecksum[i / 2] >> (4 * (1 - i % 2))) & 0x0f;
c0d00212:	5cfb      	ldrb	r3, [r7, r3]
c0d00214:	0092      	lsls	r2, r2, #2
c0d00216:	2704      	movs	r7, #4
c0d00218:	4057      	eors	r7, r2
c0d0021a:	2208      	movs	r2, #8
            if (v >= 8) {
c0d0021c:	40ba      	lsls	r2, r7
c0d0021e:	5c71      	ldrb	r1, [r6, r1]
c0d00220:	421a      	tst	r2, r3
c0d00222:	d000      	beq.n	c0d00226 <getEthAddressStringFromBinary+0xb6>
c0d00224:	3920      	subs	r1, #32
c0d00226:	9a05      	ldr	r2, [sp, #20]
c0d00228:	5411      	strb	r1, [r2, r0]
    for (i = 0; i < 40; i++) {
c0d0022a:	1c40      	adds	r0, r0, #1
c0d0022c:	2828      	cmp	r0, #40	; 0x28
c0d0022e:	d1e1      	bne.n	c0d001f4 <getEthAddressStringFromBinary+0x84>
c0d00230:	2028      	movs	r0, #40	; 0x28
c0d00232:	2100      	movs	r1, #0
            } else {
                out[i] = HEXDIGITS[digit];
            }
        }
    }
    out[40] = '\0';
c0d00234:	9a05      	ldr	r2, [sp, #20]
c0d00236:	5411      	strb	r1, [r2, r0]
}
c0d00238:	b013      	add	sp, #76	; 0x4c
c0d0023a:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0023c:	f001 f926 	bl	c0d0148c <os_longjmp>
c0d00240:	00004bf9 	.word	0x00004bf9
c0d00244:	00004be8 	.word	0x00004be8

c0d00248 <adjustDecimals>:

bool adjustDecimals(char *src,
                    uint32_t srcLength,
                    char *target,
                    uint32_t targetLength,
                    uint8_t decimals) {
c0d00248:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0024a:	b083      	sub	sp, #12
c0d0024c:	461d      	mov	r5, r3
c0d0024e:	4614      	mov	r4, r2
c0d00250:	460f      	mov	r7, r1
c0d00252:	4606      	mov	r6, r0
    PRINTF("GPIRIOU ADJUST DEC TMP BUFFER:\n");
c0d00254:	484c      	ldr	r0, [pc, #304]	; (c0d00388 <adjustDecimals+0x140>)
c0d00256:	4478      	add	r0, pc
c0d00258:	f7ff ff30 	bl	c0d000bc <semihosted_printf>
    PRINTF("GPIRIOU srcLength: %d\n", srcLength);
c0d0025c:	484b      	ldr	r0, [pc, #300]	; (c0d0038c <adjustDecimals+0x144>)
c0d0025e:	4478      	add	r0, pc
c0d00260:	4639      	mov	r1, r7
c0d00262:	f7ff ff2b 	bl	c0d000bc <semihosted_printf>
    PRINTF("GPIRIOU targetLength: %d\n", targetLength);
c0d00266:	484a      	ldr	r0, [pc, #296]	; (c0d00390 <adjustDecimals+0x148>)
c0d00268:	4478      	add	r0, pc
c0d0026a:	4629      	mov	r1, r5
c0d0026c:	f7ff ff26 	bl	c0d000bc <semihosted_printf>

    uint32_t startOffset;
    uint32_t lastZeroOffset = 0;
    uint32_t offset = 0;
    if ((srcLength == 1) && (*src == '0')) {
c0d00270:	2f01      	cmp	r7, #1
c0d00272:	d107      	bne.n	c0d00284 <adjustDecimals+0x3c>
c0d00274:	7830      	ldrb	r0, [r6, #0]
c0d00276:	2830      	cmp	r0, #48	; 0x30
c0d00278:	d104      	bne.n	c0d00284 <adjustDecimals+0x3c>
        if (targetLength < 2) {
c0d0027a:	2d01      	cmp	r5, #1
c0d0027c:	d846      	bhi.n	c0d0030c <adjustDecimals+0xc4>
            PRINTF("GPIRIOU !!!!\n");
c0d0027e:	4845      	ldr	r0, [pc, #276]	; (c0d00394 <adjustDecimals+0x14c>)
c0d00280:	4478      	add	r0, pc
c0d00282:	e00d      	b.n	c0d002a0 <adjustDecimals+0x58>
c0d00284:	9908      	ldr	r1, [sp, #32]
        }
        target[0] = '0';
        target[1] = '\0';
        return true;
    }
    if (srcLength <= decimals) {
c0d00286:	42b9      	cmp	r1, r7
c0d00288:	d205      	bcs.n	c0d00296 <adjustDecimals+0x4e>
        }
        target[offset] = '\0';
    } else {
        uint32_t sourceOffset = 0;
        uint32_t delta = srcLength - decimals;
        if (targetLength < srcLength + 1 + 1) {
c0d0028a:	1cb8      	adds	r0, r7, #2
c0d0028c:	42a8      	cmp	r0, r5
c0d0028e:	d90b      	bls.n	c0d002a8 <adjustDecimals+0x60>
            PRINTF("GPIRIOU 22222222211\n");
c0d00290:	4843      	ldr	r0, [pc, #268]	; (c0d003a0 <adjustDecimals+0x158>)
c0d00292:	4478      	add	r0, pc
c0d00294:	e004      	b.n	c0d002a0 <adjustDecimals+0x58>
        if (targetLength < srcLength + 1 + 2 + delta) {
c0d00296:	1cc8      	adds	r0, r1, #3
c0d00298:	42a8      	cmp	r0, r5
c0d0029a:	d926      	bls.n	c0d002ea <adjustDecimals+0xa2>
            PRINTF("GPIRIOU 11111111111\n");
c0d0029c:	483e      	ldr	r0, [pc, #248]	; (c0d00398 <adjustDecimals+0x150>)
c0d0029e:	4478      	add	r0, pc
c0d002a0:	f7ff ff0c 	bl	c0d000bc <semihosted_printf>
c0d002a4:	2000      	movs	r0, #0
c0d002a6:	e06c      	b.n	c0d00382 <adjustDecimals+0x13a>
c0d002a8:	9502      	str	r5, [sp, #8]
c0d002aa:	1a78      	subs	r0, r7, r1
            return false;
        }
        while (offset < delta) {
c0d002ac:	9001      	str	r0, [sp, #4]
c0d002ae:	d009      	beq.n	c0d002c4 <adjustDecimals+0x7c>
c0d002b0:	4630      	mov	r0, r6
c0d002b2:	9b01      	ldr	r3, [sp, #4]
c0d002b4:	4625      	mov	r5, r4
            target[offset++] = src[sourceOffset++];
c0d002b6:	7802      	ldrb	r2, [r0, #0]
c0d002b8:	702a      	strb	r2, [r5, #0]
        while (offset < delta) {
c0d002ba:	1c40      	adds	r0, r0, #1
c0d002bc:	1e5b      	subs	r3, r3, #1
c0d002be:	1c6d      	adds	r5, r5, #1
c0d002c0:	2b00      	cmp	r3, #0
c0d002c2:	d1f8      	bne.n	c0d002b6 <adjustDecimals+0x6e>
        }
        if (decimals != 0) {
c0d002c4:	2900      	cmp	r1, #0
c0d002c6:	9a01      	ldr	r2, [sp, #4]
c0d002c8:	4610      	mov	r0, r2
c0d002ca:	d002      	beq.n	c0d002d2 <adjustDecimals+0x8a>
c0d002cc:	202e      	movs	r0, #46	; 0x2e
            target[offset++] = '.';
c0d002ce:	54a0      	strb	r0, [r4, r2]
c0d002d0:	1c50      	adds	r0, r2, #1
        }
        startOffset = offset;
        while (sourceOffset < srcLength) {
c0d002d2:	42ba      	cmp	r2, r7
c0d002d4:	d21f      	bcs.n	c0d00316 <adjustDecimals+0xce>
c0d002d6:	1823      	adds	r3, r4, r0
c0d002d8:	18b5      	adds	r5, r6, r2
c0d002da:	2200      	movs	r2, #0
            target[offset++] = src[sourceOffset++];
c0d002dc:	5cae      	ldrb	r6, [r5, r2]
c0d002de:	549e      	strb	r6, [r3, r2]
        while (sourceOffset < srcLength) {
c0d002e0:	1c52      	adds	r2, r2, #1
c0d002e2:	4291      	cmp	r1, r2
c0d002e4:	d1fa      	bne.n	c0d002dc <adjustDecimals+0x94>
c0d002e6:	1881      	adds	r1, r0, r2
c0d002e8:	e016      	b.n	c0d00318 <adjustDecimals+0xd0>
c0d002ea:	9502      	str	r5, [sp, #8]
c0d002ec:	1bcd      	subs	r5, r1, r7
c0d002ee:	202e      	movs	r0, #46	; 0x2e
        target[offset++] = '.';
c0d002f0:	7060      	strb	r0, [r4, #1]
c0d002f2:	2030      	movs	r0, #48	; 0x30
        target[offset++] = '0';
c0d002f4:	7020      	strb	r0, [r4, #0]
        for (uint32_t i = 0; i < delta; i++) {
c0d002f6:	2d00      	cmp	r5, #0
c0d002f8:	d010      	beq.n	c0d0031c <adjustDecimals+0xd4>
c0d002fa:	1ca0      	adds	r0, r4, #2
c0d002fc:	2230      	movs	r2, #48	; 0x30
            target[offset++] = '0';
c0d002fe:	4629      	mov	r1, r5
c0d00300:	f004 fc75 	bl	c0d04bee <__aeabi_memset>
        for (uint32_t i = 0; i < delta; i++) {
c0d00304:	1ca8      	adds	r0, r5, #2
c0d00306:	1e6d      	subs	r5, r5, #1
c0d00308:	d1fd      	bne.n	c0d00306 <adjustDecimals+0xbe>
c0d0030a:	e008      	b.n	c0d0031e <adjustDecimals+0xd6>
c0d0030c:	2000      	movs	r0, #0
        target[1] = '\0';
c0d0030e:	7060      	strb	r0, [r4, #1]
c0d00310:	2030      	movs	r0, #48	; 0x30
        target[0] = '0';
c0d00312:	7020      	strb	r0, [r4, #0]
c0d00314:	e034      	b.n	c0d00380 <adjustDecimals+0x138>
c0d00316:	4601      	mov	r1, r0
c0d00318:	9d02      	ldr	r5, [sp, #8]
c0d0031a:	e00d      	b.n	c0d00338 <adjustDecimals+0xf0>
c0d0031c:	2002      	movs	r0, #2
        for (uint32_t i = 0; i < srcLength; i++) {
c0d0031e:	2f00      	cmp	r7, #0
c0d00320:	9d02      	ldr	r5, [sp, #8]
c0d00322:	d008      	beq.n	c0d00336 <adjustDecimals+0xee>
c0d00324:	1822      	adds	r2, r4, r0
c0d00326:	2100      	movs	r1, #0
            target[offset++] = src[i];
c0d00328:	5c73      	ldrb	r3, [r6, r1]
c0d0032a:	5453      	strb	r3, [r2, r1]
        for (uint32_t i = 0; i < srcLength; i++) {
c0d0032c:	1c49      	adds	r1, r1, #1
c0d0032e:	428f      	cmp	r7, r1
c0d00330:	d1fa      	bne.n	c0d00328 <adjustDecimals+0xe0>
c0d00332:	1841      	adds	r1, r0, r1
c0d00334:	e000      	b.n	c0d00338 <adjustDecimals+0xf0>
c0d00336:	4601      	mov	r1, r0
c0d00338:	2300      	movs	r3, #0
c0d0033a:	5463      	strb	r3, [r4, r1]
        }
        target[offset] = '\0';
    }
    for (uint32_t i = startOffset; i < offset; i++) {
c0d0033c:	4288      	cmp	r0, r1
c0d0033e:	d216      	bcs.n	c0d0036e <adjustDecimals+0x126>
c0d00340:	462e      	mov	r6, r5
        if (target[i] == '0') {
c0d00342:	5c25      	ldrb	r5, [r4, r0]
c0d00344:	2b00      	cmp	r3, #0
c0d00346:	4602      	mov	r2, r0
c0d00348:	d000      	beq.n	c0d0034c <adjustDecimals+0x104>
c0d0034a:	461a      	mov	r2, r3
c0d0034c:	2d30      	cmp	r5, #48	; 0x30
c0d0034e:	d000      	beq.n	c0d00352 <adjustDecimals+0x10a>
c0d00350:	2200      	movs	r2, #0
    for (uint32_t i = startOffset; i < offset; i++) {
c0d00352:	1c40      	adds	r0, r0, #1
c0d00354:	4281      	cmp	r1, r0
c0d00356:	4613      	mov	r3, r2
c0d00358:	d1f3      	bne.n	c0d00342 <adjustDecimals+0xfa>
            }
        } else {
            lastZeroOffset = 0;
        }
    }
    if (lastZeroOffset != 0) {
c0d0035a:	2a00      	cmp	r2, #0
c0d0035c:	4635      	mov	r5, r6
c0d0035e:	d006      	beq.n	c0d0036e <adjustDecimals+0x126>
c0d00360:	2000      	movs	r0, #0
        target[lastZeroOffset] = '\0';
c0d00362:	54a0      	strb	r0, [r4, r2]
        if (target[lastZeroOffset - 1] == '.') {
c0d00364:	1e51      	subs	r1, r2, #1
c0d00366:	5c62      	ldrb	r2, [r4, r1]
c0d00368:	2a2e      	cmp	r2, #46	; 0x2e
c0d0036a:	d100      	bne.n	c0d0036e <adjustDecimals+0x126>
            target[lastZeroOffset - 1] = '\0';
c0d0036c:	5460      	strb	r0, [r4, r1]
        }
    }
    PRINTF("GPIRIOU target: %s\n", target);
c0d0036e:	480b      	ldr	r0, [pc, #44]	; (c0d0039c <adjustDecimals+0x154>)
c0d00370:	4478      	add	r0, pc
c0d00372:	4621      	mov	r1, r4
c0d00374:	f7ff fea2 	bl	c0d000bc <semihosted_printf>
    print_bytes(target, targetLength);
c0d00378:	b2a9      	uxth	r1, r5
c0d0037a:	4620      	mov	r0, r4
c0d0037c:	f7ff fec2 	bl	c0d00104 <print_bytes>
c0d00380:	2001      	movs	r0, #1
    return true;
}
c0d00382:	b003      	add	sp, #12
c0d00384:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00386:	46c0      	nop			; (mov r8, r8)
c0d00388:	00004b4b 	.word	0x00004b4b
c0d0038c:	00004b63 	.word	0x00004b63
c0d00390:	00004b70 	.word	0x00004b70
c0d00394:	00004b72 	.word	0x00004b72
c0d00398:	00004b62 	.word	0x00004b62
c0d0039c:	00004aba 	.word	0x00004aba
c0d003a0:	00004b83 	.word	0x00004b83

c0d003a4 <uint256_to_decimal>:

bool uint256_to_decimal(const uint8_t *value, size_t value_len, char *out, size_t out_len) {
c0d003a4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d003a6:	b08b      	sub	sp, #44	; 0x2c
    if (value_len > INT256_LENGTH) {
c0d003a8:	2920      	cmp	r1, #32
c0d003aa:	d901      	bls.n	c0d003b0 <uint256_to_decimal+0xc>
c0d003ac:	2000      	movs	r0, #0
c0d003ae:	e056      	b.n	c0d0045e <uint256_to_decimal+0xba>
c0d003b0:	4614      	mov	r4, r2
c0d003b2:	460e      	mov	r6, r1
c0d003b4:	4607      	mov	r7, r0
c0d003b6:	ad03      	add	r5, sp, #12
c0d003b8:	2120      	movs	r1, #32
        // value len is bigger than INT256_LENGTH ?!
        return false;
    }

    uint16_t n[16] = {0};
c0d003ba:	4628      	mov	r0, r5
c0d003bc:	9302      	str	r3, [sp, #8]
c0d003be:	f004 fc09 	bl	c0d04bd4 <__aeabi_memclr>
    // Copy and right-align the number
    memcpy((uint8_t *) n + INT256_LENGTH - value_len, value, value_len);
c0d003c2:	1ba8      	subs	r0, r5, r6
c0d003c4:	3020      	adds	r0, #32
c0d003c6:	4639      	mov	r1, r7
c0d003c8:	4632      	mov	r2, r6
c0d003ca:	f004 fc08 	bl	c0d04bde <__aeabi_memcpy>
c0d003ce:	9a02      	ldr	r2, [sp, #8]
c0d003d0:	2000      	movs	r0, #0
c0d003d2:	a903      	add	r1, sp, #12
} chain_config_t;

__attribute__((no_instrument_function)) inline int allzeroes(void *buf, size_t n) {
    uint8_t *p = (uint8_t *) buf;
    for (size_t i = 0; i < n; ++i) {
        if (p[i]) {
c0d003d4:	5c09      	ldrb	r1, [r1, r0]
c0d003d6:	2900      	cmp	r1, #0
c0d003d8:	d10a      	bne.n	c0d003f0 <uint256_to_decimal+0x4c>
c0d003da:	1c40      	adds	r0, r0, #1
    for (size_t i = 0; i < n; ++i) {
c0d003dc:	2820      	cmp	r0, #32
c0d003de:	d1f8      	bne.n	c0d003d2 <uint256_to_decimal+0x2e>

    // Special case when value is 0
    if (allzeroes(n, INT256_LENGTH)) {
        if (out_len < 2) {
c0d003e0:	2a02      	cmp	r2, #2
c0d003e2:	d3e3      	bcc.n	c0d003ac <uint256_to_decimal+0x8>
            // Not enough space to hold "0" and \0.
            return false;
        }
        strncpy(out, "0", out_len);
c0d003e4:	491f      	ldr	r1, [pc, #124]	; (c0d00464 <uint256_to_decimal+0xc0>)
c0d003e6:	4479      	add	r1, pc
c0d003e8:	4620      	mov	r0, r4
c0d003ea:	f004 fc5a 	bl	c0d04ca2 <strncpy>
c0d003ee:	e035      	b.n	c0d0045c <uint256_to_decimal+0xb8>
c0d003f0:	2000      	movs	r0, #0
c0d003f2:	a903      	add	r1, sp, #12
        return true;
    }

    uint16_t *p = n;
    for (int i = 0; i < 16; i++) {
        n[i] = __builtin_bswap16(*p++);
c0d003f4:	5a0b      	ldrh	r3, [r1, r0]
c0d003f6:	ba5b      	rev16	r3, r3
c0d003f8:	520b      	strh	r3, [r1, r0]
    for (int i = 0; i < 16; i++) {
c0d003fa:	1c80      	adds	r0, r0, #2
c0d003fc:	2820      	cmp	r0, #32
c0d003fe:	d1f8      	bne.n	c0d003f2 <uint256_to_decimal+0x4e>
c0d00400:	4613      	mov	r3, r2
c0d00402:	2000      	movs	r0, #0
c0d00404:	a903      	add	r1, sp, #12
        if (p[i]) {
c0d00406:	5c09      	ldrb	r1, [r1, r0]
c0d00408:	2900      	cmp	r1, #0
c0d0040a:	d103      	bne.n	c0d00414 <uint256_to_decimal+0x70>
c0d0040c:	1c40      	adds	r0, r0, #1
    for (size_t i = 0; i < n; ++i) {
c0d0040e:	2820      	cmp	r0, #32
c0d00410:	d1f8      	bne.n	c0d00404 <uint256_to_decimal+0x60>
c0d00412:	e01b      	b.n	c0d0044c <uint256_to_decimal+0xa8>
    }
    int pos = out_len;
    while (!allzeroes(n, sizeof(n))) {
        if (pos == 0) {
c0d00414:	2b00      	cmp	r3, #0
c0d00416:	d0c9      	beq.n	c0d003ac <uint256_to_decimal+0x8>
c0d00418:	9300      	str	r3, [sp, #0]
c0d0041a:	9401      	str	r4, [sp, #4]
c0d0041c:	2400      	movs	r4, #0
c0d0041e:	4620      	mov	r0, r4
c0d00420:	af03      	add	r7, sp, #12
            return false;
        }
        pos -= 1;
        int carry = 0;
        for (int i = 0; i < 16; i++) {
            int rem = ((carry << 16) | n[i]) % 10;
c0d00422:	5b39      	ldrh	r1, [r7, r4]
c0d00424:	0400      	lsls	r0, r0, #16
c0d00426:	1845      	adds	r5, r0, r1
c0d00428:	260a      	movs	r6, #10
            n[i] = ((carry << 16) | n[i]) / 10;
c0d0042a:	4628      	mov	r0, r5
c0d0042c:	4631      	mov	r1, r6
c0d0042e:	f002 fb5d 	bl	c0d02aec <__divsi3>
c0d00432:	5338      	strh	r0, [r7, r4]
c0d00434:	4346      	muls	r6, r0
c0d00436:	1ba8      	subs	r0, r5, r6
        for (int i = 0; i < 16; i++) {
c0d00438:	1ca4      	adds	r4, r4, #2
c0d0043a:	2c20      	cmp	r4, #32
c0d0043c:	d1f0      	bne.n	c0d00420 <uint256_to_decimal+0x7c>
c0d0043e:	9b00      	ldr	r3, [sp, #0]
        pos -= 1;
c0d00440:	1e5b      	subs	r3, r3, #1
            carry = rem;
        }
        out[pos] = '0' + carry;
c0d00442:	3030      	adds	r0, #48	; 0x30
c0d00444:	9c01      	ldr	r4, [sp, #4]
c0d00446:	54e0      	strb	r0, [r4, r3]
c0d00448:	9a02      	ldr	r2, [sp, #8]
c0d0044a:	e7da      	b.n	c0d00402 <uint256_to_decimal+0x5e>
    }
    memmove(out, out + pos, out_len - pos);
c0d0044c:	18e1      	adds	r1, r4, r3
c0d0044e:	1ad5      	subs	r5, r2, r3
c0d00450:	4620      	mov	r0, r4
c0d00452:	462a      	mov	r2, r5
c0d00454:	f004 fbc7 	bl	c0d04be6 <__aeabi_memmove>
c0d00458:	2000      	movs	r0, #0
    out[out_len - pos] = 0;
c0d0045a:	5560      	strb	r0, [r4, r5]
c0d0045c:	2001      	movs	r0, #1
    return true;
}
c0d0045e:	b00b      	add	sp, #44	; 0x2c
c0d00460:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00462:	46c0      	nop			; (mov r8, r8)
c0d00464:	0000514f 	.word	0x0000514f

c0d00468 <amountToString>:
void amountToString(const uint8_t *amount,
                    uint8_t amount_size,
                    uint8_t decimals,
                    const char *ticker,
                    char *out_buffer,
                    uint8_t out_buffer_size) {
c0d00468:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0046a:	b09f      	sub	sp, #124	; 0x7c
c0d0046c:	9304      	str	r3, [sp, #16]
c0d0046e:	9203      	str	r2, [sp, #12]
c0d00470:	460c      	mov	r4, r1
c0d00472:	4605      	mov	r5, r0
c0d00474:	ae06      	add	r6, sp, #24
c0d00476:	2764      	movs	r7, #100	; 0x64
    char tmp_buffer[100] = {0};
c0d00478:	4630      	mov	r0, r6
c0d0047a:	4639      	mov	r1, r7
c0d0047c:	f004 fbaa 	bl	c0d04bd4 <__aeabi_memclr>

    bool success = uint256_to_decimal(amount, amount_size, tmp_buffer, sizeof(tmp_buffer));
c0d00480:	4628      	mov	r0, r5
c0d00482:	4621      	mov	r1, r4
c0d00484:	4632      	mov	r2, r6
c0d00486:	463b      	mov	r3, r7
c0d00488:	f7ff ff8c 	bl	c0d003a4 <uint256_to_decimal>

    if (!success) {
c0d0048c:	2800      	cmp	r0, #0
c0d0048e:	d050      	beq.n	c0d00532 <amountToString+0xca>
c0d00490:	9e25      	ldr	r6, [sp, #148]	; 0x94
c0d00492:	9d24      	ldr	r5, [sp, #144]	; 0x90
c0d00494:	a806      	add	r0, sp, #24
c0d00496:	2464      	movs	r4, #100	; 0x64
c0d00498:	9005      	str	r0, [sp, #20]
        THROW(0x6504);
    }

    uint8_t amount_len = strnlen(tmp_buffer, sizeof(tmp_buffer));
c0d0049a:	4621      	mov	r1, r4
c0d0049c:	f004 fc15 	bl	c0d04cca <strnlen>
c0d004a0:	9001      	str	r0, [sp, #4]
c0d004a2:	210c      	movs	r1, #12
    uint8_t ticker_len = strnlen(ticker, MAX_TICKER_LEN);
c0d004a4:	9804      	ldr	r0, [sp, #16]
c0d004a6:	f004 fc10 	bl	c0d04cca <strnlen>

    memcpy(out_buffer, ticker, MIN(out_buffer_size, ticker_len));
c0d004aa:	b2c7      	uxtb	r7, r0
c0d004ac:	42be      	cmp	r6, r7
c0d004ae:	9602      	str	r6, [sp, #8]
c0d004b0:	4632      	mov	r2, r6
c0d004b2:	d300      	bcc.n	c0d004b6 <amountToString+0x4e>
c0d004b4:	463a      	mov	r2, r7
c0d004b6:	4628      	mov	r0, r5
c0d004b8:	9904      	ldr	r1, [sp, #16]
c0d004ba:	f004 fb90 	bl	c0d04bde <__aeabi_memcpy>
    // PRINTF("GPIRIOU out buffer: %s\n", out_buffer);
    // print_bytes(out_buffer, out_buffer_size);
    PRINTF("GPIRIOU tmp buffer: %s\n", tmp_buffer);
c0d004be:	481f      	ldr	r0, [pc, #124]	; (c0d0053c <amountToString+0xd4>)
c0d004c0:	4478      	add	r0, pc
c0d004c2:	9e05      	ldr	r6, [sp, #20]
c0d004c4:	4631      	mov	r1, r6
c0d004c6:	f7ff fdf9 	bl	c0d000bc <semihosted_printf>
    print_bytes(tmp_buffer, sizeof(tmp_buffer));
c0d004ca:	4630      	mov	r0, r6
c0d004cc:	4621      	mov	r1, r4
c0d004ce:	f7ff fe19 	bl	c0d00104 <print_bytes>
    PRINTF("GPIRIOU amount len: %d\n", amount_len);
c0d004d2:	9801      	ldr	r0, [sp, #4]
c0d004d4:	b2c1      	uxtb	r1, r0
c0d004d6:	9104      	str	r1, [sp, #16]
c0d004d8:	4819      	ldr	r0, [pc, #100]	; (c0d00540 <amountToString+0xd8>)
c0d004da:	4478      	add	r0, pc
c0d004dc:	f7ff fdee 	bl	c0d000bc <semihosted_printf>
    PRINTF("GPIRIOU out buffer: %s\n", out_buffer);
c0d004e0:	4818      	ldr	r0, [pc, #96]	; (c0d00544 <amountToString+0xdc>)
c0d004e2:	4478      	add	r0, pc
c0d004e4:	4629      	mov	r1, r5
c0d004e6:	f7ff fde9 	bl	c0d000bc <semihosted_printf>
    print_bytes(out_buffer, out_buffer_size);
c0d004ea:	4628      	mov	r0, r5
c0d004ec:	9e02      	ldr	r6, [sp, #8]
c0d004ee:	4631      	mov	r1, r6
c0d004f0:	f7ff fe08 	bl	c0d00104 <print_bytes>
    PRINTF("GPIRIOU out buffer + ticker len: %s\n", out_buffer + ticker_len);
c0d004f4:	19ec      	adds	r4, r5, r7
c0d004f6:	4814      	ldr	r0, [pc, #80]	; (c0d00548 <amountToString+0xe0>)
c0d004f8:	4478      	add	r0, pc
c0d004fa:	4621      	mov	r1, r4
c0d004fc:	f7ff fdde 	bl	c0d000bc <semihosted_printf>
    print_bytes(out_buffer + ticker_len, out_buffer_size - ticker_len);
c0d00500:	1bf7      	subs	r7, r6, r7
c0d00502:	b2b9      	uxth	r1, r7
c0d00504:	4620      	mov	r0, r4
c0d00506:	f7ff fdfd 	bl	c0d00104 <print_bytes>
    PRINTF("GPIRIOU out buffer size - ticker_len - 1: %d\n", out_buffer_size - ticker_len - 1);
c0d0050a:	1e7f      	subs	r7, r7, #1
c0d0050c:	480f      	ldr	r0, [pc, #60]	; (c0d0054c <amountToString+0xe4>)
c0d0050e:	4478      	add	r0, pc
c0d00510:	4639      	mov	r1, r7
c0d00512:	f7ff fdd3 	bl	c0d000bc <semihosted_printf>
    // PRINTF("GPIRIOU decimals: %d\n", decimals);
    // PRINTF("GPIRIOU tmp buffer: %s\n", tmp_buffer);
    // print_bytes(tmp_buffer, sizeof(tmp_buffer));

    adjustDecimals(tmp_buffer,
c0d00516:	9803      	ldr	r0, [sp, #12]
c0d00518:	9000      	str	r0, [sp, #0]
c0d0051a:	9805      	ldr	r0, [sp, #20]
c0d0051c:	9904      	ldr	r1, [sp, #16]
c0d0051e:	4622      	mov	r2, r4
c0d00520:	463b      	mov	r3, r7
c0d00522:	f7ff fe91 	bl	c0d00248 <adjustDecimals>
                   amount_len,
                   out_buffer + ticker_len,
                   out_buffer_size - ticker_len - 1,
                   decimals);
    out_buffer[out_buffer_size - 1] = '\0';
c0d00526:	1970      	adds	r0, r6, r5
c0d00528:	1e40      	subs	r0, r0, #1
c0d0052a:	2100      	movs	r1, #0
c0d0052c:	7001      	strb	r1, [r0, #0]
}
c0d0052e:	b01f      	add	sp, #124	; 0x7c
c0d00530:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00532:	4801      	ldr	r0, [pc, #4]	; (c0d00538 <amountToString+0xd0>)
        THROW(0x6504);
c0d00534:	f000 ffaa 	bl	c0d0148c <os_longjmp>
c0d00538:	00006504 	.word	0x00006504
c0d0053c:	0000497e 	.word	0x0000497e
c0d00540:	0000497c 	.word	0x0000497c
c0d00544:	0000498c 	.word	0x0000498c
c0d00548:	0000498e 	.word	0x0000498e
c0d0054c:	0000499d 	.word	0x0000499d

c0d00550 <handle_finalize>:
        context->screen_array |= WARNING_ADDRESS_UI;
        msg->numScreens++;
    }
}

void handle_finalize(void *parameters) {
c0d00550:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00552:	b081      	sub	sp, #4
c0d00554:	4604      	mov	r4, r0
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d00556:	6885      	ldr	r5, [r0, #8]
c0d00558:	2094      	movs	r0, #148	; 0x94

    // set generic screen_array
    context->screen_array |= TX_TYPE_UI;
c0d0055a:	5c29      	ldrb	r1, [r5, r0]
c0d0055c:	2255      	movs	r2, #85	; 0x55
    context->screen_array |= AMOUNT_TOKEN_A_UI;
    context->screen_array |= AMOUNT_TOKEN_B_UI;
    context->screen_array |= ADDRESS_UI;
c0d0055e:	430a      	orrs	r2, r1
c0d00560:	542a      	strb	r2, [r5, r0]
c0d00562:	462f      	mov	r7, r5
c0d00564:	3794      	adds	r7, #148	; 0x94

    if (context->valid) {
c0d00566:	7a38      	ldrb	r0, [r7, #8]
c0d00568:	2800      	cmp	r0, #0
c0d0056a:	d01c      	beq.n	c0d005a6 <handle_finalize+0x56>
c0d0056c:	2002      	movs	r0, #2
        msg->uiType = ETH_UI_TYPE_GENERIC;
c0d0056e:	7720      	strb	r0, [r4, #28]
c0d00570:	2001      	movs	r0, #1
        context->plugin_screen_index = TX_TYPE_UI;
c0d00572:	70b8      	strb	r0, [r7, #2]
c0d00574:	2604      	movs	r6, #4
        msg->numScreens = 4;
c0d00576:	7766      	strb	r6, [r4, #29]
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH)) {
c0d00578:	69a0      	ldr	r0, [r4, #24]
c0d0057a:	4629      	mov	r1, r5
c0d0057c:	3180      	adds	r1, #128	; 0x80
c0d0057e:	2214      	movs	r2, #20
c0d00580:	f004 fb3c 	bl	c0d04bfc <memcmp>
c0d00584:	2800      	cmp	r0, #0
c0d00586:	d00a      	beq.n	c0d0059e <handle_finalize+0x4e>
        PRINTF("GPIRIOU WARNING SET\n");
c0d00588:	480b      	ldr	r0, [pc, #44]	; (c0d005b8 <handle_finalize+0x68>)
c0d0058a:	4478      	add	r0, pc
c0d0058c:	f7ff fd96 	bl	c0d000bc <semihosted_printf>
        context->screen_array |= WARNING_ADDRESS_UI;
c0d00590:	7838      	ldrb	r0, [r7, #0]
c0d00592:	2120      	movs	r1, #32
c0d00594:	4301      	orrs	r1, r0
c0d00596:	7039      	strb	r1, [r7, #0]
        msg->numScreens++;
c0d00598:	7f60      	ldrb	r0, [r4, #29]
c0d0059a:	1c40      	adds	r0, r0, #1
c0d0059c:	7760      	strb	r0, [r4, #29]

        check_beneficiary_warning(msg, context);

        msg->tokenLookup1 = context->token_a_address;  // TODO: CHECK THIS
c0d0059e:	60e5      	str	r5, [r4, #12]
        msg->tokenLookup2 = context->token_b_address;  // TODO: CHECK THIS
c0d005a0:	3514      	adds	r5, #20
c0d005a2:	6125      	str	r5, [r4, #16]
c0d005a4:	e004      	b.n	c0d005b0 <handle_finalize+0x60>
        msg->result = ETH_PLUGIN_RESULT_OK;
    } else {
        PRINTF("Invalid context\n");
c0d005a6:	4805      	ldr	r0, [pc, #20]	; (c0d005bc <handle_finalize+0x6c>)
c0d005a8:	4478      	add	r0, pc
c0d005aa:	f7ff fd87 	bl	c0d000bc <semihosted_printf>
c0d005ae:	2606      	movs	r6, #6
c0d005b0:	77a6      	strb	r6, [r4, #30]
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
c0d005b2:	b001      	add	sp, #4
c0d005b4:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d005b6:	46c0      	nop			; (mov r8, r8)
c0d005b8:	00004960 	.word	0x00004960
c0d005bc:	00004931 	.word	0x00004931

c0d005c0 <handle_init_contract>:
#include "opensea_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters) {
c0d005c0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d005c2:	b081      	sub	sp, #4
c0d005c4:	4604      	mov	r4, r0
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *) parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_1) {
c0d005c6:	7800      	ldrb	r0, [r0, #0]
c0d005c8:	2801      	cmp	r0, #1
c0d005ca:	d108      	bne.n	c0d005de <handle_init_contract+0x1e>
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    // TODO: this could be removed as this can be checked statically?
    if (msg->pluginContextLength < sizeof(opensea_parameters_t)) {
c0d005cc:	6920      	ldr	r0, [r4, #16]
c0d005ce:	289f      	cmp	r0, #159	; 0x9f
c0d005d0:	d807      	bhi.n	c0d005e2 <handle_init_contract+0x22>
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0d005d2:	4830      	ldr	r0, [pc, #192]	; (c0d00694 <handle_init_contract+0xd4>)
c0d005d4:	4478      	add	r0, pc
c0d005d6:	f7ff fd71 	bl	c0d000bc <semihosted_printf>
c0d005da:	2000      	movs	r0, #0
c0d005dc:	e051      	b.n	c0d00682 <handle_init_contract+0xc2>
c0d005de:	2001      	movs	r0, #1
c0d005e0:	e04f      	b.n	c0d00682 <handle_init_contract+0xc2>
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d005e2:	68e5      	ldr	r5, [r4, #12]
c0d005e4:	21a0      	movs	r1, #160	; 0xa0

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
c0d005e6:	4628      	mov	r0, r5
c0d005e8:	f004 faf4 	bl	c0d04bd4 <__aeabi_memclr>
c0d005ec:	209c      	movs	r0, #156	; 0x9c
c0d005ee:	2101      	movs	r1, #1
c0d005f0:	9100      	str	r1, [sp, #0]
    // Mark context as valid.
    context->valid = 1;
c0d005f2:	5429      	strb	r1, [r5, r0]
c0d005f4:	359b      	adds	r5, #155	; 0x9b
c0d005f6:	2600      	movs	r6, #0
c0d005f8:	4f27      	ldr	r7, [pc, #156]	; (c0d00698 <handle_init_contract+0xd8>)
c0d005fa:	447f      	add	r7, pc

    // Look for the index of the selectorIndex passed in by `msg`.
    uint8_t i;
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++) {
        if (memcmp((uint8_t *) PIC(OPENSA_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0) {
c0d005fc:	6838      	ldr	r0, [r7, #0]
c0d005fe:	f001 f94d 	bl	c0d0189c <pic>
c0d00602:	7801      	ldrb	r1, [r0, #0]
c0d00604:	7842      	ldrb	r2, [r0, #1]
c0d00606:	0212      	lsls	r2, r2, #8
c0d00608:	1851      	adds	r1, r2, r1
c0d0060a:	7882      	ldrb	r2, [r0, #2]
c0d0060c:	78c0      	ldrb	r0, [r0, #3]
c0d0060e:	0200      	lsls	r0, r0, #8
c0d00610:	1880      	adds	r0, r0, r2
c0d00612:	0400      	lsls	r0, r0, #16
c0d00614:	1840      	adds	r0, r0, r1
c0d00616:	6961      	ldr	r1, [r4, #20]
c0d00618:	780a      	ldrb	r2, [r1, #0]
c0d0061a:	784b      	ldrb	r3, [r1, #1]
c0d0061c:	021b      	lsls	r3, r3, #8
c0d0061e:	189a      	adds	r2, r3, r2
c0d00620:	788b      	ldrb	r3, [r1, #2]
c0d00622:	78c9      	ldrb	r1, [r1, #3]
c0d00624:	0209      	lsls	r1, r1, #8
c0d00626:	18c9      	adds	r1, r1, r3
c0d00628:	0409      	lsls	r1, r1, #16
c0d0062a:	1889      	adds	r1, r1, r2
c0d0062c:	4288      	cmp	r0, r1
c0d0062e:	d008      	beq.n	c0d00642 <handle_init_contract+0x82>
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++) {
c0d00630:	1d3f      	adds	r7, r7, #4
c0d00632:	1c76      	adds	r6, r6, #1
c0d00634:	2e11      	cmp	r6, #17
c0d00636:	d1e1      	bne.n	c0d005fc <handle_init_contract+0x3c>
c0d00638:	2000      	movs	r0, #0
        }
    }

    // If `i == NUM_UNISWAP_SELECTOR` it means we haven't found the selector. Return an error.
    if (i == NUM_OPENSEA_SELECTORS) {
        context->valid = 0;
c0d0063a:	7068      	strb	r0, [r5, #1]
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
c0d0063c:	1c60      	adds	r0, r4, #1
c0d0063e:	9e00      	ldr	r6, [sp, #0]
c0d00640:	e000      	b.n	c0d00644 <handle_init_contract+0x84>
            context->selectorIndex = i;
c0d00642:	1d28      	adds	r0, r5, #4
c0d00644:	7006      	strb	r6, [r0, #0]
    }

    // Set `next_param` to be the first field we expect to parse.
    PRINTF("INIT_CONTRACT selector: %u\n", context->selectorIndex);
c0d00646:	7929      	ldrb	r1, [r5, #4]
c0d00648:	4814      	ldr	r0, [pc, #80]	; (c0d0069c <handle_init_contract+0xdc>)
c0d0064a:	4478      	add	r0, pc
c0d0064c:	f7ff fd36 	bl	c0d000bc <semihosted_printf>
    switch (context->selectorIndex) {
c0d00650:	7928      	ldrb	r0, [r5, #4]
c0d00652:	2810      	cmp	r0, #16
c0d00654:	d80e      	bhi.n	c0d00674 <handle_init_contract+0xb4>
c0d00656:	2101      	movs	r1, #1
c0d00658:	4081      	lsls	r1, r0
c0d0065a:	060a      	lsls	r2, r1, #24
c0d0065c:	0e92      	lsrs	r2, r2, #26
c0d0065e:	d10d      	bne.n	c0d0067c <handle_init_contract+0xbc>
c0d00660:	4a0b      	ldr	r2, [pc, #44]	; (c0d00690 <handle_init_contract+0xd0>)
c0d00662:	4211      	tst	r1, r2
c0d00664:	d001      	beq.n	c0d0066a <handle_init_contract+0xaa>
c0d00666:	2008      	movs	r0, #8
c0d00668:	e009      	b.n	c0d0067e <handle_init_contract+0xbe>
c0d0066a:	0449      	lsls	r1, r1, #17
c0d0066c:	0f09      	lsrs	r1, r1, #28
c0d0066e:	d001      	beq.n	c0d00674 <handle_init_contract+0xb4>
c0d00670:	2009      	movs	r0, #9
c0d00672:	e004      	b.n	c0d0067e <handle_init_contract+0xbe>
c0d00674:	2801      	cmp	r0, #1
c0d00676:	d002      	beq.n	c0d0067e <handle_init_contract+0xbe>
c0d00678:	2800      	cmp	r0, #0
c0d0067a:	d105      	bne.n	c0d00688 <handle_init_contract+0xc8>
c0d0067c:	2000      	movs	r0, #0
c0d0067e:	7028      	strb	r0, [r5, #0]
c0d00680:	2004      	movs	r0, #4
c0d00682:	7060      	strb	r0, [r4, #1]
            return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d00684:	b001      	add	sp, #4
c0d00686:	bdf0      	pop	{r4, r5, r6, r7, pc}
            PRINTF("Missing selectorIndex\n");
c0d00688:	4805      	ldr	r0, [pc, #20]	; (c0d006a0 <handle_init_contract+0xe0>)
c0d0068a:	4478      	add	r0, pc
c0d0068c:	e7a3      	b.n	c0d005d6 <handle_init_contract+0x16>
c0d0068e:	46c0      	nop			; (mov r8, r8)
c0d00690:	00018700 	.word	0x00018700
c0d00694:	0000492b 	.word	0x0000492b
c0d00698:	00004f86 	.word	0x00004f86
c0d0069c:	000048ee 	.word	0x000048ee
c0d006a0:	000048ca 	.word	0x000048ca

c0d006a4 <handle_provide_parameter>:
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

void handle_provide_parameter(void *parameters) {
c0d006a4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d006a6:	b081      	sub	sp, #4
c0d006a8:	4605      	mov	r5, r0
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d006aa:	6884      	ldr	r4, [r0, #8]
c0d006ac:	279f      	movs	r7, #159	; 0x9f
    PRINTF("PROVIDE PARAMETER, selector: %d\n", context->selectorIndex);
c0d006ae:	5de1      	ldrb	r1, [r4, r7]
c0d006b0:	48fb      	ldr	r0, [pc, #1004]	; (c0d00aa0 <handle_provide_parameter+0x3fc>)
c0d006b2:	4478      	add	r0, pc
c0d006b4:	f7ff fd02 	bl	c0d000bc <semihosted_printf>
c0d006b8:	2604      	movs	r6, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d006ba:	752e      	strb	r6, [r5, #20]

    switch (context->selectorIndex) {
c0d006bc:	5de1      	ldrb	r1, [r4, r7]
c0d006be:	4627      	mov	r7, r4
c0d006c0:	3798      	adds	r7, #152	; 0x98
c0d006c2:	2907      	cmp	r1, #7
c0d006c4:	dd4e      	ble.n	c0d00764 <handle_provide_parameter+0xc0>
c0d006c6:	2910      	cmp	r1, #16
c0d006c8:	d900      	bls.n	c0d006cc <handle_provide_parameter+0x28>
c0d006ca:	e1a8      	b.n	c0d00a1e <handle_provide_parameter+0x37a>
c0d006cc:	2601      	movs	r6, #1
c0d006ce:	4630      	mov	r0, r6
c0d006d0:	4088      	lsls	r0, r1
c0d006d2:	0442      	lsls	r2, r0, #17
c0d006d4:	0f12      	lsrs	r2, r2, #28
c0d006d6:	d173      	bne.n	c0d007c0 <handle_provide_parameter+0x11c>
c0d006d8:	0542      	lsls	r2, r0, #21
c0d006da:	0f52      	lsrs	r2, r2, #29
c0d006dc:	d100      	bne.n	c0d006e0 <handle_provide_parameter+0x3c>
c0d006de:	e0b4      	b.n	c0d0084a <handle_provide_parameter+0x1a6>
    PRINTF("GPIRIOU msg->offset: %d\n", msg->parameterOffset);
c0d006e0:	6929      	ldr	r1, [r5, #16]
c0d006e2:	48fc      	ldr	r0, [pc, #1008]	; (c0d00ad4 <handle_provide_parameter+0x430>)
c0d006e4:	4478      	add	r0, pc
c0d006e6:	f7ff fce9 	bl	c0d000bc <semihosted_printf>
           context->next_param == TOKEN_B_ADDRESS,
c0d006ea:	78f8      	ldrb	r0, [r7, #3]
c0d006ec:	1e40      	subs	r0, r0, #1
c0d006ee:	4241      	negs	r1, r0
c0d006f0:	4141      	adcs	r1, r0
           context->skip);
c0d006f2:	78ba      	ldrb	r2, [r7, #2]
    PRINTF("GPIRIOU next_param: %d, skip: %d\n",
c0d006f4:	48f8      	ldr	r0, [pc, #992]	; (c0d00ad8 <handle_provide_parameter+0x434>)
c0d006f6:	4478      	add	r0, pc
c0d006f8:	f7ff fce0 	bl	c0d000bc <semihosted_printf>
    if (context->next_param == TOKEN_B_ADDRESS && context->skip) {
c0d006fc:	78f8      	ldrb	r0, [r7, #3]
c0d006fe:	2801      	cmp	r0, #1
c0d00700:	d103      	bne.n	c0d0070a <handle_provide_parameter+0x66>
c0d00702:	78b9      	ldrb	r1, [r7, #2]
c0d00704:	2900      	cmp	r1, #0
c0d00706:	d000      	beq.n	c0d0070a <handle_provide_parameter+0x66>
c0d00708:	e0b7      	b.n	c0d0087a <handle_provide_parameter+0x1d6>
    if ((context->path_offset) && msg->parameterOffset == context->path_offset) {
c0d0070a:	8839      	ldrh	r1, [r7, #0]
c0d0070c:	2900      	cmp	r1, #0
c0d0070e:	d003      	beq.n	c0d00718 <handle_provide_parameter+0x74>
c0d00710:	692a      	ldr	r2, [r5, #16]
c0d00712:	428a      	cmp	r2, r1
c0d00714:	d100      	bne.n	c0d00718 <handle_provide_parameter+0x74>
c0d00716:	e0fe      	b.n	c0d00916 <handle_provide_parameter+0x272>
    switch (context->next_param) {
c0d00718:	280a      	cmp	r0, #10
c0d0071a:	dd00      	ble.n	c0d0071e <handle_provide_parameter+0x7a>
c0d0071c:	e161      	b.n	c0d009e2 <handle_provide_parameter+0x33e>
c0d0071e:	2800      	cmp	r0, #0
c0d00720:	d100      	bne.n	c0d00724 <handle_provide_parameter+0x80>
c0d00722:	e1bf      	b.n	c0d00aa4 <handle_provide_parameter+0x400>
c0d00724:	2801      	cmp	r0, #1
c0d00726:	d100      	bne.n	c0d0072a <handle_provide_parameter+0x86>
c0d00728:	e13f      	b.n	c0d009aa <handle_provide_parameter+0x306>
c0d0072a:	2808      	cmp	r0, #8
c0d0072c:	d000      	beq.n	c0d00730 <handle_provide_parameter+0x8c>
c0d0072e:	e171      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("CURRENT PARAM: AMOUNT_IN INIT\n");
c0d00730:	48ea      	ldr	r0, [pc, #936]	; (c0d00adc <handle_provide_parameter+0x438>)
c0d00732:	4478      	add	r0, pc
c0d00734:	f7ff fcc2 	bl	c0d000bc <semihosted_printf>
    memset(context->token_b_amount_sent, 0, sizeof(context->token_b_amount_sent));
c0d00738:	3448      	adds	r4, #72	; 0x48
c0d0073a:	2620      	movs	r6, #32
c0d0073c:	4620      	mov	r0, r4
c0d0073e:	4631      	mov	r1, r6
c0d00740:	f004 fa48 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_b_amount_sent, msg->parameter, sizeof(context->token_b_amount_sent));
c0d00744:	68e9      	ldr	r1, [r5, #12]
c0d00746:	4620      	mov	r0, r4
c0d00748:	4632      	mov	r2, r6
c0d0074a:	f004 fa48 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN B AMOUNT:\n");
c0d0074e:	48e4      	ldr	r0, [pc, #912]	; (c0d00ae0 <handle_provide_parameter+0x43c>)
c0d00750:	4478      	add	r0, pc
c0d00752:	f7ff fcb3 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_b_amount_sent, sizeof(context->token_b_amount_sent));
c0d00756:	4620      	mov	r0, r4
c0d00758:	4631      	mov	r1, r6
c0d0075a:	f7ff fcd3 	bl	c0d00104 <print_bytes>
            PRINTF("AMOUNT OUT: %s\n", context->token_b_amount_sent);
c0d0075e:	48e1      	ldr	r0, [pc, #900]	; (c0d00ae4 <handle_provide_parameter+0x440>)
c0d00760:	4478      	add	r0, pc
c0d00762:	e2c6      	b.n	c0d00cf2 <handle_provide_parameter+0x64e>
    switch (context->selectorIndex) {
c0d00764:	2903      	cmp	r1, #3
c0d00766:	dc1b      	bgt.n	c0d007a0 <handle_provide_parameter+0xfc>
c0d00768:	1e88      	subs	r0, r1, #2
c0d0076a:	2802      	cmp	r0, #2
c0d0076c:	d200      	bcs.n	c0d00770 <handle_provide_parameter+0xcc>
c0d0076e:	e08b      	b.n	c0d00888 <handle_provide_parameter+0x1e4>
c0d00770:	2900      	cmp	r1, #0
c0d00772:	d100      	bne.n	c0d00776 <handle_provide_parameter+0xd2>
c0d00774:	e0dd      	b.n	c0d00932 <handle_provide_parameter+0x28e>
c0d00776:	2901      	cmp	r1, #1
c0d00778:	d000      	beq.n	c0d0077c <handle_provide_parameter+0xd8>
c0d0077a:	e150      	b.n	c0d00a1e <handle_provide_parameter+0x37a>
    PRINTF("GPIRIOU handle_add_liquidity eth\n");
c0d0077c:	48da      	ldr	r0, [pc, #872]	; (c0d00ae8 <handle_provide_parameter+0x444>)
c0d0077e:	4478      	add	r0, pc
c0d00780:	f7ff fc9c 	bl	c0d000bc <semihosted_printf>
    switch (context->next_param) {
c0d00784:	78f8      	ldrb	r0, [r7, #3]
c0d00786:	2806      	cmp	r0, #6
c0d00788:	dc00      	bgt.n	c0d0078c <handle_provide_parameter+0xe8>
c0d0078a:	e215      	b.n	c0d00bb8 <handle_provide_parameter+0x514>
c0d0078c:	280c      	cmp	r0, #12
c0d0078e:	dd00      	ble.n	c0d00792 <handle_provide_parameter+0xee>
c0d00790:	e0dd      	b.n	c0d0094e <handle_provide_parameter+0x2aa>
c0d00792:	2807      	cmp	r0, #7
c0d00794:	d100      	bne.n	c0d00798 <handle_provide_parameter+0xf4>
c0d00796:	e2b1      	b.n	c0d00cfc <handle_provide_parameter+0x658>
c0d00798:	280c      	cmp	r0, #12
c0d0079a:	d100      	bne.n	c0d0079e <handle_provide_parameter+0xfa>
c0d0079c:	e278      	b.n	c0d00c90 <handle_provide_parameter+0x5ec>
c0d0079e:	e139      	b.n	c0d00a14 <handle_provide_parameter+0x370>
    switch (context->next_param) {
c0d007a0:	78f8      	ldrb	r0, [r7, #3]
c0d007a2:	2806      	cmp	r0, #6
c0d007a4:	dc00      	bgt.n	c0d007a8 <handle_provide_parameter+0x104>
c0d007a6:	e08e      	b.n	c0d008c6 <handle_provide_parameter+0x222>
c0d007a8:	280c      	cmp	r0, #12
c0d007aa:	dd00      	ble.n	c0d007ae <handle_provide_parameter+0x10a>
c0d007ac:	e0ef      	b.n	c0d0098e <handle_provide_parameter+0x2ea>
c0d007ae:	2807      	cmp	r0, #7
c0d007b0:	d100      	bne.n	c0d007b4 <handle_provide_parameter+0x110>
c0d007b2:	e0d4      	b.n	c0d0095e <handle_provide_parameter+0x2ba>
c0d007b4:	280c      	cmp	r0, #12
c0d007b6:	d000      	beq.n	c0d007ba <handle_provide_parameter+0x116>
c0d007b8:	e12c      	b.n	c0d00a14 <handle_provide_parameter+0x370>
c0d007ba:	48cc      	ldr	r0, [pc, #816]	; (c0d00aec <handle_provide_parameter+0x448>)
c0d007bc:	4478      	add	r0, pc
c0d007be:	e269      	b.n	c0d00c94 <handle_provide_parameter+0x5f0>
    PRINTF("GPIRIOU msg->offset: %d\n", msg->parameterOffset);
c0d007c0:	6929      	ldr	r1, [r5, #16]
c0d007c2:	48cb      	ldr	r0, [pc, #812]	; (c0d00af0 <handle_provide_parameter+0x44c>)
c0d007c4:	4478      	add	r0, pc
c0d007c6:	f7ff fc79 	bl	c0d000bc <semihosted_printf>
           context->next_param == TOKEN_B_ADDRESS,
c0d007ca:	78f8      	ldrb	r0, [r7, #3]
c0d007cc:	1e40      	subs	r0, r0, #1
c0d007ce:	4241      	negs	r1, r0
c0d007d0:	4141      	adcs	r1, r0
           context->skip);
c0d007d2:	78ba      	ldrb	r2, [r7, #2]
    PRINTF("GPIRIOU next_param: %d, skip: %d\n",
c0d007d4:	48c7      	ldr	r0, [pc, #796]	; (c0d00af4 <handle_provide_parameter+0x450>)
c0d007d6:	4478      	add	r0, pc
c0d007d8:	f7ff fc70 	bl	c0d000bc <semihosted_printf>
    if (context->next_param == TOKEN_B_ADDRESS && context->skip) {
c0d007dc:	78f8      	ldrb	r0, [r7, #3]
c0d007de:	2801      	cmp	r0, #1
c0d007e0:	d102      	bne.n	c0d007e8 <handle_provide_parameter+0x144>
c0d007e2:	78b9      	ldrb	r1, [r7, #2]
c0d007e4:	2900      	cmp	r1, #0
c0d007e6:	d148      	bne.n	c0d0087a <handle_provide_parameter+0x1d6>
    if ((context->path_offset) && msg->parameterOffset == context->path_offset) {
c0d007e8:	8839      	ldrh	r1, [r7, #0]
c0d007ea:	2900      	cmp	r1, #0
c0d007ec:	d003      	beq.n	c0d007f6 <handle_provide_parameter+0x152>
c0d007ee:	692a      	ldr	r2, [r5, #16]
c0d007f0:	428a      	cmp	r2, r1
c0d007f2:	d100      	bne.n	c0d007f6 <handle_provide_parameter+0x152>
c0d007f4:	e08f      	b.n	c0d00916 <handle_provide_parameter+0x272>
    switch (context->next_param) {
c0d007f6:	280a      	cmp	r0, #10
c0d007f8:	dd00      	ble.n	c0d007fc <handle_provide_parameter+0x158>
c0d007fa:	e0f2      	b.n	c0d009e2 <handle_provide_parameter+0x33e>
c0d007fc:	2807      	cmp	r0, #7
c0d007fe:	dc00      	bgt.n	c0d00802 <handle_provide_parameter+0x15e>
c0d00800:	e0cf      	b.n	c0d009a2 <handle_provide_parameter+0x2fe>
c0d00802:	2808      	cmp	r0, #8
c0d00804:	d100      	bne.n	c0d00808 <handle_provide_parameter+0x164>
c0d00806:	e25b      	b.n	c0d00cc0 <handle_provide_parameter+0x61c>
c0d00808:	2809      	cmp	r0, #9
c0d0080a:	d000      	beq.n	c0d0080e <handle_provide_parameter+0x16a>
c0d0080c:	e102      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("CURRENT PARAM: AMOUNT_IN INIT\n");
c0d0080e:	48ba      	ldr	r0, [pc, #744]	; (c0d00af8 <handle_provide_parameter+0x454>)
c0d00810:	4478      	add	r0, pc
c0d00812:	f7ff fc53 	bl	c0d000bc <semihosted_printf>
    memset(context->token_a_amount_sent, 0, sizeof(context->token_a_amount_sent));
c0d00816:	3428      	adds	r4, #40	; 0x28
c0d00818:	2620      	movs	r6, #32
c0d0081a:	4620      	mov	r0, r4
c0d0081c:	4631      	mov	r1, r6
c0d0081e:	f004 f9d9 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_a_amount_sent, msg->parameter, sizeof(context->token_a_amount_sent));
c0d00822:	68e9      	ldr	r1, [r5, #12]
c0d00824:	4620      	mov	r0, r4
c0d00826:	4632      	mov	r2, r6
c0d00828:	f004 f9d9 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN A AMOUNT:\n");
c0d0082c:	48b3      	ldr	r0, [pc, #716]	; (c0d00afc <handle_provide_parameter+0x458>)
c0d0082e:	4478      	add	r0, pc
c0d00830:	f7ff fc44 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d00834:	4620      	mov	r0, r4
c0d00836:	4631      	mov	r1, r6
c0d00838:	f7ff fc64 	bl	c0d00104 <print_bytes>
            PRINTF("AMOUNT OUT: %s\n", context->token_a_amount_sent);
c0d0083c:	48b0      	ldr	r0, [pc, #704]	; (c0d00b00 <handle_provide_parameter+0x45c>)
c0d0083e:	4478      	add	r0, pc
c0d00840:	4621      	mov	r1, r4
c0d00842:	f7ff fc3b 	bl	c0d000bc <semihosted_printf>
c0d00846:	2008      	movs	r0, #8
c0d00848:	e2c5      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
c0d0084a:	03c0      	lsls	r0, r0, #15
c0d0084c:	0f80      	lsrs	r0, r0, #30
c0d0084e:	d100      	bne.n	c0d00852 <handle_provide_parameter+0x1ae>
c0d00850:	e0e5      	b.n	c0d00a1e <handle_provide_parameter+0x37a>
    PRINTF("GPIRIOU msg->offset: %d\n", msg->parameterOffset);
c0d00852:	6929      	ldr	r1, [r5, #16]
c0d00854:	48ab      	ldr	r0, [pc, #684]	; (c0d00b04 <handle_provide_parameter+0x460>)
c0d00856:	4478      	add	r0, pc
c0d00858:	f7ff fc30 	bl	c0d000bc <semihosted_printf>
           context->next_param == TOKEN_B_ADDRESS,
c0d0085c:	78f8      	ldrb	r0, [r7, #3]
c0d0085e:	1e40      	subs	r0, r0, #1
c0d00860:	4241      	negs	r1, r0
c0d00862:	4141      	adcs	r1, r0
           context->skip);
c0d00864:	78ba      	ldrb	r2, [r7, #2]
    PRINTF("GPIRIOU next_param: %d, skip: %d\n",
c0d00866:	48a8      	ldr	r0, [pc, #672]	; (c0d00b08 <handle_provide_parameter+0x464>)
c0d00868:	4478      	add	r0, pc
c0d0086a:	f7ff fc27 	bl	c0d000bc <semihosted_printf>
    if (context->next_param == TOKEN_B_ADDRESS && context->skip) {
c0d0086e:	78f8      	ldrb	r0, [r7, #3]
c0d00870:	2801      	cmp	r0, #1
c0d00872:	d14a      	bne.n	c0d0090a <handle_provide_parameter+0x266>
c0d00874:	78b9      	ldrb	r1, [r7, #2]
c0d00876:	2900      	cmp	r1, #0
c0d00878:	d047      	beq.n	c0d0090a <handle_provide_parameter+0x266>
c0d0087a:	48a4      	ldr	r0, [pc, #656]	; (c0d00b0c <handle_provide_parameter+0x468>)
c0d0087c:	4478      	add	r0, pc
c0d0087e:	f7ff fc1d 	bl	c0d000bc <semihosted_printf>
c0d00882:	78b8      	ldrb	r0, [r7, #2]
c0d00884:	1e40      	subs	r0, r0, #1
c0d00886:	e052      	b.n	c0d0092e <handle_provide_parameter+0x28a>
    switch (context->next_param) {
c0d00888:	78f8      	ldrb	r0, [r7, #3]
c0d0088a:	2805      	cmp	r0, #5
c0d0088c:	dc62      	bgt.n	c0d00954 <handle_provide_parameter+0x2b0>
c0d0088e:	2801      	cmp	r0, #1
c0d00890:	dd00      	ble.n	c0d00894 <handle_provide_parameter+0x1f0>
c0d00892:	e0e2      	b.n	c0d00a5a <handle_provide_parameter+0x3b6>
c0d00894:	2800      	cmp	r0, #0
c0d00896:	d100      	bne.n	c0d0089a <handle_provide_parameter+0x1f6>
c0d00898:	e1da      	b.n	c0d00c50 <handle_provide_parameter+0x5ac>
c0d0089a:	2801      	cmp	r0, #1
c0d0089c:	d000      	beq.n	c0d008a0 <handle_provide_parameter+0x1fc>
c0d0089e:	e0b9      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("GPIRIOU TOKEN_A_ADDRESS\n");
c0d008a0:	489b      	ldr	r0, [pc, #620]	; (c0d00b10 <handle_provide_parameter+0x46c>)
c0d008a2:	4478      	add	r0, pc
c0d008a4:	f7ff fc0a 	bl	c0d000bc <semihosted_printf>
    memset(context->token_b_address, 0, sizeof(context->token_b_address));
c0d008a8:	3414      	adds	r4, #20
c0d008aa:	2614      	movs	r6, #20
c0d008ac:	4620      	mov	r0, r4
c0d008ae:	4631      	mov	r1, r6
c0d008b0:	f004 f990 	bl	c0d04bd4 <__aeabi_memclr>
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
c0d008b4:	68e9      	ldr	r1, [r5, #12]
c0d008b6:	310c      	adds	r1, #12
    memcpy(context->token_b_address,
c0d008b8:	4620      	mov	r0, r4
c0d008ba:	4632      	mov	r2, r6
c0d008bc:	f004 f98f 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TOKEN_B_ADDRESS CONTRACT: %.*H\n", ADDRESS_LENGTH, context->token_b_address);
c0d008c0:	4894      	ldr	r0, [pc, #592]	; (c0d00b14 <handle_provide_parameter+0x470>)
c0d008c2:	4478      	add	r0, pc
c0d008c4:	e0c3      	b.n	c0d00a4e <handle_provide_parameter+0x3aa>
    switch (context->next_param) {
c0d008c6:	2800      	cmp	r0, #0
c0d008c8:	d100      	bne.n	c0d008cc <handle_provide_parameter+0x228>
c0d008ca:	e0af      	b.n	c0d00a2c <handle_provide_parameter+0x388>
c0d008cc:	2802      	cmp	r0, #2
c0d008ce:	d100      	bne.n	c0d008d2 <handle_provide_parameter+0x22e>
c0d008d0:	e0df      	b.n	c0d00a92 <handle_provide_parameter+0x3ee>
c0d008d2:	2805      	cmp	r0, #5
c0d008d4:	d000      	beq.n	c0d008d8 <handle_provide_parameter+0x234>
c0d008d6:	e09d      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("GPIRIOU TOKEN_A_MIN\n");
c0d008d8:	488f      	ldr	r0, [pc, #572]	; (c0d00b18 <handle_provide_parameter+0x474>)
c0d008da:	4478      	add	r0, pc
c0d008dc:	f7ff fbee 	bl	c0d000bc <semihosted_printf>
    memset(context->token_a_amount_sent, 0, sizeof(context->token_a_amount_sent));
c0d008e0:	3428      	adds	r4, #40	; 0x28
c0d008e2:	2620      	movs	r6, #32
c0d008e4:	4620      	mov	r0, r4
c0d008e6:	4631      	mov	r1, r6
c0d008e8:	f004 f974 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_a_amount_sent, msg->parameter, sizeof(context->token_a_amount_sent));
c0d008ec:	68e9      	ldr	r1, [r5, #12]
c0d008ee:	4620      	mov	r0, r4
c0d008f0:	4632      	mov	r2, r6
c0d008f2:	f004 f974 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN A AMOUNT:\n");
c0d008f6:	4889      	ldr	r0, [pc, #548]	; (c0d00b1c <handle_provide_parameter+0x478>)
c0d008f8:	4478      	add	r0, pc
c0d008fa:	f7ff fbdf 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d008fe:	4620      	mov	r0, r4
c0d00900:	4631      	mov	r1, r6
c0d00902:	f7ff fbff 	bl	c0d00104 <print_bytes>
c0d00906:	2007      	movs	r0, #7
c0d00908:	e265      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    if ((context->path_offset) && msg->parameterOffset == context->path_offset) {
c0d0090a:	8839      	ldrh	r1, [r7, #0]
c0d0090c:	2900      	cmp	r1, #0
c0d0090e:	d043      	beq.n	c0d00998 <handle_provide_parameter+0x2f4>
c0d00910:	692a      	ldr	r2, [r5, #16]
c0d00912:	428a      	cmp	r2, r1
c0d00914:	d140      	bne.n	c0d00998 <handle_provide_parameter+0x2f4>
c0d00916:	68e8      	ldr	r0, [r5, #12]
c0d00918:	7fc0      	ldrb	r0, [r0, #31]
c0d0091a:	1e41      	subs	r1, r0, #1
c0d0091c:	4880      	ldr	r0, [pc, #512]	; (c0d00b20 <handle_provide_parameter+0x47c>)
c0d0091e:	4478      	add	r0, pc
c0d00920:	f7ff fbcc 	bl	c0d000bc <semihosted_printf>
c0d00924:	68e8      	ldr	r0, [r5, #12]
c0d00926:	7fc0      	ldrb	r0, [r0, #31]
c0d00928:	2100      	movs	r1, #0
c0d0092a:	70f9      	strb	r1, [r7, #3]
c0d0092c:	1e80      	subs	r0, r0, #2
c0d0092e:	70b8      	strb	r0, [r7, #2]
c0d00930:	e252      	b.n	c0d00dd8 <handle_provide_parameter+0x734>
    PRINTF("GPIRIOU handle_add_liquidity\n");
c0d00932:	487c      	ldr	r0, [pc, #496]	; (c0d00b24 <handle_provide_parameter+0x480>)
c0d00934:	4478      	add	r0, pc
c0d00936:	f7ff fbc1 	bl	c0d000bc <semihosted_printf>
    switch (context->next_param) {
c0d0093a:	78f8      	ldrb	r0, [r7, #3]
c0d0093c:	2804      	cmp	r0, #4
c0d0093e:	dc00      	bgt.n	c0d00942 <handle_provide_parameter+0x29e>
c0d00940:	e11f      	b.n	c0d00b82 <handle_provide_parameter+0x4de>
c0d00942:	280b      	cmp	r0, #11
c0d00944:	dc00      	bgt.n	c0d00948 <handle_provide_parameter+0x2a4>
c0d00946:	e19a      	b.n	c0d00c7e <handle_provide_parameter+0x5da>
c0d00948:	280c      	cmp	r0, #12
c0d0094a:	d100      	bne.n	c0d0094e <handle_provide_parameter+0x2aa>
c0d0094c:	e1a0      	b.n	c0d00c90 <handle_provide_parameter+0x5ec>
c0d0094e:	280d      	cmp	r0, #13
c0d00950:	d15d      	bne.n	c0d00a0e <handle_provide_parameter+0x36a>
c0d00952:	e114      	b.n	c0d00b7e <handle_provide_parameter+0x4da>
    switch (context->next_param) {
c0d00954:	280c      	cmp	r0, #12
c0d00956:	dc1a      	bgt.n	c0d0098e <handle_provide_parameter+0x2ea>
c0d00958:	2806      	cmp	r0, #6
c0d0095a:	d000      	beq.n	c0d0095e <handle_provide_parameter+0x2ba>
c0d0095c:	e72a      	b.n	c0d007b4 <handle_provide_parameter+0x110>
c0d0095e:	4872      	ldr	r0, [pc, #456]	; (c0d00b28 <handle_provide_parameter+0x484>)
c0d00960:	4478      	add	r0, pc
c0d00962:	f7ff fbab 	bl	c0d000bc <semihosted_printf>
c0d00966:	3448      	adds	r4, #72	; 0x48
c0d00968:	2620      	movs	r6, #32
c0d0096a:	4620      	mov	r0, r4
c0d0096c:	4631      	mov	r1, r6
c0d0096e:	f004 f931 	bl	c0d04bd4 <__aeabi_memclr>
c0d00972:	68e9      	ldr	r1, [r5, #12]
c0d00974:	4620      	mov	r0, r4
c0d00976:	4632      	mov	r2, r6
c0d00978:	f004 f931 	bl	c0d04bde <__aeabi_memcpy>
c0d0097c:	486b      	ldr	r0, [pc, #428]	; (c0d00b2c <handle_provide_parameter+0x488>)
c0d0097e:	4478      	add	r0, pc
c0d00980:	f7ff fb9c 	bl	c0d000bc <semihosted_printf>
c0d00984:	4620      	mov	r0, r4
c0d00986:	4631      	mov	r1, r6
c0d00988:	f7ff fbbc 	bl	c0d00104 <print_bytes>
c0d0098c:	e1ba      	b.n	c0d00d04 <handle_provide_parameter+0x660>
c0d0098e:	280d      	cmp	r0, #13
c0d00990:	d13d      	bne.n	c0d00a0e <handle_provide_parameter+0x36a>
c0d00992:	4867      	ldr	r0, [pc, #412]	; (c0d00b30 <handle_provide_parameter+0x48c>)
c0d00994:	4478      	add	r0, pc
c0d00996:	e0f0      	b.n	c0d00b7a <handle_provide_parameter+0x4d6>
    switch (context->next_param) {
c0d00998:	280a      	cmp	r0, #10
c0d0099a:	dc22      	bgt.n	c0d009e2 <handle_provide_parameter+0x33e>
c0d0099c:	2807      	cmp	r0, #7
c0d0099e:	dd00      	ble.n	c0d009a2 <handle_provide_parameter+0x2fe>
c0d009a0:	e118      	b.n	c0d00bd4 <handle_provide_parameter+0x530>
c0d009a2:	2800      	cmp	r0, #0
c0d009a4:	d07e      	beq.n	c0d00aa4 <handle_provide_parameter+0x400>
c0d009a6:	2801      	cmp	r0, #1
c0d009a8:	d134      	bne.n	c0d00a14 <handle_provide_parameter+0x370>
c0d009aa:	4862      	ldr	r0, [pc, #392]	; (c0d00b34 <handle_provide_parameter+0x490>)
c0d009ac:	4478      	add	r0, pc
c0d009ae:	f7ff fb85 	bl	c0d000bc <semihosted_printf>
c0d009b2:	68e8      	ldr	r0, [r5, #12]
c0d009b4:	300c      	adds	r0, #12
c0d009b6:	2614      	movs	r6, #20
c0d009b8:	4631      	mov	r1, r6
c0d009ba:	f7ff fba3 	bl	c0d00104 <print_bytes>
c0d009be:	3414      	adds	r4, #20
c0d009c0:	4620      	mov	r0, r4
c0d009c2:	4631      	mov	r1, r6
c0d009c4:	f004 f906 	bl	c0d04bd4 <__aeabi_memclr>
c0d009c8:	68e9      	ldr	r1, [r5, #12]
c0d009ca:	310c      	adds	r1, #12
c0d009cc:	4620      	mov	r0, r4
c0d009ce:	4632      	mov	r2, r6
c0d009d0:	f004 f905 	bl	c0d04bde <__aeabi_memcpy>
c0d009d4:	4858      	ldr	r0, [pc, #352]	; (c0d00b38 <handle_provide_parameter+0x494>)
c0d009d6:	4478      	add	r0, pc
c0d009d8:	4631      	mov	r1, r6
c0d009da:	4622      	mov	r2, r4
c0d009dc:	f7ff fb6e 	bl	c0d000bc <semihosted_printf>
c0d009e0:	e0cd      	b.n	c0d00b7e <handle_provide_parameter+0x4da>
c0d009e2:	280c      	cmp	r0, #12
c0d009e4:	dc10      	bgt.n	c0d00a08 <handle_provide_parameter+0x364>
c0d009e6:	280b      	cmp	r0, #11
c0d009e8:	d100      	bne.n	c0d009ec <handle_provide_parameter+0x348>
c0d009ea:	e0a7      	b.n	c0d00b3c <handle_provide_parameter+0x498>
c0d009ec:	280c      	cmp	r0, #12
c0d009ee:	d111      	bne.n	c0d00a14 <handle_provide_parameter+0x370>
c0d009f0:	48fa      	ldr	r0, [pc, #1000]	; (c0d00ddc <handle_provide_parameter+0x738>)
c0d009f2:	4478      	add	r0, pc
c0d009f4:	f7ff fb62 	bl	c0d000bc <semihosted_printf>
c0d009f8:	68e8      	ldr	r0, [r5, #12]
c0d009fa:	300c      	adds	r0, #12
c0d009fc:	2614      	movs	r6, #20
c0d009fe:	4631      	mov	r1, r6
c0d00a00:	f7ff fb80 	bl	c0d00104 <print_bytes>
c0d00a04:	3480      	adds	r4, #128	; 0x80
c0d00a06:	e149      	b.n	c0d00c9c <handle_provide_parameter+0x5f8>
c0d00a08:	280d      	cmp	r0, #13
c0d00a0a:	d100      	bne.n	c0d00a0e <handle_provide_parameter+0x36a>
c0d00a0c:	e0b3      	b.n	c0d00b76 <handle_provide_parameter+0x4d2>
c0d00a0e:	280e      	cmp	r0, #14
c0d00a10:	d100      	bne.n	c0d00a14 <handle_provide_parameter+0x370>
c0d00a12:	e1e1      	b.n	c0d00dd8 <handle_provide_parameter+0x734>
c0d00a14:	48f8      	ldr	r0, [pc, #992]	; (c0d00df8 <handle_provide_parameter+0x754>)
c0d00a16:	4478      	add	r0, pc
c0d00a18:	f7ff fb50 	bl	c0d000bc <semihosted_printf>
c0d00a1c:	e003      	b.n	c0d00a26 <handle_provide_parameter+0x382>
        case SWAP_TOKENS_FOR_EXACT_ETH:
        case SWAP_TOKENS_FOR_EXACT_TOKENS:
            handle_swap_tokens(msg, context);
            break;
        default:
            PRINTF("Selector Index %d not supported\n", context->selectorIndex);
c0d00a1e:	48f0      	ldr	r0, [pc, #960]	; (c0d00de0 <handle_provide_parameter+0x73c>)
c0d00a20:	4478      	add	r0, pc
c0d00a22:	f7ff fb4b 	bl	c0d000bc <semihosted_printf>
c0d00a26:	2000      	movs	r0, #0
c0d00a28:	7528      	strb	r0, [r5, #20]
c0d00a2a:	e1d5      	b.n	c0d00dd8 <handle_provide_parameter+0x734>
            PRINTF("GPIRIOU TOKEN_A_ADDRESS\n");
c0d00a2c:	48fc      	ldr	r0, [pc, #1008]	; (c0d00e20 <handle_provide_parameter+0x77c>)
c0d00a2e:	4478      	add	r0, pc
c0d00a30:	f7ff fb44 	bl	c0d000bc <semihosted_printf>
c0d00a34:	2614      	movs	r6, #20
    memset(context->token_a_address, 0, sizeof(context->token_a_address));
c0d00a36:	4620      	mov	r0, r4
c0d00a38:	4631      	mov	r1, r6
c0d00a3a:	f004 f8cb 	bl	c0d04bd4 <__aeabi_memclr>
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
c0d00a3e:	68e9      	ldr	r1, [r5, #12]
c0d00a40:	310c      	adds	r1, #12
    memcpy(context->token_a_address,
c0d00a42:	4620      	mov	r0, r4
c0d00a44:	4632      	mov	r2, r6
c0d00a46:	f004 f8ca 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("TOKEN_A_ADDRESS CONTRACT: %.*H\n", ADDRESS_LENGTH, context->token_a_address);
c0d00a4a:	48f6      	ldr	r0, [pc, #984]	; (c0d00e24 <handle_provide_parameter+0x780>)
c0d00a4c:	4478      	add	r0, pc
c0d00a4e:	4631      	mov	r1, r6
c0d00a50:	4622      	mov	r2, r4
c0d00a52:	f7ff fb33 	bl	c0d000bc <semihosted_printf>
c0d00a56:	2002      	movs	r0, #2
c0d00a58:	e1bd      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    switch (context->next_param) {
c0d00a5a:	2802      	cmp	r0, #2
c0d00a5c:	d019      	beq.n	c0d00a92 <handle_provide_parameter+0x3ee>
c0d00a5e:	2805      	cmp	r0, #5
c0d00a60:	d1d8      	bne.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("GPIRIOU TOKEN_A_MIN\n");
c0d00a62:	48f2      	ldr	r0, [pc, #968]	; (c0d00e2c <handle_provide_parameter+0x788>)
c0d00a64:	4478      	add	r0, pc
c0d00a66:	f7ff fb29 	bl	c0d000bc <semihosted_printf>
    memset(context->token_a_amount_sent, 0, sizeof(context->token_a_amount_sent));
c0d00a6a:	3428      	adds	r4, #40	; 0x28
c0d00a6c:	2620      	movs	r6, #32
c0d00a6e:	4620      	mov	r0, r4
c0d00a70:	4631      	mov	r1, r6
c0d00a72:	f004 f8af 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_a_amount_sent, msg->parameter, sizeof(context->token_a_amount_sent));
c0d00a76:	68e9      	ldr	r1, [r5, #12]
c0d00a78:	4620      	mov	r0, r4
c0d00a7a:	4632      	mov	r2, r6
c0d00a7c:	f004 f8af 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN A AMOUNT:\n");
c0d00a80:	48eb      	ldr	r0, [pc, #940]	; (c0d00e30 <handle_provide_parameter+0x78c>)
c0d00a82:	4478      	add	r0, pc
c0d00a84:	f7ff fb1a 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d00a88:	4620      	mov	r0, r4
c0d00a8a:	4631      	mov	r1, r6
c0d00a8c:	f7ff fb3a 	bl	c0d00104 <print_bytes>
c0d00a90:	e1a0      	b.n	c0d00dd4 <handle_provide_parameter+0x730>
c0d00a92:	48e5      	ldr	r0, [pc, #916]	; (c0d00e28 <handle_provide_parameter+0x784>)
c0d00a94:	4478      	add	r0, pc
c0d00a96:	f7ff fb11 	bl	c0d000bc <semihosted_printf>
c0d00a9a:	2005      	movs	r0, #5
c0d00a9c:	e19b      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
c0d00a9e:	46c0      	nop			; (mov r8, r8)
c0d00aa0:	000048b9 	.word	0x000048b9
c0d00aa4:	48cf      	ldr	r0, [pc, #828]	; (c0d00de4 <handle_provide_parameter+0x740>)
c0d00aa6:	4478      	add	r0, pc
c0d00aa8:	f7ff fb08 	bl	c0d000bc <semihosted_printf>
c0d00aac:	68e8      	ldr	r0, [r5, #12]
c0d00aae:	300c      	adds	r0, #12
c0d00ab0:	2114      	movs	r1, #20
c0d00ab2:	9100      	str	r1, [sp, #0]
c0d00ab4:	f7ff fb26 	bl	c0d00104 <print_bytes>
c0d00ab8:	4620      	mov	r0, r4
c0d00aba:	9900      	ldr	r1, [sp, #0]
c0d00abc:	f004 f88a 	bl	c0d04bd4 <__aeabi_memclr>
c0d00ac0:	68e9      	ldr	r1, [r5, #12]
c0d00ac2:	310c      	adds	r1, #12
c0d00ac4:	4620      	mov	r0, r4
c0d00ac6:	9d00      	ldr	r5, [sp, #0]
c0d00ac8:	462a      	mov	r2, r5
c0d00aca:	f004 f888 	bl	c0d04bde <__aeabi_memcpy>
c0d00ace:	48c6      	ldr	r0, [pc, #792]	; (c0d00de8 <handle_provide_parameter+0x744>)
c0d00ad0:	4478      	add	r0, pc
c0d00ad2:	e128      	b.n	c0d00d26 <handle_provide_parameter+0x682>
c0d00ad4:	00004a85 	.word	0x00004a85
c0d00ad8:	00004a8c 	.word	0x00004a8c
c0d00adc:	00004a9d 	.word	0x00004a9d
c0d00ae0:	000048de 	.word	0x000048de
c0d00ae4:	00004a8e 	.word	0x00004a8e
c0d00ae8:	0000482f 	.word	0x0000482f
c0d00aec:	00004987 	.word	0x00004987
c0d00af0:	000049a5 	.word	0x000049a5
c0d00af4:	000049ac 	.word	0x000049ac
c0d00af8:	000049bf 	.word	0x000049bf
c0d00afc:	000048a5 	.word	0x000048a5
c0d00b00:	000049b0 	.word	0x000049b0
c0d00b04:	00004913 	.word	0x00004913
c0d00b08:	0000491a 	.word	0x0000491a
c0d00b0c:	00004928 	.word	0x00004928
c0d00b10:	0000484f 	.word	0x0000484f
c0d00b14:	00004744 	.word	0x00004744
c0d00b18:	00004843 	.word	0x00004843
c0d00b1c:	000047db 	.word	0x000047db
c0d00b20:	00004898 	.word	0x00004898
c0d00b24:	0000472b 	.word	0x0000472b
c0d00b28:	000047d2 	.word	0x000047d2
c0d00b2c:	000046b0 	.word	0x000046b0
c0d00b30:	000047c4 	.word	0x000047c4
c0d00b34:	000048f3 	.word	0x000048f3
c0d00b38:	00004630 	.word	0x00004630
c0d00b3c:	48ca      	ldr	r0, [pc, #808]	; (c0d00e68 <handle_provide_parameter+0x7c4>)
c0d00b3e:	4478      	add	r0, pc
c0d00b40:	f7ff fabc 	bl	c0d000bc <semihosted_printf>
c0d00b44:	68e8      	ldr	r0, [r5, #12]
c0d00b46:	7fc1      	ldrb	r1, [r0, #31]
c0d00b48:	48c8      	ldr	r0, [pc, #800]	; (c0d00e6c <handle_provide_parameter+0x7c8>)
c0d00b4a:	4478      	add	r0, pc
c0d00b4c:	f7ff fab6 	bl	c0d000bc <semihosted_printf>
c0d00b50:	68e8      	ldr	r0, [r5, #12]
c0d00b52:	7fc1      	ldrb	r1, [r0, #31]
c0d00b54:	7f80      	ldrb	r0, [r0, #30]
c0d00b56:	0200      	lsls	r0, r0, #8
c0d00b58:	1841      	adds	r1, r0, r1
c0d00b5a:	48c5      	ldr	r0, [pc, #788]	; (c0d00e70 <handle_provide_parameter+0x7cc>)
c0d00b5c:	4478      	add	r0, pc
c0d00b5e:	f7ff faad 	bl	c0d000bc <semihosted_printf>
c0d00b62:	68e8      	ldr	r0, [r5, #12]
c0d00b64:	7fc1      	ldrb	r1, [r0, #31]
c0d00b66:	7f80      	ldrb	r0, [r0, #30]
c0d00b68:	220c      	movs	r2, #12
c0d00b6a:	70fa      	strb	r2, [r7, #3]
c0d00b6c:	0200      	lsls	r0, r0, #8
c0d00b6e:	1840      	adds	r0, r0, r1
c0d00b70:	1d00      	adds	r0, r0, #4
c0d00b72:	8038      	strh	r0, [r7, #0]
c0d00b74:	e130      	b.n	c0d00dd8 <handle_provide_parameter+0x734>
c0d00b76:	48b1      	ldr	r0, [pc, #708]	; (c0d00e3c <handle_provide_parameter+0x798>)
c0d00b78:	4478      	add	r0, pc
c0d00b7a:	f7ff fa9f 	bl	c0d000bc <semihosted_printf>
c0d00b7e:	200e      	movs	r0, #14
c0d00b80:	e129      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    switch (context->next_param) {
c0d00b82:	2802      	cmp	r0, #2
c0d00b84:	dc48      	bgt.n	c0d00c18 <handle_provide_parameter+0x574>
c0d00b86:	2800      	cmp	r0, #0
c0d00b88:	d066      	beq.n	c0d00c58 <handle_provide_parameter+0x5b4>
c0d00b8a:	2801      	cmp	r0, #1
c0d00b8c:	d000      	beq.n	c0d00b90 <handle_provide_parameter+0x4ec>
c0d00b8e:	e741      	b.n	c0d00a14 <handle_provide_parameter+0x370>
    memset(context->token_b_address, 0, sizeof(context->token_b_address));
c0d00b90:	3414      	adds	r4, #20
c0d00b92:	2614      	movs	r6, #20
c0d00b94:	4620      	mov	r0, r4
c0d00b96:	4631      	mov	r1, r6
c0d00b98:	f004 f81c 	bl	c0d04bd4 <__aeabi_memclr>
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
c0d00b9c:	68e9      	ldr	r1, [r5, #12]
c0d00b9e:	310c      	adds	r1, #12
    memcpy(context->token_b_address,
c0d00ba0:	4620      	mov	r0, r4
c0d00ba2:	4632      	mov	r2, r6
c0d00ba4:	f004 f81b 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TOKEN_B_ADDRESS CONTRACT: %.*H\n", ADDRESS_LENGTH, context->token_b_address);
c0d00ba8:	4898      	ldr	r0, [pc, #608]	; (c0d00e0c <handle_provide_parameter+0x768>)
c0d00baa:	4478      	add	r0, pc
c0d00bac:	4631      	mov	r1, r6
c0d00bae:	4622      	mov	r2, r4
c0d00bb0:	f7ff fa84 	bl	c0d000bc <semihosted_printf>
c0d00bb4:	2003      	movs	r0, #3
c0d00bb6:	e10e      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    switch (context->next_param) {
c0d00bb8:	2801      	cmp	r0, #1
c0d00bba:	d100      	bne.n	c0d00bbe <handle_provide_parameter+0x51a>
c0d00bbc:	e0a4      	b.n	c0d00d08 <handle_provide_parameter+0x664>
c0d00bbe:	2804      	cmp	r0, #4
c0d00bc0:	d100      	bne.n	c0d00bc4 <handle_provide_parameter+0x520>
c0d00bc2:	e0b6      	b.n	c0d00d32 <handle_provide_parameter+0x68e>
c0d00bc4:	2806      	cmp	r0, #6
c0d00bc6:	d000      	beq.n	c0d00bca <handle_provide_parameter+0x526>
c0d00bc8:	e724      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("token min\n");
c0d00bca:	4888      	ldr	r0, [pc, #544]	; (c0d00dec <handle_provide_parameter+0x748>)
c0d00bcc:	4478      	add	r0, pc
c0d00bce:	f7ff fa75 	bl	c0d000bc <semihosted_printf>
c0d00bd2:	e698      	b.n	c0d00906 <handle_provide_parameter+0x262>
    switch (context->next_param) {
c0d00bd4:	2808      	cmp	r0, #8
c0d00bd6:	d100      	bne.n	c0d00bda <handle_provide_parameter+0x536>
c0d00bd8:	e0c1      	b.n	c0d00d5e <handle_provide_parameter+0x6ba>
c0d00bda:	280a      	cmp	r0, #10
c0d00bdc:	d000      	beq.n	c0d00be0 <handle_provide_parameter+0x53c>
c0d00bde:	e719      	b.n	c0d00a14 <handle_provide_parameter+0x370>
    memset(context->token_a_amount_sent, 0, sizeof(context->token_a_amount_sent));
c0d00be0:	3428      	adds	r4, #40	; 0x28
c0d00be2:	2620      	movs	r6, #32
c0d00be4:	4620      	mov	r0, r4
c0d00be6:	4631      	mov	r1, r6
c0d00be8:	f003 fff4 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_a_amount_sent, msg->parameter, sizeof(context->token_a_amount_sent));
c0d00bec:	68e9      	ldr	r1, [r5, #12]
c0d00bee:	4620      	mov	r0, r4
c0d00bf0:	4632      	mov	r2, r6
c0d00bf2:	f003 fff4 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN A AMOUNT:\n");
c0d00bf6:	4895      	ldr	r0, [pc, #596]	; (c0d00e4c <handle_provide_parameter+0x7a8>)
c0d00bf8:	4478      	add	r0, pc
c0d00bfa:	f7ff fa5f 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d00bfe:	4620      	mov	r0, r4
c0d00c00:	4631      	mov	r1, r6
c0d00c02:	f7ff fa7f 	bl	c0d00104 <print_bytes>
            PRINTF("GPIRIOU AMOUNT AFTER HANDLE A\n");
c0d00c06:	4892      	ldr	r0, [pc, #584]	; (c0d00e50 <handle_provide_parameter+0x7ac>)
c0d00c08:	4478      	add	r0, pc
c0d00c0a:	f7ff fa57 	bl	c0d000bc <semihosted_printf>
            print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d00c0e:	4620      	mov	r0, r4
c0d00c10:	4631      	mov	r1, r6
c0d00c12:	f7ff fa77 	bl	c0d00104 <print_bytes>
c0d00c16:	e06f      	b.n	c0d00cf8 <handle_provide_parameter+0x654>
    switch (context->next_param) {
c0d00c18:	2803      	cmp	r0, #3
c0d00c1a:	d100      	bne.n	c0d00c1e <handle_provide_parameter+0x57a>
c0d00c1c:	e0bd      	b.n	c0d00d9a <handle_provide_parameter+0x6f6>
c0d00c1e:	2804      	cmp	r0, #4
c0d00c20:	d000      	beq.n	c0d00c24 <handle_provide_parameter+0x580>
c0d00c22:	e6f7      	b.n	c0d00a14 <handle_provide_parameter+0x370>
    memset(context->token_b_amount_sent, 0, sizeof(context->token_b_amount_sent));
c0d00c24:	3448      	adds	r4, #72	; 0x48
c0d00c26:	2620      	movs	r6, #32
c0d00c28:	4620      	mov	r0, r4
c0d00c2a:	4631      	mov	r1, r6
c0d00c2c:	f003 ffd2 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_b_amount_sent, msg->parameter, sizeof(context->token_b_amount_sent));
c0d00c30:	68e9      	ldr	r1, [r5, #12]
c0d00c32:	4620      	mov	r0, r4
c0d00c34:	4632      	mov	r2, r6
c0d00c36:	f003 ffd2 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN B AMOUNT:\n");
c0d00c3a:	4875      	ldr	r0, [pc, #468]	; (c0d00e10 <handle_provide_parameter+0x76c>)
c0d00c3c:	4478      	add	r0, pc
c0d00c3e:	f7ff fa3d 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_b_amount_sent, sizeof(context->token_b_amount_sent));
c0d00c42:	4620      	mov	r0, r4
c0d00c44:	4631      	mov	r1, r6
c0d00c46:	f7ff fa5d 	bl	c0d00104 <print_bytes>
            PRINTF("after b\n");
c0d00c4a:	4872      	ldr	r0, [pc, #456]	; (c0d00e14 <handle_provide_parameter+0x770>)
c0d00c4c:	4478      	add	r0, pc
c0d00c4e:	e722      	b.n	c0d00a96 <handle_provide_parameter+0x3f2>
            PRINTF("GPIRIOU TOKEN_A_ADDRESS\n");
c0d00c50:	4878      	ldr	r0, [pc, #480]	; (c0d00e34 <handle_provide_parameter+0x790>)
c0d00c52:	4478      	add	r0, pc
c0d00c54:	f7ff fa32 	bl	c0d000bc <semihosted_printf>
c0d00c58:	2614      	movs	r6, #20
c0d00c5a:	4620      	mov	r0, r4
c0d00c5c:	4631      	mov	r1, r6
c0d00c5e:	f003 ffb9 	bl	c0d04bd4 <__aeabi_memclr>
c0d00c62:	68e9      	ldr	r1, [r5, #12]
c0d00c64:	310c      	adds	r1, #12
c0d00c66:	4620      	mov	r0, r4
c0d00c68:	4632      	mov	r2, r6
c0d00c6a:	f003 ffb8 	bl	c0d04bde <__aeabi_memcpy>
c0d00c6e:	4872      	ldr	r0, [pc, #456]	; (c0d00e38 <handle_provide_parameter+0x794>)
c0d00c70:	4478      	add	r0, pc
c0d00c72:	4631      	mov	r1, r6
c0d00c74:	4622      	mov	r2, r4
c0d00c76:	f7ff fa21 	bl	c0d000bc <semihosted_printf>
c0d00c7a:	2001      	movs	r0, #1
c0d00c7c:	e0ab      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    switch (context->next_param) {
c0d00c7e:	2805      	cmp	r0, #5
c0d00c80:	d100      	bne.n	c0d00c84 <handle_provide_parameter+0x5e0>
c0d00c82:	e0a3      	b.n	c0d00dcc <handle_provide_parameter+0x728>
c0d00c84:	2806      	cmp	r0, #6
c0d00c86:	d000      	beq.n	c0d00c8a <handle_provide_parameter+0x5e6>
c0d00c88:	e6c4      	b.n	c0d00a14 <handle_provide_parameter+0x370>
            PRINTF("b min\n");
c0d00c8a:	4863      	ldr	r0, [pc, #396]	; (c0d00e18 <handle_provide_parameter+0x774>)
c0d00c8c:	4478      	add	r0, pc
c0d00c8e:	e037      	b.n	c0d00d00 <handle_provide_parameter+0x65c>
c0d00c90:	4857      	ldr	r0, [pc, #348]	; (c0d00df0 <handle_provide_parameter+0x74c>)
c0d00c92:	4478      	add	r0, pc
c0d00c94:	f7ff fa12 	bl	c0d000bc <semihosted_printf>
c0d00c98:	3480      	adds	r4, #128	; 0x80
c0d00c9a:	2614      	movs	r6, #20
c0d00c9c:	4620      	mov	r0, r4
c0d00c9e:	4631      	mov	r1, r6
c0d00ca0:	f003 ff98 	bl	c0d04bd4 <__aeabi_memclr>
c0d00ca4:	68e9      	ldr	r1, [r5, #12]
c0d00ca6:	310c      	adds	r1, #12
c0d00ca8:	4620      	mov	r0, r4
c0d00caa:	4632      	mov	r2, r6
c0d00cac:	f003 ff97 	bl	c0d04bde <__aeabi_memcpy>
c0d00cb0:	4850      	ldr	r0, [pc, #320]	; (c0d00df4 <handle_provide_parameter+0x750>)
c0d00cb2:	4478      	add	r0, pc
c0d00cb4:	4631      	mov	r1, r6
c0d00cb6:	4622      	mov	r2, r4
c0d00cb8:	f7ff fa00 	bl	c0d000bc <semihosted_printf>
c0d00cbc:	200d      	movs	r0, #13
c0d00cbe:	e08a      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
            PRINTF("CURRENT PARAM: AMOUNT_IN_MAX INIT\n");
c0d00cc0:	485f      	ldr	r0, [pc, #380]	; (c0d00e40 <handle_provide_parameter+0x79c>)
c0d00cc2:	4478      	add	r0, pc
c0d00cc4:	f7ff f9fa 	bl	c0d000bc <semihosted_printf>
    memset(context->token_b_amount_sent, 0, sizeof(context->token_b_amount_sent));
c0d00cc8:	3448      	adds	r4, #72	; 0x48
c0d00cca:	2620      	movs	r6, #32
c0d00ccc:	4620      	mov	r0, r4
c0d00cce:	4631      	mov	r1, r6
c0d00cd0:	f003 ff80 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_b_amount_sent, msg->parameter, sizeof(context->token_b_amount_sent));
c0d00cd4:	68e9      	ldr	r1, [r5, #12]
c0d00cd6:	4620      	mov	r0, r4
c0d00cd8:	4632      	mov	r2, r6
c0d00cda:	f003 ff80 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN B AMOUNT:\n");
c0d00cde:	4859      	ldr	r0, [pc, #356]	; (c0d00e44 <handle_provide_parameter+0x7a0>)
c0d00ce0:	4478      	add	r0, pc
c0d00ce2:	f7ff f9eb 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_b_amount_sent, sizeof(context->token_b_amount_sent));
c0d00ce6:	4620      	mov	r0, r4
c0d00ce8:	4631      	mov	r1, r6
c0d00cea:	f7ff fa0b 	bl	c0d00104 <print_bytes>
            PRINTF("GPIRIOU AMOUNT IN MAX: %s\n", context->token_b_amount_sent);
c0d00cee:	4856      	ldr	r0, [pc, #344]	; (c0d00e48 <handle_provide_parameter+0x7a4>)
c0d00cf0:	4478      	add	r0, pc
c0d00cf2:	4621      	mov	r1, r4
c0d00cf4:	f7ff f9e2 	bl	c0d000bc <semihosted_printf>
c0d00cf8:	200b      	movs	r0, #11
c0d00cfa:	e06c      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
            PRINTF("eth min\n");
c0d00cfc:	4842      	ldr	r0, [pc, #264]	; (c0d00e08 <handle_provide_parameter+0x764>)
c0d00cfe:	4478      	add	r0, pc
c0d00d00:	f7ff f9dc 	bl	c0d000bc <semihosted_printf>
c0d00d04:	200c      	movs	r0, #12
c0d00d06:	e066      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    memset(context->token_b_address, 0, sizeof(context->token_b_address));
c0d00d08:	3414      	adds	r4, #20
c0d00d0a:	2114      	movs	r1, #20
c0d00d0c:	9100      	str	r1, [sp, #0]
c0d00d0e:	4620      	mov	r0, r4
c0d00d10:	f003 ff60 	bl	c0d04bd4 <__aeabi_memclr>
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
c0d00d14:	68e9      	ldr	r1, [r5, #12]
c0d00d16:	310c      	adds	r1, #12
    memcpy(context->token_b_address,
c0d00d18:	4620      	mov	r0, r4
c0d00d1a:	9d00      	ldr	r5, [sp, #0]
c0d00d1c:	462a      	mov	r2, r5
c0d00d1e:	f003 ff5e 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TOKEN_B_ADDRESS CONTRACT: %.*H\n", ADDRESS_LENGTH, context->token_b_address);
c0d00d22:	4836      	ldr	r0, [pc, #216]	; (c0d00dfc <handle_provide_parameter+0x758>)
c0d00d24:	4478      	add	r0, pc
c0d00d26:	4629      	mov	r1, r5
c0d00d28:	4622      	mov	r2, r4
c0d00d2a:	f7ff f9c7 	bl	c0d000bc <semihosted_printf>
c0d00d2e:	70fe      	strb	r6, [r7, #3]
c0d00d30:	e052      	b.n	c0d00dd8 <handle_provide_parameter+0x734>
    memset(context->token_b_amount_sent, 0, sizeof(context->token_b_amount_sent));
c0d00d32:	3448      	adds	r4, #72	; 0x48
c0d00d34:	2620      	movs	r6, #32
c0d00d36:	4620      	mov	r0, r4
c0d00d38:	4631      	mov	r1, r6
c0d00d3a:	f003 ff4b 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_b_amount_sent, msg->parameter, sizeof(context->token_b_amount_sent));
c0d00d3e:	68e9      	ldr	r1, [r5, #12]
c0d00d40:	4620      	mov	r0, r4
c0d00d42:	4632      	mov	r2, r6
c0d00d44:	f003 ff4b 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN B AMOUNT:\n");
c0d00d48:	482d      	ldr	r0, [pc, #180]	; (c0d00e00 <handle_provide_parameter+0x75c>)
c0d00d4a:	4478      	add	r0, pc
c0d00d4c:	f7ff f9b6 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_b_amount_sent, sizeof(context->token_b_amount_sent));
c0d00d50:	4620      	mov	r0, r4
c0d00d52:	4631      	mov	r1, r6
c0d00d54:	f7ff f9d6 	bl	c0d00104 <print_bytes>
            PRINTF("after\n");
c0d00d58:	482a      	ldr	r0, [pc, #168]	; (c0d00e04 <handle_provide_parameter+0x760>)
c0d00d5a:	4478      	add	r0, pc
c0d00d5c:	e038      	b.n	c0d00dd0 <handle_provide_parameter+0x72c>
            PRINTF("CURRENT PARAM: AMOUNT_OUT INIT\n");
c0d00d5e:	483f      	ldr	r0, [pc, #252]	; (c0d00e5c <handle_provide_parameter+0x7b8>)
c0d00d60:	4478      	add	r0, pc
c0d00d62:	f7ff f9ab 	bl	c0d000bc <semihosted_printf>
    memset(context->token_b_amount_sent, 0, sizeof(context->token_b_amount_sent));
c0d00d66:	3448      	adds	r4, #72	; 0x48
c0d00d68:	2620      	movs	r6, #32
c0d00d6a:	4620      	mov	r0, r4
c0d00d6c:	4631      	mov	r1, r6
c0d00d6e:	f003 ff31 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_b_amount_sent, msg->parameter, sizeof(context->token_b_amount_sent));
c0d00d72:	68e9      	ldr	r1, [r5, #12]
c0d00d74:	4620      	mov	r0, r4
c0d00d76:	4632      	mov	r2, r6
c0d00d78:	f003 ff31 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN B AMOUNT:\n");
c0d00d7c:	4838      	ldr	r0, [pc, #224]	; (c0d00e60 <handle_provide_parameter+0x7bc>)
c0d00d7e:	4478      	add	r0, pc
c0d00d80:	f7ff f99c 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_b_amount_sent, sizeof(context->token_b_amount_sent));
c0d00d84:	4620      	mov	r0, r4
c0d00d86:	4631      	mov	r1, r6
c0d00d88:	f7ff f9bc 	bl	c0d00104 <print_bytes>
            PRINTF("AMOUNT OUT: %s\n", context->token_b_amount_sent);
c0d00d8c:	4835      	ldr	r0, [pc, #212]	; (c0d00e64 <handle_provide_parameter+0x7c0>)
c0d00d8e:	4478      	add	r0, pc
c0d00d90:	4621      	mov	r1, r4
c0d00d92:	f7ff f993 	bl	c0d000bc <semihosted_printf>
c0d00d96:	200a      	movs	r0, #10
c0d00d98:	e01d      	b.n	c0d00dd6 <handle_provide_parameter+0x732>
    memset(context->token_a_amount_sent, 0, sizeof(context->token_a_amount_sent));
c0d00d9a:	3428      	adds	r4, #40	; 0x28
c0d00d9c:	2120      	movs	r1, #32
c0d00d9e:	9100      	str	r1, [sp, #0]
c0d00da0:	4620      	mov	r0, r4
c0d00da2:	f003 ff17 	bl	c0d04bd4 <__aeabi_memclr>
    memcpy(context->token_a_amount_sent, msg->parameter, sizeof(context->token_a_amount_sent));
c0d00da6:	68e9      	ldr	r1, [r5, #12]
c0d00da8:	4620      	mov	r0, r4
c0d00daa:	9d00      	ldr	r5, [sp, #0]
c0d00dac:	462a      	mov	r2, r5
c0d00dae:	f003 ff16 	bl	c0d04bde <__aeabi_memcpy>
    PRINTF("GPIRIOU TEST TOKEN A AMOUNT:\n");
c0d00db2:	4828      	ldr	r0, [pc, #160]	; (c0d00e54 <handle_provide_parameter+0x7b0>)
c0d00db4:	4478      	add	r0, pc
c0d00db6:	f7ff f981 	bl	c0d000bc <semihosted_printf>
    print_bytes(context->token_a_amount_sent, sizeof(context->token_a_amount_sent));
c0d00dba:	4620      	mov	r0, r4
c0d00dbc:	4629      	mov	r1, r5
c0d00dbe:	f7ff f9a1 	bl	c0d00104 <print_bytes>
            PRINTF("GPIRIOU HANDLE TOKEN A AMOUNT\n");
c0d00dc2:	4825      	ldr	r0, [pc, #148]	; (c0d00e58 <handle_provide_parameter+0x7b4>)
c0d00dc4:	4478      	add	r0, pc
c0d00dc6:	f7ff f979 	bl	c0d000bc <semihosted_printf>
c0d00dca:	e7b0      	b.n	c0d00d2e <handle_provide_parameter+0x68a>
            PRINTF("a min\n");
c0d00dcc:	4813      	ldr	r0, [pc, #76]	; (c0d00e1c <handle_provide_parameter+0x778>)
c0d00dce:	4478      	add	r0, pc
c0d00dd0:	f7ff f974 	bl	c0d000bc <semihosted_printf>
c0d00dd4:	2006      	movs	r0, #6
c0d00dd6:	70f8      	strb	r0, [r7, #3]
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
c0d00dd8:	b001      	add	sp, #4
c0d00dda:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00ddc:	0000484e 	.word	0x0000484e
c0d00de0:	0000456c 	.word	0x0000456c
c0d00de4:	000047d9 	.word	0x000047d9
c0d00de8:	000045e3 	.word	0x000045e3
c0d00dec:	0000440a 	.word	0x0000440a
c0d00df0:	00004358 	.word	0x00004358
c0d00df4:	0000439a 	.word	0x0000439a
c0d00df8:	000045db 	.word	0x000045db
c0d00dfc:	000042e2 	.word	0x000042e2
c0d00e00:	000042e4 	.word	0x000042e4
c0d00e04:	00004275 	.word	0x00004275
c0d00e08:	000042e3 	.word	0x000042e3
c0d00e0c:	0000445c 	.word	0x0000445c
c0d00e10:	000043f2 	.word	0x000043f2
c0d00e14:	00004450 	.word	0x00004450
c0d00e18:	00004420 	.word	0x00004420
c0d00e1c:	000042d7 	.word	0x000042d7
c0d00e20:	000046c3 	.word	0x000046c3
c0d00e24:	00004667 	.word	0x00004667
c0d00e28:	00004676 	.word	0x00004676
c0d00e2c:	000046b9 	.word	0x000046b9
c0d00e30:	00004651 	.word	0x00004651
c0d00e34:	0000449f 	.word	0x0000449f
c0d00e38:	00004443 	.word	0x00004443
c0d00e3c:	000046e9 	.word	0x000046e9
c0d00e40:	000045fd 	.word	0x000045fd
c0d00e44:	0000434e 	.word	0x0000434e
c0d00e48:	000045f2 	.word	0x000045f2
c0d00e4c:	000044db 	.word	0x000044db
c0d00e50:	00004715 	.word	0x00004715
c0d00e54:	0000431f 	.word	0x0000431f
c0d00e58:	000042b9 	.word	0x000042b9
c0d00e5c:	0000459d 	.word	0x0000459d
c0d00e60:	000042b0 	.word	0x000042b0
c0d00e64:	00004460 	.word	0x00004460
c0d00e68:	000046c0 	.word	0x000046c0
c0d00e6c:	000046ce 	.word	0x000046ce
c0d00e70:	000046d3 	.word	0x000046d3

c0d00e74 <handle_provide_token>:
#include "opensea_plugin.h"

void handle_provide_token(void *parameters) {
c0d00e74:	b570      	push	{r4, r5, r6, lr}
c0d00e76:	4604      	mov	r4, r0
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d00e78:	6885      	ldr	r5, [r0, #8]
    PRINTF("plugin provide token: 0x%p, 0x%p\n", msg->token1, msg->token2);
c0d00e7a:	68c1      	ldr	r1, [r0, #12]
c0d00e7c:	6902      	ldr	r2, [r0, #16]
c0d00e7e:	482f      	ldr	r0, [pc, #188]	; (c0d00f3c <handle_provide_token+0xc8>)
c0d00e80:	4478      	add	r0, pc
c0d00e82:	f7ff f91b 	bl	c0d000bc <semihosted_printf>
c0d00e86:	209f      	movs	r0, #159	; 0x9f

    // No need to check token1 for transactions involving sending ETH
    if (!(context->selectorIndex == ADD_LIQUIDITY_ETH) &&
c0d00e88:	5c28      	ldrb	r0, [r5, r0]
c0d00e8a:	462e      	mov	r6, r5
c0d00e8c:	3694      	adds	r6, #148	; 0x94
c0d00e8e:	280a      	cmp	r0, #10
c0d00e90:	d820      	bhi.n	c0d00ed4 <handle_provide_token+0x60>
c0d00e92:	2101      	movs	r1, #1
c0d00e94:	4081      	lsls	r1, r0
c0d00e96:	4828      	ldr	r0, [pc, #160]	; (c0d00f38 <handle_provide_token+0xc4>)
c0d00e98:	4201      	tst	r1, r0
c0d00e9a:	d01b      	beq.n	c0d00ed4 <handle_provide_token+0x60>
        }
    }

    // No need to check token2 for REMOVE_LIQUIDITY_ETH_PERMIT     ?????? The token address is in
    // the parameter data so what is the difference ?
    if (context->selectorIndex == REMOVE_LIQUIDITY_ETH ||
c0d00e9c:	7af0      	ldrb	r0, [r6, #11]
c0d00e9e:	21fc      	movs	r1, #252	; 0xfc
c0d00ea0:	4001      	ands	r1, r0
c0d00ea2:	2904      	cmp	r1, #4
c0d00ea4:	d109      	bne.n	c0d00eba <handle_provide_token+0x46>
c0d00ea6:	2012      	movs	r0, #18
        context->selectorIndex == REMOVE_LIQUIDITY_ETH_PERMIT ||
        context->selectorIndex == REMOVE_LIQUIDITY_ETH_FEE ||
        context->selectorIndex == REMOVE_LIQUIDITY_ETH_PERMIT_FEE) {
        context->decimals_token_b = WETH_DECIMALS;
c0d00ea8:	72b0      	strb	r0, [r6, #10]
        strncpy(context->ticker_token_b, "WETH ", 5);
c0d00eaa:	3574      	adds	r5, #116	; 0x74
c0d00eac:	4925      	ldr	r1, [pc, #148]	; (c0d00f44 <handle_provide_token+0xd0>)
c0d00eae:	4479      	add	r1, pc
c0d00eb0:	2205      	movs	r2, #5
c0d00eb2:	4628      	mov	r0, r5
c0d00eb4:	f003 fe93 	bl	c0d04bde <__aeabi_memcpy>
c0d00eb8:	e029      	b.n	c0d00f0e <handle_provide_token+0x9a>
        msg->result = ETH_PLUGIN_RESULT_OK;
        return;
    }

    if (msg->token2) {
c0d00eba:	6921      	ldr	r1, [r4, #16]
c0d00ebc:	2900      	cmp	r1, #0
c0d00ebe:	d016      	beq.n	c0d00eee <handle_provide_token+0x7a>
c0d00ec0:	2020      	movs	r0, #32
        context->decimals_token_b = msg->token2->decimals;
c0d00ec2:	5c08      	ldrb	r0, [r1, r0]
c0d00ec4:	72b0      	strb	r0, [r6, #10]
        strncpy(context->ticker_token_b,
c0d00ec6:	3574      	adds	r5, #116	; 0x74
                (char *) msg->token2->ticker,
c0d00ec8:	3114      	adds	r1, #20
c0d00eca:	220c      	movs	r2, #12
        strncpy(context->ticker_token_b,
c0d00ecc:	4628      	mov	r0, r5
c0d00ece:	f003 fee8 	bl	c0d04ca2 <strncpy>
c0d00ed2:	e01c      	b.n	c0d00f0e <handle_provide_token+0x9a>
        if (msg->token1) {
c0d00ed4:	68e1      	ldr	r1, [r4, #12]
c0d00ed6:	2900      	cmp	r1, #0
c0d00ed8:	d01c      	beq.n	c0d00f14 <handle_provide_token+0xa0>
c0d00eda:	2020      	movs	r0, #32
            context->decimals_token_a = msg->token1->decimals;
c0d00edc:	5c08      	ldrb	r0, [r1, r0]
c0d00ede:	7270      	strb	r0, [r6, #9]
            strncpy(context->ticker_token_a,
c0d00ee0:	4628      	mov	r0, r5
c0d00ee2:	3068      	adds	r0, #104	; 0x68
                    (char *) msg->token1->ticker,
c0d00ee4:	3114      	adds	r1, #20
c0d00ee6:	220c      	movs	r2, #12
            strncpy(context->ticker_token_a,
c0d00ee8:	f003 fedb 	bl	c0d04ca2 <strncpy>
c0d00eec:	e7d6      	b.n	c0d00e9c <handle_provide_token+0x28>
c0d00eee:	2012      	movs	r0, #18
                sizeof(context->ticker_token_b));
    } else {
        context->decimals_token_b = DEFAULT_DECIMAL;
c0d00ef0:	72b0      	strb	r0, [r6, #10]
        strncpy(context->ticker_token_b, DEFAULT_TICKER, sizeof(context->ticker_token_b));
c0d00ef2:	3574      	adds	r5, #116	; 0x74
c0d00ef4:	4914      	ldr	r1, [pc, #80]	; (c0d00f48 <handle_provide_token+0xd4>)
c0d00ef6:	4479      	add	r1, pc
c0d00ef8:	220c      	movs	r2, #12
c0d00efa:	4628      	mov	r0, r5
c0d00efc:	f003 fed1 	bl	c0d04ca2 <strncpy>
        context->screen_array |= WARNING_TOKEN_B_UI;
c0d00f00:	7830      	ldrb	r0, [r6, #0]
c0d00f02:	2108      	movs	r1, #8
c0d00f04:	4301      	orrs	r1, r0
c0d00f06:	7031      	strb	r1, [r6, #0]
        msg->additionalScreens++;
c0d00f08:	7d20      	ldrb	r0, [r4, #20]
c0d00f0a:	1c40      	adds	r0, r0, #1
c0d00f0c:	7520      	strb	r0, [r4, #20]
c0d00f0e:	2004      	movs	r0, #4
c0d00f10:	7560      	strb	r0, [r4, #21]
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00f12:	bd70      	pop	{r4, r5, r6, pc}
c0d00f14:	2012      	movs	r0, #18
            context->decimals_token_a = DEFAULT_DECIMAL;
c0d00f16:	7270      	strb	r0, [r6, #9]
            strncpy(context->ticker_token_a, DEFAULT_TICKER, sizeof(context->ticker_token_a));
c0d00f18:	4628      	mov	r0, r5
c0d00f1a:	3068      	adds	r0, #104	; 0x68
c0d00f1c:	4908      	ldr	r1, [pc, #32]	; (c0d00f40 <handle_provide_token+0xcc>)
c0d00f1e:	4479      	add	r1, pc
c0d00f20:	220c      	movs	r2, #12
c0d00f22:	f003 febe 	bl	c0d04ca2 <strncpy>
            context->screen_array |= WARNING_TOKEN_A_UI;
c0d00f26:	7830      	ldrb	r0, [r6, #0]
c0d00f28:	2102      	movs	r1, #2
c0d00f2a:	4301      	orrs	r1, r0
c0d00f2c:	7031      	strb	r1, [r6, #0]
            msg->additionalScreens++;
c0d00f2e:	7d20      	ldrb	r0, [r4, #20]
c0d00f30:	1c40      	adds	r0, r0, #1
c0d00f32:	7520      	strb	r0, [r4, #20]
c0d00f34:	e7b2      	b.n	c0d00e9c <handle_provide_token+0x28>
c0d00f36:	46c0      	nop			; (mov r8, r8)
c0d00f38:	00000602 	.word	0x00000602
c0d00f3c:	000044bc 	.word	0x000044bc
c0d00f40:	00004440 	.word	0x00004440
c0d00f44:	000044b3 	.word	0x000044b3
c0d00f48:	00004468 	.word	0x00004468

c0d00f4c <handle_query_contract_id>:
#include "opensea_plugin.h"

void handle_query_contract_id(void *parameters) {
c0d00f4c:	b5b0      	push	{r4, r5, r7, lr}
c0d00f4e:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d00f50:	6885      	ldr	r5, [r0, #8]

    // set 'OpenSea' title.
    strncpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d00f52:	68c0      	ldr	r0, [r0, #12]
c0d00f54:	6922      	ldr	r2, [r4, #16]
c0d00f56:	4912      	ldr	r1, [pc, #72]	; (c0d00fa0 <handle_query_contract_id+0x54>)
c0d00f58:	4479      	add	r1, pc
c0d00f5a:	f003 fea2 	bl	c0d04ca2 <strncpy>
c0d00f5e:	209f      	movs	r0, #159	; 0x9f

    switch (context->selectorIndex) {
c0d00f60:	5c29      	ldrb	r1, [r5, r0]
c0d00f62:	2910      	cmp	r1, #16
c0d00f64:	d816      	bhi.n	c0d00f94 <handle_query_contract_id+0x48>
c0d00f66:	2001      	movs	r0, #1
c0d00f68:	4088      	lsls	r0, r1
c0d00f6a:	03c1      	lsls	r1, r0, #15
c0d00f6c:	0dc9      	lsrs	r1, r1, #23
c0d00f6e:	d002      	beq.n	c0d00f76 <handle_query_contract_id+0x2a>
c0d00f70:	490d      	ldr	r1, [pc, #52]	; (c0d00fa8 <handle_query_contract_id+0x5c>)
c0d00f72:	4479      	add	r1, pc
c0d00f74:	e007      	b.n	c0d00f86 <handle_query_contract_id+0x3a>
c0d00f76:	0600      	lsls	r0, r0, #24
c0d00f78:	0e80      	lsrs	r0, r0, #26
c0d00f7a:	d002      	beq.n	c0d00f82 <handle_query_contract_id+0x36>
c0d00f7c:	490c      	ldr	r1, [pc, #48]	; (c0d00fb0 <handle_query_contract_id+0x64>)
c0d00f7e:	4479      	add	r1, pc
c0d00f80:	e001      	b.n	c0d00f86 <handle_query_contract_id+0x3a>
c0d00f82:	4908      	ldr	r1, [pc, #32]	; (c0d00fa4 <handle_query_contract_id+0x58>)
c0d00f84:	4479      	add	r1, pc
c0d00f86:	6960      	ldr	r0, [r4, #20]
c0d00f88:	69a2      	ldr	r2, [r4, #24]
c0d00f8a:	f003 fe8a 	bl	c0d04ca2 <strncpy>
c0d00f8e:	2004      	movs	r0, #4
c0d00f90:	7720      	strb	r0, [r4, #28]
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00f92:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("Selector Index :%d not supported\n", context->selectorIndex);
c0d00f94:	4805      	ldr	r0, [pc, #20]	; (c0d00fac <handle_query_contract_id+0x60>)
c0d00f96:	4478      	add	r0, pc
c0d00f98:	f7ff f890 	bl	c0d000bc <semihosted_printf>
c0d00f9c:	2000      	movs	r0, #0
c0d00f9e:	e7f7      	b.n	c0d00f90 <handle_query_contract_id+0x44>
c0d00fa0:	0000440f 	.word	0x0000440f
c0d00fa4:	000043eb 	.word	0x000043eb
c0d00fa8:	0000441c 	.word	0x0000441c
c0d00fac:	00004404 	.word	0x00004404
c0d00fb0:	000043ff 	.word	0x000043ff

c0d00fb4 <handle_query_contract_ui>:
        skip_left(msg, context);
        context->plugin_screen_index >>= 1;
    }
}

void handle_query_contract_ui(void *parameters) {
c0d00fb4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00fb6:	b089      	sub	sp, #36	; 0x24
c0d00fb8:	4604      	mov	r4, r0
    if (msg->screenIndex == 0) {
c0d00fba:	7b01      	ldrb	r1, [r0, #12]
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *) parameters;
    opensea_parameters_t *context = (opensea_parameters_t *) msg->pluginContext;
c0d00fbc:	6887      	ldr	r7, [r0, #8]
c0d00fbe:	9703      	str	r7, [sp, #12]
c0d00fc0:	3794      	adds	r7, #148	; 0x94
    if (msg->screenIndex == 0) {
c0d00fc2:	2900      	cmp	r1, #0
c0d00fc4:	d009      	beq.n	c0d00fda <handle_query_contract_ui+0x26>
    if (msg->screenIndex == context->previous_screen_index) {
c0d00fc6:	787a      	ldrb	r2, [r7, #1]
c0d00fc8:	4291      	cmp	r1, r2
c0d00fca:	d10a      	bne.n	c0d00fe2 <handle_query_contract_ui+0x2e>
c0d00fcc:	2080      	movs	r0, #128	; 0x80
        context->plugin_screen_index = LAST_UI;
c0d00fce:	70b8      	strb	r0, [r7, #2]
        if (context->screen_array & LAST_UI) return;
c0d00fd0:	7838      	ldrb	r0, [r7, #0]
c0d00fd2:	b240      	sxtb	r0, r0
c0d00fd4:	2800      	cmp	r0, #0
c0d00fd6:	d505      	bpl.n	c0d00fe4 <handle_query_contract_ui+0x30>
c0d00fd8:	e024      	b.n	c0d01024 <handle_query_contract_ui+0x70>
c0d00fda:	2000      	movs	r0, #0
        context->previous_screen_index = 0;
c0d00fdc:	7078      	strb	r0, [r7, #1]
c0d00fde:	2001      	movs	r0, #1
c0d00fe0:	e01f      	b.n	c0d01022 <handle_query_contract_ui+0x6e>
c0d00fe2:	7838      	ldrb	r0, [r7, #0]
    context->previous_screen_index = msg->screenIndex;
c0d00fe4:	7079      	strb	r1, [r7, #1]
    if (screen_index > previous_screen_index || screen_index == 0)
c0d00fe6:	1e49      	subs	r1, r1, #1
c0d00fe8:	b2c9      	uxtb	r1, r1
    if (scroll_direction == RIGHT_SCROLL) {
c0d00fea:	4291      	cmp	r1, r2
c0d00fec:	d20b      	bcs.n	c0d01006 <handle_query_contract_ui+0x52>
    while (!(context->screen_array & context->plugin_screen_index >> 1)) {
c0d00fee:	78b9      	ldrb	r1, [r7, #2]
c0d00ff0:	0849      	lsrs	r1, r1, #1
c0d00ff2:	4201      	tst	r1, r0
c0d00ff4:	d105      	bne.n	c0d01002 <handle_query_contract_ui+0x4e>
c0d00ff6:	460a      	mov	r2, r1
c0d00ff8:	0609      	lsls	r1, r1, #24
c0d00ffa:	0e49      	lsrs	r1, r1, #25
c0d00ffc:	4201      	tst	r1, r0
c0d00ffe:	d0fa      	beq.n	c0d00ff6 <handle_query_contract_ui+0x42>
        context->plugin_screen_index >>= 1;
c0d01000:	70ba      	strb	r2, [r7, #2]
        context->plugin_screen_index >>= 1;
c0d01002:	70b9      	strb	r1, [r7, #2]
c0d01004:	e00e      	b.n	c0d01024 <handle_query_contract_ui+0x70>
    while (!(context->screen_array & context->plugin_screen_index << 1)) {
c0d01006:	b2c1      	uxtb	r1, r0
c0d01008:	78b8      	ldrb	r0, [r7, #2]
c0d0100a:	0042      	lsls	r2, r0, #1
c0d0100c:	420a      	tst	r2, r1
c0d0100e:	d107      	bne.n	c0d01020 <handle_query_contract_ui+0x6c>
c0d01010:	4610      	mov	r0, r2
c0d01012:	227f      	movs	r2, #127	; 0x7f
c0d01014:	0092      	lsls	r2, r2, #2
c0d01016:	0043      	lsls	r3, r0, #1
c0d01018:	401a      	ands	r2, r3
c0d0101a:	420b      	tst	r3, r1
c0d0101c:	d0f8      	beq.n	c0d01010 <handle_query_contract_ui+0x5c>
        context->plugin_screen_index <<= 1;
c0d0101e:	70b8      	strb	r0, [r7, #2]
        context->plugin_screen_index <<= 1;
c0d01020:	0040      	lsls	r0, r0, #1
c0d01022:	70b8      	strb	r0, [r7, #2]

    get_screen_array(msg, context);
    print_bytes(&context->plugin_screen_index, 1);
c0d01024:	1cb8      	adds	r0, r7, #2
c0d01026:	2601      	movs	r6, #1
c0d01028:	4631      	mov	r1, r6
c0d0102a:	f7ff f86b 	bl	c0d00104 <print_bytes>
    memset(msg->title, 0, msg->titleLength);
c0d0102e:	6920      	ldr	r0, [r4, #16]
c0d01030:	6961      	ldr	r1, [r4, #20]
c0d01032:	f003 fdcf 	bl	c0d04bd4 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d01036:	69a0      	ldr	r0, [r4, #24]
c0d01038:	69e1      	ldr	r1, [r4, #28]
c0d0103a:	f003 fdcb 	bl	c0d04bd4 <__aeabi_memclr>
c0d0103e:	2020      	movs	r0, #32
c0d01040:	2104      	movs	r1, #4
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d01042:	5421      	strb	r1, [r4, r0]
c0d01044:	4625      	mov	r5, r4
c0d01046:	3520      	adds	r5, #32
    switch (context->plugin_screen_index) {
c0d01048:	78b8      	ldrb	r0, [r7, #2]
c0d0104a:	280f      	cmp	r0, #15
c0d0104c:	dc15      	bgt.n	c0d0107a <handle_query_contract_ui+0xc6>
c0d0104e:	2803      	cmp	r0, #3
c0d01050:	dc29      	bgt.n	c0d010a6 <handle_query_contract_ui+0xf2>
c0d01052:	2801      	cmp	r0, #1
c0d01054:	d050      	beq.n	c0d010f8 <handle_query_contract_ui+0x144>
c0d01056:	2802      	cmp	r0, #2
c0d01058:	d000      	beq.n	c0d0105c <handle_query_contract_ui+0xa8>
c0d0105a:	e0b4      	b.n	c0d011c6 <handle_query_contract_ui+0x212>
        case TX_TYPE_UI:
            PRINTF("GPIRIOU TX_TYPE\n");
            set_tx_type_ui(msg, context);
            break;
        case WARNING_TOKEN_A_UI:
            PRINTF("GPIRIOU WARNING A\n");
c0d0105c:	48ad      	ldr	r0, [pc, #692]	; (c0d01314 <handle_query_contract_ui+0x360>)
c0d0105e:	4478      	add	r0, pc
c0d01060:	f7ff f82c 	bl	c0d000bc <semihosted_printf>
    strncpy(msg->title, "0000 0010", msg->titleLength);
c0d01064:	6920      	ldr	r0, [r4, #16]
c0d01066:	6962      	ldr	r2, [r4, #20]
c0d01068:	49ab      	ldr	r1, [pc, #684]	; (c0d01318 <handle_query_contract_ui+0x364>)
c0d0106a:	4479      	add	r1, pc
c0d0106c:	f003 fe19 	bl	c0d04ca2 <strncpy>
    strncpy(msg->msg, "! token A", msg->msgLength);
c0d01070:	69a0      	ldr	r0, [r4, #24]
c0d01072:	69e2      	ldr	r2, [r4, #28]
c0d01074:	49a9      	ldr	r1, [pc, #676]	; (c0d0131c <handle_query_contract_ui+0x368>)
c0d01076:	4479      	add	r1, pc
c0d01078:	e03b      	b.n	c0d010f2 <handle_query_contract_ui+0x13e>
    switch (context->plugin_screen_index) {
c0d0107a:	283f      	cmp	r0, #63	; 0x3f
c0d0107c:	dc27      	bgt.n	c0d010ce <handle_query_contract_ui+0x11a>
c0d0107e:	2810      	cmp	r0, #16
c0d01080:	d061      	beq.n	c0d01146 <handle_query_contract_ui+0x192>
c0d01082:	2820      	cmp	r0, #32
c0d01084:	d000      	beq.n	c0d01088 <handle_query_contract_ui+0xd4>
c0d01086:	e09e      	b.n	c0d011c6 <handle_query_contract_ui+0x212>
        case AMOUNT_TOKEN_B_UI:
            PRINTF("GPIRIOU AMOUNT B\n");
            set_amount_token_b_ui(msg, context);
            break;
        case WARNING_ADDRESS_UI:
            PRINTF("GPIRIOU WARNING ADDRESS\n");
c0d01088:	48a8      	ldr	r0, [pc, #672]	; (c0d0132c <handle_query_contract_ui+0x378>)
c0d0108a:	4478      	add	r0, pc
c0d0108c:	f7ff f816 	bl	c0d000bc <semihosted_printf>
    strncpy(msg->title, "0010 0000", msg->titleLength);
c0d01090:	6920      	ldr	r0, [r4, #16]
c0d01092:	6962      	ldr	r2, [r4, #20]
c0d01094:	49a6      	ldr	r1, [pc, #664]	; (c0d01330 <handle_query_contract_ui+0x37c>)
c0d01096:	4479      	add	r1, pc
c0d01098:	f003 fe03 	bl	c0d04ca2 <strncpy>
    strncpy(msg->msg, "Not user's address", msg->titleLength);
c0d0109c:	6962      	ldr	r2, [r4, #20]
c0d0109e:	69a0      	ldr	r0, [r4, #24]
c0d010a0:	49a4      	ldr	r1, [pc, #656]	; (c0d01334 <handle_query_contract_ui+0x380>)
c0d010a2:	4479      	add	r1, pc
c0d010a4:	e025      	b.n	c0d010f2 <handle_query_contract_ui+0x13e>
    switch (context->plugin_screen_index) {
c0d010a6:	2804      	cmp	r0, #4
c0d010a8:	d060      	beq.n	c0d0116c <handle_query_contract_ui+0x1b8>
c0d010aa:	2808      	cmp	r0, #8
c0d010ac:	d000      	beq.n	c0d010b0 <handle_query_contract_ui+0xfc>
c0d010ae:	e08a      	b.n	c0d011c6 <handle_query_contract_ui+0x212>
            PRINTF("GPIRIOU WARNING B\n");
c0d010b0:	489b      	ldr	r0, [pc, #620]	; (c0d01320 <handle_query_contract_ui+0x36c>)
c0d010b2:	4478      	add	r0, pc
c0d010b4:	f7ff f802 	bl	c0d000bc <semihosted_printf>
    strncpy(msg->title, "0000 1000", msg->titleLength);
c0d010b8:	6920      	ldr	r0, [r4, #16]
c0d010ba:	6962      	ldr	r2, [r4, #20]
c0d010bc:	4999      	ldr	r1, [pc, #612]	; (c0d01324 <handle_query_contract_ui+0x370>)
c0d010be:	4479      	add	r1, pc
c0d010c0:	f003 fdef 	bl	c0d04ca2 <strncpy>
    strncpy(msg->msg, "! token B", msg->msgLength);
c0d010c4:	69a0      	ldr	r0, [r4, #24]
c0d010c6:	69e2      	ldr	r2, [r4, #28]
c0d010c8:	4997      	ldr	r1, [pc, #604]	; (c0d01328 <handle_query_contract_ui+0x374>)
c0d010ca:	4479      	add	r1, pc
c0d010cc:	e011      	b.n	c0d010f2 <handle_query_contract_ui+0x13e>
    switch (context->plugin_screen_index) {
c0d010ce:	2840      	cmp	r0, #64	; 0x40
c0d010d0:	d05a      	beq.n	c0d01188 <handle_query_contract_ui+0x1d4>
c0d010d2:	2880      	cmp	r0, #128	; 0x80
c0d010d4:	d177      	bne.n	c0d011c6 <handle_query_contract_ui+0x212>
        case ADDRESS_UI:
            PRINTF("GPIRIOU BENEFICIARY\n");
            set_beneficiary_ui(msg, context);
            break;
        case LAST_UI:
            PRINTF("GPIRIOU LAST UI\n");
c0d010d6:	4898      	ldr	r0, [pc, #608]	; (c0d01338 <handle_query_contract_ui+0x384>)
c0d010d8:	4478      	add	r0, pc
c0d010da:	f7fe ffef 	bl	c0d000bc <semihosted_printf>
    strncpy(msg->title, "1000 0000", msg->titleLength);
c0d010de:	6920      	ldr	r0, [r4, #16]
c0d010e0:	6962      	ldr	r2, [r4, #20]
c0d010e2:	4996      	ldr	r1, [pc, #600]	; (c0d0133c <handle_query_contract_ui+0x388>)
c0d010e4:	4479      	add	r1, pc
c0d010e6:	f003 fddc 	bl	c0d04ca2 <strncpy>
    strncpy(msg->msg, "LAST", msg->titleLength);
c0d010ea:	6962      	ldr	r2, [r4, #20]
c0d010ec:	69a0      	ldr	r0, [r4, #24]
c0d010ee:	4994      	ldr	r1, [pc, #592]	; (c0d01340 <handle_query_contract_ui+0x38c>)
c0d010f0:	4479      	add	r1, pc
c0d010f2:	f003 fdd6 	bl	c0d04ca2 <strncpy>
c0d010f6:	e0e2      	b.n	c0d012be <handle_query_contract_ui+0x30a>
            PRINTF("GPIRIOU TX_TYPE\n");
c0d010f8:	4892      	ldr	r0, [pc, #584]	; (c0d01344 <handle_query_contract_ui+0x390>)
c0d010fa:	4478      	add	r0, pc
c0d010fc:	f7fe ffde 	bl	c0d000bc <semihosted_printf>
    switch (context->selectorIndex) {
c0d01100:	7af8      	ldrb	r0, [r7, #11]
c0d01102:	2810      	cmp	r0, #16
c0d01104:	d900      	bls.n	c0d01108 <handle_query_contract_ui+0x154>
c0d01106:	e0a9      	b.n	c0d0125c <handle_query_contract_ui+0x2a8>
c0d01108:	4086      	lsls	r6, r0
c0d0110a:	0631      	lsls	r1, r6, #24
c0d0110c:	0e89      	lsrs	r1, r1, #26
c0d0110e:	d000      	beq.n	c0d01112 <handle_query_contract_ui+0x15e>
c0d01110:	e0be      	b.n	c0d01290 <handle_query_contract_ui+0x2dc>
c0d01112:	03f1      	lsls	r1, r6, #15
c0d01114:	0e89      	lsrs	r1, r1, #26
c0d01116:	d100      	bne.n	c0d0111a <handle_query_contract_ui+0x166>
c0d01118:	e091      	b.n	c0d0123e <handle_query_contract_ui+0x28a>
c0d0111a:	9d03      	ldr	r5, [sp, #12]
            PRINTF("tokenA: %s\n", context->ticker_token_a);
c0d0111c:	462e      	mov	r6, r5
c0d0111e:	3668      	adds	r6, #104	; 0x68
c0d01120:	488e      	ldr	r0, [pc, #568]	; (c0d0135c <handle_query_contract_ui+0x3a8>)
c0d01122:	4478      	add	r0, pc
c0d01124:	4631      	mov	r1, r6
c0d01126:	f7fe ffc9 	bl	c0d000bc <semihosted_printf>
            strncpy(msg->title, "Swap:", msg->titleLength);
c0d0112a:	6920      	ldr	r0, [r4, #16]
c0d0112c:	6962      	ldr	r2, [r4, #20]
c0d0112e:	498c      	ldr	r1, [pc, #560]	; (c0d01360 <handle_query_contract_ui+0x3ac>)
c0d01130:	4479      	add	r1, pc
c0d01132:	f003 fdb6 	bl	c0d04ca2 <strncpy>
            snprintf(msg->msg,
c0d01136:	69a0      	ldr	r0, [r4, #24]
                     msg->msgLength,
c0d01138:	69e1      	ldr	r1, [r4, #28]
                     context->ticker_token_b);
c0d0113a:	3574      	adds	r5, #116	; 0x74
            snprintf(msg->msg,
c0d0113c:	9500      	str	r5, [sp, #0]
c0d0113e:	4a89      	ldr	r2, [pc, #548]	; (c0d01364 <handle_query_contract_ui+0x3b0>)
c0d01140:	447a      	add	r2, pc
c0d01142:	4633      	mov	r3, r6
c0d01144:	e0b9      	b.n	c0d012ba <handle_query_contract_ui+0x306>
            PRINTF("GPIRIOU AMOUNT B\n");
c0d01146:	4890      	ldr	r0, [pc, #576]	; (c0d01388 <handle_query_contract_ui+0x3d4>)
c0d01148:	4478      	add	r0, pc
c0d0114a:	f7fe ffb7 	bl	c0d000bc <semihosted_printf>
    switch (context->selectorIndex) {
c0d0114e:	7af9      	ldrb	r1, [r7, #11]
c0d01150:	2910      	cmp	r1, #16
c0d01152:	d900      	bls.n	c0d01156 <handle_query_contract_ui+0x1a2>
c0d01154:	e0d5      	b.n	c0d01302 <handle_query_contract_ui+0x34e>
c0d01156:	408e      	lsls	r6, r1
c0d01158:	486d      	ldr	r0, [pc, #436]	; (c0d01310 <handle_query_contract_ui+0x35c>)
c0d0115a:	4206      	tst	r6, r0
c0d0115c:	d155      	bne.n	c0d0120a <handle_query_contract_ui+0x256>
c0d0115e:	0630      	lsls	r0, r6, #24
c0d01160:	0e80      	lsrs	r0, r0, #26
c0d01162:	d100      	bne.n	c0d01166 <handle_query_contract_ui+0x1b2>
c0d01164:	e0ad      	b.n	c0d012c2 <handle_query_contract_ui+0x30e>
c0d01166:	498b      	ldr	r1, [pc, #556]	; (c0d01394 <handle_query_contract_ui+0x3e0>)
c0d01168:	4479      	add	r1, pc
c0d0116a:	e050      	b.n	c0d0120e <handle_query_contract_ui+0x25a>
            PRINTF("GPIRIOU AMOUNT A\n");
c0d0116c:	487e      	ldr	r0, [pc, #504]	; (c0d01368 <handle_query_contract_ui+0x3b4>)
c0d0116e:	4478      	add	r0, pc
c0d01170:	f7fe ffa4 	bl	c0d000bc <semihosted_printf>
            switch (context->selectorIndex) {
c0d01174:	7af9      	ldrb	r1, [r7, #11]
c0d01176:	2907      	cmp	r1, #7
c0d01178:	dc2a      	bgt.n	c0d011d0 <handle_query_contract_ui+0x21c>
c0d0117a:	1e88      	subs	r0, r1, #2
c0d0117c:	2806      	cmp	r0, #6
c0d0117e:	d300      	bcc.n	c0d01182 <handle_query_contract_ui+0x1ce>
c0d01180:	e0a4      	b.n	c0d012cc <handle_query_contract_ui+0x318>
c0d01182:	4b7f      	ldr	r3, [pc, #508]	; (c0d01380 <handle_query_contract_ui+0x3cc>)
c0d01184:	447b      	add	r3, pc
c0d01186:	e029      	b.n	c0d011dc <handle_query_contract_ui+0x228>
            PRINTF("GPIRIOU BENEFICIARY\n");
c0d01188:	4883      	ldr	r0, [pc, #524]	; (c0d01398 <handle_query_contract_ui+0x3e4>)
c0d0118a:	4478      	add	r0, pc
c0d0118c:	f7fe ff96 	bl	c0d000bc <semihosted_printf>
    strncpy(msg->title, "Beneficiary:", msg->titleLength);
c0d01190:	6920      	ldr	r0, [r4, #16]
c0d01192:	6962      	ldr	r2, [r4, #20]
c0d01194:	4981      	ldr	r1, [pc, #516]	; (c0d0139c <handle_query_contract_ui+0x3e8>)
c0d01196:	4479      	add	r1, pc
c0d01198:	f003 fd83 	bl	c0d04ca2 <strncpy>
    msg->msg[0] = '0';
c0d0119c:	69a0      	ldr	r0, [r4, #24]
c0d0119e:	2130      	movs	r1, #48	; 0x30
c0d011a0:	7001      	strb	r1, [r0, #0]
    msg->msg[1] = 'x';
c0d011a2:	69a0      	ldr	r0, [r4, #24]
c0d011a4:	2178      	movs	r1, #120	; 0x78
c0d011a6:	7041      	strb	r1, [r0, #1]
c0d011a8:	ae04      	add	r6, sp, #16
c0d011aa:	2114      	movs	r1, #20
    chain_config_t chainConfig = {0};
c0d011ac:	4630      	mov	r0, r6
c0d011ae:	f003 fd11 	bl	c0d04bd4 <__aeabi_memclr>
                                  msg->pluginSharedRW->sha3,
c0d011b2:	6820      	ldr	r0, [r4, #0]
c0d011b4:	6802      	ldr	r2, [r0, #0]
                                  (uint8_t *) msg->msg + 2,
c0d011b6:	69a1      	ldr	r1, [r4, #24]
c0d011b8:	9803      	ldr	r0, [sp, #12]
    getEthAddressStringFromBinary((uint8_t *) context->beneficiary,
c0d011ba:	3080      	adds	r0, #128	; 0x80
                                  (uint8_t *) msg->msg + 2,
c0d011bc:	1c89      	adds	r1, r1, #2
    getEthAddressStringFromBinary((uint8_t *) context->beneficiary,
c0d011be:	4633      	mov	r3, r6
c0d011c0:	f7fe ffd6 	bl	c0d00170 <getEthAddressStringFromBinary>
c0d011c4:	e07b      	b.n	c0d012be <handle_query_contract_ui+0x30a>
            set_last_ui(msg, context);
            break;
        default:
            PRINTF("GPIRIOU ERROR\n");
c0d011c6:	4876      	ldr	r0, [pc, #472]	; (c0d013a0 <handle_query_contract_ui+0x3ec>)
c0d011c8:	4478      	add	r0, pc
c0d011ca:	f7fe ff77 	bl	c0d000bc <semihosted_printf>
c0d011ce:	e076      	b.n	c0d012be <handle_query_contract_ui+0x30a>
            switch (context->selectorIndex) {
c0d011d0:	4608      	mov	r0, r1
c0d011d2:	380c      	subs	r0, #12
c0d011d4:	2805      	cmp	r0, #5
c0d011d6:	d22b      	bcs.n	c0d01230 <handle_query_contract_ui+0x27c>
c0d011d8:	4b68      	ldr	r3, [pc, #416]	; (c0d0137c <handle_query_contract_ui+0x3c8>)
c0d011da:	447b      	add	r3, pc
c0d011dc:	6920      	ldr	r0, [r4, #16]
c0d011de:	6962      	ldr	r2, [r4, #20]
c0d011e0:	4619      	mov	r1, r3
c0d011e2:	f003 fd5e 	bl	c0d04ca2 <strncpy>
                   context->decimals_token_a,
c0d011e6:	7a7a      	ldrb	r2, [r7, #9]
                   msg->msg,
c0d011e8:	69a0      	ldr	r0, [r4, #24]
                   msg->msgLength);
c0d011ea:	7f21      	ldrb	r1, [r4, #28]
    amountToString(context->token_a_amount_sent,
c0d011ec:	9000      	str	r0, [sp, #0]
c0d011ee:	9101      	str	r1, [sp, #4]
c0d011f0:	9b03      	ldr	r3, [sp, #12]
c0d011f2:	4618      	mov	r0, r3
c0d011f4:	3028      	adds	r0, #40	; 0x28
                   context->ticker_token_a,
c0d011f6:	3368      	adds	r3, #104	; 0x68
c0d011f8:	2120      	movs	r1, #32
    amountToString(context->token_a_amount_sent,
c0d011fa:	f7ff f935 	bl	c0d00468 <amountToString>
    PRINTF("GPIRIOU msgLeength: %d\n", msg->msgLength);
c0d011fe:	69e1      	ldr	r1, [r4, #28]
c0d01200:	4860      	ldr	r0, [pc, #384]	; (c0d01384 <handle_query_contract_ui+0x3d0>)
c0d01202:	4478      	add	r0, pc
c0d01204:	f7fe ff5a 	bl	c0d000bc <semihosted_printf>
c0d01208:	e059      	b.n	c0d012be <handle_query_contract_ui+0x30a>
c0d0120a:	4961      	ldr	r1, [pc, #388]	; (c0d01390 <handle_query_contract_ui+0x3dc>)
c0d0120c:	4479      	add	r1, pc
c0d0120e:	6920      	ldr	r0, [r4, #16]
c0d01210:	6962      	ldr	r2, [r4, #20]
c0d01212:	f003 fd46 	bl	c0d04ca2 <strncpy>
                   context->decimals_token_b,
c0d01216:	7aba      	ldrb	r2, [r7, #10]
                   msg->msg,
c0d01218:	69a0      	ldr	r0, [r4, #24]
                   msg->msgLength);
c0d0121a:	7f21      	ldrb	r1, [r4, #28]
    amountToString(context->token_b_amount_sent,
c0d0121c:	9000      	str	r0, [sp, #0]
c0d0121e:	9101      	str	r1, [sp, #4]
c0d01220:	9b03      	ldr	r3, [sp, #12]
c0d01222:	4618      	mov	r0, r3
c0d01224:	3048      	adds	r0, #72	; 0x48
                   context->ticker_token_b,
c0d01226:	3374      	adds	r3, #116	; 0x74
c0d01228:	2120      	movs	r1, #32
c0d0122a:	f7ff f91d 	bl	c0d00468 <amountToString>
c0d0122e:	e046      	b.n	c0d012be <handle_query_contract_ui+0x30a>
            switch (context->selectorIndex) {
c0d01230:	4608      	mov	r0, r1
c0d01232:	3809      	subs	r0, #9
c0d01234:	2802      	cmp	r0, #2
c0d01236:	d255      	bcs.n	c0d012e4 <handle_query_contract_ui+0x330>
c0d01238:	4b4e      	ldr	r3, [pc, #312]	; (c0d01374 <handle_query_contract_ui+0x3c0>)
c0d0123a:	447b      	add	r3, pc
c0d0123c:	e04c      	b.n	c0d012d8 <handle_query_contract_ui+0x324>
c0d0123e:	0571      	lsls	r1, r6, #21
c0d01240:	0f49      	lsrs	r1, r1, #29
c0d01242:	d00b      	beq.n	c0d0125c <handle_query_contract_ui+0x2a8>
            strncpy(msg->title, "Swap:", msg->titleLength);
c0d01244:	6920      	ldr	r0, [r4, #16]
c0d01246:	6962      	ldr	r2, [r4, #20]
c0d01248:	4941      	ldr	r1, [pc, #260]	; (c0d01350 <handle_query_contract_ui+0x39c>)
c0d0124a:	4479      	add	r1, pc
c0d0124c:	f003 fd29 	bl	c0d04ca2 <strncpy>
            snprintf(msg->msg, msg->msgLength, "%s / %s", "ETH", context->ticker_token_b);
c0d01250:	69a0      	ldr	r0, [r4, #24]
c0d01252:	69e1      	ldr	r1, [r4, #28]
c0d01254:	9a03      	ldr	r2, [sp, #12]
c0d01256:	3274      	adds	r2, #116	; 0x74
c0d01258:	9200      	str	r2, [sp, #0]
c0d0125a:	e014      	b.n	c0d01286 <handle_query_contract_ui+0x2d2>
    switch (context->selectorIndex) {
c0d0125c:	2800      	cmp	r0, #0
c0d0125e:	d017      	beq.n	c0d01290 <handle_query_contract_ui+0x2dc>
c0d01260:	2801      	cmp	r0, #1
c0d01262:	d12c      	bne.n	c0d012be <handle_query_contract_ui+0x30a>
c0d01264:	9d03      	ldr	r5, [sp, #12]
            PRINTF("tokenA: %s\n", context->ticker_token_a);
c0d01266:	4629      	mov	r1, r5
c0d01268:	3168      	adds	r1, #104	; 0x68
c0d0126a:	4837      	ldr	r0, [pc, #220]	; (c0d01348 <handle_query_contract_ui+0x394>)
c0d0126c:	4478      	add	r0, pc
c0d0126e:	f7fe ff25 	bl	c0d000bc <semihosted_printf>
            strncpy(msg->title, "Liquidity Pool:", msg->titleLength);
c0d01272:	6920      	ldr	r0, [r4, #16]
c0d01274:	6962      	ldr	r2, [r4, #20]
c0d01276:	4935      	ldr	r1, [pc, #212]	; (c0d0134c <handle_query_contract_ui+0x398>)
c0d01278:	4479      	add	r1, pc
c0d0127a:	f003 fd12 	bl	c0d04ca2 <strncpy>
            snprintf(msg->msg, msg->msgLength, "%s / %s", "ETH", context->ticker_token_b);
c0d0127e:	69a0      	ldr	r0, [r4, #24]
c0d01280:	69e1      	ldr	r1, [r4, #28]
c0d01282:	3574      	adds	r5, #116	; 0x74
c0d01284:	9500      	str	r5, [sp, #0]
c0d01286:	4a33      	ldr	r2, [pc, #204]	; (c0d01354 <handle_query_contract_ui+0x3a0>)
c0d01288:	447a      	add	r2, pc
c0d0128a:	4b33      	ldr	r3, [pc, #204]	; (c0d01358 <handle_query_contract_ui+0x3a4>)
c0d0128c:	447b      	add	r3, pc
c0d0128e:	e014      	b.n	c0d012ba <handle_query_contract_ui+0x306>
c0d01290:	9d03      	ldr	r5, [sp, #12]
            PRINTF("tokenB: %s\n", context->ticker_token_b);
c0d01292:	462e      	mov	r6, r5
c0d01294:	3674      	adds	r6, #116	; 0x74
c0d01296:	4843      	ldr	r0, [pc, #268]	; (c0d013a4 <handle_query_contract_ui+0x3f0>)
c0d01298:	4478      	add	r0, pc
c0d0129a:	4631      	mov	r1, r6
c0d0129c:	f7fe ff0e 	bl	c0d000bc <semihosted_printf>
            strncpy(msg->title, "Liquidity Pool:", msg->titleLength);
c0d012a0:	6920      	ldr	r0, [r4, #16]
c0d012a2:	6962      	ldr	r2, [r4, #20]
c0d012a4:	4940      	ldr	r1, [pc, #256]	; (c0d013a8 <handle_query_contract_ui+0x3f4>)
c0d012a6:	4479      	add	r1, pc
c0d012a8:	f003 fcfb 	bl	c0d04ca2 <strncpy>
            snprintf(msg->msg,
c0d012ac:	69a0      	ldr	r0, [r4, #24]
                     msg->msgLength,
c0d012ae:	69e1      	ldr	r1, [r4, #28]
            snprintf(msg->msg,
c0d012b0:	9600      	str	r6, [sp, #0]
                     context->ticker_token_a,
c0d012b2:	3568      	adds	r5, #104	; 0x68
            snprintf(msg->msg,
c0d012b4:	4a3d      	ldr	r2, [pc, #244]	; (c0d013ac <handle_query_contract_ui+0x3f8>)
c0d012b6:	447a      	add	r2, pc
c0d012b8:	462b      	mov	r3, r5
c0d012ba:	f000 f8f5 	bl	c0d014a8 <snprintf>
            break;
    }
c0d012be:	b009      	add	sp, #36	; 0x24
c0d012c0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d012c2:	07b0      	lsls	r0, r6, #30
c0d012c4:	d01d      	beq.n	c0d01302 <handle_query_contract_ui+0x34e>
c0d012c6:	4931      	ldr	r1, [pc, #196]	; (c0d0138c <handle_query_contract_ui+0x3d8>)
c0d012c8:	4479      	add	r1, pc
c0d012ca:	e7a0      	b.n	c0d0120e <handle_query_contract_ui+0x25a>
c0d012cc:	4b27      	ldr	r3, [pc, #156]	; (c0d0136c <handle_query_contract_ui+0x3b8>)
c0d012ce:	447b      	add	r3, pc
            switch (context->selectorIndex) {
c0d012d0:	2900      	cmp	r1, #0
c0d012d2:	d083      	beq.n	c0d011dc <handle_query_contract_ui+0x228>
c0d012d4:	2901      	cmp	r1, #1
c0d012d6:	d114      	bne.n	c0d01302 <handle_query_contract_ui+0x34e>
c0d012d8:	6920      	ldr	r0, [r4, #16]
c0d012da:	6962      	ldr	r2, [r4, #20]
c0d012dc:	4619      	mov	r1, r3
c0d012de:	f003 fce0 	bl	c0d04ca2 <strncpy>
c0d012e2:	e001      	b.n	c0d012e8 <handle_query_contract_ui+0x334>
c0d012e4:	2908      	cmp	r1, #8
c0d012e6:	d10c      	bne.n	c0d01302 <handle_query_contract_ui+0x34e>
    amountToString((uint8_t *) msg->pluginSharedRO->txContent->value.value,
c0d012e8:	6860      	ldr	r0, [r4, #4]
c0d012ea:	6800      	ldr	r0, [r0, #0]
c0d012ec:	2162      	movs	r1, #98	; 0x62
                   msg->pluginSharedRO->txContent->value.length,
c0d012ee:	5c41      	ldrb	r1, [r0, r1]
                   msg->msg,
c0d012f0:	69a2      	ldr	r2, [r4, #24]
                   msg->msgLength);
c0d012f2:	7f23      	ldrb	r3, [r4, #28]
    amountToString((uint8_t *) msg->pluginSharedRO->txContent->value.value,
c0d012f4:	9200      	str	r2, [sp, #0]
c0d012f6:	9301      	str	r3, [sp, #4]
c0d012f8:	3042      	adds	r0, #66	; 0x42
c0d012fa:	2212      	movs	r2, #18
c0d012fc:	4b1e      	ldr	r3, [pc, #120]	; (c0d01378 <handle_query_contract_ui+0x3c4>)
c0d012fe:	447b      	add	r3, pc
c0d01300:	e793      	b.n	c0d0122a <handle_query_contract_ui+0x276>
c0d01302:	481b      	ldr	r0, [pc, #108]	; (c0d01370 <handle_query_contract_ui+0x3bc>)
c0d01304:	4478      	add	r0, pc
c0d01306:	f7fe fed9 	bl	c0d000bc <semihosted_printf>
c0d0130a:	2000      	movs	r0, #0
c0d0130c:	7028      	strb	r0, [r5, #0]
c0d0130e:	e7d6      	b.n	c0d012be <handle_query_contract_ui+0x30a>
c0d01310:	0001f700 	.word	0x0001f700
c0d01314:	0000436f 	.word	0x0000436f
c0d01318:	0000442a 	.word	0x0000442a
c0d0131c:	00004428 	.word	0x00004428
c0d01320:	00004340 	.word	0x00004340
c0d01324:	00004431 	.word	0x00004431
c0d01328:	0000442f 	.word	0x0000442f
c0d0132c:	0000438d 	.word	0x0000438d
c0d01330:	0000446d 	.word	0x0000446d
c0d01334:	0000446b 	.word	0x0000446b
c0d01338:	00004358 	.word	0x00004358
c0d0133c:	00004449 	.word	0x00004449
c0d01340:	00004447 	.word	0x00004447
c0d01344:	000042c2 	.word	0x000042c2
c0d01348:	000041e4 	.word	0x000041e4
c0d0134c:	000041e4 	.word	0x000041e4
c0d01350:	0000423a 	.word	0x0000423a
c0d01354:	000041e4 	.word	0x000041e4
c0d01358:	000041e8 	.word	0x000041e8
c0d0135c:	0000432e 	.word	0x0000432e
c0d01360:	00004354 	.word	0x00004354
c0d01364:	0000434a 	.word	0x0000434a
c0d01368:	00004272 	.word	0x00004272
c0d0136c:	000041da 	.word	0x000041da
c0d01370:	000041b5 	.word	0x000041b5
c0d01374:	0000424a 	.word	0x0000424a
c0d01378:	00004064 	.word	0x00004064
c0d0137c:	000042aa 	.word	0x000042aa
c0d01380:	0000432d 	.word	0x0000432d
c0d01384:	000042d5 	.word	0x000042d5
c0d01388:	000042bd 	.word	0x000042bd
c0d0138c:	000041e0 	.word	0x000041e0
c0d01390:	00004278 	.word	0x00004278
c0d01394:	00004349 	.word	0x00004349
c0d01398:	00003fb9 	.word	0x00003fb9
c0d0139c:	0000438a 	.word	0x0000438a
c0d013a0:	00004279 	.word	0x00004279
c0d013a4:	000041e0 	.word	0x000041e0
c0d013a8:	000041b6 	.word	0x000041b6
c0d013ac:	000041b6 	.word	0x000041b6

c0d013b0 <dispatch_plugin_calls>:
void dispatch_plugin_calls(int message, void *parameters) {
c0d013b0:	b5b0      	push	{r4, r5, r7, lr}
c0d013b2:	460c      	mov	r4, r1
c0d013b4:	4605      	mov	r5, r0
    PRINTF("just in: message: %d\n", message);
c0d013b6:	482a      	ldr	r0, [pc, #168]	; (c0d01460 <dispatch_plugin_calls+0xb0>)
c0d013b8:	4478      	add	r0, pc
c0d013ba:	4629      	mov	r1, r5
c0d013bc:	f7fe fe7e 	bl	c0d000bc <semihosted_printf>
c0d013c0:	20ff      	movs	r0, #255	; 0xff
c0d013c2:	4601      	mov	r1, r0
c0d013c4:	3104      	adds	r1, #4
    switch (message) {
c0d013c6:	428d      	cmp	r5, r1
c0d013c8:	dc10      	bgt.n	c0d013ec <dispatch_plugin_calls+0x3c>
c0d013ca:	3002      	adds	r0, #2
c0d013cc:	4285      	cmp	r5, r0
c0d013ce:	d020      	beq.n	c0d01412 <dispatch_plugin_calls+0x62>
c0d013d0:	2081      	movs	r0, #129	; 0x81
c0d013d2:	0040      	lsls	r0, r0, #1
c0d013d4:	4285      	cmp	r5, r0
c0d013d6:	d024      	beq.n	c0d01422 <dispatch_plugin_calls+0x72>
c0d013d8:	428d      	cmp	r5, r1
c0d013da:	d13a      	bne.n	c0d01452 <dispatch_plugin_calls+0xa2>
            PRINTF("FINALIZE\n");
c0d013dc:	4821      	ldr	r0, [pc, #132]	; (c0d01464 <dispatch_plugin_calls+0xb4>)
c0d013de:	4478      	add	r0, pc
c0d013e0:	f7fe fe6c 	bl	c0d000bc <semihosted_printf>
            handle_finalize(parameters);
c0d013e4:	4620      	mov	r0, r4
c0d013e6:	f7ff f8b3 	bl	c0d00550 <handle_finalize>
}
c0d013ea:	bdb0      	pop	{r4, r5, r7, pc}
c0d013ec:	2141      	movs	r1, #65	; 0x41
c0d013ee:	0089      	lsls	r1, r1, #2
    switch (message) {
c0d013f0:	428d      	cmp	r5, r1
c0d013f2:	d01e      	beq.n	c0d01432 <dispatch_plugin_calls+0x82>
c0d013f4:	3006      	adds	r0, #6
c0d013f6:	4285      	cmp	r5, r0
c0d013f8:	d023      	beq.n	c0d01442 <dispatch_plugin_calls+0x92>
c0d013fa:	2083      	movs	r0, #131	; 0x83
c0d013fc:	0040      	lsls	r0, r0, #1
c0d013fe:	4285      	cmp	r5, r0
c0d01400:	d127      	bne.n	c0d01452 <dispatch_plugin_calls+0xa2>
            PRINTF("QUERY CONTRACT UI\n");
c0d01402:	4819      	ldr	r0, [pc, #100]	; (c0d01468 <dispatch_plugin_calls+0xb8>)
c0d01404:	4478      	add	r0, pc
c0d01406:	f7fe fe59 	bl	c0d000bc <semihosted_printf>
            handle_query_contract_ui(parameters);
c0d0140a:	4620      	mov	r0, r4
c0d0140c:	f7ff fdd2 	bl	c0d00fb4 <handle_query_contract_ui>
}
c0d01410:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("INIT CONTRACT\n");
c0d01412:	4816      	ldr	r0, [pc, #88]	; (c0d0146c <dispatch_plugin_calls+0xbc>)
c0d01414:	4478      	add	r0, pc
c0d01416:	f7fe fe51 	bl	c0d000bc <semihosted_printf>
            handle_init_contract(parameters);
c0d0141a:	4620      	mov	r0, r4
c0d0141c:	f7ff f8d0 	bl	c0d005c0 <handle_init_contract>
}
c0d01420:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("PROVIDE PARAMETER\n");
c0d01422:	4813      	ldr	r0, [pc, #76]	; (c0d01470 <dispatch_plugin_calls+0xc0>)
c0d01424:	4478      	add	r0, pc
c0d01426:	f7fe fe49 	bl	c0d000bc <semihosted_printf>
            handle_provide_parameter(parameters);
c0d0142a:	4620      	mov	r0, r4
c0d0142c:	f7ff f93a 	bl	c0d006a4 <handle_provide_parameter>
}
c0d01430:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("PROVIDE TOKEN\n");
c0d01432:	4810      	ldr	r0, [pc, #64]	; (c0d01474 <dispatch_plugin_calls+0xc4>)
c0d01434:	4478      	add	r0, pc
c0d01436:	f7fe fe41 	bl	c0d000bc <semihosted_printf>
            handle_provide_token(parameters);
c0d0143a:	4620      	mov	r0, r4
c0d0143c:	f7ff fd1a 	bl	c0d00e74 <handle_provide_token>
}
c0d01440:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("QUERY CONTRACT ID\n");
c0d01442:	480d      	ldr	r0, [pc, #52]	; (c0d01478 <dispatch_plugin_calls+0xc8>)
c0d01444:	4478      	add	r0, pc
c0d01446:	f7fe fe39 	bl	c0d000bc <semihosted_printf>
            handle_query_contract_id(parameters);
c0d0144a:	4620      	mov	r0, r4
c0d0144c:	f7ff fd7e 	bl	c0d00f4c <handle_query_contract_id>
}
c0d01450:	bdb0      	pop	{r4, r5, r7, pc}
            PRINTF("Unhandled message %d\n", message);
c0d01452:	480a      	ldr	r0, [pc, #40]	; (c0d0147c <dispatch_plugin_calls+0xcc>)
c0d01454:	4478      	add	r0, pc
c0d01456:	4629      	mov	r1, r5
c0d01458:	f7fe fe30 	bl	c0d000bc <semihosted_printf>
}
c0d0145c:	bdb0      	pop	{r4, r5, r7, pc}
c0d0145e:	46c0      	nop			; (mov r8, r8)
c0d01460:	0000420c 	.word	0x0000420c
c0d01464:	0000421e 	.word	0x0000421e
c0d01468:	00004224 	.word	0x00004224
c0d0146c:	000041c6 	.word	0x000041c6
c0d01470:	000041c5 	.word	0x000041c5
c0d01474:	000041d2 	.word	0x000041d2
c0d01478:	000041d1 	.word	0x000041d1
c0d0147c:	000041e7 	.word	0x000041e7

c0d01480 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d01480:	b580      	push	{r7, lr}
c0d01482:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d01484:	f001 fa9a 	bl	c0d029bc <try_context_set>
#endif // HAVE_BOLOS
}
c0d01488:	bd80      	pop	{r7, pc}
	...

c0d0148c <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d0148c:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
c0d0148e:	4672      	mov	r2, lr
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
c0d01490:	4804      	ldr	r0, [pc, #16]	; (c0d014a4 <os_longjmp+0x18>)
c0d01492:	4478      	add	r0, pc
c0d01494:	4621      	mov	r1, r4
c0d01496:	f7fe fe11 	bl	c0d000bc <semihosted_printf>
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d0149a:	f001 fa83 	bl	c0d029a4 <try_context_get>
c0d0149e:	4621      	mov	r1, r4
c0d014a0:	f003 fbea 	bl	c0d04c78 <longjmp>
c0d014a4:	000041c8 	.word	0x000041c8

c0d014a8 <snprintf>:
#endif // HAVE_PRINTF

#ifdef HAVE_SPRINTF
//unsigned int snprintf(unsigned char * str, unsigned int str_size, const char* format, ...)
int snprintf(char * str, size_t str_size, const char * format, ...)
 {
c0d014a8:	b081      	sub	sp, #4
c0d014aa:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d014ac:	b08e      	sub	sp, #56	; 0x38
c0d014ae:	9313      	str	r3, [sp, #76]	; 0x4c
    char cStrlenSet;
    
    //
    // Check the arguments.
    //
    if(str == NULL ||str_size < 2) {
c0d014b0:	2800      	cmp	r0, #0
c0d014b2:	d100      	bne.n	c0d014b6 <snprintf+0xe>
c0d014b4:	e1e4      	b.n	c0d01880 <snprintf+0x3d8>
c0d014b6:	460d      	mov	r5, r1
c0d014b8:	2902      	cmp	r1, #2
c0d014ba:	d200      	bcs.n	c0d014be <snprintf+0x16>
c0d014bc:	e1e0      	b.n	c0d01880 <snprintf+0x3d8>
c0d014be:	4614      	mov	r4, r2
c0d014c0:	4606      	mov	r6, r0
      return 0;
    }

    // ensure terminating string with a \0
    memset(str, 0, str_size);
c0d014c2:	4629      	mov	r1, r5
c0d014c4:	f003 fb86 	bl	c0d04bd4 <__aeabi_memclr>
c0d014c8:	a813      	add	r0, sp, #76	; 0x4c


    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d014ca:	9009      	str	r0, [sp, #36]	; 0x24

    //
    // Loop while there are more characters in the string.
    //
    while(*format)
c0d014cc:	7821      	ldrb	r1, [r4, #0]
c0d014ce:	2900      	cmp	r1, #0
c0d014d0:	d100      	bne.n	c0d014d4 <snprintf+0x2c>
c0d014d2:	e1d5      	b.n	c0d01880 <snprintf+0x3d8>
c0d014d4:	4630      	mov	r0, r6
    str_size--;
c0d014d6:	1e6a      	subs	r2, r5, #1
c0d014d8:	4616      	mov	r6, r2
c0d014da:	4605      	mov	r5, r0
c0d014dc:	2700      	movs	r7, #0
    {
        //
        // Find the first non-% character, or the end of the string.
        //
        for(ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0');
c0d014de:	b2c8      	uxtb	r0, r1
c0d014e0:	2800      	cmp	r0, #0
c0d014e2:	d005      	beq.n	c0d014f0 <snprintf+0x48>
c0d014e4:	2825      	cmp	r0, #37	; 0x25
c0d014e6:	d003      	beq.n	c0d014f0 <snprintf+0x48>
c0d014e8:	19e0      	adds	r0, r4, r7
c0d014ea:	7841      	ldrb	r1, [r0, #1]
            ulIdx++)
c0d014ec:	1c7f      	adds	r7, r7, #1
c0d014ee:	e7f6      	b.n	c0d014de <snprintf+0x36>
        }

        //
        // Write this portion of the string.
        //
        ulIdx = MIN(ulIdx, str_size);
c0d014f0:	42b7      	cmp	r7, r6
c0d014f2:	463a      	mov	r2, r7
c0d014f4:	d300      	bcc.n	c0d014f8 <snprintf+0x50>
c0d014f6:	4632      	mov	r2, r6
        memmove(str, format, ulIdx);
c0d014f8:	9208      	str	r2, [sp, #32]
c0d014fa:	4628      	mov	r0, r5
c0d014fc:	4621      	mov	r1, r4
c0d014fe:	f003 fb72 	bl	c0d04be6 <__aeabi_memmove>
c0d01502:	9b08      	ldr	r3, [sp, #32]
        str+= ulIdx;
        str_size -= ulIdx;
c0d01504:	1af2      	subs	r2, r6, r3
c0d01506:	d100      	bne.n	c0d0150a <snprintf+0x62>
c0d01508:	e1ba      	b.n	c0d01880 <snprintf+0x3d8>
c0d0150a:	18e8      	adds	r0, r5, r3
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if(*format == '%')
c0d0150c:	5ce1      	ldrb	r1, [r4, r3]
        format += ulIdx;
c0d0150e:	18e4      	adds	r4, r4, r3
        if(*format == '%')
c0d01510:	2925      	cmp	r1, #37	; 0x25
c0d01512:	d000      	beq.n	c0d01516 <snprintf+0x6e>
c0d01514:	e1ab      	b.n	c0d0186e <snprintf+0x3c6>
c0d01516:	9204      	str	r2, [sp, #16]
c0d01518:	9001      	str	r0, [sp, #4]
        {
            //
            // Skip the %.
            //
            format++;
c0d0151a:	1c63      	adds	r3, r4, #1
c0d0151c:	2200      	movs	r2, #0
c0d0151e:	2020      	movs	r0, #32
c0d01520:	9006      	str	r0, [sp, #24]
c0d01522:	200a      	movs	r0, #10
c0d01524:	9000      	str	r0, [sp, #0]
c0d01526:	9203      	str	r2, [sp, #12]
c0d01528:	9202      	str	r2, [sp, #8]
c0d0152a:	9207      	str	r2, [sp, #28]
c0d0152c:	9505      	str	r5, [sp, #20]
c0d0152e:	461c      	mov	r4, r3
c0d01530:	4610      	mov	r0, r2
again:

            //
            // Determine how to handle the next character.
            //
            switch(*format++)
c0d01532:	7821      	ldrb	r1, [r4, #0]
c0d01534:	1c64      	adds	r4, r4, #1
c0d01536:	2200      	movs	r2, #0
c0d01538:	292d      	cmp	r1, #45	; 0x2d
c0d0153a:	d0f9      	beq.n	c0d01530 <snprintf+0x88>
c0d0153c:	2947      	cmp	r1, #71	; 0x47
c0d0153e:	dc1b      	bgt.n	c0d01578 <snprintf+0xd0>
c0d01540:	292f      	cmp	r1, #47	; 0x2f
c0d01542:	dd2c      	ble.n	c0d0159e <snprintf+0xf6>
c0d01544:	460a      	mov	r2, r1
c0d01546:	3a30      	subs	r2, #48	; 0x30
c0d01548:	2a0a      	cmp	r2, #10
c0d0154a:	d300      	bcc.n	c0d0154e <snprintf+0xa6>
c0d0154c:	e156      	b.n	c0d017fc <snprintf+0x354>
                {
                    //
                    // If this is a zero, and it is the first digit, then the
                    // fill character is a zero instead of a space.
                    //
                    if((format[-1] == '0') && (ulCount == 0))
c0d0154e:	2930      	cmp	r1, #48	; 0x30
c0d01550:	9a06      	ldr	r2, [sp, #24]
c0d01552:	d100      	bne.n	c0d01556 <snprintf+0xae>
c0d01554:	460a      	mov	r2, r1
c0d01556:	4635      	mov	r5, r6
c0d01558:	9b07      	ldr	r3, [sp, #28]
c0d0155a:	2b00      	cmp	r3, #0
c0d0155c:	d000      	beq.n	c0d01560 <snprintf+0xb8>
c0d0155e:	9a06      	ldr	r2, [sp, #24]
c0d01560:	230a      	movs	r3, #10
                    }

                    //
                    // Update the digit count.
                    //
                    ulCount *= 10;
c0d01562:	9e07      	ldr	r6, [sp, #28]
c0d01564:	4373      	muls	r3, r6
                    ulCount += format[-1] - '0';
c0d01566:	1859      	adds	r1, r3, r1
c0d01568:	3930      	subs	r1, #48	; 0x30
c0d0156a:	9107      	str	r1, [sp, #28]
c0d0156c:	4623      	mov	r3, r4
c0d0156e:	9206      	str	r2, [sp, #24]
c0d01570:	4602      	mov	r2, r0
c0d01572:	462e      	mov	r6, r5
c0d01574:	9d05      	ldr	r5, [sp, #20]
c0d01576:	e7da      	b.n	c0d0152e <snprintf+0x86>
            switch(*format++)
c0d01578:	2967      	cmp	r1, #103	; 0x67
c0d0157a:	9a04      	ldr	r2, [sp, #16]
c0d0157c:	dc07      	bgt.n	c0d0158e <snprintf+0xe6>
c0d0157e:	2962      	cmp	r1, #98	; 0x62
c0d01580:	dc3f      	bgt.n	c0d01602 <snprintf+0x15a>
c0d01582:	2948      	cmp	r1, #72	; 0x48
c0d01584:	d000      	beq.n	c0d01588 <snprintf+0xe0>
c0d01586:	e0a0      	b.n	c0d016ca <snprintf+0x222>
c0d01588:	2101      	movs	r1, #1
c0d0158a:	9102      	str	r1, [sp, #8]
c0d0158c:	e004      	b.n	c0d01598 <snprintf+0xf0>
c0d0158e:	2972      	cmp	r1, #114	; 0x72
c0d01590:	dc1c      	bgt.n	c0d015cc <snprintf+0x124>
c0d01592:	2968      	cmp	r1, #104	; 0x68
c0d01594:	d000      	beq.n	c0d01598 <snprintf+0xf0>
c0d01596:	e09d      	b.n	c0d016d4 <snprintf+0x22c>
c0d01598:	2110      	movs	r1, #16
c0d0159a:	9100      	str	r1, [sp, #0]
c0d0159c:	e019      	b.n	c0d015d2 <snprintf+0x12a>
c0d0159e:	2925      	cmp	r1, #37	; 0x25
c0d015a0:	d100      	bne.n	c0d015a4 <snprintf+0xfc>
c0d015a2:	e118      	b.n	c0d017d6 <snprintf+0x32e>
c0d015a4:	292a      	cmp	r1, #42	; 0x2a
c0d015a6:	9a04      	ldr	r2, [sp, #16]
c0d015a8:	d01f      	beq.n	c0d015ea <snprintf+0x142>
c0d015aa:	292e      	cmp	r1, #46	; 0x2e
c0d015ac:	d000      	beq.n	c0d015b0 <snprintf+0x108>
c0d015ae:	e093      	b.n	c0d016d8 <snprintf+0x230>
                // special %.*H or %.*h format to print a given length of hex digits (case: H UPPER, h lower)
                //
                case '.':
                {
                  // ensure next char is '*' and next one is 's'/'h'/'H'
                  if (format[0] == '*' && (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d015b0:	7821      	ldrb	r1, [r4, #0]
c0d015b2:	292a      	cmp	r1, #42	; 0x2a
c0d015b4:	d000      	beq.n	c0d015b8 <snprintf+0x110>
c0d015b6:	e15d      	b.n	c0d01874 <snprintf+0x3cc>
c0d015b8:	7860      	ldrb	r0, [r4, #1]
c0d015ba:	1c63      	adds	r3, r4, #1
c0d015bc:	2201      	movs	r2, #1
c0d015be:	2848      	cmp	r0, #72	; 0x48
c0d015c0:	d019      	beq.n	c0d015f6 <snprintf+0x14e>
c0d015c2:	2868      	cmp	r0, #104	; 0x68
c0d015c4:	d017      	beq.n	c0d015f6 <snprintf+0x14e>
c0d015c6:	2873      	cmp	r0, #115	; 0x73
c0d015c8:	d015      	beq.n	c0d015f6 <snprintf+0x14e>
c0d015ca:	e155      	b.n	c0d01878 <snprintf+0x3d0>
            switch(*format++)
c0d015cc:	2973      	cmp	r1, #115	; 0x73
c0d015ce:	d000      	beq.n	c0d015d2 <snprintf+0x12a>
c0d015d0:	e084      	b.n	c0d016dc <snprintf+0x234>
                case_s:
                {
                    //
                    // Get the string pointer from the varargs.
                    //
                    pcStr = va_arg(vaArgP, char *);
c0d015d2:	9909      	ldr	r1, [sp, #36]	; 0x24
c0d015d4:	1d0a      	adds	r2, r1, #4
c0d015d6:	9209      	str	r2, [sp, #36]	; 0x24

                    //
                    // Determine the length of the string. (if not specified using .*)
                    //
                    switch(cStrlenSet) {
c0d015d8:	b2c2      	uxtb	r2, r0
                    pcStr = va_arg(vaArgP, char *);
c0d015da:	6809      	ldr	r1, [r1, #0]
                    switch(cStrlenSet) {
c0d015dc:	2a01      	cmp	r2, #1
c0d015de:	dd20      	ble.n	c0d01622 <snprintf+0x17a>
c0d015e0:	2a02      	cmp	r2, #2
c0d015e2:	4623      	mov	r3, r4
c0d015e4:	4602      	mov	r2, r0
c0d015e6:	d1a2      	bne.n	c0d0152e <snprintf+0x86>
c0d015e8:	e105      	b.n	c0d017f6 <snprintf+0x34e>
                  if (*format == 's' ) {                    
c0d015ea:	7821      	ldrb	r1, [r4, #0]
c0d015ec:	2973      	cmp	r1, #115	; 0x73
c0d015ee:	d000      	beq.n	c0d015f2 <snprintf+0x14a>
c0d015f0:	e140      	b.n	c0d01874 <snprintf+0x3cc>
c0d015f2:	2202      	movs	r2, #2
c0d015f4:	4623      	mov	r3, r4
c0d015f6:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d015f8:	1d01      	adds	r1, r0, #4
c0d015fa:	9109      	str	r1, [sp, #36]	; 0x24
c0d015fc:	6800      	ldr	r0, [r0, #0]
            switch(*format++)
c0d015fe:	9003      	str	r0, [sp, #12]
c0d01600:	e795      	b.n	c0d0152e <snprintf+0x86>
c0d01602:	2963      	cmp	r1, #99	; 0x63
c0d01604:	d100      	bne.n	c0d01608 <snprintf+0x160>
c0d01606:	e0eb      	b.n	c0d017e0 <snprintf+0x338>
c0d01608:	2964      	cmp	r1, #100	; 0x64
c0d0160a:	d165      	bne.n	c0d016d8 <snprintf+0x230>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d0160c:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d0160e:	1d01      	adds	r1, r0, #4
c0d01610:	9109      	str	r1, [sp, #36]	; 0x24
c0d01612:	6800      	ldr	r0, [r0, #0]
                    if((long)ulValue < 0)
c0d01614:	17c1      	asrs	r1, r0, #31
c0d01616:	1842      	adds	r2, r0, r1
c0d01618:	404a      	eors	r2, r1
c0d0161a:	0fc0      	lsrs	r0, r0, #31
c0d0161c:	9005      	str	r0, [sp, #20]
c0d0161e:	260a      	movs	r6, #10
c0d01620:	e065      	b.n	c0d016ee <snprintf+0x246>
                    switch(cStrlenSet) {
c0d01622:	2a00      	cmp	r2, #0
c0d01624:	9b03      	ldr	r3, [sp, #12]
c0d01626:	d105      	bne.n	c0d01634 <snprintf+0x18c>
c0d01628:	2000      	movs	r0, #0
                      // compute length with strlen
                      case 0:
                        for(ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++)
c0d0162a:	5c0a      	ldrb	r2, [r1, r0]
c0d0162c:	1c40      	adds	r0, r0, #1
c0d0162e:	2a00      	cmp	r2, #0
c0d01630:	d1fb      	bne.n	c0d0162a <snprintf+0x182>
                    }

                    //
                    // Write the string.
                    //
                    switch(ulBase) {
c0d01632:	1e43      	subs	r3, r0, #1
c0d01634:	9800      	ldr	r0, [sp, #0]
c0d01636:	2810      	cmp	r0, #16
c0d01638:	d000      	beq.n	c0d0163c <snprintf+0x194>
c0d0163a:	e0e2      	b.n	c0d01802 <snprintf+0x35a>
c0d0163c:	9303      	str	r3, [sp, #12]
                            return 0;
                        }
                        break;
                      case 16: {
                        unsigned char nibble1, nibble2;
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d0163e:	2b00      	cmp	r3, #0
c0d01640:	9801      	ldr	r0, [sp, #4]
c0d01642:	9a04      	ldr	r2, [sp, #16]
c0d01644:	d100      	bne.n	c0d01648 <snprintf+0x1a0>
c0d01646:	e111      	b.n	c0d0186c <snprintf+0x3c4>
c0d01648:	42be      	cmp	r6, r7
c0d0164a:	4630      	mov	r0, r6
c0d0164c:	d300      	bcc.n	c0d01650 <snprintf+0x1a8>
c0d0164e:	4638      	mov	r0, r7
c0d01650:	1c82      	adds	r2, r0, #2
c0d01652:	9206      	str	r2, [sp, #24]
c0d01654:	9001      	str	r0, [sp, #4]
c0d01656:	4240      	negs	r0, r0
c0d01658:	9007      	str	r0, [sp, #28]
c0d0165a:	2000      	movs	r0, #0
c0d0165c:	43c0      	mvns	r0, r0
c0d0165e:	9000      	str	r0, [sp, #0]
c0d01660:	4632      	mov	r2, r6
c0d01662:	9604      	str	r6, [sp, #16]
                          nibble1 = (pcStr[ulCount]>>4)&0xF;
c0d01664:	9807      	ldr	r0, [sp, #28]
c0d01666:	1880      	adds	r0, r0, r2
                          nibble2 = pcStr[ulCount]&0xF;
                          if (str_size < 2) {
c0d01668:	2802      	cmp	r0, #2
c0d0166a:	d200      	bcs.n	c0d0166e <snprintf+0x1c6>
c0d0166c:	e108      	b.n	c0d01880 <snprintf+0x3d8>
c0d0166e:	9505      	str	r5, [sp, #20]
c0d01670:	780d      	ldrb	r5, [r1, #0]
c0d01672:	9802      	ldr	r0, [sp, #8]
                              va_end(vaArgP);
                              return 0;
                          }
                          switch(ulCap) {
c0d01674:	2800      	cmp	r0, #0
c0d01676:	d004      	beq.n	c0d01682 <snprintf+0x1da>
c0d01678:	2801      	cmp	r0, #1
c0d0167a:	d111      	bne.n	c0d016a0 <snprintf+0x1f8>
c0d0167c:	4884      	ldr	r0, [pc, #528]	; (c0d01890 <snprintf+0x3e8>)
c0d0167e:	4478      	add	r0, pc
c0d01680:	e001      	b.n	c0d01686 <snprintf+0x1de>
c0d01682:	4882      	ldr	r0, [pc, #520]	; (c0d0188c <snprintf+0x3e4>)
c0d01684:	4478      	add	r0, pc
c0d01686:	9008      	str	r0, [sp, #32]
c0d01688:	230f      	movs	r3, #15
c0d0168a:	402b      	ands	r3, r5
c0d0168c:	092d      	lsrs	r5, r5, #4
c0d0168e:	5d45      	ldrb	r5, [r0, r5]
c0d01690:	9e05      	ldr	r6, [sp, #20]
c0d01692:	9801      	ldr	r0, [sp, #4]
c0d01694:	5435      	strb	r5, [r6, r0]
c0d01696:	1835      	adds	r5, r6, r0
c0d01698:	9808      	ldr	r0, [sp, #32]
c0d0169a:	5cc0      	ldrb	r0, [r0, r3]
c0d0169c:	7068      	strb	r0, [r5, #1]
c0d0169e:	9e04      	ldr	r6, [sp, #16]
                                str[1] = g_pcHex_cap[nibble2];
                              break;
                          }
                          str+= 2;
                          str_size -= 2;
                          if (str_size == 0) {
c0d016a0:	9806      	ldr	r0, [sp, #24]
c0d016a2:	4290      	cmp	r0, r2
c0d016a4:	9d05      	ldr	r5, [sp, #20]
c0d016a6:	d100      	bne.n	c0d016aa <snprintf+0x202>
c0d016a8:	e0ea      	b.n	c0d01880 <snprintf+0x3d8>
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d016aa:	1c49      	adds	r1, r1, #1
c0d016ac:	9803      	ldr	r0, [sp, #12]
c0d016ae:	1e40      	subs	r0, r0, #1
c0d016b0:	1e92      	subs	r2, r2, #2
c0d016b2:	1cad      	adds	r5, r5, #2
c0d016b4:	9003      	str	r0, [sp, #12]
c0d016b6:	2800      	cmp	r0, #0
c0d016b8:	d1d4      	bne.n	c0d01664 <snprintf+0x1bc>
    while(*format)
c0d016ba:	42be      	cmp	r6, r7
c0d016bc:	d300      	bcc.n	c0d016c0 <snprintf+0x218>
c0d016be:	463e      	mov	r6, r7
c0d016c0:	19a8      	adds	r0, r5, r6
c0d016c2:	9900      	ldr	r1, [sp, #0]
c0d016c4:	4371      	muls	r1, r6
c0d016c6:	188a      	adds	r2, r1, r2
c0d016c8:	e0d0      	b.n	c0d0186c <snprintf+0x3c4>
            switch(*format++)
c0d016ca:	2958      	cmp	r1, #88	; 0x58
c0d016cc:	d104      	bne.n	c0d016d8 <snprintf+0x230>
c0d016ce:	2001      	movs	r0, #1
c0d016d0:	9002      	str	r0, [sp, #8]
c0d016d2:	e005      	b.n	c0d016e0 <snprintf+0x238>
c0d016d4:	2970      	cmp	r1, #112	; 0x70
c0d016d6:	d003      	beq.n	c0d016e0 <snprintf+0x238>
c0d016d8:	9801      	ldr	r0, [sp, #4]
c0d016da:	e0c7      	b.n	c0d0186c <snprintf+0x3c4>
c0d016dc:	2978      	cmp	r1, #120	; 0x78
c0d016de:	d1fb      	bne.n	c0d016d8 <snprintf+0x230>
                case 'p':
                {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d016e0:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d016e2:	1d01      	adds	r1, r0, #4
c0d016e4:	9109      	str	r1, [sp, #36]	; 0x24
c0d016e6:	6802      	ldr	r2, [r0, #0]
c0d016e8:	2000      	movs	r0, #0
c0d016ea:	9005      	str	r0, [sp, #20]
c0d016ec:	2610      	movs	r6, #16
                    // Determine the number of digits in the string version of
                    // the value.
                    //
convert:
                    for(ulIdx = 1;
                        (((ulIdx * ulBase) <= ulValue) &&
c0d016ee:	4296      	cmp	r6, r2
c0d016f0:	9208      	str	r2, [sp, #32]
c0d016f2:	d901      	bls.n	c0d016f8 <snprintf+0x250>
c0d016f4:	2701      	movs	r7, #1
c0d016f6:	e012      	b.n	c0d0171e <snprintf+0x276>
c0d016f8:	2501      	movs	r5, #1
c0d016fa:	4630      	mov	r0, r6
c0d016fc:	4607      	mov	r7, r0
                         (((ulIdx * ulBase) / ulBase) == ulIdx));
c0d016fe:	4631      	mov	r1, r6
c0d01700:	f001 f96a 	bl	c0d029d8 <__udivsi3>
                    for(ulIdx = 1;
c0d01704:	42a8      	cmp	r0, r5
c0d01706:	d109      	bne.n	c0d0171c <snprintf+0x274>
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01708:	4630      	mov	r0, r6
c0d0170a:	4378      	muls	r0, r7
                        ulIdx *= ulBase, ulCount--)
c0d0170c:	9907      	ldr	r1, [sp, #28]
c0d0170e:	1e49      	subs	r1, r1, #1
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01710:	9107      	str	r1, [sp, #28]
c0d01712:	9908      	ldr	r1, [sp, #32]
c0d01714:	4288      	cmp	r0, r1
c0d01716:	463d      	mov	r5, r7
c0d01718:	d9f0      	bls.n	c0d016fc <snprintf+0x254>
c0d0171a:	e000      	b.n	c0d0171e <snprintf+0x276>
c0d0171c:	462f      	mov	r7, r5

                    //
                    // If the value is negative, reduce the count of padding
                    // characters needed.
                    //
                    if(ulNeg)
c0d0171e:	9807      	ldr	r0, [sp, #28]
c0d01720:	9a05      	ldr	r2, [sp, #20]
c0d01722:	1a81      	subs	r1, r0, r2
c0d01724:	2300      	movs	r3, #0

                    //
                    // If the value is negative and the value is padded with
                    // zeros, then place the minus sign before the padding.
                    //
                    if(ulNeg && (cFill == '0'))
c0d01726:	2a00      	cmp	r2, #0
c0d01728:	d008      	beq.n	c0d0173c <snprintf+0x294>
c0d0172a:	9806      	ldr	r0, [sp, #24]
c0d0172c:	b2c0      	uxtb	r0, r0
c0d0172e:	2830      	cmp	r0, #48	; 0x30
c0d01730:	d106      	bne.n	c0d01740 <snprintf+0x298>
c0d01732:	a80a      	add	r0, sp, #40	; 0x28
c0d01734:	222d      	movs	r2, #45	; 0x2d
                    {
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d01736:	7002      	strb	r2, [r0, #0]
c0d01738:	2501      	movs	r5, #1
c0d0173a:	e003      	b.n	c0d01744 <snprintf+0x29c>
c0d0173c:	461d      	mov	r5, r3
c0d0173e:	e001      	b.n	c0d01744 <snprintf+0x29c>
c0d01740:	461d      	mov	r5, r3
c0d01742:	9b05      	ldr	r3, [sp, #20]

                    //
                    // Provide additional padding at the beginning of the
                    // string conversion if needed.
                    //
                    if((ulCount > 1) && (ulCount < 16))
c0d01744:	1e88      	subs	r0, r1, #2
c0d01746:	280d      	cmp	r0, #13
c0d01748:	d811      	bhi.n	c0d0176e <snprintf+0x2c6>
c0d0174a:	a80a      	add	r0, sp, #40	; 0x28
                    {
                        for(ulCount--; ulCount; ulCount--)
c0d0174c:	1940      	adds	r0, r0, r5
c0d0174e:	1e49      	subs	r1, r1, #1
                        {
                            pcBuf[ulPos++] = cFill;
c0d01750:	9a06      	ldr	r2, [sp, #24]
c0d01752:	b2d2      	uxtb	r2, r2
c0d01754:	9306      	str	r3, [sp, #24]
c0d01756:	f003 fa4a 	bl	c0d04bee <__aeabi_memset>
c0d0175a:	9b06      	ldr	r3, [sp, #24]
                        for(ulCount--; ulCount; ulCount--)
c0d0175c:	9807      	ldr	r0, [sp, #28]
c0d0175e:	9905      	ldr	r1, [sp, #20]
c0d01760:	1a08      	subs	r0, r1, r0
c0d01762:	1c40      	adds	r0, r0, #1
c0d01764:	1c41      	adds	r1, r0, #1
                            pcBuf[ulPos++] = cFill;
c0d01766:	1c6d      	adds	r5, r5, #1
                        for(ulCount--; ulCount; ulCount--)
c0d01768:	4281      	cmp	r1, r0
c0d0176a:	4608      	mov	r0, r1
c0d0176c:	d2fa      	bcs.n	c0d01764 <snprintf+0x2bc>

                    //
                    // If the value is negative, then place the minus sign
                    // before the number.
                    //
                    if(ulNeg)
c0d0176e:	2b00      	cmp	r3, #0
c0d01770:	d003      	beq.n	c0d0177a <snprintf+0x2d2>
c0d01772:	a80a      	add	r0, sp, #40	; 0x28
c0d01774:	212d      	movs	r1, #45	; 0x2d
                    {
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d01776:	5541      	strb	r1, [r0, r5]
c0d01778:	1c6d      	adds	r5, r5, #1
c0d0177a:	9802      	ldr	r0, [sp, #8]
                    }

                    //
                    // Convert the value into a string.
                    //
                    for(; ulIdx; ulIdx /= ulBase)
c0d0177c:	2f00      	cmp	r7, #0
c0d0177e:	d01a      	beq.n	c0d017b6 <snprintf+0x30e>
c0d01780:	2800      	cmp	r0, #0
c0d01782:	d002      	beq.n	c0d0178a <snprintf+0x2e2>
c0d01784:	4844      	ldr	r0, [pc, #272]	; (c0d01898 <snprintf+0x3f0>)
c0d01786:	4478      	add	r0, pc
c0d01788:	e001      	b.n	c0d0178e <snprintf+0x2e6>
c0d0178a:	4842      	ldr	r0, [pc, #264]	; (c0d01894 <snprintf+0x3ec>)
c0d0178c:	4478      	add	r0, pc
c0d0178e:	9007      	str	r0, [sp, #28]
c0d01790:	9808      	ldr	r0, [sp, #32]
c0d01792:	4639      	mov	r1, r7
c0d01794:	f001 f920 	bl	c0d029d8 <__udivsi3>
c0d01798:	4631      	mov	r1, r6
c0d0179a:	f001 f9a3 	bl	c0d02ae4 <__aeabi_uidivmod>
c0d0179e:	9807      	ldr	r0, [sp, #28]
c0d017a0:	5c40      	ldrb	r0, [r0, r1]
c0d017a2:	a90a      	add	r1, sp, #40	; 0x28
                    {
                        if (!ulCap) {
                          pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d017a4:	5548      	strb	r0, [r1, r5]
                    for(; ulIdx; ulIdx /= ulBase)
c0d017a6:	4638      	mov	r0, r7
c0d017a8:	4631      	mov	r1, r6
c0d017aa:	f001 f915 	bl	c0d029d8 <__udivsi3>
c0d017ae:	1c6d      	adds	r5, r5, #1
c0d017b0:	42be      	cmp	r6, r7
c0d017b2:	4607      	mov	r7, r0
c0d017b4:	d9ec      	bls.n	c0d01790 <snprintf+0x2e8>
c0d017b6:	9804      	ldr	r0, [sp, #16]
                    }

                    //
                    // Write the string.
                    //
                    ulPos = MIN(ulPos, str_size);
c0d017b8:	4285      	cmp	r5, r0
c0d017ba:	d300      	bcc.n	c0d017be <snprintf+0x316>
c0d017bc:	4605      	mov	r5, r0
c0d017be:	a90a      	add	r1, sp, #40	; 0x28
c0d017c0:	9e01      	ldr	r6, [sp, #4]
                    memmove(str, pcBuf, ulPos);
c0d017c2:	4630      	mov	r0, r6
c0d017c4:	462a      	mov	r2, r5
c0d017c6:	f003 fa0e 	bl	c0d04be6 <__aeabi_memmove>
c0d017ca:	9a04      	ldr	r2, [sp, #16]
                    str+= ulPos;
                    str_size -= ulPos;
c0d017cc:	1b52      	subs	r2, r2, r5
                    if (str_size == 0) {
c0d017ce:	d057      	beq.n	c0d01880 <snprintf+0x3d8>
c0d017d0:	4630      	mov	r0, r6
c0d017d2:	1970      	adds	r0, r6, r5
c0d017d4:	e04a      	b.n	c0d0186c <snprintf+0x3c4>
c0d017d6:	2025      	movs	r0, #37	; 0x25
c0d017d8:	9901      	ldr	r1, [sp, #4]
                case '%':
                {
                    //
                    // Simply write a single %.
                    //
                    str[0] = '%';
c0d017da:	7008      	strb	r0, [r1, #0]
c0d017dc:	9a04      	ldr	r2, [sp, #16]
c0d017de:	e005      	b.n	c0d017ec <snprintf+0x344>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d017e0:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d017e2:	1d01      	adds	r1, r0, #4
c0d017e4:	9109      	str	r1, [sp, #36]	; 0x24
c0d017e6:	6800      	ldr	r0, [r0, #0]
c0d017e8:	9901      	ldr	r1, [sp, #4]
                    str[0] = ulValue;
c0d017ea:	7008      	strb	r0, [r1, #0]
c0d017ec:	1e52      	subs	r2, r2, #1
c0d017ee:	d047      	beq.n	c0d01880 <snprintf+0x3d8>
c0d017f0:	4608      	mov	r0, r1
c0d017f2:	1c48      	adds	r0, r1, #1
c0d017f4:	e03a      	b.n	c0d0186c <snprintf+0x3c4>
                        if (pcStr[0] == '\0') {
c0d017f6:	7808      	ldrb	r0, [r1, #0]
c0d017f8:	2800      	cmp	r0, #0
c0d017fa:	d014      	beq.n	c0d01826 <snprintf+0x37e>
c0d017fc:	9801      	ldr	r0, [sp, #4]
c0d017fe:	9a04      	ldr	r2, [sp, #16]
c0d01800:	e034      	b.n	c0d0186c <snprintf+0x3c4>
c0d01802:	9804      	ldr	r0, [sp, #16]
                        ulIdx = MIN(ulIdx, str_size);
c0d01804:	4283      	cmp	r3, r0
c0d01806:	461a      	mov	r2, r3
c0d01808:	d301      	bcc.n	c0d0180e <snprintf+0x366>
c0d0180a:	4602      	mov	r2, r0
c0d0180c:	4603      	mov	r3, r0
c0d0180e:	461e      	mov	r6, r3
                        memmove(str, pcStr, ulIdx);
c0d01810:	9801      	ldr	r0, [sp, #4]
c0d01812:	4615      	mov	r5, r2
c0d01814:	f003 f9e7 	bl	c0d04be6 <__aeabi_memmove>
c0d01818:	462b      	mov	r3, r5
c0d0181a:	9a04      	ldr	r2, [sp, #16]
c0d0181c:	9801      	ldr	r0, [sp, #4]
                        str_size -= ulIdx;
c0d0181e:	1b52      	subs	r2, r2, r5
c0d01820:	9907      	ldr	r1, [sp, #28]
c0d01822:	d112      	bne.n	c0d0184a <snprintf+0x3a2>
c0d01824:	e02c      	b.n	c0d01880 <snprintf+0x3d8>
c0d01826:	9804      	ldr	r0, [sp, #16]
c0d01828:	9d03      	ldr	r5, [sp, #12]
                          ulStrlen = MIN(ulStrlen, str_size);
c0d0182a:	4285      	cmp	r5, r0
c0d0182c:	d300      	bcc.n	c0d01830 <snprintf+0x388>
c0d0182e:	4605      	mov	r5, r0
c0d01830:	2220      	movs	r2, #32
c0d01832:	9e01      	ldr	r6, [sp, #4]
                          memset(str, ' ', ulStrlen);
c0d01834:	4630      	mov	r0, r6
c0d01836:	4629      	mov	r1, r5
c0d01838:	f003 f9d9 	bl	c0d04bee <__aeabi_memset>
c0d0183c:	9a04      	ldr	r2, [sp, #16]
c0d0183e:	4630      	mov	r0, r6
c0d01840:	462e      	mov	r6, r5
                          str_size -= ulStrlen;
c0d01842:	1b52      	subs	r2, r2, r5
c0d01844:	9907      	ldr	r1, [sp, #28]
c0d01846:	9b08      	ldr	r3, [sp, #32]
                          if (str_size == 0) {
c0d01848:	d01a      	beq.n	c0d01880 <snprintf+0x3d8>
c0d0184a:	1980      	adds	r0, r0, r6
                    if(ulCount > ulIdx)
c0d0184c:	4299      	cmp	r1, r3
c0d0184e:	d90d      	bls.n	c0d0186c <snprintf+0x3c4>
                        ulCount -= ulIdx;
c0d01850:	1acd      	subs	r5, r1, r3
                        ulCount = MIN(ulCount, str_size);
c0d01852:	4295      	cmp	r5, r2
c0d01854:	d300      	bcc.n	c0d01858 <snprintf+0x3b0>
c0d01856:	4615      	mov	r5, r2
c0d01858:	4617      	mov	r7, r2
c0d0185a:	2220      	movs	r2, #32
c0d0185c:	4606      	mov	r6, r0
                        memset(str, ' ', ulCount);
c0d0185e:	4629      	mov	r1, r5
c0d01860:	f003 f9c5 	bl	c0d04bee <__aeabi_memset>
c0d01864:	463a      	mov	r2, r7
                        str_size -= ulCount;
c0d01866:	1b7a      	subs	r2, r7, r5
c0d01868:	d1b2      	bne.n	c0d017d0 <snprintf+0x328>
c0d0186a:	e009      	b.n	c0d01880 <snprintf+0x3d8>
    while(*format)
c0d0186c:	7821      	ldrb	r1, [r4, #0]
c0d0186e:	2900      	cmp	r1, #0
c0d01870:	d006      	beq.n	c0d01880 <snprintf+0x3d8>
c0d01872:	e631      	b.n	c0d014d8 <snprintf+0x30>
c0d01874:	9801      	ldr	r0, [sp, #4]
c0d01876:	e7fa      	b.n	c0d0186e <snprintf+0x3c6>
c0d01878:	212a      	movs	r1, #42	; 0x2a
c0d0187a:	9801      	ldr	r0, [sp, #4]
c0d0187c:	9a04      	ldr	r2, [sp, #16]
c0d0187e:	e7f6      	b.n	c0d0186e <snprintf+0x3c6>
c0d01880:	2000      	movs	r0, #0
    // End the varargs processing.
    //
    va_end(vaArgP);

    return 0;
}
c0d01882:	b00e      	add	sp, #56	; 0x38
c0d01884:	bcf0      	pop	{r4, r5, r6, r7}
c0d01886:	bc02      	pop	{r1}
c0d01888:	b001      	add	sp, #4
c0d0188a:	4708      	bx	r1
c0d0188c:	000036f7 	.word	0x000036f7
c0d01890:	00003ff6 	.word	0x00003ff6
c0d01894:	000035ef 	.word	0x000035ef
c0d01898:	00003eee 	.word	0x00003eee

c0d0189c <pic>:
// only apply PIC conversion if link_address is in linked code (over 0xC0D00000 in our example)
// this way, PIC call are armless if the address is not meant to be converted
extern void _nvram;
extern void _envram;

void *pic(void *link_address) {
c0d0189c:	b580      	push	{r7, lr}
  if (link_address >= &_nvram && link_address < &_envram) {
c0d0189e:	4904      	ldr	r1, [pc, #16]	; (c0d018b0 <pic+0x14>)
c0d018a0:	4288      	cmp	r0, r1
c0d018a2:	d304      	bcc.n	c0d018ae <pic+0x12>
c0d018a4:	4903      	ldr	r1, [pc, #12]	; (c0d018b4 <pic+0x18>)
c0d018a6:	4288      	cmp	r0, r1
c0d018a8:	d201      	bcs.n	c0d018ae <pic+0x12>
    link_address = pic_internal(link_address);
c0d018aa:	f000 f805 	bl	c0d018b8 <pic_internal>
  }
  return link_address;
c0d018ae:	bd80      	pop	{r7, pc}
c0d018b0:	c0d00000 	.word	0xc0d00000
c0d018b4:	c0d05700 	.word	0xc0d05700

c0d018b8 <pic_internal>:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
__attribute__((naked)) void *pic_internal(void *link_address)
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");
c0d018b8:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");
c0d018ba:	4902      	ldr	r1, [pc, #8]	; (c0d018c4 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");
c0d018bc:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");
c0d018be:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");
c0d018c0:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0d018c2:	4770      	bx	lr
c0d018c4:	c0d018b9 	.word	0xc0d018b9

c0d018c8 <_vsnprintf>:
// internal vsnprintf
static int _vsnprintf(out_fct_type out,
                      char* buffer,
                      const size_t maxlen,
                      const char* format,
                      va_list va) {
c0d018c8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d018ca:	b097      	sub	sp, #92	; 0x5c
c0d018cc:	461d      	mov	r5, r3
    unsigned int flags, width, precision, n;
    size_t idx = 0U;

    if (!buffer) {
c0d018ce:	2900      	cmp	r1, #0
c0d018d0:	d101      	bne.n	c0d018d6 <_vsnprintf+0xe>
c0d018d2:	48f9      	ldr	r0, [pc, #996]	; (c0d01cb8 <_vsnprintf+0x3f0>)
c0d018d4:	4478      	add	r0, pc
c0d018d6:	ab14      	add	r3, sp, #80	; 0x50
c0d018d8:	c307      	stmia	r3!, {r0, r1, r2}
c0d018da:	2700      	movs	r7, #0
c0d018dc:	43f8      	mvns	r0, r7
c0d018de:	9011      	str	r0, [sp, #68]	; 0x44
c0d018e0:	981c      	ldr	r0, [sp, #112]	; 0x70
c0d018e2:	9013      	str	r0, [sp, #76]	; 0x4c
        // use null output function
        out = _out_null;
    }

    while (*format) {
c0d018e4:	1cae      	adds	r6, r5, #2
c0d018e6:	7828      	ldrb	r0, [r5, #0]
c0d018e8:	2800      	cmp	r0, #0
c0d018ea:	d100      	bne.n	c0d018ee <_vsnprintf+0x26>
c0d018ec:	e275      	b.n	c0d01dda <_vsnprintf+0x512>
c0d018ee:	2825      	cmp	r0, #37	; 0x25
c0d018f0:	d00c      	beq.n	c0d0190c <_vsnprintf+0x44>
        // format specifier?  %[flags][width][.precision][length]
        if (*format != '%') {
            // no
            out(*format, buffer, idx++, maxlen);
c0d018f2:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d018f4:	463a      	mov	r2, r7
c0d018f6:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d018f8:	4634      	mov	r4, r6
c0d018fa:	463e      	mov	r6, r7
c0d018fc:	9f14      	ldr	r7, [sp, #80]	; 0x50
c0d018fe:	47b8      	blx	r7
c0d01900:	4637      	mov	r7, r6
c0d01902:	4626      	mov	r6, r4
            format++;
            continue;
c0d01904:	1c66      	adds	r6, r4, #1
            format++;
c0d01906:	1c6d      	adds	r5, r5, #1
            out(*format, buffer, idx++, maxlen);
c0d01908:	1c7f      	adds	r7, r7, #1
c0d0190a:	e7ec      	b.n	c0d018e6 <_vsnprintf+0x1e>
c0d0190c:	2500      	movs	r5, #0
c0d0190e:	9b11      	ldr	r3, [sp, #68]	; 0x44
c0d01910:	9c13      	ldr	r4, [sp, #76]	; 0x4c
        }

        // evaluate flags
        flags = 0U;
        do {
            switch (*format) {
c0d01912:	5cf0      	ldrb	r0, [r6, r3]
c0d01914:	282a      	cmp	r0, #42	; 0x2a
c0d01916:	dd07      	ble.n	c0d01928 <_vsnprintf+0x60>
c0d01918:	282b      	cmp	r0, #43	; 0x2b
c0d0191a:	d00b      	beq.n	c0d01934 <_vsnprintf+0x6c>
c0d0191c:	2830      	cmp	r0, #48	; 0x30
c0d0191e:	d00b      	beq.n	c0d01938 <_vsnprintf+0x70>
c0d01920:	282d      	cmp	r0, #45	; 0x2d
c0d01922:	d10f      	bne.n	c0d01944 <_vsnprintf+0x7c>
c0d01924:	2002      	movs	r0, #2
c0d01926:	e00a      	b.n	c0d0193e <_vsnprintf+0x76>
c0d01928:	2820      	cmp	r0, #32
c0d0192a:	d007      	beq.n	c0d0193c <_vsnprintf+0x74>
c0d0192c:	2823      	cmp	r0, #35	; 0x23
c0d0192e:	d109      	bne.n	c0d01944 <_vsnprintf+0x7c>
c0d01930:	2010      	movs	r0, #16
c0d01932:	e004      	b.n	c0d0193e <_vsnprintf+0x76>
c0d01934:	2004      	movs	r0, #4
c0d01936:	e002      	b.n	c0d0193e <_vsnprintf+0x76>
c0d01938:	2001      	movs	r0, #1
c0d0193a:	e000      	b.n	c0d0193e <_vsnprintf+0x76>
c0d0193c:	2008      	movs	r0, #8
c0d0193e:	4305      	orrs	r5, r0
                    break;
                default:
                    n = 0U;
                    break;
            }
        } while (n);
c0d01940:	1c76      	adds	r6, r6, #1
c0d01942:	e7e6      	b.n	c0d01912 <_vsnprintf+0x4a>

        // evaluate width field
        width = 0U;
        if (_is_digit(*format)) {
c0d01944:	18f1      	adds	r1, r6, r3
    return (ch >= '0') && (ch <= '9');
c0d01946:	4602      	mov	r2, r0
c0d01948:	3a30      	subs	r2, #48	; 0x30
c0d0194a:	b2d2      	uxtb	r2, r2
        if (_is_digit(*format)) {
c0d0194c:	2a09      	cmp	r2, #9
c0d0194e:	d80f      	bhi.n	c0d01970 <_vsnprintf+0xa8>
c0d01950:	9413      	str	r4, [sp, #76]	; 0x4c
c0d01952:	2400      	movs	r4, #0
c0d01954:	220a      	movs	r2, #10
        i = i * 10U + (unsigned int) (*((*str)++) - '0');
c0d01956:	4362      	muls	r2, r4
c0d01958:	b2c0      	uxtb	r0, r0
c0d0195a:	1814      	adds	r4, r2, r0
c0d0195c:	3c30      	subs	r4, #48	; 0x30
c0d0195e:	1c4e      	adds	r6, r1, #1
    while (_is_digit(**str)) {
c0d01960:	7848      	ldrb	r0, [r1, #1]
    return (ch >= '0') && (ch <= '9');
c0d01962:	4601      	mov	r1, r0
c0d01964:	3930      	subs	r1, #48	; 0x30
c0d01966:	b2c9      	uxtb	r1, r1
    while (_is_digit(**str)) {
c0d01968:	290a      	cmp	r1, #10
c0d0196a:	4631      	mov	r1, r6
c0d0196c:	d3f2      	bcc.n	c0d01954 <_vsnprintf+0x8c>
c0d0196e:	e00f      	b.n	c0d01990 <_vsnprintf+0xc8>
            width = _atoi(&format);
        } else if (*format == '*') {
c0d01970:	282a      	cmp	r0, #42	; 0x2a
c0d01972:	d10a      	bne.n	c0d0198a <_vsnprintf+0xc2>
            const int w = va_arg(va, int);
c0d01974:	cc01      	ldmia	r4!, {r0}
            if (w < 0) {
c0d01976:	2800      	cmp	r0, #0
c0d01978:	9413      	str	r4, [sp, #76]	; 0x4c
c0d0197a:	d501      	bpl.n	c0d01980 <_vsnprintf+0xb8>
c0d0197c:	2102      	movs	r1, #2
c0d0197e:	430d      	orrs	r5, r1
c0d01980:	17c1      	asrs	r1, r0, #31
c0d01982:	1844      	adds	r4, r0, r1
c0d01984:	404c      	eors	r4, r1
            format++;
        }

        // evaluate precision field
        precision = 0U;
        if (*format == '.') {
c0d01986:	7830      	ldrb	r0, [r6, #0]
c0d01988:	e002      	b.n	c0d01990 <_vsnprintf+0xc8>
c0d0198a:	9413      	str	r4, [sp, #76]	; 0x4c
c0d0198c:	2400      	movs	r4, #0
c0d0198e:	460e      	mov	r6, r1
c0d01990:	2200      	movs	r2, #0
c0d01992:	282e      	cmp	r0, #46	; 0x2e
c0d01994:	d126      	bne.n	c0d019e4 <_vsnprintf+0x11c>
c0d01996:	9212      	str	r2, [sp, #72]	; 0x48
c0d01998:	2001      	movs	r0, #1
c0d0199a:	0280      	lsls	r0, r0, #10
            flags |= FLAGS_PRECISION;
c0d0199c:	4305      	orrs	r5, r0
            format++;
c0d0199e:	1c71      	adds	r1, r6, #1
            if (_is_digit(*format)) {
c0d019a0:	7870      	ldrb	r0, [r6, #1]
    return (ch >= '0') && (ch <= '9');
c0d019a2:	4602      	mov	r2, r0
c0d019a4:	3a30      	subs	r2, #48	; 0x30
c0d019a6:	b2d2      	uxtb	r2, r2
            if (_is_digit(*format)) {
c0d019a8:	2a09      	cmp	r2, #9
c0d019aa:	d80f      	bhi.n	c0d019cc <_vsnprintf+0x104>
c0d019ac:	2200      	movs	r2, #0
c0d019ae:	4616      	mov	r6, r2
c0d019b0:	220a      	movs	r2, #10
        i = i * 10U + (unsigned int) (*((*str)++) - '0');
c0d019b2:	4372      	muls	r2, r6
c0d019b4:	b2c0      	uxtb	r0, r0
c0d019b6:	1812      	adds	r2, r2, r0
c0d019b8:	3a30      	subs	r2, #48	; 0x30
c0d019ba:	1c4e      	adds	r6, r1, #1
    while (_is_digit(**str)) {
c0d019bc:	7848      	ldrb	r0, [r1, #1]
    return (ch >= '0') && (ch <= '9');
c0d019be:	4601      	mov	r1, r0
c0d019c0:	3930      	subs	r1, #48	; 0x30
c0d019c2:	b2c9      	uxtb	r1, r1
    while (_is_digit(**str)) {
c0d019c4:	290a      	cmp	r1, #10
c0d019c6:	4631      	mov	r1, r6
c0d019c8:	d3f1      	bcc.n	c0d019ae <_vsnprintf+0xe6>
c0d019ca:	e00b      	b.n	c0d019e4 <_vsnprintf+0x11c>
                precision = _atoi(&format);
            } else if (*format == '*') {
c0d019cc:	282a      	cmp	r0, #42	; 0x2a
c0d019ce:	d107      	bne.n	c0d019e0 <_vsnprintf+0x118>
                const int prec = (int) va_arg(va, int);
c0d019d0:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d019d2:	c804      	ldmia	r0!, {r2}
                precision = prec > 0 ? (unsigned int) prec : 0U;
c0d019d4:	9013      	str	r0, [sp, #76]	; 0x4c
c0d019d6:	17d0      	asrs	r0, r2, #31
c0d019d8:	4382      	bics	r2, r0
                format++;
            }
        }

        // evaluate length field
        switch (*format) {
c0d019da:	78b0      	ldrb	r0, [r6, #2]
                format++;
c0d019dc:	1cb6      	adds	r6, r6, #2
c0d019de:	e001      	b.n	c0d019e4 <_vsnprintf+0x11c>
c0d019e0:	460e      	mov	r6, r1
c0d019e2:	9a12      	ldr	r2, [sp, #72]	; 0x48
        switch (*format) {
c0d019e4:	3868      	subs	r0, #104	; 0x68
c0d019e6:	2101      	movs	r1, #1
c0d019e8:	41c8      	rors	r0, r1
c0d019ea:	2801      	cmp	r0, #1
c0d019ec:	9110      	str	r1, [sp, #64]	; 0x40
c0d019ee:	dd0c      	ble.n	c0d01a0a <_vsnprintf+0x142>
c0d019f0:	2809      	cmp	r0, #9
c0d019f2:	d011      	beq.n	c0d01a18 <_vsnprintf+0x150>
c0d019f4:	2806      	cmp	r0, #6
c0d019f6:	d00f      	beq.n	c0d01a18 <_vsnprintf+0x150>
c0d019f8:	2802      	cmp	r0, #2
c0d019fa:	d118      	bne.n	c0d01a2e <_vsnprintf+0x166>
            case 'l':
                flags |= FLAGS_LONG;
                format++;
                if (*format == 'l') {
c0d019fc:	7870      	ldrb	r0, [r6, #1]
c0d019fe:	286c      	cmp	r0, #108	; 0x6c
c0d01a00:	d000      	beq.n	c0d01a04 <_vsnprintf+0x13c>
c0d01a02:	e0a0      	b.n	c0d01b46 <_vsnprintf+0x27e>
c0d01a04:	2003      	movs	r0, #3
c0d01a06:	0200      	lsls	r0, r0, #8
c0d01a08:	e00f      	b.n	c0d01a2a <_vsnprintf+0x162>
        switch (*format) {
c0d01a0a:	2800      	cmp	r0, #0
c0d01a0c:	d008      	beq.n	c0d01a20 <_vsnprintf+0x158>
c0d01a0e:	2801      	cmp	r0, #1
c0d01a10:	d10d      	bne.n	c0d01a2e <_vsnprintf+0x166>
c0d01a12:	2001      	movs	r0, #1
c0d01a14:	0240      	lsls	r0, r0, #9
c0d01a16:	e000      	b.n	c0d01a1a <_vsnprintf+0x152>
c0d01a18:	0208      	lsls	r0, r1, #8
c0d01a1a:	4305      	orrs	r5, r0
c0d01a1c:	1c76      	adds	r6, r6, #1
c0d01a1e:	e006      	b.n	c0d01a2e <_vsnprintf+0x166>
                }
                break;
            case 'h':
                flags |= FLAGS_SHORT;
                format++;
                if (*format == 'h') {
c0d01a20:	7870      	ldrb	r0, [r6, #1]
c0d01a22:	2868      	cmp	r0, #104	; 0x68
c0d01a24:	d000      	beq.n	c0d01a28 <_vsnprintf+0x160>
c0d01a26:	e090      	b.n	c0d01b4a <_vsnprintf+0x282>
c0d01a28:	20c0      	movs	r0, #192	; 0xc0
c0d01a2a:	4305      	orrs	r5, r0
c0d01a2c:	1cb6      	adds	r6, r6, #2
            default:
                break;
        }

        // evaluate specifier
        switch (*format) {
c0d01a2e:	7830      	ldrb	r0, [r6, #0]
c0d01a30:	2110      	movs	r1, #16
c0d01a32:	2864      	cmp	r0, #100	; 0x64
c0d01a34:	dd0b      	ble.n	c0d01a4e <_vsnprintf+0x186>
c0d01a36:	286e      	cmp	r0, #110	; 0x6e
c0d01a38:	dd13      	ble.n	c0d01a62 <_vsnprintf+0x19a>
c0d01a3a:	2872      	cmp	r0, #114	; 0x72
c0d01a3c:	dd22      	ble.n	c0d01a84 <_vsnprintf+0x1bc>
c0d01a3e:	2873      	cmp	r0, #115	; 0x73
c0d01a40:	d100      	bne.n	c0d01a44 <_vsnprintf+0x17c>
c0d01a42:	e086      	b.n	c0d01b52 <_vsnprintf+0x28a>
c0d01a44:	2875      	cmp	r0, #117	; 0x75
c0d01a46:	d042      	beq.n	c0d01ace <_vsnprintf+0x206>
c0d01a48:	2878      	cmp	r0, #120	; 0x78
c0d01a4a:	d043      	beq.n	c0d01ad4 <_vsnprintf+0x20c>
c0d01a4c:	e0c8      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01a4e:	2857      	cmp	r0, #87	; 0x57
c0d01a50:	dc0e      	bgt.n	c0d01a70 <_vsnprintf+0x1a8>
c0d01a52:	2845      	cmp	r0, #69	; 0x45
c0d01a54:	dc2b      	bgt.n	c0d01aae <_vsnprintf+0x1e6>
c0d01a56:	2825      	cmp	r0, #37	; 0x25
c0d01a58:	d100      	bne.n	c0d01a5c <_vsnprintf+0x194>
c0d01a5a:	e0c0      	b.n	c0d01bde <_vsnprintf+0x316>
c0d01a5c:	2845      	cmp	r0, #69	; 0x45
c0d01a5e:	d05d      	beq.n	c0d01b1c <_vsnprintf+0x254>
c0d01a60:	e0be      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01a62:	2866      	cmp	r0, #102	; 0x66
c0d01a64:	dc28      	bgt.n	c0d01ab8 <_vsnprintf+0x1f0>
c0d01a66:	2865      	cmp	r0, #101	; 0x65
c0d01a68:	d058      	beq.n	c0d01b1c <_vsnprintf+0x254>
c0d01a6a:	2866      	cmp	r0, #102	; 0x66
c0d01a6c:	d03e      	beq.n	c0d01aec <_vsnprintf+0x224>
c0d01a6e:	e0b7      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01a70:	2862      	cmp	r0, #98	; 0x62
c0d01a72:	dc26      	bgt.n	c0d01ac2 <_vsnprintf+0x1fa>
c0d01a74:	2858      	cmp	r0, #88	; 0x58
c0d01a76:	d02d      	beq.n	c0d01ad4 <_vsnprintf+0x20c>
c0d01a78:	2862      	cmp	r0, #98	; 0x62
c0d01a7a:	d000      	beq.n	c0d01a7e <_vsnprintf+0x1b6>
c0d01a7c:	e0b0      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01a7e:	9212      	str	r2, [sp, #72]	; 0x48
c0d01a80:	2102      	movs	r1, #2
c0d01a82:	e0b6      	b.n	c0d01bf2 <_vsnprintf+0x32a>
c0d01a84:	286f      	cmp	r0, #111	; 0x6f
c0d01a86:	d100      	bne.n	c0d01a8a <_vsnprintf+0x1c2>
c0d01a88:	e0b1      	b.n	c0d01bee <_vsnprintf+0x326>
c0d01a8a:	2870      	cmp	r0, #112	; 0x70
c0d01a8c:	d000      	beq.n	c0d01a90 <_vsnprintf+0x1c8>
c0d01a8e:	e0a7      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01a90:	2021      	movs	r0, #33	; 0x21
                break;
            }

            case 'p': {
                width = sizeof(void*) * 2U;
                flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
c0d01a92:	4305      	orrs	r5, r0
#endif
                    idx = _ntoa_long(out,
                                     buffer,
                                     idx,
                                     maxlen,
                                     (unsigned long) ((uintptr_t) va_arg(va, void*)),
c0d01a94:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d01a96:	c901      	ldmia	r1!, {r0}
c0d01a98:	9113      	str	r1, [sp, #76]	; 0x4c
c0d01a9a:	2108      	movs	r1, #8
c0d01a9c:	4614      	mov	r4, r2
c0d01a9e:	2210      	movs	r2, #16
c0d01aa0:	2300      	movs	r3, #0
                    idx = _ntoa_long(out,
c0d01aa2:	9000      	str	r0, [sp, #0]
c0d01aa4:	9301      	str	r3, [sp, #4]
c0d01aa6:	9202      	str	r2, [sp, #8]
c0d01aa8:	9403      	str	r4, [sp, #12]
c0d01aaa:	9104      	str	r1, [sp, #16]
c0d01aac:	e112      	b.n	c0d01cd4 <_vsnprintf+0x40c>
        switch (*format) {
c0d01aae:	2846      	cmp	r0, #70	; 0x46
c0d01ab0:	d01c      	beq.n	c0d01aec <_vsnprintf+0x224>
c0d01ab2:	2847      	cmp	r0, #71	; 0x47
c0d01ab4:	d02f      	beq.n	c0d01b16 <_vsnprintf+0x24e>
c0d01ab6:	e093      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01ab8:	2867      	cmp	r0, #103	; 0x67
c0d01aba:	d02c      	beq.n	c0d01b16 <_vsnprintf+0x24e>
c0d01abc:	2869      	cmp	r0, #105	; 0x69
c0d01abe:	d006      	beq.n	c0d01ace <_vsnprintf+0x206>
c0d01ac0:	e08e      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01ac2:	2863      	cmp	r0, #99	; 0x63
c0d01ac4:	d100      	bne.n	c0d01ac8 <_vsnprintf+0x200>
c0d01ac6:	e0de      	b.n	c0d01c86 <_vsnprintf+0x3be>
c0d01ac8:	2864      	cmp	r0, #100	; 0x64
c0d01aca:	d000      	beq.n	c0d01ace <_vsnprintf+0x206>
c0d01acc:	e088      	b.n	c0d01be0 <_vsnprintf+0x318>
c0d01ace:	2110      	movs	r1, #16
                    flags &= ~FLAGS_HASH;  // no hash for dec format
c0d01ad0:	438d      	bics	r5, r1
c0d01ad2:	210a      	movs	r1, #10
                if (*format == 'X') {
c0d01ad4:	2858      	cmp	r0, #88	; 0x58
c0d01ad6:	9212      	str	r2, [sp, #72]	; 0x48
c0d01ad8:	d101      	bne.n	c0d01ade <_vsnprintf+0x216>
c0d01ada:	2220      	movs	r2, #32
c0d01adc:	4315      	orrs	r5, r2
                if ((*format != 'i') && (*format != 'd')) {
c0d01ade:	2864      	cmp	r0, #100	; 0x64
c0d01ae0:	d100      	bne.n	c0d01ae4 <_vsnprintf+0x21c>
c0d01ae2:	e088      	b.n	c0d01bf6 <_vsnprintf+0x32e>
c0d01ae4:	2869      	cmp	r0, #105	; 0x69
c0d01ae6:	d100      	bne.n	c0d01aea <_vsnprintf+0x222>
c0d01ae8:	e085      	b.n	c0d01bf6 <_vsnprintf+0x32e>
c0d01aea:	e082      	b.n	c0d01bf2 <_vsnprintf+0x32a>
c0d01aec:	4613      	mov	r3, r2
c0d01aee:	9a13      	ldr	r2, [sp, #76]	; 0x4c
                idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d01af0:	1dd2      	adds	r2, r2, #7
c0d01af2:	2107      	movs	r1, #7
c0d01af4:	438a      	bics	r2, r1
c0d01af6:	6811      	ldr	r1, [r2, #0]
c0d01af8:	9213      	str	r2, [sp, #76]	; 0x4c
c0d01afa:	6852      	ldr	r2, [r2, #4]
                if (*format == 'F') flags |= FLAGS_UPPERCASE;
c0d01afc:	2846      	cmp	r0, #70	; 0x46
c0d01afe:	d101      	bne.n	c0d01b04 <_vsnprintf+0x23c>
c0d01b00:	2020      	movs	r0, #32
c0d01b02:	4305      	orrs	r5, r0
                idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d01b04:	a800      	add	r0, sp, #0
c0d01b06:	c03e      	stmia	r0!, {r1, r2, r3, r4, r5}
c0d01b08:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01b0a:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01b0c:	463a      	mov	r2, r7
c0d01b0e:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01b10:	f000 fa30 	bl	c0d01f74 <_ftoa>
c0d01b14:	e0a7      	b.n	c0d01c66 <_vsnprintf+0x39e>
c0d01b16:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d01b18:	02c9      	lsls	r1, r1, #11
                if ((*format == 'g') || (*format == 'G')) flags |= FLAGS_ADAPT_EXP;
c0d01b1a:	430d      	orrs	r5, r1
c0d01b1c:	2102      	movs	r1, #2
                if ((*format == 'E') || (*format == 'G')) flags |= FLAGS_UPPERCASE;
c0d01b1e:	4308      	orrs	r0, r1
c0d01b20:	2847      	cmp	r0, #71	; 0x47
c0d01b22:	d101      	bne.n	c0d01b28 <_vsnprintf+0x260>
c0d01b24:	2020      	movs	r0, #32
c0d01b26:	4305      	orrs	r5, r0
c0d01b28:	9913      	ldr	r1, [sp, #76]	; 0x4c
                idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d01b2a:	1dc9      	adds	r1, r1, #7
c0d01b2c:	2007      	movs	r0, #7
c0d01b2e:	4381      	bics	r1, r0
c0d01b30:	9113      	str	r1, [sp, #76]	; 0x4c
c0d01b32:	c903      	ldmia	r1, {r0, r1}
c0d01b34:	ab00      	add	r3, sp, #0
c0d01b36:	c337      	stmia	r3!, {r0, r1, r2, r4, r5}
c0d01b38:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01b3a:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01b3c:	463a      	mov	r2, r7
c0d01b3e:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01b40:	f000 fc08 	bl	c0d02354 <_etoa>
c0d01b44:	e08f      	b.n	c0d01c66 <_vsnprintf+0x39e>
c0d01b46:	0209      	lsls	r1, r1, #8
c0d01b48:	e000      	b.n	c0d01b4c <_vsnprintf+0x284>
c0d01b4a:	2180      	movs	r1, #128	; 0x80
c0d01b4c:	430d      	orrs	r5, r1
c0d01b4e:	1c76      	adds	r6, r6, #1
c0d01b50:	e76e      	b.n	c0d01a30 <_vsnprintf+0x168>
c0d01b52:	9212      	str	r2, [sp, #72]	; 0x48
                const char* p = va_arg(va, char*);
c0d01b54:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01b56:	c802      	ldmia	r0!, {r1}
    for (s = str; *s && maxsize--; ++s)
c0d01b58:	9013      	str	r0, [sp, #76]	; 0x4c
c0d01b5a:	7808      	ldrb	r0, [r1, #0]
c0d01b5c:	2800      	cmp	r0, #0
c0d01b5e:	910c      	str	r1, [sp, #48]	; 0x30
c0d01b60:	d00e      	beq.n	c0d01b80 <_vsnprintf+0x2b8>
c0d01b62:	9a12      	ldr	r2, [sp, #72]	; 0x48
                unsigned int l = _strnlen_s(p, precision ? precision : (size_t) -1);
c0d01b64:	2a00      	cmp	r2, #0
c0d01b66:	4619      	mov	r1, r3
c0d01b68:	d000      	beq.n	c0d01b6c <_vsnprintf+0x2a4>
c0d01b6a:	4611      	mov	r1, r2
    for (s = str; *s && maxsize--; ++s)
c0d01b6c:	1e4a      	subs	r2, r1, #1
c0d01b6e:	9b0c      	ldr	r3, [sp, #48]	; 0x30
c0d01b70:	1c59      	adds	r1, r3, #1
c0d01b72:	2a00      	cmp	r2, #0
c0d01b74:	d004      	beq.n	c0d01b80 <_vsnprintf+0x2b8>
c0d01b76:	785b      	ldrb	r3, [r3, #1]
c0d01b78:	1e52      	subs	r2, r2, #1
c0d01b7a:	2b00      	cmp	r3, #0
c0d01b7c:	460b      	mov	r3, r1
c0d01b7e:	d1f7      	bne.n	c0d01b70 <_vsnprintf+0x2a8>
c0d01b80:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d01b82:	0293      	lsls	r3, r2, #10
                if (flags & FLAGS_PRECISION) {
c0d01b84:	402b      	ands	r3, r5
    return (unsigned int) (s - str);
c0d01b86:	9a0c      	ldr	r2, [sp, #48]	; 0x30
c0d01b88:	1a89      	subs	r1, r1, r2
c0d01b8a:	9a12      	ldr	r2, [sp, #72]	; 0x48
                if (flags & FLAGS_PRECISION) {
c0d01b8c:	4291      	cmp	r1, r2
c0d01b8e:	910d      	str	r1, [sp, #52]	; 0x34
c0d01b90:	d300      	bcc.n	c0d01b94 <_vsnprintf+0x2cc>
c0d01b92:	920d      	str	r2, [sp, #52]	; 0x34
c0d01b94:	2b00      	cmp	r3, #0
c0d01b96:	d100      	bne.n	c0d01b9a <_vsnprintf+0x2d2>
c0d01b98:	910d      	str	r1, [sp, #52]	; 0x34
c0d01b9a:	2102      	movs	r1, #2
                if (!(flags & FLAGS_LEFT)) {
c0d01b9c:	400d      	ands	r5, r1
c0d01b9e:	950f      	str	r5, [sp, #60]	; 0x3c
c0d01ba0:	930e      	str	r3, [sp, #56]	; 0x38
c0d01ba2:	d000      	beq.n	c0d01ba6 <_vsnprintf+0x2de>
c0d01ba4:	e0b8      	b.n	c0d01d18 <_vsnprintf+0x450>
c0d01ba6:	990d      	ldr	r1, [sp, #52]	; 0x34
                    while (l++ < width) {
c0d01ba8:	42a1      	cmp	r1, r4
c0d01baa:	d300      	bcc.n	c0d01bae <_vsnprintf+0x2e6>
c0d01bac:	e0b2      	b.n	c0d01d14 <_vsnprintf+0x44c>
c0d01bae:	1a60      	subs	r0, r4, r1
c0d01bb0:	9010      	str	r0, [sp, #64]	; 0x40
c0d01bb2:	940a      	str	r4, [sp, #40]	; 0x28
c0d01bb4:	1c60      	adds	r0, r4, #1
c0d01bb6:	900d      	str	r0, [sp, #52]	; 0x34
c0d01bb8:	2500      	movs	r5, #0
                        out(' ', buffer, idx++, maxlen);
c0d01bba:	197a      	adds	r2, r7, r5
c0d01bbc:	2020      	movs	r0, #32
c0d01bbe:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01bc0:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01bc2:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d01bc4:	47a0      	blx	r4
                    while (l++ < width) {
c0d01bc6:	1c6d      	adds	r5, r5, #1
c0d01bc8:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d01bca:	42a8      	cmp	r0, r5
c0d01bcc:	d1f5      	bne.n	c0d01bba <_vsnprintf+0x2f2>
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d01bce:	197f      	adds	r7, r7, r5
c0d01bd0:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d01bd2:	7800      	ldrb	r0, [r0, #0]
c0d01bd4:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d01bd6:	9a12      	ldr	r2, [sp, #72]	; 0x48
c0d01bd8:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d01bda:	9c0a      	ldr	r4, [sp, #40]	; 0x28
c0d01bdc:	e09c      	b.n	c0d01d18 <_vsnprintf+0x450>
c0d01bde:	2025      	movs	r0, #37	; 0x25
c0d01be0:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01be2:	463a      	mov	r2, r7
c0d01be4:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01be6:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d01be8:	47a0      	blx	r4
c0d01bea:	1c7f      	adds	r7, r7, #1
c0d01bec:	e03f      	b.n	c0d01c6e <_vsnprintf+0x3a6>
c0d01bee:	9212      	str	r2, [sp, #72]	; 0x48
c0d01bf0:	2108      	movs	r1, #8
c0d01bf2:	220c      	movs	r2, #12
                    flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
c0d01bf4:	4395      	bics	r5, r2
                if (flags & FLAGS_PRECISION) {
c0d01bf6:	056a      	lsls	r2, r5, #21
c0d01bf8:	d501      	bpl.n	c0d01bfe <_vsnprintf+0x336>
c0d01bfa:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d01bfc:	4395      	bics	r5, r2
                if ((*format == 'i') || (*format == 'd')) {
c0d01bfe:	2869      	cmp	r0, #105	; 0x69
c0d01c00:	d001      	beq.n	c0d01c06 <_vsnprintf+0x33e>
c0d01c02:	2864      	cmp	r0, #100	; 0x64
c0d01c04:	d118      	bne.n	c0d01c38 <_vsnprintf+0x370>
                    if (flags & FLAGS_LONG_LONG) {
c0d01c06:	05a8      	lsls	r0, r5, #22
c0d01c08:	d533      	bpl.n	c0d01c72 <_vsnprintf+0x3aa>
c0d01c0a:	9b13      	ldr	r3, [sp, #76]	; 0x4c
                        const long long value = va_arg(va, long long);
c0d01c0c:	1ddb      	adds	r3, r3, #7
c0d01c0e:	2007      	movs	r0, #7
c0d01c10:	4383      	bics	r3, r0
c0d01c12:	9313      	str	r3, [sp, #76]	; 0x4c
c0d01c14:	681a      	ldr	r2, [r3, #0]
c0d01c16:	6858      	ldr	r0, [r3, #4]
                        idx = _ntoa_long_long(out,
c0d01c18:	0fc3      	lsrs	r3, r0, #31
c0d01c1a:	9302      	str	r3, [sp, #8]
c0d01c1c:	2300      	movs	r3, #0
c0d01c1e:	9104      	str	r1, [sp, #16]
c0d01c20:	9305      	str	r3, [sp, #20]
c0d01c22:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d01c24:	ab06      	add	r3, sp, #24
c0d01c26:	c332      	stmia	r3!, {r1, r4, r5}
                                              (unsigned long long) (value > 0 ? value : 0 - value),
c0d01c28:	17c1      	asrs	r1, r0, #31
c0d01c2a:	1852      	adds	r2, r2, r1
c0d01c2c:	4148      	adcs	r0, r1
c0d01c2e:	404a      	eors	r2, r1
                        idx = _ntoa_long_long(out,
c0d01c30:	9200      	str	r2, [sp, #0]
                                              (unsigned long long) (value > 0 ? value : 0 - value),
c0d01c32:	4048      	eors	r0, r1
                        idx = _ntoa_long_long(out,
c0d01c34:	9001      	str	r0, [sp, #4]
c0d01c36:	e010      	b.n	c0d01c5a <_vsnprintf+0x392>
                    if (flags & FLAGS_LONG_LONG) {
c0d01c38:	05a8      	lsls	r0, r5, #22
c0d01c3a:	d53f      	bpl.n	c0d01cbc <_vsnprintf+0x3f4>
c0d01c3c:	9a13      	ldr	r2, [sp, #76]	; 0x4c
                                              va_arg(va, unsigned long long),
c0d01c3e:	1dd2      	adds	r2, r2, #7
c0d01c40:	2007      	movs	r0, #7
c0d01c42:	4382      	bics	r2, r0
c0d01c44:	9213      	str	r2, [sp, #76]	; 0x4c
c0d01c46:	ca05      	ldmia	r2, {r0, r2}
c0d01c48:	2300      	movs	r3, #0
                        idx = _ntoa_long_long(out,
c0d01c4a:	9104      	str	r1, [sp, #16]
c0d01c4c:	9305      	str	r3, [sp, #20]
c0d01c4e:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d01c50:	9106      	str	r1, [sp, #24]
c0d01c52:	9407      	str	r4, [sp, #28]
c0d01c54:	9508      	str	r5, [sp, #32]
c0d01c56:	a900      	add	r1, sp, #0
c0d01c58:	c10d      	stmia	r1!, {r0, r2, r3}
c0d01c5a:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01c5c:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01c5e:	463a      	mov	r2, r7
c0d01c60:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01c62:	f000 f8dc 	bl	c0d01e1e <_ntoa_long_long>
c0d01c66:	4607      	mov	r7, r0
c0d01c68:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01c6a:	3008      	adds	r0, #8
c0d01c6c:	9013      	str	r0, [sp, #76]	; 0x4c
c0d01c6e:	1c75      	adds	r5, r6, #1
c0d01c70:	e638      	b.n	c0d018e4 <_vsnprintf+0x1c>
                    } else if (flags & FLAGS_LONG) {
c0d01c72:	05e8      	lsls	r0, r5, #23
c0d01c74:	d537      	bpl.n	c0d01ce6 <_vsnprintf+0x41e>
                        const long value = va_arg(va, long);
c0d01c76:	9a13      	ldr	r2, [sp, #76]	; 0x4c
c0d01c78:	ca01      	ldmia	r2!, {r0}
c0d01c7a:	9213      	str	r2, [sp, #76]	; 0x4c
                        idx = _ntoa_long(out,
c0d01c7c:	0fc2      	lsrs	r2, r0, #31
                                         (unsigned long) (value > 0 ? value : 0 - value),
c0d01c7e:	17c3      	asrs	r3, r0, #31
c0d01c80:	18c0      	adds	r0, r0, r3
c0d01c82:	4058      	eors	r0, r3
c0d01c84:	e020      	b.n	c0d01cc8 <_vsnprintf+0x400>
c0d01c86:	2002      	movs	r0, #2
                if (!(flags & FLAGS_LEFT)) {
c0d01c88:	4005      	ands	r5, r0
c0d01c8a:	960b      	str	r6, [sp, #44]	; 0x2c
c0d01c8c:	d172      	bne.n	c0d01d74 <_vsnprintf+0x4ac>
                    while (l++ < width) {
c0d01c8e:	2c02      	cmp	r4, #2
c0d01c90:	d36f      	bcc.n	c0d01d72 <_vsnprintf+0x4aa>
c0d01c92:	950f      	str	r5, [sp, #60]	; 0x3c
c0d01c94:	1e60      	subs	r0, r4, #1
c0d01c96:	9012      	str	r0, [sp, #72]	; 0x48
c0d01c98:	1c60      	adds	r0, r4, #1
c0d01c9a:	9010      	str	r0, [sp, #64]	; 0x40
c0d01c9c:	2500      	movs	r5, #0
                        out(' ', buffer, idx++, maxlen);
c0d01c9e:	197a      	adds	r2, r7, r5
c0d01ca0:	2020      	movs	r0, #32
c0d01ca2:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01ca4:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01ca6:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d01ca8:	47b0      	blx	r6
                    while (l++ < width) {
c0d01caa:	1c6d      	adds	r5, r5, #1
c0d01cac:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d01cae:	42a8      	cmp	r0, r5
c0d01cb0:	d1f5      	bne.n	c0d01c9e <_vsnprintf+0x3d6>
                out((char) va_arg(va, int), buffer, idx++, maxlen);
c0d01cb2:	197f      	adds	r7, r7, r5
c0d01cb4:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d01cb6:	e05d      	b.n	c0d01d74 <_vsnprintf+0x4ac>
c0d01cb8:	00000545 	.word	0x00000545
                    } else if (flags & FLAGS_LONG) {
c0d01cbc:	05e8      	lsls	r0, r5, #23
c0d01cbe:	d521      	bpl.n	c0d01d04 <_vsnprintf+0x43c>
                                         va_arg(va, unsigned long),
c0d01cc0:	9a13      	ldr	r2, [sp, #76]	; 0x4c
c0d01cc2:	ca01      	ldmia	r2!, {r0}
c0d01cc4:	9213      	str	r2, [sp, #76]	; 0x4c
c0d01cc6:	2200      	movs	r2, #0
c0d01cc8:	9000      	str	r0, [sp, #0]
c0d01cca:	9201      	str	r2, [sp, #4]
c0d01ccc:	9102      	str	r1, [sp, #8]
c0d01cce:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d01cd0:	9003      	str	r0, [sp, #12]
c0d01cd2:	9404      	str	r4, [sp, #16]
c0d01cd4:	9505      	str	r5, [sp, #20]
c0d01cd6:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01cd8:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01cda:	463a      	mov	r2, r7
c0d01cdc:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01cde:	f000 f8ff 	bl	c0d01ee0 <_ntoa_long>
c0d01ce2:	4607      	mov	r7, r0
c0d01ce4:	e7c3      	b.n	c0d01c6e <_vsnprintf+0x3a6>
                        const int value = (flags & FLAGS_CHAR)
c0d01ce6:	0668      	lsls	r0, r5, #25
c0d01ce8:	d405      	bmi.n	c0d01cf6 <_vsnprintf+0x42e>
                                              : (flags & FLAGS_SHORT) ? (short int) va_arg(va, int)
c0d01cea:	0628      	lsls	r0, r5, #24
c0d01cec:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01cee:	6800      	ldr	r0, [r0, #0]
c0d01cf0:	d503      	bpl.n	c0d01cfa <_vsnprintf+0x432>
c0d01cf2:	b200      	sxth	r0, r0
c0d01cf4:	e001      	b.n	c0d01cfa <_vsnprintf+0x432>
                                              ? (char) va_arg(va, int)
c0d01cf6:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01cf8:	7800      	ldrb	r0, [r0, #0]
                        idx = _ntoa_long(out,
c0d01cfa:	0fc2      	lsrs	r2, r0, #31
                                         (unsigned int) (value > 0 ? value : 0 - value),
c0d01cfc:	17c3      	asrs	r3, r0, #31
c0d01cfe:	18c0      	adds	r0, r0, r3
c0d01d00:	4058      	eors	r0, r3
c0d01d02:	e05a      	b.n	c0d01dba <_vsnprintf+0x4f2>
                            (flags & FLAGS_CHAR)
c0d01d04:	0668      	lsls	r0, r5, #25
c0d01d06:	d455      	bmi.n	c0d01db4 <_vsnprintf+0x4ec>
                                : (flags & FLAGS_SHORT)
c0d01d08:	0628      	lsls	r0, r5, #24
c0d01d0a:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01d0c:	6800      	ldr	r0, [r0, #0]
c0d01d0e:	d553      	bpl.n	c0d01db8 <_vsnprintf+0x4f0>
c0d01d10:	b280      	uxth	r0, r0
c0d01d12:	e051      	b.n	c0d01db8 <_vsnprintf+0x4f0>
c0d01d14:	1c49      	adds	r1, r1, #1
c0d01d16:	910d      	str	r1, [sp, #52]	; 0x34
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d01d18:	2800      	cmp	r0, #0
c0d01d1a:	d017      	beq.n	c0d01d4c <_vsnprintf+0x484>
c0d01d1c:	990c      	ldr	r1, [sp, #48]	; 0x30
c0d01d1e:	1c49      	adds	r1, r1, #1
c0d01d20:	2b00      	cmp	r3, #0
c0d01d22:	9110      	str	r1, [sp, #64]	; 0x40
c0d01d24:	d002      	beq.n	c0d01d2c <_vsnprintf+0x464>
c0d01d26:	2a00      	cmp	r2, #0
c0d01d28:	d010      	beq.n	c0d01d4c <_vsnprintf+0x484>
c0d01d2a:	1e52      	subs	r2, r2, #1
c0d01d2c:	9212      	str	r2, [sp, #72]	; 0x48
                    out(*(p++), buffer, idx++, maxlen);
c0d01d2e:	b2c0      	uxtb	r0, r0
c0d01d30:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01d32:	463a      	mov	r2, r7
c0d01d34:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01d36:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d01d38:	47a8      	blx	r5
c0d01d3a:	9810      	ldr	r0, [sp, #64]	; 0x40
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d01d3c:	1c41      	adds	r1, r0, #1
                    out(*(p++), buffer, idx++, maxlen);
c0d01d3e:	1c7f      	adds	r7, r7, #1
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d01d40:	7800      	ldrb	r0, [r0, #0]
c0d01d42:	2800      	cmp	r0, #0
c0d01d44:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d01d46:	9a12      	ldr	r2, [sp, #72]	; 0x48
c0d01d48:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d01d4a:	d1e9      	bne.n	c0d01d20 <_vsnprintf+0x458>
                if (flags & FLAGS_LEFT) {
c0d01d4c:	2d00      	cmp	r5, #0
c0d01d4e:	d08e      	beq.n	c0d01c6e <_vsnprintf+0x3a6>
c0d01d50:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d01d52:	42a0      	cmp	r0, r4
c0d01d54:	9914      	ldr	r1, [sp, #80]	; 0x50
c0d01d56:	d28a      	bcs.n	c0d01c6e <_vsnprintf+0x3a6>
                    while (l++ < width) {
c0d01d58:	1a24      	subs	r4, r4, r0
c0d01d5a:	9114      	str	r1, [sp, #80]	; 0x50
c0d01d5c:	2020      	movs	r0, #32
                        out(' ', buffer, idx++, maxlen);
c0d01d5e:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01d60:	463a      	mov	r2, r7
c0d01d62:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01d64:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d01d66:	47a8      	blx	r5
                    while (l++ < width) {
c0d01d68:	1e64      	subs	r4, r4, #1
                        out(' ', buffer, idx++, maxlen);
c0d01d6a:	1c7f      	adds	r7, r7, #1
                    while (l++ < width) {
c0d01d6c:	2c00      	cmp	r4, #0
c0d01d6e:	d1f5      	bne.n	c0d01d5c <_vsnprintf+0x494>
c0d01d70:	e77d      	b.n	c0d01c6e <_vsnprintf+0x3a6>
c0d01d72:	9010      	str	r0, [sp, #64]	; 0x40
                out((char) va_arg(va, int), buffer, idx++, maxlen);
c0d01d74:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01d76:	7800      	ldrb	r0, [r0, #0]
c0d01d78:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01d7a:	463a      	mov	r2, r7
c0d01d7c:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01d7e:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d01d80:	47b0      	blx	r6
c0d01d82:	1c7f      	adds	r7, r7, #1
c0d01d84:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01d86:	1d00      	adds	r0, r0, #4
c0d01d88:	9013      	str	r0, [sp, #76]	; 0x4c
                if (flags & FLAGS_LEFT) {
c0d01d8a:	2d00      	cmp	r5, #0
c0d01d8c:	d010      	beq.n	c0d01db0 <_vsnprintf+0x4e8>
c0d01d8e:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d01d90:	42a0      	cmp	r0, r4
c0d01d92:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d01d94:	d300      	bcc.n	c0d01d98 <_vsnprintf+0x4d0>
c0d01d96:	e76a      	b.n	c0d01c6e <_vsnprintf+0x3a6>
                    while (l++ < width) {
c0d01d98:	1a24      	subs	r4, r4, r0
c0d01d9a:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d01d9c:	2020      	movs	r0, #32
                        out(' ', buffer, idx++, maxlen);
c0d01d9e:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01da0:	463a      	mov	r2, r7
c0d01da2:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01da4:	47a8      	blx	r5
                    while (l++ < width) {
c0d01da6:	1e64      	subs	r4, r4, #1
                        out(' ', buffer, idx++, maxlen);
c0d01da8:	1c7f      	adds	r7, r7, #1
                    while (l++ < width) {
c0d01daa:	2c00      	cmp	r4, #0
c0d01dac:	d1f6      	bne.n	c0d01d9c <_vsnprintf+0x4d4>
c0d01dae:	e75e      	b.n	c0d01c6e <_vsnprintf+0x3a6>
c0d01db0:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d01db2:	e75c      	b.n	c0d01c6e <_vsnprintf+0x3a6>
                                ? (unsigned char) va_arg(va, unsigned int)
c0d01db4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01db6:	7800      	ldrb	r0, [r0, #0]
c0d01db8:	2200      	movs	r2, #0
c0d01dba:	9000      	str	r0, [sp, #0]
c0d01dbc:	9201      	str	r2, [sp, #4]
c0d01dbe:	9102      	str	r1, [sp, #8]
c0d01dc0:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d01dc2:	a903      	add	r1, sp, #12
c0d01dc4:	c131      	stmia	r1!, {r0, r4, r5}
c0d01dc6:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01dc8:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01dca:	463a      	mov	r2, r7
c0d01dcc:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d01dce:	f000 f887 	bl	c0d01ee0 <_ntoa_long>
c0d01dd2:	4607      	mov	r7, r0
c0d01dd4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01dd6:	1d00      	adds	r0, r0, #4
c0d01dd8:	e748      	b.n	c0d01c6c <_vsnprintf+0x3a4>
c0d01dda:	9b16      	ldr	r3, [sp, #88]	; 0x58
                break;
        }
    }

    // termination
    out((char) 0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
c0d01ddc:	429f      	cmp	r7, r3
c0d01dde:	463a      	mov	r2, r7
c0d01de0:	d300      	bcc.n	c0d01de4 <_vsnprintf+0x51c>
c0d01de2:	1e5a      	subs	r2, r3, #1
c0d01de4:	2000      	movs	r0, #0
c0d01de6:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d01de8:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d01dea:	47a0      	blx	r4

    // return written chars without terminating \0
    return (int) idx;
c0d01dec:	4638      	mov	r0, r7
c0d01dee:	b017      	add	sp, #92	; 0x5c
c0d01df0:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d01df2 <_out_buffer>:
    if (idx < maxlen) {
c0d01df2:	429a      	cmp	r2, r3
c0d01df4:	d200      	bcs.n	c0d01df8 <_out_buffer+0x6>
        ((char*) buffer)[idx] = character;
c0d01df6:	5488      	strb	r0, [r1, r2]
}
c0d01df8:	4770      	bx	lr
	...

c0d01dfc <vsnprintf_>:
int vprintf_(const char* format, va_list va) {
    char buffer[1];
    return _vsnprintf(_out_char, buffer, (size_t) -1, format, va);
}

int vsnprintf_(char* buffer, size_t count, const char* format, va_list va) {
c0d01dfc:	b510      	push	{r4, lr}
c0d01dfe:	b082      	sub	sp, #8
c0d01e00:	4614      	mov	r4, r2
c0d01e02:	460a      	mov	r2, r1
c0d01e04:	4601      	mov	r1, r0
    return _vsnprintf(_out_buffer, buffer, count, format, va);
c0d01e06:	9300      	str	r3, [sp, #0]
c0d01e08:	4803      	ldr	r0, [pc, #12]	; (c0d01e18 <vsnprintf_+0x1c>)
c0d01e0a:	4478      	add	r0, pc
c0d01e0c:	4623      	mov	r3, r4
c0d01e0e:	f7ff fd5b 	bl	c0d018c8 <_vsnprintf>
c0d01e12:	b002      	add	sp, #8
c0d01e14:	bd10      	pop	{r4, pc}
c0d01e16:	46c0      	nop			; (mov r8, r8)
c0d01e18:	ffffffe5 	.word	0xffffffe5

c0d01e1c <_out_null>:
}
c0d01e1c:	4770      	bx	lr

c0d01e1e <_ntoa_long_long>:
                              unsigned int flags) {
c0d01e1e:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01e20:	b09d      	sub	sp, #116	; 0x74
c0d01e22:	9d23      	ldr	r5, [sp, #140]	; 0x8c
c0d01e24:	9f22      	ldr	r7, [sp, #136]	; 0x88
c0d01e26:	9714      	str	r7, [sp, #80]	; 0x50
    if (!value) {
c0d01e28:	432f      	orrs	r7, r5
c0d01e2a:	9c2a      	ldr	r4, [sp, #168]	; 0xa8
c0d01e2c:	900c      	str	r0, [sp, #48]	; 0x30
c0d01e2e:	d103      	bne.n	c0d01e38 <_ntoa_long_long+0x1a>
c0d01e30:	4620      	mov	r0, r4
c0d01e32:	2410      	movs	r4, #16
c0d01e34:	43a0      	bics	r0, r4
c0d01e36:	4604      	mov	r4, r0
c0d01e38:	9826      	ldr	r0, [sp, #152]	; 0x98
c0d01e3a:	9011      	str	r0, [sp, #68]	; 0x44
c0d01e3c:	9829      	ldr	r0, [sp, #164]	; 0xa4
c0d01e3e:	9008      	str	r0, [sp, #32]
c0d01e40:	9828      	ldr	r0, [sp, #160]	; 0xa0
c0d01e42:	9009      	str	r0, [sp, #36]	; 0x24
c0d01e44:	9824      	ldr	r0, [sp, #144]	; 0x90
    if (!(flags & FLAGS_PRECISION) || value) {
c0d01e46:	900a      	str	r0, [sp, #40]	; 0x28
c0d01e48:	2f00      	cmp	r7, #0
c0d01e4a:	930f      	str	r3, [sp, #60]	; 0x3c
c0d01e4c:	920e      	str	r2, [sp, #56]	; 0x38
c0d01e4e:	910d      	str	r1, [sp, #52]	; 0x34
c0d01e50:	940b      	str	r4, [sp, #44]	; 0x2c
c0d01e52:	d106      	bne.n	c0d01e62 <_ntoa_long_long+0x44>
c0d01e54:	2001      	movs	r0, #1
c0d01e56:	0280      	lsls	r0, r0, #10
c0d01e58:	4020      	ands	r0, r4
c0d01e5a:	d002      	beq.n	c0d01e62 <_ntoa_long_long+0x44>
c0d01e5c:	2400      	movs	r4, #0
c0d01e5e:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d01e60:	e02c      	b.n	c0d01ebc <_ntoa_long_long+0x9e>
c0d01e62:	9e27      	ldr	r6, [sp, #156]	; 0x9c
c0d01e64:	2020      	movs	r0, #32
c0d01e66:	4020      	ands	r0, r4
c0d01e68:	2161      	movs	r1, #97	; 0x61
c0d01e6a:	4041      	eors	r1, r0
c0d01e6c:	31f6      	adds	r1, #246	; 0xf6
c0d01e6e:	9110      	str	r1, [sp, #64]	; 0x40
c0d01e70:	2400      	movs	r4, #0
c0d01e72:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d01e74:	9814      	ldr	r0, [sp, #80]	; 0x50
            value /= base;
c0d01e76:	9014      	str	r0, [sp, #80]	; 0x50
c0d01e78:	4629      	mov	r1, r5
c0d01e7a:	4617      	mov	r7, r2
c0d01e7c:	4633      	mov	r3, r6
c0d01e7e:	f000 ff5f 	bl	c0d02d40 <__aeabi_uldivmod>
c0d01e82:	9013      	str	r0, [sp, #76]	; 0x4c
c0d01e84:	9112      	str	r1, [sp, #72]	; 0x48
c0d01e86:	463a      	mov	r2, r7
c0d01e88:	4637      	mov	r7, r6
c0d01e8a:	4633      	mov	r3, r6
c0d01e8c:	f000 ff78 	bl	c0d02d80 <__aeabi_lmul>
c0d01e90:	9b14      	ldr	r3, [sp, #80]	; 0x50
c0d01e92:	1a18      	subs	r0, r3, r0
c0d01e94:	21fe      	movs	r1, #254	; 0xfe
                digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
c0d01e96:	4001      	ands	r1, r0
c0d01e98:	290a      	cmp	r1, #10
c0d01e9a:	d301      	bcc.n	c0d01ea0 <_ntoa_long_long+0x82>
c0d01e9c:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d01e9e:	e000      	b.n	c0d01ea2 <_ntoa_long_long+0x84>
c0d01ea0:	2130      	movs	r1, #48	; 0x30
c0d01ea2:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d01ea4:	463e      	mov	r6, r7
c0d01ea6:	1808      	adds	r0, r1, r0
c0d01ea8:	a915      	add	r1, sp, #84	; 0x54
            buf[len++] =
c0d01eaa:	5508      	strb	r0, [r1, r4]
c0d01eac:	1c64      	adds	r4, r4, #1
        } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
c0d01eae:	2c1f      	cmp	r4, #31
c0d01eb0:	d804      	bhi.n	c0d01ebc <_ntoa_long_long+0x9e>
c0d01eb2:	1a98      	subs	r0, r3, r2
c0d01eb4:	41b5      	sbcs	r5, r6
c0d01eb6:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01eb8:	9d12      	ldr	r5, [sp, #72]	; 0x48
c0d01eba:	d2dc      	bcs.n	c0d01e76 <_ntoa_long_long+0x58>
    return _ntoa_format(out,
c0d01ebc:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d01ebe:	9006      	str	r0, [sp, #24]
c0d01ec0:	9808      	ldr	r0, [sp, #32]
c0d01ec2:	9005      	str	r0, [sp, #20]
c0d01ec4:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01ec6:	9004      	str	r0, [sp, #16]
c0d01ec8:	9203      	str	r2, [sp, #12]
c0d01eca:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d01ecc:	9002      	str	r0, [sp, #8]
c0d01ece:	9401      	str	r4, [sp, #4]
c0d01ed0:	a815      	add	r0, sp, #84	; 0x54
c0d01ed2:	9000      	str	r0, [sp, #0]
c0d01ed4:	ab0c      	add	r3, sp, #48	; 0x30
c0d01ed6:	cb0f      	ldmia	r3, {r0, r1, r2, r3}
c0d01ed8:	f000 fc2e 	bl	c0d02738 <_ntoa_format>
c0d01edc:	b01d      	add	sp, #116	; 0x74
c0d01ede:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d01ee0 <_ntoa_long>:
                         unsigned int flags) {
c0d01ee0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01ee2:	b097      	sub	sp, #92	; 0x5c
c0d01ee4:	9e21      	ldr	r6, [sp, #132]	; 0x84
c0d01ee6:	9d1c      	ldr	r5, [sp, #112]	; 0x70
    if (!value) {
c0d01ee8:	2d00      	cmp	r5, #0
c0d01eea:	930e      	str	r3, [sp, #56]	; 0x38
c0d01eec:	900b      	str	r0, [sp, #44]	; 0x2c
c0d01eee:	d101      	bne.n	c0d01ef4 <_ntoa_long+0x14>
c0d01ef0:	2010      	movs	r0, #16
c0d01ef2:	4386      	bics	r6, r0
c0d01ef4:	9820      	ldr	r0, [sp, #128]	; 0x80
c0d01ef6:	9007      	str	r0, [sp, #28]
c0d01ef8:	af1d      	add	r7, sp, #116	; 0x74
c0d01efa:	cf98      	ldmia	r7, {r3, r4, r7}
    if (!(flags & FLAGS_PRECISION) || value) {
c0d01efc:	2d00      	cmp	r5, #0
c0d01efe:	920d      	str	r2, [sp, #52]	; 0x34
c0d01f00:	910c      	str	r1, [sp, #48]	; 0x30
c0d01f02:	960a      	str	r6, [sp, #40]	; 0x28
c0d01f04:	9309      	str	r3, [sp, #36]	; 0x24
c0d01f06:	9708      	str	r7, [sp, #32]
c0d01f08:	d105      	bne.n	c0d01f16 <_ntoa_long+0x36>
c0d01f0a:	2001      	movs	r0, #1
c0d01f0c:	0280      	lsls	r0, r0, #10
c0d01f0e:	4030      	ands	r0, r6
c0d01f10:	d001      	beq.n	c0d01f16 <_ntoa_long+0x36>
c0d01f12:	2700      	movs	r7, #0
c0d01f14:	e01c      	b.n	c0d01f50 <_ntoa_long+0x70>
c0d01f16:	2020      	movs	r0, #32
c0d01f18:	4030      	ands	r0, r6
c0d01f1a:	2661      	movs	r6, #97	; 0x61
c0d01f1c:	4046      	eors	r6, r0
c0d01f1e:	36f6      	adds	r6, #246	; 0xf6
c0d01f20:	2700      	movs	r7, #0
            value /= base;
c0d01f22:	4628      	mov	r0, r5
c0d01f24:	4621      	mov	r1, r4
c0d01f26:	f000 fd57 	bl	c0d029d8 <__udivsi3>
c0d01f2a:	4621      	mov	r1, r4
c0d01f2c:	4341      	muls	r1, r0
c0d01f2e:	1a69      	subs	r1, r5, r1
c0d01f30:	22fe      	movs	r2, #254	; 0xfe
                digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
c0d01f32:	400a      	ands	r2, r1
c0d01f34:	2a0a      	cmp	r2, #10
c0d01f36:	d301      	bcc.n	c0d01f3c <_ntoa_long+0x5c>
c0d01f38:	4632      	mov	r2, r6
c0d01f3a:	e000      	b.n	c0d01f3e <_ntoa_long+0x5e>
c0d01f3c:	2230      	movs	r2, #48	; 0x30
c0d01f3e:	1889      	adds	r1, r1, r2
c0d01f40:	aa0f      	add	r2, sp, #60	; 0x3c
            buf[len++] =
c0d01f42:	55d1      	strb	r1, [r2, r7]
c0d01f44:	1c7f      	adds	r7, r7, #1
        } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
c0d01f46:	2f1f      	cmp	r7, #31
c0d01f48:	d802      	bhi.n	c0d01f50 <_ntoa_long+0x70>
c0d01f4a:	42a5      	cmp	r5, r4
c0d01f4c:	4605      	mov	r5, r0
c0d01f4e:	d2e8      	bcs.n	c0d01f22 <_ntoa_long+0x42>
    return _ntoa_format(out,
c0d01f50:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d01f52:	9006      	str	r0, [sp, #24]
c0d01f54:	9807      	ldr	r0, [sp, #28]
c0d01f56:	9005      	str	r0, [sp, #20]
c0d01f58:	9808      	ldr	r0, [sp, #32]
c0d01f5a:	9004      	str	r0, [sp, #16]
c0d01f5c:	9403      	str	r4, [sp, #12]
c0d01f5e:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01f60:	9002      	str	r0, [sp, #8]
c0d01f62:	9701      	str	r7, [sp, #4]
c0d01f64:	a80f      	add	r0, sp, #60	; 0x3c
c0d01f66:	9000      	str	r0, [sp, #0]
c0d01f68:	ab0b      	add	r3, sp, #44	; 0x2c
c0d01f6a:	cb0f      	ldmia	r3, {r0, r1, r2, r3}
c0d01f6c:	f000 fbe4 	bl	c0d02738 <_ntoa_format>
c0d01f70:	b017      	add	sp, #92	; 0x5c
c0d01f72:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d01f74 <_ftoa>:
                    unsigned int flags) {
c0d01f74:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01f76:	b09d      	sub	sp, #116	; 0x74
c0d01f78:	9313      	str	r3, [sp, #76]	; 0x4c
c0d01f7a:	9214      	str	r2, [sp, #80]	; 0x50
c0d01f7c:	460f      	mov	r7, r1
c0d01f7e:	4604      	mov	r4, r0
c0d01f80:	9d22      	ldr	r5, [sp, #136]	; 0x88
c0d01f82:	9e23      	ldr	r6, [sp, #140]	; 0x8c
    if (value != value) return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
c0d01f84:	4628      	mov	r0, r5
c0d01f86:	4631      	mov	r1, r6
c0d01f88:	462a      	mov	r2, r5
c0d01f8a:	4633      	mov	r3, r6
c0d01f8c:	f002 fd4e 	bl	c0d04a2c <__aeabi_dcmpun>
c0d01f90:	9a26      	ldr	r2, [sp, #152]	; 0x98
c0d01f92:	9b25      	ldr	r3, [sp, #148]	; 0x94
c0d01f94:	2800      	cmp	r0, #0
c0d01f96:	d119      	bne.n	c0d01fcc <_ftoa+0x58>
c0d01f98:	9711      	str	r7, [sp, #68]	; 0x44
c0d01f9a:	9310      	str	r3, [sp, #64]	; 0x40
c0d01f9c:	9212      	str	r2, [sp, #72]	; 0x48
c0d01f9e:	940f      	str	r4, [sp, #60]	; 0x3c
c0d01fa0:	2000      	movs	r0, #0
c0d01fa2:	43c4      	mvns	r4, r0
c0d01fa4:	4be1      	ldr	r3, [pc, #900]	; (c0d0232c <_ftoa+0x3b8>)
    if (value < -DBL_MAX) return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
c0d01fa6:	4628      	mov	r0, r5
c0d01fa8:	4631      	mov	r1, r6
c0d01faa:	4622      	mov	r2, r4
c0d01fac:	f000 fea0 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d01fb0:	2800      	cmp	r0, #0
c0d01fb2:	d01a      	beq.n	c0d01fea <_ftoa+0x76>
c0d01fb4:	2004      	movs	r0, #4
c0d01fb6:	49e3      	ldr	r1, [pc, #908]	; (c0d02344 <_ftoa+0x3d0>)
c0d01fb8:	4479      	add	r1, pc
c0d01fba:	9100      	str	r1, [sp, #0]
c0d01fbc:	9001      	str	r0, [sp, #4]
c0d01fbe:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d01fc0:	9002      	str	r0, [sp, #8]
c0d01fc2:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d01fc4:	9003      	str	r0, [sp, #12]
c0d01fc6:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d01fc8:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d01fca:	e008      	b.n	c0d01fde <_ftoa+0x6a>
c0d01fcc:	2003      	movs	r0, #3
    if (value != value) return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
c0d01fce:	49dc      	ldr	r1, [pc, #880]	; (c0d02340 <_ftoa+0x3cc>)
c0d01fd0:	4479      	add	r1, pc
c0d01fd2:	9100      	str	r1, [sp, #0]
c0d01fd4:	9001      	str	r0, [sp, #4]
c0d01fd6:	9302      	str	r3, [sp, #8]
c0d01fd8:	9203      	str	r2, [sp, #12]
c0d01fda:	4620      	mov	r0, r4
c0d01fdc:	4639      	mov	r1, r7
c0d01fde:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d01fe0:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d01fe2:	f000 fc4c 	bl	c0d0287e <_out_rev>
}
c0d01fe6:	b01d      	add	sp, #116	; 0x74
c0d01fe8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01fea:	4bd1      	ldr	r3, [pc, #836]	; (c0d02330 <_ftoa+0x3bc>)
    if (value > DBL_MAX)
c0d01fec:	4628      	mov	r0, r5
c0d01fee:	4631      	mov	r1, r6
c0d01ff0:	4622      	mov	r2, r4
c0d01ff2:	f000 fe91 	bl	c0d02d18 <__aeabi_dcmpgt>
c0d01ff6:	2800      	cmp	r0, #0
c0d01ff8:	d012      	beq.n	c0d02020 <_ftoa+0xac>
        return _out_rev(out,
c0d01ffa:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d01ffc:	9002      	str	r0, [sp, #8]
c0d01ffe:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d02000:	9103      	str	r1, [sp, #12]
c0d02002:	2004      	movs	r0, #4
                        (flags & FLAGS_PLUS) ? "fni+" : "fni",
c0d02004:	4001      	ands	r1, r0
                        (flags & FLAGS_PLUS) ? 4U : 3U,
c0d02006:	d100      	bne.n	c0d0200a <_ftoa+0x96>
c0d02008:	2003      	movs	r0, #3
        return _out_rev(out,
c0d0200a:	9001      	str	r0, [sp, #4]
                        (flags & FLAGS_PLUS) ? "fni+" : "fni",
c0d0200c:	2900      	cmp	r1, #0
c0d0200e:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d02010:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d02012:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d02014:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d02016:	d000      	beq.n	c0d0201a <_ftoa+0xa6>
c0d02018:	e088      	b.n	c0d0212c <_ftoa+0x1b8>
c0d0201a:	4ccc      	ldr	r4, [pc, #816]	; (c0d0234c <_ftoa+0x3d8>)
c0d0201c:	447c      	add	r4, pc
c0d0201e:	e087      	b.n	c0d02130 <_ftoa+0x1bc>
c0d02020:	9824      	ldr	r0, [sp, #144]	; 0x90
    if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
c0d02022:	900c      	str	r0, [sp, #48]	; 0x30
c0d02024:	2200      	movs	r2, #0
c0d02026:	4bc3      	ldr	r3, [pc, #780]	; (c0d02334 <_ftoa+0x3c0>)
c0d02028:	4628      	mov	r0, r5
c0d0202a:	4631      	mov	r1, r6
c0d0202c:	f000 fe74 	bl	c0d02d18 <__aeabi_dcmpgt>
c0d02030:	2800      	cmp	r0, #0
c0d02032:	d17f      	bne.n	c0d02134 <_ftoa+0x1c0>
c0d02034:	2700      	movs	r7, #0
c0d02036:	4bc0      	ldr	r3, [pc, #768]	; (c0d02338 <_ftoa+0x3c4>)
c0d02038:	4628      	mov	r0, r5
c0d0203a:	4631      	mov	r1, r6
c0d0203c:	463a      	mov	r2, r7
c0d0203e:	f000 fe57 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d02042:	2800      	cmp	r0, #0
c0d02044:	d176      	bne.n	c0d02134 <_ftoa+0x1c0>
    if (value < 0) {
c0d02046:	4628      	mov	r0, r5
c0d02048:	4631      	mov	r1, r6
c0d0204a:	463a      	mov	r2, r7
c0d0204c:	463b      	mov	r3, r7
c0d0204e:	f000 fe4f 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d02052:	4604      	mov	r4, r0
c0d02054:	4638      	mov	r0, r7
c0d02056:	970e      	str	r7, [sp, #56]	; 0x38
c0d02058:	4639      	mov	r1, r7
c0d0205a:	462a      	mov	r2, r5
c0d0205c:	960b      	str	r6, [sp, #44]	; 0x2c
c0d0205e:	4633      	mov	r3, r6
c0d02060:	f002 f952 	bl	c0d04308 <__aeabi_dsub>
c0d02064:	900d      	str	r0, [sp, #52]	; 0x34
c0d02066:	460f      	mov	r7, r1
c0d02068:	2c00      	cmp	r4, #0
c0d0206a:	d100      	bne.n	c0d0206e <_ftoa+0xfa>
c0d0206c:	9f0b      	ldr	r7, [sp, #44]	; 0x2c
c0d0206e:	2c00      	cmp	r4, #0
c0d02070:	9e0c      	ldr	r6, [sp, #48]	; 0x30
c0d02072:	d100      	bne.n	c0d02076 <_ftoa+0x102>
c0d02074:	950d      	str	r5, [sp, #52]	; 0x34
    if (!(flags & FLAGS_PRECISION)) {
c0d02076:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d02078:	0540      	lsls	r0, r0, #21
c0d0207a:	d400      	bmi.n	c0d0207e <_ftoa+0x10a>
c0d0207c:	2606      	movs	r6, #6
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d0207e:	2e0a      	cmp	r6, #10
c0d02080:	950a      	str	r5, [sp, #40]	; 0x28
c0d02082:	d313      	bcc.n	c0d020ac <_ftoa+0x138>
c0d02084:	4630      	mov	r0, r6
c0d02086:	380a      	subs	r0, #10
c0d02088:	281f      	cmp	r0, #31
c0d0208a:	d300      	bcc.n	c0d0208e <_ftoa+0x11a>
c0d0208c:	201f      	movs	r0, #31
c0d0208e:	1c41      	adds	r1, r0, #1
c0d02090:	a815      	add	r0, sp, #84	; 0x54
c0d02092:	2230      	movs	r2, #48	; 0x30
        buf[len++] = '0';
c0d02094:	f002 fdab 	bl	c0d04bee <__aeabi_memset>
c0d02098:	2001      	movs	r0, #1
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d0209a:	1c41      	adds	r1, r0, #1
        prec--;
c0d0209c:	1e76      	subs	r6, r6, #1
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d0209e:	2e0a      	cmp	r6, #10
c0d020a0:	d302      	bcc.n	c0d020a8 <_ftoa+0x134>
c0d020a2:	2820      	cmp	r0, #32
c0d020a4:	4608      	mov	r0, r1
c0d020a6:	d3f8      	bcc.n	c0d0209a <_ftoa+0x126>
    int whole = (int) value;
c0d020a8:	1e48      	subs	r0, r1, #1
c0d020aa:	900e      	str	r0, [sp, #56]	; 0x38
c0d020ac:	9d0d      	ldr	r5, [sp, #52]	; 0x34
c0d020ae:	4628      	mov	r0, r5
c0d020b0:	4639      	mov	r1, r7
c0d020b2:	f002 fcd9 	bl	c0d04a68 <__aeabi_d2iz>
c0d020b6:	463c      	mov	r4, r7
c0d020b8:	4607      	mov	r7, r0
    double tmp = (value - whole) * pow10[prec];
c0d020ba:	f002 fd0b 	bl	c0d04ad4 <__aeabi_i2d>
c0d020be:	4602      	mov	r2, r0
c0d020c0:	460b      	mov	r3, r1
c0d020c2:	4628      	mov	r0, r5
c0d020c4:	9406      	str	r4, [sp, #24]
c0d020c6:	4621      	mov	r1, r4
c0d020c8:	f002 f91e 	bl	c0d04308 <__aeabi_dsub>
c0d020cc:	00f4      	lsls	r4, r6, #3
c0d020ce:	4ba0      	ldr	r3, [pc, #640]	; (c0d02350 <_ftoa+0x3dc>)
c0d020d0:	447b      	add	r3, pc
c0d020d2:	591a      	ldr	r2, [r3, r4]
c0d020d4:	191b      	adds	r3, r3, r4
c0d020d6:	685b      	ldr	r3, [r3, #4]
c0d020d8:	9209      	str	r2, [sp, #36]	; 0x24
c0d020da:	9308      	str	r3, [sp, #32]
c0d020dc:	f001 fea6 	bl	c0d03e2c <__aeabi_dmul>
c0d020e0:	4604      	mov	r4, r0
    unsigned long frac = (unsigned long) tmp;
c0d020e2:	910c      	str	r1, [sp, #48]	; 0x30
c0d020e4:	f000 fe7a 	bl	c0d02ddc <__aeabi_d2uiz>
c0d020e8:	4605      	mov	r5, r0
    diff = tmp - frac;
c0d020ea:	f002 fd23 	bl	c0d04b34 <__aeabi_ui2d>
c0d020ee:	4602      	mov	r2, r0
c0d020f0:	460b      	mov	r3, r1
c0d020f2:	4620      	mov	r0, r4
c0d020f4:	990c      	ldr	r1, [sp, #48]	; 0x30
c0d020f6:	f002 f907 	bl	c0d04308 <__aeabi_dsub>
c0d020fa:	2400      	movs	r4, #0
c0d020fc:	4b8f      	ldr	r3, [pc, #572]	; (c0d0233c <_ftoa+0x3c8>)
c0d020fe:	900c      	str	r0, [sp, #48]	; 0x30
c0d02100:	9107      	str	r1, [sp, #28]
    if (diff > 0.5) {
c0d02102:	4622      	mov	r2, r4
c0d02104:	f000 fe08 	bl	c0d02d18 <__aeabi_dcmpgt>
c0d02108:	2800      	cmp	r0, #0
c0d0210a:	d022      	beq.n	c0d02152 <_ftoa+0x1de>
        ++frac;
c0d0210c:	1c6d      	adds	r5, r5, #1
        if (frac >= pow10[prec]) {
c0d0210e:	4628      	mov	r0, r5
c0d02110:	f002 fd10 	bl	c0d04b34 <__aeabi_ui2d>
c0d02114:	4602      	mov	r2, r0
c0d02116:	460b      	mov	r3, r1
c0d02118:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d0211a:	9908      	ldr	r1, [sp, #32]
c0d0211c:	f000 fdf2 	bl	c0d02d04 <__aeabi_dcmple>
c0d02120:	2800      	cmp	r0, #0
c0d02122:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d02124:	d024      	beq.n	c0d02170 <_ftoa+0x1fc>
            ++whole;
c0d02126:	1c7f      	adds	r7, r7, #1
c0d02128:	2500      	movs	r5, #0
c0d0212a:	e021      	b.n	c0d02170 <_ftoa+0x1fc>
c0d0212c:	4c86      	ldr	r4, [pc, #536]	; (c0d02348 <_ftoa+0x3d4>)
c0d0212e:	447c      	add	r4, pc
        return _out_rev(out,
c0d02130:	9400      	str	r4, [sp, #0]
c0d02132:	e756      	b.n	c0d01fe2 <_ftoa+0x6e>
        return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
c0d02134:	9500      	str	r5, [sp, #0]
c0d02136:	9601      	str	r6, [sp, #4]
c0d02138:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d0213a:	9002      	str	r0, [sp, #8]
c0d0213c:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d0213e:	9003      	str	r0, [sp, #12]
c0d02140:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d02142:	9004      	str	r0, [sp, #16]
c0d02144:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d02146:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d02148:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d0214a:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d0214c:	f000 f902 	bl	c0d02354 <_etoa>
c0d02150:	e749      	b.n	c0d01fe6 <_ftoa+0x72>
c0d02152:	2200      	movs	r2, #0
c0d02154:	4b79      	ldr	r3, [pc, #484]	; (c0d0233c <_ftoa+0x3c8>)
    } else if (diff < 0.5) {
c0d02156:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d02158:	9907      	ldr	r1, [sp, #28]
c0d0215a:	f000 fdc9 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d0215e:	2800      	cmp	r0, #0
c0d02160:	d105      	bne.n	c0d0216e <_ftoa+0x1fa>
    } else if ((frac == 0U) || (frac & 1U)) {
c0d02162:	4268      	negs	r0, r5
c0d02164:	4168      	adcs	r0, r5
c0d02166:	2101      	movs	r1, #1
c0d02168:	4029      	ands	r1, r5
c0d0216a:	4301      	orrs	r1, r0
c0d0216c:	194d      	adds	r5, r1, r5
c0d0216e:	9b0e      	ldr	r3, [sp, #56]	; 0x38
    if (prec == 0U) {
c0d02170:	2e00      	cmp	r6, #0
c0d02172:	d01b      	beq.n	c0d021ac <_ftoa+0x238>
c0d02174:	960c      	str	r6, [sp, #48]	; 0x30
c0d02176:	a815      	add	r0, sp, #84	; 0x54
        while (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d02178:	18c0      	adds	r0, r0, r3
c0d0217a:	900d      	str	r0, [sp, #52]	; 0x34
c0d0217c:	1918      	adds	r0, r3, r4
c0d0217e:	2820      	cmp	r0, #32
c0d02180:	d028      	beq.n	c0d021d4 <_ftoa+0x260>
c0d02182:	260a      	movs	r6, #10
            if (!(frac /= 10U)) {
c0d02184:	4628      	mov	r0, r5
c0d02186:	4631      	mov	r1, r6
c0d02188:	f000 fc26 	bl	c0d029d8 <__udivsi3>
c0d0218c:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d0218e:	4346      	muls	r6, r0
c0d02190:	1baa      	subs	r2, r5, r6
c0d02192:	2130      	movs	r1, #48	; 0x30
            buf[len++] = (char) (48U + (frac % 10U));
c0d02194:	430a      	orrs	r2, r1
c0d02196:	9e0d      	ldr	r6, [sp, #52]	; 0x34
c0d02198:	5532      	strb	r2, [r6, r4]
            if (!(frac /= 10U)) {
c0d0219a:	1c64      	adds	r4, r4, #1
c0d0219c:	2d09      	cmp	r5, #9
c0d0219e:	4605      	mov	r5, r0
c0d021a0:	d8ec      	bhi.n	c0d0217c <_ftoa+0x208>
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d021a2:	191a      	adds	r2, r3, r4
c0d021a4:	2a20      	cmp	r2, #32
c0d021a6:	d318      	bcc.n	c0d021da <_ftoa+0x266>
c0d021a8:	2000      	movs	r0, #0
c0d021aa:	e017      	b.n	c0d021dc <_ftoa+0x268>
        diff = value - (double) whole;
c0d021ac:	4638      	mov	r0, r7
c0d021ae:	f002 fc91 	bl	c0d04ad4 <__aeabi_i2d>
c0d021b2:	4602      	mov	r2, r0
c0d021b4:	460b      	mov	r3, r1
c0d021b6:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d021b8:	9906      	ldr	r1, [sp, #24]
c0d021ba:	f002 f8a5 	bl	c0d04308 <__aeabi_dsub>
c0d021be:	2200      	movs	r2, #0
c0d021c0:	4b5e      	ldr	r3, [pc, #376]	; (c0d0233c <_ftoa+0x3c8>)
        if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
c0d021c2:	f000 fd95 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d021c6:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d021c8:	4241      	negs	r1, r0
c0d021ca:	4141      	adcs	r1, r0
c0d021cc:	4039      	ands	r1, r7
c0d021ce:	187f      	adds	r7, r7, r1
c0d021d0:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d021d2:	e02f      	b.n	c0d02234 <_ftoa+0x2c0>
c0d021d4:	2320      	movs	r3, #32
c0d021d6:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d021d8:	e02c      	b.n	c0d02234 <_ftoa+0x2c0>
c0d021da:	2001      	movs	r0, #1
c0d021dc:	900d      	str	r0, [sp, #52]	; 0x34
c0d021de:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d021e0:	9e0c      	ldr	r6, [sp, #48]	; 0x30
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d021e2:	2a1f      	cmp	r2, #31
c0d021e4:	d81d      	bhi.n	c0d02222 <_ftoa+0x2ae>
c0d021e6:	42a6      	cmp	r6, r4
c0d021e8:	d01b      	beq.n	c0d02222 <_ftoa+0x2ae>
            buf[len++] = '0';
c0d021ea:	1918      	adds	r0, r3, r4
c0d021ec:	900c      	str	r0, [sp, #48]	; 0x30
c0d021ee:	a815      	add	r0, sp, #84	; 0x54
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d021f0:	18c3      	adds	r3, r0, r3
c0d021f2:	43e0      	mvns	r0, r4
c0d021f4:	1985      	adds	r5, r0, r6
c0d021f6:	2600      	movs	r6, #0
c0d021f8:	960e      	str	r6, [sp, #56]	; 0x38
            buf[len++] = '0';
c0d021fa:	1998      	adds	r0, r3, r6
c0d021fc:	5501      	strb	r1, [r0, r4]
c0d021fe:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d02200:	1980      	adds	r0, r0, r6
c0d02202:	1c40      	adds	r0, r0, #1
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d02204:	2820      	cmp	r0, #32
c0d02206:	d301      	bcc.n	c0d0220c <_ftoa+0x298>
c0d02208:	9a0e      	ldr	r2, [sp, #56]	; 0x38
c0d0220a:	e000      	b.n	c0d0220e <_ftoa+0x29a>
c0d0220c:	2201      	movs	r2, #1
c0d0220e:	920d      	str	r2, [sp, #52]	; 0x34
c0d02210:	1c72      	adds	r2, r6, #1
c0d02212:	281f      	cmp	r0, #31
c0d02214:	d802      	bhi.n	c0d0221c <_ftoa+0x2a8>
c0d02216:	42b5      	cmp	r5, r6
c0d02218:	4616      	mov	r6, r2
c0d0221a:	d1ee      	bne.n	c0d021fa <_ftoa+0x286>
        if (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d0221c:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d0221e:	1882      	adds	r2, r0, r2
c0d02220:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d02222:	990d      	ldr	r1, [sp, #52]	; 0x34
c0d02224:	2900      	cmp	r1, #0
c0d02226:	d004      	beq.n	c0d02232 <_ftoa+0x2be>
c0d02228:	a815      	add	r0, sp, #84	; 0x54
c0d0222a:	212e      	movs	r1, #46	; 0x2e
            buf[len++] = '.';
c0d0222c:	5481      	strb	r1, [r0, r2]
c0d0222e:	1c53      	adds	r3, r2, #1
c0d02230:	e000      	b.n	c0d02234 <_ftoa+0x2c0>
c0d02232:	4613      	mov	r3, r2
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d02234:	2b1f      	cmp	r3, #31
c0d02236:	d810      	bhi.n	c0d0225a <_ftoa+0x2e6>
c0d02238:	240a      	movs	r4, #10
        if (!(whole /= 10)) {
c0d0223a:	4638      	mov	r0, r7
c0d0223c:	4621      	mov	r1, r4
c0d0223e:	461e      	mov	r6, r3
c0d02240:	f000 fc54 	bl	c0d02aec <__divsi3>
c0d02244:	4633      	mov	r3, r6
c0d02246:	4344      	muls	r4, r0
c0d02248:	1b39      	subs	r1, r7, r4
        buf[len++] = (char) (48 + (whole % 10));
c0d0224a:	3130      	adds	r1, #48	; 0x30
c0d0224c:	aa15      	add	r2, sp, #84	; 0x54
c0d0224e:	5591      	strb	r1, [r2, r6]
c0d02250:	1c73      	adds	r3, r6, #1
        if (!(whole /= 10)) {
c0d02252:	3709      	adds	r7, #9
c0d02254:	2f12      	cmp	r7, #18
c0d02256:	4607      	mov	r7, r0
c0d02258:	d8ec      	bhi.n	c0d02234 <_ftoa+0x2c0>
c0d0225a:	2003      	movs	r0, #3
c0d0225c:	9f12      	ldr	r7, [sp, #72]	; 0x48
    if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
c0d0225e:	4038      	ands	r0, r7
c0d02260:	2801      	cmp	r0, #1
c0d02262:	d115      	bne.n	c0d02290 <_ftoa+0x31c>
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d02264:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d02266:	2800      	cmp	r0, #0
c0d02268:	d017      	beq.n	c0d0229a <_ftoa+0x326>
c0d0226a:	2200      	movs	r2, #0
    if (value < 0) {
c0d0226c:	4628      	mov	r0, r5
c0d0226e:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d02270:	4631      	mov	r1, r6
c0d02272:	461d      	mov	r5, r3
c0d02274:	4613      	mov	r3, r2
c0d02276:	f000 fd3b 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d0227a:	462b      	mov	r3, r5
c0d0227c:	9c10      	ldr	r4, [sp, #64]	; 0x40
c0d0227e:	210c      	movs	r1, #12
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d02280:	4039      	ands	r1, r7
    if (value < 0) {
c0d02282:	4301      	orrs	r1, r0
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d02284:	1e48      	subs	r0, r1, #1
c0d02286:	4181      	sbcs	r1, r0
c0d02288:	1a64      	subs	r4, r4, r1
c0d0228a:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d0228c:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d0228e:	e008      	b.n	c0d022a2 <_ftoa+0x32e>
c0d02290:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d02292:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d02294:	9c10      	ldr	r4, [sp, #64]	; 0x40
c0d02296:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d02298:	e020      	b.n	c0d022dc <_ftoa+0x368>
c0d0229a:	2400      	movs	r4, #0
c0d0229c:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d0229e:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d022a0:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
        while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
c0d022a2:	42a3      	cmp	r3, r4
c0d022a4:	d21a      	bcs.n	c0d022dc <_ftoa+0x368>
c0d022a6:	2b1f      	cmp	r3, #31
c0d022a8:	d818      	bhi.n	c0d022dc <_ftoa+0x368>
c0d022aa:	201f      	movs	r0, #31
c0d022ac:	1ac0      	subs	r0, r0, r3
c0d022ae:	43d9      	mvns	r1, r3
c0d022b0:	4625      	mov	r5, r4
c0d022b2:	1861      	adds	r1, r4, r1
c0d022b4:	4281      	cmp	r1, r0
c0d022b6:	d300      	bcc.n	c0d022ba <_ftoa+0x346>
c0d022b8:	4601      	mov	r1, r0
c0d022ba:	1c49      	adds	r1, r1, #1
c0d022bc:	a815      	add	r0, sp, #84	; 0x54
c0d022be:	18c0      	adds	r0, r0, r3
c0d022c0:	2230      	movs	r2, #48	; 0x30
c0d022c2:	461e      	mov	r6, r3
            buf[len++] = '0';
c0d022c4:	f002 fc93 	bl	c0d04bee <__aeabi_memset>
c0d022c8:	4633      	mov	r3, r6
c0d022ca:	462c      	mov	r4, r5
c0d022cc:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d022ce:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d022d0:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d022d2:	1c5b      	adds	r3, r3, #1
        while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
c0d022d4:	42a3      	cmp	r3, r4
c0d022d6:	d201      	bcs.n	c0d022dc <_ftoa+0x368>
c0d022d8:	2b20      	cmp	r3, #32
c0d022da:	d3fa      	bcc.n	c0d022d2 <_ftoa+0x35e>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d022dc:	2b1f      	cmp	r3, #31
c0d022de:	d81e      	bhi.n	c0d0231e <_ftoa+0x3aa>
c0d022e0:	461d      	mov	r5, r3
c0d022e2:	2200      	movs	r2, #0
    if (value < 0) {
c0d022e4:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d022e6:	4631      	mov	r1, r6
c0d022e8:	4613      	mov	r3, r2
c0d022ea:	f000 fd01 	bl	c0d02cf0 <__aeabi_dcmplt>
        if (negative) {
c0d022ee:	2800      	cmp	r0, #0
c0d022f0:	d002      	beq.n	c0d022f8 <_ftoa+0x384>
c0d022f2:	a815      	add	r0, sp, #84	; 0x54
c0d022f4:	212d      	movs	r1, #45	; 0x2d
c0d022f6:	e00d      	b.n	c0d02314 <_ftoa+0x3a0>
        } else if (flags & FLAGS_PLUS) {
c0d022f8:	0778      	lsls	r0, r7, #29
c0d022fa:	d409      	bmi.n	c0d02310 <_ftoa+0x39c>
        } else if (flags & FLAGS_SPACE) {
c0d022fc:	0738      	lsls	r0, r7, #28
c0d022fe:	462b      	mov	r3, r5
c0d02300:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d02302:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d02304:	d50b      	bpl.n	c0d0231e <_ftoa+0x3aa>
c0d02306:	a815      	add	r0, sp, #84	; 0x54
c0d02308:	2520      	movs	r5, #32
            buf[len++] = ' ';
c0d0230a:	54c5      	strb	r5, [r0, r3]
c0d0230c:	1c5b      	adds	r3, r3, #1
c0d0230e:	e006      	b.n	c0d0231e <_ftoa+0x3aa>
c0d02310:	a815      	add	r0, sp, #84	; 0x54
c0d02312:	212b      	movs	r1, #43	; 0x2b
c0d02314:	462b      	mov	r3, r5
c0d02316:	5541      	strb	r1, [r0, r5]
c0d02318:	1c6b      	adds	r3, r5, #1
c0d0231a:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d0231c:	9911      	ldr	r1, [sp, #68]	; 0x44
    return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
c0d0231e:	a801      	add	r0, sp, #4
c0d02320:	c098      	stmia	r0!, {r3, r4, r7}
c0d02322:	a815      	add	r0, sp, #84	; 0x54
c0d02324:	9000      	str	r0, [sp, #0]
c0d02326:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d02328:	e65a      	b.n	c0d01fe0 <_ftoa+0x6c>
c0d0232a:	46c0      	nop			; (mov r8, r8)
c0d0232c:	ffefffff 	.word	0xffefffff
c0d02330:	7fefffff 	.word	0x7fefffff
c0d02334:	41cdcd65 	.word	0x41cdcd65
c0d02338:	c1cdcd65 	.word	0xc1cdcd65
c0d0233c:	3fe00000 	.word	0x3fe00000
c0d02340:	00003704 	.word	0x00003704
c0d02344:	00003720 	.word	0x00003720
c0d02348:	000035af 	.word	0x000035af
c0d0234c:	000036c6 	.word	0x000036c6
c0d02350:	000035b4 	.word	0x000035b4

c0d02354 <_etoa>:
                    unsigned int flags) {
c0d02354:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02356:	b097      	sub	sp, #92	; 0x5c
c0d02358:	930e      	str	r3, [sp, #56]	; 0x38
c0d0235a:	920f      	str	r2, [sp, #60]	; 0x3c
c0d0235c:	9112      	str	r1, [sp, #72]	; 0x48
c0d0235e:	4607      	mov	r7, r0
c0d02360:	2000      	movs	r0, #0
c0d02362:	43c4      	mvns	r4, r0
c0d02364:	9d1c      	ldr	r5, [sp, #112]	; 0x70
c0d02366:	9e1d      	ldr	r6, [sp, #116]	; 0x74
c0d02368:	4bd8      	ldr	r3, [pc, #864]	; (c0d026cc <_etoa+0x378>)
    if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
c0d0236a:	4628      	mov	r0, r5
c0d0236c:	4631      	mov	r1, r6
c0d0236e:	4622      	mov	r2, r4
c0d02370:	f000 fcbe 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d02374:	9920      	ldr	r1, [sp, #128]	; 0x80
c0d02376:	9115      	str	r1, [sp, #84]	; 0x54
c0d02378:	991f      	ldr	r1, [sp, #124]	; 0x7c
c0d0237a:	9116      	str	r1, [sp, #88]	; 0x58
c0d0237c:	991e      	ldr	r1, [sp, #120]	; 0x78
c0d0237e:	9113      	str	r1, [sp, #76]	; 0x4c
c0d02380:	2800      	cmp	r0, #0
c0d02382:	d000      	beq.n	c0d02386 <_etoa+0x32>
c0d02384:	e0d2      	b.n	c0d0252c <_etoa+0x1d8>
c0d02386:	4628      	mov	r0, r5
c0d02388:	4631      	mov	r1, r6
c0d0238a:	462a      	mov	r2, r5
c0d0238c:	4633      	mov	r3, r6
c0d0238e:	f002 fb4d 	bl	c0d04a2c <__aeabi_dcmpun>
c0d02392:	2800      	cmp	r0, #0
c0d02394:	d000      	beq.n	c0d02398 <_etoa+0x44>
c0d02396:	e0c9      	b.n	c0d0252c <_etoa+0x1d8>
c0d02398:	4bcd      	ldr	r3, [pc, #820]	; (c0d026d0 <_etoa+0x37c>)
c0d0239a:	4628      	mov	r0, r5
c0d0239c:	4631      	mov	r1, r6
c0d0239e:	4622      	mov	r2, r4
c0d023a0:	f000 fcba 	bl	c0d02d18 <__aeabi_dcmpgt>
c0d023a4:	2800      	cmp	r0, #0
c0d023a6:	d000      	beq.n	c0d023aa <_etoa+0x56>
c0d023a8:	e0c0      	b.n	c0d0252c <_etoa+0x1d8>
c0d023aa:	2200      	movs	r2, #0
c0d023ac:	950d      	str	r5, [sp, #52]	; 0x34
    const bool negative = value < 0;
c0d023ae:	4628      	mov	r0, r5
c0d023b0:	4631      	mov	r1, r6
c0d023b2:	9214      	str	r2, [sp, #80]	; 0x50
c0d023b4:	4613      	mov	r3, r2
c0d023b6:	f000 fc9b 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d023ba:	2101      	movs	r1, #1
c0d023bc:	910b      	str	r1, [sp, #44]	; 0x2c
c0d023be:	07c9      	lsls	r1, r1, #31
    if (negative) {
c0d023c0:	2800      	cmp	r0, #0
c0d023c2:	9709      	str	r7, [sp, #36]	; 0x24
c0d023c4:	9107      	str	r1, [sp, #28]
c0d023c6:	9608      	str	r6, [sp, #32]
c0d023c8:	4630      	mov	r0, r6
c0d023ca:	d000      	beq.n	c0d023ce <_etoa+0x7a>
c0d023cc:	4048      	eors	r0, r1
c0d023ce:	9011      	str	r0, [sp, #68]	; 0x44
c0d023d0:	4ec0      	ldr	r6, [pc, #768]	; (c0d026d4 <_etoa+0x380>)
    conv.U = (conv.U & ((1ULL << 52U) - 1U)) |
c0d023d2:	4006      	ands	r6, r0
    int exp2 = (int) ((conv.U >> 52U) & 0x07FFU) - 1023;  // effectively log2
c0d023d4:	0040      	lsls	r0, r0, #1
c0d023d6:	0d40      	lsrs	r0, r0, #21
c0d023d8:	49bf      	ldr	r1, [pc, #764]	; (c0d026d8 <_etoa+0x384>)
c0d023da:	1840      	adds	r0, r0, r1
        (int) (0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
c0d023dc:	f002 fb7a 	bl	c0d04ad4 <__aeabi_i2d>
c0d023e0:	4abe      	ldr	r2, [pc, #760]	; (c0d026dc <_etoa+0x388>)
c0d023e2:	4bbf      	ldr	r3, [pc, #764]	; (c0d026e0 <_etoa+0x38c>)
c0d023e4:	f001 fd22 	bl	c0d03e2c <__aeabi_dmul>
c0d023e8:	4abe      	ldr	r2, [pc, #760]	; (c0d026e4 <_etoa+0x390>)
c0d023ea:	4bbf      	ldr	r3, [pc, #764]	; (c0d026e8 <_etoa+0x394>)
c0d023ec:	f000 fde0 	bl	c0d02fb0 <__aeabi_dadd>
c0d023f0:	4604      	mov	r4, r0
c0d023f2:	460d      	mov	r5, r1
c0d023f4:	48bd      	ldr	r0, [pc, #756]	; (c0d026ec <_etoa+0x398>)
    conv.U = (conv.U & ((1ULL << 52U) - 1U)) |
c0d023f6:	1831      	adds	r1, r6, r0
c0d023f8:	4bbd      	ldr	r3, [pc, #756]	; (c0d026f0 <_etoa+0x39c>)
        (int) (0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
c0d023fa:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d023fc:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d023fe:	4632      	mov	r2, r6
c0d02400:	f000 fdd6 	bl	c0d02fb0 <__aeabi_dadd>
c0d02404:	4abb      	ldr	r2, [pc, #748]	; (c0d026f4 <_etoa+0x3a0>)
c0d02406:	4bbc      	ldr	r3, [pc, #752]	; (c0d026f8 <_etoa+0x3a4>)
c0d02408:	f001 fd10 	bl	c0d03e2c <__aeabi_dmul>
c0d0240c:	4622      	mov	r2, r4
c0d0240e:	462b      	mov	r3, r5
c0d02410:	f000 fdce 	bl	c0d02fb0 <__aeabi_dadd>
c0d02414:	f002 fb28 	bl	c0d04a68 <__aeabi_d2iz>
c0d02418:	900c      	str	r0, [sp, #48]	; 0x30
    exp2 = (int) (expval * 3.321928094887362 + 0.5);
c0d0241a:	f002 fb5b 	bl	c0d04ad4 <__aeabi_i2d>
c0d0241e:	4604      	mov	r4, r0
c0d02420:	460d      	mov	r5, r1
c0d02422:	4ab6      	ldr	r2, [pc, #728]	; (c0d026fc <_etoa+0x3a8>)
c0d02424:	4bb6      	ldr	r3, [pc, #728]	; (c0d02700 <_etoa+0x3ac>)
c0d02426:	f001 fd01 	bl	c0d03e2c <__aeabi_dmul>
c0d0242a:	4bb6      	ldr	r3, [pc, #728]	; (c0d02704 <_etoa+0x3b0>)
c0d0242c:	4632      	mov	r2, r6
c0d0242e:	f000 fdbf 	bl	c0d02fb0 <__aeabi_dadd>
c0d02432:	f002 fb19 	bl	c0d04a68 <__aeabi_d2iz>
c0d02436:	4606      	mov	r6, r0
    const double z = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
c0d02438:	9010      	str	r0, [sp, #64]	; 0x40
c0d0243a:	4ab3      	ldr	r2, [pc, #716]	; (c0d02708 <_etoa+0x3b4>)
c0d0243c:	4bb3      	ldr	r3, [pc, #716]	; (c0d0270c <_etoa+0x3b8>)
c0d0243e:	4620      	mov	r0, r4
c0d02440:	4629      	mov	r1, r5
c0d02442:	f001 fcf3 	bl	c0d03e2c <__aeabi_dmul>
c0d02446:	4604      	mov	r4, r0
c0d02448:	460d      	mov	r5, r1
c0d0244a:	4630      	mov	r0, r6
c0d0244c:	f002 fb42 	bl	c0d04ad4 <__aeabi_i2d>
c0d02450:	4aaf      	ldr	r2, [pc, #700]	; (c0d02710 <_etoa+0x3bc>)
c0d02452:	4bb0      	ldr	r3, [pc, #704]	; (c0d02714 <_etoa+0x3c0>)
c0d02454:	f001 fcea 	bl	c0d03e2c <__aeabi_dmul>
c0d02458:	4602      	mov	r2, r0
c0d0245a:	460b      	mov	r3, r1
c0d0245c:	4620      	mov	r0, r4
c0d0245e:	4629      	mov	r1, r5
c0d02460:	f000 fda6 	bl	c0d02fb0 <__aeabi_dadd>
c0d02464:	4606      	mov	r6, r0
    const double z2 = z * z;
c0d02466:	910a      	str	r1, [sp, #40]	; 0x28
c0d02468:	4602      	mov	r2, r0
c0d0246a:	460b      	mov	r3, r1
c0d0246c:	f001 fcde 	bl	c0d03e2c <__aeabi_dmul>
c0d02470:	4605      	mov	r5, r0
c0d02472:	460f      	mov	r7, r1
c0d02474:	4ba8      	ldr	r3, [pc, #672]	; (c0d02718 <_etoa+0x3c4>)
c0d02476:	9c14      	ldr	r4, [sp, #80]	; 0x50
    conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
c0d02478:	4622      	mov	r2, r4
c0d0247a:	f001 f8d5 	bl	c0d03628 <__aeabi_ddiv>
c0d0247e:	4ba7      	ldr	r3, [pc, #668]	; (c0d0271c <_etoa+0x3c8>)
c0d02480:	4622      	mov	r2, r4
c0d02482:	f000 fd95 	bl	c0d02fb0 <__aeabi_dadd>
c0d02486:	4602      	mov	r2, r0
c0d02488:	460b      	mov	r3, r1
c0d0248a:	4628      	mov	r0, r5
c0d0248c:	4639      	mov	r1, r7
c0d0248e:	f001 f8cb 	bl	c0d03628 <__aeabi_ddiv>
c0d02492:	4ba3      	ldr	r3, [pc, #652]	; (c0d02720 <_etoa+0x3cc>)
c0d02494:	4622      	mov	r2, r4
c0d02496:	f000 fd8b 	bl	c0d02fb0 <__aeabi_dadd>
c0d0249a:	4602      	mov	r2, r0
c0d0249c:	460b      	mov	r3, r1
c0d0249e:	4628      	mov	r0, r5
c0d024a0:	4639      	mov	r1, r7
c0d024a2:	f001 f8c1 	bl	c0d03628 <__aeabi_ddiv>
c0d024a6:	4605      	mov	r5, r0
c0d024a8:	460f      	mov	r7, r1
c0d024aa:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d024ac:	0781      	lsls	r1, r0, #30
c0d024ae:	4620      	mov	r0, r4
c0d024b0:	4632      	mov	r2, r6
c0d024b2:	9c0a      	ldr	r4, [sp, #40]	; 0x28
c0d024b4:	4623      	mov	r3, r4
c0d024b6:	f001 ff27 	bl	c0d04308 <__aeabi_dsub>
c0d024ba:	462a      	mov	r2, r5
c0d024bc:	463b      	mov	r3, r7
c0d024be:	f000 fd77 	bl	c0d02fb0 <__aeabi_dadd>
c0d024c2:	4605      	mov	r5, r0
c0d024c4:	460f      	mov	r7, r1
c0d024c6:	4630      	mov	r0, r6
c0d024c8:	4621      	mov	r1, r4
c0d024ca:	4632      	mov	r2, r6
c0d024cc:	9e0d      	ldr	r6, [sp, #52]	; 0x34
c0d024ce:	4623      	mov	r3, r4
c0d024d0:	f000 fd6e 	bl	c0d02fb0 <__aeabi_dadd>
c0d024d4:	462a      	mov	r2, r5
c0d024d6:	463b      	mov	r3, r7
c0d024d8:	f001 f8a6 	bl	c0d03628 <__aeabi_ddiv>
c0d024dc:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d024de:	462a      	mov	r2, r5
c0d024e0:	4b82      	ldr	r3, [pc, #520]	; (c0d026ec <_etoa+0x398>)
c0d024e2:	f000 fd65 	bl	c0d02fb0 <__aeabi_dadd>
c0d024e6:	4c8f      	ldr	r4, [pc, #572]	; (c0d02724 <_etoa+0x3d0>)
    conv.U = (uint64_t)(exp2 + 1023) << 52U;
c0d024e8:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d024ea:	1912      	adds	r2, r2, r4
c0d024ec:	0513      	lsls	r3, r2, #20
    conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
c0d024ee:	462a      	mov	r2, r5
c0d024f0:	f001 fc9c 	bl	c0d03e2c <__aeabi_dmul>
c0d024f4:	4602      	mov	r2, r0
c0d024f6:	460b      	mov	r3, r1
    if (value < conv.F) {
c0d024f8:	4630      	mov	r0, r6
c0d024fa:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d024fc:	4617      	mov	r7, r2
c0d024fe:	930a      	str	r3, [sp, #40]	; 0x28
c0d02500:	f000 fbf6 	bl	c0d02cf0 <__aeabi_dcmplt>
    if (!(flags & FLAGS_PRECISION)) {
c0d02504:	1c61      	adds	r1, r4, #1
c0d02506:	9d15      	ldr	r5, [sp, #84]	; 0x54
c0d02508:	400d      	ands	r5, r1
c0d0250a:	9106      	str	r1, [sp, #24]
c0d0250c:	d101      	bne.n	c0d02512 <_etoa+0x1be>
c0d0250e:	2106      	movs	r1, #6
c0d02510:	9113      	str	r1, [sp, #76]	; 0x4c
    if (value < conv.F) {
c0d02512:	2800      	cmp	r0, #0
c0d02514:	d01a      	beq.n	c0d0254c <_etoa+0x1f8>
c0d02516:	2200      	movs	r2, #0
c0d02518:	4b80      	ldr	r3, [pc, #512]	; (c0d0271c <_etoa+0x3c8>)
        conv.F /= 10;
c0d0251a:	4638      	mov	r0, r7
c0d0251c:	990a      	ldr	r1, [sp, #40]	; 0x28
c0d0251e:	f001 f883 	bl	c0d03628 <__aeabi_ddiv>
c0d02522:	4607      	mov	r7, r0
c0d02524:	910a      	str	r1, [sp, #40]	; 0x28
c0d02526:	9a0c      	ldr	r2, [sp, #48]	; 0x30
        expval--;
c0d02528:	1e52      	subs	r2, r2, #1
c0d0252a:	e010      	b.n	c0d0254e <_etoa+0x1fa>
        return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
c0d0252c:	9500      	str	r5, [sp, #0]
c0d0252e:	9601      	str	r6, [sp, #4]
c0d02530:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d02532:	9002      	str	r0, [sp, #8]
c0d02534:	9816      	ldr	r0, [sp, #88]	; 0x58
c0d02536:	9003      	str	r0, [sp, #12]
c0d02538:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d0253a:	9004      	str	r0, [sp, #16]
c0d0253c:	4638      	mov	r0, r7
c0d0253e:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d02540:	9a0f      	ldr	r2, [sp, #60]	; 0x3c
c0d02542:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d02544:	f7ff fd16 	bl	c0d01f74 <_ftoa>
c0d02548:	4604      	mov	r4, r0
c0d0254a:	e0bc      	b.n	c0d026c6 <_etoa+0x372>
c0d0254c:	9a0c      	ldr	r2, [sp, #48]	; 0x30
c0d0254e:	4876      	ldr	r0, [pc, #472]	; (c0d02728 <_etoa+0x3d4>)
    unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
c0d02550:	4611      	mov	r1, r2
c0d02552:	3163      	adds	r1, #99	; 0x63
c0d02554:	29c7      	cmp	r1, #199	; 0xc7
c0d02556:	d301      	bcc.n	c0d0255c <_etoa+0x208>
c0d02558:	2305      	movs	r3, #5
c0d0255a:	e000      	b.n	c0d0255e <_etoa+0x20a>
c0d0255c:	2304      	movs	r3, #4
    if (flags & FLAGS_ADAPT_EXP) {
c0d0255e:	1c40      	adds	r0, r0, #1
c0d02560:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d02562:	4201      	tst	r1, r0
c0d02564:	9310      	str	r3, [sp, #64]	; 0x40
c0d02566:	d018      	beq.n	c0d0259a <_etoa+0x246>
c0d02568:	920c      	str	r2, [sp, #48]	; 0x30
c0d0256a:	4a70      	ldr	r2, [pc, #448]	; (c0d0272c <_etoa+0x3d8>)
c0d0256c:	4b70      	ldr	r3, [pc, #448]	; (c0d02730 <_etoa+0x3dc>)
        if ((value >= 1e-4) && (value < 1e6)) {
c0d0256e:	4630      	mov	r0, r6
c0d02570:	9c11      	ldr	r4, [sp, #68]	; 0x44
c0d02572:	4621      	mov	r1, r4
c0d02574:	f000 fbda 	bl	c0d02d2c <__aeabi_dcmpge>
c0d02578:	2800      	cmp	r0, #0
c0d0257a:	d010      	beq.n	c0d0259e <_etoa+0x24a>
c0d0257c:	4630      	mov	r0, r6
c0d0257e:	2600      	movs	r6, #0
c0d02580:	4b6c      	ldr	r3, [pc, #432]	; (c0d02734 <_etoa+0x3e0>)
c0d02582:	4621      	mov	r1, r4
c0d02584:	4632      	mov	r2, r6
c0d02586:	f000 fbb3 	bl	c0d02cf0 <__aeabi_dcmplt>
c0d0258a:	2800      	cmp	r0, #0
c0d0258c:	d007      	beq.n	c0d0259e <_etoa+0x24a>
c0d0258e:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d02590:	9c0c      	ldr	r4, [sp, #48]	; 0x30
            if ((int) prec > expval) {
c0d02592:	42a1      	cmp	r1, r4
c0d02594:	dc0a      	bgt.n	c0d025ac <_etoa+0x258>
c0d02596:	9613      	str	r6, [sp, #76]	; 0x4c
c0d02598:	e00b      	b.n	c0d025b2 <_etoa+0x25e>
c0d0259a:	4616      	mov	r6, r2
c0d0259c:	e015      	b.n	c0d025ca <_etoa+0x276>
c0d0259e:	9913      	ldr	r1, [sp, #76]	; 0x4c
            if ((prec > 0) && (flags & FLAGS_PRECISION)) {
c0d025a0:	2900      	cmp	r1, #0
c0d025a2:	d00f      	beq.n	c0d025c4 <_etoa+0x270>
c0d025a4:	0aa8      	lsrs	r0, r5, #10
c0d025a6:	1a09      	subs	r1, r1, r0
c0d025a8:	9113      	str	r1, [sp, #76]	; 0x4c
c0d025aa:	e00d      	b.n	c0d025c8 <_etoa+0x274>
c0d025ac:	43e0      	mvns	r0, r4
c0d025ae:	1809      	adds	r1, r1, r0
c0d025b0:	9113      	str	r1, [sp, #76]	; 0x4c
c0d025b2:	463a      	mov	r2, r7
c0d025b4:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d025b6:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d025b8:	9c06      	ldr	r4, [sp, #24]
            flags |= FLAGS_PRECISION;  // make sure _ftoa respects precision
c0d025ba:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d025bc:	4320      	orrs	r0, r4
c0d025be:	9015      	str	r0, [sp, #84]	; 0x54
c0d025c0:	9610      	str	r6, [sp, #64]	; 0x40
c0d025c2:	e005      	b.n	c0d025d0 <_etoa+0x27c>
c0d025c4:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d025c6:	9013      	str	r0, [sp, #76]	; 0x4c
c0d025c8:	9e0c      	ldr	r6, [sp, #48]	; 0x30
c0d025ca:	463a      	mov	r2, r7
c0d025cc:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d025ce:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d025d0:	9d0d      	ldr	r5, [sp, #52]	; 0x34
    if (expval) {
c0d025d2:	4628      	mov	r0, r5
c0d025d4:	f001 f828 	bl	c0d03628 <__aeabi_ddiv>
c0d025d8:	4607      	mov	r7, r0
c0d025da:	460c      	mov	r4, r1
    const bool negative = value < 0;
c0d025dc:	4628      	mov	r0, r5
c0d025de:	9908      	ldr	r1, [sp, #32]
c0d025e0:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d025e2:	4613      	mov	r3, r2
c0d025e4:	f000 fb84 	bl	c0d02cf0 <__aeabi_dcmplt>
    idx = _ftoa(out,
c0d025e8:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d025ea:	9102      	str	r1, [sp, #8]
c0d025ec:	990b      	ldr	r1, [sp, #44]	; 0x2c
c0d025ee:	02c9      	lsls	r1, r1, #11
                flags & ~FLAGS_ADAPT_EXP);
c0d025f0:	9a15      	ldr	r2, [sp, #84]	; 0x54
c0d025f2:	438a      	bics	r2, r1
    idx = _ftoa(out,
c0d025f4:	9204      	str	r2, [sp, #16]
    if (expval) {
c0d025f6:	2e00      	cmp	r6, #0
c0d025f8:	d000      	beq.n	c0d025fc <_etoa+0x2a8>
c0d025fa:	463d      	mov	r5, r7
    idx = _ftoa(out,
c0d025fc:	9500      	str	r5, [sp, #0]
    if (width > minwidth) {
c0d025fe:	9916      	ldr	r1, [sp, #88]	; 0x58
c0d02600:	9b10      	ldr	r3, [sp, #64]	; 0x40
c0d02602:	1ac9      	subs	r1, r1, r3
c0d02604:	9a0f      	ldr	r2, [sp, #60]	; 0x3c
c0d02606:	d200      	bcs.n	c0d0260a <_etoa+0x2b6>
c0d02608:	9914      	ldr	r1, [sp, #80]	; 0x50
    if ((flags & FLAGS_LEFT) && minwidth) {
c0d0260a:	2b00      	cmp	r3, #0
c0d0260c:	9d11      	ldr	r5, [sp, #68]	; 0x44
c0d0260e:	d100      	bne.n	c0d02612 <_etoa+0x2be>
c0d02610:	9114      	str	r1, [sp, #80]	; 0x50
c0d02612:	2702      	movs	r7, #2
c0d02614:	9b15      	ldr	r3, [sp, #84]	; 0x54
c0d02616:	401f      	ands	r7, r3
c0d02618:	9713      	str	r7, [sp, #76]	; 0x4c
c0d0261a:	d100      	bne.n	c0d0261e <_etoa+0x2ca>
c0d0261c:	9114      	str	r1, [sp, #80]	; 0x50
    idx = _ftoa(out,
c0d0261e:	9914      	ldr	r1, [sp, #80]	; 0x50
c0d02620:	9103      	str	r1, [sp, #12]
    if (expval) {
c0d02622:	2e00      	cmp	r6, #0
c0d02624:	d000      	beq.n	c0d02628 <_etoa+0x2d4>
c0d02626:	4625      	mov	r5, r4
                negative ? -value : value,
c0d02628:	2800      	cmp	r0, #0
c0d0262a:	d001      	beq.n	c0d02630 <_etoa+0x2dc>
c0d0262c:	9807      	ldr	r0, [sp, #28]
c0d0262e:	4045      	eors	r5, r0
c0d02630:	9809      	ldr	r0, [sp, #36]	; 0x24
    idx = _ftoa(out,
c0d02632:	9501      	str	r5, [sp, #4]
c0d02634:	9f12      	ldr	r7, [sp, #72]	; 0x48
c0d02636:	4639      	mov	r1, r7
c0d02638:	9d0e      	ldr	r5, [sp, #56]	; 0x38
c0d0263a:	462b      	mov	r3, r5
c0d0263c:	f7ff fc9a 	bl	c0d01f74 <_ftoa>
c0d02640:	4604      	mov	r4, r0
c0d02642:	9b10      	ldr	r3, [sp, #64]	; 0x40
    if (minwidth) {
c0d02644:	2b00      	cmp	r3, #0
c0d02646:	d03e      	beq.n	c0d026c6 <_etoa+0x372>
c0d02648:	2020      	movs	r0, #32
c0d0264a:	9915      	ldr	r1, [sp, #84]	; 0x54
        out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
c0d0264c:	4001      	ands	r1, r0
c0d0264e:	2065      	movs	r0, #101	; 0x65
c0d02650:	4048      	eors	r0, r1
c0d02652:	4639      	mov	r1, r7
c0d02654:	4622      	mov	r2, r4
c0d02656:	9310      	str	r3, [sp, #64]	; 0x40
c0d02658:	462b      	mov	r3, r5
c0d0265a:	9f09      	ldr	r7, [sp, #36]	; 0x24
c0d0265c:	47b8      	blx	r7
c0d0265e:	2005      	movs	r0, #5
                         minwidth - 1,
c0d02660:	9015      	str	r0, [sp, #84]	; 0x54
c0d02662:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d02664:	1e40      	subs	r0, r0, #1
c0d02666:	9014      	str	r0, [sp, #80]	; 0x50
c0d02668:	2200      	movs	r2, #0
c0d0266a:	230a      	movs	r3, #10
        idx = _ntoa_long(out,
c0d0266c:	0ff1      	lsrs	r1, r6, #31
                         (expval < 0) ? -expval : expval,
c0d0266e:	17f0      	asrs	r0, r6, #31
c0d02670:	1836      	adds	r6, r6, r0
c0d02672:	4046      	eors	r6, r0
        idx = _ntoa_long(out,
c0d02674:	9600      	str	r6, [sp, #0]
c0d02676:	9101      	str	r1, [sp, #4]
c0d02678:	9302      	str	r3, [sp, #8]
c0d0267a:	9203      	str	r2, [sp, #12]
c0d0267c:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d0267e:	9004      	str	r0, [sp, #16]
c0d02680:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d02682:	9005      	str	r0, [sp, #20]
        out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
c0d02684:	1c62      	adds	r2, r4, #1
        idx = _ntoa_long(out,
c0d02686:	4638      	mov	r0, r7
c0d02688:	9f12      	ldr	r7, [sp, #72]	; 0x48
c0d0268a:	4639      	mov	r1, r7
c0d0268c:	462b      	mov	r3, r5
c0d0268e:	f7ff fc27 	bl	c0d01ee0 <_ntoa_long>
c0d02692:	4604      	mov	r4, r0
        if (flags & FLAGS_LEFT) {
c0d02694:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d02696:	2800      	cmp	r0, #0
c0d02698:	d015      	beq.n	c0d026c6 <_etoa+0x372>
c0d0269a:	990f      	ldr	r1, [sp, #60]	; 0x3c
c0d0269c:	1a60      	subs	r0, r4, r1
c0d0269e:	9a16      	ldr	r2, [sp, #88]	; 0x58
c0d026a0:	4290      	cmp	r0, r2
c0d026a2:	d210      	bcs.n	c0d026c6 <_etoa+0x372>
c0d026a4:	462b      	mov	r3, r5
c0d026a6:	463d      	mov	r5, r7
            while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
c0d026a8:	4248      	negs	r0, r1
c0d026aa:	9015      	str	r0, [sp, #84]	; 0x54
c0d026ac:	9e09      	ldr	r6, [sp, #36]	; 0x24
c0d026ae:	2020      	movs	r0, #32
c0d026b0:	4629      	mov	r1, r5
c0d026b2:	4622      	mov	r2, r4
c0d026b4:	461f      	mov	r7, r3
c0d026b6:	47b0      	blx	r6
c0d026b8:	463b      	mov	r3, r7
c0d026ba:	1c64      	adds	r4, r4, #1
c0d026bc:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d026be:	1900      	adds	r0, r0, r4
c0d026c0:	9916      	ldr	r1, [sp, #88]	; 0x58
c0d026c2:	4288      	cmp	r0, r1
c0d026c4:	d3f3      	bcc.n	c0d026ae <_etoa+0x35a>
}
c0d026c6:	4620      	mov	r0, r4
c0d026c8:	b017      	add	sp, #92	; 0x5c
c0d026ca:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d026cc:	ffefffff 	.word	0xffefffff
c0d026d0:	7fefffff 	.word	0x7fefffff
c0d026d4:	000fffff 	.word	0x000fffff
c0d026d8:	fffffc01 	.word	0xfffffc01
c0d026dc:	509f79fb 	.word	0x509f79fb
c0d026e0:	3fd34413 	.word	0x3fd34413
c0d026e4:	8b60c8b3 	.word	0x8b60c8b3
c0d026e8:	3fc68a28 	.word	0x3fc68a28
c0d026ec:	3ff00000 	.word	0x3ff00000
c0d026f0:	bff80000 	.word	0xbff80000
c0d026f4:	636f4361 	.word	0x636f4361
c0d026f8:	3fd287a7 	.word	0x3fd287a7
c0d026fc:	0979a371 	.word	0x0979a371
c0d02700:	400a934f 	.word	0x400a934f
c0d02704:	3fe00000 	.word	0x3fe00000
c0d02708:	bbb55516 	.word	0xbbb55516
c0d0270c:	40026bb1 	.word	0x40026bb1
c0d02710:	fefa39ef 	.word	0xfefa39ef
c0d02714:	bfe62e42 	.word	0xbfe62e42
c0d02718:	402c0000 	.word	0x402c0000
c0d0271c:	40240000 	.word	0x40240000
c0d02720:	40180000 	.word	0x40180000
c0d02724:	000003ff 	.word	0x000003ff
c0d02728:	000007ff 	.word	0x000007ff
c0d0272c:	eb1c432d 	.word	0xeb1c432d
c0d02730:	3f1a36e2 	.word	0x3f1a36e2
c0d02734:	412e8480 	.word	0x412e8480

c0d02738 <_ntoa_format>:
                           unsigned int flags) {
c0d02738:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0273a:	b08b      	sub	sp, #44	; 0x2c
c0d0273c:	930a      	str	r3, [sp, #40]	; 0x28
c0d0273e:	9209      	str	r2, [sp, #36]	; 0x24
c0d02740:	4606      	mov	r6, r0
c0d02742:	9b16      	ldr	r3, [sp, #88]	; 0x58
    if (!(flags & FLAGS_LEFT)) {
c0d02744:	0798      	lsls	r0, r3, #30
c0d02746:	9d15      	ldr	r5, [sp, #84]	; 0x54
c0d02748:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d0274a:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d0274c:	9007      	str	r0, [sp, #28]
c0d0274e:	9f11      	ldr	r7, [sp, #68]	; 0x44
c0d02750:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d02752:	9208      	str	r2, [sp, #32]
c0d02754:	d42a      	bmi.n	c0d027ac <_ntoa_format+0x74>
c0d02756:	9605      	str	r6, [sp, #20]
c0d02758:	9106      	str	r1, [sp, #24]
c0d0275a:	2601      	movs	r6, #1
        if (width && (flags & FLAGS_ZEROPAD) &&
c0d0275c:	401e      	ands	r6, r3
c0d0275e:	2d00      	cmp	r5, #0
c0d02760:	d008      	beq.n	c0d02774 <_ntoa_format+0x3c>
c0d02762:	2e00      	cmp	r6, #0
c0d02764:	d006      	beq.n	c0d02774 <_ntoa_format+0x3c>
c0d02766:	200c      	movs	r0, #12
            (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d02768:	4018      	ands	r0, r3
c0d0276a:	1e41      	subs	r1, r0, #1
c0d0276c:	4188      	sbcs	r0, r1
c0d0276e:	9907      	ldr	r1, [sp, #28]
c0d02770:	4308      	orrs	r0, r1
c0d02772:	1a2d      	subs	r5, r5, r0
        while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d02774:	42a7      	cmp	r7, r4
c0d02776:	d214      	bcs.n	c0d027a2 <_ntoa_format+0x6a>
c0d02778:	2f1f      	cmp	r7, #31
c0d0277a:	d812      	bhi.n	c0d027a2 <_ntoa_format+0x6a>
c0d0277c:	9304      	str	r3, [sp, #16]
c0d0277e:	201f      	movs	r0, #31
c0d02780:	1bc0      	subs	r0, r0, r7
c0d02782:	43f9      	mvns	r1, r7
c0d02784:	1909      	adds	r1, r1, r4
c0d02786:	4281      	cmp	r1, r0
c0d02788:	d300      	bcc.n	c0d0278c <_ntoa_format+0x54>
c0d0278a:	4601      	mov	r1, r0
c0d0278c:	1c49      	adds	r1, r1, #1
c0d0278e:	19d0      	adds	r0, r2, r7
c0d02790:	2230      	movs	r2, #48	; 0x30
            buf[len++] = '0';
c0d02792:	f002 fa2c 	bl	c0d04bee <__aeabi_memset>
c0d02796:	9b04      	ldr	r3, [sp, #16]
c0d02798:	1c7f      	adds	r7, r7, #1
        while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d0279a:	42a7      	cmp	r7, r4
c0d0279c:	d201      	bcs.n	c0d027a2 <_ntoa_format+0x6a>
c0d0279e:	2f20      	cmp	r7, #32
c0d027a0:	d3fa      	bcc.n	c0d02798 <_ntoa_format+0x60>
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d027a2:	2e00      	cmp	r6, #0
c0d027a4:	d115      	bne.n	c0d027d2 <_ntoa_format+0x9a>
c0d027a6:	9906      	ldr	r1, [sp, #24]
c0d027a8:	9e05      	ldr	r6, [sp, #20]
c0d027aa:	9a08      	ldr	r2, [sp, #32]
    if (flags & FLAGS_HASH) {
c0d027ac:	06d8      	lsls	r0, r3, #27
c0d027ae:	d546      	bpl.n	c0d0283e <_ntoa_format+0x106>
c0d027b0:	4630      	mov	r0, r6
c0d027b2:	461e      	mov	r6, r3
c0d027b4:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d027b6:	4632      	mov	r2, r6
        if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
c0d027b8:	0576      	lsls	r6, r6, #21
c0d027ba:	d419      	bmi.n	c0d027f0 <_ntoa_format+0xb8>
c0d027bc:	2f00      	cmp	r7, #0
c0d027be:	d017      	beq.n	c0d027f0 <_ntoa_format+0xb8>
c0d027c0:	42a7      	cmp	r7, r4
c0d027c2:	4606      	mov	r6, r0
c0d027c4:	d001      	beq.n	c0d027ca <_ntoa_format+0x92>
c0d027c6:	42af      	cmp	r7, r5
c0d027c8:	d113      	bne.n	c0d027f2 <_ntoa_format+0xba>
            len--;
c0d027ca:	1e7c      	subs	r4, r7, #1
            if (len && (base == 16U)) {
c0d027cc:	d152      	bne.n	c0d02874 <_ntoa_format+0x13c>
c0d027ce:	4627      	mov	r7, r4
c0d027d0:	e051      	b.n	c0d02876 <_ntoa_format+0x13e>
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d027d2:	42af      	cmp	r7, r5
c0d027d4:	d2e7      	bcs.n	c0d027a6 <_ntoa_format+0x6e>
c0d027d6:	2f1f      	cmp	r7, #31
c0d027d8:	d8e5      	bhi.n	c0d027a6 <_ntoa_format+0x6e>
c0d027da:	9906      	ldr	r1, [sp, #24]
c0d027dc:	9e05      	ldr	r6, [sp, #20]
c0d027de:	9a08      	ldr	r2, [sp, #32]
c0d027e0:	2030      	movs	r0, #48	; 0x30
            buf[len++] = '0';
c0d027e2:	55d0      	strb	r0, [r2, r7]
c0d027e4:	1c7f      	adds	r7, r7, #1
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d027e6:	42af      	cmp	r7, r5
c0d027e8:	d2e0      	bcs.n	c0d027ac <_ntoa_format+0x74>
c0d027ea:	2f20      	cmp	r7, #32
c0d027ec:	d3f8      	bcc.n	c0d027e0 <_ntoa_format+0xa8>
c0d027ee:	e7dd      	b.n	c0d027ac <_ntoa_format+0x74>
c0d027f0:	4606      	mov	r6, r0
        if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d027f2:	2b10      	cmp	r3, #16
c0d027f4:	d108      	bne.n	c0d02808 <_ntoa_format+0xd0>
c0d027f6:	2020      	movs	r0, #32
c0d027f8:	4613      	mov	r3, r2
c0d027fa:	4010      	ands	r0, r2
c0d027fc:	d10f      	bne.n	c0d0281e <_ntoa_format+0xe6>
c0d027fe:	2f1f      	cmp	r7, #31
c0d02800:	d80d      	bhi.n	c0d0281e <_ntoa_format+0xe6>
c0d02802:	2078      	movs	r0, #120	; 0x78
c0d02804:	9a08      	ldr	r2, [sp, #32]
c0d02806:	e010      	b.n	c0d0282a <_ntoa_format+0xf2>
        } else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d02808:	2b02      	cmp	r3, #2
c0d0280a:	d111      	bne.n	c0d02830 <_ntoa_format+0xf8>
c0d0280c:	2f1f      	cmp	r7, #31
c0d0280e:	d80f      	bhi.n	c0d02830 <_ntoa_format+0xf8>
c0d02810:	2062      	movs	r0, #98	; 0x62
c0d02812:	9c08      	ldr	r4, [sp, #32]
            buf[len++] = 'b';
c0d02814:	55e0      	strb	r0, [r4, r7]
c0d02816:	1c7f      	adds	r7, r7, #1
c0d02818:	4613      	mov	r3, r2
c0d0281a:	4622      	mov	r2, r4
c0d0281c:	e00a      	b.n	c0d02834 <_ntoa_format+0xfc>
        } else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d0281e:	2800      	cmp	r0, #0
c0d02820:	d007      	beq.n	c0d02832 <_ntoa_format+0xfa>
c0d02822:	2f1f      	cmp	r7, #31
c0d02824:	9a08      	ldr	r2, [sp, #32]
c0d02826:	d805      	bhi.n	c0d02834 <_ntoa_format+0xfc>
c0d02828:	2058      	movs	r0, #88	; 0x58
c0d0282a:	55d0      	strb	r0, [r2, r7]
c0d0282c:	1c7f      	adds	r7, r7, #1
c0d0282e:	e001      	b.n	c0d02834 <_ntoa_format+0xfc>
c0d02830:	4613      	mov	r3, r2
c0d02832:	9a08      	ldr	r2, [sp, #32]
        if (len < PRINTF_NTOA_BUFFER_SIZE) {
c0d02834:	2f1f      	cmp	r7, #31
c0d02836:	d812      	bhi.n	c0d0285e <_ntoa_format+0x126>
c0d02838:	2030      	movs	r0, #48	; 0x30
            buf[len++] = '0';
c0d0283a:	55d0      	strb	r0, [r2, r7]
c0d0283c:	1c7f      	adds	r7, r7, #1
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
c0d0283e:	2f1f      	cmp	r7, #31
c0d02840:	d80d      	bhi.n	c0d0285e <_ntoa_format+0x126>
        if (negative) {
c0d02842:	9807      	ldr	r0, [sp, #28]
c0d02844:	2800      	cmp	r0, #0
c0d02846:	d001      	beq.n	c0d0284c <_ntoa_format+0x114>
c0d02848:	202d      	movs	r0, #45	; 0x2d
c0d0284a:	e006      	b.n	c0d0285a <_ntoa_format+0x122>
        } else if (flags & FLAGS_PLUS) {
c0d0284c:	0758      	lsls	r0, r3, #29
c0d0284e:	d403      	bmi.n	c0d02858 <_ntoa_format+0x120>
        } else if (flags & FLAGS_SPACE) {
c0d02850:	0718      	lsls	r0, r3, #28
c0d02852:	d504      	bpl.n	c0d0285e <_ntoa_format+0x126>
c0d02854:	2020      	movs	r0, #32
c0d02856:	e000      	b.n	c0d0285a <_ntoa_format+0x122>
c0d02858:	202b      	movs	r0, #43	; 0x2b
c0d0285a:	55d0      	strb	r0, [r2, r7]
c0d0285c:	1c7f      	adds	r7, r7, #1
    return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
c0d0285e:	9200      	str	r2, [sp, #0]
c0d02860:	9701      	str	r7, [sp, #4]
c0d02862:	9502      	str	r5, [sp, #8]
c0d02864:	9303      	str	r3, [sp, #12]
c0d02866:	4630      	mov	r0, r6
c0d02868:	9a09      	ldr	r2, [sp, #36]	; 0x24
c0d0286a:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d0286c:	f000 f807 	bl	c0d0287e <_out_rev>
c0d02870:	b00b      	add	sp, #44	; 0x2c
c0d02872:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02874:	1ebf      	subs	r7, r7, #2
            if (len && (base == 16U)) {
c0d02876:	2b10      	cmp	r3, #16
c0d02878:	d0bb      	beq.n	c0d027f2 <_ntoa_format+0xba>
c0d0287a:	4627      	mov	r7, r4
c0d0287c:	e7b9      	b.n	c0d027f2 <_ntoa_format+0xba>

c0d0287e <_out_rev>:
                       unsigned int flags) {
c0d0287e:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02880:	b089      	sub	sp, #36	; 0x24
c0d02882:	461e      	mov	r6, r3
c0d02884:	4617      	mov	r7, r2
c0d02886:	9004      	str	r0, [sp, #16]
c0d02888:	2402      	movs	r4, #2
c0d0288a:	9811      	ldr	r0, [sp, #68]	; 0x44
    if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
c0d0288c:	4004      	ands	r4, r0
c0d0288e:	9401      	str	r4, [sp, #4]
c0d02890:	07c0      	lsls	r0, r0, #31
c0d02892:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d02894:	9006      	str	r0, [sp, #24]
c0d02896:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d02898:	9002      	str	r0, [sp, #8]
c0d0289a:	9203      	str	r2, [sp, #12]
c0d0289c:	9105      	str	r1, [sp, #20]
c0d0289e:	d116      	bne.n	c0d028ce <_out_rev+0x50>
c0d028a0:	9801      	ldr	r0, [sp, #4]
c0d028a2:	2800      	cmp	r0, #0
c0d028a4:	9f03      	ldr	r7, [sp, #12]
c0d028a6:	d112      	bne.n	c0d028ce <_out_rev+0x50>
c0d028a8:	9806      	ldr	r0, [sp, #24]
c0d028aa:	9a02      	ldr	r2, [sp, #8]
c0d028ac:	4282      	cmp	r2, r0
c0d028ae:	9f03      	ldr	r7, [sp, #12]
c0d028b0:	d20d      	bcs.n	c0d028ce <_out_rev+0x50>
        for (size_t i = len; i < width; i++) {
c0d028b2:	9806      	ldr	r0, [sp, #24]
c0d028b4:	9a02      	ldr	r2, [sp, #8]
c0d028b6:	1a85      	subs	r5, r0, r2
c0d028b8:	9f03      	ldr	r7, [sp, #12]
            out(' ', buffer, idx++, maxlen);
c0d028ba:	9c04      	ldr	r4, [sp, #16]
c0d028bc:	2020      	movs	r0, #32
c0d028be:	463a      	mov	r2, r7
c0d028c0:	4633      	mov	r3, r6
c0d028c2:	47a0      	blx	r4
c0d028c4:	9905      	ldr	r1, [sp, #20]
        for (size_t i = len; i < width; i++) {
c0d028c6:	1e6d      	subs	r5, r5, #1
            out(' ', buffer, idx++, maxlen);
c0d028c8:	1c7f      	adds	r7, r7, #1
        for (size_t i = len; i < width; i++) {
c0d028ca:	2d00      	cmp	r5, #0
c0d028cc:	d1f6      	bne.n	c0d028bc <_out_rev+0x3e>
c0d028ce:	9608      	str	r6, [sp, #32]
c0d028d0:	9c02      	ldr	r4, [sp, #8]
    while (len) {
c0d028d2:	2c00      	cmp	r4, #0
c0d028d4:	d00d      	beq.n	c0d028f2 <_out_rev+0x74>
c0d028d6:	980e      	ldr	r0, [sp, #56]	; 0x38
c0d028d8:	1e40      	subs	r0, r0, #1
c0d028da:	9007      	str	r0, [sp, #28]
c0d028dc:	9d05      	ldr	r5, [sp, #20]
c0d028de:	9e04      	ldr	r6, [sp, #16]
        out(buf[--len], buffer, idx++, maxlen);
c0d028e0:	9807      	ldr	r0, [sp, #28]
c0d028e2:	5d00      	ldrb	r0, [r0, r4]
c0d028e4:	4629      	mov	r1, r5
c0d028e6:	463a      	mov	r2, r7
c0d028e8:	9b08      	ldr	r3, [sp, #32]
c0d028ea:	47b0      	blx	r6
c0d028ec:	1c7f      	adds	r7, r7, #1
c0d028ee:	1e64      	subs	r4, r4, #1
    while (len) {
c0d028f0:	d1f6      	bne.n	c0d028e0 <_out_rev+0x62>
    if (flags & FLAGS_LEFT) {
c0d028f2:	9801      	ldr	r0, [sp, #4]
c0d028f4:	2800      	cmp	r0, #0
c0d028f6:	d014      	beq.n	c0d02922 <_out_rev+0xa4>
c0d028f8:	9a03      	ldr	r2, [sp, #12]
c0d028fa:	1ab8      	subs	r0, r7, r2
c0d028fc:	9906      	ldr	r1, [sp, #24]
c0d028fe:	4288      	cmp	r0, r1
c0d02900:	d20f      	bcs.n	c0d02922 <_out_rev+0xa4>
        while (idx - start_idx < width) {
c0d02902:	4250      	negs	r0, r2
c0d02904:	9007      	str	r0, [sp, #28]
c0d02906:	9d08      	ldr	r5, [sp, #32]
c0d02908:	9e05      	ldr	r6, [sp, #20]
c0d0290a:	9c04      	ldr	r4, [sp, #16]
c0d0290c:	2020      	movs	r0, #32
            out(' ', buffer, idx++, maxlen);
c0d0290e:	4631      	mov	r1, r6
c0d02910:	463a      	mov	r2, r7
c0d02912:	462b      	mov	r3, r5
c0d02914:	47a0      	blx	r4
c0d02916:	1c7f      	adds	r7, r7, #1
        while (idx - start_idx < width) {
c0d02918:	9807      	ldr	r0, [sp, #28]
c0d0291a:	19c0      	adds	r0, r0, r7
c0d0291c:	9906      	ldr	r1, [sp, #24]
c0d0291e:	4288      	cmp	r0, r1
c0d02920:	d3f4      	bcc.n	c0d0290c <_out_rev+0x8e>
    return idx;
c0d02922:	4638      	mov	r0, r7
c0d02924:	b009      	add	sp, #36	; 0x24
c0d02926:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02928 <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d02928:	df01      	svc	1
    cmp r1, #0
c0d0292a:	2900      	cmp	r1, #0
    bne exception
c0d0292c:	d100      	bne.n	c0d02930 <exception>
    bx lr
c0d0292e:	4770      	bx	lr

c0d02930 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d02930:	4608      	mov	r0, r1
    bl os_longjmp
c0d02932:	f7fe fdab 	bl	c0d0148c <os_longjmp>
	...

c0d02938 <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d02938:	b580      	push	{r7, lr}
c0d0293a:	b084      	sub	sp, #16
c0d0293c:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d0293e:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d02940:	9001      	str	r0, [sp, #4]
c0d02942:	4803      	ldr	r0, [pc, #12]	; (c0d02950 <get_api_level+0x18>)
c0d02944:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d02946:	f7ff ffef 	bl	c0d02928 <SVC_Call>
c0d0294a:	b004      	add	sp, #16
c0d0294c:	bd80      	pop	{r7, pc}
c0d0294e:	46c0      	nop			; (mov r8, r8)
c0d02950:	60000138 	.word	0x60000138

c0d02954 <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d02954:	b580      	push	{r7, lr}
c0d02956:	b084      	sub	sp, #16
c0d02958:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d0295a:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d0295c:	9001      	str	r0, [sp, #4]
c0d0295e:	4803      	ldr	r0, [pc, #12]	; (c0d0296c <os_lib_call+0x18>)
c0d02960:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d02962:	f7ff ffe1 	bl	c0d02928 <SVC_Call>
  return;
}
c0d02966:	b004      	add	sp, #16
c0d02968:	bd80      	pop	{r7, pc}
c0d0296a:	46c0      	nop			; (mov r8, r8)
c0d0296c:	6000670d 	.word	0x6000670d

c0d02970 <os_lib_end>:

void os_lib_end ( void ) {
c0d02970:	b580      	push	{r7, lr}
c0d02972:	b082      	sub	sp, #8
c0d02974:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d02976:	9001      	str	r0, [sp, #4]
c0d02978:	4802      	ldr	r0, [pc, #8]	; (c0d02984 <os_lib_end+0x14>)
c0d0297a:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d0297c:	f7ff ffd4 	bl	c0d02928 <SVC_Call>
  return;
}
c0d02980:	b002      	add	sp, #8
c0d02982:	bd80      	pop	{r7, pc}
c0d02984:	6000688d 	.word	0x6000688d

c0d02988 <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d02988:	b580      	push	{r7, lr}
c0d0298a:	b084      	sub	sp, #16
c0d0298c:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d0298e:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d02990:	9001      	str	r0, [sp, #4]
c0d02992:	4803      	ldr	r0, [pc, #12]	; (c0d029a0 <os_sched_exit+0x18>)
c0d02994:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d02996:	f7ff ffc7 	bl	c0d02928 <SVC_Call>
  return;
}
c0d0299a:	b004      	add	sp, #16
c0d0299c:	bd80      	pop	{r7, pc}
c0d0299e:	46c0      	nop			; (mov r8, r8)
c0d029a0:	60009abe 	.word	0x60009abe

c0d029a4 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d029a4:	b580      	push	{r7, lr}
c0d029a6:	b082      	sub	sp, #8
c0d029a8:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d029aa:	9001      	str	r0, [sp, #4]
c0d029ac:	4802      	ldr	r0, [pc, #8]	; (c0d029b8 <try_context_get+0x14>)
c0d029ae:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d029b0:	f7ff ffba 	bl	c0d02928 <SVC_Call>
c0d029b4:	b002      	add	sp, #8
c0d029b6:	bd80      	pop	{r7, pc}
c0d029b8:	600087b1 	.word	0x600087b1

c0d029bc <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d029bc:	b580      	push	{r7, lr}
c0d029be:	b084      	sub	sp, #16
c0d029c0:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d029c2:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d029c4:	9001      	str	r0, [sp, #4]
c0d029c6:	4803      	ldr	r0, [pc, #12]	; (c0d029d4 <try_context_set+0x18>)
c0d029c8:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d029ca:	f7ff ffad 	bl	c0d02928 <SVC_Call>
c0d029ce:	b004      	add	sp, #16
c0d029d0:	bd80      	pop	{r7, pc}
c0d029d2:	46c0      	nop			; (mov r8, r8)
c0d029d4:	60010b06 	.word	0x60010b06

c0d029d8 <__udivsi3>:
c0d029d8:	2200      	movs	r2, #0
c0d029da:	0843      	lsrs	r3, r0, #1
c0d029dc:	428b      	cmp	r3, r1
c0d029de:	d374      	bcc.n	c0d02aca <__udivsi3+0xf2>
c0d029e0:	0903      	lsrs	r3, r0, #4
c0d029e2:	428b      	cmp	r3, r1
c0d029e4:	d35f      	bcc.n	c0d02aa6 <__udivsi3+0xce>
c0d029e6:	0a03      	lsrs	r3, r0, #8
c0d029e8:	428b      	cmp	r3, r1
c0d029ea:	d344      	bcc.n	c0d02a76 <__udivsi3+0x9e>
c0d029ec:	0b03      	lsrs	r3, r0, #12
c0d029ee:	428b      	cmp	r3, r1
c0d029f0:	d328      	bcc.n	c0d02a44 <__udivsi3+0x6c>
c0d029f2:	0c03      	lsrs	r3, r0, #16
c0d029f4:	428b      	cmp	r3, r1
c0d029f6:	d30d      	bcc.n	c0d02a14 <__udivsi3+0x3c>
c0d029f8:	22ff      	movs	r2, #255	; 0xff
c0d029fa:	0209      	lsls	r1, r1, #8
c0d029fc:	ba12      	rev	r2, r2
c0d029fe:	0c03      	lsrs	r3, r0, #16
c0d02a00:	428b      	cmp	r3, r1
c0d02a02:	d302      	bcc.n	c0d02a0a <__udivsi3+0x32>
c0d02a04:	1212      	asrs	r2, r2, #8
c0d02a06:	0209      	lsls	r1, r1, #8
c0d02a08:	d065      	beq.n	c0d02ad6 <__udivsi3+0xfe>
c0d02a0a:	0b03      	lsrs	r3, r0, #12
c0d02a0c:	428b      	cmp	r3, r1
c0d02a0e:	d319      	bcc.n	c0d02a44 <__udivsi3+0x6c>
c0d02a10:	e000      	b.n	c0d02a14 <__udivsi3+0x3c>
c0d02a12:	0a09      	lsrs	r1, r1, #8
c0d02a14:	0bc3      	lsrs	r3, r0, #15
c0d02a16:	428b      	cmp	r3, r1
c0d02a18:	d301      	bcc.n	c0d02a1e <__udivsi3+0x46>
c0d02a1a:	03cb      	lsls	r3, r1, #15
c0d02a1c:	1ac0      	subs	r0, r0, r3
c0d02a1e:	4152      	adcs	r2, r2
c0d02a20:	0b83      	lsrs	r3, r0, #14
c0d02a22:	428b      	cmp	r3, r1
c0d02a24:	d301      	bcc.n	c0d02a2a <__udivsi3+0x52>
c0d02a26:	038b      	lsls	r3, r1, #14
c0d02a28:	1ac0      	subs	r0, r0, r3
c0d02a2a:	4152      	adcs	r2, r2
c0d02a2c:	0b43      	lsrs	r3, r0, #13
c0d02a2e:	428b      	cmp	r3, r1
c0d02a30:	d301      	bcc.n	c0d02a36 <__udivsi3+0x5e>
c0d02a32:	034b      	lsls	r3, r1, #13
c0d02a34:	1ac0      	subs	r0, r0, r3
c0d02a36:	4152      	adcs	r2, r2
c0d02a38:	0b03      	lsrs	r3, r0, #12
c0d02a3a:	428b      	cmp	r3, r1
c0d02a3c:	d301      	bcc.n	c0d02a42 <__udivsi3+0x6a>
c0d02a3e:	030b      	lsls	r3, r1, #12
c0d02a40:	1ac0      	subs	r0, r0, r3
c0d02a42:	4152      	adcs	r2, r2
c0d02a44:	0ac3      	lsrs	r3, r0, #11
c0d02a46:	428b      	cmp	r3, r1
c0d02a48:	d301      	bcc.n	c0d02a4e <__udivsi3+0x76>
c0d02a4a:	02cb      	lsls	r3, r1, #11
c0d02a4c:	1ac0      	subs	r0, r0, r3
c0d02a4e:	4152      	adcs	r2, r2
c0d02a50:	0a83      	lsrs	r3, r0, #10
c0d02a52:	428b      	cmp	r3, r1
c0d02a54:	d301      	bcc.n	c0d02a5a <__udivsi3+0x82>
c0d02a56:	028b      	lsls	r3, r1, #10
c0d02a58:	1ac0      	subs	r0, r0, r3
c0d02a5a:	4152      	adcs	r2, r2
c0d02a5c:	0a43      	lsrs	r3, r0, #9
c0d02a5e:	428b      	cmp	r3, r1
c0d02a60:	d301      	bcc.n	c0d02a66 <__udivsi3+0x8e>
c0d02a62:	024b      	lsls	r3, r1, #9
c0d02a64:	1ac0      	subs	r0, r0, r3
c0d02a66:	4152      	adcs	r2, r2
c0d02a68:	0a03      	lsrs	r3, r0, #8
c0d02a6a:	428b      	cmp	r3, r1
c0d02a6c:	d301      	bcc.n	c0d02a72 <__udivsi3+0x9a>
c0d02a6e:	020b      	lsls	r3, r1, #8
c0d02a70:	1ac0      	subs	r0, r0, r3
c0d02a72:	4152      	adcs	r2, r2
c0d02a74:	d2cd      	bcs.n	c0d02a12 <__udivsi3+0x3a>
c0d02a76:	09c3      	lsrs	r3, r0, #7
c0d02a78:	428b      	cmp	r3, r1
c0d02a7a:	d301      	bcc.n	c0d02a80 <__udivsi3+0xa8>
c0d02a7c:	01cb      	lsls	r3, r1, #7
c0d02a7e:	1ac0      	subs	r0, r0, r3
c0d02a80:	4152      	adcs	r2, r2
c0d02a82:	0983      	lsrs	r3, r0, #6
c0d02a84:	428b      	cmp	r3, r1
c0d02a86:	d301      	bcc.n	c0d02a8c <__udivsi3+0xb4>
c0d02a88:	018b      	lsls	r3, r1, #6
c0d02a8a:	1ac0      	subs	r0, r0, r3
c0d02a8c:	4152      	adcs	r2, r2
c0d02a8e:	0943      	lsrs	r3, r0, #5
c0d02a90:	428b      	cmp	r3, r1
c0d02a92:	d301      	bcc.n	c0d02a98 <__udivsi3+0xc0>
c0d02a94:	014b      	lsls	r3, r1, #5
c0d02a96:	1ac0      	subs	r0, r0, r3
c0d02a98:	4152      	adcs	r2, r2
c0d02a9a:	0903      	lsrs	r3, r0, #4
c0d02a9c:	428b      	cmp	r3, r1
c0d02a9e:	d301      	bcc.n	c0d02aa4 <__udivsi3+0xcc>
c0d02aa0:	010b      	lsls	r3, r1, #4
c0d02aa2:	1ac0      	subs	r0, r0, r3
c0d02aa4:	4152      	adcs	r2, r2
c0d02aa6:	08c3      	lsrs	r3, r0, #3
c0d02aa8:	428b      	cmp	r3, r1
c0d02aaa:	d301      	bcc.n	c0d02ab0 <__udivsi3+0xd8>
c0d02aac:	00cb      	lsls	r3, r1, #3
c0d02aae:	1ac0      	subs	r0, r0, r3
c0d02ab0:	4152      	adcs	r2, r2
c0d02ab2:	0883      	lsrs	r3, r0, #2
c0d02ab4:	428b      	cmp	r3, r1
c0d02ab6:	d301      	bcc.n	c0d02abc <__udivsi3+0xe4>
c0d02ab8:	008b      	lsls	r3, r1, #2
c0d02aba:	1ac0      	subs	r0, r0, r3
c0d02abc:	4152      	adcs	r2, r2
c0d02abe:	0843      	lsrs	r3, r0, #1
c0d02ac0:	428b      	cmp	r3, r1
c0d02ac2:	d301      	bcc.n	c0d02ac8 <__udivsi3+0xf0>
c0d02ac4:	004b      	lsls	r3, r1, #1
c0d02ac6:	1ac0      	subs	r0, r0, r3
c0d02ac8:	4152      	adcs	r2, r2
c0d02aca:	1a41      	subs	r1, r0, r1
c0d02acc:	d200      	bcs.n	c0d02ad0 <__udivsi3+0xf8>
c0d02ace:	4601      	mov	r1, r0
c0d02ad0:	4152      	adcs	r2, r2
c0d02ad2:	4610      	mov	r0, r2
c0d02ad4:	4770      	bx	lr
c0d02ad6:	e7ff      	b.n	c0d02ad8 <__udivsi3+0x100>
c0d02ad8:	b501      	push	{r0, lr}
c0d02ada:	2000      	movs	r0, #0
c0d02adc:	f000 f8f0 	bl	c0d02cc0 <__aeabi_idiv0>
c0d02ae0:	bd02      	pop	{r1, pc}
c0d02ae2:	46c0      	nop			; (mov r8, r8)

c0d02ae4 <__aeabi_uidivmod>:
c0d02ae4:	2900      	cmp	r1, #0
c0d02ae6:	d0f7      	beq.n	c0d02ad8 <__udivsi3+0x100>
c0d02ae8:	e776      	b.n	c0d029d8 <__udivsi3>
c0d02aea:	4770      	bx	lr

c0d02aec <__divsi3>:
c0d02aec:	4603      	mov	r3, r0
c0d02aee:	430b      	orrs	r3, r1
c0d02af0:	d47f      	bmi.n	c0d02bf2 <__divsi3+0x106>
c0d02af2:	2200      	movs	r2, #0
c0d02af4:	0843      	lsrs	r3, r0, #1
c0d02af6:	428b      	cmp	r3, r1
c0d02af8:	d374      	bcc.n	c0d02be4 <__divsi3+0xf8>
c0d02afa:	0903      	lsrs	r3, r0, #4
c0d02afc:	428b      	cmp	r3, r1
c0d02afe:	d35f      	bcc.n	c0d02bc0 <__divsi3+0xd4>
c0d02b00:	0a03      	lsrs	r3, r0, #8
c0d02b02:	428b      	cmp	r3, r1
c0d02b04:	d344      	bcc.n	c0d02b90 <__divsi3+0xa4>
c0d02b06:	0b03      	lsrs	r3, r0, #12
c0d02b08:	428b      	cmp	r3, r1
c0d02b0a:	d328      	bcc.n	c0d02b5e <__divsi3+0x72>
c0d02b0c:	0c03      	lsrs	r3, r0, #16
c0d02b0e:	428b      	cmp	r3, r1
c0d02b10:	d30d      	bcc.n	c0d02b2e <__divsi3+0x42>
c0d02b12:	22ff      	movs	r2, #255	; 0xff
c0d02b14:	0209      	lsls	r1, r1, #8
c0d02b16:	ba12      	rev	r2, r2
c0d02b18:	0c03      	lsrs	r3, r0, #16
c0d02b1a:	428b      	cmp	r3, r1
c0d02b1c:	d302      	bcc.n	c0d02b24 <__divsi3+0x38>
c0d02b1e:	1212      	asrs	r2, r2, #8
c0d02b20:	0209      	lsls	r1, r1, #8
c0d02b22:	d065      	beq.n	c0d02bf0 <__divsi3+0x104>
c0d02b24:	0b03      	lsrs	r3, r0, #12
c0d02b26:	428b      	cmp	r3, r1
c0d02b28:	d319      	bcc.n	c0d02b5e <__divsi3+0x72>
c0d02b2a:	e000      	b.n	c0d02b2e <__divsi3+0x42>
c0d02b2c:	0a09      	lsrs	r1, r1, #8
c0d02b2e:	0bc3      	lsrs	r3, r0, #15
c0d02b30:	428b      	cmp	r3, r1
c0d02b32:	d301      	bcc.n	c0d02b38 <__divsi3+0x4c>
c0d02b34:	03cb      	lsls	r3, r1, #15
c0d02b36:	1ac0      	subs	r0, r0, r3
c0d02b38:	4152      	adcs	r2, r2
c0d02b3a:	0b83      	lsrs	r3, r0, #14
c0d02b3c:	428b      	cmp	r3, r1
c0d02b3e:	d301      	bcc.n	c0d02b44 <__divsi3+0x58>
c0d02b40:	038b      	lsls	r3, r1, #14
c0d02b42:	1ac0      	subs	r0, r0, r3
c0d02b44:	4152      	adcs	r2, r2
c0d02b46:	0b43      	lsrs	r3, r0, #13
c0d02b48:	428b      	cmp	r3, r1
c0d02b4a:	d301      	bcc.n	c0d02b50 <__divsi3+0x64>
c0d02b4c:	034b      	lsls	r3, r1, #13
c0d02b4e:	1ac0      	subs	r0, r0, r3
c0d02b50:	4152      	adcs	r2, r2
c0d02b52:	0b03      	lsrs	r3, r0, #12
c0d02b54:	428b      	cmp	r3, r1
c0d02b56:	d301      	bcc.n	c0d02b5c <__divsi3+0x70>
c0d02b58:	030b      	lsls	r3, r1, #12
c0d02b5a:	1ac0      	subs	r0, r0, r3
c0d02b5c:	4152      	adcs	r2, r2
c0d02b5e:	0ac3      	lsrs	r3, r0, #11
c0d02b60:	428b      	cmp	r3, r1
c0d02b62:	d301      	bcc.n	c0d02b68 <__divsi3+0x7c>
c0d02b64:	02cb      	lsls	r3, r1, #11
c0d02b66:	1ac0      	subs	r0, r0, r3
c0d02b68:	4152      	adcs	r2, r2
c0d02b6a:	0a83      	lsrs	r3, r0, #10
c0d02b6c:	428b      	cmp	r3, r1
c0d02b6e:	d301      	bcc.n	c0d02b74 <__divsi3+0x88>
c0d02b70:	028b      	lsls	r3, r1, #10
c0d02b72:	1ac0      	subs	r0, r0, r3
c0d02b74:	4152      	adcs	r2, r2
c0d02b76:	0a43      	lsrs	r3, r0, #9
c0d02b78:	428b      	cmp	r3, r1
c0d02b7a:	d301      	bcc.n	c0d02b80 <__divsi3+0x94>
c0d02b7c:	024b      	lsls	r3, r1, #9
c0d02b7e:	1ac0      	subs	r0, r0, r3
c0d02b80:	4152      	adcs	r2, r2
c0d02b82:	0a03      	lsrs	r3, r0, #8
c0d02b84:	428b      	cmp	r3, r1
c0d02b86:	d301      	bcc.n	c0d02b8c <__divsi3+0xa0>
c0d02b88:	020b      	lsls	r3, r1, #8
c0d02b8a:	1ac0      	subs	r0, r0, r3
c0d02b8c:	4152      	adcs	r2, r2
c0d02b8e:	d2cd      	bcs.n	c0d02b2c <__divsi3+0x40>
c0d02b90:	09c3      	lsrs	r3, r0, #7
c0d02b92:	428b      	cmp	r3, r1
c0d02b94:	d301      	bcc.n	c0d02b9a <__divsi3+0xae>
c0d02b96:	01cb      	lsls	r3, r1, #7
c0d02b98:	1ac0      	subs	r0, r0, r3
c0d02b9a:	4152      	adcs	r2, r2
c0d02b9c:	0983      	lsrs	r3, r0, #6
c0d02b9e:	428b      	cmp	r3, r1
c0d02ba0:	d301      	bcc.n	c0d02ba6 <__divsi3+0xba>
c0d02ba2:	018b      	lsls	r3, r1, #6
c0d02ba4:	1ac0      	subs	r0, r0, r3
c0d02ba6:	4152      	adcs	r2, r2
c0d02ba8:	0943      	lsrs	r3, r0, #5
c0d02baa:	428b      	cmp	r3, r1
c0d02bac:	d301      	bcc.n	c0d02bb2 <__divsi3+0xc6>
c0d02bae:	014b      	lsls	r3, r1, #5
c0d02bb0:	1ac0      	subs	r0, r0, r3
c0d02bb2:	4152      	adcs	r2, r2
c0d02bb4:	0903      	lsrs	r3, r0, #4
c0d02bb6:	428b      	cmp	r3, r1
c0d02bb8:	d301      	bcc.n	c0d02bbe <__divsi3+0xd2>
c0d02bba:	010b      	lsls	r3, r1, #4
c0d02bbc:	1ac0      	subs	r0, r0, r3
c0d02bbe:	4152      	adcs	r2, r2
c0d02bc0:	08c3      	lsrs	r3, r0, #3
c0d02bc2:	428b      	cmp	r3, r1
c0d02bc4:	d301      	bcc.n	c0d02bca <__divsi3+0xde>
c0d02bc6:	00cb      	lsls	r3, r1, #3
c0d02bc8:	1ac0      	subs	r0, r0, r3
c0d02bca:	4152      	adcs	r2, r2
c0d02bcc:	0883      	lsrs	r3, r0, #2
c0d02bce:	428b      	cmp	r3, r1
c0d02bd0:	d301      	bcc.n	c0d02bd6 <__divsi3+0xea>
c0d02bd2:	008b      	lsls	r3, r1, #2
c0d02bd4:	1ac0      	subs	r0, r0, r3
c0d02bd6:	4152      	adcs	r2, r2
c0d02bd8:	0843      	lsrs	r3, r0, #1
c0d02bda:	428b      	cmp	r3, r1
c0d02bdc:	d301      	bcc.n	c0d02be2 <__divsi3+0xf6>
c0d02bde:	004b      	lsls	r3, r1, #1
c0d02be0:	1ac0      	subs	r0, r0, r3
c0d02be2:	4152      	adcs	r2, r2
c0d02be4:	1a41      	subs	r1, r0, r1
c0d02be6:	d200      	bcs.n	c0d02bea <__divsi3+0xfe>
c0d02be8:	4601      	mov	r1, r0
c0d02bea:	4152      	adcs	r2, r2
c0d02bec:	4610      	mov	r0, r2
c0d02bee:	4770      	bx	lr
c0d02bf0:	e05d      	b.n	c0d02cae <__divsi3+0x1c2>
c0d02bf2:	0fca      	lsrs	r2, r1, #31
c0d02bf4:	d000      	beq.n	c0d02bf8 <__divsi3+0x10c>
c0d02bf6:	4249      	negs	r1, r1
c0d02bf8:	1003      	asrs	r3, r0, #32
c0d02bfa:	d300      	bcc.n	c0d02bfe <__divsi3+0x112>
c0d02bfc:	4240      	negs	r0, r0
c0d02bfe:	4053      	eors	r3, r2
c0d02c00:	2200      	movs	r2, #0
c0d02c02:	469c      	mov	ip, r3
c0d02c04:	0903      	lsrs	r3, r0, #4
c0d02c06:	428b      	cmp	r3, r1
c0d02c08:	d32d      	bcc.n	c0d02c66 <__divsi3+0x17a>
c0d02c0a:	0a03      	lsrs	r3, r0, #8
c0d02c0c:	428b      	cmp	r3, r1
c0d02c0e:	d312      	bcc.n	c0d02c36 <__divsi3+0x14a>
c0d02c10:	22fc      	movs	r2, #252	; 0xfc
c0d02c12:	0189      	lsls	r1, r1, #6
c0d02c14:	ba12      	rev	r2, r2
c0d02c16:	0a03      	lsrs	r3, r0, #8
c0d02c18:	428b      	cmp	r3, r1
c0d02c1a:	d30c      	bcc.n	c0d02c36 <__divsi3+0x14a>
c0d02c1c:	0189      	lsls	r1, r1, #6
c0d02c1e:	1192      	asrs	r2, r2, #6
c0d02c20:	428b      	cmp	r3, r1
c0d02c22:	d308      	bcc.n	c0d02c36 <__divsi3+0x14a>
c0d02c24:	0189      	lsls	r1, r1, #6
c0d02c26:	1192      	asrs	r2, r2, #6
c0d02c28:	428b      	cmp	r3, r1
c0d02c2a:	d304      	bcc.n	c0d02c36 <__divsi3+0x14a>
c0d02c2c:	0189      	lsls	r1, r1, #6
c0d02c2e:	d03a      	beq.n	c0d02ca6 <__divsi3+0x1ba>
c0d02c30:	1192      	asrs	r2, r2, #6
c0d02c32:	e000      	b.n	c0d02c36 <__divsi3+0x14a>
c0d02c34:	0989      	lsrs	r1, r1, #6
c0d02c36:	09c3      	lsrs	r3, r0, #7
c0d02c38:	428b      	cmp	r3, r1
c0d02c3a:	d301      	bcc.n	c0d02c40 <__divsi3+0x154>
c0d02c3c:	01cb      	lsls	r3, r1, #7
c0d02c3e:	1ac0      	subs	r0, r0, r3
c0d02c40:	4152      	adcs	r2, r2
c0d02c42:	0983      	lsrs	r3, r0, #6
c0d02c44:	428b      	cmp	r3, r1
c0d02c46:	d301      	bcc.n	c0d02c4c <__divsi3+0x160>
c0d02c48:	018b      	lsls	r3, r1, #6
c0d02c4a:	1ac0      	subs	r0, r0, r3
c0d02c4c:	4152      	adcs	r2, r2
c0d02c4e:	0943      	lsrs	r3, r0, #5
c0d02c50:	428b      	cmp	r3, r1
c0d02c52:	d301      	bcc.n	c0d02c58 <__divsi3+0x16c>
c0d02c54:	014b      	lsls	r3, r1, #5
c0d02c56:	1ac0      	subs	r0, r0, r3
c0d02c58:	4152      	adcs	r2, r2
c0d02c5a:	0903      	lsrs	r3, r0, #4
c0d02c5c:	428b      	cmp	r3, r1
c0d02c5e:	d301      	bcc.n	c0d02c64 <__divsi3+0x178>
c0d02c60:	010b      	lsls	r3, r1, #4
c0d02c62:	1ac0      	subs	r0, r0, r3
c0d02c64:	4152      	adcs	r2, r2
c0d02c66:	08c3      	lsrs	r3, r0, #3
c0d02c68:	428b      	cmp	r3, r1
c0d02c6a:	d301      	bcc.n	c0d02c70 <__divsi3+0x184>
c0d02c6c:	00cb      	lsls	r3, r1, #3
c0d02c6e:	1ac0      	subs	r0, r0, r3
c0d02c70:	4152      	adcs	r2, r2
c0d02c72:	0883      	lsrs	r3, r0, #2
c0d02c74:	428b      	cmp	r3, r1
c0d02c76:	d301      	bcc.n	c0d02c7c <__divsi3+0x190>
c0d02c78:	008b      	lsls	r3, r1, #2
c0d02c7a:	1ac0      	subs	r0, r0, r3
c0d02c7c:	4152      	adcs	r2, r2
c0d02c7e:	d2d9      	bcs.n	c0d02c34 <__divsi3+0x148>
c0d02c80:	0843      	lsrs	r3, r0, #1
c0d02c82:	428b      	cmp	r3, r1
c0d02c84:	d301      	bcc.n	c0d02c8a <__divsi3+0x19e>
c0d02c86:	004b      	lsls	r3, r1, #1
c0d02c88:	1ac0      	subs	r0, r0, r3
c0d02c8a:	4152      	adcs	r2, r2
c0d02c8c:	1a41      	subs	r1, r0, r1
c0d02c8e:	d200      	bcs.n	c0d02c92 <__divsi3+0x1a6>
c0d02c90:	4601      	mov	r1, r0
c0d02c92:	4663      	mov	r3, ip
c0d02c94:	4152      	adcs	r2, r2
c0d02c96:	105b      	asrs	r3, r3, #1
c0d02c98:	4610      	mov	r0, r2
c0d02c9a:	d301      	bcc.n	c0d02ca0 <__divsi3+0x1b4>
c0d02c9c:	4240      	negs	r0, r0
c0d02c9e:	2b00      	cmp	r3, #0
c0d02ca0:	d500      	bpl.n	c0d02ca4 <__divsi3+0x1b8>
c0d02ca2:	4249      	negs	r1, r1
c0d02ca4:	4770      	bx	lr
c0d02ca6:	4663      	mov	r3, ip
c0d02ca8:	105b      	asrs	r3, r3, #1
c0d02caa:	d300      	bcc.n	c0d02cae <__divsi3+0x1c2>
c0d02cac:	4240      	negs	r0, r0
c0d02cae:	b501      	push	{r0, lr}
c0d02cb0:	2000      	movs	r0, #0
c0d02cb2:	f000 f805 	bl	c0d02cc0 <__aeabi_idiv0>
c0d02cb6:	bd02      	pop	{r1, pc}

c0d02cb8 <__aeabi_idivmod>:
c0d02cb8:	2900      	cmp	r1, #0
c0d02cba:	d0f8      	beq.n	c0d02cae <__divsi3+0x1c2>
c0d02cbc:	e716      	b.n	c0d02aec <__divsi3>
c0d02cbe:	4770      	bx	lr

c0d02cc0 <__aeabi_idiv0>:
c0d02cc0:	4770      	bx	lr
c0d02cc2:	46c0      	nop			; (mov r8, r8)

c0d02cc4 <__aeabi_cdrcmple>:
c0d02cc4:	4684      	mov	ip, r0
c0d02cc6:	0010      	movs	r0, r2
c0d02cc8:	4662      	mov	r2, ip
c0d02cca:	468c      	mov	ip, r1
c0d02ccc:	0019      	movs	r1, r3
c0d02cce:	4663      	mov	r3, ip
c0d02cd0:	e000      	b.n	c0d02cd4 <__aeabi_cdcmpeq>
c0d02cd2:	46c0      	nop			; (mov r8, r8)

c0d02cd4 <__aeabi_cdcmpeq>:
c0d02cd4:	b51f      	push	{r0, r1, r2, r3, r4, lr}
c0d02cd6:	f001 f845 	bl	c0d03d64 <__ledf2>
c0d02cda:	2800      	cmp	r0, #0
c0d02cdc:	d401      	bmi.n	c0d02ce2 <__aeabi_cdcmpeq+0xe>
c0d02cde:	2100      	movs	r1, #0
c0d02ce0:	42c8      	cmn	r0, r1
c0d02ce2:	bd1f      	pop	{r0, r1, r2, r3, r4, pc}

c0d02ce4 <__aeabi_dcmpeq>:
c0d02ce4:	b510      	push	{r4, lr}
c0d02ce6:	f000 ff95 	bl	c0d03c14 <__eqdf2>
c0d02cea:	4240      	negs	r0, r0
c0d02cec:	3001      	adds	r0, #1
c0d02cee:	bd10      	pop	{r4, pc}

c0d02cf0 <__aeabi_dcmplt>:
c0d02cf0:	b510      	push	{r4, lr}
c0d02cf2:	f001 f837 	bl	c0d03d64 <__ledf2>
c0d02cf6:	2800      	cmp	r0, #0
c0d02cf8:	db01      	blt.n	c0d02cfe <__aeabi_dcmplt+0xe>
c0d02cfa:	2000      	movs	r0, #0
c0d02cfc:	bd10      	pop	{r4, pc}
c0d02cfe:	2001      	movs	r0, #1
c0d02d00:	bd10      	pop	{r4, pc}
c0d02d02:	46c0      	nop			; (mov r8, r8)

c0d02d04 <__aeabi_dcmple>:
c0d02d04:	b510      	push	{r4, lr}
c0d02d06:	f001 f82d 	bl	c0d03d64 <__ledf2>
c0d02d0a:	2800      	cmp	r0, #0
c0d02d0c:	dd01      	ble.n	c0d02d12 <__aeabi_dcmple+0xe>
c0d02d0e:	2000      	movs	r0, #0
c0d02d10:	bd10      	pop	{r4, pc}
c0d02d12:	2001      	movs	r0, #1
c0d02d14:	bd10      	pop	{r4, pc}
c0d02d16:	46c0      	nop			; (mov r8, r8)

c0d02d18 <__aeabi_dcmpgt>:
c0d02d18:	b510      	push	{r4, lr}
c0d02d1a:	f000 ffbd 	bl	c0d03c98 <__gedf2>
c0d02d1e:	2800      	cmp	r0, #0
c0d02d20:	dc01      	bgt.n	c0d02d26 <__aeabi_dcmpgt+0xe>
c0d02d22:	2000      	movs	r0, #0
c0d02d24:	bd10      	pop	{r4, pc}
c0d02d26:	2001      	movs	r0, #1
c0d02d28:	bd10      	pop	{r4, pc}
c0d02d2a:	46c0      	nop			; (mov r8, r8)

c0d02d2c <__aeabi_dcmpge>:
c0d02d2c:	b510      	push	{r4, lr}
c0d02d2e:	f000 ffb3 	bl	c0d03c98 <__gedf2>
c0d02d32:	2800      	cmp	r0, #0
c0d02d34:	da01      	bge.n	c0d02d3a <__aeabi_dcmpge+0xe>
c0d02d36:	2000      	movs	r0, #0
c0d02d38:	bd10      	pop	{r4, pc}
c0d02d3a:	2001      	movs	r0, #1
c0d02d3c:	bd10      	pop	{r4, pc}
c0d02d3e:	46c0      	nop			; (mov r8, r8)

c0d02d40 <__aeabi_uldivmod>:
c0d02d40:	2b00      	cmp	r3, #0
c0d02d42:	d111      	bne.n	c0d02d68 <__aeabi_uldivmod+0x28>
c0d02d44:	2a00      	cmp	r2, #0
c0d02d46:	d10f      	bne.n	c0d02d68 <__aeabi_uldivmod+0x28>
c0d02d48:	2900      	cmp	r1, #0
c0d02d4a:	d100      	bne.n	c0d02d4e <__aeabi_uldivmod+0xe>
c0d02d4c:	2800      	cmp	r0, #0
c0d02d4e:	d002      	beq.n	c0d02d56 <__aeabi_uldivmod+0x16>
c0d02d50:	2100      	movs	r1, #0
c0d02d52:	43c9      	mvns	r1, r1
c0d02d54:	0008      	movs	r0, r1
c0d02d56:	b407      	push	{r0, r1, r2}
c0d02d58:	4802      	ldr	r0, [pc, #8]	; (c0d02d64 <__aeabi_uldivmod+0x24>)
c0d02d5a:	a102      	add	r1, pc, #8	; (adr r1, c0d02d64 <__aeabi_uldivmod+0x24>)
c0d02d5c:	1840      	adds	r0, r0, r1
c0d02d5e:	9002      	str	r0, [sp, #8]
c0d02d60:	bd03      	pop	{r0, r1, pc}
c0d02d62:	46c0      	nop			; (mov r8, r8)
c0d02d64:	ffffff5d 	.word	0xffffff5d
c0d02d68:	b403      	push	{r0, r1}
c0d02d6a:	4668      	mov	r0, sp
c0d02d6c:	b501      	push	{r0, lr}
c0d02d6e:	9802      	ldr	r0, [sp, #8]
c0d02d70:	f000 f852 	bl	c0d02e18 <__udivmoddi4>
c0d02d74:	9b01      	ldr	r3, [sp, #4]
c0d02d76:	469e      	mov	lr, r3
c0d02d78:	b002      	add	sp, #8
c0d02d7a:	bc0c      	pop	{r2, r3}
c0d02d7c:	4770      	bx	lr
c0d02d7e:	46c0      	nop			; (mov r8, r8)

c0d02d80 <__aeabi_lmul>:
c0d02d80:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02d82:	46ce      	mov	lr, r9
c0d02d84:	4647      	mov	r7, r8
c0d02d86:	b580      	push	{r7, lr}
c0d02d88:	0007      	movs	r7, r0
c0d02d8a:	4699      	mov	r9, r3
c0d02d8c:	0c3b      	lsrs	r3, r7, #16
c0d02d8e:	469c      	mov	ip, r3
c0d02d90:	0413      	lsls	r3, r2, #16
c0d02d92:	0c1b      	lsrs	r3, r3, #16
c0d02d94:	001d      	movs	r5, r3
c0d02d96:	000e      	movs	r6, r1
c0d02d98:	4661      	mov	r1, ip
c0d02d9a:	0400      	lsls	r0, r0, #16
c0d02d9c:	0c14      	lsrs	r4, r2, #16
c0d02d9e:	0c00      	lsrs	r0, r0, #16
c0d02da0:	4345      	muls	r5, r0
c0d02da2:	434b      	muls	r3, r1
c0d02da4:	4360      	muls	r0, r4
c0d02da6:	4361      	muls	r1, r4
c0d02da8:	18c0      	adds	r0, r0, r3
c0d02daa:	0c2c      	lsrs	r4, r5, #16
c0d02dac:	1820      	adds	r0, r4, r0
c0d02dae:	468c      	mov	ip, r1
c0d02db0:	4283      	cmp	r3, r0
c0d02db2:	d903      	bls.n	c0d02dbc <__aeabi_lmul+0x3c>
c0d02db4:	2380      	movs	r3, #128	; 0x80
c0d02db6:	025b      	lsls	r3, r3, #9
c0d02db8:	4698      	mov	r8, r3
c0d02dba:	44c4      	add	ip, r8
c0d02dbc:	4649      	mov	r1, r9
c0d02dbe:	4379      	muls	r1, r7
c0d02dc0:	4372      	muls	r2, r6
c0d02dc2:	0c03      	lsrs	r3, r0, #16
c0d02dc4:	4463      	add	r3, ip
c0d02dc6:	042d      	lsls	r5, r5, #16
c0d02dc8:	0c2d      	lsrs	r5, r5, #16
c0d02dca:	18c9      	adds	r1, r1, r3
c0d02dcc:	0400      	lsls	r0, r0, #16
c0d02dce:	1940      	adds	r0, r0, r5
c0d02dd0:	1889      	adds	r1, r1, r2
c0d02dd2:	bcc0      	pop	{r6, r7}
c0d02dd4:	46b9      	mov	r9, r7
c0d02dd6:	46b0      	mov	r8, r6
c0d02dd8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02dda:	46c0      	nop			; (mov r8, r8)

c0d02ddc <__aeabi_d2uiz>:
c0d02ddc:	b570      	push	{r4, r5, r6, lr}
c0d02dde:	2200      	movs	r2, #0
c0d02de0:	4b0c      	ldr	r3, [pc, #48]	; (c0d02e14 <__aeabi_d2uiz+0x38>)
c0d02de2:	0004      	movs	r4, r0
c0d02de4:	000d      	movs	r5, r1
c0d02de6:	f7ff ffa1 	bl	c0d02d2c <__aeabi_dcmpge>
c0d02dea:	2800      	cmp	r0, #0
c0d02dec:	d104      	bne.n	c0d02df8 <__aeabi_d2uiz+0x1c>
c0d02dee:	0020      	movs	r0, r4
c0d02df0:	0029      	movs	r1, r5
c0d02df2:	f001 fe39 	bl	c0d04a68 <__aeabi_d2iz>
c0d02df6:	bd70      	pop	{r4, r5, r6, pc}
c0d02df8:	4b06      	ldr	r3, [pc, #24]	; (c0d02e14 <__aeabi_d2uiz+0x38>)
c0d02dfa:	2200      	movs	r2, #0
c0d02dfc:	0020      	movs	r0, r4
c0d02dfe:	0029      	movs	r1, r5
c0d02e00:	f001 fa82 	bl	c0d04308 <__aeabi_dsub>
c0d02e04:	f001 fe30 	bl	c0d04a68 <__aeabi_d2iz>
c0d02e08:	2380      	movs	r3, #128	; 0x80
c0d02e0a:	061b      	lsls	r3, r3, #24
c0d02e0c:	469c      	mov	ip, r3
c0d02e0e:	4460      	add	r0, ip
c0d02e10:	e7f1      	b.n	c0d02df6 <__aeabi_d2uiz+0x1a>
c0d02e12:	46c0      	nop			; (mov r8, r8)
c0d02e14:	41e00000 	.word	0x41e00000

c0d02e18 <__udivmoddi4>:
c0d02e18:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02e1a:	4657      	mov	r7, sl
c0d02e1c:	464e      	mov	r6, r9
c0d02e1e:	4645      	mov	r5, r8
c0d02e20:	46de      	mov	lr, fp
c0d02e22:	b5e0      	push	{r5, r6, r7, lr}
c0d02e24:	0004      	movs	r4, r0
c0d02e26:	000d      	movs	r5, r1
c0d02e28:	4692      	mov	sl, r2
c0d02e2a:	4699      	mov	r9, r3
c0d02e2c:	b083      	sub	sp, #12
c0d02e2e:	428b      	cmp	r3, r1
c0d02e30:	d830      	bhi.n	c0d02e94 <__udivmoddi4+0x7c>
c0d02e32:	d02d      	beq.n	c0d02e90 <__udivmoddi4+0x78>
c0d02e34:	4649      	mov	r1, r9
c0d02e36:	4650      	mov	r0, sl
c0d02e38:	f001 fec0 	bl	c0d04bbc <__clzdi2>
c0d02e3c:	0029      	movs	r1, r5
c0d02e3e:	0006      	movs	r6, r0
c0d02e40:	0020      	movs	r0, r4
c0d02e42:	f001 febb 	bl	c0d04bbc <__clzdi2>
c0d02e46:	1a33      	subs	r3, r6, r0
c0d02e48:	4698      	mov	r8, r3
c0d02e4a:	3b20      	subs	r3, #32
c0d02e4c:	469b      	mov	fp, r3
c0d02e4e:	d433      	bmi.n	c0d02eb8 <__udivmoddi4+0xa0>
c0d02e50:	465a      	mov	r2, fp
c0d02e52:	4653      	mov	r3, sl
c0d02e54:	4093      	lsls	r3, r2
c0d02e56:	4642      	mov	r2, r8
c0d02e58:	001f      	movs	r7, r3
c0d02e5a:	4653      	mov	r3, sl
c0d02e5c:	4093      	lsls	r3, r2
c0d02e5e:	001e      	movs	r6, r3
c0d02e60:	42af      	cmp	r7, r5
c0d02e62:	d83a      	bhi.n	c0d02eda <__udivmoddi4+0xc2>
c0d02e64:	42af      	cmp	r7, r5
c0d02e66:	d100      	bne.n	c0d02e6a <__udivmoddi4+0x52>
c0d02e68:	e078      	b.n	c0d02f5c <__udivmoddi4+0x144>
c0d02e6a:	465b      	mov	r3, fp
c0d02e6c:	1ba4      	subs	r4, r4, r6
c0d02e6e:	41bd      	sbcs	r5, r7
c0d02e70:	2b00      	cmp	r3, #0
c0d02e72:	da00      	bge.n	c0d02e76 <__udivmoddi4+0x5e>
c0d02e74:	e075      	b.n	c0d02f62 <__udivmoddi4+0x14a>
c0d02e76:	2200      	movs	r2, #0
c0d02e78:	2300      	movs	r3, #0
c0d02e7a:	9200      	str	r2, [sp, #0]
c0d02e7c:	9301      	str	r3, [sp, #4]
c0d02e7e:	2301      	movs	r3, #1
c0d02e80:	465a      	mov	r2, fp
c0d02e82:	4093      	lsls	r3, r2
c0d02e84:	9301      	str	r3, [sp, #4]
c0d02e86:	2301      	movs	r3, #1
c0d02e88:	4642      	mov	r2, r8
c0d02e8a:	4093      	lsls	r3, r2
c0d02e8c:	9300      	str	r3, [sp, #0]
c0d02e8e:	e028      	b.n	c0d02ee2 <__udivmoddi4+0xca>
c0d02e90:	4282      	cmp	r2, r0
c0d02e92:	d9cf      	bls.n	c0d02e34 <__udivmoddi4+0x1c>
c0d02e94:	2200      	movs	r2, #0
c0d02e96:	2300      	movs	r3, #0
c0d02e98:	9200      	str	r2, [sp, #0]
c0d02e9a:	9301      	str	r3, [sp, #4]
c0d02e9c:	9b0c      	ldr	r3, [sp, #48]	; 0x30
c0d02e9e:	2b00      	cmp	r3, #0
c0d02ea0:	d001      	beq.n	c0d02ea6 <__udivmoddi4+0x8e>
c0d02ea2:	601c      	str	r4, [r3, #0]
c0d02ea4:	605d      	str	r5, [r3, #4]
c0d02ea6:	9800      	ldr	r0, [sp, #0]
c0d02ea8:	9901      	ldr	r1, [sp, #4]
c0d02eaa:	b003      	add	sp, #12
c0d02eac:	bcf0      	pop	{r4, r5, r6, r7}
c0d02eae:	46bb      	mov	fp, r7
c0d02eb0:	46b2      	mov	sl, r6
c0d02eb2:	46a9      	mov	r9, r5
c0d02eb4:	46a0      	mov	r8, r4
c0d02eb6:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02eb8:	4642      	mov	r2, r8
c0d02eba:	2320      	movs	r3, #32
c0d02ebc:	1a9b      	subs	r3, r3, r2
c0d02ebe:	4652      	mov	r2, sl
c0d02ec0:	40da      	lsrs	r2, r3
c0d02ec2:	4641      	mov	r1, r8
c0d02ec4:	0013      	movs	r3, r2
c0d02ec6:	464a      	mov	r2, r9
c0d02ec8:	408a      	lsls	r2, r1
c0d02eca:	0017      	movs	r7, r2
c0d02ecc:	4642      	mov	r2, r8
c0d02ece:	431f      	orrs	r7, r3
c0d02ed0:	4653      	mov	r3, sl
c0d02ed2:	4093      	lsls	r3, r2
c0d02ed4:	001e      	movs	r6, r3
c0d02ed6:	42af      	cmp	r7, r5
c0d02ed8:	d9c4      	bls.n	c0d02e64 <__udivmoddi4+0x4c>
c0d02eda:	2200      	movs	r2, #0
c0d02edc:	2300      	movs	r3, #0
c0d02ede:	9200      	str	r2, [sp, #0]
c0d02ee0:	9301      	str	r3, [sp, #4]
c0d02ee2:	4643      	mov	r3, r8
c0d02ee4:	2b00      	cmp	r3, #0
c0d02ee6:	d0d9      	beq.n	c0d02e9c <__udivmoddi4+0x84>
c0d02ee8:	07fb      	lsls	r3, r7, #31
c0d02eea:	0872      	lsrs	r2, r6, #1
c0d02eec:	431a      	orrs	r2, r3
c0d02eee:	4646      	mov	r6, r8
c0d02ef0:	087b      	lsrs	r3, r7, #1
c0d02ef2:	e00e      	b.n	c0d02f12 <__udivmoddi4+0xfa>
c0d02ef4:	42ab      	cmp	r3, r5
c0d02ef6:	d101      	bne.n	c0d02efc <__udivmoddi4+0xe4>
c0d02ef8:	42a2      	cmp	r2, r4
c0d02efa:	d80c      	bhi.n	c0d02f16 <__udivmoddi4+0xfe>
c0d02efc:	1aa4      	subs	r4, r4, r2
c0d02efe:	419d      	sbcs	r5, r3
c0d02f00:	2001      	movs	r0, #1
c0d02f02:	1924      	adds	r4, r4, r4
c0d02f04:	416d      	adcs	r5, r5
c0d02f06:	2100      	movs	r1, #0
c0d02f08:	3e01      	subs	r6, #1
c0d02f0a:	1824      	adds	r4, r4, r0
c0d02f0c:	414d      	adcs	r5, r1
c0d02f0e:	2e00      	cmp	r6, #0
c0d02f10:	d006      	beq.n	c0d02f20 <__udivmoddi4+0x108>
c0d02f12:	42ab      	cmp	r3, r5
c0d02f14:	d9ee      	bls.n	c0d02ef4 <__udivmoddi4+0xdc>
c0d02f16:	3e01      	subs	r6, #1
c0d02f18:	1924      	adds	r4, r4, r4
c0d02f1a:	416d      	adcs	r5, r5
c0d02f1c:	2e00      	cmp	r6, #0
c0d02f1e:	d1f8      	bne.n	c0d02f12 <__udivmoddi4+0xfa>
c0d02f20:	9800      	ldr	r0, [sp, #0]
c0d02f22:	9901      	ldr	r1, [sp, #4]
c0d02f24:	465b      	mov	r3, fp
c0d02f26:	1900      	adds	r0, r0, r4
c0d02f28:	4169      	adcs	r1, r5
c0d02f2a:	2b00      	cmp	r3, #0
c0d02f2c:	db24      	blt.n	c0d02f78 <__udivmoddi4+0x160>
c0d02f2e:	002b      	movs	r3, r5
c0d02f30:	465a      	mov	r2, fp
c0d02f32:	4644      	mov	r4, r8
c0d02f34:	40d3      	lsrs	r3, r2
c0d02f36:	002a      	movs	r2, r5
c0d02f38:	40e2      	lsrs	r2, r4
c0d02f3a:	001c      	movs	r4, r3
c0d02f3c:	465b      	mov	r3, fp
c0d02f3e:	0015      	movs	r5, r2
c0d02f40:	2b00      	cmp	r3, #0
c0d02f42:	db2a      	blt.n	c0d02f9a <__udivmoddi4+0x182>
c0d02f44:	0026      	movs	r6, r4
c0d02f46:	409e      	lsls	r6, r3
c0d02f48:	0033      	movs	r3, r6
c0d02f4a:	0026      	movs	r6, r4
c0d02f4c:	4647      	mov	r7, r8
c0d02f4e:	40be      	lsls	r6, r7
c0d02f50:	0032      	movs	r2, r6
c0d02f52:	1a80      	subs	r0, r0, r2
c0d02f54:	4199      	sbcs	r1, r3
c0d02f56:	9000      	str	r0, [sp, #0]
c0d02f58:	9101      	str	r1, [sp, #4]
c0d02f5a:	e79f      	b.n	c0d02e9c <__udivmoddi4+0x84>
c0d02f5c:	42a3      	cmp	r3, r4
c0d02f5e:	d8bc      	bhi.n	c0d02eda <__udivmoddi4+0xc2>
c0d02f60:	e783      	b.n	c0d02e6a <__udivmoddi4+0x52>
c0d02f62:	4642      	mov	r2, r8
c0d02f64:	2320      	movs	r3, #32
c0d02f66:	2100      	movs	r1, #0
c0d02f68:	1a9b      	subs	r3, r3, r2
c0d02f6a:	2200      	movs	r2, #0
c0d02f6c:	9100      	str	r1, [sp, #0]
c0d02f6e:	9201      	str	r2, [sp, #4]
c0d02f70:	2201      	movs	r2, #1
c0d02f72:	40da      	lsrs	r2, r3
c0d02f74:	9201      	str	r2, [sp, #4]
c0d02f76:	e786      	b.n	c0d02e86 <__udivmoddi4+0x6e>
c0d02f78:	4642      	mov	r2, r8
c0d02f7a:	2320      	movs	r3, #32
c0d02f7c:	1a9b      	subs	r3, r3, r2
c0d02f7e:	002a      	movs	r2, r5
c0d02f80:	4646      	mov	r6, r8
c0d02f82:	409a      	lsls	r2, r3
c0d02f84:	0023      	movs	r3, r4
c0d02f86:	40f3      	lsrs	r3, r6
c0d02f88:	4644      	mov	r4, r8
c0d02f8a:	4313      	orrs	r3, r2
c0d02f8c:	002a      	movs	r2, r5
c0d02f8e:	40e2      	lsrs	r2, r4
c0d02f90:	001c      	movs	r4, r3
c0d02f92:	465b      	mov	r3, fp
c0d02f94:	0015      	movs	r5, r2
c0d02f96:	2b00      	cmp	r3, #0
c0d02f98:	dad4      	bge.n	c0d02f44 <__udivmoddi4+0x12c>
c0d02f9a:	4642      	mov	r2, r8
c0d02f9c:	002f      	movs	r7, r5
c0d02f9e:	2320      	movs	r3, #32
c0d02fa0:	0026      	movs	r6, r4
c0d02fa2:	4097      	lsls	r7, r2
c0d02fa4:	1a9b      	subs	r3, r3, r2
c0d02fa6:	40de      	lsrs	r6, r3
c0d02fa8:	003b      	movs	r3, r7
c0d02faa:	4333      	orrs	r3, r6
c0d02fac:	e7cd      	b.n	c0d02f4a <__udivmoddi4+0x132>
c0d02fae:	46c0      	nop			; (mov r8, r8)

c0d02fb0 <__aeabi_dadd>:
c0d02fb0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02fb2:	464f      	mov	r7, r9
c0d02fb4:	4646      	mov	r6, r8
c0d02fb6:	46d6      	mov	lr, sl
c0d02fb8:	000d      	movs	r5, r1
c0d02fba:	0004      	movs	r4, r0
c0d02fbc:	b5c0      	push	{r6, r7, lr}
c0d02fbe:	001f      	movs	r7, r3
c0d02fc0:	0011      	movs	r1, r2
c0d02fc2:	0328      	lsls	r0, r5, #12
c0d02fc4:	0f62      	lsrs	r2, r4, #29
c0d02fc6:	0a40      	lsrs	r0, r0, #9
c0d02fc8:	4310      	orrs	r0, r2
c0d02fca:	007a      	lsls	r2, r7, #1
c0d02fcc:	0d52      	lsrs	r2, r2, #21
c0d02fce:	00e3      	lsls	r3, r4, #3
c0d02fd0:	033c      	lsls	r4, r7, #12
c0d02fd2:	4691      	mov	r9, r2
c0d02fd4:	0a64      	lsrs	r4, r4, #9
c0d02fd6:	0ffa      	lsrs	r2, r7, #31
c0d02fd8:	0f4f      	lsrs	r7, r1, #29
c0d02fda:	006e      	lsls	r6, r5, #1
c0d02fdc:	4327      	orrs	r7, r4
c0d02fde:	4692      	mov	sl, r2
c0d02fe0:	46b8      	mov	r8, r7
c0d02fe2:	0d76      	lsrs	r6, r6, #21
c0d02fe4:	0fed      	lsrs	r5, r5, #31
c0d02fe6:	00c9      	lsls	r1, r1, #3
c0d02fe8:	4295      	cmp	r5, r2
c0d02fea:	d100      	bne.n	c0d02fee <__aeabi_dadd+0x3e>
c0d02fec:	e099      	b.n	c0d03122 <__aeabi_dadd+0x172>
c0d02fee:	464c      	mov	r4, r9
c0d02ff0:	1b34      	subs	r4, r6, r4
c0d02ff2:	46a4      	mov	ip, r4
c0d02ff4:	2c00      	cmp	r4, #0
c0d02ff6:	dc00      	bgt.n	c0d02ffa <__aeabi_dadd+0x4a>
c0d02ff8:	e07c      	b.n	c0d030f4 <__aeabi_dadd+0x144>
c0d02ffa:	464a      	mov	r2, r9
c0d02ffc:	2a00      	cmp	r2, #0
c0d02ffe:	d100      	bne.n	c0d03002 <__aeabi_dadd+0x52>
c0d03000:	e0b8      	b.n	c0d03174 <__aeabi_dadd+0x1c4>
c0d03002:	4ac5      	ldr	r2, [pc, #788]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d03004:	4296      	cmp	r6, r2
c0d03006:	d100      	bne.n	c0d0300a <__aeabi_dadd+0x5a>
c0d03008:	e11c      	b.n	c0d03244 <__aeabi_dadd+0x294>
c0d0300a:	2280      	movs	r2, #128	; 0x80
c0d0300c:	003c      	movs	r4, r7
c0d0300e:	0412      	lsls	r2, r2, #16
c0d03010:	4314      	orrs	r4, r2
c0d03012:	46a0      	mov	r8, r4
c0d03014:	4662      	mov	r2, ip
c0d03016:	2a38      	cmp	r2, #56	; 0x38
c0d03018:	dd00      	ble.n	c0d0301c <__aeabi_dadd+0x6c>
c0d0301a:	e161      	b.n	c0d032e0 <__aeabi_dadd+0x330>
c0d0301c:	2a1f      	cmp	r2, #31
c0d0301e:	dd00      	ble.n	c0d03022 <__aeabi_dadd+0x72>
c0d03020:	e1cc      	b.n	c0d033bc <__aeabi_dadd+0x40c>
c0d03022:	4664      	mov	r4, ip
c0d03024:	2220      	movs	r2, #32
c0d03026:	1b12      	subs	r2, r2, r4
c0d03028:	4644      	mov	r4, r8
c0d0302a:	4094      	lsls	r4, r2
c0d0302c:	000f      	movs	r7, r1
c0d0302e:	46a1      	mov	r9, r4
c0d03030:	4664      	mov	r4, ip
c0d03032:	4091      	lsls	r1, r2
c0d03034:	40e7      	lsrs	r7, r4
c0d03036:	464c      	mov	r4, r9
c0d03038:	1e4a      	subs	r2, r1, #1
c0d0303a:	4191      	sbcs	r1, r2
c0d0303c:	433c      	orrs	r4, r7
c0d0303e:	4642      	mov	r2, r8
c0d03040:	4321      	orrs	r1, r4
c0d03042:	4664      	mov	r4, ip
c0d03044:	40e2      	lsrs	r2, r4
c0d03046:	1a80      	subs	r0, r0, r2
c0d03048:	1a5c      	subs	r4, r3, r1
c0d0304a:	42a3      	cmp	r3, r4
c0d0304c:	419b      	sbcs	r3, r3
c0d0304e:	425f      	negs	r7, r3
c0d03050:	1bc7      	subs	r7, r0, r7
c0d03052:	023b      	lsls	r3, r7, #8
c0d03054:	d400      	bmi.n	c0d03058 <__aeabi_dadd+0xa8>
c0d03056:	e0d0      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d03058:	027f      	lsls	r7, r7, #9
c0d0305a:	0a7f      	lsrs	r7, r7, #9
c0d0305c:	2f00      	cmp	r7, #0
c0d0305e:	d100      	bne.n	c0d03062 <__aeabi_dadd+0xb2>
c0d03060:	e0ff      	b.n	c0d03262 <__aeabi_dadd+0x2b2>
c0d03062:	0038      	movs	r0, r7
c0d03064:	f001 fd8c 	bl	c0d04b80 <__clzsi2>
c0d03068:	0001      	movs	r1, r0
c0d0306a:	3908      	subs	r1, #8
c0d0306c:	2320      	movs	r3, #32
c0d0306e:	0022      	movs	r2, r4
c0d03070:	1a5b      	subs	r3, r3, r1
c0d03072:	408f      	lsls	r7, r1
c0d03074:	40da      	lsrs	r2, r3
c0d03076:	408c      	lsls	r4, r1
c0d03078:	4317      	orrs	r7, r2
c0d0307a:	42b1      	cmp	r1, r6
c0d0307c:	da00      	bge.n	c0d03080 <__aeabi_dadd+0xd0>
c0d0307e:	e0ff      	b.n	c0d03280 <__aeabi_dadd+0x2d0>
c0d03080:	1b89      	subs	r1, r1, r6
c0d03082:	1c4b      	adds	r3, r1, #1
c0d03084:	2b1f      	cmp	r3, #31
c0d03086:	dd00      	ble.n	c0d0308a <__aeabi_dadd+0xda>
c0d03088:	e0a8      	b.n	c0d031dc <__aeabi_dadd+0x22c>
c0d0308a:	2220      	movs	r2, #32
c0d0308c:	0039      	movs	r1, r7
c0d0308e:	1ad2      	subs	r2, r2, r3
c0d03090:	0020      	movs	r0, r4
c0d03092:	4094      	lsls	r4, r2
c0d03094:	4091      	lsls	r1, r2
c0d03096:	40d8      	lsrs	r0, r3
c0d03098:	1e62      	subs	r2, r4, #1
c0d0309a:	4194      	sbcs	r4, r2
c0d0309c:	40df      	lsrs	r7, r3
c0d0309e:	2600      	movs	r6, #0
c0d030a0:	4301      	orrs	r1, r0
c0d030a2:	430c      	orrs	r4, r1
c0d030a4:	0763      	lsls	r3, r4, #29
c0d030a6:	d009      	beq.n	c0d030bc <__aeabi_dadd+0x10c>
c0d030a8:	230f      	movs	r3, #15
c0d030aa:	4023      	ands	r3, r4
c0d030ac:	2b04      	cmp	r3, #4
c0d030ae:	d005      	beq.n	c0d030bc <__aeabi_dadd+0x10c>
c0d030b0:	1d23      	adds	r3, r4, #4
c0d030b2:	42a3      	cmp	r3, r4
c0d030b4:	41a4      	sbcs	r4, r4
c0d030b6:	4264      	negs	r4, r4
c0d030b8:	193f      	adds	r7, r7, r4
c0d030ba:	001c      	movs	r4, r3
c0d030bc:	023b      	lsls	r3, r7, #8
c0d030be:	d400      	bmi.n	c0d030c2 <__aeabi_dadd+0x112>
c0d030c0:	e09e      	b.n	c0d03200 <__aeabi_dadd+0x250>
c0d030c2:	4b95      	ldr	r3, [pc, #596]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d030c4:	3601      	adds	r6, #1
c0d030c6:	429e      	cmp	r6, r3
c0d030c8:	d100      	bne.n	c0d030cc <__aeabi_dadd+0x11c>
c0d030ca:	e0b7      	b.n	c0d0323c <__aeabi_dadd+0x28c>
c0d030cc:	4a93      	ldr	r2, [pc, #588]	; (c0d0331c <__aeabi_dadd+0x36c>)
c0d030ce:	08e4      	lsrs	r4, r4, #3
c0d030d0:	4017      	ands	r7, r2
c0d030d2:	077b      	lsls	r3, r7, #29
c0d030d4:	0571      	lsls	r1, r6, #21
c0d030d6:	027f      	lsls	r7, r7, #9
c0d030d8:	4323      	orrs	r3, r4
c0d030da:	0b3f      	lsrs	r7, r7, #12
c0d030dc:	0d4a      	lsrs	r2, r1, #21
c0d030de:	0512      	lsls	r2, r2, #20
c0d030e0:	433a      	orrs	r2, r7
c0d030e2:	07ed      	lsls	r5, r5, #31
c0d030e4:	432a      	orrs	r2, r5
c0d030e6:	0018      	movs	r0, r3
c0d030e8:	0011      	movs	r1, r2
c0d030ea:	bce0      	pop	{r5, r6, r7}
c0d030ec:	46ba      	mov	sl, r7
c0d030ee:	46b1      	mov	r9, r6
c0d030f0:	46a8      	mov	r8, r5
c0d030f2:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d030f4:	2c00      	cmp	r4, #0
c0d030f6:	d04b      	beq.n	c0d03190 <__aeabi_dadd+0x1e0>
c0d030f8:	464c      	mov	r4, r9
c0d030fa:	1ba4      	subs	r4, r4, r6
c0d030fc:	46a4      	mov	ip, r4
c0d030fe:	2e00      	cmp	r6, #0
c0d03100:	d000      	beq.n	c0d03104 <__aeabi_dadd+0x154>
c0d03102:	e123      	b.n	c0d0334c <__aeabi_dadd+0x39c>
c0d03104:	0004      	movs	r4, r0
c0d03106:	431c      	orrs	r4, r3
c0d03108:	d100      	bne.n	c0d0310c <__aeabi_dadd+0x15c>
c0d0310a:	e1af      	b.n	c0d0346c <__aeabi_dadd+0x4bc>
c0d0310c:	4662      	mov	r2, ip
c0d0310e:	1e54      	subs	r4, r2, #1
c0d03110:	2a01      	cmp	r2, #1
c0d03112:	d100      	bne.n	c0d03116 <__aeabi_dadd+0x166>
c0d03114:	e215      	b.n	c0d03542 <__aeabi_dadd+0x592>
c0d03116:	4d80      	ldr	r5, [pc, #512]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d03118:	45ac      	cmp	ip, r5
c0d0311a:	d100      	bne.n	c0d0311e <__aeabi_dadd+0x16e>
c0d0311c:	e1c8      	b.n	c0d034b0 <__aeabi_dadd+0x500>
c0d0311e:	46a4      	mov	ip, r4
c0d03120:	e11b      	b.n	c0d0335a <__aeabi_dadd+0x3aa>
c0d03122:	464a      	mov	r2, r9
c0d03124:	1ab2      	subs	r2, r6, r2
c0d03126:	4694      	mov	ip, r2
c0d03128:	2a00      	cmp	r2, #0
c0d0312a:	dc00      	bgt.n	c0d0312e <__aeabi_dadd+0x17e>
c0d0312c:	e0ac      	b.n	c0d03288 <__aeabi_dadd+0x2d8>
c0d0312e:	464a      	mov	r2, r9
c0d03130:	2a00      	cmp	r2, #0
c0d03132:	d043      	beq.n	c0d031bc <__aeabi_dadd+0x20c>
c0d03134:	4a78      	ldr	r2, [pc, #480]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d03136:	4296      	cmp	r6, r2
c0d03138:	d100      	bne.n	c0d0313c <__aeabi_dadd+0x18c>
c0d0313a:	e1af      	b.n	c0d0349c <__aeabi_dadd+0x4ec>
c0d0313c:	2280      	movs	r2, #128	; 0x80
c0d0313e:	003c      	movs	r4, r7
c0d03140:	0412      	lsls	r2, r2, #16
c0d03142:	4314      	orrs	r4, r2
c0d03144:	46a0      	mov	r8, r4
c0d03146:	4662      	mov	r2, ip
c0d03148:	2a38      	cmp	r2, #56	; 0x38
c0d0314a:	dc67      	bgt.n	c0d0321c <__aeabi_dadd+0x26c>
c0d0314c:	2a1f      	cmp	r2, #31
c0d0314e:	dc00      	bgt.n	c0d03152 <__aeabi_dadd+0x1a2>
c0d03150:	e15f      	b.n	c0d03412 <__aeabi_dadd+0x462>
c0d03152:	4647      	mov	r7, r8
c0d03154:	3a20      	subs	r2, #32
c0d03156:	40d7      	lsrs	r7, r2
c0d03158:	4662      	mov	r2, ip
c0d0315a:	2a20      	cmp	r2, #32
c0d0315c:	d005      	beq.n	c0d0316a <__aeabi_dadd+0x1ba>
c0d0315e:	4664      	mov	r4, ip
c0d03160:	2240      	movs	r2, #64	; 0x40
c0d03162:	1b12      	subs	r2, r2, r4
c0d03164:	4644      	mov	r4, r8
c0d03166:	4094      	lsls	r4, r2
c0d03168:	4321      	orrs	r1, r4
c0d0316a:	1e4a      	subs	r2, r1, #1
c0d0316c:	4191      	sbcs	r1, r2
c0d0316e:	000c      	movs	r4, r1
c0d03170:	433c      	orrs	r4, r7
c0d03172:	e057      	b.n	c0d03224 <__aeabi_dadd+0x274>
c0d03174:	003a      	movs	r2, r7
c0d03176:	430a      	orrs	r2, r1
c0d03178:	d100      	bne.n	c0d0317c <__aeabi_dadd+0x1cc>
c0d0317a:	e105      	b.n	c0d03388 <__aeabi_dadd+0x3d8>
c0d0317c:	0022      	movs	r2, r4
c0d0317e:	3a01      	subs	r2, #1
c0d03180:	2c01      	cmp	r4, #1
c0d03182:	d100      	bne.n	c0d03186 <__aeabi_dadd+0x1d6>
c0d03184:	e182      	b.n	c0d0348c <__aeabi_dadd+0x4dc>
c0d03186:	4c64      	ldr	r4, [pc, #400]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d03188:	45a4      	cmp	ip, r4
c0d0318a:	d05b      	beq.n	c0d03244 <__aeabi_dadd+0x294>
c0d0318c:	4694      	mov	ip, r2
c0d0318e:	e741      	b.n	c0d03014 <__aeabi_dadd+0x64>
c0d03190:	4c63      	ldr	r4, [pc, #396]	; (c0d03320 <__aeabi_dadd+0x370>)
c0d03192:	1c77      	adds	r7, r6, #1
c0d03194:	4227      	tst	r7, r4
c0d03196:	d000      	beq.n	c0d0319a <__aeabi_dadd+0x1ea>
c0d03198:	e0c4      	b.n	c0d03324 <__aeabi_dadd+0x374>
c0d0319a:	0004      	movs	r4, r0
c0d0319c:	431c      	orrs	r4, r3
c0d0319e:	2e00      	cmp	r6, #0
c0d031a0:	d000      	beq.n	c0d031a4 <__aeabi_dadd+0x1f4>
c0d031a2:	e169      	b.n	c0d03478 <__aeabi_dadd+0x4c8>
c0d031a4:	2c00      	cmp	r4, #0
c0d031a6:	d100      	bne.n	c0d031aa <__aeabi_dadd+0x1fa>
c0d031a8:	e1bf      	b.n	c0d0352a <__aeabi_dadd+0x57a>
c0d031aa:	4644      	mov	r4, r8
c0d031ac:	430c      	orrs	r4, r1
c0d031ae:	d000      	beq.n	c0d031b2 <__aeabi_dadd+0x202>
c0d031b0:	e1d0      	b.n	c0d03554 <__aeabi_dadd+0x5a4>
c0d031b2:	0742      	lsls	r2, r0, #29
c0d031b4:	08db      	lsrs	r3, r3, #3
c0d031b6:	4313      	orrs	r3, r2
c0d031b8:	08c0      	lsrs	r0, r0, #3
c0d031ba:	e029      	b.n	c0d03210 <__aeabi_dadd+0x260>
c0d031bc:	003a      	movs	r2, r7
c0d031be:	430a      	orrs	r2, r1
c0d031c0:	d100      	bne.n	c0d031c4 <__aeabi_dadd+0x214>
c0d031c2:	e170      	b.n	c0d034a6 <__aeabi_dadd+0x4f6>
c0d031c4:	4662      	mov	r2, ip
c0d031c6:	4664      	mov	r4, ip
c0d031c8:	3a01      	subs	r2, #1
c0d031ca:	2c01      	cmp	r4, #1
c0d031cc:	d100      	bne.n	c0d031d0 <__aeabi_dadd+0x220>
c0d031ce:	e0e0      	b.n	c0d03392 <__aeabi_dadd+0x3e2>
c0d031d0:	4c51      	ldr	r4, [pc, #324]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d031d2:	45a4      	cmp	ip, r4
c0d031d4:	d100      	bne.n	c0d031d8 <__aeabi_dadd+0x228>
c0d031d6:	e161      	b.n	c0d0349c <__aeabi_dadd+0x4ec>
c0d031d8:	4694      	mov	ip, r2
c0d031da:	e7b4      	b.n	c0d03146 <__aeabi_dadd+0x196>
c0d031dc:	003a      	movs	r2, r7
c0d031de:	391f      	subs	r1, #31
c0d031e0:	40ca      	lsrs	r2, r1
c0d031e2:	0011      	movs	r1, r2
c0d031e4:	2b20      	cmp	r3, #32
c0d031e6:	d003      	beq.n	c0d031f0 <__aeabi_dadd+0x240>
c0d031e8:	2240      	movs	r2, #64	; 0x40
c0d031ea:	1ad3      	subs	r3, r2, r3
c0d031ec:	409f      	lsls	r7, r3
c0d031ee:	433c      	orrs	r4, r7
c0d031f0:	1e63      	subs	r3, r4, #1
c0d031f2:	419c      	sbcs	r4, r3
c0d031f4:	2700      	movs	r7, #0
c0d031f6:	2600      	movs	r6, #0
c0d031f8:	430c      	orrs	r4, r1
c0d031fa:	0763      	lsls	r3, r4, #29
c0d031fc:	d000      	beq.n	c0d03200 <__aeabi_dadd+0x250>
c0d031fe:	e753      	b.n	c0d030a8 <__aeabi_dadd+0xf8>
c0d03200:	46b4      	mov	ip, r6
c0d03202:	08e4      	lsrs	r4, r4, #3
c0d03204:	077b      	lsls	r3, r7, #29
c0d03206:	4323      	orrs	r3, r4
c0d03208:	08f8      	lsrs	r0, r7, #3
c0d0320a:	4a43      	ldr	r2, [pc, #268]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d0320c:	4594      	cmp	ip, r2
c0d0320e:	d01d      	beq.n	c0d0324c <__aeabi_dadd+0x29c>
c0d03210:	4662      	mov	r2, ip
c0d03212:	0307      	lsls	r7, r0, #12
c0d03214:	0552      	lsls	r2, r2, #21
c0d03216:	0b3f      	lsrs	r7, r7, #12
c0d03218:	0d52      	lsrs	r2, r2, #21
c0d0321a:	e760      	b.n	c0d030de <__aeabi_dadd+0x12e>
c0d0321c:	4644      	mov	r4, r8
c0d0321e:	430c      	orrs	r4, r1
c0d03220:	1e62      	subs	r2, r4, #1
c0d03222:	4194      	sbcs	r4, r2
c0d03224:	18e4      	adds	r4, r4, r3
c0d03226:	429c      	cmp	r4, r3
c0d03228:	419b      	sbcs	r3, r3
c0d0322a:	425f      	negs	r7, r3
c0d0322c:	183f      	adds	r7, r7, r0
c0d0322e:	023b      	lsls	r3, r7, #8
c0d03230:	d5e3      	bpl.n	c0d031fa <__aeabi_dadd+0x24a>
c0d03232:	4b39      	ldr	r3, [pc, #228]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d03234:	3601      	adds	r6, #1
c0d03236:	429e      	cmp	r6, r3
c0d03238:	d000      	beq.n	c0d0323c <__aeabi_dadd+0x28c>
c0d0323a:	e0b5      	b.n	c0d033a8 <__aeabi_dadd+0x3f8>
c0d0323c:	0032      	movs	r2, r6
c0d0323e:	2700      	movs	r7, #0
c0d03240:	2300      	movs	r3, #0
c0d03242:	e74c      	b.n	c0d030de <__aeabi_dadd+0x12e>
c0d03244:	0742      	lsls	r2, r0, #29
c0d03246:	08db      	lsrs	r3, r3, #3
c0d03248:	4313      	orrs	r3, r2
c0d0324a:	08c0      	lsrs	r0, r0, #3
c0d0324c:	001a      	movs	r2, r3
c0d0324e:	4302      	orrs	r2, r0
c0d03250:	d100      	bne.n	c0d03254 <__aeabi_dadd+0x2a4>
c0d03252:	e1e1      	b.n	c0d03618 <__aeabi_dadd+0x668>
c0d03254:	2780      	movs	r7, #128	; 0x80
c0d03256:	033f      	lsls	r7, r7, #12
c0d03258:	4307      	orrs	r7, r0
c0d0325a:	033f      	lsls	r7, r7, #12
c0d0325c:	4a2e      	ldr	r2, [pc, #184]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d0325e:	0b3f      	lsrs	r7, r7, #12
c0d03260:	e73d      	b.n	c0d030de <__aeabi_dadd+0x12e>
c0d03262:	0020      	movs	r0, r4
c0d03264:	f001 fc8c 	bl	c0d04b80 <__clzsi2>
c0d03268:	0001      	movs	r1, r0
c0d0326a:	3118      	adds	r1, #24
c0d0326c:	291f      	cmp	r1, #31
c0d0326e:	dc00      	bgt.n	c0d03272 <__aeabi_dadd+0x2c2>
c0d03270:	e6fc      	b.n	c0d0306c <__aeabi_dadd+0xbc>
c0d03272:	3808      	subs	r0, #8
c0d03274:	4084      	lsls	r4, r0
c0d03276:	0027      	movs	r7, r4
c0d03278:	2400      	movs	r4, #0
c0d0327a:	42b1      	cmp	r1, r6
c0d0327c:	db00      	blt.n	c0d03280 <__aeabi_dadd+0x2d0>
c0d0327e:	e6ff      	b.n	c0d03080 <__aeabi_dadd+0xd0>
c0d03280:	4a26      	ldr	r2, [pc, #152]	; (c0d0331c <__aeabi_dadd+0x36c>)
c0d03282:	1a76      	subs	r6, r6, r1
c0d03284:	4017      	ands	r7, r2
c0d03286:	e70d      	b.n	c0d030a4 <__aeabi_dadd+0xf4>
c0d03288:	2a00      	cmp	r2, #0
c0d0328a:	d02f      	beq.n	c0d032ec <__aeabi_dadd+0x33c>
c0d0328c:	464a      	mov	r2, r9
c0d0328e:	1b92      	subs	r2, r2, r6
c0d03290:	4694      	mov	ip, r2
c0d03292:	2e00      	cmp	r6, #0
c0d03294:	d100      	bne.n	c0d03298 <__aeabi_dadd+0x2e8>
c0d03296:	e0ad      	b.n	c0d033f4 <__aeabi_dadd+0x444>
c0d03298:	4a1f      	ldr	r2, [pc, #124]	; (c0d03318 <__aeabi_dadd+0x368>)
c0d0329a:	4591      	cmp	r9, r2
c0d0329c:	d100      	bne.n	c0d032a0 <__aeabi_dadd+0x2f0>
c0d0329e:	e10f      	b.n	c0d034c0 <__aeabi_dadd+0x510>
c0d032a0:	2280      	movs	r2, #128	; 0x80
c0d032a2:	0412      	lsls	r2, r2, #16
c0d032a4:	4310      	orrs	r0, r2
c0d032a6:	4662      	mov	r2, ip
c0d032a8:	2a38      	cmp	r2, #56	; 0x38
c0d032aa:	dd00      	ble.n	c0d032ae <__aeabi_dadd+0x2fe>
c0d032ac:	e10f      	b.n	c0d034ce <__aeabi_dadd+0x51e>
c0d032ae:	2a1f      	cmp	r2, #31
c0d032b0:	dd00      	ble.n	c0d032b4 <__aeabi_dadd+0x304>
c0d032b2:	e180      	b.n	c0d035b6 <__aeabi_dadd+0x606>
c0d032b4:	4664      	mov	r4, ip
c0d032b6:	2220      	movs	r2, #32
c0d032b8:	001e      	movs	r6, r3
c0d032ba:	1b12      	subs	r2, r2, r4
c0d032bc:	4667      	mov	r7, ip
c0d032be:	0004      	movs	r4, r0
c0d032c0:	4093      	lsls	r3, r2
c0d032c2:	4094      	lsls	r4, r2
c0d032c4:	40fe      	lsrs	r6, r7
c0d032c6:	1e5a      	subs	r2, r3, #1
c0d032c8:	4193      	sbcs	r3, r2
c0d032ca:	40f8      	lsrs	r0, r7
c0d032cc:	4334      	orrs	r4, r6
c0d032ce:	431c      	orrs	r4, r3
c0d032d0:	4480      	add	r8, r0
c0d032d2:	1864      	adds	r4, r4, r1
c0d032d4:	428c      	cmp	r4, r1
c0d032d6:	41bf      	sbcs	r7, r7
c0d032d8:	427f      	negs	r7, r7
c0d032da:	464e      	mov	r6, r9
c0d032dc:	4447      	add	r7, r8
c0d032de:	e7a6      	b.n	c0d0322e <__aeabi_dadd+0x27e>
c0d032e0:	4642      	mov	r2, r8
c0d032e2:	430a      	orrs	r2, r1
c0d032e4:	0011      	movs	r1, r2
c0d032e6:	1e4a      	subs	r2, r1, #1
c0d032e8:	4191      	sbcs	r1, r2
c0d032ea:	e6ad      	b.n	c0d03048 <__aeabi_dadd+0x98>
c0d032ec:	4c0c      	ldr	r4, [pc, #48]	; (c0d03320 <__aeabi_dadd+0x370>)
c0d032ee:	1c72      	adds	r2, r6, #1
c0d032f0:	4222      	tst	r2, r4
c0d032f2:	d000      	beq.n	c0d032f6 <__aeabi_dadd+0x346>
c0d032f4:	e0a1      	b.n	c0d0343a <__aeabi_dadd+0x48a>
c0d032f6:	0002      	movs	r2, r0
c0d032f8:	431a      	orrs	r2, r3
c0d032fa:	2e00      	cmp	r6, #0
c0d032fc:	d000      	beq.n	c0d03300 <__aeabi_dadd+0x350>
c0d032fe:	e0fa      	b.n	c0d034f6 <__aeabi_dadd+0x546>
c0d03300:	2a00      	cmp	r2, #0
c0d03302:	d100      	bne.n	c0d03306 <__aeabi_dadd+0x356>
c0d03304:	e145      	b.n	c0d03592 <__aeabi_dadd+0x5e2>
c0d03306:	003a      	movs	r2, r7
c0d03308:	430a      	orrs	r2, r1
c0d0330a:	d000      	beq.n	c0d0330e <__aeabi_dadd+0x35e>
c0d0330c:	e146      	b.n	c0d0359c <__aeabi_dadd+0x5ec>
c0d0330e:	0742      	lsls	r2, r0, #29
c0d03310:	08db      	lsrs	r3, r3, #3
c0d03312:	4313      	orrs	r3, r2
c0d03314:	08c0      	lsrs	r0, r0, #3
c0d03316:	e77b      	b.n	c0d03210 <__aeabi_dadd+0x260>
c0d03318:	000007ff 	.word	0x000007ff
c0d0331c:	ff7fffff 	.word	0xff7fffff
c0d03320:	000007fe 	.word	0x000007fe
c0d03324:	4647      	mov	r7, r8
c0d03326:	1a5c      	subs	r4, r3, r1
c0d03328:	1bc2      	subs	r2, r0, r7
c0d0332a:	42a3      	cmp	r3, r4
c0d0332c:	41bf      	sbcs	r7, r7
c0d0332e:	427f      	negs	r7, r7
c0d03330:	46b9      	mov	r9, r7
c0d03332:	0017      	movs	r7, r2
c0d03334:	464a      	mov	r2, r9
c0d03336:	1abf      	subs	r7, r7, r2
c0d03338:	023a      	lsls	r2, r7, #8
c0d0333a:	d500      	bpl.n	c0d0333e <__aeabi_dadd+0x38e>
c0d0333c:	e08d      	b.n	c0d0345a <__aeabi_dadd+0x4aa>
c0d0333e:	0023      	movs	r3, r4
c0d03340:	433b      	orrs	r3, r7
c0d03342:	d000      	beq.n	c0d03346 <__aeabi_dadd+0x396>
c0d03344:	e68a      	b.n	c0d0305c <__aeabi_dadd+0xac>
c0d03346:	2000      	movs	r0, #0
c0d03348:	2500      	movs	r5, #0
c0d0334a:	e761      	b.n	c0d03210 <__aeabi_dadd+0x260>
c0d0334c:	4cb4      	ldr	r4, [pc, #720]	; (c0d03620 <__aeabi_dadd+0x670>)
c0d0334e:	45a1      	cmp	r9, r4
c0d03350:	d100      	bne.n	c0d03354 <__aeabi_dadd+0x3a4>
c0d03352:	e0ad      	b.n	c0d034b0 <__aeabi_dadd+0x500>
c0d03354:	2480      	movs	r4, #128	; 0x80
c0d03356:	0424      	lsls	r4, r4, #16
c0d03358:	4320      	orrs	r0, r4
c0d0335a:	4664      	mov	r4, ip
c0d0335c:	2c38      	cmp	r4, #56	; 0x38
c0d0335e:	dc3d      	bgt.n	c0d033dc <__aeabi_dadd+0x42c>
c0d03360:	4662      	mov	r2, ip
c0d03362:	2c1f      	cmp	r4, #31
c0d03364:	dd00      	ble.n	c0d03368 <__aeabi_dadd+0x3b8>
c0d03366:	e0b7      	b.n	c0d034d8 <__aeabi_dadd+0x528>
c0d03368:	2520      	movs	r5, #32
c0d0336a:	001e      	movs	r6, r3
c0d0336c:	1b2d      	subs	r5, r5, r4
c0d0336e:	0004      	movs	r4, r0
c0d03370:	40ab      	lsls	r3, r5
c0d03372:	40ac      	lsls	r4, r5
c0d03374:	40d6      	lsrs	r6, r2
c0d03376:	40d0      	lsrs	r0, r2
c0d03378:	4642      	mov	r2, r8
c0d0337a:	1e5d      	subs	r5, r3, #1
c0d0337c:	41ab      	sbcs	r3, r5
c0d0337e:	4334      	orrs	r4, r6
c0d03380:	1a12      	subs	r2, r2, r0
c0d03382:	4690      	mov	r8, r2
c0d03384:	4323      	orrs	r3, r4
c0d03386:	e02c      	b.n	c0d033e2 <__aeabi_dadd+0x432>
c0d03388:	0742      	lsls	r2, r0, #29
c0d0338a:	08db      	lsrs	r3, r3, #3
c0d0338c:	4313      	orrs	r3, r2
c0d0338e:	08c0      	lsrs	r0, r0, #3
c0d03390:	e73b      	b.n	c0d0320a <__aeabi_dadd+0x25a>
c0d03392:	185c      	adds	r4, r3, r1
c0d03394:	429c      	cmp	r4, r3
c0d03396:	419b      	sbcs	r3, r3
c0d03398:	4440      	add	r0, r8
c0d0339a:	425b      	negs	r3, r3
c0d0339c:	18c7      	adds	r7, r0, r3
c0d0339e:	2601      	movs	r6, #1
c0d033a0:	023b      	lsls	r3, r7, #8
c0d033a2:	d400      	bmi.n	c0d033a6 <__aeabi_dadd+0x3f6>
c0d033a4:	e729      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d033a6:	2602      	movs	r6, #2
c0d033a8:	4a9e      	ldr	r2, [pc, #632]	; (c0d03624 <__aeabi_dadd+0x674>)
c0d033aa:	0863      	lsrs	r3, r4, #1
c0d033ac:	4017      	ands	r7, r2
c0d033ae:	2201      	movs	r2, #1
c0d033b0:	4014      	ands	r4, r2
c0d033b2:	431c      	orrs	r4, r3
c0d033b4:	07fb      	lsls	r3, r7, #31
c0d033b6:	431c      	orrs	r4, r3
c0d033b8:	087f      	lsrs	r7, r7, #1
c0d033ba:	e673      	b.n	c0d030a4 <__aeabi_dadd+0xf4>
c0d033bc:	4644      	mov	r4, r8
c0d033be:	3a20      	subs	r2, #32
c0d033c0:	40d4      	lsrs	r4, r2
c0d033c2:	4662      	mov	r2, ip
c0d033c4:	2a20      	cmp	r2, #32
c0d033c6:	d005      	beq.n	c0d033d4 <__aeabi_dadd+0x424>
c0d033c8:	4667      	mov	r7, ip
c0d033ca:	2240      	movs	r2, #64	; 0x40
c0d033cc:	1bd2      	subs	r2, r2, r7
c0d033ce:	4647      	mov	r7, r8
c0d033d0:	4097      	lsls	r7, r2
c0d033d2:	4339      	orrs	r1, r7
c0d033d4:	1e4a      	subs	r2, r1, #1
c0d033d6:	4191      	sbcs	r1, r2
c0d033d8:	4321      	orrs	r1, r4
c0d033da:	e635      	b.n	c0d03048 <__aeabi_dadd+0x98>
c0d033dc:	4303      	orrs	r3, r0
c0d033de:	1e58      	subs	r0, r3, #1
c0d033e0:	4183      	sbcs	r3, r0
c0d033e2:	1acc      	subs	r4, r1, r3
c0d033e4:	42a1      	cmp	r1, r4
c0d033e6:	41bf      	sbcs	r7, r7
c0d033e8:	4643      	mov	r3, r8
c0d033ea:	427f      	negs	r7, r7
c0d033ec:	4655      	mov	r5, sl
c0d033ee:	464e      	mov	r6, r9
c0d033f0:	1bdf      	subs	r7, r3, r7
c0d033f2:	e62e      	b.n	c0d03052 <__aeabi_dadd+0xa2>
c0d033f4:	0002      	movs	r2, r0
c0d033f6:	431a      	orrs	r2, r3
c0d033f8:	d100      	bne.n	c0d033fc <__aeabi_dadd+0x44c>
c0d033fa:	e0bd      	b.n	c0d03578 <__aeabi_dadd+0x5c8>
c0d033fc:	4662      	mov	r2, ip
c0d033fe:	4664      	mov	r4, ip
c0d03400:	3a01      	subs	r2, #1
c0d03402:	2c01      	cmp	r4, #1
c0d03404:	d100      	bne.n	c0d03408 <__aeabi_dadd+0x458>
c0d03406:	e0e5      	b.n	c0d035d4 <__aeabi_dadd+0x624>
c0d03408:	4c85      	ldr	r4, [pc, #532]	; (c0d03620 <__aeabi_dadd+0x670>)
c0d0340a:	45a4      	cmp	ip, r4
c0d0340c:	d058      	beq.n	c0d034c0 <__aeabi_dadd+0x510>
c0d0340e:	4694      	mov	ip, r2
c0d03410:	e749      	b.n	c0d032a6 <__aeabi_dadd+0x2f6>
c0d03412:	4664      	mov	r4, ip
c0d03414:	2220      	movs	r2, #32
c0d03416:	1b12      	subs	r2, r2, r4
c0d03418:	4644      	mov	r4, r8
c0d0341a:	4094      	lsls	r4, r2
c0d0341c:	000f      	movs	r7, r1
c0d0341e:	46a1      	mov	r9, r4
c0d03420:	4664      	mov	r4, ip
c0d03422:	4091      	lsls	r1, r2
c0d03424:	40e7      	lsrs	r7, r4
c0d03426:	464c      	mov	r4, r9
c0d03428:	1e4a      	subs	r2, r1, #1
c0d0342a:	4191      	sbcs	r1, r2
c0d0342c:	433c      	orrs	r4, r7
c0d0342e:	4642      	mov	r2, r8
c0d03430:	430c      	orrs	r4, r1
c0d03432:	4661      	mov	r1, ip
c0d03434:	40ca      	lsrs	r2, r1
c0d03436:	1880      	adds	r0, r0, r2
c0d03438:	e6f4      	b.n	c0d03224 <__aeabi_dadd+0x274>
c0d0343a:	4c79      	ldr	r4, [pc, #484]	; (c0d03620 <__aeabi_dadd+0x670>)
c0d0343c:	42a2      	cmp	r2, r4
c0d0343e:	d100      	bne.n	c0d03442 <__aeabi_dadd+0x492>
c0d03440:	e6fd      	b.n	c0d0323e <__aeabi_dadd+0x28e>
c0d03442:	1859      	adds	r1, r3, r1
c0d03444:	4299      	cmp	r1, r3
c0d03446:	419b      	sbcs	r3, r3
c0d03448:	4440      	add	r0, r8
c0d0344a:	425f      	negs	r7, r3
c0d0344c:	19c7      	adds	r7, r0, r7
c0d0344e:	07fc      	lsls	r4, r7, #31
c0d03450:	0849      	lsrs	r1, r1, #1
c0d03452:	0016      	movs	r6, r2
c0d03454:	430c      	orrs	r4, r1
c0d03456:	087f      	lsrs	r7, r7, #1
c0d03458:	e6cf      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d0345a:	1acc      	subs	r4, r1, r3
c0d0345c:	42a1      	cmp	r1, r4
c0d0345e:	41bf      	sbcs	r7, r7
c0d03460:	4643      	mov	r3, r8
c0d03462:	427f      	negs	r7, r7
c0d03464:	1a18      	subs	r0, r3, r0
c0d03466:	4655      	mov	r5, sl
c0d03468:	1bc7      	subs	r7, r0, r7
c0d0346a:	e5f7      	b.n	c0d0305c <__aeabi_dadd+0xac>
c0d0346c:	08c9      	lsrs	r1, r1, #3
c0d0346e:	077b      	lsls	r3, r7, #29
c0d03470:	4655      	mov	r5, sl
c0d03472:	430b      	orrs	r3, r1
c0d03474:	08f8      	lsrs	r0, r7, #3
c0d03476:	e6c8      	b.n	c0d0320a <__aeabi_dadd+0x25a>
c0d03478:	2c00      	cmp	r4, #0
c0d0347a:	d000      	beq.n	c0d0347e <__aeabi_dadd+0x4ce>
c0d0347c:	e081      	b.n	c0d03582 <__aeabi_dadd+0x5d2>
c0d0347e:	4643      	mov	r3, r8
c0d03480:	430b      	orrs	r3, r1
c0d03482:	d115      	bne.n	c0d034b0 <__aeabi_dadd+0x500>
c0d03484:	2080      	movs	r0, #128	; 0x80
c0d03486:	2500      	movs	r5, #0
c0d03488:	0300      	lsls	r0, r0, #12
c0d0348a:	e6e3      	b.n	c0d03254 <__aeabi_dadd+0x2a4>
c0d0348c:	1a5c      	subs	r4, r3, r1
c0d0348e:	42a3      	cmp	r3, r4
c0d03490:	419b      	sbcs	r3, r3
c0d03492:	1bc7      	subs	r7, r0, r7
c0d03494:	425b      	negs	r3, r3
c0d03496:	2601      	movs	r6, #1
c0d03498:	1aff      	subs	r7, r7, r3
c0d0349a:	e5da      	b.n	c0d03052 <__aeabi_dadd+0xa2>
c0d0349c:	0742      	lsls	r2, r0, #29
c0d0349e:	08db      	lsrs	r3, r3, #3
c0d034a0:	4313      	orrs	r3, r2
c0d034a2:	08c0      	lsrs	r0, r0, #3
c0d034a4:	e6d2      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d034a6:	0742      	lsls	r2, r0, #29
c0d034a8:	08db      	lsrs	r3, r3, #3
c0d034aa:	4313      	orrs	r3, r2
c0d034ac:	08c0      	lsrs	r0, r0, #3
c0d034ae:	e6ac      	b.n	c0d0320a <__aeabi_dadd+0x25a>
c0d034b0:	4643      	mov	r3, r8
c0d034b2:	4642      	mov	r2, r8
c0d034b4:	08c9      	lsrs	r1, r1, #3
c0d034b6:	075b      	lsls	r3, r3, #29
c0d034b8:	4655      	mov	r5, sl
c0d034ba:	430b      	orrs	r3, r1
c0d034bc:	08d0      	lsrs	r0, r2, #3
c0d034be:	e6c5      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d034c0:	4643      	mov	r3, r8
c0d034c2:	4642      	mov	r2, r8
c0d034c4:	075b      	lsls	r3, r3, #29
c0d034c6:	08c9      	lsrs	r1, r1, #3
c0d034c8:	430b      	orrs	r3, r1
c0d034ca:	08d0      	lsrs	r0, r2, #3
c0d034cc:	e6be      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d034ce:	4303      	orrs	r3, r0
c0d034d0:	001c      	movs	r4, r3
c0d034d2:	1e63      	subs	r3, r4, #1
c0d034d4:	419c      	sbcs	r4, r3
c0d034d6:	e6fc      	b.n	c0d032d2 <__aeabi_dadd+0x322>
c0d034d8:	0002      	movs	r2, r0
c0d034da:	3c20      	subs	r4, #32
c0d034dc:	40e2      	lsrs	r2, r4
c0d034de:	0014      	movs	r4, r2
c0d034e0:	4662      	mov	r2, ip
c0d034e2:	2a20      	cmp	r2, #32
c0d034e4:	d003      	beq.n	c0d034ee <__aeabi_dadd+0x53e>
c0d034e6:	2540      	movs	r5, #64	; 0x40
c0d034e8:	1aad      	subs	r5, r5, r2
c0d034ea:	40a8      	lsls	r0, r5
c0d034ec:	4303      	orrs	r3, r0
c0d034ee:	1e58      	subs	r0, r3, #1
c0d034f0:	4183      	sbcs	r3, r0
c0d034f2:	4323      	orrs	r3, r4
c0d034f4:	e775      	b.n	c0d033e2 <__aeabi_dadd+0x432>
c0d034f6:	2a00      	cmp	r2, #0
c0d034f8:	d0e2      	beq.n	c0d034c0 <__aeabi_dadd+0x510>
c0d034fa:	003a      	movs	r2, r7
c0d034fc:	430a      	orrs	r2, r1
c0d034fe:	d0cd      	beq.n	c0d0349c <__aeabi_dadd+0x4ec>
c0d03500:	0742      	lsls	r2, r0, #29
c0d03502:	08db      	lsrs	r3, r3, #3
c0d03504:	4313      	orrs	r3, r2
c0d03506:	2280      	movs	r2, #128	; 0x80
c0d03508:	08c0      	lsrs	r0, r0, #3
c0d0350a:	0312      	lsls	r2, r2, #12
c0d0350c:	4210      	tst	r0, r2
c0d0350e:	d006      	beq.n	c0d0351e <__aeabi_dadd+0x56e>
c0d03510:	08fc      	lsrs	r4, r7, #3
c0d03512:	4214      	tst	r4, r2
c0d03514:	d103      	bne.n	c0d0351e <__aeabi_dadd+0x56e>
c0d03516:	0020      	movs	r0, r4
c0d03518:	08cb      	lsrs	r3, r1, #3
c0d0351a:	077a      	lsls	r2, r7, #29
c0d0351c:	4313      	orrs	r3, r2
c0d0351e:	0f5a      	lsrs	r2, r3, #29
c0d03520:	00db      	lsls	r3, r3, #3
c0d03522:	0752      	lsls	r2, r2, #29
c0d03524:	08db      	lsrs	r3, r3, #3
c0d03526:	4313      	orrs	r3, r2
c0d03528:	e690      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d0352a:	4643      	mov	r3, r8
c0d0352c:	430b      	orrs	r3, r1
c0d0352e:	d100      	bne.n	c0d03532 <__aeabi_dadd+0x582>
c0d03530:	e709      	b.n	c0d03346 <__aeabi_dadd+0x396>
c0d03532:	4643      	mov	r3, r8
c0d03534:	4642      	mov	r2, r8
c0d03536:	08c9      	lsrs	r1, r1, #3
c0d03538:	075b      	lsls	r3, r3, #29
c0d0353a:	4655      	mov	r5, sl
c0d0353c:	430b      	orrs	r3, r1
c0d0353e:	08d0      	lsrs	r0, r2, #3
c0d03540:	e666      	b.n	c0d03210 <__aeabi_dadd+0x260>
c0d03542:	1acc      	subs	r4, r1, r3
c0d03544:	42a1      	cmp	r1, r4
c0d03546:	4189      	sbcs	r1, r1
c0d03548:	1a3f      	subs	r7, r7, r0
c0d0354a:	4249      	negs	r1, r1
c0d0354c:	4655      	mov	r5, sl
c0d0354e:	2601      	movs	r6, #1
c0d03550:	1a7f      	subs	r7, r7, r1
c0d03552:	e57e      	b.n	c0d03052 <__aeabi_dadd+0xa2>
c0d03554:	4642      	mov	r2, r8
c0d03556:	1a5c      	subs	r4, r3, r1
c0d03558:	1a87      	subs	r7, r0, r2
c0d0355a:	42a3      	cmp	r3, r4
c0d0355c:	4192      	sbcs	r2, r2
c0d0355e:	4252      	negs	r2, r2
c0d03560:	1abf      	subs	r7, r7, r2
c0d03562:	023a      	lsls	r2, r7, #8
c0d03564:	d53d      	bpl.n	c0d035e2 <__aeabi_dadd+0x632>
c0d03566:	1acc      	subs	r4, r1, r3
c0d03568:	42a1      	cmp	r1, r4
c0d0356a:	4189      	sbcs	r1, r1
c0d0356c:	4643      	mov	r3, r8
c0d0356e:	4249      	negs	r1, r1
c0d03570:	1a1f      	subs	r7, r3, r0
c0d03572:	4655      	mov	r5, sl
c0d03574:	1a7f      	subs	r7, r7, r1
c0d03576:	e595      	b.n	c0d030a4 <__aeabi_dadd+0xf4>
c0d03578:	077b      	lsls	r3, r7, #29
c0d0357a:	08c9      	lsrs	r1, r1, #3
c0d0357c:	430b      	orrs	r3, r1
c0d0357e:	08f8      	lsrs	r0, r7, #3
c0d03580:	e643      	b.n	c0d0320a <__aeabi_dadd+0x25a>
c0d03582:	4644      	mov	r4, r8
c0d03584:	08db      	lsrs	r3, r3, #3
c0d03586:	430c      	orrs	r4, r1
c0d03588:	d130      	bne.n	c0d035ec <__aeabi_dadd+0x63c>
c0d0358a:	0742      	lsls	r2, r0, #29
c0d0358c:	4313      	orrs	r3, r2
c0d0358e:	08c0      	lsrs	r0, r0, #3
c0d03590:	e65c      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d03592:	077b      	lsls	r3, r7, #29
c0d03594:	08c9      	lsrs	r1, r1, #3
c0d03596:	430b      	orrs	r3, r1
c0d03598:	08f8      	lsrs	r0, r7, #3
c0d0359a:	e639      	b.n	c0d03210 <__aeabi_dadd+0x260>
c0d0359c:	185c      	adds	r4, r3, r1
c0d0359e:	429c      	cmp	r4, r3
c0d035a0:	419b      	sbcs	r3, r3
c0d035a2:	4440      	add	r0, r8
c0d035a4:	425b      	negs	r3, r3
c0d035a6:	18c7      	adds	r7, r0, r3
c0d035a8:	023b      	lsls	r3, r7, #8
c0d035aa:	d400      	bmi.n	c0d035ae <__aeabi_dadd+0x5fe>
c0d035ac:	e625      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d035ae:	4b1d      	ldr	r3, [pc, #116]	; (c0d03624 <__aeabi_dadd+0x674>)
c0d035b0:	2601      	movs	r6, #1
c0d035b2:	401f      	ands	r7, r3
c0d035b4:	e621      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d035b6:	0004      	movs	r4, r0
c0d035b8:	3a20      	subs	r2, #32
c0d035ba:	40d4      	lsrs	r4, r2
c0d035bc:	4662      	mov	r2, ip
c0d035be:	2a20      	cmp	r2, #32
c0d035c0:	d004      	beq.n	c0d035cc <__aeabi_dadd+0x61c>
c0d035c2:	2240      	movs	r2, #64	; 0x40
c0d035c4:	4666      	mov	r6, ip
c0d035c6:	1b92      	subs	r2, r2, r6
c0d035c8:	4090      	lsls	r0, r2
c0d035ca:	4303      	orrs	r3, r0
c0d035cc:	1e5a      	subs	r2, r3, #1
c0d035ce:	4193      	sbcs	r3, r2
c0d035d0:	431c      	orrs	r4, r3
c0d035d2:	e67e      	b.n	c0d032d2 <__aeabi_dadd+0x322>
c0d035d4:	185c      	adds	r4, r3, r1
c0d035d6:	428c      	cmp	r4, r1
c0d035d8:	4189      	sbcs	r1, r1
c0d035da:	4440      	add	r0, r8
c0d035dc:	4249      	negs	r1, r1
c0d035de:	1847      	adds	r7, r0, r1
c0d035e0:	e6dd      	b.n	c0d0339e <__aeabi_dadd+0x3ee>
c0d035e2:	0023      	movs	r3, r4
c0d035e4:	433b      	orrs	r3, r7
c0d035e6:	d100      	bne.n	c0d035ea <__aeabi_dadd+0x63a>
c0d035e8:	e6ad      	b.n	c0d03346 <__aeabi_dadd+0x396>
c0d035ea:	e606      	b.n	c0d031fa <__aeabi_dadd+0x24a>
c0d035ec:	0744      	lsls	r4, r0, #29
c0d035ee:	4323      	orrs	r3, r4
c0d035f0:	2480      	movs	r4, #128	; 0x80
c0d035f2:	08c0      	lsrs	r0, r0, #3
c0d035f4:	0324      	lsls	r4, r4, #12
c0d035f6:	4220      	tst	r0, r4
c0d035f8:	d008      	beq.n	c0d0360c <__aeabi_dadd+0x65c>
c0d035fa:	4642      	mov	r2, r8
c0d035fc:	08d6      	lsrs	r6, r2, #3
c0d035fe:	4226      	tst	r6, r4
c0d03600:	d104      	bne.n	c0d0360c <__aeabi_dadd+0x65c>
c0d03602:	4655      	mov	r5, sl
c0d03604:	0030      	movs	r0, r6
c0d03606:	08cb      	lsrs	r3, r1, #3
c0d03608:	0751      	lsls	r1, r2, #29
c0d0360a:	430b      	orrs	r3, r1
c0d0360c:	0f5a      	lsrs	r2, r3, #29
c0d0360e:	00db      	lsls	r3, r3, #3
c0d03610:	08db      	lsrs	r3, r3, #3
c0d03612:	0752      	lsls	r2, r2, #29
c0d03614:	4313      	orrs	r3, r2
c0d03616:	e619      	b.n	c0d0324c <__aeabi_dadd+0x29c>
c0d03618:	2300      	movs	r3, #0
c0d0361a:	4a01      	ldr	r2, [pc, #4]	; (c0d03620 <__aeabi_dadd+0x670>)
c0d0361c:	001f      	movs	r7, r3
c0d0361e:	e55e      	b.n	c0d030de <__aeabi_dadd+0x12e>
c0d03620:	000007ff 	.word	0x000007ff
c0d03624:	ff7fffff 	.word	0xff7fffff

c0d03628 <__aeabi_ddiv>:
c0d03628:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0362a:	4657      	mov	r7, sl
c0d0362c:	464e      	mov	r6, r9
c0d0362e:	4645      	mov	r5, r8
c0d03630:	46de      	mov	lr, fp
c0d03632:	b5e0      	push	{r5, r6, r7, lr}
c0d03634:	4681      	mov	r9, r0
c0d03636:	0005      	movs	r5, r0
c0d03638:	030c      	lsls	r4, r1, #12
c0d0363a:	0048      	lsls	r0, r1, #1
c0d0363c:	4692      	mov	sl, r2
c0d0363e:	001f      	movs	r7, r3
c0d03640:	b085      	sub	sp, #20
c0d03642:	0b24      	lsrs	r4, r4, #12
c0d03644:	0d40      	lsrs	r0, r0, #21
c0d03646:	0fce      	lsrs	r6, r1, #31
c0d03648:	2800      	cmp	r0, #0
c0d0364a:	d100      	bne.n	c0d0364e <__aeabi_ddiv+0x26>
c0d0364c:	e156      	b.n	c0d038fc <__aeabi_ddiv+0x2d4>
c0d0364e:	4bd4      	ldr	r3, [pc, #848]	; (c0d039a0 <__aeabi_ddiv+0x378>)
c0d03650:	4298      	cmp	r0, r3
c0d03652:	d100      	bne.n	c0d03656 <__aeabi_ddiv+0x2e>
c0d03654:	e172      	b.n	c0d0393c <__aeabi_ddiv+0x314>
c0d03656:	0f6b      	lsrs	r3, r5, #29
c0d03658:	00e4      	lsls	r4, r4, #3
c0d0365a:	431c      	orrs	r4, r3
c0d0365c:	2380      	movs	r3, #128	; 0x80
c0d0365e:	041b      	lsls	r3, r3, #16
c0d03660:	4323      	orrs	r3, r4
c0d03662:	4698      	mov	r8, r3
c0d03664:	4bcf      	ldr	r3, [pc, #828]	; (c0d039a4 <__aeabi_ddiv+0x37c>)
c0d03666:	00ed      	lsls	r5, r5, #3
c0d03668:	469b      	mov	fp, r3
c0d0366a:	2300      	movs	r3, #0
c0d0366c:	4699      	mov	r9, r3
c0d0366e:	4483      	add	fp, r0
c0d03670:	9300      	str	r3, [sp, #0]
c0d03672:	033c      	lsls	r4, r7, #12
c0d03674:	007b      	lsls	r3, r7, #1
c0d03676:	4650      	mov	r0, sl
c0d03678:	0b24      	lsrs	r4, r4, #12
c0d0367a:	0d5b      	lsrs	r3, r3, #21
c0d0367c:	0fff      	lsrs	r7, r7, #31
c0d0367e:	2b00      	cmp	r3, #0
c0d03680:	d100      	bne.n	c0d03684 <__aeabi_ddiv+0x5c>
c0d03682:	e11f      	b.n	c0d038c4 <__aeabi_ddiv+0x29c>
c0d03684:	4ac6      	ldr	r2, [pc, #792]	; (c0d039a0 <__aeabi_ddiv+0x378>)
c0d03686:	4293      	cmp	r3, r2
c0d03688:	d100      	bne.n	c0d0368c <__aeabi_ddiv+0x64>
c0d0368a:	e162      	b.n	c0d03952 <__aeabi_ddiv+0x32a>
c0d0368c:	49c5      	ldr	r1, [pc, #788]	; (c0d039a4 <__aeabi_ddiv+0x37c>)
c0d0368e:	0f42      	lsrs	r2, r0, #29
c0d03690:	468c      	mov	ip, r1
c0d03692:	00e4      	lsls	r4, r4, #3
c0d03694:	4659      	mov	r1, fp
c0d03696:	4314      	orrs	r4, r2
c0d03698:	2280      	movs	r2, #128	; 0x80
c0d0369a:	4463      	add	r3, ip
c0d0369c:	0412      	lsls	r2, r2, #16
c0d0369e:	1acb      	subs	r3, r1, r3
c0d036a0:	4314      	orrs	r4, r2
c0d036a2:	469b      	mov	fp, r3
c0d036a4:	00c2      	lsls	r2, r0, #3
c0d036a6:	2000      	movs	r0, #0
c0d036a8:	0033      	movs	r3, r6
c0d036aa:	407b      	eors	r3, r7
c0d036ac:	469a      	mov	sl, r3
c0d036ae:	464b      	mov	r3, r9
c0d036b0:	2b0f      	cmp	r3, #15
c0d036b2:	d827      	bhi.n	c0d03704 <__aeabi_ddiv+0xdc>
c0d036b4:	49bc      	ldr	r1, [pc, #752]	; (c0d039a8 <__aeabi_ddiv+0x380>)
c0d036b6:	009b      	lsls	r3, r3, #2
c0d036b8:	58cb      	ldr	r3, [r1, r3]
c0d036ba:	469f      	mov	pc, r3
c0d036bc:	46b2      	mov	sl, r6
c0d036be:	9b00      	ldr	r3, [sp, #0]
c0d036c0:	2b02      	cmp	r3, #2
c0d036c2:	d016      	beq.n	c0d036f2 <__aeabi_ddiv+0xca>
c0d036c4:	2b03      	cmp	r3, #3
c0d036c6:	d100      	bne.n	c0d036ca <__aeabi_ddiv+0xa2>
c0d036c8:	e28e      	b.n	c0d03be8 <__aeabi_ddiv+0x5c0>
c0d036ca:	2b01      	cmp	r3, #1
c0d036cc:	d000      	beq.n	c0d036d0 <__aeabi_ddiv+0xa8>
c0d036ce:	e0d9      	b.n	c0d03884 <__aeabi_ddiv+0x25c>
c0d036d0:	2300      	movs	r3, #0
c0d036d2:	2400      	movs	r4, #0
c0d036d4:	2500      	movs	r5, #0
c0d036d6:	4652      	mov	r2, sl
c0d036d8:	051b      	lsls	r3, r3, #20
c0d036da:	4323      	orrs	r3, r4
c0d036dc:	07d2      	lsls	r2, r2, #31
c0d036de:	4313      	orrs	r3, r2
c0d036e0:	0028      	movs	r0, r5
c0d036e2:	0019      	movs	r1, r3
c0d036e4:	b005      	add	sp, #20
c0d036e6:	bcf0      	pop	{r4, r5, r6, r7}
c0d036e8:	46bb      	mov	fp, r7
c0d036ea:	46b2      	mov	sl, r6
c0d036ec:	46a9      	mov	r9, r5
c0d036ee:	46a0      	mov	r8, r4
c0d036f0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d036f2:	2400      	movs	r4, #0
c0d036f4:	2500      	movs	r5, #0
c0d036f6:	4baa      	ldr	r3, [pc, #680]	; (c0d039a0 <__aeabi_ddiv+0x378>)
c0d036f8:	e7ed      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d036fa:	46ba      	mov	sl, r7
c0d036fc:	46a0      	mov	r8, r4
c0d036fe:	0015      	movs	r5, r2
c0d03700:	9000      	str	r0, [sp, #0]
c0d03702:	e7dc      	b.n	c0d036be <__aeabi_ddiv+0x96>
c0d03704:	4544      	cmp	r4, r8
c0d03706:	d200      	bcs.n	c0d0370a <__aeabi_ddiv+0xe2>
c0d03708:	e1c7      	b.n	c0d03a9a <__aeabi_ddiv+0x472>
c0d0370a:	d100      	bne.n	c0d0370e <__aeabi_ddiv+0xe6>
c0d0370c:	e1c2      	b.n	c0d03a94 <__aeabi_ddiv+0x46c>
c0d0370e:	2301      	movs	r3, #1
c0d03710:	425b      	negs	r3, r3
c0d03712:	469c      	mov	ip, r3
c0d03714:	002e      	movs	r6, r5
c0d03716:	4640      	mov	r0, r8
c0d03718:	2500      	movs	r5, #0
c0d0371a:	44e3      	add	fp, ip
c0d0371c:	0223      	lsls	r3, r4, #8
c0d0371e:	0e14      	lsrs	r4, r2, #24
c0d03720:	431c      	orrs	r4, r3
c0d03722:	0c1b      	lsrs	r3, r3, #16
c0d03724:	4699      	mov	r9, r3
c0d03726:	0423      	lsls	r3, r4, #16
c0d03728:	0c1f      	lsrs	r7, r3, #16
c0d0372a:	0212      	lsls	r2, r2, #8
c0d0372c:	4649      	mov	r1, r9
c0d0372e:	9200      	str	r2, [sp, #0]
c0d03730:	9701      	str	r7, [sp, #4]
c0d03732:	f7ff f9d7 	bl	c0d02ae4 <__aeabi_uidivmod>
c0d03736:	0002      	movs	r2, r0
c0d03738:	437a      	muls	r2, r7
c0d0373a:	040b      	lsls	r3, r1, #16
c0d0373c:	0c31      	lsrs	r1, r6, #16
c0d0373e:	4680      	mov	r8, r0
c0d03740:	4319      	orrs	r1, r3
c0d03742:	428a      	cmp	r2, r1
c0d03744:	d907      	bls.n	c0d03756 <__aeabi_ddiv+0x12e>
c0d03746:	2301      	movs	r3, #1
c0d03748:	425b      	negs	r3, r3
c0d0374a:	469c      	mov	ip, r3
c0d0374c:	1909      	adds	r1, r1, r4
c0d0374e:	44e0      	add	r8, ip
c0d03750:	428c      	cmp	r4, r1
c0d03752:	d800      	bhi.n	c0d03756 <__aeabi_ddiv+0x12e>
c0d03754:	e207      	b.n	c0d03b66 <__aeabi_ddiv+0x53e>
c0d03756:	1a88      	subs	r0, r1, r2
c0d03758:	4649      	mov	r1, r9
c0d0375a:	f7ff f9c3 	bl	c0d02ae4 <__aeabi_uidivmod>
c0d0375e:	0409      	lsls	r1, r1, #16
c0d03760:	468c      	mov	ip, r1
c0d03762:	0431      	lsls	r1, r6, #16
c0d03764:	4666      	mov	r6, ip
c0d03766:	9a01      	ldr	r2, [sp, #4]
c0d03768:	0c09      	lsrs	r1, r1, #16
c0d0376a:	4342      	muls	r2, r0
c0d0376c:	0003      	movs	r3, r0
c0d0376e:	4331      	orrs	r1, r6
c0d03770:	428a      	cmp	r2, r1
c0d03772:	d904      	bls.n	c0d0377e <__aeabi_ddiv+0x156>
c0d03774:	1909      	adds	r1, r1, r4
c0d03776:	3b01      	subs	r3, #1
c0d03778:	428c      	cmp	r4, r1
c0d0377a:	d800      	bhi.n	c0d0377e <__aeabi_ddiv+0x156>
c0d0377c:	e1ed      	b.n	c0d03b5a <__aeabi_ddiv+0x532>
c0d0377e:	1a88      	subs	r0, r1, r2
c0d03780:	4642      	mov	r2, r8
c0d03782:	0412      	lsls	r2, r2, #16
c0d03784:	431a      	orrs	r2, r3
c0d03786:	4690      	mov	r8, r2
c0d03788:	4641      	mov	r1, r8
c0d0378a:	9b00      	ldr	r3, [sp, #0]
c0d0378c:	040e      	lsls	r6, r1, #16
c0d0378e:	0c1b      	lsrs	r3, r3, #16
c0d03790:	001f      	movs	r7, r3
c0d03792:	9302      	str	r3, [sp, #8]
c0d03794:	9b00      	ldr	r3, [sp, #0]
c0d03796:	0c36      	lsrs	r6, r6, #16
c0d03798:	041b      	lsls	r3, r3, #16
c0d0379a:	0c19      	lsrs	r1, r3, #16
c0d0379c:	000b      	movs	r3, r1
c0d0379e:	4373      	muls	r3, r6
c0d037a0:	0c12      	lsrs	r2, r2, #16
c0d037a2:	437e      	muls	r6, r7
c0d037a4:	9103      	str	r1, [sp, #12]
c0d037a6:	4351      	muls	r1, r2
c0d037a8:	437a      	muls	r2, r7
c0d037aa:	0c1f      	lsrs	r7, r3, #16
c0d037ac:	46bc      	mov	ip, r7
c0d037ae:	1876      	adds	r6, r6, r1
c0d037b0:	4466      	add	r6, ip
c0d037b2:	42b1      	cmp	r1, r6
c0d037b4:	d903      	bls.n	c0d037be <__aeabi_ddiv+0x196>
c0d037b6:	2180      	movs	r1, #128	; 0x80
c0d037b8:	0249      	lsls	r1, r1, #9
c0d037ba:	468c      	mov	ip, r1
c0d037bc:	4462      	add	r2, ip
c0d037be:	0c31      	lsrs	r1, r6, #16
c0d037c0:	188a      	adds	r2, r1, r2
c0d037c2:	0431      	lsls	r1, r6, #16
c0d037c4:	041e      	lsls	r6, r3, #16
c0d037c6:	0c36      	lsrs	r6, r6, #16
c0d037c8:	198e      	adds	r6, r1, r6
c0d037ca:	4290      	cmp	r0, r2
c0d037cc:	d302      	bcc.n	c0d037d4 <__aeabi_ddiv+0x1ac>
c0d037ce:	d112      	bne.n	c0d037f6 <__aeabi_ddiv+0x1ce>
c0d037d0:	42b5      	cmp	r5, r6
c0d037d2:	d210      	bcs.n	c0d037f6 <__aeabi_ddiv+0x1ce>
c0d037d4:	4643      	mov	r3, r8
c0d037d6:	1e59      	subs	r1, r3, #1
c0d037d8:	9b00      	ldr	r3, [sp, #0]
c0d037da:	469c      	mov	ip, r3
c0d037dc:	4465      	add	r5, ip
c0d037de:	001f      	movs	r7, r3
c0d037e0:	429d      	cmp	r5, r3
c0d037e2:	419b      	sbcs	r3, r3
c0d037e4:	425b      	negs	r3, r3
c0d037e6:	191b      	adds	r3, r3, r4
c0d037e8:	18c0      	adds	r0, r0, r3
c0d037ea:	4284      	cmp	r4, r0
c0d037ec:	d200      	bcs.n	c0d037f0 <__aeabi_ddiv+0x1c8>
c0d037ee:	e1a0      	b.n	c0d03b32 <__aeabi_ddiv+0x50a>
c0d037f0:	d100      	bne.n	c0d037f4 <__aeabi_ddiv+0x1cc>
c0d037f2:	e19b      	b.n	c0d03b2c <__aeabi_ddiv+0x504>
c0d037f4:	4688      	mov	r8, r1
c0d037f6:	1bae      	subs	r6, r5, r6
c0d037f8:	42b5      	cmp	r5, r6
c0d037fa:	41ad      	sbcs	r5, r5
c0d037fc:	1a80      	subs	r0, r0, r2
c0d037fe:	426d      	negs	r5, r5
c0d03800:	1b40      	subs	r0, r0, r5
c0d03802:	4284      	cmp	r4, r0
c0d03804:	d100      	bne.n	c0d03808 <__aeabi_ddiv+0x1e0>
c0d03806:	e1d5      	b.n	c0d03bb4 <__aeabi_ddiv+0x58c>
c0d03808:	4649      	mov	r1, r9
c0d0380a:	f7ff f96b 	bl	c0d02ae4 <__aeabi_uidivmod>
c0d0380e:	9a01      	ldr	r2, [sp, #4]
c0d03810:	040b      	lsls	r3, r1, #16
c0d03812:	4342      	muls	r2, r0
c0d03814:	0c31      	lsrs	r1, r6, #16
c0d03816:	0005      	movs	r5, r0
c0d03818:	4319      	orrs	r1, r3
c0d0381a:	428a      	cmp	r2, r1
c0d0381c:	d900      	bls.n	c0d03820 <__aeabi_ddiv+0x1f8>
c0d0381e:	e16c      	b.n	c0d03afa <__aeabi_ddiv+0x4d2>
c0d03820:	1a88      	subs	r0, r1, r2
c0d03822:	4649      	mov	r1, r9
c0d03824:	f7ff f95e 	bl	c0d02ae4 <__aeabi_uidivmod>
c0d03828:	9a01      	ldr	r2, [sp, #4]
c0d0382a:	0436      	lsls	r6, r6, #16
c0d0382c:	4342      	muls	r2, r0
c0d0382e:	0409      	lsls	r1, r1, #16
c0d03830:	0c36      	lsrs	r6, r6, #16
c0d03832:	0003      	movs	r3, r0
c0d03834:	430e      	orrs	r6, r1
c0d03836:	42b2      	cmp	r2, r6
c0d03838:	d900      	bls.n	c0d0383c <__aeabi_ddiv+0x214>
c0d0383a:	e153      	b.n	c0d03ae4 <__aeabi_ddiv+0x4bc>
c0d0383c:	9803      	ldr	r0, [sp, #12]
c0d0383e:	1ab6      	subs	r6, r6, r2
c0d03840:	0002      	movs	r2, r0
c0d03842:	042d      	lsls	r5, r5, #16
c0d03844:	431d      	orrs	r5, r3
c0d03846:	9f02      	ldr	r7, [sp, #8]
c0d03848:	042b      	lsls	r3, r5, #16
c0d0384a:	0c1b      	lsrs	r3, r3, #16
c0d0384c:	435a      	muls	r2, r3
c0d0384e:	437b      	muls	r3, r7
c0d03850:	469c      	mov	ip, r3
c0d03852:	0c29      	lsrs	r1, r5, #16
c0d03854:	4348      	muls	r0, r1
c0d03856:	0c13      	lsrs	r3, r2, #16
c0d03858:	4484      	add	ip, r0
c0d0385a:	4463      	add	r3, ip
c0d0385c:	4379      	muls	r1, r7
c0d0385e:	4298      	cmp	r0, r3
c0d03860:	d903      	bls.n	c0d0386a <__aeabi_ddiv+0x242>
c0d03862:	2080      	movs	r0, #128	; 0x80
c0d03864:	0240      	lsls	r0, r0, #9
c0d03866:	4684      	mov	ip, r0
c0d03868:	4461      	add	r1, ip
c0d0386a:	0c18      	lsrs	r0, r3, #16
c0d0386c:	0412      	lsls	r2, r2, #16
c0d0386e:	041b      	lsls	r3, r3, #16
c0d03870:	0c12      	lsrs	r2, r2, #16
c0d03872:	1841      	adds	r1, r0, r1
c0d03874:	189b      	adds	r3, r3, r2
c0d03876:	428e      	cmp	r6, r1
c0d03878:	d200      	bcs.n	c0d0387c <__aeabi_ddiv+0x254>
c0d0387a:	e0ff      	b.n	c0d03a7c <__aeabi_ddiv+0x454>
c0d0387c:	d100      	bne.n	c0d03880 <__aeabi_ddiv+0x258>
c0d0387e:	e0fa      	b.n	c0d03a76 <__aeabi_ddiv+0x44e>
c0d03880:	2301      	movs	r3, #1
c0d03882:	431d      	orrs	r5, r3
c0d03884:	4a49      	ldr	r2, [pc, #292]	; (c0d039ac <__aeabi_ddiv+0x384>)
c0d03886:	445a      	add	r2, fp
c0d03888:	2a00      	cmp	r2, #0
c0d0388a:	dc00      	bgt.n	c0d0388e <__aeabi_ddiv+0x266>
c0d0388c:	e0aa      	b.n	c0d039e4 <__aeabi_ddiv+0x3bc>
c0d0388e:	076b      	lsls	r3, r5, #29
c0d03890:	d000      	beq.n	c0d03894 <__aeabi_ddiv+0x26c>
c0d03892:	e13d      	b.n	c0d03b10 <__aeabi_ddiv+0x4e8>
c0d03894:	08ed      	lsrs	r5, r5, #3
c0d03896:	4643      	mov	r3, r8
c0d03898:	01db      	lsls	r3, r3, #7
c0d0389a:	d506      	bpl.n	c0d038aa <__aeabi_ddiv+0x282>
c0d0389c:	4642      	mov	r2, r8
c0d0389e:	4b44      	ldr	r3, [pc, #272]	; (c0d039b0 <__aeabi_ddiv+0x388>)
c0d038a0:	401a      	ands	r2, r3
c0d038a2:	4690      	mov	r8, r2
c0d038a4:	2280      	movs	r2, #128	; 0x80
c0d038a6:	00d2      	lsls	r2, r2, #3
c0d038a8:	445a      	add	r2, fp
c0d038aa:	4b42      	ldr	r3, [pc, #264]	; (c0d039b4 <__aeabi_ddiv+0x38c>)
c0d038ac:	429a      	cmp	r2, r3
c0d038ae:	dd00      	ble.n	c0d038b2 <__aeabi_ddiv+0x28a>
c0d038b0:	e71f      	b.n	c0d036f2 <__aeabi_ddiv+0xca>
c0d038b2:	4643      	mov	r3, r8
c0d038b4:	075b      	lsls	r3, r3, #29
c0d038b6:	431d      	orrs	r5, r3
c0d038b8:	4643      	mov	r3, r8
c0d038ba:	0552      	lsls	r2, r2, #21
c0d038bc:	025c      	lsls	r4, r3, #9
c0d038be:	0b24      	lsrs	r4, r4, #12
c0d038c0:	0d53      	lsrs	r3, r2, #21
c0d038c2:	e708      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d038c4:	4652      	mov	r2, sl
c0d038c6:	4322      	orrs	r2, r4
c0d038c8:	d100      	bne.n	c0d038cc <__aeabi_ddiv+0x2a4>
c0d038ca:	e07b      	b.n	c0d039c4 <__aeabi_ddiv+0x39c>
c0d038cc:	2c00      	cmp	r4, #0
c0d038ce:	d100      	bne.n	c0d038d2 <__aeabi_ddiv+0x2aa>
c0d038d0:	e0fa      	b.n	c0d03ac8 <__aeabi_ddiv+0x4a0>
c0d038d2:	0020      	movs	r0, r4
c0d038d4:	f001 f954 	bl	c0d04b80 <__clzsi2>
c0d038d8:	0002      	movs	r2, r0
c0d038da:	3a0b      	subs	r2, #11
c0d038dc:	231d      	movs	r3, #29
c0d038de:	0001      	movs	r1, r0
c0d038e0:	1a9b      	subs	r3, r3, r2
c0d038e2:	4652      	mov	r2, sl
c0d038e4:	3908      	subs	r1, #8
c0d038e6:	40da      	lsrs	r2, r3
c0d038e8:	408c      	lsls	r4, r1
c0d038ea:	4314      	orrs	r4, r2
c0d038ec:	4652      	mov	r2, sl
c0d038ee:	408a      	lsls	r2, r1
c0d038f0:	4b31      	ldr	r3, [pc, #196]	; (c0d039b8 <__aeabi_ddiv+0x390>)
c0d038f2:	4458      	add	r0, fp
c0d038f4:	469b      	mov	fp, r3
c0d038f6:	4483      	add	fp, r0
c0d038f8:	2000      	movs	r0, #0
c0d038fa:	e6d5      	b.n	c0d036a8 <__aeabi_ddiv+0x80>
c0d038fc:	464b      	mov	r3, r9
c0d038fe:	4323      	orrs	r3, r4
c0d03900:	4698      	mov	r8, r3
c0d03902:	d044      	beq.n	c0d0398e <__aeabi_ddiv+0x366>
c0d03904:	2c00      	cmp	r4, #0
c0d03906:	d100      	bne.n	c0d0390a <__aeabi_ddiv+0x2e2>
c0d03908:	e0ce      	b.n	c0d03aa8 <__aeabi_ddiv+0x480>
c0d0390a:	0020      	movs	r0, r4
c0d0390c:	f001 f938 	bl	c0d04b80 <__clzsi2>
c0d03910:	0001      	movs	r1, r0
c0d03912:	0002      	movs	r2, r0
c0d03914:	390b      	subs	r1, #11
c0d03916:	231d      	movs	r3, #29
c0d03918:	1a5b      	subs	r3, r3, r1
c0d0391a:	4649      	mov	r1, r9
c0d0391c:	0010      	movs	r0, r2
c0d0391e:	40d9      	lsrs	r1, r3
c0d03920:	3808      	subs	r0, #8
c0d03922:	4084      	lsls	r4, r0
c0d03924:	000b      	movs	r3, r1
c0d03926:	464d      	mov	r5, r9
c0d03928:	4323      	orrs	r3, r4
c0d0392a:	4698      	mov	r8, r3
c0d0392c:	4085      	lsls	r5, r0
c0d0392e:	4823      	ldr	r0, [pc, #140]	; (c0d039bc <__aeabi_ddiv+0x394>)
c0d03930:	1a83      	subs	r3, r0, r2
c0d03932:	469b      	mov	fp, r3
c0d03934:	2300      	movs	r3, #0
c0d03936:	4699      	mov	r9, r3
c0d03938:	9300      	str	r3, [sp, #0]
c0d0393a:	e69a      	b.n	c0d03672 <__aeabi_ddiv+0x4a>
c0d0393c:	464b      	mov	r3, r9
c0d0393e:	4323      	orrs	r3, r4
c0d03940:	4698      	mov	r8, r3
c0d03942:	d11d      	bne.n	c0d03980 <__aeabi_ddiv+0x358>
c0d03944:	2308      	movs	r3, #8
c0d03946:	4699      	mov	r9, r3
c0d03948:	3b06      	subs	r3, #6
c0d0394a:	2500      	movs	r5, #0
c0d0394c:	4683      	mov	fp, r0
c0d0394e:	9300      	str	r3, [sp, #0]
c0d03950:	e68f      	b.n	c0d03672 <__aeabi_ddiv+0x4a>
c0d03952:	4652      	mov	r2, sl
c0d03954:	4322      	orrs	r2, r4
c0d03956:	d109      	bne.n	c0d0396c <__aeabi_ddiv+0x344>
c0d03958:	2302      	movs	r3, #2
c0d0395a:	4649      	mov	r1, r9
c0d0395c:	4319      	orrs	r1, r3
c0d0395e:	4b18      	ldr	r3, [pc, #96]	; (c0d039c0 <__aeabi_ddiv+0x398>)
c0d03960:	4689      	mov	r9, r1
c0d03962:	469c      	mov	ip, r3
c0d03964:	2400      	movs	r4, #0
c0d03966:	2002      	movs	r0, #2
c0d03968:	44e3      	add	fp, ip
c0d0396a:	e69d      	b.n	c0d036a8 <__aeabi_ddiv+0x80>
c0d0396c:	2303      	movs	r3, #3
c0d0396e:	464a      	mov	r2, r9
c0d03970:	431a      	orrs	r2, r3
c0d03972:	4b13      	ldr	r3, [pc, #76]	; (c0d039c0 <__aeabi_ddiv+0x398>)
c0d03974:	4691      	mov	r9, r2
c0d03976:	469c      	mov	ip, r3
c0d03978:	4652      	mov	r2, sl
c0d0397a:	2003      	movs	r0, #3
c0d0397c:	44e3      	add	fp, ip
c0d0397e:	e693      	b.n	c0d036a8 <__aeabi_ddiv+0x80>
c0d03980:	230c      	movs	r3, #12
c0d03982:	4699      	mov	r9, r3
c0d03984:	3b09      	subs	r3, #9
c0d03986:	46a0      	mov	r8, r4
c0d03988:	4683      	mov	fp, r0
c0d0398a:	9300      	str	r3, [sp, #0]
c0d0398c:	e671      	b.n	c0d03672 <__aeabi_ddiv+0x4a>
c0d0398e:	2304      	movs	r3, #4
c0d03990:	4699      	mov	r9, r3
c0d03992:	2300      	movs	r3, #0
c0d03994:	469b      	mov	fp, r3
c0d03996:	3301      	adds	r3, #1
c0d03998:	2500      	movs	r5, #0
c0d0399a:	9300      	str	r3, [sp, #0]
c0d0399c:	e669      	b.n	c0d03672 <__aeabi_ddiv+0x4a>
c0d0399e:	46c0      	nop			; (mov r8, r8)
c0d039a0:	000007ff 	.word	0x000007ff
c0d039a4:	fffffc01 	.word	0xfffffc01
c0d039a8:	c0d04ce0 	.word	0xc0d04ce0
c0d039ac:	000003ff 	.word	0x000003ff
c0d039b0:	feffffff 	.word	0xfeffffff
c0d039b4:	000007fe 	.word	0x000007fe
c0d039b8:	000003f3 	.word	0x000003f3
c0d039bc:	fffffc0d 	.word	0xfffffc0d
c0d039c0:	fffff801 	.word	0xfffff801
c0d039c4:	4649      	mov	r1, r9
c0d039c6:	2301      	movs	r3, #1
c0d039c8:	4319      	orrs	r1, r3
c0d039ca:	4689      	mov	r9, r1
c0d039cc:	2400      	movs	r4, #0
c0d039ce:	2001      	movs	r0, #1
c0d039d0:	e66a      	b.n	c0d036a8 <__aeabi_ddiv+0x80>
c0d039d2:	2300      	movs	r3, #0
c0d039d4:	2480      	movs	r4, #128	; 0x80
c0d039d6:	469a      	mov	sl, r3
c0d039d8:	2500      	movs	r5, #0
c0d039da:	4b8a      	ldr	r3, [pc, #552]	; (c0d03c04 <__aeabi_ddiv+0x5dc>)
c0d039dc:	0324      	lsls	r4, r4, #12
c0d039de:	e67a      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d039e0:	2501      	movs	r5, #1
c0d039e2:	426d      	negs	r5, r5
c0d039e4:	2301      	movs	r3, #1
c0d039e6:	1a9b      	subs	r3, r3, r2
c0d039e8:	2b38      	cmp	r3, #56	; 0x38
c0d039ea:	dd00      	ble.n	c0d039ee <__aeabi_ddiv+0x3c6>
c0d039ec:	e670      	b.n	c0d036d0 <__aeabi_ddiv+0xa8>
c0d039ee:	2b1f      	cmp	r3, #31
c0d039f0:	dc00      	bgt.n	c0d039f4 <__aeabi_ddiv+0x3cc>
c0d039f2:	e0bf      	b.n	c0d03b74 <__aeabi_ddiv+0x54c>
c0d039f4:	211f      	movs	r1, #31
c0d039f6:	4249      	negs	r1, r1
c0d039f8:	1a8a      	subs	r2, r1, r2
c0d039fa:	4641      	mov	r1, r8
c0d039fc:	40d1      	lsrs	r1, r2
c0d039fe:	000a      	movs	r2, r1
c0d03a00:	2b20      	cmp	r3, #32
c0d03a02:	d004      	beq.n	c0d03a0e <__aeabi_ddiv+0x3e6>
c0d03a04:	4641      	mov	r1, r8
c0d03a06:	4b80      	ldr	r3, [pc, #512]	; (c0d03c08 <__aeabi_ddiv+0x5e0>)
c0d03a08:	445b      	add	r3, fp
c0d03a0a:	4099      	lsls	r1, r3
c0d03a0c:	430d      	orrs	r5, r1
c0d03a0e:	1e6b      	subs	r3, r5, #1
c0d03a10:	419d      	sbcs	r5, r3
c0d03a12:	2307      	movs	r3, #7
c0d03a14:	432a      	orrs	r2, r5
c0d03a16:	001d      	movs	r5, r3
c0d03a18:	2400      	movs	r4, #0
c0d03a1a:	4015      	ands	r5, r2
c0d03a1c:	4213      	tst	r3, r2
c0d03a1e:	d100      	bne.n	c0d03a22 <__aeabi_ddiv+0x3fa>
c0d03a20:	e0d4      	b.n	c0d03bcc <__aeabi_ddiv+0x5a4>
c0d03a22:	210f      	movs	r1, #15
c0d03a24:	2300      	movs	r3, #0
c0d03a26:	4011      	ands	r1, r2
c0d03a28:	2904      	cmp	r1, #4
c0d03a2a:	d100      	bne.n	c0d03a2e <__aeabi_ddiv+0x406>
c0d03a2c:	e0cb      	b.n	c0d03bc6 <__aeabi_ddiv+0x59e>
c0d03a2e:	1d11      	adds	r1, r2, #4
c0d03a30:	4291      	cmp	r1, r2
c0d03a32:	4192      	sbcs	r2, r2
c0d03a34:	4252      	negs	r2, r2
c0d03a36:	189b      	adds	r3, r3, r2
c0d03a38:	000a      	movs	r2, r1
c0d03a3a:	0219      	lsls	r1, r3, #8
c0d03a3c:	d400      	bmi.n	c0d03a40 <__aeabi_ddiv+0x418>
c0d03a3e:	e0c2      	b.n	c0d03bc6 <__aeabi_ddiv+0x59e>
c0d03a40:	2301      	movs	r3, #1
c0d03a42:	2400      	movs	r4, #0
c0d03a44:	2500      	movs	r5, #0
c0d03a46:	e646      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d03a48:	2380      	movs	r3, #128	; 0x80
c0d03a4a:	4641      	mov	r1, r8
c0d03a4c:	031b      	lsls	r3, r3, #12
c0d03a4e:	4219      	tst	r1, r3
c0d03a50:	d008      	beq.n	c0d03a64 <__aeabi_ddiv+0x43c>
c0d03a52:	421c      	tst	r4, r3
c0d03a54:	d106      	bne.n	c0d03a64 <__aeabi_ddiv+0x43c>
c0d03a56:	431c      	orrs	r4, r3
c0d03a58:	0324      	lsls	r4, r4, #12
c0d03a5a:	46ba      	mov	sl, r7
c0d03a5c:	0015      	movs	r5, r2
c0d03a5e:	4b69      	ldr	r3, [pc, #420]	; (c0d03c04 <__aeabi_ddiv+0x5dc>)
c0d03a60:	0b24      	lsrs	r4, r4, #12
c0d03a62:	e638      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d03a64:	2480      	movs	r4, #128	; 0x80
c0d03a66:	4643      	mov	r3, r8
c0d03a68:	0324      	lsls	r4, r4, #12
c0d03a6a:	431c      	orrs	r4, r3
c0d03a6c:	0324      	lsls	r4, r4, #12
c0d03a6e:	46b2      	mov	sl, r6
c0d03a70:	4b64      	ldr	r3, [pc, #400]	; (c0d03c04 <__aeabi_ddiv+0x5dc>)
c0d03a72:	0b24      	lsrs	r4, r4, #12
c0d03a74:	e62f      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d03a76:	2b00      	cmp	r3, #0
c0d03a78:	d100      	bne.n	c0d03a7c <__aeabi_ddiv+0x454>
c0d03a7a:	e703      	b.n	c0d03884 <__aeabi_ddiv+0x25c>
c0d03a7c:	19a6      	adds	r6, r4, r6
c0d03a7e:	1e68      	subs	r0, r5, #1
c0d03a80:	42a6      	cmp	r6, r4
c0d03a82:	d200      	bcs.n	c0d03a86 <__aeabi_ddiv+0x45e>
c0d03a84:	e08d      	b.n	c0d03ba2 <__aeabi_ddiv+0x57a>
c0d03a86:	428e      	cmp	r6, r1
c0d03a88:	d200      	bcs.n	c0d03a8c <__aeabi_ddiv+0x464>
c0d03a8a:	e0a3      	b.n	c0d03bd4 <__aeabi_ddiv+0x5ac>
c0d03a8c:	d100      	bne.n	c0d03a90 <__aeabi_ddiv+0x468>
c0d03a8e:	e0b3      	b.n	c0d03bf8 <__aeabi_ddiv+0x5d0>
c0d03a90:	0005      	movs	r5, r0
c0d03a92:	e6f5      	b.n	c0d03880 <__aeabi_ddiv+0x258>
c0d03a94:	42aa      	cmp	r2, r5
c0d03a96:	d900      	bls.n	c0d03a9a <__aeabi_ddiv+0x472>
c0d03a98:	e639      	b.n	c0d0370e <__aeabi_ddiv+0xe6>
c0d03a9a:	4643      	mov	r3, r8
c0d03a9c:	07de      	lsls	r6, r3, #31
c0d03a9e:	0858      	lsrs	r0, r3, #1
c0d03aa0:	086b      	lsrs	r3, r5, #1
c0d03aa2:	431e      	orrs	r6, r3
c0d03aa4:	07ed      	lsls	r5, r5, #31
c0d03aa6:	e639      	b.n	c0d0371c <__aeabi_ddiv+0xf4>
c0d03aa8:	4648      	mov	r0, r9
c0d03aaa:	f001 f869 	bl	c0d04b80 <__clzsi2>
c0d03aae:	0001      	movs	r1, r0
c0d03ab0:	0002      	movs	r2, r0
c0d03ab2:	3115      	adds	r1, #21
c0d03ab4:	3220      	adds	r2, #32
c0d03ab6:	291c      	cmp	r1, #28
c0d03ab8:	dc00      	bgt.n	c0d03abc <__aeabi_ddiv+0x494>
c0d03aba:	e72c      	b.n	c0d03916 <__aeabi_ddiv+0x2ee>
c0d03abc:	464b      	mov	r3, r9
c0d03abe:	3808      	subs	r0, #8
c0d03ac0:	4083      	lsls	r3, r0
c0d03ac2:	2500      	movs	r5, #0
c0d03ac4:	4698      	mov	r8, r3
c0d03ac6:	e732      	b.n	c0d0392e <__aeabi_ddiv+0x306>
c0d03ac8:	f001 f85a 	bl	c0d04b80 <__clzsi2>
c0d03acc:	0003      	movs	r3, r0
c0d03ace:	001a      	movs	r2, r3
c0d03ad0:	3215      	adds	r2, #21
c0d03ad2:	3020      	adds	r0, #32
c0d03ad4:	2a1c      	cmp	r2, #28
c0d03ad6:	dc00      	bgt.n	c0d03ada <__aeabi_ddiv+0x4b2>
c0d03ad8:	e700      	b.n	c0d038dc <__aeabi_ddiv+0x2b4>
c0d03ada:	4654      	mov	r4, sl
c0d03adc:	3b08      	subs	r3, #8
c0d03ade:	2200      	movs	r2, #0
c0d03ae0:	409c      	lsls	r4, r3
c0d03ae2:	e705      	b.n	c0d038f0 <__aeabi_ddiv+0x2c8>
c0d03ae4:	1936      	adds	r6, r6, r4
c0d03ae6:	3b01      	subs	r3, #1
c0d03ae8:	42b4      	cmp	r4, r6
c0d03aea:	d900      	bls.n	c0d03aee <__aeabi_ddiv+0x4c6>
c0d03aec:	e6a6      	b.n	c0d0383c <__aeabi_ddiv+0x214>
c0d03aee:	42b2      	cmp	r2, r6
c0d03af0:	d800      	bhi.n	c0d03af4 <__aeabi_ddiv+0x4cc>
c0d03af2:	e6a3      	b.n	c0d0383c <__aeabi_ddiv+0x214>
c0d03af4:	1e83      	subs	r3, r0, #2
c0d03af6:	1936      	adds	r6, r6, r4
c0d03af8:	e6a0      	b.n	c0d0383c <__aeabi_ddiv+0x214>
c0d03afa:	1909      	adds	r1, r1, r4
c0d03afc:	3d01      	subs	r5, #1
c0d03afe:	428c      	cmp	r4, r1
c0d03b00:	d900      	bls.n	c0d03b04 <__aeabi_ddiv+0x4dc>
c0d03b02:	e68d      	b.n	c0d03820 <__aeabi_ddiv+0x1f8>
c0d03b04:	428a      	cmp	r2, r1
c0d03b06:	d800      	bhi.n	c0d03b0a <__aeabi_ddiv+0x4e2>
c0d03b08:	e68a      	b.n	c0d03820 <__aeabi_ddiv+0x1f8>
c0d03b0a:	1e85      	subs	r5, r0, #2
c0d03b0c:	1909      	adds	r1, r1, r4
c0d03b0e:	e687      	b.n	c0d03820 <__aeabi_ddiv+0x1f8>
c0d03b10:	230f      	movs	r3, #15
c0d03b12:	402b      	ands	r3, r5
c0d03b14:	2b04      	cmp	r3, #4
c0d03b16:	d100      	bne.n	c0d03b1a <__aeabi_ddiv+0x4f2>
c0d03b18:	e6bc      	b.n	c0d03894 <__aeabi_ddiv+0x26c>
c0d03b1a:	2305      	movs	r3, #5
c0d03b1c:	425b      	negs	r3, r3
c0d03b1e:	42ab      	cmp	r3, r5
c0d03b20:	419b      	sbcs	r3, r3
c0d03b22:	3504      	adds	r5, #4
c0d03b24:	425b      	negs	r3, r3
c0d03b26:	08ed      	lsrs	r5, r5, #3
c0d03b28:	4498      	add	r8, r3
c0d03b2a:	e6b4      	b.n	c0d03896 <__aeabi_ddiv+0x26e>
c0d03b2c:	42af      	cmp	r7, r5
c0d03b2e:	d900      	bls.n	c0d03b32 <__aeabi_ddiv+0x50a>
c0d03b30:	e660      	b.n	c0d037f4 <__aeabi_ddiv+0x1cc>
c0d03b32:	4282      	cmp	r2, r0
c0d03b34:	d804      	bhi.n	c0d03b40 <__aeabi_ddiv+0x518>
c0d03b36:	d000      	beq.n	c0d03b3a <__aeabi_ddiv+0x512>
c0d03b38:	e65c      	b.n	c0d037f4 <__aeabi_ddiv+0x1cc>
c0d03b3a:	42ae      	cmp	r6, r5
c0d03b3c:	d800      	bhi.n	c0d03b40 <__aeabi_ddiv+0x518>
c0d03b3e:	e659      	b.n	c0d037f4 <__aeabi_ddiv+0x1cc>
c0d03b40:	2302      	movs	r3, #2
c0d03b42:	425b      	negs	r3, r3
c0d03b44:	469c      	mov	ip, r3
c0d03b46:	9b00      	ldr	r3, [sp, #0]
c0d03b48:	44e0      	add	r8, ip
c0d03b4a:	469c      	mov	ip, r3
c0d03b4c:	4465      	add	r5, ip
c0d03b4e:	429d      	cmp	r5, r3
c0d03b50:	419b      	sbcs	r3, r3
c0d03b52:	425b      	negs	r3, r3
c0d03b54:	191b      	adds	r3, r3, r4
c0d03b56:	18c0      	adds	r0, r0, r3
c0d03b58:	e64d      	b.n	c0d037f6 <__aeabi_ddiv+0x1ce>
c0d03b5a:	428a      	cmp	r2, r1
c0d03b5c:	d800      	bhi.n	c0d03b60 <__aeabi_ddiv+0x538>
c0d03b5e:	e60e      	b.n	c0d0377e <__aeabi_ddiv+0x156>
c0d03b60:	1e83      	subs	r3, r0, #2
c0d03b62:	1909      	adds	r1, r1, r4
c0d03b64:	e60b      	b.n	c0d0377e <__aeabi_ddiv+0x156>
c0d03b66:	428a      	cmp	r2, r1
c0d03b68:	d800      	bhi.n	c0d03b6c <__aeabi_ddiv+0x544>
c0d03b6a:	e5f4      	b.n	c0d03756 <__aeabi_ddiv+0x12e>
c0d03b6c:	1e83      	subs	r3, r0, #2
c0d03b6e:	4698      	mov	r8, r3
c0d03b70:	1909      	adds	r1, r1, r4
c0d03b72:	e5f0      	b.n	c0d03756 <__aeabi_ddiv+0x12e>
c0d03b74:	4925      	ldr	r1, [pc, #148]	; (c0d03c0c <__aeabi_ddiv+0x5e4>)
c0d03b76:	0028      	movs	r0, r5
c0d03b78:	4459      	add	r1, fp
c0d03b7a:	408d      	lsls	r5, r1
c0d03b7c:	4642      	mov	r2, r8
c0d03b7e:	408a      	lsls	r2, r1
c0d03b80:	1e69      	subs	r1, r5, #1
c0d03b82:	418d      	sbcs	r5, r1
c0d03b84:	4641      	mov	r1, r8
c0d03b86:	40d8      	lsrs	r0, r3
c0d03b88:	40d9      	lsrs	r1, r3
c0d03b8a:	4302      	orrs	r2, r0
c0d03b8c:	432a      	orrs	r2, r5
c0d03b8e:	000b      	movs	r3, r1
c0d03b90:	0751      	lsls	r1, r2, #29
c0d03b92:	d100      	bne.n	c0d03b96 <__aeabi_ddiv+0x56e>
c0d03b94:	e751      	b.n	c0d03a3a <__aeabi_ddiv+0x412>
c0d03b96:	210f      	movs	r1, #15
c0d03b98:	4011      	ands	r1, r2
c0d03b9a:	2904      	cmp	r1, #4
c0d03b9c:	d000      	beq.n	c0d03ba0 <__aeabi_ddiv+0x578>
c0d03b9e:	e746      	b.n	c0d03a2e <__aeabi_ddiv+0x406>
c0d03ba0:	e74b      	b.n	c0d03a3a <__aeabi_ddiv+0x412>
c0d03ba2:	0005      	movs	r5, r0
c0d03ba4:	428e      	cmp	r6, r1
c0d03ba6:	d000      	beq.n	c0d03baa <__aeabi_ddiv+0x582>
c0d03ba8:	e66a      	b.n	c0d03880 <__aeabi_ddiv+0x258>
c0d03baa:	9a00      	ldr	r2, [sp, #0]
c0d03bac:	4293      	cmp	r3, r2
c0d03bae:	d000      	beq.n	c0d03bb2 <__aeabi_ddiv+0x58a>
c0d03bb0:	e666      	b.n	c0d03880 <__aeabi_ddiv+0x258>
c0d03bb2:	e667      	b.n	c0d03884 <__aeabi_ddiv+0x25c>
c0d03bb4:	4a16      	ldr	r2, [pc, #88]	; (c0d03c10 <__aeabi_ddiv+0x5e8>)
c0d03bb6:	445a      	add	r2, fp
c0d03bb8:	2a00      	cmp	r2, #0
c0d03bba:	dc00      	bgt.n	c0d03bbe <__aeabi_ddiv+0x596>
c0d03bbc:	e710      	b.n	c0d039e0 <__aeabi_ddiv+0x3b8>
c0d03bbe:	2301      	movs	r3, #1
c0d03bc0:	2500      	movs	r5, #0
c0d03bc2:	4498      	add	r8, r3
c0d03bc4:	e667      	b.n	c0d03896 <__aeabi_ddiv+0x26e>
c0d03bc6:	075d      	lsls	r5, r3, #29
c0d03bc8:	025b      	lsls	r3, r3, #9
c0d03bca:	0b1c      	lsrs	r4, r3, #12
c0d03bcc:	08d2      	lsrs	r2, r2, #3
c0d03bce:	2300      	movs	r3, #0
c0d03bd0:	4315      	orrs	r5, r2
c0d03bd2:	e580      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d03bd4:	9800      	ldr	r0, [sp, #0]
c0d03bd6:	3d02      	subs	r5, #2
c0d03bd8:	0042      	lsls	r2, r0, #1
c0d03bda:	4282      	cmp	r2, r0
c0d03bdc:	41bf      	sbcs	r7, r7
c0d03bde:	427f      	negs	r7, r7
c0d03be0:	193c      	adds	r4, r7, r4
c0d03be2:	1936      	adds	r6, r6, r4
c0d03be4:	9200      	str	r2, [sp, #0]
c0d03be6:	e7dd      	b.n	c0d03ba4 <__aeabi_ddiv+0x57c>
c0d03be8:	2480      	movs	r4, #128	; 0x80
c0d03bea:	4643      	mov	r3, r8
c0d03bec:	0324      	lsls	r4, r4, #12
c0d03bee:	431c      	orrs	r4, r3
c0d03bf0:	0324      	lsls	r4, r4, #12
c0d03bf2:	4b04      	ldr	r3, [pc, #16]	; (c0d03c04 <__aeabi_ddiv+0x5dc>)
c0d03bf4:	0b24      	lsrs	r4, r4, #12
c0d03bf6:	e56e      	b.n	c0d036d6 <__aeabi_ddiv+0xae>
c0d03bf8:	9a00      	ldr	r2, [sp, #0]
c0d03bfa:	429a      	cmp	r2, r3
c0d03bfc:	d3ea      	bcc.n	c0d03bd4 <__aeabi_ddiv+0x5ac>
c0d03bfe:	0005      	movs	r5, r0
c0d03c00:	e7d3      	b.n	c0d03baa <__aeabi_ddiv+0x582>
c0d03c02:	46c0      	nop			; (mov r8, r8)
c0d03c04:	000007ff 	.word	0x000007ff
c0d03c08:	0000043e 	.word	0x0000043e
c0d03c0c:	0000041e 	.word	0x0000041e
c0d03c10:	000003ff 	.word	0x000003ff

c0d03c14 <__eqdf2>:
c0d03c14:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03c16:	464e      	mov	r6, r9
c0d03c18:	4645      	mov	r5, r8
c0d03c1a:	46de      	mov	lr, fp
c0d03c1c:	4657      	mov	r7, sl
c0d03c1e:	4690      	mov	r8, r2
c0d03c20:	b5e0      	push	{r5, r6, r7, lr}
c0d03c22:	0017      	movs	r7, r2
c0d03c24:	031a      	lsls	r2, r3, #12
c0d03c26:	0b12      	lsrs	r2, r2, #12
c0d03c28:	0005      	movs	r5, r0
c0d03c2a:	4684      	mov	ip, r0
c0d03c2c:	4819      	ldr	r0, [pc, #100]	; (c0d03c94 <__eqdf2+0x80>)
c0d03c2e:	030e      	lsls	r6, r1, #12
c0d03c30:	004c      	lsls	r4, r1, #1
c0d03c32:	4691      	mov	r9, r2
c0d03c34:	005a      	lsls	r2, r3, #1
c0d03c36:	0fdb      	lsrs	r3, r3, #31
c0d03c38:	469b      	mov	fp, r3
c0d03c3a:	0b36      	lsrs	r6, r6, #12
c0d03c3c:	0d64      	lsrs	r4, r4, #21
c0d03c3e:	0fc9      	lsrs	r1, r1, #31
c0d03c40:	0d52      	lsrs	r2, r2, #21
c0d03c42:	4284      	cmp	r4, r0
c0d03c44:	d019      	beq.n	c0d03c7a <__eqdf2+0x66>
c0d03c46:	4282      	cmp	r2, r0
c0d03c48:	d010      	beq.n	c0d03c6c <__eqdf2+0x58>
c0d03c4a:	2001      	movs	r0, #1
c0d03c4c:	4294      	cmp	r4, r2
c0d03c4e:	d10e      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c50:	454e      	cmp	r6, r9
c0d03c52:	d10c      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c54:	2001      	movs	r0, #1
c0d03c56:	45c4      	cmp	ip, r8
c0d03c58:	d109      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c5a:	4559      	cmp	r1, fp
c0d03c5c:	d017      	beq.n	c0d03c8e <__eqdf2+0x7a>
c0d03c5e:	2c00      	cmp	r4, #0
c0d03c60:	d105      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c62:	0030      	movs	r0, r6
c0d03c64:	4328      	orrs	r0, r5
c0d03c66:	1e43      	subs	r3, r0, #1
c0d03c68:	4198      	sbcs	r0, r3
c0d03c6a:	e000      	b.n	c0d03c6e <__eqdf2+0x5a>
c0d03c6c:	2001      	movs	r0, #1
c0d03c6e:	bcf0      	pop	{r4, r5, r6, r7}
c0d03c70:	46bb      	mov	fp, r7
c0d03c72:	46b2      	mov	sl, r6
c0d03c74:	46a9      	mov	r9, r5
c0d03c76:	46a0      	mov	r8, r4
c0d03c78:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03c7a:	0033      	movs	r3, r6
c0d03c7c:	2001      	movs	r0, #1
c0d03c7e:	432b      	orrs	r3, r5
c0d03c80:	d1f5      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c82:	42a2      	cmp	r2, r4
c0d03c84:	d1f3      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c86:	464b      	mov	r3, r9
c0d03c88:	433b      	orrs	r3, r7
c0d03c8a:	d1f0      	bne.n	c0d03c6e <__eqdf2+0x5a>
c0d03c8c:	e7e2      	b.n	c0d03c54 <__eqdf2+0x40>
c0d03c8e:	2000      	movs	r0, #0
c0d03c90:	e7ed      	b.n	c0d03c6e <__eqdf2+0x5a>
c0d03c92:	46c0      	nop			; (mov r8, r8)
c0d03c94:	000007ff 	.word	0x000007ff

c0d03c98 <__gedf2>:
c0d03c98:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03c9a:	4647      	mov	r7, r8
c0d03c9c:	46ce      	mov	lr, r9
c0d03c9e:	0004      	movs	r4, r0
c0d03ca0:	0018      	movs	r0, r3
c0d03ca2:	0016      	movs	r6, r2
c0d03ca4:	031b      	lsls	r3, r3, #12
c0d03ca6:	0b1b      	lsrs	r3, r3, #12
c0d03ca8:	4d2d      	ldr	r5, [pc, #180]	; (c0d03d60 <__gedf2+0xc8>)
c0d03caa:	004a      	lsls	r2, r1, #1
c0d03cac:	4699      	mov	r9, r3
c0d03cae:	b580      	push	{r7, lr}
c0d03cb0:	0043      	lsls	r3, r0, #1
c0d03cb2:	030f      	lsls	r7, r1, #12
c0d03cb4:	46a4      	mov	ip, r4
c0d03cb6:	46b0      	mov	r8, r6
c0d03cb8:	0b3f      	lsrs	r7, r7, #12
c0d03cba:	0d52      	lsrs	r2, r2, #21
c0d03cbc:	0fc9      	lsrs	r1, r1, #31
c0d03cbe:	0d5b      	lsrs	r3, r3, #21
c0d03cc0:	0fc0      	lsrs	r0, r0, #31
c0d03cc2:	42aa      	cmp	r2, r5
c0d03cc4:	d021      	beq.n	c0d03d0a <__gedf2+0x72>
c0d03cc6:	42ab      	cmp	r3, r5
c0d03cc8:	d013      	beq.n	c0d03cf2 <__gedf2+0x5a>
c0d03cca:	2a00      	cmp	r2, #0
c0d03ccc:	d122      	bne.n	c0d03d14 <__gedf2+0x7c>
c0d03cce:	433c      	orrs	r4, r7
c0d03cd0:	2b00      	cmp	r3, #0
c0d03cd2:	d102      	bne.n	c0d03cda <__gedf2+0x42>
c0d03cd4:	464d      	mov	r5, r9
c0d03cd6:	432e      	orrs	r6, r5
c0d03cd8:	d022      	beq.n	c0d03d20 <__gedf2+0x88>
c0d03cda:	2c00      	cmp	r4, #0
c0d03cdc:	d010      	beq.n	c0d03d00 <__gedf2+0x68>
c0d03cde:	4281      	cmp	r1, r0
c0d03ce0:	d022      	beq.n	c0d03d28 <__gedf2+0x90>
c0d03ce2:	2002      	movs	r0, #2
c0d03ce4:	3901      	subs	r1, #1
c0d03ce6:	4008      	ands	r0, r1
c0d03ce8:	3801      	subs	r0, #1
c0d03cea:	bcc0      	pop	{r6, r7}
c0d03cec:	46b9      	mov	r9, r7
c0d03cee:	46b0      	mov	r8, r6
c0d03cf0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03cf2:	464d      	mov	r5, r9
c0d03cf4:	432e      	orrs	r6, r5
c0d03cf6:	d129      	bne.n	c0d03d4c <__gedf2+0xb4>
c0d03cf8:	2a00      	cmp	r2, #0
c0d03cfa:	d1f0      	bne.n	c0d03cde <__gedf2+0x46>
c0d03cfc:	433c      	orrs	r4, r7
c0d03cfe:	d1ee      	bne.n	c0d03cde <__gedf2+0x46>
c0d03d00:	2800      	cmp	r0, #0
c0d03d02:	d1f2      	bne.n	c0d03cea <__gedf2+0x52>
c0d03d04:	2001      	movs	r0, #1
c0d03d06:	4240      	negs	r0, r0
c0d03d08:	e7ef      	b.n	c0d03cea <__gedf2+0x52>
c0d03d0a:	003d      	movs	r5, r7
c0d03d0c:	4325      	orrs	r5, r4
c0d03d0e:	d11d      	bne.n	c0d03d4c <__gedf2+0xb4>
c0d03d10:	4293      	cmp	r3, r2
c0d03d12:	d0ee      	beq.n	c0d03cf2 <__gedf2+0x5a>
c0d03d14:	2b00      	cmp	r3, #0
c0d03d16:	d1e2      	bne.n	c0d03cde <__gedf2+0x46>
c0d03d18:	464c      	mov	r4, r9
c0d03d1a:	4326      	orrs	r6, r4
c0d03d1c:	d1df      	bne.n	c0d03cde <__gedf2+0x46>
c0d03d1e:	e7e0      	b.n	c0d03ce2 <__gedf2+0x4a>
c0d03d20:	2000      	movs	r0, #0
c0d03d22:	2c00      	cmp	r4, #0
c0d03d24:	d0e1      	beq.n	c0d03cea <__gedf2+0x52>
c0d03d26:	e7dc      	b.n	c0d03ce2 <__gedf2+0x4a>
c0d03d28:	429a      	cmp	r2, r3
c0d03d2a:	dc0a      	bgt.n	c0d03d42 <__gedf2+0xaa>
c0d03d2c:	dbe8      	blt.n	c0d03d00 <__gedf2+0x68>
c0d03d2e:	454f      	cmp	r7, r9
c0d03d30:	d8d7      	bhi.n	c0d03ce2 <__gedf2+0x4a>
c0d03d32:	d00e      	beq.n	c0d03d52 <__gedf2+0xba>
c0d03d34:	2000      	movs	r0, #0
c0d03d36:	454f      	cmp	r7, r9
c0d03d38:	d2d7      	bcs.n	c0d03cea <__gedf2+0x52>
c0d03d3a:	2900      	cmp	r1, #0
c0d03d3c:	d0e2      	beq.n	c0d03d04 <__gedf2+0x6c>
c0d03d3e:	0008      	movs	r0, r1
c0d03d40:	e7d3      	b.n	c0d03cea <__gedf2+0x52>
c0d03d42:	4243      	negs	r3, r0
c0d03d44:	4158      	adcs	r0, r3
c0d03d46:	0040      	lsls	r0, r0, #1
c0d03d48:	3801      	subs	r0, #1
c0d03d4a:	e7ce      	b.n	c0d03cea <__gedf2+0x52>
c0d03d4c:	2002      	movs	r0, #2
c0d03d4e:	4240      	negs	r0, r0
c0d03d50:	e7cb      	b.n	c0d03cea <__gedf2+0x52>
c0d03d52:	45c4      	cmp	ip, r8
c0d03d54:	d8c5      	bhi.n	c0d03ce2 <__gedf2+0x4a>
c0d03d56:	2000      	movs	r0, #0
c0d03d58:	45c4      	cmp	ip, r8
c0d03d5a:	d2c6      	bcs.n	c0d03cea <__gedf2+0x52>
c0d03d5c:	e7ed      	b.n	c0d03d3a <__gedf2+0xa2>
c0d03d5e:	46c0      	nop			; (mov r8, r8)
c0d03d60:	000007ff 	.word	0x000007ff

c0d03d64 <__ledf2>:
c0d03d64:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03d66:	4647      	mov	r7, r8
c0d03d68:	46ce      	mov	lr, r9
c0d03d6a:	0004      	movs	r4, r0
c0d03d6c:	0018      	movs	r0, r3
c0d03d6e:	0016      	movs	r6, r2
c0d03d70:	031b      	lsls	r3, r3, #12
c0d03d72:	0b1b      	lsrs	r3, r3, #12
c0d03d74:	4d2c      	ldr	r5, [pc, #176]	; (c0d03e28 <__ledf2+0xc4>)
c0d03d76:	004a      	lsls	r2, r1, #1
c0d03d78:	4699      	mov	r9, r3
c0d03d7a:	b580      	push	{r7, lr}
c0d03d7c:	0043      	lsls	r3, r0, #1
c0d03d7e:	030f      	lsls	r7, r1, #12
c0d03d80:	46a4      	mov	ip, r4
c0d03d82:	46b0      	mov	r8, r6
c0d03d84:	0b3f      	lsrs	r7, r7, #12
c0d03d86:	0d52      	lsrs	r2, r2, #21
c0d03d88:	0fc9      	lsrs	r1, r1, #31
c0d03d8a:	0d5b      	lsrs	r3, r3, #21
c0d03d8c:	0fc0      	lsrs	r0, r0, #31
c0d03d8e:	42aa      	cmp	r2, r5
c0d03d90:	d00d      	beq.n	c0d03dae <__ledf2+0x4a>
c0d03d92:	42ab      	cmp	r3, r5
c0d03d94:	d010      	beq.n	c0d03db8 <__ledf2+0x54>
c0d03d96:	2a00      	cmp	r2, #0
c0d03d98:	d127      	bne.n	c0d03dea <__ledf2+0x86>
c0d03d9a:	433c      	orrs	r4, r7
c0d03d9c:	2b00      	cmp	r3, #0
c0d03d9e:	d111      	bne.n	c0d03dc4 <__ledf2+0x60>
c0d03da0:	464d      	mov	r5, r9
c0d03da2:	432e      	orrs	r6, r5
c0d03da4:	d10e      	bne.n	c0d03dc4 <__ledf2+0x60>
c0d03da6:	2000      	movs	r0, #0
c0d03da8:	2c00      	cmp	r4, #0
c0d03daa:	d015      	beq.n	c0d03dd8 <__ledf2+0x74>
c0d03dac:	e00e      	b.n	c0d03dcc <__ledf2+0x68>
c0d03dae:	003d      	movs	r5, r7
c0d03db0:	4325      	orrs	r5, r4
c0d03db2:	d110      	bne.n	c0d03dd6 <__ledf2+0x72>
c0d03db4:	4293      	cmp	r3, r2
c0d03db6:	d118      	bne.n	c0d03dea <__ledf2+0x86>
c0d03db8:	464d      	mov	r5, r9
c0d03dba:	432e      	orrs	r6, r5
c0d03dbc:	d10b      	bne.n	c0d03dd6 <__ledf2+0x72>
c0d03dbe:	2a00      	cmp	r2, #0
c0d03dc0:	d102      	bne.n	c0d03dc8 <__ledf2+0x64>
c0d03dc2:	433c      	orrs	r4, r7
c0d03dc4:	2c00      	cmp	r4, #0
c0d03dc6:	d00b      	beq.n	c0d03de0 <__ledf2+0x7c>
c0d03dc8:	4281      	cmp	r1, r0
c0d03dca:	d014      	beq.n	c0d03df6 <__ledf2+0x92>
c0d03dcc:	2002      	movs	r0, #2
c0d03dce:	3901      	subs	r1, #1
c0d03dd0:	4008      	ands	r0, r1
c0d03dd2:	3801      	subs	r0, #1
c0d03dd4:	e000      	b.n	c0d03dd8 <__ledf2+0x74>
c0d03dd6:	2002      	movs	r0, #2
c0d03dd8:	bcc0      	pop	{r6, r7}
c0d03dda:	46b9      	mov	r9, r7
c0d03ddc:	46b0      	mov	r8, r6
c0d03dde:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03de0:	2800      	cmp	r0, #0
c0d03de2:	d1f9      	bne.n	c0d03dd8 <__ledf2+0x74>
c0d03de4:	2001      	movs	r0, #1
c0d03de6:	4240      	negs	r0, r0
c0d03de8:	e7f6      	b.n	c0d03dd8 <__ledf2+0x74>
c0d03dea:	2b00      	cmp	r3, #0
c0d03dec:	d1ec      	bne.n	c0d03dc8 <__ledf2+0x64>
c0d03dee:	464c      	mov	r4, r9
c0d03df0:	4326      	orrs	r6, r4
c0d03df2:	d1e9      	bne.n	c0d03dc8 <__ledf2+0x64>
c0d03df4:	e7ea      	b.n	c0d03dcc <__ledf2+0x68>
c0d03df6:	429a      	cmp	r2, r3
c0d03df8:	dd04      	ble.n	c0d03e04 <__ledf2+0xa0>
c0d03dfa:	4243      	negs	r3, r0
c0d03dfc:	4158      	adcs	r0, r3
c0d03dfe:	0040      	lsls	r0, r0, #1
c0d03e00:	3801      	subs	r0, #1
c0d03e02:	e7e9      	b.n	c0d03dd8 <__ledf2+0x74>
c0d03e04:	429a      	cmp	r2, r3
c0d03e06:	dbeb      	blt.n	c0d03de0 <__ledf2+0x7c>
c0d03e08:	454f      	cmp	r7, r9
c0d03e0a:	d8df      	bhi.n	c0d03dcc <__ledf2+0x68>
c0d03e0c:	d006      	beq.n	c0d03e1c <__ledf2+0xb8>
c0d03e0e:	2000      	movs	r0, #0
c0d03e10:	454f      	cmp	r7, r9
c0d03e12:	d2e1      	bcs.n	c0d03dd8 <__ledf2+0x74>
c0d03e14:	2900      	cmp	r1, #0
c0d03e16:	d0e5      	beq.n	c0d03de4 <__ledf2+0x80>
c0d03e18:	0008      	movs	r0, r1
c0d03e1a:	e7dd      	b.n	c0d03dd8 <__ledf2+0x74>
c0d03e1c:	45c4      	cmp	ip, r8
c0d03e1e:	d8d5      	bhi.n	c0d03dcc <__ledf2+0x68>
c0d03e20:	2000      	movs	r0, #0
c0d03e22:	45c4      	cmp	ip, r8
c0d03e24:	d2d8      	bcs.n	c0d03dd8 <__ledf2+0x74>
c0d03e26:	e7f5      	b.n	c0d03e14 <__ledf2+0xb0>
c0d03e28:	000007ff 	.word	0x000007ff

c0d03e2c <__aeabi_dmul>:
c0d03e2c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03e2e:	4657      	mov	r7, sl
c0d03e30:	464e      	mov	r6, r9
c0d03e32:	4645      	mov	r5, r8
c0d03e34:	46de      	mov	lr, fp
c0d03e36:	b5e0      	push	{r5, r6, r7, lr}
c0d03e38:	4698      	mov	r8, r3
c0d03e3a:	030c      	lsls	r4, r1, #12
c0d03e3c:	004b      	lsls	r3, r1, #1
c0d03e3e:	0006      	movs	r6, r0
c0d03e40:	4692      	mov	sl, r2
c0d03e42:	b087      	sub	sp, #28
c0d03e44:	0b24      	lsrs	r4, r4, #12
c0d03e46:	0d5b      	lsrs	r3, r3, #21
c0d03e48:	0fcf      	lsrs	r7, r1, #31
c0d03e4a:	2b00      	cmp	r3, #0
c0d03e4c:	d100      	bne.n	c0d03e50 <__aeabi_dmul+0x24>
c0d03e4e:	e15e      	b.n	c0d0410e <__aeabi_dmul+0x2e2>
c0d03e50:	4ada      	ldr	r2, [pc, #872]	; (c0d041bc <__aeabi_dmul+0x390>)
c0d03e52:	4293      	cmp	r3, r2
c0d03e54:	d100      	bne.n	c0d03e58 <__aeabi_dmul+0x2c>
c0d03e56:	e177      	b.n	c0d04148 <__aeabi_dmul+0x31c>
c0d03e58:	0f42      	lsrs	r2, r0, #29
c0d03e5a:	00e4      	lsls	r4, r4, #3
c0d03e5c:	4314      	orrs	r4, r2
c0d03e5e:	2280      	movs	r2, #128	; 0x80
c0d03e60:	0412      	lsls	r2, r2, #16
c0d03e62:	4314      	orrs	r4, r2
c0d03e64:	4ad6      	ldr	r2, [pc, #856]	; (c0d041c0 <__aeabi_dmul+0x394>)
c0d03e66:	00c5      	lsls	r5, r0, #3
c0d03e68:	4694      	mov	ip, r2
c0d03e6a:	4463      	add	r3, ip
c0d03e6c:	9300      	str	r3, [sp, #0]
c0d03e6e:	2300      	movs	r3, #0
c0d03e70:	4699      	mov	r9, r3
c0d03e72:	469b      	mov	fp, r3
c0d03e74:	4643      	mov	r3, r8
c0d03e76:	4642      	mov	r2, r8
c0d03e78:	031e      	lsls	r6, r3, #12
c0d03e7a:	0fd2      	lsrs	r2, r2, #31
c0d03e7c:	005b      	lsls	r3, r3, #1
c0d03e7e:	4650      	mov	r0, sl
c0d03e80:	4690      	mov	r8, r2
c0d03e82:	0b36      	lsrs	r6, r6, #12
c0d03e84:	0d5b      	lsrs	r3, r3, #21
c0d03e86:	d100      	bne.n	c0d03e8a <__aeabi_dmul+0x5e>
c0d03e88:	e122      	b.n	c0d040d0 <__aeabi_dmul+0x2a4>
c0d03e8a:	4acc      	ldr	r2, [pc, #816]	; (c0d041bc <__aeabi_dmul+0x390>)
c0d03e8c:	4293      	cmp	r3, r2
c0d03e8e:	d100      	bne.n	c0d03e92 <__aeabi_dmul+0x66>
c0d03e90:	e164      	b.n	c0d0415c <__aeabi_dmul+0x330>
c0d03e92:	49cb      	ldr	r1, [pc, #812]	; (c0d041c0 <__aeabi_dmul+0x394>)
c0d03e94:	0f42      	lsrs	r2, r0, #29
c0d03e96:	468c      	mov	ip, r1
c0d03e98:	9900      	ldr	r1, [sp, #0]
c0d03e9a:	4463      	add	r3, ip
c0d03e9c:	00f6      	lsls	r6, r6, #3
c0d03e9e:	468c      	mov	ip, r1
c0d03ea0:	4316      	orrs	r6, r2
c0d03ea2:	2280      	movs	r2, #128	; 0x80
c0d03ea4:	449c      	add	ip, r3
c0d03ea6:	0412      	lsls	r2, r2, #16
c0d03ea8:	4663      	mov	r3, ip
c0d03eaa:	4316      	orrs	r6, r2
c0d03eac:	00c2      	lsls	r2, r0, #3
c0d03eae:	2000      	movs	r0, #0
c0d03eb0:	9300      	str	r3, [sp, #0]
c0d03eb2:	9900      	ldr	r1, [sp, #0]
c0d03eb4:	4643      	mov	r3, r8
c0d03eb6:	3101      	adds	r1, #1
c0d03eb8:	468c      	mov	ip, r1
c0d03eba:	4649      	mov	r1, r9
c0d03ebc:	407b      	eors	r3, r7
c0d03ebe:	9301      	str	r3, [sp, #4]
c0d03ec0:	290f      	cmp	r1, #15
c0d03ec2:	d826      	bhi.n	c0d03f12 <__aeabi_dmul+0xe6>
c0d03ec4:	4bbf      	ldr	r3, [pc, #764]	; (c0d041c4 <__aeabi_dmul+0x398>)
c0d03ec6:	0089      	lsls	r1, r1, #2
c0d03ec8:	5859      	ldr	r1, [r3, r1]
c0d03eca:	468f      	mov	pc, r1
c0d03ecc:	4643      	mov	r3, r8
c0d03ece:	9301      	str	r3, [sp, #4]
c0d03ed0:	0034      	movs	r4, r6
c0d03ed2:	0015      	movs	r5, r2
c0d03ed4:	4683      	mov	fp, r0
c0d03ed6:	465b      	mov	r3, fp
c0d03ed8:	2b02      	cmp	r3, #2
c0d03eda:	d016      	beq.n	c0d03f0a <__aeabi_dmul+0xde>
c0d03edc:	2b03      	cmp	r3, #3
c0d03ede:	d100      	bne.n	c0d03ee2 <__aeabi_dmul+0xb6>
c0d03ee0:	e205      	b.n	c0d042ee <__aeabi_dmul+0x4c2>
c0d03ee2:	2b01      	cmp	r3, #1
c0d03ee4:	d000      	beq.n	c0d03ee8 <__aeabi_dmul+0xbc>
c0d03ee6:	e0cf      	b.n	c0d04088 <__aeabi_dmul+0x25c>
c0d03ee8:	2200      	movs	r2, #0
c0d03eea:	2400      	movs	r4, #0
c0d03eec:	2500      	movs	r5, #0
c0d03eee:	9b01      	ldr	r3, [sp, #4]
c0d03ef0:	0512      	lsls	r2, r2, #20
c0d03ef2:	4322      	orrs	r2, r4
c0d03ef4:	07db      	lsls	r3, r3, #31
c0d03ef6:	431a      	orrs	r2, r3
c0d03ef8:	0028      	movs	r0, r5
c0d03efa:	0011      	movs	r1, r2
c0d03efc:	b007      	add	sp, #28
c0d03efe:	bcf0      	pop	{r4, r5, r6, r7}
c0d03f00:	46bb      	mov	fp, r7
c0d03f02:	46b2      	mov	sl, r6
c0d03f04:	46a9      	mov	r9, r5
c0d03f06:	46a0      	mov	r8, r4
c0d03f08:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03f0a:	2400      	movs	r4, #0
c0d03f0c:	2500      	movs	r5, #0
c0d03f0e:	4aab      	ldr	r2, [pc, #684]	; (c0d041bc <__aeabi_dmul+0x390>)
c0d03f10:	e7ed      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d03f12:	0c28      	lsrs	r0, r5, #16
c0d03f14:	042d      	lsls	r5, r5, #16
c0d03f16:	0c2d      	lsrs	r5, r5, #16
c0d03f18:	002b      	movs	r3, r5
c0d03f1a:	0c11      	lsrs	r1, r2, #16
c0d03f1c:	0412      	lsls	r2, r2, #16
c0d03f1e:	0c12      	lsrs	r2, r2, #16
c0d03f20:	4353      	muls	r3, r2
c0d03f22:	4698      	mov	r8, r3
c0d03f24:	0013      	movs	r3, r2
c0d03f26:	002f      	movs	r7, r5
c0d03f28:	4343      	muls	r3, r0
c0d03f2a:	4699      	mov	r9, r3
c0d03f2c:	434f      	muls	r7, r1
c0d03f2e:	444f      	add	r7, r9
c0d03f30:	46bb      	mov	fp, r7
c0d03f32:	4647      	mov	r7, r8
c0d03f34:	000b      	movs	r3, r1
c0d03f36:	0c3f      	lsrs	r7, r7, #16
c0d03f38:	46ba      	mov	sl, r7
c0d03f3a:	465f      	mov	r7, fp
c0d03f3c:	4343      	muls	r3, r0
c0d03f3e:	4457      	add	r7, sl
c0d03f40:	9302      	str	r3, [sp, #8]
c0d03f42:	45b9      	cmp	r9, r7
c0d03f44:	d906      	bls.n	c0d03f54 <__aeabi_dmul+0x128>
c0d03f46:	469a      	mov	sl, r3
c0d03f48:	2380      	movs	r3, #128	; 0x80
c0d03f4a:	025b      	lsls	r3, r3, #9
c0d03f4c:	4699      	mov	r9, r3
c0d03f4e:	44ca      	add	sl, r9
c0d03f50:	4653      	mov	r3, sl
c0d03f52:	9302      	str	r3, [sp, #8]
c0d03f54:	0c3b      	lsrs	r3, r7, #16
c0d03f56:	469b      	mov	fp, r3
c0d03f58:	4643      	mov	r3, r8
c0d03f5a:	041b      	lsls	r3, r3, #16
c0d03f5c:	043f      	lsls	r7, r7, #16
c0d03f5e:	0c1b      	lsrs	r3, r3, #16
c0d03f60:	4698      	mov	r8, r3
c0d03f62:	003b      	movs	r3, r7
c0d03f64:	4443      	add	r3, r8
c0d03f66:	9304      	str	r3, [sp, #16]
c0d03f68:	0c33      	lsrs	r3, r6, #16
c0d03f6a:	0436      	lsls	r6, r6, #16
c0d03f6c:	0c36      	lsrs	r6, r6, #16
c0d03f6e:	4698      	mov	r8, r3
c0d03f70:	0033      	movs	r3, r6
c0d03f72:	4343      	muls	r3, r0
c0d03f74:	4699      	mov	r9, r3
c0d03f76:	4643      	mov	r3, r8
c0d03f78:	4343      	muls	r3, r0
c0d03f7a:	002f      	movs	r7, r5
c0d03f7c:	469a      	mov	sl, r3
c0d03f7e:	4643      	mov	r3, r8
c0d03f80:	4377      	muls	r7, r6
c0d03f82:	435d      	muls	r5, r3
c0d03f84:	0c38      	lsrs	r0, r7, #16
c0d03f86:	444d      	add	r5, r9
c0d03f88:	1945      	adds	r5, r0, r5
c0d03f8a:	45a9      	cmp	r9, r5
c0d03f8c:	d903      	bls.n	c0d03f96 <__aeabi_dmul+0x16a>
c0d03f8e:	2380      	movs	r3, #128	; 0x80
c0d03f90:	025b      	lsls	r3, r3, #9
c0d03f92:	4699      	mov	r9, r3
c0d03f94:	44ca      	add	sl, r9
c0d03f96:	043f      	lsls	r7, r7, #16
c0d03f98:	0c28      	lsrs	r0, r5, #16
c0d03f9a:	0c3f      	lsrs	r7, r7, #16
c0d03f9c:	042d      	lsls	r5, r5, #16
c0d03f9e:	19ed      	adds	r5, r5, r7
c0d03fa0:	0c27      	lsrs	r7, r4, #16
c0d03fa2:	0424      	lsls	r4, r4, #16
c0d03fa4:	0c24      	lsrs	r4, r4, #16
c0d03fa6:	0003      	movs	r3, r0
c0d03fa8:	0020      	movs	r0, r4
c0d03faa:	4350      	muls	r0, r2
c0d03fac:	437a      	muls	r2, r7
c0d03fae:	4691      	mov	r9, r2
c0d03fb0:	003a      	movs	r2, r7
c0d03fb2:	4453      	add	r3, sl
c0d03fb4:	9305      	str	r3, [sp, #20]
c0d03fb6:	0c03      	lsrs	r3, r0, #16
c0d03fb8:	469a      	mov	sl, r3
c0d03fba:	434a      	muls	r2, r1
c0d03fbc:	4361      	muls	r1, r4
c0d03fbe:	4449      	add	r1, r9
c0d03fc0:	4451      	add	r1, sl
c0d03fc2:	44ab      	add	fp, r5
c0d03fc4:	4589      	cmp	r9, r1
c0d03fc6:	d903      	bls.n	c0d03fd0 <__aeabi_dmul+0x1a4>
c0d03fc8:	2380      	movs	r3, #128	; 0x80
c0d03fca:	025b      	lsls	r3, r3, #9
c0d03fcc:	4699      	mov	r9, r3
c0d03fce:	444a      	add	r2, r9
c0d03fd0:	0400      	lsls	r0, r0, #16
c0d03fd2:	0c0b      	lsrs	r3, r1, #16
c0d03fd4:	0c00      	lsrs	r0, r0, #16
c0d03fd6:	0409      	lsls	r1, r1, #16
c0d03fd8:	1809      	adds	r1, r1, r0
c0d03fda:	0020      	movs	r0, r4
c0d03fdc:	4699      	mov	r9, r3
c0d03fde:	4643      	mov	r3, r8
c0d03fe0:	4370      	muls	r0, r6
c0d03fe2:	435c      	muls	r4, r3
c0d03fe4:	437e      	muls	r6, r7
c0d03fe6:	435f      	muls	r7, r3
c0d03fe8:	0c03      	lsrs	r3, r0, #16
c0d03fea:	4698      	mov	r8, r3
c0d03fec:	19a4      	adds	r4, r4, r6
c0d03fee:	4444      	add	r4, r8
c0d03ff0:	444a      	add	r2, r9
c0d03ff2:	9703      	str	r7, [sp, #12]
c0d03ff4:	42a6      	cmp	r6, r4
c0d03ff6:	d904      	bls.n	c0d04002 <__aeabi_dmul+0x1d6>
c0d03ff8:	2380      	movs	r3, #128	; 0x80
c0d03ffa:	025b      	lsls	r3, r3, #9
c0d03ffc:	4698      	mov	r8, r3
c0d03ffe:	4447      	add	r7, r8
c0d04000:	9703      	str	r7, [sp, #12]
c0d04002:	9b02      	ldr	r3, [sp, #8]
c0d04004:	0400      	lsls	r0, r0, #16
c0d04006:	445b      	add	r3, fp
c0d04008:	001e      	movs	r6, r3
c0d0400a:	42ab      	cmp	r3, r5
c0d0400c:	41ad      	sbcs	r5, r5
c0d0400e:	0423      	lsls	r3, r4, #16
c0d04010:	469a      	mov	sl, r3
c0d04012:	9b05      	ldr	r3, [sp, #20]
c0d04014:	1876      	adds	r6, r6, r1
c0d04016:	4698      	mov	r8, r3
c0d04018:	428e      	cmp	r6, r1
c0d0401a:	4189      	sbcs	r1, r1
c0d0401c:	0c00      	lsrs	r0, r0, #16
c0d0401e:	4450      	add	r0, sl
c0d04020:	4440      	add	r0, r8
c0d04022:	426d      	negs	r5, r5
c0d04024:	1947      	adds	r7, r0, r5
c0d04026:	46b8      	mov	r8, r7
c0d04028:	4693      	mov	fp, r2
c0d0402a:	4249      	negs	r1, r1
c0d0402c:	4689      	mov	r9, r1
c0d0402e:	44c3      	add	fp, r8
c0d04030:	44d9      	add	r9, fp
c0d04032:	4298      	cmp	r0, r3
c0d04034:	4180      	sbcs	r0, r0
c0d04036:	45a8      	cmp	r8, r5
c0d04038:	41ad      	sbcs	r5, r5
c0d0403a:	4593      	cmp	fp, r2
c0d0403c:	4192      	sbcs	r2, r2
c0d0403e:	4589      	cmp	r9, r1
c0d04040:	4189      	sbcs	r1, r1
c0d04042:	426d      	negs	r5, r5
c0d04044:	4240      	negs	r0, r0
c0d04046:	4328      	orrs	r0, r5
c0d04048:	0c24      	lsrs	r4, r4, #16
c0d0404a:	4252      	negs	r2, r2
c0d0404c:	4249      	negs	r1, r1
c0d0404e:	430a      	orrs	r2, r1
c0d04050:	9b03      	ldr	r3, [sp, #12]
c0d04052:	1900      	adds	r0, r0, r4
c0d04054:	1880      	adds	r0, r0, r2
c0d04056:	18c7      	adds	r7, r0, r3
c0d04058:	464b      	mov	r3, r9
c0d0405a:	0ddc      	lsrs	r4, r3, #23
c0d0405c:	9b04      	ldr	r3, [sp, #16]
c0d0405e:	0275      	lsls	r5, r6, #9
c0d04060:	431d      	orrs	r5, r3
c0d04062:	1e6a      	subs	r2, r5, #1
c0d04064:	4195      	sbcs	r5, r2
c0d04066:	464b      	mov	r3, r9
c0d04068:	0df6      	lsrs	r6, r6, #23
c0d0406a:	027f      	lsls	r7, r7, #9
c0d0406c:	4335      	orrs	r5, r6
c0d0406e:	025a      	lsls	r2, r3, #9
c0d04070:	433c      	orrs	r4, r7
c0d04072:	4315      	orrs	r5, r2
c0d04074:	01fb      	lsls	r3, r7, #7
c0d04076:	d400      	bmi.n	c0d0407a <__aeabi_dmul+0x24e>
c0d04078:	e11c      	b.n	c0d042b4 <__aeabi_dmul+0x488>
c0d0407a:	2101      	movs	r1, #1
c0d0407c:	086a      	lsrs	r2, r5, #1
c0d0407e:	400d      	ands	r5, r1
c0d04080:	4315      	orrs	r5, r2
c0d04082:	07e2      	lsls	r2, r4, #31
c0d04084:	4315      	orrs	r5, r2
c0d04086:	0864      	lsrs	r4, r4, #1
c0d04088:	494f      	ldr	r1, [pc, #316]	; (c0d041c8 <__aeabi_dmul+0x39c>)
c0d0408a:	4461      	add	r1, ip
c0d0408c:	2900      	cmp	r1, #0
c0d0408e:	dc00      	bgt.n	c0d04092 <__aeabi_dmul+0x266>
c0d04090:	e0b0      	b.n	c0d041f4 <__aeabi_dmul+0x3c8>
c0d04092:	076b      	lsls	r3, r5, #29
c0d04094:	d009      	beq.n	c0d040aa <__aeabi_dmul+0x27e>
c0d04096:	220f      	movs	r2, #15
c0d04098:	402a      	ands	r2, r5
c0d0409a:	2a04      	cmp	r2, #4
c0d0409c:	d005      	beq.n	c0d040aa <__aeabi_dmul+0x27e>
c0d0409e:	1d2a      	adds	r2, r5, #4
c0d040a0:	42aa      	cmp	r2, r5
c0d040a2:	41ad      	sbcs	r5, r5
c0d040a4:	426d      	negs	r5, r5
c0d040a6:	1964      	adds	r4, r4, r5
c0d040a8:	0015      	movs	r5, r2
c0d040aa:	01e3      	lsls	r3, r4, #7
c0d040ac:	d504      	bpl.n	c0d040b8 <__aeabi_dmul+0x28c>
c0d040ae:	2180      	movs	r1, #128	; 0x80
c0d040b0:	4a46      	ldr	r2, [pc, #280]	; (c0d041cc <__aeabi_dmul+0x3a0>)
c0d040b2:	00c9      	lsls	r1, r1, #3
c0d040b4:	4014      	ands	r4, r2
c0d040b6:	4461      	add	r1, ip
c0d040b8:	4a45      	ldr	r2, [pc, #276]	; (c0d041d0 <__aeabi_dmul+0x3a4>)
c0d040ba:	4291      	cmp	r1, r2
c0d040bc:	dd00      	ble.n	c0d040c0 <__aeabi_dmul+0x294>
c0d040be:	e724      	b.n	c0d03f0a <__aeabi_dmul+0xde>
c0d040c0:	0762      	lsls	r2, r4, #29
c0d040c2:	08ed      	lsrs	r5, r5, #3
c0d040c4:	0264      	lsls	r4, r4, #9
c0d040c6:	0549      	lsls	r1, r1, #21
c0d040c8:	4315      	orrs	r5, r2
c0d040ca:	0b24      	lsrs	r4, r4, #12
c0d040cc:	0d4a      	lsrs	r2, r1, #21
c0d040ce:	e70e      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d040d0:	4652      	mov	r2, sl
c0d040d2:	4332      	orrs	r2, r6
c0d040d4:	d100      	bne.n	c0d040d8 <__aeabi_dmul+0x2ac>
c0d040d6:	e07f      	b.n	c0d041d8 <__aeabi_dmul+0x3ac>
c0d040d8:	2e00      	cmp	r6, #0
c0d040da:	d100      	bne.n	c0d040de <__aeabi_dmul+0x2b2>
c0d040dc:	e0dc      	b.n	c0d04298 <__aeabi_dmul+0x46c>
c0d040de:	0030      	movs	r0, r6
c0d040e0:	f000 fd4e 	bl	c0d04b80 <__clzsi2>
c0d040e4:	0002      	movs	r2, r0
c0d040e6:	3a0b      	subs	r2, #11
c0d040e8:	231d      	movs	r3, #29
c0d040ea:	0001      	movs	r1, r0
c0d040ec:	1a9b      	subs	r3, r3, r2
c0d040ee:	4652      	mov	r2, sl
c0d040f0:	3908      	subs	r1, #8
c0d040f2:	40da      	lsrs	r2, r3
c0d040f4:	408e      	lsls	r6, r1
c0d040f6:	4316      	orrs	r6, r2
c0d040f8:	4652      	mov	r2, sl
c0d040fa:	408a      	lsls	r2, r1
c0d040fc:	9b00      	ldr	r3, [sp, #0]
c0d040fe:	4935      	ldr	r1, [pc, #212]	; (c0d041d4 <__aeabi_dmul+0x3a8>)
c0d04100:	1a18      	subs	r0, r3, r0
c0d04102:	0003      	movs	r3, r0
c0d04104:	468c      	mov	ip, r1
c0d04106:	4463      	add	r3, ip
c0d04108:	2000      	movs	r0, #0
c0d0410a:	9300      	str	r3, [sp, #0]
c0d0410c:	e6d1      	b.n	c0d03eb2 <__aeabi_dmul+0x86>
c0d0410e:	0025      	movs	r5, r4
c0d04110:	4305      	orrs	r5, r0
c0d04112:	d04a      	beq.n	c0d041aa <__aeabi_dmul+0x37e>
c0d04114:	2c00      	cmp	r4, #0
c0d04116:	d100      	bne.n	c0d0411a <__aeabi_dmul+0x2ee>
c0d04118:	e0b0      	b.n	c0d0427c <__aeabi_dmul+0x450>
c0d0411a:	0020      	movs	r0, r4
c0d0411c:	f000 fd30 	bl	c0d04b80 <__clzsi2>
c0d04120:	0001      	movs	r1, r0
c0d04122:	0002      	movs	r2, r0
c0d04124:	390b      	subs	r1, #11
c0d04126:	231d      	movs	r3, #29
c0d04128:	0010      	movs	r0, r2
c0d0412a:	1a5b      	subs	r3, r3, r1
c0d0412c:	0031      	movs	r1, r6
c0d0412e:	0035      	movs	r5, r6
c0d04130:	3808      	subs	r0, #8
c0d04132:	4084      	lsls	r4, r0
c0d04134:	40d9      	lsrs	r1, r3
c0d04136:	4085      	lsls	r5, r0
c0d04138:	430c      	orrs	r4, r1
c0d0413a:	4826      	ldr	r0, [pc, #152]	; (c0d041d4 <__aeabi_dmul+0x3a8>)
c0d0413c:	1a83      	subs	r3, r0, r2
c0d0413e:	9300      	str	r3, [sp, #0]
c0d04140:	2300      	movs	r3, #0
c0d04142:	4699      	mov	r9, r3
c0d04144:	469b      	mov	fp, r3
c0d04146:	e695      	b.n	c0d03e74 <__aeabi_dmul+0x48>
c0d04148:	0005      	movs	r5, r0
c0d0414a:	4325      	orrs	r5, r4
c0d0414c:	d126      	bne.n	c0d0419c <__aeabi_dmul+0x370>
c0d0414e:	2208      	movs	r2, #8
c0d04150:	9300      	str	r3, [sp, #0]
c0d04152:	2302      	movs	r3, #2
c0d04154:	2400      	movs	r4, #0
c0d04156:	4691      	mov	r9, r2
c0d04158:	469b      	mov	fp, r3
c0d0415a:	e68b      	b.n	c0d03e74 <__aeabi_dmul+0x48>
c0d0415c:	4652      	mov	r2, sl
c0d0415e:	9b00      	ldr	r3, [sp, #0]
c0d04160:	4332      	orrs	r2, r6
c0d04162:	d110      	bne.n	c0d04186 <__aeabi_dmul+0x35a>
c0d04164:	4915      	ldr	r1, [pc, #84]	; (c0d041bc <__aeabi_dmul+0x390>)
c0d04166:	2600      	movs	r6, #0
c0d04168:	468c      	mov	ip, r1
c0d0416a:	4463      	add	r3, ip
c0d0416c:	4649      	mov	r1, r9
c0d0416e:	9300      	str	r3, [sp, #0]
c0d04170:	2302      	movs	r3, #2
c0d04172:	4319      	orrs	r1, r3
c0d04174:	4689      	mov	r9, r1
c0d04176:	2002      	movs	r0, #2
c0d04178:	e69b      	b.n	c0d03eb2 <__aeabi_dmul+0x86>
c0d0417a:	465b      	mov	r3, fp
c0d0417c:	9701      	str	r7, [sp, #4]
c0d0417e:	2b02      	cmp	r3, #2
c0d04180:	d000      	beq.n	c0d04184 <__aeabi_dmul+0x358>
c0d04182:	e6ab      	b.n	c0d03edc <__aeabi_dmul+0xb0>
c0d04184:	e6c1      	b.n	c0d03f0a <__aeabi_dmul+0xde>
c0d04186:	4a0d      	ldr	r2, [pc, #52]	; (c0d041bc <__aeabi_dmul+0x390>)
c0d04188:	2003      	movs	r0, #3
c0d0418a:	4694      	mov	ip, r2
c0d0418c:	4463      	add	r3, ip
c0d0418e:	464a      	mov	r2, r9
c0d04190:	9300      	str	r3, [sp, #0]
c0d04192:	2303      	movs	r3, #3
c0d04194:	431a      	orrs	r2, r3
c0d04196:	4691      	mov	r9, r2
c0d04198:	4652      	mov	r2, sl
c0d0419a:	e68a      	b.n	c0d03eb2 <__aeabi_dmul+0x86>
c0d0419c:	220c      	movs	r2, #12
c0d0419e:	9300      	str	r3, [sp, #0]
c0d041a0:	2303      	movs	r3, #3
c0d041a2:	0005      	movs	r5, r0
c0d041a4:	4691      	mov	r9, r2
c0d041a6:	469b      	mov	fp, r3
c0d041a8:	e664      	b.n	c0d03e74 <__aeabi_dmul+0x48>
c0d041aa:	2304      	movs	r3, #4
c0d041ac:	4699      	mov	r9, r3
c0d041ae:	2300      	movs	r3, #0
c0d041b0:	9300      	str	r3, [sp, #0]
c0d041b2:	3301      	adds	r3, #1
c0d041b4:	2400      	movs	r4, #0
c0d041b6:	469b      	mov	fp, r3
c0d041b8:	e65c      	b.n	c0d03e74 <__aeabi_dmul+0x48>
c0d041ba:	46c0      	nop			; (mov r8, r8)
c0d041bc:	000007ff 	.word	0x000007ff
c0d041c0:	fffffc01 	.word	0xfffffc01
c0d041c4:	c0d04d20 	.word	0xc0d04d20
c0d041c8:	000003ff 	.word	0x000003ff
c0d041cc:	feffffff 	.word	0xfeffffff
c0d041d0:	000007fe 	.word	0x000007fe
c0d041d4:	fffffc0d 	.word	0xfffffc0d
c0d041d8:	4649      	mov	r1, r9
c0d041da:	2301      	movs	r3, #1
c0d041dc:	4319      	orrs	r1, r3
c0d041de:	4689      	mov	r9, r1
c0d041e0:	2600      	movs	r6, #0
c0d041e2:	2001      	movs	r0, #1
c0d041e4:	e665      	b.n	c0d03eb2 <__aeabi_dmul+0x86>
c0d041e6:	2300      	movs	r3, #0
c0d041e8:	2480      	movs	r4, #128	; 0x80
c0d041ea:	2500      	movs	r5, #0
c0d041ec:	4a43      	ldr	r2, [pc, #268]	; (c0d042fc <__aeabi_dmul+0x4d0>)
c0d041ee:	9301      	str	r3, [sp, #4]
c0d041f0:	0324      	lsls	r4, r4, #12
c0d041f2:	e67c      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d041f4:	2001      	movs	r0, #1
c0d041f6:	1a40      	subs	r0, r0, r1
c0d041f8:	2838      	cmp	r0, #56	; 0x38
c0d041fa:	dd00      	ble.n	c0d041fe <__aeabi_dmul+0x3d2>
c0d041fc:	e674      	b.n	c0d03ee8 <__aeabi_dmul+0xbc>
c0d041fe:	281f      	cmp	r0, #31
c0d04200:	dd5b      	ble.n	c0d042ba <__aeabi_dmul+0x48e>
c0d04202:	221f      	movs	r2, #31
c0d04204:	0023      	movs	r3, r4
c0d04206:	4252      	negs	r2, r2
c0d04208:	1a51      	subs	r1, r2, r1
c0d0420a:	40cb      	lsrs	r3, r1
c0d0420c:	0019      	movs	r1, r3
c0d0420e:	2820      	cmp	r0, #32
c0d04210:	d003      	beq.n	c0d0421a <__aeabi_dmul+0x3ee>
c0d04212:	4a3b      	ldr	r2, [pc, #236]	; (c0d04300 <__aeabi_dmul+0x4d4>)
c0d04214:	4462      	add	r2, ip
c0d04216:	4094      	lsls	r4, r2
c0d04218:	4325      	orrs	r5, r4
c0d0421a:	1e6a      	subs	r2, r5, #1
c0d0421c:	4195      	sbcs	r5, r2
c0d0421e:	002a      	movs	r2, r5
c0d04220:	430a      	orrs	r2, r1
c0d04222:	2107      	movs	r1, #7
c0d04224:	000d      	movs	r5, r1
c0d04226:	2400      	movs	r4, #0
c0d04228:	4015      	ands	r5, r2
c0d0422a:	4211      	tst	r1, r2
c0d0422c:	d05b      	beq.n	c0d042e6 <__aeabi_dmul+0x4ba>
c0d0422e:	210f      	movs	r1, #15
c0d04230:	2400      	movs	r4, #0
c0d04232:	4011      	ands	r1, r2
c0d04234:	2904      	cmp	r1, #4
c0d04236:	d053      	beq.n	c0d042e0 <__aeabi_dmul+0x4b4>
c0d04238:	1d11      	adds	r1, r2, #4
c0d0423a:	4291      	cmp	r1, r2
c0d0423c:	4192      	sbcs	r2, r2
c0d0423e:	4252      	negs	r2, r2
c0d04240:	18a4      	adds	r4, r4, r2
c0d04242:	000a      	movs	r2, r1
c0d04244:	0223      	lsls	r3, r4, #8
c0d04246:	d54b      	bpl.n	c0d042e0 <__aeabi_dmul+0x4b4>
c0d04248:	2201      	movs	r2, #1
c0d0424a:	2400      	movs	r4, #0
c0d0424c:	2500      	movs	r5, #0
c0d0424e:	e64e      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d04250:	2380      	movs	r3, #128	; 0x80
c0d04252:	031b      	lsls	r3, r3, #12
c0d04254:	421c      	tst	r4, r3
c0d04256:	d009      	beq.n	c0d0426c <__aeabi_dmul+0x440>
c0d04258:	421e      	tst	r6, r3
c0d0425a:	d107      	bne.n	c0d0426c <__aeabi_dmul+0x440>
c0d0425c:	4333      	orrs	r3, r6
c0d0425e:	031c      	lsls	r4, r3, #12
c0d04260:	4643      	mov	r3, r8
c0d04262:	0015      	movs	r5, r2
c0d04264:	0b24      	lsrs	r4, r4, #12
c0d04266:	4a25      	ldr	r2, [pc, #148]	; (c0d042fc <__aeabi_dmul+0x4d0>)
c0d04268:	9301      	str	r3, [sp, #4]
c0d0426a:	e640      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d0426c:	2280      	movs	r2, #128	; 0x80
c0d0426e:	0312      	lsls	r2, r2, #12
c0d04270:	4314      	orrs	r4, r2
c0d04272:	0324      	lsls	r4, r4, #12
c0d04274:	4a21      	ldr	r2, [pc, #132]	; (c0d042fc <__aeabi_dmul+0x4d0>)
c0d04276:	0b24      	lsrs	r4, r4, #12
c0d04278:	9701      	str	r7, [sp, #4]
c0d0427a:	e638      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d0427c:	f000 fc80 	bl	c0d04b80 <__clzsi2>
c0d04280:	0001      	movs	r1, r0
c0d04282:	0002      	movs	r2, r0
c0d04284:	3115      	adds	r1, #21
c0d04286:	3220      	adds	r2, #32
c0d04288:	291c      	cmp	r1, #28
c0d0428a:	dc00      	bgt.n	c0d0428e <__aeabi_dmul+0x462>
c0d0428c:	e74b      	b.n	c0d04126 <__aeabi_dmul+0x2fa>
c0d0428e:	0034      	movs	r4, r6
c0d04290:	3808      	subs	r0, #8
c0d04292:	2500      	movs	r5, #0
c0d04294:	4084      	lsls	r4, r0
c0d04296:	e750      	b.n	c0d0413a <__aeabi_dmul+0x30e>
c0d04298:	f000 fc72 	bl	c0d04b80 <__clzsi2>
c0d0429c:	0003      	movs	r3, r0
c0d0429e:	001a      	movs	r2, r3
c0d042a0:	3215      	adds	r2, #21
c0d042a2:	3020      	adds	r0, #32
c0d042a4:	2a1c      	cmp	r2, #28
c0d042a6:	dc00      	bgt.n	c0d042aa <__aeabi_dmul+0x47e>
c0d042a8:	e71e      	b.n	c0d040e8 <__aeabi_dmul+0x2bc>
c0d042aa:	4656      	mov	r6, sl
c0d042ac:	3b08      	subs	r3, #8
c0d042ae:	2200      	movs	r2, #0
c0d042b0:	409e      	lsls	r6, r3
c0d042b2:	e723      	b.n	c0d040fc <__aeabi_dmul+0x2d0>
c0d042b4:	9b00      	ldr	r3, [sp, #0]
c0d042b6:	469c      	mov	ip, r3
c0d042b8:	e6e6      	b.n	c0d04088 <__aeabi_dmul+0x25c>
c0d042ba:	4912      	ldr	r1, [pc, #72]	; (c0d04304 <__aeabi_dmul+0x4d8>)
c0d042bc:	0022      	movs	r2, r4
c0d042be:	4461      	add	r1, ip
c0d042c0:	002e      	movs	r6, r5
c0d042c2:	408d      	lsls	r5, r1
c0d042c4:	408a      	lsls	r2, r1
c0d042c6:	40c6      	lsrs	r6, r0
c0d042c8:	1e69      	subs	r1, r5, #1
c0d042ca:	418d      	sbcs	r5, r1
c0d042cc:	4332      	orrs	r2, r6
c0d042ce:	432a      	orrs	r2, r5
c0d042d0:	40c4      	lsrs	r4, r0
c0d042d2:	0753      	lsls	r3, r2, #29
c0d042d4:	d0b6      	beq.n	c0d04244 <__aeabi_dmul+0x418>
c0d042d6:	210f      	movs	r1, #15
c0d042d8:	4011      	ands	r1, r2
c0d042da:	2904      	cmp	r1, #4
c0d042dc:	d1ac      	bne.n	c0d04238 <__aeabi_dmul+0x40c>
c0d042de:	e7b1      	b.n	c0d04244 <__aeabi_dmul+0x418>
c0d042e0:	0765      	lsls	r5, r4, #29
c0d042e2:	0264      	lsls	r4, r4, #9
c0d042e4:	0b24      	lsrs	r4, r4, #12
c0d042e6:	08d2      	lsrs	r2, r2, #3
c0d042e8:	4315      	orrs	r5, r2
c0d042ea:	2200      	movs	r2, #0
c0d042ec:	e5ff      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d042ee:	2280      	movs	r2, #128	; 0x80
c0d042f0:	0312      	lsls	r2, r2, #12
c0d042f2:	4314      	orrs	r4, r2
c0d042f4:	0324      	lsls	r4, r4, #12
c0d042f6:	4a01      	ldr	r2, [pc, #4]	; (c0d042fc <__aeabi_dmul+0x4d0>)
c0d042f8:	0b24      	lsrs	r4, r4, #12
c0d042fa:	e5f8      	b.n	c0d03eee <__aeabi_dmul+0xc2>
c0d042fc:	000007ff 	.word	0x000007ff
c0d04300:	0000043e 	.word	0x0000043e
c0d04304:	0000041e 	.word	0x0000041e

c0d04308 <__aeabi_dsub>:
c0d04308:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
c0d0430a:	4657      	mov	r7, sl
c0d0430c:	464e      	mov	r6, r9
c0d0430e:	4645      	mov	r5, r8
c0d04310:	46de      	mov	lr, fp
c0d04312:	b5e0      	push	{r5, r6, r7, lr}
c0d04314:	001e      	movs	r6, r3
c0d04316:	0017      	movs	r7, r2
c0d04318:	004a      	lsls	r2, r1, #1
c0d0431a:	030b      	lsls	r3, r1, #12
c0d0431c:	0d52      	lsrs	r2, r2, #21
c0d0431e:	0a5b      	lsrs	r3, r3, #9
c0d04320:	4690      	mov	r8, r2
c0d04322:	0f42      	lsrs	r2, r0, #29
c0d04324:	431a      	orrs	r2, r3
c0d04326:	0fcd      	lsrs	r5, r1, #31
c0d04328:	4ccd      	ldr	r4, [pc, #820]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d0432a:	0331      	lsls	r1, r6, #12
c0d0432c:	00c3      	lsls	r3, r0, #3
c0d0432e:	4694      	mov	ip, r2
c0d04330:	0070      	lsls	r0, r6, #1
c0d04332:	0f7a      	lsrs	r2, r7, #29
c0d04334:	0a49      	lsrs	r1, r1, #9
c0d04336:	00ff      	lsls	r7, r7, #3
c0d04338:	469a      	mov	sl, r3
c0d0433a:	46b9      	mov	r9, r7
c0d0433c:	0d40      	lsrs	r0, r0, #21
c0d0433e:	0ff6      	lsrs	r6, r6, #31
c0d04340:	4311      	orrs	r1, r2
c0d04342:	42a0      	cmp	r0, r4
c0d04344:	d100      	bne.n	c0d04348 <__aeabi_dsub+0x40>
c0d04346:	e0b1      	b.n	c0d044ac <__aeabi_dsub+0x1a4>
c0d04348:	2201      	movs	r2, #1
c0d0434a:	4056      	eors	r6, r2
c0d0434c:	46b3      	mov	fp, r6
c0d0434e:	42b5      	cmp	r5, r6
c0d04350:	d100      	bne.n	c0d04354 <__aeabi_dsub+0x4c>
c0d04352:	e088      	b.n	c0d04466 <__aeabi_dsub+0x15e>
c0d04354:	4642      	mov	r2, r8
c0d04356:	1a12      	subs	r2, r2, r0
c0d04358:	2a00      	cmp	r2, #0
c0d0435a:	dc00      	bgt.n	c0d0435e <__aeabi_dsub+0x56>
c0d0435c:	e0ae      	b.n	c0d044bc <__aeabi_dsub+0x1b4>
c0d0435e:	2800      	cmp	r0, #0
c0d04360:	d100      	bne.n	c0d04364 <__aeabi_dsub+0x5c>
c0d04362:	e0c1      	b.n	c0d044e8 <__aeabi_dsub+0x1e0>
c0d04364:	48be      	ldr	r0, [pc, #760]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d04366:	4580      	cmp	r8, r0
c0d04368:	d100      	bne.n	c0d0436c <__aeabi_dsub+0x64>
c0d0436a:	e151      	b.n	c0d04610 <__aeabi_dsub+0x308>
c0d0436c:	2080      	movs	r0, #128	; 0x80
c0d0436e:	0400      	lsls	r0, r0, #16
c0d04370:	4301      	orrs	r1, r0
c0d04372:	2a38      	cmp	r2, #56	; 0x38
c0d04374:	dd00      	ble.n	c0d04378 <__aeabi_dsub+0x70>
c0d04376:	e17b      	b.n	c0d04670 <__aeabi_dsub+0x368>
c0d04378:	2a1f      	cmp	r2, #31
c0d0437a:	dd00      	ble.n	c0d0437e <__aeabi_dsub+0x76>
c0d0437c:	e1ee      	b.n	c0d0475c <__aeabi_dsub+0x454>
c0d0437e:	2020      	movs	r0, #32
c0d04380:	003e      	movs	r6, r7
c0d04382:	1a80      	subs	r0, r0, r2
c0d04384:	000c      	movs	r4, r1
c0d04386:	40d6      	lsrs	r6, r2
c0d04388:	40d1      	lsrs	r1, r2
c0d0438a:	4087      	lsls	r7, r0
c0d0438c:	4662      	mov	r2, ip
c0d0438e:	4084      	lsls	r4, r0
c0d04390:	1a52      	subs	r2, r2, r1
c0d04392:	1e78      	subs	r0, r7, #1
c0d04394:	4187      	sbcs	r7, r0
c0d04396:	4694      	mov	ip, r2
c0d04398:	4334      	orrs	r4, r6
c0d0439a:	4327      	orrs	r7, r4
c0d0439c:	1bdc      	subs	r4, r3, r7
c0d0439e:	42a3      	cmp	r3, r4
c0d043a0:	419b      	sbcs	r3, r3
c0d043a2:	4662      	mov	r2, ip
c0d043a4:	425b      	negs	r3, r3
c0d043a6:	1ad3      	subs	r3, r2, r3
c0d043a8:	4699      	mov	r9, r3
c0d043aa:	464b      	mov	r3, r9
c0d043ac:	021b      	lsls	r3, r3, #8
c0d043ae:	d400      	bmi.n	c0d043b2 <__aeabi_dsub+0xaa>
c0d043b0:	e118      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d043b2:	464b      	mov	r3, r9
c0d043b4:	0258      	lsls	r0, r3, #9
c0d043b6:	0a43      	lsrs	r3, r0, #9
c0d043b8:	4699      	mov	r9, r3
c0d043ba:	464b      	mov	r3, r9
c0d043bc:	2b00      	cmp	r3, #0
c0d043be:	d100      	bne.n	c0d043c2 <__aeabi_dsub+0xba>
c0d043c0:	e137      	b.n	c0d04632 <__aeabi_dsub+0x32a>
c0d043c2:	4648      	mov	r0, r9
c0d043c4:	f000 fbdc 	bl	c0d04b80 <__clzsi2>
c0d043c8:	0001      	movs	r1, r0
c0d043ca:	3908      	subs	r1, #8
c0d043cc:	2320      	movs	r3, #32
c0d043ce:	0022      	movs	r2, r4
c0d043d0:	4648      	mov	r0, r9
c0d043d2:	1a5b      	subs	r3, r3, r1
c0d043d4:	40da      	lsrs	r2, r3
c0d043d6:	4088      	lsls	r0, r1
c0d043d8:	408c      	lsls	r4, r1
c0d043da:	4643      	mov	r3, r8
c0d043dc:	4310      	orrs	r0, r2
c0d043de:	4588      	cmp	r8, r1
c0d043e0:	dd00      	ble.n	c0d043e4 <__aeabi_dsub+0xdc>
c0d043e2:	e136      	b.n	c0d04652 <__aeabi_dsub+0x34a>
c0d043e4:	1ac9      	subs	r1, r1, r3
c0d043e6:	1c4b      	adds	r3, r1, #1
c0d043e8:	2b1f      	cmp	r3, #31
c0d043ea:	dd00      	ble.n	c0d043ee <__aeabi_dsub+0xe6>
c0d043ec:	e0ea      	b.n	c0d045c4 <__aeabi_dsub+0x2bc>
c0d043ee:	2220      	movs	r2, #32
c0d043f0:	0026      	movs	r6, r4
c0d043f2:	1ad2      	subs	r2, r2, r3
c0d043f4:	0001      	movs	r1, r0
c0d043f6:	4094      	lsls	r4, r2
c0d043f8:	40de      	lsrs	r6, r3
c0d043fa:	40d8      	lsrs	r0, r3
c0d043fc:	2300      	movs	r3, #0
c0d043fe:	4091      	lsls	r1, r2
c0d04400:	1e62      	subs	r2, r4, #1
c0d04402:	4194      	sbcs	r4, r2
c0d04404:	4681      	mov	r9, r0
c0d04406:	4698      	mov	r8, r3
c0d04408:	4331      	orrs	r1, r6
c0d0440a:	430c      	orrs	r4, r1
c0d0440c:	0763      	lsls	r3, r4, #29
c0d0440e:	d009      	beq.n	c0d04424 <__aeabi_dsub+0x11c>
c0d04410:	230f      	movs	r3, #15
c0d04412:	4023      	ands	r3, r4
c0d04414:	2b04      	cmp	r3, #4
c0d04416:	d005      	beq.n	c0d04424 <__aeabi_dsub+0x11c>
c0d04418:	1d23      	adds	r3, r4, #4
c0d0441a:	42a3      	cmp	r3, r4
c0d0441c:	41a4      	sbcs	r4, r4
c0d0441e:	4264      	negs	r4, r4
c0d04420:	44a1      	add	r9, r4
c0d04422:	001c      	movs	r4, r3
c0d04424:	464b      	mov	r3, r9
c0d04426:	021b      	lsls	r3, r3, #8
c0d04428:	d400      	bmi.n	c0d0442c <__aeabi_dsub+0x124>
c0d0442a:	e0de      	b.n	c0d045ea <__aeabi_dsub+0x2e2>
c0d0442c:	4641      	mov	r1, r8
c0d0442e:	4b8c      	ldr	r3, [pc, #560]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d04430:	3101      	adds	r1, #1
c0d04432:	4299      	cmp	r1, r3
c0d04434:	d100      	bne.n	c0d04438 <__aeabi_dsub+0x130>
c0d04436:	e0e7      	b.n	c0d04608 <__aeabi_dsub+0x300>
c0d04438:	464b      	mov	r3, r9
c0d0443a:	488a      	ldr	r0, [pc, #552]	; (c0d04664 <__aeabi_dsub+0x35c>)
c0d0443c:	08e4      	lsrs	r4, r4, #3
c0d0443e:	4003      	ands	r3, r0
c0d04440:	0018      	movs	r0, r3
c0d04442:	0549      	lsls	r1, r1, #21
c0d04444:	075b      	lsls	r3, r3, #29
c0d04446:	0240      	lsls	r0, r0, #9
c0d04448:	4323      	orrs	r3, r4
c0d0444a:	0d4a      	lsrs	r2, r1, #21
c0d0444c:	0b04      	lsrs	r4, r0, #12
c0d0444e:	0512      	lsls	r2, r2, #20
c0d04450:	07ed      	lsls	r5, r5, #31
c0d04452:	4322      	orrs	r2, r4
c0d04454:	432a      	orrs	r2, r5
c0d04456:	0018      	movs	r0, r3
c0d04458:	0011      	movs	r1, r2
c0d0445a:	bcf0      	pop	{r4, r5, r6, r7}
c0d0445c:	46bb      	mov	fp, r7
c0d0445e:	46b2      	mov	sl, r6
c0d04460:	46a9      	mov	r9, r5
c0d04462:	46a0      	mov	r8, r4
c0d04464:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
c0d04466:	4642      	mov	r2, r8
c0d04468:	1a12      	subs	r2, r2, r0
c0d0446a:	2a00      	cmp	r2, #0
c0d0446c:	dd52      	ble.n	c0d04514 <__aeabi_dsub+0x20c>
c0d0446e:	2800      	cmp	r0, #0
c0d04470:	d100      	bne.n	c0d04474 <__aeabi_dsub+0x16c>
c0d04472:	e09c      	b.n	c0d045ae <__aeabi_dsub+0x2a6>
c0d04474:	45a0      	cmp	r8, r4
c0d04476:	d100      	bne.n	c0d0447a <__aeabi_dsub+0x172>
c0d04478:	e0ca      	b.n	c0d04610 <__aeabi_dsub+0x308>
c0d0447a:	2080      	movs	r0, #128	; 0x80
c0d0447c:	0400      	lsls	r0, r0, #16
c0d0447e:	4301      	orrs	r1, r0
c0d04480:	2a38      	cmp	r2, #56	; 0x38
c0d04482:	dd00      	ble.n	c0d04486 <__aeabi_dsub+0x17e>
c0d04484:	e149      	b.n	c0d0471a <__aeabi_dsub+0x412>
c0d04486:	2a1f      	cmp	r2, #31
c0d04488:	dc00      	bgt.n	c0d0448c <__aeabi_dsub+0x184>
c0d0448a:	e197      	b.n	c0d047bc <__aeabi_dsub+0x4b4>
c0d0448c:	0010      	movs	r0, r2
c0d0448e:	000e      	movs	r6, r1
c0d04490:	3820      	subs	r0, #32
c0d04492:	40c6      	lsrs	r6, r0
c0d04494:	2a20      	cmp	r2, #32
c0d04496:	d004      	beq.n	c0d044a2 <__aeabi_dsub+0x19a>
c0d04498:	2040      	movs	r0, #64	; 0x40
c0d0449a:	1a82      	subs	r2, r0, r2
c0d0449c:	4091      	lsls	r1, r2
c0d0449e:	430f      	orrs	r7, r1
c0d044a0:	46b9      	mov	r9, r7
c0d044a2:	464c      	mov	r4, r9
c0d044a4:	1e62      	subs	r2, r4, #1
c0d044a6:	4194      	sbcs	r4, r2
c0d044a8:	4334      	orrs	r4, r6
c0d044aa:	e13a      	b.n	c0d04722 <__aeabi_dsub+0x41a>
c0d044ac:	000a      	movs	r2, r1
c0d044ae:	433a      	orrs	r2, r7
c0d044b0:	d028      	beq.n	c0d04504 <__aeabi_dsub+0x1fc>
c0d044b2:	46b3      	mov	fp, r6
c0d044b4:	42b5      	cmp	r5, r6
c0d044b6:	d02b      	beq.n	c0d04510 <__aeabi_dsub+0x208>
c0d044b8:	4a6b      	ldr	r2, [pc, #428]	; (c0d04668 <__aeabi_dsub+0x360>)
c0d044ba:	4442      	add	r2, r8
c0d044bc:	2a00      	cmp	r2, #0
c0d044be:	d05d      	beq.n	c0d0457c <__aeabi_dsub+0x274>
c0d044c0:	4642      	mov	r2, r8
c0d044c2:	4644      	mov	r4, r8
c0d044c4:	1a82      	subs	r2, r0, r2
c0d044c6:	2c00      	cmp	r4, #0
c0d044c8:	d000      	beq.n	c0d044cc <__aeabi_dsub+0x1c4>
c0d044ca:	e0f5      	b.n	c0d046b8 <__aeabi_dsub+0x3b0>
c0d044cc:	4665      	mov	r5, ip
c0d044ce:	431d      	orrs	r5, r3
c0d044d0:	d100      	bne.n	c0d044d4 <__aeabi_dsub+0x1cc>
c0d044d2:	e19c      	b.n	c0d0480e <__aeabi_dsub+0x506>
c0d044d4:	1e55      	subs	r5, r2, #1
c0d044d6:	2a01      	cmp	r2, #1
c0d044d8:	d100      	bne.n	c0d044dc <__aeabi_dsub+0x1d4>
c0d044da:	e1fb      	b.n	c0d048d4 <__aeabi_dsub+0x5cc>
c0d044dc:	4c60      	ldr	r4, [pc, #384]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d044de:	42a2      	cmp	r2, r4
c0d044e0:	d100      	bne.n	c0d044e4 <__aeabi_dsub+0x1dc>
c0d044e2:	e1bd      	b.n	c0d04860 <__aeabi_dsub+0x558>
c0d044e4:	002a      	movs	r2, r5
c0d044e6:	e0f0      	b.n	c0d046ca <__aeabi_dsub+0x3c2>
c0d044e8:	0008      	movs	r0, r1
c0d044ea:	4338      	orrs	r0, r7
c0d044ec:	d100      	bne.n	c0d044f0 <__aeabi_dsub+0x1e8>
c0d044ee:	e0c3      	b.n	c0d04678 <__aeabi_dsub+0x370>
c0d044f0:	1e50      	subs	r0, r2, #1
c0d044f2:	2a01      	cmp	r2, #1
c0d044f4:	d100      	bne.n	c0d044f8 <__aeabi_dsub+0x1f0>
c0d044f6:	e1a8      	b.n	c0d0484a <__aeabi_dsub+0x542>
c0d044f8:	4c59      	ldr	r4, [pc, #356]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d044fa:	42a2      	cmp	r2, r4
c0d044fc:	d100      	bne.n	c0d04500 <__aeabi_dsub+0x1f8>
c0d044fe:	e087      	b.n	c0d04610 <__aeabi_dsub+0x308>
c0d04500:	0002      	movs	r2, r0
c0d04502:	e736      	b.n	c0d04372 <__aeabi_dsub+0x6a>
c0d04504:	2201      	movs	r2, #1
c0d04506:	4056      	eors	r6, r2
c0d04508:	46b3      	mov	fp, r6
c0d0450a:	42b5      	cmp	r5, r6
c0d0450c:	d000      	beq.n	c0d04510 <__aeabi_dsub+0x208>
c0d0450e:	e721      	b.n	c0d04354 <__aeabi_dsub+0x4c>
c0d04510:	4a55      	ldr	r2, [pc, #340]	; (c0d04668 <__aeabi_dsub+0x360>)
c0d04512:	4442      	add	r2, r8
c0d04514:	2a00      	cmp	r2, #0
c0d04516:	d100      	bne.n	c0d0451a <__aeabi_dsub+0x212>
c0d04518:	e0b5      	b.n	c0d04686 <__aeabi_dsub+0x37e>
c0d0451a:	4642      	mov	r2, r8
c0d0451c:	4644      	mov	r4, r8
c0d0451e:	1a82      	subs	r2, r0, r2
c0d04520:	2c00      	cmp	r4, #0
c0d04522:	d100      	bne.n	c0d04526 <__aeabi_dsub+0x21e>
c0d04524:	e138      	b.n	c0d04798 <__aeabi_dsub+0x490>
c0d04526:	4e4e      	ldr	r6, [pc, #312]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d04528:	42b0      	cmp	r0, r6
c0d0452a:	d100      	bne.n	c0d0452e <__aeabi_dsub+0x226>
c0d0452c:	e1de      	b.n	c0d048ec <__aeabi_dsub+0x5e4>
c0d0452e:	2680      	movs	r6, #128	; 0x80
c0d04530:	4664      	mov	r4, ip
c0d04532:	0436      	lsls	r6, r6, #16
c0d04534:	4334      	orrs	r4, r6
c0d04536:	46a4      	mov	ip, r4
c0d04538:	2a38      	cmp	r2, #56	; 0x38
c0d0453a:	dd00      	ble.n	c0d0453e <__aeabi_dsub+0x236>
c0d0453c:	e196      	b.n	c0d0486c <__aeabi_dsub+0x564>
c0d0453e:	2a1f      	cmp	r2, #31
c0d04540:	dd00      	ble.n	c0d04544 <__aeabi_dsub+0x23c>
c0d04542:	e224      	b.n	c0d0498e <__aeabi_dsub+0x686>
c0d04544:	2620      	movs	r6, #32
c0d04546:	1ab4      	subs	r4, r6, r2
c0d04548:	46a2      	mov	sl, r4
c0d0454a:	4664      	mov	r4, ip
c0d0454c:	4656      	mov	r6, sl
c0d0454e:	40b4      	lsls	r4, r6
c0d04550:	46a1      	mov	r9, r4
c0d04552:	001c      	movs	r4, r3
c0d04554:	464e      	mov	r6, r9
c0d04556:	40d4      	lsrs	r4, r2
c0d04558:	4326      	orrs	r6, r4
c0d0455a:	0034      	movs	r4, r6
c0d0455c:	4656      	mov	r6, sl
c0d0455e:	40b3      	lsls	r3, r6
c0d04560:	1e5e      	subs	r6, r3, #1
c0d04562:	41b3      	sbcs	r3, r6
c0d04564:	431c      	orrs	r4, r3
c0d04566:	4663      	mov	r3, ip
c0d04568:	40d3      	lsrs	r3, r2
c0d0456a:	18c9      	adds	r1, r1, r3
c0d0456c:	19e4      	adds	r4, r4, r7
c0d0456e:	42bc      	cmp	r4, r7
c0d04570:	41bf      	sbcs	r7, r7
c0d04572:	427f      	negs	r7, r7
c0d04574:	46b9      	mov	r9, r7
c0d04576:	4680      	mov	r8, r0
c0d04578:	4489      	add	r9, r1
c0d0457a:	e0d8      	b.n	c0d0472e <__aeabi_dsub+0x426>
c0d0457c:	4640      	mov	r0, r8
c0d0457e:	4c3b      	ldr	r4, [pc, #236]	; (c0d0466c <__aeabi_dsub+0x364>)
c0d04580:	3001      	adds	r0, #1
c0d04582:	4220      	tst	r0, r4
c0d04584:	d000      	beq.n	c0d04588 <__aeabi_dsub+0x280>
c0d04586:	e0b4      	b.n	c0d046f2 <__aeabi_dsub+0x3ea>
c0d04588:	4640      	mov	r0, r8
c0d0458a:	2800      	cmp	r0, #0
c0d0458c:	d000      	beq.n	c0d04590 <__aeabi_dsub+0x288>
c0d0458e:	e144      	b.n	c0d0481a <__aeabi_dsub+0x512>
c0d04590:	4660      	mov	r0, ip
c0d04592:	4318      	orrs	r0, r3
c0d04594:	d100      	bne.n	c0d04598 <__aeabi_dsub+0x290>
c0d04596:	e190      	b.n	c0d048ba <__aeabi_dsub+0x5b2>
c0d04598:	0008      	movs	r0, r1
c0d0459a:	4338      	orrs	r0, r7
c0d0459c:	d000      	beq.n	c0d045a0 <__aeabi_dsub+0x298>
c0d0459e:	e1aa      	b.n	c0d048f6 <__aeabi_dsub+0x5ee>
c0d045a0:	4661      	mov	r1, ip
c0d045a2:	08db      	lsrs	r3, r3, #3
c0d045a4:	0749      	lsls	r1, r1, #29
c0d045a6:	430b      	orrs	r3, r1
c0d045a8:	4661      	mov	r1, ip
c0d045aa:	08cc      	lsrs	r4, r1, #3
c0d045ac:	e027      	b.n	c0d045fe <__aeabi_dsub+0x2f6>
c0d045ae:	0008      	movs	r0, r1
c0d045b0:	4338      	orrs	r0, r7
c0d045b2:	d061      	beq.n	c0d04678 <__aeabi_dsub+0x370>
c0d045b4:	1e50      	subs	r0, r2, #1
c0d045b6:	2a01      	cmp	r2, #1
c0d045b8:	d100      	bne.n	c0d045bc <__aeabi_dsub+0x2b4>
c0d045ba:	e139      	b.n	c0d04830 <__aeabi_dsub+0x528>
c0d045bc:	42a2      	cmp	r2, r4
c0d045be:	d027      	beq.n	c0d04610 <__aeabi_dsub+0x308>
c0d045c0:	0002      	movs	r2, r0
c0d045c2:	e75d      	b.n	c0d04480 <__aeabi_dsub+0x178>
c0d045c4:	0002      	movs	r2, r0
c0d045c6:	391f      	subs	r1, #31
c0d045c8:	40ca      	lsrs	r2, r1
c0d045ca:	0011      	movs	r1, r2
c0d045cc:	2b20      	cmp	r3, #32
c0d045ce:	d003      	beq.n	c0d045d8 <__aeabi_dsub+0x2d0>
c0d045d0:	2240      	movs	r2, #64	; 0x40
c0d045d2:	1ad3      	subs	r3, r2, r3
c0d045d4:	4098      	lsls	r0, r3
c0d045d6:	4304      	orrs	r4, r0
c0d045d8:	1e63      	subs	r3, r4, #1
c0d045da:	419c      	sbcs	r4, r3
c0d045dc:	2300      	movs	r3, #0
c0d045de:	4699      	mov	r9, r3
c0d045e0:	4698      	mov	r8, r3
c0d045e2:	430c      	orrs	r4, r1
c0d045e4:	0763      	lsls	r3, r4, #29
c0d045e6:	d000      	beq.n	c0d045ea <__aeabi_dsub+0x2e2>
c0d045e8:	e712      	b.n	c0d04410 <__aeabi_dsub+0x108>
c0d045ea:	464b      	mov	r3, r9
c0d045ec:	464a      	mov	r2, r9
c0d045ee:	08e4      	lsrs	r4, r4, #3
c0d045f0:	075b      	lsls	r3, r3, #29
c0d045f2:	4323      	orrs	r3, r4
c0d045f4:	08d4      	lsrs	r4, r2, #3
c0d045f6:	4642      	mov	r2, r8
c0d045f8:	4919      	ldr	r1, [pc, #100]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d045fa:	428a      	cmp	r2, r1
c0d045fc:	d00e      	beq.n	c0d0461c <__aeabi_dsub+0x314>
c0d045fe:	0324      	lsls	r4, r4, #12
c0d04600:	0552      	lsls	r2, r2, #21
c0d04602:	0b24      	lsrs	r4, r4, #12
c0d04604:	0d52      	lsrs	r2, r2, #21
c0d04606:	e722      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d04608:	000a      	movs	r2, r1
c0d0460a:	2400      	movs	r4, #0
c0d0460c:	2300      	movs	r3, #0
c0d0460e:	e71e      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d04610:	08db      	lsrs	r3, r3, #3
c0d04612:	4662      	mov	r2, ip
c0d04614:	0752      	lsls	r2, r2, #29
c0d04616:	4313      	orrs	r3, r2
c0d04618:	4662      	mov	r2, ip
c0d0461a:	08d4      	lsrs	r4, r2, #3
c0d0461c:	001a      	movs	r2, r3
c0d0461e:	4322      	orrs	r2, r4
c0d04620:	d100      	bne.n	c0d04624 <__aeabi_dsub+0x31c>
c0d04622:	e1fc      	b.n	c0d04a1e <__aeabi_dsub+0x716>
c0d04624:	2280      	movs	r2, #128	; 0x80
c0d04626:	0312      	lsls	r2, r2, #12
c0d04628:	4314      	orrs	r4, r2
c0d0462a:	0324      	lsls	r4, r4, #12
c0d0462c:	4a0c      	ldr	r2, [pc, #48]	; (c0d04660 <__aeabi_dsub+0x358>)
c0d0462e:	0b24      	lsrs	r4, r4, #12
c0d04630:	e70d      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d04632:	0020      	movs	r0, r4
c0d04634:	f000 faa4 	bl	c0d04b80 <__clzsi2>
c0d04638:	0001      	movs	r1, r0
c0d0463a:	3118      	adds	r1, #24
c0d0463c:	291f      	cmp	r1, #31
c0d0463e:	dc00      	bgt.n	c0d04642 <__aeabi_dsub+0x33a>
c0d04640:	e6c4      	b.n	c0d043cc <__aeabi_dsub+0xc4>
c0d04642:	3808      	subs	r0, #8
c0d04644:	4084      	lsls	r4, r0
c0d04646:	4643      	mov	r3, r8
c0d04648:	0020      	movs	r0, r4
c0d0464a:	2400      	movs	r4, #0
c0d0464c:	4588      	cmp	r8, r1
c0d0464e:	dc00      	bgt.n	c0d04652 <__aeabi_dsub+0x34a>
c0d04650:	e6c8      	b.n	c0d043e4 <__aeabi_dsub+0xdc>
c0d04652:	4a04      	ldr	r2, [pc, #16]	; (c0d04664 <__aeabi_dsub+0x35c>)
c0d04654:	1a5b      	subs	r3, r3, r1
c0d04656:	4010      	ands	r0, r2
c0d04658:	4698      	mov	r8, r3
c0d0465a:	4681      	mov	r9, r0
c0d0465c:	e6d6      	b.n	c0d0440c <__aeabi_dsub+0x104>
c0d0465e:	46c0      	nop			; (mov r8, r8)
c0d04660:	000007ff 	.word	0x000007ff
c0d04664:	ff7fffff 	.word	0xff7fffff
c0d04668:	fffff801 	.word	0xfffff801
c0d0466c:	000007fe 	.word	0x000007fe
c0d04670:	430f      	orrs	r7, r1
c0d04672:	1e7a      	subs	r2, r7, #1
c0d04674:	4197      	sbcs	r7, r2
c0d04676:	e691      	b.n	c0d0439c <__aeabi_dsub+0x94>
c0d04678:	4661      	mov	r1, ip
c0d0467a:	08db      	lsrs	r3, r3, #3
c0d0467c:	0749      	lsls	r1, r1, #29
c0d0467e:	430b      	orrs	r3, r1
c0d04680:	4661      	mov	r1, ip
c0d04682:	08cc      	lsrs	r4, r1, #3
c0d04684:	e7b8      	b.n	c0d045f8 <__aeabi_dsub+0x2f0>
c0d04686:	4640      	mov	r0, r8
c0d04688:	4cd3      	ldr	r4, [pc, #844]	; (c0d049d8 <__aeabi_dsub+0x6d0>)
c0d0468a:	3001      	adds	r0, #1
c0d0468c:	4220      	tst	r0, r4
c0d0468e:	d000      	beq.n	c0d04692 <__aeabi_dsub+0x38a>
c0d04690:	e0a2      	b.n	c0d047d8 <__aeabi_dsub+0x4d0>
c0d04692:	4640      	mov	r0, r8
c0d04694:	2800      	cmp	r0, #0
c0d04696:	d000      	beq.n	c0d0469a <__aeabi_dsub+0x392>
c0d04698:	e101      	b.n	c0d0489e <__aeabi_dsub+0x596>
c0d0469a:	4660      	mov	r0, ip
c0d0469c:	4318      	orrs	r0, r3
c0d0469e:	d100      	bne.n	c0d046a2 <__aeabi_dsub+0x39a>
c0d046a0:	e15e      	b.n	c0d04960 <__aeabi_dsub+0x658>
c0d046a2:	0008      	movs	r0, r1
c0d046a4:	4338      	orrs	r0, r7
c0d046a6:	d000      	beq.n	c0d046aa <__aeabi_dsub+0x3a2>
c0d046a8:	e15f      	b.n	c0d0496a <__aeabi_dsub+0x662>
c0d046aa:	4661      	mov	r1, ip
c0d046ac:	08db      	lsrs	r3, r3, #3
c0d046ae:	0749      	lsls	r1, r1, #29
c0d046b0:	430b      	orrs	r3, r1
c0d046b2:	4661      	mov	r1, ip
c0d046b4:	08cc      	lsrs	r4, r1, #3
c0d046b6:	e7a2      	b.n	c0d045fe <__aeabi_dsub+0x2f6>
c0d046b8:	4dc8      	ldr	r5, [pc, #800]	; (c0d049dc <__aeabi_dsub+0x6d4>)
c0d046ba:	42a8      	cmp	r0, r5
c0d046bc:	d100      	bne.n	c0d046c0 <__aeabi_dsub+0x3b8>
c0d046be:	e0cf      	b.n	c0d04860 <__aeabi_dsub+0x558>
c0d046c0:	2580      	movs	r5, #128	; 0x80
c0d046c2:	4664      	mov	r4, ip
c0d046c4:	042d      	lsls	r5, r5, #16
c0d046c6:	432c      	orrs	r4, r5
c0d046c8:	46a4      	mov	ip, r4
c0d046ca:	2a38      	cmp	r2, #56	; 0x38
c0d046cc:	dc56      	bgt.n	c0d0477c <__aeabi_dsub+0x474>
c0d046ce:	2a1f      	cmp	r2, #31
c0d046d0:	dd00      	ble.n	c0d046d4 <__aeabi_dsub+0x3cc>
c0d046d2:	e0d1      	b.n	c0d04878 <__aeabi_dsub+0x570>
c0d046d4:	2520      	movs	r5, #32
c0d046d6:	001e      	movs	r6, r3
c0d046d8:	1aad      	subs	r5, r5, r2
c0d046da:	4664      	mov	r4, ip
c0d046dc:	40ab      	lsls	r3, r5
c0d046de:	40ac      	lsls	r4, r5
c0d046e0:	40d6      	lsrs	r6, r2
c0d046e2:	1e5d      	subs	r5, r3, #1
c0d046e4:	41ab      	sbcs	r3, r5
c0d046e6:	4334      	orrs	r4, r6
c0d046e8:	4323      	orrs	r3, r4
c0d046ea:	4664      	mov	r4, ip
c0d046ec:	40d4      	lsrs	r4, r2
c0d046ee:	1b09      	subs	r1, r1, r4
c0d046f0:	e049      	b.n	c0d04786 <__aeabi_dsub+0x47e>
c0d046f2:	4660      	mov	r0, ip
c0d046f4:	1bdc      	subs	r4, r3, r7
c0d046f6:	1a46      	subs	r6, r0, r1
c0d046f8:	42a3      	cmp	r3, r4
c0d046fa:	4180      	sbcs	r0, r0
c0d046fc:	4240      	negs	r0, r0
c0d046fe:	4681      	mov	r9, r0
c0d04700:	0030      	movs	r0, r6
c0d04702:	464e      	mov	r6, r9
c0d04704:	1b80      	subs	r0, r0, r6
c0d04706:	4681      	mov	r9, r0
c0d04708:	0200      	lsls	r0, r0, #8
c0d0470a:	d476      	bmi.n	c0d047fa <__aeabi_dsub+0x4f2>
c0d0470c:	464b      	mov	r3, r9
c0d0470e:	4323      	orrs	r3, r4
c0d04710:	d000      	beq.n	c0d04714 <__aeabi_dsub+0x40c>
c0d04712:	e652      	b.n	c0d043ba <__aeabi_dsub+0xb2>
c0d04714:	2400      	movs	r4, #0
c0d04716:	2500      	movs	r5, #0
c0d04718:	e771      	b.n	c0d045fe <__aeabi_dsub+0x2f6>
c0d0471a:	4339      	orrs	r1, r7
c0d0471c:	000c      	movs	r4, r1
c0d0471e:	1e62      	subs	r2, r4, #1
c0d04720:	4194      	sbcs	r4, r2
c0d04722:	18e4      	adds	r4, r4, r3
c0d04724:	429c      	cmp	r4, r3
c0d04726:	419b      	sbcs	r3, r3
c0d04728:	425b      	negs	r3, r3
c0d0472a:	4463      	add	r3, ip
c0d0472c:	4699      	mov	r9, r3
c0d0472e:	464b      	mov	r3, r9
c0d04730:	021b      	lsls	r3, r3, #8
c0d04732:	d400      	bmi.n	c0d04736 <__aeabi_dsub+0x42e>
c0d04734:	e756      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d04736:	2301      	movs	r3, #1
c0d04738:	469c      	mov	ip, r3
c0d0473a:	4ba8      	ldr	r3, [pc, #672]	; (c0d049dc <__aeabi_dsub+0x6d4>)
c0d0473c:	44e0      	add	r8, ip
c0d0473e:	4598      	cmp	r8, r3
c0d04740:	d038      	beq.n	c0d047b4 <__aeabi_dsub+0x4ac>
c0d04742:	464b      	mov	r3, r9
c0d04744:	48a6      	ldr	r0, [pc, #664]	; (c0d049e0 <__aeabi_dsub+0x6d8>)
c0d04746:	2201      	movs	r2, #1
c0d04748:	4003      	ands	r3, r0
c0d0474a:	0018      	movs	r0, r3
c0d0474c:	0863      	lsrs	r3, r4, #1
c0d0474e:	4014      	ands	r4, r2
c0d04750:	431c      	orrs	r4, r3
c0d04752:	07c3      	lsls	r3, r0, #31
c0d04754:	431c      	orrs	r4, r3
c0d04756:	0843      	lsrs	r3, r0, #1
c0d04758:	4699      	mov	r9, r3
c0d0475a:	e657      	b.n	c0d0440c <__aeabi_dsub+0x104>
c0d0475c:	0010      	movs	r0, r2
c0d0475e:	000e      	movs	r6, r1
c0d04760:	3820      	subs	r0, #32
c0d04762:	40c6      	lsrs	r6, r0
c0d04764:	2a20      	cmp	r2, #32
c0d04766:	d004      	beq.n	c0d04772 <__aeabi_dsub+0x46a>
c0d04768:	2040      	movs	r0, #64	; 0x40
c0d0476a:	1a82      	subs	r2, r0, r2
c0d0476c:	4091      	lsls	r1, r2
c0d0476e:	430f      	orrs	r7, r1
c0d04770:	46b9      	mov	r9, r7
c0d04772:	464f      	mov	r7, r9
c0d04774:	1e7a      	subs	r2, r7, #1
c0d04776:	4197      	sbcs	r7, r2
c0d04778:	4337      	orrs	r7, r6
c0d0477a:	e60f      	b.n	c0d0439c <__aeabi_dsub+0x94>
c0d0477c:	4662      	mov	r2, ip
c0d0477e:	431a      	orrs	r2, r3
c0d04780:	0013      	movs	r3, r2
c0d04782:	1e5a      	subs	r2, r3, #1
c0d04784:	4193      	sbcs	r3, r2
c0d04786:	1afc      	subs	r4, r7, r3
c0d04788:	42a7      	cmp	r7, r4
c0d0478a:	41bf      	sbcs	r7, r7
c0d0478c:	427f      	negs	r7, r7
c0d0478e:	1bcb      	subs	r3, r1, r7
c0d04790:	4699      	mov	r9, r3
c0d04792:	465d      	mov	r5, fp
c0d04794:	4680      	mov	r8, r0
c0d04796:	e608      	b.n	c0d043aa <__aeabi_dsub+0xa2>
c0d04798:	4666      	mov	r6, ip
c0d0479a:	431e      	orrs	r6, r3
c0d0479c:	d100      	bne.n	c0d047a0 <__aeabi_dsub+0x498>
c0d0479e:	e0be      	b.n	c0d0491e <__aeabi_dsub+0x616>
c0d047a0:	1e56      	subs	r6, r2, #1
c0d047a2:	2a01      	cmp	r2, #1
c0d047a4:	d100      	bne.n	c0d047a8 <__aeabi_dsub+0x4a0>
c0d047a6:	e109      	b.n	c0d049bc <__aeabi_dsub+0x6b4>
c0d047a8:	4c8c      	ldr	r4, [pc, #560]	; (c0d049dc <__aeabi_dsub+0x6d4>)
c0d047aa:	42a2      	cmp	r2, r4
c0d047ac:	d100      	bne.n	c0d047b0 <__aeabi_dsub+0x4a8>
c0d047ae:	e119      	b.n	c0d049e4 <__aeabi_dsub+0x6dc>
c0d047b0:	0032      	movs	r2, r6
c0d047b2:	e6c1      	b.n	c0d04538 <__aeabi_dsub+0x230>
c0d047b4:	4642      	mov	r2, r8
c0d047b6:	2400      	movs	r4, #0
c0d047b8:	2300      	movs	r3, #0
c0d047ba:	e648      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d047bc:	2020      	movs	r0, #32
c0d047be:	000c      	movs	r4, r1
c0d047c0:	1a80      	subs	r0, r0, r2
c0d047c2:	003e      	movs	r6, r7
c0d047c4:	4087      	lsls	r7, r0
c0d047c6:	4084      	lsls	r4, r0
c0d047c8:	40d6      	lsrs	r6, r2
c0d047ca:	1e78      	subs	r0, r7, #1
c0d047cc:	4187      	sbcs	r7, r0
c0d047ce:	40d1      	lsrs	r1, r2
c0d047d0:	4334      	orrs	r4, r6
c0d047d2:	433c      	orrs	r4, r7
c0d047d4:	448c      	add	ip, r1
c0d047d6:	e7a4      	b.n	c0d04722 <__aeabi_dsub+0x41a>
c0d047d8:	4a80      	ldr	r2, [pc, #512]	; (c0d049dc <__aeabi_dsub+0x6d4>)
c0d047da:	4290      	cmp	r0, r2
c0d047dc:	d100      	bne.n	c0d047e0 <__aeabi_dsub+0x4d8>
c0d047de:	e0e9      	b.n	c0d049b4 <__aeabi_dsub+0x6ac>
c0d047e0:	19df      	adds	r7, r3, r7
c0d047e2:	429f      	cmp	r7, r3
c0d047e4:	419b      	sbcs	r3, r3
c0d047e6:	4461      	add	r1, ip
c0d047e8:	425b      	negs	r3, r3
c0d047ea:	18c9      	adds	r1, r1, r3
c0d047ec:	07cc      	lsls	r4, r1, #31
c0d047ee:	087f      	lsrs	r7, r7, #1
c0d047f0:	084b      	lsrs	r3, r1, #1
c0d047f2:	4699      	mov	r9, r3
c0d047f4:	4680      	mov	r8, r0
c0d047f6:	433c      	orrs	r4, r7
c0d047f8:	e6f4      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d047fa:	1afc      	subs	r4, r7, r3
c0d047fc:	42a7      	cmp	r7, r4
c0d047fe:	41bf      	sbcs	r7, r7
c0d04800:	4663      	mov	r3, ip
c0d04802:	427f      	negs	r7, r7
c0d04804:	1ac9      	subs	r1, r1, r3
c0d04806:	1bcb      	subs	r3, r1, r7
c0d04808:	4699      	mov	r9, r3
c0d0480a:	465d      	mov	r5, fp
c0d0480c:	e5d5      	b.n	c0d043ba <__aeabi_dsub+0xb2>
c0d0480e:	08ff      	lsrs	r7, r7, #3
c0d04810:	074b      	lsls	r3, r1, #29
c0d04812:	465d      	mov	r5, fp
c0d04814:	433b      	orrs	r3, r7
c0d04816:	08cc      	lsrs	r4, r1, #3
c0d04818:	e6ee      	b.n	c0d045f8 <__aeabi_dsub+0x2f0>
c0d0481a:	4662      	mov	r2, ip
c0d0481c:	431a      	orrs	r2, r3
c0d0481e:	d000      	beq.n	c0d04822 <__aeabi_dsub+0x51a>
c0d04820:	e082      	b.n	c0d04928 <__aeabi_dsub+0x620>
c0d04822:	000b      	movs	r3, r1
c0d04824:	433b      	orrs	r3, r7
c0d04826:	d11b      	bne.n	c0d04860 <__aeabi_dsub+0x558>
c0d04828:	2480      	movs	r4, #128	; 0x80
c0d0482a:	2500      	movs	r5, #0
c0d0482c:	0324      	lsls	r4, r4, #12
c0d0482e:	e6f9      	b.n	c0d04624 <__aeabi_dsub+0x31c>
c0d04830:	19dc      	adds	r4, r3, r7
c0d04832:	429c      	cmp	r4, r3
c0d04834:	419b      	sbcs	r3, r3
c0d04836:	4461      	add	r1, ip
c0d04838:	4689      	mov	r9, r1
c0d0483a:	425b      	negs	r3, r3
c0d0483c:	4499      	add	r9, r3
c0d0483e:	464b      	mov	r3, r9
c0d04840:	021b      	lsls	r3, r3, #8
c0d04842:	d444      	bmi.n	c0d048ce <__aeabi_dsub+0x5c6>
c0d04844:	2301      	movs	r3, #1
c0d04846:	4698      	mov	r8, r3
c0d04848:	e6cc      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d0484a:	1bdc      	subs	r4, r3, r7
c0d0484c:	4662      	mov	r2, ip
c0d0484e:	42a3      	cmp	r3, r4
c0d04850:	419b      	sbcs	r3, r3
c0d04852:	1a51      	subs	r1, r2, r1
c0d04854:	425b      	negs	r3, r3
c0d04856:	1acb      	subs	r3, r1, r3
c0d04858:	4699      	mov	r9, r3
c0d0485a:	2301      	movs	r3, #1
c0d0485c:	4698      	mov	r8, r3
c0d0485e:	e5a4      	b.n	c0d043aa <__aeabi_dsub+0xa2>
c0d04860:	08ff      	lsrs	r7, r7, #3
c0d04862:	074b      	lsls	r3, r1, #29
c0d04864:	465d      	mov	r5, fp
c0d04866:	433b      	orrs	r3, r7
c0d04868:	08cc      	lsrs	r4, r1, #3
c0d0486a:	e6d7      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d0486c:	4662      	mov	r2, ip
c0d0486e:	431a      	orrs	r2, r3
c0d04870:	0014      	movs	r4, r2
c0d04872:	1e63      	subs	r3, r4, #1
c0d04874:	419c      	sbcs	r4, r3
c0d04876:	e679      	b.n	c0d0456c <__aeabi_dsub+0x264>
c0d04878:	0015      	movs	r5, r2
c0d0487a:	4664      	mov	r4, ip
c0d0487c:	3d20      	subs	r5, #32
c0d0487e:	40ec      	lsrs	r4, r5
c0d04880:	46a0      	mov	r8, r4
c0d04882:	2a20      	cmp	r2, #32
c0d04884:	d005      	beq.n	c0d04892 <__aeabi_dsub+0x58a>
c0d04886:	2540      	movs	r5, #64	; 0x40
c0d04888:	4664      	mov	r4, ip
c0d0488a:	1aaa      	subs	r2, r5, r2
c0d0488c:	4094      	lsls	r4, r2
c0d0488e:	4323      	orrs	r3, r4
c0d04890:	469a      	mov	sl, r3
c0d04892:	4654      	mov	r4, sl
c0d04894:	1e63      	subs	r3, r4, #1
c0d04896:	419c      	sbcs	r4, r3
c0d04898:	4643      	mov	r3, r8
c0d0489a:	4323      	orrs	r3, r4
c0d0489c:	e773      	b.n	c0d04786 <__aeabi_dsub+0x47e>
c0d0489e:	4662      	mov	r2, ip
c0d048a0:	431a      	orrs	r2, r3
c0d048a2:	d023      	beq.n	c0d048ec <__aeabi_dsub+0x5e4>
c0d048a4:	000a      	movs	r2, r1
c0d048a6:	433a      	orrs	r2, r7
c0d048a8:	d000      	beq.n	c0d048ac <__aeabi_dsub+0x5a4>
c0d048aa:	e0a0      	b.n	c0d049ee <__aeabi_dsub+0x6e6>
c0d048ac:	4662      	mov	r2, ip
c0d048ae:	08db      	lsrs	r3, r3, #3
c0d048b0:	0752      	lsls	r2, r2, #29
c0d048b2:	4313      	orrs	r3, r2
c0d048b4:	4662      	mov	r2, ip
c0d048b6:	08d4      	lsrs	r4, r2, #3
c0d048b8:	e6b0      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d048ba:	000b      	movs	r3, r1
c0d048bc:	433b      	orrs	r3, r7
c0d048be:	d100      	bne.n	c0d048c2 <__aeabi_dsub+0x5ba>
c0d048c0:	e728      	b.n	c0d04714 <__aeabi_dsub+0x40c>
c0d048c2:	08ff      	lsrs	r7, r7, #3
c0d048c4:	074b      	lsls	r3, r1, #29
c0d048c6:	465d      	mov	r5, fp
c0d048c8:	433b      	orrs	r3, r7
c0d048ca:	08cc      	lsrs	r4, r1, #3
c0d048cc:	e697      	b.n	c0d045fe <__aeabi_dsub+0x2f6>
c0d048ce:	2302      	movs	r3, #2
c0d048d0:	4698      	mov	r8, r3
c0d048d2:	e736      	b.n	c0d04742 <__aeabi_dsub+0x43a>
c0d048d4:	1afc      	subs	r4, r7, r3
c0d048d6:	42a7      	cmp	r7, r4
c0d048d8:	41bf      	sbcs	r7, r7
c0d048da:	4663      	mov	r3, ip
c0d048dc:	427f      	negs	r7, r7
c0d048de:	1ac9      	subs	r1, r1, r3
c0d048e0:	1bcb      	subs	r3, r1, r7
c0d048e2:	4699      	mov	r9, r3
c0d048e4:	2301      	movs	r3, #1
c0d048e6:	465d      	mov	r5, fp
c0d048e8:	4698      	mov	r8, r3
c0d048ea:	e55e      	b.n	c0d043aa <__aeabi_dsub+0xa2>
c0d048ec:	074b      	lsls	r3, r1, #29
c0d048ee:	08ff      	lsrs	r7, r7, #3
c0d048f0:	433b      	orrs	r3, r7
c0d048f2:	08cc      	lsrs	r4, r1, #3
c0d048f4:	e692      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d048f6:	1bdc      	subs	r4, r3, r7
c0d048f8:	4660      	mov	r0, ip
c0d048fa:	42a3      	cmp	r3, r4
c0d048fc:	41b6      	sbcs	r6, r6
c0d048fe:	1a40      	subs	r0, r0, r1
c0d04900:	4276      	negs	r6, r6
c0d04902:	1b80      	subs	r0, r0, r6
c0d04904:	4681      	mov	r9, r0
c0d04906:	0200      	lsls	r0, r0, #8
c0d04908:	d560      	bpl.n	c0d049cc <__aeabi_dsub+0x6c4>
c0d0490a:	1afc      	subs	r4, r7, r3
c0d0490c:	42a7      	cmp	r7, r4
c0d0490e:	41bf      	sbcs	r7, r7
c0d04910:	4663      	mov	r3, ip
c0d04912:	427f      	negs	r7, r7
c0d04914:	1ac9      	subs	r1, r1, r3
c0d04916:	1bcb      	subs	r3, r1, r7
c0d04918:	4699      	mov	r9, r3
c0d0491a:	465d      	mov	r5, fp
c0d0491c:	e576      	b.n	c0d0440c <__aeabi_dsub+0x104>
c0d0491e:	08ff      	lsrs	r7, r7, #3
c0d04920:	074b      	lsls	r3, r1, #29
c0d04922:	433b      	orrs	r3, r7
c0d04924:	08cc      	lsrs	r4, r1, #3
c0d04926:	e667      	b.n	c0d045f8 <__aeabi_dsub+0x2f0>
c0d04928:	000a      	movs	r2, r1
c0d0492a:	08db      	lsrs	r3, r3, #3
c0d0492c:	433a      	orrs	r2, r7
c0d0492e:	d100      	bne.n	c0d04932 <__aeabi_dsub+0x62a>
c0d04930:	e66f      	b.n	c0d04612 <__aeabi_dsub+0x30a>
c0d04932:	4662      	mov	r2, ip
c0d04934:	0752      	lsls	r2, r2, #29
c0d04936:	4313      	orrs	r3, r2
c0d04938:	4662      	mov	r2, ip
c0d0493a:	08d4      	lsrs	r4, r2, #3
c0d0493c:	2280      	movs	r2, #128	; 0x80
c0d0493e:	0312      	lsls	r2, r2, #12
c0d04940:	4214      	tst	r4, r2
c0d04942:	d007      	beq.n	c0d04954 <__aeabi_dsub+0x64c>
c0d04944:	08c8      	lsrs	r0, r1, #3
c0d04946:	4210      	tst	r0, r2
c0d04948:	d104      	bne.n	c0d04954 <__aeabi_dsub+0x64c>
c0d0494a:	465d      	mov	r5, fp
c0d0494c:	0004      	movs	r4, r0
c0d0494e:	08fb      	lsrs	r3, r7, #3
c0d04950:	0749      	lsls	r1, r1, #29
c0d04952:	430b      	orrs	r3, r1
c0d04954:	0f5a      	lsrs	r2, r3, #29
c0d04956:	00db      	lsls	r3, r3, #3
c0d04958:	08db      	lsrs	r3, r3, #3
c0d0495a:	0752      	lsls	r2, r2, #29
c0d0495c:	4313      	orrs	r3, r2
c0d0495e:	e65d      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d04960:	074b      	lsls	r3, r1, #29
c0d04962:	08ff      	lsrs	r7, r7, #3
c0d04964:	433b      	orrs	r3, r7
c0d04966:	08cc      	lsrs	r4, r1, #3
c0d04968:	e649      	b.n	c0d045fe <__aeabi_dsub+0x2f6>
c0d0496a:	19dc      	adds	r4, r3, r7
c0d0496c:	429c      	cmp	r4, r3
c0d0496e:	419b      	sbcs	r3, r3
c0d04970:	4461      	add	r1, ip
c0d04972:	4689      	mov	r9, r1
c0d04974:	425b      	negs	r3, r3
c0d04976:	4499      	add	r9, r3
c0d04978:	464b      	mov	r3, r9
c0d0497a:	021b      	lsls	r3, r3, #8
c0d0497c:	d400      	bmi.n	c0d04980 <__aeabi_dsub+0x678>
c0d0497e:	e631      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d04980:	464a      	mov	r2, r9
c0d04982:	4b17      	ldr	r3, [pc, #92]	; (c0d049e0 <__aeabi_dsub+0x6d8>)
c0d04984:	401a      	ands	r2, r3
c0d04986:	2301      	movs	r3, #1
c0d04988:	4691      	mov	r9, r2
c0d0498a:	4698      	mov	r8, r3
c0d0498c:	e62a      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d0498e:	0016      	movs	r6, r2
c0d04990:	4664      	mov	r4, ip
c0d04992:	3e20      	subs	r6, #32
c0d04994:	40f4      	lsrs	r4, r6
c0d04996:	46a0      	mov	r8, r4
c0d04998:	2a20      	cmp	r2, #32
c0d0499a:	d005      	beq.n	c0d049a8 <__aeabi_dsub+0x6a0>
c0d0499c:	2640      	movs	r6, #64	; 0x40
c0d0499e:	4664      	mov	r4, ip
c0d049a0:	1ab2      	subs	r2, r6, r2
c0d049a2:	4094      	lsls	r4, r2
c0d049a4:	4323      	orrs	r3, r4
c0d049a6:	469a      	mov	sl, r3
c0d049a8:	4654      	mov	r4, sl
c0d049aa:	1e63      	subs	r3, r4, #1
c0d049ac:	419c      	sbcs	r4, r3
c0d049ae:	4643      	mov	r3, r8
c0d049b0:	431c      	orrs	r4, r3
c0d049b2:	e5db      	b.n	c0d0456c <__aeabi_dsub+0x264>
c0d049b4:	0002      	movs	r2, r0
c0d049b6:	2400      	movs	r4, #0
c0d049b8:	2300      	movs	r3, #0
c0d049ba:	e548      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d049bc:	19dc      	adds	r4, r3, r7
c0d049be:	42bc      	cmp	r4, r7
c0d049c0:	41bf      	sbcs	r7, r7
c0d049c2:	4461      	add	r1, ip
c0d049c4:	4689      	mov	r9, r1
c0d049c6:	427f      	negs	r7, r7
c0d049c8:	44b9      	add	r9, r7
c0d049ca:	e738      	b.n	c0d0483e <__aeabi_dsub+0x536>
c0d049cc:	464b      	mov	r3, r9
c0d049ce:	4323      	orrs	r3, r4
c0d049d0:	d100      	bne.n	c0d049d4 <__aeabi_dsub+0x6cc>
c0d049d2:	e69f      	b.n	c0d04714 <__aeabi_dsub+0x40c>
c0d049d4:	e606      	b.n	c0d045e4 <__aeabi_dsub+0x2dc>
c0d049d6:	46c0      	nop			; (mov r8, r8)
c0d049d8:	000007fe 	.word	0x000007fe
c0d049dc:	000007ff 	.word	0x000007ff
c0d049e0:	ff7fffff 	.word	0xff7fffff
c0d049e4:	08ff      	lsrs	r7, r7, #3
c0d049e6:	074b      	lsls	r3, r1, #29
c0d049e8:	433b      	orrs	r3, r7
c0d049ea:	08cc      	lsrs	r4, r1, #3
c0d049ec:	e616      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d049ee:	4662      	mov	r2, ip
c0d049f0:	08db      	lsrs	r3, r3, #3
c0d049f2:	0752      	lsls	r2, r2, #29
c0d049f4:	4313      	orrs	r3, r2
c0d049f6:	4662      	mov	r2, ip
c0d049f8:	08d4      	lsrs	r4, r2, #3
c0d049fa:	2280      	movs	r2, #128	; 0x80
c0d049fc:	0312      	lsls	r2, r2, #12
c0d049fe:	4214      	tst	r4, r2
c0d04a00:	d007      	beq.n	c0d04a12 <__aeabi_dsub+0x70a>
c0d04a02:	08c8      	lsrs	r0, r1, #3
c0d04a04:	4210      	tst	r0, r2
c0d04a06:	d104      	bne.n	c0d04a12 <__aeabi_dsub+0x70a>
c0d04a08:	465d      	mov	r5, fp
c0d04a0a:	0004      	movs	r4, r0
c0d04a0c:	08fb      	lsrs	r3, r7, #3
c0d04a0e:	0749      	lsls	r1, r1, #29
c0d04a10:	430b      	orrs	r3, r1
c0d04a12:	0f5a      	lsrs	r2, r3, #29
c0d04a14:	00db      	lsls	r3, r3, #3
c0d04a16:	0752      	lsls	r2, r2, #29
c0d04a18:	08db      	lsrs	r3, r3, #3
c0d04a1a:	4313      	orrs	r3, r2
c0d04a1c:	e5fe      	b.n	c0d0461c <__aeabi_dsub+0x314>
c0d04a1e:	2300      	movs	r3, #0
c0d04a20:	4a01      	ldr	r2, [pc, #4]	; (c0d04a28 <__aeabi_dsub+0x720>)
c0d04a22:	001c      	movs	r4, r3
c0d04a24:	e513      	b.n	c0d0444e <__aeabi_dsub+0x146>
c0d04a26:	46c0      	nop			; (mov r8, r8)
c0d04a28:	000007ff 	.word	0x000007ff

c0d04a2c <__aeabi_dcmpun>:
c0d04a2c:	b570      	push	{r4, r5, r6, lr}
c0d04a2e:	0005      	movs	r5, r0
c0d04a30:	480c      	ldr	r0, [pc, #48]	; (c0d04a64 <__aeabi_dcmpun+0x38>)
c0d04a32:	031c      	lsls	r4, r3, #12
c0d04a34:	0016      	movs	r6, r2
c0d04a36:	005b      	lsls	r3, r3, #1
c0d04a38:	030a      	lsls	r2, r1, #12
c0d04a3a:	0049      	lsls	r1, r1, #1
c0d04a3c:	0b12      	lsrs	r2, r2, #12
c0d04a3e:	0d49      	lsrs	r1, r1, #21
c0d04a40:	0b24      	lsrs	r4, r4, #12
c0d04a42:	0d5b      	lsrs	r3, r3, #21
c0d04a44:	4281      	cmp	r1, r0
c0d04a46:	d008      	beq.n	c0d04a5a <__aeabi_dcmpun+0x2e>
c0d04a48:	4a06      	ldr	r2, [pc, #24]	; (c0d04a64 <__aeabi_dcmpun+0x38>)
c0d04a4a:	2000      	movs	r0, #0
c0d04a4c:	4293      	cmp	r3, r2
c0d04a4e:	d103      	bne.n	c0d04a58 <__aeabi_dcmpun+0x2c>
c0d04a50:	0020      	movs	r0, r4
c0d04a52:	4330      	orrs	r0, r6
c0d04a54:	1e43      	subs	r3, r0, #1
c0d04a56:	4198      	sbcs	r0, r3
c0d04a58:	bd70      	pop	{r4, r5, r6, pc}
c0d04a5a:	2001      	movs	r0, #1
c0d04a5c:	432a      	orrs	r2, r5
c0d04a5e:	d1fb      	bne.n	c0d04a58 <__aeabi_dcmpun+0x2c>
c0d04a60:	e7f2      	b.n	c0d04a48 <__aeabi_dcmpun+0x1c>
c0d04a62:	46c0      	nop			; (mov r8, r8)
c0d04a64:	000007ff 	.word	0x000007ff

c0d04a68 <__aeabi_d2iz>:
c0d04a68:	000a      	movs	r2, r1
c0d04a6a:	b530      	push	{r4, r5, lr}
c0d04a6c:	4c13      	ldr	r4, [pc, #76]	; (c0d04abc <__aeabi_d2iz+0x54>)
c0d04a6e:	0053      	lsls	r3, r2, #1
c0d04a70:	0309      	lsls	r1, r1, #12
c0d04a72:	0005      	movs	r5, r0
c0d04a74:	0b09      	lsrs	r1, r1, #12
c0d04a76:	2000      	movs	r0, #0
c0d04a78:	0d5b      	lsrs	r3, r3, #21
c0d04a7a:	0fd2      	lsrs	r2, r2, #31
c0d04a7c:	42a3      	cmp	r3, r4
c0d04a7e:	dd04      	ble.n	c0d04a8a <__aeabi_d2iz+0x22>
c0d04a80:	480f      	ldr	r0, [pc, #60]	; (c0d04ac0 <__aeabi_d2iz+0x58>)
c0d04a82:	4283      	cmp	r3, r0
c0d04a84:	dd02      	ble.n	c0d04a8c <__aeabi_d2iz+0x24>
c0d04a86:	4b0f      	ldr	r3, [pc, #60]	; (c0d04ac4 <__aeabi_d2iz+0x5c>)
c0d04a88:	18d0      	adds	r0, r2, r3
c0d04a8a:	bd30      	pop	{r4, r5, pc}
c0d04a8c:	2080      	movs	r0, #128	; 0x80
c0d04a8e:	0340      	lsls	r0, r0, #13
c0d04a90:	4301      	orrs	r1, r0
c0d04a92:	480d      	ldr	r0, [pc, #52]	; (c0d04ac8 <__aeabi_d2iz+0x60>)
c0d04a94:	1ac0      	subs	r0, r0, r3
c0d04a96:	281f      	cmp	r0, #31
c0d04a98:	dd08      	ble.n	c0d04aac <__aeabi_d2iz+0x44>
c0d04a9a:	480c      	ldr	r0, [pc, #48]	; (c0d04acc <__aeabi_d2iz+0x64>)
c0d04a9c:	1ac3      	subs	r3, r0, r3
c0d04a9e:	40d9      	lsrs	r1, r3
c0d04aa0:	000b      	movs	r3, r1
c0d04aa2:	4258      	negs	r0, r3
c0d04aa4:	2a00      	cmp	r2, #0
c0d04aa6:	d1f0      	bne.n	c0d04a8a <__aeabi_d2iz+0x22>
c0d04aa8:	0018      	movs	r0, r3
c0d04aaa:	e7ee      	b.n	c0d04a8a <__aeabi_d2iz+0x22>
c0d04aac:	4c08      	ldr	r4, [pc, #32]	; (c0d04ad0 <__aeabi_d2iz+0x68>)
c0d04aae:	40c5      	lsrs	r5, r0
c0d04ab0:	46a4      	mov	ip, r4
c0d04ab2:	4463      	add	r3, ip
c0d04ab4:	4099      	lsls	r1, r3
c0d04ab6:	000b      	movs	r3, r1
c0d04ab8:	432b      	orrs	r3, r5
c0d04aba:	e7f2      	b.n	c0d04aa2 <__aeabi_d2iz+0x3a>
c0d04abc:	000003fe 	.word	0x000003fe
c0d04ac0:	0000041d 	.word	0x0000041d
c0d04ac4:	7fffffff 	.word	0x7fffffff
c0d04ac8:	00000433 	.word	0x00000433
c0d04acc:	00000413 	.word	0x00000413
c0d04ad0:	fffffbed 	.word	0xfffffbed

c0d04ad4 <__aeabi_i2d>:
c0d04ad4:	b570      	push	{r4, r5, r6, lr}
c0d04ad6:	2800      	cmp	r0, #0
c0d04ad8:	d016      	beq.n	c0d04b08 <__aeabi_i2d+0x34>
c0d04ada:	17c3      	asrs	r3, r0, #31
c0d04adc:	18c5      	adds	r5, r0, r3
c0d04ade:	405d      	eors	r5, r3
c0d04ae0:	0fc4      	lsrs	r4, r0, #31
c0d04ae2:	0028      	movs	r0, r5
c0d04ae4:	f000 f84c 	bl	c0d04b80 <__clzsi2>
c0d04ae8:	4a11      	ldr	r2, [pc, #68]	; (c0d04b30 <__aeabi_i2d+0x5c>)
c0d04aea:	1a12      	subs	r2, r2, r0
c0d04aec:	280a      	cmp	r0, #10
c0d04aee:	dc16      	bgt.n	c0d04b1e <__aeabi_i2d+0x4a>
c0d04af0:	0003      	movs	r3, r0
c0d04af2:	002e      	movs	r6, r5
c0d04af4:	3315      	adds	r3, #21
c0d04af6:	409e      	lsls	r6, r3
c0d04af8:	230b      	movs	r3, #11
c0d04afa:	1a18      	subs	r0, r3, r0
c0d04afc:	40c5      	lsrs	r5, r0
c0d04afe:	0552      	lsls	r2, r2, #21
c0d04b00:	032d      	lsls	r5, r5, #12
c0d04b02:	0b2d      	lsrs	r5, r5, #12
c0d04b04:	0d53      	lsrs	r3, r2, #21
c0d04b06:	e003      	b.n	c0d04b10 <__aeabi_i2d+0x3c>
c0d04b08:	2400      	movs	r4, #0
c0d04b0a:	2300      	movs	r3, #0
c0d04b0c:	2500      	movs	r5, #0
c0d04b0e:	2600      	movs	r6, #0
c0d04b10:	051b      	lsls	r3, r3, #20
c0d04b12:	432b      	orrs	r3, r5
c0d04b14:	07e4      	lsls	r4, r4, #31
c0d04b16:	4323      	orrs	r3, r4
c0d04b18:	0030      	movs	r0, r6
c0d04b1a:	0019      	movs	r1, r3
c0d04b1c:	bd70      	pop	{r4, r5, r6, pc}
c0d04b1e:	380b      	subs	r0, #11
c0d04b20:	4085      	lsls	r5, r0
c0d04b22:	0552      	lsls	r2, r2, #21
c0d04b24:	032d      	lsls	r5, r5, #12
c0d04b26:	2600      	movs	r6, #0
c0d04b28:	0b2d      	lsrs	r5, r5, #12
c0d04b2a:	0d53      	lsrs	r3, r2, #21
c0d04b2c:	e7f0      	b.n	c0d04b10 <__aeabi_i2d+0x3c>
c0d04b2e:	46c0      	nop			; (mov r8, r8)
c0d04b30:	0000041e 	.word	0x0000041e

c0d04b34 <__aeabi_ui2d>:
c0d04b34:	b510      	push	{r4, lr}
c0d04b36:	1e04      	subs	r4, r0, #0
c0d04b38:	d010      	beq.n	c0d04b5c <__aeabi_ui2d+0x28>
c0d04b3a:	f000 f821 	bl	c0d04b80 <__clzsi2>
c0d04b3e:	4b0f      	ldr	r3, [pc, #60]	; (c0d04b7c <__aeabi_ui2d+0x48>)
c0d04b40:	1a1b      	subs	r3, r3, r0
c0d04b42:	280a      	cmp	r0, #10
c0d04b44:	dc11      	bgt.n	c0d04b6a <__aeabi_ui2d+0x36>
c0d04b46:	220b      	movs	r2, #11
c0d04b48:	0021      	movs	r1, r4
c0d04b4a:	1a12      	subs	r2, r2, r0
c0d04b4c:	40d1      	lsrs	r1, r2
c0d04b4e:	3015      	adds	r0, #21
c0d04b50:	030a      	lsls	r2, r1, #12
c0d04b52:	055b      	lsls	r3, r3, #21
c0d04b54:	4084      	lsls	r4, r0
c0d04b56:	0b12      	lsrs	r2, r2, #12
c0d04b58:	0d5b      	lsrs	r3, r3, #21
c0d04b5a:	e001      	b.n	c0d04b60 <__aeabi_ui2d+0x2c>
c0d04b5c:	2300      	movs	r3, #0
c0d04b5e:	2200      	movs	r2, #0
c0d04b60:	051b      	lsls	r3, r3, #20
c0d04b62:	4313      	orrs	r3, r2
c0d04b64:	0020      	movs	r0, r4
c0d04b66:	0019      	movs	r1, r3
c0d04b68:	bd10      	pop	{r4, pc}
c0d04b6a:	0022      	movs	r2, r4
c0d04b6c:	380b      	subs	r0, #11
c0d04b6e:	4082      	lsls	r2, r0
c0d04b70:	055b      	lsls	r3, r3, #21
c0d04b72:	0312      	lsls	r2, r2, #12
c0d04b74:	2400      	movs	r4, #0
c0d04b76:	0b12      	lsrs	r2, r2, #12
c0d04b78:	0d5b      	lsrs	r3, r3, #21
c0d04b7a:	e7f1      	b.n	c0d04b60 <__aeabi_ui2d+0x2c>
c0d04b7c:	0000041e 	.word	0x0000041e

c0d04b80 <__clzsi2>:
c0d04b80:	211c      	movs	r1, #28
c0d04b82:	2301      	movs	r3, #1
c0d04b84:	041b      	lsls	r3, r3, #16
c0d04b86:	4298      	cmp	r0, r3
c0d04b88:	d301      	bcc.n	c0d04b8e <__clzsi2+0xe>
c0d04b8a:	0c00      	lsrs	r0, r0, #16
c0d04b8c:	3910      	subs	r1, #16
c0d04b8e:	0a1b      	lsrs	r3, r3, #8
c0d04b90:	4298      	cmp	r0, r3
c0d04b92:	d301      	bcc.n	c0d04b98 <__clzsi2+0x18>
c0d04b94:	0a00      	lsrs	r0, r0, #8
c0d04b96:	3908      	subs	r1, #8
c0d04b98:	091b      	lsrs	r3, r3, #4
c0d04b9a:	4298      	cmp	r0, r3
c0d04b9c:	d301      	bcc.n	c0d04ba2 <__clzsi2+0x22>
c0d04b9e:	0900      	lsrs	r0, r0, #4
c0d04ba0:	3904      	subs	r1, #4
c0d04ba2:	a202      	add	r2, pc, #8	; (adr r2, c0d04bac <__clzsi2+0x2c>)
c0d04ba4:	5c10      	ldrb	r0, [r2, r0]
c0d04ba6:	1840      	adds	r0, r0, r1
c0d04ba8:	4770      	bx	lr
c0d04baa:	46c0      	nop			; (mov r8, r8)
c0d04bac:	02020304 	.word	0x02020304
c0d04bb0:	01010101 	.word	0x01010101
	...

c0d04bbc <__clzdi2>:
c0d04bbc:	b510      	push	{r4, lr}
c0d04bbe:	2900      	cmp	r1, #0
c0d04bc0:	d103      	bne.n	c0d04bca <__clzdi2+0xe>
c0d04bc2:	f7ff ffdd 	bl	c0d04b80 <__clzsi2>
c0d04bc6:	3020      	adds	r0, #32
c0d04bc8:	e002      	b.n	c0d04bd0 <__clzdi2+0x14>
c0d04bca:	0008      	movs	r0, r1
c0d04bcc:	f7ff ffd8 	bl	c0d04b80 <__clzsi2>
c0d04bd0:	bd10      	pop	{r4, pc}
c0d04bd2:	46c0      	nop			; (mov r8, r8)

c0d04bd4 <__aeabi_memclr>:
c0d04bd4:	b510      	push	{r4, lr}
c0d04bd6:	2200      	movs	r2, #0
c0d04bd8:	f000 f809 	bl	c0d04bee <__aeabi_memset>
c0d04bdc:	bd10      	pop	{r4, pc}

c0d04bde <__aeabi_memcpy>:
c0d04bde:	b510      	push	{r4, lr}
c0d04be0:	f000 f81a 	bl	c0d04c18 <memcpy>
c0d04be4:	bd10      	pop	{r4, pc}

c0d04be6 <__aeabi_memmove>:
c0d04be6:	b510      	push	{r4, lr}
c0d04be8:	f000 f81f 	bl	c0d04c2a <memmove>
c0d04bec:	bd10      	pop	{r4, pc}

c0d04bee <__aeabi_memset>:
c0d04bee:	000b      	movs	r3, r1
c0d04bf0:	b510      	push	{r4, lr}
c0d04bf2:	0011      	movs	r1, r2
c0d04bf4:	001a      	movs	r2, r3
c0d04bf6:	f000 f82b 	bl	c0d04c50 <memset>
c0d04bfa:	bd10      	pop	{r4, pc}

c0d04bfc <memcmp>:
c0d04bfc:	b530      	push	{r4, r5, lr}
c0d04bfe:	2400      	movs	r4, #0
c0d04c00:	3901      	subs	r1, #1
c0d04c02:	42a2      	cmp	r2, r4
c0d04c04:	d101      	bne.n	c0d04c0a <memcmp+0xe>
c0d04c06:	2000      	movs	r0, #0
c0d04c08:	e005      	b.n	c0d04c16 <memcmp+0x1a>
c0d04c0a:	5d03      	ldrb	r3, [r0, r4]
c0d04c0c:	3401      	adds	r4, #1
c0d04c0e:	5d0d      	ldrb	r5, [r1, r4]
c0d04c10:	42ab      	cmp	r3, r5
c0d04c12:	d0f6      	beq.n	c0d04c02 <memcmp+0x6>
c0d04c14:	1b58      	subs	r0, r3, r5
c0d04c16:	bd30      	pop	{r4, r5, pc}

c0d04c18 <memcpy>:
c0d04c18:	2300      	movs	r3, #0
c0d04c1a:	b510      	push	{r4, lr}
c0d04c1c:	429a      	cmp	r2, r3
c0d04c1e:	d100      	bne.n	c0d04c22 <memcpy+0xa>
c0d04c20:	bd10      	pop	{r4, pc}
c0d04c22:	5ccc      	ldrb	r4, [r1, r3]
c0d04c24:	54c4      	strb	r4, [r0, r3]
c0d04c26:	3301      	adds	r3, #1
c0d04c28:	e7f8      	b.n	c0d04c1c <memcpy+0x4>

c0d04c2a <memmove>:
c0d04c2a:	b510      	push	{r4, lr}
c0d04c2c:	4288      	cmp	r0, r1
c0d04c2e:	d902      	bls.n	c0d04c36 <memmove+0xc>
c0d04c30:	188b      	adds	r3, r1, r2
c0d04c32:	4298      	cmp	r0, r3
c0d04c34:	d303      	bcc.n	c0d04c3e <memmove+0x14>
c0d04c36:	2300      	movs	r3, #0
c0d04c38:	e007      	b.n	c0d04c4a <memmove+0x20>
c0d04c3a:	5c8b      	ldrb	r3, [r1, r2]
c0d04c3c:	5483      	strb	r3, [r0, r2]
c0d04c3e:	3a01      	subs	r2, #1
c0d04c40:	d2fb      	bcs.n	c0d04c3a <memmove+0x10>
c0d04c42:	bd10      	pop	{r4, pc}
c0d04c44:	5ccc      	ldrb	r4, [r1, r3]
c0d04c46:	54c4      	strb	r4, [r0, r3]
c0d04c48:	3301      	adds	r3, #1
c0d04c4a:	429a      	cmp	r2, r3
c0d04c4c:	d1fa      	bne.n	c0d04c44 <memmove+0x1a>
c0d04c4e:	e7f8      	b.n	c0d04c42 <memmove+0x18>

c0d04c50 <memset>:
c0d04c50:	0003      	movs	r3, r0
c0d04c52:	1882      	adds	r2, r0, r2
c0d04c54:	4293      	cmp	r3, r2
c0d04c56:	d100      	bne.n	c0d04c5a <memset+0xa>
c0d04c58:	4770      	bx	lr
c0d04c5a:	7019      	strb	r1, [r3, #0]
c0d04c5c:	3301      	adds	r3, #1
c0d04c5e:	e7f9      	b.n	c0d04c54 <memset+0x4>

c0d04c60 <setjmp>:
c0d04c60:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d04c62:	4641      	mov	r1, r8
c0d04c64:	464a      	mov	r2, r9
c0d04c66:	4653      	mov	r3, sl
c0d04c68:	465c      	mov	r4, fp
c0d04c6a:	466d      	mov	r5, sp
c0d04c6c:	4676      	mov	r6, lr
c0d04c6e:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d04c70:	3828      	subs	r0, #40	; 0x28
c0d04c72:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d04c74:	2000      	movs	r0, #0
c0d04c76:	4770      	bx	lr

c0d04c78 <longjmp>:
c0d04c78:	3010      	adds	r0, #16
c0d04c7a:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d04c7c:	4690      	mov	r8, r2
c0d04c7e:	4699      	mov	r9, r3
c0d04c80:	46a2      	mov	sl, r4
c0d04c82:	46ab      	mov	fp, r5
c0d04c84:	46b5      	mov	sp, r6
c0d04c86:	c808      	ldmia	r0!, {r3}
c0d04c88:	3828      	subs	r0, #40	; 0x28
c0d04c8a:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d04c8c:	1c08      	adds	r0, r1, #0
c0d04c8e:	d100      	bne.n	c0d04c92 <longjmp+0x1a>
c0d04c90:	2001      	movs	r0, #1
c0d04c92:	4718      	bx	r3

c0d04c94 <strlen>:
c0d04c94:	2300      	movs	r3, #0
c0d04c96:	5cc2      	ldrb	r2, [r0, r3]
c0d04c98:	3301      	adds	r3, #1
c0d04c9a:	2a00      	cmp	r2, #0
c0d04c9c:	d1fb      	bne.n	c0d04c96 <strlen+0x2>
c0d04c9e:	1e58      	subs	r0, r3, #1
c0d04ca0:	4770      	bx	lr

c0d04ca2 <strncpy>:
c0d04ca2:	0003      	movs	r3, r0
c0d04ca4:	b530      	push	{r4, r5, lr}
c0d04ca6:	001d      	movs	r5, r3
c0d04ca8:	2a00      	cmp	r2, #0
c0d04caa:	d006      	beq.n	c0d04cba <strncpy+0x18>
c0d04cac:	780c      	ldrb	r4, [r1, #0]
c0d04cae:	3a01      	subs	r2, #1
c0d04cb0:	3301      	adds	r3, #1
c0d04cb2:	702c      	strb	r4, [r5, #0]
c0d04cb4:	3101      	adds	r1, #1
c0d04cb6:	2c00      	cmp	r4, #0
c0d04cb8:	d1f5      	bne.n	c0d04ca6 <strncpy+0x4>
c0d04cba:	2100      	movs	r1, #0
c0d04cbc:	189a      	adds	r2, r3, r2
c0d04cbe:	4293      	cmp	r3, r2
c0d04cc0:	d100      	bne.n	c0d04cc4 <strncpy+0x22>
c0d04cc2:	bd30      	pop	{r4, r5, pc}
c0d04cc4:	7019      	strb	r1, [r3, #0]
c0d04cc6:	3301      	adds	r3, #1
c0d04cc8:	e7f9      	b.n	c0d04cbe <strncpy+0x1c>

c0d04cca <strnlen>:
c0d04cca:	0003      	movs	r3, r0
c0d04ccc:	1841      	adds	r1, r0, r1
c0d04cce:	428b      	cmp	r3, r1
c0d04cd0:	d002      	beq.n	c0d04cd8 <strnlen+0xe>
c0d04cd2:	781a      	ldrb	r2, [r3, #0]
c0d04cd4:	2a00      	cmp	r2, #0
c0d04cd6:	d101      	bne.n	c0d04cdc <strnlen+0x12>
c0d04cd8:	1a18      	subs	r0, r3, r0
c0d04cda:	4770      	bx	lr
c0d04cdc:	3301      	adds	r3, #1
c0d04cde:	e7f6      	b.n	c0d04cce <strnlen+0x4>
c0d04ce0:	c0d03704 	.word	0xc0d03704
c0d04ce4:	c0d036f2 	.word	0xc0d036f2
c0d04ce8:	c0d036d0 	.word	0xc0d036d0
c0d04cec:	c0d036fa 	.word	0xc0d036fa
c0d04cf0:	c0d036d0 	.word	0xc0d036d0
c0d04cf4:	c0d039d2 	.word	0xc0d039d2
c0d04cf8:	c0d036d0 	.word	0xc0d036d0
c0d04cfc:	c0d036fa 	.word	0xc0d036fa
c0d04d00:	c0d036f2 	.word	0xc0d036f2
c0d04d04:	c0d036f2 	.word	0xc0d036f2
c0d04d08:	c0d039d2 	.word	0xc0d039d2
c0d04d0c:	c0d036fa 	.word	0xc0d036fa
c0d04d10:	c0d036bc 	.word	0xc0d036bc
c0d04d14:	c0d036bc 	.word	0xc0d036bc
c0d04d18:	c0d036bc 	.word	0xc0d036bc
c0d04d1c:	c0d03a48 	.word	0xc0d03a48
c0d04d20:	c0d03f12 	.word	0xc0d03f12
c0d04d24:	c0d03ed0 	.word	0xc0d03ed0
c0d04d28:	c0d03ed0 	.word	0xc0d03ed0
c0d04d2c:	c0d03ecc 	.word	0xc0d03ecc
c0d04d30:	c0d03ed6 	.word	0xc0d03ed6
c0d04d34:	c0d03ed6 	.word	0xc0d03ed6
c0d04d38:	c0d041e6 	.word	0xc0d041e6
c0d04d3c:	c0d03ecc 	.word	0xc0d03ecc
c0d04d40:	c0d03ed6 	.word	0xc0d03ed6
c0d04d44:	c0d041e6 	.word	0xc0d041e6
c0d04d48:	c0d03ed6 	.word	0xc0d03ed6
c0d04d4c:	c0d03ecc 	.word	0xc0d03ecc
c0d04d50:	c0d0417a 	.word	0xc0d0417a
c0d04d54:	c0d0417a 	.word	0xc0d0417a
c0d04d58:	c0d0417a 	.word	0xc0d0417a
c0d04d5c:	c0d04250 	.word	0xc0d04250
c0d04d60:	696d6573 	.word	0x696d6573
c0d04d64:	736f682d 	.word	0x736f682d
c0d04d68:	676e6974 	.word	0x676e6974
c0d04d6c:	4700203a 	.word	0x4700203a
c0d04d70:	49524950 	.word	0x49524950
c0d04d74:	6220554f 	.word	0x6220554f
c0d04d78:	73657479 	.word	0x73657479
c0d04d7c:	203a      	.short	0x203a
	...

c0d04d7f <G_HEX>:
c0d04d7f:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
c0d04d8f:	6425 7830                                    %d0x.

c0d04d94 <HEXDIGITS>:
c0d04d94:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
c0d04da4:	4700 4950 4952 554f 4120 4a44 5355 2054     .GPIRIOU ADJUST 
c0d04db4:	4544 2043 4d54 2050 5542 4646 5245 0a3a     DEC TMP BUFFER:.
c0d04dc4:	4700 4950 4952 554f 7320 6372 654c 676e     .GPIRIOU srcLeng
c0d04dd4:	6874 203a 6425 000a 5047 5249 4f49 2055     th: %d..GPIRIOU 
c0d04de4:	6174 6772 7465 654c 676e 6874 203a 6425     targetLength: %d
c0d04df4:	000a 5047 5249 4f49 2055 2121 2121 000a     ..GPIRIOU !!!!..
c0d04e04:	5047 5249 4f49 2055 3131 3131 3131 3131     GPIRIOU 11111111
c0d04e14:	3131 0a31 4700 4950 4952 554f 3220 3232     111..GPIRIOU 222
c0d04e24:	3232 3232 3232 3131 000a 5047 5249 4f49     22222211..GPIRIO
c0d04e34:	2055 6174 6772 7465 203a 7325 000a 5047     U target: %s..GP
c0d04e44:	5249 4f49 2055 6d74 2070 7562 6666 7265     IRIOU tmp buffer
c0d04e54:	203a 7325 000a 5047 5249 4f49 2055 6d61     : %s..GPIRIOU am
c0d04e64:	756f 746e 6c20 6e65 203a 6425 000a 5047     ount len: %d..GP
c0d04e74:	5249 4f49 2055 756f 2074 7562 6666 7265     IRIOU out buffer
c0d04e84:	203a 7325 000a 5047 5249 4f49 2055 756f     : %s..GPIRIOU ou
c0d04e94:	2074 7562 6666 7265 2b20 7420 6369 656b     t buffer + ticke
c0d04ea4:	2072 656c 3a6e 2520 0a73 4700 4950 4952     r len: %s..GPIRI
c0d04eb4:	554f 6f20 7475 6220 6675 6566 2072 6973     OU out buffer si
c0d04ec4:	657a 2d20 7420 6369 656b 5f72 656c 206e     ze - ticker_len 
c0d04ed4:	202d 3a31 2520 0a64 4900 766e 6c61 6469     - 1: %d..Invalid
c0d04ee4:	6320 6e6f 6574 7478 000a 5047 5249 4f49      context..GPIRIO
c0d04ef4:	2055 4157 4e52 4e49 2047 4553 0a54 5000     U WARNING SET..P
c0d04f04:	756c 6967 206e 6170 6172 656d 6574 7372     lugin parameters
c0d04f14:	7320 7274 6375 7574 6572 6920 2073 6962      structure is bi
c0d04f24:	6767 7265 7420 6168 206e 6c61 6f6c 6577     gger than allowe
c0d04f34:	2064 6973 657a 000a 4e49 5449 435f 4e4f     d size..INIT_CON
c0d04f44:	5254 4341 2054 6573 656c 7463 726f 203a     TRACT selector: 
c0d04f54:	7525 000a 694d 7373 6e69 2067 6573 656c     %u..Missing sele
c0d04f64:	7463 726f 6e49 6564 0a78 5000 4f52 4956     ctorIndex..PROVI
c0d04f74:	4544 5020 5241 4d41 5445 5245 202c 6573     DE PARAMETER, se
c0d04f84:	656c 7463 726f 203a 6425 000a 6553 656c     lector: %d..Sele
c0d04f94:	7463 726f 4920 646e 7865 2520 2064 6f6e     ctor Index %d no
c0d04fa4:	2074 7573 7070 726f 6574 0a64 4700 4950     t supported..GPI
c0d04fb4:	4952 554f 6820 6e61 6c64 5f65 6461 5f64     RIOU handle_add_
c0d04fc4:	696c 7571 6469 7469 2079 7465 0a68 6100     liquidity eth..a
c0d04fd4:	7466 7265 000a 6f74 656b 206e 696d 0a6e     fter..token min.
c0d04fe4:	6500 6874 6d20 6e69 000a 6562 656e 0a66     .eth min..benef.
c0d04ff4:	5000 7261 6d61 6e20 746f 7320 7075 6f70     .Param not suppo
c0d05004:	7472 6465 000a 5047 5249 4f49 2055 4f54     rted..GPIRIOU TO
c0d05014:	454b 5f4e 5f42 4441 5244 5345 2053 4f43     KEN_B_ADDRESS CO
c0d05024:	544e 4152 5443 203a 2e25 482a 000a 5047     NTRACT: %.*H..GP
c0d05034:	5249 4f49 2055 4554 5453 5420 4b4f 4e45     IRIOU TEST TOKEN
c0d05044:	4220 4120 4f4d 4e55 3a54 000a 4542 454e      B AMOUNT:..BENE
c0d05054:	4946 4943 5241 3a59 2520 2a2e 0a48 4700     FICIARY: %.*H..G
c0d05064:	4950 4952 554f 6820 6e61 6c64 5f65 6461     PIRIOU handle_ad
c0d05074:	5f64 696c 7571 6469 7469 0a79 4700 4950     d_liquidity..GPI
c0d05084:	4952 554f 4820 4e41 4c44 2045 4f54 454b     RIOU HANDLE TOKE
c0d05094:	204e 2041 4d41 554f 544e 000a 6661 6574     N A AMOUNT..afte
c0d050a4:	2072 0a62 6100 6d20 6e69 000a 2062 696d     r b..a min..b mi
c0d050b4:	0a6e 5400 4b4f 4e45 415f 415f 4444 4552     n..TOKEN_A_ADDRE
c0d050c4:	5353 4320 4e4f 5254 4341 3a54 2520 2a2e     SS CONTRACT: %.*
c0d050d4:	0a48 4700 4950 4952 554f 5420 5345 2054     H..GPIRIOU TEST 
c0d050e4:	4f54 454b 204e 2041 4d41 554f 544e 0a3a     TOKEN A AMOUNT:.
c0d050f4:	4700 4950 4952 554f 5420 4b4f 4e45 415f     .GPIRIOU TOKEN_A
c0d05104:	415f 4444 4552 5353 000a 5047 5249 4f49     _ADDRESS..GPIRIO
c0d05114:	2055 494c 5551 4449 5449 0a59 4700 4950     U LIQUIDITY..GPI
c0d05124:	4952 554f 5420 4b4f 4e45 415f 4d5f 4e49     RIOU TOKEN_A_MIN
c0d05134:	000a 5047 5249 4f49 2055 5445 2048 494d     ..GPIRIOU ETH MI
c0d05144:	0a4e 4700 4950 4952 554f 4220 4e45 4645     N..GPIRIOU BENEF
c0d05154:	4349 4149 5952 000a 5047 5249 4f49 2055     ICIARY..GPIRIOU 
c0d05164:	4544 4c41 4e49 0a45 4700 4950 4952 554f     DEALINE..GPIRIOU
c0d05174:	6d20 6773 3e2d 666f 7366 7465 203a 6425      msg->offset: %d
c0d05184:	000a 5047 5249 4f49 2055 656e 7478 705f     ..GPIRIOU next_p
c0d05194:	7261 6d61 203a 6425 202c 6b73 7069 203a     aram: %d, skip: 
c0d051a4:	6425 000a 5047 5249 4f49 2055 4b53 5049     %d..GPIRIOU SKIP
c0d051b4:	4950 474e 000a 5047 5249 4f49 2055 4150     PING..GPIRIOU PA
c0d051c4:	4854 4c20 4e45 5447 3a48 2520 0a75 4300     TH LENGTH: %u..C
c0d051d4:	5255 4552 544e 5020 5241 4d41 203a 4d41     URRENT PARAM: AM
c0d051e4:	554f 544e 495f 204e 4e49 5449 000a 4d41     OUNT_IN INIT..AM
c0d051f4:	554f 544e 4f20 5455 203a 7325 000a 5543     OUNT OUT: %s..CU
c0d05204:	5252 4e45 2054 4150 4152 3a4d 5020 5441     RRENT PARAM: PAT
c0d05214:	2048 4e49 5449 000a 5047 5249 4f49 2055     H INIT..GPIRIOU 
c0d05224:	4150 4854 5420 5345 3a54 2520 0a64 5000     PATH TEST: %d..P
c0d05234:	5441 2048 666f 7366 7465 203a 6425 000a     ATH offset: %d..
c0d05244:	5543 5252 4e45 2054 4150 4152 3a4d 4220     CURRENT PARAM: B
c0d05254:	4e45 4645 4349 4149 5952 4920 494e 0a54     ENEFICIARY INIT.
c0d05264:	4300 5255 4552 544e 5020 5241 4d41 203a     .CURRENT PARAM: 
c0d05274:	4544 4441 494c 454e 4920 494e 0a54 4300     DEADLINE INIT..C
c0d05284:	5255 4552 544e 5020 5241 4d41 203a 4f54     URRENT PARAM: TO
c0d05294:	454b 5f4e 5f41 4441 5244 5345 0a53 4300     KEN_A_ADDRESS..C
c0d052a4:	5255 4552 544e 5020 5241 4d41 203a 4f54     URRENT PARAM: TO
c0d052b4:	454b 5f4e 5f42 4441 5244 5345 0a53 4300     KEN_B_ADDRESS..C
c0d052c4:	5255 4552 544e 5020 5241 4d41 203a 4d41     URRENT PARAM: AM
c0d052d4:	554f 544e 495f 5f4e 414d 2058 4e49 5449     OUNT_IN_MAX INIT
c0d052e4:	000a 5047 5249 4f49 2055 4d41 554f 544e     ..GPIRIOU AMOUNT
c0d052f4:	4920 204e 414d 3a58 2520 0a73 4300 5255      IN MAX: %s..CUR
c0d05304:	4552 544e 5020 5241 4d41 203a 4d41 554f     RENT PARAM: AMOU
c0d05314:	544e 4f5f 5455 4920 494e 0a54 4700 4950     NT_OUT INIT..GPI
c0d05324:	4952 554f 4120 4f4d 4e55 2054 4641 4554     RIOU AMOUNT AFTE
c0d05334:	2052 4148 444e 454c 4120 000a 6c70 6775     R HANDLE A..plug
c0d05344:	6e69 7020 6f72 6976 6564 7420 6b6f 6e65     in provide token
c0d05354:	203a 7830 7025 202c 7830 7025 000a 203f     : 0x%p, 0x%p..? 
c0d05364:	5700 5445 2048 5500 696e 7773 7061 4100     .WETH .OpenSea.A
c0d05374:	6464 6c20 7169 6975 6964 7974 5200 6d65     dd liquidity.Rem
c0d05384:	766f 2065 696c 7571 6469 7469 0079 7753     ove liquidity.Sw
c0d05394:	7061 7420 6b6f 6e65 0073 6553 656c 7463     ap tokens.Select
c0d053a4:	726f 4920 646e 7865 3a20 6425 6e20 746f     or Index :%d not
c0d053b4:	7320 7075 6f70 7472 6465 000a 5047 5249      supported..GPIR
c0d053c4:	4f49 2055 5854 545f 5059 0a45 4700 4950     IOU TX_TYPE..GPI
c0d053d4:	4952 554f 5720 5241 494e 474e 4120 000a     RIOU WARNING A..
c0d053e4:	5047 5249 4f49 2055 4d41 554f 544e 4120     GPIRIOU AMOUNT A
c0d053f4:	000a 5047 5249 4f49 2055 4157 4e52 4e49     ..GPIRIOU WARNIN
c0d05404:	2047 0a42 4700 4950 4952 554f 4120 4f4d     G B..GPIRIOU AMO
c0d05414:	4e55 2054 0a42 4700 4950 4952 554f 5720     UNT B..GPIRIOU W
c0d05424:	5241 494e 474e 4120 4444 4552 5353 000a     ARNING ADDRESS..
c0d05434:	5047 5249 4f49 2055 414c 5453 5520 0a49     GPIRIOU LAST UI.
c0d05444:	4700 4950 4952 554f 4520 5252 524f 000a     .GPIRIOU ERROR..
c0d05454:	6f74 656b 416e 203a 7325 000a 694c 7571     tokenA: %s..Liqu
c0d05464:	6469 7469 2079 6f50 6c6f 003a 7325 2f20     idity Pool:.%s /
c0d05474:	2520 0073 5445 0048 6f74 656b 426e 203a      %s.ETH.tokenB: 
c0d05484:	7325 000a 7753 7061 003a 7325 6620 726f     %s..Swap:.%s for
c0d05494:	2520 0073 3030 3030 3020 3130 0030 2021      %s.0000 0010.! 
c0d054a4:	6f74 656b 206e 0041 6544 6f70 6973 3a74     token A.Deposit:
c0d054b4:	5200 6d65 766f 3a65 5500 686e 6e61 6c64     .Remove:.Unhandl
c0d054c4:	6465 7320 6c65 6365 6f74 2072 6e49 6564     ed selector Inde
c0d054d4:	3a78 2520 0a64 4700 4950 4952 554f 6d20     x: %d..GPIRIOU m
c0d054e4:	6773 654c 6e65 7467 3a68 2520 0a64 3000     sgLeength: %d..0
c0d054f4:	3030 2030 3031 3030 2100 7420 6b6f 6e65     000 1000.! token
c0d05504:	4220 3000 3130 2030 3030 3030 4e00 746f      B.0010 0000.Not
c0d05514:	7520 6573 2772 2073 6461 7264 7365 0073      user's address.
c0d05524:	6542 656e 6966 6963 7261 3a79 3100 3030     Beneficiary:.100
c0d05534:	2030 3030 3030 4c00 5341 0054               0 0000.LAST.

c0d05540 <UNISWAP_ADD_LIQUIDITY>:
c0d05540:	e3e8 0037                                   ..7.

c0d05544 <UNISWAP_ADD_LIQUIDITY_ETH>:
c0d05544:	05f3 19d7                                   ....

c0d05548 <UNISWAP_REMOVE_LIQUIDITY>:
c0d05548:	a2ba deab                                   ....

c0d0554c <UNISWAP_REMOVE_LIQUIDITY_PERMIT>:
c0d0554c:	9521 5c99                                   !..\

c0d05550 <UNISWAP_REMOVE_LIQUIDITY_ETH>:
c0d05550:	7502 ec1c                                   .u..

c0d05554 <UNISWAP_REMOVE_LIQUIDITY_ETH_PERMIT>:
c0d05554:	d9de 2a38                                   ..8*

c0d05558 <UNISWAP_REMOVE_LIQUIDITY_ETH_FEE>:
c0d05558:	29af eb79                                   .)y.

c0d0555c <UNISWAP_REMOVE_LIQUIDITY_ETH_PERMIT_FEE>:
c0d0555c:	0d5b 8459                                   [.Y.

c0d05560 <UNISWAP_SWAP_ETH_FOR_EXACT_TOKENS>:
c0d05560:	3bfb 41db                                   .;.A

c0d05564 <UNISWAP_SWAP_EXACT_ETH_FOR_TOKENS>:
c0d05564:	f37f b56a                                   ..j.

c0d05568 <UNISWAP_SWAP_EXACT_ETH_FOR_TOKENS_FEE>:
c0d05568:	f9b6 95de                                   ....

c0d0556c <UNISWAP_SWAP_EXACT_TOKENS_FOR_ETH>:
c0d0556c:	cb18 e5af                                   ....

c0d05570 <UNISWAP_SWAP_EXACT_TOKENS_FOR_ETH_FEE>:
c0d05570:	1a79 47c9                                   y..G

c0d05574 <UNISWAP_SWAP_EXACT_TOKENS_FOR_TOKENS>:
c0d05574:	ed38 3917                                   8..9

c0d05578 <UNISWAP_SWAP_EXACT_TOKENS_FOR_TOKENS_FEE>:
c0d05578:	115c 95d7                                   \...

c0d0557c <UNISWAP_SWAP_TOKENS_FOR_EXACT_ETH>:
c0d0557c:	254a 4ad9                                   J%.J

c0d05580 <UNISWAP_SWAP_TOKENS_FOR_EXACT_TOKENS>:
c0d05580:	0388 eedb                                   ....

c0d05584 <OPENSA_SELECTORS>:
c0d05584:	5540 c0d0 5544 c0d0 5548 c0d0 554c c0d0     @U..DU..HU..LU..
c0d05594:	5550 c0d0 5554 c0d0 5558 c0d0 555c c0d0     PU..TU..XU..\U..
c0d055a4:	5560 c0d0 5564 c0d0 5568 c0d0 556c c0d0     `U..dU..hU..lU..
c0d055b4:	5570 c0d0 5574 c0d0 5578 c0d0 557c c0d0     pU..tU..xU..|U..
c0d055c4:	5580 c0d0 756a 7473 6920 3a6e 6d20 7365     .U..just in: mes
c0d055d4:	6173 6567 203a 6425 000a 4e49 5449 4320     sage: %d..INIT C
c0d055e4:	4e4f 5254 4341 0a54 5000 4f52 4956 4544     ONTRACT..PROVIDE
c0d055f4:	5020 5241 4d41 5445 5245 000a 4946 414e      PARAMETER..FINA
c0d05604:	494c 455a 000a 5250 564f 4449 2045 4f54     LIZE..PROVIDE TO
c0d05614:	454b 0a4e 5100 4555 5952 4320 4e4f 5254     KEN..QUERY CONTR
c0d05624:	4341 2054 4449 000a 5551 5245 2059 4f43     ACT ID..QUERY CO
c0d05634:	544e 4152 5443 5520 0a49 5500 686e 6e61     NTRACT UI..Unhan
c0d05644:	6c64 6465 6d20 7365 6173 6567 2520 0a64     dled message %d.
c0d05654:	4500 6874 7265 7565 006d 7865 6563 7470     .Ethereum.except
c0d05664:	6f69 5b6e 6425 3a5d 4c20 3d52 7830 3025     ion[%d]: LR=0x%0
c0d05674:	5838 000a                                   8X..

c0d05678 <g_pcHex_cap>:
c0d05678:	3130 3332 3534 3736 3938 4241 4443 4645     0123456789ABCDEF

c0d05688 <_ftoa.pow10>:
c0d05688:	0000 0000 0000 3ff0 0000 0000 0000 4024     .......?......$@
c0d05698:	0000 0000 0000 4059 0000 0000 4000 408f     ......Y@.....@.@
c0d056a8:	0000 0000 8800 40c3 0000 0000 6a00 40f8     .......@.....j.@
c0d056b8:	0000 0000 8480 412e 0000 0000 12d0 4163     .......A......cA
c0d056c8:	0000 0000 d784 4197 0000 0000 cd65 41cd     .......A....e..A
c0d056d8:	616e 006e 6e66 2d69 6600 696e 002b 6e66     nan.fni-.fni+.fn
c0d056e8:	0069 0000                                   i...

c0d056ec <_etext>:
	...
