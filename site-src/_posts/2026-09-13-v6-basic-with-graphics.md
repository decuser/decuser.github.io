---
title: "V6 BASIC with Graphics! in OpenSIMH: Reconstructing the VT01 Display Path"
tags: [unix v6 research-unix basic pdp-11 opensimh vt01]
---

Today's post is a dive into getting this:

![V6 BASIC draw, erase, and display](/assets/img/v6/v6vt/v6vt-2.png)

to work on a basic v6 instance running bas, the v6 version of BASIC:

![V6 BASIC graphics under OpenSIMH](/assets/img/v6/v6vt/v6vt-1.png)

### Background

Lately, my interests have revolved around language design. I wrote Aiki, pulled its heart out into Nezha, and in the process realized that I needed a deeper understanding of compilers and compiler design, and of how they came to be.

That led me to ALGOL 60 and the early compilers—or translators, as they were often called. I dug out my copies of the three Dragon Books and settled on the Green one for a deep dive into early techniques. In the process of reading and thinking about language translation, I realized that I should have a language in mind to compile.

Aiki has its appeal, but it is not a good first target. Nezha is small and constrained enough, but no, I thought, I want something more conventional. K&R C? Perhaps. V6 assembly? That has its appeal, that's for sure. I heart V6.

So I logged in to see what other candidates it might offer up and found SNOBOL, and then `bas`—V6 BASIC.

But BASIC, really? Surely this was just a sad little implementation of BASIC for V6 that didn't even do graphics.

I pulled up the source with little hope, and then saw: wait a minute. It *does* do graphics?

Nothing in V6 does graphics.

But there it was.

The V6 BASIC source contains `draw`, `erase`, and `display`, and writes its graphics output to `/dev/vt0`. The corresponding kernel driver is still present in `/usr/sys/dmr/vt.c` and identifies itself as:

    VT01 driver via DR11C to 11/20

At that point the compiler investigation became a hardware reconstruction problem.

<!--more-->

OpenSIMH has a `VT` device, but it is not the device this V6 driver expects. The existing OpenSIMH device emulates the VT11/VS60/GT40 family. The V6 driver instead expects a DR11-C interface connected to another PDP-11/20 handling the display.

Rather than emulate that entire historical arrangement, I wanted to see how little had to be reconstructed to make the original V6 software work unchanged.

The answer turned out to be: not very much.

The reconstructed path is:

    V6 BASIC
        |
        v
    /dev/vt0
        |
        v
    V6 vt.c
        |
        v
    DR11-C registers at 0167770
        |
        v
    OpenSIMH V6VT
        |
        v
    SIMH display window

The distinction matters. `V6VT` is not intended to be a complete VT01 emulator. It implements the V6-facing endpoint required by the original driver and BASIC implementation.

For the UNIX side I started from the pristine Lions Laboratory baseline:

https://github.com/decuser/lions-laboratory/blob/master/known-good/baseline-v6.tar.gz

The complete Lions Laboratory repository is here:

https://github.com/decuser/lions-laboratory

### OpenSIMH changes

The first part of the reconstruction was on the OpenSIMH side. I cloned the current source tree and installed its build dependencies:

    sudo apt install cmake cmake-data

    mkdir ~/v6vt-work
    cd ~/v6vt-work
    git clone https://github.com/open-simh/simh.git

    cd simh
    sudo sh .travis/deps.sh linux

The simulator-side change is deliberately small: add one PDP-11 device source file, register it with the PDP-11 simulator, and add it to the build.

In `makefile`, find:

    ${PDP11D}/pdp11_vt.c ${PDP11D}/pdp11_td.c ${PDP11D}/pdp11_io_lib.c \

and add `${PDP11D}/pdp11_v6vt.c`:

    ${PDP11D}/pdp11_vt.c ${PDP11D}/pdp11_v6vt.c ${PDP11D}/pdp11_td.c ${PDP11D}/pdp11_io_lib.c \

In `PDP11/pdp11_sys.c`, find:

    extern DEVICE vt_dev;

and add:

    extern DEVICE v6vt_dev;

Then find:

    #ifdef USE_DISPLAY
        &vt_dev,
    #endif

and change it to:

    #ifdef USE_DISPLAY
        &vt_dev,
        &v6vt_dev,
    #endif

Finally, create `PDP11/pdp11_v6vt.c`.

This is the complete device:

