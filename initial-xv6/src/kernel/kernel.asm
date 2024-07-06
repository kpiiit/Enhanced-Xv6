
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a3010113          	add	sp,sp,-1488 # 80008a30 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8a070713          	add	a4,a4,-1888 # 800088f0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	2ee78793          	add	a5,a5,750 # 80006350 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb88f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	4d2080e7          	jalr	1234(ra) # 800025fc <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	8ac50513          	add	a0,a0,-1876 # 80010a30 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	89c48493          	add	s1,s1,-1892 # 80010a30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	92c90913          	add	s2,s2,-1748 # 80010ac8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	28a080e7          	jalr	650(ra) # 80002446 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	fb6080e7          	jalr	-74(ra) # 80002180 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	85270713          	add	a4,a4,-1966 # 80010a30 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	396080e7          	jalr	918(ra) # 800025a6 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	80850513          	add	a0,a0,-2040 # 80010a30 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	7f250513          	add	a0,a0,2034 # 80010a30 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	84f72d23          	sw	a5,-1958(a4) # 80010ac8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	76850513          	add	a0,a0,1896 # 80010a30 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	364080e7          	jalr	868(ra) # 80002652 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	73a50513          	add	a0,a0,1850 # 80010a30 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	71670713          	add	a4,a4,1814 # 80010a30 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	6ec78793          	add	a5,a5,1772 # 80010a30 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7567a783          	lw	a5,1878(a5) # 80010ac8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	6aa70713          	add	a4,a4,1706 # 80010a30 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	69a48493          	add	s1,s1,1690 # 80010a30 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	65e70713          	add	a4,a4,1630 # 80010a30 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	6ef72423          	sw	a5,1768(a4) # 80010ad0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	62278793          	add	a5,a5,1570 # 80010a30 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	68c7ad23          	sw	a2,1690(a5) # 80010acc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	68e50513          	add	a0,a0,1678 # 80010ac8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	da2080e7          	jalr	-606(ra) # 800021e4 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	5d450513          	add	a0,a0,1492 # 80010a30 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00022797          	auipc	a5,0x22
    80000478:	96478793          	add	a5,a5,-1692 # 80021dd8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5a07a423          	sw	zero,1448(a5) # 80010af0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	add	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	32f72a23          	sw	a5,820(a4) # 800088b0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	538dad83          	lw	s11,1336(s11) # 80010af0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	4e250513          	add	a0,a0,1250 # 80010ad8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	38450513          	add	a0,a0,900 # 80010ad8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	36848493          	add	s1,s1,872 # 80010ad8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	32850513          	add	a0,a0,808 # 80010af8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0b47a783          	lw	a5,180(a5) # 800088b0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0847b783          	ld	a5,132(a5) # 800088b8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	08473703          	ld	a4,132(a4) # 800088c0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	29aa0a13          	add	s4,s4,666 # 80010af8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	05248493          	add	s1,s1,82 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	05298993          	add	s3,s3,82 # 800088c0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	954080e7          	jalr	-1708(ra) # 800021e4 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	22c50513          	add	a0,a0,556 # 80010af8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	fd47a783          	lw	a5,-44(a5) # 800088b0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	fda73703          	ld	a4,-38(a4) # 800088c0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	fca7b783          	ld	a5,-54(a5) # 800088b8 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	1fe98993          	add	s3,s3,510 # 80010af8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	fb648493          	add	s1,s1,-74 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	fb690913          	add	s2,s2,-74 # 800088c0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	866080e7          	jalr	-1946(ra) # 80002180 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1c848493          	add	s1,s1,456 # 80010af8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f6e7be23          	sd	a4,-132(a5) # 800088c0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	14248493          	add	s1,s1,322 # 80010af8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	57878793          	add	a5,a5,1400 # 80022f70 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	11890913          	add	s2,s2,280 # 80010b30 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	07a50513          	add	a0,a0,122 # 80010b30 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	4a650513          	add	a0,a0,1190 # 80022f70 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	04448493          	add	s1,s1,68 # 80010b30 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	02c50513          	add	a0,a0,44 # 80010b30 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	00050513          	mv	a0,a0
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0) # 80010b30 <kmem>
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc091>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a4670713          	add	a4,a4,-1466 # 800088c8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	b16080e7          	jalr	-1258(ra) # 800029ce <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	4d0080e7          	jalr	1232(ra) # 80006390 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	07a080e7          	jalr	122(ra) # 80001f42 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	add	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	add	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	a76080e7          	jalr	-1418(ra) # 800029a6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	a96080e7          	jalr	-1386(ra) # 800029ce <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	43a080e7          	jalr	1082(ra) # 8000637a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	448080e7          	jalr	1096(ra) # 80006390 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	63e080e7          	jalr	1598(ra) # 8000358e <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	cdc080e7          	jalr	-804(ra) # 80003c34 <iinit>
    fileinit();      // file table
    80000f60:	00004097          	auipc	ra,0x4
    80000f64:	c52080e7          	jalr	-942(ra) # 80004bb2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	530080e7          	jalr	1328(ra) # 80006498 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	db4080e7          	jalr	-588(ra) # 80001d24 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	94f72523          	sw	a5,-1718(a4) # 800088c8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	add	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	93e7b783          	ld	a5,-1730(a5) # 800088d0 <kernel_pagetable>
    80000f9a:	83b1                	srl	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	sll	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	add	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	add	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	add	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srl	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	add	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srl	a5,s1,0xc
    80001006:	07aa                	sll	a5,a5,0xa
    80001008:	0017e793          	or	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc087>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	and	s2,s2,511
    8000101e:	090e                	sll	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	and	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srl	s1,s1,0xa
    8000102e:	04b2                	sll	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srl	a0,s3,0xc
    80001036:	1ff57513          	and	a0,a0,511
    8000103a:	050e                	sll	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	add	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srl	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	add	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	and	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	add	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srl	a5,a5,0xa
    8000108e:	00c79513          	sll	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	add	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	add	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	and	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srl	s1,s1,0xc
    800010e8:	04aa                	sll	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	or	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	add	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	add	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	add	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	add	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	add	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	add	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	add	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	add	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	add	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	add	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	sll	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	sll	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	add	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	sll	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	add	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	add	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	68a7b123          	sd	a0,1666(a5) # 800088d0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	add	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	add	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	sll	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	sll	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	add	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	add	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	add	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	add	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	add	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	and	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	and	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	sll	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	add	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	add	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	add	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	add	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	add	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	add	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	add	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	add	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	add	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	add	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	add	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	add	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	sll	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	add	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	and	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	and	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	add	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	add	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	add	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	add	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	add	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srl	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	add	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	add	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	and	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srl	a1,a4,0xa
    8000159e:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	add	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	add	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srl	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	add	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	add	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	and	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	add	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	add	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	add	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	add	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	add	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	add	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	add	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	add	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	add	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	add	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	add	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc090>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	add	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	add	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	add	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	add	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	74a48493          	add	s1,s1,1866 # 80010f90 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	add	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001860:	00016a17          	auipc	s4,0x16
    80001864:	330a0a13          	add	s4,s4,816 # 80017b90 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if (pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	8591                	sra	a1,a1,0x4
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addw	a1,a1,1
    80001884:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    8000189a:	1b048493          	add	s1,s1,432
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	add	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	add	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018c6:	7139                	add	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	add	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	add	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	26e50513          	add	a0,a0,622 # 80010b50 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	add	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	26e50513          	add	a0,a0,622 # 80010b68 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	68648493          	add	s1,s1,1670 # 80010f90 <proc>
  {
    initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	add	s6,s6,-1818 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	add	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000192c:	00016997          	auipc	s3,0x16
    80001930:	26498993          	add	s3,s3,612 # 80017b90 <tickslock>
    initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
    p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	8791                	sra	a5,a5,0x4
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addw	a5,a5,1
    80001954:	00d7979b          	sllw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	fcbc                	sd	a5,120(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000195e:	1b048493          	add	s1,s1,432
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
 
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	add	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000197a:	1141                	add	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	add	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000198a:	1141                	add	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	add	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	sll	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	1ea50513          	add	a0,a0,490 # 80010b80 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	add	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019a6:	1101                	add	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	add	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	sll	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	19270713          	add	a4,a4,402 # 80010b50 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	add	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019de:	1141                	add	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first)
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	e6a7a783          	lw	a5,-406(a5) # 80008860 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	fe6080e7          	jalr	-26(ra) # 800029e6 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	add	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	e407a823          	sw	zero,-432(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	19a080e7          	jalr	410(ra) # 80003bb4 <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	add	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	12090913          	add	s2,s2,288 # 80010b50 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	e2278793          	add	a5,a5,-478 # 80008864 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	add	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	add	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	add	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	add	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	sll	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	09093683          	ld	a3,144(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	sll	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	add	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	sll	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	add	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	add	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	sll	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	sll	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	add	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	add	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	add	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b64:	6948                	ld	a0,144(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0804b823          	sd	zero,144(s1)
  if (p->cpy_trapframe)
    80001b74:	6ca8                	ld	a0,88(s1)
    80001b76:	c509                	beqz	a0,80001b80 <freeproc+0x28>
    kfree((void *)p->cpy_trapframe);
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	e6c080e7          	jalr	-404(ra) # 800009e4 <kfree>
  p->cpy_trapframe = 0;
    80001b80:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b84:	64c8                	ld	a0,136(s1)
    80001b86:	c511                	beqz	a0,80001b92 <freeproc+0x3a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b88:	60cc                	ld	a1,128(s1)
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	f7c080e7          	jalr	-132(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b92:	0804b423          	sd	zero,136(s1)
  p->sz = 0;
    80001b96:	0804b023          	sd	zero,128(s1)
  p->pid = 0;
    80001b9a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba2:	18048823          	sb	zero,400(s1)
  p->chan = 0;
    80001ba6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001baa:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb2:	0004ac23          	sw	zero,24(s1)
  p->current_trun = 0;
    80001bb6:	0604a023          	sw	zero,96(s1)
  p->current_tsun = 0;
    80001bba:	0604a223          	sw	zero,100(s1)
  q_count[p->qprio]--;
    80001bbe:	54f8                	lw	a4,108(s1)
    80001bc0:	070a                	sll	a4,a4,0x2
    80001bc2:	0000f797          	auipc	a5,0xf
    80001bc6:	f8e78793          	add	a5,a5,-114 # 80010b50 <pid_lock>
    80001bca:	97ba                	add	a5,a5,a4
    80001bcc:	4307a703          	lw	a4,1072(a5)
    80001bd0:	377d                	addw	a4,a4,-1
    80001bd2:	42e7a823          	sw	a4,1072(a5)
  p->qprio=0;
    80001bd6:	0604a623          	sw	zero,108(s1)
  p->wait_time=0;
    80001bda:	0604a823          	sw	zero,112(s1)
}
    80001bde:	60e2                	ld	ra,24(sp)
    80001be0:	6442                	ld	s0,16(sp)
    80001be2:	64a2                	ld	s1,8(sp)
    80001be4:	6105                	add	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <allocproc>:
{
    80001be8:	1101                	add	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	e04a                	sd	s2,0(sp)
    80001bf2:	1000                	add	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf4:	0000f497          	auipc	s1,0xf
    80001bf8:	39c48493          	add	s1,s1,924 # 80010f90 <proc>
    80001bfc:	00016917          	auipc	s2,0x16
    80001c00:	f9490913          	add	s2,s2,-108 # 80017b90 <tickslock>
    acquire(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	fcc080e7          	jalr	-52(ra) # 80000bd2 <acquire>
    if (p->state == UNUSED)
    80001c0e:	4c9c                	lw	a5,24(s1)
    80001c10:	cf81                	beqz	a5,80001c28 <allocproc+0x40>
      release(&p->lock);
    80001c12:	8526                	mv	a0,s1
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	072080e7          	jalr	114(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c1c:	1b048493          	add	s1,s1,432
    80001c20:	ff2492e3          	bne	s1,s2,80001c04 <allocproc+0x1c>
  return 0;
    80001c24:	4481                	li	s1,0
    80001c26:	a065                	j	80001cce <allocproc+0xe6>
  p->pid = allocpid();
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	dfc080e7          	jalr	-516(ra) # 80001a24 <allocpid>
    80001c30:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c32:	4785                	li	a5,1
    80001c34:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	eac080e7          	jalr	-340(ra) # 80000ae2 <kalloc>
    80001c3e:	892a                	mv	s2,a0
    80001c40:	e8c8                	sd	a0,144(s1)
    80001c42:	cd49                	beqz	a0,80001cdc <allocproc+0xf4>
  if ((p->cpy_trapframe = (struct trapframe *)kalloc()) == 0)
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	e9e080e7          	jalr	-354(ra) # 80000ae2 <kalloc>
    80001c4c:	892a                	mv	s2,a0
    80001c4e:	eca8                	sd	a0,88(s1)
    80001c50:	c155                	beqz	a0,80001cf4 <allocproc+0x10c>
  p->pagetable = proc_pagetable(p);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	e16080e7          	jalr	-490(ra) # 80001a6a <proc_pagetable>
    80001c5c:	892a                	mv	s2,a0
    80001c5e:	e4c8                	sd	a0,136(s1)
  if (p->pagetable == 0)
    80001c60:	c555                	beqz	a0,80001d0c <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    80001c62:	07000613          	li	a2,112
    80001c66:	4581                	li	a1,0
    80001c68:	09848513          	add	a0,s1,152
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	062080e7          	jalr	98(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c74:	00000797          	auipc	a5,0x0
    80001c78:	d6a78793          	add	a5,a5,-662 # 800019de <forkret>
    80001c7c:	ecdc                	sd	a5,152(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c7e:	7cbc                	ld	a5,120(s1)
    80001c80:	6705                	lui	a4,0x1
    80001c82:	97ba                	add	a5,a5,a4
    80001c84:	f0dc                	sd	a5,160(s1)
  p->rtime = 0;
    80001c86:	1a04a023          	sw	zero,416(s1)
  p->etime = 0;
    80001c8a:	1a04a423          	sw	zero,424(s1)
  p->ctime = ticks;
    80001c8e:	00007717          	auipc	a4,0x7
    80001c92:	c5272703          	lw	a4,-942(a4) # 800088e0 <ticks>
    80001c96:	1ae4a223          	sw	a4,420(s1)
  p->readid = 0;
    80001c9a:	0404b023          	sd	zero,64(s1)
  p->sigalarm = 0;
    80001c9e:	0404a423          	sw	zero,72(s1)
  p->sigalarm_interval = -1;
    80001ca2:	57fd                	li	a5,-1
    80001ca4:	c4fc                	sw	a5,76(s1)
  p->sigalarm_handler = 0;
    80001ca6:	0404a823          	sw	zero,80(s1)
  p->CPU_ticks = 0;
    80001caa:	0404aa23          	sw	zero,84(s1)
  p->current_trun = 0;
    80001cae:	0604a023          	sw	zero,96(s1)
  p->current_tsun = 0;
    80001cb2:	0604a223          	sw	zero,100(s1)
  p->qprio=0;
    80001cb6:	0604a623          	sw	zero,108(s1)
  q_count[0]++;
    80001cba:	0000f697          	auipc	a3,0xf
    80001cbe:	e9668693          	add	a3,a3,-362 # 80010b50 <pid_lock>
    80001cc2:	4306a783          	lw	a5,1072(a3)
    80001cc6:	2785                	addw	a5,a5,1
    80001cc8:	42f6a823          	sw	a5,1072(a3)
  p->intime = ticks;
    80001ccc:	d4b8                	sw	a4,104(s1)
}
    80001cce:	8526                	mv	a0,s1
    80001cd0:	60e2                	ld	ra,24(sp)
    80001cd2:	6442                	ld	s0,16(sp)
    80001cd4:	64a2                	ld	s1,8(sp)
    80001cd6:	6902                	ld	s2,0(sp)
    80001cd8:	6105                	add	sp,sp,32
    80001cda:	8082                	ret
    freeproc(p);
    80001cdc:	8526                	mv	a0,s1
    80001cde:	00000097          	auipc	ra,0x0
    80001ce2:	e7a080e7          	jalr	-390(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	f9e080e7          	jalr	-98(ra) # 80000c86 <release>
    return 0;
    80001cf0:	84ca                	mv	s1,s2
    80001cf2:	bff1                	j	80001cce <allocproc+0xe6>
    freeproc(p);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	00000097          	auipc	ra,0x0
    80001cfa:	e62080e7          	jalr	-414(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	f86080e7          	jalr	-122(ra) # 80000c86 <release>
    return 0;
    80001d08:	84ca                	mv	s1,s2
    80001d0a:	b7d1                	j	80001cce <allocproc+0xe6>
    freeproc(p);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	e4a080e7          	jalr	-438(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	f6e080e7          	jalr	-146(ra) # 80000c86 <release>
    return 0;
    80001d20:	84ca                	mv	s1,s2
    80001d22:	b775                	j	80001cce <allocproc+0xe6>

0000000080001d24 <userinit>:
{
    80001d24:	1101                	add	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	1000                	add	s0,sp,32
  p = allocproc();
    80001d2e:	00000097          	auipc	ra,0x0
    80001d32:	eba080e7          	jalr	-326(ra) # 80001be8 <allocproc>
    80001d36:	84aa                	mv	s1,a0
  initproc = p;
    80001d38:	00007797          	auipc	a5,0x7
    80001d3c:	baa7b023          	sd	a0,-1120(a5) # 800088d8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d40:	03400613          	li	a2,52
    80001d44:	00007597          	auipc	a1,0x7
    80001d48:	b2c58593          	add	a1,a1,-1236 # 80008870 <initcode>
    80001d4c:	6548                	ld	a0,136(a0)
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	602080e7          	jalr	1538(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001d56:	6785                	lui	a5,0x1
    80001d58:	e0dc                	sd	a5,128(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d5a:	68d8                	ld	a4,144(s1)
    80001d5c:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d60:	68d8                	ld	a4,144(s1)
    80001d62:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d64:	4641                	li	a2,16
    80001d66:	00006597          	auipc	a1,0x6
    80001d6a:	49a58593          	add	a1,a1,1178 # 80008200 <digits+0x1c0>
    80001d6e:	19048513          	add	a0,s1,400
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	0a4080e7          	jalr	164(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	49650513          	add	a0,a0,1174 # 80008210 <digits+0x1d0>
    80001d82:	00003097          	auipc	ra,0x3
    80001d86:	850080e7          	jalr	-1968(ra) # 800045d2 <namei>
    80001d8a:	18a4b423          	sd	a0,392(s1)
  p->state = RUNNABLE;
    80001d8e:	478d                	li	a5,3
    80001d90:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d92:	8526                	mv	a0,s1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	ef2080e7          	jalr	-270(ra) # 80000c86 <release>
}
    80001d9c:	60e2                	ld	ra,24(sp)
    80001d9e:	6442                	ld	s0,16(sp)
    80001da0:	64a2                	ld	s1,8(sp)
    80001da2:	6105                	add	sp,sp,32
    80001da4:	8082                	ret

0000000080001da6 <growproc>:
{
    80001da6:	1101                	add	sp,sp,-32
    80001da8:	ec06                	sd	ra,24(sp)
    80001daa:	e822                	sd	s0,16(sp)
    80001dac:	e426                	sd	s1,8(sp)
    80001dae:	e04a                	sd	s2,0(sp)
    80001db0:	1000                	add	s0,sp,32
    80001db2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	bf2080e7          	jalr	-1038(ra) # 800019a6 <myproc>
    80001dbc:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dbe:	614c                	ld	a1,128(a0)
  if (n > 0)
    80001dc0:	01204c63          	bgtz	s2,80001dd8 <growproc+0x32>
  else if (n < 0)
    80001dc4:	02094663          	bltz	s2,80001df0 <growproc+0x4a>
  p->sz = sz;
    80001dc8:	e0cc                	sd	a1,128(s1)
  return 0;
    80001dca:	4501                	li	a0,0
}
    80001dcc:	60e2                	ld	ra,24(sp)
    80001dce:	6442                	ld	s0,16(sp)
    80001dd0:	64a2                	ld	s1,8(sp)
    80001dd2:	6902                	ld	s2,0(sp)
    80001dd4:	6105                	add	sp,sp,32
    80001dd6:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001dd8:	4691                	li	a3,4
    80001dda:	00b90633          	add	a2,s2,a1
    80001dde:	6548                	ld	a0,136(a0)
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	62a080e7          	jalr	1578(ra) # 8000140a <uvmalloc>
    80001de8:	85aa                	mv	a1,a0
    80001dea:	fd79                	bnez	a0,80001dc8 <growproc+0x22>
      return -1;
    80001dec:	557d                	li	a0,-1
    80001dee:	bff9                	j	80001dcc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df0:	00b90633          	add	a2,s2,a1
    80001df4:	6548                	ld	a0,136(a0)
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	5cc080e7          	jalr	1484(ra) # 800013c2 <uvmdealloc>
    80001dfe:	85aa                	mv	a1,a0
    80001e00:	b7e1                	j	80001dc8 <growproc+0x22>

0000000080001e02 <fork>:
{
    80001e02:	7139                	add	sp,sp,-64
    80001e04:	fc06                	sd	ra,56(sp)
    80001e06:	f822                	sd	s0,48(sp)
    80001e08:	f426                	sd	s1,40(sp)
    80001e0a:	f04a                	sd	s2,32(sp)
    80001e0c:	ec4e                	sd	s3,24(sp)
    80001e0e:	e852                	sd	s4,16(sp)
    80001e10:	e456                	sd	s5,8(sp)
    80001e12:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	b92080e7          	jalr	-1134(ra) # 800019a6 <myproc>
    80001e1c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	dca080e7          	jalr	-566(ra) # 80001be8 <allocproc>
    80001e26:	10050c63          	beqz	a0,80001f3e <fork+0x13c>
    80001e2a:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e2c:	080ab603          	ld	a2,128(s5)
    80001e30:	654c                	ld	a1,136(a0)
    80001e32:	088ab503          	ld	a0,136(s5)
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	72c080e7          	jalr	1836(ra) # 80001562 <uvmcopy>
    80001e3e:	04054863          	bltz	a0,80001e8e <fork+0x8c>
  np->sz = p->sz;
    80001e42:	080ab783          	ld	a5,128(s5)
    80001e46:	08fa3023          	sd	a5,128(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e4a:	090ab683          	ld	a3,144(s5)
    80001e4e:	87b6                	mv	a5,a3
    80001e50:	090a3703          	ld	a4,144(s4)
    80001e54:	12068693          	add	a3,a3,288
    80001e58:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5c:	6788                	ld	a0,8(a5)
    80001e5e:	6b8c                	ld	a1,16(a5)
    80001e60:	6f90                	ld	a2,24(a5)
    80001e62:	01073023          	sd	a6,0(a4)
    80001e66:	e708                	sd	a0,8(a4)
    80001e68:	eb0c                	sd	a1,16(a4)
    80001e6a:	ef10                	sd	a2,24(a4)
    80001e6c:	02078793          	add	a5,a5,32
    80001e70:	02070713          	add	a4,a4,32
    80001e74:	fed792e3          	bne	a5,a3,80001e58 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e78:	090a3783          	ld	a5,144(s4)
    80001e7c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e80:	108a8493          	add	s1,s5,264
    80001e84:	108a0913          	add	s2,s4,264
    80001e88:	188a8993          	add	s3,s5,392
    80001e8c:	a00d                	j	80001eae <fork+0xac>
    freeproc(np);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	cc8080e7          	jalr	-824(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001e98:	8552                	mv	a0,s4
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	dec080e7          	jalr	-532(ra) # 80000c86 <release>
    return -1;
    80001ea2:	597d                	li	s2,-1
    80001ea4:	a059                	j	80001f2a <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	add	s1,s1,8
    80001ea8:	0921                	add	s2,s2,8
    80001eaa:	01348b63          	beq	s1,s3,80001ec0 <fork+0xbe>
    if (p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00003097          	auipc	ra,0x3
    80001eb6:	d92080e7          	jalr	-622(ra) # 80004c44 <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ec0:	188ab503          	ld	a0,392(s5)
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	f2a080e7          	jalr	-214(ra) # 80003dee <idup>
    80001ecc:	18aa3423          	sd	a0,392(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	190a8593          	add	a1,s5,400
    80001ed6:	190a0513          	add	a0,s4,400
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f3c080e7          	jalr	-196(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	d9e080e7          	jalr	-610(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001ef0:	0000f497          	auipc	s1,0xf
    80001ef4:	c7848493          	add	s1,s1,-904 # 80010b68 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cd8080e7          	jalr	-808(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f02:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d7e080e7          	jalr	-642(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cc0080e7          	jalr	-832(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f20:	8552                	mv	a0,s4
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d64080e7          	jalr	-668(ra) # 80000c86 <release>
}
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	70e2                	ld	ra,56(sp)
    80001f2e:	7442                	ld	s0,48(sp)
    80001f30:	74a2                	ld	s1,40(sp)
    80001f32:	7902                	ld	s2,32(sp)
    80001f34:	69e2                	ld	s3,24(sp)
    80001f36:	6a42                	ld	s4,16(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	add	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	b7ed                	j	80001f2a <fork+0x128>

0000000080001f42 <scheduler>:
{
    80001f42:	7139                	add	sp,sp,-64
    80001f44:	fc06                	sd	ra,56(sp)
    80001f46:	f822                	sd	s0,48(sp)
    80001f48:	f426                	sd	s1,40(sp)
    80001f4a:	f04a                	sd	s2,32(sp)
    80001f4c:	ec4e                	sd	s3,24(sp)
    80001f4e:	e852                	sd	s4,16(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	e05a                	sd	s6,0(sp)
    80001f54:	0080                	add	s0,sp,64
    80001f56:	8792                	mv	a5,tp
  int id = r_tp();
    80001f58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5a:	00779693          	sll	a3,a5,0x7
    80001f5e:	0000f717          	auipc	a4,0xf
    80001f62:	bf270713          	add	a4,a4,-1038 # 80010b50 <pid_lock>
    80001f66:	9736                	add	a4,a4,a3
    80001f68:	02073823          	sd	zero,48(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f6c:	10002773          	csrr	a4,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f70:	00276713          	or	a4,a4,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f74:	10071073          	csrw	sstatus,a4
      swtch(&c->context, &temp->context);
    80001f78:	0000f717          	auipc	a4,0xf
    80001f7c:	c1070713          	add	a4,a4,-1008 # 80010b88 <cpus+0x8>
    80001f80:	00e68b33          	add	s6,a3,a4
    for(int i=0;i<3;i++)
    80001f84:	4901                	li	s2,0
    uint64 min_intime = 1000000000;
    80001f86:	3b9ad9b7          	lui	s3,0x3b9ad
    80001f8a:	a0098993          	add	s3,s3,-1536 # 3b9aca00 <_entry-0x44653600>
      for(struct proc* p = proc; p < &proc[NPROC]; p++)
    80001f8e:	00016497          	auipc	s1,0x16
    80001f92:	c0248493          	add	s1,s1,-1022 # 80017b90 <tickslock>
      c->proc = temp;
    80001f96:	0000fa17          	auipc	s4,0xf
    80001f9a:	bbaa0a13          	add	s4,s4,-1094 # 80010b50 <pid_lock>
    80001f9e:	9a36                	add	s4,s4,a3
    80001fa0:	a871                	j	8000203c <scheduler+0xfa>
        for(struct proc* p = proc; p<&proc[NPROC]; p++){
    80001fa2:	1b078793          	add	a5,a5,432
    80001fa6:	00978f63          	beq	a5,s1,80001fc4 <scheduler+0x82>
          if(p->qprio != i) continue;
    80001faa:	57f8                	lw	a4,108(a5)
    80001fac:	fed71be3          	bne	a4,a3,80001fa2 <scheduler+0x60>
          if(p->state != RUNNABLE) continue;
    80001fb0:	4f98                	lw	a4,24(a5)
    80001fb2:	fec718e3          	bne	a4,a2,80001fa2 <scheduler+0x60>
          if(p->intime < min_intime){
    80001fb6:	57b8                	lw	a4,104(a5)
    80001fb8:	feb775e3          	bgeu	a4,a1,80001fa2 <scheduler+0x60>
            min_intime = p->intime;
    80001fbc:	85ba                	mv	a1,a4
    80001fbe:	883e                	mv	a6,a5
            found = 1;
    80001fc0:	851a                	mv	a0,t1
    80001fc2:	b7c5                	j	80001fa2 <scheduler+0x60>
        if(found==1) break;
    80001fc4:	08650363          	beq	a0,t1,8000204a <scheduler+0x108>
    for(int i=0;i<3;i++)
    80001fc8:	2685                	addw	a3,a3,1
    80001fca:	0891                	add	a7,a7,4
    80001fcc:	00c68c63          	beq	a3,a2,80001fe4 <scheduler+0xa2>
      if(q_count[i]>0)
    80001fd0:	0008a783          	lw	a5,0(a7)
    80001fd4:	fef05ae3          	blez	a5,80001fc8 <scheduler+0x86>
        for(struct proc* p = proc; p<&proc[NPROC]; p++){
    80001fd8:	0000f797          	auipc	a5,0xf
    80001fdc:	fb878793          	add	a5,a5,-72 # 80010f90 <proc>
    80001fe0:	854a                	mv	a0,s2
    80001fe2:	b7e1                	j	80001faa <scheduler+0x68>
      for(struct proc* p = proc; p < &proc[NPROC]; p++)
    80001fe4:	0000fa97          	auipc	s5,0xf
    80001fe8:	faca8a93          	add	s5,s5,-84 # 80010f90 <proc>
        if(p->state != RUNNABLE) continue;
    80001fec:	018aa783          	lw	a5,24(s5)
    80001ff0:	04c79963          	bne	a5,a2,80002042 <scheduler+0x100>
    if(temp!=0 && temp->state == RUNNABLE) {
    80001ff4:	018aa783          	lw	a5,24(s5)
    80001ff8:	04c79b63          	bne	a5,a2,8000204e <scheduler+0x10c>
      acquire(&temp->lock);
    80001ffc:	8556                	mv	a0,s5
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	bd4080e7          	jalr	-1068(ra) # 80000bd2 <acquire>
      temp->state = RUNNING;
    80002006:	4791                	li	a5,4
    80002008:	00faac23          	sw	a5,24(s5)
      c->proc = temp;
    8000200c:	035a3823          	sd	s5,48(s4)
      temp->wait_time = 0;
    80002010:	060aa823          	sw	zero,112(s5)
      swtch(&c->context, &temp->context);
    80002014:	098a8593          	add	a1,s5,152
    80002018:	855a                	mv	a0,s6
    8000201a:	00001097          	auipc	ra,0x1
    8000201e:	922080e7          	jalr	-1758(ra) # 8000293c <swtch>
      temp->current_tsun = 0;
    80002022:	060aa223          	sw	zero,100(s5)
      temp->current_trun = 0;
    80002026:	060aa023          	sw	zero,96(s5)
      temp->wait_time = 0;
    8000202a:	060aa823          	sw	zero,112(s5)
      c->proc = 0;
    8000202e:	020a3823          	sd	zero,48(s4)
      release(&temp->lock);
    80002032:	8556                	mv	a0,s5
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c52080e7          	jalr	-942(ra) # 80000c86 <release>
    for(int i=0;i<3;i++)
    8000203c:	460d                	li	a2,3
            found = 1;
    8000203e:	4305                	li	t1,1
    80002040:	a039                	j	8000204e <scheduler+0x10c>
      for(struct proc* p = proc; p < &proc[NPROC]; p++)
    80002042:	1b0a8a93          	add	s5,s5,432
    80002046:	fa9a93e3          	bne	s5,s1,80001fec <scheduler+0xaa>
    if(temp!=0 && temp->state == RUNNABLE) {
    8000204a:	02081063          	bnez	a6,8000206a <scheduler+0x128>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002052:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002056:	10079073          	csrw	sstatus,a5
    for(int i=0;i<3;i++)
    8000205a:	0000f897          	auipc	a7,0xf
    8000205e:	f2688893          	add	a7,a7,-218 # 80010f80 <q_count>
    80002062:	86ca                	mv	a3,s2
    uint64 min_intime = 1000000000;
    80002064:	85ce                	mv	a1,s3
    struct proc* temp = 0;
    80002066:	884a                	mv	a6,s2
    80002068:	b7a5                	j	80001fd0 <scheduler+0x8e>
    8000206a:	8ac2                	mv	s5,a6
    8000206c:	b761                	j	80001ff4 <scheduler+0xb2>

000000008000206e <sched>:
{
    8000206e:	7179                	add	sp,sp,-48
    80002070:	f406                	sd	ra,40(sp)
    80002072:	f022                	sd	s0,32(sp)
    80002074:	ec26                	sd	s1,24(sp)
    80002076:	e84a                	sd	s2,16(sp)
    80002078:	e44e                	sd	s3,8(sp)
    8000207a:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	92a080e7          	jalr	-1750(ra) # 800019a6 <myproc>
    80002084:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	ad2080e7          	jalr	-1326(ra) # 80000b58 <holding>
    8000208e:	c93d                	beqz	a0,80002104 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002090:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002092:	2781                	sext.w	a5,a5
    80002094:	079e                	sll	a5,a5,0x7
    80002096:	0000f717          	auipc	a4,0xf
    8000209a:	aba70713          	add	a4,a4,-1350 # 80010b50 <pid_lock>
    8000209e:	97ba                	add	a5,a5,a4
    800020a0:	0a87a703          	lw	a4,168(a5)
    800020a4:	4785                	li	a5,1
    800020a6:	06f71763          	bne	a4,a5,80002114 <sched+0xa6>
  if (p->state == RUNNING)
    800020aa:	4c98                	lw	a4,24(s1)
    800020ac:	4791                	li	a5,4
    800020ae:	06f70b63          	beq	a4,a5,80002124 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020b6:	8b89                	and	a5,a5,2
  if (intr_get())
    800020b8:	efb5                	bnez	a5,80002134 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ba:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020bc:	0000f917          	auipc	s2,0xf
    800020c0:	a9490913          	add	s2,s2,-1388 # 80010b50 <pid_lock>
    800020c4:	2781                	sext.w	a5,a5
    800020c6:	079e                	sll	a5,a5,0x7
    800020c8:	97ca                	add	a5,a5,s2
    800020ca:	0ac7a983          	lw	s3,172(a5)
    800020ce:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020d0:	2781                	sext.w	a5,a5
    800020d2:	079e                	sll	a5,a5,0x7
    800020d4:	0000f597          	auipc	a1,0xf
    800020d8:	ab458593          	add	a1,a1,-1356 # 80010b88 <cpus+0x8>
    800020dc:	95be                	add	a1,a1,a5
    800020de:	09848513          	add	a0,s1,152
    800020e2:	00001097          	auipc	ra,0x1
    800020e6:	85a080e7          	jalr	-1958(ra) # 8000293c <swtch>
    800020ea:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020ec:	2781                	sext.w	a5,a5
    800020ee:	079e                	sll	a5,a5,0x7
    800020f0:	993e                	add	s2,s2,a5
    800020f2:	0b392623          	sw	s3,172(s2)
}
    800020f6:	70a2                	ld	ra,40(sp)
    800020f8:	7402                	ld	s0,32(sp)
    800020fa:	64e2                	ld	s1,24(sp)
    800020fc:	6942                	ld	s2,16(sp)
    800020fe:	69a2                	ld	s3,8(sp)
    80002100:	6145                	add	sp,sp,48
    80002102:	8082                	ret
    panic("sched p->lock");
    80002104:	00006517          	auipc	a0,0x6
    80002108:	11450513          	add	a0,a0,276 # 80008218 <digits+0x1d8>
    8000210c:	ffffe097          	auipc	ra,0xffffe
    80002110:	430080e7          	jalr	1072(ra) # 8000053c <panic>
    panic("sched locks");
    80002114:	00006517          	auipc	a0,0x6
    80002118:	11450513          	add	a0,a0,276 # 80008228 <digits+0x1e8>
    8000211c:	ffffe097          	auipc	ra,0xffffe
    80002120:	420080e7          	jalr	1056(ra) # 8000053c <panic>
    panic("sched running");
    80002124:	00006517          	auipc	a0,0x6
    80002128:	11450513          	add	a0,a0,276 # 80008238 <digits+0x1f8>
    8000212c:	ffffe097          	auipc	ra,0xffffe
    80002130:	410080e7          	jalr	1040(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002134:	00006517          	auipc	a0,0x6
    80002138:	11450513          	add	a0,a0,276 # 80008248 <digits+0x208>
    8000213c:	ffffe097          	auipc	ra,0xffffe
    80002140:	400080e7          	jalr	1024(ra) # 8000053c <panic>

0000000080002144 <yield>:
{
    80002144:	1101                	add	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	858080e7          	jalr	-1960(ra) # 800019a6 <myproc>
    80002156:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	a7a080e7          	jalr	-1414(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002160:	478d                	li	a5,3
    80002162:	cc9c                	sw	a5,24(s1)
  sched();
    80002164:	00000097          	auipc	ra,0x0
    80002168:	f0a080e7          	jalr	-246(ra) # 8000206e <sched>
  release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	b18080e7          	jalr	-1256(ra) # 80000c86 <release>
}
    80002176:	60e2                	ld	ra,24(sp)
    80002178:	6442                	ld	s0,16(sp)
    8000217a:	64a2                	ld	s1,8(sp)
    8000217c:	6105                	add	sp,sp,32
    8000217e:	8082                	ret

0000000080002180 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002180:	7179                	add	sp,sp,-48
    80002182:	f406                	sd	ra,40(sp)
    80002184:	f022                	sd	s0,32(sp)
    80002186:	ec26                	sd	s1,24(sp)
    80002188:	e84a                	sd	s2,16(sp)
    8000218a:	e44e                	sd	s3,8(sp)
    8000218c:	1800                	add	s0,sp,48
    8000218e:	89aa                	mv	s3,a0
    80002190:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002192:	00000097          	auipc	ra,0x0
    80002196:	814080e7          	jalr	-2028(ra) # 800019a6 <myproc>
    8000219a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	a36080e7          	jalr	-1482(ra) # 80000bd2 <acquire>
  release(lk);
    800021a4:	854a                	mv	a0,s2
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	ae0080e7          	jalr	-1312(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800021ae:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021b2:	4789                	li	a5,2
    800021b4:	cc9c                	sw	a5,24(s1)

  sched();
    800021b6:	00000097          	auipc	ra,0x0
    800021ba:	eb8080e7          	jalr	-328(ra) # 8000206e <sched>

  // Tidy up.
  p->chan = 0;
    800021be:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021c2:	8526                	mv	a0,s1
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	ac2080e7          	jalr	-1342(ra) # 80000c86 <release>
  acquire(lk);
    800021cc:	854a                	mv	a0,s2
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	a04080e7          	jalr	-1532(ra) # 80000bd2 <acquire>
}
    800021d6:	70a2                	ld	ra,40(sp)
    800021d8:	7402                	ld	s0,32(sp)
    800021da:	64e2                	ld	s1,24(sp)
    800021dc:	6942                	ld	s2,16(sp)
    800021de:	69a2                	ld	s3,8(sp)
    800021e0:	6145                	add	sp,sp,48
    800021e2:	8082                	ret

00000000800021e4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800021e4:	7139                	add	sp,sp,-64
    800021e6:	fc06                	sd	ra,56(sp)
    800021e8:	f822                	sd	s0,48(sp)
    800021ea:	f426                	sd	s1,40(sp)
    800021ec:	f04a                	sd	s2,32(sp)
    800021ee:	ec4e                	sd	s3,24(sp)
    800021f0:	e852                	sd	s4,16(sp)
    800021f2:	e456                	sd	s5,8(sp)
    800021f4:	e05a                	sd	s6,0(sp)
    800021f6:	0080                	add	s0,sp,64
    800021f8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800021fa:	0000f497          	auipc	s1,0xf
    800021fe:	d9648493          	add	s1,s1,-618 # 80010f90 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002202:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002204:	4b0d                	li	s6,3
        #ifdef MLFQ
        p->intime = ticks;
    80002206:	00006a97          	auipc	s5,0x6
    8000220a:	6daa8a93          	add	s5,s5,1754 # 800088e0 <ticks>
  for (p = proc; p < &proc[NPROC]; p++)
    8000220e:	00016917          	auipc	s2,0x16
    80002212:	98290913          	add	s2,s2,-1662 # 80017b90 <tickslock>
    80002216:	a811                	j	8000222a <wakeup+0x46>
        #endif
      }
      release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a6c080e7          	jalr	-1428(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002222:	1b048493          	add	s1,s1,432
    80002226:	03248963          	beq	s1,s2,80002258 <wakeup+0x74>
    if (p != myproc())
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	77c080e7          	jalr	1916(ra) # 800019a6 <myproc>
    80002232:	fea488e3          	beq	s1,a0,80002222 <wakeup+0x3e>
      acquire(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	99a080e7          	jalr	-1638(ra) # 80000bd2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002240:	4c9c                	lw	a5,24(s1)
    80002242:	fd379be3          	bne	a5,s3,80002218 <wakeup+0x34>
    80002246:	709c                	ld	a5,32(s1)
    80002248:	fd4798e3          	bne	a5,s4,80002218 <wakeup+0x34>
        p->state = RUNNABLE;
    8000224c:	0164ac23          	sw	s6,24(s1)
        p->intime = ticks;
    80002250:	000aa783          	lw	a5,0(s5)
    80002254:	d4bc                	sw	a5,104(s1)
    80002256:	b7c9                	j	80002218 <wakeup+0x34>
    }
  }
}
    80002258:	70e2                	ld	ra,56(sp)
    8000225a:	7442                	ld	s0,48(sp)
    8000225c:	74a2                	ld	s1,40(sp)
    8000225e:	7902                	ld	s2,32(sp)
    80002260:	69e2                	ld	s3,24(sp)
    80002262:	6a42                	ld	s4,16(sp)
    80002264:	6aa2                	ld	s5,8(sp)
    80002266:	6b02                	ld	s6,0(sp)
    80002268:	6121                	add	sp,sp,64
    8000226a:	8082                	ret

000000008000226c <reparent>:
{
    8000226c:	7179                	add	sp,sp,-48
    8000226e:	f406                	sd	ra,40(sp)
    80002270:	f022                	sd	s0,32(sp)
    80002272:	ec26                	sd	s1,24(sp)
    80002274:	e84a                	sd	s2,16(sp)
    80002276:	e44e                	sd	s3,8(sp)
    80002278:	e052                	sd	s4,0(sp)
    8000227a:	1800                	add	s0,sp,48
    8000227c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000227e:	0000f497          	auipc	s1,0xf
    80002282:	d1248493          	add	s1,s1,-750 # 80010f90 <proc>
      pp->parent = initproc;
    80002286:	00006a17          	auipc	s4,0x6
    8000228a:	652a0a13          	add	s4,s4,1618 # 800088d8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000228e:	00016997          	auipc	s3,0x16
    80002292:	90298993          	add	s3,s3,-1790 # 80017b90 <tickslock>
    80002296:	a029                	j	800022a0 <reparent+0x34>
    80002298:	1b048493          	add	s1,s1,432
    8000229c:	01348d63          	beq	s1,s3,800022b6 <reparent+0x4a>
    if (pp->parent == p)
    800022a0:	7c9c                	ld	a5,56(s1)
    800022a2:	ff279be3          	bne	a5,s2,80002298 <reparent+0x2c>
      pp->parent = initproc;
    800022a6:	000a3503          	ld	a0,0(s4)
    800022aa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	f38080e7          	jalr	-200(ra) # 800021e4 <wakeup>
    800022b4:	b7d5                	j	80002298 <reparent+0x2c>
}
    800022b6:	70a2                	ld	ra,40(sp)
    800022b8:	7402                	ld	s0,32(sp)
    800022ba:	64e2                	ld	s1,24(sp)
    800022bc:	6942                	ld	s2,16(sp)
    800022be:	69a2                	ld	s3,8(sp)
    800022c0:	6a02                	ld	s4,0(sp)
    800022c2:	6145                	add	sp,sp,48
    800022c4:	8082                	ret

00000000800022c6 <exit>:
{
    800022c6:	7179                	add	sp,sp,-48
    800022c8:	f406                	sd	ra,40(sp)
    800022ca:	f022                	sd	s0,32(sp)
    800022cc:	ec26                	sd	s1,24(sp)
    800022ce:	e84a                	sd	s2,16(sp)
    800022d0:	e44e                	sd	s3,8(sp)
    800022d2:	e052                	sd	s4,0(sp)
    800022d4:	1800                	add	s0,sp,48
    800022d6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	6ce080e7          	jalr	1742(ra) # 800019a6 <myproc>
    800022e0:	89aa                	mv	s3,a0
  if (p == initproc)
    800022e2:	00006797          	auipc	a5,0x6
    800022e6:	5f67b783          	ld	a5,1526(a5) # 800088d8 <initproc>
    800022ea:	10850493          	add	s1,a0,264
    800022ee:	18850913          	add	s2,a0,392
    800022f2:	02a79363          	bne	a5,a0,80002318 <exit+0x52>
    panic("init exiting");
    800022f6:	00006517          	auipc	a0,0x6
    800022fa:	f6a50513          	add	a0,a0,-150 # 80008260 <digits+0x220>
    800022fe:	ffffe097          	auipc	ra,0xffffe
    80002302:	23e080e7          	jalr	574(ra) # 8000053c <panic>
      fileclose(f);
    80002306:	00003097          	auipc	ra,0x3
    8000230a:	990080e7          	jalr	-1648(ra) # 80004c96 <fileclose>
      p->ofile[fd] = 0;
    8000230e:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002312:	04a1                	add	s1,s1,8
    80002314:	01248563          	beq	s1,s2,8000231e <exit+0x58>
    if (p->ofile[fd])
    80002318:	6088                	ld	a0,0(s1)
    8000231a:	f575                	bnez	a0,80002306 <exit+0x40>
    8000231c:	bfdd                	j	80002312 <exit+0x4c>
  begin_op();
    8000231e:	00002097          	auipc	ra,0x2
    80002322:	4b4080e7          	jalr	1204(ra) # 800047d2 <begin_op>
  iput(p->cwd);
    80002326:	1889b503          	ld	a0,392(s3)
    8000232a:	00002097          	auipc	ra,0x2
    8000232e:	cbc080e7          	jalr	-836(ra) # 80003fe6 <iput>
  end_op();
    80002332:	00002097          	auipc	ra,0x2
    80002336:	51a080e7          	jalr	1306(ra) # 8000484c <end_op>
  p->cwd = 0;
    8000233a:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    8000233e:	0000f497          	auipc	s1,0xf
    80002342:	82a48493          	add	s1,s1,-2006 # 80010b68 <wait_lock>
    80002346:	8526                	mv	a0,s1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	88a080e7          	jalr	-1910(ra) # 80000bd2 <acquire>
  reparent(p);
    80002350:	854e                	mv	a0,s3
    80002352:	00000097          	auipc	ra,0x0
    80002356:	f1a080e7          	jalr	-230(ra) # 8000226c <reparent>
  wakeup(p->parent);
    8000235a:	0389b503          	ld	a0,56(s3)
    8000235e:	00000097          	auipc	ra,0x0
    80002362:	e86080e7          	jalr	-378(ra) # 800021e4 <wakeup>
  acquire(&p->lock);
    80002366:	854e                	mv	a0,s3
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	86a080e7          	jalr	-1942(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002370:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002374:	4795                	li	a5,5
    80002376:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000237a:	00006797          	auipc	a5,0x6
    8000237e:	5667a783          	lw	a5,1382(a5) # 800088e0 <ticks>
    80002382:	1af9a423          	sw	a5,424(s3)
  release(&wait_lock);
    80002386:	8526                	mv	a0,s1
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	8fe080e7          	jalr	-1794(ra) # 80000c86 <release>
  sched();
    80002390:	00000097          	auipc	ra,0x0
    80002394:	cde080e7          	jalr	-802(ra) # 8000206e <sched>
  panic("zombie exit");
    80002398:	00006517          	auipc	a0,0x6
    8000239c:	ed850513          	add	a0,a0,-296 # 80008270 <digits+0x230>
    800023a0:	ffffe097          	auipc	ra,0xffffe
    800023a4:	19c080e7          	jalr	412(ra) # 8000053c <panic>

00000000800023a8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023a8:	7179                	add	sp,sp,-48
    800023aa:	f406                	sd	ra,40(sp)
    800023ac:	f022                	sd	s0,32(sp)
    800023ae:	ec26                	sd	s1,24(sp)
    800023b0:	e84a                	sd	s2,16(sp)
    800023b2:	e44e                	sd	s3,8(sp)
    800023b4:	1800                	add	s0,sp,48
    800023b6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023b8:	0000f497          	auipc	s1,0xf
    800023bc:	bd848493          	add	s1,s1,-1064 # 80010f90 <proc>
    800023c0:	00015997          	auipc	s3,0x15
    800023c4:	7d098993          	add	s3,s3,2000 # 80017b90 <tickslock>
  {
    acquire(&p->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	808080e7          	jalr	-2040(ra) # 80000bd2 <acquire>
    if (p->pid == pid)
    800023d2:	589c                	lw	a5,48(s1)
    800023d4:	01278d63          	beq	a5,s2,800023ee <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023d8:	8526                	mv	a0,s1
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	8ac080e7          	jalr	-1876(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023e2:	1b048493          	add	s1,s1,432
    800023e6:	ff3491e3          	bne	s1,s3,800023c8 <kill+0x20>
  }
  return -1;
    800023ea:	557d                	li	a0,-1
    800023ec:	a829                	j	80002406 <kill+0x5e>
      p->killed = 1;
    800023ee:	4785                	li	a5,1
    800023f0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800023f2:	4c98                	lw	a4,24(s1)
    800023f4:	4789                	li	a5,2
    800023f6:	00f70f63          	beq	a4,a5,80002414 <kill+0x6c>
      release(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	88a080e7          	jalr	-1910(ra) # 80000c86 <release>
      return 0;
    80002404:	4501                	li	a0,0
}
    80002406:	70a2                	ld	ra,40(sp)
    80002408:	7402                	ld	s0,32(sp)
    8000240a:	64e2                	ld	s1,24(sp)
    8000240c:	6942                	ld	s2,16(sp)
    8000240e:	69a2                	ld	s3,8(sp)
    80002410:	6145                	add	sp,sp,48
    80002412:	8082                	ret
        p->state = RUNNABLE;
    80002414:	478d                	li	a5,3
    80002416:	cc9c                	sw	a5,24(s1)
    80002418:	b7cd                	j	800023fa <kill+0x52>

000000008000241a <setkilled>:

void setkilled(struct proc *p)
{
    8000241a:	1101                	add	sp,sp,-32
    8000241c:	ec06                	sd	ra,24(sp)
    8000241e:	e822                	sd	s0,16(sp)
    80002420:	e426                	sd	s1,8(sp)
    80002422:	1000                	add	s0,sp,32
    80002424:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002426:	ffffe097          	auipc	ra,0xffffe
    8000242a:	7ac080e7          	jalr	1964(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000242e:	4785                	li	a5,1
    80002430:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	852080e7          	jalr	-1966(ra) # 80000c86 <release>
}
    8000243c:	60e2                	ld	ra,24(sp)
    8000243e:	6442                	ld	s0,16(sp)
    80002440:	64a2                	ld	s1,8(sp)
    80002442:	6105                	add	sp,sp,32
    80002444:	8082                	ret

0000000080002446 <killed>:

int killed(struct proc *p)
{
    80002446:	1101                	add	sp,sp,-32
    80002448:	ec06                	sd	ra,24(sp)
    8000244a:	e822                	sd	s0,16(sp)
    8000244c:	e426                	sd	s1,8(sp)
    8000244e:	e04a                	sd	s2,0(sp)
    80002450:	1000                	add	s0,sp,32
    80002452:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	77e080e7          	jalr	1918(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000245c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	824080e7          	jalr	-2012(ra) # 80000c86 <release>
  return k;
}
    8000246a:	854a                	mv	a0,s2
    8000246c:	60e2                	ld	ra,24(sp)
    8000246e:	6442                	ld	s0,16(sp)
    80002470:	64a2                	ld	s1,8(sp)
    80002472:	6902                	ld	s2,0(sp)
    80002474:	6105                	add	sp,sp,32
    80002476:	8082                	ret

0000000080002478 <wait>:
{
    80002478:	715d                	add	sp,sp,-80
    8000247a:	e486                	sd	ra,72(sp)
    8000247c:	e0a2                	sd	s0,64(sp)
    8000247e:	fc26                	sd	s1,56(sp)
    80002480:	f84a                	sd	s2,48(sp)
    80002482:	f44e                	sd	s3,40(sp)
    80002484:	f052                	sd	s4,32(sp)
    80002486:	ec56                	sd	s5,24(sp)
    80002488:	e85a                	sd	s6,16(sp)
    8000248a:	e45e                	sd	s7,8(sp)
    8000248c:	e062                	sd	s8,0(sp)
    8000248e:	0880                	add	s0,sp,80
    80002490:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	514080e7          	jalr	1300(ra) # 800019a6 <myproc>
    8000249a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000249c:	0000e517          	auipc	a0,0xe
    800024a0:	6cc50513          	add	a0,a0,1740 # 80010b68 <wait_lock>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	72e080e7          	jalr	1838(ra) # 80000bd2 <acquire>
    havekids = 0;
    800024ac:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800024ae:	4a15                	li	s4,5
        havekids = 1;
    800024b0:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024b2:	00015997          	auipc	s3,0x15
    800024b6:	6de98993          	add	s3,s3,1758 # 80017b90 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024ba:	0000ec17          	auipc	s8,0xe
    800024be:	6aec0c13          	add	s8,s8,1710 # 80010b68 <wait_lock>
    800024c2:	a0d1                	j	80002586 <wait+0x10e>
          pid = pp->pid;
    800024c4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024c8:	000b0e63          	beqz	s6,800024e4 <wait+0x6c>
    800024cc:	4691                	li	a3,4
    800024ce:	02c48613          	add	a2,s1,44
    800024d2:	85da                	mv	a1,s6
    800024d4:	08893503          	ld	a0,136(s2)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	18e080e7          	jalr	398(ra) # 80001666 <copyout>
    800024e0:	04054163          	bltz	a0,80002522 <wait+0xaa>
          freeproc(pp);
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	672080e7          	jalr	1650(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	796080e7          	jalr	1942(ra) # 80000c86 <release>
          release(&wait_lock);
    800024f8:	0000e517          	auipc	a0,0xe
    800024fc:	67050513          	add	a0,a0,1648 # 80010b68 <wait_lock>
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	786080e7          	jalr	1926(ra) # 80000c86 <release>
}
    80002508:	854e                	mv	a0,s3
    8000250a:	60a6                	ld	ra,72(sp)
    8000250c:	6406                	ld	s0,64(sp)
    8000250e:	74e2                	ld	s1,56(sp)
    80002510:	7942                	ld	s2,48(sp)
    80002512:	79a2                	ld	s3,40(sp)
    80002514:	7a02                	ld	s4,32(sp)
    80002516:	6ae2                	ld	s5,24(sp)
    80002518:	6b42                	ld	s6,16(sp)
    8000251a:	6ba2                	ld	s7,8(sp)
    8000251c:	6c02                	ld	s8,0(sp)
    8000251e:	6161                	add	sp,sp,80
    80002520:	8082                	ret
            release(&pp->lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	762080e7          	jalr	1890(ra) # 80000c86 <release>
            release(&wait_lock);
    8000252c:	0000e517          	auipc	a0,0xe
    80002530:	63c50513          	add	a0,a0,1596 # 80010b68 <wait_lock>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	752080e7          	jalr	1874(ra) # 80000c86 <release>
            return -1;
    8000253c:	59fd                	li	s3,-1
    8000253e:	b7e9                	j	80002508 <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002540:	1b048493          	add	s1,s1,432
    80002544:	03348463          	beq	s1,s3,8000256c <wait+0xf4>
      if (pp->parent == p)
    80002548:	7c9c                	ld	a5,56(s1)
    8000254a:	ff279be3          	bne	a5,s2,80002540 <wait+0xc8>
        acquire(&pp->lock);
    8000254e:	8526                	mv	a0,s1
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	682080e7          	jalr	1666(ra) # 80000bd2 <acquire>
        if (pp->state == ZOMBIE)
    80002558:	4c9c                	lw	a5,24(s1)
    8000255a:	f74785e3          	beq	a5,s4,800024c4 <wait+0x4c>
        release(&pp->lock);
    8000255e:	8526                	mv	a0,s1
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	726080e7          	jalr	1830(ra) # 80000c86 <release>
        havekids = 1;
    80002568:	8756                	mv	a4,s5
    8000256a:	bfd9                	j	80002540 <wait+0xc8>
    if (!havekids || killed(p))
    8000256c:	c31d                	beqz	a4,80002592 <wait+0x11a>
    8000256e:	854a                	mv	a0,s2
    80002570:	00000097          	auipc	ra,0x0
    80002574:	ed6080e7          	jalr	-298(ra) # 80002446 <killed>
    80002578:	ed09                	bnez	a0,80002592 <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000257a:	85e2                	mv	a1,s8
    8000257c:	854a                	mv	a0,s2
    8000257e:	00000097          	auipc	ra,0x0
    80002582:	c02080e7          	jalr	-1022(ra) # 80002180 <sleep>
    havekids = 0;
    80002586:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002588:	0000f497          	auipc	s1,0xf
    8000258c:	a0848493          	add	s1,s1,-1528 # 80010f90 <proc>
    80002590:	bf65                	j	80002548 <wait+0xd0>
      release(&wait_lock);
    80002592:	0000e517          	auipc	a0,0xe
    80002596:	5d650513          	add	a0,a0,1494 # 80010b68 <wait_lock>
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	6ec080e7          	jalr	1772(ra) # 80000c86 <release>
      return -1;
    800025a2:	59fd                	li	s3,-1
    800025a4:	b795                	j	80002508 <wait+0x90>

00000000800025a6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025a6:	7179                	add	sp,sp,-48
    800025a8:	f406                	sd	ra,40(sp)
    800025aa:	f022                	sd	s0,32(sp)
    800025ac:	ec26                	sd	s1,24(sp)
    800025ae:	e84a                	sd	s2,16(sp)
    800025b0:	e44e                	sd	s3,8(sp)
    800025b2:	e052                	sd	s4,0(sp)
    800025b4:	1800                	add	s0,sp,48
    800025b6:	84aa                	mv	s1,a0
    800025b8:	892e                	mv	s2,a1
    800025ba:	89b2                	mv	s3,a2
    800025bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	3e8080e7          	jalr	1000(ra) # 800019a6 <myproc>
  if (user_dst)
    800025c6:	c08d                	beqz	s1,800025e8 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025c8:	86d2                	mv	a3,s4
    800025ca:	864e                	mv	a2,s3
    800025cc:	85ca                	mv	a1,s2
    800025ce:	6548                	ld	a0,136(a0)
    800025d0:	fffff097          	auipc	ra,0xfffff
    800025d4:	096080e7          	jalr	150(ra) # 80001666 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025d8:	70a2                	ld	ra,40(sp)
    800025da:	7402                	ld	s0,32(sp)
    800025dc:	64e2                	ld	s1,24(sp)
    800025de:	6942                	ld	s2,16(sp)
    800025e0:	69a2                	ld	s3,8(sp)
    800025e2:	6a02                	ld	s4,0(sp)
    800025e4:	6145                	add	sp,sp,48
    800025e6:	8082                	ret
    memmove((char *)dst, src, len);
    800025e8:	000a061b          	sext.w	a2,s4
    800025ec:	85ce                	mv	a1,s3
    800025ee:	854a                	mv	a0,s2
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	73a080e7          	jalr	1850(ra) # 80000d2a <memmove>
    return 0;
    800025f8:	8526                	mv	a0,s1
    800025fa:	bff9                	j	800025d8 <either_copyout+0x32>

00000000800025fc <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025fc:	7179                	add	sp,sp,-48
    800025fe:	f406                	sd	ra,40(sp)
    80002600:	f022                	sd	s0,32(sp)
    80002602:	ec26                	sd	s1,24(sp)
    80002604:	e84a                	sd	s2,16(sp)
    80002606:	e44e                	sd	s3,8(sp)
    80002608:	e052                	sd	s4,0(sp)
    8000260a:	1800                	add	s0,sp,48
    8000260c:	892a                	mv	s2,a0
    8000260e:	84ae                	mv	s1,a1
    80002610:	89b2                	mv	s3,a2
    80002612:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	392080e7          	jalr	914(ra) # 800019a6 <myproc>
  if (user_src)
    8000261c:	c08d                	beqz	s1,8000263e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000261e:	86d2                	mv	a3,s4
    80002620:	864e                	mv	a2,s3
    80002622:	85ca                	mv	a1,s2
    80002624:	6548                	ld	a0,136(a0)
    80002626:	fffff097          	auipc	ra,0xfffff
    8000262a:	0cc080e7          	jalr	204(ra) # 800016f2 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000262e:	70a2                	ld	ra,40(sp)
    80002630:	7402                	ld	s0,32(sp)
    80002632:	64e2                	ld	s1,24(sp)
    80002634:	6942                	ld	s2,16(sp)
    80002636:	69a2                	ld	s3,8(sp)
    80002638:	6a02                	ld	s4,0(sp)
    8000263a:	6145                	add	sp,sp,48
    8000263c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000263e:	000a061b          	sext.w	a2,s4
    80002642:	85ce                	mv	a1,s3
    80002644:	854a                	mv	a0,s2
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	6e4080e7          	jalr	1764(ra) # 80000d2a <memmove>
    return 0;
    8000264e:	8526                	mv	a0,s1
    80002650:	bff9                	j	8000262e <either_copyin+0x32>

0000000080002652 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002652:	715d                	add	sp,sp,-80
    80002654:	e486                	sd	ra,72(sp)
    80002656:	e0a2                	sd	s0,64(sp)
    80002658:	fc26                	sd	s1,56(sp)
    8000265a:	f84a                	sd	s2,48(sp)
    8000265c:	f44e                	sd	s3,40(sp)
    8000265e:	f052                	sd	s4,32(sp)
    80002660:	ec56                	sd	s5,24(sp)
    80002662:	e85a                	sd	s6,16(sp)
    80002664:	e45e                	sd	s7,8(sp)
    80002666:	0880                	add	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002668:	00006517          	auipc	a0,0x6
    8000266c:	a6050513          	add	a0,a0,-1440 # 800080c8 <digits+0x88>
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	f16080e7          	jalr	-234(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002678:	0000f497          	auipc	s1,0xf
    8000267c:	aa848493          	add	s1,s1,-1368 # 80011120 <proc+0x190>
    80002680:	00015917          	auipc	s2,0x15
    80002684:	6a090913          	add	s2,s2,1696 # 80017d20 <bcache+0x178>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002688:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000268a:	00006997          	auipc	s3,0x6
    8000268e:	bf698993          	add	s3,s3,-1034 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002692:	00006a97          	auipc	s5,0x6
    80002696:	bf6a8a93          	add	s5,s5,-1034 # 80008288 <digits+0x248>
    printf("\n");
    8000269a:	00006a17          	auipc	s4,0x6
    8000269e:	a2ea0a13          	add	s4,s4,-1490 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a2:	00006b97          	auipc	s7,0x6
    800026a6:	c26b8b93          	add	s7,s7,-986 # 800082c8 <states.0>
    800026aa:	a00d                	j	800026cc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026ac:	ea06a583          	lw	a1,-352(a3)
    800026b0:	8556                	mv	a0,s5
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	ed4080e7          	jalr	-300(ra) # 80000586 <printf>
    printf("\n");
    800026ba:	8552                	mv	a0,s4
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	eca080e7          	jalr	-310(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026c4:	1b048493          	add	s1,s1,432
    800026c8:	03248263          	beq	s1,s2,800026ec <procdump+0x9a>
    if (p->state == UNUSED)
    800026cc:	86a6                	mv	a3,s1
    800026ce:	e884a783          	lw	a5,-376(s1)
    800026d2:	dbed                	beqz	a5,800026c4 <procdump+0x72>
      state = "???";
    800026d4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d6:	fcfb6be3          	bltu	s6,a5,800026ac <procdump+0x5a>
    800026da:	02079713          	sll	a4,a5,0x20
    800026de:	01d75793          	srl	a5,a4,0x1d
    800026e2:	97de                	add	a5,a5,s7
    800026e4:	6390                	ld	a2,0(a5)
    800026e6:	f279                	bnez	a2,800026ac <procdump+0x5a>
      state = "???";
    800026e8:	864e                	mv	a2,s3
    800026ea:	b7c9                	j	800026ac <procdump+0x5a>
  }
}
    800026ec:	60a6                	ld	ra,72(sp)
    800026ee:	6406                	ld	s0,64(sp)
    800026f0:	74e2                	ld	s1,56(sp)
    800026f2:	7942                	ld	s2,48(sp)
    800026f4:	79a2                	ld	s3,40(sp)
    800026f6:	7a02                	ld	s4,32(sp)
    800026f8:	6ae2                	ld	s5,24(sp)
    800026fa:	6b42                	ld	s6,16(sp)
    800026fc:	6ba2                	ld	s7,8(sp)
    800026fe:	6161                	add	sp,sp,80
    80002700:	8082                	ret

0000000080002702 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002702:	711d                	add	sp,sp,-96
    80002704:	ec86                	sd	ra,88(sp)
    80002706:	e8a2                	sd	s0,80(sp)
    80002708:	e4a6                	sd	s1,72(sp)
    8000270a:	e0ca                	sd	s2,64(sp)
    8000270c:	fc4e                	sd	s3,56(sp)
    8000270e:	f852                	sd	s4,48(sp)
    80002710:	f456                	sd	s5,40(sp)
    80002712:	f05a                	sd	s6,32(sp)
    80002714:	ec5e                	sd	s7,24(sp)
    80002716:	e862                	sd	s8,16(sp)
    80002718:	e466                	sd	s9,8(sp)
    8000271a:	e06a                	sd	s10,0(sp)
    8000271c:	1080                	add	s0,sp,96
    8000271e:	8b2a                	mv	s6,a0
    80002720:	8bae                	mv	s7,a1
    80002722:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002724:	fffff097          	auipc	ra,0xfffff
    80002728:	282080e7          	jalr	642(ra) # 800019a6 <myproc>
    8000272c:	892a                	mv	s2,a0

  acquire(&wait_lock);
    8000272e:	0000e517          	auipc	a0,0xe
    80002732:	43a50513          	add	a0,a0,1082 # 80010b68 <wait_lock>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	49c080e7          	jalr	1180(ra) # 80000bd2 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    8000273e:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002740:	4a15                	li	s4,5
        havekids = 1;
    80002742:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002744:	00015997          	auipc	s3,0x15
    80002748:	44c98993          	add	s3,s3,1100 # 80017b90 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000274c:	0000ed17          	auipc	s10,0xe
    80002750:	41cd0d13          	add	s10,s10,1052 # 80010b68 <wait_lock>
    80002754:	a8e9                	j	8000282e <waitx+0x12c>
          pid = np->pid;
    80002756:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000275a:	1a04a783          	lw	a5,416(s1)
    8000275e:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002762:	1a44a703          	lw	a4,420(s1)
    80002766:	9f3d                	addw	a4,a4,a5
    80002768:	1a84a783          	lw	a5,424(s1)
    8000276c:	9f99                	subw	a5,a5,a4
    8000276e:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002772:	000b0e63          	beqz	s6,8000278e <waitx+0x8c>
    80002776:	4691                	li	a3,4
    80002778:	02c48613          	add	a2,s1,44
    8000277c:	85da                	mv	a1,s6
    8000277e:	08893503          	ld	a0,136(s2)
    80002782:	fffff097          	auipc	ra,0xfffff
    80002786:	ee4080e7          	jalr	-284(ra) # 80001666 <copyout>
    8000278a:	04054363          	bltz	a0,800027d0 <waitx+0xce>
          freeproc(np);
    8000278e:	8526                	mv	a0,s1
    80002790:	fffff097          	auipc	ra,0xfffff
    80002794:	3c8080e7          	jalr	968(ra) # 80001b58 <freeproc>
          release(&np->lock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4ec080e7          	jalr	1260(ra) # 80000c86 <release>
          release(&wait_lock);
    800027a2:	0000e517          	auipc	a0,0xe
    800027a6:	3c650513          	add	a0,a0,966 # 80010b68 <wait_lock>
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	4dc080e7          	jalr	1244(ra) # 80000c86 <release>
  }
}
    800027b2:	854e                	mv	a0,s3
    800027b4:	60e6                	ld	ra,88(sp)
    800027b6:	6446                	ld	s0,80(sp)
    800027b8:	64a6                	ld	s1,72(sp)
    800027ba:	6906                	ld	s2,64(sp)
    800027bc:	79e2                	ld	s3,56(sp)
    800027be:	7a42                	ld	s4,48(sp)
    800027c0:	7aa2                	ld	s5,40(sp)
    800027c2:	7b02                	ld	s6,32(sp)
    800027c4:	6be2                	ld	s7,24(sp)
    800027c6:	6c42                	ld	s8,16(sp)
    800027c8:	6ca2                	ld	s9,8(sp)
    800027ca:	6d02                	ld	s10,0(sp)
    800027cc:	6125                	add	sp,sp,96
    800027ce:	8082                	ret
            release(&np->lock);
    800027d0:	8526                	mv	a0,s1
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	4b4080e7          	jalr	1204(ra) # 80000c86 <release>
            release(&wait_lock);
    800027da:	0000e517          	auipc	a0,0xe
    800027de:	38e50513          	add	a0,a0,910 # 80010b68 <wait_lock>
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	4a4080e7          	jalr	1188(ra) # 80000c86 <release>
            return -1;
    800027ea:	59fd                	li	s3,-1
    800027ec:	b7d9                	j	800027b2 <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    800027ee:	1b048493          	add	s1,s1,432
    800027f2:	03348463          	beq	s1,s3,8000281a <waitx+0x118>
      if (np->parent == p)
    800027f6:	7c9c                	ld	a5,56(s1)
    800027f8:	ff279be3          	bne	a5,s2,800027ee <waitx+0xec>
        acquire(&np->lock);
    800027fc:	8526                	mv	a0,s1
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	3d4080e7          	jalr	980(ra) # 80000bd2 <acquire>
        if (np->state == ZOMBIE)
    80002806:	4c9c                	lw	a5,24(s1)
    80002808:	f54787e3          	beq	a5,s4,80002756 <waitx+0x54>
        release(&np->lock);
    8000280c:	8526                	mv	a0,s1
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	478080e7          	jalr	1144(ra) # 80000c86 <release>
        havekids = 1;
    80002816:	8756                	mv	a4,s5
    80002818:	bfd9                	j	800027ee <waitx+0xec>
    if (!havekids || p->killed)
    8000281a:	c305                	beqz	a4,8000283a <waitx+0x138>
    8000281c:	02892783          	lw	a5,40(s2)
    80002820:	ef89                	bnez	a5,8000283a <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002822:	85ea                	mv	a1,s10
    80002824:	854a                	mv	a0,s2
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	95a080e7          	jalr	-1702(ra) # 80002180 <sleep>
    havekids = 0;
    8000282e:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002830:	0000e497          	auipc	s1,0xe
    80002834:	76048493          	add	s1,s1,1888 # 80010f90 <proc>
    80002838:	bf7d                	j	800027f6 <waitx+0xf4>
      release(&wait_lock);
    8000283a:	0000e517          	auipc	a0,0xe
    8000283e:	32e50513          	add	a0,a0,814 # 80010b68 <wait_lock>
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	444080e7          	jalr	1092(ra) # 80000c86 <release>
      return -1;
    8000284a:	59fd                	li	s3,-1
    8000284c:	b79d                	j	800027b2 <waitx+0xb0>

000000008000284e <update_time>:

void update_time()
{
    8000284e:	715d                	add	sp,sp,-80
    80002850:	e486                	sd	ra,72(sp)
    80002852:	e0a2                	sd	s0,64(sp)
    80002854:	fc26                	sd	s1,56(sp)
    80002856:	f84a                	sd	s2,48(sp)
    80002858:	f44e                	sd	s3,40(sp)
    8000285a:	f052                	sd	s4,32(sp)
    8000285c:	ec56                	sd	s5,24(sp)
    8000285e:	e85a                	sd	s6,16(sp)
    80002860:	e45e                	sd	s7,8(sp)
    80002862:	e062                	sd	s8,0(sp)
    80002864:	0880                	add	s0,sp,80
  for (struct proc *p = proc; p < &proc[NPROC]; p++)
    80002866:	0000e497          	auipc	s1,0xe
    8000286a:	72a48493          	add	s1,s1,1834 # 80010f90 <proc>
  {
    acquire(&p->lock);

    if (p->state == RUNNING)
    8000286e:	4991                	li	s3,4

#ifdef MLFQ
      p->current_trun++;
#endif
    }
    else if(p->state == RUNNABLE)
    80002870:	4a0d                	li	s4,3
          p->wait_time = 0;
        }
      }
   #endif
    }
    else if (p->state == SLEEPING)
    80002872:	4a89                	li	s5,2
        if(p->qprio != 0 && p->wait_time > 30)
    80002874:	4bf9                	li	s7,30
          q_count[p->qprio]--;
    80002876:	0000eb17          	auipc	s6,0xe
    8000287a:	2dab0b13          	add	s6,s6,730 # 80010b50 <pid_lock>
          p->intime = ticks;
    8000287e:	00006c17          	auipc	s8,0x6
    80002882:	062c0c13          	add	s8,s8,98 # 800088e0 <ticks>
  for (struct proc *p = proc; p < &proc[NPROC]; p++)
    80002886:	00015917          	auipc	s2,0x15
    8000288a:	30a90913          	add	s2,s2,778 # 80017b90 <tickslock>
    8000288e:	a015                	j	800028b2 <update_time+0x64>
      p->rtime++;
    80002890:	1a04a783          	lw	a5,416(s1)
    80002894:	2785                	addw	a5,a5,1
    80002896:	1af4a023          	sw	a5,416(s1)
      p->current_trun++;
    8000289a:	50bc                	lw	a5,96(s1)
    8000289c:	2785                	addw	a5,a5,1
    8000289e:	d0bc                	sw	a5,96(s1)
    {
    #ifdef MLFQ
      p->current_tsun++;
    #endif
    }
    release(&p->lock);
    800028a0:	8526                	mv	a0,s1
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	3e4080e7          	jalr	996(ra) # 80000c86 <release>
  for (struct proc *p = proc; p < &proc[NPROC]; p++)
    800028aa:	1b048493          	add	s1,s1,432
    800028ae:	07248b63          	beq	s1,s2,80002924 <update_time+0xd6>
    acquire(&p->lock);
    800028b2:	8526                	mv	a0,s1
    800028b4:	ffffe097          	auipc	ra,0xffffe
    800028b8:	31e080e7          	jalr	798(ra) # 80000bd2 <acquire>
    if (p->state == RUNNING)
    800028bc:	4c9c                	lw	a5,24(s1)
    800028be:	fd3789e3          	beq	a5,s3,80002890 <update_time+0x42>
    else if(p->state == RUNNABLE)
    800028c2:	01478863          	beq	a5,s4,800028d2 <update_time+0x84>
    else if (p->state == SLEEPING)
    800028c6:	fd579de3          	bne	a5,s5,800028a0 <update_time+0x52>
      p->current_tsun++;
    800028ca:	50fc                	lw	a5,100(s1)
    800028cc:	2785                	addw	a5,a5,1
    800028ce:	d0fc                	sw	a5,100(s1)
    800028d0:	bfc1                	j	800028a0 <update_time+0x52>
      if(p != myproc()){
    800028d2:	fffff097          	auipc	ra,0xfffff
    800028d6:	0d4080e7          	jalr	212(ra) # 800019a6 <myproc>
    800028da:	fca483e3          	beq	s1,a0,800028a0 <update_time+0x52>
        p->wait_time++;
    800028de:	58bc                	lw	a5,112(s1)
    800028e0:	2785                	addw	a5,a5,1
    800028e2:	0007871b          	sext.w	a4,a5
    800028e6:	d8bc                	sw	a5,112(s1)
        if(p->qprio != 0 && p->wait_time > 30)
    800028e8:	54fc                	lw	a5,108(s1)
    800028ea:	dbdd                	beqz	a5,800028a0 <update_time+0x52>
    800028ec:	faebdae3          	bge	s7,a4,800028a0 <update_time+0x52>
          q_count[p->qprio]--;
    800028f0:	00279713          	sll	a4,a5,0x2
    800028f4:	975a                	add	a4,a4,s6
    800028f6:	43072683          	lw	a3,1072(a4)
    800028fa:	36fd                	addw	a3,a3,-1
    800028fc:	42d72823          	sw	a3,1072(a4)
          p->qprio--;
    80002900:	37fd                	addw	a5,a5,-1
    80002902:	0007871b          	sext.w	a4,a5
    80002906:	d4fc                	sw	a5,108(s1)
          q_count[p->qprio]++;
    80002908:	00271793          	sll	a5,a4,0x2
    8000290c:	97da                	add	a5,a5,s6
    8000290e:	4307a703          	lw	a4,1072(a5)
    80002912:	2705                	addw	a4,a4,1
    80002914:	42e7a823          	sw	a4,1072(a5)
          p->intime = ticks;
    80002918:	000c2783          	lw	a5,0(s8)
    8000291c:	d4bc                	sw	a5,104(s1)
          p->wait_time = 0;
    8000291e:	0604a823          	sw	zero,112(s1)
    80002922:	bfbd                	j	800028a0 <update_time+0x52>
  }
    
  
    80002924:	60a6                	ld	ra,72(sp)
    80002926:	6406                	ld	s0,64(sp)
    80002928:	74e2                	ld	s1,56(sp)
    8000292a:	7942                	ld	s2,48(sp)
    8000292c:	79a2                	ld	s3,40(sp)
    8000292e:	7a02                	ld	s4,32(sp)
    80002930:	6ae2                	ld	s5,24(sp)
    80002932:	6b42                	ld	s6,16(sp)
    80002934:	6ba2                	ld	s7,8(sp)
    80002936:	6c02                	ld	s8,0(sp)
    80002938:	6161                	add	sp,sp,80
    8000293a:	8082                	ret

000000008000293c <swtch>:
    8000293c:	00153023          	sd	ra,0(a0)
    80002940:	00253423          	sd	sp,8(a0)
    80002944:	e900                	sd	s0,16(a0)
    80002946:	ed04                	sd	s1,24(a0)
    80002948:	03253023          	sd	s2,32(a0)
    8000294c:	03353423          	sd	s3,40(a0)
    80002950:	03453823          	sd	s4,48(a0)
    80002954:	03553c23          	sd	s5,56(a0)
    80002958:	05653023          	sd	s6,64(a0)
    8000295c:	05753423          	sd	s7,72(a0)
    80002960:	05853823          	sd	s8,80(a0)
    80002964:	05953c23          	sd	s9,88(a0)
    80002968:	07a53023          	sd	s10,96(a0)
    8000296c:	07b53423          	sd	s11,104(a0)
    80002970:	0005b083          	ld	ra,0(a1)
    80002974:	0085b103          	ld	sp,8(a1)
    80002978:	6980                	ld	s0,16(a1)
    8000297a:	6d84                	ld	s1,24(a1)
    8000297c:	0205b903          	ld	s2,32(a1)
    80002980:	0285b983          	ld	s3,40(a1)
    80002984:	0305ba03          	ld	s4,48(a1)
    80002988:	0385ba83          	ld	s5,56(a1)
    8000298c:	0405bb03          	ld	s6,64(a1)
    80002990:	0485bb83          	ld	s7,72(a1)
    80002994:	0505bc03          	ld	s8,80(a1)
    80002998:	0585bc83          	ld	s9,88(a1)
    8000299c:	0605bd03          	ld	s10,96(a1)
    800029a0:	0685bd83          	ld	s11,104(a1)
    800029a4:	8082                	ret

00000000800029a6 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800029a6:	1141                	add	sp,sp,-16
    800029a8:	e406                	sd	ra,8(sp)
    800029aa:	e022                	sd	s0,0(sp)
    800029ac:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800029ae:	00006597          	auipc	a1,0x6
    800029b2:	94a58593          	add	a1,a1,-1718 # 800082f8 <states.0+0x30>
    800029b6:	00015517          	auipc	a0,0x15
    800029ba:	1da50513          	add	a0,a0,474 # 80017b90 <tickslock>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	184080e7          	jalr	388(ra) # 80000b42 <initlock>
}
    800029c6:	60a2                	ld	ra,8(sp)
    800029c8:	6402                	ld	s0,0(sp)
    800029ca:	0141                	add	sp,sp,16
    800029cc:	8082                	ret

00000000800029ce <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800029ce:	1141                	add	sp,sp,-16
    800029d0:	e422                	sd	s0,8(sp)
    800029d2:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029d4:	00004797          	auipc	a5,0x4
    800029d8:	8ec78793          	add	a5,a5,-1812 # 800062c0 <kernelvec>
    800029dc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029e0:	6422                	ld	s0,8(sp)
    800029e2:	0141                	add	sp,sp,16
    800029e4:	8082                	ret

00000000800029e6 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800029e6:	1141                	add	sp,sp,-16
    800029e8:	e406                	sd	ra,8(sp)
    800029ea:	e022                	sd	s0,0(sp)
    800029ec:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800029ee:	fffff097          	auipc	ra,0xfffff
    800029f2:	fb8080e7          	jalr	-72(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029fa:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a00:	00004697          	auipc	a3,0x4
    80002a04:	60068693          	add	a3,a3,1536 # 80007000 <_trampoline>
    80002a08:	00004717          	auipc	a4,0x4
    80002a0c:	5f870713          	add	a4,a4,1528 # 80007000 <_trampoline>
    80002a10:	8f15                	sub	a4,a4,a3
    80002a12:	040007b7          	lui	a5,0x4000
    80002a16:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002a18:	07b2                	sll	a5,a5,0xc
    80002a1a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a1c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a20:	6958                	ld	a4,144(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a22:	18002673          	csrr	a2,satp
    80002a26:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a28:	6950                	ld	a2,144(a0)
    80002a2a:	7d38                	ld	a4,120(a0)
    80002a2c:	6585                	lui	a1,0x1
    80002a2e:	972e                	add	a4,a4,a1
    80002a30:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a32:	6958                	ld	a4,144(a0)
    80002a34:	00000617          	auipc	a2,0x0
    80002a38:	14260613          	add	a2,a2,322 # 80002b76 <usertrap>
    80002a3c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a3e:	6958                	ld	a4,144(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a40:	8612                	mv	a2,tp
    80002a42:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a44:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a48:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a4c:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a50:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a54:	6958                	ld	a4,144(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a56:	6f18                	ld	a4,24(a4)
    80002a58:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a5c:	6548                	ld	a0,136(a0)
    80002a5e:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a60:	00004717          	auipc	a4,0x4
    80002a64:	63c70713          	add	a4,a4,1596 # 8000709c <userret>
    80002a68:	8f15                	sub	a4,a4,a3
    80002a6a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a6c:	577d                	li	a4,-1
    80002a6e:	177e                	sll	a4,a4,0x3f
    80002a70:	8d59                	or	a0,a0,a4
    80002a72:	9782                	jalr	a5
}
    80002a74:	60a2                	ld	ra,8(sp)
    80002a76:	6402                	ld	s0,0(sp)
    80002a78:	0141                	add	sp,sp,16
    80002a7a:	8082                	ret

0000000080002a7c <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a7c:	1101                	add	sp,sp,-32
    80002a7e:	ec06                	sd	ra,24(sp)
    80002a80:	e822                	sd	s0,16(sp)
    80002a82:	e426                	sd	s1,8(sp)
    80002a84:	e04a                	sd	s2,0(sp)
    80002a86:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002a88:	00015917          	auipc	s2,0x15
    80002a8c:	10890913          	add	s2,s2,264 # 80017b90 <tickslock>
    80002a90:	854a                	mv	a0,s2
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	140080e7          	jalr	320(ra) # 80000bd2 <acquire>
  ticks++;
    80002a9a:	00006497          	auipc	s1,0x6
    80002a9e:	e4648493          	add	s1,s1,-442 # 800088e0 <ticks>
    80002aa2:	409c                	lw	a5,0(s1)
    80002aa4:	2785                	addw	a5,a5,1
    80002aa6:	c09c                	sw	a5,0(s1)
  update_time();
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	da6080e7          	jalr	-602(ra) # 8000284e <update_time>
  wakeup(&ticks);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	732080e7          	jalr	1842(ra) # 800021e4 <wakeup>
  release(&tickslock);
    80002aba:	854a                	mv	a0,s2
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	1ca080e7          	jalr	458(ra) # 80000c86 <release>
}
    80002ac4:	60e2                	ld	ra,24(sp)
    80002ac6:	6442                	ld	s0,16(sp)
    80002ac8:	64a2                	ld	s1,8(sp)
    80002aca:	6902                	ld	s2,0(sp)
    80002acc:	6105                	add	sp,sp,32
    80002ace:	8082                	ret

0000000080002ad0 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad0:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002ad4:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002ad6:	0807df63          	bgez	a5,80002b74 <devintr+0xa4>
{
    80002ada:	1101                	add	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	1000                	add	s0,sp,32
      (scause & 0xff) == 9)
    80002ae4:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002ae8:	46a5                	li	a3,9
    80002aea:	00d70d63          	beq	a4,a3,80002b04 <devintr+0x34>
  else if (scause == 0x8000000000000001L)
    80002aee:	577d                	li	a4,-1
    80002af0:	177e                	sll	a4,a4,0x3f
    80002af2:	0705                	add	a4,a4,1
    return 0;
    80002af4:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002af6:	04e78e63          	beq	a5,a4,80002b52 <devintr+0x82>
  }
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6105                	add	sp,sp,32
    80002b02:	8082                	ret
    int irq = plic_claim();
    80002b04:	00004097          	auipc	ra,0x4
    80002b08:	8c4080e7          	jalr	-1852(ra) # 800063c8 <plic_claim>
    80002b0c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002b0e:	47a9                	li	a5,10
    80002b10:	02f50763          	beq	a0,a5,80002b3e <devintr+0x6e>
    else if (irq == VIRTIO0_IRQ)
    80002b14:	4785                	li	a5,1
    80002b16:	02f50963          	beq	a0,a5,80002b48 <devintr+0x78>
    return 1;
    80002b1a:	4505                	li	a0,1
    else if (irq)
    80002b1c:	dcf9                	beqz	s1,80002afa <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b1e:	85a6                	mv	a1,s1
    80002b20:	00005517          	auipc	a0,0x5
    80002b24:	7e050513          	add	a0,a0,2016 # 80008300 <states.0+0x38>
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a5e080e7          	jalr	-1442(ra) # 80000586 <printf>
      plic_complete(irq);
    80002b30:	8526                	mv	a0,s1
    80002b32:	00004097          	auipc	ra,0x4
    80002b36:	8ba080e7          	jalr	-1862(ra) # 800063ec <plic_complete>
    return 1;
    80002b3a:	4505                	li	a0,1
    80002b3c:	bf7d                	j	80002afa <devintr+0x2a>
      uartintr();
    80002b3e:	ffffe097          	auipc	ra,0xffffe
    80002b42:	e56080e7          	jalr	-426(ra) # 80000994 <uartintr>
    if (irq)
    80002b46:	b7ed                	j	80002b30 <devintr+0x60>
      virtio_disk_intr();
    80002b48:	00004097          	auipc	ra,0x4
    80002b4c:	d6a080e7          	jalr	-662(ra) # 800068b2 <virtio_disk_intr>
    if (irq)
    80002b50:	b7c5                	j	80002b30 <devintr+0x60>
    if (cpuid() == 0)
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	e28080e7          	jalr	-472(ra) # 8000197a <cpuid>
    80002b5a:	c901                	beqz	a0,80002b6a <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b5c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b60:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b62:	14479073          	csrw	sip,a5
    return 2;
    80002b66:	4509                	li	a0,2
    80002b68:	bf49                	j	80002afa <devintr+0x2a>
      clockintr();
    80002b6a:	00000097          	auipc	ra,0x0
    80002b6e:	f12080e7          	jalr	-238(ra) # 80002a7c <clockintr>
    80002b72:	b7ed                	j	80002b5c <devintr+0x8c>
    80002b74:	8082                	ret

0000000080002b76 <usertrap>:
{
    80002b76:	1101                	add	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	e426                	sd	s1,8(sp)
    80002b7e:	e04a                	sd	s2,0(sp)
    80002b80:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b82:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002b86:	1007f793          	and	a5,a5,256
    80002b8a:	e3b1                	bnez	a5,80002bce <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b8c:	00003797          	auipc	a5,0x3
    80002b90:	73478793          	add	a5,a5,1844 # 800062c0 <kernelvec>
    80002b94:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	e0e080e7          	jalr	-498(ra) # 800019a6 <myproc>
    80002ba0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ba2:	695c                	ld	a5,144(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba4:	14102773          	csrr	a4,sepc
    80002ba8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002baa:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002bae:	47a1                	li	a5,8
    80002bb0:	02f70763          	beq	a4,a5,80002bde <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	f1c080e7          	jalr	-228(ra) # 80002ad0 <devintr>
    80002bbc:	892a                	mv	s2,a0
    80002bbe:	c92d                	beqz	a0,80002c30 <usertrap+0xba>
  if (killed(p))
    80002bc0:	8526                	mv	a0,s1
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	884080e7          	jalr	-1916(ra) # 80002446 <killed>
    80002bca:	c555                	beqz	a0,80002c76 <usertrap+0x100>
    80002bcc:	a045                	j	80002c6c <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002bce:	00005517          	auipc	a0,0x5
    80002bd2:	75250513          	add	a0,a0,1874 # 80008320 <states.0+0x58>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	966080e7          	jalr	-1690(ra) # 8000053c <panic>
    if (killed(p))
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	868080e7          	jalr	-1944(ra) # 80002446 <killed>
    80002be6:	ed1d                	bnez	a0,80002c24 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002be8:	68d8                	ld	a4,144(s1)
    80002bea:	6f1c                	ld	a5,24(a4)
    80002bec:	0791                	add	a5,a5,4
    80002bee:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bf4:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf8:	10079073          	csrw	sstatus,a5
    syscall();
    80002bfc:	00000097          	auipc	ra,0x0
    80002c00:	572080e7          	jalr	1394(ra) # 8000316e <syscall>
  if (killed(p))
    80002c04:	8526                	mv	a0,s1
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	840080e7          	jalr	-1984(ra) # 80002446 <killed>
    80002c0e:	ed31                	bnez	a0,80002c6a <usertrap+0xf4>
  usertrapret();
    80002c10:	00000097          	auipc	ra,0x0
    80002c14:	dd6080e7          	jalr	-554(ra) # 800029e6 <usertrapret>
}
    80002c18:	60e2                	ld	ra,24(sp)
    80002c1a:	6442                	ld	s0,16(sp)
    80002c1c:	64a2                	ld	s1,8(sp)
    80002c1e:	6902                	ld	s2,0(sp)
    80002c20:	6105                	add	sp,sp,32
    80002c22:	8082                	ret
      exit(-1);
    80002c24:	557d                	li	a0,-1
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	6a0080e7          	jalr	1696(ra) # 800022c6 <exit>
    80002c2e:	bf6d                	j	80002be8 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c30:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c34:	5890                	lw	a2,48(s1)
    80002c36:	00005517          	auipc	a0,0x5
    80002c3a:	70a50513          	add	a0,a0,1802 # 80008340 <states.0+0x78>
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	948080e7          	jalr	-1720(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c46:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c4a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c4e:	00005517          	auipc	a0,0x5
    80002c52:	72250513          	add	a0,a0,1826 # 80008370 <states.0+0xa8>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	930080e7          	jalr	-1744(ra) # 80000586 <printf>
    setkilled(p);
    80002c5e:	8526                	mv	a0,s1
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	7ba080e7          	jalr	1978(ra) # 8000241a <setkilled>
    80002c68:	bf71                	j	80002c04 <usertrap+0x8e>
  if (killed(p))
    80002c6a:	4901                	li	s2,0
    exit(-1);
    80002c6c:	557d                	li	a0,-1
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	658080e7          	jalr	1624(ra) # 800022c6 <exit>
  if (which_dev == 2)
    80002c76:	4789                	li	a5,2
    80002c78:	f8f91ce3          	bne	s2,a5,80002c10 <usertrap+0x9a>
    p->CPU_ticks++;
    80002c7c:	48fc                	lw	a5,84(s1)
    80002c7e:	2785                	addw	a5,a5,1
    80002c80:	c8fc                	sw	a5,84(s1)
    if (p->sigalarm != 0)
    80002c82:	44b8                	lw	a4,72(s1)
    80002c84:	cf1d                	beqz	a4,80002cc2 <usertrap+0x14c>
      if ((p->CPU_ticks) % (p->sigalarm_interval) == 0)
    80002c86:	44f8                	lw	a4,76(s1)
    80002c88:	02e7e7bb          	remw	a5,a5,a4
    80002c8c:	eb9d                	bnez	a5,80002cc2 <usertrap+0x14c>
        p->sigalarm = 0;
    80002c8e:	0404a423          	sw	zero,72(s1)
        *(p->cpy_trapframe) = *(p->trapframe);
    80002c92:	68d4                	ld	a3,144(s1)
    80002c94:	87b6                	mv	a5,a3
    80002c96:	6cb8                	ld	a4,88(s1)
    80002c98:	12068693          	add	a3,a3,288
    80002c9c:	0007b803          	ld	a6,0(a5)
    80002ca0:	6788                	ld	a0,8(a5)
    80002ca2:	6b8c                	ld	a1,16(a5)
    80002ca4:	6f90                	ld	a2,24(a5)
    80002ca6:	01073023          	sd	a6,0(a4)
    80002caa:	e708                	sd	a0,8(a4)
    80002cac:	eb0c                	sd	a1,16(a4)
    80002cae:	ef10                	sd	a2,24(a4)
    80002cb0:	02078793          	add	a5,a5,32
    80002cb4:	02070713          	add	a4,a4,32
    80002cb8:	fed792e3          	bne	a5,a3,80002c9c <usertrap+0x126>
        p->trapframe->epc = p->sigalarm_handler;
    80002cbc:	68dc                	ld	a5,144(s1)
    80002cbe:	48b8                	lw	a4,80(s1)
    80002cc0:	ef98                	sd	a4,24(a5)
    int prio = p->qprio;
    80002cc2:	06c4a883          	lw	a7,108(s1)
    for(int i=prio - 1;i>=0;i--){
    80002cc6:	fff8869b          	addw	a3,a7,-1
    80002cca:	0406cc63          	bltz	a3,80002d22 <usertrap+0x1ac>
    80002cce:	00289513          	sll	a0,a7,0x2
    80002cd2:	0000e797          	auipc	a5,0xe
    80002cd6:	2ae78793          	add	a5,a5,686 # 80010f80 <q_count>
    80002cda:	953e                	add	a0,a0,a5
          if(p->qprio == i && p->state == RUNNABLE){
    80002cdc:	458d                	li	a1,3
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002cde:	00015617          	auipc	a2,0x15
    80002ce2:	eb260613          	add	a2,a2,-334 # 80017b90 <tickslock>
    for(int i=prio - 1;i>=0;i--){
    80002ce6:	587d                	li	a6,-1
    80002ce8:	a025                	j	80002d10 <usertrap+0x19a>
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002cea:	1b078793          	add	a5,a5,432
    80002cee:	00c78d63          	beq	a5,a2,80002d08 <usertrap+0x192>
          if(p->qprio == i && p->state == RUNNABLE){
    80002cf2:	57f8                	lw	a4,108(a5)
    80002cf4:	fed71be3          	bne	a4,a3,80002cea <usertrap+0x174>
    80002cf8:	4f98                	lw	a4,24(a5)
    80002cfa:	feb718e3          	bne	a4,a1,80002cea <usertrap+0x174>
            yield();
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	446080e7          	jalr	1094(ra) # 80002144 <yield>
    if(x == 0){
    80002d06:	b729                	j	80002c10 <usertrap+0x9a>
    for(int i=prio - 1;i>=0;i--){
    80002d08:	36fd                	addw	a3,a3,-1
    80002d0a:	1571                	add	a0,a0,-4
    80002d0c:	01068b63          	beq	a3,a6,80002d22 <usertrap+0x1ac>
      if(q_count[i] > 0){
    80002d10:	ffc52783          	lw	a5,-4(a0)
    80002d14:	fef05ae3          	blez	a5,80002d08 <usertrap+0x192>
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002d18:	0000e797          	auipc	a5,0xe
    80002d1c:	27878793          	add	a5,a5,632 # 80010f90 <proc>
    80002d20:	bfc9                	j	80002cf2 <usertrap+0x17c>
    if(prio == 0){
    80002d22:	02088563          	beqz	a7,80002d4c <usertrap+0x1d6>
    else if(prio == 1){
    80002d26:	4785                	li	a5,1
    80002d28:	04f88a63          	beq	a7,a5,80002d7c <usertrap+0x206>
    else if(prio == 2){
    80002d2c:	4789                	li	a5,2
    80002d2e:	08f88563          	beq	a7,a5,80002db8 <usertrap+0x242>
      if(p->current_trun % 15 == 0){
    80002d32:	50bc                	lw	a5,96(s1)
    80002d34:	473d                	li	a4,15
    80002d36:	02e7e7bb          	remw	a5,a5,a4
    80002d3a:	ec079be3          	bnez	a5,80002c10 <usertrap+0x9a>
        p->current_trun = 0;
    80002d3e:	0604a023          	sw	zero,96(s1)
        yield();
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	402080e7          	jalr	1026(ra) # 80002144 <yield>
    80002d4a:	b5d9                	j	80002c10 <usertrap+0x9a>
        p->current_trun = 0;
    80002d4c:	0604a023          	sw	zero,96(s1)
        q_count[prio]--;
    80002d50:	0000e797          	auipc	a5,0xe
    80002d54:	23078793          	add	a5,a5,560 # 80010f80 <q_count>
    80002d58:	4398                	lw	a4,0(a5)
    80002d5a:	377d                	addw	a4,a4,-1
    80002d5c:	c398                	sw	a4,0(a5)
        p->qprio = 1;
    80002d5e:	4705                	li	a4,1
    80002d60:	d4f8                	sw	a4,108(s1)
        q_count[1]++;
    80002d62:	43d8                	lw	a4,4(a5)
    80002d64:	2705                	addw	a4,a4,1
    80002d66:	c3d8                	sw	a4,4(a5)
        p->intime = ticks;
    80002d68:	00006797          	auipc	a5,0x6
    80002d6c:	b787a783          	lw	a5,-1160(a5) # 800088e0 <ticks>
    80002d70:	d4bc                	sw	a5,104(s1)
        yield();
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	3d2080e7          	jalr	978(ra) # 80002144 <yield>
    80002d7a:	bd59                	j	80002c10 <usertrap+0x9a>
      if(p->current_trun % 3 == 0){
    80002d7c:	50bc                	lw	a5,96(s1)
    80002d7e:	470d                	li	a4,3
    80002d80:	02e7e7bb          	remw	a5,a5,a4
    80002d84:	e80796e3          	bnez	a5,80002c10 <usertrap+0x9a>
        p->current_trun = 0;
    80002d88:	0604a023          	sw	zero,96(s1)
        q_count[prio]--;
    80002d8c:	0000e797          	auipc	a5,0xe
    80002d90:	1f478793          	add	a5,a5,500 # 80010f80 <q_count>
    80002d94:	43d8                	lw	a4,4(a5)
    80002d96:	377d                	addw	a4,a4,-1
    80002d98:	c3d8                	sw	a4,4(a5)
        p->qprio = 2;
    80002d9a:	4709                	li	a4,2
    80002d9c:	d4f8                	sw	a4,108(s1)
        q_count[2]++;
    80002d9e:	4798                	lw	a4,8(a5)
    80002da0:	2705                	addw	a4,a4,1
    80002da2:	c798                	sw	a4,8(a5)
        p->intime = ticks;
    80002da4:	00006797          	auipc	a5,0x6
    80002da8:	b3c7a783          	lw	a5,-1220(a5) # 800088e0 <ticks>
    80002dac:	d4bc                	sw	a5,104(s1)
        yield();
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	396080e7          	jalr	918(ra) # 80002144 <yield>
    80002db6:	bda9                	j	80002c10 <usertrap+0x9a>
      if(p->current_trun % 9 == 0){
    80002db8:	50bc                	lw	a5,96(s1)
    80002dba:	4725                	li	a4,9
    80002dbc:	02e7e7bb          	remw	a5,a5,a4
    80002dc0:	e40798e3          	bnez	a5,80002c10 <usertrap+0x9a>
        p->current_trun = 0;
    80002dc4:	0604a023          	sw	zero,96(s1)
        q_count[prio]--;
    80002dc8:	0000e797          	auipc	a5,0xe
    80002dcc:	1b878793          	add	a5,a5,440 # 80010f80 <q_count>
    80002dd0:	4798                	lw	a4,8(a5)
    80002dd2:	377d                	addw	a4,a4,-1
    80002dd4:	c798                	sw	a4,8(a5)
        p->qprio = 3;
    80002dd6:	470d                	li	a4,3
    80002dd8:	d4f8                	sw	a4,108(s1)
        q_count[3]++;
    80002dda:	47d8                	lw	a4,12(a5)
    80002ddc:	2705                	addw	a4,a4,1
    80002dde:	c7d8                	sw	a4,12(a5)
        p->intime = ticks;
    80002de0:	00006797          	auipc	a5,0x6
    80002de4:	b007a783          	lw	a5,-1280(a5) # 800088e0 <ticks>
    80002de8:	d4bc                	sw	a5,104(s1)
        yield();
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	35a080e7          	jalr	858(ra) # 80002144 <yield>
    80002df2:	bd39                	j	80002c10 <usertrap+0x9a>

0000000080002df4 <kerneltrap>:
{
    80002df4:	7179                	add	sp,sp,-48
    80002df6:	f406                	sd	ra,40(sp)
    80002df8:	f022                	sd	s0,32(sp)
    80002dfa:	ec26                	sd	s1,24(sp)
    80002dfc:	e84a                	sd	s2,16(sp)
    80002dfe:	e44e                	sd	s3,8(sp)
    80002e00:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e02:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e06:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e0a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002e0e:	1004f793          	and	a5,s1,256
    80002e12:	cb85                	beqz	a5,80002e42 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e18:	8b89                	and	a5,a5,2
  if (intr_get() != 0)
    80002e1a:	ef85                	bnez	a5,80002e52 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002e1c:	00000097          	auipc	ra,0x0
    80002e20:	cb4080e7          	jalr	-844(ra) # 80002ad0 <devintr>
    80002e24:	cd1d                	beqz	a0,80002e62 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e26:	4789                	li	a5,2
    80002e28:	06f50a63          	beq	a0,a5,80002e9c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e2c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e30:	10049073          	csrw	sstatus,s1
}
    80002e34:	70a2                	ld	ra,40(sp)
    80002e36:	7402                	ld	s0,32(sp)
    80002e38:	64e2                	ld	s1,24(sp)
    80002e3a:	6942                	ld	s2,16(sp)
    80002e3c:	69a2                	ld	s3,8(sp)
    80002e3e:	6145                	add	sp,sp,48
    80002e40:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e42:	00005517          	auipc	a0,0x5
    80002e46:	54e50513          	add	a0,a0,1358 # 80008390 <states.0+0xc8>
    80002e4a:	ffffd097          	auipc	ra,0xffffd
    80002e4e:	6f2080e7          	jalr	1778(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	56650513          	add	a0,a0,1382 # 800083b8 <states.0+0xf0>
    80002e5a:	ffffd097          	auipc	ra,0xffffd
    80002e5e:	6e2080e7          	jalr	1762(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002e62:	85ce                	mv	a1,s3
    80002e64:	00005517          	auipc	a0,0x5
    80002e68:	57450513          	add	a0,a0,1396 # 800083d8 <states.0+0x110>
    80002e6c:	ffffd097          	auipc	ra,0xffffd
    80002e70:	71a080e7          	jalr	1818(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e78:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e7c:	00005517          	auipc	a0,0x5
    80002e80:	56c50513          	add	a0,a0,1388 # 800083e8 <states.0+0x120>
    80002e84:	ffffd097          	auipc	ra,0xffffd
    80002e88:	702080e7          	jalr	1794(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	57450513          	add	a0,a0,1396 # 80008400 <states.0+0x138>
    80002e94:	ffffd097          	auipc	ra,0xffffd
    80002e98:	6a8080e7          	jalr	1704(ra) # 8000053c <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e9c:	fffff097          	auipc	ra,0xfffff
    80002ea0:	b0a080e7          	jalr	-1270(ra) # 800019a6 <myproc>
    80002ea4:	d541                	beqz	a0,80002e2c <kerneltrap+0x38>
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	b00080e7          	jalr	-1280(ra) # 800019a6 <myproc>
    80002eae:	4d18                	lw	a4,24(a0)
    80002eb0:	4791                	li	a5,4
    80002eb2:	f6f71de3          	bne	a4,a5,80002e2c <kerneltrap+0x38>
    struct proc *p = myproc();
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	af0080e7          	jalr	-1296(ra) # 800019a6 <myproc>
    int prio = p->qprio;
    80002ebe:	06c52303          	lw	t1,108(a0)
    for(int i=prio - 1;i>=0;i--){
    80002ec2:	fff3069b          	addw	a3,t1,-1
    80002ec6:	0406cc63          	bltz	a3,80002f1e <kerneltrap+0x12a>
    80002eca:	00231813          	sll	a6,t1,0x2
    80002ece:	0000e797          	auipc	a5,0xe
    80002ed2:	0b278793          	add	a5,a5,178 # 80010f80 <q_count>
    80002ed6:	983e                	add	a6,a6,a5
          if(p->qprio == i && p->state == RUNNABLE){
    80002ed8:	458d                	li	a1,3
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002eda:	00015617          	auipc	a2,0x15
    80002ede:	cb660613          	add	a2,a2,-842 # 80017b90 <tickslock>
    for(int i=prio - 1;i>=0;i--){
    80002ee2:	58fd                	li	a7,-1
    80002ee4:	a025                	j	80002f0c <kerneltrap+0x118>
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002ee6:	1b078793          	add	a5,a5,432
    80002eea:	00c78d63          	beq	a5,a2,80002f04 <kerneltrap+0x110>
          if(p->qprio == i && p->state == RUNNABLE){
    80002eee:	57f8                	lw	a4,108(a5)
    80002ef0:	fed71be3          	bne	a4,a3,80002ee6 <kerneltrap+0xf2>
    80002ef4:	4f98                	lw	a4,24(a5)
    80002ef6:	feb718e3          	bne	a4,a1,80002ee6 <kerneltrap+0xf2>
            yield();
    80002efa:	fffff097          	auipc	ra,0xfffff
    80002efe:	24a080e7          	jalr	586(ra) # 80002144 <yield>
    if(x == 0){
    80002f02:	b72d                	j	80002e2c <kerneltrap+0x38>
    for(int i=prio - 1;i>=0;i--){
    80002f04:	36fd                	addw	a3,a3,-1
    80002f06:	1871                	add	a6,a6,-4
    80002f08:	01168b63          	beq	a3,a7,80002f1e <kerneltrap+0x12a>
      if(q_count[i] > 0){
    80002f0c:	ffc82783          	lw	a5,-4(a6)
    80002f10:	fef05ae3          	blez	a5,80002f04 <kerneltrap+0x110>
          for(struct proc *p = proc; p < &proc[NPROC]; p++){
    80002f14:	0000e797          	auipc	a5,0xe
    80002f18:	07c78793          	add	a5,a5,124 # 80010f90 <proc>
    80002f1c:	bfc9                	j	80002eee <kerneltrap+0xfa>
    if(prio == 0){
    80002f1e:	02030563          	beqz	t1,80002f48 <kerneltrap+0x154>
    else if(prio == 1){
    80002f22:	4785                	li	a5,1
    80002f24:	04f30a63          	beq	t1,a5,80002f78 <kerneltrap+0x184>
    else if(prio == 2){
    80002f28:	4789                	li	a5,2
    80002f2a:	08f30563          	beq	t1,a5,80002fb4 <kerneltrap+0x1c0>
      if(p->current_trun % 15 == 0){
    80002f2e:	513c                	lw	a5,96(a0)
    80002f30:	473d                	li	a4,15
    80002f32:	02e7e7bb          	remw	a5,a5,a4
    80002f36:	ee079be3          	bnez	a5,80002e2c <kerneltrap+0x38>
        p->current_trun = 0;
    80002f3a:	06052023          	sw	zero,96(a0)
        yield();
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	206080e7          	jalr	518(ra) # 80002144 <yield>
    80002f46:	b5dd                	j	80002e2c <kerneltrap+0x38>
        p->current_trun = 0;
    80002f48:	06052023          	sw	zero,96(a0)
        q_count[prio]--;
    80002f4c:	0000e797          	auipc	a5,0xe
    80002f50:	03478793          	add	a5,a5,52 # 80010f80 <q_count>
    80002f54:	4398                	lw	a4,0(a5)
    80002f56:	377d                	addw	a4,a4,-1
    80002f58:	c398                	sw	a4,0(a5)
        p->qprio = 1;
    80002f5a:	4705                	li	a4,1
    80002f5c:	d578                	sw	a4,108(a0)
        q_count[1]++;
    80002f5e:	43d8                	lw	a4,4(a5)
    80002f60:	2705                	addw	a4,a4,1
    80002f62:	c3d8                	sw	a4,4(a5)
        p->intime = ticks;
    80002f64:	00006797          	auipc	a5,0x6
    80002f68:	97c7a783          	lw	a5,-1668(a5) # 800088e0 <ticks>
    80002f6c:	d53c                	sw	a5,104(a0)
        yield();
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	1d6080e7          	jalr	470(ra) # 80002144 <yield>
    80002f76:	bd5d                	j	80002e2c <kerneltrap+0x38>
      if(p->current_trun % 3 == 0){
    80002f78:	513c                	lw	a5,96(a0)
    80002f7a:	470d                	li	a4,3
    80002f7c:	02e7e7bb          	remw	a5,a5,a4
    80002f80:	ea0796e3          	bnez	a5,80002e2c <kerneltrap+0x38>
        p->current_trun = 0;
    80002f84:	06052023          	sw	zero,96(a0)
        q_count[prio]--;
    80002f88:	0000e797          	auipc	a5,0xe
    80002f8c:	ff878793          	add	a5,a5,-8 # 80010f80 <q_count>
    80002f90:	43d8                	lw	a4,4(a5)
    80002f92:	377d                	addw	a4,a4,-1
    80002f94:	c3d8                	sw	a4,4(a5)
        p->qprio = 2;
    80002f96:	4709                	li	a4,2
    80002f98:	d578                	sw	a4,108(a0)
        q_count[2]++;
    80002f9a:	4798                	lw	a4,8(a5)
    80002f9c:	2705                	addw	a4,a4,1
    80002f9e:	c798                	sw	a4,8(a5)
        p->intime = ticks;
    80002fa0:	00006797          	auipc	a5,0x6
    80002fa4:	9407a783          	lw	a5,-1728(a5) # 800088e0 <ticks>
    80002fa8:	d53c                	sw	a5,104(a0)
        yield();
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	19a080e7          	jalr	410(ra) # 80002144 <yield>
    80002fb2:	bdad                	j	80002e2c <kerneltrap+0x38>
      if(p->current_trun % 9 == 0){
    80002fb4:	513c                	lw	a5,96(a0)
    80002fb6:	4725                	li	a4,9
    80002fb8:	02e7e7bb          	remw	a5,a5,a4
    80002fbc:	e60798e3          	bnez	a5,80002e2c <kerneltrap+0x38>
        p->current_trun = 0;
    80002fc0:	06052023          	sw	zero,96(a0)
        q_count[prio]--;
    80002fc4:	0000e797          	auipc	a5,0xe
    80002fc8:	fbc78793          	add	a5,a5,-68 # 80010f80 <q_count>
    80002fcc:	4798                	lw	a4,8(a5)
    80002fce:	377d                	addw	a4,a4,-1
    80002fd0:	c798                	sw	a4,8(a5)
        p->qprio = 3;
    80002fd2:	470d                	li	a4,3
    80002fd4:	d578                	sw	a4,108(a0)
        q_count[3]++;
    80002fd6:	47d8                	lw	a4,12(a5)
    80002fd8:	2705                	addw	a4,a4,1
    80002fda:	c7d8                	sw	a4,12(a5)
        p->intime = ticks;
    80002fdc:	00006797          	auipc	a5,0x6
    80002fe0:	9047a783          	lw	a5,-1788(a5) # 800088e0 <ticks>
    80002fe4:	d53c                	sw	a5,104(a0)
        yield();
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	15e080e7          	jalr	350(ra) # 80002144 <yield>
    80002fee:	bd3d                	j	80002e2c <kerneltrap+0x38>

0000000080002ff0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ff0:	1101                	add	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	e426                	sd	s1,8(sp)
    80002ff8:	1000                	add	s0,sp,32
    80002ffa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ffc:	fffff097          	auipc	ra,0xfffff
    80003000:	9aa080e7          	jalr	-1622(ra) # 800019a6 <myproc>
  switch (n) {
    80003004:	4795                	li	a5,5
    80003006:	0497e163          	bltu	a5,s1,80003048 <argraw+0x58>
    8000300a:	048a                	sll	s1,s1,0x2
    8000300c:	00005717          	auipc	a4,0x5
    80003010:	42c70713          	add	a4,a4,1068 # 80008438 <states.0+0x170>
    80003014:	94ba                	add	s1,s1,a4
    80003016:	409c                	lw	a5,0(s1)
    80003018:	97ba                	add	a5,a5,a4
    8000301a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000301c:	695c                	ld	a5,144(a0)
    8000301e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	64a2                	ld	s1,8(sp)
    80003026:	6105                	add	sp,sp,32
    80003028:	8082                	ret
    return p->trapframe->a1;
    8000302a:	695c                	ld	a5,144(a0)
    8000302c:	7fa8                	ld	a0,120(a5)
    8000302e:	bfcd                	j	80003020 <argraw+0x30>
    return p->trapframe->a2;
    80003030:	695c                	ld	a5,144(a0)
    80003032:	63c8                	ld	a0,128(a5)
    80003034:	b7f5                	j	80003020 <argraw+0x30>
    return p->trapframe->a3;
    80003036:	695c                	ld	a5,144(a0)
    80003038:	67c8                	ld	a0,136(a5)
    8000303a:	b7dd                	j	80003020 <argraw+0x30>
    return p->trapframe->a4;
    8000303c:	695c                	ld	a5,144(a0)
    8000303e:	6bc8                	ld	a0,144(a5)
    80003040:	b7c5                	j	80003020 <argraw+0x30>
    return p->trapframe->a5;
    80003042:	695c                	ld	a5,144(a0)
    80003044:	6fc8                	ld	a0,152(a5)
    80003046:	bfe9                	j	80003020 <argraw+0x30>
  panic("argraw");
    80003048:	00005517          	auipc	a0,0x5
    8000304c:	3c850513          	add	a0,a0,968 # 80008410 <states.0+0x148>
    80003050:	ffffd097          	auipc	ra,0xffffd
    80003054:	4ec080e7          	jalr	1260(ra) # 8000053c <panic>

0000000080003058 <fetchaddr>:
{
    80003058:	1101                	add	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	e426                	sd	s1,8(sp)
    80003060:	e04a                	sd	s2,0(sp)
    80003062:	1000                	add	s0,sp,32
    80003064:	84aa                	mv	s1,a0
    80003066:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003068:	fffff097          	auipc	ra,0xfffff
    8000306c:	93e080e7          	jalr	-1730(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003070:	615c                	ld	a5,128(a0)
    80003072:	02f4f863          	bgeu	s1,a5,800030a2 <fetchaddr+0x4a>
    80003076:	00848713          	add	a4,s1,8
    8000307a:	02e7e663          	bltu	a5,a4,800030a6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000307e:	46a1                	li	a3,8
    80003080:	8626                	mv	a2,s1
    80003082:	85ca                	mv	a1,s2
    80003084:	6548                	ld	a0,136(a0)
    80003086:	ffffe097          	auipc	ra,0xffffe
    8000308a:	66c080e7          	jalr	1644(ra) # 800016f2 <copyin>
    8000308e:	00a03533          	snez	a0,a0
    80003092:	40a00533          	neg	a0,a0
}
    80003096:	60e2                	ld	ra,24(sp)
    80003098:	6442                	ld	s0,16(sp)
    8000309a:	64a2                	ld	s1,8(sp)
    8000309c:	6902                	ld	s2,0(sp)
    8000309e:	6105                	add	sp,sp,32
    800030a0:	8082                	ret
    return -1;
    800030a2:	557d                	li	a0,-1
    800030a4:	bfcd                	j	80003096 <fetchaddr+0x3e>
    800030a6:	557d                	li	a0,-1
    800030a8:	b7fd                	j	80003096 <fetchaddr+0x3e>

00000000800030aa <fetchstr>:
{
    800030aa:	7179                	add	sp,sp,-48
    800030ac:	f406                	sd	ra,40(sp)
    800030ae:	f022                	sd	s0,32(sp)
    800030b0:	ec26                	sd	s1,24(sp)
    800030b2:	e84a                	sd	s2,16(sp)
    800030b4:	e44e                	sd	s3,8(sp)
    800030b6:	1800                	add	s0,sp,48
    800030b8:	892a                	mv	s2,a0
    800030ba:	84ae                	mv	s1,a1
    800030bc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	8e8080e7          	jalr	-1816(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800030c6:	86ce                	mv	a3,s3
    800030c8:	864a                	mv	a2,s2
    800030ca:	85a6                	mv	a1,s1
    800030cc:	6548                	ld	a0,136(a0)
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	6b2080e7          	jalr	1714(ra) # 80001780 <copyinstr>
    800030d6:	00054e63          	bltz	a0,800030f2 <fetchstr+0x48>
  return strlen(buf);
    800030da:	8526                	mv	a0,s1
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	d6c080e7          	jalr	-660(ra) # 80000e48 <strlen>
}
    800030e4:	70a2                	ld	ra,40(sp)
    800030e6:	7402                	ld	s0,32(sp)
    800030e8:	64e2                	ld	s1,24(sp)
    800030ea:	6942                	ld	s2,16(sp)
    800030ec:	69a2                	ld	s3,8(sp)
    800030ee:	6145                	add	sp,sp,48
    800030f0:	8082                	ret
    return -1;
    800030f2:	557d                	li	a0,-1
    800030f4:	bfc5                	j	800030e4 <fetchstr+0x3a>

00000000800030f6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800030f6:	1101                	add	sp,sp,-32
    800030f8:	ec06                	sd	ra,24(sp)
    800030fa:	e822                	sd	s0,16(sp)
    800030fc:	e426                	sd	s1,8(sp)
    800030fe:	1000                	add	s0,sp,32
    80003100:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003102:	00000097          	auipc	ra,0x0
    80003106:	eee080e7          	jalr	-274(ra) # 80002ff0 <argraw>
    8000310a:	c088                	sw	a0,0(s1)
}
    8000310c:	60e2                	ld	ra,24(sp)
    8000310e:	6442                	ld	s0,16(sp)
    80003110:	64a2                	ld	s1,8(sp)
    80003112:	6105                	add	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003116:	1101                	add	sp,sp,-32
    80003118:	ec06                	sd	ra,24(sp)
    8000311a:	e822                	sd	s0,16(sp)
    8000311c:	e426                	sd	s1,8(sp)
    8000311e:	1000                	add	s0,sp,32
    80003120:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003122:	00000097          	auipc	ra,0x0
    80003126:	ece080e7          	jalr	-306(ra) # 80002ff0 <argraw>
    8000312a:	e088                	sd	a0,0(s1)
}
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	add	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003136:	7179                	add	sp,sp,-48
    80003138:	f406                	sd	ra,40(sp)
    8000313a:	f022                	sd	s0,32(sp)
    8000313c:	ec26                	sd	s1,24(sp)
    8000313e:	e84a                	sd	s2,16(sp)
    80003140:	1800                	add	s0,sp,48
    80003142:	84ae                	mv	s1,a1
    80003144:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003146:	fd840593          	add	a1,s0,-40
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	fcc080e7          	jalr	-52(ra) # 80003116 <argaddr>
  return fetchstr(addr, buf, max);
    80003152:	864a                	mv	a2,s2
    80003154:	85a6                	mv	a1,s1
    80003156:	fd843503          	ld	a0,-40(s0)
    8000315a:	00000097          	auipc	ra,0x0
    8000315e:	f50080e7          	jalr	-176(ra) # 800030aa <fetchstr>
}
    80003162:	70a2                	ld	ra,40(sp)
    80003164:	7402                	ld	s0,32(sp)
    80003166:	64e2                	ld	s1,24(sp)
    80003168:	6942                	ld	s2,16(sp)
    8000316a:	6145                	add	sp,sp,48
    8000316c:	8082                	ret

000000008000316e <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    8000316e:	1101                	add	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	e426                	sd	s1,8(sp)
    80003176:	e04a                	sd	s2,0(sp)
    80003178:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000317a:	fffff097          	auipc	ra,0xfffff
    8000317e:	82c080e7          	jalr	-2004(ra) # 800019a6 <myproc>
    80003182:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003184:	09053903          	ld	s2,144(a0)
    80003188:	0a893783          	ld	a5,168(s2)
    8000318c:	0007869b          	sext.w	a3,a5
  if (num==SYS_read){
    80003190:	4715                	li	a4,5
    80003192:	02e68663          	beq	a3,a4,800031be <syscall+0x50>
    readcount++; //my change
  }
  if (num==SYS_getreadcount){
    80003196:	475d                	li	a4,23
    80003198:	04e69663          	bne	a3,a4,800031e4 <syscall+0x76>
    p->readid = readcount; //my change
    8000319c:	00005717          	auipc	a4,0x5
    800031a0:	74c73703          	ld	a4,1868(a4) # 800088e8 <readcount>
    800031a4:	e138                	sd	a4,64(a0)
  }
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031a6:	37fd                	addw	a5,a5,-1
    800031a8:	4661                	li	a2,24
    800031aa:	00000717          	auipc	a4,0x0
    800031ae:	0a870713          	add	a4,a4,168 # 80003252 <sys_getreadcount>
    800031b2:	04f66663          	bltu	a2,a5,800031fe <syscall+0x90>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800031b6:	9702                	jalr	a4
    800031b8:	06a93823          	sd	a0,112(s2)
    800031bc:	a8b9                	j	8000321a <syscall+0xac>
    readcount++; //my change
    800031be:	00005617          	auipc	a2,0x5
    800031c2:	72a60613          	add	a2,a2,1834 # 800088e8 <readcount>
    800031c6:	6218                	ld	a4,0(a2)
    800031c8:	0705                	add	a4,a4,1
    800031ca:	e218                	sd	a4,0(a2)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031cc:	37fd                	addw	a5,a5,-1
    800031ce:	4761                	li	a4,24
    800031d0:	02f76763          	bltu	a4,a5,800031fe <syscall+0x90>
    800031d4:	068e                	sll	a3,a3,0x3
    800031d6:	00005797          	auipc	a5,0x5
    800031da:	27a78793          	add	a5,a5,634 # 80008450 <syscalls>
    800031de:	97b6                	add	a5,a5,a3
    800031e0:	6398                	ld	a4,0(a5)
    800031e2:	bfd1                	j	800031b6 <syscall+0x48>
    800031e4:	37fd                	addw	a5,a5,-1
    800031e6:	4761                	li	a4,24
    800031e8:	00f76b63          	bltu	a4,a5,800031fe <syscall+0x90>
    800031ec:	00369713          	sll	a4,a3,0x3
    800031f0:	00005797          	auipc	a5,0x5
    800031f4:	26078793          	add	a5,a5,608 # 80008450 <syscalls>
    800031f8:	97ba                	add	a5,a5,a4
    800031fa:	6398                	ld	a4,0(a5)
    800031fc:	ff4d                	bnez	a4,800031b6 <syscall+0x48>
  }
   else {
    printf("%d %s: unknown sys call %d\n",
    800031fe:	19048613          	add	a2,s1,400
    80003202:	588c                	lw	a1,48(s1)
    80003204:	00005517          	auipc	a0,0x5
    80003208:	21450513          	add	a0,a0,532 # 80008418 <states.0+0x150>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	37a080e7          	jalr	890(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003214:	68dc                	ld	a5,144(s1)
    80003216:	577d                	li	a4,-1
    80003218:	fbb8                	sd	a4,112(a5)
  }
}
    8000321a:	60e2                	ld	ra,24(sp)
    8000321c:	6442                	ld	s0,16(sp)
    8000321e:	64a2                	ld	s1,8(sp)
    80003220:	6902                	ld	s2,0(sp)
    80003222:	6105                	add	sp,sp,32
    80003224:	8082                	ret

0000000080003226 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003226:	1101                	add	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    8000322e:	fec40593          	add	a1,s0,-20
    80003232:	4501                	li	a0,0
    80003234:	00000097          	auipc	ra,0x0
    80003238:	ec2080e7          	jalr	-318(ra) # 800030f6 <argint>
  exit(n);
    8000323c:	fec42503          	lw	a0,-20(s0)
    80003240:	fffff097          	auipc	ra,0xfffff
    80003244:	086080e7          	jalr	134(ra) # 800022c6 <exit>
  return 0; // not reached
}
    80003248:	4501                	li	a0,0
    8000324a:	60e2                	ld	ra,24(sp)
    8000324c:	6442                	ld	s0,16(sp)
    8000324e:	6105                	add	sp,sp,32
    80003250:	8082                	ret

0000000080003252 <sys_getreadcount>:
uint64
sys_getreadcount(void)
{
    80003252:	1141                	add	sp,sp,-16
    80003254:	e406                	sd	ra,8(sp)
    80003256:	e022                	sd	s0,0(sp)
    80003258:	0800                	add	s0,sp,16
  return myproc()->readid;
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	74c080e7          	jalr	1868(ra) # 800019a6 <myproc>
}
    80003262:	6128                	ld	a0,64(a0)
    80003264:	60a2                	ld	ra,8(sp)
    80003266:	6402                	ld	s0,0(sp)
    80003268:	0141                	add	sp,sp,16
    8000326a:	8082                	ret

000000008000326c <sys_sigalarm>:
uint64
sys_sigalarm(void)
{
    8000326c:	7179                	add	sp,sp,-48
    8000326e:	f406                	sd	ra,40(sp)
    80003270:	f022                	sd	s0,32(sp)
    80003272:	ec26                	sd	s1,24(sp)
    80003274:	1800                	add	s0,sp,48
  myproc()->sigalarm = 0;
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	730080e7          	jalr	1840(ra) # 800019a6 <myproc>
    8000327e:	04052423          	sw	zero,72(a0)

  int interval;
  argint(0, &interval);
    80003282:	fdc40593          	add	a1,s0,-36
    80003286:	4501                	li	a0,0
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	e6e080e7          	jalr	-402(ra) # 800030f6 <argint>
  myproc()->sigalarm_interval = interval;
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	716080e7          	jalr	1814(ra) # 800019a6 <myproc>
    80003298:	fdc42783          	lw	a5,-36(s0)
    8000329c:	c57c                	sw	a5,76(a0)

  uint64 handler;
  argaddr(1, &handler);
    8000329e:	fd040593          	add	a1,s0,-48
    800032a2:	4505                	li	a0,1
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	e72080e7          	jalr	-398(ra) # 80003116 <argaddr>
  myproc()->sigalarm_handler = handler;
    800032ac:	fd043483          	ld	s1,-48(s0)
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	6f6080e7          	jalr	1782(ra) # 800019a6 <myproc>
    800032b8:	c924                	sw	s1,80(a0)

  myproc()->CPU_ticks = 0;
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	6ec080e7          	jalr	1772(ra) # 800019a6 <myproc>
    800032c2:	04052a23          	sw	zero,84(a0)
  myproc()->sigalarm = 1;
    800032c6:	ffffe097          	auipc	ra,0xffffe
    800032ca:	6e0080e7          	jalr	1760(ra) # 800019a6 <myproc>
    800032ce:	4785                	li	a5,1
    800032d0:	c53c                	sw	a5,72(a0)

  return 0;
}
    800032d2:	4501                	li	a0,0
    800032d4:	70a2                	ld	ra,40(sp)
    800032d6:	7402                	ld	s0,32(sp)
    800032d8:	64e2                	ld	s1,24(sp)
    800032da:	6145                	add	sp,sp,48
    800032dc:	8082                	ret

00000000800032de <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    800032de:	1101                	add	sp,sp,-32
    800032e0:	ec06                	sd	ra,24(sp)
    800032e2:	e822                	sd	s0,16(sp)
    800032e4:	e426                	sd	s1,8(sp)
    800032e6:	1000                	add	s0,sp,32
  *(myproc()->trapframe) = *(myproc()->cpy_trapframe);
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	6be080e7          	jalr	1726(ra) # 800019a6 <myproc>
    800032f0:	6d24                	ld	s1,88(a0)
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	6b4080e7          	jalr	1716(ra) # 800019a6 <myproc>
    800032fa:	87a6                	mv	a5,s1
    800032fc:	6958                	ld	a4,144(a0)
    800032fe:	12048493          	add	s1,s1,288
    80003302:	6388                	ld	a0,0(a5)
    80003304:	678c                	ld	a1,8(a5)
    80003306:	6b90                	ld	a2,16(a5)
    80003308:	6f94                	ld	a3,24(a5)
    8000330a:	e308                	sd	a0,0(a4)
    8000330c:	e70c                	sd	a1,8(a4)
    8000330e:	eb10                	sd	a2,16(a4)
    80003310:	ef14                	sd	a3,24(a4)
    80003312:	02078793          	add	a5,a5,32
    80003316:	02070713          	add	a4,a4,32
    8000331a:	fe9794e3          	bne	a5,s1,80003302 <sys_sigreturn+0x24>
  myproc()->sigalarm = 1;
    8000331e:	ffffe097          	auipc	ra,0xffffe
    80003322:	688080e7          	jalr	1672(ra) # 800019a6 <myproc>
    80003326:	4785                	li	a5,1
    80003328:	c53c                	sw	a5,72(a0)
  usertrapret();
    8000332a:	fffff097          	auipc	ra,0xfffff
    8000332e:	6bc080e7          	jalr	1724(ra) # 800029e6 <usertrapret>

  return 0;
}
    80003332:	4501                	li	a0,0
    80003334:	60e2                	ld	ra,24(sp)
    80003336:	6442                	ld	s0,16(sp)
    80003338:	64a2                	ld	s1,8(sp)
    8000333a:	6105                	add	sp,sp,32
    8000333c:	8082                	ret

000000008000333e <sys_getpid>:
uint64
sys_getpid(void)
{
    8000333e:	1141                	add	sp,sp,-16
    80003340:	e406                	sd	ra,8(sp)
    80003342:	e022                	sd	s0,0(sp)
    80003344:	0800                	add	s0,sp,16
  return myproc()->pid;
    80003346:	ffffe097          	auipc	ra,0xffffe
    8000334a:	660080e7          	jalr	1632(ra) # 800019a6 <myproc>
}
    8000334e:	5908                	lw	a0,48(a0)
    80003350:	60a2                	ld	ra,8(sp)
    80003352:	6402                	ld	s0,0(sp)
    80003354:	0141                	add	sp,sp,16
    80003356:	8082                	ret

0000000080003358 <sys_fork>:

uint64
sys_fork(void)
{
    80003358:	1141                	add	sp,sp,-16
    8000335a:	e406                	sd	ra,8(sp)
    8000335c:	e022                	sd	s0,0(sp)
    8000335e:	0800                	add	s0,sp,16
  return fork();
    80003360:	fffff097          	auipc	ra,0xfffff
    80003364:	aa2080e7          	jalr	-1374(ra) # 80001e02 <fork>
}
    80003368:	60a2                	ld	ra,8(sp)
    8000336a:	6402                	ld	s0,0(sp)
    8000336c:	0141                	add	sp,sp,16
    8000336e:	8082                	ret

0000000080003370 <sys_wait>:

uint64
sys_wait(void)
{
    80003370:	1101                	add	sp,sp,-32
    80003372:	ec06                	sd	ra,24(sp)
    80003374:	e822                	sd	s0,16(sp)
    80003376:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003378:	fe840593          	add	a1,s0,-24
    8000337c:	4501                	li	a0,0
    8000337e:	00000097          	auipc	ra,0x0
    80003382:	d98080e7          	jalr	-616(ra) # 80003116 <argaddr>
  return wait(p);
    80003386:	fe843503          	ld	a0,-24(s0)
    8000338a:	fffff097          	auipc	ra,0xfffff
    8000338e:	0ee080e7          	jalr	238(ra) # 80002478 <wait>
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	6105                	add	sp,sp,32
    80003398:	8082                	ret

000000008000339a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000339a:	7179                	add	sp,sp,-48
    8000339c:	f406                	sd	ra,40(sp)
    8000339e:	f022                	sd	s0,32(sp)
    800033a0:	ec26                	sd	s1,24(sp)
    800033a2:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800033a4:	fdc40593          	add	a1,s0,-36
    800033a8:	4501                	li	a0,0
    800033aa:	00000097          	auipc	ra,0x0
    800033ae:	d4c080e7          	jalr	-692(ra) # 800030f6 <argint>
  addr = myproc()->sz;
    800033b2:	ffffe097          	auipc	ra,0xffffe
    800033b6:	5f4080e7          	jalr	1524(ra) # 800019a6 <myproc>
    800033ba:	6144                	ld	s1,128(a0)
  if (growproc(n) < 0)
    800033bc:	fdc42503          	lw	a0,-36(s0)
    800033c0:	fffff097          	auipc	ra,0xfffff
    800033c4:	9e6080e7          	jalr	-1562(ra) # 80001da6 <growproc>
    800033c8:	00054863          	bltz	a0,800033d8 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800033cc:	8526                	mv	a0,s1
    800033ce:	70a2                	ld	ra,40(sp)
    800033d0:	7402                	ld	s0,32(sp)
    800033d2:	64e2                	ld	s1,24(sp)
    800033d4:	6145                	add	sp,sp,48
    800033d6:	8082                	ret
    return -1;
    800033d8:	54fd                	li	s1,-1
    800033da:	bfcd                	j	800033cc <sys_sbrk+0x32>

00000000800033dc <sys_sleep>:

uint64
sys_sleep(void)
{
    800033dc:	7139                	add	sp,sp,-64
    800033de:	fc06                	sd	ra,56(sp)
    800033e0:	f822                	sd	s0,48(sp)
    800033e2:	f426                	sd	s1,40(sp)
    800033e4:	f04a                	sd	s2,32(sp)
    800033e6:	ec4e                	sd	s3,24(sp)
    800033e8:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800033ea:	fcc40593          	add	a1,s0,-52
    800033ee:	4501                	li	a0,0
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	d06080e7          	jalr	-762(ra) # 800030f6 <argint>
  acquire(&tickslock);
    800033f8:	00014517          	auipc	a0,0x14
    800033fc:	79850513          	add	a0,a0,1944 # 80017b90 <tickslock>
    80003400:	ffffd097          	auipc	ra,0xffffd
    80003404:	7d2080e7          	jalr	2002(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80003408:	00005917          	auipc	s2,0x5
    8000340c:	4d892903          	lw	s2,1240(s2) # 800088e0 <ticks>
  while (ticks - ticks0 < n)
    80003410:	fcc42783          	lw	a5,-52(s0)
    80003414:	cf9d                	beqz	a5,80003452 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003416:	00014997          	auipc	s3,0x14
    8000341a:	77a98993          	add	s3,s3,1914 # 80017b90 <tickslock>
    8000341e:	00005497          	auipc	s1,0x5
    80003422:	4c248493          	add	s1,s1,1218 # 800088e0 <ticks>
    if (killed(myproc()))
    80003426:	ffffe097          	auipc	ra,0xffffe
    8000342a:	580080e7          	jalr	1408(ra) # 800019a6 <myproc>
    8000342e:	fffff097          	auipc	ra,0xfffff
    80003432:	018080e7          	jalr	24(ra) # 80002446 <killed>
    80003436:	ed15                	bnez	a0,80003472 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003438:	85ce                	mv	a1,s3
    8000343a:	8526                	mv	a0,s1
    8000343c:	fffff097          	auipc	ra,0xfffff
    80003440:	d44080e7          	jalr	-700(ra) # 80002180 <sleep>
  while (ticks - ticks0 < n)
    80003444:	409c                	lw	a5,0(s1)
    80003446:	412787bb          	subw	a5,a5,s2
    8000344a:	fcc42703          	lw	a4,-52(s0)
    8000344e:	fce7ece3          	bltu	a5,a4,80003426 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003452:	00014517          	auipc	a0,0x14
    80003456:	73e50513          	add	a0,a0,1854 # 80017b90 <tickslock>
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	82c080e7          	jalr	-2004(ra) # 80000c86 <release>
  return 0;
    80003462:	4501                	li	a0,0
}
    80003464:	70e2                	ld	ra,56(sp)
    80003466:	7442                	ld	s0,48(sp)
    80003468:	74a2                	ld	s1,40(sp)
    8000346a:	7902                	ld	s2,32(sp)
    8000346c:	69e2                	ld	s3,24(sp)
    8000346e:	6121                	add	sp,sp,64
    80003470:	8082                	ret
      release(&tickslock);
    80003472:	00014517          	auipc	a0,0x14
    80003476:	71e50513          	add	a0,a0,1822 # 80017b90 <tickslock>
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	80c080e7          	jalr	-2036(ra) # 80000c86 <release>
      return -1;
    80003482:	557d                	li	a0,-1
    80003484:	b7c5                	j	80003464 <sys_sleep+0x88>

0000000080003486 <sys_kill>:

uint64
sys_kill(void)
{
    80003486:	1101                	add	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    8000348e:	fec40593          	add	a1,s0,-20
    80003492:	4501                	li	a0,0
    80003494:	00000097          	auipc	ra,0x0
    80003498:	c62080e7          	jalr	-926(ra) # 800030f6 <argint>
  return kill(pid);
    8000349c:	fec42503          	lw	a0,-20(s0)
    800034a0:	fffff097          	auipc	ra,0xfffff
    800034a4:	f08080e7          	jalr	-248(ra) # 800023a8 <kill>
}
    800034a8:	60e2                	ld	ra,24(sp)
    800034aa:	6442                	ld	s0,16(sp)
    800034ac:	6105                	add	sp,sp,32
    800034ae:	8082                	ret

00000000800034b0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034b0:	1101                	add	sp,sp,-32
    800034b2:	ec06                	sd	ra,24(sp)
    800034b4:	e822                	sd	s0,16(sp)
    800034b6:	e426                	sd	s1,8(sp)
    800034b8:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034ba:	00014517          	auipc	a0,0x14
    800034be:	6d650513          	add	a0,a0,1750 # 80017b90 <tickslock>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	710080e7          	jalr	1808(ra) # 80000bd2 <acquire>
  xticks = ticks;
    800034ca:	00005497          	auipc	s1,0x5
    800034ce:	4164a483          	lw	s1,1046(s1) # 800088e0 <ticks>
  release(&tickslock);
    800034d2:	00014517          	auipc	a0,0x14
    800034d6:	6be50513          	add	a0,a0,1726 # 80017b90 <tickslock>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	7ac080e7          	jalr	1964(ra) # 80000c86 <release>
  return xticks;
}
    800034e2:	02049513          	sll	a0,s1,0x20
    800034e6:	9101                	srl	a0,a0,0x20
    800034e8:	60e2                	ld	ra,24(sp)
    800034ea:	6442                	ld	s0,16(sp)
    800034ec:	64a2                	ld	s1,8(sp)
    800034ee:	6105                	add	sp,sp,32
    800034f0:	8082                	ret

00000000800034f2 <sys_waitx>:

uint64
sys_waitx(void)
{
    800034f2:	7139                	add	sp,sp,-64
    800034f4:	fc06                	sd	ra,56(sp)
    800034f6:	f822                	sd	s0,48(sp)
    800034f8:	f426                	sd	s1,40(sp)
    800034fa:	f04a                	sd	s2,32(sp)
    800034fc:	0080                	add	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800034fe:	fd840593          	add	a1,s0,-40
    80003502:	4501                	li	a0,0
    80003504:	00000097          	auipc	ra,0x0
    80003508:	c12080e7          	jalr	-1006(ra) # 80003116 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000350c:	fd040593          	add	a1,s0,-48
    80003510:	4505                	li	a0,1
    80003512:	00000097          	auipc	ra,0x0
    80003516:	c04080e7          	jalr	-1020(ra) # 80003116 <argaddr>
  argaddr(2, &addr2);
    8000351a:	fc840593          	add	a1,s0,-56
    8000351e:	4509                	li	a0,2
    80003520:	00000097          	auipc	ra,0x0
    80003524:	bf6080e7          	jalr	-1034(ra) # 80003116 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003528:	fc040613          	add	a2,s0,-64
    8000352c:	fc440593          	add	a1,s0,-60
    80003530:	fd843503          	ld	a0,-40(s0)
    80003534:	fffff097          	auipc	ra,0xfffff
    80003538:	1ce080e7          	jalr	462(ra) # 80002702 <waitx>
    8000353c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000353e:	ffffe097          	auipc	ra,0xffffe
    80003542:	468080e7          	jalr	1128(ra) # 800019a6 <myproc>
    80003546:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003548:	4691                	li	a3,4
    8000354a:	fc440613          	add	a2,s0,-60
    8000354e:	fd043583          	ld	a1,-48(s0)
    80003552:	6548                	ld	a0,136(a0)
    80003554:	ffffe097          	auipc	ra,0xffffe
    80003558:	112080e7          	jalr	274(ra) # 80001666 <copyout>
    return -1;
    8000355c:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000355e:	00054f63          	bltz	a0,8000357c <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003562:	4691                	li	a3,4
    80003564:	fc040613          	add	a2,s0,-64
    80003568:	fc843583          	ld	a1,-56(s0)
    8000356c:	64c8                	ld	a0,136(s1)
    8000356e:	ffffe097          	auipc	ra,0xffffe
    80003572:	0f8080e7          	jalr	248(ra) # 80001666 <copyout>
    80003576:	00054a63          	bltz	a0,8000358a <sys_waitx+0x98>
    return -1;
  return ret;
    8000357a:	87ca                	mv	a5,s2
    8000357c:	853e                	mv	a0,a5
    8000357e:	70e2                	ld	ra,56(sp)
    80003580:	7442                	ld	s0,48(sp)
    80003582:	74a2                	ld	s1,40(sp)
    80003584:	7902                	ld	s2,32(sp)
    80003586:	6121                	add	sp,sp,64
    80003588:	8082                	ret
    return -1;
    8000358a:	57fd                	li	a5,-1
    8000358c:	bfc5                	j	8000357c <sys_waitx+0x8a>

000000008000358e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000358e:	7179                	add	sp,sp,-48
    80003590:	f406                	sd	ra,40(sp)
    80003592:	f022                	sd	s0,32(sp)
    80003594:	ec26                	sd	s1,24(sp)
    80003596:	e84a                	sd	s2,16(sp)
    80003598:	e44e                	sd	s3,8(sp)
    8000359a:	e052                	sd	s4,0(sp)
    8000359c:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000359e:	00005597          	auipc	a1,0x5
    800035a2:	f8258593          	add	a1,a1,-126 # 80008520 <syscalls+0xd0>
    800035a6:	00014517          	auipc	a0,0x14
    800035aa:	60250513          	add	a0,a0,1538 # 80017ba8 <bcache>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	594080e7          	jalr	1428(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035b6:	0001c797          	auipc	a5,0x1c
    800035ba:	5f278793          	add	a5,a5,1522 # 8001fba8 <bcache+0x8000>
    800035be:	0001d717          	auipc	a4,0x1d
    800035c2:	85270713          	add	a4,a4,-1966 # 8001fe10 <bcache+0x8268>
    800035c6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800035ca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035ce:	00014497          	auipc	s1,0x14
    800035d2:	5f248493          	add	s1,s1,1522 # 80017bc0 <bcache+0x18>
    b->next = bcache.head.next;
    800035d6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035d8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035da:	00005a17          	auipc	s4,0x5
    800035de:	f4ea0a13          	add	s4,s4,-178 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    800035e2:	2b893783          	ld	a5,696(s2)
    800035e6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800035e8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800035ec:	85d2                	mv	a1,s4
    800035ee:	01048513          	add	a0,s1,16
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	496080e7          	jalr	1174(ra) # 80004a88 <initsleeplock>
    bcache.head.next->prev = b;
    800035fa:	2b893783          	ld	a5,696(s2)
    800035fe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003600:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003604:	45848493          	add	s1,s1,1112
    80003608:	fd349de3          	bne	s1,s3,800035e2 <binit+0x54>
  }
}
    8000360c:	70a2                	ld	ra,40(sp)
    8000360e:	7402                	ld	s0,32(sp)
    80003610:	64e2                	ld	s1,24(sp)
    80003612:	6942                	ld	s2,16(sp)
    80003614:	69a2                	ld	s3,8(sp)
    80003616:	6a02                	ld	s4,0(sp)
    80003618:	6145                	add	sp,sp,48
    8000361a:	8082                	ret

000000008000361c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000361c:	7179                	add	sp,sp,-48
    8000361e:	f406                	sd	ra,40(sp)
    80003620:	f022                	sd	s0,32(sp)
    80003622:	ec26                	sd	s1,24(sp)
    80003624:	e84a                	sd	s2,16(sp)
    80003626:	e44e                	sd	s3,8(sp)
    80003628:	1800                	add	s0,sp,48
    8000362a:	892a                	mv	s2,a0
    8000362c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000362e:	00014517          	auipc	a0,0x14
    80003632:	57a50513          	add	a0,a0,1402 # 80017ba8 <bcache>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	59c080e7          	jalr	1436(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000363e:	0001d497          	auipc	s1,0x1d
    80003642:	8224b483          	ld	s1,-2014(s1) # 8001fe60 <bcache+0x82b8>
    80003646:	0001c797          	auipc	a5,0x1c
    8000364a:	7ca78793          	add	a5,a5,1994 # 8001fe10 <bcache+0x8268>
    8000364e:	02f48f63          	beq	s1,a5,8000368c <bread+0x70>
    80003652:	873e                	mv	a4,a5
    80003654:	a021                	j	8000365c <bread+0x40>
    80003656:	68a4                	ld	s1,80(s1)
    80003658:	02e48a63          	beq	s1,a4,8000368c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000365c:	449c                	lw	a5,8(s1)
    8000365e:	ff279ce3          	bne	a5,s2,80003656 <bread+0x3a>
    80003662:	44dc                	lw	a5,12(s1)
    80003664:	ff3799e3          	bne	a5,s3,80003656 <bread+0x3a>
      b->refcnt++;
    80003668:	40bc                	lw	a5,64(s1)
    8000366a:	2785                	addw	a5,a5,1
    8000366c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000366e:	00014517          	auipc	a0,0x14
    80003672:	53a50513          	add	a0,a0,1338 # 80017ba8 <bcache>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	610080e7          	jalr	1552(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000367e:	01048513          	add	a0,s1,16
    80003682:	00001097          	auipc	ra,0x1
    80003686:	440080e7          	jalr	1088(ra) # 80004ac2 <acquiresleep>
      return b;
    8000368a:	a8b9                	j	800036e8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000368c:	0001c497          	auipc	s1,0x1c
    80003690:	7cc4b483          	ld	s1,1996(s1) # 8001fe58 <bcache+0x82b0>
    80003694:	0001c797          	auipc	a5,0x1c
    80003698:	77c78793          	add	a5,a5,1916 # 8001fe10 <bcache+0x8268>
    8000369c:	00f48863          	beq	s1,a5,800036ac <bread+0x90>
    800036a0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036a2:	40bc                	lw	a5,64(s1)
    800036a4:	cf81                	beqz	a5,800036bc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036a6:	64a4                	ld	s1,72(s1)
    800036a8:	fee49de3          	bne	s1,a4,800036a2 <bread+0x86>
  panic("bget: no buffers");
    800036ac:	00005517          	auipc	a0,0x5
    800036b0:	e8450513          	add	a0,a0,-380 # 80008530 <syscalls+0xe0>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	e88080e7          	jalr	-376(ra) # 8000053c <panic>
      b->dev = dev;
    800036bc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800036c0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800036c4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036c8:	4785                	li	a5,1
    800036ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036cc:	00014517          	auipc	a0,0x14
    800036d0:	4dc50513          	add	a0,a0,1244 # 80017ba8 <bcache>
    800036d4:	ffffd097          	auipc	ra,0xffffd
    800036d8:	5b2080e7          	jalr	1458(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800036dc:	01048513          	add	a0,s1,16
    800036e0:	00001097          	auipc	ra,0x1
    800036e4:	3e2080e7          	jalr	994(ra) # 80004ac2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036e8:	409c                	lw	a5,0(s1)
    800036ea:	cb89                	beqz	a5,800036fc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800036ec:	8526                	mv	a0,s1
    800036ee:	70a2                	ld	ra,40(sp)
    800036f0:	7402                	ld	s0,32(sp)
    800036f2:	64e2                	ld	s1,24(sp)
    800036f4:	6942                	ld	s2,16(sp)
    800036f6:	69a2                	ld	s3,8(sp)
    800036f8:	6145                	add	sp,sp,48
    800036fa:	8082                	ret
    virtio_disk_rw(b, 0);
    800036fc:	4581                	li	a1,0
    800036fe:	8526                	mv	a0,s1
    80003700:	00003097          	auipc	ra,0x3
    80003704:	f82080e7          	jalr	-126(ra) # 80006682 <virtio_disk_rw>
    b->valid = 1;
    80003708:	4785                	li	a5,1
    8000370a:	c09c                	sw	a5,0(s1)
  return b;
    8000370c:	b7c5                	j	800036ec <bread+0xd0>

000000008000370e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000370e:	1101                	add	sp,sp,-32
    80003710:	ec06                	sd	ra,24(sp)
    80003712:	e822                	sd	s0,16(sp)
    80003714:	e426                	sd	s1,8(sp)
    80003716:	1000                	add	s0,sp,32
    80003718:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000371a:	0541                	add	a0,a0,16
    8000371c:	00001097          	auipc	ra,0x1
    80003720:	440080e7          	jalr	1088(ra) # 80004b5c <holdingsleep>
    80003724:	cd01                	beqz	a0,8000373c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003726:	4585                	li	a1,1
    80003728:	8526                	mv	a0,s1
    8000372a:	00003097          	auipc	ra,0x3
    8000372e:	f58080e7          	jalr	-168(ra) # 80006682 <virtio_disk_rw>
}
    80003732:	60e2                	ld	ra,24(sp)
    80003734:	6442                	ld	s0,16(sp)
    80003736:	64a2                	ld	s1,8(sp)
    80003738:	6105                	add	sp,sp,32
    8000373a:	8082                	ret
    panic("bwrite");
    8000373c:	00005517          	auipc	a0,0x5
    80003740:	e0c50513          	add	a0,a0,-500 # 80008548 <syscalls+0xf8>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	df8080e7          	jalr	-520(ra) # 8000053c <panic>

000000008000374c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000374c:	1101                	add	sp,sp,-32
    8000374e:	ec06                	sd	ra,24(sp)
    80003750:	e822                	sd	s0,16(sp)
    80003752:	e426                	sd	s1,8(sp)
    80003754:	e04a                	sd	s2,0(sp)
    80003756:	1000                	add	s0,sp,32
    80003758:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000375a:	01050913          	add	s2,a0,16
    8000375e:	854a                	mv	a0,s2
    80003760:	00001097          	auipc	ra,0x1
    80003764:	3fc080e7          	jalr	1020(ra) # 80004b5c <holdingsleep>
    80003768:	c925                	beqz	a0,800037d8 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8000376a:	854a                	mv	a0,s2
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	3ac080e7          	jalr	940(ra) # 80004b18 <releasesleep>

  acquire(&bcache.lock);
    80003774:	00014517          	auipc	a0,0x14
    80003778:	43450513          	add	a0,a0,1076 # 80017ba8 <bcache>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	456080e7          	jalr	1110(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003784:	40bc                	lw	a5,64(s1)
    80003786:	37fd                	addw	a5,a5,-1
    80003788:	0007871b          	sext.w	a4,a5
    8000378c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000378e:	e71d                	bnez	a4,800037bc <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003790:	68b8                	ld	a4,80(s1)
    80003792:	64bc                	ld	a5,72(s1)
    80003794:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003796:	68b8                	ld	a4,80(s1)
    80003798:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000379a:	0001c797          	auipc	a5,0x1c
    8000379e:	40e78793          	add	a5,a5,1038 # 8001fba8 <bcache+0x8000>
    800037a2:	2b87b703          	ld	a4,696(a5)
    800037a6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800037a8:	0001c717          	auipc	a4,0x1c
    800037ac:	66870713          	add	a4,a4,1640 # 8001fe10 <bcache+0x8268>
    800037b0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800037b2:	2b87b703          	ld	a4,696(a5)
    800037b6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800037b8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800037bc:	00014517          	auipc	a0,0x14
    800037c0:	3ec50513          	add	a0,a0,1004 # 80017ba8 <bcache>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	4c2080e7          	jalr	1218(ra) # 80000c86 <release>
}
    800037cc:	60e2                	ld	ra,24(sp)
    800037ce:	6442                	ld	s0,16(sp)
    800037d0:	64a2                	ld	s1,8(sp)
    800037d2:	6902                	ld	s2,0(sp)
    800037d4:	6105                	add	sp,sp,32
    800037d6:	8082                	ret
    panic("brelse");
    800037d8:	00005517          	auipc	a0,0x5
    800037dc:	d7850513          	add	a0,a0,-648 # 80008550 <syscalls+0x100>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	d5c080e7          	jalr	-676(ra) # 8000053c <panic>

00000000800037e8 <bpin>:

void
bpin(struct buf *b) {
    800037e8:	1101                	add	sp,sp,-32
    800037ea:	ec06                	sd	ra,24(sp)
    800037ec:	e822                	sd	s0,16(sp)
    800037ee:	e426                	sd	s1,8(sp)
    800037f0:	1000                	add	s0,sp,32
    800037f2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037f4:	00014517          	auipc	a0,0x14
    800037f8:	3b450513          	add	a0,a0,948 # 80017ba8 <bcache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	3d6080e7          	jalr	982(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003804:	40bc                	lw	a5,64(s1)
    80003806:	2785                	addw	a5,a5,1
    80003808:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000380a:	00014517          	auipc	a0,0x14
    8000380e:	39e50513          	add	a0,a0,926 # 80017ba8 <bcache>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	474080e7          	jalr	1140(ra) # 80000c86 <release>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6105                	add	sp,sp,32
    80003822:	8082                	ret

0000000080003824 <bunpin>:

void
bunpin(struct buf *b) {
    80003824:	1101                	add	sp,sp,-32
    80003826:	ec06                	sd	ra,24(sp)
    80003828:	e822                	sd	s0,16(sp)
    8000382a:	e426                	sd	s1,8(sp)
    8000382c:	1000                	add	s0,sp,32
    8000382e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003830:	00014517          	auipc	a0,0x14
    80003834:	37850513          	add	a0,a0,888 # 80017ba8 <bcache>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	39a080e7          	jalr	922(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003840:	40bc                	lw	a5,64(s1)
    80003842:	37fd                	addw	a5,a5,-1
    80003844:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003846:	00014517          	auipc	a0,0x14
    8000384a:	36250513          	add	a0,a0,866 # 80017ba8 <bcache>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	438080e7          	jalr	1080(ra) # 80000c86 <release>
}
    80003856:	60e2                	ld	ra,24(sp)
    80003858:	6442                	ld	s0,16(sp)
    8000385a:	64a2                	ld	s1,8(sp)
    8000385c:	6105                	add	sp,sp,32
    8000385e:	8082                	ret

0000000080003860 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003860:	1101                	add	sp,sp,-32
    80003862:	ec06                	sd	ra,24(sp)
    80003864:	e822                	sd	s0,16(sp)
    80003866:	e426                	sd	s1,8(sp)
    80003868:	e04a                	sd	s2,0(sp)
    8000386a:	1000                	add	s0,sp,32
    8000386c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000386e:	00d5d59b          	srlw	a1,a1,0xd
    80003872:	0001d797          	auipc	a5,0x1d
    80003876:	a127a783          	lw	a5,-1518(a5) # 80020284 <sb+0x1c>
    8000387a:	9dbd                	addw	a1,a1,a5
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	da0080e7          	jalr	-608(ra) # 8000361c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003884:	0074f713          	and	a4,s1,7
    80003888:	4785                	li	a5,1
    8000388a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000388e:	14ce                	sll	s1,s1,0x33
    80003890:	90d9                	srl	s1,s1,0x36
    80003892:	00950733          	add	a4,a0,s1
    80003896:	05874703          	lbu	a4,88(a4)
    8000389a:	00e7f6b3          	and	a3,a5,a4
    8000389e:	c69d                	beqz	a3,800038cc <bfree+0x6c>
    800038a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038a2:	94aa                	add	s1,s1,a0
    800038a4:	fff7c793          	not	a5,a5
    800038a8:	8f7d                	and	a4,a4,a5
    800038aa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800038ae:	00001097          	auipc	ra,0x1
    800038b2:	0f6080e7          	jalr	246(ra) # 800049a4 <log_write>
  brelse(bp);
    800038b6:	854a                	mv	a0,s2
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	e94080e7          	jalr	-364(ra) # 8000374c <brelse>
}
    800038c0:	60e2                	ld	ra,24(sp)
    800038c2:	6442                	ld	s0,16(sp)
    800038c4:	64a2                	ld	s1,8(sp)
    800038c6:	6902                	ld	s2,0(sp)
    800038c8:	6105                	add	sp,sp,32
    800038ca:	8082                	ret
    panic("freeing free block");
    800038cc:	00005517          	auipc	a0,0x5
    800038d0:	c8c50513          	add	a0,a0,-884 # 80008558 <syscalls+0x108>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	c68080e7          	jalr	-920(ra) # 8000053c <panic>

00000000800038dc <balloc>:
{
    800038dc:	711d                	add	sp,sp,-96
    800038de:	ec86                	sd	ra,88(sp)
    800038e0:	e8a2                	sd	s0,80(sp)
    800038e2:	e4a6                	sd	s1,72(sp)
    800038e4:	e0ca                	sd	s2,64(sp)
    800038e6:	fc4e                	sd	s3,56(sp)
    800038e8:	f852                	sd	s4,48(sp)
    800038ea:	f456                	sd	s5,40(sp)
    800038ec:	f05a                	sd	s6,32(sp)
    800038ee:	ec5e                	sd	s7,24(sp)
    800038f0:	e862                	sd	s8,16(sp)
    800038f2:	e466                	sd	s9,8(sp)
    800038f4:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800038f6:	0001d797          	auipc	a5,0x1d
    800038fa:	9767a783          	lw	a5,-1674(a5) # 8002026c <sb+0x4>
    800038fe:	cff5                	beqz	a5,800039fa <balloc+0x11e>
    80003900:	8baa                	mv	s7,a0
    80003902:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003904:	0001db17          	auipc	s6,0x1d
    80003908:	964b0b13          	add	s6,s6,-1692 # 80020268 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000390c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000390e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003910:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003912:	6c89                	lui	s9,0x2
    80003914:	a061                	j	8000399c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003916:	97ca                	add	a5,a5,s2
    80003918:	8e55                	or	a2,a2,a3
    8000391a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000391e:	854a                	mv	a0,s2
    80003920:	00001097          	auipc	ra,0x1
    80003924:	084080e7          	jalr	132(ra) # 800049a4 <log_write>
        brelse(bp);
    80003928:	854a                	mv	a0,s2
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	e22080e7          	jalr	-478(ra) # 8000374c <brelse>
  bp = bread(dev, bno);
    80003932:	85a6                	mv	a1,s1
    80003934:	855e                	mv	a0,s7
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	ce6080e7          	jalr	-794(ra) # 8000361c <bread>
    8000393e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003940:	40000613          	li	a2,1024
    80003944:	4581                	li	a1,0
    80003946:	05850513          	add	a0,a0,88
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	384080e7          	jalr	900(ra) # 80000cce <memset>
  log_write(bp);
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	050080e7          	jalr	80(ra) # 800049a4 <log_write>
  brelse(bp);
    8000395c:	854a                	mv	a0,s2
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	dee080e7          	jalr	-530(ra) # 8000374c <brelse>
}
    80003966:	8526                	mv	a0,s1
    80003968:	60e6                	ld	ra,88(sp)
    8000396a:	6446                	ld	s0,80(sp)
    8000396c:	64a6                	ld	s1,72(sp)
    8000396e:	6906                	ld	s2,64(sp)
    80003970:	79e2                	ld	s3,56(sp)
    80003972:	7a42                	ld	s4,48(sp)
    80003974:	7aa2                	ld	s5,40(sp)
    80003976:	7b02                	ld	s6,32(sp)
    80003978:	6be2                	ld	s7,24(sp)
    8000397a:	6c42                	ld	s8,16(sp)
    8000397c:	6ca2                	ld	s9,8(sp)
    8000397e:	6125                	add	sp,sp,96
    80003980:	8082                	ret
    brelse(bp);
    80003982:	854a                	mv	a0,s2
    80003984:	00000097          	auipc	ra,0x0
    80003988:	dc8080e7          	jalr	-568(ra) # 8000374c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000398c:	015c87bb          	addw	a5,s9,s5
    80003990:	00078a9b          	sext.w	s5,a5
    80003994:	004b2703          	lw	a4,4(s6)
    80003998:	06eaf163          	bgeu	s5,a4,800039fa <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000399c:	41fad79b          	sraw	a5,s5,0x1f
    800039a0:	0137d79b          	srlw	a5,a5,0x13
    800039a4:	015787bb          	addw	a5,a5,s5
    800039a8:	40d7d79b          	sraw	a5,a5,0xd
    800039ac:	01cb2583          	lw	a1,28(s6)
    800039b0:	9dbd                	addw	a1,a1,a5
    800039b2:	855e                	mv	a0,s7
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	c68080e7          	jalr	-920(ra) # 8000361c <bread>
    800039bc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039be:	004b2503          	lw	a0,4(s6)
    800039c2:	000a849b          	sext.w	s1,s5
    800039c6:	8762                	mv	a4,s8
    800039c8:	faa4fde3          	bgeu	s1,a0,80003982 <balloc+0xa6>
      m = 1 << (bi % 8);
    800039cc:	00777693          	and	a3,a4,7
    800039d0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800039d4:	41f7579b          	sraw	a5,a4,0x1f
    800039d8:	01d7d79b          	srlw	a5,a5,0x1d
    800039dc:	9fb9                	addw	a5,a5,a4
    800039de:	4037d79b          	sraw	a5,a5,0x3
    800039e2:	00f90633          	add	a2,s2,a5
    800039e6:	05864603          	lbu	a2,88(a2)
    800039ea:	00c6f5b3          	and	a1,a3,a2
    800039ee:	d585                	beqz	a1,80003916 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039f0:	2705                	addw	a4,a4,1
    800039f2:	2485                	addw	s1,s1,1
    800039f4:	fd471ae3          	bne	a4,s4,800039c8 <balloc+0xec>
    800039f8:	b769                	j	80003982 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800039fa:	00005517          	auipc	a0,0x5
    800039fe:	b7650513          	add	a0,a0,-1162 # 80008570 <syscalls+0x120>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	b84080e7          	jalr	-1148(ra) # 80000586 <printf>
  return 0;
    80003a0a:	4481                	li	s1,0
    80003a0c:	bfa9                	j	80003966 <balloc+0x8a>

0000000080003a0e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a0e:	7179                	add	sp,sp,-48
    80003a10:	f406                	sd	ra,40(sp)
    80003a12:	f022                	sd	s0,32(sp)
    80003a14:	ec26                	sd	s1,24(sp)
    80003a16:	e84a                	sd	s2,16(sp)
    80003a18:	e44e                	sd	s3,8(sp)
    80003a1a:	e052                	sd	s4,0(sp)
    80003a1c:	1800                	add	s0,sp,48
    80003a1e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a20:	47ad                	li	a5,11
    80003a22:	02b7e863          	bltu	a5,a1,80003a52 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003a26:	02059793          	sll	a5,a1,0x20
    80003a2a:	01e7d593          	srl	a1,a5,0x1e
    80003a2e:	00b504b3          	add	s1,a0,a1
    80003a32:	0504a903          	lw	s2,80(s1)
    80003a36:	06091e63          	bnez	s2,80003ab2 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003a3a:	4108                	lw	a0,0(a0)
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	ea0080e7          	jalr	-352(ra) # 800038dc <balloc>
    80003a44:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a48:	06090563          	beqz	s2,80003ab2 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003a4c:	0524a823          	sw	s2,80(s1)
    80003a50:	a08d                	j	80003ab2 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003a52:	ff45849b          	addw	s1,a1,-12
    80003a56:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a5a:	0ff00793          	li	a5,255
    80003a5e:	08e7e563          	bltu	a5,a4,80003ae8 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003a62:	08052903          	lw	s2,128(a0)
    80003a66:	00091d63          	bnez	s2,80003a80 <bmap+0x72>
      addr = balloc(ip->dev);
    80003a6a:	4108                	lw	a0,0(a0)
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	e70080e7          	jalr	-400(ra) # 800038dc <balloc>
    80003a74:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a78:	02090d63          	beqz	s2,80003ab2 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a7c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a80:	85ca                	mv	a1,s2
    80003a82:	0009a503          	lw	a0,0(s3)
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	b96080e7          	jalr	-1130(ra) # 8000361c <bread>
    80003a8e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a90:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a94:	02049713          	sll	a4,s1,0x20
    80003a98:	01e75593          	srl	a1,a4,0x1e
    80003a9c:	00b784b3          	add	s1,a5,a1
    80003aa0:	0004a903          	lw	s2,0(s1)
    80003aa4:	02090063          	beqz	s2,80003ac4 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	ca2080e7          	jalr	-862(ra) # 8000374c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	70a2                	ld	ra,40(sp)
    80003ab6:	7402                	ld	s0,32(sp)
    80003ab8:	64e2                	ld	s1,24(sp)
    80003aba:	6942                	ld	s2,16(sp)
    80003abc:	69a2                	ld	s3,8(sp)
    80003abe:	6a02                	ld	s4,0(sp)
    80003ac0:	6145                	add	sp,sp,48
    80003ac2:	8082                	ret
      addr = balloc(ip->dev);
    80003ac4:	0009a503          	lw	a0,0(s3)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	e14080e7          	jalr	-492(ra) # 800038dc <balloc>
    80003ad0:	0005091b          	sext.w	s2,a0
      if(addr){
    80003ad4:	fc090ae3          	beqz	s2,80003aa8 <bmap+0x9a>
        a[bn] = addr;
    80003ad8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003adc:	8552                	mv	a0,s4
    80003ade:	00001097          	auipc	ra,0x1
    80003ae2:	ec6080e7          	jalr	-314(ra) # 800049a4 <log_write>
    80003ae6:	b7c9                	j	80003aa8 <bmap+0x9a>
  panic("bmap: out of range");
    80003ae8:	00005517          	auipc	a0,0x5
    80003aec:	aa050513          	add	a0,a0,-1376 # 80008588 <syscalls+0x138>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a4c080e7          	jalr	-1460(ra) # 8000053c <panic>

0000000080003af8 <iget>:
{
    80003af8:	7179                	add	sp,sp,-48
    80003afa:	f406                	sd	ra,40(sp)
    80003afc:	f022                	sd	s0,32(sp)
    80003afe:	ec26                	sd	s1,24(sp)
    80003b00:	e84a                	sd	s2,16(sp)
    80003b02:	e44e                	sd	s3,8(sp)
    80003b04:	e052                	sd	s4,0(sp)
    80003b06:	1800                	add	s0,sp,48
    80003b08:	89aa                	mv	s3,a0
    80003b0a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b0c:	0001c517          	auipc	a0,0x1c
    80003b10:	77c50513          	add	a0,a0,1916 # 80020288 <itable>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	0be080e7          	jalr	190(ra) # 80000bd2 <acquire>
  empty = 0;
    80003b1c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b1e:	0001c497          	auipc	s1,0x1c
    80003b22:	78248493          	add	s1,s1,1922 # 800202a0 <itable+0x18>
    80003b26:	0001e697          	auipc	a3,0x1e
    80003b2a:	20a68693          	add	a3,a3,522 # 80021d30 <log>
    80003b2e:	a039                	j	80003b3c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b30:	02090b63          	beqz	s2,80003b66 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b34:	08848493          	add	s1,s1,136
    80003b38:	02d48a63          	beq	s1,a3,80003b6c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b3c:	449c                	lw	a5,8(s1)
    80003b3e:	fef059e3          	blez	a5,80003b30 <iget+0x38>
    80003b42:	4098                	lw	a4,0(s1)
    80003b44:	ff3716e3          	bne	a4,s3,80003b30 <iget+0x38>
    80003b48:	40d8                	lw	a4,4(s1)
    80003b4a:	ff4713e3          	bne	a4,s4,80003b30 <iget+0x38>
      ip->ref++;
    80003b4e:	2785                	addw	a5,a5,1
    80003b50:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003b52:	0001c517          	auipc	a0,0x1c
    80003b56:	73650513          	add	a0,a0,1846 # 80020288 <itable>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	12c080e7          	jalr	300(ra) # 80000c86 <release>
      return ip;
    80003b62:	8926                	mv	s2,s1
    80003b64:	a03d                	j	80003b92 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b66:	f7f9                	bnez	a5,80003b34 <iget+0x3c>
    80003b68:	8926                	mv	s2,s1
    80003b6a:	b7e9                	j	80003b34 <iget+0x3c>
  if(empty == 0)
    80003b6c:	02090c63          	beqz	s2,80003ba4 <iget+0xac>
  ip->dev = dev;
    80003b70:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b74:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b78:	4785                	li	a5,1
    80003b7a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b7e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b82:	0001c517          	auipc	a0,0x1c
    80003b86:	70650513          	add	a0,a0,1798 # 80020288 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	0fc080e7          	jalr	252(ra) # 80000c86 <release>
}
    80003b92:	854a                	mv	a0,s2
    80003b94:	70a2                	ld	ra,40(sp)
    80003b96:	7402                	ld	s0,32(sp)
    80003b98:	64e2                	ld	s1,24(sp)
    80003b9a:	6942                	ld	s2,16(sp)
    80003b9c:	69a2                	ld	s3,8(sp)
    80003b9e:	6a02                	ld	s4,0(sp)
    80003ba0:	6145                	add	sp,sp,48
    80003ba2:	8082                	ret
    panic("iget: no inodes");
    80003ba4:	00005517          	auipc	a0,0x5
    80003ba8:	9fc50513          	add	a0,a0,-1540 # 800085a0 <syscalls+0x150>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	990080e7          	jalr	-1648(ra) # 8000053c <panic>

0000000080003bb4 <fsinit>:
fsinit(int dev) {
    80003bb4:	7179                	add	sp,sp,-48
    80003bb6:	f406                	sd	ra,40(sp)
    80003bb8:	f022                	sd	s0,32(sp)
    80003bba:	ec26                	sd	s1,24(sp)
    80003bbc:	e84a                	sd	s2,16(sp)
    80003bbe:	e44e                	sd	s3,8(sp)
    80003bc0:	1800                	add	s0,sp,48
    80003bc2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003bc4:	4585                	li	a1,1
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	a56080e7          	jalr	-1450(ra) # 8000361c <bread>
    80003bce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003bd0:	0001c997          	auipc	s3,0x1c
    80003bd4:	69898993          	add	s3,s3,1688 # 80020268 <sb>
    80003bd8:	02000613          	li	a2,32
    80003bdc:	05850593          	add	a1,a0,88
    80003be0:	854e                	mv	a0,s3
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	148080e7          	jalr	328(ra) # 80000d2a <memmove>
  brelse(bp);
    80003bea:	8526                	mv	a0,s1
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	b60080e7          	jalr	-1184(ra) # 8000374c <brelse>
  if(sb.magic != FSMAGIC)
    80003bf4:	0009a703          	lw	a4,0(s3)
    80003bf8:	102037b7          	lui	a5,0x10203
    80003bfc:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c00:	02f71263          	bne	a4,a5,80003c24 <fsinit+0x70>
  initlog(dev, &sb);
    80003c04:	0001c597          	auipc	a1,0x1c
    80003c08:	66458593          	add	a1,a1,1636 # 80020268 <sb>
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	00001097          	auipc	ra,0x1
    80003c12:	b2c080e7          	jalr	-1236(ra) # 8000473a <initlog>
}
    80003c16:	70a2                	ld	ra,40(sp)
    80003c18:	7402                	ld	s0,32(sp)
    80003c1a:	64e2                	ld	s1,24(sp)
    80003c1c:	6942                	ld	s2,16(sp)
    80003c1e:	69a2                	ld	s3,8(sp)
    80003c20:	6145                	add	sp,sp,48
    80003c22:	8082                	ret
    panic("invalid file system");
    80003c24:	00005517          	auipc	a0,0x5
    80003c28:	98c50513          	add	a0,a0,-1652 # 800085b0 <syscalls+0x160>
    80003c2c:	ffffd097          	auipc	ra,0xffffd
    80003c30:	910080e7          	jalr	-1776(ra) # 8000053c <panic>

0000000080003c34 <iinit>:
{
    80003c34:	7179                	add	sp,sp,-48
    80003c36:	f406                	sd	ra,40(sp)
    80003c38:	f022                	sd	s0,32(sp)
    80003c3a:	ec26                	sd	s1,24(sp)
    80003c3c:	e84a                	sd	s2,16(sp)
    80003c3e:	e44e                	sd	s3,8(sp)
    80003c40:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c42:	00005597          	auipc	a1,0x5
    80003c46:	98658593          	add	a1,a1,-1658 # 800085c8 <syscalls+0x178>
    80003c4a:	0001c517          	auipc	a0,0x1c
    80003c4e:	63e50513          	add	a0,a0,1598 # 80020288 <itable>
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	ef0080e7          	jalr	-272(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c5a:	0001c497          	auipc	s1,0x1c
    80003c5e:	65648493          	add	s1,s1,1622 # 800202b0 <itable+0x28>
    80003c62:	0001e997          	auipc	s3,0x1e
    80003c66:	0de98993          	add	s3,s3,222 # 80021d40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c6a:	00005917          	auipc	s2,0x5
    80003c6e:	96690913          	add	s2,s2,-1690 # 800085d0 <syscalls+0x180>
    80003c72:	85ca                	mv	a1,s2
    80003c74:	8526                	mv	a0,s1
    80003c76:	00001097          	auipc	ra,0x1
    80003c7a:	e12080e7          	jalr	-494(ra) # 80004a88 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c7e:	08848493          	add	s1,s1,136
    80003c82:	ff3498e3          	bne	s1,s3,80003c72 <iinit+0x3e>
}
    80003c86:	70a2                	ld	ra,40(sp)
    80003c88:	7402                	ld	s0,32(sp)
    80003c8a:	64e2                	ld	s1,24(sp)
    80003c8c:	6942                	ld	s2,16(sp)
    80003c8e:	69a2                	ld	s3,8(sp)
    80003c90:	6145                	add	sp,sp,48
    80003c92:	8082                	ret

0000000080003c94 <ialloc>:
{
    80003c94:	7139                	add	sp,sp,-64
    80003c96:	fc06                	sd	ra,56(sp)
    80003c98:	f822                	sd	s0,48(sp)
    80003c9a:	f426                	sd	s1,40(sp)
    80003c9c:	f04a                	sd	s2,32(sp)
    80003c9e:	ec4e                	sd	s3,24(sp)
    80003ca0:	e852                	sd	s4,16(sp)
    80003ca2:	e456                	sd	s5,8(sp)
    80003ca4:	e05a                	sd	s6,0(sp)
    80003ca6:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ca8:	0001c717          	auipc	a4,0x1c
    80003cac:	5cc72703          	lw	a4,1484(a4) # 80020274 <sb+0xc>
    80003cb0:	4785                	li	a5,1
    80003cb2:	04e7f863          	bgeu	a5,a4,80003d02 <ialloc+0x6e>
    80003cb6:	8aaa                	mv	s5,a0
    80003cb8:	8b2e                	mv	s6,a1
    80003cba:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003cbc:	0001ca17          	auipc	s4,0x1c
    80003cc0:	5aca0a13          	add	s4,s4,1452 # 80020268 <sb>
    80003cc4:	00495593          	srl	a1,s2,0x4
    80003cc8:	018a2783          	lw	a5,24(s4)
    80003ccc:	9dbd                	addw	a1,a1,a5
    80003cce:	8556                	mv	a0,s5
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	94c080e7          	jalr	-1716(ra) # 8000361c <bread>
    80003cd8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003cda:	05850993          	add	s3,a0,88
    80003cde:	00f97793          	and	a5,s2,15
    80003ce2:	079a                	sll	a5,a5,0x6
    80003ce4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ce6:	00099783          	lh	a5,0(s3)
    80003cea:	cf9d                	beqz	a5,80003d28 <ialloc+0x94>
    brelse(bp);
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	a60080e7          	jalr	-1440(ra) # 8000374c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cf4:	0905                	add	s2,s2,1
    80003cf6:	00ca2703          	lw	a4,12(s4)
    80003cfa:	0009079b          	sext.w	a5,s2
    80003cfe:	fce7e3e3          	bltu	a5,a4,80003cc4 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003d02:	00005517          	auipc	a0,0x5
    80003d06:	8d650513          	add	a0,a0,-1834 # 800085d8 <syscalls+0x188>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	87c080e7          	jalr	-1924(ra) # 80000586 <printf>
  return 0;
    80003d12:	4501                	li	a0,0
}
    80003d14:	70e2                	ld	ra,56(sp)
    80003d16:	7442                	ld	s0,48(sp)
    80003d18:	74a2                	ld	s1,40(sp)
    80003d1a:	7902                	ld	s2,32(sp)
    80003d1c:	69e2                	ld	s3,24(sp)
    80003d1e:	6a42                	ld	s4,16(sp)
    80003d20:	6aa2                	ld	s5,8(sp)
    80003d22:	6b02                	ld	s6,0(sp)
    80003d24:	6121                	add	sp,sp,64
    80003d26:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003d28:	04000613          	li	a2,64
    80003d2c:	4581                	li	a1,0
    80003d2e:	854e                	mv	a0,s3
    80003d30:	ffffd097          	auipc	ra,0xffffd
    80003d34:	f9e080e7          	jalr	-98(ra) # 80000cce <memset>
      dip->type = type;
    80003d38:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	00001097          	auipc	ra,0x1
    80003d42:	c66080e7          	jalr	-922(ra) # 800049a4 <log_write>
      brelse(bp);
    80003d46:	8526                	mv	a0,s1
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	a04080e7          	jalr	-1532(ra) # 8000374c <brelse>
      return iget(dev, inum);
    80003d50:	0009059b          	sext.w	a1,s2
    80003d54:	8556                	mv	a0,s5
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	da2080e7          	jalr	-606(ra) # 80003af8 <iget>
    80003d5e:	bf5d                	j	80003d14 <ialloc+0x80>

0000000080003d60 <iupdate>:
{
    80003d60:	1101                	add	sp,sp,-32
    80003d62:	ec06                	sd	ra,24(sp)
    80003d64:	e822                	sd	s0,16(sp)
    80003d66:	e426                	sd	s1,8(sp)
    80003d68:	e04a                	sd	s2,0(sp)
    80003d6a:	1000                	add	s0,sp,32
    80003d6c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d6e:	415c                	lw	a5,4(a0)
    80003d70:	0047d79b          	srlw	a5,a5,0x4
    80003d74:	0001c597          	auipc	a1,0x1c
    80003d78:	50c5a583          	lw	a1,1292(a1) # 80020280 <sb+0x18>
    80003d7c:	9dbd                	addw	a1,a1,a5
    80003d7e:	4108                	lw	a0,0(a0)
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	89c080e7          	jalr	-1892(ra) # 8000361c <bread>
    80003d88:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d8a:	05850793          	add	a5,a0,88
    80003d8e:	40d8                	lw	a4,4(s1)
    80003d90:	8b3d                	and	a4,a4,15
    80003d92:	071a                	sll	a4,a4,0x6
    80003d94:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d96:	04449703          	lh	a4,68(s1)
    80003d9a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d9e:	04649703          	lh	a4,70(s1)
    80003da2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003da6:	04849703          	lh	a4,72(s1)
    80003daa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003dae:	04a49703          	lh	a4,74(s1)
    80003db2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003db6:	44f8                	lw	a4,76(s1)
    80003db8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003dba:	03400613          	li	a2,52
    80003dbe:	05048593          	add	a1,s1,80
    80003dc2:	00c78513          	add	a0,a5,12
    80003dc6:	ffffd097          	auipc	ra,0xffffd
    80003dca:	f64080e7          	jalr	-156(ra) # 80000d2a <memmove>
  log_write(bp);
    80003dce:	854a                	mv	a0,s2
    80003dd0:	00001097          	auipc	ra,0x1
    80003dd4:	bd4080e7          	jalr	-1068(ra) # 800049a4 <log_write>
  brelse(bp);
    80003dd8:	854a                	mv	a0,s2
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	972080e7          	jalr	-1678(ra) # 8000374c <brelse>
}
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6902                	ld	s2,0(sp)
    80003dea:	6105                	add	sp,sp,32
    80003dec:	8082                	ret

0000000080003dee <idup>:
{
    80003dee:	1101                	add	sp,sp,-32
    80003df0:	ec06                	sd	ra,24(sp)
    80003df2:	e822                	sd	s0,16(sp)
    80003df4:	e426                	sd	s1,8(sp)
    80003df6:	1000                	add	s0,sp,32
    80003df8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dfa:	0001c517          	auipc	a0,0x1c
    80003dfe:	48e50513          	add	a0,a0,1166 # 80020288 <itable>
    80003e02:	ffffd097          	auipc	ra,0xffffd
    80003e06:	dd0080e7          	jalr	-560(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003e0a:	449c                	lw	a5,8(s1)
    80003e0c:	2785                	addw	a5,a5,1
    80003e0e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e10:	0001c517          	auipc	a0,0x1c
    80003e14:	47850513          	add	a0,a0,1144 # 80020288 <itable>
    80003e18:	ffffd097          	auipc	ra,0xffffd
    80003e1c:	e6e080e7          	jalr	-402(ra) # 80000c86 <release>
}
    80003e20:	8526                	mv	a0,s1
    80003e22:	60e2                	ld	ra,24(sp)
    80003e24:	6442                	ld	s0,16(sp)
    80003e26:	64a2                	ld	s1,8(sp)
    80003e28:	6105                	add	sp,sp,32
    80003e2a:	8082                	ret

0000000080003e2c <ilock>:
{
    80003e2c:	1101                	add	sp,sp,-32
    80003e2e:	ec06                	sd	ra,24(sp)
    80003e30:	e822                	sd	s0,16(sp)
    80003e32:	e426                	sd	s1,8(sp)
    80003e34:	e04a                	sd	s2,0(sp)
    80003e36:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e38:	c115                	beqz	a0,80003e5c <ilock+0x30>
    80003e3a:	84aa                	mv	s1,a0
    80003e3c:	451c                	lw	a5,8(a0)
    80003e3e:	00f05f63          	blez	a5,80003e5c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e42:	0541                	add	a0,a0,16
    80003e44:	00001097          	auipc	ra,0x1
    80003e48:	c7e080e7          	jalr	-898(ra) # 80004ac2 <acquiresleep>
  if(ip->valid == 0){
    80003e4c:	40bc                	lw	a5,64(s1)
    80003e4e:	cf99                	beqz	a5,80003e6c <ilock+0x40>
}
    80003e50:	60e2                	ld	ra,24(sp)
    80003e52:	6442                	ld	s0,16(sp)
    80003e54:	64a2                	ld	s1,8(sp)
    80003e56:	6902                	ld	s2,0(sp)
    80003e58:	6105                	add	sp,sp,32
    80003e5a:	8082                	ret
    panic("ilock");
    80003e5c:	00004517          	auipc	a0,0x4
    80003e60:	79450513          	add	a0,a0,1940 # 800085f0 <syscalls+0x1a0>
    80003e64:	ffffc097          	auipc	ra,0xffffc
    80003e68:	6d8080e7          	jalr	1752(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e6c:	40dc                	lw	a5,4(s1)
    80003e6e:	0047d79b          	srlw	a5,a5,0x4
    80003e72:	0001c597          	auipc	a1,0x1c
    80003e76:	40e5a583          	lw	a1,1038(a1) # 80020280 <sb+0x18>
    80003e7a:	9dbd                	addw	a1,a1,a5
    80003e7c:	4088                	lw	a0,0(s1)
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	79e080e7          	jalr	1950(ra) # 8000361c <bread>
    80003e86:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e88:	05850593          	add	a1,a0,88
    80003e8c:	40dc                	lw	a5,4(s1)
    80003e8e:	8bbd                	and	a5,a5,15
    80003e90:	079a                	sll	a5,a5,0x6
    80003e92:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e94:	00059783          	lh	a5,0(a1)
    80003e98:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e9c:	00259783          	lh	a5,2(a1)
    80003ea0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ea4:	00459783          	lh	a5,4(a1)
    80003ea8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003eac:	00659783          	lh	a5,6(a1)
    80003eb0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003eb4:	459c                	lw	a5,8(a1)
    80003eb6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003eb8:	03400613          	li	a2,52
    80003ebc:	05b1                	add	a1,a1,12
    80003ebe:	05048513          	add	a0,s1,80
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	e68080e7          	jalr	-408(ra) # 80000d2a <memmove>
    brelse(bp);
    80003eca:	854a                	mv	a0,s2
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	880080e7          	jalr	-1920(ra) # 8000374c <brelse>
    ip->valid = 1;
    80003ed4:	4785                	li	a5,1
    80003ed6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ed8:	04449783          	lh	a5,68(s1)
    80003edc:	fbb5                	bnez	a5,80003e50 <ilock+0x24>
      panic("ilock: no type");
    80003ede:	00004517          	auipc	a0,0x4
    80003ee2:	71a50513          	add	a0,a0,1818 # 800085f8 <syscalls+0x1a8>
    80003ee6:	ffffc097          	auipc	ra,0xffffc
    80003eea:	656080e7          	jalr	1622(ra) # 8000053c <panic>

0000000080003eee <iunlock>:
{
    80003eee:	1101                	add	sp,sp,-32
    80003ef0:	ec06                	sd	ra,24(sp)
    80003ef2:	e822                	sd	s0,16(sp)
    80003ef4:	e426                	sd	s1,8(sp)
    80003ef6:	e04a                	sd	s2,0(sp)
    80003ef8:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003efa:	c905                	beqz	a0,80003f2a <iunlock+0x3c>
    80003efc:	84aa                	mv	s1,a0
    80003efe:	01050913          	add	s2,a0,16
    80003f02:	854a                	mv	a0,s2
    80003f04:	00001097          	auipc	ra,0x1
    80003f08:	c58080e7          	jalr	-936(ra) # 80004b5c <holdingsleep>
    80003f0c:	cd19                	beqz	a0,80003f2a <iunlock+0x3c>
    80003f0e:	449c                	lw	a5,8(s1)
    80003f10:	00f05d63          	blez	a5,80003f2a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f14:	854a                	mv	a0,s2
    80003f16:	00001097          	auipc	ra,0x1
    80003f1a:	c02080e7          	jalr	-1022(ra) # 80004b18 <releasesleep>
}
    80003f1e:	60e2                	ld	ra,24(sp)
    80003f20:	6442                	ld	s0,16(sp)
    80003f22:	64a2                	ld	s1,8(sp)
    80003f24:	6902                	ld	s2,0(sp)
    80003f26:	6105                	add	sp,sp,32
    80003f28:	8082                	ret
    panic("iunlock");
    80003f2a:	00004517          	auipc	a0,0x4
    80003f2e:	6de50513          	add	a0,a0,1758 # 80008608 <syscalls+0x1b8>
    80003f32:	ffffc097          	auipc	ra,0xffffc
    80003f36:	60a080e7          	jalr	1546(ra) # 8000053c <panic>

0000000080003f3a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f3a:	7179                	add	sp,sp,-48
    80003f3c:	f406                	sd	ra,40(sp)
    80003f3e:	f022                	sd	s0,32(sp)
    80003f40:	ec26                	sd	s1,24(sp)
    80003f42:	e84a                	sd	s2,16(sp)
    80003f44:	e44e                	sd	s3,8(sp)
    80003f46:	e052                	sd	s4,0(sp)
    80003f48:	1800                	add	s0,sp,48
    80003f4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f4c:	05050493          	add	s1,a0,80
    80003f50:	08050913          	add	s2,a0,128
    80003f54:	a021                	j	80003f5c <itrunc+0x22>
    80003f56:	0491                	add	s1,s1,4
    80003f58:	01248d63          	beq	s1,s2,80003f72 <itrunc+0x38>
    if(ip->addrs[i]){
    80003f5c:	408c                	lw	a1,0(s1)
    80003f5e:	dde5                	beqz	a1,80003f56 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003f60:	0009a503          	lw	a0,0(s3)
    80003f64:	00000097          	auipc	ra,0x0
    80003f68:	8fc080e7          	jalr	-1796(ra) # 80003860 <bfree>
      ip->addrs[i] = 0;
    80003f6c:	0004a023          	sw	zero,0(s1)
    80003f70:	b7dd                	j	80003f56 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f72:	0809a583          	lw	a1,128(s3)
    80003f76:	e185                	bnez	a1,80003f96 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f78:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f7c:	854e                	mv	a0,s3
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	de2080e7          	jalr	-542(ra) # 80003d60 <iupdate>
}
    80003f86:	70a2                	ld	ra,40(sp)
    80003f88:	7402                	ld	s0,32(sp)
    80003f8a:	64e2                	ld	s1,24(sp)
    80003f8c:	6942                	ld	s2,16(sp)
    80003f8e:	69a2                	ld	s3,8(sp)
    80003f90:	6a02                	ld	s4,0(sp)
    80003f92:	6145                	add	sp,sp,48
    80003f94:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f96:	0009a503          	lw	a0,0(s3)
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	682080e7          	jalr	1666(ra) # 8000361c <bread>
    80003fa2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003fa4:	05850493          	add	s1,a0,88
    80003fa8:	45850913          	add	s2,a0,1112
    80003fac:	a021                	j	80003fb4 <itrunc+0x7a>
    80003fae:	0491                	add	s1,s1,4
    80003fb0:	01248b63          	beq	s1,s2,80003fc6 <itrunc+0x8c>
      if(a[j])
    80003fb4:	408c                	lw	a1,0(s1)
    80003fb6:	dde5                	beqz	a1,80003fae <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003fb8:	0009a503          	lw	a0,0(s3)
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	8a4080e7          	jalr	-1884(ra) # 80003860 <bfree>
    80003fc4:	b7ed                	j	80003fae <itrunc+0x74>
    brelse(bp);
    80003fc6:	8552                	mv	a0,s4
    80003fc8:	fffff097          	auipc	ra,0xfffff
    80003fcc:	784080e7          	jalr	1924(ra) # 8000374c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003fd0:	0809a583          	lw	a1,128(s3)
    80003fd4:	0009a503          	lw	a0,0(s3)
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	888080e7          	jalr	-1912(ra) # 80003860 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003fe0:	0809a023          	sw	zero,128(s3)
    80003fe4:	bf51                	j	80003f78 <itrunc+0x3e>

0000000080003fe6 <iput>:
{
    80003fe6:	1101                	add	sp,sp,-32
    80003fe8:	ec06                	sd	ra,24(sp)
    80003fea:	e822                	sd	s0,16(sp)
    80003fec:	e426                	sd	s1,8(sp)
    80003fee:	e04a                	sd	s2,0(sp)
    80003ff0:	1000                	add	s0,sp,32
    80003ff2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ff4:	0001c517          	auipc	a0,0x1c
    80003ff8:	29450513          	add	a0,a0,660 # 80020288 <itable>
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	bd6080e7          	jalr	-1066(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004004:	4498                	lw	a4,8(s1)
    80004006:	4785                	li	a5,1
    80004008:	02f70363          	beq	a4,a5,8000402e <iput+0x48>
  ip->ref--;
    8000400c:	449c                	lw	a5,8(s1)
    8000400e:	37fd                	addw	a5,a5,-1
    80004010:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004012:	0001c517          	auipc	a0,0x1c
    80004016:	27650513          	add	a0,a0,630 # 80020288 <itable>
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	c6c080e7          	jalr	-916(ra) # 80000c86 <release>
}
    80004022:	60e2                	ld	ra,24(sp)
    80004024:	6442                	ld	s0,16(sp)
    80004026:	64a2                	ld	s1,8(sp)
    80004028:	6902                	ld	s2,0(sp)
    8000402a:	6105                	add	sp,sp,32
    8000402c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000402e:	40bc                	lw	a5,64(s1)
    80004030:	dff1                	beqz	a5,8000400c <iput+0x26>
    80004032:	04a49783          	lh	a5,74(s1)
    80004036:	fbf9                	bnez	a5,8000400c <iput+0x26>
    acquiresleep(&ip->lock);
    80004038:	01048913          	add	s2,s1,16
    8000403c:	854a                	mv	a0,s2
    8000403e:	00001097          	auipc	ra,0x1
    80004042:	a84080e7          	jalr	-1404(ra) # 80004ac2 <acquiresleep>
    release(&itable.lock);
    80004046:	0001c517          	auipc	a0,0x1c
    8000404a:	24250513          	add	a0,a0,578 # 80020288 <itable>
    8000404e:	ffffd097          	auipc	ra,0xffffd
    80004052:	c38080e7          	jalr	-968(ra) # 80000c86 <release>
    itrunc(ip);
    80004056:	8526                	mv	a0,s1
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	ee2080e7          	jalr	-286(ra) # 80003f3a <itrunc>
    ip->type = 0;
    80004060:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004064:	8526                	mv	a0,s1
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	cfa080e7          	jalr	-774(ra) # 80003d60 <iupdate>
    ip->valid = 0;
    8000406e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004072:	854a                	mv	a0,s2
    80004074:	00001097          	auipc	ra,0x1
    80004078:	aa4080e7          	jalr	-1372(ra) # 80004b18 <releasesleep>
    acquire(&itable.lock);
    8000407c:	0001c517          	auipc	a0,0x1c
    80004080:	20c50513          	add	a0,a0,524 # 80020288 <itable>
    80004084:	ffffd097          	auipc	ra,0xffffd
    80004088:	b4e080e7          	jalr	-1202(ra) # 80000bd2 <acquire>
    8000408c:	b741                	j	8000400c <iput+0x26>

000000008000408e <iunlockput>:
{
    8000408e:	1101                	add	sp,sp,-32
    80004090:	ec06                	sd	ra,24(sp)
    80004092:	e822                	sd	s0,16(sp)
    80004094:	e426                	sd	s1,8(sp)
    80004096:	1000                	add	s0,sp,32
    80004098:	84aa                	mv	s1,a0
  iunlock(ip);
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	e54080e7          	jalr	-428(ra) # 80003eee <iunlock>
  iput(ip);
    800040a2:	8526                	mv	a0,s1
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	f42080e7          	jalr	-190(ra) # 80003fe6 <iput>
}
    800040ac:	60e2                	ld	ra,24(sp)
    800040ae:	6442                	ld	s0,16(sp)
    800040b0:	64a2                	ld	s1,8(sp)
    800040b2:	6105                	add	sp,sp,32
    800040b4:	8082                	ret

00000000800040b6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800040b6:	1141                	add	sp,sp,-16
    800040b8:	e422                	sd	s0,8(sp)
    800040ba:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    800040bc:	411c                	lw	a5,0(a0)
    800040be:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800040c0:	415c                	lw	a5,4(a0)
    800040c2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800040c4:	04451783          	lh	a5,68(a0)
    800040c8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800040cc:	04a51783          	lh	a5,74(a0)
    800040d0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800040d4:	04c56783          	lwu	a5,76(a0)
    800040d8:	e99c                	sd	a5,16(a1)
}
    800040da:	6422                	ld	s0,8(sp)
    800040dc:	0141                	add	sp,sp,16
    800040de:	8082                	ret

00000000800040e0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040e0:	457c                	lw	a5,76(a0)
    800040e2:	0ed7e963          	bltu	a5,a3,800041d4 <readi+0xf4>
{
    800040e6:	7159                	add	sp,sp,-112
    800040e8:	f486                	sd	ra,104(sp)
    800040ea:	f0a2                	sd	s0,96(sp)
    800040ec:	eca6                	sd	s1,88(sp)
    800040ee:	e8ca                	sd	s2,80(sp)
    800040f0:	e4ce                	sd	s3,72(sp)
    800040f2:	e0d2                	sd	s4,64(sp)
    800040f4:	fc56                	sd	s5,56(sp)
    800040f6:	f85a                	sd	s6,48(sp)
    800040f8:	f45e                	sd	s7,40(sp)
    800040fa:	f062                	sd	s8,32(sp)
    800040fc:	ec66                	sd	s9,24(sp)
    800040fe:	e86a                	sd	s10,16(sp)
    80004100:	e46e                	sd	s11,8(sp)
    80004102:	1880                	add	s0,sp,112
    80004104:	8b2a                	mv	s6,a0
    80004106:	8bae                	mv	s7,a1
    80004108:	8a32                	mv	s4,a2
    8000410a:	84b6                	mv	s1,a3
    8000410c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000410e:	9f35                	addw	a4,a4,a3
    return 0;
    80004110:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004112:	0ad76063          	bltu	a4,a3,800041b2 <readi+0xd2>
  if(off + n > ip->size)
    80004116:	00e7f463          	bgeu	a5,a4,8000411e <readi+0x3e>
    n = ip->size - off;
    8000411a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000411e:	0a0a8963          	beqz	s5,800041d0 <readi+0xf0>
    80004122:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004124:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004128:	5c7d                	li	s8,-1
    8000412a:	a82d                	j	80004164 <readi+0x84>
    8000412c:	020d1d93          	sll	s11,s10,0x20
    80004130:	020ddd93          	srl	s11,s11,0x20
    80004134:	05890613          	add	a2,s2,88
    80004138:	86ee                	mv	a3,s11
    8000413a:	963a                	add	a2,a2,a4
    8000413c:	85d2                	mv	a1,s4
    8000413e:	855e                	mv	a0,s7
    80004140:	ffffe097          	auipc	ra,0xffffe
    80004144:	466080e7          	jalr	1126(ra) # 800025a6 <either_copyout>
    80004148:	05850d63          	beq	a0,s8,800041a2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000414c:	854a                	mv	a0,s2
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	5fe080e7          	jalr	1534(ra) # 8000374c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004156:	013d09bb          	addw	s3,s10,s3
    8000415a:	009d04bb          	addw	s1,s10,s1
    8000415e:	9a6e                	add	s4,s4,s11
    80004160:	0559f763          	bgeu	s3,s5,800041ae <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004164:	00a4d59b          	srlw	a1,s1,0xa
    80004168:	855a                	mv	a0,s6
    8000416a:	00000097          	auipc	ra,0x0
    8000416e:	8a4080e7          	jalr	-1884(ra) # 80003a0e <bmap>
    80004172:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004176:	cd85                	beqz	a1,800041ae <readi+0xce>
    bp = bread(ip->dev, addr);
    80004178:	000b2503          	lw	a0,0(s6)
    8000417c:	fffff097          	auipc	ra,0xfffff
    80004180:	4a0080e7          	jalr	1184(ra) # 8000361c <bread>
    80004184:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004186:	3ff4f713          	and	a4,s1,1023
    8000418a:	40ec87bb          	subw	a5,s9,a4
    8000418e:	413a86bb          	subw	a3,s5,s3
    80004192:	8d3e                	mv	s10,a5
    80004194:	2781                	sext.w	a5,a5
    80004196:	0006861b          	sext.w	a2,a3
    8000419a:	f8f679e3          	bgeu	a2,a5,8000412c <readi+0x4c>
    8000419e:	8d36                	mv	s10,a3
    800041a0:	b771                	j	8000412c <readi+0x4c>
      brelse(bp);
    800041a2:	854a                	mv	a0,s2
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	5a8080e7          	jalr	1448(ra) # 8000374c <brelse>
      tot = -1;
    800041ac:	59fd                	li	s3,-1
  }
  return tot;
    800041ae:	0009851b          	sext.w	a0,s3
}
    800041b2:	70a6                	ld	ra,104(sp)
    800041b4:	7406                	ld	s0,96(sp)
    800041b6:	64e6                	ld	s1,88(sp)
    800041b8:	6946                	ld	s2,80(sp)
    800041ba:	69a6                	ld	s3,72(sp)
    800041bc:	6a06                	ld	s4,64(sp)
    800041be:	7ae2                	ld	s5,56(sp)
    800041c0:	7b42                	ld	s6,48(sp)
    800041c2:	7ba2                	ld	s7,40(sp)
    800041c4:	7c02                	ld	s8,32(sp)
    800041c6:	6ce2                	ld	s9,24(sp)
    800041c8:	6d42                	ld	s10,16(sp)
    800041ca:	6da2                	ld	s11,8(sp)
    800041cc:	6165                	add	sp,sp,112
    800041ce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041d0:	89d6                	mv	s3,s5
    800041d2:	bff1                	j	800041ae <readi+0xce>
    return 0;
    800041d4:	4501                	li	a0,0
}
    800041d6:	8082                	ret

00000000800041d8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041d8:	457c                	lw	a5,76(a0)
    800041da:	10d7e863          	bltu	a5,a3,800042ea <writei+0x112>
{
    800041de:	7159                	add	sp,sp,-112
    800041e0:	f486                	sd	ra,104(sp)
    800041e2:	f0a2                	sd	s0,96(sp)
    800041e4:	eca6                	sd	s1,88(sp)
    800041e6:	e8ca                	sd	s2,80(sp)
    800041e8:	e4ce                	sd	s3,72(sp)
    800041ea:	e0d2                	sd	s4,64(sp)
    800041ec:	fc56                	sd	s5,56(sp)
    800041ee:	f85a                	sd	s6,48(sp)
    800041f0:	f45e                	sd	s7,40(sp)
    800041f2:	f062                	sd	s8,32(sp)
    800041f4:	ec66                	sd	s9,24(sp)
    800041f6:	e86a                	sd	s10,16(sp)
    800041f8:	e46e                	sd	s11,8(sp)
    800041fa:	1880                	add	s0,sp,112
    800041fc:	8aaa                	mv	s5,a0
    800041fe:	8bae                	mv	s7,a1
    80004200:	8a32                	mv	s4,a2
    80004202:	8936                	mv	s2,a3
    80004204:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004206:	00e687bb          	addw	a5,a3,a4
    8000420a:	0ed7e263          	bltu	a5,a3,800042ee <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000420e:	00043737          	lui	a4,0x43
    80004212:	0ef76063          	bltu	a4,a5,800042f2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004216:	0c0b0863          	beqz	s6,800042e6 <writei+0x10e>
    8000421a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000421c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004220:	5c7d                	li	s8,-1
    80004222:	a091                	j	80004266 <writei+0x8e>
    80004224:	020d1d93          	sll	s11,s10,0x20
    80004228:	020ddd93          	srl	s11,s11,0x20
    8000422c:	05848513          	add	a0,s1,88
    80004230:	86ee                	mv	a3,s11
    80004232:	8652                	mv	a2,s4
    80004234:	85de                	mv	a1,s7
    80004236:	953a                	add	a0,a0,a4
    80004238:	ffffe097          	auipc	ra,0xffffe
    8000423c:	3c4080e7          	jalr	964(ra) # 800025fc <either_copyin>
    80004240:	07850263          	beq	a0,s8,800042a4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004244:	8526                	mv	a0,s1
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	75e080e7          	jalr	1886(ra) # 800049a4 <log_write>
    brelse(bp);
    8000424e:	8526                	mv	a0,s1
    80004250:	fffff097          	auipc	ra,0xfffff
    80004254:	4fc080e7          	jalr	1276(ra) # 8000374c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004258:	013d09bb          	addw	s3,s10,s3
    8000425c:	012d093b          	addw	s2,s10,s2
    80004260:	9a6e                	add	s4,s4,s11
    80004262:	0569f663          	bgeu	s3,s6,800042ae <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004266:	00a9559b          	srlw	a1,s2,0xa
    8000426a:	8556                	mv	a0,s5
    8000426c:	fffff097          	auipc	ra,0xfffff
    80004270:	7a2080e7          	jalr	1954(ra) # 80003a0e <bmap>
    80004274:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004278:	c99d                	beqz	a1,800042ae <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000427a:	000aa503          	lw	a0,0(s5)
    8000427e:	fffff097          	auipc	ra,0xfffff
    80004282:	39e080e7          	jalr	926(ra) # 8000361c <bread>
    80004286:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004288:	3ff97713          	and	a4,s2,1023
    8000428c:	40ec87bb          	subw	a5,s9,a4
    80004290:	413b06bb          	subw	a3,s6,s3
    80004294:	8d3e                	mv	s10,a5
    80004296:	2781                	sext.w	a5,a5
    80004298:	0006861b          	sext.w	a2,a3
    8000429c:	f8f674e3          	bgeu	a2,a5,80004224 <writei+0x4c>
    800042a0:	8d36                	mv	s10,a3
    800042a2:	b749                	j	80004224 <writei+0x4c>
      brelse(bp);
    800042a4:	8526                	mv	a0,s1
    800042a6:	fffff097          	auipc	ra,0xfffff
    800042aa:	4a6080e7          	jalr	1190(ra) # 8000374c <brelse>
  }

  if(off > ip->size)
    800042ae:	04caa783          	lw	a5,76(s5)
    800042b2:	0127f463          	bgeu	a5,s2,800042ba <writei+0xe2>
    ip->size = off;
    800042b6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800042ba:	8556                	mv	a0,s5
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	aa4080e7          	jalr	-1372(ra) # 80003d60 <iupdate>

  return tot;
    800042c4:	0009851b          	sext.w	a0,s3
}
    800042c8:	70a6                	ld	ra,104(sp)
    800042ca:	7406                	ld	s0,96(sp)
    800042cc:	64e6                	ld	s1,88(sp)
    800042ce:	6946                	ld	s2,80(sp)
    800042d0:	69a6                	ld	s3,72(sp)
    800042d2:	6a06                	ld	s4,64(sp)
    800042d4:	7ae2                	ld	s5,56(sp)
    800042d6:	7b42                	ld	s6,48(sp)
    800042d8:	7ba2                	ld	s7,40(sp)
    800042da:	7c02                	ld	s8,32(sp)
    800042dc:	6ce2                	ld	s9,24(sp)
    800042de:	6d42                	ld	s10,16(sp)
    800042e0:	6da2                	ld	s11,8(sp)
    800042e2:	6165                	add	sp,sp,112
    800042e4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042e6:	89da                	mv	s3,s6
    800042e8:	bfc9                	j	800042ba <writei+0xe2>
    return -1;
    800042ea:	557d                	li	a0,-1
}
    800042ec:	8082                	ret
    return -1;
    800042ee:	557d                	li	a0,-1
    800042f0:	bfe1                	j	800042c8 <writei+0xf0>
    return -1;
    800042f2:	557d                	li	a0,-1
    800042f4:	bfd1                	j	800042c8 <writei+0xf0>

00000000800042f6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800042f6:	1141                	add	sp,sp,-16
    800042f8:	e406                	sd	ra,8(sp)
    800042fa:	e022                	sd	s0,0(sp)
    800042fc:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042fe:	4639                	li	a2,14
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	a9e080e7          	jalr	-1378(ra) # 80000d9e <strncmp>
}
    80004308:	60a2                	ld	ra,8(sp)
    8000430a:	6402                	ld	s0,0(sp)
    8000430c:	0141                	add	sp,sp,16
    8000430e:	8082                	ret

0000000080004310 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004310:	7139                	add	sp,sp,-64
    80004312:	fc06                	sd	ra,56(sp)
    80004314:	f822                	sd	s0,48(sp)
    80004316:	f426                	sd	s1,40(sp)
    80004318:	f04a                	sd	s2,32(sp)
    8000431a:	ec4e                	sd	s3,24(sp)
    8000431c:	e852                	sd	s4,16(sp)
    8000431e:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004320:	04451703          	lh	a4,68(a0)
    80004324:	4785                	li	a5,1
    80004326:	00f71a63          	bne	a4,a5,8000433a <dirlookup+0x2a>
    8000432a:	892a                	mv	s2,a0
    8000432c:	89ae                	mv	s3,a1
    8000432e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004330:	457c                	lw	a5,76(a0)
    80004332:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004334:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004336:	e79d                	bnez	a5,80004364 <dirlookup+0x54>
    80004338:	a8a5                	j	800043b0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000433a:	00004517          	auipc	a0,0x4
    8000433e:	2d650513          	add	a0,a0,726 # 80008610 <syscalls+0x1c0>
    80004342:	ffffc097          	auipc	ra,0xffffc
    80004346:	1fa080e7          	jalr	506(ra) # 8000053c <panic>
      panic("dirlookup read");
    8000434a:	00004517          	auipc	a0,0x4
    8000434e:	2de50513          	add	a0,a0,734 # 80008628 <syscalls+0x1d8>
    80004352:	ffffc097          	auipc	ra,0xffffc
    80004356:	1ea080e7          	jalr	490(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000435a:	24c1                	addw	s1,s1,16
    8000435c:	04c92783          	lw	a5,76(s2)
    80004360:	04f4f763          	bgeu	s1,a5,800043ae <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004364:	4741                	li	a4,16
    80004366:	86a6                	mv	a3,s1
    80004368:	fc040613          	add	a2,s0,-64
    8000436c:	4581                	li	a1,0
    8000436e:	854a                	mv	a0,s2
    80004370:	00000097          	auipc	ra,0x0
    80004374:	d70080e7          	jalr	-656(ra) # 800040e0 <readi>
    80004378:	47c1                	li	a5,16
    8000437a:	fcf518e3          	bne	a0,a5,8000434a <dirlookup+0x3a>
    if(de.inum == 0)
    8000437e:	fc045783          	lhu	a5,-64(s0)
    80004382:	dfe1                	beqz	a5,8000435a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004384:	fc240593          	add	a1,s0,-62
    80004388:	854e                	mv	a0,s3
    8000438a:	00000097          	auipc	ra,0x0
    8000438e:	f6c080e7          	jalr	-148(ra) # 800042f6 <namecmp>
    80004392:	f561                	bnez	a0,8000435a <dirlookup+0x4a>
      if(poff)
    80004394:	000a0463          	beqz	s4,8000439c <dirlookup+0x8c>
        *poff = off;
    80004398:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000439c:	fc045583          	lhu	a1,-64(s0)
    800043a0:	00092503          	lw	a0,0(s2)
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	754080e7          	jalr	1876(ra) # 80003af8 <iget>
    800043ac:	a011                	j	800043b0 <dirlookup+0xa0>
  return 0;
    800043ae:	4501                	li	a0,0
}
    800043b0:	70e2                	ld	ra,56(sp)
    800043b2:	7442                	ld	s0,48(sp)
    800043b4:	74a2                	ld	s1,40(sp)
    800043b6:	7902                	ld	s2,32(sp)
    800043b8:	69e2                	ld	s3,24(sp)
    800043ba:	6a42                	ld	s4,16(sp)
    800043bc:	6121                	add	sp,sp,64
    800043be:	8082                	ret

00000000800043c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043c0:	711d                	add	sp,sp,-96
    800043c2:	ec86                	sd	ra,88(sp)
    800043c4:	e8a2                	sd	s0,80(sp)
    800043c6:	e4a6                	sd	s1,72(sp)
    800043c8:	e0ca                	sd	s2,64(sp)
    800043ca:	fc4e                	sd	s3,56(sp)
    800043cc:	f852                	sd	s4,48(sp)
    800043ce:	f456                	sd	s5,40(sp)
    800043d0:	f05a                	sd	s6,32(sp)
    800043d2:	ec5e                	sd	s7,24(sp)
    800043d4:	e862                	sd	s8,16(sp)
    800043d6:	e466                	sd	s9,8(sp)
    800043d8:	1080                	add	s0,sp,96
    800043da:	84aa                	mv	s1,a0
    800043dc:	8b2e                	mv	s6,a1
    800043de:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043e0:	00054703          	lbu	a4,0(a0)
    800043e4:	02f00793          	li	a5,47
    800043e8:	02f70263          	beq	a4,a5,8000440c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	5ba080e7          	jalr	1466(ra) # 800019a6 <myproc>
    800043f4:	18853503          	ld	a0,392(a0)
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	9f6080e7          	jalr	-1546(ra) # 80003dee <idup>
    80004400:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004402:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004406:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004408:	4b85                	li	s7,1
    8000440a:	a875                	j	800044c6 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    8000440c:	4585                	li	a1,1
    8000440e:	4505                	li	a0,1
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	6e8080e7          	jalr	1768(ra) # 80003af8 <iget>
    80004418:	8a2a                	mv	s4,a0
    8000441a:	b7e5                	j	80004402 <namex+0x42>
      iunlockput(ip);
    8000441c:	8552                	mv	a0,s4
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	c70080e7          	jalr	-912(ra) # 8000408e <iunlockput>
      return 0;
    80004426:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004428:	8552                	mv	a0,s4
    8000442a:	60e6                	ld	ra,88(sp)
    8000442c:	6446                	ld	s0,80(sp)
    8000442e:	64a6                	ld	s1,72(sp)
    80004430:	6906                	ld	s2,64(sp)
    80004432:	79e2                	ld	s3,56(sp)
    80004434:	7a42                	ld	s4,48(sp)
    80004436:	7aa2                	ld	s5,40(sp)
    80004438:	7b02                	ld	s6,32(sp)
    8000443a:	6be2                	ld	s7,24(sp)
    8000443c:	6c42                	ld	s8,16(sp)
    8000443e:	6ca2                	ld	s9,8(sp)
    80004440:	6125                	add	sp,sp,96
    80004442:	8082                	ret
      iunlock(ip);
    80004444:	8552                	mv	a0,s4
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	aa8080e7          	jalr	-1368(ra) # 80003eee <iunlock>
      return ip;
    8000444e:	bfe9                	j	80004428 <namex+0x68>
      iunlockput(ip);
    80004450:	8552                	mv	a0,s4
    80004452:	00000097          	auipc	ra,0x0
    80004456:	c3c080e7          	jalr	-964(ra) # 8000408e <iunlockput>
      return 0;
    8000445a:	8a4e                	mv	s4,s3
    8000445c:	b7f1                	j	80004428 <namex+0x68>
  len = path - s;
    8000445e:	40998633          	sub	a2,s3,s1
    80004462:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004466:	099c5863          	bge	s8,s9,800044f6 <namex+0x136>
    memmove(name, s, DIRSIZ);
    8000446a:	4639                	li	a2,14
    8000446c:	85a6                	mv	a1,s1
    8000446e:	8556                	mv	a0,s5
    80004470:	ffffd097          	auipc	ra,0xffffd
    80004474:	8ba080e7          	jalr	-1862(ra) # 80000d2a <memmove>
    80004478:	84ce                	mv	s1,s3
  while(*path == '/')
    8000447a:	0004c783          	lbu	a5,0(s1)
    8000447e:	01279763          	bne	a5,s2,8000448c <namex+0xcc>
    path++;
    80004482:	0485                	add	s1,s1,1
  while(*path == '/')
    80004484:	0004c783          	lbu	a5,0(s1)
    80004488:	ff278de3          	beq	a5,s2,80004482 <namex+0xc2>
    ilock(ip);
    8000448c:	8552                	mv	a0,s4
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	99e080e7          	jalr	-1634(ra) # 80003e2c <ilock>
    if(ip->type != T_DIR){
    80004496:	044a1783          	lh	a5,68(s4)
    8000449a:	f97791e3          	bne	a5,s7,8000441c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000449e:	000b0563          	beqz	s6,800044a8 <namex+0xe8>
    800044a2:	0004c783          	lbu	a5,0(s1)
    800044a6:	dfd9                	beqz	a5,80004444 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800044a8:	4601                	li	a2,0
    800044aa:	85d6                	mv	a1,s5
    800044ac:	8552                	mv	a0,s4
    800044ae:	00000097          	auipc	ra,0x0
    800044b2:	e62080e7          	jalr	-414(ra) # 80004310 <dirlookup>
    800044b6:	89aa                	mv	s3,a0
    800044b8:	dd41                	beqz	a0,80004450 <namex+0x90>
    iunlockput(ip);
    800044ba:	8552                	mv	a0,s4
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	bd2080e7          	jalr	-1070(ra) # 8000408e <iunlockput>
    ip = next;
    800044c4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800044c6:	0004c783          	lbu	a5,0(s1)
    800044ca:	01279763          	bne	a5,s2,800044d8 <namex+0x118>
    path++;
    800044ce:	0485                	add	s1,s1,1
  while(*path == '/')
    800044d0:	0004c783          	lbu	a5,0(s1)
    800044d4:	ff278de3          	beq	a5,s2,800044ce <namex+0x10e>
  if(*path == 0)
    800044d8:	cb9d                	beqz	a5,8000450e <namex+0x14e>
  while(*path != '/' && *path != 0)
    800044da:	0004c783          	lbu	a5,0(s1)
    800044de:	89a6                	mv	s3,s1
  len = path - s;
    800044e0:	4c81                	li	s9,0
    800044e2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800044e4:	01278963          	beq	a5,s2,800044f6 <namex+0x136>
    800044e8:	dbbd                	beqz	a5,8000445e <namex+0x9e>
    path++;
    800044ea:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    800044ec:	0009c783          	lbu	a5,0(s3)
    800044f0:	ff279ce3          	bne	a5,s2,800044e8 <namex+0x128>
    800044f4:	b7ad                	j	8000445e <namex+0x9e>
    memmove(name, s, len);
    800044f6:	2601                	sext.w	a2,a2
    800044f8:	85a6                	mv	a1,s1
    800044fa:	8556                	mv	a0,s5
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	82e080e7          	jalr	-2002(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004504:	9cd6                	add	s9,s9,s5
    80004506:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000450a:	84ce                	mv	s1,s3
    8000450c:	b7bd                	j	8000447a <namex+0xba>
  if(nameiparent){
    8000450e:	f00b0de3          	beqz	s6,80004428 <namex+0x68>
    iput(ip);
    80004512:	8552                	mv	a0,s4
    80004514:	00000097          	auipc	ra,0x0
    80004518:	ad2080e7          	jalr	-1326(ra) # 80003fe6 <iput>
    return 0;
    8000451c:	4a01                	li	s4,0
    8000451e:	b729                	j	80004428 <namex+0x68>

0000000080004520 <dirlink>:
{
    80004520:	7139                	add	sp,sp,-64
    80004522:	fc06                	sd	ra,56(sp)
    80004524:	f822                	sd	s0,48(sp)
    80004526:	f426                	sd	s1,40(sp)
    80004528:	f04a                	sd	s2,32(sp)
    8000452a:	ec4e                	sd	s3,24(sp)
    8000452c:	e852                	sd	s4,16(sp)
    8000452e:	0080                	add	s0,sp,64
    80004530:	892a                	mv	s2,a0
    80004532:	8a2e                	mv	s4,a1
    80004534:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004536:	4601                	li	a2,0
    80004538:	00000097          	auipc	ra,0x0
    8000453c:	dd8080e7          	jalr	-552(ra) # 80004310 <dirlookup>
    80004540:	e93d                	bnez	a0,800045b6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004542:	04c92483          	lw	s1,76(s2)
    80004546:	c49d                	beqz	s1,80004574 <dirlink+0x54>
    80004548:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000454a:	4741                	li	a4,16
    8000454c:	86a6                	mv	a3,s1
    8000454e:	fc040613          	add	a2,s0,-64
    80004552:	4581                	li	a1,0
    80004554:	854a                	mv	a0,s2
    80004556:	00000097          	auipc	ra,0x0
    8000455a:	b8a080e7          	jalr	-1142(ra) # 800040e0 <readi>
    8000455e:	47c1                	li	a5,16
    80004560:	06f51163          	bne	a0,a5,800045c2 <dirlink+0xa2>
    if(de.inum == 0)
    80004564:	fc045783          	lhu	a5,-64(s0)
    80004568:	c791                	beqz	a5,80004574 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000456a:	24c1                	addw	s1,s1,16
    8000456c:	04c92783          	lw	a5,76(s2)
    80004570:	fcf4ede3          	bltu	s1,a5,8000454a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004574:	4639                	li	a2,14
    80004576:	85d2                	mv	a1,s4
    80004578:	fc240513          	add	a0,s0,-62
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	85e080e7          	jalr	-1954(ra) # 80000dda <strncpy>
  de.inum = inum;
    80004584:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004588:	4741                	li	a4,16
    8000458a:	86a6                	mv	a3,s1
    8000458c:	fc040613          	add	a2,s0,-64
    80004590:	4581                	li	a1,0
    80004592:	854a                	mv	a0,s2
    80004594:	00000097          	auipc	ra,0x0
    80004598:	c44080e7          	jalr	-956(ra) # 800041d8 <writei>
    8000459c:	1541                	add	a0,a0,-16
    8000459e:	00a03533          	snez	a0,a0
    800045a2:	40a00533          	neg	a0,a0
}
    800045a6:	70e2                	ld	ra,56(sp)
    800045a8:	7442                	ld	s0,48(sp)
    800045aa:	74a2                	ld	s1,40(sp)
    800045ac:	7902                	ld	s2,32(sp)
    800045ae:	69e2                	ld	s3,24(sp)
    800045b0:	6a42                	ld	s4,16(sp)
    800045b2:	6121                	add	sp,sp,64
    800045b4:	8082                	ret
    iput(ip);
    800045b6:	00000097          	auipc	ra,0x0
    800045ba:	a30080e7          	jalr	-1488(ra) # 80003fe6 <iput>
    return -1;
    800045be:	557d                	li	a0,-1
    800045c0:	b7dd                	j	800045a6 <dirlink+0x86>
      panic("dirlink read");
    800045c2:	00004517          	auipc	a0,0x4
    800045c6:	07650513          	add	a0,a0,118 # 80008638 <syscalls+0x1e8>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	f72080e7          	jalr	-142(ra) # 8000053c <panic>

00000000800045d2 <namei>:

struct inode*
namei(char *path)
{
    800045d2:	1101                	add	sp,sp,-32
    800045d4:	ec06                	sd	ra,24(sp)
    800045d6:	e822                	sd	s0,16(sp)
    800045d8:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800045da:	fe040613          	add	a2,s0,-32
    800045de:	4581                	li	a1,0
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	de0080e7          	jalr	-544(ra) # 800043c0 <namex>
}
    800045e8:	60e2                	ld	ra,24(sp)
    800045ea:	6442                	ld	s0,16(sp)
    800045ec:	6105                	add	sp,sp,32
    800045ee:	8082                	ret

00000000800045f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045f0:	1141                	add	sp,sp,-16
    800045f2:	e406                	sd	ra,8(sp)
    800045f4:	e022                	sd	s0,0(sp)
    800045f6:	0800                	add	s0,sp,16
    800045f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045fa:	4585                	li	a1,1
    800045fc:	00000097          	auipc	ra,0x0
    80004600:	dc4080e7          	jalr	-572(ra) # 800043c0 <namex>
}
    80004604:	60a2                	ld	ra,8(sp)
    80004606:	6402                	ld	s0,0(sp)
    80004608:	0141                	add	sp,sp,16
    8000460a:	8082                	ret

000000008000460c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000460c:	1101                	add	sp,sp,-32
    8000460e:	ec06                	sd	ra,24(sp)
    80004610:	e822                	sd	s0,16(sp)
    80004612:	e426                	sd	s1,8(sp)
    80004614:	e04a                	sd	s2,0(sp)
    80004616:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004618:	0001d917          	auipc	s2,0x1d
    8000461c:	71890913          	add	s2,s2,1816 # 80021d30 <log>
    80004620:	01892583          	lw	a1,24(s2)
    80004624:	02892503          	lw	a0,40(s2)
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	ff4080e7          	jalr	-12(ra) # 8000361c <bread>
    80004630:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004632:	02c92603          	lw	a2,44(s2)
    80004636:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004638:	00c05f63          	blez	a2,80004656 <write_head+0x4a>
    8000463c:	0001d717          	auipc	a4,0x1d
    80004640:	72470713          	add	a4,a4,1828 # 80021d60 <log+0x30>
    80004644:	87aa                	mv	a5,a0
    80004646:	060a                	sll	a2,a2,0x2
    80004648:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000464a:	4314                	lw	a3,0(a4)
    8000464c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000464e:	0711                	add	a4,a4,4
    80004650:	0791                	add	a5,a5,4
    80004652:	fec79ce3          	bne	a5,a2,8000464a <write_head+0x3e>
  }
  bwrite(buf);
    80004656:	8526                	mv	a0,s1
    80004658:	fffff097          	auipc	ra,0xfffff
    8000465c:	0b6080e7          	jalr	182(ra) # 8000370e <bwrite>
  brelse(buf);
    80004660:	8526                	mv	a0,s1
    80004662:	fffff097          	auipc	ra,0xfffff
    80004666:	0ea080e7          	jalr	234(ra) # 8000374c <brelse>
}
    8000466a:	60e2                	ld	ra,24(sp)
    8000466c:	6442                	ld	s0,16(sp)
    8000466e:	64a2                	ld	s1,8(sp)
    80004670:	6902                	ld	s2,0(sp)
    80004672:	6105                	add	sp,sp,32
    80004674:	8082                	ret

0000000080004676 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004676:	0001d797          	auipc	a5,0x1d
    8000467a:	6e67a783          	lw	a5,1766(a5) # 80021d5c <log+0x2c>
    8000467e:	0af05d63          	blez	a5,80004738 <install_trans+0xc2>
{
    80004682:	7139                	add	sp,sp,-64
    80004684:	fc06                	sd	ra,56(sp)
    80004686:	f822                	sd	s0,48(sp)
    80004688:	f426                	sd	s1,40(sp)
    8000468a:	f04a                	sd	s2,32(sp)
    8000468c:	ec4e                	sd	s3,24(sp)
    8000468e:	e852                	sd	s4,16(sp)
    80004690:	e456                	sd	s5,8(sp)
    80004692:	e05a                	sd	s6,0(sp)
    80004694:	0080                	add	s0,sp,64
    80004696:	8b2a                	mv	s6,a0
    80004698:	0001da97          	auipc	s5,0x1d
    8000469c:	6c8a8a93          	add	s5,s5,1736 # 80021d60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046a0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046a2:	0001d997          	auipc	s3,0x1d
    800046a6:	68e98993          	add	s3,s3,1678 # 80021d30 <log>
    800046aa:	a00d                	j	800046cc <install_trans+0x56>
    brelse(lbuf);
    800046ac:	854a                	mv	a0,s2
    800046ae:	fffff097          	auipc	ra,0xfffff
    800046b2:	09e080e7          	jalr	158(ra) # 8000374c <brelse>
    brelse(dbuf);
    800046b6:	8526                	mv	a0,s1
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	094080e7          	jalr	148(ra) # 8000374c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046c0:	2a05                	addw	s4,s4,1
    800046c2:	0a91                	add	s5,s5,4
    800046c4:	02c9a783          	lw	a5,44(s3)
    800046c8:	04fa5e63          	bge	s4,a5,80004724 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046cc:	0189a583          	lw	a1,24(s3)
    800046d0:	014585bb          	addw	a1,a1,s4
    800046d4:	2585                	addw	a1,a1,1
    800046d6:	0289a503          	lw	a0,40(s3)
    800046da:	fffff097          	auipc	ra,0xfffff
    800046de:	f42080e7          	jalr	-190(ra) # 8000361c <bread>
    800046e2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800046e4:	000aa583          	lw	a1,0(s5)
    800046e8:	0289a503          	lw	a0,40(s3)
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	f30080e7          	jalr	-208(ra) # 8000361c <bread>
    800046f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046f6:	40000613          	li	a2,1024
    800046fa:	05890593          	add	a1,s2,88
    800046fe:	05850513          	add	a0,a0,88
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	628080e7          	jalr	1576(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000470a:	8526                	mv	a0,s1
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	002080e7          	jalr	2(ra) # 8000370e <bwrite>
    if(recovering == 0)
    80004714:	f80b1ce3          	bnez	s6,800046ac <install_trans+0x36>
      bunpin(dbuf);
    80004718:	8526                	mv	a0,s1
    8000471a:	fffff097          	auipc	ra,0xfffff
    8000471e:	10a080e7          	jalr	266(ra) # 80003824 <bunpin>
    80004722:	b769                	j	800046ac <install_trans+0x36>
}
    80004724:	70e2                	ld	ra,56(sp)
    80004726:	7442                	ld	s0,48(sp)
    80004728:	74a2                	ld	s1,40(sp)
    8000472a:	7902                	ld	s2,32(sp)
    8000472c:	69e2                	ld	s3,24(sp)
    8000472e:	6a42                	ld	s4,16(sp)
    80004730:	6aa2                	ld	s5,8(sp)
    80004732:	6b02                	ld	s6,0(sp)
    80004734:	6121                	add	sp,sp,64
    80004736:	8082                	ret
    80004738:	8082                	ret

000000008000473a <initlog>:
{
    8000473a:	7179                	add	sp,sp,-48
    8000473c:	f406                	sd	ra,40(sp)
    8000473e:	f022                	sd	s0,32(sp)
    80004740:	ec26                	sd	s1,24(sp)
    80004742:	e84a                	sd	s2,16(sp)
    80004744:	e44e                	sd	s3,8(sp)
    80004746:	1800                	add	s0,sp,48
    80004748:	892a                	mv	s2,a0
    8000474a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000474c:	0001d497          	auipc	s1,0x1d
    80004750:	5e448493          	add	s1,s1,1508 # 80021d30 <log>
    80004754:	00004597          	auipc	a1,0x4
    80004758:	ef458593          	add	a1,a1,-268 # 80008648 <syscalls+0x1f8>
    8000475c:	8526                	mv	a0,s1
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	3e4080e7          	jalr	996(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004766:	0149a583          	lw	a1,20(s3)
    8000476a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000476c:	0109a783          	lw	a5,16(s3)
    80004770:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004772:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004776:	854a                	mv	a0,s2
    80004778:	fffff097          	auipc	ra,0xfffff
    8000477c:	ea4080e7          	jalr	-348(ra) # 8000361c <bread>
  log.lh.n = lh->n;
    80004780:	4d30                	lw	a2,88(a0)
    80004782:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004784:	00c05f63          	blez	a2,800047a2 <initlog+0x68>
    80004788:	87aa                	mv	a5,a0
    8000478a:	0001d717          	auipc	a4,0x1d
    8000478e:	5d670713          	add	a4,a4,1494 # 80021d60 <log+0x30>
    80004792:	060a                	sll	a2,a2,0x2
    80004794:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004796:	4ff4                	lw	a3,92(a5)
    80004798:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000479a:	0791                	add	a5,a5,4
    8000479c:	0711                	add	a4,a4,4
    8000479e:	fec79ce3          	bne	a5,a2,80004796 <initlog+0x5c>
  brelse(buf);
    800047a2:	fffff097          	auipc	ra,0xfffff
    800047a6:	faa080e7          	jalr	-86(ra) # 8000374c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800047aa:	4505                	li	a0,1
    800047ac:	00000097          	auipc	ra,0x0
    800047b0:	eca080e7          	jalr	-310(ra) # 80004676 <install_trans>
  log.lh.n = 0;
    800047b4:	0001d797          	auipc	a5,0x1d
    800047b8:	5a07a423          	sw	zero,1448(a5) # 80021d5c <log+0x2c>
  write_head(); // clear the log
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	e50080e7          	jalr	-432(ra) # 8000460c <write_head>
}
    800047c4:	70a2                	ld	ra,40(sp)
    800047c6:	7402                	ld	s0,32(sp)
    800047c8:	64e2                	ld	s1,24(sp)
    800047ca:	6942                	ld	s2,16(sp)
    800047cc:	69a2                	ld	s3,8(sp)
    800047ce:	6145                	add	sp,sp,48
    800047d0:	8082                	ret

00000000800047d2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800047d2:	1101                	add	sp,sp,-32
    800047d4:	ec06                	sd	ra,24(sp)
    800047d6:	e822                	sd	s0,16(sp)
    800047d8:	e426                	sd	s1,8(sp)
    800047da:	e04a                	sd	s2,0(sp)
    800047dc:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800047de:	0001d517          	auipc	a0,0x1d
    800047e2:	55250513          	add	a0,a0,1362 # 80021d30 <log>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	3ec080e7          	jalr	1004(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    800047ee:	0001d497          	auipc	s1,0x1d
    800047f2:	54248493          	add	s1,s1,1346 # 80021d30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047f6:	4979                	li	s2,30
    800047f8:	a039                	j	80004806 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047fa:	85a6                	mv	a1,s1
    800047fc:	8526                	mv	a0,s1
    800047fe:	ffffe097          	auipc	ra,0xffffe
    80004802:	982080e7          	jalr	-1662(ra) # 80002180 <sleep>
    if(log.committing){
    80004806:	50dc                	lw	a5,36(s1)
    80004808:	fbed                	bnez	a5,800047fa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000480a:	5098                	lw	a4,32(s1)
    8000480c:	2705                	addw	a4,a4,1
    8000480e:	0027179b          	sllw	a5,a4,0x2
    80004812:	9fb9                	addw	a5,a5,a4
    80004814:	0017979b          	sllw	a5,a5,0x1
    80004818:	54d4                	lw	a3,44(s1)
    8000481a:	9fb5                	addw	a5,a5,a3
    8000481c:	00f95963          	bge	s2,a5,8000482e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004820:	85a6                	mv	a1,s1
    80004822:	8526                	mv	a0,s1
    80004824:	ffffe097          	auipc	ra,0xffffe
    80004828:	95c080e7          	jalr	-1700(ra) # 80002180 <sleep>
    8000482c:	bfe9                	j	80004806 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000482e:	0001d517          	auipc	a0,0x1d
    80004832:	50250513          	add	a0,a0,1282 # 80021d30 <log>
    80004836:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	44e080e7          	jalr	1102(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004840:	60e2                	ld	ra,24(sp)
    80004842:	6442                	ld	s0,16(sp)
    80004844:	64a2                	ld	s1,8(sp)
    80004846:	6902                	ld	s2,0(sp)
    80004848:	6105                	add	sp,sp,32
    8000484a:	8082                	ret

000000008000484c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000484c:	7139                	add	sp,sp,-64
    8000484e:	fc06                	sd	ra,56(sp)
    80004850:	f822                	sd	s0,48(sp)
    80004852:	f426                	sd	s1,40(sp)
    80004854:	f04a                	sd	s2,32(sp)
    80004856:	ec4e                	sd	s3,24(sp)
    80004858:	e852                	sd	s4,16(sp)
    8000485a:	e456                	sd	s5,8(sp)
    8000485c:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000485e:	0001d497          	auipc	s1,0x1d
    80004862:	4d248493          	add	s1,s1,1234 # 80021d30 <log>
    80004866:	8526                	mv	a0,s1
    80004868:	ffffc097          	auipc	ra,0xffffc
    8000486c:	36a080e7          	jalr	874(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    80004870:	509c                	lw	a5,32(s1)
    80004872:	37fd                	addw	a5,a5,-1
    80004874:	0007891b          	sext.w	s2,a5
    80004878:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000487a:	50dc                	lw	a5,36(s1)
    8000487c:	e7b9                	bnez	a5,800048ca <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000487e:	04091e63          	bnez	s2,800048da <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004882:	0001d497          	auipc	s1,0x1d
    80004886:	4ae48493          	add	s1,s1,1198 # 80021d30 <log>
    8000488a:	4785                	li	a5,1
    8000488c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000488e:	8526                	mv	a0,s1
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	3f6080e7          	jalr	1014(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004898:	54dc                	lw	a5,44(s1)
    8000489a:	06f04763          	bgtz	a5,80004908 <end_op+0xbc>
    acquire(&log.lock);
    8000489e:	0001d497          	auipc	s1,0x1d
    800048a2:	49248493          	add	s1,s1,1170 # 80021d30 <log>
    800048a6:	8526                	mv	a0,s1
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	32a080e7          	jalr	810(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800048b0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800048b4:	8526                	mv	a0,s1
    800048b6:	ffffe097          	auipc	ra,0xffffe
    800048ba:	92e080e7          	jalr	-1746(ra) # 800021e4 <wakeup>
    release(&log.lock);
    800048be:	8526                	mv	a0,s1
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	3c6080e7          	jalr	966(ra) # 80000c86 <release>
}
    800048c8:	a03d                	j	800048f6 <end_op+0xaa>
    panic("log.committing");
    800048ca:	00004517          	auipc	a0,0x4
    800048ce:	d8650513          	add	a0,a0,-634 # 80008650 <syscalls+0x200>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	c6a080e7          	jalr	-918(ra) # 8000053c <panic>
    wakeup(&log);
    800048da:	0001d497          	auipc	s1,0x1d
    800048de:	45648493          	add	s1,s1,1110 # 80021d30 <log>
    800048e2:	8526                	mv	a0,s1
    800048e4:	ffffe097          	auipc	ra,0xffffe
    800048e8:	900080e7          	jalr	-1792(ra) # 800021e4 <wakeup>
  release(&log.lock);
    800048ec:	8526                	mv	a0,s1
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	398080e7          	jalr	920(ra) # 80000c86 <release>
}
    800048f6:	70e2                	ld	ra,56(sp)
    800048f8:	7442                	ld	s0,48(sp)
    800048fa:	74a2                	ld	s1,40(sp)
    800048fc:	7902                	ld	s2,32(sp)
    800048fe:	69e2                	ld	s3,24(sp)
    80004900:	6a42                	ld	s4,16(sp)
    80004902:	6aa2                	ld	s5,8(sp)
    80004904:	6121                	add	sp,sp,64
    80004906:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004908:	0001da97          	auipc	s5,0x1d
    8000490c:	458a8a93          	add	s5,s5,1112 # 80021d60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004910:	0001da17          	auipc	s4,0x1d
    80004914:	420a0a13          	add	s4,s4,1056 # 80021d30 <log>
    80004918:	018a2583          	lw	a1,24(s4)
    8000491c:	012585bb          	addw	a1,a1,s2
    80004920:	2585                	addw	a1,a1,1
    80004922:	028a2503          	lw	a0,40(s4)
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	cf6080e7          	jalr	-778(ra) # 8000361c <bread>
    8000492e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004930:	000aa583          	lw	a1,0(s5)
    80004934:	028a2503          	lw	a0,40(s4)
    80004938:	fffff097          	auipc	ra,0xfffff
    8000493c:	ce4080e7          	jalr	-796(ra) # 8000361c <bread>
    80004940:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004942:	40000613          	li	a2,1024
    80004946:	05850593          	add	a1,a0,88
    8000494a:	05848513          	add	a0,s1,88
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	3dc080e7          	jalr	988(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004956:	8526                	mv	a0,s1
    80004958:	fffff097          	auipc	ra,0xfffff
    8000495c:	db6080e7          	jalr	-586(ra) # 8000370e <bwrite>
    brelse(from);
    80004960:	854e                	mv	a0,s3
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	dea080e7          	jalr	-534(ra) # 8000374c <brelse>
    brelse(to);
    8000496a:	8526                	mv	a0,s1
    8000496c:	fffff097          	auipc	ra,0xfffff
    80004970:	de0080e7          	jalr	-544(ra) # 8000374c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004974:	2905                	addw	s2,s2,1
    80004976:	0a91                	add	s5,s5,4
    80004978:	02ca2783          	lw	a5,44(s4)
    8000497c:	f8f94ee3          	blt	s2,a5,80004918 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004980:	00000097          	auipc	ra,0x0
    80004984:	c8c080e7          	jalr	-884(ra) # 8000460c <write_head>
    install_trans(0); // Now install writes to home locations
    80004988:	4501                	li	a0,0
    8000498a:	00000097          	auipc	ra,0x0
    8000498e:	cec080e7          	jalr	-788(ra) # 80004676 <install_trans>
    log.lh.n = 0;
    80004992:	0001d797          	auipc	a5,0x1d
    80004996:	3c07a523          	sw	zero,970(a5) # 80021d5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000499a:	00000097          	auipc	ra,0x0
    8000499e:	c72080e7          	jalr	-910(ra) # 8000460c <write_head>
    800049a2:	bdf5                	j	8000489e <end_op+0x52>

00000000800049a4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800049a4:	1101                	add	sp,sp,-32
    800049a6:	ec06                	sd	ra,24(sp)
    800049a8:	e822                	sd	s0,16(sp)
    800049aa:	e426                	sd	s1,8(sp)
    800049ac:	e04a                	sd	s2,0(sp)
    800049ae:	1000                	add	s0,sp,32
    800049b0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800049b2:	0001d917          	auipc	s2,0x1d
    800049b6:	37e90913          	add	s2,s2,894 # 80021d30 <log>
    800049ba:	854a                	mv	a0,s2
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	216080e7          	jalr	534(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800049c4:	02c92603          	lw	a2,44(s2)
    800049c8:	47f5                	li	a5,29
    800049ca:	06c7c563          	blt	a5,a2,80004a34 <log_write+0x90>
    800049ce:	0001d797          	auipc	a5,0x1d
    800049d2:	37e7a783          	lw	a5,894(a5) # 80021d4c <log+0x1c>
    800049d6:	37fd                	addw	a5,a5,-1
    800049d8:	04f65e63          	bge	a2,a5,80004a34 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800049dc:	0001d797          	auipc	a5,0x1d
    800049e0:	3747a783          	lw	a5,884(a5) # 80021d50 <log+0x20>
    800049e4:	06f05063          	blez	a5,80004a44 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049e8:	4781                	li	a5,0
    800049ea:	06c05563          	blez	a2,80004a54 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049ee:	44cc                	lw	a1,12(s1)
    800049f0:	0001d717          	auipc	a4,0x1d
    800049f4:	37070713          	add	a4,a4,880 # 80021d60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049f8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049fa:	4314                	lw	a3,0(a4)
    800049fc:	04b68c63          	beq	a3,a1,80004a54 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a00:	2785                	addw	a5,a5,1
    80004a02:	0711                	add	a4,a4,4
    80004a04:	fef61be3          	bne	a2,a5,800049fa <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a08:	0621                	add	a2,a2,8
    80004a0a:	060a                	sll	a2,a2,0x2
    80004a0c:	0001d797          	auipc	a5,0x1d
    80004a10:	32478793          	add	a5,a5,804 # 80021d30 <log>
    80004a14:	97b2                	add	a5,a5,a2
    80004a16:	44d8                	lw	a4,12(s1)
    80004a18:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	fffff097          	auipc	ra,0xfffff
    80004a20:	dcc080e7          	jalr	-564(ra) # 800037e8 <bpin>
    log.lh.n++;
    80004a24:	0001d717          	auipc	a4,0x1d
    80004a28:	30c70713          	add	a4,a4,780 # 80021d30 <log>
    80004a2c:	575c                	lw	a5,44(a4)
    80004a2e:	2785                	addw	a5,a5,1
    80004a30:	d75c                	sw	a5,44(a4)
    80004a32:	a82d                	j	80004a6c <log_write+0xc8>
    panic("too big a transaction");
    80004a34:	00004517          	auipc	a0,0x4
    80004a38:	c2c50513          	add	a0,a0,-980 # 80008660 <syscalls+0x210>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	b00080e7          	jalr	-1280(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004a44:	00004517          	auipc	a0,0x4
    80004a48:	c3450513          	add	a0,a0,-972 # 80008678 <syscalls+0x228>
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	af0080e7          	jalr	-1296(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004a54:	00878693          	add	a3,a5,8
    80004a58:	068a                	sll	a3,a3,0x2
    80004a5a:	0001d717          	auipc	a4,0x1d
    80004a5e:	2d670713          	add	a4,a4,726 # 80021d30 <log>
    80004a62:	9736                	add	a4,a4,a3
    80004a64:	44d4                	lw	a3,12(s1)
    80004a66:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a68:	faf609e3          	beq	a2,a5,80004a1a <log_write+0x76>
  }
  release(&log.lock);
    80004a6c:	0001d517          	auipc	a0,0x1d
    80004a70:	2c450513          	add	a0,a0,708 # 80021d30 <log>
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	212080e7          	jalr	530(ra) # 80000c86 <release>
}
    80004a7c:	60e2                	ld	ra,24(sp)
    80004a7e:	6442                	ld	s0,16(sp)
    80004a80:	64a2                	ld	s1,8(sp)
    80004a82:	6902                	ld	s2,0(sp)
    80004a84:	6105                	add	sp,sp,32
    80004a86:	8082                	ret

0000000080004a88 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a88:	1101                	add	sp,sp,-32
    80004a8a:	ec06                	sd	ra,24(sp)
    80004a8c:	e822                	sd	s0,16(sp)
    80004a8e:	e426                	sd	s1,8(sp)
    80004a90:	e04a                	sd	s2,0(sp)
    80004a92:	1000                	add	s0,sp,32
    80004a94:	84aa                	mv	s1,a0
    80004a96:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a98:	00004597          	auipc	a1,0x4
    80004a9c:	c0058593          	add	a1,a1,-1024 # 80008698 <syscalls+0x248>
    80004aa0:	0521                	add	a0,a0,8
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	0a0080e7          	jalr	160(ra) # 80000b42 <initlock>
  lk->name = name;
    80004aaa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004aae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ab2:	0204a423          	sw	zero,40(s1)
}
    80004ab6:	60e2                	ld	ra,24(sp)
    80004ab8:	6442                	ld	s0,16(sp)
    80004aba:	64a2                	ld	s1,8(sp)
    80004abc:	6902                	ld	s2,0(sp)
    80004abe:	6105                	add	sp,sp,32
    80004ac0:	8082                	ret

0000000080004ac2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004ac2:	1101                	add	sp,sp,-32
    80004ac4:	ec06                	sd	ra,24(sp)
    80004ac6:	e822                	sd	s0,16(sp)
    80004ac8:	e426                	sd	s1,8(sp)
    80004aca:	e04a                	sd	s2,0(sp)
    80004acc:	1000                	add	s0,sp,32
    80004ace:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ad0:	00850913          	add	s2,a0,8
    80004ad4:	854a                	mv	a0,s2
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	0fc080e7          	jalr	252(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004ade:	409c                	lw	a5,0(s1)
    80004ae0:	cb89                	beqz	a5,80004af2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004ae2:	85ca                	mv	a1,s2
    80004ae4:	8526                	mv	a0,s1
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	69a080e7          	jalr	1690(ra) # 80002180 <sleep>
  while (lk->locked) {
    80004aee:	409c                	lw	a5,0(s1)
    80004af0:	fbed                	bnez	a5,80004ae2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004af2:	4785                	li	a5,1
    80004af4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004af6:	ffffd097          	auipc	ra,0xffffd
    80004afa:	eb0080e7          	jalr	-336(ra) # 800019a6 <myproc>
    80004afe:	591c                	lw	a5,48(a0)
    80004b00:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b02:	854a                	mv	a0,s2
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	182080e7          	jalr	386(ra) # 80000c86 <release>
}
    80004b0c:	60e2                	ld	ra,24(sp)
    80004b0e:	6442                	ld	s0,16(sp)
    80004b10:	64a2                	ld	s1,8(sp)
    80004b12:	6902                	ld	s2,0(sp)
    80004b14:	6105                	add	sp,sp,32
    80004b16:	8082                	ret

0000000080004b18 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b18:	1101                	add	sp,sp,-32
    80004b1a:	ec06                	sd	ra,24(sp)
    80004b1c:	e822                	sd	s0,16(sp)
    80004b1e:	e426                	sd	s1,8(sp)
    80004b20:	e04a                	sd	s2,0(sp)
    80004b22:	1000                	add	s0,sp,32
    80004b24:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b26:	00850913          	add	s2,a0,8
    80004b2a:	854a                	mv	a0,s2
    80004b2c:	ffffc097          	auipc	ra,0xffffc
    80004b30:	0a6080e7          	jalr	166(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004b34:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b38:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b3c:	8526                	mv	a0,s1
    80004b3e:	ffffd097          	auipc	ra,0xffffd
    80004b42:	6a6080e7          	jalr	1702(ra) # 800021e4 <wakeup>
  release(&lk->lk);
    80004b46:	854a                	mv	a0,s2
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	13e080e7          	jalr	318(ra) # 80000c86 <release>
}
    80004b50:	60e2                	ld	ra,24(sp)
    80004b52:	6442                	ld	s0,16(sp)
    80004b54:	64a2                	ld	s1,8(sp)
    80004b56:	6902                	ld	s2,0(sp)
    80004b58:	6105                	add	sp,sp,32
    80004b5a:	8082                	ret

0000000080004b5c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b5c:	7179                	add	sp,sp,-48
    80004b5e:	f406                	sd	ra,40(sp)
    80004b60:	f022                	sd	s0,32(sp)
    80004b62:	ec26                	sd	s1,24(sp)
    80004b64:	e84a                	sd	s2,16(sp)
    80004b66:	e44e                	sd	s3,8(sp)
    80004b68:	1800                	add	s0,sp,48
    80004b6a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b6c:	00850913          	add	s2,a0,8
    80004b70:	854a                	mv	a0,s2
    80004b72:	ffffc097          	auipc	ra,0xffffc
    80004b76:	060080e7          	jalr	96(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b7a:	409c                	lw	a5,0(s1)
    80004b7c:	ef99                	bnez	a5,80004b9a <holdingsleep+0x3e>
    80004b7e:	4481                	li	s1,0
  release(&lk->lk);
    80004b80:	854a                	mv	a0,s2
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	104080e7          	jalr	260(ra) # 80000c86 <release>
  return r;
}
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	70a2                	ld	ra,40(sp)
    80004b8e:	7402                	ld	s0,32(sp)
    80004b90:	64e2                	ld	s1,24(sp)
    80004b92:	6942                	ld	s2,16(sp)
    80004b94:	69a2                	ld	s3,8(sp)
    80004b96:	6145                	add	sp,sp,48
    80004b98:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b9a:	0284a983          	lw	s3,40(s1)
    80004b9e:	ffffd097          	auipc	ra,0xffffd
    80004ba2:	e08080e7          	jalr	-504(ra) # 800019a6 <myproc>
    80004ba6:	5904                	lw	s1,48(a0)
    80004ba8:	413484b3          	sub	s1,s1,s3
    80004bac:	0014b493          	seqz	s1,s1
    80004bb0:	bfc1                	j	80004b80 <holdingsleep+0x24>

0000000080004bb2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004bb2:	1141                	add	sp,sp,-16
    80004bb4:	e406                	sd	ra,8(sp)
    80004bb6:	e022                	sd	s0,0(sp)
    80004bb8:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bba:	00004597          	auipc	a1,0x4
    80004bbe:	aee58593          	add	a1,a1,-1298 # 800086a8 <syscalls+0x258>
    80004bc2:	0001d517          	auipc	a0,0x1d
    80004bc6:	2b650513          	add	a0,a0,694 # 80021e78 <ftable>
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	f78080e7          	jalr	-136(ra) # 80000b42 <initlock>
}
    80004bd2:	60a2                	ld	ra,8(sp)
    80004bd4:	6402                	ld	s0,0(sp)
    80004bd6:	0141                	add	sp,sp,16
    80004bd8:	8082                	ret

0000000080004bda <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004bda:	1101                	add	sp,sp,-32
    80004bdc:	ec06                	sd	ra,24(sp)
    80004bde:	e822                	sd	s0,16(sp)
    80004be0:	e426                	sd	s1,8(sp)
    80004be2:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004be4:	0001d517          	auipc	a0,0x1d
    80004be8:	29450513          	add	a0,a0,660 # 80021e78 <ftable>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	fe6080e7          	jalr	-26(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bf4:	0001d497          	auipc	s1,0x1d
    80004bf8:	29c48493          	add	s1,s1,668 # 80021e90 <ftable+0x18>
    80004bfc:	0001e717          	auipc	a4,0x1e
    80004c00:	23470713          	add	a4,a4,564 # 80022e30 <disk>
    if(f->ref == 0){
    80004c04:	40dc                	lw	a5,4(s1)
    80004c06:	cf99                	beqz	a5,80004c24 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c08:	02848493          	add	s1,s1,40
    80004c0c:	fee49ce3          	bne	s1,a4,80004c04 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c10:	0001d517          	auipc	a0,0x1d
    80004c14:	26850513          	add	a0,a0,616 # 80021e78 <ftable>
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	06e080e7          	jalr	110(ra) # 80000c86 <release>
  return 0;
    80004c20:	4481                	li	s1,0
    80004c22:	a819                	j	80004c38 <filealloc+0x5e>
      f->ref = 1;
    80004c24:	4785                	li	a5,1
    80004c26:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c28:	0001d517          	auipc	a0,0x1d
    80004c2c:	25050513          	add	a0,a0,592 # 80021e78 <ftable>
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	056080e7          	jalr	86(ra) # 80000c86 <release>
}
    80004c38:	8526                	mv	a0,s1
    80004c3a:	60e2                	ld	ra,24(sp)
    80004c3c:	6442                	ld	s0,16(sp)
    80004c3e:	64a2                	ld	s1,8(sp)
    80004c40:	6105                	add	sp,sp,32
    80004c42:	8082                	ret

0000000080004c44 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c44:	1101                	add	sp,sp,-32
    80004c46:	ec06                	sd	ra,24(sp)
    80004c48:	e822                	sd	s0,16(sp)
    80004c4a:	e426                	sd	s1,8(sp)
    80004c4c:	1000                	add	s0,sp,32
    80004c4e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c50:	0001d517          	auipc	a0,0x1d
    80004c54:	22850513          	add	a0,a0,552 # 80021e78 <ftable>
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	f7a080e7          	jalr	-134(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004c60:	40dc                	lw	a5,4(s1)
    80004c62:	02f05263          	blez	a5,80004c86 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c66:	2785                	addw	a5,a5,1
    80004c68:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c6a:	0001d517          	auipc	a0,0x1d
    80004c6e:	20e50513          	add	a0,a0,526 # 80021e78 <ftable>
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	014080e7          	jalr	20(ra) # 80000c86 <release>
  return f;
}
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	60e2                	ld	ra,24(sp)
    80004c7e:	6442                	ld	s0,16(sp)
    80004c80:	64a2                	ld	s1,8(sp)
    80004c82:	6105                	add	sp,sp,32
    80004c84:	8082                	ret
    panic("filedup");
    80004c86:	00004517          	auipc	a0,0x4
    80004c8a:	a2a50513          	add	a0,a0,-1494 # 800086b0 <syscalls+0x260>
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	8ae080e7          	jalr	-1874(ra) # 8000053c <panic>

0000000080004c96 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c96:	7139                	add	sp,sp,-64
    80004c98:	fc06                	sd	ra,56(sp)
    80004c9a:	f822                	sd	s0,48(sp)
    80004c9c:	f426                	sd	s1,40(sp)
    80004c9e:	f04a                	sd	s2,32(sp)
    80004ca0:	ec4e                	sd	s3,24(sp)
    80004ca2:	e852                	sd	s4,16(sp)
    80004ca4:	e456                	sd	s5,8(sp)
    80004ca6:	0080                	add	s0,sp,64
    80004ca8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004caa:	0001d517          	auipc	a0,0x1d
    80004cae:	1ce50513          	add	a0,a0,462 # 80021e78 <ftable>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	f20080e7          	jalr	-224(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004cba:	40dc                	lw	a5,4(s1)
    80004cbc:	06f05163          	blez	a5,80004d1e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004cc0:	37fd                	addw	a5,a5,-1
    80004cc2:	0007871b          	sext.w	a4,a5
    80004cc6:	c0dc                	sw	a5,4(s1)
    80004cc8:	06e04363          	bgtz	a4,80004d2e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ccc:	0004a903          	lw	s2,0(s1)
    80004cd0:	0094ca83          	lbu	s5,9(s1)
    80004cd4:	0104ba03          	ld	s4,16(s1)
    80004cd8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cdc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ce0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ce4:	0001d517          	auipc	a0,0x1d
    80004ce8:	19450513          	add	a0,a0,404 # 80021e78 <ftable>
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	f9a080e7          	jalr	-102(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004cf4:	4785                	li	a5,1
    80004cf6:	04f90d63          	beq	s2,a5,80004d50 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cfa:	3979                	addw	s2,s2,-2
    80004cfc:	4785                	li	a5,1
    80004cfe:	0527e063          	bltu	a5,s2,80004d3e <fileclose+0xa8>
    begin_op();
    80004d02:	00000097          	auipc	ra,0x0
    80004d06:	ad0080e7          	jalr	-1328(ra) # 800047d2 <begin_op>
    iput(ff.ip);
    80004d0a:	854e                	mv	a0,s3
    80004d0c:	fffff097          	auipc	ra,0xfffff
    80004d10:	2da080e7          	jalr	730(ra) # 80003fe6 <iput>
    end_op();
    80004d14:	00000097          	auipc	ra,0x0
    80004d18:	b38080e7          	jalr	-1224(ra) # 8000484c <end_op>
    80004d1c:	a00d                	j	80004d3e <fileclose+0xa8>
    panic("fileclose");
    80004d1e:	00004517          	auipc	a0,0x4
    80004d22:	99a50513          	add	a0,a0,-1638 # 800086b8 <syscalls+0x268>
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	816080e7          	jalr	-2026(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004d2e:	0001d517          	auipc	a0,0x1d
    80004d32:	14a50513          	add	a0,a0,330 # 80021e78 <ftable>
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	f50080e7          	jalr	-176(ra) # 80000c86 <release>
  }
}
    80004d3e:	70e2                	ld	ra,56(sp)
    80004d40:	7442                	ld	s0,48(sp)
    80004d42:	74a2                	ld	s1,40(sp)
    80004d44:	7902                	ld	s2,32(sp)
    80004d46:	69e2                	ld	s3,24(sp)
    80004d48:	6a42                	ld	s4,16(sp)
    80004d4a:	6aa2                	ld	s5,8(sp)
    80004d4c:	6121                	add	sp,sp,64
    80004d4e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d50:	85d6                	mv	a1,s5
    80004d52:	8552                	mv	a0,s4
    80004d54:	00000097          	auipc	ra,0x0
    80004d58:	348080e7          	jalr	840(ra) # 8000509c <pipeclose>
    80004d5c:	b7cd                	j	80004d3e <fileclose+0xa8>

0000000080004d5e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d5e:	715d                	add	sp,sp,-80
    80004d60:	e486                	sd	ra,72(sp)
    80004d62:	e0a2                	sd	s0,64(sp)
    80004d64:	fc26                	sd	s1,56(sp)
    80004d66:	f84a                	sd	s2,48(sp)
    80004d68:	f44e                	sd	s3,40(sp)
    80004d6a:	0880                	add	s0,sp,80
    80004d6c:	84aa                	mv	s1,a0
    80004d6e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	c36080e7          	jalr	-970(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d78:	409c                	lw	a5,0(s1)
    80004d7a:	37f9                	addw	a5,a5,-2
    80004d7c:	4705                	li	a4,1
    80004d7e:	04f76763          	bltu	a4,a5,80004dcc <filestat+0x6e>
    80004d82:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d84:	6c88                	ld	a0,24(s1)
    80004d86:	fffff097          	auipc	ra,0xfffff
    80004d8a:	0a6080e7          	jalr	166(ra) # 80003e2c <ilock>
    stati(f->ip, &st);
    80004d8e:	fb840593          	add	a1,s0,-72
    80004d92:	6c88                	ld	a0,24(s1)
    80004d94:	fffff097          	auipc	ra,0xfffff
    80004d98:	322080e7          	jalr	802(ra) # 800040b6 <stati>
    iunlock(f->ip);
    80004d9c:	6c88                	ld	a0,24(s1)
    80004d9e:	fffff097          	auipc	ra,0xfffff
    80004da2:	150080e7          	jalr	336(ra) # 80003eee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004da6:	46e1                	li	a3,24
    80004da8:	fb840613          	add	a2,s0,-72
    80004dac:	85ce                	mv	a1,s3
    80004dae:	08893503          	ld	a0,136(s2)
    80004db2:	ffffd097          	auipc	ra,0xffffd
    80004db6:	8b4080e7          	jalr	-1868(ra) # 80001666 <copyout>
    80004dba:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004dbe:	60a6                	ld	ra,72(sp)
    80004dc0:	6406                	ld	s0,64(sp)
    80004dc2:	74e2                	ld	s1,56(sp)
    80004dc4:	7942                	ld	s2,48(sp)
    80004dc6:	79a2                	ld	s3,40(sp)
    80004dc8:	6161                	add	sp,sp,80
    80004dca:	8082                	ret
  return -1;
    80004dcc:	557d                	li	a0,-1
    80004dce:	bfc5                	j	80004dbe <filestat+0x60>

0000000080004dd0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004dd0:	7179                	add	sp,sp,-48
    80004dd2:	f406                	sd	ra,40(sp)
    80004dd4:	f022                	sd	s0,32(sp)
    80004dd6:	ec26                	sd	s1,24(sp)
    80004dd8:	e84a                	sd	s2,16(sp)
    80004dda:	e44e                	sd	s3,8(sp)
    80004ddc:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dde:	00854783          	lbu	a5,8(a0)
    80004de2:	c3d5                	beqz	a5,80004e86 <fileread+0xb6>
    80004de4:	84aa                	mv	s1,a0
    80004de6:	89ae                	mv	s3,a1
    80004de8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dea:	411c                	lw	a5,0(a0)
    80004dec:	4705                	li	a4,1
    80004dee:	04e78963          	beq	a5,a4,80004e40 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004df2:	470d                	li	a4,3
    80004df4:	04e78d63          	beq	a5,a4,80004e4e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004df8:	4709                	li	a4,2
    80004dfa:	06e79e63          	bne	a5,a4,80004e76 <fileread+0xa6>
    ilock(f->ip);
    80004dfe:	6d08                	ld	a0,24(a0)
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	02c080e7          	jalr	44(ra) # 80003e2c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e08:	874a                	mv	a4,s2
    80004e0a:	5094                	lw	a3,32(s1)
    80004e0c:	864e                	mv	a2,s3
    80004e0e:	4585                	li	a1,1
    80004e10:	6c88                	ld	a0,24(s1)
    80004e12:	fffff097          	auipc	ra,0xfffff
    80004e16:	2ce080e7          	jalr	718(ra) # 800040e0 <readi>
    80004e1a:	892a                	mv	s2,a0
    80004e1c:	00a05563          	blez	a0,80004e26 <fileread+0x56>
      f->off += r;
    80004e20:	509c                	lw	a5,32(s1)
    80004e22:	9fa9                	addw	a5,a5,a0
    80004e24:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e26:	6c88                	ld	a0,24(s1)
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	0c6080e7          	jalr	198(ra) # 80003eee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e30:	854a                	mv	a0,s2
    80004e32:	70a2                	ld	ra,40(sp)
    80004e34:	7402                	ld	s0,32(sp)
    80004e36:	64e2                	ld	s1,24(sp)
    80004e38:	6942                	ld	s2,16(sp)
    80004e3a:	69a2                	ld	s3,8(sp)
    80004e3c:	6145                	add	sp,sp,48
    80004e3e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e40:	6908                	ld	a0,16(a0)
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	3c2080e7          	jalr	962(ra) # 80005204 <piperead>
    80004e4a:	892a                	mv	s2,a0
    80004e4c:	b7d5                	j	80004e30 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e4e:	02451783          	lh	a5,36(a0)
    80004e52:	03079693          	sll	a3,a5,0x30
    80004e56:	92c1                	srl	a3,a3,0x30
    80004e58:	4725                	li	a4,9
    80004e5a:	02d76863          	bltu	a4,a3,80004e8a <fileread+0xba>
    80004e5e:	0792                	sll	a5,a5,0x4
    80004e60:	0001d717          	auipc	a4,0x1d
    80004e64:	f7870713          	add	a4,a4,-136 # 80021dd8 <devsw>
    80004e68:	97ba                	add	a5,a5,a4
    80004e6a:	639c                	ld	a5,0(a5)
    80004e6c:	c38d                	beqz	a5,80004e8e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e6e:	4505                	li	a0,1
    80004e70:	9782                	jalr	a5
    80004e72:	892a                	mv	s2,a0
    80004e74:	bf75                	j	80004e30 <fileread+0x60>
    panic("fileread");
    80004e76:	00004517          	auipc	a0,0x4
    80004e7a:	85250513          	add	a0,a0,-1966 # 800086c8 <syscalls+0x278>
    80004e7e:	ffffb097          	auipc	ra,0xffffb
    80004e82:	6be080e7          	jalr	1726(ra) # 8000053c <panic>
    return -1;
    80004e86:	597d                	li	s2,-1
    80004e88:	b765                	j	80004e30 <fileread+0x60>
      return -1;
    80004e8a:	597d                	li	s2,-1
    80004e8c:	b755                	j	80004e30 <fileread+0x60>
    80004e8e:	597d                	li	s2,-1
    80004e90:	b745                	j	80004e30 <fileread+0x60>

0000000080004e92 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004e92:	00954783          	lbu	a5,9(a0)
    80004e96:	10078e63          	beqz	a5,80004fb2 <filewrite+0x120>
{
    80004e9a:	715d                	add	sp,sp,-80
    80004e9c:	e486                	sd	ra,72(sp)
    80004e9e:	e0a2                	sd	s0,64(sp)
    80004ea0:	fc26                	sd	s1,56(sp)
    80004ea2:	f84a                	sd	s2,48(sp)
    80004ea4:	f44e                	sd	s3,40(sp)
    80004ea6:	f052                	sd	s4,32(sp)
    80004ea8:	ec56                	sd	s5,24(sp)
    80004eaa:	e85a                	sd	s6,16(sp)
    80004eac:	e45e                	sd	s7,8(sp)
    80004eae:	e062                	sd	s8,0(sp)
    80004eb0:	0880                	add	s0,sp,80
    80004eb2:	892a                	mv	s2,a0
    80004eb4:	8b2e                	mv	s6,a1
    80004eb6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004eb8:	411c                	lw	a5,0(a0)
    80004eba:	4705                	li	a4,1
    80004ebc:	02e78263          	beq	a5,a4,80004ee0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ec0:	470d                	li	a4,3
    80004ec2:	02e78563          	beq	a5,a4,80004eec <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ec6:	4709                	li	a4,2
    80004ec8:	0ce79d63          	bne	a5,a4,80004fa2 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ecc:	0ac05b63          	blez	a2,80004f82 <filewrite+0xf0>
    int i = 0;
    80004ed0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004ed2:	6b85                	lui	s7,0x1
    80004ed4:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ed8:	6c05                	lui	s8,0x1
    80004eda:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004ede:	a851                	j	80004f72 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004ee0:	6908                	ld	a0,16(a0)
    80004ee2:	00000097          	auipc	ra,0x0
    80004ee6:	22a080e7          	jalr	554(ra) # 8000510c <pipewrite>
    80004eea:	a045                	j	80004f8a <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004eec:	02451783          	lh	a5,36(a0)
    80004ef0:	03079693          	sll	a3,a5,0x30
    80004ef4:	92c1                	srl	a3,a3,0x30
    80004ef6:	4725                	li	a4,9
    80004ef8:	0ad76f63          	bltu	a4,a3,80004fb6 <filewrite+0x124>
    80004efc:	0792                	sll	a5,a5,0x4
    80004efe:	0001d717          	auipc	a4,0x1d
    80004f02:	eda70713          	add	a4,a4,-294 # 80021dd8 <devsw>
    80004f06:	97ba                	add	a5,a5,a4
    80004f08:	679c                	ld	a5,8(a5)
    80004f0a:	cbc5                	beqz	a5,80004fba <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004f0c:	4505                	li	a0,1
    80004f0e:	9782                	jalr	a5
    80004f10:	a8ad                	j	80004f8a <filewrite+0xf8>
      if(n1 > max)
    80004f12:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004f16:	00000097          	auipc	ra,0x0
    80004f1a:	8bc080e7          	jalr	-1860(ra) # 800047d2 <begin_op>
      ilock(f->ip);
    80004f1e:	01893503          	ld	a0,24(s2)
    80004f22:	fffff097          	auipc	ra,0xfffff
    80004f26:	f0a080e7          	jalr	-246(ra) # 80003e2c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f2a:	8756                	mv	a4,s5
    80004f2c:	02092683          	lw	a3,32(s2)
    80004f30:	01698633          	add	a2,s3,s6
    80004f34:	4585                	li	a1,1
    80004f36:	01893503          	ld	a0,24(s2)
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	29e080e7          	jalr	670(ra) # 800041d8 <writei>
    80004f42:	84aa                	mv	s1,a0
    80004f44:	00a05763          	blez	a0,80004f52 <filewrite+0xc0>
        f->off += r;
    80004f48:	02092783          	lw	a5,32(s2)
    80004f4c:	9fa9                	addw	a5,a5,a0
    80004f4e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f52:	01893503          	ld	a0,24(s2)
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	f98080e7          	jalr	-104(ra) # 80003eee <iunlock>
      end_op();
    80004f5e:	00000097          	auipc	ra,0x0
    80004f62:	8ee080e7          	jalr	-1810(ra) # 8000484c <end_op>

      if(r != n1){
    80004f66:	009a9f63          	bne	s5,s1,80004f84 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004f6a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f6e:	0149db63          	bge	s3,s4,80004f84 <filewrite+0xf2>
      int n1 = n - i;
    80004f72:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004f76:	0004879b          	sext.w	a5,s1
    80004f7a:	f8fbdce3          	bge	s7,a5,80004f12 <filewrite+0x80>
    80004f7e:	84e2                	mv	s1,s8
    80004f80:	bf49                	j	80004f12 <filewrite+0x80>
    int i = 0;
    80004f82:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f84:	033a1d63          	bne	s4,s3,80004fbe <filewrite+0x12c>
    80004f88:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f8a:	60a6                	ld	ra,72(sp)
    80004f8c:	6406                	ld	s0,64(sp)
    80004f8e:	74e2                	ld	s1,56(sp)
    80004f90:	7942                	ld	s2,48(sp)
    80004f92:	79a2                	ld	s3,40(sp)
    80004f94:	7a02                	ld	s4,32(sp)
    80004f96:	6ae2                	ld	s5,24(sp)
    80004f98:	6b42                	ld	s6,16(sp)
    80004f9a:	6ba2                	ld	s7,8(sp)
    80004f9c:	6c02                	ld	s8,0(sp)
    80004f9e:	6161                	add	sp,sp,80
    80004fa0:	8082                	ret
    panic("filewrite");
    80004fa2:	00003517          	auipc	a0,0x3
    80004fa6:	73650513          	add	a0,a0,1846 # 800086d8 <syscalls+0x288>
    80004faa:	ffffb097          	auipc	ra,0xffffb
    80004fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    return -1;
    80004fb2:	557d                	li	a0,-1
}
    80004fb4:	8082                	ret
      return -1;
    80004fb6:	557d                	li	a0,-1
    80004fb8:	bfc9                	j	80004f8a <filewrite+0xf8>
    80004fba:	557d                	li	a0,-1
    80004fbc:	b7f9                	j	80004f8a <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004fbe:	557d                	li	a0,-1
    80004fc0:	b7e9                	j	80004f8a <filewrite+0xf8>

0000000080004fc2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004fc2:	7179                	add	sp,sp,-48
    80004fc4:	f406                	sd	ra,40(sp)
    80004fc6:	f022                	sd	s0,32(sp)
    80004fc8:	ec26                	sd	s1,24(sp)
    80004fca:	e84a                	sd	s2,16(sp)
    80004fcc:	e44e                	sd	s3,8(sp)
    80004fce:	e052                	sd	s4,0(sp)
    80004fd0:	1800                	add	s0,sp,48
    80004fd2:	84aa                	mv	s1,a0
    80004fd4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004fd6:	0005b023          	sd	zero,0(a1)
    80004fda:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fde:	00000097          	auipc	ra,0x0
    80004fe2:	bfc080e7          	jalr	-1028(ra) # 80004bda <filealloc>
    80004fe6:	e088                	sd	a0,0(s1)
    80004fe8:	c551                	beqz	a0,80005074 <pipealloc+0xb2>
    80004fea:	00000097          	auipc	ra,0x0
    80004fee:	bf0080e7          	jalr	-1040(ra) # 80004bda <filealloc>
    80004ff2:	00aa3023          	sd	a0,0(s4)
    80004ff6:	c92d                	beqz	a0,80005068 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	aea080e7          	jalr	-1302(ra) # 80000ae2 <kalloc>
    80005000:	892a                	mv	s2,a0
    80005002:	c125                	beqz	a0,80005062 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005004:	4985                	li	s3,1
    80005006:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000500a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000500e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005012:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005016:	00003597          	auipc	a1,0x3
    8000501a:	6d258593          	add	a1,a1,1746 # 800086e8 <syscalls+0x298>
    8000501e:	ffffc097          	auipc	ra,0xffffc
    80005022:	b24080e7          	jalr	-1244(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80005026:	609c                	ld	a5,0(s1)
    80005028:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000502c:	609c                	ld	a5,0(s1)
    8000502e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005032:	609c                	ld	a5,0(s1)
    80005034:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005038:	609c                	ld	a5,0(s1)
    8000503a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000503e:	000a3783          	ld	a5,0(s4)
    80005042:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005046:	000a3783          	ld	a5,0(s4)
    8000504a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000504e:	000a3783          	ld	a5,0(s4)
    80005052:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005056:	000a3783          	ld	a5,0(s4)
    8000505a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000505e:	4501                	li	a0,0
    80005060:	a025                	j	80005088 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005062:	6088                	ld	a0,0(s1)
    80005064:	e501                	bnez	a0,8000506c <pipealloc+0xaa>
    80005066:	a039                	j	80005074 <pipealloc+0xb2>
    80005068:	6088                	ld	a0,0(s1)
    8000506a:	c51d                	beqz	a0,80005098 <pipealloc+0xd6>
    fileclose(*f0);
    8000506c:	00000097          	auipc	ra,0x0
    80005070:	c2a080e7          	jalr	-982(ra) # 80004c96 <fileclose>
  if(*f1)
    80005074:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005078:	557d                	li	a0,-1
  if(*f1)
    8000507a:	c799                	beqz	a5,80005088 <pipealloc+0xc6>
    fileclose(*f1);
    8000507c:	853e                	mv	a0,a5
    8000507e:	00000097          	auipc	ra,0x0
    80005082:	c18080e7          	jalr	-1000(ra) # 80004c96 <fileclose>
  return -1;
    80005086:	557d                	li	a0,-1
}
    80005088:	70a2                	ld	ra,40(sp)
    8000508a:	7402                	ld	s0,32(sp)
    8000508c:	64e2                	ld	s1,24(sp)
    8000508e:	6942                	ld	s2,16(sp)
    80005090:	69a2                	ld	s3,8(sp)
    80005092:	6a02                	ld	s4,0(sp)
    80005094:	6145                	add	sp,sp,48
    80005096:	8082                	ret
  return -1;
    80005098:	557d                	li	a0,-1
    8000509a:	b7fd                	j	80005088 <pipealloc+0xc6>

000000008000509c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000509c:	1101                	add	sp,sp,-32
    8000509e:	ec06                	sd	ra,24(sp)
    800050a0:	e822                	sd	s0,16(sp)
    800050a2:	e426                	sd	s1,8(sp)
    800050a4:	e04a                	sd	s2,0(sp)
    800050a6:	1000                	add	s0,sp,32
    800050a8:	84aa                	mv	s1,a0
    800050aa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	b26080e7          	jalr	-1242(ra) # 80000bd2 <acquire>
  if(writable){
    800050b4:	02090d63          	beqz	s2,800050ee <pipeclose+0x52>
    pi->writeopen = 0;
    800050b8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800050bc:	21848513          	add	a0,s1,536
    800050c0:	ffffd097          	auipc	ra,0xffffd
    800050c4:	124080e7          	jalr	292(ra) # 800021e4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800050c8:	2204b783          	ld	a5,544(s1)
    800050cc:	eb95                	bnez	a5,80005100 <pipeclose+0x64>
    release(&pi->lock);
    800050ce:	8526                	mv	a0,s1
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	bb6080e7          	jalr	-1098(ra) # 80000c86 <release>
    kfree((char*)pi);
    800050d8:	8526                	mv	a0,s1
    800050da:	ffffc097          	auipc	ra,0xffffc
    800050de:	90a080e7          	jalr	-1782(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800050e2:	60e2                	ld	ra,24(sp)
    800050e4:	6442                	ld	s0,16(sp)
    800050e6:	64a2                	ld	s1,8(sp)
    800050e8:	6902                	ld	s2,0(sp)
    800050ea:	6105                	add	sp,sp,32
    800050ec:	8082                	ret
    pi->readopen = 0;
    800050ee:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050f2:	21c48513          	add	a0,s1,540
    800050f6:	ffffd097          	auipc	ra,0xffffd
    800050fa:	0ee080e7          	jalr	238(ra) # 800021e4 <wakeup>
    800050fe:	b7e9                	j	800050c8 <pipeclose+0x2c>
    release(&pi->lock);
    80005100:	8526                	mv	a0,s1
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	b84080e7          	jalr	-1148(ra) # 80000c86 <release>
}
    8000510a:	bfe1                	j	800050e2 <pipeclose+0x46>

000000008000510c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000510c:	711d                	add	sp,sp,-96
    8000510e:	ec86                	sd	ra,88(sp)
    80005110:	e8a2                	sd	s0,80(sp)
    80005112:	e4a6                	sd	s1,72(sp)
    80005114:	e0ca                	sd	s2,64(sp)
    80005116:	fc4e                	sd	s3,56(sp)
    80005118:	f852                	sd	s4,48(sp)
    8000511a:	f456                	sd	s5,40(sp)
    8000511c:	f05a                	sd	s6,32(sp)
    8000511e:	ec5e                	sd	s7,24(sp)
    80005120:	e862                	sd	s8,16(sp)
    80005122:	1080                	add	s0,sp,96
    80005124:	84aa                	mv	s1,a0
    80005126:	8aae                	mv	s5,a1
    80005128:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	87c080e7          	jalr	-1924(ra) # 800019a6 <myproc>
    80005132:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005134:	8526                	mv	a0,s1
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	a9c080e7          	jalr	-1380(ra) # 80000bd2 <acquire>
  while(i < n){
    8000513e:	0b405663          	blez	s4,800051ea <pipewrite+0xde>
  int i = 0;
    80005142:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005144:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005146:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000514a:	21c48b93          	add	s7,s1,540
    8000514e:	a089                	j	80005190 <pipewrite+0x84>
      release(&pi->lock);
    80005150:	8526                	mv	a0,s1
    80005152:	ffffc097          	auipc	ra,0xffffc
    80005156:	b34080e7          	jalr	-1228(ra) # 80000c86 <release>
      return -1;
    8000515a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000515c:	854a                	mv	a0,s2
    8000515e:	60e6                	ld	ra,88(sp)
    80005160:	6446                	ld	s0,80(sp)
    80005162:	64a6                	ld	s1,72(sp)
    80005164:	6906                	ld	s2,64(sp)
    80005166:	79e2                	ld	s3,56(sp)
    80005168:	7a42                	ld	s4,48(sp)
    8000516a:	7aa2                	ld	s5,40(sp)
    8000516c:	7b02                	ld	s6,32(sp)
    8000516e:	6be2                	ld	s7,24(sp)
    80005170:	6c42                	ld	s8,16(sp)
    80005172:	6125                	add	sp,sp,96
    80005174:	8082                	ret
      wakeup(&pi->nread);
    80005176:	8562                	mv	a0,s8
    80005178:	ffffd097          	auipc	ra,0xffffd
    8000517c:	06c080e7          	jalr	108(ra) # 800021e4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005180:	85a6                	mv	a1,s1
    80005182:	855e                	mv	a0,s7
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	ffc080e7          	jalr	-4(ra) # 80002180 <sleep>
  while(i < n){
    8000518c:	07495063          	bge	s2,s4,800051ec <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005190:	2204a783          	lw	a5,544(s1)
    80005194:	dfd5                	beqz	a5,80005150 <pipewrite+0x44>
    80005196:	854e                	mv	a0,s3
    80005198:	ffffd097          	auipc	ra,0xffffd
    8000519c:	2ae080e7          	jalr	686(ra) # 80002446 <killed>
    800051a0:	f945                	bnez	a0,80005150 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800051a2:	2184a783          	lw	a5,536(s1)
    800051a6:	21c4a703          	lw	a4,540(s1)
    800051aa:	2007879b          	addw	a5,a5,512
    800051ae:	fcf704e3          	beq	a4,a5,80005176 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051b2:	4685                	li	a3,1
    800051b4:	01590633          	add	a2,s2,s5
    800051b8:	faf40593          	add	a1,s0,-81
    800051bc:	0889b503          	ld	a0,136(s3)
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	532080e7          	jalr	1330(ra) # 800016f2 <copyin>
    800051c8:	03650263          	beq	a0,s6,800051ec <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800051cc:	21c4a783          	lw	a5,540(s1)
    800051d0:	0017871b          	addw	a4,a5,1
    800051d4:	20e4ae23          	sw	a4,540(s1)
    800051d8:	1ff7f793          	and	a5,a5,511
    800051dc:	97a6                	add	a5,a5,s1
    800051de:	faf44703          	lbu	a4,-81(s0)
    800051e2:	00e78c23          	sb	a4,24(a5)
      i++;
    800051e6:	2905                	addw	s2,s2,1
    800051e8:	b755                	j	8000518c <pipewrite+0x80>
  int i = 0;
    800051ea:	4901                	li	s2,0
  wakeup(&pi->nread);
    800051ec:	21848513          	add	a0,s1,536
    800051f0:	ffffd097          	auipc	ra,0xffffd
    800051f4:	ff4080e7          	jalr	-12(ra) # 800021e4 <wakeup>
  release(&pi->lock);
    800051f8:	8526                	mv	a0,s1
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	a8c080e7          	jalr	-1396(ra) # 80000c86 <release>
  return i;
    80005202:	bfa9                	j	8000515c <pipewrite+0x50>

0000000080005204 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005204:	715d                	add	sp,sp,-80
    80005206:	e486                	sd	ra,72(sp)
    80005208:	e0a2                	sd	s0,64(sp)
    8000520a:	fc26                	sd	s1,56(sp)
    8000520c:	f84a                	sd	s2,48(sp)
    8000520e:	f44e                	sd	s3,40(sp)
    80005210:	f052                	sd	s4,32(sp)
    80005212:	ec56                	sd	s5,24(sp)
    80005214:	e85a                	sd	s6,16(sp)
    80005216:	0880                	add	s0,sp,80
    80005218:	84aa                	mv	s1,a0
    8000521a:	892e                	mv	s2,a1
    8000521c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	788080e7          	jalr	1928(ra) # 800019a6 <myproc>
    80005226:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005228:	8526                	mv	a0,s1
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	9a8080e7          	jalr	-1624(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005232:	2184a703          	lw	a4,536(s1)
    80005236:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000523a:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000523e:	02f71763          	bne	a4,a5,8000526c <piperead+0x68>
    80005242:	2244a783          	lw	a5,548(s1)
    80005246:	c39d                	beqz	a5,8000526c <piperead+0x68>
    if(killed(pr)){
    80005248:	8552                	mv	a0,s4
    8000524a:	ffffd097          	auipc	ra,0xffffd
    8000524e:	1fc080e7          	jalr	508(ra) # 80002446 <killed>
    80005252:	e949                	bnez	a0,800052e4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005254:	85a6                	mv	a1,s1
    80005256:	854e                	mv	a0,s3
    80005258:	ffffd097          	auipc	ra,0xffffd
    8000525c:	f28080e7          	jalr	-216(ra) # 80002180 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005260:	2184a703          	lw	a4,536(s1)
    80005264:	21c4a783          	lw	a5,540(s1)
    80005268:	fcf70de3          	beq	a4,a5,80005242 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000526c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000526e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005270:	05505463          	blez	s5,800052b8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005274:	2184a783          	lw	a5,536(s1)
    80005278:	21c4a703          	lw	a4,540(s1)
    8000527c:	02f70e63          	beq	a4,a5,800052b8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005280:	0017871b          	addw	a4,a5,1
    80005284:	20e4ac23          	sw	a4,536(s1)
    80005288:	1ff7f793          	and	a5,a5,511
    8000528c:	97a6                	add	a5,a5,s1
    8000528e:	0187c783          	lbu	a5,24(a5)
    80005292:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005296:	4685                	li	a3,1
    80005298:	fbf40613          	add	a2,s0,-65
    8000529c:	85ca                	mv	a1,s2
    8000529e:	088a3503          	ld	a0,136(s4)
    800052a2:	ffffc097          	auipc	ra,0xffffc
    800052a6:	3c4080e7          	jalr	964(ra) # 80001666 <copyout>
    800052aa:	01650763          	beq	a0,s6,800052b8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052ae:	2985                	addw	s3,s3,1
    800052b0:	0905                	add	s2,s2,1
    800052b2:	fd3a91e3          	bne	s5,s3,80005274 <piperead+0x70>
    800052b6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800052b8:	21c48513          	add	a0,s1,540
    800052bc:	ffffd097          	auipc	ra,0xffffd
    800052c0:	f28080e7          	jalr	-216(ra) # 800021e4 <wakeup>
  release(&pi->lock);
    800052c4:	8526                	mv	a0,s1
    800052c6:	ffffc097          	auipc	ra,0xffffc
    800052ca:	9c0080e7          	jalr	-1600(ra) # 80000c86 <release>
  return i;
}
    800052ce:	854e                	mv	a0,s3
    800052d0:	60a6                	ld	ra,72(sp)
    800052d2:	6406                	ld	s0,64(sp)
    800052d4:	74e2                	ld	s1,56(sp)
    800052d6:	7942                	ld	s2,48(sp)
    800052d8:	79a2                	ld	s3,40(sp)
    800052da:	7a02                	ld	s4,32(sp)
    800052dc:	6ae2                	ld	s5,24(sp)
    800052de:	6b42                	ld	s6,16(sp)
    800052e0:	6161                	add	sp,sp,80
    800052e2:	8082                	ret
      release(&pi->lock);
    800052e4:	8526                	mv	a0,s1
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	9a0080e7          	jalr	-1632(ra) # 80000c86 <release>
      return -1;
    800052ee:	59fd                	li	s3,-1
    800052f0:	bff9                	j	800052ce <piperead+0xca>

00000000800052f2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800052f2:	1141                	add	sp,sp,-16
    800052f4:	e422                	sd	s0,8(sp)
    800052f6:	0800                	add	s0,sp,16
    800052f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800052fa:	8905                	and	a0,a0,1
    800052fc:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800052fe:	8b89                	and	a5,a5,2
    80005300:	c399                	beqz	a5,80005306 <flags2perm+0x14>
      perm |= PTE_W;
    80005302:	00456513          	or	a0,a0,4
    return perm;
}
    80005306:	6422                	ld	s0,8(sp)
    80005308:	0141                	add	sp,sp,16
    8000530a:	8082                	ret

000000008000530c <exec>:

int
exec(char *path, char **argv)
{
    8000530c:	df010113          	add	sp,sp,-528
    80005310:	20113423          	sd	ra,520(sp)
    80005314:	20813023          	sd	s0,512(sp)
    80005318:	ffa6                	sd	s1,504(sp)
    8000531a:	fbca                	sd	s2,496(sp)
    8000531c:	f7ce                	sd	s3,488(sp)
    8000531e:	f3d2                	sd	s4,480(sp)
    80005320:	efd6                	sd	s5,472(sp)
    80005322:	ebda                	sd	s6,464(sp)
    80005324:	e7de                	sd	s7,456(sp)
    80005326:	e3e2                	sd	s8,448(sp)
    80005328:	ff66                	sd	s9,440(sp)
    8000532a:	fb6a                	sd	s10,432(sp)
    8000532c:	f76e                	sd	s11,424(sp)
    8000532e:	0c00                	add	s0,sp,528
    80005330:	892a                	mv	s2,a0
    80005332:	dea43c23          	sd	a0,-520(s0)
    80005336:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000533a:	ffffc097          	auipc	ra,0xffffc
    8000533e:	66c080e7          	jalr	1644(ra) # 800019a6 <myproc>
    80005342:	84aa                	mv	s1,a0

  begin_op();
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	48e080e7          	jalr	1166(ra) # 800047d2 <begin_op>

  if((ip = namei(path)) == 0){
    8000534c:	854a                	mv	a0,s2
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	284080e7          	jalr	644(ra) # 800045d2 <namei>
    80005356:	c92d                	beqz	a0,800053c8 <exec+0xbc>
    80005358:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000535a:	fffff097          	auipc	ra,0xfffff
    8000535e:	ad2080e7          	jalr	-1326(ra) # 80003e2c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005362:	04000713          	li	a4,64
    80005366:	4681                	li	a3,0
    80005368:	e5040613          	add	a2,s0,-432
    8000536c:	4581                	li	a1,0
    8000536e:	8552                	mv	a0,s4
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	d70080e7          	jalr	-656(ra) # 800040e0 <readi>
    80005378:	04000793          	li	a5,64
    8000537c:	00f51a63          	bne	a0,a5,80005390 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005380:	e5042703          	lw	a4,-432(s0)
    80005384:	464c47b7          	lui	a5,0x464c4
    80005388:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000538c:	04f70463          	beq	a4,a5,800053d4 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005390:	8552                	mv	a0,s4
    80005392:	fffff097          	auipc	ra,0xfffff
    80005396:	cfc080e7          	jalr	-772(ra) # 8000408e <iunlockput>
    end_op();
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	4b2080e7          	jalr	1202(ra) # 8000484c <end_op>
  }
  return -1;
    800053a2:	557d                	li	a0,-1
}
    800053a4:	20813083          	ld	ra,520(sp)
    800053a8:	20013403          	ld	s0,512(sp)
    800053ac:	74fe                	ld	s1,504(sp)
    800053ae:	795e                	ld	s2,496(sp)
    800053b0:	79be                	ld	s3,488(sp)
    800053b2:	7a1e                	ld	s4,480(sp)
    800053b4:	6afe                	ld	s5,472(sp)
    800053b6:	6b5e                	ld	s6,464(sp)
    800053b8:	6bbe                	ld	s7,456(sp)
    800053ba:	6c1e                	ld	s8,448(sp)
    800053bc:	7cfa                	ld	s9,440(sp)
    800053be:	7d5a                	ld	s10,432(sp)
    800053c0:	7dba                	ld	s11,424(sp)
    800053c2:	21010113          	add	sp,sp,528
    800053c6:	8082                	ret
    end_op();
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	484080e7          	jalr	1156(ra) # 8000484c <end_op>
    return -1;
    800053d0:	557d                	li	a0,-1
    800053d2:	bfc9                	j	800053a4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800053d4:	8526                	mv	a0,s1
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	694080e7          	jalr	1684(ra) # 80001a6a <proc_pagetable>
    800053de:	8b2a                	mv	s6,a0
    800053e0:	d945                	beqz	a0,80005390 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053e2:	e7042d03          	lw	s10,-400(s0)
    800053e6:	e8845783          	lhu	a5,-376(s0)
    800053ea:	10078463          	beqz	a5,800054f2 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053ee:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053f0:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800053f2:	6c85                	lui	s9,0x1
    800053f4:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    800053f8:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800053fc:	6a85                	lui	s5,0x1
    800053fe:	a0b5                	j	8000546a <exec+0x15e>
      panic("loadseg: address should exist");
    80005400:	00003517          	auipc	a0,0x3
    80005404:	2f050513          	add	a0,a0,752 # 800086f0 <syscalls+0x2a0>
    80005408:	ffffb097          	auipc	ra,0xffffb
    8000540c:	134080e7          	jalr	308(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005410:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005412:	8726                	mv	a4,s1
    80005414:	012c06bb          	addw	a3,s8,s2
    80005418:	4581                	li	a1,0
    8000541a:	8552                	mv	a0,s4
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	cc4080e7          	jalr	-828(ra) # 800040e0 <readi>
    80005424:	2501                	sext.w	a0,a0
    80005426:	24a49863          	bne	s1,a0,80005676 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    8000542a:	012a893b          	addw	s2,s5,s2
    8000542e:	03397563          	bgeu	s2,s3,80005458 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80005432:	02091593          	sll	a1,s2,0x20
    80005436:	9181                	srl	a1,a1,0x20
    80005438:	95de                	add	a1,a1,s7
    8000543a:	855a                	mv	a0,s6
    8000543c:	ffffc097          	auipc	ra,0xffffc
    80005440:	c1a080e7          	jalr	-998(ra) # 80001056 <walkaddr>
    80005444:	862a                	mv	a2,a0
    if(pa == 0)
    80005446:	dd4d                	beqz	a0,80005400 <exec+0xf4>
    if(sz - i < PGSIZE)
    80005448:	412984bb          	subw	s1,s3,s2
    8000544c:	0004879b          	sext.w	a5,s1
    80005450:	fcfcf0e3          	bgeu	s9,a5,80005410 <exec+0x104>
    80005454:	84d6                	mv	s1,s5
    80005456:	bf6d                	j	80005410 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005458:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000545c:	2d85                	addw	s11,s11,1
    8000545e:	038d0d1b          	addw	s10,s10,56
    80005462:	e8845783          	lhu	a5,-376(s0)
    80005466:	08fdd763          	bge	s11,a5,800054f4 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000546a:	2d01                	sext.w	s10,s10
    8000546c:	03800713          	li	a4,56
    80005470:	86ea                	mv	a3,s10
    80005472:	e1840613          	add	a2,s0,-488
    80005476:	4581                	li	a1,0
    80005478:	8552                	mv	a0,s4
    8000547a:	fffff097          	auipc	ra,0xfffff
    8000547e:	c66080e7          	jalr	-922(ra) # 800040e0 <readi>
    80005482:	03800793          	li	a5,56
    80005486:	1ef51663          	bne	a0,a5,80005672 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    8000548a:	e1842783          	lw	a5,-488(s0)
    8000548e:	4705                	li	a4,1
    80005490:	fce796e3          	bne	a5,a4,8000545c <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005494:	e4043483          	ld	s1,-448(s0)
    80005498:	e3843783          	ld	a5,-456(s0)
    8000549c:	1ef4e863          	bltu	s1,a5,8000568c <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054a0:	e2843783          	ld	a5,-472(s0)
    800054a4:	94be                	add	s1,s1,a5
    800054a6:	1ef4e663          	bltu	s1,a5,80005692 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    800054aa:	df043703          	ld	a4,-528(s0)
    800054ae:	8ff9                	and	a5,a5,a4
    800054b0:	1e079463          	bnez	a5,80005698 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054b4:	e1c42503          	lw	a0,-484(s0)
    800054b8:	00000097          	auipc	ra,0x0
    800054bc:	e3a080e7          	jalr	-454(ra) # 800052f2 <flags2perm>
    800054c0:	86aa                	mv	a3,a0
    800054c2:	8626                	mv	a2,s1
    800054c4:	85ca                	mv	a1,s2
    800054c6:	855a                	mv	a0,s6
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	f42080e7          	jalr	-190(ra) # 8000140a <uvmalloc>
    800054d0:	e0a43423          	sd	a0,-504(s0)
    800054d4:	1c050563          	beqz	a0,8000569e <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054d8:	e2843b83          	ld	s7,-472(s0)
    800054dc:	e2042c03          	lw	s8,-480(s0)
    800054e0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054e4:	00098463          	beqz	s3,800054ec <exec+0x1e0>
    800054e8:	4901                	li	s2,0
    800054ea:	b7a1                	j	80005432 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054ec:	e0843903          	ld	s2,-504(s0)
    800054f0:	b7b5                	j	8000545c <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054f2:	4901                	li	s2,0
  iunlockput(ip);
    800054f4:	8552                	mv	a0,s4
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	b98080e7          	jalr	-1128(ra) # 8000408e <iunlockput>
  end_op();
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	34e080e7          	jalr	846(ra) # 8000484c <end_op>
  p = myproc();
    80005506:	ffffc097          	auipc	ra,0xffffc
    8000550a:	4a0080e7          	jalr	1184(ra) # 800019a6 <myproc>
    8000550e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005510:	08053c83          	ld	s9,128(a0)
  sz = PGROUNDUP(sz);
    80005514:	6985                	lui	s3,0x1
    80005516:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005518:	99ca                	add	s3,s3,s2
    8000551a:	77fd                	lui	a5,0xfffff
    8000551c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005520:	4691                	li	a3,4
    80005522:	6609                	lui	a2,0x2
    80005524:	964e                	add	a2,a2,s3
    80005526:	85ce                	mv	a1,s3
    80005528:	855a                	mv	a0,s6
    8000552a:	ffffc097          	auipc	ra,0xffffc
    8000552e:	ee0080e7          	jalr	-288(ra) # 8000140a <uvmalloc>
    80005532:	892a                	mv	s2,a0
    80005534:	e0a43423          	sd	a0,-504(s0)
    80005538:	e509                	bnez	a0,80005542 <exec+0x236>
  if(pagetable)
    8000553a:	e1343423          	sd	s3,-504(s0)
    8000553e:	4a01                	li	s4,0
    80005540:	aa1d                	j	80005676 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005542:	75f9                	lui	a1,0xffffe
    80005544:	95aa                	add	a1,a1,a0
    80005546:	855a                	mv	a0,s6
    80005548:	ffffc097          	auipc	ra,0xffffc
    8000554c:	0ec080e7          	jalr	236(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80005550:	7bfd                	lui	s7,0xfffff
    80005552:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005554:	e0043783          	ld	a5,-512(s0)
    80005558:	6388                	ld	a0,0(a5)
    8000555a:	c52d                	beqz	a0,800055c4 <exec+0x2b8>
    8000555c:	e9040993          	add	s3,s0,-368
    80005560:	f9040c13          	add	s8,s0,-112
    80005564:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005566:	ffffc097          	auipc	ra,0xffffc
    8000556a:	8e2080e7          	jalr	-1822(ra) # 80000e48 <strlen>
    8000556e:	0015079b          	addw	a5,a0,1
    80005572:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005576:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    8000557a:	13796563          	bltu	s2,s7,800056a4 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000557e:	e0043d03          	ld	s10,-512(s0)
    80005582:	000d3a03          	ld	s4,0(s10)
    80005586:	8552                	mv	a0,s4
    80005588:	ffffc097          	auipc	ra,0xffffc
    8000558c:	8c0080e7          	jalr	-1856(ra) # 80000e48 <strlen>
    80005590:	0015069b          	addw	a3,a0,1
    80005594:	8652                	mv	a2,s4
    80005596:	85ca                	mv	a1,s2
    80005598:	855a                	mv	a0,s6
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	0cc080e7          	jalr	204(ra) # 80001666 <copyout>
    800055a2:	10054363          	bltz	a0,800056a8 <exec+0x39c>
    ustack[argc] = sp;
    800055a6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055aa:	0485                	add	s1,s1,1
    800055ac:	008d0793          	add	a5,s10,8
    800055b0:	e0f43023          	sd	a5,-512(s0)
    800055b4:	008d3503          	ld	a0,8(s10)
    800055b8:	c909                	beqz	a0,800055ca <exec+0x2be>
    if(argc >= MAXARG)
    800055ba:	09a1                	add	s3,s3,8
    800055bc:	fb8995e3          	bne	s3,s8,80005566 <exec+0x25a>
  ip = 0;
    800055c0:	4a01                	li	s4,0
    800055c2:	a855                	j	80005676 <exec+0x36a>
  sp = sz;
    800055c4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800055c8:	4481                	li	s1,0
  ustack[argc] = 0;
    800055ca:	00349793          	sll	a5,s1,0x3
    800055ce:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc020>
    800055d2:	97a2                	add	a5,a5,s0
    800055d4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800055d8:	00148693          	add	a3,s1,1
    800055dc:	068e                	sll	a3,a3,0x3
    800055de:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055e2:	ff097913          	and	s2,s2,-16
  sz = sz1;
    800055e6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800055ea:	f57968e3          	bltu	s2,s7,8000553a <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800055ee:	e9040613          	add	a2,s0,-368
    800055f2:	85ca                	mv	a1,s2
    800055f4:	855a                	mv	a0,s6
    800055f6:	ffffc097          	auipc	ra,0xffffc
    800055fa:	070080e7          	jalr	112(ra) # 80001666 <copyout>
    800055fe:	0a054763          	bltz	a0,800056ac <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005602:	090ab783          	ld	a5,144(s5) # 1090 <_entry-0x7fffef70>
    80005606:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000560a:	df843783          	ld	a5,-520(s0)
    8000560e:	0007c703          	lbu	a4,0(a5)
    80005612:	cf11                	beqz	a4,8000562e <exec+0x322>
    80005614:	0785                	add	a5,a5,1
    if(*s == '/')
    80005616:	02f00693          	li	a3,47
    8000561a:	a039                	j	80005628 <exec+0x31c>
      last = s+1;
    8000561c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005620:	0785                	add	a5,a5,1
    80005622:	fff7c703          	lbu	a4,-1(a5)
    80005626:	c701                	beqz	a4,8000562e <exec+0x322>
    if(*s == '/')
    80005628:	fed71ce3          	bne	a4,a3,80005620 <exec+0x314>
    8000562c:	bfc5                	j	8000561c <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    8000562e:	4641                	li	a2,16
    80005630:	df843583          	ld	a1,-520(s0)
    80005634:	190a8513          	add	a0,s5,400
    80005638:	ffffb097          	auipc	ra,0xffffb
    8000563c:	7de080e7          	jalr	2014(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005640:	088ab503          	ld	a0,136(s5)
  p->pagetable = pagetable;
    80005644:	096ab423          	sd	s6,136(s5)
  p->sz = sz;
    80005648:	e0843783          	ld	a5,-504(s0)
    8000564c:	08fab023          	sd	a5,128(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005650:	090ab783          	ld	a5,144(s5)
    80005654:	e6843703          	ld	a4,-408(s0)
    80005658:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000565a:	090ab783          	ld	a5,144(s5)
    8000565e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005662:	85e6                	mv	a1,s9
    80005664:	ffffc097          	auipc	ra,0xffffc
    80005668:	4a2080e7          	jalr	1186(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000566c:	0004851b          	sext.w	a0,s1
    80005670:	bb15                	j	800053a4 <exec+0x98>
    80005672:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005676:	e0843583          	ld	a1,-504(s0)
    8000567a:	855a                	mv	a0,s6
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	48a080e7          	jalr	1162(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80005684:	557d                	li	a0,-1
  if(ip){
    80005686:	d00a0fe3          	beqz	s4,800053a4 <exec+0x98>
    8000568a:	b319                	j	80005390 <exec+0x84>
    8000568c:	e1243423          	sd	s2,-504(s0)
    80005690:	b7dd                	j	80005676 <exec+0x36a>
    80005692:	e1243423          	sd	s2,-504(s0)
    80005696:	b7c5                	j	80005676 <exec+0x36a>
    80005698:	e1243423          	sd	s2,-504(s0)
    8000569c:	bfe9                	j	80005676 <exec+0x36a>
    8000569e:	e1243423          	sd	s2,-504(s0)
    800056a2:	bfd1                	j	80005676 <exec+0x36a>
  ip = 0;
    800056a4:	4a01                	li	s4,0
    800056a6:	bfc1                	j	80005676 <exec+0x36a>
    800056a8:	4a01                	li	s4,0
  if(pagetable)
    800056aa:	b7f1                	j	80005676 <exec+0x36a>
  sz = sz1;
    800056ac:	e0843983          	ld	s3,-504(s0)
    800056b0:	b569                	j	8000553a <exec+0x22e>

00000000800056b2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800056b2:	7179                	add	sp,sp,-48
    800056b4:	f406                	sd	ra,40(sp)
    800056b6:	f022                	sd	s0,32(sp)
    800056b8:	ec26                	sd	s1,24(sp)
    800056ba:	e84a                	sd	s2,16(sp)
    800056bc:	1800                	add	s0,sp,48
    800056be:	892e                	mv	s2,a1
    800056c0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800056c2:	fdc40593          	add	a1,s0,-36
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	a30080e7          	jalr	-1488(ra) # 800030f6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800056ce:	fdc42703          	lw	a4,-36(s0)
    800056d2:	47bd                	li	a5,15
    800056d4:	02e7eb63          	bltu	a5,a4,8000570a <argfd+0x58>
    800056d8:	ffffc097          	auipc	ra,0xffffc
    800056dc:	2ce080e7          	jalr	718(ra) # 800019a6 <myproc>
    800056e0:	fdc42703          	lw	a4,-36(s0)
    800056e4:	02070793          	add	a5,a4,32
    800056e8:	078e                	sll	a5,a5,0x3
    800056ea:	953e                	add	a0,a0,a5
    800056ec:	651c                	ld	a5,8(a0)
    800056ee:	c385                	beqz	a5,8000570e <argfd+0x5c>
    return -1;
  if(pfd)
    800056f0:	00090463          	beqz	s2,800056f8 <argfd+0x46>
    *pfd = fd;
    800056f4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800056f8:	4501                	li	a0,0
  if(pf)
    800056fa:	c091                	beqz	s1,800056fe <argfd+0x4c>
    *pf = f;
    800056fc:	e09c                	sd	a5,0(s1)
}
    800056fe:	70a2                	ld	ra,40(sp)
    80005700:	7402                	ld	s0,32(sp)
    80005702:	64e2                	ld	s1,24(sp)
    80005704:	6942                	ld	s2,16(sp)
    80005706:	6145                	add	sp,sp,48
    80005708:	8082                	ret
    return -1;
    8000570a:	557d                	li	a0,-1
    8000570c:	bfcd                	j	800056fe <argfd+0x4c>
    8000570e:	557d                	li	a0,-1
    80005710:	b7fd                	j	800056fe <argfd+0x4c>

0000000080005712 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005712:	1101                	add	sp,sp,-32
    80005714:	ec06                	sd	ra,24(sp)
    80005716:	e822                	sd	s0,16(sp)
    80005718:	e426                	sd	s1,8(sp)
    8000571a:	1000                	add	s0,sp,32
    8000571c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000571e:	ffffc097          	auipc	ra,0xffffc
    80005722:	288080e7          	jalr	648(ra) # 800019a6 <myproc>
    80005726:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005728:	10850793          	add	a5,a0,264
    8000572c:	4501                	li	a0,0
    8000572e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005730:	6398                	ld	a4,0(a5)
    80005732:	cb19                	beqz	a4,80005748 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005734:	2505                	addw	a0,a0,1
    80005736:	07a1                	add	a5,a5,8
    80005738:	fed51ce3          	bne	a0,a3,80005730 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000573c:	557d                	li	a0,-1
}
    8000573e:	60e2                	ld	ra,24(sp)
    80005740:	6442                	ld	s0,16(sp)
    80005742:	64a2                	ld	s1,8(sp)
    80005744:	6105                	add	sp,sp,32
    80005746:	8082                	ret
      p->ofile[fd] = f;
    80005748:	02050793          	add	a5,a0,32
    8000574c:	078e                	sll	a5,a5,0x3
    8000574e:	963e                	add	a2,a2,a5
    80005750:	e604                	sd	s1,8(a2)
      return fd;
    80005752:	b7f5                	j	8000573e <fdalloc+0x2c>

0000000080005754 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005754:	715d                	add	sp,sp,-80
    80005756:	e486                	sd	ra,72(sp)
    80005758:	e0a2                	sd	s0,64(sp)
    8000575a:	fc26                	sd	s1,56(sp)
    8000575c:	f84a                	sd	s2,48(sp)
    8000575e:	f44e                	sd	s3,40(sp)
    80005760:	f052                	sd	s4,32(sp)
    80005762:	ec56                	sd	s5,24(sp)
    80005764:	e85a                	sd	s6,16(sp)
    80005766:	0880                	add	s0,sp,80
    80005768:	8b2e                	mv	s6,a1
    8000576a:	89b2                	mv	s3,a2
    8000576c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000576e:	fb040593          	add	a1,s0,-80
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	e7e080e7          	jalr	-386(ra) # 800045f0 <nameiparent>
    8000577a:	84aa                	mv	s1,a0
    8000577c:	14050b63          	beqz	a0,800058d2 <create+0x17e>
    return 0;

  ilock(dp);
    80005780:	ffffe097          	auipc	ra,0xffffe
    80005784:	6ac080e7          	jalr	1708(ra) # 80003e2c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005788:	4601                	li	a2,0
    8000578a:	fb040593          	add	a1,s0,-80
    8000578e:	8526                	mv	a0,s1
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	b80080e7          	jalr	-1152(ra) # 80004310 <dirlookup>
    80005798:	8aaa                	mv	s5,a0
    8000579a:	c921                	beqz	a0,800057ea <create+0x96>
    iunlockput(dp);
    8000579c:	8526                	mv	a0,s1
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	8f0080e7          	jalr	-1808(ra) # 8000408e <iunlockput>
    ilock(ip);
    800057a6:	8556                	mv	a0,s5
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	684080e7          	jalr	1668(ra) # 80003e2c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800057b0:	4789                	li	a5,2
    800057b2:	02fb1563          	bne	s6,a5,800057dc <create+0x88>
    800057b6:	044ad783          	lhu	a5,68(s5)
    800057ba:	37f9                	addw	a5,a5,-2
    800057bc:	17c2                	sll	a5,a5,0x30
    800057be:	93c1                	srl	a5,a5,0x30
    800057c0:	4705                	li	a4,1
    800057c2:	00f76d63          	bltu	a4,a5,800057dc <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800057c6:	8556                	mv	a0,s5
    800057c8:	60a6                	ld	ra,72(sp)
    800057ca:	6406                	ld	s0,64(sp)
    800057cc:	74e2                	ld	s1,56(sp)
    800057ce:	7942                	ld	s2,48(sp)
    800057d0:	79a2                	ld	s3,40(sp)
    800057d2:	7a02                	ld	s4,32(sp)
    800057d4:	6ae2                	ld	s5,24(sp)
    800057d6:	6b42                	ld	s6,16(sp)
    800057d8:	6161                	add	sp,sp,80
    800057da:	8082                	ret
    iunlockput(ip);
    800057dc:	8556                	mv	a0,s5
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	8b0080e7          	jalr	-1872(ra) # 8000408e <iunlockput>
    return 0;
    800057e6:	4a81                	li	s5,0
    800057e8:	bff9                	j	800057c6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    800057ea:	85da                	mv	a1,s6
    800057ec:	4088                	lw	a0,0(s1)
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	4a6080e7          	jalr	1190(ra) # 80003c94 <ialloc>
    800057f6:	8a2a                	mv	s4,a0
    800057f8:	c529                	beqz	a0,80005842 <create+0xee>
  ilock(ip);
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	632080e7          	jalr	1586(ra) # 80003e2c <ilock>
  ip->major = major;
    80005802:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005806:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000580a:	4905                	li	s2,1
    8000580c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005810:	8552                	mv	a0,s4
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	54e080e7          	jalr	1358(ra) # 80003d60 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000581a:	032b0b63          	beq	s6,s2,80005850 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000581e:	004a2603          	lw	a2,4(s4)
    80005822:	fb040593          	add	a1,s0,-80
    80005826:	8526                	mv	a0,s1
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	cf8080e7          	jalr	-776(ra) # 80004520 <dirlink>
    80005830:	06054f63          	bltz	a0,800058ae <create+0x15a>
  iunlockput(dp);
    80005834:	8526                	mv	a0,s1
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	858080e7          	jalr	-1960(ra) # 8000408e <iunlockput>
  return ip;
    8000583e:	8ad2                	mv	s5,s4
    80005840:	b759                	j	800057c6 <create+0x72>
    iunlockput(dp);
    80005842:	8526                	mv	a0,s1
    80005844:	fffff097          	auipc	ra,0xfffff
    80005848:	84a080e7          	jalr	-1974(ra) # 8000408e <iunlockput>
    return 0;
    8000584c:	8ad2                	mv	s5,s4
    8000584e:	bfa5                	j	800057c6 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005850:	004a2603          	lw	a2,4(s4)
    80005854:	00003597          	auipc	a1,0x3
    80005858:	ebc58593          	add	a1,a1,-324 # 80008710 <syscalls+0x2c0>
    8000585c:	8552                	mv	a0,s4
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	cc2080e7          	jalr	-830(ra) # 80004520 <dirlink>
    80005866:	04054463          	bltz	a0,800058ae <create+0x15a>
    8000586a:	40d0                	lw	a2,4(s1)
    8000586c:	00003597          	auipc	a1,0x3
    80005870:	eac58593          	add	a1,a1,-340 # 80008718 <syscalls+0x2c8>
    80005874:	8552                	mv	a0,s4
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	caa080e7          	jalr	-854(ra) # 80004520 <dirlink>
    8000587e:	02054863          	bltz	a0,800058ae <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005882:	004a2603          	lw	a2,4(s4)
    80005886:	fb040593          	add	a1,s0,-80
    8000588a:	8526                	mv	a0,s1
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	c94080e7          	jalr	-876(ra) # 80004520 <dirlink>
    80005894:	00054d63          	bltz	a0,800058ae <create+0x15a>
    dp->nlink++;  // for ".."
    80005898:	04a4d783          	lhu	a5,74(s1)
    8000589c:	2785                	addw	a5,a5,1
    8000589e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058a2:	8526                	mv	a0,s1
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	4bc080e7          	jalr	1212(ra) # 80003d60 <iupdate>
    800058ac:	b761                	j	80005834 <create+0xe0>
  ip->nlink = 0;
    800058ae:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800058b2:	8552                	mv	a0,s4
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	4ac080e7          	jalr	1196(ra) # 80003d60 <iupdate>
  iunlockput(ip);
    800058bc:	8552                	mv	a0,s4
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	7d0080e7          	jalr	2000(ra) # 8000408e <iunlockput>
  iunlockput(dp);
    800058c6:	8526                	mv	a0,s1
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	7c6080e7          	jalr	1990(ra) # 8000408e <iunlockput>
  return 0;
    800058d0:	bddd                	j	800057c6 <create+0x72>
    return 0;
    800058d2:	8aaa                	mv	s5,a0
    800058d4:	bdcd                	j	800057c6 <create+0x72>

00000000800058d6 <sys_dup>:
{
    800058d6:	7179                	add	sp,sp,-48
    800058d8:	f406                	sd	ra,40(sp)
    800058da:	f022                	sd	s0,32(sp)
    800058dc:	ec26                	sd	s1,24(sp)
    800058de:	e84a                	sd	s2,16(sp)
    800058e0:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800058e2:	fd840613          	add	a2,s0,-40
    800058e6:	4581                	li	a1,0
    800058e8:	4501                	li	a0,0
    800058ea:	00000097          	auipc	ra,0x0
    800058ee:	dc8080e7          	jalr	-568(ra) # 800056b2 <argfd>
    return -1;
    800058f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800058f4:	02054363          	bltz	a0,8000591a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800058f8:	fd843903          	ld	s2,-40(s0)
    800058fc:	854a                	mv	a0,s2
    800058fe:	00000097          	auipc	ra,0x0
    80005902:	e14080e7          	jalr	-492(ra) # 80005712 <fdalloc>
    80005906:	84aa                	mv	s1,a0
    return -1;
    80005908:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000590a:	00054863          	bltz	a0,8000591a <sys_dup+0x44>
  filedup(f);
    8000590e:	854a                	mv	a0,s2
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	334080e7          	jalr	820(ra) # 80004c44 <filedup>
  return fd;
    80005918:	87a6                	mv	a5,s1
}
    8000591a:	853e                	mv	a0,a5
    8000591c:	70a2                	ld	ra,40(sp)
    8000591e:	7402                	ld	s0,32(sp)
    80005920:	64e2                	ld	s1,24(sp)
    80005922:	6942                	ld	s2,16(sp)
    80005924:	6145                	add	sp,sp,48
    80005926:	8082                	ret

0000000080005928 <sys_read>:
{
    80005928:	7179                	add	sp,sp,-48
    8000592a:	f406                	sd	ra,40(sp)
    8000592c:	f022                	sd	s0,32(sp)
    8000592e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005930:	fd840593          	add	a1,s0,-40
    80005934:	4505                	li	a0,1
    80005936:	ffffd097          	auipc	ra,0xffffd
    8000593a:	7e0080e7          	jalr	2016(ra) # 80003116 <argaddr>
  argint(2, &n);
    8000593e:	fe440593          	add	a1,s0,-28
    80005942:	4509                	li	a0,2
    80005944:	ffffd097          	auipc	ra,0xffffd
    80005948:	7b2080e7          	jalr	1970(ra) # 800030f6 <argint>
  if(argfd(0, 0, &f) < 0)
    8000594c:	fe840613          	add	a2,s0,-24
    80005950:	4581                	li	a1,0
    80005952:	4501                	li	a0,0
    80005954:	00000097          	auipc	ra,0x0
    80005958:	d5e080e7          	jalr	-674(ra) # 800056b2 <argfd>
    8000595c:	87aa                	mv	a5,a0
    return -1;
    8000595e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005960:	0007cc63          	bltz	a5,80005978 <sys_read+0x50>
  return fileread(f, p, n);
    80005964:	fe442603          	lw	a2,-28(s0)
    80005968:	fd843583          	ld	a1,-40(s0)
    8000596c:	fe843503          	ld	a0,-24(s0)
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	460080e7          	jalr	1120(ra) # 80004dd0 <fileread>
}
    80005978:	70a2                	ld	ra,40(sp)
    8000597a:	7402                	ld	s0,32(sp)
    8000597c:	6145                	add	sp,sp,48
    8000597e:	8082                	ret

0000000080005980 <sys_write>:
{
    80005980:	7179                	add	sp,sp,-48
    80005982:	f406                	sd	ra,40(sp)
    80005984:	f022                	sd	s0,32(sp)
    80005986:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005988:	fd840593          	add	a1,s0,-40
    8000598c:	4505                	li	a0,1
    8000598e:	ffffd097          	auipc	ra,0xffffd
    80005992:	788080e7          	jalr	1928(ra) # 80003116 <argaddr>
  argint(2, &n);
    80005996:	fe440593          	add	a1,s0,-28
    8000599a:	4509                	li	a0,2
    8000599c:	ffffd097          	auipc	ra,0xffffd
    800059a0:	75a080e7          	jalr	1882(ra) # 800030f6 <argint>
  if(argfd(0, 0, &f) < 0)
    800059a4:	fe840613          	add	a2,s0,-24
    800059a8:	4581                	li	a1,0
    800059aa:	4501                	li	a0,0
    800059ac:	00000097          	auipc	ra,0x0
    800059b0:	d06080e7          	jalr	-762(ra) # 800056b2 <argfd>
    800059b4:	87aa                	mv	a5,a0
    return -1;
    800059b6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059b8:	0007cc63          	bltz	a5,800059d0 <sys_write+0x50>
  return filewrite(f, p, n);
    800059bc:	fe442603          	lw	a2,-28(s0)
    800059c0:	fd843583          	ld	a1,-40(s0)
    800059c4:	fe843503          	ld	a0,-24(s0)
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	4ca080e7          	jalr	1226(ra) # 80004e92 <filewrite>
}
    800059d0:	70a2                	ld	ra,40(sp)
    800059d2:	7402                	ld	s0,32(sp)
    800059d4:	6145                	add	sp,sp,48
    800059d6:	8082                	ret

00000000800059d8 <sys_close>:
{
    800059d8:	1101                	add	sp,sp,-32
    800059da:	ec06                	sd	ra,24(sp)
    800059dc:	e822                	sd	s0,16(sp)
    800059de:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800059e0:	fe040613          	add	a2,s0,-32
    800059e4:	fec40593          	add	a1,s0,-20
    800059e8:	4501                	li	a0,0
    800059ea:	00000097          	auipc	ra,0x0
    800059ee:	cc8080e7          	jalr	-824(ra) # 800056b2 <argfd>
    return -1;
    800059f2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800059f4:	02054563          	bltz	a0,80005a1e <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    800059f8:	ffffc097          	auipc	ra,0xffffc
    800059fc:	fae080e7          	jalr	-82(ra) # 800019a6 <myproc>
    80005a00:	fec42783          	lw	a5,-20(s0)
    80005a04:	02078793          	add	a5,a5,32
    80005a08:	078e                	sll	a5,a5,0x3
    80005a0a:	953e                	add	a0,a0,a5
    80005a0c:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005a10:	fe043503          	ld	a0,-32(s0)
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	282080e7          	jalr	642(ra) # 80004c96 <fileclose>
  return 0;
    80005a1c:	4781                	li	a5,0
}
    80005a1e:	853e                	mv	a0,a5
    80005a20:	60e2                	ld	ra,24(sp)
    80005a22:	6442                	ld	s0,16(sp)
    80005a24:	6105                	add	sp,sp,32
    80005a26:	8082                	ret

0000000080005a28 <sys_fstat>:
{
    80005a28:	1101                	add	sp,sp,-32
    80005a2a:	ec06                	sd	ra,24(sp)
    80005a2c:	e822                	sd	s0,16(sp)
    80005a2e:	1000                	add	s0,sp,32
  argaddr(1, &st);
    80005a30:	fe040593          	add	a1,s0,-32
    80005a34:	4505                	li	a0,1
    80005a36:	ffffd097          	auipc	ra,0xffffd
    80005a3a:	6e0080e7          	jalr	1760(ra) # 80003116 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a3e:	fe840613          	add	a2,s0,-24
    80005a42:	4581                	li	a1,0
    80005a44:	4501                	li	a0,0
    80005a46:	00000097          	auipc	ra,0x0
    80005a4a:	c6c080e7          	jalr	-916(ra) # 800056b2 <argfd>
    80005a4e:	87aa                	mv	a5,a0
    return -1;
    80005a50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a52:	0007ca63          	bltz	a5,80005a66 <sys_fstat+0x3e>
  return filestat(f, st);
    80005a56:	fe043583          	ld	a1,-32(s0)
    80005a5a:	fe843503          	ld	a0,-24(s0)
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	300080e7          	jalr	768(ra) # 80004d5e <filestat>
}
    80005a66:	60e2                	ld	ra,24(sp)
    80005a68:	6442                	ld	s0,16(sp)
    80005a6a:	6105                	add	sp,sp,32
    80005a6c:	8082                	ret

0000000080005a6e <sys_link>:
{
    80005a6e:	7169                	add	sp,sp,-304
    80005a70:	f606                	sd	ra,296(sp)
    80005a72:	f222                	sd	s0,288(sp)
    80005a74:	ee26                	sd	s1,280(sp)
    80005a76:	ea4a                	sd	s2,272(sp)
    80005a78:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a7a:	08000613          	li	a2,128
    80005a7e:	ed040593          	add	a1,s0,-304
    80005a82:	4501                	li	a0,0
    80005a84:	ffffd097          	auipc	ra,0xffffd
    80005a88:	6b2080e7          	jalr	1714(ra) # 80003136 <argstr>
    return -1;
    80005a8c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a8e:	10054e63          	bltz	a0,80005baa <sys_link+0x13c>
    80005a92:	08000613          	li	a2,128
    80005a96:	f5040593          	add	a1,s0,-176
    80005a9a:	4505                	li	a0,1
    80005a9c:	ffffd097          	auipc	ra,0xffffd
    80005aa0:	69a080e7          	jalr	1690(ra) # 80003136 <argstr>
    return -1;
    80005aa4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005aa6:	10054263          	bltz	a0,80005baa <sys_link+0x13c>
  begin_op();
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	d28080e7          	jalr	-728(ra) # 800047d2 <begin_op>
  if((ip = namei(old)) == 0){
    80005ab2:	ed040513          	add	a0,s0,-304
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	b1c080e7          	jalr	-1252(ra) # 800045d2 <namei>
    80005abe:	84aa                	mv	s1,a0
    80005ac0:	c551                	beqz	a0,80005b4c <sys_link+0xde>
  ilock(ip);
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	36a080e7          	jalr	874(ra) # 80003e2c <ilock>
  if(ip->type == T_DIR){
    80005aca:	04449703          	lh	a4,68(s1)
    80005ace:	4785                	li	a5,1
    80005ad0:	08f70463          	beq	a4,a5,80005b58 <sys_link+0xea>
  ip->nlink++;
    80005ad4:	04a4d783          	lhu	a5,74(s1)
    80005ad8:	2785                	addw	a5,a5,1
    80005ada:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ade:	8526                	mv	a0,s1
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	280080e7          	jalr	640(ra) # 80003d60 <iupdate>
  iunlock(ip);
    80005ae8:	8526                	mv	a0,s1
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	404080e7          	jalr	1028(ra) # 80003eee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005af2:	fd040593          	add	a1,s0,-48
    80005af6:	f5040513          	add	a0,s0,-176
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	af6080e7          	jalr	-1290(ra) # 800045f0 <nameiparent>
    80005b02:	892a                	mv	s2,a0
    80005b04:	c935                	beqz	a0,80005b78 <sys_link+0x10a>
  ilock(dp);
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	326080e7          	jalr	806(ra) # 80003e2c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b0e:	00092703          	lw	a4,0(s2)
    80005b12:	409c                	lw	a5,0(s1)
    80005b14:	04f71d63          	bne	a4,a5,80005b6e <sys_link+0x100>
    80005b18:	40d0                	lw	a2,4(s1)
    80005b1a:	fd040593          	add	a1,s0,-48
    80005b1e:	854a                	mv	a0,s2
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	a00080e7          	jalr	-1536(ra) # 80004520 <dirlink>
    80005b28:	04054363          	bltz	a0,80005b6e <sys_link+0x100>
  iunlockput(dp);
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	560080e7          	jalr	1376(ra) # 8000408e <iunlockput>
  iput(ip);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	4ae080e7          	jalr	1198(ra) # 80003fe6 <iput>
  end_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	d0c080e7          	jalr	-756(ra) # 8000484c <end_op>
  return 0;
    80005b48:	4781                	li	a5,0
    80005b4a:	a085                	j	80005baa <sys_link+0x13c>
    end_op();
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	d00080e7          	jalr	-768(ra) # 8000484c <end_op>
    return -1;
    80005b54:	57fd                	li	a5,-1
    80005b56:	a891                	j	80005baa <sys_link+0x13c>
    iunlockput(ip);
    80005b58:	8526                	mv	a0,s1
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	534080e7          	jalr	1332(ra) # 8000408e <iunlockput>
    end_op();
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	cea080e7          	jalr	-790(ra) # 8000484c <end_op>
    return -1;
    80005b6a:	57fd                	li	a5,-1
    80005b6c:	a83d                	j	80005baa <sys_link+0x13c>
    iunlockput(dp);
    80005b6e:	854a                	mv	a0,s2
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	51e080e7          	jalr	1310(ra) # 8000408e <iunlockput>
  ilock(ip);
    80005b78:	8526                	mv	a0,s1
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	2b2080e7          	jalr	690(ra) # 80003e2c <ilock>
  ip->nlink--;
    80005b82:	04a4d783          	lhu	a5,74(s1)
    80005b86:	37fd                	addw	a5,a5,-1
    80005b88:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	1d2080e7          	jalr	466(ra) # 80003d60 <iupdate>
  iunlockput(ip);
    80005b96:	8526                	mv	a0,s1
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	4f6080e7          	jalr	1270(ra) # 8000408e <iunlockput>
  end_op();
    80005ba0:	fffff097          	auipc	ra,0xfffff
    80005ba4:	cac080e7          	jalr	-852(ra) # 8000484c <end_op>
  return -1;
    80005ba8:	57fd                	li	a5,-1
}
    80005baa:	853e                	mv	a0,a5
    80005bac:	70b2                	ld	ra,296(sp)
    80005bae:	7412                	ld	s0,288(sp)
    80005bb0:	64f2                	ld	s1,280(sp)
    80005bb2:	6952                	ld	s2,272(sp)
    80005bb4:	6155                	add	sp,sp,304
    80005bb6:	8082                	ret

0000000080005bb8 <sys_unlink>:
{
    80005bb8:	7151                	add	sp,sp,-240
    80005bba:	f586                	sd	ra,232(sp)
    80005bbc:	f1a2                	sd	s0,224(sp)
    80005bbe:	eda6                	sd	s1,216(sp)
    80005bc0:	e9ca                	sd	s2,208(sp)
    80005bc2:	e5ce                	sd	s3,200(sp)
    80005bc4:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005bc6:	08000613          	li	a2,128
    80005bca:	f3040593          	add	a1,s0,-208
    80005bce:	4501                	li	a0,0
    80005bd0:	ffffd097          	auipc	ra,0xffffd
    80005bd4:	566080e7          	jalr	1382(ra) # 80003136 <argstr>
    80005bd8:	18054163          	bltz	a0,80005d5a <sys_unlink+0x1a2>
  begin_op();
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	bf6080e7          	jalr	-1034(ra) # 800047d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005be4:	fb040593          	add	a1,s0,-80
    80005be8:	f3040513          	add	a0,s0,-208
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	a04080e7          	jalr	-1532(ra) # 800045f0 <nameiparent>
    80005bf4:	84aa                	mv	s1,a0
    80005bf6:	c979                	beqz	a0,80005ccc <sys_unlink+0x114>
  ilock(dp);
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	234080e7          	jalr	564(ra) # 80003e2c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c00:	00003597          	auipc	a1,0x3
    80005c04:	b1058593          	add	a1,a1,-1264 # 80008710 <syscalls+0x2c0>
    80005c08:	fb040513          	add	a0,s0,-80
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	6ea080e7          	jalr	1770(ra) # 800042f6 <namecmp>
    80005c14:	14050a63          	beqz	a0,80005d68 <sys_unlink+0x1b0>
    80005c18:	00003597          	auipc	a1,0x3
    80005c1c:	b0058593          	add	a1,a1,-1280 # 80008718 <syscalls+0x2c8>
    80005c20:	fb040513          	add	a0,s0,-80
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	6d2080e7          	jalr	1746(ra) # 800042f6 <namecmp>
    80005c2c:	12050e63          	beqz	a0,80005d68 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c30:	f2c40613          	add	a2,s0,-212
    80005c34:	fb040593          	add	a1,s0,-80
    80005c38:	8526                	mv	a0,s1
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	6d6080e7          	jalr	1750(ra) # 80004310 <dirlookup>
    80005c42:	892a                	mv	s2,a0
    80005c44:	12050263          	beqz	a0,80005d68 <sys_unlink+0x1b0>
  ilock(ip);
    80005c48:	ffffe097          	auipc	ra,0xffffe
    80005c4c:	1e4080e7          	jalr	484(ra) # 80003e2c <ilock>
  if(ip->nlink < 1)
    80005c50:	04a91783          	lh	a5,74(s2)
    80005c54:	08f05263          	blez	a5,80005cd8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c58:	04491703          	lh	a4,68(s2)
    80005c5c:	4785                	li	a5,1
    80005c5e:	08f70563          	beq	a4,a5,80005ce8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005c62:	4641                	li	a2,16
    80005c64:	4581                	li	a1,0
    80005c66:	fc040513          	add	a0,s0,-64
    80005c6a:	ffffb097          	auipc	ra,0xffffb
    80005c6e:	064080e7          	jalr	100(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c72:	4741                	li	a4,16
    80005c74:	f2c42683          	lw	a3,-212(s0)
    80005c78:	fc040613          	add	a2,s0,-64
    80005c7c:	4581                	li	a1,0
    80005c7e:	8526                	mv	a0,s1
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	558080e7          	jalr	1368(ra) # 800041d8 <writei>
    80005c88:	47c1                	li	a5,16
    80005c8a:	0af51563          	bne	a0,a5,80005d34 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c8e:	04491703          	lh	a4,68(s2)
    80005c92:	4785                	li	a5,1
    80005c94:	0af70863          	beq	a4,a5,80005d44 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c98:	8526                	mv	a0,s1
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	3f4080e7          	jalr	1012(ra) # 8000408e <iunlockput>
  ip->nlink--;
    80005ca2:	04a95783          	lhu	a5,74(s2)
    80005ca6:	37fd                	addw	a5,a5,-1
    80005ca8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005cac:	854a                	mv	a0,s2
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	0b2080e7          	jalr	178(ra) # 80003d60 <iupdate>
  iunlockput(ip);
    80005cb6:	854a                	mv	a0,s2
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	3d6080e7          	jalr	982(ra) # 8000408e <iunlockput>
  end_op();
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	b8c080e7          	jalr	-1140(ra) # 8000484c <end_op>
  return 0;
    80005cc8:	4501                	li	a0,0
    80005cca:	a84d                	j	80005d7c <sys_unlink+0x1c4>
    end_op();
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	b80080e7          	jalr	-1152(ra) # 8000484c <end_op>
    return -1;
    80005cd4:	557d                	li	a0,-1
    80005cd6:	a05d                	j	80005d7c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	a4850513          	add	a0,a0,-1464 # 80008720 <syscalls+0x2d0>
    80005ce0:	ffffb097          	auipc	ra,0xffffb
    80005ce4:	85c080e7          	jalr	-1956(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ce8:	04c92703          	lw	a4,76(s2)
    80005cec:	02000793          	li	a5,32
    80005cf0:	f6e7f9e3          	bgeu	a5,a4,80005c62 <sys_unlink+0xaa>
    80005cf4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cf8:	4741                	li	a4,16
    80005cfa:	86ce                	mv	a3,s3
    80005cfc:	f1840613          	add	a2,s0,-232
    80005d00:	4581                	li	a1,0
    80005d02:	854a                	mv	a0,s2
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	3dc080e7          	jalr	988(ra) # 800040e0 <readi>
    80005d0c:	47c1                	li	a5,16
    80005d0e:	00f51b63          	bne	a0,a5,80005d24 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005d12:	f1845783          	lhu	a5,-232(s0)
    80005d16:	e7a1                	bnez	a5,80005d5e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d18:	29c1                	addw	s3,s3,16
    80005d1a:	04c92783          	lw	a5,76(s2)
    80005d1e:	fcf9ede3          	bltu	s3,a5,80005cf8 <sys_unlink+0x140>
    80005d22:	b781                	j	80005c62 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005d24:	00003517          	auipc	a0,0x3
    80005d28:	a1450513          	add	a0,a0,-1516 # 80008738 <syscalls+0x2e8>
    80005d2c:	ffffb097          	auipc	ra,0xffffb
    80005d30:	810080e7          	jalr	-2032(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005d34:	00003517          	auipc	a0,0x3
    80005d38:	a1c50513          	add	a0,a0,-1508 # 80008750 <syscalls+0x300>
    80005d3c:	ffffb097          	auipc	ra,0xffffb
    80005d40:	800080e7          	jalr	-2048(ra) # 8000053c <panic>
    dp->nlink--;
    80005d44:	04a4d783          	lhu	a5,74(s1)
    80005d48:	37fd                	addw	a5,a5,-1
    80005d4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d4e:	8526                	mv	a0,s1
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	010080e7          	jalr	16(ra) # 80003d60 <iupdate>
    80005d58:	b781                	j	80005c98 <sys_unlink+0xe0>
    return -1;
    80005d5a:	557d                	li	a0,-1
    80005d5c:	a005                	j	80005d7c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005d5e:	854a                	mv	a0,s2
    80005d60:	ffffe097          	auipc	ra,0xffffe
    80005d64:	32e080e7          	jalr	814(ra) # 8000408e <iunlockput>
  iunlockput(dp);
    80005d68:	8526                	mv	a0,s1
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	324080e7          	jalr	804(ra) # 8000408e <iunlockput>
  end_op();
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	ada080e7          	jalr	-1318(ra) # 8000484c <end_op>
  return -1;
    80005d7a:	557d                	li	a0,-1
}
    80005d7c:	70ae                	ld	ra,232(sp)
    80005d7e:	740e                	ld	s0,224(sp)
    80005d80:	64ee                	ld	s1,216(sp)
    80005d82:	694e                	ld	s2,208(sp)
    80005d84:	69ae                	ld	s3,200(sp)
    80005d86:	616d                	add	sp,sp,240
    80005d88:	8082                	ret

0000000080005d8a <sys_open>:

uint64
sys_open(void)
{
    80005d8a:	7131                	add	sp,sp,-192
    80005d8c:	fd06                	sd	ra,184(sp)
    80005d8e:	f922                	sd	s0,176(sp)
    80005d90:	f526                	sd	s1,168(sp)
    80005d92:	f14a                	sd	s2,160(sp)
    80005d94:	ed4e                	sd	s3,152(sp)
    80005d96:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d98:	f4c40593          	add	a1,s0,-180
    80005d9c:	4505                	li	a0,1
    80005d9e:	ffffd097          	auipc	ra,0xffffd
    80005da2:	358080e7          	jalr	856(ra) # 800030f6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005da6:	08000613          	li	a2,128
    80005daa:	f5040593          	add	a1,s0,-176
    80005dae:	4501                	li	a0,0
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	386080e7          	jalr	902(ra) # 80003136 <argstr>
    80005db8:	87aa                	mv	a5,a0
    return -1;
    80005dba:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005dbc:	0a07c863          	bltz	a5,80005e6c <sys_open+0xe2>

  begin_op();
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	a12080e7          	jalr	-1518(ra) # 800047d2 <begin_op>

  if(omode & O_CREATE){
    80005dc8:	f4c42783          	lw	a5,-180(s0)
    80005dcc:	2007f793          	and	a5,a5,512
    80005dd0:	cbdd                	beqz	a5,80005e86 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005dd2:	4681                	li	a3,0
    80005dd4:	4601                	li	a2,0
    80005dd6:	4589                	li	a1,2
    80005dd8:	f5040513          	add	a0,s0,-176
    80005ddc:	00000097          	auipc	ra,0x0
    80005de0:	978080e7          	jalr	-1672(ra) # 80005754 <create>
    80005de4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005de6:	c951                	beqz	a0,80005e7a <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005de8:	04449703          	lh	a4,68(s1)
    80005dec:	478d                	li	a5,3
    80005dee:	00f71763          	bne	a4,a5,80005dfc <sys_open+0x72>
    80005df2:	0464d703          	lhu	a4,70(s1)
    80005df6:	47a5                	li	a5,9
    80005df8:	0ce7ec63          	bltu	a5,a4,80005ed0 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005dfc:	fffff097          	auipc	ra,0xfffff
    80005e00:	dde080e7          	jalr	-546(ra) # 80004bda <filealloc>
    80005e04:	892a                	mv	s2,a0
    80005e06:	c56d                	beqz	a0,80005ef0 <sys_open+0x166>
    80005e08:	00000097          	auipc	ra,0x0
    80005e0c:	90a080e7          	jalr	-1782(ra) # 80005712 <fdalloc>
    80005e10:	89aa                	mv	s3,a0
    80005e12:	0c054a63          	bltz	a0,80005ee6 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e16:	04449703          	lh	a4,68(s1)
    80005e1a:	478d                	li	a5,3
    80005e1c:	0ef70563          	beq	a4,a5,80005f06 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e20:	4789                	li	a5,2
    80005e22:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005e26:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005e2a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005e2e:	f4c42783          	lw	a5,-180(s0)
    80005e32:	0017c713          	xor	a4,a5,1
    80005e36:	8b05                	and	a4,a4,1
    80005e38:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e3c:	0037f713          	and	a4,a5,3
    80005e40:	00e03733          	snez	a4,a4
    80005e44:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e48:	4007f793          	and	a5,a5,1024
    80005e4c:	c791                	beqz	a5,80005e58 <sys_open+0xce>
    80005e4e:	04449703          	lh	a4,68(s1)
    80005e52:	4789                	li	a5,2
    80005e54:	0cf70063          	beq	a4,a5,80005f14 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005e58:	8526                	mv	a0,s1
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	094080e7          	jalr	148(ra) # 80003eee <iunlock>
  end_op();
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	9ea080e7          	jalr	-1558(ra) # 8000484c <end_op>

  return fd;
    80005e6a:	854e                	mv	a0,s3
}
    80005e6c:	70ea                	ld	ra,184(sp)
    80005e6e:	744a                	ld	s0,176(sp)
    80005e70:	74aa                	ld	s1,168(sp)
    80005e72:	790a                	ld	s2,160(sp)
    80005e74:	69ea                	ld	s3,152(sp)
    80005e76:	6129                	add	sp,sp,192
    80005e78:	8082                	ret
      end_op();
    80005e7a:	fffff097          	auipc	ra,0xfffff
    80005e7e:	9d2080e7          	jalr	-1582(ra) # 8000484c <end_op>
      return -1;
    80005e82:	557d                	li	a0,-1
    80005e84:	b7e5                	j	80005e6c <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005e86:	f5040513          	add	a0,s0,-176
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	748080e7          	jalr	1864(ra) # 800045d2 <namei>
    80005e92:	84aa                	mv	s1,a0
    80005e94:	c905                	beqz	a0,80005ec4 <sys_open+0x13a>
    ilock(ip);
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	f96080e7          	jalr	-106(ra) # 80003e2c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e9e:	04449703          	lh	a4,68(s1)
    80005ea2:	4785                	li	a5,1
    80005ea4:	f4f712e3          	bne	a4,a5,80005de8 <sys_open+0x5e>
    80005ea8:	f4c42783          	lw	a5,-180(s0)
    80005eac:	dba1                	beqz	a5,80005dfc <sys_open+0x72>
      iunlockput(ip);
    80005eae:	8526                	mv	a0,s1
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	1de080e7          	jalr	478(ra) # 8000408e <iunlockput>
      end_op();
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	994080e7          	jalr	-1644(ra) # 8000484c <end_op>
      return -1;
    80005ec0:	557d                	li	a0,-1
    80005ec2:	b76d                	j	80005e6c <sys_open+0xe2>
      end_op();
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	988080e7          	jalr	-1656(ra) # 8000484c <end_op>
      return -1;
    80005ecc:	557d                	li	a0,-1
    80005ece:	bf79                	j	80005e6c <sys_open+0xe2>
    iunlockput(ip);
    80005ed0:	8526                	mv	a0,s1
    80005ed2:	ffffe097          	auipc	ra,0xffffe
    80005ed6:	1bc080e7          	jalr	444(ra) # 8000408e <iunlockput>
    end_op();
    80005eda:	fffff097          	auipc	ra,0xfffff
    80005ede:	972080e7          	jalr	-1678(ra) # 8000484c <end_op>
    return -1;
    80005ee2:	557d                	li	a0,-1
    80005ee4:	b761                	j	80005e6c <sys_open+0xe2>
      fileclose(f);
    80005ee6:	854a                	mv	a0,s2
    80005ee8:	fffff097          	auipc	ra,0xfffff
    80005eec:	dae080e7          	jalr	-594(ra) # 80004c96 <fileclose>
    iunlockput(ip);
    80005ef0:	8526                	mv	a0,s1
    80005ef2:	ffffe097          	auipc	ra,0xffffe
    80005ef6:	19c080e7          	jalr	412(ra) # 8000408e <iunlockput>
    end_op();
    80005efa:	fffff097          	auipc	ra,0xfffff
    80005efe:	952080e7          	jalr	-1710(ra) # 8000484c <end_op>
    return -1;
    80005f02:	557d                	li	a0,-1
    80005f04:	b7a5                	j	80005e6c <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005f06:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005f0a:	04649783          	lh	a5,70(s1)
    80005f0e:	02f91223          	sh	a5,36(s2)
    80005f12:	bf21                	j	80005e2a <sys_open+0xa0>
    itrunc(ip);
    80005f14:	8526                	mv	a0,s1
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	024080e7          	jalr	36(ra) # 80003f3a <itrunc>
    80005f1e:	bf2d                	j	80005e58 <sys_open+0xce>

0000000080005f20 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f20:	7175                	add	sp,sp,-144
    80005f22:	e506                	sd	ra,136(sp)
    80005f24:	e122                	sd	s0,128(sp)
    80005f26:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f28:	fffff097          	auipc	ra,0xfffff
    80005f2c:	8aa080e7          	jalr	-1878(ra) # 800047d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f30:	08000613          	li	a2,128
    80005f34:	f7040593          	add	a1,s0,-144
    80005f38:	4501                	li	a0,0
    80005f3a:	ffffd097          	auipc	ra,0xffffd
    80005f3e:	1fc080e7          	jalr	508(ra) # 80003136 <argstr>
    80005f42:	02054963          	bltz	a0,80005f74 <sys_mkdir+0x54>
    80005f46:	4681                	li	a3,0
    80005f48:	4601                	li	a2,0
    80005f4a:	4585                	li	a1,1
    80005f4c:	f7040513          	add	a0,s0,-144
    80005f50:	00000097          	auipc	ra,0x0
    80005f54:	804080e7          	jalr	-2044(ra) # 80005754 <create>
    80005f58:	cd11                	beqz	a0,80005f74 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	134080e7          	jalr	308(ra) # 8000408e <iunlockput>
  end_op();
    80005f62:	fffff097          	auipc	ra,0xfffff
    80005f66:	8ea080e7          	jalr	-1814(ra) # 8000484c <end_op>
  return 0;
    80005f6a:	4501                	li	a0,0
}
    80005f6c:	60aa                	ld	ra,136(sp)
    80005f6e:	640a                	ld	s0,128(sp)
    80005f70:	6149                	add	sp,sp,144
    80005f72:	8082                	ret
    end_op();
    80005f74:	fffff097          	auipc	ra,0xfffff
    80005f78:	8d8080e7          	jalr	-1832(ra) # 8000484c <end_op>
    return -1;
    80005f7c:	557d                	li	a0,-1
    80005f7e:	b7fd                	j	80005f6c <sys_mkdir+0x4c>

0000000080005f80 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f80:	7135                	add	sp,sp,-160
    80005f82:	ed06                	sd	ra,152(sp)
    80005f84:	e922                	sd	s0,144(sp)
    80005f86:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f88:	fffff097          	auipc	ra,0xfffff
    80005f8c:	84a080e7          	jalr	-1974(ra) # 800047d2 <begin_op>
  argint(1, &major);
    80005f90:	f6c40593          	add	a1,s0,-148
    80005f94:	4505                	li	a0,1
    80005f96:	ffffd097          	auipc	ra,0xffffd
    80005f9a:	160080e7          	jalr	352(ra) # 800030f6 <argint>
  argint(2, &minor);
    80005f9e:	f6840593          	add	a1,s0,-152
    80005fa2:	4509                	li	a0,2
    80005fa4:	ffffd097          	auipc	ra,0xffffd
    80005fa8:	152080e7          	jalr	338(ra) # 800030f6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fac:	08000613          	li	a2,128
    80005fb0:	f7040593          	add	a1,s0,-144
    80005fb4:	4501                	li	a0,0
    80005fb6:	ffffd097          	auipc	ra,0xffffd
    80005fba:	180080e7          	jalr	384(ra) # 80003136 <argstr>
    80005fbe:	02054b63          	bltz	a0,80005ff4 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005fc2:	f6841683          	lh	a3,-152(s0)
    80005fc6:	f6c41603          	lh	a2,-148(s0)
    80005fca:	458d                	li	a1,3
    80005fcc:	f7040513          	add	a0,s0,-144
    80005fd0:	fffff097          	auipc	ra,0xfffff
    80005fd4:	784080e7          	jalr	1924(ra) # 80005754 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fd8:	cd11                	beqz	a0,80005ff4 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fda:	ffffe097          	auipc	ra,0xffffe
    80005fde:	0b4080e7          	jalr	180(ra) # 8000408e <iunlockput>
  end_op();
    80005fe2:	fffff097          	auipc	ra,0xfffff
    80005fe6:	86a080e7          	jalr	-1942(ra) # 8000484c <end_op>
  return 0;
    80005fea:	4501                	li	a0,0
}
    80005fec:	60ea                	ld	ra,152(sp)
    80005fee:	644a                	ld	s0,144(sp)
    80005ff0:	610d                	add	sp,sp,160
    80005ff2:	8082                	ret
    end_op();
    80005ff4:	fffff097          	auipc	ra,0xfffff
    80005ff8:	858080e7          	jalr	-1960(ra) # 8000484c <end_op>
    return -1;
    80005ffc:	557d                	li	a0,-1
    80005ffe:	b7fd                	j	80005fec <sys_mknod+0x6c>

0000000080006000 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006000:	7135                	add	sp,sp,-160
    80006002:	ed06                	sd	ra,152(sp)
    80006004:	e922                	sd	s0,144(sp)
    80006006:	e526                	sd	s1,136(sp)
    80006008:	e14a                	sd	s2,128(sp)
    8000600a:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000600c:	ffffc097          	auipc	ra,0xffffc
    80006010:	99a080e7          	jalr	-1638(ra) # 800019a6 <myproc>
    80006014:	892a                	mv	s2,a0
  
  begin_op();
    80006016:	ffffe097          	auipc	ra,0xffffe
    8000601a:	7bc080e7          	jalr	1980(ra) # 800047d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000601e:	08000613          	li	a2,128
    80006022:	f6040593          	add	a1,s0,-160
    80006026:	4501                	li	a0,0
    80006028:	ffffd097          	auipc	ra,0xffffd
    8000602c:	10e080e7          	jalr	270(ra) # 80003136 <argstr>
    80006030:	04054b63          	bltz	a0,80006086 <sys_chdir+0x86>
    80006034:	f6040513          	add	a0,s0,-160
    80006038:	ffffe097          	auipc	ra,0xffffe
    8000603c:	59a080e7          	jalr	1434(ra) # 800045d2 <namei>
    80006040:	84aa                	mv	s1,a0
    80006042:	c131                	beqz	a0,80006086 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006044:	ffffe097          	auipc	ra,0xffffe
    80006048:	de8080e7          	jalr	-536(ra) # 80003e2c <ilock>
  if(ip->type != T_DIR){
    8000604c:	04449703          	lh	a4,68(s1)
    80006050:	4785                	li	a5,1
    80006052:	04f71063          	bne	a4,a5,80006092 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006056:	8526                	mv	a0,s1
    80006058:	ffffe097          	auipc	ra,0xffffe
    8000605c:	e96080e7          	jalr	-362(ra) # 80003eee <iunlock>
  iput(p->cwd);
    80006060:	18893503          	ld	a0,392(s2)
    80006064:	ffffe097          	auipc	ra,0xffffe
    80006068:	f82080e7          	jalr	-126(ra) # 80003fe6 <iput>
  end_op();
    8000606c:	ffffe097          	auipc	ra,0xffffe
    80006070:	7e0080e7          	jalr	2016(ra) # 8000484c <end_op>
  p->cwd = ip;
    80006074:	18993423          	sd	s1,392(s2)
  return 0;
    80006078:	4501                	li	a0,0
}
    8000607a:	60ea                	ld	ra,152(sp)
    8000607c:	644a                	ld	s0,144(sp)
    8000607e:	64aa                	ld	s1,136(sp)
    80006080:	690a                	ld	s2,128(sp)
    80006082:	610d                	add	sp,sp,160
    80006084:	8082                	ret
    end_op();
    80006086:	ffffe097          	auipc	ra,0xffffe
    8000608a:	7c6080e7          	jalr	1990(ra) # 8000484c <end_op>
    return -1;
    8000608e:	557d                	li	a0,-1
    80006090:	b7ed                	j	8000607a <sys_chdir+0x7a>
    iunlockput(ip);
    80006092:	8526                	mv	a0,s1
    80006094:	ffffe097          	auipc	ra,0xffffe
    80006098:	ffa080e7          	jalr	-6(ra) # 8000408e <iunlockput>
    end_op();
    8000609c:	ffffe097          	auipc	ra,0xffffe
    800060a0:	7b0080e7          	jalr	1968(ra) # 8000484c <end_op>
    return -1;
    800060a4:	557d                	li	a0,-1
    800060a6:	bfd1                	j	8000607a <sys_chdir+0x7a>

00000000800060a8 <sys_exec>:

uint64
sys_exec(void)
{
    800060a8:	7121                	add	sp,sp,-448
    800060aa:	ff06                	sd	ra,440(sp)
    800060ac:	fb22                	sd	s0,432(sp)
    800060ae:	f726                	sd	s1,424(sp)
    800060b0:	f34a                	sd	s2,416(sp)
    800060b2:	ef4e                	sd	s3,408(sp)
    800060b4:	eb52                	sd	s4,400(sp)
    800060b6:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800060b8:	e4840593          	add	a1,s0,-440
    800060bc:	4505                	li	a0,1
    800060be:	ffffd097          	auipc	ra,0xffffd
    800060c2:	058080e7          	jalr	88(ra) # 80003116 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800060c6:	08000613          	li	a2,128
    800060ca:	f5040593          	add	a1,s0,-176
    800060ce:	4501                	li	a0,0
    800060d0:	ffffd097          	auipc	ra,0xffffd
    800060d4:	066080e7          	jalr	102(ra) # 80003136 <argstr>
    800060d8:	87aa                	mv	a5,a0
    return -1;
    800060da:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800060dc:	0c07c263          	bltz	a5,800061a0 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    800060e0:	10000613          	li	a2,256
    800060e4:	4581                	li	a1,0
    800060e6:	e5040513          	add	a0,s0,-432
    800060ea:	ffffb097          	auipc	ra,0xffffb
    800060ee:	be4080e7          	jalr	-1052(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800060f2:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800060f6:	89a6                	mv	s3,s1
    800060f8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800060fa:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060fe:	00391513          	sll	a0,s2,0x3
    80006102:	e4040593          	add	a1,s0,-448
    80006106:	e4843783          	ld	a5,-440(s0)
    8000610a:	953e                	add	a0,a0,a5
    8000610c:	ffffd097          	auipc	ra,0xffffd
    80006110:	f4c080e7          	jalr	-180(ra) # 80003058 <fetchaddr>
    80006114:	02054a63          	bltz	a0,80006148 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006118:	e4043783          	ld	a5,-448(s0)
    8000611c:	c3b9                	beqz	a5,80006162 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000611e:	ffffb097          	auipc	ra,0xffffb
    80006122:	9c4080e7          	jalr	-1596(ra) # 80000ae2 <kalloc>
    80006126:	85aa                	mv	a1,a0
    80006128:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000612c:	cd11                	beqz	a0,80006148 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000612e:	6605                	lui	a2,0x1
    80006130:	e4043503          	ld	a0,-448(s0)
    80006134:	ffffd097          	auipc	ra,0xffffd
    80006138:	f76080e7          	jalr	-138(ra) # 800030aa <fetchstr>
    8000613c:	00054663          	bltz	a0,80006148 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80006140:	0905                	add	s2,s2,1
    80006142:	09a1                	add	s3,s3,8
    80006144:	fb491de3          	bne	s2,s4,800060fe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006148:	f5040913          	add	s2,s0,-176
    8000614c:	6088                	ld	a0,0(s1)
    8000614e:	c921                	beqz	a0,8000619e <sys_exec+0xf6>
    kfree(argv[i]);
    80006150:	ffffb097          	auipc	ra,0xffffb
    80006154:	894080e7          	jalr	-1900(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006158:	04a1                	add	s1,s1,8
    8000615a:	ff2499e3          	bne	s1,s2,8000614c <sys_exec+0xa4>
  return -1;
    8000615e:	557d                	li	a0,-1
    80006160:	a081                	j	800061a0 <sys_exec+0xf8>
      argv[i] = 0;
    80006162:	0009079b          	sext.w	a5,s2
    80006166:	078e                	sll	a5,a5,0x3
    80006168:	fd078793          	add	a5,a5,-48
    8000616c:	97a2                	add	a5,a5,s0
    8000616e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006172:	e5040593          	add	a1,s0,-432
    80006176:	f5040513          	add	a0,s0,-176
    8000617a:	fffff097          	auipc	ra,0xfffff
    8000617e:	192080e7          	jalr	402(ra) # 8000530c <exec>
    80006182:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006184:	f5040993          	add	s3,s0,-176
    80006188:	6088                	ld	a0,0(s1)
    8000618a:	c901                	beqz	a0,8000619a <sys_exec+0xf2>
    kfree(argv[i]);
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	858080e7          	jalr	-1960(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006194:	04a1                	add	s1,s1,8
    80006196:	ff3499e3          	bne	s1,s3,80006188 <sys_exec+0xe0>
  return ret;
    8000619a:	854a                	mv	a0,s2
    8000619c:	a011                	j	800061a0 <sys_exec+0xf8>
  return -1;
    8000619e:	557d                	li	a0,-1
}
    800061a0:	70fa                	ld	ra,440(sp)
    800061a2:	745a                	ld	s0,432(sp)
    800061a4:	74ba                	ld	s1,424(sp)
    800061a6:	791a                	ld	s2,416(sp)
    800061a8:	69fa                	ld	s3,408(sp)
    800061aa:	6a5a                	ld	s4,400(sp)
    800061ac:	6139                	add	sp,sp,448
    800061ae:	8082                	ret

00000000800061b0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800061b0:	7139                	add	sp,sp,-64
    800061b2:	fc06                	sd	ra,56(sp)
    800061b4:	f822                	sd	s0,48(sp)
    800061b6:	f426                	sd	s1,40(sp)
    800061b8:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800061ba:	ffffb097          	auipc	ra,0xffffb
    800061be:	7ec080e7          	jalr	2028(ra) # 800019a6 <myproc>
    800061c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800061c4:	fd840593          	add	a1,s0,-40
    800061c8:	4501                	li	a0,0
    800061ca:	ffffd097          	auipc	ra,0xffffd
    800061ce:	f4c080e7          	jalr	-180(ra) # 80003116 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800061d2:	fc840593          	add	a1,s0,-56
    800061d6:	fd040513          	add	a0,s0,-48
    800061da:	fffff097          	auipc	ra,0xfffff
    800061de:	de8080e7          	jalr	-536(ra) # 80004fc2 <pipealloc>
    return -1;
    800061e2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061e4:	0c054763          	bltz	a0,800062b2 <sys_pipe+0x102>
  fd0 = -1;
    800061e8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061ec:	fd043503          	ld	a0,-48(s0)
    800061f0:	fffff097          	auipc	ra,0xfffff
    800061f4:	522080e7          	jalr	1314(ra) # 80005712 <fdalloc>
    800061f8:	fca42223          	sw	a0,-60(s0)
    800061fc:	08054e63          	bltz	a0,80006298 <sys_pipe+0xe8>
    80006200:	fc843503          	ld	a0,-56(s0)
    80006204:	fffff097          	auipc	ra,0xfffff
    80006208:	50e080e7          	jalr	1294(ra) # 80005712 <fdalloc>
    8000620c:	fca42023          	sw	a0,-64(s0)
    80006210:	06054a63          	bltz	a0,80006284 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006214:	4691                	li	a3,4
    80006216:	fc440613          	add	a2,s0,-60
    8000621a:	fd843583          	ld	a1,-40(s0)
    8000621e:	64c8                	ld	a0,136(s1)
    80006220:	ffffb097          	auipc	ra,0xffffb
    80006224:	446080e7          	jalr	1094(ra) # 80001666 <copyout>
    80006228:	02054063          	bltz	a0,80006248 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000622c:	4691                	li	a3,4
    8000622e:	fc040613          	add	a2,s0,-64
    80006232:	fd843583          	ld	a1,-40(s0)
    80006236:	0591                	add	a1,a1,4
    80006238:	64c8                	ld	a0,136(s1)
    8000623a:	ffffb097          	auipc	ra,0xffffb
    8000623e:	42c080e7          	jalr	1068(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006242:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006244:	06055763          	bgez	a0,800062b2 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80006248:	fc442783          	lw	a5,-60(s0)
    8000624c:	02078793          	add	a5,a5,32
    80006250:	078e                	sll	a5,a5,0x3
    80006252:	97a6                	add	a5,a5,s1
    80006254:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006258:	fc042783          	lw	a5,-64(s0)
    8000625c:	02078793          	add	a5,a5,32
    80006260:	078e                	sll	a5,a5,0x3
    80006262:	94be                	add	s1,s1,a5
    80006264:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006268:	fd043503          	ld	a0,-48(s0)
    8000626c:	fffff097          	auipc	ra,0xfffff
    80006270:	a2a080e7          	jalr	-1494(ra) # 80004c96 <fileclose>
    fileclose(wf);
    80006274:	fc843503          	ld	a0,-56(s0)
    80006278:	fffff097          	auipc	ra,0xfffff
    8000627c:	a1e080e7          	jalr	-1506(ra) # 80004c96 <fileclose>
    return -1;
    80006280:	57fd                	li	a5,-1
    80006282:	a805                	j	800062b2 <sys_pipe+0x102>
    if(fd0 >= 0)
    80006284:	fc442783          	lw	a5,-60(s0)
    80006288:	0007c863          	bltz	a5,80006298 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    8000628c:	02078793          	add	a5,a5,32
    80006290:	078e                	sll	a5,a5,0x3
    80006292:	97a6                	add	a5,a5,s1
    80006294:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80006298:	fd043503          	ld	a0,-48(s0)
    8000629c:	fffff097          	auipc	ra,0xfffff
    800062a0:	9fa080e7          	jalr	-1542(ra) # 80004c96 <fileclose>
    fileclose(wf);
    800062a4:	fc843503          	ld	a0,-56(s0)
    800062a8:	fffff097          	auipc	ra,0xfffff
    800062ac:	9ee080e7          	jalr	-1554(ra) # 80004c96 <fileclose>
    return -1;
    800062b0:	57fd                	li	a5,-1
}
    800062b2:	853e                	mv	a0,a5
    800062b4:	70e2                	ld	ra,56(sp)
    800062b6:	7442                	ld	s0,48(sp)
    800062b8:	74a2                	ld	s1,40(sp)
    800062ba:	6121                	add	sp,sp,64
    800062bc:	8082                	ret
	...

00000000800062c0 <kernelvec>:
    800062c0:	7111                	add	sp,sp,-256
    800062c2:	e006                	sd	ra,0(sp)
    800062c4:	e40a                	sd	sp,8(sp)
    800062c6:	e80e                	sd	gp,16(sp)
    800062c8:	ec12                	sd	tp,24(sp)
    800062ca:	f016                	sd	t0,32(sp)
    800062cc:	f41a                	sd	t1,40(sp)
    800062ce:	f81e                	sd	t2,48(sp)
    800062d0:	fc22                	sd	s0,56(sp)
    800062d2:	e0a6                	sd	s1,64(sp)
    800062d4:	e4aa                	sd	a0,72(sp)
    800062d6:	e8ae                	sd	a1,80(sp)
    800062d8:	ecb2                	sd	a2,88(sp)
    800062da:	f0b6                	sd	a3,96(sp)
    800062dc:	f4ba                	sd	a4,104(sp)
    800062de:	f8be                	sd	a5,112(sp)
    800062e0:	fcc2                	sd	a6,120(sp)
    800062e2:	e146                	sd	a7,128(sp)
    800062e4:	e54a                	sd	s2,136(sp)
    800062e6:	e94e                	sd	s3,144(sp)
    800062e8:	ed52                	sd	s4,152(sp)
    800062ea:	f156                	sd	s5,160(sp)
    800062ec:	f55a                	sd	s6,168(sp)
    800062ee:	f95e                	sd	s7,176(sp)
    800062f0:	fd62                	sd	s8,184(sp)
    800062f2:	e1e6                	sd	s9,192(sp)
    800062f4:	e5ea                	sd	s10,200(sp)
    800062f6:	e9ee                	sd	s11,208(sp)
    800062f8:	edf2                	sd	t3,216(sp)
    800062fa:	f1f6                	sd	t4,224(sp)
    800062fc:	f5fa                	sd	t5,232(sp)
    800062fe:	f9fe                	sd	t6,240(sp)
    80006300:	af5fc0ef          	jal	80002df4 <kerneltrap>
    80006304:	6082                	ld	ra,0(sp)
    80006306:	6122                	ld	sp,8(sp)
    80006308:	61c2                	ld	gp,16(sp)
    8000630a:	7282                	ld	t0,32(sp)
    8000630c:	7322                	ld	t1,40(sp)
    8000630e:	73c2                	ld	t2,48(sp)
    80006310:	7462                	ld	s0,56(sp)
    80006312:	6486                	ld	s1,64(sp)
    80006314:	6526                	ld	a0,72(sp)
    80006316:	65c6                	ld	a1,80(sp)
    80006318:	6666                	ld	a2,88(sp)
    8000631a:	7686                	ld	a3,96(sp)
    8000631c:	7726                	ld	a4,104(sp)
    8000631e:	77c6                	ld	a5,112(sp)
    80006320:	7866                	ld	a6,120(sp)
    80006322:	688a                	ld	a7,128(sp)
    80006324:	692a                	ld	s2,136(sp)
    80006326:	69ca                	ld	s3,144(sp)
    80006328:	6a6a                	ld	s4,152(sp)
    8000632a:	7a8a                	ld	s5,160(sp)
    8000632c:	7b2a                	ld	s6,168(sp)
    8000632e:	7bca                	ld	s7,176(sp)
    80006330:	7c6a                	ld	s8,184(sp)
    80006332:	6c8e                	ld	s9,192(sp)
    80006334:	6d2e                	ld	s10,200(sp)
    80006336:	6dce                	ld	s11,208(sp)
    80006338:	6e6e                	ld	t3,216(sp)
    8000633a:	7e8e                	ld	t4,224(sp)
    8000633c:	7f2e                	ld	t5,232(sp)
    8000633e:	7fce                	ld	t6,240(sp)
    80006340:	6111                	add	sp,sp,256
    80006342:	10200073          	sret
    80006346:	00000013          	nop
    8000634a:	00000013          	nop
    8000634e:	0001                	nop

0000000080006350 <timervec>:
    80006350:	34051573          	csrrw	a0,mscratch,a0
    80006354:	e10c                	sd	a1,0(a0)
    80006356:	e510                	sd	a2,8(a0)
    80006358:	e914                	sd	a3,16(a0)
    8000635a:	6d0c                	ld	a1,24(a0)
    8000635c:	7110                	ld	a2,32(a0)
    8000635e:	6194                	ld	a3,0(a1)
    80006360:	96b2                	add	a3,a3,a2
    80006362:	e194                	sd	a3,0(a1)
    80006364:	4589                	li	a1,2
    80006366:	14459073          	csrw	sip,a1
    8000636a:	6914                	ld	a3,16(a0)
    8000636c:	6510                	ld	a2,8(a0)
    8000636e:	610c                	ld	a1,0(a0)
    80006370:	34051573          	csrrw	a0,mscratch,a0
    80006374:	30200073          	mret
	...

000000008000637a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000637a:	1141                	add	sp,sp,-16
    8000637c:	e422                	sd	s0,8(sp)
    8000637e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006380:	0c0007b7          	lui	a5,0xc000
    80006384:	4705                	li	a4,1
    80006386:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006388:	c3d8                	sw	a4,4(a5)
}
    8000638a:	6422                	ld	s0,8(sp)
    8000638c:	0141                	add	sp,sp,16
    8000638e:	8082                	ret

0000000080006390 <plicinithart>:

void
plicinithart(void)
{
    80006390:	1141                	add	sp,sp,-16
    80006392:	e406                	sd	ra,8(sp)
    80006394:	e022                	sd	s0,0(sp)
    80006396:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	5e2080e7          	jalr	1506(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800063a0:	0085171b          	sllw	a4,a0,0x8
    800063a4:	0c0027b7          	lui	a5,0xc002
    800063a8:	97ba                	add	a5,a5,a4
    800063aa:	40200713          	li	a4,1026
    800063ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800063b2:	00d5151b          	sllw	a0,a0,0xd
    800063b6:	0c2017b7          	lui	a5,0xc201
    800063ba:	97aa                	add	a5,a5,a0
    800063bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800063c0:	60a2                	ld	ra,8(sp)
    800063c2:	6402                	ld	s0,0(sp)
    800063c4:	0141                	add	sp,sp,16
    800063c6:	8082                	ret

00000000800063c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800063c8:	1141                	add	sp,sp,-16
    800063ca:	e406                	sd	ra,8(sp)
    800063cc:	e022                	sd	s0,0(sp)
    800063ce:	0800                	add	s0,sp,16
  int hart = cpuid();
    800063d0:	ffffb097          	auipc	ra,0xffffb
    800063d4:	5aa080e7          	jalr	1450(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063d8:	00d5151b          	sllw	a0,a0,0xd
    800063dc:	0c2017b7          	lui	a5,0xc201
    800063e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800063e2:	43c8                	lw	a0,4(a5)
    800063e4:	60a2                	ld	ra,8(sp)
    800063e6:	6402                	ld	s0,0(sp)
    800063e8:	0141                	add	sp,sp,16
    800063ea:	8082                	ret

00000000800063ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063ec:	1101                	add	sp,sp,-32
    800063ee:	ec06                	sd	ra,24(sp)
    800063f0:	e822                	sd	s0,16(sp)
    800063f2:	e426                	sd	s1,8(sp)
    800063f4:	1000                	add	s0,sp,32
    800063f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063f8:	ffffb097          	auipc	ra,0xffffb
    800063fc:	582080e7          	jalr	1410(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006400:	00d5151b          	sllw	a0,a0,0xd
    80006404:	0c2017b7          	lui	a5,0xc201
    80006408:	97aa                	add	a5,a5,a0
    8000640a:	c3c4                	sw	s1,4(a5)
}
    8000640c:	60e2                	ld	ra,24(sp)
    8000640e:	6442                	ld	s0,16(sp)
    80006410:	64a2                	ld	s1,8(sp)
    80006412:	6105                	add	sp,sp,32
    80006414:	8082                	ret

0000000080006416 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006416:	1141                	add	sp,sp,-16
    80006418:	e406                	sd	ra,8(sp)
    8000641a:	e022                	sd	s0,0(sp)
    8000641c:	0800                	add	s0,sp,16
  if(i >= NUM)
    8000641e:	479d                	li	a5,7
    80006420:	04a7cc63          	blt	a5,a0,80006478 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006424:	0001d797          	auipc	a5,0x1d
    80006428:	a0c78793          	add	a5,a5,-1524 # 80022e30 <disk>
    8000642c:	97aa                	add	a5,a5,a0
    8000642e:	0187c783          	lbu	a5,24(a5)
    80006432:	ebb9                	bnez	a5,80006488 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006434:	00451693          	sll	a3,a0,0x4
    80006438:	0001d797          	auipc	a5,0x1d
    8000643c:	9f878793          	add	a5,a5,-1544 # 80022e30 <disk>
    80006440:	6398                	ld	a4,0(a5)
    80006442:	9736                	add	a4,a4,a3
    80006444:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006448:	6398                	ld	a4,0(a5)
    8000644a:	9736                	add	a4,a4,a3
    8000644c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006450:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006454:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006458:	97aa                	add	a5,a5,a0
    8000645a:	4705                	li	a4,1
    8000645c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006460:	0001d517          	auipc	a0,0x1d
    80006464:	9e850513          	add	a0,a0,-1560 # 80022e48 <disk+0x18>
    80006468:	ffffc097          	auipc	ra,0xffffc
    8000646c:	d7c080e7          	jalr	-644(ra) # 800021e4 <wakeup>
}
    80006470:	60a2                	ld	ra,8(sp)
    80006472:	6402                	ld	s0,0(sp)
    80006474:	0141                	add	sp,sp,16
    80006476:	8082                	ret
    panic("free_desc 1");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	2e850513          	add	a0,a0,744 # 80008760 <syscalls+0x310>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0bc080e7          	jalr	188(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	2e850513          	add	a0,a0,744 # 80008770 <syscalls+0x320>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0ac080e7          	jalr	172(ra) # 8000053c <panic>

0000000080006498 <virtio_disk_init>:
{
    80006498:	1101                	add	sp,sp,-32
    8000649a:	ec06                	sd	ra,24(sp)
    8000649c:	e822                	sd	s0,16(sp)
    8000649e:	e426                	sd	s1,8(sp)
    800064a0:	e04a                	sd	s2,0(sp)
    800064a2:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800064a4:	00002597          	auipc	a1,0x2
    800064a8:	2dc58593          	add	a1,a1,732 # 80008780 <syscalls+0x330>
    800064ac:	0001d517          	auipc	a0,0x1d
    800064b0:	aac50513          	add	a0,a0,-1364 # 80022f58 <disk+0x128>
    800064b4:	ffffa097          	auipc	ra,0xffffa
    800064b8:	68e080e7          	jalr	1678(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064bc:	100017b7          	lui	a5,0x10001
    800064c0:	4398                	lw	a4,0(a5)
    800064c2:	2701                	sext.w	a4,a4
    800064c4:	747277b7          	lui	a5,0x74727
    800064c8:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064cc:	14f71b63          	bne	a4,a5,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064d0:	100017b7          	lui	a5,0x10001
    800064d4:	43dc                	lw	a5,4(a5)
    800064d6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064d8:	4709                	li	a4,2
    800064da:	14e79463          	bne	a5,a4,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064de:	100017b7          	lui	a5,0x10001
    800064e2:	479c                	lw	a5,8(a5)
    800064e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064e6:	12e79e63          	bne	a5,a4,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064ea:	100017b7          	lui	a5,0x10001
    800064ee:	47d8                	lw	a4,12(a5)
    800064f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064f2:	554d47b7          	lui	a5,0x554d4
    800064f6:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064fa:	12f71463          	bne	a4,a5,80006622 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064fe:	100017b7          	lui	a5,0x10001
    80006502:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006506:	4705                	li	a4,1
    80006508:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000650a:	470d                	li	a4,3
    8000650c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000650e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006510:	c7ffe6b7          	lui	a3,0xc7ffe
    80006514:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb7ef>
    80006518:	8f75                	and	a4,a4,a3
    8000651a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000651c:	472d                	li	a4,11
    8000651e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006520:	5bbc                	lw	a5,112(a5)
    80006522:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006526:	8ba1                	and	a5,a5,8
    80006528:	10078563          	beqz	a5,80006632 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000652c:	100017b7          	lui	a5,0x10001
    80006530:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006534:	43fc                	lw	a5,68(a5)
    80006536:	2781                	sext.w	a5,a5
    80006538:	10079563          	bnez	a5,80006642 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000653c:	100017b7          	lui	a5,0x10001
    80006540:	5bdc                	lw	a5,52(a5)
    80006542:	2781                	sext.w	a5,a5
  if(max == 0)
    80006544:	10078763          	beqz	a5,80006652 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006548:	471d                	li	a4,7
    8000654a:	10f77c63          	bgeu	a4,a5,80006662 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	594080e7          	jalr	1428(ra) # 80000ae2 <kalloc>
    80006556:	0001d497          	auipc	s1,0x1d
    8000655a:	8da48493          	add	s1,s1,-1830 # 80022e30 <disk>
    8000655e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	582080e7          	jalr	1410(ra) # 80000ae2 <kalloc>
    80006568:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	578080e7          	jalr	1400(ra) # 80000ae2 <kalloc>
    80006572:	87aa                	mv	a5,a0
    80006574:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006576:	6088                	ld	a0,0(s1)
    80006578:	cd6d                	beqz	a0,80006672 <virtio_disk_init+0x1da>
    8000657a:	0001d717          	auipc	a4,0x1d
    8000657e:	8be73703          	ld	a4,-1858(a4) # 80022e38 <disk+0x8>
    80006582:	cb65                	beqz	a4,80006672 <virtio_disk_init+0x1da>
    80006584:	c7fd                	beqz	a5,80006672 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006586:	6605                	lui	a2,0x1
    80006588:	4581                	li	a1,0
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	744080e7          	jalr	1860(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80006592:	0001d497          	auipc	s1,0x1d
    80006596:	89e48493          	add	s1,s1,-1890 # 80022e30 <disk>
    8000659a:	6605                	lui	a2,0x1
    8000659c:	4581                	li	a1,0
    8000659e:	6488                	ld	a0,8(s1)
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	72e080e7          	jalr	1838(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800065a8:	6605                	lui	a2,0x1
    800065aa:	4581                	li	a1,0
    800065ac:	6888                	ld	a0,16(s1)
    800065ae:	ffffa097          	auipc	ra,0xffffa
    800065b2:	720080e7          	jalr	1824(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800065b6:	100017b7          	lui	a5,0x10001
    800065ba:	4721                	li	a4,8
    800065bc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800065be:	4098                	lw	a4,0(s1)
    800065c0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800065c4:	40d8                	lw	a4,4(s1)
    800065c6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800065ca:	6498                	ld	a4,8(s1)
    800065cc:	0007069b          	sext.w	a3,a4
    800065d0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800065d4:	9701                	sra	a4,a4,0x20
    800065d6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800065da:	6898                	ld	a4,16(s1)
    800065dc:	0007069b          	sext.w	a3,a4
    800065e0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800065e4:	9701                	sra	a4,a4,0x20
    800065e6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800065ea:	4705                	li	a4,1
    800065ec:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800065ee:	00e48c23          	sb	a4,24(s1)
    800065f2:	00e48ca3          	sb	a4,25(s1)
    800065f6:	00e48d23          	sb	a4,26(s1)
    800065fa:	00e48da3          	sb	a4,27(s1)
    800065fe:	00e48e23          	sb	a4,28(s1)
    80006602:	00e48ea3          	sb	a4,29(s1)
    80006606:	00e48f23          	sb	a4,30(s1)
    8000660a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000660e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006612:	0727a823          	sw	s2,112(a5)
}
    80006616:	60e2                	ld	ra,24(sp)
    80006618:	6442                	ld	s0,16(sp)
    8000661a:	64a2                	ld	s1,8(sp)
    8000661c:	6902                	ld	s2,0(sp)
    8000661e:	6105                	add	sp,sp,32
    80006620:	8082                	ret
    panic("could not find virtio disk");
    80006622:	00002517          	auipc	a0,0x2
    80006626:	16e50513          	add	a0,a0,366 # 80008790 <syscalls+0x340>
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	f12080e7          	jalr	-238(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006632:	00002517          	auipc	a0,0x2
    80006636:	17e50513          	add	a0,a0,382 # 800087b0 <syscalls+0x360>
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	f02080e7          	jalr	-254(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006642:	00002517          	auipc	a0,0x2
    80006646:	18e50513          	add	a0,a0,398 # 800087d0 <syscalls+0x380>
    8000664a:	ffffa097          	auipc	ra,0xffffa
    8000664e:	ef2080e7          	jalr	-270(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006652:	00002517          	auipc	a0,0x2
    80006656:	19e50513          	add	a0,a0,414 # 800087f0 <syscalls+0x3a0>
    8000665a:	ffffa097          	auipc	ra,0xffffa
    8000665e:	ee2080e7          	jalr	-286(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006662:	00002517          	auipc	a0,0x2
    80006666:	1ae50513          	add	a0,a0,430 # 80008810 <syscalls+0x3c0>
    8000666a:	ffffa097          	auipc	ra,0xffffa
    8000666e:	ed2080e7          	jalr	-302(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006672:	00002517          	auipc	a0,0x2
    80006676:	1be50513          	add	a0,a0,446 # 80008830 <syscalls+0x3e0>
    8000667a:	ffffa097          	auipc	ra,0xffffa
    8000667e:	ec2080e7          	jalr	-318(ra) # 8000053c <panic>

0000000080006682 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006682:	7159                	add	sp,sp,-112
    80006684:	f486                	sd	ra,104(sp)
    80006686:	f0a2                	sd	s0,96(sp)
    80006688:	eca6                	sd	s1,88(sp)
    8000668a:	e8ca                	sd	s2,80(sp)
    8000668c:	e4ce                	sd	s3,72(sp)
    8000668e:	e0d2                	sd	s4,64(sp)
    80006690:	fc56                	sd	s5,56(sp)
    80006692:	f85a                	sd	s6,48(sp)
    80006694:	f45e                	sd	s7,40(sp)
    80006696:	f062                	sd	s8,32(sp)
    80006698:	ec66                	sd	s9,24(sp)
    8000669a:	e86a                	sd	s10,16(sp)
    8000669c:	1880                	add	s0,sp,112
    8000669e:	8a2a                	mv	s4,a0
    800066a0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800066a2:	00c52c83          	lw	s9,12(a0)
    800066a6:	001c9c9b          	sllw	s9,s9,0x1
    800066aa:	1c82                	sll	s9,s9,0x20
    800066ac:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800066b0:	0001d517          	auipc	a0,0x1d
    800066b4:	8a850513          	add	a0,a0,-1880 # 80022f58 <disk+0x128>
    800066b8:	ffffa097          	auipc	ra,0xffffa
    800066bc:	51a080e7          	jalr	1306(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    800066c0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    800066c2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800066c4:	0001cb17          	auipc	s6,0x1c
    800066c8:	76cb0b13          	add	s6,s6,1900 # 80022e30 <disk>
  for(int i = 0; i < 3; i++){
    800066cc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066ce:	0001dc17          	auipc	s8,0x1d
    800066d2:	88ac0c13          	add	s8,s8,-1910 # 80022f58 <disk+0x128>
    800066d6:	a095                	j	8000673a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800066d8:	00fb0733          	add	a4,s6,a5
    800066dc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800066e0:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    800066e2:	0207c563          	bltz	a5,8000670c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    800066e6:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    800066e8:	0591                	add	a1,a1,4
    800066ea:	05560d63          	beq	a2,s5,80006744 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800066ee:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    800066f0:	0001c717          	auipc	a4,0x1c
    800066f4:	74070713          	add	a4,a4,1856 # 80022e30 <disk>
    800066f8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    800066fa:	01874683          	lbu	a3,24(a4)
    800066fe:	fee9                	bnez	a3,800066d8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006700:	2785                	addw	a5,a5,1
    80006702:	0705                	add	a4,a4,1
    80006704:	fe979be3          	bne	a5,s1,800066fa <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006708:	57fd                	li	a5,-1
    8000670a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000670c:	00c05e63          	blez	a2,80006728 <virtio_disk_rw+0xa6>
    80006710:	060a                	sll	a2,a2,0x2
    80006712:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006716:	0009a503          	lw	a0,0(s3)
    8000671a:	00000097          	auipc	ra,0x0
    8000671e:	cfc080e7          	jalr	-772(ra) # 80006416 <free_desc>
      for(int j = 0; j < i; j++)
    80006722:	0991                	add	s3,s3,4
    80006724:	ffa999e3          	bne	s3,s10,80006716 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006728:	85e2                	mv	a1,s8
    8000672a:	0001c517          	auipc	a0,0x1c
    8000672e:	71e50513          	add	a0,a0,1822 # 80022e48 <disk+0x18>
    80006732:	ffffc097          	auipc	ra,0xffffc
    80006736:	a4e080e7          	jalr	-1458(ra) # 80002180 <sleep>
  for(int i = 0; i < 3; i++){
    8000673a:	f9040993          	add	s3,s0,-112
{
    8000673e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006740:	864a                	mv	a2,s2
    80006742:	b775                	j	800066ee <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006744:	f9042503          	lw	a0,-112(s0)
    80006748:	00a50713          	add	a4,a0,10
    8000674c:	0712                	sll	a4,a4,0x4

  if(write)
    8000674e:	0001c797          	auipc	a5,0x1c
    80006752:	6e278793          	add	a5,a5,1762 # 80022e30 <disk>
    80006756:	00e786b3          	add	a3,a5,a4
    8000675a:	01703633          	snez	a2,s7
    8000675e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006760:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006764:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006768:	f6070613          	add	a2,a4,-160
    8000676c:	6394                	ld	a3,0(a5)
    8000676e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006770:	00870593          	add	a1,a4,8
    80006774:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006776:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006778:	0007b803          	ld	a6,0(a5)
    8000677c:	9642                	add	a2,a2,a6
    8000677e:	46c1                	li	a3,16
    80006780:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006782:	4585                	li	a1,1
    80006784:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006788:	f9442683          	lw	a3,-108(s0)
    8000678c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006790:	0692                	sll	a3,a3,0x4
    80006792:	9836                	add	a6,a6,a3
    80006794:	058a0613          	add	a2,s4,88
    80006798:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000679c:	0007b803          	ld	a6,0(a5)
    800067a0:	96c2                	add	a3,a3,a6
    800067a2:	40000613          	li	a2,1024
    800067a6:	c690                	sw	a2,8(a3)
  if(write)
    800067a8:	001bb613          	seqz	a2,s7
    800067ac:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800067b0:	00166613          	or	a2,a2,1
    800067b4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800067b8:	f9842603          	lw	a2,-104(s0)
    800067bc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067c0:	00250693          	add	a3,a0,2
    800067c4:	0692                	sll	a3,a3,0x4
    800067c6:	96be                	add	a3,a3,a5
    800067c8:	58fd                	li	a7,-1
    800067ca:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067ce:	0612                	sll	a2,a2,0x4
    800067d0:	9832                	add	a6,a6,a2
    800067d2:	f9070713          	add	a4,a4,-112
    800067d6:	973e                	add	a4,a4,a5
    800067d8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800067dc:	6398                	ld	a4,0(a5)
    800067de:	9732                	add	a4,a4,a2
    800067e0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800067e2:	4609                	li	a2,2
    800067e4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800067e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800067ec:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    800067f0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800067f4:	6794                	ld	a3,8(a5)
    800067f6:	0026d703          	lhu	a4,2(a3)
    800067fa:	8b1d                	and	a4,a4,7
    800067fc:	0706                	sll	a4,a4,0x1
    800067fe:	96ba                	add	a3,a3,a4
    80006800:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006804:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006808:	6798                	ld	a4,8(a5)
    8000680a:	00275783          	lhu	a5,2(a4)
    8000680e:	2785                	addw	a5,a5,1
    80006810:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006814:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006818:	100017b7          	lui	a5,0x10001
    8000681c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006820:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006824:	0001c917          	auipc	s2,0x1c
    80006828:	73490913          	add	s2,s2,1844 # 80022f58 <disk+0x128>
  while(b->disk == 1) {
    8000682c:	4485                	li	s1,1
    8000682e:	00b79c63          	bne	a5,a1,80006846 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006832:	85ca                	mv	a1,s2
    80006834:	8552                	mv	a0,s4
    80006836:	ffffc097          	auipc	ra,0xffffc
    8000683a:	94a080e7          	jalr	-1718(ra) # 80002180 <sleep>
  while(b->disk == 1) {
    8000683e:	004a2783          	lw	a5,4(s4)
    80006842:	fe9788e3          	beq	a5,s1,80006832 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006846:	f9042903          	lw	s2,-112(s0)
    8000684a:	00290713          	add	a4,s2,2
    8000684e:	0712                	sll	a4,a4,0x4
    80006850:	0001c797          	auipc	a5,0x1c
    80006854:	5e078793          	add	a5,a5,1504 # 80022e30 <disk>
    80006858:	97ba                	add	a5,a5,a4
    8000685a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000685e:	0001c997          	auipc	s3,0x1c
    80006862:	5d298993          	add	s3,s3,1490 # 80022e30 <disk>
    80006866:	00491713          	sll	a4,s2,0x4
    8000686a:	0009b783          	ld	a5,0(s3)
    8000686e:	97ba                	add	a5,a5,a4
    80006870:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006874:	854a                	mv	a0,s2
    80006876:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000687a:	00000097          	auipc	ra,0x0
    8000687e:	b9c080e7          	jalr	-1124(ra) # 80006416 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006882:	8885                	and	s1,s1,1
    80006884:	f0ed                	bnez	s1,80006866 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006886:	0001c517          	auipc	a0,0x1c
    8000688a:	6d250513          	add	a0,a0,1746 # 80022f58 <disk+0x128>
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	3f8080e7          	jalr	1016(ra) # 80000c86 <release>
}
    80006896:	70a6                	ld	ra,104(sp)
    80006898:	7406                	ld	s0,96(sp)
    8000689a:	64e6                	ld	s1,88(sp)
    8000689c:	6946                	ld	s2,80(sp)
    8000689e:	69a6                	ld	s3,72(sp)
    800068a0:	6a06                	ld	s4,64(sp)
    800068a2:	7ae2                	ld	s5,56(sp)
    800068a4:	7b42                	ld	s6,48(sp)
    800068a6:	7ba2                	ld	s7,40(sp)
    800068a8:	7c02                	ld	s8,32(sp)
    800068aa:	6ce2                	ld	s9,24(sp)
    800068ac:	6d42                	ld	s10,16(sp)
    800068ae:	6165                	add	sp,sp,112
    800068b0:	8082                	ret

00000000800068b2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800068b2:	1101                	add	sp,sp,-32
    800068b4:	ec06                	sd	ra,24(sp)
    800068b6:	e822                	sd	s0,16(sp)
    800068b8:	e426                	sd	s1,8(sp)
    800068ba:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800068bc:	0001c497          	auipc	s1,0x1c
    800068c0:	57448493          	add	s1,s1,1396 # 80022e30 <disk>
    800068c4:	0001c517          	auipc	a0,0x1c
    800068c8:	69450513          	add	a0,a0,1684 # 80022f58 <disk+0x128>
    800068cc:	ffffa097          	auipc	ra,0xffffa
    800068d0:	306080e7          	jalr	774(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800068d4:	10001737          	lui	a4,0x10001
    800068d8:	533c                	lw	a5,96(a4)
    800068da:	8b8d                	and	a5,a5,3
    800068dc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800068de:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800068e2:	689c                	ld	a5,16(s1)
    800068e4:	0204d703          	lhu	a4,32(s1)
    800068e8:	0027d783          	lhu	a5,2(a5)
    800068ec:	04f70863          	beq	a4,a5,8000693c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800068f0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068f4:	6898                	ld	a4,16(s1)
    800068f6:	0204d783          	lhu	a5,32(s1)
    800068fa:	8b9d                	and	a5,a5,7
    800068fc:	078e                	sll	a5,a5,0x3
    800068fe:	97ba                	add	a5,a5,a4
    80006900:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006902:	00278713          	add	a4,a5,2
    80006906:	0712                	sll	a4,a4,0x4
    80006908:	9726                	add	a4,a4,s1
    8000690a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000690e:	e721                	bnez	a4,80006956 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006910:	0789                	add	a5,a5,2
    80006912:	0792                	sll	a5,a5,0x4
    80006914:	97a6                	add	a5,a5,s1
    80006916:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006918:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000691c:	ffffc097          	auipc	ra,0xffffc
    80006920:	8c8080e7          	jalr	-1848(ra) # 800021e4 <wakeup>

    disk.used_idx += 1;
    80006924:	0204d783          	lhu	a5,32(s1)
    80006928:	2785                	addw	a5,a5,1
    8000692a:	17c2                	sll	a5,a5,0x30
    8000692c:	93c1                	srl	a5,a5,0x30
    8000692e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006932:	6898                	ld	a4,16(s1)
    80006934:	00275703          	lhu	a4,2(a4)
    80006938:	faf71ce3          	bne	a4,a5,800068f0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000693c:	0001c517          	auipc	a0,0x1c
    80006940:	61c50513          	add	a0,a0,1564 # 80022f58 <disk+0x128>
    80006944:	ffffa097          	auipc	ra,0xffffa
    80006948:	342080e7          	jalr	834(ra) # 80000c86 <release>
}
    8000694c:	60e2                	ld	ra,24(sp)
    8000694e:	6442                	ld	s0,16(sp)
    80006950:	64a2                	ld	s1,8(sp)
    80006952:	6105                	add	sp,sp,32
    80006954:	8082                	ret
      panic("virtio_disk_intr status");
    80006956:	00002517          	auipc	a0,0x2
    8000695a:	ef250513          	add	a0,a0,-270 # 80008848 <syscalls+0x3f8>
    8000695e:	ffffa097          	auipc	ra,0xffffa
    80006962:	bde080e7          	jalr	-1058(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
