
user/_benchmark:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int number_of_processes = 10;


int main(int argc, char *argv[])
{
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	add	s0,sp,64
  int j;
  for (j = 0; j < number_of_processes; j++)
   e:	00001797          	auipc	a5,0x1
  12:	ff27a783          	lw	a5,-14(a5) # 1000 <number_of_processes>
  16:	0cf05863          	blez	a5,e6 <main+0xe6>
  1a:	4481                	li	s1,0
  {
    int pid = fork();
    if (pid < 0)
    { 
      int l=1;
      printf("Fork failed: %d\n",l);
  1c:	00001997          	auipc	s3,0x1
  20:	8b498993          	add	s3,s3,-1868 # 8d0 <malloc+0xea>
  for (j = 0; j < number_of_processes; j++)
  24:	00001917          	auipc	s2,0x1
  28:	fdc90913          	add	s2,s2,-36 # 1000 <number_of_processes>
  2c:	a821                	j	44 <main+0x44>
      printf("Fork failed: %d\n",l);
  2e:	4585                	li	a1,1
  30:	854e                	mv	a0,s3
  32:	00000097          	auipc	ra,0x0
  36:	6fc080e7          	jalr	1788(ra) # 72e <printf>
  for (j = 0; j < number_of_processes; j++)
  3a:	2485                	addw	s1,s1,1
  3c:	00092783          	lw	a5,0(s2)
  40:	0af4d363          	bge	s1,a5,e6 <main+0xe6>
    int pid = fork();
  44:	00000097          	auipc	ra,0x0
  48:	35a080e7          	jalr	858(ra) # 39e <fork>
    if (pid < 0)
  4c:	fe0541e3          	bltz	a0,2e <main+0x2e>
      continue;
    }
    if (pid == 0)
  50:	f56d                	bnez	a0,3a <main+0x3a>
    {
      volatile int i;
      for (volatile int k = 0; k < number_of_processes; k++)
  52:	fc042623          	sw	zero,-52(s0)
  56:	fcc42783          	lw	a5,-52(s0)
  5a:	2781                	sext.w	a5,a5
  5c:	00001717          	auipc	a4,0x1
  60:	fa472703          	lw	a4,-92(a4) # 1000 <number_of_processes>
  64:	06e7d463          	bge	a5,a4,cc <main+0xcc>
        {
          sleep(200); // io time
        }
        else
        {
          for (i = 0; i < 100000000; i++)
  68:	05f5e937          	lui	s2,0x5f5e
  6c:	0ff90913          	add	s2,s2,255 # 5f5e0ff <base+0x5f5d0df>
      for (volatile int k = 0; k < number_of_processes; k++)
  70:	00001997          	auipc	s3,0x1
  74:	f9098993          	add	s3,s3,-112 # 1000 <number_of_processes>
  78:	a835                	j	b4 <main+0xb4>
          for (i = 0; i < 100000000; i++)
  7a:	fc042423          	sw	zero,-56(s0)
  7e:	fc842783          	lw	a5,-56(s0)
  82:	2781                	sext.w	a5,a5
  84:	00f94c63          	blt	s2,a5,9c <main+0x9c>
  88:	fc842783          	lw	a5,-56(s0)
  8c:	2785                	addw	a5,a5,1
  8e:	fcf42423          	sw	a5,-56(s0)
  92:	fc842783          	lw	a5,-56(s0)
  96:	2781                	sext.w	a5,a5
  98:	fef958e3          	bge	s2,a5,88 <main+0x88>
      for (volatile int k = 0; k < number_of_processes; k++)
  9c:	fcc42783          	lw	a5,-52(s0)
  a0:	2785                	addw	a5,a5,1
  a2:	fcf42623          	sw	a5,-52(s0)
  a6:	fcc42783          	lw	a5,-52(s0)
  aa:	2781                	sext.w	a5,a5
  ac:	0009a703          	lw	a4,0(s3)
  b0:	00e7de63          	bge	a5,a4,cc <main+0xcc>
        if (k <= j)
  b4:	fcc42783          	lw	a5,-52(s0)
  b8:	2781                	sext.w	a5,a5
  ba:	fcf4c0e3          	blt	s1,a5,7a <main+0x7a>
          sleep(200); // io time
  be:	0c800513          	li	a0,200
  c2:	00000097          	auipc	ra,0x0
  c6:	374080e7          	jalr	884(ra) # 436 <sleep>
  ca:	bfc9                	j	9c <main+0x9c>
              ;
          }
        }
      }
      if (!PLOT)
        printf("Process: 1 Finished\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	81c50513          	add	a0,a0,-2020 # 8e8 <malloc+0x102>
  d4:	00000097          	auipc	ra,0x0
  d8:	65a080e7          	jalr	1626(ra) # 72e <printf>
      exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	2c8080e7          	jalr	712(ra) # 3a6 <exit>
    }
   
  }
  for (j = 0; j < number_of_processes + 5; j++)
  e6:	00001717          	auipc	a4,0x1
  ea:	f1a72703          	lw	a4,-230(a4) # 1000 <number_of_processes>
  ee:	57f1                	li	a5,-4
  f0:	02f74363          	blt	a4,a5,116 <main+0x116>
  f4:	4481                	li	s1,0
  f6:	00001917          	auipc	s2,0x1
  fa:	f0a90913          	add	s2,s2,-246 # 1000 <number_of_processes>
  {
    int status;
    wait(&status);
  fe:	fcc40513          	add	a0,s0,-52
 102:	00000097          	auipc	ra,0x0
 106:	2ac080e7          	jalr	684(ra) # 3ae <wait>
  for (j = 0; j < number_of_processes + 5; j++)
 10a:	2485                	addw	s1,s1,1
 10c:	00092783          	lw	a5,0(s2)
 110:	2791                	addw	a5,a5,4
 112:	fe97d6e3          	bge	a5,s1,fe <main+0xfe>
  }
  exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	28e080e7          	jalr	654(ra) # 3a6 <exit>