```c
#ifdef USE_DISPLAY
/* pdp11_v6vt.c: V6 VT01/DR11-C display endpoint

   This device implements the V6-facing endpoint used by /dev/vt0: the
   DR11-C register handshake plus the display command stream used by V6 BASIC.
   It renders onto SIMH's generic Tektronix 611-style display model.  It does
   not emulate the remote PDP-11/20 or deliver DR11-C interrupts.
*/

#include "pdp11_defs.h"
#include "display/display.h"

#define V6VT_IOBA       (IOPAGEBASE + 007770)   /* V6 0167770 */
#define V6VT_IOLN       004                     /* CSR, buffer */

/* Bits used by the V6 vt driver. */
#define V6VT_RQINT      000001
#define V6VT_BIENABL    000040
#define V6VT_SEOF       0100000

static uint16 v6vt_csr = 0;
static uint16 v6vt_buf = 0;

#define V6VT_PROTO_IDLE       0
#define V6VT_PROTO_ERASE      1
#define V6VT_PROTO_TEXT_XY    2
#define V6VT_PROTO_TEXT_SYNC  3
#define V6VT_PROTO_TEXT       4
#define V6VT_PROTO_DRAW       5

static uint8 v6vt_proto_state = V6VT_PROTO_IDLE;
static uint8 v6vt_proto_buf[8];
static uint32 v6vt_proto_count = 0;
static t_bool v6vt_display_open = FALSE;
static double v6vt_text_origin_x = 0.0;
static double v6vt_text_origin_y = 0.0;
static int v6vt_text_x = 0;
static int v6vt_text_y = 0;
static int v6vt_text_origin_px = 0;

static void v6vt_request (void);
static void v6vt_decode_byte (uint8 byte);
static void v6vt_decode_reset (void);
static t_bool v6vt_display_ensure (void);
static void v6vt_display_erase (void);
static void v6vt_display_draw (double x1, double y1, double x2, double y2);
static void v6vt_display_text_begin (double x, double y);
static void v6vt_display_text_char (uint8 byte);

t_stat v6vt_rd (int32 *data, int32 PA, int32 access);
t_stat v6vt_wr (int32 data, int32 PA, int32 access);
t_stat v6vt_reset (DEVICE *dptr);
const char *v6vt_description (DEVICE *dptr);

DIB v6vt_dib = {
    V6VT_IOBA, V6VT_IOLN, &v6vt_rd, &v6vt_wr,
    0, 0, 0, { NULL }
    };

UNIT v6vt_unit = {
    UDATA (NULL, 0, 0)
    };

REG v6vt_reg[] = {
    { ORDATAD (CSR, v6vt_csr, 16, "control/status register") },
    { ORDATAD (BUF, v6vt_buf, 16, "data buffer") },
    { GRDATA (DEVADDR, v6vt_dib.ba, DEV_RDX, 32, 0), REG_HRO },
    { NULL }
    };

MTAB v6vt_mod[] = {
    { MTAB_XTD|MTAB_VDV|MTAB_VALR, 004, "ADDRESS", "ADDRESS",
      &set_addr, &show_addr, NULL, "Bus address" },
    { 0 }
    };

#define DBG_IO      0001
#define DBG_DATA    0002
#define DBG_DECODE  0004
#define DBG_DISPLAY 0010

DEBTAB v6vt_deb[] = {
    { "IO",      DBG_IO,      "register reads and writes" },
    { "DATA",    DBG_DATA,    "V6 display request data" },
    { "DECODE",  DBG_DECODE,  "decoded V6 BASIC display operations" },
    { "DISPLAY", DBG_DISPLAY, "generic XY display operations" },
    { NULL, 0 }
    };

DEVICE v6vt_dev = {
    "V6VT", &v6vt_unit, v6vt_reg, v6vt_mod,
    1, 8, 16, 1, 8, 16,
    NULL, NULL, &v6vt_reset,
    NULL, NULL, NULL,
    &v6vt_dib, DEV_DIS | DEV_DISABLE | DEV_UBUS | DEV_DEBUG,
    0, v6vt_deb, NULL, NULL, NULL, NULL, NULL,
    &v6vt_description
    };

/*
 * Coordinates emitted by BASIC are signed 16-bit values in little-endian
 * byte order.  BASIC forms them as (coordinate - .5) * 4096, so converting
 * back to the user-visible 0..1 coordinate is n/4096 + .5.
 */
static double v6vt_coord (const uint8 *p)
{
    int16 n = (int16)((uint16)p[0] | ((uint16)p[1] << 8));
    return ((double)n / 4096.0) + 0.5;
}

static void v6vt_decode_reset (void)
{
    v6vt_proto_state = V6VT_PROTO_IDLE;
    v6vt_proto_count = 0;
}


/*
 * The Tektronix 611 entry already present in SIMH's generic display layer is
 * DIS_NG (512 x 512).  BASIC presents coordinates as 0..1, so map them onto
 * that raster only after the byte protocol has been decoded.
 */
static t_bool v6vt_display_ensure (void)
{
    if (v6vt_display_open)
        return TRUE;

    if (!display_init (DIS_NG, RES_FULL, &v6vt_dev)) {
        sim_debug (DBG_DISPLAY, &v6vt_dev, "display initialization failed\n");
        return FALSE;
        }

    v6vt_display_open = TRUE;
    sim_debug (DBG_DISPLAY, &v6vt_dev, "display opened (%d x %d)\n",
               display_xpoints (), display_ypoints ());
    return TRUE;
}

static int v6vt_display_coord (double v, int points)
{
    if (v < 0.0)
        v = 0.0;
    else if (v > 1.0)
        v = 1.0;

    return (int)(v * (double)(points - 1) + 0.5);
}

static void v6vt_display_erase (void)
{
    /* display_reset() is currently a no-op.  Recreate this display to clear it. */
    if (v6vt_display_open) {
        display_close (&v6vt_dev);
        v6vt_display_open = FALSE;
        }

    if (v6vt_display_ensure ()) {
        display_sync ();
        sim_debug (DBG_DISPLAY, &v6vt_dev, "erase\n");
        }
}


/*
 * Dot-matrix glyphs reused from SIMH's VT11 character generator.  They give
 * this endpoint the same simulator-native vector-display text appearance
 * without adding a second font implementation elsewhere in the display layer.
 */
static const unsigned char v6vt_dots[0200][6] = {
    { 0x8f, 0x50, 0x20, 0x10, 0x08, 0x07 },     /* 000 lambda */
    { 0x1e, 0x21, 0x22, 0x14, 0x0c, 0x13 },     /* 001 alpha */
    { 0x00, 0x18, 0x24, 0xff, 0x24, 0x18 },     /* 002 phi */
    { 0x83, 0xc5, 0xa9, 0x91, 0x81, 0xc3 },     /* 003 SIGMA */
    { 0x00, 0x46, 0xa9, 0x91, 0x89, 0x06 },     /* 004 delta */
    { 0x03, 0x05, 0x09, 0x11, 0x21, 0x7f },     /* 005 DELTA */
    { 0x00, 0x20, 0x20, 0x3f, 0x01, 0x01 },     /* 006 iota */
    { 0x46, 0x29, 0x11, 0x2e, 0x40, 0x80 },     /* 007 gamma */
    { 0x7f, 0x80, 0x80, 0x80, 0x80, 0x7f },     /* 010 intersect */
    { 0x40, 0x3c, 0x04, 0xff, 0x04, 0x78 },     /* 011 psi */
    { 0x00, 0x10, 0x10, 0x54, 0x10, 0x10 },     /* 012 divide by */
    { 0x00, 0x60, 0x90, 0x90, 0x60, 0x00 },     /* 013 degree */
    { 0x00, 0x01, 0x00, 0x10, 0x00, 0x01 },     /* 014 therefore */
    { 0x01, 0x02, 0x3c, 0x02, 0x02, 0x3c },     /* 015 mu */
    { 0x11, 0x7f, 0x91, 0x81, 0x41, 0x03 },     /* 016 pound sterling */
    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },     /* 017 SHIFT IN */
    { 0x20, 0x40, 0x7f, 0x40, 0x7f, 0x40 },     /* 020 pi */
    { 0x00, 0xff, 0x00, 0x00, 0xff, 0x00 },     /* 021 parallel */
    { 0x1d, 0x23, 0x40, 0x42, 0x25, 0x19 },     /* 022 OMEGA */
    { 0x1c, 0x22, 0x61, 0x51, 0x4e, 0x40 },     /* 023 sigma */
    { 0x20, 0x40, 0x40, 0x7f, 0x40, 0x40 },     /* 024 UPSILON */
    { 0x00, 0x1c, 0x2a, 0x49, 0x49, 0x00 },     /* 025 epsilon */
    { 0x10, 0x38, 0x54, 0x10, 0x10, 0x10 },     /* 026 left arrow */
    { 0x10, 0x10, 0x10, 0x54, 0x38, 0x10 },     /* 027 right arrow */
    { 0x00, 0x20, 0x40, 0xfe, 0x40, 0x20 },     /* 030 up arrow */
    { 0x00, 0x04, 0x02, 0x7f, 0x02, 0x04 },     /* 031 down arrow */
    { 0x00, 0xff, 0x80, 0x80, 0x80, 0x80 },     /* 032 GAMMA */
    { 0x00, 0x01, 0x01, 0xff, 0x01, 0x01 },     /* 033 perpendicular */
    { 0x2a, 0x2c, 0x28, 0x38, 0x68, 0xa8 },     /* 034 unequal */
    { 0x24, 0x48, 0x48, 0x24, 0x24, 0x48 },     /* 035 approx equal */
    { 0x00, 0x20, 0x10, 0x08, 0x10, 0x20 },     /* 036 vel */
    { 0xff, 0x81, 0x81, 0x81, 0x81, 0xff },     /* 037 box */
    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },     /* 040 space */
    { 0x00, 0x00, 0x00, 0xfd, 0x00, 0x00 },     /* 041 ! */
    { 0x00, 0xe0, 0x00, 0x00, 0xe0, 0x00 },     /* 042 " */
    { 0x00, 0x24, 0xff, 0x24, 0xff, 0x24 },     /* 043 # */
    { 0x22, 0x52, 0xff, 0x52, 0x4c, 0x00 },     /* 044 $ */
    { 0x42, 0xa4, 0x48, 0x12, 0x25, 0x42 },     /* 045 % */
    { 0x66, 0x99, 0x99, 0x66, 0x0a, 0x11 },     /* 046 & */
    { 0x00, 0x00, 0x20, 0x40, 0x80, 0x00 },     /* 047 ' */
    { 0x00, 0x00, 0x3c, 0x42, 0x81, 0x00 },     /* 050 ( */
    { 0x00, 0x00, 0x81, 0x42, 0x3c, 0x00 },     /* 051 ) */
    { 0x00, 0x44, 0x28, 0xf0, 0x28, 0x44 },     /* 052 * */
    { 0x00, 0x10, 0x10, 0x7c, 0x10, 0x10 },     /* 053 + */
    { 0x00, 0x01, 0x06, 0x00, 0x00, 0x00 },     /* 054 , */
    { 0x00, 0x10, 0x10, 0x10, 0x10, 0x10 },     /* 055 - */
    { 0x00, 0x00, 0x06, 0x06, 0x00, 0x00 },     /* 056 . */
    { 0x02, 0x04, 0x08, 0x10, 0x20, 0x40 },     /* 057 / */
    { 0x7e, 0x85, 0x89, 0x91, 0xa1, 0x7e },     /* 060 0 */
    { 0x00, 0x41, 0xff, 0x01, 0x00, 0x00 },     /* 061 1 */
    { 0x47, 0x89, 0x91, 0x91, 0x91, 0x61 },     /* 062 2 */
    { 0x42, 0x81, 0x91, 0xb1, 0xd1, 0x8e },     /* 063 3 */
    { 0x0c, 0x14, 0x24, 0x44, 0xff, 0x04 },     /* 064 4 */
    { 0xf2, 0x91, 0x91, 0x91, 0x91, 0x8e },     /* 065 5 */
    { 0x3c, 0x46, 0x89, 0x89, 0x89, 0x46 },     /* 066 6 */
    { 0x40, 0x87, 0x88, 0x90, 0xa0, 0xc0 },     /* 067 7 */
    { 0x6e, 0x91, 0x91, 0x91, 0x91, 0x6e },     /* 070 8 */
    { 0x62, 0x91, 0x91, 0x91, 0x62, 0x3c },     /* 071 9 */
    { 0x00, 0x66, 0x66, 0x00, 0x00, 0x00 },     /* 072 : */
    { 0x00, 0x00, 0x61, 0x66, 0x00, 0x00 },     /* 073 ; */
    { 0x00, 0x18, 0x24, 0x42, 0x81, 0x00 },     /* 074 < */
    { 0x00, 0x28, 0x28, 0x28, 0x28, 0x28 },     /* 075 = */
    { 0x00, 0x81, 0x42, 0x24, 0x18, 0x00 },     /* 076 > */
    { 0x00, 0x40, 0x80, 0x9d, 0x90, 0x60 },     /* 077 ? */
    { 0x3c, 0x42, 0x91, 0xa9, 0xa9, 0x72 },     /* 100 @ */
    { 0x3f, 0x48, 0x88, 0x88, 0x48, 0x3f },     /* 101 A */
    { 0x81, 0xff, 0x91, 0x91, 0x91, 0x6e },     /* 102 B */
    { 0x3c, 0x42, 0x81, 0x81, 0x81, 0x42 },     /* 103 C */
    { 0x81, 0xff, 0x81, 0x81, 0x42, 0x3c },     /* 104 D */
    { 0x81, 0xff, 0x91, 0x91, 0x91, 0xc3 },     /* 105 E */
    { 0x81, 0xff, 0x91, 0x90, 0x80, 0xc0 },     /* 106 F */
    { 0x3c, 0x42, 0x81, 0x89, 0x89, 0x4f },     /* 107 G */
    { 0xff, 0x10, 0x10, 0x10, 0x10, 0xff },     /* 110 H */
    { 0x00, 0x81, 0xff, 0x81, 0x00, 0x00 },     /* 111 I */
    { 0x0e, 0x01, 0x01, 0x81, 0xfe, 0x80 },     /* 112 J */
    { 0xff, 0x08, 0x10, 0x28, 0x44, 0x83 },     /* 113 K */
    { 0x81, 0xff, 0x81, 0x01, 0x01, 0x03 },     /* 114 L */
    { 0xff, 0x40, 0x30, 0x30, 0x40, 0xff },     /* 115 M */
    { 0xff, 0x20, 0x10, 0x08, 0x04, 0xff },     /* 116 N */
    { 0x3c, 0x42, 0x81, 0x81, 0x42, 0x3c },     /* 117 O */
    { 0x81, 0xff, 0x90, 0x90, 0x90, 0x60 },     /* 120 P */
    { 0x3c, 0x42, 0x81, 0x8f, 0x42, 0x3d },     /* 121 Q */
    { 0x81, 0xff, 0x90, 0x98, 0x94, 0x63 },     /* 122 R */
    { 0x22, 0x51, 0x91, 0x91, 0x89, 0x46 },     /* 123 S */
    { 0xc0, 0x80, 0x81, 0xff, 0x81, 0xc0 },     /* 124 T */
    { 0xfe, 0x01, 0x01, 0x01, 0x01, 0xfe },     /* 125 U */
    { 0xff, 0x02, 0x04, 0x08, 0x10, 0xe0 },     /* 126 V */
    { 0xff, 0x02, 0x0c, 0x0c, 0x02, 0xff },     /* 127 W */
    { 0xc3, 0x24, 0x18, 0x18, 0x24, 0xc3 },     /* 130 X */
    { 0x00, 0xe0, 0x10, 0x0f, 0x10, 0xe0 },     /* 131 Y */
    { 0x83, 0x85, 0x89, 0x91, 0xa1, 0xc1 },     /* 132 Z */
    { 0x00, 0x00, 0xff, 0x81, 0x81, 0x00 },     /* 133 [ */
    { 0x00, 0x40, 0x20, 0x10, 0x08, 0x04 },     /* 134 \ */
    { 0x00, 0x00, 0x81, 0x81, 0xff, 0x00 },     /* 135 ] */
    { 0x00, 0x10, 0x20, 0x40, 0x20, 0x10 },     /* 136 ^ */
    { 0x01, 0x01, 0x01, 0x01, 0x01, 0x00 },     /* 137 _ */
    /* for all lowercase characters, first column is just a "descender" flag: */
    { 0x00, 0x00, 0x80, 0x40, 0x20, 0x00 },     /* 140 ` */
    { 0x00, 0x26, 0x29, 0x29, 0x2a, 0x1f },     /* 141 a */
    { 0x00, 0xff, 0x12, 0x21, 0x21, 0x1e },     /* 142 b */
    { 0x00, 0x1e, 0x21, 0x21, 0x21, 0x12 },     /* 143 c */
    { 0x00, 0x1e, 0x21, 0x21, 0x12, 0xff },     /* 144 d */
    { 0x00, 0x1e, 0x29, 0x29, 0x29, 0x19 },     /* 145 e */
    { 0x00, 0x20, 0x7f, 0xa0, 0xa0, 0x80 },     /* 146 f */
    { 0x01, 0x78, 0x85, 0x85, 0x49, 0xfe },     /* 147 g */
    { 0x00, 0xff, 0x10, 0x20, 0x20, 0x1f },     /* 150 h */
    { 0x00, 0x00, 0x21, 0xbf, 0x01, 0x00 },     /* 151 i */
    { 0x01, 0x02, 0x01, 0x81, 0xfe, 0x00 },     /* 152 j */
    { 0x00, 0xff, 0x08, 0x14, 0x22, 0x21 },     /* 153 k */
    { 0x00, 0x00, 0xfe, 0x01, 0x01, 0x00 },     /* 154 l */
    { 0x00, 0x3f, 0x20, 0x3f, 0x20, 0x3f },     /* 155 m */
    { 0x00, 0x3f, 0x10, 0x20, 0x20, 0x1f },     /* 156 n */
    { 0x00, 0x1e, 0x21, 0x21, 0x21, 0x1e },     /* 157 o */
    { 0x01, 0xff, 0x48, 0x84, 0x84, 0x78 },     /* 160 p */
    { 0x01, 0x78, 0x84, 0x84, 0x48, 0xff },     /* 161 q */
    { 0x00, 0x3f, 0x08, 0x10, 0x20, 0x20 },     /* 162 r */
    { 0x00, 0x12, 0x29, 0x29, 0x29, 0x26 },     /* 163 s */
    { 0x00, 0x20, 0xfe, 0x21, 0x21, 0x00 },     /* 164 t */
    { 0x00, 0x3e, 0x01, 0x01, 0x02, 0x3f },     /* 165 u */
    { 0x00, 0x3c, 0x02, 0x01, 0x02, 0x3c },     /* 166 v */
    { 0x00, 0x3e, 0x01, 0x1e, 0x01, 0x3e },     /* 167 w */
    { 0x00, 0x23, 0x14, 0x08, 0x14, 0x23 },     /* 170 x */
    { 0x01, 0xf8, 0x05, 0x05, 0x09, 0xfe },     /* 171 y */
    { 0x00, 0x23, 0x25, 0x29, 0x31, 0x21 },     /* 172 z */
    { 0x00, 0x18, 0x66, 0x81, 0x81, 0x00 },     /* 173 { */
    { 0x00, 0x00, 0xe7, 0x00, 0x00, 0x00 },     /* 174 | */
    { 0x00, 0x00, 0x81, 0x81, 0x66, 0x18 },     /* 175 } */
    { 0x00, 0x0c, 0x10, 0x08, 0x04, 0x18 },     /* 176 ~ */
    { 0x00, 0xff, 0xff, 0xff, 0xff, 0xff }      /* 177 rubout */
    };

