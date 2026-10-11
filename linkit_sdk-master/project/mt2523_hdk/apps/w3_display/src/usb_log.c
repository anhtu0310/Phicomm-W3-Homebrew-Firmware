#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
#include "hal.h"
#include "usb.h"
#include "usb_custom_def.h"
#include "usbacm_drv.h"
#include "usbacm_adap.h"
#include "bmd.h"
#include "usb_log.h"

#define LOG_PORT 0                         /* first CDC-ACM interface */

static bool s_open;
/* ulog() is called from several tasks (display, BT): one writer at a time,
 * or lines interleave and the USB transmit ring can be corrupted. */
static SemaphoreHandle_t s_tx_lock;
/* Long enough for a 64-byte bootloader packet as hex (AT+TPBL). */
static char s_line[200];
static uint32_t s_line_len;

/* Same steps as port service's serial_port_usb_init(), for one port. */
static void acm_open(void)
{
    USB2UART_init();

    if (USB2UARTPort[LOG_PORT].RingBuffers.rx_buffer == NULL) {
        USB2UARTPort[LOG_PORT].RingBuffers.rx_buffer = (uint8_t *)USB_Get_Memory(USB_RX_RING_BUFFER_1_SIZE);
    }
    Buf_init(&(USB2UARTPort[LOG_PORT].Rx_Buffer), USB2UARTPort[LOG_PORT].RingBuffers.rx_buffer,
             USB_RX_RING_BUFFER_1_SIZE);
    if (USB2UARTPort[LOG_PORT].RingBuffers.tx_buffer == NULL) {
        USB2UARTPort[LOG_PORT].RingBuffers.tx_buffer = (uint8_t *)USB_Get_Memory(USB_TX_RING_BUFFER_1_SIZE);
    }
    Buf_init(&(USB2UARTPort[LOG_PORT].Tx_Buffer), USB2UARTPort[LOG_PORT].RingBuffers.tx_buffer,
             USB_TX_RING_BUFFER_1_SIZE);

    USB2UARTPort[LOG_PORT].initialized = true;
    g_UsbACM[LOG_PORT].send_Txilm = false;
    g_UsbACM[LOG_PORT].send_Rxilm = true;
    g_UsbACM[LOG_PORT].transfer_type = CDC_NORMAL;
    g_UsbACM[LOG_PORT].config_send_Txilm = false;

    if (g_UsbACM[LOG_PORT].txpipe != NULL) {
        hal_usb_enable_tx_endpoint(g_UsbACM[LOG_PORT].txpipe->byEP, HAL_USB_EP_TRANSFER_BULK, HAL_USB_EP_USE_ONLY_DMA, false);
        hal_usb_enable_rx_endpoint(g_UsbACM[LOG_PORT].rxpipe->byEP, HAL_USB_EP_TRANSFER_BULK, HAL_USB_EP_USE_NO_DMA, false);
        USB_UnMask_COM_Intr(LOG_PORT);
    }
}

static bool ready(void)
{
    return s_open && USB_Get_Device_State() == DEVSTATE_CONFIG;
}

static void write_str(const char *s)
{
    if (!ready() || s_tx_lock == NULL) {
        return;
    }
    xSemaphoreTake(s_tx_lock, portMAX_DELAY);
    USB2UART_PutBytes(LOG_PORT, (uint8_t *)s, (uint16_t)strlen(s));
    xSemaphoreGive(s_tx_lock);
}

void usb_log_init(void)
{
    s_tx_lock = xSemaphoreCreateMutex();
    usb_boot_init();
}

void ulog(const char *fmt, ...)
{
    char buf[160];
    int n;
    va_list ap;

    if (!ready()) {
        return;
    }
    n = snprintf(buf, sizeof(buf), "[%7lu] ", (unsigned long)(xTaskGetTickCount() * portTICK_RATE_MS));
    va_start(ap, fmt);
    vsnprintf(buf + n, sizeof(buf) - n - 2, fmt, ap);
    va_end(ap);
    strcat(buf, "\r\n");
    write_str(buf);
}

__attribute__((weak)) bool usb_log_app_command(const char *line)
{
    (void)line;
    return false;
}

void usb_log_write(const char *s)
{
    write_str(s);
}

static void handle_line(const char *line)
{
    if (usb_log_app_command(line)) {
        return;
    }
    if (strncmp(line, "AT+EWDT=1", 9) == 0) {
        write_str("OK\r\nrebooting\r\n");
        vTaskDelay(50 / portTICK_RATE_MS);
        /* Disconnect from the PC first (USB block off drops the D+ pull-up)
         * so the host sees a clean unplug. Resetting with the link still up
         * often made the Boot ROM's ~1 s download window go unnoticed, and the
         * watch came straight back into this firmware. */
        hal_usb_deinit();
        vTaskDelay(300 / portTICK_RATE_MS);
        hal_wdt_software_reset();
    } else if (strcmp(line, "AT") == 0) {
        write_str("OK\r\n");
    } else if (line[0]) {
        write_str("ERROR\r\n");
    }
}

void usb_log_poll(void)
{
    uint8_t buf[16];
    uint16_t n, i;

    if (USB_Get_Device_State() != DEVSTATE_CONFIG) {
        s_open = false;
        return;
    }
    if (!s_open) {
        acm_open();
        s_open = true;
        write_str("\r\nw3_display USB log ready\r\n");
    }
    while ((n = USB2UART_GetBytes(LOG_PORT, buf, sizeof(buf))) > 0) {
        for (i = 0; i < n; i++) {
            if (buf[i] == '\r' || buf[i] == '\n') {
                s_line[s_line_len] = 0;
                handle_line(s_line);
                s_line_len = 0;
            } else if (buf[i] < 0x20 || buf[i] > 0x7E) {
                /* Binary bytes (e.g. ModemManager's QCDM probe) are not part
                 * of a command; drop the line so the next AT command starts
                 * clean instead of being glued onto the junk. */
                s_line_len = 0;
            } else if (s_line_len < sizeof(s_line) - 1) {
                s_line[s_line_len++] = (char)buf[i];
            }
        }
    }
}
