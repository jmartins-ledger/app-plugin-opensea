
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    os_lib_call((unsigned int *)&libcall_params);
}

// Weird low-level black magic.
__attribute__((section(".boot"))) int main(int arg0)
{
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
c0d00008:	f000 fa64 	bl	c0d004d4 <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY
    {
        TRY
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f003 fc24 	bl	c0d0385c <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f001 fafe 	bl	c0d0161c <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f001 fab9 	bl	c0d01598 <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f001 fadc 	bl	c0d015e8 <os_sched_exit>
c0d00030:	2001      	movs	r0, #1
c0d00032:	0201      	lsls	r1, r0, #8
        {
            // Low-level black magic. Don't touch.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0)
c0d00034:	2c00      	cmp	r4, #0
c0d00036:	d017      	beq.n	c0d00068 <main+0x68>
            {
                // not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *)arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE`, we can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE)
c0d00038:	6820      	ldr	r0, [r4, #0]
c0d0003a:	31ff      	adds	r1, #255	; 0xff
c0d0003c:	4288      	cmp	r0, r1
c0d0003e:	d002      	beq.n	c0d00046 <main+0x46>
                {
                    dispatch_plugin_calls(args[0], (void *)args[1]);
c0d00040:	6861      	ldr	r1, [r4, #4]
c0d00042:	f000 f9df 	bl	c0d00404 <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f001 fac3 	bl	c0d015d0 <os_lib_end>
            }
        }
        FINALLY
c0d0004a:	f001 fadb 	bl	c0d01604 <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f001 fae1 	bl	c0d0161c <try_context_set>
c0d0005a:	a801      	add	r0, sp, #4
        {
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
    libcall_params[0] = (unsigned int)"Ethereum";
c0d0006c:	4804      	ldr	r0, [pc, #16]	; (c0d00080 <main+0x80>)
c0d0006e:	4478      	add	r0, pc
c0d00070:	900d      	str	r0, [sp, #52]	; 0x34
c0d00072:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *)&libcall_params);
c0d00074:	f001 fa9e 	bl	c0d015b4 <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f000 fa31 	bl	c0d004e0 <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	00003b83 	.word	0x00003b83

c0d00084 <semihosted_printf>:
        "svc      0xab\n" ::"r"(buf)
        : "r0", "r1");
}

// Special printf function using the `debug_write` function.
int semihosted_printf(const char *format, ...) {
c0d00084:	b083      	sub	sp, #12
c0d00086:	b510      	push	{r4, lr}
c0d00088:	b0a3      	sub	sp, #140	; 0x8c
c0d0008a:	4604      	mov	r4, r0
c0d0008c:	a825      	add	r0, sp, #148	; 0x94
c0d0008e:	c00e      	stmia	r0!, {r1, r2, r3}
c0d00090:	ab25      	add	r3, sp, #148	; 0x94
    char buf[128 + 1];

    va_list args;
    va_start(args, format);
c0d00092:	9301      	str	r3, [sp, #4]
c0d00094:	a802      	add	r0, sp, #8
c0d00096:	2180      	movs	r1, #128	; 0x80

    int ret = vsnprintf(buf, sizeof(buf) - 1, format, args);
c0d00098:	4622      	mov	r2, r4
c0d0009a:	f000 fcdf 	bl	c0d00a5c <vsnprintf_>
c0d0009e:	4602      	mov	r2, r0
    asm volatile(
c0d000a0:	4b09      	ldr	r3, [pc, #36]	; (c0d000c8 <semihosted_printf+0x44>)
c0d000a2:	447b      	add	r3, pc
c0d000a4:	2004      	movs	r0, #4
c0d000a6:	0019      	movs	r1, r3
c0d000a8:	dfab      	svc	171	; 0xab

    va_end(args);

    debug_write("semi-hosting: ");
    if (ret > 0) {
c0d000aa:	2a01      	cmp	r2, #1
c0d000ac:	db05      	blt.n	c0d000ba <semihosted_printf+0x36>
c0d000ae:	ab02      	add	r3, sp, #8
c0d000b0:	2000      	movs	r0, #0
        buf[ret] = 0;
c0d000b2:	5498      	strb	r0, [r3, r2]
    asm volatile(
c0d000b4:	2004      	movs	r0, #4
c0d000b6:	0019      	movs	r1, r3
c0d000b8:	dfab      	svc	171	; 0xab
        debug_write(buf);
    }

    return ret;
c0d000ba:	4610      	mov	r0, r2
c0d000bc:	b023      	add	sp, #140	; 0x8c
c0d000be:	bc10      	pop	{r4}
c0d000c0:	bc02      	pop	{r1}
c0d000c2:	b003      	add	sp, #12
c0d000c4:	4708      	bx	r1
c0d000c6:	46c0      	nop			; (mov r8, r8)
c0d000c8:	00003892 	.word	0x00003892

c0d000cc <print_bytes>:
    'f',
};

// %.*H doesn't work with semi-hosted printf, so here's a utility function to print bytes in hex
// format.
void print_bytes(const uint8_t *bytes, uint16_t len) {
c0d000cc:	b570      	push	{r4, r5, r6, lr}
c0d000ce:	b081      	sub	sp, #4
c0d000d0:	460a      	mov	r2, r1
c0d000d2:	4603      	mov	r3, r0
c0d000d4:	4668      	mov	r0, sp
c0d000d6:	2100      	movs	r1, #0
    unsigned char nibble1, nibble2;
    char str[] = {0, 0, 0};
c0d000d8:	7081      	strb	r1, [r0, #2]
c0d000da:	8001      	strh	r1, [r0, #0]
    asm volatile(
c0d000dc:	4c12      	ldr	r4, [pc, #72]	; (c0d00128 <print_bytes+0x5c>)
c0d000de:	447c      	add	r4, pc
c0d000e0:	2004      	movs	r0, #4
c0d000e2:	0021      	movs	r1, r4
c0d000e4:	dfab      	svc	171	; 0xab

    debug_write("GPIRIOU bytes: ");
    for (uint16_t count = 0; count < len; count++) {
c0d000e6:	2a00      	cmp	r2, #0
c0d000e8:	d016      	beq.n	c0d00118 <print_bytes+0x4c>
c0d000ea:	4c10      	ldr	r4, [pc, #64]	; (c0d0012c <print_bytes+0x60>)
c0d000ec:	447c      	add	r4, pc
c0d000ee:	4d10      	ldr	r5, [pc, #64]	; (c0d00130 <print_bytes+0x64>)
c0d000f0:	447d      	add	r5, pc
        nibble1 = (bytes[count] >> 4) & 0xF;
c0d000f2:	7818      	ldrb	r0, [r3, #0]
c0d000f4:	210f      	movs	r1, #15
        nibble2 = bytes[count] & 0xF;
c0d000f6:	4001      	ands	r1, r0
        str[0] = G_HEX[nibble1];
        str[1] = G_HEX[nibble2];
c0d000f8:	5c61      	ldrb	r1, [r4, r1]
c0d000fa:	466e      	mov	r6, sp
c0d000fc:	7071      	strb	r1, [r6, #1]
        nibble1 = (bytes[count] >> 4) & 0xF;
c0d000fe:	0900      	lsrs	r0, r0, #4
        str[0] = G_HEX[nibble1];
c0d00100:	5c20      	ldrb	r0, [r4, r0]
c0d00102:	7030      	strb	r0, [r6, #0]
    asm volatile(
c0d00104:	2004      	movs	r0, #4
c0d00106:	0031      	movs	r1, r6
c0d00108:	dfab      	svc	171	; 0xab
c0d0010a:	2004      	movs	r0, #4
c0d0010c:	0029      	movs	r1, r5
c0d0010e:	dfab      	svc	171	; 0xab
    for (uint16_t count = 0; count < len; count++) {
c0d00110:	1e52      	subs	r2, r2, #1
c0d00112:	1c5b      	adds	r3, r3, #1
c0d00114:	2a00      	cmp	r2, #0
c0d00116:	d1ec      	bne.n	c0d000f2 <print_bytes+0x26>
    asm volatile(
c0d00118:	4a06      	ldr	r2, [pc, #24]	; (c0d00134 <print_bytes+0x68>)
c0d0011a:	447a      	add	r2, pc
c0d0011c:	2004      	movs	r0, #4
c0d0011e:	0011      	movs	r1, r2
c0d00120:	dfab      	svc	171	; 0xab
        debug_write(str);
        debug_write(" ");
    }
    debug_write("\n");
c0d00122:	b001      	add	sp, #4
c0d00124:	bd70      	pop	{r4, r5, r6, pc}
c0d00126:	46c0      	nop			; (mov r8, r8)
c0d00128:	00003865 	.word	0x00003865
c0d0012c:	00003867 	.word	0x00003867
c0d00130:	00003851 	.word	0x00003851
c0d00134:	0000387c 	.word	0x0000387c

c0d00138 <handle_finalize>:
        msg->numScreens++;
    }
}

void handle_finalize(void *parameters)
{
c0d00138:	b510      	push	{r4, lr}
c0d0013a:	4604      	mov	r4, r0
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
c0d0013c:	6880      	ldr	r0, [r0, #8]
c0d0013e:	2294      	movs	r2, #148	; 0x94

    // set generic screen_array
    context->screen_array |= TX_TYPE_UI;
c0d00140:	5c83      	ldrb	r3, [r0, r2]
c0d00142:	2101      	movs	r1, #1
c0d00144:	430b      	orrs	r3, r1
c0d00146:	5483      	strb	r3, [r0, r2]
c0d00148:	3094      	adds	r0, #148	; 0x94
    // context->screen_array |= AMOUNT_TOKEN_A_UI;
    // context->screen_array |= AMOUNT_TOKEN_B_UI;
    // context->screen_array |= ADDRESS_UI;

    if (context->valid)
c0d0014a:	7a02      	ldrb	r2, [r0, #8]
c0d0014c:	2a00      	cmp	r2, #0
c0d0014e:	d005      	beq.n	c0d0015c <handle_finalize+0x24>
c0d00150:	2202      	movs	r2, #2
    {
        msg->uiType = ETH_UI_TYPE_GENERIC;
c0d00152:	7722      	strb	r2, [r4, #28]
        context->plugin_screen_index = TX_TYPE_UI;
c0d00154:	7081      	strb	r1, [r0, #2]
        msg->numScreens = 1;
c0d00156:	7761      	strb	r1, [r4, #29]
c0d00158:	2004      	movs	r0, #4
c0d0015a:	e004      	b.n	c0d00166 <handle_finalize+0x2e>
        //msg->tokenLookup2 = context->token_b_address; // TODO: CHECK THIS
        msg->result = ETH_PLUGIN_RESULT_OK;
    }
    else
    {
        PRINTF("Invalid context\n");
c0d0015c:	4803      	ldr	r0, [pc, #12]	; (c0d0016c <handle_finalize+0x34>)
c0d0015e:	4478      	add	r0, pc
c0d00160:	f7ff ff90 	bl	c0d00084 <semihosted_printf>
c0d00164:	2006      	movs	r0, #6
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
c0d00166:	77a0      	strb	r0, [r4, #30]
    }
c0d00168:	bd10      	pop	{r4, pc}
c0d0016a:	46c0      	nop			; (mov r8, r8)
c0d0016c:	00003805 	.word	0x00003805

c0d00170 <handle_init_contract>:
#include "opensea_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters)
{
c0d00170:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00172:	b083      	sub	sp, #12
c0d00174:	4604      	mov	r4, r0
    PRINTF("GPIRIOU TEST\n");
c0d00176:	483a      	ldr	r0, [pc, #232]	; (c0d00260 <handle_init_contract+0xf0>)
c0d00178:	4478      	add	r0, pc
c0d0017a:	f7ff ff83 	bl	c0d00084 <semihosted_printf>
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
c0d0017e:	7820      	ldrb	r0, [r4, #0]
c0d00180:	2802      	cmp	r0, #2
c0d00182:	d109      	bne.n	c0d00198 <handle_init_contract+0x28>
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    // TODO: this could be removed as this can be checked statically?
    PRINTF("GPIRIOU PROUTAFOND 1\n");
c0d00184:	4837      	ldr	r0, [pc, #220]	; (c0d00264 <handle_init_contract+0xf4>)
c0d00186:	4478      	add	r0, pc
c0d00188:	f7ff ff7c 	bl	c0d00084 <semihosted_printf>
    if (msg->pluginContextLength < sizeof(opensea_parameters_t))
c0d0018c:	6920      	ldr	r0, [r4, #16]
c0d0018e:	289f      	cmp	r0, #159	; 0x9f
c0d00190:	d804      	bhi.n	c0d0019c <handle_init_contract+0x2c>
    {
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0d00192:	4835      	ldr	r0, [pc, #212]	; (c0d00268 <handle_init_contract+0xf8>)
c0d00194:	4478      	add	r0, pc
c0d00196:	e059      	b.n	c0d0024c <handle_init_contract+0xdc>
c0d00198:	2001      	movs	r0, #1
c0d0019a:	e05e      	b.n	c0d0025a <handle_init_contract+0xea>
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
c0d0019c:	68e5      	ldr	r5, [r4, #12]

    PRINTF("GPIRIOU PROUTAFOND 1\n");
c0d0019e:	4833      	ldr	r0, [pc, #204]	; (c0d0026c <handle_init_contract+0xfc>)
c0d001a0:	4478      	add	r0, pc
c0d001a2:	f7ff ff6f 	bl	c0d00084 <semihosted_printf>
c0d001a6:	21a0      	movs	r1, #160	; 0xa0
    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
c0d001a8:	4628      	mov	r0, r5
c0d001aa:	f003 fb43 	bl	c0d03834 <__aeabi_memclr>
c0d001ae:	209c      	movs	r0, #156	; 0x9c
c0d001b0:	2101      	movs	r1, #1
c0d001b2:	9101      	str	r1, [sp, #4]
    // Mark context as valid.
    context->valid = 1;
c0d001b4:	5429      	strb	r1, [r5, r0]
    PRINTF("GPIRIOU PROUTAFOND 2 2\n");
c0d001b6:	482e      	ldr	r0, [pc, #184]	; (c0d00270 <handle_init_contract+0x100>)
c0d001b8:	4478      	add	r0, pc
c0d001ba:	f7ff ff63 	bl	c0d00084 <semihosted_printf>
c0d001be:	359b      	adds	r5, #155	; 0x9b
c0d001c0:	9502      	str	r5, [sp, #8]
c0d001c2:	2600      	movs	r6, #0
c0d001c4:	4d2b      	ldr	r5, [pc, #172]	; (c0d00274 <handle_init_contract+0x104>)
c0d001c6:	447d      	add	r5, pc
c0d001c8:	4f2b      	ldr	r7, [pc, #172]	; (c0d00278 <handle_init_contract+0x108>)
c0d001ca:	447f      	add	r7, pc

    // Look for the index of the selectorIndex passed in by `msg`.
    uint8_t i;
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++)
    {
        PRINTF("LOOKING for selector %d", i);
c0d001cc:	4638      	mov	r0, r7
c0d001ce:	4631      	mov	r1, r6
c0d001d0:	f7ff ff58 	bl	c0d00084 <semihosted_printf>
        if (memcmp((uint8_t *)PIC(OPENSEA_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0)
c0d001d4:	6828      	ldr	r0, [r5, #0]
c0d001d6:	f000 f991 	bl	c0d004fc <pic>
c0d001da:	7801      	ldrb	r1, [r0, #0]
c0d001dc:	7842      	ldrb	r2, [r0, #1]
c0d001de:	0212      	lsls	r2, r2, #8
c0d001e0:	1851      	adds	r1, r2, r1
c0d001e2:	7882      	ldrb	r2, [r0, #2]
c0d001e4:	78c0      	ldrb	r0, [r0, #3]
c0d001e6:	0200      	lsls	r0, r0, #8
c0d001e8:	1880      	adds	r0, r0, r2
c0d001ea:	0400      	lsls	r0, r0, #16
c0d001ec:	1840      	adds	r0, r0, r1
c0d001ee:	6961      	ldr	r1, [r4, #20]
c0d001f0:	780a      	ldrb	r2, [r1, #0]
c0d001f2:	784b      	ldrb	r3, [r1, #1]
c0d001f4:	021b      	lsls	r3, r3, #8
c0d001f6:	189a      	adds	r2, r3, r2
c0d001f8:	788b      	ldrb	r3, [r1, #2]
c0d001fa:	78c9      	ldrb	r1, [r1, #3]
c0d001fc:	0209      	lsls	r1, r1, #8
c0d001fe:	18c9      	adds	r1, r1, r3
c0d00200:	0409      	lsls	r1, r1, #16
c0d00202:	1889      	adds	r1, r1, r2
c0d00204:	4288      	cmp	r0, r1
c0d00206:	d00d      	beq.n	c0d00224 <handle_init_contract+0xb4>
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++)
c0d00208:	1d2d      	adds	r5, r5, #4
c0d0020a:	1c76      	adds	r6, r6, #1
c0d0020c:	2e02      	cmp	r6, #2
c0d0020e:	d1dd      	bne.n	c0d001cc <handle_init_contract+0x5c>
        {
            context->selectorIndex = i;
            break;
        }
    }
    PRINTF("GPIRIOU PROUTAFOND 3\n");
c0d00210:	481b      	ldr	r0, [pc, #108]	; (c0d00280 <handle_init_contract+0x110>)
c0d00212:	4478      	add	r0, pc
c0d00214:	f7ff ff36 	bl	c0d00084 <semihosted_printf>
c0d00218:	2000      	movs	r0, #0
c0d0021a:	9d02      	ldr	r5, [sp, #8]

    // If `i == NUM_UNISWAP_SELECTOR` it means we haven't found the selector. Return an error.
    if (i == NUM_OPENSEA_SELECTORS)
    {
        context->valid = 0;
c0d0021c:	7068      	strb	r0, [r5, #1]
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
c0d0021e:	9801      	ldr	r0, [sp, #4]
c0d00220:	7060      	strb	r0, [r4, #1]
c0d00222:	e005      	b.n	c0d00230 <handle_init_contract+0xc0>
c0d00224:	9d02      	ldr	r5, [sp, #8]
            context->selectorIndex = i;
c0d00226:	712e      	strb	r6, [r5, #4]
    PRINTF("GPIRIOU PROUTAFOND 3\n");
c0d00228:	4814      	ldr	r0, [pc, #80]	; (c0d0027c <handle_init_contract+0x10c>)
c0d0022a:	4478      	add	r0, pc
c0d0022c:	f7ff ff2a 	bl	c0d00084 <semihosted_printf>
    }

    PRINTF("GPIRIOU PROUTAFOND 4\n");
c0d00230:	4814      	ldr	r0, [pc, #80]	; (c0d00284 <handle_init_contract+0x114>)
c0d00232:	4478      	add	r0, pc
c0d00234:	f7ff ff26 	bl	c0d00084 <semihosted_printf>
    // Set `next_param` to be the first field we expect to parse.
    PRINTF("INIT_CONTRACT selector: %u\n", context->selectorIndex);
c0d00238:	7929      	ldrb	r1, [r5, #4]
c0d0023a:	4813      	ldr	r0, [pc, #76]	; (c0d00288 <handle_init_contract+0x118>)
c0d0023c:	4478      	add	r0, pc
c0d0023e:	f7ff ff21 	bl	c0d00084 <semihosted_printf>
    switch (context->selectorIndex)
c0d00242:	7928      	ldrb	r0, [r5, #4]
c0d00244:	2800      	cmp	r0, #0
c0d00246:	d005      	beq.n	c0d00254 <handle_init_contract+0xe4>
    // case SWAP_TOKENS_FOR_EXACT_ETH:
    // case SWAP_TOKENS_FOR_EXACT_TOKENS:
    // context->next_param = AMOUNT_OUT;
    // break;
    default:
        PRINTF("Missing selectorIndex\n");
c0d00248:	4810      	ldr	r0, [pc, #64]	; (c0d0028c <handle_init_contract+0x11c>)
c0d0024a:	4478      	add	r0, pc
c0d0024c:	f7ff ff1a 	bl	c0d00084 <semihosted_printf>
c0d00250:	2000      	movs	r0, #0
c0d00252:	e002      	b.n	c0d0025a <handle_init_contract+0xea>
c0d00254:	2002      	movs	r0, #2
        context->next_param = NONE;
c0d00256:	7028      	strb	r0, [r5, #0]
c0d00258:	2004      	movs	r0, #4
c0d0025a:	7060      	strb	r0, [r4, #1]
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d0025c:	b003      	add	sp, #12
c0d0025e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00260:	000037fc 	.word	0x000037fc
c0d00264:	000037fc 	.word	0x000037fc
c0d00268:	00003804 	.word	0x00003804
c0d0026c:	000037e2 	.word	0x000037e2
c0d00270:	00003819 	.word	0x00003819
c0d00274:	0000398e 	.word	0x0000398e
c0d00278:	0000381f 	.word	0x0000381f
c0d0027c:	000037d7 	.word	0x000037d7
c0d00280:	000037ef 	.word	0x000037ef
c0d00284:	000037e5 	.word	0x000037e5
c0d00288:	000037f1 	.word	0x000037f1
c0d0028c:	000037ff 	.word	0x000037ff

c0d00290 <handle_provide_parameter>:
        break;
    }
}

void handle_provide_parameter(void *parameters)
{
c0d00290:	b570      	push	{r4, r5, r6, lr}
c0d00292:	4604      	mov	r4, r0
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
c0d00294:	6885      	ldr	r5, [r0, #8]
c0d00296:	269f      	movs	r6, #159	; 0x9f
    PRINTF("PROVIDE PARAMETER, selector: %d\n", context->selectorIndex);
c0d00298:	5da9      	ldrb	r1, [r5, r6]
c0d0029a:	480a      	ldr	r0, [pc, #40]	; (c0d002c4 <handle_provide_parameter+0x34>)
c0d0029c:	4478      	add	r0, pc
c0d0029e:	f7ff fef1 	bl	c0d00084 <semihosted_printf>
c0d002a2:	2004      	movs	r0, #4

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d002a4:	7520      	strb	r0, [r4, #20]

    switch (context->selectorIndex)
c0d002a6:	5da9      	ldrb	r1, [r5, r6]
c0d002a8:	2900      	cmp	r1, #0
c0d002aa:	d004      	beq.n	c0d002b6 <handle_provide_parameter+0x26>
    {
    case APPROVE_PROXY:
        handle_approve_proxy(msg, context);
        break;
    default:
        PRINTF("Selector Index %d not supported\n", context->selectorIndex);
c0d002ac:	4807      	ldr	r0, [pc, #28]	; (c0d002cc <handle_provide_parameter+0x3c>)
c0d002ae:	4478      	add	r0, pc
c0d002b0:	f7ff fee8 	bl	c0d00084 <semihosted_printf>
c0d002b4:	e003      	b.n	c0d002be <handle_provide_parameter+0x2e>
        PRINTF("Param not supported\n");
c0d002b6:	4804      	ldr	r0, [pc, #16]	; (c0d002c8 <handle_provide_parameter+0x38>)
c0d002b8:	4478      	add	r0, pc
c0d002ba:	f7ff fee3 	bl	c0d00084 <semihosted_printf>
c0d002be:	2000      	movs	r0, #0
c0d002c0:	7520      	strb	r0, [r4, #20]
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
c0d002c2:	bd70      	pop	{r4, r5, r6, pc}
c0d002c4:	000037c4 	.word	0x000037c4
c0d002c8:	000037ea 	.word	0x000037ea
c0d002cc:	000037d3 	.word	0x000037d3

c0d002d0 <handle_provide_token>:
#include "opensea_plugin.h"

void handle_provide_token(void *parameters)
{
c0d002d0:	b510      	push	{r4, lr}
c0d002d2:	4604      	mov	r4, r0
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
    PRINTF("plugin provide token: 0x%p, 0x%p\n", msg->token1, msg->token2);
c0d002d4:	68c1      	ldr	r1, [r0, #12]
c0d002d6:	6902      	ldr	r2, [r0, #16]
c0d002d8:	4803      	ldr	r0, [pc, #12]	; (c0d002e8 <handle_provide_token+0x18>)
c0d002da:	4478      	add	r0, pc
c0d002dc:	f7ff fed2 	bl	c0d00084 <semihosted_printf>
c0d002e0:	2004      	movs	r0, #4
c0d002e2:	7560      	strb	r0, [r4, #21]
    //    context->screen_array |= WARNING_TOKEN_B_UI;
    //    msg->additionalScreens++;
    //}

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d002e4:	bd10      	pop	{r4, pc}
c0d002e6:	46c0      	nop			; (mov r8, r8)
c0d002e8:	000037dd 	.word	0x000037dd

c0d002ec <handle_query_contract_id>:
#include "opensea_plugin.h"

void handle_query_contract_id(void *parameters)
{
c0d002ec:	b5b0      	push	{r4, r5, r7, lr}
c0d002ee:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
c0d002f0:	6885      	ldr	r5, [r0, #8]

    // set 'OpenSea' title.
    strncpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d002f2:	68c0      	ldr	r0, [r0, #12]
c0d002f4:	6922      	ldr	r2, [r4, #16]
c0d002f6:	490b      	ldr	r1, [pc, #44]	; (c0d00324 <handle_query_contract_id+0x38>)
c0d002f8:	4479      	add	r1, pc
c0d002fa:	f003 fac9 	bl	c0d03890 <strncpy>
c0d002fe:	209f      	movs	r0, #159	; 0x9f

    switch (context->selectorIndex)
c0d00300:	5c29      	ldrb	r1, [r5, r0]
c0d00302:	2900      	cmp	r1, #0
c0d00304:	d005      	beq.n	c0d00312 <handle_query_contract_id+0x26>
    {
    case APPROVE_PROXY:
        strncpy(msg->version, "Unlock wallet", msg->versionLength);
        break;
    default:
        PRINTF("Selector Index :%d not supported\n", context->selectorIndex);
c0d00306:	4809      	ldr	r0, [pc, #36]	; (c0d0032c <handle_query_contract_id+0x40>)
c0d00308:	4478      	add	r0, pc
c0d0030a:	f7ff febb 	bl	c0d00084 <semihosted_printf>
c0d0030e:	2000      	movs	r0, #0
c0d00310:	e006      	b.n	c0d00320 <handle_query_contract_id+0x34>
        strncpy(msg->version, "Unlock wallet", msg->versionLength);
c0d00312:	6960      	ldr	r0, [r4, #20]
c0d00314:	69a2      	ldr	r2, [r4, #24]
c0d00316:	4904      	ldr	r1, [pc, #16]	; (c0d00328 <handle_query_contract_id+0x3c>)
c0d00318:	4479      	add	r1, pc
c0d0031a:	f003 fab9 	bl	c0d03890 <strncpy>
c0d0031e:	2004      	movs	r0, #4
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d00320:	7720      	strb	r0, [r4, #28]
c0d00322:	bdb0      	pop	{r4, r5, r7, pc}
c0d00324:	000037e1 	.word	0x000037e1
c0d00328:	000037c9 	.word	0x000037c9
c0d0032c:	000037e7 	.word	0x000037e7

c0d00330 <handle_query_contract_ui>:
        context->plugin_screen_index >>= 1;
    }
}

void handle_query_contract_ui(void *parameters)
{
c0d00330:	b5b0      	push	{r4, r5, r7, lr}
c0d00332:	4604      	mov	r4, r0
    if (msg->screenIndex == 0)
c0d00334:	7b01      	ldrb	r1, [r0, #12]
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
c0d00336:	6885      	ldr	r5, [r0, #8]
c0d00338:	3594      	adds	r5, #148	; 0x94
    if (msg->screenIndex == 0)
c0d0033a:	2900      	cmp	r1, #0
c0d0033c:	d009      	beq.n	c0d00352 <handle_query_contract_ui+0x22>
    if (msg->screenIndex == context->previous_screen_index)
c0d0033e:	786a      	ldrb	r2, [r5, #1]
c0d00340:	4291      	cmp	r1, r2
c0d00342:	d10a      	bne.n	c0d0035a <handle_query_contract_ui+0x2a>
c0d00344:	2080      	movs	r0, #128	; 0x80
        context->plugin_screen_index = LAST_UI;
c0d00346:	70a8      	strb	r0, [r5, #2]
        if (context->screen_array & LAST_UI)
c0d00348:	7828      	ldrb	r0, [r5, #0]
c0d0034a:	b240      	sxtb	r0, r0
c0d0034c:	2800      	cmp	r0, #0
c0d0034e:	d505      	bpl.n	c0d0035c <handle_query_contract_ui+0x2c>
c0d00350:	e024      	b.n	c0d0039c <handle_query_contract_ui+0x6c>
c0d00352:	2000      	movs	r0, #0
        context->previous_screen_index = 0;
c0d00354:	7068      	strb	r0, [r5, #1]
c0d00356:	2001      	movs	r0, #1
c0d00358:	e01f      	b.n	c0d0039a <handle_query_contract_ui+0x6a>
c0d0035a:	7828      	ldrb	r0, [r5, #0]
    context->previous_screen_index = msg->screenIndex;
c0d0035c:	7069      	strb	r1, [r5, #1]
    if (screen_index > previous_screen_index || screen_index == 0)
c0d0035e:	1e49      	subs	r1, r1, #1
c0d00360:	b2c9      	uxtb	r1, r1
    if (scroll_direction == RIGHT_SCROLL)
c0d00362:	4291      	cmp	r1, r2
c0d00364:	d20b      	bcs.n	c0d0037e <handle_query_contract_ui+0x4e>
    while (!(context->screen_array & context->plugin_screen_index >> 1))
c0d00366:	78a9      	ldrb	r1, [r5, #2]
c0d00368:	0849      	lsrs	r1, r1, #1
c0d0036a:	4201      	tst	r1, r0
c0d0036c:	d105      	bne.n	c0d0037a <handle_query_contract_ui+0x4a>
c0d0036e:	460a      	mov	r2, r1
c0d00370:	0609      	lsls	r1, r1, #24
c0d00372:	0e49      	lsrs	r1, r1, #25
c0d00374:	4201      	tst	r1, r0
c0d00376:	d0fa      	beq.n	c0d0036e <handle_query_contract_ui+0x3e>
        context->plugin_screen_index >>= 1;
c0d00378:	70aa      	strb	r2, [r5, #2]
        context->plugin_screen_index >>= 1;
c0d0037a:	70a9      	strb	r1, [r5, #2]
c0d0037c:	e00e      	b.n	c0d0039c <handle_query_contract_ui+0x6c>
    while (!(context->screen_array & context->plugin_screen_index << 1))
c0d0037e:	b2c1      	uxtb	r1, r0
c0d00380:	78a8      	ldrb	r0, [r5, #2]
c0d00382:	0042      	lsls	r2, r0, #1
c0d00384:	420a      	tst	r2, r1
c0d00386:	d107      	bne.n	c0d00398 <handle_query_contract_ui+0x68>
c0d00388:	4610      	mov	r0, r2
c0d0038a:	227f      	movs	r2, #127	; 0x7f
c0d0038c:	0092      	lsls	r2, r2, #2
c0d0038e:	0043      	lsls	r3, r0, #1
c0d00390:	401a      	ands	r2, r3
c0d00392:	420b      	tst	r3, r1
c0d00394:	d0f8      	beq.n	c0d00388 <handle_query_contract_ui+0x58>
        context->plugin_screen_index <<= 1;
c0d00396:	70a8      	strb	r0, [r5, #2]
        context->plugin_screen_index <<= 1;
c0d00398:	0040      	lsls	r0, r0, #1
c0d0039a:	70a8      	strb	r0, [r5, #2]

    get_screen_array(msg, context);
    print_bytes(&context->plugin_screen_index, 1);
c0d0039c:	1ca8      	adds	r0, r5, #2
c0d0039e:	2101      	movs	r1, #1
c0d003a0:	f7ff fe94 	bl	c0d000cc <print_bytes>
    memset(msg->title, 0, msg->titleLength);
c0d003a4:	6920      	ldr	r0, [r4, #16]
c0d003a6:	6961      	ldr	r1, [r4, #20]
c0d003a8:	f003 fa44 	bl	c0d03834 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d003ac:	69a0      	ldr	r0, [r4, #24]
c0d003ae:	69e1      	ldr	r1, [r4, #28]
c0d003b0:	f003 fa40 	bl	c0d03834 <__aeabi_memclr>
c0d003b4:	2020      	movs	r0, #32
c0d003b6:	2104      	movs	r1, #4
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d003b8:	5421      	strb	r1, [r4, r0]
    switch (context->plugin_screen_index)
c0d003ba:	78a8      	ldrb	r0, [r5, #2]
c0d003bc:	2801      	cmp	r0, #1
c0d003be:	d107      	bne.n	c0d003d0 <handle_query_contract_ui+0xa0>
    {
    case TX_TYPE_UI:
        PRINTF("GPIRIOU TX_TYPE\n");
c0d003c0:	480c      	ldr	r0, [pc, #48]	; (c0d003f4 <handle_query_contract_ui+0xc4>)
c0d003c2:	4478      	add	r0, pc
c0d003c4:	f7ff fe5e 	bl	c0d00084 <semihosted_printf>
    switch (context->selectorIndex)
c0d003c8:	7ae8      	ldrb	r0, [r5, #11]
c0d003ca:	2800      	cmp	r0, #0
c0d003cc:	d005      	beq.n	c0d003da <handle_query_contract_ui+0xaa>
    //    break;
    default:
        PRINTF("GPIRIOU ERROR\n");
        break;
    }
c0d003ce:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("GPIRIOU ERROR\n");
c0d003d0:	480b      	ldr	r0, [pc, #44]	; (c0d00400 <handle_query_contract_ui+0xd0>)
c0d003d2:	4478      	add	r0, pc
c0d003d4:	f7ff fe56 	bl	c0d00084 <semihosted_printf>
c0d003d8:	bdb0      	pop	{r4, r5, r7, pc}
        strncpy(msg->title, "Unlock wallet", msg->titleLength);
c0d003da:	6920      	ldr	r0, [r4, #16]
c0d003dc:	6962      	ldr	r2, [r4, #20]
c0d003de:	4906      	ldr	r1, [pc, #24]	; (c0d003f8 <handle_query_contract_ui+0xc8>)
c0d003e0:	4479      	add	r1, pc
c0d003e2:	f003 fa55 	bl	c0d03890 <strncpy>
        strncpy(msg->msg, "Sign to unlock wallet ?", msg->msgLength);
c0d003e6:	69a0      	ldr	r0, [r4, #24]
c0d003e8:	69e2      	ldr	r2, [r4, #28]
c0d003ea:	4904      	ldr	r1, [pc, #16]	; (c0d003fc <handle_query_contract_ui+0xcc>)
c0d003ec:	4479      	add	r1, pc
c0d003ee:	f003 fa4f 	bl	c0d03890 <strncpy>
c0d003f2:	bdb0      	pop	{r4, r5, r7, pc}
c0d003f4:	0000374f 	.word	0x0000374f
c0d003f8:	00003701 	.word	0x00003701
c0d003fc:	00003745 	.word	0x00003745
c0d00400:	00003750 	.word	0x00003750

c0d00404 <dispatch_plugin_calls>:
{
c0d00404:	b5b0      	push	{r4, r5, r7, lr}
c0d00406:	460c      	mov	r4, r1
c0d00408:	4605      	mov	r5, r0
    PRINTF("just in: message: %d\n", message);
c0d0040a:	482a      	ldr	r0, [pc, #168]	; (c0d004b4 <dispatch_plugin_calls+0xb0>)
c0d0040c:	4478      	add	r0, pc
c0d0040e:	4629      	mov	r1, r5
c0d00410:	f7ff fe38 	bl	c0d00084 <semihosted_printf>
c0d00414:	20ff      	movs	r0, #255	; 0xff
c0d00416:	4601      	mov	r1, r0
c0d00418:	3104      	adds	r1, #4
    switch (message)
c0d0041a:	428d      	cmp	r5, r1
c0d0041c:	dc10      	bgt.n	c0d00440 <dispatch_plugin_calls+0x3c>
c0d0041e:	3002      	adds	r0, #2
c0d00420:	4285      	cmp	r5, r0
c0d00422:	d020      	beq.n	c0d00466 <dispatch_plugin_calls+0x62>
c0d00424:	2081      	movs	r0, #129	; 0x81
c0d00426:	0040      	lsls	r0, r0, #1
c0d00428:	4285      	cmp	r5, r0
c0d0042a:	d024      	beq.n	c0d00476 <dispatch_plugin_calls+0x72>
c0d0042c:	428d      	cmp	r5, r1
c0d0042e:	d13a      	bne.n	c0d004a6 <dispatch_plugin_calls+0xa2>
        PRINTF("FINALIZE\n");
c0d00430:	4821      	ldr	r0, [pc, #132]	; (c0d004b8 <dispatch_plugin_calls+0xb4>)
c0d00432:	4478      	add	r0, pc
c0d00434:	f7ff fe26 	bl	c0d00084 <semihosted_printf>
        handle_finalize(parameters);
c0d00438:	4620      	mov	r0, r4
c0d0043a:	f7ff fe7d 	bl	c0d00138 <handle_finalize>
}
c0d0043e:	bdb0      	pop	{r4, r5, r7, pc}
c0d00440:	2141      	movs	r1, #65	; 0x41
c0d00442:	0089      	lsls	r1, r1, #2
    switch (message)
c0d00444:	428d      	cmp	r5, r1
c0d00446:	d01e      	beq.n	c0d00486 <dispatch_plugin_calls+0x82>
c0d00448:	3006      	adds	r0, #6
c0d0044a:	4285      	cmp	r5, r0
c0d0044c:	d023      	beq.n	c0d00496 <dispatch_plugin_calls+0x92>
c0d0044e:	2083      	movs	r0, #131	; 0x83
c0d00450:	0040      	lsls	r0, r0, #1
c0d00452:	4285      	cmp	r5, r0
c0d00454:	d127      	bne.n	c0d004a6 <dispatch_plugin_calls+0xa2>
        PRINTF("QUERY CONTRACT UI\n");
c0d00456:	4819      	ldr	r0, [pc, #100]	; (c0d004bc <dispatch_plugin_calls+0xb8>)
c0d00458:	4478      	add	r0, pc
c0d0045a:	f7ff fe13 	bl	c0d00084 <semihosted_printf>
        handle_query_contract_ui(parameters);
c0d0045e:	4620      	mov	r0, r4
c0d00460:	f7ff ff66 	bl	c0d00330 <handle_query_contract_ui>
}
c0d00464:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("GPIRIOU INIT CONTRACT\n");
c0d00466:	4816      	ldr	r0, [pc, #88]	; (c0d004c0 <dispatch_plugin_calls+0xbc>)
c0d00468:	4478      	add	r0, pc
c0d0046a:	f7ff fe0b 	bl	c0d00084 <semihosted_printf>
        handle_init_contract(parameters);
c0d0046e:	4620      	mov	r0, r4
c0d00470:	f7ff fe7e 	bl	c0d00170 <handle_init_contract>
}
c0d00474:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("PROVIDE PARAMETER\n");
c0d00476:	4813      	ldr	r0, [pc, #76]	; (c0d004c4 <dispatch_plugin_calls+0xc0>)
c0d00478:	4478      	add	r0, pc
c0d0047a:	f7ff fe03 	bl	c0d00084 <semihosted_printf>
        handle_provide_parameter(parameters);
c0d0047e:	4620      	mov	r0, r4
c0d00480:	f7ff ff06 	bl	c0d00290 <handle_provide_parameter>
}
c0d00484:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("PROVIDE TOKEN\n");
c0d00486:	4810      	ldr	r0, [pc, #64]	; (c0d004c8 <dispatch_plugin_calls+0xc4>)
c0d00488:	4478      	add	r0, pc
c0d0048a:	f7ff fdfb 	bl	c0d00084 <semihosted_printf>
        handle_provide_token(parameters);
c0d0048e:	4620      	mov	r0, r4
c0d00490:	f7ff ff1e 	bl	c0d002d0 <handle_provide_token>
}
c0d00494:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("QUERY CONTRACT ID\n");
c0d00496:	480d      	ldr	r0, [pc, #52]	; (c0d004cc <dispatch_plugin_calls+0xc8>)
c0d00498:	4478      	add	r0, pc
c0d0049a:	f7ff fdf3 	bl	c0d00084 <semihosted_printf>
        handle_query_contract_id(parameters);
c0d0049e:	4620      	mov	r0, r4
c0d004a0:	f7ff ff24 	bl	c0d002ec <handle_query_contract_id>
}
c0d004a4:	bdb0      	pop	{r4, r5, r7, pc}
        PRINTF("Unhandled message %d\n", message);
c0d004a6:	480a      	ldr	r0, [pc, #40]	; (c0d004d0 <dispatch_plugin_calls+0xcc>)
c0d004a8:	4478      	add	r0, pc
c0d004aa:	4629      	mov	r1, r5
c0d004ac:	f7ff fdea 	bl	c0d00084 <semihosted_printf>
}
c0d004b0:	bdb0      	pop	{r4, r5, r7, pc}
c0d004b2:	46c0      	nop			; (mov r8, r8)
c0d004b4:	00003750 	.word	0x00003750
c0d004b8:	0000376a 	.word	0x0000376a
c0d004bc:	00003770 	.word	0x00003770
c0d004c0:	0000370a 	.word	0x0000370a
c0d004c4:	00003711 	.word	0x00003711
c0d004c8:	0000371e 	.word	0x0000371e
c0d004cc:	0000371d 	.word	0x0000371d
c0d004d0:	00003733 	.word	0x00003733

c0d004d4 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d004d4:	b580      	push	{r7, lr}
c0d004d6:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d004d8:	f001 f8a0 	bl	c0d0161c <try_context_set>
#endif // HAVE_BOLOS
}
c0d004dc:	bd80      	pop	{r7, pc}
	...

c0d004e0 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d004e0:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
c0d004e2:	4672      	mov	r2, lr
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
c0d004e4:	4804      	ldr	r0, [pc, #16]	; (c0d004f8 <os_longjmp+0x18>)
c0d004e6:	4478      	add	r0, pc
c0d004e8:	4621      	mov	r1, r4
c0d004ea:	f7ff fdcb 	bl	c0d00084 <semihosted_printf>
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d004ee:	f001 f889 	bl	c0d01604 <try_context_get>
c0d004f2:	4621      	mov	r1, r4
c0d004f4:	f003 f9be 	bl	c0d03874 <longjmp>
c0d004f8:	00003714 	.word	0x00003714

c0d004fc <pic>:
// only apply PIC conversion if link_address is in linked code (over 0xC0D00000 in our example)
// this way, PIC call are armless if the address is not meant to be converted
extern void _nvram;
extern void _envram;

void *pic(void *link_address) {
c0d004fc:	b580      	push	{r7, lr}
  if (link_address >= &_nvram && link_address < &_envram) {
c0d004fe:	4904      	ldr	r1, [pc, #16]	; (c0d00510 <pic+0x14>)
c0d00500:	4288      	cmp	r0, r1
c0d00502:	d304      	bcc.n	c0d0050e <pic+0x12>
c0d00504:	4903      	ldr	r1, [pc, #12]	; (c0d00514 <pic+0x18>)
c0d00506:	4288      	cmp	r0, r1
c0d00508:	d201      	bcs.n	c0d0050e <pic+0x12>
    link_address = pic_internal(link_address);
c0d0050a:	f000 f805 	bl	c0d00518 <pic_internal>
  }
  return link_address;
c0d0050e:	bd80      	pop	{r7, pc}
c0d00510:	c0d00000 	.word	0xc0d00000
c0d00514:	c0d03c80 	.word	0xc0d03c80

c0d00518 <pic_internal>:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
__attribute__((naked)) void *pic_internal(void *link_address)
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");
c0d00518:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");
c0d0051a:	4902      	ldr	r1, [pc, #8]	; (c0d00524 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");
c0d0051c:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");
c0d0051e:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");
c0d00520:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0d00522:	4770      	bx	lr
c0d00524:	c0d00519 	.word	0xc0d00519

c0d00528 <_vsnprintf>:
// internal vsnprintf
static int _vsnprintf(out_fct_type out,
                      char* buffer,
                      const size_t maxlen,
                      const char* format,
                      va_list va) {
c0d00528:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0052a:	b097      	sub	sp, #92	; 0x5c
c0d0052c:	461d      	mov	r5, r3
    unsigned int flags, width, precision, n;
    size_t idx = 0U;

    if (!buffer) {
c0d0052e:	2900      	cmp	r1, #0
c0d00530:	d101      	bne.n	c0d00536 <_vsnprintf+0xe>
c0d00532:	48f9      	ldr	r0, [pc, #996]	; (c0d00918 <_vsnprintf+0x3f0>)
c0d00534:	4478      	add	r0, pc
c0d00536:	ab14      	add	r3, sp, #80	; 0x50
c0d00538:	c307      	stmia	r3!, {r0, r1, r2}
c0d0053a:	2700      	movs	r7, #0
c0d0053c:	43f8      	mvns	r0, r7
c0d0053e:	9011      	str	r0, [sp, #68]	; 0x44
c0d00540:	981c      	ldr	r0, [sp, #112]	; 0x70
c0d00542:	9013      	str	r0, [sp, #76]	; 0x4c
        // use null output function
        out = _out_null;
    }

    while (*format) {
c0d00544:	1cae      	adds	r6, r5, #2
c0d00546:	7828      	ldrb	r0, [r5, #0]
c0d00548:	2800      	cmp	r0, #0
c0d0054a:	d100      	bne.n	c0d0054e <_vsnprintf+0x26>
c0d0054c:	e275      	b.n	c0d00a3a <_vsnprintf+0x512>
c0d0054e:	2825      	cmp	r0, #37	; 0x25
c0d00550:	d00c      	beq.n	c0d0056c <_vsnprintf+0x44>
        // format specifier?  %[flags][width][.precision][length]
        if (*format != '%') {
            // no
            out(*format, buffer, idx++, maxlen);
c0d00552:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00554:	463a      	mov	r2, r7
c0d00556:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00558:	4634      	mov	r4, r6
c0d0055a:	463e      	mov	r6, r7
c0d0055c:	9f14      	ldr	r7, [sp, #80]	; 0x50
c0d0055e:	47b8      	blx	r7
c0d00560:	4637      	mov	r7, r6
c0d00562:	4626      	mov	r6, r4
            format++;
            continue;
c0d00564:	1c66      	adds	r6, r4, #1
            format++;
c0d00566:	1c6d      	adds	r5, r5, #1
            out(*format, buffer, idx++, maxlen);
c0d00568:	1c7f      	adds	r7, r7, #1
c0d0056a:	e7ec      	b.n	c0d00546 <_vsnprintf+0x1e>
c0d0056c:	2500      	movs	r5, #0
c0d0056e:	9b11      	ldr	r3, [sp, #68]	; 0x44
c0d00570:	9c13      	ldr	r4, [sp, #76]	; 0x4c
        }

        // evaluate flags
        flags = 0U;
        do {
            switch (*format) {
c0d00572:	5cf0      	ldrb	r0, [r6, r3]
c0d00574:	282a      	cmp	r0, #42	; 0x2a
c0d00576:	dd07      	ble.n	c0d00588 <_vsnprintf+0x60>
c0d00578:	282b      	cmp	r0, #43	; 0x2b
c0d0057a:	d00b      	beq.n	c0d00594 <_vsnprintf+0x6c>
c0d0057c:	2830      	cmp	r0, #48	; 0x30
c0d0057e:	d00b      	beq.n	c0d00598 <_vsnprintf+0x70>
c0d00580:	282d      	cmp	r0, #45	; 0x2d
c0d00582:	d10f      	bne.n	c0d005a4 <_vsnprintf+0x7c>
c0d00584:	2002      	movs	r0, #2
c0d00586:	e00a      	b.n	c0d0059e <_vsnprintf+0x76>
c0d00588:	2820      	cmp	r0, #32
c0d0058a:	d007      	beq.n	c0d0059c <_vsnprintf+0x74>
c0d0058c:	2823      	cmp	r0, #35	; 0x23
c0d0058e:	d109      	bne.n	c0d005a4 <_vsnprintf+0x7c>
c0d00590:	2010      	movs	r0, #16
c0d00592:	e004      	b.n	c0d0059e <_vsnprintf+0x76>
c0d00594:	2004      	movs	r0, #4
c0d00596:	e002      	b.n	c0d0059e <_vsnprintf+0x76>
c0d00598:	2001      	movs	r0, #1
c0d0059a:	e000      	b.n	c0d0059e <_vsnprintf+0x76>
c0d0059c:	2008      	movs	r0, #8
c0d0059e:	4305      	orrs	r5, r0
                    break;
                default:
                    n = 0U;
                    break;
            }
        } while (n);
c0d005a0:	1c76      	adds	r6, r6, #1
c0d005a2:	e7e6      	b.n	c0d00572 <_vsnprintf+0x4a>

        // evaluate width field
        width = 0U;
        if (_is_digit(*format)) {
c0d005a4:	18f1      	adds	r1, r6, r3
    return (ch >= '0') && (ch <= '9');
c0d005a6:	4602      	mov	r2, r0
c0d005a8:	3a30      	subs	r2, #48	; 0x30
c0d005aa:	b2d2      	uxtb	r2, r2
        if (_is_digit(*format)) {
c0d005ac:	2a09      	cmp	r2, #9
c0d005ae:	d80f      	bhi.n	c0d005d0 <_vsnprintf+0xa8>
c0d005b0:	9413      	str	r4, [sp, #76]	; 0x4c
c0d005b2:	2400      	movs	r4, #0
c0d005b4:	220a      	movs	r2, #10
        i = i * 10U + (unsigned int) (*((*str)++) - '0');
c0d005b6:	4362      	muls	r2, r4
c0d005b8:	b2c0      	uxtb	r0, r0
c0d005ba:	1814      	adds	r4, r2, r0
c0d005bc:	3c30      	subs	r4, #48	; 0x30
c0d005be:	1c4e      	adds	r6, r1, #1
    while (_is_digit(**str)) {
c0d005c0:	7848      	ldrb	r0, [r1, #1]
    return (ch >= '0') && (ch <= '9');
c0d005c2:	4601      	mov	r1, r0
c0d005c4:	3930      	subs	r1, #48	; 0x30
c0d005c6:	b2c9      	uxtb	r1, r1
    while (_is_digit(**str)) {
c0d005c8:	290a      	cmp	r1, #10
c0d005ca:	4631      	mov	r1, r6
c0d005cc:	d3f2      	bcc.n	c0d005b4 <_vsnprintf+0x8c>
c0d005ce:	e00f      	b.n	c0d005f0 <_vsnprintf+0xc8>
            width = _atoi(&format);
        } else if (*format == '*') {
c0d005d0:	282a      	cmp	r0, #42	; 0x2a
c0d005d2:	d10a      	bne.n	c0d005ea <_vsnprintf+0xc2>
            const int w = va_arg(va, int);
c0d005d4:	cc01      	ldmia	r4!, {r0}
            if (w < 0) {
c0d005d6:	2800      	cmp	r0, #0
c0d005d8:	9413      	str	r4, [sp, #76]	; 0x4c
c0d005da:	d501      	bpl.n	c0d005e0 <_vsnprintf+0xb8>
c0d005dc:	2102      	movs	r1, #2
c0d005de:	430d      	orrs	r5, r1
c0d005e0:	17c1      	asrs	r1, r0, #31
c0d005e2:	1844      	adds	r4, r0, r1
c0d005e4:	404c      	eors	r4, r1
            format++;
        }

        // evaluate precision field
        precision = 0U;
        if (*format == '.') {
c0d005e6:	7830      	ldrb	r0, [r6, #0]
c0d005e8:	e002      	b.n	c0d005f0 <_vsnprintf+0xc8>
c0d005ea:	9413      	str	r4, [sp, #76]	; 0x4c
c0d005ec:	2400      	movs	r4, #0
c0d005ee:	460e      	mov	r6, r1
c0d005f0:	2200      	movs	r2, #0
c0d005f2:	282e      	cmp	r0, #46	; 0x2e
c0d005f4:	d126      	bne.n	c0d00644 <_vsnprintf+0x11c>
c0d005f6:	9212      	str	r2, [sp, #72]	; 0x48
c0d005f8:	2001      	movs	r0, #1
c0d005fa:	0280      	lsls	r0, r0, #10
            flags |= FLAGS_PRECISION;
c0d005fc:	4305      	orrs	r5, r0
            format++;
c0d005fe:	1c71      	adds	r1, r6, #1
            if (_is_digit(*format)) {
c0d00600:	7870      	ldrb	r0, [r6, #1]
    return (ch >= '0') && (ch <= '9');
c0d00602:	4602      	mov	r2, r0
c0d00604:	3a30      	subs	r2, #48	; 0x30
c0d00606:	b2d2      	uxtb	r2, r2
            if (_is_digit(*format)) {
c0d00608:	2a09      	cmp	r2, #9
c0d0060a:	d80f      	bhi.n	c0d0062c <_vsnprintf+0x104>
c0d0060c:	2200      	movs	r2, #0
c0d0060e:	4616      	mov	r6, r2
c0d00610:	220a      	movs	r2, #10
        i = i * 10U + (unsigned int) (*((*str)++) - '0');
c0d00612:	4372      	muls	r2, r6
c0d00614:	b2c0      	uxtb	r0, r0
c0d00616:	1812      	adds	r2, r2, r0
c0d00618:	3a30      	subs	r2, #48	; 0x30
c0d0061a:	1c4e      	adds	r6, r1, #1
    while (_is_digit(**str)) {
c0d0061c:	7848      	ldrb	r0, [r1, #1]
    return (ch >= '0') && (ch <= '9');
c0d0061e:	4601      	mov	r1, r0
c0d00620:	3930      	subs	r1, #48	; 0x30
c0d00622:	b2c9      	uxtb	r1, r1
    while (_is_digit(**str)) {
c0d00624:	290a      	cmp	r1, #10
c0d00626:	4631      	mov	r1, r6
c0d00628:	d3f1      	bcc.n	c0d0060e <_vsnprintf+0xe6>
c0d0062a:	e00b      	b.n	c0d00644 <_vsnprintf+0x11c>
                precision = _atoi(&format);
            } else if (*format == '*') {
c0d0062c:	282a      	cmp	r0, #42	; 0x2a
c0d0062e:	d107      	bne.n	c0d00640 <_vsnprintf+0x118>
                const int prec = (int) va_arg(va, int);
c0d00630:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d00632:	c804      	ldmia	r0!, {r2}
                precision = prec > 0 ? (unsigned int) prec : 0U;
c0d00634:	9013      	str	r0, [sp, #76]	; 0x4c
c0d00636:	17d0      	asrs	r0, r2, #31
c0d00638:	4382      	bics	r2, r0
                format++;
            }
        }

        // evaluate length field
        switch (*format) {
c0d0063a:	78b0      	ldrb	r0, [r6, #2]
                format++;
c0d0063c:	1cb6      	adds	r6, r6, #2
c0d0063e:	e001      	b.n	c0d00644 <_vsnprintf+0x11c>
c0d00640:	460e      	mov	r6, r1
c0d00642:	9a12      	ldr	r2, [sp, #72]	; 0x48
        switch (*format) {
c0d00644:	3868      	subs	r0, #104	; 0x68
c0d00646:	2101      	movs	r1, #1
c0d00648:	41c8      	rors	r0, r1
c0d0064a:	2801      	cmp	r0, #1
c0d0064c:	9110      	str	r1, [sp, #64]	; 0x40
c0d0064e:	dd0c      	ble.n	c0d0066a <_vsnprintf+0x142>
c0d00650:	2809      	cmp	r0, #9
c0d00652:	d011      	beq.n	c0d00678 <_vsnprintf+0x150>
c0d00654:	2806      	cmp	r0, #6
c0d00656:	d00f      	beq.n	c0d00678 <_vsnprintf+0x150>
c0d00658:	2802      	cmp	r0, #2
c0d0065a:	d118      	bne.n	c0d0068e <_vsnprintf+0x166>
            case 'l':
                flags |= FLAGS_LONG;
                format++;
                if (*format == 'l') {
c0d0065c:	7870      	ldrb	r0, [r6, #1]
c0d0065e:	286c      	cmp	r0, #108	; 0x6c
c0d00660:	d000      	beq.n	c0d00664 <_vsnprintf+0x13c>
c0d00662:	e0a0      	b.n	c0d007a6 <_vsnprintf+0x27e>
c0d00664:	2003      	movs	r0, #3
c0d00666:	0200      	lsls	r0, r0, #8
c0d00668:	e00f      	b.n	c0d0068a <_vsnprintf+0x162>
        switch (*format) {
c0d0066a:	2800      	cmp	r0, #0
c0d0066c:	d008      	beq.n	c0d00680 <_vsnprintf+0x158>
c0d0066e:	2801      	cmp	r0, #1
c0d00670:	d10d      	bne.n	c0d0068e <_vsnprintf+0x166>
c0d00672:	2001      	movs	r0, #1
c0d00674:	0240      	lsls	r0, r0, #9
c0d00676:	e000      	b.n	c0d0067a <_vsnprintf+0x152>
c0d00678:	0208      	lsls	r0, r1, #8
c0d0067a:	4305      	orrs	r5, r0
c0d0067c:	1c76      	adds	r6, r6, #1
c0d0067e:	e006      	b.n	c0d0068e <_vsnprintf+0x166>
                }
                break;
            case 'h':
                flags |= FLAGS_SHORT;
                format++;
                if (*format == 'h') {
c0d00680:	7870      	ldrb	r0, [r6, #1]
c0d00682:	2868      	cmp	r0, #104	; 0x68
c0d00684:	d000      	beq.n	c0d00688 <_vsnprintf+0x160>
c0d00686:	e090      	b.n	c0d007aa <_vsnprintf+0x282>
c0d00688:	20c0      	movs	r0, #192	; 0xc0
c0d0068a:	4305      	orrs	r5, r0
c0d0068c:	1cb6      	adds	r6, r6, #2
            default:
                break;
        }

        // evaluate specifier
        switch (*format) {
c0d0068e:	7830      	ldrb	r0, [r6, #0]
c0d00690:	2110      	movs	r1, #16
c0d00692:	2864      	cmp	r0, #100	; 0x64
c0d00694:	dd0b      	ble.n	c0d006ae <_vsnprintf+0x186>
c0d00696:	286e      	cmp	r0, #110	; 0x6e
c0d00698:	dd13      	ble.n	c0d006c2 <_vsnprintf+0x19a>
c0d0069a:	2872      	cmp	r0, #114	; 0x72
c0d0069c:	dd22      	ble.n	c0d006e4 <_vsnprintf+0x1bc>
c0d0069e:	2873      	cmp	r0, #115	; 0x73
c0d006a0:	d100      	bne.n	c0d006a4 <_vsnprintf+0x17c>
c0d006a2:	e086      	b.n	c0d007b2 <_vsnprintf+0x28a>
c0d006a4:	2875      	cmp	r0, #117	; 0x75
c0d006a6:	d042      	beq.n	c0d0072e <_vsnprintf+0x206>
c0d006a8:	2878      	cmp	r0, #120	; 0x78
c0d006aa:	d043      	beq.n	c0d00734 <_vsnprintf+0x20c>
c0d006ac:	e0c8      	b.n	c0d00840 <_vsnprintf+0x318>
c0d006ae:	2857      	cmp	r0, #87	; 0x57
c0d006b0:	dc0e      	bgt.n	c0d006d0 <_vsnprintf+0x1a8>
c0d006b2:	2845      	cmp	r0, #69	; 0x45
c0d006b4:	dc2b      	bgt.n	c0d0070e <_vsnprintf+0x1e6>
c0d006b6:	2825      	cmp	r0, #37	; 0x25
c0d006b8:	d100      	bne.n	c0d006bc <_vsnprintf+0x194>
c0d006ba:	e0c0      	b.n	c0d0083e <_vsnprintf+0x316>
c0d006bc:	2845      	cmp	r0, #69	; 0x45
c0d006be:	d05d      	beq.n	c0d0077c <_vsnprintf+0x254>
c0d006c0:	e0be      	b.n	c0d00840 <_vsnprintf+0x318>
c0d006c2:	2866      	cmp	r0, #102	; 0x66
c0d006c4:	dc28      	bgt.n	c0d00718 <_vsnprintf+0x1f0>
c0d006c6:	2865      	cmp	r0, #101	; 0x65
c0d006c8:	d058      	beq.n	c0d0077c <_vsnprintf+0x254>
c0d006ca:	2866      	cmp	r0, #102	; 0x66
c0d006cc:	d03e      	beq.n	c0d0074c <_vsnprintf+0x224>
c0d006ce:	e0b7      	b.n	c0d00840 <_vsnprintf+0x318>
c0d006d0:	2862      	cmp	r0, #98	; 0x62
c0d006d2:	dc26      	bgt.n	c0d00722 <_vsnprintf+0x1fa>
c0d006d4:	2858      	cmp	r0, #88	; 0x58
c0d006d6:	d02d      	beq.n	c0d00734 <_vsnprintf+0x20c>
c0d006d8:	2862      	cmp	r0, #98	; 0x62
c0d006da:	d000      	beq.n	c0d006de <_vsnprintf+0x1b6>
c0d006dc:	e0b0      	b.n	c0d00840 <_vsnprintf+0x318>
c0d006de:	9212      	str	r2, [sp, #72]	; 0x48
c0d006e0:	2102      	movs	r1, #2
c0d006e2:	e0b6      	b.n	c0d00852 <_vsnprintf+0x32a>
c0d006e4:	286f      	cmp	r0, #111	; 0x6f
c0d006e6:	d100      	bne.n	c0d006ea <_vsnprintf+0x1c2>
c0d006e8:	e0b1      	b.n	c0d0084e <_vsnprintf+0x326>
c0d006ea:	2870      	cmp	r0, #112	; 0x70
c0d006ec:	d000      	beq.n	c0d006f0 <_vsnprintf+0x1c8>
c0d006ee:	e0a7      	b.n	c0d00840 <_vsnprintf+0x318>
c0d006f0:	2021      	movs	r0, #33	; 0x21
                break;
            }

            case 'p': {
                width = sizeof(void*) * 2U;
                flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
c0d006f2:	4305      	orrs	r5, r0
#endif
                    idx = _ntoa_long(out,
                                     buffer,
                                     idx,
                                     maxlen,
                                     (unsigned long) ((uintptr_t) va_arg(va, void*)),
c0d006f4:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d006f6:	c901      	ldmia	r1!, {r0}
c0d006f8:	9113      	str	r1, [sp, #76]	; 0x4c
c0d006fa:	2108      	movs	r1, #8
c0d006fc:	4614      	mov	r4, r2
c0d006fe:	2210      	movs	r2, #16
c0d00700:	2300      	movs	r3, #0
                    idx = _ntoa_long(out,
c0d00702:	9000      	str	r0, [sp, #0]
c0d00704:	9301      	str	r3, [sp, #4]
c0d00706:	9202      	str	r2, [sp, #8]
c0d00708:	9403      	str	r4, [sp, #12]
c0d0070a:	9104      	str	r1, [sp, #16]
c0d0070c:	e112      	b.n	c0d00934 <_vsnprintf+0x40c>
        switch (*format) {
c0d0070e:	2846      	cmp	r0, #70	; 0x46
c0d00710:	d01c      	beq.n	c0d0074c <_vsnprintf+0x224>
c0d00712:	2847      	cmp	r0, #71	; 0x47
c0d00714:	d02f      	beq.n	c0d00776 <_vsnprintf+0x24e>
c0d00716:	e093      	b.n	c0d00840 <_vsnprintf+0x318>
c0d00718:	2867      	cmp	r0, #103	; 0x67
c0d0071a:	d02c      	beq.n	c0d00776 <_vsnprintf+0x24e>
c0d0071c:	2869      	cmp	r0, #105	; 0x69
c0d0071e:	d006      	beq.n	c0d0072e <_vsnprintf+0x206>
c0d00720:	e08e      	b.n	c0d00840 <_vsnprintf+0x318>
c0d00722:	2863      	cmp	r0, #99	; 0x63
c0d00724:	d100      	bne.n	c0d00728 <_vsnprintf+0x200>
c0d00726:	e0de      	b.n	c0d008e6 <_vsnprintf+0x3be>
c0d00728:	2864      	cmp	r0, #100	; 0x64
c0d0072a:	d000      	beq.n	c0d0072e <_vsnprintf+0x206>
c0d0072c:	e088      	b.n	c0d00840 <_vsnprintf+0x318>
c0d0072e:	2110      	movs	r1, #16
                    flags &= ~FLAGS_HASH;  // no hash for dec format
c0d00730:	438d      	bics	r5, r1
c0d00732:	210a      	movs	r1, #10
                if (*format == 'X') {
c0d00734:	2858      	cmp	r0, #88	; 0x58
c0d00736:	9212      	str	r2, [sp, #72]	; 0x48
c0d00738:	d101      	bne.n	c0d0073e <_vsnprintf+0x216>
c0d0073a:	2220      	movs	r2, #32
c0d0073c:	4315      	orrs	r5, r2
                if ((*format != 'i') && (*format != 'd')) {
c0d0073e:	2864      	cmp	r0, #100	; 0x64
c0d00740:	d100      	bne.n	c0d00744 <_vsnprintf+0x21c>
c0d00742:	e088      	b.n	c0d00856 <_vsnprintf+0x32e>
c0d00744:	2869      	cmp	r0, #105	; 0x69
c0d00746:	d100      	bne.n	c0d0074a <_vsnprintf+0x222>
c0d00748:	e085      	b.n	c0d00856 <_vsnprintf+0x32e>
c0d0074a:	e082      	b.n	c0d00852 <_vsnprintf+0x32a>
c0d0074c:	4613      	mov	r3, r2
c0d0074e:	9a13      	ldr	r2, [sp, #76]	; 0x4c
                idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d00750:	1dd2      	adds	r2, r2, #7
c0d00752:	2107      	movs	r1, #7
c0d00754:	438a      	bics	r2, r1
c0d00756:	6811      	ldr	r1, [r2, #0]
c0d00758:	9213      	str	r2, [sp, #76]	; 0x4c
c0d0075a:	6852      	ldr	r2, [r2, #4]
                if (*format == 'F') flags |= FLAGS_UPPERCASE;
c0d0075c:	2846      	cmp	r0, #70	; 0x46
c0d0075e:	d101      	bne.n	c0d00764 <_vsnprintf+0x23c>
c0d00760:	2020      	movs	r0, #32
c0d00762:	4305      	orrs	r5, r0
                idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d00764:	a800      	add	r0, sp, #0
c0d00766:	c03e      	stmia	r0!, {r1, r2, r3, r4, r5}
c0d00768:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d0076a:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d0076c:	463a      	mov	r2, r7
c0d0076e:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00770:	f000 fa30 	bl	c0d00bd4 <_ftoa>
c0d00774:	e0a7      	b.n	c0d008c6 <_vsnprintf+0x39e>
c0d00776:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d00778:	02c9      	lsls	r1, r1, #11
                if ((*format == 'g') || (*format == 'G')) flags |= FLAGS_ADAPT_EXP;
c0d0077a:	430d      	orrs	r5, r1
c0d0077c:	2102      	movs	r1, #2
                if ((*format == 'E') || (*format == 'G')) flags |= FLAGS_UPPERCASE;
c0d0077e:	4308      	orrs	r0, r1
c0d00780:	2847      	cmp	r0, #71	; 0x47
c0d00782:	d101      	bne.n	c0d00788 <_vsnprintf+0x260>
c0d00784:	2020      	movs	r0, #32
c0d00786:	4305      	orrs	r5, r0
c0d00788:	9913      	ldr	r1, [sp, #76]	; 0x4c
                idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
c0d0078a:	1dc9      	adds	r1, r1, #7
c0d0078c:	2007      	movs	r0, #7
c0d0078e:	4381      	bics	r1, r0
c0d00790:	9113      	str	r1, [sp, #76]	; 0x4c
c0d00792:	c903      	ldmia	r1, {r0, r1}
c0d00794:	ab00      	add	r3, sp, #0
c0d00796:	c337      	stmia	r3!, {r0, r1, r2, r4, r5}
c0d00798:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d0079a:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d0079c:	463a      	mov	r2, r7
c0d0079e:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d007a0:	f000 fc08 	bl	c0d00fb4 <_etoa>
c0d007a4:	e08f      	b.n	c0d008c6 <_vsnprintf+0x39e>
c0d007a6:	0209      	lsls	r1, r1, #8
c0d007a8:	e000      	b.n	c0d007ac <_vsnprintf+0x284>
c0d007aa:	2180      	movs	r1, #128	; 0x80
c0d007ac:	430d      	orrs	r5, r1
c0d007ae:	1c76      	adds	r6, r6, #1
c0d007b0:	e76e      	b.n	c0d00690 <_vsnprintf+0x168>
c0d007b2:	9212      	str	r2, [sp, #72]	; 0x48
                const char* p = va_arg(va, char*);
c0d007b4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d007b6:	c802      	ldmia	r0!, {r1}
    for (s = str; *s && maxsize--; ++s)
c0d007b8:	9013      	str	r0, [sp, #76]	; 0x4c
c0d007ba:	7808      	ldrb	r0, [r1, #0]
c0d007bc:	2800      	cmp	r0, #0
c0d007be:	910c      	str	r1, [sp, #48]	; 0x30
c0d007c0:	d00e      	beq.n	c0d007e0 <_vsnprintf+0x2b8>
c0d007c2:	9a12      	ldr	r2, [sp, #72]	; 0x48
                unsigned int l = _strnlen_s(p, precision ? precision : (size_t) -1);
c0d007c4:	2a00      	cmp	r2, #0
c0d007c6:	4619      	mov	r1, r3
c0d007c8:	d000      	beq.n	c0d007cc <_vsnprintf+0x2a4>
c0d007ca:	4611      	mov	r1, r2
    for (s = str; *s && maxsize--; ++s)
c0d007cc:	1e4a      	subs	r2, r1, #1
c0d007ce:	9b0c      	ldr	r3, [sp, #48]	; 0x30
c0d007d0:	1c59      	adds	r1, r3, #1
c0d007d2:	2a00      	cmp	r2, #0
c0d007d4:	d004      	beq.n	c0d007e0 <_vsnprintf+0x2b8>
c0d007d6:	785b      	ldrb	r3, [r3, #1]
c0d007d8:	1e52      	subs	r2, r2, #1
c0d007da:	2b00      	cmp	r3, #0
c0d007dc:	460b      	mov	r3, r1
c0d007de:	d1f7      	bne.n	c0d007d0 <_vsnprintf+0x2a8>
c0d007e0:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d007e2:	0293      	lsls	r3, r2, #10
                if (flags & FLAGS_PRECISION) {
c0d007e4:	402b      	ands	r3, r5
    return (unsigned int) (s - str);
c0d007e6:	9a0c      	ldr	r2, [sp, #48]	; 0x30
c0d007e8:	1a89      	subs	r1, r1, r2
c0d007ea:	9a12      	ldr	r2, [sp, #72]	; 0x48
                if (flags & FLAGS_PRECISION) {
c0d007ec:	4291      	cmp	r1, r2
c0d007ee:	910d      	str	r1, [sp, #52]	; 0x34
c0d007f0:	d300      	bcc.n	c0d007f4 <_vsnprintf+0x2cc>
c0d007f2:	920d      	str	r2, [sp, #52]	; 0x34
c0d007f4:	2b00      	cmp	r3, #0
c0d007f6:	d100      	bne.n	c0d007fa <_vsnprintf+0x2d2>
c0d007f8:	910d      	str	r1, [sp, #52]	; 0x34
c0d007fa:	2102      	movs	r1, #2
                if (!(flags & FLAGS_LEFT)) {
c0d007fc:	400d      	ands	r5, r1
c0d007fe:	950f      	str	r5, [sp, #60]	; 0x3c
c0d00800:	930e      	str	r3, [sp, #56]	; 0x38
c0d00802:	d000      	beq.n	c0d00806 <_vsnprintf+0x2de>
c0d00804:	e0b8      	b.n	c0d00978 <_vsnprintf+0x450>
c0d00806:	990d      	ldr	r1, [sp, #52]	; 0x34
                    while (l++ < width) {
c0d00808:	42a1      	cmp	r1, r4
c0d0080a:	d300      	bcc.n	c0d0080e <_vsnprintf+0x2e6>
c0d0080c:	e0b2      	b.n	c0d00974 <_vsnprintf+0x44c>
c0d0080e:	1a60      	subs	r0, r4, r1
c0d00810:	9010      	str	r0, [sp, #64]	; 0x40
c0d00812:	940a      	str	r4, [sp, #40]	; 0x28
c0d00814:	1c60      	adds	r0, r4, #1
c0d00816:	900d      	str	r0, [sp, #52]	; 0x34
c0d00818:	2500      	movs	r5, #0
                        out(' ', buffer, idx++, maxlen);
c0d0081a:	197a      	adds	r2, r7, r5
c0d0081c:	2020      	movs	r0, #32
c0d0081e:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00820:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00822:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d00824:	47a0      	blx	r4
                    while (l++ < width) {
c0d00826:	1c6d      	adds	r5, r5, #1
c0d00828:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d0082a:	42a8      	cmp	r0, r5
c0d0082c:	d1f5      	bne.n	c0d0081a <_vsnprintf+0x2f2>
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d0082e:	197f      	adds	r7, r7, r5
c0d00830:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00832:	7800      	ldrb	r0, [r0, #0]
c0d00834:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d00836:	9a12      	ldr	r2, [sp, #72]	; 0x48
c0d00838:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d0083a:	9c0a      	ldr	r4, [sp, #40]	; 0x28
c0d0083c:	e09c      	b.n	c0d00978 <_vsnprintf+0x450>
c0d0083e:	2025      	movs	r0, #37	; 0x25
c0d00840:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00842:	463a      	mov	r2, r7
c0d00844:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00846:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d00848:	47a0      	blx	r4
c0d0084a:	1c7f      	adds	r7, r7, #1
c0d0084c:	e03f      	b.n	c0d008ce <_vsnprintf+0x3a6>
c0d0084e:	9212      	str	r2, [sp, #72]	; 0x48
c0d00850:	2108      	movs	r1, #8
c0d00852:	220c      	movs	r2, #12
                    flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
c0d00854:	4395      	bics	r5, r2
                if (flags & FLAGS_PRECISION) {
c0d00856:	056a      	lsls	r2, r5, #21
c0d00858:	d501      	bpl.n	c0d0085e <_vsnprintf+0x336>
c0d0085a:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d0085c:	4395      	bics	r5, r2
                if ((*format == 'i') || (*format == 'd')) {
c0d0085e:	2869      	cmp	r0, #105	; 0x69
c0d00860:	d001      	beq.n	c0d00866 <_vsnprintf+0x33e>
c0d00862:	2864      	cmp	r0, #100	; 0x64
c0d00864:	d118      	bne.n	c0d00898 <_vsnprintf+0x370>
                    if (flags & FLAGS_LONG_LONG) {
c0d00866:	05a8      	lsls	r0, r5, #22
c0d00868:	d533      	bpl.n	c0d008d2 <_vsnprintf+0x3aa>
c0d0086a:	9b13      	ldr	r3, [sp, #76]	; 0x4c
                        const long long value = va_arg(va, long long);
c0d0086c:	1ddb      	adds	r3, r3, #7
c0d0086e:	2007      	movs	r0, #7
c0d00870:	4383      	bics	r3, r0
c0d00872:	9313      	str	r3, [sp, #76]	; 0x4c
c0d00874:	681a      	ldr	r2, [r3, #0]
c0d00876:	6858      	ldr	r0, [r3, #4]
                        idx = _ntoa_long_long(out,
c0d00878:	0fc3      	lsrs	r3, r0, #31
c0d0087a:	9302      	str	r3, [sp, #8]
c0d0087c:	2300      	movs	r3, #0
c0d0087e:	9104      	str	r1, [sp, #16]
c0d00880:	9305      	str	r3, [sp, #20]
c0d00882:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d00884:	ab06      	add	r3, sp, #24
c0d00886:	c332      	stmia	r3!, {r1, r4, r5}
                                              (unsigned long long) (value > 0 ? value : 0 - value),
c0d00888:	17c1      	asrs	r1, r0, #31
c0d0088a:	1852      	adds	r2, r2, r1
c0d0088c:	4148      	adcs	r0, r1
c0d0088e:	404a      	eors	r2, r1
                        idx = _ntoa_long_long(out,
c0d00890:	9200      	str	r2, [sp, #0]
                                              (unsigned long long) (value > 0 ? value : 0 - value),
c0d00892:	4048      	eors	r0, r1
                        idx = _ntoa_long_long(out,
c0d00894:	9001      	str	r0, [sp, #4]
c0d00896:	e010      	b.n	c0d008ba <_vsnprintf+0x392>
                    if (flags & FLAGS_LONG_LONG) {
c0d00898:	05a8      	lsls	r0, r5, #22
c0d0089a:	d53f      	bpl.n	c0d0091c <_vsnprintf+0x3f4>
c0d0089c:	9a13      	ldr	r2, [sp, #76]	; 0x4c
                                              va_arg(va, unsigned long long),
c0d0089e:	1dd2      	adds	r2, r2, #7
c0d008a0:	2007      	movs	r0, #7
c0d008a2:	4382      	bics	r2, r0
c0d008a4:	9213      	str	r2, [sp, #76]	; 0x4c
c0d008a6:	ca05      	ldmia	r2, {r0, r2}
c0d008a8:	2300      	movs	r3, #0
                        idx = _ntoa_long_long(out,
c0d008aa:	9104      	str	r1, [sp, #16]
c0d008ac:	9305      	str	r3, [sp, #20]
c0d008ae:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d008b0:	9106      	str	r1, [sp, #24]
c0d008b2:	9407      	str	r4, [sp, #28]
c0d008b4:	9508      	str	r5, [sp, #32]
c0d008b6:	a900      	add	r1, sp, #0
c0d008b8:	c10d      	stmia	r1!, {r0, r2, r3}
c0d008ba:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d008bc:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d008be:	463a      	mov	r2, r7
c0d008c0:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d008c2:	f000 f8dc 	bl	c0d00a7e <_ntoa_long_long>
c0d008c6:	4607      	mov	r7, r0
c0d008c8:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d008ca:	3008      	adds	r0, #8
c0d008cc:	9013      	str	r0, [sp, #76]	; 0x4c
c0d008ce:	1c75      	adds	r5, r6, #1
c0d008d0:	e638      	b.n	c0d00544 <_vsnprintf+0x1c>
                    } else if (flags & FLAGS_LONG) {
c0d008d2:	05e8      	lsls	r0, r5, #23
c0d008d4:	d537      	bpl.n	c0d00946 <_vsnprintf+0x41e>
                        const long value = va_arg(va, long);
c0d008d6:	9a13      	ldr	r2, [sp, #76]	; 0x4c
c0d008d8:	ca01      	ldmia	r2!, {r0}
c0d008da:	9213      	str	r2, [sp, #76]	; 0x4c
                        idx = _ntoa_long(out,
c0d008dc:	0fc2      	lsrs	r2, r0, #31
                                         (unsigned long) (value > 0 ? value : 0 - value),
c0d008de:	17c3      	asrs	r3, r0, #31
c0d008e0:	18c0      	adds	r0, r0, r3
c0d008e2:	4058      	eors	r0, r3
c0d008e4:	e020      	b.n	c0d00928 <_vsnprintf+0x400>
c0d008e6:	2002      	movs	r0, #2
                if (!(flags & FLAGS_LEFT)) {
c0d008e8:	4005      	ands	r5, r0
c0d008ea:	960b      	str	r6, [sp, #44]	; 0x2c
c0d008ec:	d172      	bne.n	c0d009d4 <_vsnprintf+0x4ac>
                    while (l++ < width) {
c0d008ee:	2c02      	cmp	r4, #2
c0d008f0:	d36f      	bcc.n	c0d009d2 <_vsnprintf+0x4aa>
c0d008f2:	950f      	str	r5, [sp, #60]	; 0x3c
c0d008f4:	1e60      	subs	r0, r4, #1
c0d008f6:	9012      	str	r0, [sp, #72]	; 0x48
c0d008f8:	1c60      	adds	r0, r4, #1
c0d008fa:	9010      	str	r0, [sp, #64]	; 0x40
c0d008fc:	2500      	movs	r5, #0
                        out(' ', buffer, idx++, maxlen);
c0d008fe:	197a      	adds	r2, r7, r5
c0d00900:	2020      	movs	r0, #32
c0d00902:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00904:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00906:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d00908:	47b0      	blx	r6
                    while (l++ < width) {
c0d0090a:	1c6d      	adds	r5, r5, #1
c0d0090c:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d0090e:	42a8      	cmp	r0, r5
c0d00910:	d1f5      	bne.n	c0d008fe <_vsnprintf+0x3d6>
                out((char) va_arg(va, int), buffer, idx++, maxlen);
c0d00912:	197f      	adds	r7, r7, r5
c0d00914:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d00916:	e05d      	b.n	c0d009d4 <_vsnprintf+0x4ac>
c0d00918:	00000545 	.word	0x00000545
                    } else if (flags & FLAGS_LONG) {
c0d0091c:	05e8      	lsls	r0, r5, #23
c0d0091e:	d521      	bpl.n	c0d00964 <_vsnprintf+0x43c>
                                         va_arg(va, unsigned long),
c0d00920:	9a13      	ldr	r2, [sp, #76]	; 0x4c
c0d00922:	ca01      	ldmia	r2!, {r0}
c0d00924:	9213      	str	r2, [sp, #76]	; 0x4c
c0d00926:	2200      	movs	r2, #0
c0d00928:	9000      	str	r0, [sp, #0]
c0d0092a:	9201      	str	r2, [sp, #4]
c0d0092c:	9102      	str	r1, [sp, #8]
c0d0092e:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d00930:	9003      	str	r0, [sp, #12]
c0d00932:	9404      	str	r4, [sp, #16]
c0d00934:	9505      	str	r5, [sp, #20]
c0d00936:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d00938:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d0093a:	463a      	mov	r2, r7
c0d0093c:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d0093e:	f000 f8ff 	bl	c0d00b40 <_ntoa_long>
c0d00942:	4607      	mov	r7, r0
c0d00944:	e7c3      	b.n	c0d008ce <_vsnprintf+0x3a6>
                        const int value = (flags & FLAGS_CHAR)
c0d00946:	0668      	lsls	r0, r5, #25
c0d00948:	d405      	bmi.n	c0d00956 <_vsnprintf+0x42e>
                                              : (flags & FLAGS_SHORT) ? (short int) va_arg(va, int)
c0d0094a:	0628      	lsls	r0, r5, #24
c0d0094c:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d0094e:	6800      	ldr	r0, [r0, #0]
c0d00950:	d503      	bpl.n	c0d0095a <_vsnprintf+0x432>
c0d00952:	b200      	sxth	r0, r0
c0d00954:	e001      	b.n	c0d0095a <_vsnprintf+0x432>
                                              ? (char) va_arg(va, int)
c0d00956:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d00958:	7800      	ldrb	r0, [r0, #0]
                        idx = _ntoa_long(out,
c0d0095a:	0fc2      	lsrs	r2, r0, #31
                                         (unsigned int) (value > 0 ? value : 0 - value),
c0d0095c:	17c3      	asrs	r3, r0, #31
c0d0095e:	18c0      	adds	r0, r0, r3
c0d00960:	4058      	eors	r0, r3
c0d00962:	e05a      	b.n	c0d00a1a <_vsnprintf+0x4f2>
                            (flags & FLAGS_CHAR)
c0d00964:	0668      	lsls	r0, r5, #25
c0d00966:	d455      	bmi.n	c0d00a14 <_vsnprintf+0x4ec>
                                : (flags & FLAGS_SHORT)
c0d00968:	0628      	lsls	r0, r5, #24
c0d0096a:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d0096c:	6800      	ldr	r0, [r0, #0]
c0d0096e:	d553      	bpl.n	c0d00a18 <_vsnprintf+0x4f0>
c0d00970:	b280      	uxth	r0, r0
c0d00972:	e051      	b.n	c0d00a18 <_vsnprintf+0x4f0>
c0d00974:	1c49      	adds	r1, r1, #1
c0d00976:	910d      	str	r1, [sp, #52]	; 0x34
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d00978:	2800      	cmp	r0, #0
c0d0097a:	d017      	beq.n	c0d009ac <_vsnprintf+0x484>
c0d0097c:	990c      	ldr	r1, [sp, #48]	; 0x30
c0d0097e:	1c49      	adds	r1, r1, #1
c0d00980:	2b00      	cmp	r3, #0
c0d00982:	9110      	str	r1, [sp, #64]	; 0x40
c0d00984:	d002      	beq.n	c0d0098c <_vsnprintf+0x464>
c0d00986:	2a00      	cmp	r2, #0
c0d00988:	d010      	beq.n	c0d009ac <_vsnprintf+0x484>
c0d0098a:	1e52      	subs	r2, r2, #1
c0d0098c:	9212      	str	r2, [sp, #72]	; 0x48
                    out(*(p++), buffer, idx++, maxlen);
c0d0098e:	b2c0      	uxtb	r0, r0
c0d00990:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00992:	463a      	mov	r2, r7
c0d00994:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00996:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d00998:	47a8      	blx	r5
c0d0099a:	9810      	ldr	r0, [sp, #64]	; 0x40
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d0099c:	1c41      	adds	r1, r0, #1
                    out(*(p++), buffer, idx++, maxlen);
c0d0099e:	1c7f      	adds	r7, r7, #1
                while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
c0d009a0:	7800      	ldrb	r0, [r0, #0]
c0d009a2:	2800      	cmp	r0, #0
c0d009a4:	9d0f      	ldr	r5, [sp, #60]	; 0x3c
c0d009a6:	9a12      	ldr	r2, [sp, #72]	; 0x48
c0d009a8:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d009aa:	d1e9      	bne.n	c0d00980 <_vsnprintf+0x458>
                if (flags & FLAGS_LEFT) {
c0d009ac:	2d00      	cmp	r5, #0
c0d009ae:	d08e      	beq.n	c0d008ce <_vsnprintf+0x3a6>
c0d009b0:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d009b2:	42a0      	cmp	r0, r4
c0d009b4:	9914      	ldr	r1, [sp, #80]	; 0x50
c0d009b6:	d28a      	bcs.n	c0d008ce <_vsnprintf+0x3a6>
                    while (l++ < width) {
c0d009b8:	1a24      	subs	r4, r4, r0
c0d009ba:	9114      	str	r1, [sp, #80]	; 0x50
c0d009bc:	2020      	movs	r0, #32
                        out(' ', buffer, idx++, maxlen);
c0d009be:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d009c0:	463a      	mov	r2, r7
c0d009c2:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d009c4:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d009c6:	47a8      	blx	r5
                    while (l++ < width) {
c0d009c8:	1e64      	subs	r4, r4, #1
                        out(' ', buffer, idx++, maxlen);
c0d009ca:	1c7f      	adds	r7, r7, #1
                    while (l++ < width) {
c0d009cc:	2c00      	cmp	r4, #0
c0d009ce:	d1f5      	bne.n	c0d009bc <_vsnprintf+0x494>
c0d009d0:	e77d      	b.n	c0d008ce <_vsnprintf+0x3a6>
c0d009d2:	9010      	str	r0, [sp, #64]	; 0x40
                out((char) va_arg(va, int), buffer, idx++, maxlen);
c0d009d4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d009d6:	7800      	ldrb	r0, [r0, #0]
c0d009d8:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d009da:	463a      	mov	r2, r7
c0d009dc:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d009de:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d009e0:	47b0      	blx	r6
c0d009e2:	1c7f      	adds	r7, r7, #1
c0d009e4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d009e6:	1d00      	adds	r0, r0, #4
c0d009e8:	9013      	str	r0, [sp, #76]	; 0x4c
                if (flags & FLAGS_LEFT) {
c0d009ea:	2d00      	cmp	r5, #0
c0d009ec:	d010      	beq.n	c0d00a10 <_vsnprintf+0x4e8>
c0d009ee:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d009f0:	42a0      	cmp	r0, r4
c0d009f2:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d009f4:	d300      	bcc.n	c0d009f8 <_vsnprintf+0x4d0>
c0d009f6:	e76a      	b.n	c0d008ce <_vsnprintf+0x3a6>
                    while (l++ < width) {
c0d009f8:	1a24      	subs	r4, r4, r0
c0d009fa:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d009fc:	2020      	movs	r0, #32
                        out(' ', buffer, idx++, maxlen);
c0d009fe:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00a00:	463a      	mov	r2, r7
c0d00a02:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00a04:	47a8      	blx	r5
                    while (l++ < width) {
c0d00a06:	1e64      	subs	r4, r4, #1
                        out(' ', buffer, idx++, maxlen);
c0d00a08:	1c7f      	adds	r7, r7, #1
                    while (l++ < width) {
c0d00a0a:	2c00      	cmp	r4, #0
c0d00a0c:	d1f6      	bne.n	c0d009fc <_vsnprintf+0x4d4>
c0d00a0e:	e75e      	b.n	c0d008ce <_vsnprintf+0x3a6>
c0d00a10:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d00a12:	e75c      	b.n	c0d008ce <_vsnprintf+0x3a6>
                                ? (unsigned char) va_arg(va, unsigned int)
c0d00a14:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d00a16:	7800      	ldrb	r0, [r0, #0]
c0d00a18:	2200      	movs	r2, #0
c0d00a1a:	9000      	str	r0, [sp, #0]
c0d00a1c:	9201      	str	r2, [sp, #4]
c0d00a1e:	9102      	str	r1, [sp, #8]
c0d00a20:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d00a22:	a903      	add	r1, sp, #12
c0d00a24:	c131      	stmia	r1!, {r0, r4, r5}
c0d00a26:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d00a28:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00a2a:	463a      	mov	r2, r7
c0d00a2c:	9b16      	ldr	r3, [sp, #88]	; 0x58
c0d00a2e:	f000 f887 	bl	c0d00b40 <_ntoa_long>
c0d00a32:	4607      	mov	r7, r0
c0d00a34:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d00a36:	1d00      	adds	r0, r0, #4
c0d00a38:	e748      	b.n	c0d008cc <_vsnprintf+0x3a4>
c0d00a3a:	9b16      	ldr	r3, [sp, #88]	; 0x58
                break;
        }
    }

    // termination
    out((char) 0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
c0d00a3c:	429f      	cmp	r7, r3
c0d00a3e:	463a      	mov	r2, r7
c0d00a40:	d300      	bcc.n	c0d00a44 <_vsnprintf+0x51c>
c0d00a42:	1e5a      	subs	r2, r3, #1
c0d00a44:	2000      	movs	r0, #0
c0d00a46:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d00a48:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d00a4a:	47a0      	blx	r4

    // return written chars without terminating \0
    return (int) idx;
c0d00a4c:	4638      	mov	r0, r7
c0d00a4e:	b017      	add	sp, #92	; 0x5c
c0d00a50:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00a52 <_out_buffer>:
    if (idx < maxlen) {
c0d00a52:	429a      	cmp	r2, r3
c0d00a54:	d200      	bcs.n	c0d00a58 <_out_buffer+0x6>
        ((char*) buffer)[idx] = character;
c0d00a56:	5488      	strb	r0, [r1, r2]
}
c0d00a58:	4770      	bx	lr
	...

c0d00a5c <vsnprintf_>:
int vprintf_(const char* format, va_list va) {
    char buffer[1];
    return _vsnprintf(_out_char, buffer, (size_t) -1, format, va);
}

int vsnprintf_(char* buffer, size_t count, const char* format, va_list va) {
c0d00a5c:	b510      	push	{r4, lr}
c0d00a5e:	b082      	sub	sp, #8
c0d00a60:	4614      	mov	r4, r2
c0d00a62:	460a      	mov	r2, r1
c0d00a64:	4601      	mov	r1, r0
    return _vsnprintf(_out_buffer, buffer, count, format, va);
c0d00a66:	9300      	str	r3, [sp, #0]
c0d00a68:	4803      	ldr	r0, [pc, #12]	; (c0d00a78 <vsnprintf_+0x1c>)
c0d00a6a:	4478      	add	r0, pc
c0d00a6c:	4623      	mov	r3, r4
c0d00a6e:	f7ff fd5b 	bl	c0d00528 <_vsnprintf>
c0d00a72:	b002      	add	sp, #8
c0d00a74:	bd10      	pop	{r4, pc}
c0d00a76:	46c0      	nop			; (mov r8, r8)
c0d00a78:	ffffffe5 	.word	0xffffffe5

c0d00a7c <_out_null>:
}
c0d00a7c:	4770      	bx	lr

c0d00a7e <_ntoa_long_long>:
                              unsigned int flags) {
c0d00a7e:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00a80:	b09d      	sub	sp, #116	; 0x74
c0d00a82:	9d23      	ldr	r5, [sp, #140]	; 0x8c
c0d00a84:	9f22      	ldr	r7, [sp, #136]	; 0x88
c0d00a86:	9714      	str	r7, [sp, #80]	; 0x50
    if (!value) {
c0d00a88:	432f      	orrs	r7, r5
c0d00a8a:	9c2a      	ldr	r4, [sp, #168]	; 0xa8
c0d00a8c:	900c      	str	r0, [sp, #48]	; 0x30
c0d00a8e:	d103      	bne.n	c0d00a98 <_ntoa_long_long+0x1a>
c0d00a90:	4620      	mov	r0, r4
c0d00a92:	2410      	movs	r4, #16
c0d00a94:	43a0      	bics	r0, r4
c0d00a96:	4604      	mov	r4, r0
c0d00a98:	9826      	ldr	r0, [sp, #152]	; 0x98
c0d00a9a:	9011      	str	r0, [sp, #68]	; 0x44
c0d00a9c:	9829      	ldr	r0, [sp, #164]	; 0xa4
c0d00a9e:	9008      	str	r0, [sp, #32]
c0d00aa0:	9828      	ldr	r0, [sp, #160]	; 0xa0
c0d00aa2:	9009      	str	r0, [sp, #36]	; 0x24
c0d00aa4:	9824      	ldr	r0, [sp, #144]	; 0x90
    if (!(flags & FLAGS_PRECISION) || value) {
c0d00aa6:	900a      	str	r0, [sp, #40]	; 0x28
c0d00aa8:	2f00      	cmp	r7, #0
c0d00aaa:	930f      	str	r3, [sp, #60]	; 0x3c
c0d00aac:	920e      	str	r2, [sp, #56]	; 0x38
c0d00aae:	910d      	str	r1, [sp, #52]	; 0x34
c0d00ab0:	940b      	str	r4, [sp, #44]	; 0x2c
c0d00ab2:	d106      	bne.n	c0d00ac2 <_ntoa_long_long+0x44>
c0d00ab4:	2001      	movs	r0, #1
c0d00ab6:	0280      	lsls	r0, r0, #10
c0d00ab8:	4020      	ands	r0, r4
c0d00aba:	d002      	beq.n	c0d00ac2 <_ntoa_long_long+0x44>
c0d00abc:	2400      	movs	r4, #0
c0d00abe:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d00ac0:	e02c      	b.n	c0d00b1c <_ntoa_long_long+0x9e>
c0d00ac2:	9e27      	ldr	r6, [sp, #156]	; 0x9c
c0d00ac4:	2020      	movs	r0, #32
c0d00ac6:	4020      	ands	r0, r4
c0d00ac8:	2161      	movs	r1, #97	; 0x61
c0d00aca:	4041      	eors	r1, r0
c0d00acc:	31f6      	adds	r1, #246	; 0xf6
c0d00ace:	9110      	str	r1, [sp, #64]	; 0x40
c0d00ad0:	2400      	movs	r4, #0
c0d00ad2:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d00ad4:	9814      	ldr	r0, [sp, #80]	; 0x50
            value /= base;
c0d00ad6:	9014      	str	r0, [sp, #80]	; 0x50
c0d00ad8:	4629      	mov	r1, r5
c0d00ada:	4617      	mov	r7, r2
c0d00adc:	4633      	mov	r3, r6
c0d00ade:	f000 ff5f 	bl	c0d019a0 <__aeabi_uldivmod>
c0d00ae2:	9013      	str	r0, [sp, #76]	; 0x4c
c0d00ae4:	9112      	str	r1, [sp, #72]	; 0x48
c0d00ae6:	463a      	mov	r2, r7
c0d00ae8:	4637      	mov	r7, r6
c0d00aea:	4633      	mov	r3, r6
c0d00aec:	f000 ff78 	bl	c0d019e0 <__aeabi_lmul>
c0d00af0:	9b14      	ldr	r3, [sp, #80]	; 0x50
c0d00af2:	1a18      	subs	r0, r3, r0
c0d00af4:	21fe      	movs	r1, #254	; 0xfe
                digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
c0d00af6:	4001      	ands	r1, r0
c0d00af8:	290a      	cmp	r1, #10
c0d00afa:	d301      	bcc.n	c0d00b00 <_ntoa_long_long+0x82>
c0d00afc:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d00afe:	e000      	b.n	c0d00b02 <_ntoa_long_long+0x84>
c0d00b00:	2130      	movs	r1, #48	; 0x30
c0d00b02:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d00b04:	463e      	mov	r6, r7
c0d00b06:	1808      	adds	r0, r1, r0
c0d00b08:	a915      	add	r1, sp, #84	; 0x54
            buf[len++] =
c0d00b0a:	5508      	strb	r0, [r1, r4]
c0d00b0c:	1c64      	adds	r4, r4, #1
        } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
c0d00b0e:	2c1f      	cmp	r4, #31
c0d00b10:	d804      	bhi.n	c0d00b1c <_ntoa_long_long+0x9e>
c0d00b12:	1a98      	subs	r0, r3, r2
c0d00b14:	41b5      	sbcs	r5, r6
c0d00b16:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d00b18:	9d12      	ldr	r5, [sp, #72]	; 0x48
c0d00b1a:	d2dc      	bcs.n	c0d00ad6 <_ntoa_long_long+0x58>
    return _ntoa_format(out,
c0d00b1c:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00b1e:	9006      	str	r0, [sp, #24]
c0d00b20:	9808      	ldr	r0, [sp, #32]
c0d00b22:	9005      	str	r0, [sp, #20]
c0d00b24:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d00b26:	9004      	str	r0, [sp, #16]
c0d00b28:	9203      	str	r2, [sp, #12]
c0d00b2a:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00b2c:	9002      	str	r0, [sp, #8]
c0d00b2e:	9401      	str	r4, [sp, #4]
c0d00b30:	a815      	add	r0, sp, #84	; 0x54
c0d00b32:	9000      	str	r0, [sp, #0]
c0d00b34:	ab0c      	add	r3, sp, #48	; 0x30
c0d00b36:	cb0f      	ldmia	r3, {r0, r1, r2, r3}
c0d00b38:	f000 fc2e 	bl	c0d01398 <_ntoa_format>
c0d00b3c:	b01d      	add	sp, #116	; 0x74
c0d00b3e:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00b40 <_ntoa_long>:
                         unsigned int flags) {
c0d00b40:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00b42:	b097      	sub	sp, #92	; 0x5c
c0d00b44:	9e21      	ldr	r6, [sp, #132]	; 0x84
c0d00b46:	9d1c      	ldr	r5, [sp, #112]	; 0x70
    if (!value) {
c0d00b48:	2d00      	cmp	r5, #0
c0d00b4a:	930e      	str	r3, [sp, #56]	; 0x38
c0d00b4c:	900b      	str	r0, [sp, #44]	; 0x2c
c0d00b4e:	d101      	bne.n	c0d00b54 <_ntoa_long+0x14>
c0d00b50:	2010      	movs	r0, #16
c0d00b52:	4386      	bics	r6, r0
c0d00b54:	9820      	ldr	r0, [sp, #128]	; 0x80
c0d00b56:	9007      	str	r0, [sp, #28]
c0d00b58:	af1d      	add	r7, sp, #116	; 0x74
c0d00b5a:	cf98      	ldmia	r7, {r3, r4, r7}
    if (!(flags & FLAGS_PRECISION) || value) {
c0d00b5c:	2d00      	cmp	r5, #0
c0d00b5e:	920d      	str	r2, [sp, #52]	; 0x34
c0d00b60:	910c      	str	r1, [sp, #48]	; 0x30
c0d00b62:	960a      	str	r6, [sp, #40]	; 0x28
c0d00b64:	9309      	str	r3, [sp, #36]	; 0x24
c0d00b66:	9708      	str	r7, [sp, #32]
c0d00b68:	d105      	bne.n	c0d00b76 <_ntoa_long+0x36>
c0d00b6a:	2001      	movs	r0, #1
c0d00b6c:	0280      	lsls	r0, r0, #10
c0d00b6e:	4030      	ands	r0, r6
c0d00b70:	d001      	beq.n	c0d00b76 <_ntoa_long+0x36>
c0d00b72:	2700      	movs	r7, #0
c0d00b74:	e01c      	b.n	c0d00bb0 <_ntoa_long+0x70>
c0d00b76:	2020      	movs	r0, #32
c0d00b78:	4030      	ands	r0, r6
c0d00b7a:	2661      	movs	r6, #97	; 0x61
c0d00b7c:	4046      	eors	r6, r0
c0d00b7e:	36f6      	adds	r6, #246	; 0xf6
c0d00b80:	2700      	movs	r7, #0
            value /= base;
c0d00b82:	4628      	mov	r0, r5
c0d00b84:	4621      	mov	r1, r4
c0d00b86:	f000 fd57 	bl	c0d01638 <__udivsi3>
c0d00b8a:	4621      	mov	r1, r4
c0d00b8c:	4341      	muls	r1, r0
c0d00b8e:	1a69      	subs	r1, r5, r1
c0d00b90:	22fe      	movs	r2, #254	; 0xfe
                digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
c0d00b92:	400a      	ands	r2, r1
c0d00b94:	2a0a      	cmp	r2, #10
c0d00b96:	d301      	bcc.n	c0d00b9c <_ntoa_long+0x5c>
c0d00b98:	4632      	mov	r2, r6
c0d00b9a:	e000      	b.n	c0d00b9e <_ntoa_long+0x5e>
c0d00b9c:	2230      	movs	r2, #48	; 0x30
c0d00b9e:	1889      	adds	r1, r1, r2
c0d00ba0:	aa0f      	add	r2, sp, #60	; 0x3c
            buf[len++] =
c0d00ba2:	55d1      	strb	r1, [r2, r7]
c0d00ba4:	1c7f      	adds	r7, r7, #1
        } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
c0d00ba6:	2f1f      	cmp	r7, #31
c0d00ba8:	d802      	bhi.n	c0d00bb0 <_ntoa_long+0x70>
c0d00baa:	42a5      	cmp	r5, r4
c0d00bac:	4605      	mov	r5, r0
c0d00bae:	d2e8      	bcs.n	c0d00b82 <_ntoa_long+0x42>
    return _ntoa_format(out,
c0d00bb0:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00bb2:	9006      	str	r0, [sp, #24]
c0d00bb4:	9807      	ldr	r0, [sp, #28]
c0d00bb6:	9005      	str	r0, [sp, #20]
c0d00bb8:	9808      	ldr	r0, [sp, #32]
c0d00bba:	9004      	str	r0, [sp, #16]
c0d00bbc:	9403      	str	r4, [sp, #12]
c0d00bbe:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d00bc0:	9002      	str	r0, [sp, #8]
c0d00bc2:	9701      	str	r7, [sp, #4]
c0d00bc4:	a80f      	add	r0, sp, #60	; 0x3c
c0d00bc6:	9000      	str	r0, [sp, #0]
c0d00bc8:	ab0b      	add	r3, sp, #44	; 0x2c
c0d00bca:	cb0f      	ldmia	r3, {r0, r1, r2, r3}
c0d00bcc:	f000 fbe4 	bl	c0d01398 <_ntoa_format>
c0d00bd0:	b017      	add	sp, #92	; 0x5c
c0d00bd2:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00bd4 <_ftoa>:
                    unsigned int flags) {
c0d00bd4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00bd6:	b09d      	sub	sp, #116	; 0x74
c0d00bd8:	9313      	str	r3, [sp, #76]	; 0x4c
c0d00bda:	9214      	str	r2, [sp, #80]	; 0x50
c0d00bdc:	460f      	mov	r7, r1
c0d00bde:	4604      	mov	r4, r0
c0d00be0:	9d22      	ldr	r5, [sp, #136]	; 0x88
c0d00be2:	9e23      	ldr	r6, [sp, #140]	; 0x8c
    if (value != value) return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
c0d00be4:	4628      	mov	r0, r5
c0d00be6:	4631      	mov	r1, r6
c0d00be8:	462a      	mov	r2, r5
c0d00bea:	4633      	mov	r3, r6
c0d00bec:	f002 fd4e 	bl	c0d0368c <__aeabi_dcmpun>
c0d00bf0:	9a26      	ldr	r2, [sp, #152]	; 0x98
c0d00bf2:	9b25      	ldr	r3, [sp, #148]	; 0x94
c0d00bf4:	2800      	cmp	r0, #0
c0d00bf6:	d119      	bne.n	c0d00c2c <_ftoa+0x58>
c0d00bf8:	9711      	str	r7, [sp, #68]	; 0x44
c0d00bfa:	9310      	str	r3, [sp, #64]	; 0x40
c0d00bfc:	9212      	str	r2, [sp, #72]	; 0x48
c0d00bfe:	940f      	str	r4, [sp, #60]	; 0x3c
c0d00c00:	2000      	movs	r0, #0
c0d00c02:	43c4      	mvns	r4, r0
c0d00c04:	4be1      	ldr	r3, [pc, #900]	; (c0d00f8c <_ftoa+0x3b8>)
    if (value < -DBL_MAX) return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
c0d00c06:	4628      	mov	r0, r5
c0d00c08:	4631      	mov	r1, r6
c0d00c0a:	4622      	mov	r2, r4
c0d00c0c:	f000 fea0 	bl	c0d01950 <__aeabi_dcmplt>
c0d00c10:	2800      	cmp	r0, #0
c0d00c12:	d01a      	beq.n	c0d00c4a <_ftoa+0x76>
c0d00c14:	2004      	movs	r0, #4
c0d00c16:	49e3      	ldr	r1, [pc, #908]	; (c0d00fa4 <_ftoa+0x3d0>)
c0d00c18:	4479      	add	r1, pc
c0d00c1a:	9100      	str	r1, [sp, #0]
c0d00c1c:	9001      	str	r0, [sp, #4]
c0d00c1e:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d00c20:	9002      	str	r0, [sp, #8]
c0d00c22:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d00c24:	9003      	str	r0, [sp, #12]
c0d00c26:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d00c28:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00c2a:	e008      	b.n	c0d00c3e <_ftoa+0x6a>
c0d00c2c:	2003      	movs	r0, #3
    if (value != value) return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
c0d00c2e:	49dc      	ldr	r1, [pc, #880]	; (c0d00fa0 <_ftoa+0x3cc>)
c0d00c30:	4479      	add	r1, pc
c0d00c32:	9100      	str	r1, [sp, #0]
c0d00c34:	9001      	str	r0, [sp, #4]
c0d00c36:	9302      	str	r3, [sp, #8]
c0d00c38:	9203      	str	r2, [sp, #12]
c0d00c3a:	4620      	mov	r0, r4
c0d00c3c:	4639      	mov	r1, r7
c0d00c3e:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00c40:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d00c42:	f000 fc4c 	bl	c0d014de <_out_rev>
}
c0d00c46:	b01d      	add	sp, #116	; 0x74
c0d00c48:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00c4a:	4bd1      	ldr	r3, [pc, #836]	; (c0d00f90 <_ftoa+0x3bc>)
    if (value > DBL_MAX)
c0d00c4c:	4628      	mov	r0, r5
c0d00c4e:	4631      	mov	r1, r6
c0d00c50:	4622      	mov	r2, r4
c0d00c52:	f000 fe91 	bl	c0d01978 <__aeabi_dcmpgt>
c0d00c56:	2800      	cmp	r0, #0
c0d00c58:	d012      	beq.n	c0d00c80 <_ftoa+0xac>
        return _out_rev(out,
c0d00c5a:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d00c5c:	9002      	str	r0, [sp, #8]
c0d00c5e:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d00c60:	9103      	str	r1, [sp, #12]
c0d00c62:	2004      	movs	r0, #4
                        (flags & FLAGS_PLUS) ? "fni+" : "fni",
c0d00c64:	4001      	ands	r1, r0
                        (flags & FLAGS_PLUS) ? 4U : 3U,
c0d00c66:	d100      	bne.n	c0d00c6a <_ftoa+0x96>
c0d00c68:	2003      	movs	r0, #3
        return _out_rev(out,
c0d00c6a:	9001      	str	r0, [sp, #4]
                        (flags & FLAGS_PLUS) ? "fni+" : "fni",
c0d00c6c:	2900      	cmp	r1, #0
c0d00c6e:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d00c70:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d00c72:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00c74:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00c76:	d000      	beq.n	c0d00c7a <_ftoa+0xa6>
c0d00c78:	e088      	b.n	c0d00d8c <_ftoa+0x1b8>
c0d00c7a:	4ccc      	ldr	r4, [pc, #816]	; (c0d00fac <_ftoa+0x3d8>)
c0d00c7c:	447c      	add	r4, pc
c0d00c7e:	e087      	b.n	c0d00d90 <_ftoa+0x1bc>
c0d00c80:	9824      	ldr	r0, [sp, #144]	; 0x90
    if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
c0d00c82:	900c      	str	r0, [sp, #48]	; 0x30
c0d00c84:	2200      	movs	r2, #0
c0d00c86:	4bc3      	ldr	r3, [pc, #780]	; (c0d00f94 <_ftoa+0x3c0>)
c0d00c88:	4628      	mov	r0, r5
c0d00c8a:	4631      	mov	r1, r6
c0d00c8c:	f000 fe74 	bl	c0d01978 <__aeabi_dcmpgt>
c0d00c90:	2800      	cmp	r0, #0
c0d00c92:	d17f      	bne.n	c0d00d94 <_ftoa+0x1c0>
c0d00c94:	2700      	movs	r7, #0
c0d00c96:	4bc0      	ldr	r3, [pc, #768]	; (c0d00f98 <_ftoa+0x3c4>)
c0d00c98:	4628      	mov	r0, r5
c0d00c9a:	4631      	mov	r1, r6
c0d00c9c:	463a      	mov	r2, r7
c0d00c9e:	f000 fe57 	bl	c0d01950 <__aeabi_dcmplt>
c0d00ca2:	2800      	cmp	r0, #0
c0d00ca4:	d176      	bne.n	c0d00d94 <_ftoa+0x1c0>
    if (value < 0) {
c0d00ca6:	4628      	mov	r0, r5
c0d00ca8:	4631      	mov	r1, r6
c0d00caa:	463a      	mov	r2, r7
c0d00cac:	463b      	mov	r3, r7
c0d00cae:	f000 fe4f 	bl	c0d01950 <__aeabi_dcmplt>
c0d00cb2:	4604      	mov	r4, r0
c0d00cb4:	4638      	mov	r0, r7
c0d00cb6:	970e      	str	r7, [sp, #56]	; 0x38
c0d00cb8:	4639      	mov	r1, r7
c0d00cba:	462a      	mov	r2, r5
c0d00cbc:	960b      	str	r6, [sp, #44]	; 0x2c
c0d00cbe:	4633      	mov	r3, r6
c0d00cc0:	f002 f952 	bl	c0d02f68 <__aeabi_dsub>
c0d00cc4:	900d      	str	r0, [sp, #52]	; 0x34
c0d00cc6:	460f      	mov	r7, r1
c0d00cc8:	2c00      	cmp	r4, #0
c0d00cca:	d100      	bne.n	c0d00cce <_ftoa+0xfa>
c0d00ccc:	9f0b      	ldr	r7, [sp, #44]	; 0x2c
c0d00cce:	2c00      	cmp	r4, #0
c0d00cd0:	9e0c      	ldr	r6, [sp, #48]	; 0x30
c0d00cd2:	d100      	bne.n	c0d00cd6 <_ftoa+0x102>
c0d00cd4:	950d      	str	r5, [sp, #52]	; 0x34
    if (!(flags & FLAGS_PRECISION)) {
c0d00cd6:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d00cd8:	0540      	lsls	r0, r0, #21
c0d00cda:	d400      	bmi.n	c0d00cde <_ftoa+0x10a>
c0d00cdc:	2606      	movs	r6, #6
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d00cde:	2e0a      	cmp	r6, #10
c0d00ce0:	950a      	str	r5, [sp, #40]	; 0x28
c0d00ce2:	d313      	bcc.n	c0d00d0c <_ftoa+0x138>
c0d00ce4:	4630      	mov	r0, r6
c0d00ce6:	380a      	subs	r0, #10
c0d00ce8:	281f      	cmp	r0, #31
c0d00cea:	d300      	bcc.n	c0d00cee <_ftoa+0x11a>
c0d00cec:	201f      	movs	r0, #31
c0d00cee:	1c41      	adds	r1, r0, #1
c0d00cf0:	a815      	add	r0, sp, #84	; 0x54
c0d00cf2:	2230      	movs	r2, #48	; 0x30
        buf[len++] = '0';
c0d00cf4:	f002 fda3 	bl	c0d0383e <__aeabi_memset>
c0d00cf8:	2001      	movs	r0, #1
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d00cfa:	1c41      	adds	r1, r0, #1
        prec--;
c0d00cfc:	1e76      	subs	r6, r6, #1
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
c0d00cfe:	2e0a      	cmp	r6, #10
c0d00d00:	d302      	bcc.n	c0d00d08 <_ftoa+0x134>
c0d00d02:	2820      	cmp	r0, #32
c0d00d04:	4608      	mov	r0, r1
c0d00d06:	d3f8      	bcc.n	c0d00cfa <_ftoa+0x126>
    int whole = (int) value;
c0d00d08:	1e48      	subs	r0, r1, #1
c0d00d0a:	900e      	str	r0, [sp, #56]	; 0x38
c0d00d0c:	9d0d      	ldr	r5, [sp, #52]	; 0x34
c0d00d0e:	4628      	mov	r0, r5
c0d00d10:	4639      	mov	r1, r7
c0d00d12:	f002 fcd9 	bl	c0d036c8 <__aeabi_d2iz>
c0d00d16:	463c      	mov	r4, r7
c0d00d18:	4607      	mov	r7, r0
    double tmp = (value - whole) * pow10[prec];
c0d00d1a:	f002 fd0b 	bl	c0d03734 <__aeabi_i2d>
c0d00d1e:	4602      	mov	r2, r0
c0d00d20:	460b      	mov	r3, r1
c0d00d22:	4628      	mov	r0, r5
c0d00d24:	9406      	str	r4, [sp, #24]
c0d00d26:	4621      	mov	r1, r4
c0d00d28:	f002 f91e 	bl	c0d02f68 <__aeabi_dsub>
c0d00d2c:	00f4      	lsls	r4, r6, #3
c0d00d2e:	4ba0      	ldr	r3, [pc, #640]	; (c0d00fb0 <_ftoa+0x3dc>)
c0d00d30:	447b      	add	r3, pc
c0d00d32:	591a      	ldr	r2, [r3, r4]
c0d00d34:	191b      	adds	r3, r3, r4
c0d00d36:	685b      	ldr	r3, [r3, #4]
c0d00d38:	9209      	str	r2, [sp, #36]	; 0x24
c0d00d3a:	9308      	str	r3, [sp, #32]
c0d00d3c:	f001 fea6 	bl	c0d02a8c <__aeabi_dmul>
c0d00d40:	4604      	mov	r4, r0
    unsigned long frac = (unsigned long) tmp;
c0d00d42:	910c      	str	r1, [sp, #48]	; 0x30
c0d00d44:	f000 fe7a 	bl	c0d01a3c <__aeabi_d2uiz>
c0d00d48:	4605      	mov	r5, r0
    diff = tmp - frac;
c0d00d4a:	f002 fd23 	bl	c0d03794 <__aeabi_ui2d>
c0d00d4e:	4602      	mov	r2, r0
c0d00d50:	460b      	mov	r3, r1
c0d00d52:	4620      	mov	r0, r4
c0d00d54:	990c      	ldr	r1, [sp, #48]	; 0x30
c0d00d56:	f002 f907 	bl	c0d02f68 <__aeabi_dsub>
c0d00d5a:	2400      	movs	r4, #0
c0d00d5c:	4b8f      	ldr	r3, [pc, #572]	; (c0d00f9c <_ftoa+0x3c8>)
c0d00d5e:	900c      	str	r0, [sp, #48]	; 0x30
c0d00d60:	9107      	str	r1, [sp, #28]
    if (diff > 0.5) {
c0d00d62:	4622      	mov	r2, r4
c0d00d64:	f000 fe08 	bl	c0d01978 <__aeabi_dcmpgt>
c0d00d68:	2800      	cmp	r0, #0
c0d00d6a:	d022      	beq.n	c0d00db2 <_ftoa+0x1de>
        ++frac;
c0d00d6c:	1c6d      	adds	r5, r5, #1
        if (frac >= pow10[prec]) {
c0d00d6e:	4628      	mov	r0, r5
c0d00d70:	f002 fd10 	bl	c0d03794 <__aeabi_ui2d>
c0d00d74:	4602      	mov	r2, r0
c0d00d76:	460b      	mov	r3, r1
c0d00d78:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d00d7a:	9908      	ldr	r1, [sp, #32]
c0d00d7c:	f000 fdf2 	bl	c0d01964 <__aeabi_dcmple>
c0d00d80:	2800      	cmp	r0, #0
c0d00d82:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d00d84:	d024      	beq.n	c0d00dd0 <_ftoa+0x1fc>
            ++whole;
c0d00d86:	1c7f      	adds	r7, r7, #1
c0d00d88:	2500      	movs	r5, #0
c0d00d8a:	e021      	b.n	c0d00dd0 <_ftoa+0x1fc>
c0d00d8c:	4c86      	ldr	r4, [pc, #536]	; (c0d00fa8 <_ftoa+0x3d4>)
c0d00d8e:	447c      	add	r4, pc
        return _out_rev(out,
c0d00d90:	9400      	str	r4, [sp, #0]
c0d00d92:	e756      	b.n	c0d00c42 <_ftoa+0x6e>
        return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
c0d00d94:	9500      	str	r5, [sp, #0]
c0d00d96:	9601      	str	r6, [sp, #4]
c0d00d98:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00d9a:	9002      	str	r0, [sp, #8]
c0d00d9c:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d00d9e:	9003      	str	r0, [sp, #12]
c0d00da0:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d00da2:	9004      	str	r0, [sp, #16]
c0d00da4:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d00da6:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00da8:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00daa:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d00dac:	f000 f902 	bl	c0d00fb4 <_etoa>
c0d00db0:	e749      	b.n	c0d00c46 <_ftoa+0x72>
c0d00db2:	2200      	movs	r2, #0
c0d00db4:	4b79      	ldr	r3, [pc, #484]	; (c0d00f9c <_ftoa+0x3c8>)
    } else if (diff < 0.5) {
c0d00db6:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00db8:	9907      	ldr	r1, [sp, #28]
c0d00dba:	f000 fdc9 	bl	c0d01950 <__aeabi_dcmplt>
c0d00dbe:	2800      	cmp	r0, #0
c0d00dc0:	d105      	bne.n	c0d00dce <_ftoa+0x1fa>
    } else if ((frac == 0U) || (frac & 1U)) {
c0d00dc2:	4268      	negs	r0, r5
c0d00dc4:	4168      	adcs	r0, r5
c0d00dc6:	2101      	movs	r1, #1
c0d00dc8:	4029      	ands	r1, r5
c0d00dca:	4301      	orrs	r1, r0
c0d00dcc:	194d      	adds	r5, r1, r5
c0d00dce:	9b0e      	ldr	r3, [sp, #56]	; 0x38
    if (prec == 0U) {
c0d00dd0:	2e00      	cmp	r6, #0
c0d00dd2:	d01b      	beq.n	c0d00e0c <_ftoa+0x238>
c0d00dd4:	960c      	str	r6, [sp, #48]	; 0x30
c0d00dd6:	a815      	add	r0, sp, #84	; 0x54
        while (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d00dd8:	18c0      	adds	r0, r0, r3
c0d00dda:	900d      	str	r0, [sp, #52]	; 0x34
c0d00ddc:	1918      	adds	r0, r3, r4
c0d00dde:	2820      	cmp	r0, #32
c0d00de0:	d028      	beq.n	c0d00e34 <_ftoa+0x260>
c0d00de2:	260a      	movs	r6, #10
            if (!(frac /= 10U)) {
c0d00de4:	4628      	mov	r0, r5
c0d00de6:	4631      	mov	r1, r6
c0d00de8:	f000 fc26 	bl	c0d01638 <__udivsi3>
c0d00dec:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d00dee:	4346      	muls	r6, r0
c0d00df0:	1baa      	subs	r2, r5, r6
c0d00df2:	2130      	movs	r1, #48	; 0x30
            buf[len++] = (char) (48U + (frac % 10U));
c0d00df4:	430a      	orrs	r2, r1
c0d00df6:	9e0d      	ldr	r6, [sp, #52]	; 0x34
c0d00df8:	5532      	strb	r2, [r6, r4]
            if (!(frac /= 10U)) {
c0d00dfa:	1c64      	adds	r4, r4, #1
c0d00dfc:	2d09      	cmp	r5, #9
c0d00dfe:	4605      	mov	r5, r0
c0d00e00:	d8ec      	bhi.n	c0d00ddc <_ftoa+0x208>
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d00e02:	191a      	adds	r2, r3, r4
c0d00e04:	2a20      	cmp	r2, #32
c0d00e06:	d318      	bcc.n	c0d00e3a <_ftoa+0x266>
c0d00e08:	2000      	movs	r0, #0
c0d00e0a:	e017      	b.n	c0d00e3c <_ftoa+0x268>
        diff = value - (double) whole;
c0d00e0c:	4638      	mov	r0, r7
c0d00e0e:	f002 fc91 	bl	c0d03734 <__aeabi_i2d>
c0d00e12:	4602      	mov	r2, r0
c0d00e14:	460b      	mov	r3, r1
c0d00e16:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d00e18:	9906      	ldr	r1, [sp, #24]
c0d00e1a:	f002 f8a5 	bl	c0d02f68 <__aeabi_dsub>
c0d00e1e:	2200      	movs	r2, #0
c0d00e20:	4b5e      	ldr	r3, [pc, #376]	; (c0d00f9c <_ftoa+0x3c8>)
        if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
c0d00e22:	f000 fd95 	bl	c0d01950 <__aeabi_dcmplt>
c0d00e26:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d00e28:	4241      	negs	r1, r0
c0d00e2a:	4141      	adcs	r1, r0
c0d00e2c:	4039      	ands	r1, r7
c0d00e2e:	187f      	adds	r7, r7, r1
c0d00e30:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d00e32:	e02f      	b.n	c0d00e94 <_ftoa+0x2c0>
c0d00e34:	2320      	movs	r3, #32
c0d00e36:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d00e38:	e02c      	b.n	c0d00e94 <_ftoa+0x2c0>
c0d00e3a:	2001      	movs	r0, #1
c0d00e3c:	900d      	str	r0, [sp, #52]	; 0x34
c0d00e3e:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d00e40:	9e0c      	ldr	r6, [sp, #48]	; 0x30
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d00e42:	2a1f      	cmp	r2, #31
c0d00e44:	d81d      	bhi.n	c0d00e82 <_ftoa+0x2ae>
c0d00e46:	42a6      	cmp	r6, r4
c0d00e48:	d01b      	beq.n	c0d00e82 <_ftoa+0x2ae>
            buf[len++] = '0';
c0d00e4a:	1918      	adds	r0, r3, r4
c0d00e4c:	900c      	str	r0, [sp, #48]	; 0x30
c0d00e4e:	a815      	add	r0, sp, #84	; 0x54
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d00e50:	18c3      	adds	r3, r0, r3
c0d00e52:	43e0      	mvns	r0, r4
c0d00e54:	1985      	adds	r5, r0, r6
c0d00e56:	2600      	movs	r6, #0
c0d00e58:	960e      	str	r6, [sp, #56]	; 0x38
            buf[len++] = '0';
c0d00e5a:	1998      	adds	r0, r3, r6
c0d00e5c:	5501      	strb	r1, [r0, r4]
c0d00e5e:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00e60:	1980      	adds	r0, r0, r6
c0d00e62:	1c40      	adds	r0, r0, #1
        while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
c0d00e64:	2820      	cmp	r0, #32
c0d00e66:	d301      	bcc.n	c0d00e6c <_ftoa+0x298>
c0d00e68:	9a0e      	ldr	r2, [sp, #56]	; 0x38
c0d00e6a:	e000      	b.n	c0d00e6e <_ftoa+0x29a>
c0d00e6c:	2201      	movs	r2, #1
c0d00e6e:	920d      	str	r2, [sp, #52]	; 0x34
c0d00e70:	1c72      	adds	r2, r6, #1
c0d00e72:	281f      	cmp	r0, #31
c0d00e74:	d802      	bhi.n	c0d00e7c <_ftoa+0x2a8>
c0d00e76:	42b5      	cmp	r5, r6
c0d00e78:	4616      	mov	r6, r2
c0d00e7a:	d1ee      	bne.n	c0d00e5a <_ftoa+0x286>
        if (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d00e7c:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00e7e:	1882      	adds	r2, r0, r2
c0d00e80:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d00e82:	990d      	ldr	r1, [sp, #52]	; 0x34
c0d00e84:	2900      	cmp	r1, #0
c0d00e86:	d004      	beq.n	c0d00e92 <_ftoa+0x2be>
c0d00e88:	a815      	add	r0, sp, #84	; 0x54
c0d00e8a:	212e      	movs	r1, #46	; 0x2e
            buf[len++] = '.';
c0d00e8c:	5481      	strb	r1, [r0, r2]
c0d00e8e:	1c53      	adds	r3, r2, #1
c0d00e90:	e000      	b.n	c0d00e94 <_ftoa+0x2c0>
c0d00e92:	4613      	mov	r3, r2
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d00e94:	2b1f      	cmp	r3, #31
c0d00e96:	d810      	bhi.n	c0d00eba <_ftoa+0x2e6>
c0d00e98:	240a      	movs	r4, #10
        if (!(whole /= 10)) {
c0d00e9a:	4638      	mov	r0, r7
c0d00e9c:	4621      	mov	r1, r4
c0d00e9e:	461e      	mov	r6, r3
c0d00ea0:	f000 fc54 	bl	c0d0174c <__divsi3>
c0d00ea4:	4633      	mov	r3, r6
c0d00ea6:	4344      	muls	r4, r0
c0d00ea8:	1b39      	subs	r1, r7, r4
        buf[len++] = (char) (48 + (whole % 10));
c0d00eaa:	3130      	adds	r1, #48	; 0x30
c0d00eac:	aa15      	add	r2, sp, #84	; 0x54
c0d00eae:	5591      	strb	r1, [r2, r6]
c0d00eb0:	1c73      	adds	r3, r6, #1
        if (!(whole /= 10)) {
c0d00eb2:	3709      	adds	r7, #9
c0d00eb4:	2f12      	cmp	r7, #18
c0d00eb6:	4607      	mov	r7, r0
c0d00eb8:	d8ec      	bhi.n	c0d00e94 <_ftoa+0x2c0>
c0d00eba:	2003      	movs	r0, #3
c0d00ebc:	9f12      	ldr	r7, [sp, #72]	; 0x48
    if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
c0d00ebe:	4038      	ands	r0, r7
c0d00ec0:	2801      	cmp	r0, #1
c0d00ec2:	d115      	bne.n	c0d00ef0 <_ftoa+0x31c>
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d00ec4:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d00ec6:	2800      	cmp	r0, #0
c0d00ec8:	d017      	beq.n	c0d00efa <_ftoa+0x326>
c0d00eca:	2200      	movs	r2, #0
    if (value < 0) {
c0d00ecc:	4628      	mov	r0, r5
c0d00ece:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d00ed0:	4631      	mov	r1, r6
c0d00ed2:	461d      	mov	r5, r3
c0d00ed4:	4613      	mov	r3, r2
c0d00ed6:	f000 fd3b 	bl	c0d01950 <__aeabi_dcmplt>
c0d00eda:	462b      	mov	r3, r5
c0d00edc:	9c10      	ldr	r4, [sp, #64]	; 0x40
c0d00ede:	210c      	movs	r1, #12
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d00ee0:	4039      	ands	r1, r7
    if (value < 0) {
c0d00ee2:	4301      	orrs	r1, r0
        if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d00ee4:	1e48      	subs	r0, r1, #1
c0d00ee6:	4181      	sbcs	r1, r0
c0d00ee8:	1a64      	subs	r4, r4, r1
c0d00eea:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00eec:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00eee:	e008      	b.n	c0d00f02 <_ftoa+0x32e>
c0d00ef0:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00ef2:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00ef4:	9c10      	ldr	r4, [sp, #64]	; 0x40
c0d00ef6:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d00ef8:	e020      	b.n	c0d00f3c <_ftoa+0x368>
c0d00efa:	2400      	movs	r4, #0
c0d00efc:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00efe:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00f00:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
        while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
c0d00f02:	42a3      	cmp	r3, r4
c0d00f04:	d21a      	bcs.n	c0d00f3c <_ftoa+0x368>
c0d00f06:	2b1f      	cmp	r3, #31
c0d00f08:	d818      	bhi.n	c0d00f3c <_ftoa+0x368>
c0d00f0a:	201f      	movs	r0, #31
c0d00f0c:	1ac0      	subs	r0, r0, r3
c0d00f0e:	43d9      	mvns	r1, r3
c0d00f10:	4625      	mov	r5, r4
c0d00f12:	1861      	adds	r1, r4, r1
c0d00f14:	4281      	cmp	r1, r0
c0d00f16:	d300      	bcc.n	c0d00f1a <_ftoa+0x346>
c0d00f18:	4601      	mov	r1, r0
c0d00f1a:	1c49      	adds	r1, r1, #1
c0d00f1c:	a815      	add	r0, sp, #84	; 0x54
c0d00f1e:	18c0      	adds	r0, r0, r3
c0d00f20:	2230      	movs	r2, #48	; 0x30
c0d00f22:	461e      	mov	r6, r3
            buf[len++] = '0';
c0d00f24:	f002 fc8b 	bl	c0d0383e <__aeabi_memset>
c0d00f28:	4633      	mov	r3, r6
c0d00f2a:	462c      	mov	r4, r5
c0d00f2c:	9e0b      	ldr	r6, [sp, #44]	; 0x2c
c0d00f2e:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00f30:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00f32:	1c5b      	adds	r3, r3, #1
        while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
c0d00f34:	42a3      	cmp	r3, r4
c0d00f36:	d201      	bcs.n	c0d00f3c <_ftoa+0x368>
c0d00f38:	2b20      	cmp	r3, #32
c0d00f3a:	d3fa      	bcc.n	c0d00f32 <_ftoa+0x35e>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
c0d00f3c:	2b1f      	cmp	r3, #31
c0d00f3e:	d81e      	bhi.n	c0d00f7e <_ftoa+0x3aa>
c0d00f40:	461d      	mov	r5, r3
c0d00f42:	2200      	movs	r2, #0
    if (value < 0) {
c0d00f44:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00f46:	4631      	mov	r1, r6
c0d00f48:	4613      	mov	r3, r2
c0d00f4a:	f000 fd01 	bl	c0d01950 <__aeabi_dcmplt>
        if (negative) {
c0d00f4e:	2800      	cmp	r0, #0
c0d00f50:	d002      	beq.n	c0d00f58 <_ftoa+0x384>
c0d00f52:	a815      	add	r0, sp, #84	; 0x54
c0d00f54:	212d      	movs	r1, #45	; 0x2d
c0d00f56:	e00d      	b.n	c0d00f74 <_ftoa+0x3a0>
        } else if (flags & FLAGS_PLUS) {
c0d00f58:	0778      	lsls	r0, r7, #29
c0d00f5a:	d409      	bmi.n	c0d00f70 <_ftoa+0x39c>
        } else if (flags & FLAGS_SPACE) {
c0d00f5c:	0738      	lsls	r0, r7, #28
c0d00f5e:	462b      	mov	r3, r5
c0d00f60:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00f62:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d00f64:	d50b      	bpl.n	c0d00f7e <_ftoa+0x3aa>
c0d00f66:	a815      	add	r0, sp, #84	; 0x54
c0d00f68:	2520      	movs	r5, #32
            buf[len++] = ' ';
c0d00f6a:	54c5      	strb	r5, [r0, r3]
c0d00f6c:	1c5b      	adds	r3, r3, #1
c0d00f6e:	e006      	b.n	c0d00f7e <_ftoa+0x3aa>
c0d00f70:	a815      	add	r0, sp, #84	; 0x54
c0d00f72:	212b      	movs	r1, #43	; 0x2b
c0d00f74:	462b      	mov	r3, r5
c0d00f76:	5541      	strb	r1, [r0, r5]
c0d00f78:	1c6b      	adds	r3, r5, #1
c0d00f7a:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d00f7c:	9911      	ldr	r1, [sp, #68]	; 0x44
    return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
c0d00f7e:	a801      	add	r0, sp, #4
c0d00f80:	c098      	stmia	r0!, {r3, r4, r7}
c0d00f82:	a815      	add	r0, sp, #84	; 0x54
c0d00f84:	9000      	str	r0, [sp, #0]
c0d00f86:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d00f88:	e65a      	b.n	c0d00c40 <_ftoa+0x6c>
c0d00f8a:	46c0      	nop			; (mov r8, r8)
c0d00f8c:	ffefffff 	.word	0xffefffff
c0d00f90:	7fefffff 	.word	0x7fefffff
c0d00f94:	41cdcd65 	.word	0x41cdcd65
c0d00f98:	c1cdcd65 	.word	0xc1cdcd65
c0d00f9c:	3fe00000 	.word	0x3fe00000
c0d00fa0:	00003034 	.word	0x00003034
c0d00fa4:	00003050 	.word	0x00003050
c0d00fa8:	00002edf 	.word	0x00002edf
c0d00fac:	00002ff6 	.word	0x00002ff6
c0d00fb0:	00002ee4 	.word	0x00002ee4

c0d00fb4 <_etoa>:
                    unsigned int flags) {
c0d00fb4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00fb6:	b097      	sub	sp, #92	; 0x5c
c0d00fb8:	930e      	str	r3, [sp, #56]	; 0x38
c0d00fba:	920f      	str	r2, [sp, #60]	; 0x3c
c0d00fbc:	9112      	str	r1, [sp, #72]	; 0x48
c0d00fbe:	4607      	mov	r7, r0
c0d00fc0:	2000      	movs	r0, #0
c0d00fc2:	43c4      	mvns	r4, r0
c0d00fc4:	9d1c      	ldr	r5, [sp, #112]	; 0x70
c0d00fc6:	9e1d      	ldr	r6, [sp, #116]	; 0x74
c0d00fc8:	4bd8      	ldr	r3, [pc, #864]	; (c0d0132c <_etoa+0x378>)
    if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
c0d00fca:	4628      	mov	r0, r5
c0d00fcc:	4631      	mov	r1, r6
c0d00fce:	4622      	mov	r2, r4
c0d00fd0:	f000 fcbe 	bl	c0d01950 <__aeabi_dcmplt>
c0d00fd4:	9920      	ldr	r1, [sp, #128]	; 0x80
c0d00fd6:	9115      	str	r1, [sp, #84]	; 0x54
c0d00fd8:	991f      	ldr	r1, [sp, #124]	; 0x7c
c0d00fda:	9116      	str	r1, [sp, #88]	; 0x58
c0d00fdc:	991e      	ldr	r1, [sp, #120]	; 0x78
c0d00fde:	9113      	str	r1, [sp, #76]	; 0x4c
c0d00fe0:	2800      	cmp	r0, #0
c0d00fe2:	d000      	beq.n	c0d00fe6 <_etoa+0x32>
c0d00fe4:	e0d2      	b.n	c0d0118c <_etoa+0x1d8>
c0d00fe6:	4628      	mov	r0, r5
c0d00fe8:	4631      	mov	r1, r6
c0d00fea:	462a      	mov	r2, r5
c0d00fec:	4633      	mov	r3, r6
c0d00fee:	f002 fb4d 	bl	c0d0368c <__aeabi_dcmpun>
c0d00ff2:	2800      	cmp	r0, #0
c0d00ff4:	d000      	beq.n	c0d00ff8 <_etoa+0x44>
c0d00ff6:	e0c9      	b.n	c0d0118c <_etoa+0x1d8>
c0d00ff8:	4bcd      	ldr	r3, [pc, #820]	; (c0d01330 <_etoa+0x37c>)
c0d00ffa:	4628      	mov	r0, r5
c0d00ffc:	4631      	mov	r1, r6
c0d00ffe:	4622      	mov	r2, r4
c0d01000:	f000 fcba 	bl	c0d01978 <__aeabi_dcmpgt>
c0d01004:	2800      	cmp	r0, #0
c0d01006:	d000      	beq.n	c0d0100a <_etoa+0x56>
c0d01008:	e0c0      	b.n	c0d0118c <_etoa+0x1d8>
c0d0100a:	2200      	movs	r2, #0
c0d0100c:	950d      	str	r5, [sp, #52]	; 0x34
    const bool negative = value < 0;
c0d0100e:	4628      	mov	r0, r5
c0d01010:	4631      	mov	r1, r6
c0d01012:	9214      	str	r2, [sp, #80]	; 0x50
c0d01014:	4613      	mov	r3, r2
c0d01016:	f000 fc9b 	bl	c0d01950 <__aeabi_dcmplt>
c0d0101a:	2101      	movs	r1, #1
c0d0101c:	910b      	str	r1, [sp, #44]	; 0x2c
c0d0101e:	07c9      	lsls	r1, r1, #31
    if (negative) {
c0d01020:	2800      	cmp	r0, #0
c0d01022:	9709      	str	r7, [sp, #36]	; 0x24
c0d01024:	9107      	str	r1, [sp, #28]
c0d01026:	9608      	str	r6, [sp, #32]
c0d01028:	4630      	mov	r0, r6
c0d0102a:	d000      	beq.n	c0d0102e <_etoa+0x7a>
c0d0102c:	4048      	eors	r0, r1
c0d0102e:	9011      	str	r0, [sp, #68]	; 0x44
c0d01030:	4ec0      	ldr	r6, [pc, #768]	; (c0d01334 <_etoa+0x380>)
    conv.U = (conv.U & ((1ULL << 52U) - 1U)) |
c0d01032:	4006      	ands	r6, r0
    int exp2 = (int) ((conv.U >> 52U) & 0x07FFU) - 1023;  // effectively log2
c0d01034:	0040      	lsls	r0, r0, #1
c0d01036:	0d40      	lsrs	r0, r0, #21
c0d01038:	49bf      	ldr	r1, [pc, #764]	; (c0d01338 <_etoa+0x384>)
c0d0103a:	1840      	adds	r0, r0, r1
        (int) (0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
c0d0103c:	f002 fb7a 	bl	c0d03734 <__aeabi_i2d>
c0d01040:	4abe      	ldr	r2, [pc, #760]	; (c0d0133c <_etoa+0x388>)
c0d01042:	4bbf      	ldr	r3, [pc, #764]	; (c0d01340 <_etoa+0x38c>)
c0d01044:	f001 fd22 	bl	c0d02a8c <__aeabi_dmul>
c0d01048:	4abe      	ldr	r2, [pc, #760]	; (c0d01344 <_etoa+0x390>)
c0d0104a:	4bbf      	ldr	r3, [pc, #764]	; (c0d01348 <_etoa+0x394>)
c0d0104c:	f000 fde0 	bl	c0d01c10 <__aeabi_dadd>
c0d01050:	4604      	mov	r4, r0
c0d01052:	460d      	mov	r5, r1
c0d01054:	48bd      	ldr	r0, [pc, #756]	; (c0d0134c <_etoa+0x398>)
    conv.U = (conv.U & ((1ULL << 52U) - 1U)) |
c0d01056:	1831      	adds	r1, r6, r0
c0d01058:	4bbd      	ldr	r3, [pc, #756]	; (c0d01350 <_etoa+0x39c>)
        (int) (0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
c0d0105a:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d0105c:	9e14      	ldr	r6, [sp, #80]	; 0x50
c0d0105e:	4632      	mov	r2, r6
c0d01060:	f000 fdd6 	bl	c0d01c10 <__aeabi_dadd>
c0d01064:	4abb      	ldr	r2, [pc, #748]	; (c0d01354 <_etoa+0x3a0>)
c0d01066:	4bbc      	ldr	r3, [pc, #752]	; (c0d01358 <_etoa+0x3a4>)
c0d01068:	f001 fd10 	bl	c0d02a8c <__aeabi_dmul>
c0d0106c:	4622      	mov	r2, r4
c0d0106e:	462b      	mov	r3, r5
c0d01070:	f000 fdce 	bl	c0d01c10 <__aeabi_dadd>
c0d01074:	f002 fb28 	bl	c0d036c8 <__aeabi_d2iz>
c0d01078:	900c      	str	r0, [sp, #48]	; 0x30
    exp2 = (int) (expval * 3.321928094887362 + 0.5);
c0d0107a:	f002 fb5b 	bl	c0d03734 <__aeabi_i2d>
c0d0107e:	4604      	mov	r4, r0
c0d01080:	460d      	mov	r5, r1
c0d01082:	4ab6      	ldr	r2, [pc, #728]	; (c0d0135c <_etoa+0x3a8>)
c0d01084:	4bb6      	ldr	r3, [pc, #728]	; (c0d01360 <_etoa+0x3ac>)
c0d01086:	f001 fd01 	bl	c0d02a8c <__aeabi_dmul>
c0d0108a:	4bb6      	ldr	r3, [pc, #728]	; (c0d01364 <_etoa+0x3b0>)
c0d0108c:	4632      	mov	r2, r6
c0d0108e:	f000 fdbf 	bl	c0d01c10 <__aeabi_dadd>
c0d01092:	f002 fb19 	bl	c0d036c8 <__aeabi_d2iz>
c0d01096:	4606      	mov	r6, r0
    const double z = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
c0d01098:	9010      	str	r0, [sp, #64]	; 0x40
c0d0109a:	4ab3      	ldr	r2, [pc, #716]	; (c0d01368 <_etoa+0x3b4>)
c0d0109c:	4bb3      	ldr	r3, [pc, #716]	; (c0d0136c <_etoa+0x3b8>)
c0d0109e:	4620      	mov	r0, r4
c0d010a0:	4629      	mov	r1, r5
c0d010a2:	f001 fcf3 	bl	c0d02a8c <__aeabi_dmul>
c0d010a6:	4604      	mov	r4, r0
c0d010a8:	460d      	mov	r5, r1
c0d010aa:	4630      	mov	r0, r6
c0d010ac:	f002 fb42 	bl	c0d03734 <__aeabi_i2d>
c0d010b0:	4aaf      	ldr	r2, [pc, #700]	; (c0d01370 <_etoa+0x3bc>)
c0d010b2:	4bb0      	ldr	r3, [pc, #704]	; (c0d01374 <_etoa+0x3c0>)
c0d010b4:	f001 fcea 	bl	c0d02a8c <__aeabi_dmul>
c0d010b8:	4602      	mov	r2, r0
c0d010ba:	460b      	mov	r3, r1
c0d010bc:	4620      	mov	r0, r4
c0d010be:	4629      	mov	r1, r5
c0d010c0:	f000 fda6 	bl	c0d01c10 <__aeabi_dadd>
c0d010c4:	4606      	mov	r6, r0
    const double z2 = z * z;
c0d010c6:	910a      	str	r1, [sp, #40]	; 0x28
c0d010c8:	4602      	mov	r2, r0
c0d010ca:	460b      	mov	r3, r1
c0d010cc:	f001 fcde 	bl	c0d02a8c <__aeabi_dmul>
c0d010d0:	4605      	mov	r5, r0
c0d010d2:	460f      	mov	r7, r1
c0d010d4:	4ba8      	ldr	r3, [pc, #672]	; (c0d01378 <_etoa+0x3c4>)
c0d010d6:	9c14      	ldr	r4, [sp, #80]	; 0x50
    conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
c0d010d8:	4622      	mov	r2, r4
c0d010da:	f001 f8d5 	bl	c0d02288 <__aeabi_ddiv>
c0d010de:	4ba7      	ldr	r3, [pc, #668]	; (c0d0137c <_etoa+0x3c8>)
c0d010e0:	4622      	mov	r2, r4
c0d010e2:	f000 fd95 	bl	c0d01c10 <__aeabi_dadd>
c0d010e6:	4602      	mov	r2, r0
c0d010e8:	460b      	mov	r3, r1
c0d010ea:	4628      	mov	r0, r5
c0d010ec:	4639      	mov	r1, r7
c0d010ee:	f001 f8cb 	bl	c0d02288 <__aeabi_ddiv>
c0d010f2:	4ba3      	ldr	r3, [pc, #652]	; (c0d01380 <_etoa+0x3cc>)
c0d010f4:	4622      	mov	r2, r4
c0d010f6:	f000 fd8b 	bl	c0d01c10 <__aeabi_dadd>
c0d010fa:	4602      	mov	r2, r0
c0d010fc:	460b      	mov	r3, r1
c0d010fe:	4628      	mov	r0, r5
c0d01100:	4639      	mov	r1, r7
c0d01102:	f001 f8c1 	bl	c0d02288 <__aeabi_ddiv>
c0d01106:	4605      	mov	r5, r0
c0d01108:	460f      	mov	r7, r1
c0d0110a:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d0110c:	0781      	lsls	r1, r0, #30
c0d0110e:	4620      	mov	r0, r4
c0d01110:	4632      	mov	r2, r6
c0d01112:	9c0a      	ldr	r4, [sp, #40]	; 0x28
c0d01114:	4623      	mov	r3, r4
c0d01116:	f001 ff27 	bl	c0d02f68 <__aeabi_dsub>
c0d0111a:	462a      	mov	r2, r5
c0d0111c:	463b      	mov	r3, r7
c0d0111e:	f000 fd77 	bl	c0d01c10 <__aeabi_dadd>
c0d01122:	4605      	mov	r5, r0
c0d01124:	460f      	mov	r7, r1
c0d01126:	4630      	mov	r0, r6
c0d01128:	4621      	mov	r1, r4
c0d0112a:	4632      	mov	r2, r6
c0d0112c:	9e0d      	ldr	r6, [sp, #52]	; 0x34
c0d0112e:	4623      	mov	r3, r4
c0d01130:	f000 fd6e 	bl	c0d01c10 <__aeabi_dadd>
c0d01134:	462a      	mov	r2, r5
c0d01136:	463b      	mov	r3, r7
c0d01138:	f001 f8a6 	bl	c0d02288 <__aeabi_ddiv>
c0d0113c:	9d14      	ldr	r5, [sp, #80]	; 0x50
c0d0113e:	462a      	mov	r2, r5
c0d01140:	4b82      	ldr	r3, [pc, #520]	; (c0d0134c <_etoa+0x398>)
c0d01142:	f000 fd65 	bl	c0d01c10 <__aeabi_dadd>
c0d01146:	4c8f      	ldr	r4, [pc, #572]	; (c0d01384 <_etoa+0x3d0>)
    conv.U = (uint64_t)(exp2 + 1023) << 52U;
c0d01148:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d0114a:	1912      	adds	r2, r2, r4
c0d0114c:	0513      	lsls	r3, r2, #20
    conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
c0d0114e:	462a      	mov	r2, r5
c0d01150:	f001 fc9c 	bl	c0d02a8c <__aeabi_dmul>
c0d01154:	4602      	mov	r2, r0
c0d01156:	460b      	mov	r3, r1
    if (value < conv.F) {
c0d01158:	4630      	mov	r0, r6
c0d0115a:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d0115c:	4617      	mov	r7, r2
c0d0115e:	930a      	str	r3, [sp, #40]	; 0x28
c0d01160:	f000 fbf6 	bl	c0d01950 <__aeabi_dcmplt>
    if (!(flags & FLAGS_PRECISION)) {
c0d01164:	1c61      	adds	r1, r4, #1
c0d01166:	9d15      	ldr	r5, [sp, #84]	; 0x54
c0d01168:	400d      	ands	r5, r1
c0d0116a:	9106      	str	r1, [sp, #24]
c0d0116c:	d101      	bne.n	c0d01172 <_etoa+0x1be>
c0d0116e:	2106      	movs	r1, #6
c0d01170:	9113      	str	r1, [sp, #76]	; 0x4c
    if (value < conv.F) {
c0d01172:	2800      	cmp	r0, #0
c0d01174:	d01a      	beq.n	c0d011ac <_etoa+0x1f8>
c0d01176:	2200      	movs	r2, #0
c0d01178:	4b80      	ldr	r3, [pc, #512]	; (c0d0137c <_etoa+0x3c8>)
        conv.F /= 10;
c0d0117a:	4638      	mov	r0, r7
c0d0117c:	990a      	ldr	r1, [sp, #40]	; 0x28
c0d0117e:	f001 f883 	bl	c0d02288 <__aeabi_ddiv>
c0d01182:	4607      	mov	r7, r0
c0d01184:	910a      	str	r1, [sp, #40]	; 0x28
c0d01186:	9a0c      	ldr	r2, [sp, #48]	; 0x30
        expval--;
c0d01188:	1e52      	subs	r2, r2, #1
c0d0118a:	e010      	b.n	c0d011ae <_etoa+0x1fa>
        return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
c0d0118c:	9500      	str	r5, [sp, #0]
c0d0118e:	9601      	str	r6, [sp, #4]
c0d01190:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d01192:	9002      	str	r0, [sp, #8]
c0d01194:	9816      	ldr	r0, [sp, #88]	; 0x58
c0d01196:	9003      	str	r0, [sp, #12]
c0d01198:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d0119a:	9004      	str	r0, [sp, #16]
c0d0119c:	4638      	mov	r0, r7
c0d0119e:	9912      	ldr	r1, [sp, #72]	; 0x48
c0d011a0:	9a0f      	ldr	r2, [sp, #60]	; 0x3c
c0d011a2:	9b0e      	ldr	r3, [sp, #56]	; 0x38
c0d011a4:	f7ff fd16 	bl	c0d00bd4 <_ftoa>
c0d011a8:	4604      	mov	r4, r0
c0d011aa:	e0bc      	b.n	c0d01326 <_etoa+0x372>
c0d011ac:	9a0c      	ldr	r2, [sp, #48]	; 0x30
c0d011ae:	4876      	ldr	r0, [pc, #472]	; (c0d01388 <_etoa+0x3d4>)
    unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
c0d011b0:	4611      	mov	r1, r2
c0d011b2:	3163      	adds	r1, #99	; 0x63
c0d011b4:	29c7      	cmp	r1, #199	; 0xc7
c0d011b6:	d301      	bcc.n	c0d011bc <_etoa+0x208>
c0d011b8:	2305      	movs	r3, #5
c0d011ba:	e000      	b.n	c0d011be <_etoa+0x20a>
c0d011bc:	2304      	movs	r3, #4
    if (flags & FLAGS_ADAPT_EXP) {
c0d011be:	1c40      	adds	r0, r0, #1
c0d011c0:	9915      	ldr	r1, [sp, #84]	; 0x54
c0d011c2:	4201      	tst	r1, r0
c0d011c4:	9310      	str	r3, [sp, #64]	; 0x40
c0d011c6:	d018      	beq.n	c0d011fa <_etoa+0x246>
c0d011c8:	920c      	str	r2, [sp, #48]	; 0x30
c0d011ca:	4a70      	ldr	r2, [pc, #448]	; (c0d0138c <_etoa+0x3d8>)
c0d011cc:	4b70      	ldr	r3, [pc, #448]	; (c0d01390 <_etoa+0x3dc>)
        if ((value >= 1e-4) && (value < 1e6)) {
c0d011ce:	4630      	mov	r0, r6
c0d011d0:	9c11      	ldr	r4, [sp, #68]	; 0x44
c0d011d2:	4621      	mov	r1, r4
c0d011d4:	f000 fbda 	bl	c0d0198c <__aeabi_dcmpge>
c0d011d8:	2800      	cmp	r0, #0
c0d011da:	d010      	beq.n	c0d011fe <_etoa+0x24a>
c0d011dc:	4630      	mov	r0, r6
c0d011de:	2600      	movs	r6, #0
c0d011e0:	4b6c      	ldr	r3, [pc, #432]	; (c0d01394 <_etoa+0x3e0>)
c0d011e2:	4621      	mov	r1, r4
c0d011e4:	4632      	mov	r2, r6
c0d011e6:	f000 fbb3 	bl	c0d01950 <__aeabi_dcmplt>
c0d011ea:	2800      	cmp	r0, #0
c0d011ec:	d007      	beq.n	c0d011fe <_etoa+0x24a>
c0d011ee:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d011f0:	9c0c      	ldr	r4, [sp, #48]	; 0x30
            if ((int) prec > expval) {
c0d011f2:	42a1      	cmp	r1, r4
c0d011f4:	dc0a      	bgt.n	c0d0120c <_etoa+0x258>
c0d011f6:	9613      	str	r6, [sp, #76]	; 0x4c
c0d011f8:	e00b      	b.n	c0d01212 <_etoa+0x25e>
c0d011fa:	4616      	mov	r6, r2
c0d011fc:	e015      	b.n	c0d0122a <_etoa+0x276>
c0d011fe:	9913      	ldr	r1, [sp, #76]	; 0x4c
            if ((prec > 0) && (flags & FLAGS_PRECISION)) {
c0d01200:	2900      	cmp	r1, #0
c0d01202:	d00f      	beq.n	c0d01224 <_etoa+0x270>
c0d01204:	0aa8      	lsrs	r0, r5, #10
c0d01206:	1a09      	subs	r1, r1, r0
c0d01208:	9113      	str	r1, [sp, #76]	; 0x4c
c0d0120a:	e00d      	b.n	c0d01228 <_etoa+0x274>
c0d0120c:	43e0      	mvns	r0, r4
c0d0120e:	1809      	adds	r1, r1, r0
c0d01210:	9113      	str	r1, [sp, #76]	; 0x4c
c0d01212:	463a      	mov	r2, r7
c0d01214:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d01216:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d01218:	9c06      	ldr	r4, [sp, #24]
            flags |= FLAGS_PRECISION;  // make sure _ftoa respects precision
c0d0121a:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d0121c:	4320      	orrs	r0, r4
c0d0121e:	9015      	str	r0, [sp, #84]	; 0x54
c0d01220:	9610      	str	r6, [sp, #64]	; 0x40
c0d01222:	e005      	b.n	c0d01230 <_etoa+0x27c>
c0d01224:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d01226:	9013      	str	r0, [sp, #76]	; 0x4c
c0d01228:	9e0c      	ldr	r6, [sp, #48]	; 0x30
c0d0122a:	463a      	mov	r2, r7
c0d0122c:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d0122e:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d01230:	9d0d      	ldr	r5, [sp, #52]	; 0x34
    if (expval) {
c0d01232:	4628      	mov	r0, r5
c0d01234:	f001 f828 	bl	c0d02288 <__aeabi_ddiv>
c0d01238:	4607      	mov	r7, r0
c0d0123a:	460c      	mov	r4, r1
    const bool negative = value < 0;
c0d0123c:	4628      	mov	r0, r5
c0d0123e:	9908      	ldr	r1, [sp, #32]
c0d01240:	9a14      	ldr	r2, [sp, #80]	; 0x50
c0d01242:	4613      	mov	r3, r2
c0d01244:	f000 fb84 	bl	c0d01950 <__aeabi_dcmplt>
    idx = _ftoa(out,
c0d01248:	9913      	ldr	r1, [sp, #76]	; 0x4c
c0d0124a:	9102      	str	r1, [sp, #8]
c0d0124c:	990b      	ldr	r1, [sp, #44]	; 0x2c
c0d0124e:	02c9      	lsls	r1, r1, #11
                flags & ~FLAGS_ADAPT_EXP);
c0d01250:	9a15      	ldr	r2, [sp, #84]	; 0x54
c0d01252:	438a      	bics	r2, r1
    idx = _ftoa(out,
c0d01254:	9204      	str	r2, [sp, #16]
    if (expval) {
c0d01256:	2e00      	cmp	r6, #0
c0d01258:	d000      	beq.n	c0d0125c <_etoa+0x2a8>
c0d0125a:	463d      	mov	r5, r7
    idx = _ftoa(out,
c0d0125c:	9500      	str	r5, [sp, #0]
    if (width > minwidth) {
c0d0125e:	9916      	ldr	r1, [sp, #88]	; 0x58
c0d01260:	9b10      	ldr	r3, [sp, #64]	; 0x40
c0d01262:	1ac9      	subs	r1, r1, r3
c0d01264:	9a0f      	ldr	r2, [sp, #60]	; 0x3c
c0d01266:	d200      	bcs.n	c0d0126a <_etoa+0x2b6>
c0d01268:	9914      	ldr	r1, [sp, #80]	; 0x50
    if ((flags & FLAGS_LEFT) && minwidth) {
c0d0126a:	2b00      	cmp	r3, #0
c0d0126c:	9d11      	ldr	r5, [sp, #68]	; 0x44
c0d0126e:	d100      	bne.n	c0d01272 <_etoa+0x2be>
c0d01270:	9114      	str	r1, [sp, #80]	; 0x50
c0d01272:	2702      	movs	r7, #2
c0d01274:	9b15      	ldr	r3, [sp, #84]	; 0x54
c0d01276:	401f      	ands	r7, r3
c0d01278:	9713      	str	r7, [sp, #76]	; 0x4c
c0d0127a:	d100      	bne.n	c0d0127e <_etoa+0x2ca>
c0d0127c:	9114      	str	r1, [sp, #80]	; 0x50
    idx = _ftoa(out,
c0d0127e:	9914      	ldr	r1, [sp, #80]	; 0x50
c0d01280:	9103      	str	r1, [sp, #12]
    if (expval) {
c0d01282:	2e00      	cmp	r6, #0
c0d01284:	d000      	beq.n	c0d01288 <_etoa+0x2d4>
c0d01286:	4625      	mov	r5, r4
                negative ? -value : value,
c0d01288:	2800      	cmp	r0, #0
c0d0128a:	d001      	beq.n	c0d01290 <_etoa+0x2dc>
c0d0128c:	9807      	ldr	r0, [sp, #28]
c0d0128e:	4045      	eors	r5, r0
c0d01290:	9809      	ldr	r0, [sp, #36]	; 0x24
    idx = _ftoa(out,
c0d01292:	9501      	str	r5, [sp, #4]
c0d01294:	9f12      	ldr	r7, [sp, #72]	; 0x48
c0d01296:	4639      	mov	r1, r7
c0d01298:	9d0e      	ldr	r5, [sp, #56]	; 0x38
c0d0129a:	462b      	mov	r3, r5
c0d0129c:	f7ff fc9a 	bl	c0d00bd4 <_ftoa>
c0d012a0:	4604      	mov	r4, r0
c0d012a2:	9b10      	ldr	r3, [sp, #64]	; 0x40
    if (minwidth) {
c0d012a4:	2b00      	cmp	r3, #0
c0d012a6:	d03e      	beq.n	c0d01326 <_etoa+0x372>
c0d012a8:	2020      	movs	r0, #32
c0d012aa:	9915      	ldr	r1, [sp, #84]	; 0x54
        out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
c0d012ac:	4001      	ands	r1, r0
c0d012ae:	2065      	movs	r0, #101	; 0x65
c0d012b0:	4048      	eors	r0, r1
c0d012b2:	4639      	mov	r1, r7
c0d012b4:	4622      	mov	r2, r4
c0d012b6:	9310      	str	r3, [sp, #64]	; 0x40
c0d012b8:	462b      	mov	r3, r5
c0d012ba:	9f09      	ldr	r7, [sp, #36]	; 0x24
c0d012bc:	47b8      	blx	r7
c0d012be:	2005      	movs	r0, #5
                         minwidth - 1,
c0d012c0:	9015      	str	r0, [sp, #84]	; 0x54
c0d012c2:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d012c4:	1e40      	subs	r0, r0, #1
c0d012c6:	9014      	str	r0, [sp, #80]	; 0x50
c0d012c8:	2200      	movs	r2, #0
c0d012ca:	230a      	movs	r3, #10
        idx = _ntoa_long(out,
c0d012cc:	0ff1      	lsrs	r1, r6, #31
                         (expval < 0) ? -expval : expval,
c0d012ce:	17f0      	asrs	r0, r6, #31
c0d012d0:	1836      	adds	r6, r6, r0
c0d012d2:	4046      	eors	r6, r0
        idx = _ntoa_long(out,
c0d012d4:	9600      	str	r6, [sp, #0]
c0d012d6:	9101      	str	r1, [sp, #4]
c0d012d8:	9302      	str	r3, [sp, #8]
c0d012da:	9203      	str	r2, [sp, #12]
c0d012dc:	9814      	ldr	r0, [sp, #80]	; 0x50
c0d012de:	9004      	str	r0, [sp, #16]
c0d012e0:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d012e2:	9005      	str	r0, [sp, #20]
        out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
c0d012e4:	1c62      	adds	r2, r4, #1
        idx = _ntoa_long(out,
c0d012e6:	4638      	mov	r0, r7
c0d012e8:	9f12      	ldr	r7, [sp, #72]	; 0x48
c0d012ea:	4639      	mov	r1, r7
c0d012ec:	462b      	mov	r3, r5
c0d012ee:	f7ff fc27 	bl	c0d00b40 <_ntoa_long>
c0d012f2:	4604      	mov	r4, r0
        if (flags & FLAGS_LEFT) {
c0d012f4:	9813      	ldr	r0, [sp, #76]	; 0x4c
c0d012f6:	2800      	cmp	r0, #0
c0d012f8:	d015      	beq.n	c0d01326 <_etoa+0x372>
c0d012fa:	990f      	ldr	r1, [sp, #60]	; 0x3c
c0d012fc:	1a60      	subs	r0, r4, r1
c0d012fe:	9a16      	ldr	r2, [sp, #88]	; 0x58
c0d01300:	4290      	cmp	r0, r2
c0d01302:	d210      	bcs.n	c0d01326 <_etoa+0x372>
c0d01304:	462b      	mov	r3, r5
c0d01306:	463d      	mov	r5, r7
            while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
c0d01308:	4248      	negs	r0, r1
c0d0130a:	9015      	str	r0, [sp, #84]	; 0x54
c0d0130c:	9e09      	ldr	r6, [sp, #36]	; 0x24
c0d0130e:	2020      	movs	r0, #32
c0d01310:	4629      	mov	r1, r5
c0d01312:	4622      	mov	r2, r4
c0d01314:	461f      	mov	r7, r3
c0d01316:	47b0      	blx	r6
c0d01318:	463b      	mov	r3, r7
c0d0131a:	1c64      	adds	r4, r4, #1
c0d0131c:	9815      	ldr	r0, [sp, #84]	; 0x54
c0d0131e:	1900      	adds	r0, r0, r4
c0d01320:	9916      	ldr	r1, [sp, #88]	; 0x58
c0d01322:	4288      	cmp	r0, r1
c0d01324:	d3f3      	bcc.n	c0d0130e <_etoa+0x35a>
}
c0d01326:	4620      	mov	r0, r4
c0d01328:	b017      	add	sp, #92	; 0x5c
c0d0132a:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0132c:	ffefffff 	.word	0xffefffff
c0d01330:	7fefffff 	.word	0x7fefffff
c0d01334:	000fffff 	.word	0x000fffff
c0d01338:	fffffc01 	.word	0xfffffc01
c0d0133c:	509f79fb 	.word	0x509f79fb
c0d01340:	3fd34413 	.word	0x3fd34413
c0d01344:	8b60c8b3 	.word	0x8b60c8b3
c0d01348:	3fc68a28 	.word	0x3fc68a28
c0d0134c:	3ff00000 	.word	0x3ff00000
c0d01350:	bff80000 	.word	0xbff80000
c0d01354:	636f4361 	.word	0x636f4361
c0d01358:	3fd287a7 	.word	0x3fd287a7
c0d0135c:	0979a371 	.word	0x0979a371
c0d01360:	400a934f 	.word	0x400a934f
c0d01364:	3fe00000 	.word	0x3fe00000
c0d01368:	bbb55516 	.word	0xbbb55516
c0d0136c:	40026bb1 	.word	0x40026bb1
c0d01370:	fefa39ef 	.word	0xfefa39ef
c0d01374:	bfe62e42 	.word	0xbfe62e42
c0d01378:	402c0000 	.word	0x402c0000
c0d0137c:	40240000 	.word	0x40240000
c0d01380:	40180000 	.word	0x40180000
c0d01384:	000003ff 	.word	0x000003ff
c0d01388:	000007ff 	.word	0x000007ff
c0d0138c:	eb1c432d 	.word	0xeb1c432d
c0d01390:	3f1a36e2 	.word	0x3f1a36e2
c0d01394:	412e8480 	.word	0x412e8480

c0d01398 <_ntoa_format>:
                           unsigned int flags) {
c0d01398:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0139a:	b08b      	sub	sp, #44	; 0x2c
c0d0139c:	930a      	str	r3, [sp, #40]	; 0x28
c0d0139e:	9209      	str	r2, [sp, #36]	; 0x24
c0d013a0:	4606      	mov	r6, r0
c0d013a2:	9b16      	ldr	r3, [sp, #88]	; 0x58
    if (!(flags & FLAGS_LEFT)) {
c0d013a4:	0798      	lsls	r0, r3, #30
c0d013a6:	9d15      	ldr	r5, [sp, #84]	; 0x54
c0d013a8:	9c14      	ldr	r4, [sp, #80]	; 0x50
c0d013aa:	9812      	ldr	r0, [sp, #72]	; 0x48
c0d013ac:	9007      	str	r0, [sp, #28]
c0d013ae:	9f11      	ldr	r7, [sp, #68]	; 0x44
c0d013b0:	9a10      	ldr	r2, [sp, #64]	; 0x40
c0d013b2:	9208      	str	r2, [sp, #32]
c0d013b4:	d42a      	bmi.n	c0d0140c <_ntoa_format+0x74>
c0d013b6:	9605      	str	r6, [sp, #20]
c0d013b8:	9106      	str	r1, [sp, #24]
c0d013ba:	2601      	movs	r6, #1
        if (width && (flags & FLAGS_ZEROPAD) &&
c0d013bc:	401e      	ands	r6, r3
c0d013be:	2d00      	cmp	r5, #0
c0d013c0:	d008      	beq.n	c0d013d4 <_ntoa_format+0x3c>
c0d013c2:	2e00      	cmp	r6, #0
c0d013c4:	d006      	beq.n	c0d013d4 <_ntoa_format+0x3c>
c0d013c6:	200c      	movs	r0, #12
            (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
c0d013c8:	4018      	ands	r0, r3
c0d013ca:	1e41      	subs	r1, r0, #1
c0d013cc:	4188      	sbcs	r0, r1
c0d013ce:	9907      	ldr	r1, [sp, #28]
c0d013d0:	4308      	orrs	r0, r1
c0d013d2:	1a2d      	subs	r5, r5, r0
        while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d013d4:	42a7      	cmp	r7, r4
c0d013d6:	d214      	bcs.n	c0d01402 <_ntoa_format+0x6a>
c0d013d8:	2f1f      	cmp	r7, #31
c0d013da:	d812      	bhi.n	c0d01402 <_ntoa_format+0x6a>
c0d013dc:	9304      	str	r3, [sp, #16]
c0d013de:	201f      	movs	r0, #31
c0d013e0:	1bc0      	subs	r0, r0, r7
c0d013e2:	43f9      	mvns	r1, r7
c0d013e4:	1909      	adds	r1, r1, r4
c0d013e6:	4281      	cmp	r1, r0
c0d013e8:	d300      	bcc.n	c0d013ec <_ntoa_format+0x54>
c0d013ea:	4601      	mov	r1, r0
c0d013ec:	1c49      	adds	r1, r1, #1
c0d013ee:	19d0      	adds	r0, r2, r7
c0d013f0:	2230      	movs	r2, #48	; 0x30
            buf[len++] = '0';
c0d013f2:	f002 fa24 	bl	c0d0383e <__aeabi_memset>
c0d013f6:	9b04      	ldr	r3, [sp, #16]
c0d013f8:	1c7f      	adds	r7, r7, #1
        while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d013fa:	42a7      	cmp	r7, r4
c0d013fc:	d201      	bcs.n	c0d01402 <_ntoa_format+0x6a>
c0d013fe:	2f20      	cmp	r7, #32
c0d01400:	d3fa      	bcc.n	c0d013f8 <_ntoa_format+0x60>
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d01402:	2e00      	cmp	r6, #0
c0d01404:	d115      	bne.n	c0d01432 <_ntoa_format+0x9a>
c0d01406:	9906      	ldr	r1, [sp, #24]
c0d01408:	9e05      	ldr	r6, [sp, #20]
c0d0140a:	9a08      	ldr	r2, [sp, #32]
    if (flags & FLAGS_HASH) {
c0d0140c:	06d8      	lsls	r0, r3, #27
c0d0140e:	d546      	bpl.n	c0d0149e <_ntoa_format+0x106>
c0d01410:	4630      	mov	r0, r6
c0d01412:	461e      	mov	r6, r3
c0d01414:	9b13      	ldr	r3, [sp, #76]	; 0x4c
c0d01416:	4632      	mov	r2, r6
        if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
c0d01418:	0576      	lsls	r6, r6, #21
c0d0141a:	d419      	bmi.n	c0d01450 <_ntoa_format+0xb8>
c0d0141c:	2f00      	cmp	r7, #0
c0d0141e:	d017      	beq.n	c0d01450 <_ntoa_format+0xb8>
c0d01420:	42a7      	cmp	r7, r4
c0d01422:	4606      	mov	r6, r0
c0d01424:	d001      	beq.n	c0d0142a <_ntoa_format+0x92>
c0d01426:	42af      	cmp	r7, r5
c0d01428:	d113      	bne.n	c0d01452 <_ntoa_format+0xba>
            len--;
c0d0142a:	1e7c      	subs	r4, r7, #1
            if (len && (base == 16U)) {
c0d0142c:	d152      	bne.n	c0d014d4 <_ntoa_format+0x13c>
c0d0142e:	4627      	mov	r7, r4
c0d01430:	e051      	b.n	c0d014d6 <_ntoa_format+0x13e>
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d01432:	42af      	cmp	r7, r5
c0d01434:	d2e7      	bcs.n	c0d01406 <_ntoa_format+0x6e>
c0d01436:	2f1f      	cmp	r7, #31
c0d01438:	d8e5      	bhi.n	c0d01406 <_ntoa_format+0x6e>
c0d0143a:	9906      	ldr	r1, [sp, #24]
c0d0143c:	9e05      	ldr	r6, [sp, #20]
c0d0143e:	9a08      	ldr	r2, [sp, #32]
c0d01440:	2030      	movs	r0, #48	; 0x30
            buf[len++] = '0';
c0d01442:	55d0      	strb	r0, [r2, r7]
c0d01444:	1c7f      	adds	r7, r7, #1
        while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d01446:	42af      	cmp	r7, r5
c0d01448:	d2e0      	bcs.n	c0d0140c <_ntoa_format+0x74>
c0d0144a:	2f20      	cmp	r7, #32
c0d0144c:	d3f8      	bcc.n	c0d01440 <_ntoa_format+0xa8>
c0d0144e:	e7dd      	b.n	c0d0140c <_ntoa_format+0x74>
c0d01450:	4606      	mov	r6, r0
        if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d01452:	2b10      	cmp	r3, #16
c0d01454:	d108      	bne.n	c0d01468 <_ntoa_format+0xd0>
c0d01456:	2020      	movs	r0, #32
c0d01458:	4613      	mov	r3, r2
c0d0145a:	4010      	ands	r0, r2
c0d0145c:	d10f      	bne.n	c0d0147e <_ntoa_format+0xe6>
c0d0145e:	2f1f      	cmp	r7, #31
c0d01460:	d80d      	bhi.n	c0d0147e <_ntoa_format+0xe6>
c0d01462:	2078      	movs	r0, #120	; 0x78
c0d01464:	9a08      	ldr	r2, [sp, #32]
c0d01466:	e010      	b.n	c0d0148a <_ntoa_format+0xf2>
        } else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d01468:	2b02      	cmp	r3, #2
c0d0146a:	d111      	bne.n	c0d01490 <_ntoa_format+0xf8>
c0d0146c:	2f1f      	cmp	r7, #31
c0d0146e:	d80f      	bhi.n	c0d01490 <_ntoa_format+0xf8>
c0d01470:	2062      	movs	r0, #98	; 0x62
c0d01472:	9c08      	ldr	r4, [sp, #32]
            buf[len++] = 'b';
c0d01474:	55e0      	strb	r0, [r4, r7]
c0d01476:	1c7f      	adds	r7, r7, #1
c0d01478:	4613      	mov	r3, r2
c0d0147a:	4622      	mov	r2, r4
c0d0147c:	e00a      	b.n	c0d01494 <_ntoa_format+0xfc>
        } else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
c0d0147e:	2800      	cmp	r0, #0
c0d01480:	d007      	beq.n	c0d01492 <_ntoa_format+0xfa>
c0d01482:	2f1f      	cmp	r7, #31
c0d01484:	9a08      	ldr	r2, [sp, #32]
c0d01486:	d805      	bhi.n	c0d01494 <_ntoa_format+0xfc>
c0d01488:	2058      	movs	r0, #88	; 0x58
c0d0148a:	55d0      	strb	r0, [r2, r7]
c0d0148c:	1c7f      	adds	r7, r7, #1
c0d0148e:	e001      	b.n	c0d01494 <_ntoa_format+0xfc>
c0d01490:	4613      	mov	r3, r2
c0d01492:	9a08      	ldr	r2, [sp, #32]
        if (len < PRINTF_NTOA_BUFFER_SIZE) {
c0d01494:	2f1f      	cmp	r7, #31
c0d01496:	d812      	bhi.n	c0d014be <_ntoa_format+0x126>
c0d01498:	2030      	movs	r0, #48	; 0x30
            buf[len++] = '0';
c0d0149a:	55d0      	strb	r0, [r2, r7]
c0d0149c:	1c7f      	adds	r7, r7, #1
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
c0d0149e:	2f1f      	cmp	r7, #31
c0d014a0:	d80d      	bhi.n	c0d014be <_ntoa_format+0x126>
        if (negative) {
c0d014a2:	9807      	ldr	r0, [sp, #28]
c0d014a4:	2800      	cmp	r0, #0
c0d014a6:	d001      	beq.n	c0d014ac <_ntoa_format+0x114>
c0d014a8:	202d      	movs	r0, #45	; 0x2d
c0d014aa:	e006      	b.n	c0d014ba <_ntoa_format+0x122>
        } else if (flags & FLAGS_PLUS) {
c0d014ac:	0758      	lsls	r0, r3, #29
c0d014ae:	d403      	bmi.n	c0d014b8 <_ntoa_format+0x120>
        } else if (flags & FLAGS_SPACE) {
c0d014b0:	0718      	lsls	r0, r3, #28
c0d014b2:	d504      	bpl.n	c0d014be <_ntoa_format+0x126>
c0d014b4:	2020      	movs	r0, #32
c0d014b6:	e000      	b.n	c0d014ba <_ntoa_format+0x122>
c0d014b8:	202b      	movs	r0, #43	; 0x2b
c0d014ba:	55d0      	strb	r0, [r2, r7]
c0d014bc:	1c7f      	adds	r7, r7, #1
    return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
c0d014be:	9200      	str	r2, [sp, #0]
c0d014c0:	9701      	str	r7, [sp, #4]
c0d014c2:	9502      	str	r5, [sp, #8]
c0d014c4:	9303      	str	r3, [sp, #12]
c0d014c6:	4630      	mov	r0, r6
c0d014c8:	9a09      	ldr	r2, [sp, #36]	; 0x24
c0d014ca:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d014cc:	f000 f807 	bl	c0d014de <_out_rev>
c0d014d0:	b00b      	add	sp, #44	; 0x2c
c0d014d2:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d014d4:	1ebf      	subs	r7, r7, #2
            if (len && (base == 16U)) {
c0d014d6:	2b10      	cmp	r3, #16
c0d014d8:	d0bb      	beq.n	c0d01452 <_ntoa_format+0xba>
c0d014da:	4627      	mov	r7, r4
c0d014dc:	e7b9      	b.n	c0d01452 <_ntoa_format+0xba>

c0d014de <_out_rev>:
                       unsigned int flags) {
c0d014de:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d014e0:	b089      	sub	sp, #36	; 0x24
c0d014e2:	461e      	mov	r6, r3
c0d014e4:	4617      	mov	r7, r2
c0d014e6:	9004      	str	r0, [sp, #16]
c0d014e8:	2402      	movs	r4, #2
c0d014ea:	9811      	ldr	r0, [sp, #68]	; 0x44
    if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
c0d014ec:	4004      	ands	r4, r0
c0d014ee:	9401      	str	r4, [sp, #4]
c0d014f0:	07c0      	lsls	r0, r0, #31
c0d014f2:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d014f4:	9006      	str	r0, [sp, #24]
c0d014f6:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d014f8:	9002      	str	r0, [sp, #8]
c0d014fa:	9203      	str	r2, [sp, #12]
c0d014fc:	9105      	str	r1, [sp, #20]
c0d014fe:	d116      	bne.n	c0d0152e <_out_rev+0x50>
c0d01500:	9801      	ldr	r0, [sp, #4]
c0d01502:	2800      	cmp	r0, #0
c0d01504:	9f03      	ldr	r7, [sp, #12]
c0d01506:	d112      	bne.n	c0d0152e <_out_rev+0x50>
c0d01508:	9806      	ldr	r0, [sp, #24]
c0d0150a:	9a02      	ldr	r2, [sp, #8]
c0d0150c:	4282      	cmp	r2, r0
c0d0150e:	9f03      	ldr	r7, [sp, #12]
c0d01510:	d20d      	bcs.n	c0d0152e <_out_rev+0x50>
        for (size_t i = len; i < width; i++) {
c0d01512:	9806      	ldr	r0, [sp, #24]
c0d01514:	9a02      	ldr	r2, [sp, #8]
c0d01516:	1a85      	subs	r5, r0, r2
c0d01518:	9f03      	ldr	r7, [sp, #12]
            out(' ', buffer, idx++, maxlen);
c0d0151a:	9c04      	ldr	r4, [sp, #16]
c0d0151c:	2020      	movs	r0, #32
c0d0151e:	463a      	mov	r2, r7
c0d01520:	4633      	mov	r3, r6
c0d01522:	47a0      	blx	r4
c0d01524:	9905      	ldr	r1, [sp, #20]
        for (size_t i = len; i < width; i++) {
c0d01526:	1e6d      	subs	r5, r5, #1
            out(' ', buffer, idx++, maxlen);
c0d01528:	1c7f      	adds	r7, r7, #1
        for (size_t i = len; i < width; i++) {
c0d0152a:	2d00      	cmp	r5, #0
c0d0152c:	d1f6      	bne.n	c0d0151c <_out_rev+0x3e>
c0d0152e:	9608      	str	r6, [sp, #32]
c0d01530:	9c02      	ldr	r4, [sp, #8]
    while (len) {
c0d01532:	2c00      	cmp	r4, #0
c0d01534:	d00d      	beq.n	c0d01552 <_out_rev+0x74>
c0d01536:	980e      	ldr	r0, [sp, #56]	; 0x38
c0d01538:	1e40      	subs	r0, r0, #1
c0d0153a:	9007      	str	r0, [sp, #28]
c0d0153c:	9d05      	ldr	r5, [sp, #20]
c0d0153e:	9e04      	ldr	r6, [sp, #16]
        out(buf[--len], buffer, idx++, maxlen);
c0d01540:	9807      	ldr	r0, [sp, #28]
c0d01542:	5d00      	ldrb	r0, [r0, r4]
c0d01544:	4629      	mov	r1, r5
c0d01546:	463a      	mov	r2, r7
c0d01548:	9b08      	ldr	r3, [sp, #32]
c0d0154a:	47b0      	blx	r6
c0d0154c:	1c7f      	adds	r7, r7, #1
c0d0154e:	1e64      	subs	r4, r4, #1
    while (len) {
c0d01550:	d1f6      	bne.n	c0d01540 <_out_rev+0x62>
    if (flags & FLAGS_LEFT) {
c0d01552:	9801      	ldr	r0, [sp, #4]
c0d01554:	2800      	cmp	r0, #0
c0d01556:	d014      	beq.n	c0d01582 <_out_rev+0xa4>
c0d01558:	9a03      	ldr	r2, [sp, #12]
c0d0155a:	1ab8      	subs	r0, r7, r2
c0d0155c:	9906      	ldr	r1, [sp, #24]
c0d0155e:	4288      	cmp	r0, r1
c0d01560:	d20f      	bcs.n	c0d01582 <_out_rev+0xa4>
        while (idx - start_idx < width) {
c0d01562:	4250      	negs	r0, r2
c0d01564:	9007      	str	r0, [sp, #28]
c0d01566:	9d08      	ldr	r5, [sp, #32]
c0d01568:	9e05      	ldr	r6, [sp, #20]
c0d0156a:	9c04      	ldr	r4, [sp, #16]
c0d0156c:	2020      	movs	r0, #32
            out(' ', buffer, idx++, maxlen);
c0d0156e:	4631      	mov	r1, r6
c0d01570:	463a      	mov	r2, r7
c0d01572:	462b      	mov	r3, r5
c0d01574:	47a0      	blx	r4
c0d01576:	1c7f      	adds	r7, r7, #1
        while (idx - start_idx < width) {
c0d01578:	9807      	ldr	r0, [sp, #28]
c0d0157a:	19c0      	adds	r0, r0, r7
c0d0157c:	9906      	ldr	r1, [sp, #24]
c0d0157e:	4288      	cmp	r0, r1
c0d01580:	d3f4      	bcc.n	c0d0156c <_out_rev+0x8e>
    return idx;
c0d01582:	4638      	mov	r0, r7
c0d01584:	b009      	add	sp, #36	; 0x24
c0d01586:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d01588 <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d01588:	df01      	svc	1
    cmp r1, #0
c0d0158a:	2900      	cmp	r1, #0
    bne exception
c0d0158c:	d100      	bne.n	c0d01590 <exception>
    bx lr
c0d0158e:	4770      	bx	lr

c0d01590 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d01590:	4608      	mov	r0, r1
    bl os_longjmp
c0d01592:	f7fe ffa5 	bl	c0d004e0 <os_longjmp>
	...

c0d01598 <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d01598:	b580      	push	{r7, lr}
c0d0159a:	b084      	sub	sp, #16
c0d0159c:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d0159e:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d015a0:	9001      	str	r0, [sp, #4]
c0d015a2:	4803      	ldr	r0, [pc, #12]	; (c0d015b0 <get_api_level+0x18>)
c0d015a4:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d015a6:	f7ff ffef 	bl	c0d01588 <SVC_Call>
c0d015aa:	b004      	add	sp, #16
c0d015ac:	bd80      	pop	{r7, pc}
c0d015ae:	46c0      	nop			; (mov r8, r8)
c0d015b0:	60000138 	.word	0x60000138

c0d015b4 <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d015b4:	b580      	push	{r7, lr}
c0d015b6:	b084      	sub	sp, #16
c0d015b8:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d015ba:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d015bc:	9001      	str	r0, [sp, #4]
c0d015be:	4803      	ldr	r0, [pc, #12]	; (c0d015cc <os_lib_call+0x18>)
c0d015c0:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d015c2:	f7ff ffe1 	bl	c0d01588 <SVC_Call>
  return;
}
c0d015c6:	b004      	add	sp, #16
c0d015c8:	bd80      	pop	{r7, pc}
c0d015ca:	46c0      	nop			; (mov r8, r8)
c0d015cc:	6000670d 	.word	0x6000670d

c0d015d0 <os_lib_end>:

void os_lib_end ( void ) {
c0d015d0:	b580      	push	{r7, lr}
c0d015d2:	b082      	sub	sp, #8
c0d015d4:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d015d6:	9001      	str	r0, [sp, #4]
c0d015d8:	4802      	ldr	r0, [pc, #8]	; (c0d015e4 <os_lib_end+0x14>)
c0d015da:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d015dc:	f7ff ffd4 	bl	c0d01588 <SVC_Call>
  return;
}
c0d015e0:	b002      	add	sp, #8
c0d015e2:	bd80      	pop	{r7, pc}
c0d015e4:	6000688d 	.word	0x6000688d

c0d015e8 <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d015e8:	b580      	push	{r7, lr}
c0d015ea:	b084      	sub	sp, #16
c0d015ec:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d015ee:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d015f0:	9001      	str	r0, [sp, #4]
c0d015f2:	4803      	ldr	r0, [pc, #12]	; (c0d01600 <os_sched_exit+0x18>)
c0d015f4:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d015f6:	f7ff ffc7 	bl	c0d01588 <SVC_Call>
  return;
}
c0d015fa:	b004      	add	sp, #16
c0d015fc:	bd80      	pop	{r7, pc}
c0d015fe:	46c0      	nop			; (mov r8, r8)
c0d01600:	60009abe 	.word	0x60009abe

c0d01604 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d01604:	b580      	push	{r7, lr}
c0d01606:	b082      	sub	sp, #8
c0d01608:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d0160a:	9001      	str	r0, [sp, #4]
c0d0160c:	4802      	ldr	r0, [pc, #8]	; (c0d01618 <try_context_get+0x14>)
c0d0160e:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d01610:	f7ff ffba 	bl	c0d01588 <SVC_Call>
c0d01614:	b002      	add	sp, #8
c0d01616:	bd80      	pop	{r7, pc}
c0d01618:	600087b1 	.word	0x600087b1

c0d0161c <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d0161c:	b580      	push	{r7, lr}
c0d0161e:	b084      	sub	sp, #16
c0d01620:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d01622:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d01624:	9001      	str	r0, [sp, #4]
c0d01626:	4803      	ldr	r0, [pc, #12]	; (c0d01634 <try_context_set+0x18>)
c0d01628:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d0162a:	f7ff ffad 	bl	c0d01588 <SVC_Call>
c0d0162e:	b004      	add	sp, #16
c0d01630:	bd80      	pop	{r7, pc}
c0d01632:	46c0      	nop			; (mov r8, r8)
c0d01634:	60010b06 	.word	0x60010b06

c0d01638 <__udivsi3>:
c0d01638:	2200      	movs	r2, #0
c0d0163a:	0843      	lsrs	r3, r0, #1
c0d0163c:	428b      	cmp	r3, r1
c0d0163e:	d374      	bcc.n	c0d0172a <__udivsi3+0xf2>
c0d01640:	0903      	lsrs	r3, r0, #4
c0d01642:	428b      	cmp	r3, r1
c0d01644:	d35f      	bcc.n	c0d01706 <__udivsi3+0xce>
c0d01646:	0a03      	lsrs	r3, r0, #8
c0d01648:	428b      	cmp	r3, r1
c0d0164a:	d344      	bcc.n	c0d016d6 <__udivsi3+0x9e>
c0d0164c:	0b03      	lsrs	r3, r0, #12
c0d0164e:	428b      	cmp	r3, r1
c0d01650:	d328      	bcc.n	c0d016a4 <__udivsi3+0x6c>
c0d01652:	0c03      	lsrs	r3, r0, #16
c0d01654:	428b      	cmp	r3, r1
c0d01656:	d30d      	bcc.n	c0d01674 <__udivsi3+0x3c>
c0d01658:	22ff      	movs	r2, #255	; 0xff
c0d0165a:	0209      	lsls	r1, r1, #8
c0d0165c:	ba12      	rev	r2, r2
c0d0165e:	0c03      	lsrs	r3, r0, #16
c0d01660:	428b      	cmp	r3, r1
c0d01662:	d302      	bcc.n	c0d0166a <__udivsi3+0x32>
c0d01664:	1212      	asrs	r2, r2, #8
c0d01666:	0209      	lsls	r1, r1, #8
c0d01668:	d065      	beq.n	c0d01736 <__udivsi3+0xfe>
c0d0166a:	0b03      	lsrs	r3, r0, #12
c0d0166c:	428b      	cmp	r3, r1
c0d0166e:	d319      	bcc.n	c0d016a4 <__udivsi3+0x6c>
c0d01670:	e000      	b.n	c0d01674 <__udivsi3+0x3c>
c0d01672:	0a09      	lsrs	r1, r1, #8
c0d01674:	0bc3      	lsrs	r3, r0, #15
c0d01676:	428b      	cmp	r3, r1
c0d01678:	d301      	bcc.n	c0d0167e <__udivsi3+0x46>
c0d0167a:	03cb      	lsls	r3, r1, #15
c0d0167c:	1ac0      	subs	r0, r0, r3
c0d0167e:	4152      	adcs	r2, r2
c0d01680:	0b83      	lsrs	r3, r0, #14
c0d01682:	428b      	cmp	r3, r1
c0d01684:	d301      	bcc.n	c0d0168a <__udivsi3+0x52>
c0d01686:	038b      	lsls	r3, r1, #14
c0d01688:	1ac0      	subs	r0, r0, r3
c0d0168a:	4152      	adcs	r2, r2
c0d0168c:	0b43      	lsrs	r3, r0, #13
c0d0168e:	428b      	cmp	r3, r1
c0d01690:	d301      	bcc.n	c0d01696 <__udivsi3+0x5e>
c0d01692:	034b      	lsls	r3, r1, #13
c0d01694:	1ac0      	subs	r0, r0, r3
c0d01696:	4152      	adcs	r2, r2
c0d01698:	0b03      	lsrs	r3, r0, #12
c0d0169a:	428b      	cmp	r3, r1
c0d0169c:	d301      	bcc.n	c0d016a2 <__udivsi3+0x6a>
c0d0169e:	030b      	lsls	r3, r1, #12
c0d016a0:	1ac0      	subs	r0, r0, r3
c0d016a2:	4152      	adcs	r2, r2
c0d016a4:	0ac3      	lsrs	r3, r0, #11
c0d016a6:	428b      	cmp	r3, r1
c0d016a8:	d301      	bcc.n	c0d016ae <__udivsi3+0x76>
c0d016aa:	02cb      	lsls	r3, r1, #11
c0d016ac:	1ac0      	subs	r0, r0, r3
c0d016ae:	4152      	adcs	r2, r2
c0d016b0:	0a83      	lsrs	r3, r0, #10
c0d016b2:	428b      	cmp	r3, r1
c0d016b4:	d301      	bcc.n	c0d016ba <__udivsi3+0x82>
c0d016b6:	028b      	lsls	r3, r1, #10
c0d016b8:	1ac0      	subs	r0, r0, r3
c0d016ba:	4152      	adcs	r2, r2
c0d016bc:	0a43      	lsrs	r3, r0, #9
c0d016be:	428b      	cmp	r3, r1
c0d016c0:	d301      	bcc.n	c0d016c6 <__udivsi3+0x8e>
c0d016c2:	024b      	lsls	r3, r1, #9
c0d016c4:	1ac0      	subs	r0, r0, r3
c0d016c6:	4152      	adcs	r2, r2
c0d016c8:	0a03      	lsrs	r3, r0, #8
c0d016ca:	428b      	cmp	r3, r1
c0d016cc:	d301      	bcc.n	c0d016d2 <__udivsi3+0x9a>
c0d016ce:	020b      	lsls	r3, r1, #8
c0d016d0:	1ac0      	subs	r0, r0, r3
c0d016d2:	4152      	adcs	r2, r2
c0d016d4:	d2cd      	bcs.n	c0d01672 <__udivsi3+0x3a>
c0d016d6:	09c3      	lsrs	r3, r0, #7
c0d016d8:	428b      	cmp	r3, r1
c0d016da:	d301      	bcc.n	c0d016e0 <__udivsi3+0xa8>
c0d016dc:	01cb      	lsls	r3, r1, #7
c0d016de:	1ac0      	subs	r0, r0, r3
c0d016e0:	4152      	adcs	r2, r2
c0d016e2:	0983      	lsrs	r3, r0, #6
c0d016e4:	428b      	cmp	r3, r1
c0d016e6:	d301      	bcc.n	c0d016ec <__udivsi3+0xb4>
c0d016e8:	018b      	lsls	r3, r1, #6
c0d016ea:	1ac0      	subs	r0, r0, r3
c0d016ec:	4152      	adcs	r2, r2
c0d016ee:	0943      	lsrs	r3, r0, #5
c0d016f0:	428b      	cmp	r3, r1
c0d016f2:	d301      	bcc.n	c0d016f8 <__udivsi3+0xc0>
c0d016f4:	014b      	lsls	r3, r1, #5
c0d016f6:	1ac0      	subs	r0, r0, r3
c0d016f8:	4152      	adcs	r2, r2
c0d016fa:	0903      	lsrs	r3, r0, #4
c0d016fc:	428b      	cmp	r3, r1
c0d016fe:	d301      	bcc.n	c0d01704 <__udivsi3+0xcc>
c0d01700:	010b      	lsls	r3, r1, #4
c0d01702:	1ac0      	subs	r0, r0, r3
c0d01704:	4152      	adcs	r2, r2
c0d01706:	08c3      	lsrs	r3, r0, #3
c0d01708:	428b      	cmp	r3, r1
c0d0170a:	d301      	bcc.n	c0d01710 <__udivsi3+0xd8>
c0d0170c:	00cb      	lsls	r3, r1, #3
c0d0170e:	1ac0      	subs	r0, r0, r3
c0d01710:	4152      	adcs	r2, r2
c0d01712:	0883      	lsrs	r3, r0, #2
c0d01714:	428b      	cmp	r3, r1
c0d01716:	d301      	bcc.n	c0d0171c <__udivsi3+0xe4>
c0d01718:	008b      	lsls	r3, r1, #2
c0d0171a:	1ac0      	subs	r0, r0, r3
c0d0171c:	4152      	adcs	r2, r2
c0d0171e:	0843      	lsrs	r3, r0, #1
c0d01720:	428b      	cmp	r3, r1
c0d01722:	d301      	bcc.n	c0d01728 <__udivsi3+0xf0>
c0d01724:	004b      	lsls	r3, r1, #1
c0d01726:	1ac0      	subs	r0, r0, r3
c0d01728:	4152      	adcs	r2, r2
c0d0172a:	1a41      	subs	r1, r0, r1
c0d0172c:	d200      	bcs.n	c0d01730 <__udivsi3+0xf8>
c0d0172e:	4601      	mov	r1, r0
c0d01730:	4152      	adcs	r2, r2
c0d01732:	4610      	mov	r0, r2
c0d01734:	4770      	bx	lr
c0d01736:	e7ff      	b.n	c0d01738 <__udivsi3+0x100>
c0d01738:	b501      	push	{r0, lr}
c0d0173a:	2000      	movs	r0, #0
c0d0173c:	f000 f8f0 	bl	c0d01920 <__aeabi_idiv0>
c0d01740:	bd02      	pop	{r1, pc}
c0d01742:	46c0      	nop			; (mov r8, r8)

c0d01744 <__aeabi_uidivmod>:
c0d01744:	2900      	cmp	r1, #0
c0d01746:	d0f7      	beq.n	c0d01738 <__udivsi3+0x100>
c0d01748:	e776      	b.n	c0d01638 <__udivsi3>
c0d0174a:	4770      	bx	lr

c0d0174c <__divsi3>:
c0d0174c:	4603      	mov	r3, r0
c0d0174e:	430b      	orrs	r3, r1
c0d01750:	d47f      	bmi.n	c0d01852 <__divsi3+0x106>
c0d01752:	2200      	movs	r2, #0
c0d01754:	0843      	lsrs	r3, r0, #1
c0d01756:	428b      	cmp	r3, r1
c0d01758:	d374      	bcc.n	c0d01844 <__divsi3+0xf8>
c0d0175a:	0903      	lsrs	r3, r0, #4
c0d0175c:	428b      	cmp	r3, r1
c0d0175e:	d35f      	bcc.n	c0d01820 <__divsi3+0xd4>
c0d01760:	0a03      	lsrs	r3, r0, #8
c0d01762:	428b      	cmp	r3, r1
c0d01764:	d344      	bcc.n	c0d017f0 <__divsi3+0xa4>
c0d01766:	0b03      	lsrs	r3, r0, #12
c0d01768:	428b      	cmp	r3, r1
c0d0176a:	d328      	bcc.n	c0d017be <__divsi3+0x72>
c0d0176c:	0c03      	lsrs	r3, r0, #16
c0d0176e:	428b      	cmp	r3, r1
c0d01770:	d30d      	bcc.n	c0d0178e <__divsi3+0x42>
c0d01772:	22ff      	movs	r2, #255	; 0xff
c0d01774:	0209      	lsls	r1, r1, #8
c0d01776:	ba12      	rev	r2, r2
c0d01778:	0c03      	lsrs	r3, r0, #16
c0d0177a:	428b      	cmp	r3, r1
c0d0177c:	d302      	bcc.n	c0d01784 <__divsi3+0x38>
c0d0177e:	1212      	asrs	r2, r2, #8
c0d01780:	0209      	lsls	r1, r1, #8
c0d01782:	d065      	beq.n	c0d01850 <__divsi3+0x104>
c0d01784:	0b03      	lsrs	r3, r0, #12
c0d01786:	428b      	cmp	r3, r1
c0d01788:	d319      	bcc.n	c0d017be <__divsi3+0x72>
c0d0178a:	e000      	b.n	c0d0178e <__divsi3+0x42>
c0d0178c:	0a09      	lsrs	r1, r1, #8
c0d0178e:	0bc3      	lsrs	r3, r0, #15
c0d01790:	428b      	cmp	r3, r1
c0d01792:	d301      	bcc.n	c0d01798 <__divsi3+0x4c>
c0d01794:	03cb      	lsls	r3, r1, #15
c0d01796:	1ac0      	subs	r0, r0, r3
c0d01798:	4152      	adcs	r2, r2
c0d0179a:	0b83      	lsrs	r3, r0, #14
c0d0179c:	428b      	cmp	r3, r1
c0d0179e:	d301      	bcc.n	c0d017a4 <__divsi3+0x58>
c0d017a0:	038b      	lsls	r3, r1, #14
c0d017a2:	1ac0      	subs	r0, r0, r3
c0d017a4:	4152      	adcs	r2, r2
c0d017a6:	0b43      	lsrs	r3, r0, #13
c0d017a8:	428b      	cmp	r3, r1
c0d017aa:	d301      	bcc.n	c0d017b0 <__divsi3+0x64>
c0d017ac:	034b      	lsls	r3, r1, #13
c0d017ae:	1ac0      	subs	r0, r0, r3
c0d017b0:	4152      	adcs	r2, r2
c0d017b2:	0b03      	lsrs	r3, r0, #12
c0d017b4:	428b      	cmp	r3, r1
c0d017b6:	d301      	bcc.n	c0d017bc <__divsi3+0x70>
c0d017b8:	030b      	lsls	r3, r1, #12
c0d017ba:	1ac0      	subs	r0, r0, r3
c0d017bc:	4152      	adcs	r2, r2
c0d017be:	0ac3      	lsrs	r3, r0, #11
c0d017c0:	428b      	cmp	r3, r1
c0d017c2:	d301      	bcc.n	c0d017c8 <__divsi3+0x7c>
c0d017c4:	02cb      	lsls	r3, r1, #11
c0d017c6:	1ac0      	subs	r0, r0, r3
c0d017c8:	4152      	adcs	r2, r2
c0d017ca:	0a83      	lsrs	r3, r0, #10
c0d017cc:	428b      	cmp	r3, r1
c0d017ce:	d301      	bcc.n	c0d017d4 <__divsi3+0x88>
c0d017d0:	028b      	lsls	r3, r1, #10
c0d017d2:	1ac0      	subs	r0, r0, r3
c0d017d4:	4152      	adcs	r2, r2
c0d017d6:	0a43      	lsrs	r3, r0, #9
c0d017d8:	428b      	cmp	r3, r1
c0d017da:	d301      	bcc.n	c0d017e0 <__divsi3+0x94>
c0d017dc:	024b      	lsls	r3, r1, #9
c0d017de:	1ac0      	subs	r0, r0, r3
c0d017e0:	4152      	adcs	r2, r2
c0d017e2:	0a03      	lsrs	r3, r0, #8
c0d017e4:	428b      	cmp	r3, r1
c0d017e6:	d301      	bcc.n	c0d017ec <__divsi3+0xa0>
c0d017e8:	020b      	lsls	r3, r1, #8
c0d017ea:	1ac0      	subs	r0, r0, r3
c0d017ec:	4152      	adcs	r2, r2
c0d017ee:	d2cd      	bcs.n	c0d0178c <__divsi3+0x40>
c0d017f0:	09c3      	lsrs	r3, r0, #7
c0d017f2:	428b      	cmp	r3, r1
c0d017f4:	d301      	bcc.n	c0d017fa <__divsi3+0xae>
c0d017f6:	01cb      	lsls	r3, r1, #7
c0d017f8:	1ac0      	subs	r0, r0, r3
c0d017fa:	4152      	adcs	r2, r2
c0d017fc:	0983      	lsrs	r3, r0, #6
c0d017fe:	428b      	cmp	r3, r1
c0d01800:	d301      	bcc.n	c0d01806 <__divsi3+0xba>
c0d01802:	018b      	lsls	r3, r1, #6
c0d01804:	1ac0      	subs	r0, r0, r3
c0d01806:	4152      	adcs	r2, r2
c0d01808:	0943      	lsrs	r3, r0, #5
c0d0180a:	428b      	cmp	r3, r1
c0d0180c:	d301      	bcc.n	c0d01812 <__divsi3+0xc6>
c0d0180e:	014b      	lsls	r3, r1, #5
c0d01810:	1ac0      	subs	r0, r0, r3
c0d01812:	4152      	adcs	r2, r2
c0d01814:	0903      	lsrs	r3, r0, #4
c0d01816:	428b      	cmp	r3, r1
c0d01818:	d301      	bcc.n	c0d0181e <__divsi3+0xd2>
c0d0181a:	010b      	lsls	r3, r1, #4
c0d0181c:	1ac0      	subs	r0, r0, r3
c0d0181e:	4152      	adcs	r2, r2
c0d01820:	08c3      	lsrs	r3, r0, #3
c0d01822:	428b      	cmp	r3, r1
c0d01824:	d301      	bcc.n	c0d0182a <__divsi3+0xde>
c0d01826:	00cb      	lsls	r3, r1, #3
c0d01828:	1ac0      	subs	r0, r0, r3
c0d0182a:	4152      	adcs	r2, r2
c0d0182c:	0883      	lsrs	r3, r0, #2
c0d0182e:	428b      	cmp	r3, r1
c0d01830:	d301      	bcc.n	c0d01836 <__divsi3+0xea>
c0d01832:	008b      	lsls	r3, r1, #2
c0d01834:	1ac0      	subs	r0, r0, r3
c0d01836:	4152      	adcs	r2, r2
c0d01838:	0843      	lsrs	r3, r0, #1
c0d0183a:	428b      	cmp	r3, r1
c0d0183c:	d301      	bcc.n	c0d01842 <__divsi3+0xf6>
c0d0183e:	004b      	lsls	r3, r1, #1
c0d01840:	1ac0      	subs	r0, r0, r3
c0d01842:	4152      	adcs	r2, r2
c0d01844:	1a41      	subs	r1, r0, r1
c0d01846:	d200      	bcs.n	c0d0184a <__divsi3+0xfe>
c0d01848:	4601      	mov	r1, r0
c0d0184a:	4152      	adcs	r2, r2
c0d0184c:	4610      	mov	r0, r2
c0d0184e:	4770      	bx	lr
c0d01850:	e05d      	b.n	c0d0190e <__divsi3+0x1c2>
c0d01852:	0fca      	lsrs	r2, r1, #31
c0d01854:	d000      	beq.n	c0d01858 <__divsi3+0x10c>
c0d01856:	4249      	negs	r1, r1
c0d01858:	1003      	asrs	r3, r0, #32
c0d0185a:	d300      	bcc.n	c0d0185e <__divsi3+0x112>
c0d0185c:	4240      	negs	r0, r0
c0d0185e:	4053      	eors	r3, r2
c0d01860:	2200      	movs	r2, #0
c0d01862:	469c      	mov	ip, r3
c0d01864:	0903      	lsrs	r3, r0, #4
c0d01866:	428b      	cmp	r3, r1
c0d01868:	d32d      	bcc.n	c0d018c6 <__divsi3+0x17a>
c0d0186a:	0a03      	lsrs	r3, r0, #8
c0d0186c:	428b      	cmp	r3, r1
c0d0186e:	d312      	bcc.n	c0d01896 <__divsi3+0x14a>
c0d01870:	22fc      	movs	r2, #252	; 0xfc
c0d01872:	0189      	lsls	r1, r1, #6
c0d01874:	ba12      	rev	r2, r2
c0d01876:	0a03      	lsrs	r3, r0, #8
c0d01878:	428b      	cmp	r3, r1
c0d0187a:	d30c      	bcc.n	c0d01896 <__divsi3+0x14a>
c0d0187c:	0189      	lsls	r1, r1, #6
c0d0187e:	1192      	asrs	r2, r2, #6
c0d01880:	428b      	cmp	r3, r1
c0d01882:	d308      	bcc.n	c0d01896 <__divsi3+0x14a>
c0d01884:	0189      	lsls	r1, r1, #6
c0d01886:	1192      	asrs	r2, r2, #6
c0d01888:	428b      	cmp	r3, r1
c0d0188a:	d304      	bcc.n	c0d01896 <__divsi3+0x14a>
c0d0188c:	0189      	lsls	r1, r1, #6
c0d0188e:	d03a      	beq.n	c0d01906 <__divsi3+0x1ba>
c0d01890:	1192      	asrs	r2, r2, #6
c0d01892:	e000      	b.n	c0d01896 <__divsi3+0x14a>
c0d01894:	0989      	lsrs	r1, r1, #6
c0d01896:	09c3      	lsrs	r3, r0, #7
c0d01898:	428b      	cmp	r3, r1
c0d0189a:	d301      	bcc.n	c0d018a0 <__divsi3+0x154>
c0d0189c:	01cb      	lsls	r3, r1, #7
c0d0189e:	1ac0      	subs	r0, r0, r3
c0d018a0:	4152      	adcs	r2, r2
c0d018a2:	0983      	lsrs	r3, r0, #6
c0d018a4:	428b      	cmp	r3, r1
c0d018a6:	d301      	bcc.n	c0d018ac <__divsi3+0x160>
c0d018a8:	018b      	lsls	r3, r1, #6
c0d018aa:	1ac0      	subs	r0, r0, r3
c0d018ac:	4152      	adcs	r2, r2
c0d018ae:	0943      	lsrs	r3, r0, #5
c0d018b0:	428b      	cmp	r3, r1
c0d018b2:	d301      	bcc.n	c0d018b8 <__divsi3+0x16c>
c0d018b4:	014b      	lsls	r3, r1, #5
c0d018b6:	1ac0      	subs	r0, r0, r3
c0d018b8:	4152      	adcs	r2, r2
c0d018ba:	0903      	lsrs	r3, r0, #4
c0d018bc:	428b      	cmp	r3, r1
c0d018be:	d301      	bcc.n	c0d018c4 <__divsi3+0x178>
c0d018c0:	010b      	lsls	r3, r1, #4
c0d018c2:	1ac0      	subs	r0, r0, r3
c0d018c4:	4152      	adcs	r2, r2
c0d018c6:	08c3      	lsrs	r3, r0, #3
c0d018c8:	428b      	cmp	r3, r1
c0d018ca:	d301      	bcc.n	c0d018d0 <__divsi3+0x184>
c0d018cc:	00cb      	lsls	r3, r1, #3
c0d018ce:	1ac0      	subs	r0, r0, r3
c0d018d0:	4152      	adcs	r2, r2
c0d018d2:	0883      	lsrs	r3, r0, #2
c0d018d4:	428b      	cmp	r3, r1
c0d018d6:	d301      	bcc.n	c0d018dc <__divsi3+0x190>
c0d018d8:	008b      	lsls	r3, r1, #2
c0d018da:	1ac0      	subs	r0, r0, r3
c0d018dc:	4152      	adcs	r2, r2
c0d018de:	d2d9      	bcs.n	c0d01894 <__divsi3+0x148>
c0d018e0:	0843      	lsrs	r3, r0, #1
c0d018e2:	428b      	cmp	r3, r1
c0d018e4:	d301      	bcc.n	c0d018ea <__divsi3+0x19e>
c0d018e6:	004b      	lsls	r3, r1, #1
c0d018e8:	1ac0      	subs	r0, r0, r3
c0d018ea:	4152      	adcs	r2, r2
c0d018ec:	1a41      	subs	r1, r0, r1
c0d018ee:	d200      	bcs.n	c0d018f2 <__divsi3+0x1a6>
c0d018f0:	4601      	mov	r1, r0
c0d018f2:	4663      	mov	r3, ip
c0d018f4:	4152      	adcs	r2, r2
c0d018f6:	105b      	asrs	r3, r3, #1
c0d018f8:	4610      	mov	r0, r2
c0d018fa:	d301      	bcc.n	c0d01900 <__divsi3+0x1b4>
c0d018fc:	4240      	negs	r0, r0
c0d018fe:	2b00      	cmp	r3, #0
c0d01900:	d500      	bpl.n	c0d01904 <__divsi3+0x1b8>
c0d01902:	4249      	negs	r1, r1
c0d01904:	4770      	bx	lr
c0d01906:	4663      	mov	r3, ip
c0d01908:	105b      	asrs	r3, r3, #1
c0d0190a:	d300      	bcc.n	c0d0190e <__divsi3+0x1c2>
c0d0190c:	4240      	negs	r0, r0
c0d0190e:	b501      	push	{r0, lr}
c0d01910:	2000      	movs	r0, #0
c0d01912:	f000 f805 	bl	c0d01920 <__aeabi_idiv0>
c0d01916:	bd02      	pop	{r1, pc}

c0d01918 <__aeabi_idivmod>:
c0d01918:	2900      	cmp	r1, #0
c0d0191a:	d0f8      	beq.n	c0d0190e <__divsi3+0x1c2>
c0d0191c:	e716      	b.n	c0d0174c <__divsi3>
c0d0191e:	4770      	bx	lr

c0d01920 <__aeabi_idiv0>:
c0d01920:	4770      	bx	lr
c0d01922:	46c0      	nop			; (mov r8, r8)

c0d01924 <__aeabi_cdrcmple>:
c0d01924:	4684      	mov	ip, r0
c0d01926:	0010      	movs	r0, r2
c0d01928:	4662      	mov	r2, ip
c0d0192a:	468c      	mov	ip, r1
c0d0192c:	0019      	movs	r1, r3
c0d0192e:	4663      	mov	r3, ip
c0d01930:	e000      	b.n	c0d01934 <__aeabi_cdcmpeq>
c0d01932:	46c0      	nop			; (mov r8, r8)

c0d01934 <__aeabi_cdcmpeq>:
c0d01934:	b51f      	push	{r0, r1, r2, r3, r4, lr}
c0d01936:	f001 f845 	bl	c0d029c4 <__ledf2>
c0d0193a:	2800      	cmp	r0, #0
c0d0193c:	d401      	bmi.n	c0d01942 <__aeabi_cdcmpeq+0xe>
c0d0193e:	2100      	movs	r1, #0
c0d01940:	42c8      	cmn	r0, r1
c0d01942:	bd1f      	pop	{r0, r1, r2, r3, r4, pc}

c0d01944 <__aeabi_dcmpeq>:
c0d01944:	b510      	push	{r4, lr}
c0d01946:	f000 ff95 	bl	c0d02874 <__eqdf2>
c0d0194a:	4240      	negs	r0, r0
c0d0194c:	3001      	adds	r0, #1
c0d0194e:	bd10      	pop	{r4, pc}

c0d01950 <__aeabi_dcmplt>:
c0d01950:	b510      	push	{r4, lr}
c0d01952:	f001 f837 	bl	c0d029c4 <__ledf2>
c0d01956:	2800      	cmp	r0, #0
c0d01958:	db01      	blt.n	c0d0195e <__aeabi_dcmplt+0xe>
c0d0195a:	2000      	movs	r0, #0
c0d0195c:	bd10      	pop	{r4, pc}
c0d0195e:	2001      	movs	r0, #1
c0d01960:	bd10      	pop	{r4, pc}
c0d01962:	46c0      	nop			; (mov r8, r8)

c0d01964 <__aeabi_dcmple>:
c0d01964:	b510      	push	{r4, lr}
c0d01966:	f001 f82d 	bl	c0d029c4 <__ledf2>
c0d0196a:	2800      	cmp	r0, #0
c0d0196c:	dd01      	ble.n	c0d01972 <__aeabi_dcmple+0xe>
c0d0196e:	2000      	movs	r0, #0
c0d01970:	bd10      	pop	{r4, pc}
c0d01972:	2001      	movs	r0, #1
c0d01974:	bd10      	pop	{r4, pc}
c0d01976:	46c0      	nop			; (mov r8, r8)

c0d01978 <__aeabi_dcmpgt>:
c0d01978:	b510      	push	{r4, lr}
c0d0197a:	f000 ffbd 	bl	c0d028f8 <__gedf2>
c0d0197e:	2800      	cmp	r0, #0
c0d01980:	dc01      	bgt.n	c0d01986 <__aeabi_dcmpgt+0xe>
c0d01982:	2000      	movs	r0, #0
c0d01984:	bd10      	pop	{r4, pc}
c0d01986:	2001      	movs	r0, #1
c0d01988:	bd10      	pop	{r4, pc}
c0d0198a:	46c0      	nop			; (mov r8, r8)

c0d0198c <__aeabi_dcmpge>:
c0d0198c:	b510      	push	{r4, lr}
c0d0198e:	f000 ffb3 	bl	c0d028f8 <__gedf2>
c0d01992:	2800      	cmp	r0, #0
c0d01994:	da01      	bge.n	c0d0199a <__aeabi_dcmpge+0xe>
c0d01996:	2000      	movs	r0, #0
c0d01998:	bd10      	pop	{r4, pc}
c0d0199a:	2001      	movs	r0, #1
c0d0199c:	bd10      	pop	{r4, pc}
c0d0199e:	46c0      	nop			; (mov r8, r8)

c0d019a0 <__aeabi_uldivmod>:
c0d019a0:	2b00      	cmp	r3, #0
c0d019a2:	d111      	bne.n	c0d019c8 <__aeabi_uldivmod+0x28>
c0d019a4:	2a00      	cmp	r2, #0
c0d019a6:	d10f      	bne.n	c0d019c8 <__aeabi_uldivmod+0x28>
c0d019a8:	2900      	cmp	r1, #0
c0d019aa:	d100      	bne.n	c0d019ae <__aeabi_uldivmod+0xe>
c0d019ac:	2800      	cmp	r0, #0
c0d019ae:	d002      	beq.n	c0d019b6 <__aeabi_uldivmod+0x16>
c0d019b0:	2100      	movs	r1, #0
c0d019b2:	43c9      	mvns	r1, r1
c0d019b4:	0008      	movs	r0, r1
c0d019b6:	b407      	push	{r0, r1, r2}
c0d019b8:	4802      	ldr	r0, [pc, #8]	; (c0d019c4 <__aeabi_uldivmod+0x24>)
c0d019ba:	a102      	add	r1, pc, #8	; (adr r1, c0d019c4 <__aeabi_uldivmod+0x24>)
c0d019bc:	1840      	adds	r0, r0, r1
c0d019be:	9002      	str	r0, [sp, #8]
c0d019c0:	bd03      	pop	{r0, r1, pc}
c0d019c2:	46c0      	nop			; (mov r8, r8)
c0d019c4:	ffffff5d 	.word	0xffffff5d
c0d019c8:	b403      	push	{r0, r1}
c0d019ca:	4668      	mov	r0, sp
c0d019cc:	b501      	push	{r0, lr}
c0d019ce:	9802      	ldr	r0, [sp, #8]
c0d019d0:	f000 f852 	bl	c0d01a78 <__udivmoddi4>
c0d019d4:	9b01      	ldr	r3, [sp, #4]
c0d019d6:	469e      	mov	lr, r3
c0d019d8:	b002      	add	sp, #8
c0d019da:	bc0c      	pop	{r2, r3}
c0d019dc:	4770      	bx	lr
c0d019de:	46c0      	nop			; (mov r8, r8)

c0d019e0 <__aeabi_lmul>:
c0d019e0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d019e2:	46ce      	mov	lr, r9
c0d019e4:	4647      	mov	r7, r8
c0d019e6:	b580      	push	{r7, lr}
c0d019e8:	0007      	movs	r7, r0
c0d019ea:	4699      	mov	r9, r3
c0d019ec:	0c3b      	lsrs	r3, r7, #16
c0d019ee:	469c      	mov	ip, r3
c0d019f0:	0413      	lsls	r3, r2, #16
c0d019f2:	0c1b      	lsrs	r3, r3, #16
c0d019f4:	001d      	movs	r5, r3
c0d019f6:	000e      	movs	r6, r1
c0d019f8:	4661      	mov	r1, ip
c0d019fa:	0400      	lsls	r0, r0, #16
c0d019fc:	0c14      	lsrs	r4, r2, #16
c0d019fe:	0c00      	lsrs	r0, r0, #16
c0d01a00:	4345      	muls	r5, r0
c0d01a02:	434b      	muls	r3, r1
c0d01a04:	4360      	muls	r0, r4
c0d01a06:	4361      	muls	r1, r4
c0d01a08:	18c0      	adds	r0, r0, r3
c0d01a0a:	0c2c      	lsrs	r4, r5, #16
c0d01a0c:	1820      	adds	r0, r4, r0
c0d01a0e:	468c      	mov	ip, r1
c0d01a10:	4283      	cmp	r3, r0
c0d01a12:	d903      	bls.n	c0d01a1c <__aeabi_lmul+0x3c>
c0d01a14:	2380      	movs	r3, #128	; 0x80
c0d01a16:	025b      	lsls	r3, r3, #9
c0d01a18:	4698      	mov	r8, r3
c0d01a1a:	44c4      	add	ip, r8
c0d01a1c:	4649      	mov	r1, r9
c0d01a1e:	4379      	muls	r1, r7
c0d01a20:	4372      	muls	r2, r6
c0d01a22:	0c03      	lsrs	r3, r0, #16
c0d01a24:	4463      	add	r3, ip
c0d01a26:	042d      	lsls	r5, r5, #16
c0d01a28:	0c2d      	lsrs	r5, r5, #16
c0d01a2a:	18c9      	adds	r1, r1, r3
c0d01a2c:	0400      	lsls	r0, r0, #16
c0d01a2e:	1940      	adds	r0, r0, r5
c0d01a30:	1889      	adds	r1, r1, r2
c0d01a32:	bcc0      	pop	{r6, r7}
c0d01a34:	46b9      	mov	r9, r7
c0d01a36:	46b0      	mov	r8, r6
c0d01a38:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01a3a:	46c0      	nop			; (mov r8, r8)

c0d01a3c <__aeabi_d2uiz>:
c0d01a3c:	b570      	push	{r4, r5, r6, lr}
c0d01a3e:	2200      	movs	r2, #0
c0d01a40:	4b0c      	ldr	r3, [pc, #48]	; (c0d01a74 <__aeabi_d2uiz+0x38>)
c0d01a42:	0004      	movs	r4, r0
c0d01a44:	000d      	movs	r5, r1
c0d01a46:	f7ff ffa1 	bl	c0d0198c <__aeabi_dcmpge>
c0d01a4a:	2800      	cmp	r0, #0
c0d01a4c:	d104      	bne.n	c0d01a58 <__aeabi_d2uiz+0x1c>
c0d01a4e:	0020      	movs	r0, r4
c0d01a50:	0029      	movs	r1, r5
c0d01a52:	f001 fe39 	bl	c0d036c8 <__aeabi_d2iz>
c0d01a56:	bd70      	pop	{r4, r5, r6, pc}
c0d01a58:	4b06      	ldr	r3, [pc, #24]	; (c0d01a74 <__aeabi_d2uiz+0x38>)
c0d01a5a:	2200      	movs	r2, #0
c0d01a5c:	0020      	movs	r0, r4
c0d01a5e:	0029      	movs	r1, r5
c0d01a60:	f001 fa82 	bl	c0d02f68 <__aeabi_dsub>
c0d01a64:	f001 fe30 	bl	c0d036c8 <__aeabi_d2iz>
c0d01a68:	2380      	movs	r3, #128	; 0x80
c0d01a6a:	061b      	lsls	r3, r3, #24
c0d01a6c:	469c      	mov	ip, r3
c0d01a6e:	4460      	add	r0, ip
c0d01a70:	e7f1      	b.n	c0d01a56 <__aeabi_d2uiz+0x1a>
c0d01a72:	46c0      	nop			; (mov r8, r8)
c0d01a74:	41e00000 	.word	0x41e00000

c0d01a78 <__udivmoddi4>:
c0d01a78:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01a7a:	4657      	mov	r7, sl
c0d01a7c:	464e      	mov	r6, r9
c0d01a7e:	4645      	mov	r5, r8
c0d01a80:	46de      	mov	lr, fp
c0d01a82:	b5e0      	push	{r5, r6, r7, lr}
c0d01a84:	0004      	movs	r4, r0
c0d01a86:	000d      	movs	r5, r1
c0d01a88:	4692      	mov	sl, r2
c0d01a8a:	4699      	mov	r9, r3
c0d01a8c:	b083      	sub	sp, #12
c0d01a8e:	428b      	cmp	r3, r1
c0d01a90:	d830      	bhi.n	c0d01af4 <__udivmoddi4+0x7c>
c0d01a92:	d02d      	beq.n	c0d01af0 <__udivmoddi4+0x78>
c0d01a94:	4649      	mov	r1, r9
c0d01a96:	4650      	mov	r0, sl
c0d01a98:	f001 fec0 	bl	c0d0381c <__clzdi2>
c0d01a9c:	0029      	movs	r1, r5
c0d01a9e:	0006      	movs	r6, r0
c0d01aa0:	0020      	movs	r0, r4
c0d01aa2:	f001 febb 	bl	c0d0381c <__clzdi2>
c0d01aa6:	1a33      	subs	r3, r6, r0
c0d01aa8:	4698      	mov	r8, r3
c0d01aaa:	3b20      	subs	r3, #32
c0d01aac:	469b      	mov	fp, r3
c0d01aae:	d433      	bmi.n	c0d01b18 <__udivmoddi4+0xa0>
c0d01ab0:	465a      	mov	r2, fp
c0d01ab2:	4653      	mov	r3, sl
c0d01ab4:	4093      	lsls	r3, r2
c0d01ab6:	4642      	mov	r2, r8
c0d01ab8:	001f      	movs	r7, r3
c0d01aba:	4653      	mov	r3, sl
c0d01abc:	4093      	lsls	r3, r2
c0d01abe:	001e      	movs	r6, r3
c0d01ac0:	42af      	cmp	r7, r5
c0d01ac2:	d83a      	bhi.n	c0d01b3a <__udivmoddi4+0xc2>
c0d01ac4:	42af      	cmp	r7, r5
c0d01ac6:	d100      	bne.n	c0d01aca <__udivmoddi4+0x52>
c0d01ac8:	e078      	b.n	c0d01bbc <__udivmoddi4+0x144>
c0d01aca:	465b      	mov	r3, fp
c0d01acc:	1ba4      	subs	r4, r4, r6
c0d01ace:	41bd      	sbcs	r5, r7
c0d01ad0:	2b00      	cmp	r3, #0
c0d01ad2:	da00      	bge.n	c0d01ad6 <__udivmoddi4+0x5e>
c0d01ad4:	e075      	b.n	c0d01bc2 <__udivmoddi4+0x14a>
c0d01ad6:	2200      	movs	r2, #0
c0d01ad8:	2300      	movs	r3, #0
c0d01ada:	9200      	str	r2, [sp, #0]
c0d01adc:	9301      	str	r3, [sp, #4]
c0d01ade:	2301      	movs	r3, #1
c0d01ae0:	465a      	mov	r2, fp
c0d01ae2:	4093      	lsls	r3, r2
c0d01ae4:	9301      	str	r3, [sp, #4]
c0d01ae6:	2301      	movs	r3, #1
c0d01ae8:	4642      	mov	r2, r8
c0d01aea:	4093      	lsls	r3, r2
c0d01aec:	9300      	str	r3, [sp, #0]
c0d01aee:	e028      	b.n	c0d01b42 <__udivmoddi4+0xca>
c0d01af0:	4282      	cmp	r2, r0
c0d01af2:	d9cf      	bls.n	c0d01a94 <__udivmoddi4+0x1c>
c0d01af4:	2200      	movs	r2, #0
c0d01af6:	2300      	movs	r3, #0
c0d01af8:	9200      	str	r2, [sp, #0]
c0d01afa:	9301      	str	r3, [sp, #4]
c0d01afc:	9b0c      	ldr	r3, [sp, #48]	; 0x30
c0d01afe:	2b00      	cmp	r3, #0
c0d01b00:	d001      	beq.n	c0d01b06 <__udivmoddi4+0x8e>
c0d01b02:	601c      	str	r4, [r3, #0]
c0d01b04:	605d      	str	r5, [r3, #4]
c0d01b06:	9800      	ldr	r0, [sp, #0]
c0d01b08:	9901      	ldr	r1, [sp, #4]
c0d01b0a:	b003      	add	sp, #12
c0d01b0c:	bcf0      	pop	{r4, r5, r6, r7}
c0d01b0e:	46bb      	mov	fp, r7
c0d01b10:	46b2      	mov	sl, r6
c0d01b12:	46a9      	mov	r9, r5
c0d01b14:	46a0      	mov	r8, r4
c0d01b16:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01b18:	4642      	mov	r2, r8
c0d01b1a:	2320      	movs	r3, #32
c0d01b1c:	1a9b      	subs	r3, r3, r2
c0d01b1e:	4652      	mov	r2, sl
c0d01b20:	40da      	lsrs	r2, r3
c0d01b22:	4641      	mov	r1, r8
c0d01b24:	0013      	movs	r3, r2
c0d01b26:	464a      	mov	r2, r9
c0d01b28:	408a      	lsls	r2, r1
c0d01b2a:	0017      	movs	r7, r2
c0d01b2c:	4642      	mov	r2, r8
c0d01b2e:	431f      	orrs	r7, r3
c0d01b30:	4653      	mov	r3, sl
c0d01b32:	4093      	lsls	r3, r2
c0d01b34:	001e      	movs	r6, r3
c0d01b36:	42af      	cmp	r7, r5
c0d01b38:	d9c4      	bls.n	c0d01ac4 <__udivmoddi4+0x4c>
c0d01b3a:	2200      	movs	r2, #0
c0d01b3c:	2300      	movs	r3, #0
c0d01b3e:	9200      	str	r2, [sp, #0]
c0d01b40:	9301      	str	r3, [sp, #4]
c0d01b42:	4643      	mov	r3, r8
c0d01b44:	2b00      	cmp	r3, #0
c0d01b46:	d0d9      	beq.n	c0d01afc <__udivmoddi4+0x84>
c0d01b48:	07fb      	lsls	r3, r7, #31
c0d01b4a:	0872      	lsrs	r2, r6, #1
c0d01b4c:	431a      	orrs	r2, r3
c0d01b4e:	4646      	mov	r6, r8
c0d01b50:	087b      	lsrs	r3, r7, #1
c0d01b52:	e00e      	b.n	c0d01b72 <__udivmoddi4+0xfa>
c0d01b54:	42ab      	cmp	r3, r5
c0d01b56:	d101      	bne.n	c0d01b5c <__udivmoddi4+0xe4>
c0d01b58:	42a2      	cmp	r2, r4
c0d01b5a:	d80c      	bhi.n	c0d01b76 <__udivmoddi4+0xfe>
c0d01b5c:	1aa4      	subs	r4, r4, r2
c0d01b5e:	419d      	sbcs	r5, r3
c0d01b60:	2001      	movs	r0, #1
c0d01b62:	1924      	adds	r4, r4, r4
c0d01b64:	416d      	adcs	r5, r5
c0d01b66:	2100      	movs	r1, #0
c0d01b68:	3e01      	subs	r6, #1
c0d01b6a:	1824      	adds	r4, r4, r0
c0d01b6c:	414d      	adcs	r5, r1
c0d01b6e:	2e00      	cmp	r6, #0
c0d01b70:	d006      	beq.n	c0d01b80 <__udivmoddi4+0x108>
c0d01b72:	42ab      	cmp	r3, r5
c0d01b74:	d9ee      	bls.n	c0d01b54 <__udivmoddi4+0xdc>
c0d01b76:	3e01      	subs	r6, #1
c0d01b78:	1924      	adds	r4, r4, r4
c0d01b7a:	416d      	adcs	r5, r5
c0d01b7c:	2e00      	cmp	r6, #0
c0d01b7e:	d1f8      	bne.n	c0d01b72 <__udivmoddi4+0xfa>
c0d01b80:	9800      	ldr	r0, [sp, #0]
c0d01b82:	9901      	ldr	r1, [sp, #4]
c0d01b84:	465b      	mov	r3, fp
c0d01b86:	1900      	adds	r0, r0, r4
c0d01b88:	4169      	adcs	r1, r5
c0d01b8a:	2b00      	cmp	r3, #0
c0d01b8c:	db24      	blt.n	c0d01bd8 <__udivmoddi4+0x160>
c0d01b8e:	002b      	movs	r3, r5
c0d01b90:	465a      	mov	r2, fp
c0d01b92:	4644      	mov	r4, r8
c0d01b94:	40d3      	lsrs	r3, r2
c0d01b96:	002a      	movs	r2, r5
c0d01b98:	40e2      	lsrs	r2, r4
c0d01b9a:	001c      	movs	r4, r3
c0d01b9c:	465b      	mov	r3, fp
c0d01b9e:	0015      	movs	r5, r2
c0d01ba0:	2b00      	cmp	r3, #0
c0d01ba2:	db2a      	blt.n	c0d01bfa <__udivmoddi4+0x182>
c0d01ba4:	0026      	movs	r6, r4
c0d01ba6:	409e      	lsls	r6, r3
c0d01ba8:	0033      	movs	r3, r6
c0d01baa:	0026      	movs	r6, r4
c0d01bac:	4647      	mov	r7, r8
c0d01bae:	40be      	lsls	r6, r7
c0d01bb0:	0032      	movs	r2, r6
c0d01bb2:	1a80      	subs	r0, r0, r2
c0d01bb4:	4199      	sbcs	r1, r3
c0d01bb6:	9000      	str	r0, [sp, #0]
c0d01bb8:	9101      	str	r1, [sp, #4]
c0d01bba:	e79f      	b.n	c0d01afc <__udivmoddi4+0x84>
c0d01bbc:	42a3      	cmp	r3, r4
c0d01bbe:	d8bc      	bhi.n	c0d01b3a <__udivmoddi4+0xc2>
c0d01bc0:	e783      	b.n	c0d01aca <__udivmoddi4+0x52>
c0d01bc2:	4642      	mov	r2, r8
c0d01bc4:	2320      	movs	r3, #32
c0d01bc6:	2100      	movs	r1, #0
c0d01bc8:	1a9b      	subs	r3, r3, r2
c0d01bca:	2200      	movs	r2, #0
c0d01bcc:	9100      	str	r1, [sp, #0]
c0d01bce:	9201      	str	r2, [sp, #4]
c0d01bd0:	2201      	movs	r2, #1
c0d01bd2:	40da      	lsrs	r2, r3
c0d01bd4:	9201      	str	r2, [sp, #4]
c0d01bd6:	e786      	b.n	c0d01ae6 <__udivmoddi4+0x6e>
c0d01bd8:	4642      	mov	r2, r8
c0d01bda:	2320      	movs	r3, #32
c0d01bdc:	1a9b      	subs	r3, r3, r2
c0d01bde:	002a      	movs	r2, r5
c0d01be0:	4646      	mov	r6, r8
c0d01be2:	409a      	lsls	r2, r3
c0d01be4:	0023      	movs	r3, r4
c0d01be6:	40f3      	lsrs	r3, r6
c0d01be8:	4644      	mov	r4, r8
c0d01bea:	4313      	orrs	r3, r2
c0d01bec:	002a      	movs	r2, r5
c0d01bee:	40e2      	lsrs	r2, r4
c0d01bf0:	001c      	movs	r4, r3
c0d01bf2:	465b      	mov	r3, fp
c0d01bf4:	0015      	movs	r5, r2
c0d01bf6:	2b00      	cmp	r3, #0
c0d01bf8:	dad4      	bge.n	c0d01ba4 <__udivmoddi4+0x12c>
c0d01bfa:	4642      	mov	r2, r8
c0d01bfc:	002f      	movs	r7, r5
c0d01bfe:	2320      	movs	r3, #32
c0d01c00:	0026      	movs	r6, r4
c0d01c02:	4097      	lsls	r7, r2
c0d01c04:	1a9b      	subs	r3, r3, r2
c0d01c06:	40de      	lsrs	r6, r3
c0d01c08:	003b      	movs	r3, r7
c0d01c0a:	4333      	orrs	r3, r6
c0d01c0c:	e7cd      	b.n	c0d01baa <__udivmoddi4+0x132>
c0d01c0e:	46c0      	nop			; (mov r8, r8)

c0d01c10 <__aeabi_dadd>:
c0d01c10:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01c12:	464f      	mov	r7, r9
c0d01c14:	4646      	mov	r6, r8
c0d01c16:	46d6      	mov	lr, sl
c0d01c18:	000d      	movs	r5, r1
c0d01c1a:	0004      	movs	r4, r0
c0d01c1c:	b5c0      	push	{r6, r7, lr}
c0d01c1e:	001f      	movs	r7, r3
c0d01c20:	0011      	movs	r1, r2
c0d01c22:	0328      	lsls	r0, r5, #12
c0d01c24:	0f62      	lsrs	r2, r4, #29
c0d01c26:	0a40      	lsrs	r0, r0, #9
c0d01c28:	4310      	orrs	r0, r2
c0d01c2a:	007a      	lsls	r2, r7, #1
c0d01c2c:	0d52      	lsrs	r2, r2, #21
c0d01c2e:	00e3      	lsls	r3, r4, #3
c0d01c30:	033c      	lsls	r4, r7, #12
c0d01c32:	4691      	mov	r9, r2
c0d01c34:	0a64      	lsrs	r4, r4, #9
c0d01c36:	0ffa      	lsrs	r2, r7, #31
c0d01c38:	0f4f      	lsrs	r7, r1, #29
c0d01c3a:	006e      	lsls	r6, r5, #1
c0d01c3c:	4327      	orrs	r7, r4
c0d01c3e:	4692      	mov	sl, r2
c0d01c40:	46b8      	mov	r8, r7
c0d01c42:	0d76      	lsrs	r6, r6, #21
c0d01c44:	0fed      	lsrs	r5, r5, #31
c0d01c46:	00c9      	lsls	r1, r1, #3
c0d01c48:	4295      	cmp	r5, r2
c0d01c4a:	d100      	bne.n	c0d01c4e <__aeabi_dadd+0x3e>
c0d01c4c:	e099      	b.n	c0d01d82 <__aeabi_dadd+0x172>
c0d01c4e:	464c      	mov	r4, r9
c0d01c50:	1b34      	subs	r4, r6, r4
c0d01c52:	46a4      	mov	ip, r4
c0d01c54:	2c00      	cmp	r4, #0
c0d01c56:	dc00      	bgt.n	c0d01c5a <__aeabi_dadd+0x4a>
c0d01c58:	e07c      	b.n	c0d01d54 <__aeabi_dadd+0x144>
c0d01c5a:	464a      	mov	r2, r9
c0d01c5c:	2a00      	cmp	r2, #0
c0d01c5e:	d100      	bne.n	c0d01c62 <__aeabi_dadd+0x52>
c0d01c60:	e0b8      	b.n	c0d01dd4 <__aeabi_dadd+0x1c4>
c0d01c62:	4ac5      	ldr	r2, [pc, #788]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01c64:	4296      	cmp	r6, r2
c0d01c66:	d100      	bne.n	c0d01c6a <__aeabi_dadd+0x5a>
c0d01c68:	e11c      	b.n	c0d01ea4 <__aeabi_dadd+0x294>
c0d01c6a:	2280      	movs	r2, #128	; 0x80
c0d01c6c:	003c      	movs	r4, r7
c0d01c6e:	0412      	lsls	r2, r2, #16
c0d01c70:	4314      	orrs	r4, r2
c0d01c72:	46a0      	mov	r8, r4
c0d01c74:	4662      	mov	r2, ip
c0d01c76:	2a38      	cmp	r2, #56	; 0x38
c0d01c78:	dd00      	ble.n	c0d01c7c <__aeabi_dadd+0x6c>
c0d01c7a:	e161      	b.n	c0d01f40 <__aeabi_dadd+0x330>
c0d01c7c:	2a1f      	cmp	r2, #31
c0d01c7e:	dd00      	ble.n	c0d01c82 <__aeabi_dadd+0x72>
c0d01c80:	e1cc      	b.n	c0d0201c <__aeabi_dadd+0x40c>
c0d01c82:	4664      	mov	r4, ip
c0d01c84:	2220      	movs	r2, #32
c0d01c86:	1b12      	subs	r2, r2, r4
c0d01c88:	4644      	mov	r4, r8
c0d01c8a:	4094      	lsls	r4, r2
c0d01c8c:	000f      	movs	r7, r1
c0d01c8e:	46a1      	mov	r9, r4
c0d01c90:	4664      	mov	r4, ip
c0d01c92:	4091      	lsls	r1, r2
c0d01c94:	40e7      	lsrs	r7, r4
c0d01c96:	464c      	mov	r4, r9
c0d01c98:	1e4a      	subs	r2, r1, #1
c0d01c9a:	4191      	sbcs	r1, r2
c0d01c9c:	433c      	orrs	r4, r7
c0d01c9e:	4642      	mov	r2, r8
c0d01ca0:	4321      	orrs	r1, r4
c0d01ca2:	4664      	mov	r4, ip
c0d01ca4:	40e2      	lsrs	r2, r4
c0d01ca6:	1a80      	subs	r0, r0, r2
c0d01ca8:	1a5c      	subs	r4, r3, r1
c0d01caa:	42a3      	cmp	r3, r4
c0d01cac:	419b      	sbcs	r3, r3
c0d01cae:	425f      	negs	r7, r3
c0d01cb0:	1bc7      	subs	r7, r0, r7
c0d01cb2:	023b      	lsls	r3, r7, #8
c0d01cb4:	d400      	bmi.n	c0d01cb8 <__aeabi_dadd+0xa8>
c0d01cb6:	e0d0      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d01cb8:	027f      	lsls	r7, r7, #9
c0d01cba:	0a7f      	lsrs	r7, r7, #9
c0d01cbc:	2f00      	cmp	r7, #0
c0d01cbe:	d100      	bne.n	c0d01cc2 <__aeabi_dadd+0xb2>
c0d01cc0:	e0ff      	b.n	c0d01ec2 <__aeabi_dadd+0x2b2>
c0d01cc2:	0038      	movs	r0, r7
c0d01cc4:	f001 fd8c 	bl	c0d037e0 <__clzsi2>
c0d01cc8:	0001      	movs	r1, r0
c0d01cca:	3908      	subs	r1, #8
c0d01ccc:	2320      	movs	r3, #32
c0d01cce:	0022      	movs	r2, r4
c0d01cd0:	1a5b      	subs	r3, r3, r1
c0d01cd2:	408f      	lsls	r7, r1
c0d01cd4:	40da      	lsrs	r2, r3
c0d01cd6:	408c      	lsls	r4, r1
c0d01cd8:	4317      	orrs	r7, r2
c0d01cda:	42b1      	cmp	r1, r6
c0d01cdc:	da00      	bge.n	c0d01ce0 <__aeabi_dadd+0xd0>
c0d01cde:	e0ff      	b.n	c0d01ee0 <__aeabi_dadd+0x2d0>
c0d01ce0:	1b89      	subs	r1, r1, r6
c0d01ce2:	1c4b      	adds	r3, r1, #1
c0d01ce4:	2b1f      	cmp	r3, #31
c0d01ce6:	dd00      	ble.n	c0d01cea <__aeabi_dadd+0xda>
c0d01ce8:	e0a8      	b.n	c0d01e3c <__aeabi_dadd+0x22c>
c0d01cea:	2220      	movs	r2, #32
c0d01cec:	0039      	movs	r1, r7
c0d01cee:	1ad2      	subs	r2, r2, r3
c0d01cf0:	0020      	movs	r0, r4
c0d01cf2:	4094      	lsls	r4, r2
c0d01cf4:	4091      	lsls	r1, r2
c0d01cf6:	40d8      	lsrs	r0, r3
c0d01cf8:	1e62      	subs	r2, r4, #1
c0d01cfa:	4194      	sbcs	r4, r2
c0d01cfc:	40df      	lsrs	r7, r3
c0d01cfe:	2600      	movs	r6, #0
c0d01d00:	4301      	orrs	r1, r0
c0d01d02:	430c      	orrs	r4, r1
c0d01d04:	0763      	lsls	r3, r4, #29
c0d01d06:	d009      	beq.n	c0d01d1c <__aeabi_dadd+0x10c>
c0d01d08:	230f      	movs	r3, #15
c0d01d0a:	4023      	ands	r3, r4
c0d01d0c:	2b04      	cmp	r3, #4
c0d01d0e:	d005      	beq.n	c0d01d1c <__aeabi_dadd+0x10c>
c0d01d10:	1d23      	adds	r3, r4, #4
c0d01d12:	42a3      	cmp	r3, r4
c0d01d14:	41a4      	sbcs	r4, r4
c0d01d16:	4264      	negs	r4, r4
c0d01d18:	193f      	adds	r7, r7, r4
c0d01d1a:	001c      	movs	r4, r3
c0d01d1c:	023b      	lsls	r3, r7, #8
c0d01d1e:	d400      	bmi.n	c0d01d22 <__aeabi_dadd+0x112>
c0d01d20:	e09e      	b.n	c0d01e60 <__aeabi_dadd+0x250>
c0d01d22:	4b95      	ldr	r3, [pc, #596]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01d24:	3601      	adds	r6, #1
c0d01d26:	429e      	cmp	r6, r3
c0d01d28:	d100      	bne.n	c0d01d2c <__aeabi_dadd+0x11c>
c0d01d2a:	e0b7      	b.n	c0d01e9c <__aeabi_dadd+0x28c>
c0d01d2c:	4a93      	ldr	r2, [pc, #588]	; (c0d01f7c <__aeabi_dadd+0x36c>)
c0d01d2e:	08e4      	lsrs	r4, r4, #3
c0d01d30:	4017      	ands	r7, r2
c0d01d32:	077b      	lsls	r3, r7, #29
c0d01d34:	0571      	lsls	r1, r6, #21
c0d01d36:	027f      	lsls	r7, r7, #9
c0d01d38:	4323      	orrs	r3, r4
c0d01d3a:	0b3f      	lsrs	r7, r7, #12
c0d01d3c:	0d4a      	lsrs	r2, r1, #21
c0d01d3e:	0512      	lsls	r2, r2, #20
c0d01d40:	433a      	orrs	r2, r7
c0d01d42:	07ed      	lsls	r5, r5, #31
c0d01d44:	432a      	orrs	r2, r5
c0d01d46:	0018      	movs	r0, r3
c0d01d48:	0011      	movs	r1, r2
c0d01d4a:	bce0      	pop	{r5, r6, r7}
c0d01d4c:	46ba      	mov	sl, r7
c0d01d4e:	46b1      	mov	r9, r6
c0d01d50:	46a8      	mov	r8, r5
c0d01d52:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01d54:	2c00      	cmp	r4, #0
c0d01d56:	d04b      	beq.n	c0d01df0 <__aeabi_dadd+0x1e0>
c0d01d58:	464c      	mov	r4, r9
c0d01d5a:	1ba4      	subs	r4, r4, r6
c0d01d5c:	46a4      	mov	ip, r4
c0d01d5e:	2e00      	cmp	r6, #0
c0d01d60:	d000      	beq.n	c0d01d64 <__aeabi_dadd+0x154>
c0d01d62:	e123      	b.n	c0d01fac <__aeabi_dadd+0x39c>
c0d01d64:	0004      	movs	r4, r0
c0d01d66:	431c      	orrs	r4, r3
c0d01d68:	d100      	bne.n	c0d01d6c <__aeabi_dadd+0x15c>
c0d01d6a:	e1af      	b.n	c0d020cc <__aeabi_dadd+0x4bc>
c0d01d6c:	4662      	mov	r2, ip
c0d01d6e:	1e54      	subs	r4, r2, #1
c0d01d70:	2a01      	cmp	r2, #1
c0d01d72:	d100      	bne.n	c0d01d76 <__aeabi_dadd+0x166>
c0d01d74:	e215      	b.n	c0d021a2 <__aeabi_dadd+0x592>
c0d01d76:	4d80      	ldr	r5, [pc, #512]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01d78:	45ac      	cmp	ip, r5
c0d01d7a:	d100      	bne.n	c0d01d7e <__aeabi_dadd+0x16e>
c0d01d7c:	e1c8      	b.n	c0d02110 <__aeabi_dadd+0x500>
c0d01d7e:	46a4      	mov	ip, r4
c0d01d80:	e11b      	b.n	c0d01fba <__aeabi_dadd+0x3aa>
c0d01d82:	464a      	mov	r2, r9
c0d01d84:	1ab2      	subs	r2, r6, r2
c0d01d86:	4694      	mov	ip, r2
c0d01d88:	2a00      	cmp	r2, #0
c0d01d8a:	dc00      	bgt.n	c0d01d8e <__aeabi_dadd+0x17e>
c0d01d8c:	e0ac      	b.n	c0d01ee8 <__aeabi_dadd+0x2d8>
c0d01d8e:	464a      	mov	r2, r9
c0d01d90:	2a00      	cmp	r2, #0
c0d01d92:	d043      	beq.n	c0d01e1c <__aeabi_dadd+0x20c>
c0d01d94:	4a78      	ldr	r2, [pc, #480]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01d96:	4296      	cmp	r6, r2
c0d01d98:	d100      	bne.n	c0d01d9c <__aeabi_dadd+0x18c>
c0d01d9a:	e1af      	b.n	c0d020fc <__aeabi_dadd+0x4ec>
c0d01d9c:	2280      	movs	r2, #128	; 0x80
c0d01d9e:	003c      	movs	r4, r7
c0d01da0:	0412      	lsls	r2, r2, #16
c0d01da2:	4314      	orrs	r4, r2
c0d01da4:	46a0      	mov	r8, r4
c0d01da6:	4662      	mov	r2, ip
c0d01da8:	2a38      	cmp	r2, #56	; 0x38
c0d01daa:	dc67      	bgt.n	c0d01e7c <__aeabi_dadd+0x26c>
c0d01dac:	2a1f      	cmp	r2, #31
c0d01dae:	dc00      	bgt.n	c0d01db2 <__aeabi_dadd+0x1a2>
c0d01db0:	e15f      	b.n	c0d02072 <__aeabi_dadd+0x462>
c0d01db2:	4647      	mov	r7, r8
c0d01db4:	3a20      	subs	r2, #32
c0d01db6:	40d7      	lsrs	r7, r2
c0d01db8:	4662      	mov	r2, ip
c0d01dba:	2a20      	cmp	r2, #32
c0d01dbc:	d005      	beq.n	c0d01dca <__aeabi_dadd+0x1ba>
c0d01dbe:	4664      	mov	r4, ip
c0d01dc0:	2240      	movs	r2, #64	; 0x40
c0d01dc2:	1b12      	subs	r2, r2, r4
c0d01dc4:	4644      	mov	r4, r8
c0d01dc6:	4094      	lsls	r4, r2
c0d01dc8:	4321      	orrs	r1, r4
c0d01dca:	1e4a      	subs	r2, r1, #1
c0d01dcc:	4191      	sbcs	r1, r2
c0d01dce:	000c      	movs	r4, r1
c0d01dd0:	433c      	orrs	r4, r7
c0d01dd2:	e057      	b.n	c0d01e84 <__aeabi_dadd+0x274>
c0d01dd4:	003a      	movs	r2, r7
c0d01dd6:	430a      	orrs	r2, r1
c0d01dd8:	d100      	bne.n	c0d01ddc <__aeabi_dadd+0x1cc>
c0d01dda:	e105      	b.n	c0d01fe8 <__aeabi_dadd+0x3d8>
c0d01ddc:	0022      	movs	r2, r4
c0d01dde:	3a01      	subs	r2, #1
c0d01de0:	2c01      	cmp	r4, #1
c0d01de2:	d100      	bne.n	c0d01de6 <__aeabi_dadd+0x1d6>
c0d01de4:	e182      	b.n	c0d020ec <__aeabi_dadd+0x4dc>
c0d01de6:	4c64      	ldr	r4, [pc, #400]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01de8:	45a4      	cmp	ip, r4
c0d01dea:	d05b      	beq.n	c0d01ea4 <__aeabi_dadd+0x294>
c0d01dec:	4694      	mov	ip, r2
c0d01dee:	e741      	b.n	c0d01c74 <__aeabi_dadd+0x64>
c0d01df0:	4c63      	ldr	r4, [pc, #396]	; (c0d01f80 <__aeabi_dadd+0x370>)
c0d01df2:	1c77      	adds	r7, r6, #1
c0d01df4:	4227      	tst	r7, r4
c0d01df6:	d000      	beq.n	c0d01dfa <__aeabi_dadd+0x1ea>
c0d01df8:	e0c4      	b.n	c0d01f84 <__aeabi_dadd+0x374>
c0d01dfa:	0004      	movs	r4, r0
c0d01dfc:	431c      	orrs	r4, r3
c0d01dfe:	2e00      	cmp	r6, #0
c0d01e00:	d000      	beq.n	c0d01e04 <__aeabi_dadd+0x1f4>
c0d01e02:	e169      	b.n	c0d020d8 <__aeabi_dadd+0x4c8>
c0d01e04:	2c00      	cmp	r4, #0
c0d01e06:	d100      	bne.n	c0d01e0a <__aeabi_dadd+0x1fa>
c0d01e08:	e1bf      	b.n	c0d0218a <__aeabi_dadd+0x57a>
c0d01e0a:	4644      	mov	r4, r8
c0d01e0c:	430c      	orrs	r4, r1
c0d01e0e:	d000      	beq.n	c0d01e12 <__aeabi_dadd+0x202>
c0d01e10:	e1d0      	b.n	c0d021b4 <__aeabi_dadd+0x5a4>
c0d01e12:	0742      	lsls	r2, r0, #29
c0d01e14:	08db      	lsrs	r3, r3, #3
c0d01e16:	4313      	orrs	r3, r2
c0d01e18:	08c0      	lsrs	r0, r0, #3
c0d01e1a:	e029      	b.n	c0d01e70 <__aeabi_dadd+0x260>
c0d01e1c:	003a      	movs	r2, r7
c0d01e1e:	430a      	orrs	r2, r1
c0d01e20:	d100      	bne.n	c0d01e24 <__aeabi_dadd+0x214>
c0d01e22:	e170      	b.n	c0d02106 <__aeabi_dadd+0x4f6>
c0d01e24:	4662      	mov	r2, ip
c0d01e26:	4664      	mov	r4, ip
c0d01e28:	3a01      	subs	r2, #1
c0d01e2a:	2c01      	cmp	r4, #1
c0d01e2c:	d100      	bne.n	c0d01e30 <__aeabi_dadd+0x220>
c0d01e2e:	e0e0      	b.n	c0d01ff2 <__aeabi_dadd+0x3e2>
c0d01e30:	4c51      	ldr	r4, [pc, #324]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01e32:	45a4      	cmp	ip, r4
c0d01e34:	d100      	bne.n	c0d01e38 <__aeabi_dadd+0x228>
c0d01e36:	e161      	b.n	c0d020fc <__aeabi_dadd+0x4ec>
c0d01e38:	4694      	mov	ip, r2
c0d01e3a:	e7b4      	b.n	c0d01da6 <__aeabi_dadd+0x196>
c0d01e3c:	003a      	movs	r2, r7
c0d01e3e:	391f      	subs	r1, #31
c0d01e40:	40ca      	lsrs	r2, r1
c0d01e42:	0011      	movs	r1, r2
c0d01e44:	2b20      	cmp	r3, #32
c0d01e46:	d003      	beq.n	c0d01e50 <__aeabi_dadd+0x240>
c0d01e48:	2240      	movs	r2, #64	; 0x40
c0d01e4a:	1ad3      	subs	r3, r2, r3
c0d01e4c:	409f      	lsls	r7, r3
c0d01e4e:	433c      	orrs	r4, r7
c0d01e50:	1e63      	subs	r3, r4, #1
c0d01e52:	419c      	sbcs	r4, r3
c0d01e54:	2700      	movs	r7, #0
c0d01e56:	2600      	movs	r6, #0
c0d01e58:	430c      	orrs	r4, r1
c0d01e5a:	0763      	lsls	r3, r4, #29
c0d01e5c:	d000      	beq.n	c0d01e60 <__aeabi_dadd+0x250>
c0d01e5e:	e753      	b.n	c0d01d08 <__aeabi_dadd+0xf8>
c0d01e60:	46b4      	mov	ip, r6
c0d01e62:	08e4      	lsrs	r4, r4, #3
c0d01e64:	077b      	lsls	r3, r7, #29
c0d01e66:	4323      	orrs	r3, r4
c0d01e68:	08f8      	lsrs	r0, r7, #3
c0d01e6a:	4a43      	ldr	r2, [pc, #268]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01e6c:	4594      	cmp	ip, r2
c0d01e6e:	d01d      	beq.n	c0d01eac <__aeabi_dadd+0x29c>
c0d01e70:	4662      	mov	r2, ip
c0d01e72:	0307      	lsls	r7, r0, #12
c0d01e74:	0552      	lsls	r2, r2, #21
c0d01e76:	0b3f      	lsrs	r7, r7, #12
c0d01e78:	0d52      	lsrs	r2, r2, #21
c0d01e7a:	e760      	b.n	c0d01d3e <__aeabi_dadd+0x12e>
c0d01e7c:	4644      	mov	r4, r8
c0d01e7e:	430c      	orrs	r4, r1
c0d01e80:	1e62      	subs	r2, r4, #1
c0d01e82:	4194      	sbcs	r4, r2
c0d01e84:	18e4      	adds	r4, r4, r3
c0d01e86:	429c      	cmp	r4, r3
c0d01e88:	419b      	sbcs	r3, r3
c0d01e8a:	425f      	negs	r7, r3
c0d01e8c:	183f      	adds	r7, r7, r0
c0d01e8e:	023b      	lsls	r3, r7, #8
c0d01e90:	d5e3      	bpl.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d01e92:	4b39      	ldr	r3, [pc, #228]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01e94:	3601      	adds	r6, #1
c0d01e96:	429e      	cmp	r6, r3
c0d01e98:	d000      	beq.n	c0d01e9c <__aeabi_dadd+0x28c>
c0d01e9a:	e0b5      	b.n	c0d02008 <__aeabi_dadd+0x3f8>
c0d01e9c:	0032      	movs	r2, r6
c0d01e9e:	2700      	movs	r7, #0
c0d01ea0:	2300      	movs	r3, #0
c0d01ea2:	e74c      	b.n	c0d01d3e <__aeabi_dadd+0x12e>
c0d01ea4:	0742      	lsls	r2, r0, #29
c0d01ea6:	08db      	lsrs	r3, r3, #3
c0d01ea8:	4313      	orrs	r3, r2
c0d01eaa:	08c0      	lsrs	r0, r0, #3
c0d01eac:	001a      	movs	r2, r3
c0d01eae:	4302      	orrs	r2, r0
c0d01eb0:	d100      	bne.n	c0d01eb4 <__aeabi_dadd+0x2a4>
c0d01eb2:	e1e1      	b.n	c0d02278 <__aeabi_dadd+0x668>
c0d01eb4:	2780      	movs	r7, #128	; 0x80
c0d01eb6:	033f      	lsls	r7, r7, #12
c0d01eb8:	4307      	orrs	r7, r0
c0d01eba:	033f      	lsls	r7, r7, #12
c0d01ebc:	4a2e      	ldr	r2, [pc, #184]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01ebe:	0b3f      	lsrs	r7, r7, #12
c0d01ec0:	e73d      	b.n	c0d01d3e <__aeabi_dadd+0x12e>
c0d01ec2:	0020      	movs	r0, r4
c0d01ec4:	f001 fc8c 	bl	c0d037e0 <__clzsi2>
c0d01ec8:	0001      	movs	r1, r0
c0d01eca:	3118      	adds	r1, #24
c0d01ecc:	291f      	cmp	r1, #31
c0d01ece:	dc00      	bgt.n	c0d01ed2 <__aeabi_dadd+0x2c2>
c0d01ed0:	e6fc      	b.n	c0d01ccc <__aeabi_dadd+0xbc>
c0d01ed2:	3808      	subs	r0, #8
c0d01ed4:	4084      	lsls	r4, r0
c0d01ed6:	0027      	movs	r7, r4
c0d01ed8:	2400      	movs	r4, #0
c0d01eda:	42b1      	cmp	r1, r6
c0d01edc:	db00      	blt.n	c0d01ee0 <__aeabi_dadd+0x2d0>
c0d01ede:	e6ff      	b.n	c0d01ce0 <__aeabi_dadd+0xd0>
c0d01ee0:	4a26      	ldr	r2, [pc, #152]	; (c0d01f7c <__aeabi_dadd+0x36c>)
c0d01ee2:	1a76      	subs	r6, r6, r1
c0d01ee4:	4017      	ands	r7, r2
c0d01ee6:	e70d      	b.n	c0d01d04 <__aeabi_dadd+0xf4>
c0d01ee8:	2a00      	cmp	r2, #0
c0d01eea:	d02f      	beq.n	c0d01f4c <__aeabi_dadd+0x33c>
c0d01eec:	464a      	mov	r2, r9
c0d01eee:	1b92      	subs	r2, r2, r6
c0d01ef0:	4694      	mov	ip, r2
c0d01ef2:	2e00      	cmp	r6, #0
c0d01ef4:	d100      	bne.n	c0d01ef8 <__aeabi_dadd+0x2e8>
c0d01ef6:	e0ad      	b.n	c0d02054 <__aeabi_dadd+0x444>
c0d01ef8:	4a1f      	ldr	r2, [pc, #124]	; (c0d01f78 <__aeabi_dadd+0x368>)
c0d01efa:	4591      	cmp	r9, r2
c0d01efc:	d100      	bne.n	c0d01f00 <__aeabi_dadd+0x2f0>
c0d01efe:	e10f      	b.n	c0d02120 <__aeabi_dadd+0x510>
c0d01f00:	2280      	movs	r2, #128	; 0x80
c0d01f02:	0412      	lsls	r2, r2, #16
c0d01f04:	4310      	orrs	r0, r2
c0d01f06:	4662      	mov	r2, ip
c0d01f08:	2a38      	cmp	r2, #56	; 0x38
c0d01f0a:	dd00      	ble.n	c0d01f0e <__aeabi_dadd+0x2fe>
c0d01f0c:	e10f      	b.n	c0d0212e <__aeabi_dadd+0x51e>
c0d01f0e:	2a1f      	cmp	r2, #31
c0d01f10:	dd00      	ble.n	c0d01f14 <__aeabi_dadd+0x304>
c0d01f12:	e180      	b.n	c0d02216 <__aeabi_dadd+0x606>
c0d01f14:	4664      	mov	r4, ip
c0d01f16:	2220      	movs	r2, #32
c0d01f18:	001e      	movs	r6, r3
c0d01f1a:	1b12      	subs	r2, r2, r4
c0d01f1c:	4667      	mov	r7, ip
c0d01f1e:	0004      	movs	r4, r0
c0d01f20:	4093      	lsls	r3, r2
c0d01f22:	4094      	lsls	r4, r2
c0d01f24:	40fe      	lsrs	r6, r7
c0d01f26:	1e5a      	subs	r2, r3, #1
c0d01f28:	4193      	sbcs	r3, r2
c0d01f2a:	40f8      	lsrs	r0, r7
c0d01f2c:	4334      	orrs	r4, r6
c0d01f2e:	431c      	orrs	r4, r3
c0d01f30:	4480      	add	r8, r0
c0d01f32:	1864      	adds	r4, r4, r1
c0d01f34:	428c      	cmp	r4, r1
c0d01f36:	41bf      	sbcs	r7, r7
c0d01f38:	427f      	negs	r7, r7
c0d01f3a:	464e      	mov	r6, r9
c0d01f3c:	4447      	add	r7, r8
c0d01f3e:	e7a6      	b.n	c0d01e8e <__aeabi_dadd+0x27e>
c0d01f40:	4642      	mov	r2, r8
c0d01f42:	430a      	orrs	r2, r1
c0d01f44:	0011      	movs	r1, r2
c0d01f46:	1e4a      	subs	r2, r1, #1
c0d01f48:	4191      	sbcs	r1, r2
c0d01f4a:	e6ad      	b.n	c0d01ca8 <__aeabi_dadd+0x98>
c0d01f4c:	4c0c      	ldr	r4, [pc, #48]	; (c0d01f80 <__aeabi_dadd+0x370>)
c0d01f4e:	1c72      	adds	r2, r6, #1
c0d01f50:	4222      	tst	r2, r4
c0d01f52:	d000      	beq.n	c0d01f56 <__aeabi_dadd+0x346>
c0d01f54:	e0a1      	b.n	c0d0209a <__aeabi_dadd+0x48a>
c0d01f56:	0002      	movs	r2, r0
c0d01f58:	431a      	orrs	r2, r3
c0d01f5a:	2e00      	cmp	r6, #0
c0d01f5c:	d000      	beq.n	c0d01f60 <__aeabi_dadd+0x350>
c0d01f5e:	e0fa      	b.n	c0d02156 <__aeabi_dadd+0x546>
c0d01f60:	2a00      	cmp	r2, #0
c0d01f62:	d100      	bne.n	c0d01f66 <__aeabi_dadd+0x356>
c0d01f64:	e145      	b.n	c0d021f2 <__aeabi_dadd+0x5e2>
c0d01f66:	003a      	movs	r2, r7
c0d01f68:	430a      	orrs	r2, r1
c0d01f6a:	d000      	beq.n	c0d01f6e <__aeabi_dadd+0x35e>
c0d01f6c:	e146      	b.n	c0d021fc <__aeabi_dadd+0x5ec>
c0d01f6e:	0742      	lsls	r2, r0, #29
c0d01f70:	08db      	lsrs	r3, r3, #3
c0d01f72:	4313      	orrs	r3, r2
c0d01f74:	08c0      	lsrs	r0, r0, #3
c0d01f76:	e77b      	b.n	c0d01e70 <__aeabi_dadd+0x260>
c0d01f78:	000007ff 	.word	0x000007ff
c0d01f7c:	ff7fffff 	.word	0xff7fffff
c0d01f80:	000007fe 	.word	0x000007fe
c0d01f84:	4647      	mov	r7, r8
c0d01f86:	1a5c      	subs	r4, r3, r1
c0d01f88:	1bc2      	subs	r2, r0, r7
c0d01f8a:	42a3      	cmp	r3, r4
c0d01f8c:	41bf      	sbcs	r7, r7
c0d01f8e:	427f      	negs	r7, r7
c0d01f90:	46b9      	mov	r9, r7
c0d01f92:	0017      	movs	r7, r2
c0d01f94:	464a      	mov	r2, r9
c0d01f96:	1abf      	subs	r7, r7, r2
c0d01f98:	023a      	lsls	r2, r7, #8
c0d01f9a:	d500      	bpl.n	c0d01f9e <__aeabi_dadd+0x38e>
c0d01f9c:	e08d      	b.n	c0d020ba <__aeabi_dadd+0x4aa>
c0d01f9e:	0023      	movs	r3, r4
c0d01fa0:	433b      	orrs	r3, r7
c0d01fa2:	d000      	beq.n	c0d01fa6 <__aeabi_dadd+0x396>
c0d01fa4:	e68a      	b.n	c0d01cbc <__aeabi_dadd+0xac>
c0d01fa6:	2000      	movs	r0, #0
c0d01fa8:	2500      	movs	r5, #0
c0d01faa:	e761      	b.n	c0d01e70 <__aeabi_dadd+0x260>
c0d01fac:	4cb4      	ldr	r4, [pc, #720]	; (c0d02280 <__aeabi_dadd+0x670>)
c0d01fae:	45a1      	cmp	r9, r4
c0d01fb0:	d100      	bne.n	c0d01fb4 <__aeabi_dadd+0x3a4>
c0d01fb2:	e0ad      	b.n	c0d02110 <__aeabi_dadd+0x500>
c0d01fb4:	2480      	movs	r4, #128	; 0x80
c0d01fb6:	0424      	lsls	r4, r4, #16
c0d01fb8:	4320      	orrs	r0, r4
c0d01fba:	4664      	mov	r4, ip
c0d01fbc:	2c38      	cmp	r4, #56	; 0x38
c0d01fbe:	dc3d      	bgt.n	c0d0203c <__aeabi_dadd+0x42c>
c0d01fc0:	4662      	mov	r2, ip
c0d01fc2:	2c1f      	cmp	r4, #31
c0d01fc4:	dd00      	ble.n	c0d01fc8 <__aeabi_dadd+0x3b8>
c0d01fc6:	e0b7      	b.n	c0d02138 <__aeabi_dadd+0x528>
c0d01fc8:	2520      	movs	r5, #32
c0d01fca:	001e      	movs	r6, r3
c0d01fcc:	1b2d      	subs	r5, r5, r4
c0d01fce:	0004      	movs	r4, r0
c0d01fd0:	40ab      	lsls	r3, r5
c0d01fd2:	40ac      	lsls	r4, r5
c0d01fd4:	40d6      	lsrs	r6, r2
c0d01fd6:	40d0      	lsrs	r0, r2
c0d01fd8:	4642      	mov	r2, r8
c0d01fda:	1e5d      	subs	r5, r3, #1
c0d01fdc:	41ab      	sbcs	r3, r5
c0d01fde:	4334      	orrs	r4, r6
c0d01fe0:	1a12      	subs	r2, r2, r0
c0d01fe2:	4690      	mov	r8, r2
c0d01fe4:	4323      	orrs	r3, r4
c0d01fe6:	e02c      	b.n	c0d02042 <__aeabi_dadd+0x432>
c0d01fe8:	0742      	lsls	r2, r0, #29
c0d01fea:	08db      	lsrs	r3, r3, #3
c0d01fec:	4313      	orrs	r3, r2
c0d01fee:	08c0      	lsrs	r0, r0, #3
c0d01ff0:	e73b      	b.n	c0d01e6a <__aeabi_dadd+0x25a>
c0d01ff2:	185c      	adds	r4, r3, r1
c0d01ff4:	429c      	cmp	r4, r3
c0d01ff6:	419b      	sbcs	r3, r3
c0d01ff8:	4440      	add	r0, r8
c0d01ffa:	425b      	negs	r3, r3
c0d01ffc:	18c7      	adds	r7, r0, r3
c0d01ffe:	2601      	movs	r6, #1
c0d02000:	023b      	lsls	r3, r7, #8
c0d02002:	d400      	bmi.n	c0d02006 <__aeabi_dadd+0x3f6>
c0d02004:	e729      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d02006:	2602      	movs	r6, #2
c0d02008:	4a9e      	ldr	r2, [pc, #632]	; (c0d02284 <__aeabi_dadd+0x674>)
c0d0200a:	0863      	lsrs	r3, r4, #1
c0d0200c:	4017      	ands	r7, r2
c0d0200e:	2201      	movs	r2, #1
c0d02010:	4014      	ands	r4, r2
c0d02012:	431c      	orrs	r4, r3
c0d02014:	07fb      	lsls	r3, r7, #31
c0d02016:	431c      	orrs	r4, r3
c0d02018:	087f      	lsrs	r7, r7, #1
c0d0201a:	e673      	b.n	c0d01d04 <__aeabi_dadd+0xf4>
c0d0201c:	4644      	mov	r4, r8
c0d0201e:	3a20      	subs	r2, #32
c0d02020:	40d4      	lsrs	r4, r2
c0d02022:	4662      	mov	r2, ip
c0d02024:	2a20      	cmp	r2, #32
c0d02026:	d005      	beq.n	c0d02034 <__aeabi_dadd+0x424>
c0d02028:	4667      	mov	r7, ip
c0d0202a:	2240      	movs	r2, #64	; 0x40
c0d0202c:	1bd2      	subs	r2, r2, r7
c0d0202e:	4647      	mov	r7, r8
c0d02030:	4097      	lsls	r7, r2
c0d02032:	4339      	orrs	r1, r7
c0d02034:	1e4a      	subs	r2, r1, #1
c0d02036:	4191      	sbcs	r1, r2
c0d02038:	4321      	orrs	r1, r4
c0d0203a:	e635      	b.n	c0d01ca8 <__aeabi_dadd+0x98>
c0d0203c:	4303      	orrs	r3, r0
c0d0203e:	1e58      	subs	r0, r3, #1
c0d02040:	4183      	sbcs	r3, r0
c0d02042:	1acc      	subs	r4, r1, r3
c0d02044:	42a1      	cmp	r1, r4
c0d02046:	41bf      	sbcs	r7, r7
c0d02048:	4643      	mov	r3, r8
c0d0204a:	427f      	negs	r7, r7
c0d0204c:	4655      	mov	r5, sl
c0d0204e:	464e      	mov	r6, r9
c0d02050:	1bdf      	subs	r7, r3, r7
c0d02052:	e62e      	b.n	c0d01cb2 <__aeabi_dadd+0xa2>
c0d02054:	0002      	movs	r2, r0
c0d02056:	431a      	orrs	r2, r3
c0d02058:	d100      	bne.n	c0d0205c <__aeabi_dadd+0x44c>
c0d0205a:	e0bd      	b.n	c0d021d8 <__aeabi_dadd+0x5c8>
c0d0205c:	4662      	mov	r2, ip
c0d0205e:	4664      	mov	r4, ip
c0d02060:	3a01      	subs	r2, #1
c0d02062:	2c01      	cmp	r4, #1
c0d02064:	d100      	bne.n	c0d02068 <__aeabi_dadd+0x458>
c0d02066:	e0e5      	b.n	c0d02234 <__aeabi_dadd+0x624>
c0d02068:	4c85      	ldr	r4, [pc, #532]	; (c0d02280 <__aeabi_dadd+0x670>)
c0d0206a:	45a4      	cmp	ip, r4
c0d0206c:	d058      	beq.n	c0d02120 <__aeabi_dadd+0x510>
c0d0206e:	4694      	mov	ip, r2
c0d02070:	e749      	b.n	c0d01f06 <__aeabi_dadd+0x2f6>
c0d02072:	4664      	mov	r4, ip
c0d02074:	2220      	movs	r2, #32
c0d02076:	1b12      	subs	r2, r2, r4
c0d02078:	4644      	mov	r4, r8
c0d0207a:	4094      	lsls	r4, r2
c0d0207c:	000f      	movs	r7, r1
c0d0207e:	46a1      	mov	r9, r4
c0d02080:	4664      	mov	r4, ip
c0d02082:	4091      	lsls	r1, r2
c0d02084:	40e7      	lsrs	r7, r4
c0d02086:	464c      	mov	r4, r9
c0d02088:	1e4a      	subs	r2, r1, #1
c0d0208a:	4191      	sbcs	r1, r2
c0d0208c:	433c      	orrs	r4, r7
c0d0208e:	4642      	mov	r2, r8
c0d02090:	430c      	orrs	r4, r1
c0d02092:	4661      	mov	r1, ip
c0d02094:	40ca      	lsrs	r2, r1
c0d02096:	1880      	adds	r0, r0, r2
c0d02098:	e6f4      	b.n	c0d01e84 <__aeabi_dadd+0x274>
c0d0209a:	4c79      	ldr	r4, [pc, #484]	; (c0d02280 <__aeabi_dadd+0x670>)
c0d0209c:	42a2      	cmp	r2, r4
c0d0209e:	d100      	bne.n	c0d020a2 <__aeabi_dadd+0x492>
c0d020a0:	e6fd      	b.n	c0d01e9e <__aeabi_dadd+0x28e>
c0d020a2:	1859      	adds	r1, r3, r1
c0d020a4:	4299      	cmp	r1, r3
c0d020a6:	419b      	sbcs	r3, r3
c0d020a8:	4440      	add	r0, r8
c0d020aa:	425f      	negs	r7, r3
c0d020ac:	19c7      	adds	r7, r0, r7
c0d020ae:	07fc      	lsls	r4, r7, #31
c0d020b0:	0849      	lsrs	r1, r1, #1
c0d020b2:	0016      	movs	r6, r2
c0d020b4:	430c      	orrs	r4, r1
c0d020b6:	087f      	lsrs	r7, r7, #1
c0d020b8:	e6cf      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d020ba:	1acc      	subs	r4, r1, r3
c0d020bc:	42a1      	cmp	r1, r4
c0d020be:	41bf      	sbcs	r7, r7
c0d020c0:	4643      	mov	r3, r8
c0d020c2:	427f      	negs	r7, r7
c0d020c4:	1a18      	subs	r0, r3, r0
c0d020c6:	4655      	mov	r5, sl
c0d020c8:	1bc7      	subs	r7, r0, r7
c0d020ca:	e5f7      	b.n	c0d01cbc <__aeabi_dadd+0xac>
c0d020cc:	08c9      	lsrs	r1, r1, #3
c0d020ce:	077b      	lsls	r3, r7, #29
c0d020d0:	4655      	mov	r5, sl
c0d020d2:	430b      	orrs	r3, r1
c0d020d4:	08f8      	lsrs	r0, r7, #3
c0d020d6:	e6c8      	b.n	c0d01e6a <__aeabi_dadd+0x25a>
c0d020d8:	2c00      	cmp	r4, #0
c0d020da:	d000      	beq.n	c0d020de <__aeabi_dadd+0x4ce>
c0d020dc:	e081      	b.n	c0d021e2 <__aeabi_dadd+0x5d2>
c0d020de:	4643      	mov	r3, r8
c0d020e0:	430b      	orrs	r3, r1
c0d020e2:	d115      	bne.n	c0d02110 <__aeabi_dadd+0x500>
c0d020e4:	2080      	movs	r0, #128	; 0x80
c0d020e6:	2500      	movs	r5, #0
c0d020e8:	0300      	lsls	r0, r0, #12
c0d020ea:	e6e3      	b.n	c0d01eb4 <__aeabi_dadd+0x2a4>
c0d020ec:	1a5c      	subs	r4, r3, r1
c0d020ee:	42a3      	cmp	r3, r4
c0d020f0:	419b      	sbcs	r3, r3
c0d020f2:	1bc7      	subs	r7, r0, r7
c0d020f4:	425b      	negs	r3, r3
c0d020f6:	2601      	movs	r6, #1
c0d020f8:	1aff      	subs	r7, r7, r3
c0d020fa:	e5da      	b.n	c0d01cb2 <__aeabi_dadd+0xa2>
c0d020fc:	0742      	lsls	r2, r0, #29
c0d020fe:	08db      	lsrs	r3, r3, #3
c0d02100:	4313      	orrs	r3, r2
c0d02102:	08c0      	lsrs	r0, r0, #3
c0d02104:	e6d2      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d02106:	0742      	lsls	r2, r0, #29
c0d02108:	08db      	lsrs	r3, r3, #3
c0d0210a:	4313      	orrs	r3, r2
c0d0210c:	08c0      	lsrs	r0, r0, #3
c0d0210e:	e6ac      	b.n	c0d01e6a <__aeabi_dadd+0x25a>
c0d02110:	4643      	mov	r3, r8
c0d02112:	4642      	mov	r2, r8
c0d02114:	08c9      	lsrs	r1, r1, #3
c0d02116:	075b      	lsls	r3, r3, #29
c0d02118:	4655      	mov	r5, sl
c0d0211a:	430b      	orrs	r3, r1
c0d0211c:	08d0      	lsrs	r0, r2, #3
c0d0211e:	e6c5      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d02120:	4643      	mov	r3, r8
c0d02122:	4642      	mov	r2, r8
c0d02124:	075b      	lsls	r3, r3, #29
c0d02126:	08c9      	lsrs	r1, r1, #3
c0d02128:	430b      	orrs	r3, r1
c0d0212a:	08d0      	lsrs	r0, r2, #3
c0d0212c:	e6be      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d0212e:	4303      	orrs	r3, r0
c0d02130:	001c      	movs	r4, r3
c0d02132:	1e63      	subs	r3, r4, #1
c0d02134:	419c      	sbcs	r4, r3
c0d02136:	e6fc      	b.n	c0d01f32 <__aeabi_dadd+0x322>
c0d02138:	0002      	movs	r2, r0
c0d0213a:	3c20      	subs	r4, #32
c0d0213c:	40e2      	lsrs	r2, r4
c0d0213e:	0014      	movs	r4, r2
c0d02140:	4662      	mov	r2, ip
c0d02142:	2a20      	cmp	r2, #32
c0d02144:	d003      	beq.n	c0d0214e <__aeabi_dadd+0x53e>
c0d02146:	2540      	movs	r5, #64	; 0x40
c0d02148:	1aad      	subs	r5, r5, r2
c0d0214a:	40a8      	lsls	r0, r5
c0d0214c:	4303      	orrs	r3, r0
c0d0214e:	1e58      	subs	r0, r3, #1
c0d02150:	4183      	sbcs	r3, r0
c0d02152:	4323      	orrs	r3, r4
c0d02154:	e775      	b.n	c0d02042 <__aeabi_dadd+0x432>
c0d02156:	2a00      	cmp	r2, #0
c0d02158:	d0e2      	beq.n	c0d02120 <__aeabi_dadd+0x510>
c0d0215a:	003a      	movs	r2, r7
c0d0215c:	430a      	orrs	r2, r1
c0d0215e:	d0cd      	beq.n	c0d020fc <__aeabi_dadd+0x4ec>
c0d02160:	0742      	lsls	r2, r0, #29
c0d02162:	08db      	lsrs	r3, r3, #3
c0d02164:	4313      	orrs	r3, r2
c0d02166:	2280      	movs	r2, #128	; 0x80
c0d02168:	08c0      	lsrs	r0, r0, #3
c0d0216a:	0312      	lsls	r2, r2, #12
c0d0216c:	4210      	tst	r0, r2
c0d0216e:	d006      	beq.n	c0d0217e <__aeabi_dadd+0x56e>
c0d02170:	08fc      	lsrs	r4, r7, #3
c0d02172:	4214      	tst	r4, r2
c0d02174:	d103      	bne.n	c0d0217e <__aeabi_dadd+0x56e>
c0d02176:	0020      	movs	r0, r4
c0d02178:	08cb      	lsrs	r3, r1, #3
c0d0217a:	077a      	lsls	r2, r7, #29
c0d0217c:	4313      	orrs	r3, r2
c0d0217e:	0f5a      	lsrs	r2, r3, #29
c0d02180:	00db      	lsls	r3, r3, #3
c0d02182:	0752      	lsls	r2, r2, #29
c0d02184:	08db      	lsrs	r3, r3, #3
c0d02186:	4313      	orrs	r3, r2
c0d02188:	e690      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d0218a:	4643      	mov	r3, r8
c0d0218c:	430b      	orrs	r3, r1
c0d0218e:	d100      	bne.n	c0d02192 <__aeabi_dadd+0x582>
c0d02190:	e709      	b.n	c0d01fa6 <__aeabi_dadd+0x396>
c0d02192:	4643      	mov	r3, r8
c0d02194:	4642      	mov	r2, r8
c0d02196:	08c9      	lsrs	r1, r1, #3
c0d02198:	075b      	lsls	r3, r3, #29
c0d0219a:	4655      	mov	r5, sl
c0d0219c:	430b      	orrs	r3, r1
c0d0219e:	08d0      	lsrs	r0, r2, #3
c0d021a0:	e666      	b.n	c0d01e70 <__aeabi_dadd+0x260>
c0d021a2:	1acc      	subs	r4, r1, r3
c0d021a4:	42a1      	cmp	r1, r4
c0d021a6:	4189      	sbcs	r1, r1
c0d021a8:	1a3f      	subs	r7, r7, r0
c0d021aa:	4249      	negs	r1, r1
c0d021ac:	4655      	mov	r5, sl
c0d021ae:	2601      	movs	r6, #1
c0d021b0:	1a7f      	subs	r7, r7, r1
c0d021b2:	e57e      	b.n	c0d01cb2 <__aeabi_dadd+0xa2>
c0d021b4:	4642      	mov	r2, r8
c0d021b6:	1a5c      	subs	r4, r3, r1
c0d021b8:	1a87      	subs	r7, r0, r2
c0d021ba:	42a3      	cmp	r3, r4
c0d021bc:	4192      	sbcs	r2, r2
c0d021be:	4252      	negs	r2, r2
c0d021c0:	1abf      	subs	r7, r7, r2
c0d021c2:	023a      	lsls	r2, r7, #8
c0d021c4:	d53d      	bpl.n	c0d02242 <__aeabi_dadd+0x632>
c0d021c6:	1acc      	subs	r4, r1, r3
c0d021c8:	42a1      	cmp	r1, r4
c0d021ca:	4189      	sbcs	r1, r1
c0d021cc:	4643      	mov	r3, r8
c0d021ce:	4249      	negs	r1, r1
c0d021d0:	1a1f      	subs	r7, r3, r0
c0d021d2:	4655      	mov	r5, sl
c0d021d4:	1a7f      	subs	r7, r7, r1
c0d021d6:	e595      	b.n	c0d01d04 <__aeabi_dadd+0xf4>
c0d021d8:	077b      	lsls	r3, r7, #29
c0d021da:	08c9      	lsrs	r1, r1, #3
c0d021dc:	430b      	orrs	r3, r1
c0d021de:	08f8      	lsrs	r0, r7, #3
c0d021e0:	e643      	b.n	c0d01e6a <__aeabi_dadd+0x25a>
c0d021e2:	4644      	mov	r4, r8
c0d021e4:	08db      	lsrs	r3, r3, #3
c0d021e6:	430c      	orrs	r4, r1
c0d021e8:	d130      	bne.n	c0d0224c <__aeabi_dadd+0x63c>
c0d021ea:	0742      	lsls	r2, r0, #29
c0d021ec:	4313      	orrs	r3, r2
c0d021ee:	08c0      	lsrs	r0, r0, #3
c0d021f0:	e65c      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d021f2:	077b      	lsls	r3, r7, #29
c0d021f4:	08c9      	lsrs	r1, r1, #3
c0d021f6:	430b      	orrs	r3, r1
c0d021f8:	08f8      	lsrs	r0, r7, #3
c0d021fa:	e639      	b.n	c0d01e70 <__aeabi_dadd+0x260>
c0d021fc:	185c      	adds	r4, r3, r1
c0d021fe:	429c      	cmp	r4, r3
c0d02200:	419b      	sbcs	r3, r3
c0d02202:	4440      	add	r0, r8
c0d02204:	425b      	negs	r3, r3
c0d02206:	18c7      	adds	r7, r0, r3
c0d02208:	023b      	lsls	r3, r7, #8
c0d0220a:	d400      	bmi.n	c0d0220e <__aeabi_dadd+0x5fe>
c0d0220c:	e625      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d0220e:	4b1d      	ldr	r3, [pc, #116]	; (c0d02284 <__aeabi_dadd+0x674>)
c0d02210:	2601      	movs	r6, #1
c0d02212:	401f      	ands	r7, r3
c0d02214:	e621      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d02216:	0004      	movs	r4, r0
c0d02218:	3a20      	subs	r2, #32
c0d0221a:	40d4      	lsrs	r4, r2
c0d0221c:	4662      	mov	r2, ip
c0d0221e:	2a20      	cmp	r2, #32
c0d02220:	d004      	beq.n	c0d0222c <__aeabi_dadd+0x61c>
c0d02222:	2240      	movs	r2, #64	; 0x40
c0d02224:	4666      	mov	r6, ip
c0d02226:	1b92      	subs	r2, r2, r6
c0d02228:	4090      	lsls	r0, r2
c0d0222a:	4303      	orrs	r3, r0
c0d0222c:	1e5a      	subs	r2, r3, #1
c0d0222e:	4193      	sbcs	r3, r2
c0d02230:	431c      	orrs	r4, r3
c0d02232:	e67e      	b.n	c0d01f32 <__aeabi_dadd+0x322>
c0d02234:	185c      	adds	r4, r3, r1
c0d02236:	428c      	cmp	r4, r1
c0d02238:	4189      	sbcs	r1, r1
c0d0223a:	4440      	add	r0, r8
c0d0223c:	4249      	negs	r1, r1
c0d0223e:	1847      	adds	r7, r0, r1
c0d02240:	e6dd      	b.n	c0d01ffe <__aeabi_dadd+0x3ee>
c0d02242:	0023      	movs	r3, r4
c0d02244:	433b      	orrs	r3, r7
c0d02246:	d100      	bne.n	c0d0224a <__aeabi_dadd+0x63a>
c0d02248:	e6ad      	b.n	c0d01fa6 <__aeabi_dadd+0x396>
c0d0224a:	e606      	b.n	c0d01e5a <__aeabi_dadd+0x24a>
c0d0224c:	0744      	lsls	r4, r0, #29
c0d0224e:	4323      	orrs	r3, r4
c0d02250:	2480      	movs	r4, #128	; 0x80
c0d02252:	08c0      	lsrs	r0, r0, #3
c0d02254:	0324      	lsls	r4, r4, #12
c0d02256:	4220      	tst	r0, r4
c0d02258:	d008      	beq.n	c0d0226c <__aeabi_dadd+0x65c>
c0d0225a:	4642      	mov	r2, r8
c0d0225c:	08d6      	lsrs	r6, r2, #3
c0d0225e:	4226      	tst	r6, r4
c0d02260:	d104      	bne.n	c0d0226c <__aeabi_dadd+0x65c>
c0d02262:	4655      	mov	r5, sl
c0d02264:	0030      	movs	r0, r6
c0d02266:	08cb      	lsrs	r3, r1, #3
c0d02268:	0751      	lsls	r1, r2, #29
c0d0226a:	430b      	orrs	r3, r1
c0d0226c:	0f5a      	lsrs	r2, r3, #29
c0d0226e:	00db      	lsls	r3, r3, #3
c0d02270:	08db      	lsrs	r3, r3, #3
c0d02272:	0752      	lsls	r2, r2, #29
c0d02274:	4313      	orrs	r3, r2
c0d02276:	e619      	b.n	c0d01eac <__aeabi_dadd+0x29c>
c0d02278:	2300      	movs	r3, #0
c0d0227a:	4a01      	ldr	r2, [pc, #4]	; (c0d02280 <__aeabi_dadd+0x670>)
c0d0227c:	001f      	movs	r7, r3
c0d0227e:	e55e      	b.n	c0d01d3e <__aeabi_dadd+0x12e>
c0d02280:	000007ff 	.word	0x000007ff
c0d02284:	ff7fffff 	.word	0xff7fffff

c0d02288 <__aeabi_ddiv>:
c0d02288:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0228a:	4657      	mov	r7, sl
c0d0228c:	464e      	mov	r6, r9
c0d0228e:	4645      	mov	r5, r8
c0d02290:	46de      	mov	lr, fp
c0d02292:	b5e0      	push	{r5, r6, r7, lr}
c0d02294:	4681      	mov	r9, r0
c0d02296:	0005      	movs	r5, r0
c0d02298:	030c      	lsls	r4, r1, #12
c0d0229a:	0048      	lsls	r0, r1, #1
c0d0229c:	4692      	mov	sl, r2
c0d0229e:	001f      	movs	r7, r3
c0d022a0:	b085      	sub	sp, #20
c0d022a2:	0b24      	lsrs	r4, r4, #12
c0d022a4:	0d40      	lsrs	r0, r0, #21
c0d022a6:	0fce      	lsrs	r6, r1, #31
c0d022a8:	2800      	cmp	r0, #0
c0d022aa:	d100      	bne.n	c0d022ae <__aeabi_ddiv+0x26>
c0d022ac:	e156      	b.n	c0d0255c <__aeabi_ddiv+0x2d4>
c0d022ae:	4bd4      	ldr	r3, [pc, #848]	; (c0d02600 <__aeabi_ddiv+0x378>)
c0d022b0:	4298      	cmp	r0, r3
c0d022b2:	d100      	bne.n	c0d022b6 <__aeabi_ddiv+0x2e>
c0d022b4:	e172      	b.n	c0d0259c <__aeabi_ddiv+0x314>
c0d022b6:	0f6b      	lsrs	r3, r5, #29
c0d022b8:	00e4      	lsls	r4, r4, #3
c0d022ba:	431c      	orrs	r4, r3
c0d022bc:	2380      	movs	r3, #128	; 0x80
c0d022be:	041b      	lsls	r3, r3, #16
c0d022c0:	4323      	orrs	r3, r4
c0d022c2:	4698      	mov	r8, r3
c0d022c4:	4bcf      	ldr	r3, [pc, #828]	; (c0d02604 <__aeabi_ddiv+0x37c>)
c0d022c6:	00ed      	lsls	r5, r5, #3
c0d022c8:	469b      	mov	fp, r3
c0d022ca:	2300      	movs	r3, #0
c0d022cc:	4699      	mov	r9, r3
c0d022ce:	4483      	add	fp, r0
c0d022d0:	9300      	str	r3, [sp, #0]
c0d022d2:	033c      	lsls	r4, r7, #12
c0d022d4:	007b      	lsls	r3, r7, #1
c0d022d6:	4650      	mov	r0, sl
c0d022d8:	0b24      	lsrs	r4, r4, #12
c0d022da:	0d5b      	lsrs	r3, r3, #21
c0d022dc:	0fff      	lsrs	r7, r7, #31
c0d022de:	2b00      	cmp	r3, #0
c0d022e0:	d100      	bne.n	c0d022e4 <__aeabi_ddiv+0x5c>
c0d022e2:	e11f      	b.n	c0d02524 <__aeabi_ddiv+0x29c>
c0d022e4:	4ac6      	ldr	r2, [pc, #792]	; (c0d02600 <__aeabi_ddiv+0x378>)
c0d022e6:	4293      	cmp	r3, r2
c0d022e8:	d100      	bne.n	c0d022ec <__aeabi_ddiv+0x64>
c0d022ea:	e162      	b.n	c0d025b2 <__aeabi_ddiv+0x32a>
c0d022ec:	49c5      	ldr	r1, [pc, #788]	; (c0d02604 <__aeabi_ddiv+0x37c>)
c0d022ee:	0f42      	lsrs	r2, r0, #29
c0d022f0:	468c      	mov	ip, r1
c0d022f2:	00e4      	lsls	r4, r4, #3
c0d022f4:	4659      	mov	r1, fp
c0d022f6:	4314      	orrs	r4, r2
c0d022f8:	2280      	movs	r2, #128	; 0x80
c0d022fa:	4463      	add	r3, ip
c0d022fc:	0412      	lsls	r2, r2, #16
c0d022fe:	1acb      	subs	r3, r1, r3
c0d02300:	4314      	orrs	r4, r2
c0d02302:	469b      	mov	fp, r3
c0d02304:	00c2      	lsls	r2, r0, #3
c0d02306:	2000      	movs	r0, #0
c0d02308:	0033      	movs	r3, r6
c0d0230a:	407b      	eors	r3, r7
c0d0230c:	469a      	mov	sl, r3
c0d0230e:	464b      	mov	r3, r9
c0d02310:	2b0f      	cmp	r3, #15
c0d02312:	d827      	bhi.n	c0d02364 <__aeabi_ddiv+0xdc>
c0d02314:	49bc      	ldr	r1, [pc, #752]	; (c0d02608 <__aeabi_ddiv+0x380>)
c0d02316:	009b      	lsls	r3, r3, #2
c0d02318:	58cb      	ldr	r3, [r1, r3]
c0d0231a:	469f      	mov	pc, r3
c0d0231c:	46b2      	mov	sl, r6
c0d0231e:	9b00      	ldr	r3, [sp, #0]
c0d02320:	2b02      	cmp	r3, #2
c0d02322:	d016      	beq.n	c0d02352 <__aeabi_ddiv+0xca>
c0d02324:	2b03      	cmp	r3, #3
c0d02326:	d100      	bne.n	c0d0232a <__aeabi_ddiv+0xa2>
c0d02328:	e28e      	b.n	c0d02848 <__aeabi_ddiv+0x5c0>
c0d0232a:	2b01      	cmp	r3, #1
c0d0232c:	d000      	beq.n	c0d02330 <__aeabi_ddiv+0xa8>
c0d0232e:	e0d9      	b.n	c0d024e4 <__aeabi_ddiv+0x25c>
c0d02330:	2300      	movs	r3, #0
c0d02332:	2400      	movs	r4, #0
c0d02334:	2500      	movs	r5, #0
c0d02336:	4652      	mov	r2, sl
c0d02338:	051b      	lsls	r3, r3, #20
c0d0233a:	4323      	orrs	r3, r4
c0d0233c:	07d2      	lsls	r2, r2, #31
c0d0233e:	4313      	orrs	r3, r2
c0d02340:	0028      	movs	r0, r5
c0d02342:	0019      	movs	r1, r3
c0d02344:	b005      	add	sp, #20
c0d02346:	bcf0      	pop	{r4, r5, r6, r7}
c0d02348:	46bb      	mov	fp, r7
c0d0234a:	46b2      	mov	sl, r6
c0d0234c:	46a9      	mov	r9, r5
c0d0234e:	46a0      	mov	r8, r4
c0d02350:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02352:	2400      	movs	r4, #0
c0d02354:	2500      	movs	r5, #0
c0d02356:	4baa      	ldr	r3, [pc, #680]	; (c0d02600 <__aeabi_ddiv+0x378>)
c0d02358:	e7ed      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d0235a:	46ba      	mov	sl, r7
c0d0235c:	46a0      	mov	r8, r4
c0d0235e:	0015      	movs	r5, r2
c0d02360:	9000      	str	r0, [sp, #0]
c0d02362:	e7dc      	b.n	c0d0231e <__aeabi_ddiv+0x96>
c0d02364:	4544      	cmp	r4, r8
c0d02366:	d200      	bcs.n	c0d0236a <__aeabi_ddiv+0xe2>
c0d02368:	e1c7      	b.n	c0d026fa <__aeabi_ddiv+0x472>
c0d0236a:	d100      	bne.n	c0d0236e <__aeabi_ddiv+0xe6>
c0d0236c:	e1c2      	b.n	c0d026f4 <__aeabi_ddiv+0x46c>
c0d0236e:	2301      	movs	r3, #1
c0d02370:	425b      	negs	r3, r3
c0d02372:	469c      	mov	ip, r3
c0d02374:	002e      	movs	r6, r5
c0d02376:	4640      	mov	r0, r8
c0d02378:	2500      	movs	r5, #0
c0d0237a:	44e3      	add	fp, ip
c0d0237c:	0223      	lsls	r3, r4, #8
c0d0237e:	0e14      	lsrs	r4, r2, #24
c0d02380:	431c      	orrs	r4, r3
c0d02382:	0c1b      	lsrs	r3, r3, #16
c0d02384:	4699      	mov	r9, r3
c0d02386:	0423      	lsls	r3, r4, #16
c0d02388:	0c1f      	lsrs	r7, r3, #16
c0d0238a:	0212      	lsls	r2, r2, #8
c0d0238c:	4649      	mov	r1, r9
c0d0238e:	9200      	str	r2, [sp, #0]
c0d02390:	9701      	str	r7, [sp, #4]
c0d02392:	f7ff f9d7 	bl	c0d01744 <__aeabi_uidivmod>
c0d02396:	0002      	movs	r2, r0
c0d02398:	437a      	muls	r2, r7
c0d0239a:	040b      	lsls	r3, r1, #16
c0d0239c:	0c31      	lsrs	r1, r6, #16
c0d0239e:	4680      	mov	r8, r0
c0d023a0:	4319      	orrs	r1, r3
c0d023a2:	428a      	cmp	r2, r1
c0d023a4:	d907      	bls.n	c0d023b6 <__aeabi_ddiv+0x12e>
c0d023a6:	2301      	movs	r3, #1
c0d023a8:	425b      	negs	r3, r3
c0d023aa:	469c      	mov	ip, r3
c0d023ac:	1909      	adds	r1, r1, r4
c0d023ae:	44e0      	add	r8, ip
c0d023b0:	428c      	cmp	r4, r1
c0d023b2:	d800      	bhi.n	c0d023b6 <__aeabi_ddiv+0x12e>
c0d023b4:	e207      	b.n	c0d027c6 <__aeabi_ddiv+0x53e>
c0d023b6:	1a88      	subs	r0, r1, r2
c0d023b8:	4649      	mov	r1, r9
c0d023ba:	f7ff f9c3 	bl	c0d01744 <__aeabi_uidivmod>
c0d023be:	0409      	lsls	r1, r1, #16
c0d023c0:	468c      	mov	ip, r1
c0d023c2:	0431      	lsls	r1, r6, #16
c0d023c4:	4666      	mov	r6, ip
c0d023c6:	9a01      	ldr	r2, [sp, #4]
c0d023c8:	0c09      	lsrs	r1, r1, #16
c0d023ca:	4342      	muls	r2, r0
c0d023cc:	0003      	movs	r3, r0
c0d023ce:	4331      	orrs	r1, r6
c0d023d0:	428a      	cmp	r2, r1
c0d023d2:	d904      	bls.n	c0d023de <__aeabi_ddiv+0x156>
c0d023d4:	1909      	adds	r1, r1, r4
c0d023d6:	3b01      	subs	r3, #1
c0d023d8:	428c      	cmp	r4, r1
c0d023da:	d800      	bhi.n	c0d023de <__aeabi_ddiv+0x156>
c0d023dc:	e1ed      	b.n	c0d027ba <__aeabi_ddiv+0x532>
c0d023de:	1a88      	subs	r0, r1, r2
c0d023e0:	4642      	mov	r2, r8
c0d023e2:	0412      	lsls	r2, r2, #16
c0d023e4:	431a      	orrs	r2, r3
c0d023e6:	4690      	mov	r8, r2
c0d023e8:	4641      	mov	r1, r8
c0d023ea:	9b00      	ldr	r3, [sp, #0]
c0d023ec:	040e      	lsls	r6, r1, #16
c0d023ee:	0c1b      	lsrs	r3, r3, #16
c0d023f0:	001f      	movs	r7, r3
c0d023f2:	9302      	str	r3, [sp, #8]
c0d023f4:	9b00      	ldr	r3, [sp, #0]
c0d023f6:	0c36      	lsrs	r6, r6, #16
c0d023f8:	041b      	lsls	r3, r3, #16
c0d023fa:	0c19      	lsrs	r1, r3, #16
c0d023fc:	000b      	movs	r3, r1
c0d023fe:	4373      	muls	r3, r6
c0d02400:	0c12      	lsrs	r2, r2, #16
c0d02402:	437e      	muls	r6, r7
c0d02404:	9103      	str	r1, [sp, #12]
c0d02406:	4351      	muls	r1, r2
c0d02408:	437a      	muls	r2, r7
c0d0240a:	0c1f      	lsrs	r7, r3, #16
c0d0240c:	46bc      	mov	ip, r7
c0d0240e:	1876      	adds	r6, r6, r1
c0d02410:	4466      	add	r6, ip
c0d02412:	42b1      	cmp	r1, r6
c0d02414:	d903      	bls.n	c0d0241e <__aeabi_ddiv+0x196>
c0d02416:	2180      	movs	r1, #128	; 0x80
c0d02418:	0249      	lsls	r1, r1, #9
c0d0241a:	468c      	mov	ip, r1
c0d0241c:	4462      	add	r2, ip
c0d0241e:	0c31      	lsrs	r1, r6, #16
c0d02420:	188a      	adds	r2, r1, r2
c0d02422:	0431      	lsls	r1, r6, #16
c0d02424:	041e      	lsls	r6, r3, #16
c0d02426:	0c36      	lsrs	r6, r6, #16
c0d02428:	198e      	adds	r6, r1, r6
c0d0242a:	4290      	cmp	r0, r2
c0d0242c:	d302      	bcc.n	c0d02434 <__aeabi_ddiv+0x1ac>
c0d0242e:	d112      	bne.n	c0d02456 <__aeabi_ddiv+0x1ce>
c0d02430:	42b5      	cmp	r5, r6
c0d02432:	d210      	bcs.n	c0d02456 <__aeabi_ddiv+0x1ce>
c0d02434:	4643      	mov	r3, r8
c0d02436:	1e59      	subs	r1, r3, #1
c0d02438:	9b00      	ldr	r3, [sp, #0]
c0d0243a:	469c      	mov	ip, r3
c0d0243c:	4465      	add	r5, ip
c0d0243e:	001f      	movs	r7, r3
c0d02440:	429d      	cmp	r5, r3
c0d02442:	419b      	sbcs	r3, r3
c0d02444:	425b      	negs	r3, r3
c0d02446:	191b      	adds	r3, r3, r4
c0d02448:	18c0      	adds	r0, r0, r3
c0d0244a:	4284      	cmp	r4, r0
c0d0244c:	d200      	bcs.n	c0d02450 <__aeabi_ddiv+0x1c8>
c0d0244e:	e1a0      	b.n	c0d02792 <__aeabi_ddiv+0x50a>
c0d02450:	d100      	bne.n	c0d02454 <__aeabi_ddiv+0x1cc>
c0d02452:	e19b      	b.n	c0d0278c <__aeabi_ddiv+0x504>
c0d02454:	4688      	mov	r8, r1
c0d02456:	1bae      	subs	r6, r5, r6
c0d02458:	42b5      	cmp	r5, r6
c0d0245a:	41ad      	sbcs	r5, r5
c0d0245c:	1a80      	subs	r0, r0, r2
c0d0245e:	426d      	negs	r5, r5
c0d02460:	1b40      	subs	r0, r0, r5
c0d02462:	4284      	cmp	r4, r0
c0d02464:	d100      	bne.n	c0d02468 <__aeabi_ddiv+0x1e0>
c0d02466:	e1d5      	b.n	c0d02814 <__aeabi_ddiv+0x58c>
c0d02468:	4649      	mov	r1, r9
c0d0246a:	f7ff f96b 	bl	c0d01744 <__aeabi_uidivmod>
c0d0246e:	9a01      	ldr	r2, [sp, #4]
c0d02470:	040b      	lsls	r3, r1, #16
c0d02472:	4342      	muls	r2, r0
c0d02474:	0c31      	lsrs	r1, r6, #16
c0d02476:	0005      	movs	r5, r0
c0d02478:	4319      	orrs	r1, r3
c0d0247a:	428a      	cmp	r2, r1
c0d0247c:	d900      	bls.n	c0d02480 <__aeabi_ddiv+0x1f8>
c0d0247e:	e16c      	b.n	c0d0275a <__aeabi_ddiv+0x4d2>
c0d02480:	1a88      	subs	r0, r1, r2
c0d02482:	4649      	mov	r1, r9
c0d02484:	f7ff f95e 	bl	c0d01744 <__aeabi_uidivmod>
c0d02488:	9a01      	ldr	r2, [sp, #4]
c0d0248a:	0436      	lsls	r6, r6, #16
c0d0248c:	4342      	muls	r2, r0
c0d0248e:	0409      	lsls	r1, r1, #16
c0d02490:	0c36      	lsrs	r6, r6, #16
c0d02492:	0003      	movs	r3, r0
c0d02494:	430e      	orrs	r6, r1
c0d02496:	42b2      	cmp	r2, r6
c0d02498:	d900      	bls.n	c0d0249c <__aeabi_ddiv+0x214>
c0d0249a:	e153      	b.n	c0d02744 <__aeabi_ddiv+0x4bc>
c0d0249c:	9803      	ldr	r0, [sp, #12]
c0d0249e:	1ab6      	subs	r6, r6, r2
c0d024a0:	0002      	movs	r2, r0
c0d024a2:	042d      	lsls	r5, r5, #16
c0d024a4:	431d      	orrs	r5, r3
c0d024a6:	9f02      	ldr	r7, [sp, #8]
c0d024a8:	042b      	lsls	r3, r5, #16
c0d024aa:	0c1b      	lsrs	r3, r3, #16
c0d024ac:	435a      	muls	r2, r3
c0d024ae:	437b      	muls	r3, r7
c0d024b0:	469c      	mov	ip, r3
c0d024b2:	0c29      	lsrs	r1, r5, #16
c0d024b4:	4348      	muls	r0, r1
c0d024b6:	0c13      	lsrs	r3, r2, #16
c0d024b8:	4484      	add	ip, r0
c0d024ba:	4463      	add	r3, ip
c0d024bc:	4379      	muls	r1, r7
c0d024be:	4298      	cmp	r0, r3
c0d024c0:	d903      	bls.n	c0d024ca <__aeabi_ddiv+0x242>
c0d024c2:	2080      	movs	r0, #128	; 0x80
c0d024c4:	0240      	lsls	r0, r0, #9
c0d024c6:	4684      	mov	ip, r0
c0d024c8:	4461      	add	r1, ip
c0d024ca:	0c18      	lsrs	r0, r3, #16
c0d024cc:	0412      	lsls	r2, r2, #16
c0d024ce:	041b      	lsls	r3, r3, #16
c0d024d0:	0c12      	lsrs	r2, r2, #16
c0d024d2:	1841      	adds	r1, r0, r1
c0d024d4:	189b      	adds	r3, r3, r2
c0d024d6:	428e      	cmp	r6, r1
c0d024d8:	d200      	bcs.n	c0d024dc <__aeabi_ddiv+0x254>
c0d024da:	e0ff      	b.n	c0d026dc <__aeabi_ddiv+0x454>
c0d024dc:	d100      	bne.n	c0d024e0 <__aeabi_ddiv+0x258>
c0d024de:	e0fa      	b.n	c0d026d6 <__aeabi_ddiv+0x44e>
c0d024e0:	2301      	movs	r3, #1
c0d024e2:	431d      	orrs	r5, r3
c0d024e4:	4a49      	ldr	r2, [pc, #292]	; (c0d0260c <__aeabi_ddiv+0x384>)
c0d024e6:	445a      	add	r2, fp
c0d024e8:	2a00      	cmp	r2, #0
c0d024ea:	dc00      	bgt.n	c0d024ee <__aeabi_ddiv+0x266>
c0d024ec:	e0aa      	b.n	c0d02644 <__aeabi_ddiv+0x3bc>
c0d024ee:	076b      	lsls	r3, r5, #29
c0d024f0:	d000      	beq.n	c0d024f4 <__aeabi_ddiv+0x26c>
c0d024f2:	e13d      	b.n	c0d02770 <__aeabi_ddiv+0x4e8>
c0d024f4:	08ed      	lsrs	r5, r5, #3
c0d024f6:	4643      	mov	r3, r8
c0d024f8:	01db      	lsls	r3, r3, #7
c0d024fa:	d506      	bpl.n	c0d0250a <__aeabi_ddiv+0x282>
c0d024fc:	4642      	mov	r2, r8
c0d024fe:	4b44      	ldr	r3, [pc, #272]	; (c0d02610 <__aeabi_ddiv+0x388>)
c0d02500:	401a      	ands	r2, r3
c0d02502:	4690      	mov	r8, r2
c0d02504:	2280      	movs	r2, #128	; 0x80
c0d02506:	00d2      	lsls	r2, r2, #3
c0d02508:	445a      	add	r2, fp
c0d0250a:	4b42      	ldr	r3, [pc, #264]	; (c0d02614 <__aeabi_ddiv+0x38c>)
c0d0250c:	429a      	cmp	r2, r3
c0d0250e:	dd00      	ble.n	c0d02512 <__aeabi_ddiv+0x28a>
c0d02510:	e71f      	b.n	c0d02352 <__aeabi_ddiv+0xca>
c0d02512:	4643      	mov	r3, r8
c0d02514:	075b      	lsls	r3, r3, #29
c0d02516:	431d      	orrs	r5, r3
c0d02518:	4643      	mov	r3, r8
c0d0251a:	0552      	lsls	r2, r2, #21
c0d0251c:	025c      	lsls	r4, r3, #9
c0d0251e:	0b24      	lsrs	r4, r4, #12
c0d02520:	0d53      	lsrs	r3, r2, #21
c0d02522:	e708      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d02524:	4652      	mov	r2, sl
c0d02526:	4322      	orrs	r2, r4
c0d02528:	d100      	bne.n	c0d0252c <__aeabi_ddiv+0x2a4>
c0d0252a:	e07b      	b.n	c0d02624 <__aeabi_ddiv+0x39c>
c0d0252c:	2c00      	cmp	r4, #0
c0d0252e:	d100      	bne.n	c0d02532 <__aeabi_ddiv+0x2aa>
c0d02530:	e0fa      	b.n	c0d02728 <__aeabi_ddiv+0x4a0>
c0d02532:	0020      	movs	r0, r4
c0d02534:	f001 f954 	bl	c0d037e0 <__clzsi2>
c0d02538:	0002      	movs	r2, r0
c0d0253a:	3a0b      	subs	r2, #11
c0d0253c:	231d      	movs	r3, #29
c0d0253e:	0001      	movs	r1, r0
c0d02540:	1a9b      	subs	r3, r3, r2
c0d02542:	4652      	mov	r2, sl
c0d02544:	3908      	subs	r1, #8
c0d02546:	40da      	lsrs	r2, r3
c0d02548:	408c      	lsls	r4, r1
c0d0254a:	4314      	orrs	r4, r2
c0d0254c:	4652      	mov	r2, sl
c0d0254e:	408a      	lsls	r2, r1
c0d02550:	4b31      	ldr	r3, [pc, #196]	; (c0d02618 <__aeabi_ddiv+0x390>)
c0d02552:	4458      	add	r0, fp
c0d02554:	469b      	mov	fp, r3
c0d02556:	4483      	add	fp, r0
c0d02558:	2000      	movs	r0, #0
c0d0255a:	e6d5      	b.n	c0d02308 <__aeabi_ddiv+0x80>
c0d0255c:	464b      	mov	r3, r9
c0d0255e:	4323      	orrs	r3, r4
c0d02560:	4698      	mov	r8, r3
c0d02562:	d044      	beq.n	c0d025ee <__aeabi_ddiv+0x366>
c0d02564:	2c00      	cmp	r4, #0
c0d02566:	d100      	bne.n	c0d0256a <__aeabi_ddiv+0x2e2>
c0d02568:	e0ce      	b.n	c0d02708 <__aeabi_ddiv+0x480>
c0d0256a:	0020      	movs	r0, r4
c0d0256c:	f001 f938 	bl	c0d037e0 <__clzsi2>
c0d02570:	0001      	movs	r1, r0
c0d02572:	0002      	movs	r2, r0
c0d02574:	390b      	subs	r1, #11
c0d02576:	231d      	movs	r3, #29
c0d02578:	1a5b      	subs	r3, r3, r1
c0d0257a:	4649      	mov	r1, r9
c0d0257c:	0010      	movs	r0, r2
c0d0257e:	40d9      	lsrs	r1, r3
c0d02580:	3808      	subs	r0, #8
c0d02582:	4084      	lsls	r4, r0
c0d02584:	000b      	movs	r3, r1
c0d02586:	464d      	mov	r5, r9
c0d02588:	4323      	orrs	r3, r4
c0d0258a:	4698      	mov	r8, r3
c0d0258c:	4085      	lsls	r5, r0
c0d0258e:	4823      	ldr	r0, [pc, #140]	; (c0d0261c <__aeabi_ddiv+0x394>)
c0d02590:	1a83      	subs	r3, r0, r2
c0d02592:	469b      	mov	fp, r3
c0d02594:	2300      	movs	r3, #0
c0d02596:	4699      	mov	r9, r3
c0d02598:	9300      	str	r3, [sp, #0]
c0d0259a:	e69a      	b.n	c0d022d2 <__aeabi_ddiv+0x4a>
c0d0259c:	464b      	mov	r3, r9
c0d0259e:	4323      	orrs	r3, r4
c0d025a0:	4698      	mov	r8, r3
c0d025a2:	d11d      	bne.n	c0d025e0 <__aeabi_ddiv+0x358>
c0d025a4:	2308      	movs	r3, #8
c0d025a6:	4699      	mov	r9, r3
c0d025a8:	3b06      	subs	r3, #6
c0d025aa:	2500      	movs	r5, #0
c0d025ac:	4683      	mov	fp, r0
c0d025ae:	9300      	str	r3, [sp, #0]
c0d025b0:	e68f      	b.n	c0d022d2 <__aeabi_ddiv+0x4a>
c0d025b2:	4652      	mov	r2, sl
c0d025b4:	4322      	orrs	r2, r4
c0d025b6:	d109      	bne.n	c0d025cc <__aeabi_ddiv+0x344>
c0d025b8:	2302      	movs	r3, #2
c0d025ba:	4649      	mov	r1, r9
c0d025bc:	4319      	orrs	r1, r3
c0d025be:	4b18      	ldr	r3, [pc, #96]	; (c0d02620 <__aeabi_ddiv+0x398>)
c0d025c0:	4689      	mov	r9, r1
c0d025c2:	469c      	mov	ip, r3
c0d025c4:	2400      	movs	r4, #0
c0d025c6:	2002      	movs	r0, #2
c0d025c8:	44e3      	add	fp, ip
c0d025ca:	e69d      	b.n	c0d02308 <__aeabi_ddiv+0x80>
c0d025cc:	2303      	movs	r3, #3
c0d025ce:	464a      	mov	r2, r9
c0d025d0:	431a      	orrs	r2, r3
c0d025d2:	4b13      	ldr	r3, [pc, #76]	; (c0d02620 <__aeabi_ddiv+0x398>)
c0d025d4:	4691      	mov	r9, r2
c0d025d6:	469c      	mov	ip, r3
c0d025d8:	4652      	mov	r2, sl
c0d025da:	2003      	movs	r0, #3
c0d025dc:	44e3      	add	fp, ip
c0d025de:	e693      	b.n	c0d02308 <__aeabi_ddiv+0x80>
c0d025e0:	230c      	movs	r3, #12
c0d025e2:	4699      	mov	r9, r3
c0d025e4:	3b09      	subs	r3, #9
c0d025e6:	46a0      	mov	r8, r4
c0d025e8:	4683      	mov	fp, r0
c0d025ea:	9300      	str	r3, [sp, #0]
c0d025ec:	e671      	b.n	c0d022d2 <__aeabi_ddiv+0x4a>
c0d025ee:	2304      	movs	r3, #4
c0d025f0:	4699      	mov	r9, r3
c0d025f2:	2300      	movs	r3, #0
c0d025f4:	469b      	mov	fp, r3
c0d025f6:	3301      	adds	r3, #1
c0d025f8:	2500      	movs	r5, #0
c0d025fa:	9300      	str	r3, [sp, #0]
c0d025fc:	e669      	b.n	c0d022d2 <__aeabi_ddiv+0x4a>
c0d025fe:	46c0      	nop			; (mov r8, r8)
c0d02600:	000007ff 	.word	0x000007ff
c0d02604:	fffffc01 	.word	0xfffffc01
c0d02608:	c0d038b8 	.word	0xc0d038b8
c0d0260c:	000003ff 	.word	0x000003ff
c0d02610:	feffffff 	.word	0xfeffffff
c0d02614:	000007fe 	.word	0x000007fe
c0d02618:	000003f3 	.word	0x000003f3
c0d0261c:	fffffc0d 	.word	0xfffffc0d
c0d02620:	fffff801 	.word	0xfffff801
c0d02624:	4649      	mov	r1, r9
c0d02626:	2301      	movs	r3, #1
c0d02628:	4319      	orrs	r1, r3
c0d0262a:	4689      	mov	r9, r1
c0d0262c:	2400      	movs	r4, #0
c0d0262e:	2001      	movs	r0, #1
c0d02630:	e66a      	b.n	c0d02308 <__aeabi_ddiv+0x80>
c0d02632:	2300      	movs	r3, #0
c0d02634:	2480      	movs	r4, #128	; 0x80
c0d02636:	469a      	mov	sl, r3
c0d02638:	2500      	movs	r5, #0
c0d0263a:	4b8a      	ldr	r3, [pc, #552]	; (c0d02864 <__aeabi_ddiv+0x5dc>)
c0d0263c:	0324      	lsls	r4, r4, #12
c0d0263e:	e67a      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d02640:	2501      	movs	r5, #1
c0d02642:	426d      	negs	r5, r5
c0d02644:	2301      	movs	r3, #1
c0d02646:	1a9b      	subs	r3, r3, r2
c0d02648:	2b38      	cmp	r3, #56	; 0x38
c0d0264a:	dd00      	ble.n	c0d0264e <__aeabi_ddiv+0x3c6>
c0d0264c:	e670      	b.n	c0d02330 <__aeabi_ddiv+0xa8>
c0d0264e:	2b1f      	cmp	r3, #31
c0d02650:	dc00      	bgt.n	c0d02654 <__aeabi_ddiv+0x3cc>
c0d02652:	e0bf      	b.n	c0d027d4 <__aeabi_ddiv+0x54c>
c0d02654:	211f      	movs	r1, #31
c0d02656:	4249      	negs	r1, r1
c0d02658:	1a8a      	subs	r2, r1, r2
c0d0265a:	4641      	mov	r1, r8
c0d0265c:	40d1      	lsrs	r1, r2
c0d0265e:	000a      	movs	r2, r1
c0d02660:	2b20      	cmp	r3, #32
c0d02662:	d004      	beq.n	c0d0266e <__aeabi_ddiv+0x3e6>
c0d02664:	4641      	mov	r1, r8
c0d02666:	4b80      	ldr	r3, [pc, #512]	; (c0d02868 <__aeabi_ddiv+0x5e0>)
c0d02668:	445b      	add	r3, fp
c0d0266a:	4099      	lsls	r1, r3
c0d0266c:	430d      	orrs	r5, r1
c0d0266e:	1e6b      	subs	r3, r5, #1
c0d02670:	419d      	sbcs	r5, r3
c0d02672:	2307      	movs	r3, #7
c0d02674:	432a      	orrs	r2, r5
c0d02676:	001d      	movs	r5, r3
c0d02678:	2400      	movs	r4, #0
c0d0267a:	4015      	ands	r5, r2
c0d0267c:	4213      	tst	r3, r2
c0d0267e:	d100      	bne.n	c0d02682 <__aeabi_ddiv+0x3fa>
c0d02680:	e0d4      	b.n	c0d0282c <__aeabi_ddiv+0x5a4>
c0d02682:	210f      	movs	r1, #15
c0d02684:	2300      	movs	r3, #0
c0d02686:	4011      	ands	r1, r2
c0d02688:	2904      	cmp	r1, #4
c0d0268a:	d100      	bne.n	c0d0268e <__aeabi_ddiv+0x406>
c0d0268c:	e0cb      	b.n	c0d02826 <__aeabi_ddiv+0x59e>
c0d0268e:	1d11      	adds	r1, r2, #4
c0d02690:	4291      	cmp	r1, r2
c0d02692:	4192      	sbcs	r2, r2
c0d02694:	4252      	negs	r2, r2
c0d02696:	189b      	adds	r3, r3, r2
c0d02698:	000a      	movs	r2, r1
c0d0269a:	0219      	lsls	r1, r3, #8
c0d0269c:	d400      	bmi.n	c0d026a0 <__aeabi_ddiv+0x418>
c0d0269e:	e0c2      	b.n	c0d02826 <__aeabi_ddiv+0x59e>
c0d026a0:	2301      	movs	r3, #1
c0d026a2:	2400      	movs	r4, #0
c0d026a4:	2500      	movs	r5, #0
c0d026a6:	e646      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d026a8:	2380      	movs	r3, #128	; 0x80
c0d026aa:	4641      	mov	r1, r8
c0d026ac:	031b      	lsls	r3, r3, #12
c0d026ae:	4219      	tst	r1, r3
c0d026b0:	d008      	beq.n	c0d026c4 <__aeabi_ddiv+0x43c>
c0d026b2:	421c      	tst	r4, r3
c0d026b4:	d106      	bne.n	c0d026c4 <__aeabi_ddiv+0x43c>
c0d026b6:	431c      	orrs	r4, r3
c0d026b8:	0324      	lsls	r4, r4, #12
c0d026ba:	46ba      	mov	sl, r7
c0d026bc:	0015      	movs	r5, r2
c0d026be:	4b69      	ldr	r3, [pc, #420]	; (c0d02864 <__aeabi_ddiv+0x5dc>)
c0d026c0:	0b24      	lsrs	r4, r4, #12
c0d026c2:	e638      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d026c4:	2480      	movs	r4, #128	; 0x80
c0d026c6:	4643      	mov	r3, r8
c0d026c8:	0324      	lsls	r4, r4, #12
c0d026ca:	431c      	orrs	r4, r3
c0d026cc:	0324      	lsls	r4, r4, #12
c0d026ce:	46b2      	mov	sl, r6
c0d026d0:	4b64      	ldr	r3, [pc, #400]	; (c0d02864 <__aeabi_ddiv+0x5dc>)
c0d026d2:	0b24      	lsrs	r4, r4, #12
c0d026d4:	e62f      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d026d6:	2b00      	cmp	r3, #0
c0d026d8:	d100      	bne.n	c0d026dc <__aeabi_ddiv+0x454>
c0d026da:	e703      	b.n	c0d024e4 <__aeabi_ddiv+0x25c>
c0d026dc:	19a6      	adds	r6, r4, r6
c0d026de:	1e68      	subs	r0, r5, #1
c0d026e0:	42a6      	cmp	r6, r4
c0d026e2:	d200      	bcs.n	c0d026e6 <__aeabi_ddiv+0x45e>
c0d026e4:	e08d      	b.n	c0d02802 <__aeabi_ddiv+0x57a>
c0d026e6:	428e      	cmp	r6, r1
c0d026e8:	d200      	bcs.n	c0d026ec <__aeabi_ddiv+0x464>
c0d026ea:	e0a3      	b.n	c0d02834 <__aeabi_ddiv+0x5ac>
c0d026ec:	d100      	bne.n	c0d026f0 <__aeabi_ddiv+0x468>
c0d026ee:	e0b3      	b.n	c0d02858 <__aeabi_ddiv+0x5d0>
c0d026f0:	0005      	movs	r5, r0
c0d026f2:	e6f5      	b.n	c0d024e0 <__aeabi_ddiv+0x258>
c0d026f4:	42aa      	cmp	r2, r5
c0d026f6:	d900      	bls.n	c0d026fa <__aeabi_ddiv+0x472>
c0d026f8:	e639      	b.n	c0d0236e <__aeabi_ddiv+0xe6>
c0d026fa:	4643      	mov	r3, r8
c0d026fc:	07de      	lsls	r6, r3, #31
c0d026fe:	0858      	lsrs	r0, r3, #1
c0d02700:	086b      	lsrs	r3, r5, #1
c0d02702:	431e      	orrs	r6, r3
c0d02704:	07ed      	lsls	r5, r5, #31
c0d02706:	e639      	b.n	c0d0237c <__aeabi_ddiv+0xf4>
c0d02708:	4648      	mov	r0, r9
c0d0270a:	f001 f869 	bl	c0d037e0 <__clzsi2>
c0d0270e:	0001      	movs	r1, r0
c0d02710:	0002      	movs	r2, r0
c0d02712:	3115      	adds	r1, #21
c0d02714:	3220      	adds	r2, #32
c0d02716:	291c      	cmp	r1, #28
c0d02718:	dc00      	bgt.n	c0d0271c <__aeabi_ddiv+0x494>
c0d0271a:	e72c      	b.n	c0d02576 <__aeabi_ddiv+0x2ee>
c0d0271c:	464b      	mov	r3, r9
c0d0271e:	3808      	subs	r0, #8
c0d02720:	4083      	lsls	r3, r0
c0d02722:	2500      	movs	r5, #0
c0d02724:	4698      	mov	r8, r3
c0d02726:	e732      	b.n	c0d0258e <__aeabi_ddiv+0x306>
c0d02728:	f001 f85a 	bl	c0d037e0 <__clzsi2>
c0d0272c:	0003      	movs	r3, r0
c0d0272e:	001a      	movs	r2, r3
c0d02730:	3215      	adds	r2, #21
c0d02732:	3020      	adds	r0, #32
c0d02734:	2a1c      	cmp	r2, #28
c0d02736:	dc00      	bgt.n	c0d0273a <__aeabi_ddiv+0x4b2>
c0d02738:	e700      	b.n	c0d0253c <__aeabi_ddiv+0x2b4>
c0d0273a:	4654      	mov	r4, sl
c0d0273c:	3b08      	subs	r3, #8
c0d0273e:	2200      	movs	r2, #0
c0d02740:	409c      	lsls	r4, r3
c0d02742:	e705      	b.n	c0d02550 <__aeabi_ddiv+0x2c8>
c0d02744:	1936      	adds	r6, r6, r4
c0d02746:	3b01      	subs	r3, #1
c0d02748:	42b4      	cmp	r4, r6
c0d0274a:	d900      	bls.n	c0d0274e <__aeabi_ddiv+0x4c6>
c0d0274c:	e6a6      	b.n	c0d0249c <__aeabi_ddiv+0x214>
c0d0274e:	42b2      	cmp	r2, r6
c0d02750:	d800      	bhi.n	c0d02754 <__aeabi_ddiv+0x4cc>
c0d02752:	e6a3      	b.n	c0d0249c <__aeabi_ddiv+0x214>
c0d02754:	1e83      	subs	r3, r0, #2
c0d02756:	1936      	adds	r6, r6, r4
c0d02758:	e6a0      	b.n	c0d0249c <__aeabi_ddiv+0x214>
c0d0275a:	1909      	adds	r1, r1, r4
c0d0275c:	3d01      	subs	r5, #1
c0d0275e:	428c      	cmp	r4, r1
c0d02760:	d900      	bls.n	c0d02764 <__aeabi_ddiv+0x4dc>
c0d02762:	e68d      	b.n	c0d02480 <__aeabi_ddiv+0x1f8>
c0d02764:	428a      	cmp	r2, r1
c0d02766:	d800      	bhi.n	c0d0276a <__aeabi_ddiv+0x4e2>
c0d02768:	e68a      	b.n	c0d02480 <__aeabi_ddiv+0x1f8>
c0d0276a:	1e85      	subs	r5, r0, #2
c0d0276c:	1909      	adds	r1, r1, r4
c0d0276e:	e687      	b.n	c0d02480 <__aeabi_ddiv+0x1f8>
c0d02770:	230f      	movs	r3, #15
c0d02772:	402b      	ands	r3, r5
c0d02774:	2b04      	cmp	r3, #4
c0d02776:	d100      	bne.n	c0d0277a <__aeabi_ddiv+0x4f2>
c0d02778:	e6bc      	b.n	c0d024f4 <__aeabi_ddiv+0x26c>
c0d0277a:	2305      	movs	r3, #5
c0d0277c:	425b      	negs	r3, r3
c0d0277e:	42ab      	cmp	r3, r5
c0d02780:	419b      	sbcs	r3, r3
c0d02782:	3504      	adds	r5, #4
c0d02784:	425b      	negs	r3, r3
c0d02786:	08ed      	lsrs	r5, r5, #3
c0d02788:	4498      	add	r8, r3
c0d0278a:	e6b4      	b.n	c0d024f6 <__aeabi_ddiv+0x26e>
c0d0278c:	42af      	cmp	r7, r5
c0d0278e:	d900      	bls.n	c0d02792 <__aeabi_ddiv+0x50a>
c0d02790:	e660      	b.n	c0d02454 <__aeabi_ddiv+0x1cc>
c0d02792:	4282      	cmp	r2, r0
c0d02794:	d804      	bhi.n	c0d027a0 <__aeabi_ddiv+0x518>
c0d02796:	d000      	beq.n	c0d0279a <__aeabi_ddiv+0x512>
c0d02798:	e65c      	b.n	c0d02454 <__aeabi_ddiv+0x1cc>
c0d0279a:	42ae      	cmp	r6, r5
c0d0279c:	d800      	bhi.n	c0d027a0 <__aeabi_ddiv+0x518>
c0d0279e:	e659      	b.n	c0d02454 <__aeabi_ddiv+0x1cc>
c0d027a0:	2302      	movs	r3, #2
c0d027a2:	425b      	negs	r3, r3
c0d027a4:	469c      	mov	ip, r3
c0d027a6:	9b00      	ldr	r3, [sp, #0]
c0d027a8:	44e0      	add	r8, ip
c0d027aa:	469c      	mov	ip, r3
c0d027ac:	4465      	add	r5, ip
c0d027ae:	429d      	cmp	r5, r3
c0d027b0:	419b      	sbcs	r3, r3
c0d027b2:	425b      	negs	r3, r3
c0d027b4:	191b      	adds	r3, r3, r4
c0d027b6:	18c0      	adds	r0, r0, r3
c0d027b8:	e64d      	b.n	c0d02456 <__aeabi_ddiv+0x1ce>
c0d027ba:	428a      	cmp	r2, r1
c0d027bc:	d800      	bhi.n	c0d027c0 <__aeabi_ddiv+0x538>
c0d027be:	e60e      	b.n	c0d023de <__aeabi_ddiv+0x156>
c0d027c0:	1e83      	subs	r3, r0, #2
c0d027c2:	1909      	adds	r1, r1, r4
c0d027c4:	e60b      	b.n	c0d023de <__aeabi_ddiv+0x156>
c0d027c6:	428a      	cmp	r2, r1
c0d027c8:	d800      	bhi.n	c0d027cc <__aeabi_ddiv+0x544>
c0d027ca:	e5f4      	b.n	c0d023b6 <__aeabi_ddiv+0x12e>
c0d027cc:	1e83      	subs	r3, r0, #2
c0d027ce:	4698      	mov	r8, r3
c0d027d0:	1909      	adds	r1, r1, r4
c0d027d2:	e5f0      	b.n	c0d023b6 <__aeabi_ddiv+0x12e>
c0d027d4:	4925      	ldr	r1, [pc, #148]	; (c0d0286c <__aeabi_ddiv+0x5e4>)
c0d027d6:	0028      	movs	r0, r5
c0d027d8:	4459      	add	r1, fp
c0d027da:	408d      	lsls	r5, r1
c0d027dc:	4642      	mov	r2, r8
c0d027de:	408a      	lsls	r2, r1
c0d027e0:	1e69      	subs	r1, r5, #1
c0d027e2:	418d      	sbcs	r5, r1
c0d027e4:	4641      	mov	r1, r8
c0d027e6:	40d8      	lsrs	r0, r3
c0d027e8:	40d9      	lsrs	r1, r3
c0d027ea:	4302      	orrs	r2, r0
c0d027ec:	432a      	orrs	r2, r5
c0d027ee:	000b      	movs	r3, r1
c0d027f0:	0751      	lsls	r1, r2, #29
c0d027f2:	d100      	bne.n	c0d027f6 <__aeabi_ddiv+0x56e>
c0d027f4:	e751      	b.n	c0d0269a <__aeabi_ddiv+0x412>
c0d027f6:	210f      	movs	r1, #15
c0d027f8:	4011      	ands	r1, r2
c0d027fa:	2904      	cmp	r1, #4
c0d027fc:	d000      	beq.n	c0d02800 <__aeabi_ddiv+0x578>
c0d027fe:	e746      	b.n	c0d0268e <__aeabi_ddiv+0x406>
c0d02800:	e74b      	b.n	c0d0269a <__aeabi_ddiv+0x412>
c0d02802:	0005      	movs	r5, r0
c0d02804:	428e      	cmp	r6, r1
c0d02806:	d000      	beq.n	c0d0280a <__aeabi_ddiv+0x582>
c0d02808:	e66a      	b.n	c0d024e0 <__aeabi_ddiv+0x258>
c0d0280a:	9a00      	ldr	r2, [sp, #0]
c0d0280c:	4293      	cmp	r3, r2
c0d0280e:	d000      	beq.n	c0d02812 <__aeabi_ddiv+0x58a>
c0d02810:	e666      	b.n	c0d024e0 <__aeabi_ddiv+0x258>
c0d02812:	e667      	b.n	c0d024e4 <__aeabi_ddiv+0x25c>
c0d02814:	4a16      	ldr	r2, [pc, #88]	; (c0d02870 <__aeabi_ddiv+0x5e8>)
c0d02816:	445a      	add	r2, fp
c0d02818:	2a00      	cmp	r2, #0
c0d0281a:	dc00      	bgt.n	c0d0281e <__aeabi_ddiv+0x596>
c0d0281c:	e710      	b.n	c0d02640 <__aeabi_ddiv+0x3b8>
c0d0281e:	2301      	movs	r3, #1
c0d02820:	2500      	movs	r5, #0
c0d02822:	4498      	add	r8, r3
c0d02824:	e667      	b.n	c0d024f6 <__aeabi_ddiv+0x26e>
c0d02826:	075d      	lsls	r5, r3, #29
c0d02828:	025b      	lsls	r3, r3, #9
c0d0282a:	0b1c      	lsrs	r4, r3, #12
c0d0282c:	08d2      	lsrs	r2, r2, #3
c0d0282e:	2300      	movs	r3, #0
c0d02830:	4315      	orrs	r5, r2
c0d02832:	e580      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d02834:	9800      	ldr	r0, [sp, #0]
c0d02836:	3d02      	subs	r5, #2
c0d02838:	0042      	lsls	r2, r0, #1
c0d0283a:	4282      	cmp	r2, r0
c0d0283c:	41bf      	sbcs	r7, r7
c0d0283e:	427f      	negs	r7, r7
c0d02840:	193c      	adds	r4, r7, r4
c0d02842:	1936      	adds	r6, r6, r4
c0d02844:	9200      	str	r2, [sp, #0]
c0d02846:	e7dd      	b.n	c0d02804 <__aeabi_ddiv+0x57c>
c0d02848:	2480      	movs	r4, #128	; 0x80
c0d0284a:	4643      	mov	r3, r8
c0d0284c:	0324      	lsls	r4, r4, #12
c0d0284e:	431c      	orrs	r4, r3
c0d02850:	0324      	lsls	r4, r4, #12
c0d02852:	4b04      	ldr	r3, [pc, #16]	; (c0d02864 <__aeabi_ddiv+0x5dc>)
c0d02854:	0b24      	lsrs	r4, r4, #12
c0d02856:	e56e      	b.n	c0d02336 <__aeabi_ddiv+0xae>
c0d02858:	9a00      	ldr	r2, [sp, #0]
c0d0285a:	429a      	cmp	r2, r3
c0d0285c:	d3ea      	bcc.n	c0d02834 <__aeabi_ddiv+0x5ac>
c0d0285e:	0005      	movs	r5, r0
c0d02860:	e7d3      	b.n	c0d0280a <__aeabi_ddiv+0x582>
c0d02862:	46c0      	nop			; (mov r8, r8)
c0d02864:	000007ff 	.word	0x000007ff
c0d02868:	0000043e 	.word	0x0000043e
c0d0286c:	0000041e 	.word	0x0000041e
c0d02870:	000003ff 	.word	0x000003ff

c0d02874 <__eqdf2>:
c0d02874:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02876:	464e      	mov	r6, r9
c0d02878:	4645      	mov	r5, r8
c0d0287a:	46de      	mov	lr, fp
c0d0287c:	4657      	mov	r7, sl
c0d0287e:	4690      	mov	r8, r2
c0d02880:	b5e0      	push	{r5, r6, r7, lr}
c0d02882:	0017      	movs	r7, r2
c0d02884:	031a      	lsls	r2, r3, #12
c0d02886:	0b12      	lsrs	r2, r2, #12
c0d02888:	0005      	movs	r5, r0
c0d0288a:	4684      	mov	ip, r0
c0d0288c:	4819      	ldr	r0, [pc, #100]	; (c0d028f4 <__eqdf2+0x80>)
c0d0288e:	030e      	lsls	r6, r1, #12
c0d02890:	004c      	lsls	r4, r1, #1
c0d02892:	4691      	mov	r9, r2
c0d02894:	005a      	lsls	r2, r3, #1
c0d02896:	0fdb      	lsrs	r3, r3, #31
c0d02898:	469b      	mov	fp, r3
c0d0289a:	0b36      	lsrs	r6, r6, #12
c0d0289c:	0d64      	lsrs	r4, r4, #21
c0d0289e:	0fc9      	lsrs	r1, r1, #31
c0d028a0:	0d52      	lsrs	r2, r2, #21
c0d028a2:	4284      	cmp	r4, r0
c0d028a4:	d019      	beq.n	c0d028da <__eqdf2+0x66>
c0d028a6:	4282      	cmp	r2, r0
c0d028a8:	d010      	beq.n	c0d028cc <__eqdf2+0x58>
c0d028aa:	2001      	movs	r0, #1
c0d028ac:	4294      	cmp	r4, r2
c0d028ae:	d10e      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028b0:	454e      	cmp	r6, r9
c0d028b2:	d10c      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028b4:	2001      	movs	r0, #1
c0d028b6:	45c4      	cmp	ip, r8
c0d028b8:	d109      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028ba:	4559      	cmp	r1, fp
c0d028bc:	d017      	beq.n	c0d028ee <__eqdf2+0x7a>
c0d028be:	2c00      	cmp	r4, #0
c0d028c0:	d105      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028c2:	0030      	movs	r0, r6
c0d028c4:	4328      	orrs	r0, r5
c0d028c6:	1e43      	subs	r3, r0, #1
c0d028c8:	4198      	sbcs	r0, r3
c0d028ca:	e000      	b.n	c0d028ce <__eqdf2+0x5a>
c0d028cc:	2001      	movs	r0, #1
c0d028ce:	bcf0      	pop	{r4, r5, r6, r7}
c0d028d0:	46bb      	mov	fp, r7
c0d028d2:	46b2      	mov	sl, r6
c0d028d4:	46a9      	mov	r9, r5
c0d028d6:	46a0      	mov	r8, r4
c0d028d8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d028da:	0033      	movs	r3, r6
c0d028dc:	2001      	movs	r0, #1
c0d028de:	432b      	orrs	r3, r5
c0d028e0:	d1f5      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028e2:	42a2      	cmp	r2, r4
c0d028e4:	d1f3      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028e6:	464b      	mov	r3, r9
c0d028e8:	433b      	orrs	r3, r7
c0d028ea:	d1f0      	bne.n	c0d028ce <__eqdf2+0x5a>
c0d028ec:	e7e2      	b.n	c0d028b4 <__eqdf2+0x40>
c0d028ee:	2000      	movs	r0, #0
c0d028f0:	e7ed      	b.n	c0d028ce <__eqdf2+0x5a>
c0d028f2:	46c0      	nop			; (mov r8, r8)
c0d028f4:	000007ff 	.word	0x000007ff

c0d028f8 <__gedf2>:
c0d028f8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d028fa:	4647      	mov	r7, r8
c0d028fc:	46ce      	mov	lr, r9
c0d028fe:	0004      	movs	r4, r0
c0d02900:	0018      	movs	r0, r3
c0d02902:	0016      	movs	r6, r2
c0d02904:	031b      	lsls	r3, r3, #12
c0d02906:	0b1b      	lsrs	r3, r3, #12
c0d02908:	4d2d      	ldr	r5, [pc, #180]	; (c0d029c0 <__gedf2+0xc8>)
c0d0290a:	004a      	lsls	r2, r1, #1
c0d0290c:	4699      	mov	r9, r3
c0d0290e:	b580      	push	{r7, lr}
c0d02910:	0043      	lsls	r3, r0, #1
c0d02912:	030f      	lsls	r7, r1, #12
c0d02914:	46a4      	mov	ip, r4
c0d02916:	46b0      	mov	r8, r6
c0d02918:	0b3f      	lsrs	r7, r7, #12
c0d0291a:	0d52      	lsrs	r2, r2, #21
c0d0291c:	0fc9      	lsrs	r1, r1, #31
c0d0291e:	0d5b      	lsrs	r3, r3, #21
c0d02920:	0fc0      	lsrs	r0, r0, #31
c0d02922:	42aa      	cmp	r2, r5
c0d02924:	d021      	beq.n	c0d0296a <__gedf2+0x72>
c0d02926:	42ab      	cmp	r3, r5
c0d02928:	d013      	beq.n	c0d02952 <__gedf2+0x5a>
c0d0292a:	2a00      	cmp	r2, #0
c0d0292c:	d122      	bne.n	c0d02974 <__gedf2+0x7c>
c0d0292e:	433c      	orrs	r4, r7
c0d02930:	2b00      	cmp	r3, #0
c0d02932:	d102      	bne.n	c0d0293a <__gedf2+0x42>
c0d02934:	464d      	mov	r5, r9
c0d02936:	432e      	orrs	r6, r5
c0d02938:	d022      	beq.n	c0d02980 <__gedf2+0x88>
c0d0293a:	2c00      	cmp	r4, #0
c0d0293c:	d010      	beq.n	c0d02960 <__gedf2+0x68>
c0d0293e:	4281      	cmp	r1, r0
c0d02940:	d022      	beq.n	c0d02988 <__gedf2+0x90>
c0d02942:	2002      	movs	r0, #2
c0d02944:	3901      	subs	r1, #1
c0d02946:	4008      	ands	r0, r1
c0d02948:	3801      	subs	r0, #1
c0d0294a:	bcc0      	pop	{r6, r7}
c0d0294c:	46b9      	mov	r9, r7
c0d0294e:	46b0      	mov	r8, r6
c0d02950:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02952:	464d      	mov	r5, r9
c0d02954:	432e      	orrs	r6, r5
c0d02956:	d129      	bne.n	c0d029ac <__gedf2+0xb4>
c0d02958:	2a00      	cmp	r2, #0
c0d0295a:	d1f0      	bne.n	c0d0293e <__gedf2+0x46>
c0d0295c:	433c      	orrs	r4, r7
c0d0295e:	d1ee      	bne.n	c0d0293e <__gedf2+0x46>
c0d02960:	2800      	cmp	r0, #0
c0d02962:	d1f2      	bne.n	c0d0294a <__gedf2+0x52>
c0d02964:	2001      	movs	r0, #1
c0d02966:	4240      	negs	r0, r0
c0d02968:	e7ef      	b.n	c0d0294a <__gedf2+0x52>
c0d0296a:	003d      	movs	r5, r7
c0d0296c:	4325      	orrs	r5, r4
c0d0296e:	d11d      	bne.n	c0d029ac <__gedf2+0xb4>
c0d02970:	4293      	cmp	r3, r2
c0d02972:	d0ee      	beq.n	c0d02952 <__gedf2+0x5a>
c0d02974:	2b00      	cmp	r3, #0
c0d02976:	d1e2      	bne.n	c0d0293e <__gedf2+0x46>
c0d02978:	464c      	mov	r4, r9
c0d0297a:	4326      	orrs	r6, r4
c0d0297c:	d1df      	bne.n	c0d0293e <__gedf2+0x46>
c0d0297e:	e7e0      	b.n	c0d02942 <__gedf2+0x4a>
c0d02980:	2000      	movs	r0, #0
c0d02982:	2c00      	cmp	r4, #0
c0d02984:	d0e1      	beq.n	c0d0294a <__gedf2+0x52>
c0d02986:	e7dc      	b.n	c0d02942 <__gedf2+0x4a>
c0d02988:	429a      	cmp	r2, r3
c0d0298a:	dc0a      	bgt.n	c0d029a2 <__gedf2+0xaa>
c0d0298c:	dbe8      	blt.n	c0d02960 <__gedf2+0x68>
c0d0298e:	454f      	cmp	r7, r9
c0d02990:	d8d7      	bhi.n	c0d02942 <__gedf2+0x4a>
c0d02992:	d00e      	beq.n	c0d029b2 <__gedf2+0xba>
c0d02994:	2000      	movs	r0, #0
c0d02996:	454f      	cmp	r7, r9
c0d02998:	d2d7      	bcs.n	c0d0294a <__gedf2+0x52>
c0d0299a:	2900      	cmp	r1, #0
c0d0299c:	d0e2      	beq.n	c0d02964 <__gedf2+0x6c>
c0d0299e:	0008      	movs	r0, r1
c0d029a0:	e7d3      	b.n	c0d0294a <__gedf2+0x52>
c0d029a2:	4243      	negs	r3, r0
c0d029a4:	4158      	adcs	r0, r3
c0d029a6:	0040      	lsls	r0, r0, #1
c0d029a8:	3801      	subs	r0, #1
c0d029aa:	e7ce      	b.n	c0d0294a <__gedf2+0x52>
c0d029ac:	2002      	movs	r0, #2
c0d029ae:	4240      	negs	r0, r0
c0d029b0:	e7cb      	b.n	c0d0294a <__gedf2+0x52>
c0d029b2:	45c4      	cmp	ip, r8
c0d029b4:	d8c5      	bhi.n	c0d02942 <__gedf2+0x4a>
c0d029b6:	2000      	movs	r0, #0
c0d029b8:	45c4      	cmp	ip, r8
c0d029ba:	d2c6      	bcs.n	c0d0294a <__gedf2+0x52>
c0d029bc:	e7ed      	b.n	c0d0299a <__gedf2+0xa2>
c0d029be:	46c0      	nop			; (mov r8, r8)
c0d029c0:	000007ff 	.word	0x000007ff

c0d029c4 <__ledf2>:
c0d029c4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d029c6:	4647      	mov	r7, r8
c0d029c8:	46ce      	mov	lr, r9
c0d029ca:	0004      	movs	r4, r0
c0d029cc:	0018      	movs	r0, r3
c0d029ce:	0016      	movs	r6, r2
c0d029d0:	031b      	lsls	r3, r3, #12
c0d029d2:	0b1b      	lsrs	r3, r3, #12
c0d029d4:	4d2c      	ldr	r5, [pc, #176]	; (c0d02a88 <__ledf2+0xc4>)
c0d029d6:	004a      	lsls	r2, r1, #1
c0d029d8:	4699      	mov	r9, r3
c0d029da:	b580      	push	{r7, lr}
c0d029dc:	0043      	lsls	r3, r0, #1
c0d029de:	030f      	lsls	r7, r1, #12
c0d029e0:	46a4      	mov	ip, r4
c0d029e2:	46b0      	mov	r8, r6
c0d029e4:	0b3f      	lsrs	r7, r7, #12
c0d029e6:	0d52      	lsrs	r2, r2, #21
c0d029e8:	0fc9      	lsrs	r1, r1, #31
c0d029ea:	0d5b      	lsrs	r3, r3, #21
c0d029ec:	0fc0      	lsrs	r0, r0, #31
c0d029ee:	42aa      	cmp	r2, r5
c0d029f0:	d00d      	beq.n	c0d02a0e <__ledf2+0x4a>
c0d029f2:	42ab      	cmp	r3, r5
c0d029f4:	d010      	beq.n	c0d02a18 <__ledf2+0x54>
c0d029f6:	2a00      	cmp	r2, #0
c0d029f8:	d127      	bne.n	c0d02a4a <__ledf2+0x86>
c0d029fa:	433c      	orrs	r4, r7
c0d029fc:	2b00      	cmp	r3, #0
c0d029fe:	d111      	bne.n	c0d02a24 <__ledf2+0x60>
c0d02a00:	464d      	mov	r5, r9
c0d02a02:	432e      	orrs	r6, r5
c0d02a04:	d10e      	bne.n	c0d02a24 <__ledf2+0x60>
c0d02a06:	2000      	movs	r0, #0
c0d02a08:	2c00      	cmp	r4, #0
c0d02a0a:	d015      	beq.n	c0d02a38 <__ledf2+0x74>
c0d02a0c:	e00e      	b.n	c0d02a2c <__ledf2+0x68>
c0d02a0e:	003d      	movs	r5, r7
c0d02a10:	4325      	orrs	r5, r4
c0d02a12:	d110      	bne.n	c0d02a36 <__ledf2+0x72>
c0d02a14:	4293      	cmp	r3, r2
c0d02a16:	d118      	bne.n	c0d02a4a <__ledf2+0x86>
c0d02a18:	464d      	mov	r5, r9
c0d02a1a:	432e      	orrs	r6, r5
c0d02a1c:	d10b      	bne.n	c0d02a36 <__ledf2+0x72>
c0d02a1e:	2a00      	cmp	r2, #0
c0d02a20:	d102      	bne.n	c0d02a28 <__ledf2+0x64>
c0d02a22:	433c      	orrs	r4, r7
c0d02a24:	2c00      	cmp	r4, #0
c0d02a26:	d00b      	beq.n	c0d02a40 <__ledf2+0x7c>
c0d02a28:	4281      	cmp	r1, r0
c0d02a2a:	d014      	beq.n	c0d02a56 <__ledf2+0x92>
c0d02a2c:	2002      	movs	r0, #2
c0d02a2e:	3901      	subs	r1, #1
c0d02a30:	4008      	ands	r0, r1
c0d02a32:	3801      	subs	r0, #1
c0d02a34:	e000      	b.n	c0d02a38 <__ledf2+0x74>
c0d02a36:	2002      	movs	r0, #2
c0d02a38:	bcc0      	pop	{r6, r7}
c0d02a3a:	46b9      	mov	r9, r7
c0d02a3c:	46b0      	mov	r8, r6
c0d02a3e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02a40:	2800      	cmp	r0, #0
c0d02a42:	d1f9      	bne.n	c0d02a38 <__ledf2+0x74>
c0d02a44:	2001      	movs	r0, #1
c0d02a46:	4240      	negs	r0, r0
c0d02a48:	e7f6      	b.n	c0d02a38 <__ledf2+0x74>
c0d02a4a:	2b00      	cmp	r3, #0
c0d02a4c:	d1ec      	bne.n	c0d02a28 <__ledf2+0x64>
c0d02a4e:	464c      	mov	r4, r9
c0d02a50:	4326      	orrs	r6, r4
c0d02a52:	d1e9      	bne.n	c0d02a28 <__ledf2+0x64>
c0d02a54:	e7ea      	b.n	c0d02a2c <__ledf2+0x68>
c0d02a56:	429a      	cmp	r2, r3
c0d02a58:	dd04      	ble.n	c0d02a64 <__ledf2+0xa0>
c0d02a5a:	4243      	negs	r3, r0
c0d02a5c:	4158      	adcs	r0, r3
c0d02a5e:	0040      	lsls	r0, r0, #1
c0d02a60:	3801      	subs	r0, #1
c0d02a62:	e7e9      	b.n	c0d02a38 <__ledf2+0x74>
c0d02a64:	429a      	cmp	r2, r3
c0d02a66:	dbeb      	blt.n	c0d02a40 <__ledf2+0x7c>
c0d02a68:	454f      	cmp	r7, r9
c0d02a6a:	d8df      	bhi.n	c0d02a2c <__ledf2+0x68>
c0d02a6c:	d006      	beq.n	c0d02a7c <__ledf2+0xb8>
c0d02a6e:	2000      	movs	r0, #0
c0d02a70:	454f      	cmp	r7, r9
c0d02a72:	d2e1      	bcs.n	c0d02a38 <__ledf2+0x74>
c0d02a74:	2900      	cmp	r1, #0
c0d02a76:	d0e5      	beq.n	c0d02a44 <__ledf2+0x80>
c0d02a78:	0008      	movs	r0, r1
c0d02a7a:	e7dd      	b.n	c0d02a38 <__ledf2+0x74>
c0d02a7c:	45c4      	cmp	ip, r8
c0d02a7e:	d8d5      	bhi.n	c0d02a2c <__ledf2+0x68>
c0d02a80:	2000      	movs	r0, #0
c0d02a82:	45c4      	cmp	ip, r8
c0d02a84:	d2d8      	bcs.n	c0d02a38 <__ledf2+0x74>
c0d02a86:	e7f5      	b.n	c0d02a74 <__ledf2+0xb0>
c0d02a88:	000007ff 	.word	0x000007ff

c0d02a8c <__aeabi_dmul>:
c0d02a8c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02a8e:	4657      	mov	r7, sl
c0d02a90:	464e      	mov	r6, r9
c0d02a92:	4645      	mov	r5, r8
c0d02a94:	46de      	mov	lr, fp
c0d02a96:	b5e0      	push	{r5, r6, r7, lr}
c0d02a98:	4698      	mov	r8, r3
c0d02a9a:	030c      	lsls	r4, r1, #12
c0d02a9c:	004b      	lsls	r3, r1, #1
c0d02a9e:	0006      	movs	r6, r0
c0d02aa0:	4692      	mov	sl, r2
c0d02aa2:	b087      	sub	sp, #28
c0d02aa4:	0b24      	lsrs	r4, r4, #12
c0d02aa6:	0d5b      	lsrs	r3, r3, #21
c0d02aa8:	0fcf      	lsrs	r7, r1, #31
c0d02aaa:	2b00      	cmp	r3, #0
c0d02aac:	d100      	bne.n	c0d02ab0 <__aeabi_dmul+0x24>
c0d02aae:	e15e      	b.n	c0d02d6e <__aeabi_dmul+0x2e2>
c0d02ab0:	4ada      	ldr	r2, [pc, #872]	; (c0d02e1c <__aeabi_dmul+0x390>)
c0d02ab2:	4293      	cmp	r3, r2
c0d02ab4:	d100      	bne.n	c0d02ab8 <__aeabi_dmul+0x2c>
c0d02ab6:	e177      	b.n	c0d02da8 <__aeabi_dmul+0x31c>
c0d02ab8:	0f42      	lsrs	r2, r0, #29
c0d02aba:	00e4      	lsls	r4, r4, #3
c0d02abc:	4314      	orrs	r4, r2
c0d02abe:	2280      	movs	r2, #128	; 0x80
c0d02ac0:	0412      	lsls	r2, r2, #16
c0d02ac2:	4314      	orrs	r4, r2
c0d02ac4:	4ad6      	ldr	r2, [pc, #856]	; (c0d02e20 <__aeabi_dmul+0x394>)
c0d02ac6:	00c5      	lsls	r5, r0, #3
c0d02ac8:	4694      	mov	ip, r2
c0d02aca:	4463      	add	r3, ip
c0d02acc:	9300      	str	r3, [sp, #0]
c0d02ace:	2300      	movs	r3, #0
c0d02ad0:	4699      	mov	r9, r3
c0d02ad2:	469b      	mov	fp, r3
c0d02ad4:	4643      	mov	r3, r8
c0d02ad6:	4642      	mov	r2, r8
c0d02ad8:	031e      	lsls	r6, r3, #12
c0d02ada:	0fd2      	lsrs	r2, r2, #31
c0d02adc:	005b      	lsls	r3, r3, #1
c0d02ade:	4650      	mov	r0, sl
c0d02ae0:	4690      	mov	r8, r2
c0d02ae2:	0b36      	lsrs	r6, r6, #12
c0d02ae4:	0d5b      	lsrs	r3, r3, #21
c0d02ae6:	d100      	bne.n	c0d02aea <__aeabi_dmul+0x5e>
c0d02ae8:	e122      	b.n	c0d02d30 <__aeabi_dmul+0x2a4>
c0d02aea:	4acc      	ldr	r2, [pc, #816]	; (c0d02e1c <__aeabi_dmul+0x390>)
c0d02aec:	4293      	cmp	r3, r2
c0d02aee:	d100      	bne.n	c0d02af2 <__aeabi_dmul+0x66>
c0d02af0:	e164      	b.n	c0d02dbc <__aeabi_dmul+0x330>
c0d02af2:	49cb      	ldr	r1, [pc, #812]	; (c0d02e20 <__aeabi_dmul+0x394>)
c0d02af4:	0f42      	lsrs	r2, r0, #29
c0d02af6:	468c      	mov	ip, r1
c0d02af8:	9900      	ldr	r1, [sp, #0]
c0d02afa:	4463      	add	r3, ip
c0d02afc:	00f6      	lsls	r6, r6, #3
c0d02afe:	468c      	mov	ip, r1
c0d02b00:	4316      	orrs	r6, r2
c0d02b02:	2280      	movs	r2, #128	; 0x80
c0d02b04:	449c      	add	ip, r3
c0d02b06:	0412      	lsls	r2, r2, #16
c0d02b08:	4663      	mov	r3, ip
c0d02b0a:	4316      	orrs	r6, r2
c0d02b0c:	00c2      	lsls	r2, r0, #3
c0d02b0e:	2000      	movs	r0, #0
c0d02b10:	9300      	str	r3, [sp, #0]
c0d02b12:	9900      	ldr	r1, [sp, #0]
c0d02b14:	4643      	mov	r3, r8
c0d02b16:	3101      	adds	r1, #1
c0d02b18:	468c      	mov	ip, r1
c0d02b1a:	4649      	mov	r1, r9
c0d02b1c:	407b      	eors	r3, r7
c0d02b1e:	9301      	str	r3, [sp, #4]
c0d02b20:	290f      	cmp	r1, #15
c0d02b22:	d826      	bhi.n	c0d02b72 <__aeabi_dmul+0xe6>
c0d02b24:	4bbf      	ldr	r3, [pc, #764]	; (c0d02e24 <__aeabi_dmul+0x398>)
c0d02b26:	0089      	lsls	r1, r1, #2
c0d02b28:	5859      	ldr	r1, [r3, r1]
c0d02b2a:	468f      	mov	pc, r1
c0d02b2c:	4643      	mov	r3, r8
c0d02b2e:	9301      	str	r3, [sp, #4]
c0d02b30:	0034      	movs	r4, r6
c0d02b32:	0015      	movs	r5, r2
c0d02b34:	4683      	mov	fp, r0
c0d02b36:	465b      	mov	r3, fp
c0d02b38:	2b02      	cmp	r3, #2
c0d02b3a:	d016      	beq.n	c0d02b6a <__aeabi_dmul+0xde>
c0d02b3c:	2b03      	cmp	r3, #3
c0d02b3e:	d100      	bne.n	c0d02b42 <__aeabi_dmul+0xb6>
c0d02b40:	e205      	b.n	c0d02f4e <__aeabi_dmul+0x4c2>
c0d02b42:	2b01      	cmp	r3, #1
c0d02b44:	d000      	beq.n	c0d02b48 <__aeabi_dmul+0xbc>
c0d02b46:	e0cf      	b.n	c0d02ce8 <__aeabi_dmul+0x25c>
c0d02b48:	2200      	movs	r2, #0
c0d02b4a:	2400      	movs	r4, #0
c0d02b4c:	2500      	movs	r5, #0
c0d02b4e:	9b01      	ldr	r3, [sp, #4]
c0d02b50:	0512      	lsls	r2, r2, #20
c0d02b52:	4322      	orrs	r2, r4
c0d02b54:	07db      	lsls	r3, r3, #31
c0d02b56:	431a      	orrs	r2, r3
c0d02b58:	0028      	movs	r0, r5
c0d02b5a:	0011      	movs	r1, r2
c0d02b5c:	b007      	add	sp, #28
c0d02b5e:	bcf0      	pop	{r4, r5, r6, r7}
c0d02b60:	46bb      	mov	fp, r7
c0d02b62:	46b2      	mov	sl, r6
c0d02b64:	46a9      	mov	r9, r5
c0d02b66:	46a0      	mov	r8, r4
c0d02b68:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02b6a:	2400      	movs	r4, #0
c0d02b6c:	2500      	movs	r5, #0
c0d02b6e:	4aab      	ldr	r2, [pc, #684]	; (c0d02e1c <__aeabi_dmul+0x390>)
c0d02b70:	e7ed      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02b72:	0c28      	lsrs	r0, r5, #16
c0d02b74:	042d      	lsls	r5, r5, #16
c0d02b76:	0c2d      	lsrs	r5, r5, #16
c0d02b78:	002b      	movs	r3, r5
c0d02b7a:	0c11      	lsrs	r1, r2, #16
c0d02b7c:	0412      	lsls	r2, r2, #16
c0d02b7e:	0c12      	lsrs	r2, r2, #16
c0d02b80:	4353      	muls	r3, r2
c0d02b82:	4698      	mov	r8, r3
c0d02b84:	0013      	movs	r3, r2
c0d02b86:	002f      	movs	r7, r5
c0d02b88:	4343      	muls	r3, r0
c0d02b8a:	4699      	mov	r9, r3
c0d02b8c:	434f      	muls	r7, r1
c0d02b8e:	444f      	add	r7, r9
c0d02b90:	46bb      	mov	fp, r7
c0d02b92:	4647      	mov	r7, r8
c0d02b94:	000b      	movs	r3, r1
c0d02b96:	0c3f      	lsrs	r7, r7, #16
c0d02b98:	46ba      	mov	sl, r7
c0d02b9a:	465f      	mov	r7, fp
c0d02b9c:	4343      	muls	r3, r0
c0d02b9e:	4457      	add	r7, sl
c0d02ba0:	9302      	str	r3, [sp, #8]
c0d02ba2:	45b9      	cmp	r9, r7
c0d02ba4:	d906      	bls.n	c0d02bb4 <__aeabi_dmul+0x128>
c0d02ba6:	469a      	mov	sl, r3
c0d02ba8:	2380      	movs	r3, #128	; 0x80
c0d02baa:	025b      	lsls	r3, r3, #9
c0d02bac:	4699      	mov	r9, r3
c0d02bae:	44ca      	add	sl, r9
c0d02bb0:	4653      	mov	r3, sl
c0d02bb2:	9302      	str	r3, [sp, #8]
c0d02bb4:	0c3b      	lsrs	r3, r7, #16
c0d02bb6:	469b      	mov	fp, r3
c0d02bb8:	4643      	mov	r3, r8
c0d02bba:	041b      	lsls	r3, r3, #16
c0d02bbc:	043f      	lsls	r7, r7, #16
c0d02bbe:	0c1b      	lsrs	r3, r3, #16
c0d02bc0:	4698      	mov	r8, r3
c0d02bc2:	003b      	movs	r3, r7
c0d02bc4:	4443      	add	r3, r8
c0d02bc6:	9304      	str	r3, [sp, #16]
c0d02bc8:	0c33      	lsrs	r3, r6, #16
c0d02bca:	0436      	lsls	r6, r6, #16
c0d02bcc:	0c36      	lsrs	r6, r6, #16
c0d02bce:	4698      	mov	r8, r3
c0d02bd0:	0033      	movs	r3, r6
c0d02bd2:	4343      	muls	r3, r0
c0d02bd4:	4699      	mov	r9, r3
c0d02bd6:	4643      	mov	r3, r8
c0d02bd8:	4343      	muls	r3, r0
c0d02bda:	002f      	movs	r7, r5
c0d02bdc:	469a      	mov	sl, r3
c0d02bde:	4643      	mov	r3, r8
c0d02be0:	4377      	muls	r7, r6
c0d02be2:	435d      	muls	r5, r3
c0d02be4:	0c38      	lsrs	r0, r7, #16
c0d02be6:	444d      	add	r5, r9
c0d02be8:	1945      	adds	r5, r0, r5
c0d02bea:	45a9      	cmp	r9, r5
c0d02bec:	d903      	bls.n	c0d02bf6 <__aeabi_dmul+0x16a>
c0d02bee:	2380      	movs	r3, #128	; 0x80
c0d02bf0:	025b      	lsls	r3, r3, #9
c0d02bf2:	4699      	mov	r9, r3
c0d02bf4:	44ca      	add	sl, r9
c0d02bf6:	043f      	lsls	r7, r7, #16
c0d02bf8:	0c28      	lsrs	r0, r5, #16
c0d02bfa:	0c3f      	lsrs	r7, r7, #16
c0d02bfc:	042d      	lsls	r5, r5, #16
c0d02bfe:	19ed      	adds	r5, r5, r7
c0d02c00:	0c27      	lsrs	r7, r4, #16
c0d02c02:	0424      	lsls	r4, r4, #16
c0d02c04:	0c24      	lsrs	r4, r4, #16
c0d02c06:	0003      	movs	r3, r0
c0d02c08:	0020      	movs	r0, r4
c0d02c0a:	4350      	muls	r0, r2
c0d02c0c:	437a      	muls	r2, r7
c0d02c0e:	4691      	mov	r9, r2
c0d02c10:	003a      	movs	r2, r7
c0d02c12:	4453      	add	r3, sl
c0d02c14:	9305      	str	r3, [sp, #20]
c0d02c16:	0c03      	lsrs	r3, r0, #16
c0d02c18:	469a      	mov	sl, r3
c0d02c1a:	434a      	muls	r2, r1
c0d02c1c:	4361      	muls	r1, r4
c0d02c1e:	4449      	add	r1, r9
c0d02c20:	4451      	add	r1, sl
c0d02c22:	44ab      	add	fp, r5
c0d02c24:	4589      	cmp	r9, r1
c0d02c26:	d903      	bls.n	c0d02c30 <__aeabi_dmul+0x1a4>
c0d02c28:	2380      	movs	r3, #128	; 0x80
c0d02c2a:	025b      	lsls	r3, r3, #9
c0d02c2c:	4699      	mov	r9, r3
c0d02c2e:	444a      	add	r2, r9
c0d02c30:	0400      	lsls	r0, r0, #16
c0d02c32:	0c0b      	lsrs	r3, r1, #16
c0d02c34:	0c00      	lsrs	r0, r0, #16
c0d02c36:	0409      	lsls	r1, r1, #16
c0d02c38:	1809      	adds	r1, r1, r0
c0d02c3a:	0020      	movs	r0, r4
c0d02c3c:	4699      	mov	r9, r3
c0d02c3e:	4643      	mov	r3, r8
c0d02c40:	4370      	muls	r0, r6
c0d02c42:	435c      	muls	r4, r3
c0d02c44:	437e      	muls	r6, r7
c0d02c46:	435f      	muls	r7, r3
c0d02c48:	0c03      	lsrs	r3, r0, #16
c0d02c4a:	4698      	mov	r8, r3
c0d02c4c:	19a4      	adds	r4, r4, r6
c0d02c4e:	4444      	add	r4, r8
c0d02c50:	444a      	add	r2, r9
c0d02c52:	9703      	str	r7, [sp, #12]
c0d02c54:	42a6      	cmp	r6, r4
c0d02c56:	d904      	bls.n	c0d02c62 <__aeabi_dmul+0x1d6>
c0d02c58:	2380      	movs	r3, #128	; 0x80
c0d02c5a:	025b      	lsls	r3, r3, #9
c0d02c5c:	4698      	mov	r8, r3
c0d02c5e:	4447      	add	r7, r8
c0d02c60:	9703      	str	r7, [sp, #12]
c0d02c62:	9b02      	ldr	r3, [sp, #8]
c0d02c64:	0400      	lsls	r0, r0, #16
c0d02c66:	445b      	add	r3, fp
c0d02c68:	001e      	movs	r6, r3
c0d02c6a:	42ab      	cmp	r3, r5
c0d02c6c:	41ad      	sbcs	r5, r5
c0d02c6e:	0423      	lsls	r3, r4, #16
c0d02c70:	469a      	mov	sl, r3
c0d02c72:	9b05      	ldr	r3, [sp, #20]
c0d02c74:	1876      	adds	r6, r6, r1
c0d02c76:	4698      	mov	r8, r3
c0d02c78:	428e      	cmp	r6, r1
c0d02c7a:	4189      	sbcs	r1, r1
c0d02c7c:	0c00      	lsrs	r0, r0, #16
c0d02c7e:	4450      	add	r0, sl
c0d02c80:	4440      	add	r0, r8
c0d02c82:	426d      	negs	r5, r5
c0d02c84:	1947      	adds	r7, r0, r5
c0d02c86:	46b8      	mov	r8, r7
c0d02c88:	4693      	mov	fp, r2
c0d02c8a:	4249      	negs	r1, r1
c0d02c8c:	4689      	mov	r9, r1
c0d02c8e:	44c3      	add	fp, r8
c0d02c90:	44d9      	add	r9, fp
c0d02c92:	4298      	cmp	r0, r3
c0d02c94:	4180      	sbcs	r0, r0
c0d02c96:	45a8      	cmp	r8, r5
c0d02c98:	41ad      	sbcs	r5, r5
c0d02c9a:	4593      	cmp	fp, r2
c0d02c9c:	4192      	sbcs	r2, r2
c0d02c9e:	4589      	cmp	r9, r1
c0d02ca0:	4189      	sbcs	r1, r1
c0d02ca2:	426d      	negs	r5, r5
c0d02ca4:	4240      	negs	r0, r0
c0d02ca6:	4328      	orrs	r0, r5
c0d02ca8:	0c24      	lsrs	r4, r4, #16
c0d02caa:	4252      	negs	r2, r2
c0d02cac:	4249      	negs	r1, r1
c0d02cae:	430a      	orrs	r2, r1
c0d02cb0:	9b03      	ldr	r3, [sp, #12]
c0d02cb2:	1900      	adds	r0, r0, r4
c0d02cb4:	1880      	adds	r0, r0, r2
c0d02cb6:	18c7      	adds	r7, r0, r3
c0d02cb8:	464b      	mov	r3, r9
c0d02cba:	0ddc      	lsrs	r4, r3, #23
c0d02cbc:	9b04      	ldr	r3, [sp, #16]
c0d02cbe:	0275      	lsls	r5, r6, #9
c0d02cc0:	431d      	orrs	r5, r3
c0d02cc2:	1e6a      	subs	r2, r5, #1
c0d02cc4:	4195      	sbcs	r5, r2
c0d02cc6:	464b      	mov	r3, r9
c0d02cc8:	0df6      	lsrs	r6, r6, #23
c0d02cca:	027f      	lsls	r7, r7, #9
c0d02ccc:	4335      	orrs	r5, r6
c0d02cce:	025a      	lsls	r2, r3, #9
c0d02cd0:	433c      	orrs	r4, r7
c0d02cd2:	4315      	orrs	r5, r2
c0d02cd4:	01fb      	lsls	r3, r7, #7
c0d02cd6:	d400      	bmi.n	c0d02cda <__aeabi_dmul+0x24e>
c0d02cd8:	e11c      	b.n	c0d02f14 <__aeabi_dmul+0x488>
c0d02cda:	2101      	movs	r1, #1
c0d02cdc:	086a      	lsrs	r2, r5, #1
c0d02cde:	400d      	ands	r5, r1
c0d02ce0:	4315      	orrs	r5, r2
c0d02ce2:	07e2      	lsls	r2, r4, #31
c0d02ce4:	4315      	orrs	r5, r2
c0d02ce6:	0864      	lsrs	r4, r4, #1
c0d02ce8:	494f      	ldr	r1, [pc, #316]	; (c0d02e28 <__aeabi_dmul+0x39c>)
c0d02cea:	4461      	add	r1, ip
c0d02cec:	2900      	cmp	r1, #0
c0d02cee:	dc00      	bgt.n	c0d02cf2 <__aeabi_dmul+0x266>
c0d02cf0:	e0b0      	b.n	c0d02e54 <__aeabi_dmul+0x3c8>
c0d02cf2:	076b      	lsls	r3, r5, #29
c0d02cf4:	d009      	beq.n	c0d02d0a <__aeabi_dmul+0x27e>
c0d02cf6:	220f      	movs	r2, #15
c0d02cf8:	402a      	ands	r2, r5
c0d02cfa:	2a04      	cmp	r2, #4
c0d02cfc:	d005      	beq.n	c0d02d0a <__aeabi_dmul+0x27e>
c0d02cfe:	1d2a      	adds	r2, r5, #4
c0d02d00:	42aa      	cmp	r2, r5
c0d02d02:	41ad      	sbcs	r5, r5
c0d02d04:	426d      	negs	r5, r5
c0d02d06:	1964      	adds	r4, r4, r5
c0d02d08:	0015      	movs	r5, r2
c0d02d0a:	01e3      	lsls	r3, r4, #7
c0d02d0c:	d504      	bpl.n	c0d02d18 <__aeabi_dmul+0x28c>
c0d02d0e:	2180      	movs	r1, #128	; 0x80
c0d02d10:	4a46      	ldr	r2, [pc, #280]	; (c0d02e2c <__aeabi_dmul+0x3a0>)
c0d02d12:	00c9      	lsls	r1, r1, #3
c0d02d14:	4014      	ands	r4, r2
c0d02d16:	4461      	add	r1, ip
c0d02d18:	4a45      	ldr	r2, [pc, #276]	; (c0d02e30 <__aeabi_dmul+0x3a4>)
c0d02d1a:	4291      	cmp	r1, r2
c0d02d1c:	dd00      	ble.n	c0d02d20 <__aeabi_dmul+0x294>
c0d02d1e:	e724      	b.n	c0d02b6a <__aeabi_dmul+0xde>
c0d02d20:	0762      	lsls	r2, r4, #29
c0d02d22:	08ed      	lsrs	r5, r5, #3
c0d02d24:	0264      	lsls	r4, r4, #9
c0d02d26:	0549      	lsls	r1, r1, #21
c0d02d28:	4315      	orrs	r5, r2
c0d02d2a:	0b24      	lsrs	r4, r4, #12
c0d02d2c:	0d4a      	lsrs	r2, r1, #21
c0d02d2e:	e70e      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02d30:	4652      	mov	r2, sl
c0d02d32:	4332      	orrs	r2, r6
c0d02d34:	d100      	bne.n	c0d02d38 <__aeabi_dmul+0x2ac>
c0d02d36:	e07f      	b.n	c0d02e38 <__aeabi_dmul+0x3ac>
c0d02d38:	2e00      	cmp	r6, #0
c0d02d3a:	d100      	bne.n	c0d02d3e <__aeabi_dmul+0x2b2>
c0d02d3c:	e0dc      	b.n	c0d02ef8 <__aeabi_dmul+0x46c>
c0d02d3e:	0030      	movs	r0, r6
c0d02d40:	f000 fd4e 	bl	c0d037e0 <__clzsi2>
c0d02d44:	0002      	movs	r2, r0
c0d02d46:	3a0b      	subs	r2, #11
c0d02d48:	231d      	movs	r3, #29
c0d02d4a:	0001      	movs	r1, r0
c0d02d4c:	1a9b      	subs	r3, r3, r2
c0d02d4e:	4652      	mov	r2, sl
c0d02d50:	3908      	subs	r1, #8
c0d02d52:	40da      	lsrs	r2, r3
c0d02d54:	408e      	lsls	r6, r1
c0d02d56:	4316      	orrs	r6, r2
c0d02d58:	4652      	mov	r2, sl
c0d02d5a:	408a      	lsls	r2, r1
c0d02d5c:	9b00      	ldr	r3, [sp, #0]
c0d02d5e:	4935      	ldr	r1, [pc, #212]	; (c0d02e34 <__aeabi_dmul+0x3a8>)
c0d02d60:	1a18      	subs	r0, r3, r0
c0d02d62:	0003      	movs	r3, r0
c0d02d64:	468c      	mov	ip, r1
c0d02d66:	4463      	add	r3, ip
c0d02d68:	2000      	movs	r0, #0
c0d02d6a:	9300      	str	r3, [sp, #0]
c0d02d6c:	e6d1      	b.n	c0d02b12 <__aeabi_dmul+0x86>
c0d02d6e:	0025      	movs	r5, r4
c0d02d70:	4305      	orrs	r5, r0
c0d02d72:	d04a      	beq.n	c0d02e0a <__aeabi_dmul+0x37e>
c0d02d74:	2c00      	cmp	r4, #0
c0d02d76:	d100      	bne.n	c0d02d7a <__aeabi_dmul+0x2ee>
c0d02d78:	e0b0      	b.n	c0d02edc <__aeabi_dmul+0x450>
c0d02d7a:	0020      	movs	r0, r4
c0d02d7c:	f000 fd30 	bl	c0d037e0 <__clzsi2>
c0d02d80:	0001      	movs	r1, r0
c0d02d82:	0002      	movs	r2, r0
c0d02d84:	390b      	subs	r1, #11
c0d02d86:	231d      	movs	r3, #29
c0d02d88:	0010      	movs	r0, r2
c0d02d8a:	1a5b      	subs	r3, r3, r1
c0d02d8c:	0031      	movs	r1, r6
c0d02d8e:	0035      	movs	r5, r6
c0d02d90:	3808      	subs	r0, #8
c0d02d92:	4084      	lsls	r4, r0
c0d02d94:	40d9      	lsrs	r1, r3
c0d02d96:	4085      	lsls	r5, r0
c0d02d98:	430c      	orrs	r4, r1
c0d02d9a:	4826      	ldr	r0, [pc, #152]	; (c0d02e34 <__aeabi_dmul+0x3a8>)
c0d02d9c:	1a83      	subs	r3, r0, r2
c0d02d9e:	9300      	str	r3, [sp, #0]
c0d02da0:	2300      	movs	r3, #0
c0d02da2:	4699      	mov	r9, r3
c0d02da4:	469b      	mov	fp, r3
c0d02da6:	e695      	b.n	c0d02ad4 <__aeabi_dmul+0x48>
c0d02da8:	0005      	movs	r5, r0
c0d02daa:	4325      	orrs	r5, r4
c0d02dac:	d126      	bne.n	c0d02dfc <__aeabi_dmul+0x370>
c0d02dae:	2208      	movs	r2, #8
c0d02db0:	9300      	str	r3, [sp, #0]
c0d02db2:	2302      	movs	r3, #2
c0d02db4:	2400      	movs	r4, #0
c0d02db6:	4691      	mov	r9, r2
c0d02db8:	469b      	mov	fp, r3
c0d02dba:	e68b      	b.n	c0d02ad4 <__aeabi_dmul+0x48>
c0d02dbc:	4652      	mov	r2, sl
c0d02dbe:	9b00      	ldr	r3, [sp, #0]
c0d02dc0:	4332      	orrs	r2, r6
c0d02dc2:	d110      	bne.n	c0d02de6 <__aeabi_dmul+0x35a>
c0d02dc4:	4915      	ldr	r1, [pc, #84]	; (c0d02e1c <__aeabi_dmul+0x390>)
c0d02dc6:	2600      	movs	r6, #0
c0d02dc8:	468c      	mov	ip, r1
c0d02dca:	4463      	add	r3, ip
c0d02dcc:	4649      	mov	r1, r9
c0d02dce:	9300      	str	r3, [sp, #0]
c0d02dd0:	2302      	movs	r3, #2
c0d02dd2:	4319      	orrs	r1, r3
c0d02dd4:	4689      	mov	r9, r1
c0d02dd6:	2002      	movs	r0, #2
c0d02dd8:	e69b      	b.n	c0d02b12 <__aeabi_dmul+0x86>
c0d02dda:	465b      	mov	r3, fp
c0d02ddc:	9701      	str	r7, [sp, #4]
c0d02dde:	2b02      	cmp	r3, #2
c0d02de0:	d000      	beq.n	c0d02de4 <__aeabi_dmul+0x358>
c0d02de2:	e6ab      	b.n	c0d02b3c <__aeabi_dmul+0xb0>
c0d02de4:	e6c1      	b.n	c0d02b6a <__aeabi_dmul+0xde>
c0d02de6:	4a0d      	ldr	r2, [pc, #52]	; (c0d02e1c <__aeabi_dmul+0x390>)
c0d02de8:	2003      	movs	r0, #3
c0d02dea:	4694      	mov	ip, r2
c0d02dec:	4463      	add	r3, ip
c0d02dee:	464a      	mov	r2, r9
c0d02df0:	9300      	str	r3, [sp, #0]
c0d02df2:	2303      	movs	r3, #3
c0d02df4:	431a      	orrs	r2, r3
c0d02df6:	4691      	mov	r9, r2
c0d02df8:	4652      	mov	r2, sl
c0d02dfa:	e68a      	b.n	c0d02b12 <__aeabi_dmul+0x86>
c0d02dfc:	220c      	movs	r2, #12
c0d02dfe:	9300      	str	r3, [sp, #0]
c0d02e00:	2303      	movs	r3, #3
c0d02e02:	0005      	movs	r5, r0
c0d02e04:	4691      	mov	r9, r2
c0d02e06:	469b      	mov	fp, r3
c0d02e08:	e664      	b.n	c0d02ad4 <__aeabi_dmul+0x48>
c0d02e0a:	2304      	movs	r3, #4
c0d02e0c:	4699      	mov	r9, r3
c0d02e0e:	2300      	movs	r3, #0
c0d02e10:	9300      	str	r3, [sp, #0]
c0d02e12:	3301      	adds	r3, #1
c0d02e14:	2400      	movs	r4, #0
c0d02e16:	469b      	mov	fp, r3
c0d02e18:	e65c      	b.n	c0d02ad4 <__aeabi_dmul+0x48>
c0d02e1a:	46c0      	nop			; (mov r8, r8)
c0d02e1c:	000007ff 	.word	0x000007ff
c0d02e20:	fffffc01 	.word	0xfffffc01
c0d02e24:	c0d038f8 	.word	0xc0d038f8
c0d02e28:	000003ff 	.word	0x000003ff
c0d02e2c:	feffffff 	.word	0xfeffffff
c0d02e30:	000007fe 	.word	0x000007fe
c0d02e34:	fffffc0d 	.word	0xfffffc0d
c0d02e38:	4649      	mov	r1, r9
c0d02e3a:	2301      	movs	r3, #1
c0d02e3c:	4319      	orrs	r1, r3
c0d02e3e:	4689      	mov	r9, r1
c0d02e40:	2600      	movs	r6, #0
c0d02e42:	2001      	movs	r0, #1
c0d02e44:	e665      	b.n	c0d02b12 <__aeabi_dmul+0x86>
c0d02e46:	2300      	movs	r3, #0
c0d02e48:	2480      	movs	r4, #128	; 0x80
c0d02e4a:	2500      	movs	r5, #0
c0d02e4c:	4a43      	ldr	r2, [pc, #268]	; (c0d02f5c <__aeabi_dmul+0x4d0>)
c0d02e4e:	9301      	str	r3, [sp, #4]
c0d02e50:	0324      	lsls	r4, r4, #12
c0d02e52:	e67c      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02e54:	2001      	movs	r0, #1
c0d02e56:	1a40      	subs	r0, r0, r1
c0d02e58:	2838      	cmp	r0, #56	; 0x38
c0d02e5a:	dd00      	ble.n	c0d02e5e <__aeabi_dmul+0x3d2>
c0d02e5c:	e674      	b.n	c0d02b48 <__aeabi_dmul+0xbc>
c0d02e5e:	281f      	cmp	r0, #31
c0d02e60:	dd5b      	ble.n	c0d02f1a <__aeabi_dmul+0x48e>
c0d02e62:	221f      	movs	r2, #31
c0d02e64:	0023      	movs	r3, r4
c0d02e66:	4252      	negs	r2, r2
c0d02e68:	1a51      	subs	r1, r2, r1
c0d02e6a:	40cb      	lsrs	r3, r1
c0d02e6c:	0019      	movs	r1, r3
c0d02e6e:	2820      	cmp	r0, #32
c0d02e70:	d003      	beq.n	c0d02e7a <__aeabi_dmul+0x3ee>
c0d02e72:	4a3b      	ldr	r2, [pc, #236]	; (c0d02f60 <__aeabi_dmul+0x4d4>)
c0d02e74:	4462      	add	r2, ip
c0d02e76:	4094      	lsls	r4, r2
c0d02e78:	4325      	orrs	r5, r4
c0d02e7a:	1e6a      	subs	r2, r5, #1
c0d02e7c:	4195      	sbcs	r5, r2
c0d02e7e:	002a      	movs	r2, r5
c0d02e80:	430a      	orrs	r2, r1
c0d02e82:	2107      	movs	r1, #7
c0d02e84:	000d      	movs	r5, r1
c0d02e86:	2400      	movs	r4, #0
c0d02e88:	4015      	ands	r5, r2
c0d02e8a:	4211      	tst	r1, r2
c0d02e8c:	d05b      	beq.n	c0d02f46 <__aeabi_dmul+0x4ba>
c0d02e8e:	210f      	movs	r1, #15
c0d02e90:	2400      	movs	r4, #0
c0d02e92:	4011      	ands	r1, r2
c0d02e94:	2904      	cmp	r1, #4
c0d02e96:	d053      	beq.n	c0d02f40 <__aeabi_dmul+0x4b4>
c0d02e98:	1d11      	adds	r1, r2, #4
c0d02e9a:	4291      	cmp	r1, r2
c0d02e9c:	4192      	sbcs	r2, r2
c0d02e9e:	4252      	negs	r2, r2
c0d02ea0:	18a4      	adds	r4, r4, r2
c0d02ea2:	000a      	movs	r2, r1
c0d02ea4:	0223      	lsls	r3, r4, #8
c0d02ea6:	d54b      	bpl.n	c0d02f40 <__aeabi_dmul+0x4b4>
c0d02ea8:	2201      	movs	r2, #1
c0d02eaa:	2400      	movs	r4, #0
c0d02eac:	2500      	movs	r5, #0
c0d02eae:	e64e      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02eb0:	2380      	movs	r3, #128	; 0x80
c0d02eb2:	031b      	lsls	r3, r3, #12
c0d02eb4:	421c      	tst	r4, r3
c0d02eb6:	d009      	beq.n	c0d02ecc <__aeabi_dmul+0x440>
c0d02eb8:	421e      	tst	r6, r3
c0d02eba:	d107      	bne.n	c0d02ecc <__aeabi_dmul+0x440>
c0d02ebc:	4333      	orrs	r3, r6
c0d02ebe:	031c      	lsls	r4, r3, #12
c0d02ec0:	4643      	mov	r3, r8
c0d02ec2:	0015      	movs	r5, r2
c0d02ec4:	0b24      	lsrs	r4, r4, #12
c0d02ec6:	4a25      	ldr	r2, [pc, #148]	; (c0d02f5c <__aeabi_dmul+0x4d0>)
c0d02ec8:	9301      	str	r3, [sp, #4]
c0d02eca:	e640      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02ecc:	2280      	movs	r2, #128	; 0x80
c0d02ece:	0312      	lsls	r2, r2, #12
c0d02ed0:	4314      	orrs	r4, r2
c0d02ed2:	0324      	lsls	r4, r4, #12
c0d02ed4:	4a21      	ldr	r2, [pc, #132]	; (c0d02f5c <__aeabi_dmul+0x4d0>)
c0d02ed6:	0b24      	lsrs	r4, r4, #12
c0d02ed8:	9701      	str	r7, [sp, #4]
c0d02eda:	e638      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02edc:	f000 fc80 	bl	c0d037e0 <__clzsi2>
c0d02ee0:	0001      	movs	r1, r0
c0d02ee2:	0002      	movs	r2, r0
c0d02ee4:	3115      	adds	r1, #21
c0d02ee6:	3220      	adds	r2, #32
c0d02ee8:	291c      	cmp	r1, #28
c0d02eea:	dc00      	bgt.n	c0d02eee <__aeabi_dmul+0x462>
c0d02eec:	e74b      	b.n	c0d02d86 <__aeabi_dmul+0x2fa>
c0d02eee:	0034      	movs	r4, r6
c0d02ef0:	3808      	subs	r0, #8
c0d02ef2:	2500      	movs	r5, #0
c0d02ef4:	4084      	lsls	r4, r0
c0d02ef6:	e750      	b.n	c0d02d9a <__aeabi_dmul+0x30e>
c0d02ef8:	f000 fc72 	bl	c0d037e0 <__clzsi2>
c0d02efc:	0003      	movs	r3, r0
c0d02efe:	001a      	movs	r2, r3
c0d02f00:	3215      	adds	r2, #21
c0d02f02:	3020      	adds	r0, #32
c0d02f04:	2a1c      	cmp	r2, #28
c0d02f06:	dc00      	bgt.n	c0d02f0a <__aeabi_dmul+0x47e>
c0d02f08:	e71e      	b.n	c0d02d48 <__aeabi_dmul+0x2bc>
c0d02f0a:	4656      	mov	r6, sl
c0d02f0c:	3b08      	subs	r3, #8
c0d02f0e:	2200      	movs	r2, #0
c0d02f10:	409e      	lsls	r6, r3
c0d02f12:	e723      	b.n	c0d02d5c <__aeabi_dmul+0x2d0>
c0d02f14:	9b00      	ldr	r3, [sp, #0]
c0d02f16:	469c      	mov	ip, r3
c0d02f18:	e6e6      	b.n	c0d02ce8 <__aeabi_dmul+0x25c>
c0d02f1a:	4912      	ldr	r1, [pc, #72]	; (c0d02f64 <__aeabi_dmul+0x4d8>)
c0d02f1c:	0022      	movs	r2, r4
c0d02f1e:	4461      	add	r1, ip
c0d02f20:	002e      	movs	r6, r5
c0d02f22:	408d      	lsls	r5, r1
c0d02f24:	408a      	lsls	r2, r1
c0d02f26:	40c6      	lsrs	r6, r0
c0d02f28:	1e69      	subs	r1, r5, #1
c0d02f2a:	418d      	sbcs	r5, r1
c0d02f2c:	4332      	orrs	r2, r6
c0d02f2e:	432a      	orrs	r2, r5
c0d02f30:	40c4      	lsrs	r4, r0
c0d02f32:	0753      	lsls	r3, r2, #29
c0d02f34:	d0b6      	beq.n	c0d02ea4 <__aeabi_dmul+0x418>
c0d02f36:	210f      	movs	r1, #15
c0d02f38:	4011      	ands	r1, r2
c0d02f3a:	2904      	cmp	r1, #4
c0d02f3c:	d1ac      	bne.n	c0d02e98 <__aeabi_dmul+0x40c>
c0d02f3e:	e7b1      	b.n	c0d02ea4 <__aeabi_dmul+0x418>
c0d02f40:	0765      	lsls	r5, r4, #29
c0d02f42:	0264      	lsls	r4, r4, #9
c0d02f44:	0b24      	lsrs	r4, r4, #12
c0d02f46:	08d2      	lsrs	r2, r2, #3
c0d02f48:	4315      	orrs	r5, r2
c0d02f4a:	2200      	movs	r2, #0
c0d02f4c:	e5ff      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02f4e:	2280      	movs	r2, #128	; 0x80
c0d02f50:	0312      	lsls	r2, r2, #12
c0d02f52:	4314      	orrs	r4, r2
c0d02f54:	0324      	lsls	r4, r4, #12
c0d02f56:	4a01      	ldr	r2, [pc, #4]	; (c0d02f5c <__aeabi_dmul+0x4d0>)
c0d02f58:	0b24      	lsrs	r4, r4, #12
c0d02f5a:	e5f8      	b.n	c0d02b4e <__aeabi_dmul+0xc2>
c0d02f5c:	000007ff 	.word	0x000007ff
c0d02f60:	0000043e 	.word	0x0000043e
c0d02f64:	0000041e 	.word	0x0000041e

c0d02f68 <__aeabi_dsub>:
c0d02f68:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
c0d02f6a:	4657      	mov	r7, sl
c0d02f6c:	464e      	mov	r6, r9
c0d02f6e:	4645      	mov	r5, r8
c0d02f70:	46de      	mov	lr, fp
c0d02f72:	b5e0      	push	{r5, r6, r7, lr}
c0d02f74:	001e      	movs	r6, r3
c0d02f76:	0017      	movs	r7, r2
c0d02f78:	004a      	lsls	r2, r1, #1
c0d02f7a:	030b      	lsls	r3, r1, #12
c0d02f7c:	0d52      	lsrs	r2, r2, #21
c0d02f7e:	0a5b      	lsrs	r3, r3, #9
c0d02f80:	4690      	mov	r8, r2
c0d02f82:	0f42      	lsrs	r2, r0, #29
c0d02f84:	431a      	orrs	r2, r3
c0d02f86:	0fcd      	lsrs	r5, r1, #31
c0d02f88:	4ccd      	ldr	r4, [pc, #820]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d02f8a:	0331      	lsls	r1, r6, #12
c0d02f8c:	00c3      	lsls	r3, r0, #3
c0d02f8e:	4694      	mov	ip, r2
c0d02f90:	0070      	lsls	r0, r6, #1
c0d02f92:	0f7a      	lsrs	r2, r7, #29
c0d02f94:	0a49      	lsrs	r1, r1, #9
c0d02f96:	00ff      	lsls	r7, r7, #3
c0d02f98:	469a      	mov	sl, r3
c0d02f9a:	46b9      	mov	r9, r7
c0d02f9c:	0d40      	lsrs	r0, r0, #21
c0d02f9e:	0ff6      	lsrs	r6, r6, #31
c0d02fa0:	4311      	orrs	r1, r2
c0d02fa2:	42a0      	cmp	r0, r4
c0d02fa4:	d100      	bne.n	c0d02fa8 <__aeabi_dsub+0x40>
c0d02fa6:	e0b1      	b.n	c0d0310c <__aeabi_dsub+0x1a4>
c0d02fa8:	2201      	movs	r2, #1
c0d02faa:	4056      	eors	r6, r2
c0d02fac:	46b3      	mov	fp, r6
c0d02fae:	42b5      	cmp	r5, r6
c0d02fb0:	d100      	bne.n	c0d02fb4 <__aeabi_dsub+0x4c>
c0d02fb2:	e088      	b.n	c0d030c6 <__aeabi_dsub+0x15e>
c0d02fb4:	4642      	mov	r2, r8
c0d02fb6:	1a12      	subs	r2, r2, r0
c0d02fb8:	2a00      	cmp	r2, #0
c0d02fba:	dc00      	bgt.n	c0d02fbe <__aeabi_dsub+0x56>
c0d02fbc:	e0ae      	b.n	c0d0311c <__aeabi_dsub+0x1b4>
c0d02fbe:	2800      	cmp	r0, #0
c0d02fc0:	d100      	bne.n	c0d02fc4 <__aeabi_dsub+0x5c>
c0d02fc2:	e0c1      	b.n	c0d03148 <__aeabi_dsub+0x1e0>
c0d02fc4:	48be      	ldr	r0, [pc, #760]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d02fc6:	4580      	cmp	r8, r0
c0d02fc8:	d100      	bne.n	c0d02fcc <__aeabi_dsub+0x64>
c0d02fca:	e151      	b.n	c0d03270 <__aeabi_dsub+0x308>
c0d02fcc:	2080      	movs	r0, #128	; 0x80
c0d02fce:	0400      	lsls	r0, r0, #16
c0d02fd0:	4301      	orrs	r1, r0
c0d02fd2:	2a38      	cmp	r2, #56	; 0x38
c0d02fd4:	dd00      	ble.n	c0d02fd8 <__aeabi_dsub+0x70>
c0d02fd6:	e17b      	b.n	c0d032d0 <__aeabi_dsub+0x368>
c0d02fd8:	2a1f      	cmp	r2, #31
c0d02fda:	dd00      	ble.n	c0d02fde <__aeabi_dsub+0x76>
c0d02fdc:	e1ee      	b.n	c0d033bc <__aeabi_dsub+0x454>
c0d02fde:	2020      	movs	r0, #32
c0d02fe0:	003e      	movs	r6, r7
c0d02fe2:	1a80      	subs	r0, r0, r2
c0d02fe4:	000c      	movs	r4, r1
c0d02fe6:	40d6      	lsrs	r6, r2
c0d02fe8:	40d1      	lsrs	r1, r2
c0d02fea:	4087      	lsls	r7, r0
c0d02fec:	4662      	mov	r2, ip
c0d02fee:	4084      	lsls	r4, r0
c0d02ff0:	1a52      	subs	r2, r2, r1
c0d02ff2:	1e78      	subs	r0, r7, #1
c0d02ff4:	4187      	sbcs	r7, r0
c0d02ff6:	4694      	mov	ip, r2
c0d02ff8:	4334      	orrs	r4, r6
c0d02ffa:	4327      	orrs	r7, r4
c0d02ffc:	1bdc      	subs	r4, r3, r7
c0d02ffe:	42a3      	cmp	r3, r4
c0d03000:	419b      	sbcs	r3, r3
c0d03002:	4662      	mov	r2, ip
c0d03004:	425b      	negs	r3, r3
c0d03006:	1ad3      	subs	r3, r2, r3
c0d03008:	4699      	mov	r9, r3
c0d0300a:	464b      	mov	r3, r9
c0d0300c:	021b      	lsls	r3, r3, #8
c0d0300e:	d400      	bmi.n	c0d03012 <__aeabi_dsub+0xaa>
c0d03010:	e118      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d03012:	464b      	mov	r3, r9
c0d03014:	0258      	lsls	r0, r3, #9
c0d03016:	0a43      	lsrs	r3, r0, #9
c0d03018:	4699      	mov	r9, r3
c0d0301a:	464b      	mov	r3, r9
c0d0301c:	2b00      	cmp	r3, #0
c0d0301e:	d100      	bne.n	c0d03022 <__aeabi_dsub+0xba>
c0d03020:	e137      	b.n	c0d03292 <__aeabi_dsub+0x32a>
c0d03022:	4648      	mov	r0, r9
c0d03024:	f000 fbdc 	bl	c0d037e0 <__clzsi2>
c0d03028:	0001      	movs	r1, r0
c0d0302a:	3908      	subs	r1, #8
c0d0302c:	2320      	movs	r3, #32
c0d0302e:	0022      	movs	r2, r4
c0d03030:	4648      	mov	r0, r9
c0d03032:	1a5b      	subs	r3, r3, r1
c0d03034:	40da      	lsrs	r2, r3
c0d03036:	4088      	lsls	r0, r1
c0d03038:	408c      	lsls	r4, r1
c0d0303a:	4643      	mov	r3, r8
c0d0303c:	4310      	orrs	r0, r2
c0d0303e:	4588      	cmp	r8, r1
c0d03040:	dd00      	ble.n	c0d03044 <__aeabi_dsub+0xdc>
c0d03042:	e136      	b.n	c0d032b2 <__aeabi_dsub+0x34a>
c0d03044:	1ac9      	subs	r1, r1, r3
c0d03046:	1c4b      	adds	r3, r1, #1
c0d03048:	2b1f      	cmp	r3, #31
c0d0304a:	dd00      	ble.n	c0d0304e <__aeabi_dsub+0xe6>
c0d0304c:	e0ea      	b.n	c0d03224 <__aeabi_dsub+0x2bc>
c0d0304e:	2220      	movs	r2, #32
c0d03050:	0026      	movs	r6, r4
c0d03052:	1ad2      	subs	r2, r2, r3
c0d03054:	0001      	movs	r1, r0
c0d03056:	4094      	lsls	r4, r2
c0d03058:	40de      	lsrs	r6, r3
c0d0305a:	40d8      	lsrs	r0, r3
c0d0305c:	2300      	movs	r3, #0
c0d0305e:	4091      	lsls	r1, r2
c0d03060:	1e62      	subs	r2, r4, #1
c0d03062:	4194      	sbcs	r4, r2
c0d03064:	4681      	mov	r9, r0
c0d03066:	4698      	mov	r8, r3
c0d03068:	4331      	orrs	r1, r6
c0d0306a:	430c      	orrs	r4, r1
c0d0306c:	0763      	lsls	r3, r4, #29
c0d0306e:	d009      	beq.n	c0d03084 <__aeabi_dsub+0x11c>
c0d03070:	230f      	movs	r3, #15
c0d03072:	4023      	ands	r3, r4
c0d03074:	2b04      	cmp	r3, #4
c0d03076:	d005      	beq.n	c0d03084 <__aeabi_dsub+0x11c>
c0d03078:	1d23      	adds	r3, r4, #4
c0d0307a:	42a3      	cmp	r3, r4
c0d0307c:	41a4      	sbcs	r4, r4
c0d0307e:	4264      	negs	r4, r4
c0d03080:	44a1      	add	r9, r4
c0d03082:	001c      	movs	r4, r3
c0d03084:	464b      	mov	r3, r9
c0d03086:	021b      	lsls	r3, r3, #8
c0d03088:	d400      	bmi.n	c0d0308c <__aeabi_dsub+0x124>
c0d0308a:	e0de      	b.n	c0d0324a <__aeabi_dsub+0x2e2>
c0d0308c:	4641      	mov	r1, r8
c0d0308e:	4b8c      	ldr	r3, [pc, #560]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d03090:	3101      	adds	r1, #1
c0d03092:	4299      	cmp	r1, r3
c0d03094:	d100      	bne.n	c0d03098 <__aeabi_dsub+0x130>
c0d03096:	e0e7      	b.n	c0d03268 <__aeabi_dsub+0x300>
c0d03098:	464b      	mov	r3, r9
c0d0309a:	488a      	ldr	r0, [pc, #552]	; (c0d032c4 <__aeabi_dsub+0x35c>)
c0d0309c:	08e4      	lsrs	r4, r4, #3
c0d0309e:	4003      	ands	r3, r0
c0d030a0:	0018      	movs	r0, r3
c0d030a2:	0549      	lsls	r1, r1, #21
c0d030a4:	075b      	lsls	r3, r3, #29
c0d030a6:	0240      	lsls	r0, r0, #9
c0d030a8:	4323      	orrs	r3, r4
c0d030aa:	0d4a      	lsrs	r2, r1, #21
c0d030ac:	0b04      	lsrs	r4, r0, #12
c0d030ae:	0512      	lsls	r2, r2, #20
c0d030b0:	07ed      	lsls	r5, r5, #31
c0d030b2:	4322      	orrs	r2, r4
c0d030b4:	432a      	orrs	r2, r5
c0d030b6:	0018      	movs	r0, r3
c0d030b8:	0011      	movs	r1, r2
c0d030ba:	bcf0      	pop	{r4, r5, r6, r7}
c0d030bc:	46bb      	mov	fp, r7
c0d030be:	46b2      	mov	sl, r6
c0d030c0:	46a9      	mov	r9, r5
c0d030c2:	46a0      	mov	r8, r4
c0d030c4:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
c0d030c6:	4642      	mov	r2, r8
c0d030c8:	1a12      	subs	r2, r2, r0
c0d030ca:	2a00      	cmp	r2, #0
c0d030cc:	dd52      	ble.n	c0d03174 <__aeabi_dsub+0x20c>
c0d030ce:	2800      	cmp	r0, #0
c0d030d0:	d100      	bne.n	c0d030d4 <__aeabi_dsub+0x16c>
c0d030d2:	e09c      	b.n	c0d0320e <__aeabi_dsub+0x2a6>
c0d030d4:	45a0      	cmp	r8, r4
c0d030d6:	d100      	bne.n	c0d030da <__aeabi_dsub+0x172>
c0d030d8:	e0ca      	b.n	c0d03270 <__aeabi_dsub+0x308>
c0d030da:	2080      	movs	r0, #128	; 0x80
c0d030dc:	0400      	lsls	r0, r0, #16
c0d030de:	4301      	orrs	r1, r0
c0d030e0:	2a38      	cmp	r2, #56	; 0x38
c0d030e2:	dd00      	ble.n	c0d030e6 <__aeabi_dsub+0x17e>
c0d030e4:	e149      	b.n	c0d0337a <__aeabi_dsub+0x412>
c0d030e6:	2a1f      	cmp	r2, #31
c0d030e8:	dc00      	bgt.n	c0d030ec <__aeabi_dsub+0x184>
c0d030ea:	e197      	b.n	c0d0341c <__aeabi_dsub+0x4b4>
c0d030ec:	0010      	movs	r0, r2
c0d030ee:	000e      	movs	r6, r1
c0d030f0:	3820      	subs	r0, #32
c0d030f2:	40c6      	lsrs	r6, r0
c0d030f4:	2a20      	cmp	r2, #32
c0d030f6:	d004      	beq.n	c0d03102 <__aeabi_dsub+0x19a>
c0d030f8:	2040      	movs	r0, #64	; 0x40
c0d030fa:	1a82      	subs	r2, r0, r2
c0d030fc:	4091      	lsls	r1, r2
c0d030fe:	430f      	orrs	r7, r1
c0d03100:	46b9      	mov	r9, r7
c0d03102:	464c      	mov	r4, r9
c0d03104:	1e62      	subs	r2, r4, #1
c0d03106:	4194      	sbcs	r4, r2
c0d03108:	4334      	orrs	r4, r6
c0d0310a:	e13a      	b.n	c0d03382 <__aeabi_dsub+0x41a>
c0d0310c:	000a      	movs	r2, r1
c0d0310e:	433a      	orrs	r2, r7
c0d03110:	d028      	beq.n	c0d03164 <__aeabi_dsub+0x1fc>
c0d03112:	46b3      	mov	fp, r6
c0d03114:	42b5      	cmp	r5, r6
c0d03116:	d02b      	beq.n	c0d03170 <__aeabi_dsub+0x208>
c0d03118:	4a6b      	ldr	r2, [pc, #428]	; (c0d032c8 <__aeabi_dsub+0x360>)
c0d0311a:	4442      	add	r2, r8
c0d0311c:	2a00      	cmp	r2, #0
c0d0311e:	d05d      	beq.n	c0d031dc <__aeabi_dsub+0x274>
c0d03120:	4642      	mov	r2, r8
c0d03122:	4644      	mov	r4, r8
c0d03124:	1a82      	subs	r2, r0, r2
c0d03126:	2c00      	cmp	r4, #0
c0d03128:	d000      	beq.n	c0d0312c <__aeabi_dsub+0x1c4>
c0d0312a:	e0f5      	b.n	c0d03318 <__aeabi_dsub+0x3b0>
c0d0312c:	4665      	mov	r5, ip
c0d0312e:	431d      	orrs	r5, r3
c0d03130:	d100      	bne.n	c0d03134 <__aeabi_dsub+0x1cc>
c0d03132:	e19c      	b.n	c0d0346e <__aeabi_dsub+0x506>
c0d03134:	1e55      	subs	r5, r2, #1
c0d03136:	2a01      	cmp	r2, #1
c0d03138:	d100      	bne.n	c0d0313c <__aeabi_dsub+0x1d4>
c0d0313a:	e1fb      	b.n	c0d03534 <__aeabi_dsub+0x5cc>
c0d0313c:	4c60      	ldr	r4, [pc, #384]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d0313e:	42a2      	cmp	r2, r4
c0d03140:	d100      	bne.n	c0d03144 <__aeabi_dsub+0x1dc>
c0d03142:	e1bd      	b.n	c0d034c0 <__aeabi_dsub+0x558>
c0d03144:	002a      	movs	r2, r5
c0d03146:	e0f0      	b.n	c0d0332a <__aeabi_dsub+0x3c2>
c0d03148:	0008      	movs	r0, r1
c0d0314a:	4338      	orrs	r0, r7
c0d0314c:	d100      	bne.n	c0d03150 <__aeabi_dsub+0x1e8>
c0d0314e:	e0c3      	b.n	c0d032d8 <__aeabi_dsub+0x370>
c0d03150:	1e50      	subs	r0, r2, #1
c0d03152:	2a01      	cmp	r2, #1
c0d03154:	d100      	bne.n	c0d03158 <__aeabi_dsub+0x1f0>
c0d03156:	e1a8      	b.n	c0d034aa <__aeabi_dsub+0x542>
c0d03158:	4c59      	ldr	r4, [pc, #356]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d0315a:	42a2      	cmp	r2, r4
c0d0315c:	d100      	bne.n	c0d03160 <__aeabi_dsub+0x1f8>
c0d0315e:	e087      	b.n	c0d03270 <__aeabi_dsub+0x308>
c0d03160:	0002      	movs	r2, r0
c0d03162:	e736      	b.n	c0d02fd2 <__aeabi_dsub+0x6a>
c0d03164:	2201      	movs	r2, #1
c0d03166:	4056      	eors	r6, r2
c0d03168:	46b3      	mov	fp, r6
c0d0316a:	42b5      	cmp	r5, r6
c0d0316c:	d000      	beq.n	c0d03170 <__aeabi_dsub+0x208>
c0d0316e:	e721      	b.n	c0d02fb4 <__aeabi_dsub+0x4c>
c0d03170:	4a55      	ldr	r2, [pc, #340]	; (c0d032c8 <__aeabi_dsub+0x360>)
c0d03172:	4442      	add	r2, r8
c0d03174:	2a00      	cmp	r2, #0
c0d03176:	d100      	bne.n	c0d0317a <__aeabi_dsub+0x212>
c0d03178:	e0b5      	b.n	c0d032e6 <__aeabi_dsub+0x37e>
c0d0317a:	4642      	mov	r2, r8
c0d0317c:	4644      	mov	r4, r8
c0d0317e:	1a82      	subs	r2, r0, r2
c0d03180:	2c00      	cmp	r4, #0
c0d03182:	d100      	bne.n	c0d03186 <__aeabi_dsub+0x21e>
c0d03184:	e138      	b.n	c0d033f8 <__aeabi_dsub+0x490>
c0d03186:	4e4e      	ldr	r6, [pc, #312]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d03188:	42b0      	cmp	r0, r6
c0d0318a:	d100      	bne.n	c0d0318e <__aeabi_dsub+0x226>
c0d0318c:	e1de      	b.n	c0d0354c <__aeabi_dsub+0x5e4>
c0d0318e:	2680      	movs	r6, #128	; 0x80
c0d03190:	4664      	mov	r4, ip
c0d03192:	0436      	lsls	r6, r6, #16
c0d03194:	4334      	orrs	r4, r6
c0d03196:	46a4      	mov	ip, r4
c0d03198:	2a38      	cmp	r2, #56	; 0x38
c0d0319a:	dd00      	ble.n	c0d0319e <__aeabi_dsub+0x236>
c0d0319c:	e196      	b.n	c0d034cc <__aeabi_dsub+0x564>
c0d0319e:	2a1f      	cmp	r2, #31
c0d031a0:	dd00      	ble.n	c0d031a4 <__aeabi_dsub+0x23c>
c0d031a2:	e224      	b.n	c0d035ee <__aeabi_dsub+0x686>
c0d031a4:	2620      	movs	r6, #32
c0d031a6:	1ab4      	subs	r4, r6, r2
c0d031a8:	46a2      	mov	sl, r4
c0d031aa:	4664      	mov	r4, ip
c0d031ac:	4656      	mov	r6, sl
c0d031ae:	40b4      	lsls	r4, r6
c0d031b0:	46a1      	mov	r9, r4
c0d031b2:	001c      	movs	r4, r3
c0d031b4:	464e      	mov	r6, r9
c0d031b6:	40d4      	lsrs	r4, r2
c0d031b8:	4326      	orrs	r6, r4
c0d031ba:	0034      	movs	r4, r6
c0d031bc:	4656      	mov	r6, sl
c0d031be:	40b3      	lsls	r3, r6
c0d031c0:	1e5e      	subs	r6, r3, #1
c0d031c2:	41b3      	sbcs	r3, r6
c0d031c4:	431c      	orrs	r4, r3
c0d031c6:	4663      	mov	r3, ip
c0d031c8:	40d3      	lsrs	r3, r2
c0d031ca:	18c9      	adds	r1, r1, r3
c0d031cc:	19e4      	adds	r4, r4, r7
c0d031ce:	42bc      	cmp	r4, r7
c0d031d0:	41bf      	sbcs	r7, r7
c0d031d2:	427f      	negs	r7, r7
c0d031d4:	46b9      	mov	r9, r7
c0d031d6:	4680      	mov	r8, r0
c0d031d8:	4489      	add	r9, r1
c0d031da:	e0d8      	b.n	c0d0338e <__aeabi_dsub+0x426>
c0d031dc:	4640      	mov	r0, r8
c0d031de:	4c3b      	ldr	r4, [pc, #236]	; (c0d032cc <__aeabi_dsub+0x364>)
c0d031e0:	3001      	adds	r0, #1
c0d031e2:	4220      	tst	r0, r4
c0d031e4:	d000      	beq.n	c0d031e8 <__aeabi_dsub+0x280>
c0d031e6:	e0b4      	b.n	c0d03352 <__aeabi_dsub+0x3ea>
c0d031e8:	4640      	mov	r0, r8
c0d031ea:	2800      	cmp	r0, #0
c0d031ec:	d000      	beq.n	c0d031f0 <__aeabi_dsub+0x288>
c0d031ee:	e144      	b.n	c0d0347a <__aeabi_dsub+0x512>
c0d031f0:	4660      	mov	r0, ip
c0d031f2:	4318      	orrs	r0, r3
c0d031f4:	d100      	bne.n	c0d031f8 <__aeabi_dsub+0x290>
c0d031f6:	e190      	b.n	c0d0351a <__aeabi_dsub+0x5b2>
c0d031f8:	0008      	movs	r0, r1
c0d031fa:	4338      	orrs	r0, r7
c0d031fc:	d000      	beq.n	c0d03200 <__aeabi_dsub+0x298>
c0d031fe:	e1aa      	b.n	c0d03556 <__aeabi_dsub+0x5ee>
c0d03200:	4661      	mov	r1, ip
c0d03202:	08db      	lsrs	r3, r3, #3
c0d03204:	0749      	lsls	r1, r1, #29
c0d03206:	430b      	orrs	r3, r1
c0d03208:	4661      	mov	r1, ip
c0d0320a:	08cc      	lsrs	r4, r1, #3
c0d0320c:	e027      	b.n	c0d0325e <__aeabi_dsub+0x2f6>
c0d0320e:	0008      	movs	r0, r1
c0d03210:	4338      	orrs	r0, r7
c0d03212:	d061      	beq.n	c0d032d8 <__aeabi_dsub+0x370>
c0d03214:	1e50      	subs	r0, r2, #1
c0d03216:	2a01      	cmp	r2, #1
c0d03218:	d100      	bne.n	c0d0321c <__aeabi_dsub+0x2b4>
c0d0321a:	e139      	b.n	c0d03490 <__aeabi_dsub+0x528>
c0d0321c:	42a2      	cmp	r2, r4
c0d0321e:	d027      	beq.n	c0d03270 <__aeabi_dsub+0x308>
c0d03220:	0002      	movs	r2, r0
c0d03222:	e75d      	b.n	c0d030e0 <__aeabi_dsub+0x178>
c0d03224:	0002      	movs	r2, r0
c0d03226:	391f      	subs	r1, #31
c0d03228:	40ca      	lsrs	r2, r1
c0d0322a:	0011      	movs	r1, r2
c0d0322c:	2b20      	cmp	r3, #32
c0d0322e:	d003      	beq.n	c0d03238 <__aeabi_dsub+0x2d0>
c0d03230:	2240      	movs	r2, #64	; 0x40
c0d03232:	1ad3      	subs	r3, r2, r3
c0d03234:	4098      	lsls	r0, r3
c0d03236:	4304      	orrs	r4, r0
c0d03238:	1e63      	subs	r3, r4, #1
c0d0323a:	419c      	sbcs	r4, r3
c0d0323c:	2300      	movs	r3, #0
c0d0323e:	4699      	mov	r9, r3
c0d03240:	4698      	mov	r8, r3
c0d03242:	430c      	orrs	r4, r1
c0d03244:	0763      	lsls	r3, r4, #29
c0d03246:	d000      	beq.n	c0d0324a <__aeabi_dsub+0x2e2>
c0d03248:	e712      	b.n	c0d03070 <__aeabi_dsub+0x108>
c0d0324a:	464b      	mov	r3, r9
c0d0324c:	464a      	mov	r2, r9
c0d0324e:	08e4      	lsrs	r4, r4, #3
c0d03250:	075b      	lsls	r3, r3, #29
c0d03252:	4323      	orrs	r3, r4
c0d03254:	08d4      	lsrs	r4, r2, #3
c0d03256:	4642      	mov	r2, r8
c0d03258:	4919      	ldr	r1, [pc, #100]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d0325a:	428a      	cmp	r2, r1
c0d0325c:	d00e      	beq.n	c0d0327c <__aeabi_dsub+0x314>
c0d0325e:	0324      	lsls	r4, r4, #12
c0d03260:	0552      	lsls	r2, r2, #21
c0d03262:	0b24      	lsrs	r4, r4, #12
c0d03264:	0d52      	lsrs	r2, r2, #21
c0d03266:	e722      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d03268:	000a      	movs	r2, r1
c0d0326a:	2400      	movs	r4, #0
c0d0326c:	2300      	movs	r3, #0
c0d0326e:	e71e      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d03270:	08db      	lsrs	r3, r3, #3
c0d03272:	4662      	mov	r2, ip
c0d03274:	0752      	lsls	r2, r2, #29
c0d03276:	4313      	orrs	r3, r2
c0d03278:	4662      	mov	r2, ip
c0d0327a:	08d4      	lsrs	r4, r2, #3
c0d0327c:	001a      	movs	r2, r3
c0d0327e:	4322      	orrs	r2, r4
c0d03280:	d100      	bne.n	c0d03284 <__aeabi_dsub+0x31c>
c0d03282:	e1fc      	b.n	c0d0367e <__aeabi_dsub+0x716>
c0d03284:	2280      	movs	r2, #128	; 0x80
c0d03286:	0312      	lsls	r2, r2, #12
c0d03288:	4314      	orrs	r4, r2
c0d0328a:	0324      	lsls	r4, r4, #12
c0d0328c:	4a0c      	ldr	r2, [pc, #48]	; (c0d032c0 <__aeabi_dsub+0x358>)
c0d0328e:	0b24      	lsrs	r4, r4, #12
c0d03290:	e70d      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d03292:	0020      	movs	r0, r4
c0d03294:	f000 faa4 	bl	c0d037e0 <__clzsi2>
c0d03298:	0001      	movs	r1, r0
c0d0329a:	3118      	adds	r1, #24
c0d0329c:	291f      	cmp	r1, #31
c0d0329e:	dc00      	bgt.n	c0d032a2 <__aeabi_dsub+0x33a>
c0d032a0:	e6c4      	b.n	c0d0302c <__aeabi_dsub+0xc4>
c0d032a2:	3808      	subs	r0, #8
c0d032a4:	4084      	lsls	r4, r0
c0d032a6:	4643      	mov	r3, r8
c0d032a8:	0020      	movs	r0, r4
c0d032aa:	2400      	movs	r4, #0
c0d032ac:	4588      	cmp	r8, r1
c0d032ae:	dc00      	bgt.n	c0d032b2 <__aeabi_dsub+0x34a>
c0d032b0:	e6c8      	b.n	c0d03044 <__aeabi_dsub+0xdc>
c0d032b2:	4a04      	ldr	r2, [pc, #16]	; (c0d032c4 <__aeabi_dsub+0x35c>)
c0d032b4:	1a5b      	subs	r3, r3, r1
c0d032b6:	4010      	ands	r0, r2
c0d032b8:	4698      	mov	r8, r3
c0d032ba:	4681      	mov	r9, r0
c0d032bc:	e6d6      	b.n	c0d0306c <__aeabi_dsub+0x104>
c0d032be:	46c0      	nop			; (mov r8, r8)
c0d032c0:	000007ff 	.word	0x000007ff
c0d032c4:	ff7fffff 	.word	0xff7fffff
c0d032c8:	fffff801 	.word	0xfffff801
c0d032cc:	000007fe 	.word	0x000007fe
c0d032d0:	430f      	orrs	r7, r1
c0d032d2:	1e7a      	subs	r2, r7, #1
c0d032d4:	4197      	sbcs	r7, r2
c0d032d6:	e691      	b.n	c0d02ffc <__aeabi_dsub+0x94>
c0d032d8:	4661      	mov	r1, ip
c0d032da:	08db      	lsrs	r3, r3, #3
c0d032dc:	0749      	lsls	r1, r1, #29
c0d032de:	430b      	orrs	r3, r1
c0d032e0:	4661      	mov	r1, ip
c0d032e2:	08cc      	lsrs	r4, r1, #3
c0d032e4:	e7b8      	b.n	c0d03258 <__aeabi_dsub+0x2f0>
c0d032e6:	4640      	mov	r0, r8
c0d032e8:	4cd3      	ldr	r4, [pc, #844]	; (c0d03638 <__aeabi_dsub+0x6d0>)
c0d032ea:	3001      	adds	r0, #1
c0d032ec:	4220      	tst	r0, r4
c0d032ee:	d000      	beq.n	c0d032f2 <__aeabi_dsub+0x38a>
c0d032f0:	e0a2      	b.n	c0d03438 <__aeabi_dsub+0x4d0>
c0d032f2:	4640      	mov	r0, r8
c0d032f4:	2800      	cmp	r0, #0
c0d032f6:	d000      	beq.n	c0d032fa <__aeabi_dsub+0x392>
c0d032f8:	e101      	b.n	c0d034fe <__aeabi_dsub+0x596>
c0d032fa:	4660      	mov	r0, ip
c0d032fc:	4318      	orrs	r0, r3
c0d032fe:	d100      	bne.n	c0d03302 <__aeabi_dsub+0x39a>
c0d03300:	e15e      	b.n	c0d035c0 <__aeabi_dsub+0x658>
c0d03302:	0008      	movs	r0, r1
c0d03304:	4338      	orrs	r0, r7
c0d03306:	d000      	beq.n	c0d0330a <__aeabi_dsub+0x3a2>
c0d03308:	e15f      	b.n	c0d035ca <__aeabi_dsub+0x662>
c0d0330a:	4661      	mov	r1, ip
c0d0330c:	08db      	lsrs	r3, r3, #3
c0d0330e:	0749      	lsls	r1, r1, #29
c0d03310:	430b      	orrs	r3, r1
c0d03312:	4661      	mov	r1, ip
c0d03314:	08cc      	lsrs	r4, r1, #3
c0d03316:	e7a2      	b.n	c0d0325e <__aeabi_dsub+0x2f6>
c0d03318:	4dc8      	ldr	r5, [pc, #800]	; (c0d0363c <__aeabi_dsub+0x6d4>)
c0d0331a:	42a8      	cmp	r0, r5
c0d0331c:	d100      	bne.n	c0d03320 <__aeabi_dsub+0x3b8>
c0d0331e:	e0cf      	b.n	c0d034c0 <__aeabi_dsub+0x558>
c0d03320:	2580      	movs	r5, #128	; 0x80
c0d03322:	4664      	mov	r4, ip
c0d03324:	042d      	lsls	r5, r5, #16
c0d03326:	432c      	orrs	r4, r5
c0d03328:	46a4      	mov	ip, r4
c0d0332a:	2a38      	cmp	r2, #56	; 0x38
c0d0332c:	dc56      	bgt.n	c0d033dc <__aeabi_dsub+0x474>
c0d0332e:	2a1f      	cmp	r2, #31
c0d03330:	dd00      	ble.n	c0d03334 <__aeabi_dsub+0x3cc>
c0d03332:	e0d1      	b.n	c0d034d8 <__aeabi_dsub+0x570>
c0d03334:	2520      	movs	r5, #32
c0d03336:	001e      	movs	r6, r3
c0d03338:	1aad      	subs	r5, r5, r2
c0d0333a:	4664      	mov	r4, ip
c0d0333c:	40ab      	lsls	r3, r5
c0d0333e:	40ac      	lsls	r4, r5
c0d03340:	40d6      	lsrs	r6, r2
c0d03342:	1e5d      	subs	r5, r3, #1
c0d03344:	41ab      	sbcs	r3, r5
c0d03346:	4334      	orrs	r4, r6
c0d03348:	4323      	orrs	r3, r4
c0d0334a:	4664      	mov	r4, ip
c0d0334c:	40d4      	lsrs	r4, r2
c0d0334e:	1b09      	subs	r1, r1, r4
c0d03350:	e049      	b.n	c0d033e6 <__aeabi_dsub+0x47e>
c0d03352:	4660      	mov	r0, ip
c0d03354:	1bdc      	subs	r4, r3, r7
c0d03356:	1a46      	subs	r6, r0, r1
c0d03358:	42a3      	cmp	r3, r4
c0d0335a:	4180      	sbcs	r0, r0
c0d0335c:	4240      	negs	r0, r0
c0d0335e:	4681      	mov	r9, r0
c0d03360:	0030      	movs	r0, r6
c0d03362:	464e      	mov	r6, r9
c0d03364:	1b80      	subs	r0, r0, r6
c0d03366:	4681      	mov	r9, r0
c0d03368:	0200      	lsls	r0, r0, #8
c0d0336a:	d476      	bmi.n	c0d0345a <__aeabi_dsub+0x4f2>
c0d0336c:	464b      	mov	r3, r9
c0d0336e:	4323      	orrs	r3, r4
c0d03370:	d000      	beq.n	c0d03374 <__aeabi_dsub+0x40c>
c0d03372:	e652      	b.n	c0d0301a <__aeabi_dsub+0xb2>
c0d03374:	2400      	movs	r4, #0
c0d03376:	2500      	movs	r5, #0
c0d03378:	e771      	b.n	c0d0325e <__aeabi_dsub+0x2f6>
c0d0337a:	4339      	orrs	r1, r7
c0d0337c:	000c      	movs	r4, r1
c0d0337e:	1e62      	subs	r2, r4, #1
c0d03380:	4194      	sbcs	r4, r2
c0d03382:	18e4      	adds	r4, r4, r3
c0d03384:	429c      	cmp	r4, r3
c0d03386:	419b      	sbcs	r3, r3
c0d03388:	425b      	negs	r3, r3
c0d0338a:	4463      	add	r3, ip
c0d0338c:	4699      	mov	r9, r3
c0d0338e:	464b      	mov	r3, r9
c0d03390:	021b      	lsls	r3, r3, #8
c0d03392:	d400      	bmi.n	c0d03396 <__aeabi_dsub+0x42e>
c0d03394:	e756      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d03396:	2301      	movs	r3, #1
c0d03398:	469c      	mov	ip, r3
c0d0339a:	4ba8      	ldr	r3, [pc, #672]	; (c0d0363c <__aeabi_dsub+0x6d4>)
c0d0339c:	44e0      	add	r8, ip
c0d0339e:	4598      	cmp	r8, r3
c0d033a0:	d038      	beq.n	c0d03414 <__aeabi_dsub+0x4ac>
c0d033a2:	464b      	mov	r3, r9
c0d033a4:	48a6      	ldr	r0, [pc, #664]	; (c0d03640 <__aeabi_dsub+0x6d8>)
c0d033a6:	2201      	movs	r2, #1
c0d033a8:	4003      	ands	r3, r0
c0d033aa:	0018      	movs	r0, r3
c0d033ac:	0863      	lsrs	r3, r4, #1
c0d033ae:	4014      	ands	r4, r2
c0d033b0:	431c      	orrs	r4, r3
c0d033b2:	07c3      	lsls	r3, r0, #31
c0d033b4:	431c      	orrs	r4, r3
c0d033b6:	0843      	lsrs	r3, r0, #1
c0d033b8:	4699      	mov	r9, r3
c0d033ba:	e657      	b.n	c0d0306c <__aeabi_dsub+0x104>
c0d033bc:	0010      	movs	r0, r2
c0d033be:	000e      	movs	r6, r1
c0d033c0:	3820      	subs	r0, #32
c0d033c2:	40c6      	lsrs	r6, r0
c0d033c4:	2a20      	cmp	r2, #32
c0d033c6:	d004      	beq.n	c0d033d2 <__aeabi_dsub+0x46a>
c0d033c8:	2040      	movs	r0, #64	; 0x40
c0d033ca:	1a82      	subs	r2, r0, r2
c0d033cc:	4091      	lsls	r1, r2
c0d033ce:	430f      	orrs	r7, r1
c0d033d0:	46b9      	mov	r9, r7
c0d033d2:	464f      	mov	r7, r9
c0d033d4:	1e7a      	subs	r2, r7, #1
c0d033d6:	4197      	sbcs	r7, r2
c0d033d8:	4337      	orrs	r7, r6
c0d033da:	e60f      	b.n	c0d02ffc <__aeabi_dsub+0x94>
c0d033dc:	4662      	mov	r2, ip
c0d033de:	431a      	orrs	r2, r3
c0d033e0:	0013      	movs	r3, r2
c0d033e2:	1e5a      	subs	r2, r3, #1
c0d033e4:	4193      	sbcs	r3, r2
c0d033e6:	1afc      	subs	r4, r7, r3
c0d033e8:	42a7      	cmp	r7, r4
c0d033ea:	41bf      	sbcs	r7, r7
c0d033ec:	427f      	negs	r7, r7
c0d033ee:	1bcb      	subs	r3, r1, r7
c0d033f0:	4699      	mov	r9, r3
c0d033f2:	465d      	mov	r5, fp
c0d033f4:	4680      	mov	r8, r0
c0d033f6:	e608      	b.n	c0d0300a <__aeabi_dsub+0xa2>
c0d033f8:	4666      	mov	r6, ip
c0d033fa:	431e      	orrs	r6, r3
c0d033fc:	d100      	bne.n	c0d03400 <__aeabi_dsub+0x498>
c0d033fe:	e0be      	b.n	c0d0357e <__aeabi_dsub+0x616>
c0d03400:	1e56      	subs	r6, r2, #1
c0d03402:	2a01      	cmp	r2, #1
c0d03404:	d100      	bne.n	c0d03408 <__aeabi_dsub+0x4a0>
c0d03406:	e109      	b.n	c0d0361c <__aeabi_dsub+0x6b4>
c0d03408:	4c8c      	ldr	r4, [pc, #560]	; (c0d0363c <__aeabi_dsub+0x6d4>)
c0d0340a:	42a2      	cmp	r2, r4
c0d0340c:	d100      	bne.n	c0d03410 <__aeabi_dsub+0x4a8>
c0d0340e:	e119      	b.n	c0d03644 <__aeabi_dsub+0x6dc>
c0d03410:	0032      	movs	r2, r6
c0d03412:	e6c1      	b.n	c0d03198 <__aeabi_dsub+0x230>
c0d03414:	4642      	mov	r2, r8
c0d03416:	2400      	movs	r4, #0
c0d03418:	2300      	movs	r3, #0
c0d0341a:	e648      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d0341c:	2020      	movs	r0, #32
c0d0341e:	000c      	movs	r4, r1
c0d03420:	1a80      	subs	r0, r0, r2
c0d03422:	003e      	movs	r6, r7
c0d03424:	4087      	lsls	r7, r0
c0d03426:	4084      	lsls	r4, r0
c0d03428:	40d6      	lsrs	r6, r2
c0d0342a:	1e78      	subs	r0, r7, #1
c0d0342c:	4187      	sbcs	r7, r0
c0d0342e:	40d1      	lsrs	r1, r2
c0d03430:	4334      	orrs	r4, r6
c0d03432:	433c      	orrs	r4, r7
c0d03434:	448c      	add	ip, r1
c0d03436:	e7a4      	b.n	c0d03382 <__aeabi_dsub+0x41a>
c0d03438:	4a80      	ldr	r2, [pc, #512]	; (c0d0363c <__aeabi_dsub+0x6d4>)
c0d0343a:	4290      	cmp	r0, r2
c0d0343c:	d100      	bne.n	c0d03440 <__aeabi_dsub+0x4d8>
c0d0343e:	e0e9      	b.n	c0d03614 <__aeabi_dsub+0x6ac>
c0d03440:	19df      	adds	r7, r3, r7
c0d03442:	429f      	cmp	r7, r3
c0d03444:	419b      	sbcs	r3, r3
c0d03446:	4461      	add	r1, ip
c0d03448:	425b      	negs	r3, r3
c0d0344a:	18c9      	adds	r1, r1, r3
c0d0344c:	07cc      	lsls	r4, r1, #31
c0d0344e:	087f      	lsrs	r7, r7, #1
c0d03450:	084b      	lsrs	r3, r1, #1
c0d03452:	4699      	mov	r9, r3
c0d03454:	4680      	mov	r8, r0
c0d03456:	433c      	orrs	r4, r7
c0d03458:	e6f4      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d0345a:	1afc      	subs	r4, r7, r3
c0d0345c:	42a7      	cmp	r7, r4
c0d0345e:	41bf      	sbcs	r7, r7
c0d03460:	4663      	mov	r3, ip
c0d03462:	427f      	negs	r7, r7
c0d03464:	1ac9      	subs	r1, r1, r3
c0d03466:	1bcb      	subs	r3, r1, r7
c0d03468:	4699      	mov	r9, r3
c0d0346a:	465d      	mov	r5, fp
c0d0346c:	e5d5      	b.n	c0d0301a <__aeabi_dsub+0xb2>
c0d0346e:	08ff      	lsrs	r7, r7, #3
c0d03470:	074b      	lsls	r3, r1, #29
c0d03472:	465d      	mov	r5, fp
c0d03474:	433b      	orrs	r3, r7
c0d03476:	08cc      	lsrs	r4, r1, #3
c0d03478:	e6ee      	b.n	c0d03258 <__aeabi_dsub+0x2f0>
c0d0347a:	4662      	mov	r2, ip
c0d0347c:	431a      	orrs	r2, r3
c0d0347e:	d000      	beq.n	c0d03482 <__aeabi_dsub+0x51a>
c0d03480:	e082      	b.n	c0d03588 <__aeabi_dsub+0x620>
c0d03482:	000b      	movs	r3, r1
c0d03484:	433b      	orrs	r3, r7
c0d03486:	d11b      	bne.n	c0d034c0 <__aeabi_dsub+0x558>
c0d03488:	2480      	movs	r4, #128	; 0x80
c0d0348a:	2500      	movs	r5, #0
c0d0348c:	0324      	lsls	r4, r4, #12
c0d0348e:	e6f9      	b.n	c0d03284 <__aeabi_dsub+0x31c>
c0d03490:	19dc      	adds	r4, r3, r7
c0d03492:	429c      	cmp	r4, r3
c0d03494:	419b      	sbcs	r3, r3
c0d03496:	4461      	add	r1, ip
c0d03498:	4689      	mov	r9, r1
c0d0349a:	425b      	negs	r3, r3
c0d0349c:	4499      	add	r9, r3
c0d0349e:	464b      	mov	r3, r9
c0d034a0:	021b      	lsls	r3, r3, #8
c0d034a2:	d444      	bmi.n	c0d0352e <__aeabi_dsub+0x5c6>
c0d034a4:	2301      	movs	r3, #1
c0d034a6:	4698      	mov	r8, r3
c0d034a8:	e6cc      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d034aa:	1bdc      	subs	r4, r3, r7
c0d034ac:	4662      	mov	r2, ip
c0d034ae:	42a3      	cmp	r3, r4
c0d034b0:	419b      	sbcs	r3, r3
c0d034b2:	1a51      	subs	r1, r2, r1
c0d034b4:	425b      	negs	r3, r3
c0d034b6:	1acb      	subs	r3, r1, r3
c0d034b8:	4699      	mov	r9, r3
c0d034ba:	2301      	movs	r3, #1
c0d034bc:	4698      	mov	r8, r3
c0d034be:	e5a4      	b.n	c0d0300a <__aeabi_dsub+0xa2>
c0d034c0:	08ff      	lsrs	r7, r7, #3
c0d034c2:	074b      	lsls	r3, r1, #29
c0d034c4:	465d      	mov	r5, fp
c0d034c6:	433b      	orrs	r3, r7
c0d034c8:	08cc      	lsrs	r4, r1, #3
c0d034ca:	e6d7      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d034cc:	4662      	mov	r2, ip
c0d034ce:	431a      	orrs	r2, r3
c0d034d0:	0014      	movs	r4, r2
c0d034d2:	1e63      	subs	r3, r4, #1
c0d034d4:	419c      	sbcs	r4, r3
c0d034d6:	e679      	b.n	c0d031cc <__aeabi_dsub+0x264>
c0d034d8:	0015      	movs	r5, r2
c0d034da:	4664      	mov	r4, ip
c0d034dc:	3d20      	subs	r5, #32
c0d034de:	40ec      	lsrs	r4, r5
c0d034e0:	46a0      	mov	r8, r4
c0d034e2:	2a20      	cmp	r2, #32
c0d034e4:	d005      	beq.n	c0d034f2 <__aeabi_dsub+0x58a>
c0d034e6:	2540      	movs	r5, #64	; 0x40
c0d034e8:	4664      	mov	r4, ip
c0d034ea:	1aaa      	subs	r2, r5, r2
c0d034ec:	4094      	lsls	r4, r2
c0d034ee:	4323      	orrs	r3, r4
c0d034f0:	469a      	mov	sl, r3
c0d034f2:	4654      	mov	r4, sl
c0d034f4:	1e63      	subs	r3, r4, #1
c0d034f6:	419c      	sbcs	r4, r3
c0d034f8:	4643      	mov	r3, r8
c0d034fa:	4323      	orrs	r3, r4
c0d034fc:	e773      	b.n	c0d033e6 <__aeabi_dsub+0x47e>
c0d034fe:	4662      	mov	r2, ip
c0d03500:	431a      	orrs	r2, r3
c0d03502:	d023      	beq.n	c0d0354c <__aeabi_dsub+0x5e4>
c0d03504:	000a      	movs	r2, r1
c0d03506:	433a      	orrs	r2, r7
c0d03508:	d000      	beq.n	c0d0350c <__aeabi_dsub+0x5a4>
c0d0350a:	e0a0      	b.n	c0d0364e <__aeabi_dsub+0x6e6>
c0d0350c:	4662      	mov	r2, ip
c0d0350e:	08db      	lsrs	r3, r3, #3
c0d03510:	0752      	lsls	r2, r2, #29
c0d03512:	4313      	orrs	r3, r2
c0d03514:	4662      	mov	r2, ip
c0d03516:	08d4      	lsrs	r4, r2, #3
c0d03518:	e6b0      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d0351a:	000b      	movs	r3, r1
c0d0351c:	433b      	orrs	r3, r7
c0d0351e:	d100      	bne.n	c0d03522 <__aeabi_dsub+0x5ba>
c0d03520:	e728      	b.n	c0d03374 <__aeabi_dsub+0x40c>
c0d03522:	08ff      	lsrs	r7, r7, #3
c0d03524:	074b      	lsls	r3, r1, #29
c0d03526:	465d      	mov	r5, fp
c0d03528:	433b      	orrs	r3, r7
c0d0352a:	08cc      	lsrs	r4, r1, #3
c0d0352c:	e697      	b.n	c0d0325e <__aeabi_dsub+0x2f6>
c0d0352e:	2302      	movs	r3, #2
c0d03530:	4698      	mov	r8, r3
c0d03532:	e736      	b.n	c0d033a2 <__aeabi_dsub+0x43a>
c0d03534:	1afc      	subs	r4, r7, r3
c0d03536:	42a7      	cmp	r7, r4
c0d03538:	41bf      	sbcs	r7, r7
c0d0353a:	4663      	mov	r3, ip
c0d0353c:	427f      	negs	r7, r7
c0d0353e:	1ac9      	subs	r1, r1, r3
c0d03540:	1bcb      	subs	r3, r1, r7
c0d03542:	4699      	mov	r9, r3
c0d03544:	2301      	movs	r3, #1
c0d03546:	465d      	mov	r5, fp
c0d03548:	4698      	mov	r8, r3
c0d0354a:	e55e      	b.n	c0d0300a <__aeabi_dsub+0xa2>
c0d0354c:	074b      	lsls	r3, r1, #29
c0d0354e:	08ff      	lsrs	r7, r7, #3
c0d03550:	433b      	orrs	r3, r7
c0d03552:	08cc      	lsrs	r4, r1, #3
c0d03554:	e692      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d03556:	1bdc      	subs	r4, r3, r7
c0d03558:	4660      	mov	r0, ip
c0d0355a:	42a3      	cmp	r3, r4
c0d0355c:	41b6      	sbcs	r6, r6
c0d0355e:	1a40      	subs	r0, r0, r1
c0d03560:	4276      	negs	r6, r6
c0d03562:	1b80      	subs	r0, r0, r6
c0d03564:	4681      	mov	r9, r0
c0d03566:	0200      	lsls	r0, r0, #8
c0d03568:	d560      	bpl.n	c0d0362c <__aeabi_dsub+0x6c4>
c0d0356a:	1afc      	subs	r4, r7, r3
c0d0356c:	42a7      	cmp	r7, r4
c0d0356e:	41bf      	sbcs	r7, r7
c0d03570:	4663      	mov	r3, ip
c0d03572:	427f      	negs	r7, r7
c0d03574:	1ac9      	subs	r1, r1, r3
c0d03576:	1bcb      	subs	r3, r1, r7
c0d03578:	4699      	mov	r9, r3
c0d0357a:	465d      	mov	r5, fp
c0d0357c:	e576      	b.n	c0d0306c <__aeabi_dsub+0x104>
c0d0357e:	08ff      	lsrs	r7, r7, #3
c0d03580:	074b      	lsls	r3, r1, #29
c0d03582:	433b      	orrs	r3, r7
c0d03584:	08cc      	lsrs	r4, r1, #3
c0d03586:	e667      	b.n	c0d03258 <__aeabi_dsub+0x2f0>
c0d03588:	000a      	movs	r2, r1
c0d0358a:	08db      	lsrs	r3, r3, #3
c0d0358c:	433a      	orrs	r2, r7
c0d0358e:	d100      	bne.n	c0d03592 <__aeabi_dsub+0x62a>
c0d03590:	e66f      	b.n	c0d03272 <__aeabi_dsub+0x30a>
c0d03592:	4662      	mov	r2, ip
c0d03594:	0752      	lsls	r2, r2, #29
c0d03596:	4313      	orrs	r3, r2
c0d03598:	4662      	mov	r2, ip
c0d0359a:	08d4      	lsrs	r4, r2, #3
c0d0359c:	2280      	movs	r2, #128	; 0x80
c0d0359e:	0312      	lsls	r2, r2, #12
c0d035a0:	4214      	tst	r4, r2
c0d035a2:	d007      	beq.n	c0d035b4 <__aeabi_dsub+0x64c>
c0d035a4:	08c8      	lsrs	r0, r1, #3
c0d035a6:	4210      	tst	r0, r2
c0d035a8:	d104      	bne.n	c0d035b4 <__aeabi_dsub+0x64c>
c0d035aa:	465d      	mov	r5, fp
c0d035ac:	0004      	movs	r4, r0
c0d035ae:	08fb      	lsrs	r3, r7, #3
c0d035b0:	0749      	lsls	r1, r1, #29
c0d035b2:	430b      	orrs	r3, r1
c0d035b4:	0f5a      	lsrs	r2, r3, #29
c0d035b6:	00db      	lsls	r3, r3, #3
c0d035b8:	08db      	lsrs	r3, r3, #3
c0d035ba:	0752      	lsls	r2, r2, #29
c0d035bc:	4313      	orrs	r3, r2
c0d035be:	e65d      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d035c0:	074b      	lsls	r3, r1, #29
c0d035c2:	08ff      	lsrs	r7, r7, #3
c0d035c4:	433b      	orrs	r3, r7
c0d035c6:	08cc      	lsrs	r4, r1, #3
c0d035c8:	e649      	b.n	c0d0325e <__aeabi_dsub+0x2f6>
c0d035ca:	19dc      	adds	r4, r3, r7
c0d035cc:	429c      	cmp	r4, r3
c0d035ce:	419b      	sbcs	r3, r3
c0d035d0:	4461      	add	r1, ip
c0d035d2:	4689      	mov	r9, r1
c0d035d4:	425b      	negs	r3, r3
c0d035d6:	4499      	add	r9, r3
c0d035d8:	464b      	mov	r3, r9
c0d035da:	021b      	lsls	r3, r3, #8
c0d035dc:	d400      	bmi.n	c0d035e0 <__aeabi_dsub+0x678>
c0d035de:	e631      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d035e0:	464a      	mov	r2, r9
c0d035e2:	4b17      	ldr	r3, [pc, #92]	; (c0d03640 <__aeabi_dsub+0x6d8>)
c0d035e4:	401a      	ands	r2, r3
c0d035e6:	2301      	movs	r3, #1
c0d035e8:	4691      	mov	r9, r2
c0d035ea:	4698      	mov	r8, r3
c0d035ec:	e62a      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d035ee:	0016      	movs	r6, r2
c0d035f0:	4664      	mov	r4, ip
c0d035f2:	3e20      	subs	r6, #32
c0d035f4:	40f4      	lsrs	r4, r6
c0d035f6:	46a0      	mov	r8, r4
c0d035f8:	2a20      	cmp	r2, #32
c0d035fa:	d005      	beq.n	c0d03608 <__aeabi_dsub+0x6a0>
c0d035fc:	2640      	movs	r6, #64	; 0x40
c0d035fe:	4664      	mov	r4, ip
c0d03600:	1ab2      	subs	r2, r6, r2
c0d03602:	4094      	lsls	r4, r2
c0d03604:	4323      	orrs	r3, r4
c0d03606:	469a      	mov	sl, r3
c0d03608:	4654      	mov	r4, sl
c0d0360a:	1e63      	subs	r3, r4, #1
c0d0360c:	419c      	sbcs	r4, r3
c0d0360e:	4643      	mov	r3, r8
c0d03610:	431c      	orrs	r4, r3
c0d03612:	e5db      	b.n	c0d031cc <__aeabi_dsub+0x264>
c0d03614:	0002      	movs	r2, r0
c0d03616:	2400      	movs	r4, #0
c0d03618:	2300      	movs	r3, #0
c0d0361a:	e548      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d0361c:	19dc      	adds	r4, r3, r7
c0d0361e:	42bc      	cmp	r4, r7
c0d03620:	41bf      	sbcs	r7, r7
c0d03622:	4461      	add	r1, ip
c0d03624:	4689      	mov	r9, r1
c0d03626:	427f      	negs	r7, r7
c0d03628:	44b9      	add	r9, r7
c0d0362a:	e738      	b.n	c0d0349e <__aeabi_dsub+0x536>
c0d0362c:	464b      	mov	r3, r9
c0d0362e:	4323      	orrs	r3, r4
c0d03630:	d100      	bne.n	c0d03634 <__aeabi_dsub+0x6cc>
c0d03632:	e69f      	b.n	c0d03374 <__aeabi_dsub+0x40c>
c0d03634:	e606      	b.n	c0d03244 <__aeabi_dsub+0x2dc>
c0d03636:	46c0      	nop			; (mov r8, r8)
c0d03638:	000007fe 	.word	0x000007fe
c0d0363c:	000007ff 	.word	0x000007ff
c0d03640:	ff7fffff 	.word	0xff7fffff
c0d03644:	08ff      	lsrs	r7, r7, #3
c0d03646:	074b      	lsls	r3, r1, #29
c0d03648:	433b      	orrs	r3, r7
c0d0364a:	08cc      	lsrs	r4, r1, #3
c0d0364c:	e616      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d0364e:	4662      	mov	r2, ip
c0d03650:	08db      	lsrs	r3, r3, #3
c0d03652:	0752      	lsls	r2, r2, #29
c0d03654:	4313      	orrs	r3, r2
c0d03656:	4662      	mov	r2, ip
c0d03658:	08d4      	lsrs	r4, r2, #3
c0d0365a:	2280      	movs	r2, #128	; 0x80
c0d0365c:	0312      	lsls	r2, r2, #12
c0d0365e:	4214      	tst	r4, r2
c0d03660:	d007      	beq.n	c0d03672 <__aeabi_dsub+0x70a>
c0d03662:	08c8      	lsrs	r0, r1, #3
c0d03664:	4210      	tst	r0, r2
c0d03666:	d104      	bne.n	c0d03672 <__aeabi_dsub+0x70a>
c0d03668:	465d      	mov	r5, fp
c0d0366a:	0004      	movs	r4, r0
c0d0366c:	08fb      	lsrs	r3, r7, #3
c0d0366e:	0749      	lsls	r1, r1, #29
c0d03670:	430b      	orrs	r3, r1
c0d03672:	0f5a      	lsrs	r2, r3, #29
c0d03674:	00db      	lsls	r3, r3, #3
c0d03676:	0752      	lsls	r2, r2, #29
c0d03678:	08db      	lsrs	r3, r3, #3
c0d0367a:	4313      	orrs	r3, r2
c0d0367c:	e5fe      	b.n	c0d0327c <__aeabi_dsub+0x314>
c0d0367e:	2300      	movs	r3, #0
c0d03680:	4a01      	ldr	r2, [pc, #4]	; (c0d03688 <__aeabi_dsub+0x720>)
c0d03682:	001c      	movs	r4, r3
c0d03684:	e513      	b.n	c0d030ae <__aeabi_dsub+0x146>
c0d03686:	46c0      	nop			; (mov r8, r8)
c0d03688:	000007ff 	.word	0x000007ff

c0d0368c <__aeabi_dcmpun>:
c0d0368c:	b570      	push	{r4, r5, r6, lr}
c0d0368e:	0005      	movs	r5, r0
c0d03690:	480c      	ldr	r0, [pc, #48]	; (c0d036c4 <__aeabi_dcmpun+0x38>)
c0d03692:	031c      	lsls	r4, r3, #12
c0d03694:	0016      	movs	r6, r2
c0d03696:	005b      	lsls	r3, r3, #1
c0d03698:	030a      	lsls	r2, r1, #12
c0d0369a:	0049      	lsls	r1, r1, #1
c0d0369c:	0b12      	lsrs	r2, r2, #12
c0d0369e:	0d49      	lsrs	r1, r1, #21
c0d036a0:	0b24      	lsrs	r4, r4, #12
c0d036a2:	0d5b      	lsrs	r3, r3, #21
c0d036a4:	4281      	cmp	r1, r0
c0d036a6:	d008      	beq.n	c0d036ba <__aeabi_dcmpun+0x2e>
c0d036a8:	4a06      	ldr	r2, [pc, #24]	; (c0d036c4 <__aeabi_dcmpun+0x38>)
c0d036aa:	2000      	movs	r0, #0
c0d036ac:	4293      	cmp	r3, r2
c0d036ae:	d103      	bne.n	c0d036b8 <__aeabi_dcmpun+0x2c>
c0d036b0:	0020      	movs	r0, r4
c0d036b2:	4330      	orrs	r0, r6
c0d036b4:	1e43      	subs	r3, r0, #1
c0d036b6:	4198      	sbcs	r0, r3
c0d036b8:	bd70      	pop	{r4, r5, r6, pc}
c0d036ba:	2001      	movs	r0, #1
c0d036bc:	432a      	orrs	r2, r5
c0d036be:	d1fb      	bne.n	c0d036b8 <__aeabi_dcmpun+0x2c>
c0d036c0:	e7f2      	b.n	c0d036a8 <__aeabi_dcmpun+0x1c>
c0d036c2:	46c0      	nop			; (mov r8, r8)
c0d036c4:	000007ff 	.word	0x000007ff

c0d036c8 <__aeabi_d2iz>:
c0d036c8:	000a      	movs	r2, r1
c0d036ca:	b530      	push	{r4, r5, lr}
c0d036cc:	4c13      	ldr	r4, [pc, #76]	; (c0d0371c <__aeabi_d2iz+0x54>)
c0d036ce:	0053      	lsls	r3, r2, #1
c0d036d0:	0309      	lsls	r1, r1, #12
c0d036d2:	0005      	movs	r5, r0
c0d036d4:	0b09      	lsrs	r1, r1, #12
c0d036d6:	2000      	movs	r0, #0
c0d036d8:	0d5b      	lsrs	r3, r3, #21
c0d036da:	0fd2      	lsrs	r2, r2, #31
c0d036dc:	42a3      	cmp	r3, r4
c0d036de:	dd04      	ble.n	c0d036ea <__aeabi_d2iz+0x22>
c0d036e0:	480f      	ldr	r0, [pc, #60]	; (c0d03720 <__aeabi_d2iz+0x58>)
c0d036e2:	4283      	cmp	r3, r0
c0d036e4:	dd02      	ble.n	c0d036ec <__aeabi_d2iz+0x24>
c0d036e6:	4b0f      	ldr	r3, [pc, #60]	; (c0d03724 <__aeabi_d2iz+0x5c>)
c0d036e8:	18d0      	adds	r0, r2, r3
c0d036ea:	bd30      	pop	{r4, r5, pc}
c0d036ec:	2080      	movs	r0, #128	; 0x80
c0d036ee:	0340      	lsls	r0, r0, #13
c0d036f0:	4301      	orrs	r1, r0
c0d036f2:	480d      	ldr	r0, [pc, #52]	; (c0d03728 <__aeabi_d2iz+0x60>)
c0d036f4:	1ac0      	subs	r0, r0, r3
c0d036f6:	281f      	cmp	r0, #31
c0d036f8:	dd08      	ble.n	c0d0370c <__aeabi_d2iz+0x44>
c0d036fa:	480c      	ldr	r0, [pc, #48]	; (c0d0372c <__aeabi_d2iz+0x64>)
c0d036fc:	1ac3      	subs	r3, r0, r3
c0d036fe:	40d9      	lsrs	r1, r3
c0d03700:	000b      	movs	r3, r1
c0d03702:	4258      	negs	r0, r3
c0d03704:	2a00      	cmp	r2, #0
c0d03706:	d1f0      	bne.n	c0d036ea <__aeabi_d2iz+0x22>
c0d03708:	0018      	movs	r0, r3
c0d0370a:	e7ee      	b.n	c0d036ea <__aeabi_d2iz+0x22>
c0d0370c:	4c08      	ldr	r4, [pc, #32]	; (c0d03730 <__aeabi_d2iz+0x68>)
c0d0370e:	40c5      	lsrs	r5, r0
c0d03710:	46a4      	mov	ip, r4
c0d03712:	4463      	add	r3, ip
c0d03714:	4099      	lsls	r1, r3
c0d03716:	000b      	movs	r3, r1
c0d03718:	432b      	orrs	r3, r5
c0d0371a:	e7f2      	b.n	c0d03702 <__aeabi_d2iz+0x3a>
c0d0371c:	000003fe 	.word	0x000003fe
c0d03720:	0000041d 	.word	0x0000041d
c0d03724:	7fffffff 	.word	0x7fffffff
c0d03728:	00000433 	.word	0x00000433
c0d0372c:	00000413 	.word	0x00000413
c0d03730:	fffffbed 	.word	0xfffffbed

c0d03734 <__aeabi_i2d>:
c0d03734:	b570      	push	{r4, r5, r6, lr}
c0d03736:	2800      	cmp	r0, #0
c0d03738:	d016      	beq.n	c0d03768 <__aeabi_i2d+0x34>
c0d0373a:	17c3      	asrs	r3, r0, #31
c0d0373c:	18c5      	adds	r5, r0, r3
c0d0373e:	405d      	eors	r5, r3
c0d03740:	0fc4      	lsrs	r4, r0, #31
c0d03742:	0028      	movs	r0, r5
c0d03744:	f000 f84c 	bl	c0d037e0 <__clzsi2>
c0d03748:	4a11      	ldr	r2, [pc, #68]	; (c0d03790 <__aeabi_i2d+0x5c>)
c0d0374a:	1a12      	subs	r2, r2, r0
c0d0374c:	280a      	cmp	r0, #10
c0d0374e:	dc16      	bgt.n	c0d0377e <__aeabi_i2d+0x4a>
c0d03750:	0003      	movs	r3, r0
c0d03752:	002e      	movs	r6, r5
c0d03754:	3315      	adds	r3, #21
c0d03756:	409e      	lsls	r6, r3
c0d03758:	230b      	movs	r3, #11
c0d0375a:	1a18      	subs	r0, r3, r0
c0d0375c:	40c5      	lsrs	r5, r0
c0d0375e:	0552      	lsls	r2, r2, #21
c0d03760:	032d      	lsls	r5, r5, #12
c0d03762:	0b2d      	lsrs	r5, r5, #12
c0d03764:	0d53      	lsrs	r3, r2, #21
c0d03766:	e003      	b.n	c0d03770 <__aeabi_i2d+0x3c>
c0d03768:	2400      	movs	r4, #0
c0d0376a:	2300      	movs	r3, #0
c0d0376c:	2500      	movs	r5, #0
c0d0376e:	2600      	movs	r6, #0
c0d03770:	051b      	lsls	r3, r3, #20
c0d03772:	432b      	orrs	r3, r5
c0d03774:	07e4      	lsls	r4, r4, #31
c0d03776:	4323      	orrs	r3, r4
c0d03778:	0030      	movs	r0, r6
c0d0377a:	0019      	movs	r1, r3
c0d0377c:	bd70      	pop	{r4, r5, r6, pc}
c0d0377e:	380b      	subs	r0, #11
c0d03780:	4085      	lsls	r5, r0
c0d03782:	0552      	lsls	r2, r2, #21
c0d03784:	032d      	lsls	r5, r5, #12
c0d03786:	2600      	movs	r6, #0
c0d03788:	0b2d      	lsrs	r5, r5, #12
c0d0378a:	0d53      	lsrs	r3, r2, #21
c0d0378c:	e7f0      	b.n	c0d03770 <__aeabi_i2d+0x3c>
c0d0378e:	46c0      	nop			; (mov r8, r8)
c0d03790:	0000041e 	.word	0x0000041e

c0d03794 <__aeabi_ui2d>:
c0d03794:	b510      	push	{r4, lr}
c0d03796:	1e04      	subs	r4, r0, #0
c0d03798:	d010      	beq.n	c0d037bc <__aeabi_ui2d+0x28>
c0d0379a:	f000 f821 	bl	c0d037e0 <__clzsi2>
c0d0379e:	4b0f      	ldr	r3, [pc, #60]	; (c0d037dc <__aeabi_ui2d+0x48>)
c0d037a0:	1a1b      	subs	r3, r3, r0
c0d037a2:	280a      	cmp	r0, #10
c0d037a4:	dc11      	bgt.n	c0d037ca <__aeabi_ui2d+0x36>
c0d037a6:	220b      	movs	r2, #11
c0d037a8:	0021      	movs	r1, r4
c0d037aa:	1a12      	subs	r2, r2, r0
c0d037ac:	40d1      	lsrs	r1, r2
c0d037ae:	3015      	adds	r0, #21
c0d037b0:	030a      	lsls	r2, r1, #12
c0d037b2:	055b      	lsls	r3, r3, #21
c0d037b4:	4084      	lsls	r4, r0
c0d037b6:	0b12      	lsrs	r2, r2, #12
c0d037b8:	0d5b      	lsrs	r3, r3, #21
c0d037ba:	e001      	b.n	c0d037c0 <__aeabi_ui2d+0x2c>
c0d037bc:	2300      	movs	r3, #0
c0d037be:	2200      	movs	r2, #0
c0d037c0:	051b      	lsls	r3, r3, #20
c0d037c2:	4313      	orrs	r3, r2
c0d037c4:	0020      	movs	r0, r4
c0d037c6:	0019      	movs	r1, r3
c0d037c8:	bd10      	pop	{r4, pc}
c0d037ca:	0022      	movs	r2, r4
c0d037cc:	380b      	subs	r0, #11
c0d037ce:	4082      	lsls	r2, r0
c0d037d0:	055b      	lsls	r3, r3, #21
c0d037d2:	0312      	lsls	r2, r2, #12
c0d037d4:	2400      	movs	r4, #0
c0d037d6:	0b12      	lsrs	r2, r2, #12
c0d037d8:	0d5b      	lsrs	r3, r3, #21
c0d037da:	e7f1      	b.n	c0d037c0 <__aeabi_ui2d+0x2c>
c0d037dc:	0000041e 	.word	0x0000041e

c0d037e0 <__clzsi2>:
c0d037e0:	211c      	movs	r1, #28
c0d037e2:	2301      	movs	r3, #1
c0d037e4:	041b      	lsls	r3, r3, #16
c0d037e6:	4298      	cmp	r0, r3
c0d037e8:	d301      	bcc.n	c0d037ee <__clzsi2+0xe>
c0d037ea:	0c00      	lsrs	r0, r0, #16
c0d037ec:	3910      	subs	r1, #16
c0d037ee:	0a1b      	lsrs	r3, r3, #8
c0d037f0:	4298      	cmp	r0, r3
c0d037f2:	d301      	bcc.n	c0d037f8 <__clzsi2+0x18>
c0d037f4:	0a00      	lsrs	r0, r0, #8
c0d037f6:	3908      	subs	r1, #8
c0d037f8:	091b      	lsrs	r3, r3, #4
c0d037fa:	4298      	cmp	r0, r3
c0d037fc:	d301      	bcc.n	c0d03802 <__clzsi2+0x22>
c0d037fe:	0900      	lsrs	r0, r0, #4
c0d03800:	3904      	subs	r1, #4
c0d03802:	a202      	add	r2, pc, #8	; (adr r2, c0d0380c <__clzsi2+0x2c>)
c0d03804:	5c10      	ldrb	r0, [r2, r0]
c0d03806:	1840      	adds	r0, r0, r1
c0d03808:	4770      	bx	lr
c0d0380a:	46c0      	nop			; (mov r8, r8)
c0d0380c:	02020304 	.word	0x02020304
c0d03810:	01010101 	.word	0x01010101
	...

c0d0381c <__clzdi2>:
c0d0381c:	b510      	push	{r4, lr}
c0d0381e:	2900      	cmp	r1, #0
c0d03820:	d103      	bne.n	c0d0382a <__clzdi2+0xe>
c0d03822:	f7ff ffdd 	bl	c0d037e0 <__clzsi2>
c0d03826:	3020      	adds	r0, #32
c0d03828:	e002      	b.n	c0d03830 <__clzdi2+0x14>
c0d0382a:	0008      	movs	r0, r1
c0d0382c:	f7ff ffd8 	bl	c0d037e0 <__clzsi2>
c0d03830:	bd10      	pop	{r4, pc}
c0d03832:	46c0      	nop			; (mov r8, r8)

c0d03834 <__aeabi_memclr>:
c0d03834:	b510      	push	{r4, lr}
c0d03836:	2200      	movs	r2, #0
c0d03838:	f000 f801 	bl	c0d0383e <__aeabi_memset>
c0d0383c:	bd10      	pop	{r4, pc}

c0d0383e <__aeabi_memset>:
c0d0383e:	000b      	movs	r3, r1
c0d03840:	b510      	push	{r4, lr}
c0d03842:	0011      	movs	r1, r2
c0d03844:	001a      	movs	r2, r3
c0d03846:	f000 f801 	bl	c0d0384c <memset>
c0d0384a:	bd10      	pop	{r4, pc}

c0d0384c <memset>:
c0d0384c:	0003      	movs	r3, r0
c0d0384e:	1882      	adds	r2, r0, r2
c0d03850:	4293      	cmp	r3, r2
c0d03852:	d100      	bne.n	c0d03856 <memset+0xa>
c0d03854:	4770      	bx	lr
c0d03856:	7019      	strb	r1, [r3, #0]
c0d03858:	3301      	adds	r3, #1
c0d0385a:	e7f9      	b.n	c0d03850 <memset+0x4>

c0d0385c <setjmp>:
c0d0385c:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d0385e:	4641      	mov	r1, r8
c0d03860:	464a      	mov	r2, r9
c0d03862:	4653      	mov	r3, sl
c0d03864:	465c      	mov	r4, fp
c0d03866:	466d      	mov	r5, sp
c0d03868:	4676      	mov	r6, lr
c0d0386a:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d0386c:	3828      	subs	r0, #40	; 0x28
c0d0386e:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d03870:	2000      	movs	r0, #0
c0d03872:	4770      	bx	lr

c0d03874 <longjmp>:
c0d03874:	3010      	adds	r0, #16
c0d03876:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d03878:	4690      	mov	r8, r2
c0d0387a:	4699      	mov	r9, r3
c0d0387c:	46a2      	mov	sl, r4
c0d0387e:	46ab      	mov	fp, r5
c0d03880:	46b5      	mov	sp, r6
c0d03882:	c808      	ldmia	r0!, {r3}
c0d03884:	3828      	subs	r0, #40	; 0x28
c0d03886:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d03888:	1c08      	adds	r0, r1, #0
c0d0388a:	d100      	bne.n	c0d0388e <longjmp+0x1a>
c0d0388c:	2001      	movs	r0, #1
c0d0388e:	4718      	bx	r3

c0d03890 <strncpy>:
c0d03890:	0003      	movs	r3, r0
c0d03892:	b530      	push	{r4, r5, lr}
c0d03894:	001d      	movs	r5, r3
c0d03896:	2a00      	cmp	r2, #0
c0d03898:	d006      	beq.n	c0d038a8 <strncpy+0x18>
c0d0389a:	780c      	ldrb	r4, [r1, #0]
c0d0389c:	3a01      	subs	r2, #1
c0d0389e:	3301      	adds	r3, #1
c0d038a0:	702c      	strb	r4, [r5, #0]
c0d038a2:	3101      	adds	r1, #1
c0d038a4:	2c00      	cmp	r4, #0
c0d038a6:	d1f5      	bne.n	c0d03894 <strncpy+0x4>
c0d038a8:	2100      	movs	r1, #0
c0d038aa:	189a      	adds	r2, r3, r2
c0d038ac:	4293      	cmp	r3, r2
c0d038ae:	d100      	bne.n	c0d038b2 <strncpy+0x22>
c0d038b0:	bd30      	pop	{r4, r5, pc}
c0d038b2:	7019      	strb	r1, [r3, #0]
c0d038b4:	3301      	adds	r3, #1
c0d038b6:	e7f9      	b.n	c0d038ac <strncpy+0x1c>
c0d038b8:	c0d02364 	.word	0xc0d02364
c0d038bc:	c0d02352 	.word	0xc0d02352
c0d038c0:	c0d02330 	.word	0xc0d02330
c0d038c4:	c0d0235a 	.word	0xc0d0235a
c0d038c8:	c0d02330 	.word	0xc0d02330
c0d038cc:	c0d02632 	.word	0xc0d02632
c0d038d0:	c0d02330 	.word	0xc0d02330
c0d038d4:	c0d0235a 	.word	0xc0d0235a
c0d038d8:	c0d02352 	.word	0xc0d02352
c0d038dc:	c0d02352 	.word	0xc0d02352
c0d038e0:	c0d02632 	.word	0xc0d02632
c0d038e4:	c0d0235a 	.word	0xc0d0235a
c0d038e8:	c0d0231c 	.word	0xc0d0231c
c0d038ec:	c0d0231c 	.word	0xc0d0231c
c0d038f0:	c0d0231c 	.word	0xc0d0231c
c0d038f4:	c0d026a8 	.word	0xc0d026a8
c0d038f8:	c0d02b72 	.word	0xc0d02b72
c0d038fc:	c0d02b30 	.word	0xc0d02b30
c0d03900:	c0d02b30 	.word	0xc0d02b30
c0d03904:	c0d02b2c 	.word	0xc0d02b2c
c0d03908:	c0d02b36 	.word	0xc0d02b36
c0d0390c:	c0d02b36 	.word	0xc0d02b36
c0d03910:	c0d02e46 	.word	0xc0d02e46
c0d03914:	c0d02b2c 	.word	0xc0d02b2c
c0d03918:	c0d02b36 	.word	0xc0d02b36
c0d0391c:	c0d02e46 	.word	0xc0d02e46
c0d03920:	c0d02b36 	.word	0xc0d02b36
c0d03924:	c0d02b2c 	.word	0xc0d02b2c
c0d03928:	c0d02dda 	.word	0xc0d02dda
c0d0392c:	c0d02dda 	.word	0xc0d02dda
c0d03930:	c0d02dda 	.word	0xc0d02dda
c0d03934:	c0d02eb0 	.word	0xc0d02eb0
c0d03938:	696d6573 	.word	0x696d6573
c0d0393c:	736f682d 	.word	0x736f682d
c0d03940:	676e6974 	.word	0x676e6974
c0d03944:	4700203a 	.word	0x4700203a
c0d03948:	49524950 	.word	0x49524950
c0d0394c:	6220554f 	.word	0x6220554f
c0d03950:	73657479 	.word	0x73657479
c0d03954:	203a      	.short	0x203a
	...

c0d03957 <G_HEX>:
c0d03957:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
c0d03967:	6e49 6176 696c 2064 6f63 746e 7865 0a74     Invalid context.
c0d03977:	4700 4950 4952 554f 5420 5345 0a54 4700     .GPIRIOU TEST..G
c0d03987:	4950 4952 554f 5020 4f52 5455 4641 4e4f     PIRIOU PROUTAFON
c0d03997:	2044 0a31 5000 756c 6967 206e 6170 6172     D 1..Plugin para
c0d039a7:	656d 6574 7372 7320 7274 6375 7574 6572     meters structure
c0d039b7:	6920 2073 6962 6767 7265 7420 6168 206e      is bigger than 
c0d039c7:	6c61 6f6c 6577 2064 6973 657a 000a 5047     allowed size..GP
c0d039d7:	5249 4f49 2055 5250 554f 4154 4f46 444e     IRIOU PROUTAFOND
c0d039e7:	3220 3220 000a 4f4c 4b4f 4e49 2047 6f66      2 2..LOOKING fo
c0d039f7:	2072 6573 656c 7463 726f 2520 0064 5047     r selector %d.GP
c0d03a07:	5249 4f49 2055 5250 554f 4154 4f46 444e     IRIOU PROUTAFOND
c0d03a17:	3320 000a 5047 5249 4f49 2055 5250 554f      3..GPIRIOU PROU
c0d03a27:	4154 4f46 444e 3420 000a 4e49 5449 435f     TAFOND 4..INIT_C
c0d03a37:	4e4f 5254 4341 2054 6573 656c 7463 726f     ONTRACT selector
c0d03a47:	203a 7525 000a 694d 7373 6e69 2067 6573     : %u..Missing se
c0d03a57:	656c 7463 726f 6e49 6564 0a78 5000 4f52     lectorIndex..PRO
c0d03a67:	4956 4544 5020 5241 4d41 5445 5245 202c     VIDE PARAMETER, 
c0d03a77:	6573 656c 7463 726f 203a 6425 000a 6553     selector: %d..Se
c0d03a87:	656c 7463 726f 4920 646e 7865 2520 2064     lector Index %d 
c0d03a97:	6f6e 2074 7573 7070 726f 6574 0a64 5000     not supported..P
c0d03aa7:	7261 6d61 6e20 746f 7320 7075 6f70 7472     aram not support
c0d03ab7:	6465 000a 6c70 6775 6e69 7020 6f72 6976     ed..plugin provi
c0d03ac7:	6564 7420 6b6f 6e65 203a 7830 7025 202c     de token: 0x%p, 
c0d03ad7:	7830 7025 000a 704f 6e65 6553 0061 6e55     0x%p..OpenSea.Un
c0d03ae7:	6f6c 6b63 7720 6c61 656c 0074 6553 656c     lock wallet.Sele
c0d03af7:	7463 726f 4920 646e 7865 3a20 6425 6e20     ctor Index :%d n
c0d03b07:	746f 7320 7075 6f70 7472 6465 000a 5047     ot supported..GP
c0d03b17:	5249 4f49 2055 5854 545f 5059 0a45 4700     IRIOU TX_TYPE..G
c0d03b27:	4950 4952 554f 4520 5252 524f 000a 6953     PIRIOU ERROR..Si
c0d03b37:	6e67 7420 206f 6e75 6f6c 6b63 7720 6c61     gn to unlock wal
c0d03b47:	656c 2074 003f                              let ?.

c0d03b4d <OPENSEA_APPROVE_PROXY>:
c0d03b4d:	d8dd 821f                                   ....

c0d03b51 <OPENSEA_CANCEL_ORDER_>:
c0d03b51:	a4a8 701c 0000                               ...p...

c0d03b58 <OPENSEA_SELECTORS>:
c0d03b58:	3b4d c0d0 3b51 c0d0 756a 7473 6920 3a6e     M;..Q;..just in:
c0d03b68:	6d20 7365 6173 6567 203a 6425 000a 5047      message: %d..GP
c0d03b78:	5249 4f49 2055 4e49 5449 4320 4e4f 5254     IRIOU INIT CONTR
c0d03b88:	4341 0a54 5000 4f52 4956 4544 5020 5241     ACT..PROVIDE PAR
c0d03b98:	4d41 5445 5245 000a 4946 414e 494c 455a     AMETER..FINALIZE
c0d03ba8:	000a 5250 564f 4449 2045 4f54 454b 0a4e     ..PROVIDE TOKEN.
c0d03bb8:	5100 4555 5952 4320 4e4f 5254 4341 2054     .QUERY CONTRACT 
c0d03bc8:	4449 000a 5551 5245 2059 4f43 544e 4152     ID..QUERY CONTRA
c0d03bd8:	5443 5520 0a49 5500 686e 6e61 6c64 6465     CT UI..Unhandled
c0d03be8:	6d20 7365 6173 6567 2520 0a64 4500 6874      message %d..Eth
c0d03bf8:	7265 7565 006d 7865 6563 7470 6f69 5b6e     ereum.exception[
c0d03c08:	6425 3a5d 4c20 3d52 7830 3025 5838 000a     %d]: LR=0x%08X..

c0d03c18 <_ftoa.pow10>:
c0d03c18:	0000 0000 0000 3ff0 0000 0000 0000 4024     .......?......$@
c0d03c28:	0000 0000 0000 4059 0000 0000 4000 408f     ......Y@.....@.@
c0d03c38:	0000 0000 8800 40c3 0000 0000 6a00 40f8     .......@.....j.@
c0d03c48:	0000 0000 8480 412e 0000 0000 12d0 4163     .......A......cA
c0d03c58:	0000 0000 d784 4197 0000 0000 cd65 41cd     .......A....e..A
c0d03c68:	616e 006e 6e66 2d69 6600 696e 002b 6e66     nan.fni-.fni+.fn
c0d03c78:	0069 0000                                   i...

c0d03c7c <_etext>:
c0d03c7c:	00000000 	.word	0x00000000