static void v6vt_display_draw (double x1, double y1, double x2, double y2)
{
    int px1, py1, px2, py2;

    if (!v6vt_display_ensure ())
        return;

    px1 = v6vt_display_coord (x1, display_xpoints ());
    py1 = v6vt_display_coord (y1, display_ypoints ());
    px2 = v6vt_display_coord (x2, display_xpoints ());
    py2 = v6vt_display_coord (y2, display_ypoints ());

    display_line (px1, py1, px2, py2, DISPLAY_INT_MAX);
    display_sync ();
    sim_debug (DBG_DISPLAY, &v6vt_dev,
               "line (%d,%d) -> (%d,%d)\n", px1, py1, px2, py2);
}

static void v6vt_display_text_begin (double x, double y)
{
    if (!v6vt_display_ensure ())
        return;

    v6vt_text_origin_x = x;
    v6vt_text_origin_y = y;
    v6vt_text_origin_px = v6vt_display_coord (x, display_xpoints ());
    v6vt_text_x = v6vt_text_origin_px;
    v6vt_text_y = v6vt_display_coord (y, display_ypoints ());

    sim_debug (DBG_DISPLAY, &v6vt_dev, "text origin (%d,%d)\n",
               v6vt_text_x, v6vt_text_y);
}

static void v6vt_display_text_char (uint8 byte)
{
    const unsigned char *glyph;
    int col, row;

    if (!v6vt_display_ensure ())
        return;

    switch (byte) {
    case '\r':
        v6vt_text_x = v6vt_text_origin_px;
        return;

    case '\n':
        v6vt_text_x = v6vt_text_origin_px;
        v6vt_text_y -= 18;
        return;

    case '\b':
        v6vt_text_x -= 12;
        if (v6vt_text_x < 0)
            v6vt_text_x = 0;
        return;

    case '\t':
        v6vt_text_x += 48;
        return;

    default:
        break;
        }

    if (byte < 040 || byte >= 0177)
        return;

    glyph = v6vt_dots[byte];
    for (col = 0; col < 6; col++) {
        for (row = 0; row < 8; row++) {
            if (glyph[col] & (1u << row)) {
                int x = v6vt_text_x + col * 2;
                int y = v6vt_text_y + row * 2;
                display_point (x,     y,     DISPLAY_INT_MAX, 0);
                display_point (x + 1, y,     DISPLAY_INT_MAX, 0);
                display_point (x,     y + 1, DISPLAY_INT_MAX, 0);
                display_point (x + 1, y + 1, DISPLAY_INT_MAX, 0);
                }
            }
        }

    v6vt_text_x += 12;
    display_sync ();
    sim_debug (DBG_DISPLAY, &v6vt_dev, "char '%c' at (%d,%d)\n",
               byte, v6vt_text_x - 12, v6vt_text_y);
}