0000000000000120 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 120:	1141                	add	sp,sp,-16
 122:	e406                	sd	ra,8(sp)
 124:	e022                	sd	s0,0(sp)
 126:	0800                	add	s0,sp,16
  extern int main();
  main();
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <main>
  exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	274080e7          	jalr	628(ra) # 3a6 <exit>

000000000000013a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 13a:	1141                	add	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 140:	87aa                	mv	a5,a0
 142:	0585                	add	a1,a1,1
 144:	0785                	add	a5,a5,1
 146:	fff5c703          	lbu	a4,-1(a1)
 14a:	fee78fa3          	sb	a4,-1(a5)
 14e:	fb75                	bnez	a4,142 <strcpy+0x8>
    ;
  return os;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	add	sp,sp,16
 154:	8082                	ret

0000000000000156 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 156:	1141                	add	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cb91                	beqz	a5,174 <strcmp+0x1e>
 162:	0005c703          	lbu	a4,0(a1)
 166:	00f71763          	bne	a4,a5,174 <strcmp+0x1e>
    p++, q++;
 16a:	0505                	add	a0,a0,1
 16c:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 16e:	00054783          	lbu	a5,0(a0)
 172:	fbe5                	bnez	a5,162 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 174:	0005c503          	lbu	a0,0(a1)
}
 178:	40a7853b          	subw	a0,a5,a0
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	add	sp,sp,16
 180:	8082                	ret

0000000000000182 <strlen>:

uint
strlen(const char *s)
{
 182:	1141                	add	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cf91                	beqz	a5,1a8 <strlen+0x26>
 18e:	0505                	add	a0,a0,1
 190:	87aa                	mv	a5,a0
 192:	86be                	mv	a3,a5
 194:	0785                	add	a5,a5,1
 196:	fff7c703          	lbu	a4,-1(a5)
 19a:	ff65                	bnez	a4,192 <strlen+0x10>
 19c:	40a6853b          	subw	a0,a3,a0
 1a0:	2505                	addw	a0,a0,1
    ;
  return n;
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	add	sp,sp,16
 1a6:	8082                	ret
  for(n = 0; s[n]; n++)
 1a8:	4501                	li	a0,0
 1aa:	bfe5                	j	1a2 <strlen+0x20>

00000000000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	1141                	add	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b2:	ca19                	beqz	a2,1c8 <memset+0x1c>
 1b4:	87aa                	mv	a5,a0
 1b6:	1602                	sll	a2,a2,0x20
 1b8:	9201                	srl	a2,a2,0x20
 1ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c2:	0785                	add	a5,a5,1
 1c4:	fee79de3          	bne	a5,a4,1be <memset+0x12>
  }
  return dst;
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	add	sp,sp,16
 1cc:	8082                	ret

