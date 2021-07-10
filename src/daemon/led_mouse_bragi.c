#include "led.h"
#include "notify.h"
#include "profile.h"
#include "usb.h"
#include "bragi_proto.h"

#define N_BRAGI_MOUSE_ZONES 9

// Compare two light structures, ignore keys
static int rgbcmp(const lighting* lhs, const lighting* rhs){
    return memcmp(lhs->r + LED_MOUSE, rhs->r + LED_MOUSE, N_BRAGI_MOUSE_ZONES) || memcmp(lhs->g + LED_MOUSE, rhs->g + LED_MOUSE, N_BRAGI_MOUSE_ZONES) || memcmp(lhs->b + LED_MOUSE, rhs->b + LED_MOUSE, N_BRAGI_MOUSE_ZONES);
}

int updatergb_mouse_bragi(usbdevice* kb, int force){
    if(!kb->active)
        return 0;
    lighting* lastlight = &kb->profile->lastlight;
    lighting* newlight = &kb->profile->currentmode->light;
    // Don't do anything if the lighting hasn't changed
    if(!force && !lastlight->forceupdate && !newlight->forceupdate
            && !rgbcmp(lastlight, newlight))
        return 0;
    lastlight->forceupdate = newlight->forceupdate = 0;

    uchar pkt[64] = {BRAGI_MAGIC, BRAGI_WRITE_DATA, BRAGI_LIGHTING_HANDLE, 0x12};

    // Back
    pkt[7] = newlight->r[LED_MOUSE + 1];
    pkt[13] = newlight->g[LED_MOUSE + 1];
    pkt[19] = newlight->b[LED_MOUSE + 1];

    // Wheel
    pkt[8] = newlight->r[LED_MOUSE + 3];
    pkt[14] = newlight->g[LED_MOUSE + 3];
    pkt[20] = newlight->b[LED_MOUSE + 3];

    // Front
    pkt[9] = newlight->r[LED_MOUSE];
    pkt[15] = newlight->g[LED_MOUSE];
    pkt[21] = newlight->b[LED_MOUSE];

    // DPI 0
    pkt[10] = newlight->r[LED_MOUSE + 6];
    pkt[16] = newlight->g[LED_MOUSE + 6];
    pkt[22] = newlight->b[LED_MOUSE + 6];

    // DPI 1
    pkt[11] = newlight->r[LED_MOUSE + 7];
    pkt[17] = newlight->g[LED_MOUSE + 7];
    pkt[23] = newlight->b[LED_MOUSE + 7];

    // DPI 2
    pkt[12] = newlight->r[LED_MOUSE + 8];
    pkt[18] = newlight->g[LED_MOUSE + 8];
    pkt[24] = newlight->b[LED_MOUSE + 8];

    uchar response[64] = {0};
    if(!usbrecv(kb, pkt, response))
        return 1;
#warning "Check if the device responded with success"
    memcpy(lastlight, newlight, sizeof(lighting));
    return 0;
}