static void v6vt_decode_byte (uint8 byte)
{
    switch (v6vt_proto_state) {
    case V6VT_PROTO_IDLE:
        switch (byte) {
        case 001:
            v6vt_proto_state = V6VT_PROTO_ERASE;
            break;

        case 002:
            v6vt_proto_state = V6VT_PROTO_TEXT_XY;
            v6vt_proto_count = 0;
            break;

        case 003:
            v6vt_proto_state = V6VT_PROTO_DRAW;
            v6vt_proto_count = 0;
            break;

        case 000:
            sim_debug (DBG_DECODE, &v6vt_dev, "display end\n");
            break;

        default:
            sim_debug (DBG_DECODE, &v6vt_dev,
                       "unrecognized command byte %03o (0x%02X)\n",
                       byte, byte);
            break;
            }
        break;

    case V6VT_PROTO_ERASE:
        if (byte == 001) {
            sim_debug (DBG_DECODE, &v6vt_dev, "erase\n");
            v6vt_display_erase ();
            }
        else
            sim_debug (DBG_DECODE, &v6vt_dev,
                       "unrecognized 001 sequence: %03o (0x%02X)\n",
                       byte, byte);
        v6vt_decode_reset ();
        break;

    case V6VT_PROTO_TEXT_XY:
        v6vt_proto_buf[v6vt_proto_count++] = byte;
        if (v6vt_proto_count == 4) {
            double x = v6vt_coord (&v6vt_proto_buf[0]);
            double y = v6vt_coord (&v6vt_proto_buf[2]);

            sim_debug (DBG_DECODE, &v6vt_dev,
                       "display begin at (%.6f, %.6f)\n", x, y);
            v6vt_display_text_begin (x, y);
            v6vt_proto_state = V6VT_PROTO_TEXT_SYNC;
            v6vt_proto_count = 0;
            }
        break;

    case V6VT_PROTO_TEXT_SYNC:
        /* BASIC emits 001,003 after the display origin, then text bytes. */
        if (v6vt_proto_count == 0 && byte == 001) {
            v6vt_proto_count = 1;
            break;
            }
        if (v6vt_proto_count == 1 && byte == 003) {
            v6vt_proto_state = V6VT_PROTO_TEXT;
            v6vt_proto_count = 0;
            break;
            }
        sim_debug (DBG_DECODE, &v6vt_dev,
                   "bad display sync byte %03o (0x%02X)\n", byte, byte);
        v6vt_decode_reset ();
        break;

    case V6VT_PROTO_TEXT:
        if (byte == 000) {
            sim_debug (DBG_DECODE, &v6vt_dev, "display end\n");
            v6vt_decode_reset ();
            }
        else {
            if (byte >= 040 && byte < 0177)
                sim_debug (DBG_DECODE, &v6vt_dev, "display char '%c'\n", byte);
            else
                sim_debug (DBG_DECODE, &v6vt_dev,
                           "display byte %03o (0x%02X)\n", byte, byte);
            v6vt_display_text_char (byte);
            }
        break;

    case V6VT_PROTO_DRAW:
        v6vt_proto_buf[v6vt_proto_count++] = byte;
        if (v6vt_proto_count == 8) {
            double x1 = v6vt_coord (&v6vt_proto_buf[0]);
            double y1 = v6vt_coord (&v6vt_proto_buf[2]);
            double x2 = v6vt_coord (&v6vt_proto_buf[4]);
            double y2 = v6vt_coord (&v6vt_proto_buf[6]);

            sim_debug (DBG_DECODE, &v6vt_dev,
                       "draw (%.6f, %.6f) -> (%.6f, %.6f)\n",
                       x1, y1, x2, y2);
            v6vt_display_draw (x1, y1, x2, y2);
            v6vt_decode_reset ();
            }
        break;

    default:
        v6vt_decode_reset ();
        break;
        }
}