00000000000001ce <strchr>:

char*
strchr(const char *s, char c)
{
 1ce:	1141                	add	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	add	s0,sp,16
  for(; *s; s++)
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	cb99                	beqz	a5,1ee <strchr+0x20>
    if(*s == c)
 1da:	00f58763          	beq	a1,a5,1e8 <strchr+0x1a>
  for(; *s; s++)
 1de:	0505                	add	a0,a0,1
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	fbfd                	bnez	a5,1da <strchr+0xc>
      return (char*)s;
  return 0;
 1e6:	4501                	li	a0,0
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	add	sp,sp,16
 1ec:	8082                	ret
  return 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strchr+0x1a>

00000000000001f2 <gets>:

char*
gets(char *buf, int max)
{
 1f2:	711d                	add	sp,sp,-96
 1f4:	ec86                	sd	ra,88(sp)
 1f6:	e8a2                	sd	s0,80(sp)
 1f8:	e4a6                	sd	s1,72(sp)
 1fa:	e0ca                	sd	s2,64(sp)
 1fc:	fc4e                	sd	s3,56(sp)
 1fe:	f852                	sd	s4,48(sp)
 200:	f456                	sd	s5,40(sp)
 202:	f05a                	sd	s6,32(sp)
 204:	ec5e                	sd	s7,24(sp)
 206:	1080                	add	s0,sp,96
 208:	8baa                	mv	s7,a0
 20a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20c:	892a                	mv	s2,a0
 20e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 210:	4aa9                	li	s5,10
 212:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 214:	89a6                	mv	s3,s1
 216:	2485                	addw	s1,s1,1
 218:	0344d863          	bge	s1,s4,248 <gets+0x56>
    cc = read(0, &c, 1);
 21c:	4605                	li	a2,1
 21e:	faf40593          	add	a1,s0,-81
 222:	4501                	li	a0,0
 224:	00000097          	auipc	ra,0x0
 228:	19a080e7          	jalr	410(ra) # 3be <read>
    if(cc < 1)
 22c:	00a05e63          	blez	a0,248 <gets+0x56>
    buf[i++] = c;
 230:	faf44783          	lbu	a5,-81(s0)
 234:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 238:	01578763          	beq	a5,s5,246 <gets+0x54>
 23c:	0905                	add	s2,s2,1
 23e:	fd679be3          	bne	a5,s6,214 <gets+0x22>
  for(i=0; i+1 < max; ){
 242:	89a6                	mv	s3,s1
 244:	a011                	j	248 <gets+0x56>
 246:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 248:	99de                	add	s3,s3,s7
 24a:	00098023          	sb	zero,0(s3)
  return buf;
}
 24e:	855e                	mv	a0,s7
 250:	60e6                	ld	ra,88(sp)
 252:	6446                	ld	s0,80(sp)
 254:	64a6                	ld	s1,72(sp)
 256:	6906                	ld	s2,64(sp)
 258:	79e2                	ld	s3,56(sp)
 25a:	7a42                	ld	s4,48(sp)
 25c:	7aa2                	ld	s5,40(sp)
 25e:	7b02                	ld	s6,32(sp)
 260:	6be2                	ld	s7,24(sp)
 262:	6125                	add	sp,sp,96
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	add	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e426                	sd	s1,8(sp)
 26e:	e04a                	sd	s2,0(sp)
 270:	1000                	add	s0,sp,32
 272:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 274:	4581                	li	a1,0
 276:	00000097          	auipc	ra,0x0
 27a:	170080e7          	jalr	368(ra) # 3e6 <open>
  if(fd < 0)
 27e:	02054563          	bltz	a0,2a8 <stat+0x42>
 282:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 284:	85ca                	mv	a1,s2
 286:	00000097          	auipc	ra,0x0
 28a:	178080e7          	jalr	376(ra) # 3fe <fstat>
 28e:	892a                	mv	s2,a0
  close(fd);
 290:	8526                	mv	a0,s1
 292:	00000097          	auipc	ra,0x0
 296:	13c080e7          	jalr	316(ra) # 3ce <close>
  return r;
}
 29a:	854a                	mv	a0,s2
 29c:	60e2                	ld	ra,24(sp)
 29e:	6442                	ld	s0,16(sp)
 2a0:	64a2                	ld	s1,8(sp)
 2a2:	6902                	ld	s2,0(sp)
 2a4:	6105                	add	sp,sp,32
 2a6:	8082                	ret
    return -1;
 2a8:	597d                	li	s2,-1
 2aa:	bfc5                	j	29a <stat+0x34>

00000000000002ac <atoi>:

int
atoi(const char *s)
{
 2ac:	1141                	add	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b2:	00054683          	lbu	a3,0(a0)
 2b6:	fd06879b          	addw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	4625                	li	a2,9
 2c0:	02f66863          	bltu	a2,a5,2f0 <atoi+0x44>
 2c4:	872a                	mv	a4,a0
  n = 0;
 2c6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c8:	0705                	add	a4,a4,1
 2ca:	0025179b          	sllw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	sllw	a5,a5,0x1
 2d4:	9fb5                	addw	a5,a5,a3
 2d6:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	00074683          	lbu	a3,0(a4)
 2de:	fd06879b          	addw	a5,a3,-48
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	fef671e3          	bgeu	a2,a5,2c8 <atoi+0x1c>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	add	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x3e>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	add	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	sll	a2,a2,0x20
 304:	9201                	srl	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	add	a1,a1,1
 30e:	0705                	add	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	add	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addw	a5,a2,-1
 330:	1782                	sll	a5,a5,0x20
 332:	9381                	srl	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	add	a1,a1,-1
 33c:	177d                	add	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	add	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addw	a3,a2,-1
 358:	1682                	sll	a3,a3,0x20
 35a:	9281                	srl	a3,a3,0x20
 35c:	0685                	add	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	add	a0,a0,1
    p2++;
 36e:	0585                	add	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	add	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	add	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	add	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 446:	48d9                	li	a7,22
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 44e:	48dd                	li	a7,23
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 456:	48e1                	li	a7,24
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 45e:	48e5                	li	a7,25
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 466:	1101                	add	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	1000                	add	s0,sp,32
 46e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 472:	4605                	li	a2,1
 474:	fef40593          	add	a1,s0,-17
 478:	00000097          	auipc	ra,0x0
 47c:	f4e080e7          	jalr	-178(ra) # 3c6 <write>
}
 480:	60e2                	ld	ra,24(sp)
 482:	6442                	ld	s0,16(sp)
 484:	6105                	add	sp,sp,32
 486:	8082                	ret

0000000000000488 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 488:	7139                	add	sp,sp,-64
 48a:	fc06                	sd	ra,56(sp)
 48c:	f822                	sd	s0,48(sp)
 48e:	f426                	sd	s1,40(sp)
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	0080                	add	s0,sp,64
 496:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x16>
 49a:	0805c963          	bltz	a1,52c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49e:	2581                	sext.w	a1,a1
  neg = 0;
 4a0:	4881                	li	a7,0
 4a2:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 4a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a8:	2601                	sext.w	a2,a2
 4aa:	00000517          	auipc	a0,0x0
 4ae:	4b650513          	add	a0,a0,1206 # 960 <digits>
 4b2:	883a                	mv	a6,a4
 4b4:	2705                	addw	a4,a4,1
 4b6:	02c5f7bb          	remuw	a5,a1,a2
 4ba:	1782                	sll	a5,a5,0x20
 4bc:	9381                	srl	a5,a5,0x20
 4be:	97aa                	add	a5,a5,a0
 4c0:	0007c783          	lbu	a5,0(a5)
 4c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c8:	0005879b          	sext.w	a5,a1
 4cc:	02c5d5bb          	divuw	a1,a1,a2
 4d0:	0685                	add	a3,a3,1
 4d2:	fec7f0e3          	bgeu	a5,a2,4b2 <printint+0x2a>
  if(neg)
 4d6:	00088c63          	beqz	a7,4ee <printint+0x66>
    buf[i++] = '-';
 4da:	fd070793          	add	a5,a4,-48
 4de:	00878733          	add	a4,a5,s0
 4e2:	02d00793          	li	a5,45
 4e6:	fef70823          	sb	a5,-16(a4)
 4ea:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4ee:	02e05863          	blez	a4,51e <printint+0x96>
 4f2:	fc040793          	add	a5,s0,-64
 4f6:	00e78933          	add	s2,a5,a4
 4fa:	fff78993          	add	s3,a5,-1
 4fe:	99ba                	add	s3,s3,a4
 500:	377d                	addw	a4,a4,-1
 502:	1702                	sll	a4,a4,0x20
 504:	9301                	srl	a4,a4,0x20
 506:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 50a:	fff94583          	lbu	a1,-1(s2)
 50e:	8526                	mv	a0,s1
 510:	00000097          	auipc	ra,0x0
 514:	f56080e7          	jalr	-170(ra) # 466 <putc>
  while(--i >= 0)
 518:	197d                	add	s2,s2,-1
 51a:	ff3918e3          	bne	s2,s3,50a <printint+0x82>
}
 51e:	70e2                	ld	ra,56(sp)
 520:	7442                	ld	s0,48(sp)
 522:	74a2                	ld	s1,40(sp)
 524:	7902                	ld	s2,32(sp)
 526:	69e2                	ld	s3,24(sp)
 528:	6121                	add	sp,sp,64
 52a:	8082                	ret
    x = -xx;
 52c:	40b005bb          	negw	a1,a1
    neg = 1;
 530:	4885                	li	a7,1
    x = -xx;
 532:	bf85                	j	4a2 <printint+0x1a>

