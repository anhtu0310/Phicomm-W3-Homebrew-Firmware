/*
 * Minimal USB CDC-ACM log console (no port service / NVDM needed).
 *
 * Enumerates as 0e8d:0023 (same as the stock firmware), first ACM port
 * (/dev/ttyACM0 on Linux). Lines received on it are handled as commands:
 *   AT            -> OK
 *   AT+EWDT=1     -> reboot (with USB attached this opens the BROM download
 *                    window, so tools/mt2523_flash.py --reboot-from works)
 */
#ifndef __USB_LOG_H__
#define __USB_LOG_H__

#include <stdbool.h>

void usb_log_init(void);
/* Call periodically: opens the port once the host configured the device,
 * and processes received command lines. */
void usb_log_poll(void);
void ulog(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
void usb_log_write(const char *s);
/* Optional application hook for extra commands; return true if handled. */
bool usb_log_app_command(const char *line);

#endif /* __USB_LOG_H__ */