/*
 * V6 writes a value to BUF and then sets CSR<RQINT>.  We consume the
 * request synchronously and clear RQINT before returning.
 */
static void v6vt_request (void)
{
    if (v6vt_buf & V6VT_SEOF) {
        sim_debug (DBG_DATA, &v6vt_dev, "request SEOF (BUF=%06o)\n", v6vt_buf);
        sim_debug (DBG_DECODE, &v6vt_dev, "session end\n");
        v6vt_decode_reset ();
        }
    else {
        uint8 byte = (uint8)(v6vt_buf & 0377);
        sim_debug (DBG_DATA, &v6vt_dev, "request byte %03o (0x%02X)\n",
                   byte, byte);
        v6vt_decode_byte (byte);
        }

    v6vt_csr &= ~V6VT_RQINT;
}

t_stat v6vt_rd (int32 *data, int32 PA, int32 access)
{
    switch (PA & 02) {
    case 00:
        *data = v6vt_csr;
        sim_debug (DBG_IO, &v6vt_dev, "read CSR = %06o\n", *data);
        return SCPE_OK;

    case 02:
        *data = v6vt_buf;
        sim_debug (DBG_IO, &v6vt_dev, "read BUF = %06o\n", *data);
        return SCPE_OK;
        }

    return SCPE_NXM;
}