0000000000000534 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 534:	715d                	add	sp,sp,-80
 536:	e486                	sd	ra,72(sp)
 538:	e0a2                	sd	s0,64(sp)
 53a:	fc26                	sd	s1,56(sp)
 53c:	f84a                	sd	s2,48(sp)
 53e:	f44e                	sd	s3,40(sp)
 540:	f052                	sd	s4,32(sp)
 542:	ec56                	sd	s5,24(sp)
 544:	e85a                	sd	s6,16(sp)
 546:	e45e                	sd	s7,8(sp)
 548:	e062                	sd	s8,0(sp)
 54a:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54c:	0005c903          	lbu	s2,0(a1)
 550:	18090c63          	beqz	s2,6e8 <vprintf+0x1b4>
 554:	8aaa                	mv	s5,a0
 556:	8bb2                	mv	s7,a2
 558:	00158493          	add	s1,a1,1
  state = 0;
 55c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55e:	02500a13          	li	s4,37
 562:	4b55                	li	s6,21
 564:	a839                	j	582 <vprintf+0x4e>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	efc080e7          	jalr	-260(ra) # 466 <putc>
 572:	a019                	j	578 <vprintf+0x44>
    } else if(state == '%'){
 574:	01498d63          	beq	s3,s4,58e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 578:	0485                	add	s1,s1,1
 57a:	fff4c903          	lbu	s2,-1(s1)
 57e:	16090563          	beqz	s2,6e8 <vprintf+0x1b4>
    if(state == 0){
 582:	fe0999e3          	bnez	s3,574 <vprintf+0x40>
      if(c == '%'){
 586:	ff4910e3          	bne	s2,s4,566 <vprintf+0x32>
        state = '%';
 58a:	89d2                	mv	s3,s4
 58c:	b7f5                	j	578 <vprintf+0x44>
      if(c == 'd'){
 58e:	13490263          	beq	s2,s4,6b2 <vprintf+0x17e>
 592:	f9d9079b          	addw	a5,s2,-99
 596:	0ff7f793          	zext.b	a5,a5
 59a:	12fb6563          	bltu	s6,a5,6c4 <vprintf+0x190>
 59e:	f9d9079b          	addw	a5,s2,-99
 5a2:	0ff7f713          	zext.b	a4,a5
 5a6:	10eb6f63          	bltu	s6,a4,6c4 <vprintf+0x190>
 5aa:	00271793          	sll	a5,a4,0x2
 5ae:	00000717          	auipc	a4,0x0
 5b2:	35a70713          	add	a4,a4,858 # 908 <malloc+0x122>
 5b6:	97ba                	add	a5,a5,a4
 5b8:	439c                	lw	a5,0(a5)
 5ba:	97ba                	add	a5,a5,a4
 5bc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5be:	008b8913          	add	s2,s7,8
 5c2:	4685                	li	a3,1
 5c4:	4629                	li	a2,10
 5c6:	000ba583          	lw	a1,0(s7)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	ebc080e7          	jalr	-324(ra) # 488 <printint>
 5d4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b745                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5da:	008b8913          	add	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4629                	li	a2,10
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ea0080e7          	jalr	-352(ra) # 488 <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b751                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5f6:	008b8913          	add	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000ba583          	lw	a1,0(s7)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e84080e7          	jalr	-380(ra) # 488 <printint>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b7a5                	j	578 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 612:	008b8c13          	add	s8,s7,8
 616:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 61a:	03000593          	li	a1,48
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e46080e7          	jalr	-442(ra) # 466 <putc>
  putc(fd, 'x');
 628:	07800593          	li	a1,120
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	e38080e7          	jalr	-456(ra) # 466 <putc>
 636:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 638:	00000b97          	auipc	s7,0x0
 63c:	328b8b93          	add	s7,s7,808 # 960 <digits>
 640:	03c9d793          	srl	a5,s3,0x3c
 644:	97de                	add	a5,a5,s7
 646:	0007c583          	lbu	a1,0(a5)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e1a080e7          	jalr	-486(ra) # 466 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 654:	0992                	sll	s3,s3,0x4
 656:	397d                	addw	s2,s2,-1
 658:	fe0914e3          	bnez	s2,640 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 65c:	8be2                	mv	s7,s8
      state = 0;
 65e:	4981                	li	s3,0
 660:	bf21                	j	578 <vprintf+0x44>
        s = va_arg(ap, char*);
 662:	008b8993          	add	s3,s7,8
 666:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 66a:	02090163          	beqz	s2,68c <vprintf+0x158>
        while(*s != 0){
 66e:	00094583          	lbu	a1,0(s2)
 672:	c9a5                	beqz	a1,6e2 <vprintf+0x1ae>
          putc(fd, *s);
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	df0080e7          	jalr	-528(ra) # 466 <putc>
          s++;
 67e:	0905                	add	s2,s2,1
        while(*s != 0){
 680:	00094583          	lbu	a1,0(s2)
 684:	f9e5                	bnez	a1,674 <vprintf+0x140>
        s = va_arg(ap, char*);
 686:	8bce                	mv	s7,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	b5fd                	j	578 <vprintf+0x44>
          s = "(null)";
 68c:	00000917          	auipc	s2,0x0
 690:	27490913          	add	s2,s2,628 # 900 <malloc+0x11a>
        while(*s != 0){
 694:	02800593          	li	a1,40
 698:	bff1                	j	674 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 69a:	008b8913          	add	s2,s7,8
 69e:	000bc583          	lbu	a1,0(s7)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	dc2080e7          	jalr	-574(ra) # 466 <putc>
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b5e1                	j	578 <vprintf+0x44>
        putc(fd, c);
 6b2:	02500593          	li	a1,37
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	dae080e7          	jalr	-594(ra) # 466 <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bd5d                	j	578 <vprintf+0x44>
        putc(fd, '%');
 6c4:	02500593          	li	a1,37
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	d9c080e7          	jalr	-612(ra) # 466 <putc>
        putc(fd, c);
 6d2:	85ca                	mv	a1,s2
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	d90080e7          	jalr	-624(ra) # 466 <putc>
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bd61                	j	578 <vprintf+0x44>
        s = va_arg(ap, char*);
 6e2:	8bce                	mv	s7,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bd49                	j	578 <vprintf+0x44>
    }
  }
}
 6e8:	60a6                	ld	ra,72(sp)
 6ea:	6406                	ld	s0,64(sp)
 6ec:	74e2                	ld	s1,56(sp)
 6ee:	7942                	ld	s2,48(sp)
 6f0:	79a2                	ld	s3,40(sp)
 6f2:	7a02                	ld	s4,32(sp)
 6f4:	6ae2                	ld	s5,24(sp)
 6f6:	6b42                	ld	s6,16(sp)
 6f8:	6ba2                	ld	s7,8(sp)
 6fa:	6c02                	ld	s8,0(sp)
 6fc:	6161                	add	sp,sp,80
 6fe:	8082                	ret

0000000000000700 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 700:	715d                	add	sp,sp,-80
 702:	ec06                	sd	ra,24(sp)
 704:	e822                	sd	s0,16(sp)
 706:	1000                	add	s0,sp,32
 708:	e010                	sd	a2,0(s0)
 70a:	e414                	sd	a3,8(s0)
 70c:	e818                	sd	a4,16(s0)
 70e:	ec1c                	sd	a5,24(s0)
 710:	03043023          	sd	a6,32(s0)
 714:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 718:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 71c:	8622                	mv	a2,s0
 71e:	00000097          	auipc	ra,0x0
 722:	e16080e7          	jalr	-490(ra) # 534 <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6161                	add	sp,sp,80
 72c:	8082                	ret

000000000000072e <printf>:

void
printf(const char *fmt, ...)
{
 72e:	711d                	add	sp,sp,-96
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	add	s0,sp,32
 736:	e40c                	sd	a1,8(s0)
 738:	e810                	sd	a2,16(s0)
 73a:	ec14                	sd	a3,24(s0)
 73c:	f018                	sd	a4,32(s0)
 73e:	f41c                	sd	a5,40(s0)
 740:	03043823          	sd	a6,48(s0)
 744:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	00840613          	add	a2,s0,8
 74c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 750:	85aa                	mv	a1,a0
 752:	4505                	li	a0,1
 754:	00000097          	auipc	ra,0x0
 758:	de0080e7          	jalr	-544(ra) # 534 <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6125                	add	sp,sp,96
 762:	8082                	ret

0000000000000764 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 764:	1141                	add	sp,sp,-16
 766:	e422                	sd	s0,8(sp)
 768:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76e:	00001797          	auipc	a5,0x1
 772:	8a27b783          	ld	a5,-1886(a5) # 1010 <freep>
 776:	a02d                	j	7a0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 778:	4618                	lw	a4,8(a2)
 77a:	9f2d                	addw	a4,a4,a1
 77c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	6398                	ld	a4,0(a5)
 782:	6310                	ld	a2,0(a4)
 784:	a83d                	j	7c2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 786:	ff852703          	lw	a4,-8(a0)
 78a:	9f31                	addw	a4,a4,a2
 78c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 78e:	ff053683          	ld	a3,-16(a0)
 792:	a091                	j	7d6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 794:	6398                	ld	a4,0(a5)
 796:	00e7e463          	bltu	a5,a4,79e <free+0x3a>
 79a:	00e6ea63          	bltu	a3,a4,7ae <free+0x4a>
{
 79e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a0:	fed7fae3          	bgeu	a5,a3,794 <free+0x30>
 7a4:	6398                	ld	a4,0(a5)
 7a6:	00e6e463          	bltu	a3,a4,7ae <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	fee7eae3          	bltu	a5,a4,79e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ae:	ff852583          	lw	a1,-8(a0)
 7b2:	6390                	ld	a2,0(a5)
 7b4:	02059813          	sll	a6,a1,0x20
 7b8:	01c85713          	srl	a4,a6,0x1c
 7bc:	9736                	add	a4,a4,a3
 7be:	fae60de3          	beq	a2,a4,778 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c6:	4790                	lw	a2,8(a5)
 7c8:	02061593          	sll	a1,a2,0x20
 7cc:	01c5d713          	srl	a4,a1,0x1c
 7d0:	973e                	add	a4,a4,a5
 7d2:	fae68ae3          	beq	a3,a4,786 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d8:	00001717          	auipc	a4,0x1
 7dc:	82f73c23          	sd	a5,-1992(a4) # 1010 <freep>
}
 7e0:	6422                	ld	s0,8(sp)
 7e2:	0141                	add	sp,sp,16
 7e4:	8082                	ret

00000000000007e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e6:	7139                	add	sp,sp,-64
 7e8:	fc06                	sd	ra,56(sp)
 7ea:	f822                	sd	s0,48(sp)
 7ec:	f426                	sd	s1,40(sp)
 7ee:	f04a                	sd	s2,32(sp)
 7f0:	ec4e                	sd	s3,24(sp)
 7f2:	e852                	sd	s4,16(sp)
 7f4:	e456                	sd	s5,8(sp)
 7f6:	e05a                	sd	s6,0(sp)
 7f8:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fa:	02051493          	sll	s1,a0,0x20
 7fe:	9081                	srl	s1,s1,0x20
 800:	04bd                	add	s1,s1,15
 802:	8091                	srl	s1,s1,0x4
 804:	0014899b          	addw	s3,s1,1
 808:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 80a:	00001517          	auipc	a0,0x1
 80e:	80653503          	ld	a0,-2042(a0) # 1010 <freep>
 812:	c515                	beqz	a0,83e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 814:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 816:	4798                	lw	a4,8(a5)
 818:	02977f63          	bgeu	a4,s1,856 <malloc+0x70>
  if(nu < 4096)
 81c:	8a4e                	mv	s4,s3
 81e:	0009871b          	sext.w	a4,s3
 822:	6685                	lui	a3,0x1
 824:	00d77363          	bgeu	a4,a3,82a <malloc+0x44>
 828:	6a05                	lui	s4,0x1
 82a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 832:	00000917          	auipc	s2,0x0
 836:	7de90913          	add	s2,s2,2014 # 1010 <freep>
  if(p == (char*)-1)
 83a:	5afd                	li	s5,-1
 83c:	a895                	j	8b0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 83e:	00000797          	auipc	a5,0x0
 842:	7e278793          	add	a5,a5,2018 # 1020 <base>
 846:	00000717          	auipc	a4,0x0
 84a:	7cf73523          	sd	a5,1994(a4) # 1010 <freep>
 84e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 850:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 854:	b7e1                	j	81c <malloc+0x36>
      if(p->s.size == nunits)
 856:	02e48c63          	beq	s1,a4,88e <malloc+0xa8>
        p->s.size -= nunits;
 85a:	4137073b          	subw	a4,a4,s3
 85e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 860:	02071693          	sll	a3,a4,0x20
 864:	01c6d713          	srl	a4,a3,0x1c
 868:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86e:	00000717          	auipc	a4,0x0
 872:	7aa73123          	sd	a0,1954(a4) # 1010 <freep>
      return (void*)(p + 1);
 876:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87a:	70e2                	ld	ra,56(sp)
 87c:	7442                	ld	s0,48(sp)
 87e:	74a2                	ld	s1,40(sp)
 880:	7902                	ld	s2,32(sp)
 882:	69e2                	ld	s3,24(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	6121                	add	sp,sp,64
 88c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 88e:	6398                	ld	a4,0(a5)
 890:	e118                	sd	a4,0(a0)
 892:	bff1                	j	86e <malloc+0x88>
  hp->s.size = nu;
 894:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 898:	0541                	add	a0,a0,16
 89a:	00000097          	auipc	ra,0x0
 89e:	eca080e7          	jalr	-310(ra) # 764 <free>
  return freep;
 8a2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a6:	d971                	beqz	a0,87a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8aa:	4798                	lw	a4,8(a5)
 8ac:	fa9775e3          	bgeu	a4,s1,856 <malloc+0x70>
    if(p == freep)
 8b0:	00093703          	ld	a4,0(s2)
 8b4:	853e                	mv	a0,a5
 8b6:	fef719e3          	bne	a4,a5,8a8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8ba:	8552                	mv	a0,s4
 8bc:	00000097          	auipc	ra,0x0
 8c0:	b72080e7          	jalr	-1166(ra) # 42e <sbrk>
  if(p == (char*)-1)
 8c4:	fd5518e3          	bne	a0,s5,894 <malloc+0xae>
        return 0;
 8c8:	4501                	li	a0,0
 8ca:	bf45                	j	87a <malloc+0x94>