t_stat v6vt_wr (int32 data, int32 PA, int32 access)
{
    switch (PA & 02) {
    case 00:
        v6vt_csr = data & DMASK;
        sim_debug (DBG_IO, &v6vt_dev, "write CSR = %06o\n", v6vt_csr);
        if (v6vt_csr & V6VT_RQINT)
            v6vt_request ();
        return SCPE_OK;

    case 02:
        v6vt_buf = data & DMASK;
        sim_debug (DBG_IO, &v6vt_dev, "write BUF = %06o\n", v6vt_buf);
        return SCPE_OK;
        }

    return SCPE_NXM;
}

t_stat v6vt_reset (DEVICE *dptr)
{
    v6vt_csr = 0;
    v6vt_buf = 0;
    v6vt_decode_reset ();
    if (v6vt_display_open) {
        display_close (&v6vt_dev);
        v6vt_display_open = FALSE;
        }
    return SCPE_OK;
}

const char *v6vt_description (DEVICE *dptr)
{
    return "V6 VT01/DR11-C display endpoint";
}
#endif
```
Build it

`make pdp11`

You should see:

```
 Running internal register sanity checks on PDP-11 simulator.
*** Good Registers in PDP-11 simulator.
```

If so, install it somewhere useful:

`cp BIN/pdp11 ~/bin/`

### V6 Changes

The other half of the work is inside the pristine V6 baseline.
```
cd ~/v6vt-work
wget -O baseline-v6.tar.gz \
  https://github.com/decuser/lions-laboratory/raw/refs/heads/master/known-good/baseline-v6.tar.gz
cd  ~/v6vt-work/baseline-v6
ls
ls
boot.ini  rk0  rk1  rk2  rk3
```

Start pdp11

```
pdp11 boot.ini
PDP-11 simulator Open SIMH V4.1-0 Current        git commit id: a1f57fa3+uncommitted-changes
Disabling XQ
/home/wsenn/v6vt-work/baseline-v6/boot.ini-14> attach ptr ptr.txt
%SIM-INFO: PTR: creating new file
/home/wsenn/v6vt-work/baseline-v6/boot.ini-15> attach ptp ptp.txt
%SIM-INFO: PTP: creating new file
/home/wsenn/v6vt-work/baseline-v6/boot.ini-16> attach lpt lpt.txt
%SIM-INFO: LPT: creating new file
@unix

login: root
#
```


Although `/usr/sys/dmr/vt.c` is present, the driver object is not included in the baseline device-driver library:

```
# ar t /usr/sys/lib2
bio.o
tty.o
dc.o
dn.o
dp.o
kl.o
mem.o
pc.o
rf.o
rk.o
tc.o
tm.o
partab.o
rp.o
lp.o
dhdm.o
dh.o
dhfdm.o
sys.o
hp.o
ht.o
hs.o
```

There is no `vt.o`.

Following the V6 configuration procedure, I compiled the existing driver and added it to `lib2`:

```
chdir /usr/sys/dmr
cc -c -O vt.c
ar r ../lib2 vt.o
rm vt.o
```

The stock `mkconf` also does not know about `vt`, so I added it as another character device.

```
chdir /usr/sys/conf
ed mkconf.c
8726
37p
        0
37i
        "vt",
.
36,38p
        "ht",
        "vt",
        0

251,p
        "dl",
251i
        "vt",
        0,      0,      CHAR,
        "",
        "",
        "",
        "",
        "\t&vtopen,   &vtclose,  &nodev,    &vtwrite,  &nodev,",
.
251,259p
        "vt",
        0,      0,      CHAR,
        "",
        "",
        "",
        "",
        "\t&vtopen,   &vtclose,  &nodev,    &vtwrite,  &nodev,",

        "dl",

w
8897
q
```

I saved the file, rebuilt `mkconf`, and generated a new system configuration:

```
cc mkconf.c
mv a.out mkconf

./mkconf
rk
tm
pc
lp
vt
done
```

As usual, `mkconf` creates `c.c` and `l.s`. I inspected both before linking the kernel:

```
cat c.c
cat l.s
```

In this configuration VT is character-device major 16.

I then rebuilt the kernel:

```
as m40.s
mv a.out m40.o

cc -c c.c
as l.s

ld -x a.out m40.o c.o ../lib1 ../lib2
mv a.out /unix.vt

sync
sync
sync
```

and created the special file:

```
/etc/mknod /dev/vt0 c 16 0
chmod 666 /dev/vt0
```

Pause the sim and exit

```
CTL-e
q
```

On the OpenSIMH side, normal operation requires only:

`set v6vt enable`

Debugging is optional. To keep simulator diagnostics out of the V6 console, I send them to a host file:

```
set debug v6vt-debug.log
set v6vt debug=decode;display
```

For the full register and protocol trace:

`set v6vt debug=io;data;decode;display`

```
vi boot.ini (and v6vt entries after tm)
set cpu 11/40
set cpu idle
set tto 7b
;set tm0 locked
set v6vt enable
; set debug v6vt-debug.log
; set v6vt debug=decode;display
; set v6vt debug=io;data;decode;display
; set v6vt nodebug
; set nodebug
;attach tm0 dist.tap
set rk0 en noautosize
set rk1 en noautosize
set rk2 en noautosize
set rk3 en noautosize
attach rk0 rk0
attach rk1 rk1
attach rk2 rk2
attach rk3 rk3
attach ptr ptr.txt
attach ptp ptp.txt
attach lpt lpt.txt
;dep system sr 173030
boot rk0
```

### Running in bas

Boot normally:

```
~/v6vt-work/baseline-v6 $ pdp11 boot.ini

PDP-11 simulator Open SIMH V4.1-0 Current        git commit id: a1f57fa3+uncommitted-changes
Disabling XQ
@unix.vt

login: root
# 
```

and the original V6 BASIC interpreter can use the reconstructed display path without modification.

```
bas
10 erase
20 draw .2 .2 0
30 draw .8 .2 1
40 draw .8 .8 1
50 draw .2 .8 1
60 draw .2 .2 1
70 draw .35 .5 0
80 display "UNIX V6 BASIC"
90 done
run
```

produces a square with text in the SIMH graphics window:

![V6 BASIC draw, erase, and display](/assets/img/v6/v6vt/v6vt-2.png)

The same program can be saved as a normal V6 BASIC source file:

```
ed hello.bas
a
10 erase
20 draw .2 .2 0
30 draw .8 .2 1
40 draw .8 .8 1
50 draw .2 .8 1
60 draw .2 .2 1
70 draw .35 .5 0
80 display "UNIX V6 BASIC"
90 done
run
.
w
q

145
```

and run directly:

`bas hello.bas`

If you want to destroy the graphics display, it's in simh:

```
CTL-e
sim> set v6vt disable
```

### Conclusions

The interesting part for me is that essentially none of the original V6 software needs to know that the historical display hardware is gone.

The original BASIC emits the same command stream. The original kernel driver writes to the same address. `/dev/vt0` remains the interface seen by the application.

Only the hardware side of that boundary has been replaced.

This is not a complete VT01 reconstruction, but it is enough to make the graphics support already present in Sixth Edition UNIX BASIC work again under OpenSIMH.

And now I can go back to figuring out whether BASIC is the language I wanted to compile in the first place.

*post added 2026-09-13 17:19:00 -0500*
