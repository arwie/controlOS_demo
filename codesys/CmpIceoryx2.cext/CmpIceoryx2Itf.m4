/**
 * <interfacename>CmpIceoryx2</interfacename>
 * <description></description>
 *
 * <copyright></copyright>
 */

SET_INTERFACE_NAME(`CmpIceoryx2')

/** EXTERN LIB SECTION BEGIN **/
/*  Comments are ignored for m4 compiler so restructured text can be used. changecom(`/*', `*/') */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
 * SPDX-License-Identifier: MIT
 * The reason of a failed call, in the words of iceoryx2.
 * A port never holds a message, only a POINTER TO ERROR: every message is a
 * string literal that lives in the binary for the whole process, so the
 * pointer is valid forever and costs nothing to pass around.
 * 127 is generous, the longest message in iceoryx2 0.9.3 is 76 characters.
 */
typedef RTS_IEC_STRING STRING__127[127];
typedef STRING__127 ERROR;



/**
 * <description>
 * iox2plc_listener_close_cext
 * </description>
 * <element name="iox2plc_listener_close_cext" type=OUT></element>
 * <element name="port" type=IN></element>
*/
typedef struct tagiox2plc_listener_close_cext_struct
{
	RTS_IEC_XWORD *port;
	RTS_IEC_STRING *iox2plc_listener_close_cext;
} iox2plc_listener_close_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_listener_close_cext',`(iox2plc_listener_close_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x57F660FC, 0xC231886C),0x00010000)

/**
 * <description>
 * iox2plc_listener_open_cext
 * </description>
 * <element name="iox2plc_listener_open_cext" type=OUT></element>
 * <element name="service" type=IN></element>
 * <element name="out_port" type=IN></element>
*/
typedef struct tagiox2plc_listener_open_cext_struct
{
	RTS_IEC_STRING *service;
	RTS_IEC_XWORD *out_port;
	RTS_IEC_STRING *iox2plc_listener_open_cext;
} iox2plc_listener_open_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_listener_open_cext',`(iox2plc_listener_open_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0xE69C68B2, 0x5A6ACD7D),0x00010000)

/**
 * <description>
 * iox2plc_listener_poll_cext
 * </description>
 * <element name="iox2plc_listener_poll_cext" type=OUT></element>
 * <element name="port" type=IN></element>
 * <element name="out_event_id" type=IN></element>
 * <element name="out_has_event" type=IN></element>
*/
typedef struct tagiox2plc_listener_poll_cext_struct
{
	RTS_IEC_XWORD port;
	RTS_IEC_UDINT *out_event_id;
	RTS_IEC_BOOL *out_has_event;
	RTS_IEC_STRING *iox2plc_listener_poll_cext;
} iox2plc_listener_poll_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_listener_poll_cext',`(iox2plc_listener_poll_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0xB0CDF3AF, 0xA54DC556),0x00010000)

/**
 * <description>
 * iox2plc_notifier_close_cext
 * </description>
 * <element name="iox2plc_notifier_close_cext" type=OUT></element>
 * <element name="port" type=IN></element>
*/
typedef struct tagiox2plc_notifier_close_cext_struct
{
	RTS_IEC_XWORD *port;
	RTS_IEC_STRING *iox2plc_notifier_close_cext;
} iox2plc_notifier_close_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_notifier_close_cext',`(iox2plc_notifier_close_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x9711B3EE, 0x02D65B7E),0x00010000)

/**
 * <description>
 * iox2plc_notifier_notify_cext
 * </description>
 * <element name="iox2plc_notifier_notify_cext" type=OUT></element>
 * <element name="port" type=IN></element>
 * <element name="event_id" type=IN></element>
 * <element name="out_notified" type=IN></element>
*/
typedef struct tagiox2plc_notifier_notify_cext_struct
{
	RTS_IEC_XWORD port;
	RTS_IEC_UDINT event_id;
	RTS_IEC_UDINT *out_notified;
	RTS_IEC_STRING *iox2plc_notifier_notify_cext;
} iox2plc_notifier_notify_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_notifier_notify_cext',`(iox2plc_notifier_notify_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x75590336, 0xAAC976A1),0x00010000)

/**
 * <description>
 * iox2plc_notifier_open_cext
 * </description>
 * <element name="iox2plc_notifier_open_cext" type=OUT></element>
 * <element name="service" type=IN></element>
 * <element name="out_port" type=IN></element>
*/
typedef struct tagiox2plc_notifier_open_cext_struct
{
	RTS_IEC_STRING *service;
	RTS_IEC_XWORD *out_port;
	RTS_IEC_STRING *iox2plc_notifier_open_cext;
} iox2plc_notifier_open_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_notifier_open_cext',`(iox2plc_notifier_open_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x53FCA141, 0xEF0A048E),0x00010000)

/**
 * <description>
 * iox2plc_publisher_close_cext
 * </description>
 * <element name="iox2plc_publisher_close_cext" type=OUT></element>
 * <element name="port" type=IN></element>
*/
typedef struct tagiox2plc_publisher_close_cext_struct
{
	RTS_IEC_XWORD *port;
	RTS_IEC_STRING *iox2plc_publisher_close_cext;
} iox2plc_publisher_close_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_publisher_close_cext',`(iox2plc_publisher_close_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x9A1D0EF2, 0x3FC664BA),0x00010000)

/**
 * <description>
 * iox2plc_publisher_open_cext
 * </description>
 * <element name="iox2plc_publisher_open_cext" type=OUT></element>
 * <element name="service" type=IN></element>
 * <element name="type_name" type=IN></element>
 * <element name="payload_size" type=IN></element>
 * <element name="alignment" type=IN></element>
 * <element name="publishers" type=IN></element>
 * <element name="subscribers" type=IN></element>
 * <element name="history" type=IN></element>
 * <element name="out_port" type=IN></element>
*/
typedef struct tagiox2plc_publisher_open_cext_struct
{
	RTS_IEC_STRING *service;
	RTS_IEC_STRING *type_name;
	RTS_IEC_UDINT payload_size;
	RTS_IEC_UDINT alignment;
	RTS_IEC_UDINT publishers;
	RTS_IEC_UDINT subscribers;
	RTS_IEC_BOOL history;
	RTS_IEC_XWORD *out_port;
	RTS_IEC_STRING *iox2plc_publisher_open_cext;
} iox2plc_publisher_open_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_publisher_open_cext',`(iox2plc_publisher_open_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x211A52FC, 0x4856570D),0x00010000)

/**
 * <description>
 * iox2plc_publisher_send_cext
 * </description>
 * <element name="iox2plc_publisher_send_cext" type=OUT></element>
 * <element name="port" type=IN></element>
 * <element name="data" type=IN></element>
 * <element name="size" type=IN></element>
 * <element name="out_delivered" type=IN></element>
*/
typedef struct tagiox2plc_publisher_send_cext_struct
{
	RTS_IEC_XWORD port;
	RTS_IEC_BYTE *data;
	RTS_IEC_UDINT size;
	RTS_IEC_UDINT *out_delivered;
	RTS_IEC_STRING *iox2plc_publisher_send_cext;
} iox2plc_publisher_send_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_publisher_send_cext',`(iox2plc_publisher_send_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x64F61ACE, 0x7A995C30),0x00010000)

/**
 * <description>
 * iox2plc_subscriber_close_cext
 * </description>
 * <element name="iox2plc_subscriber_close_cext" type=OUT></element>
 * <element name="port" type=IN></element>
*/
typedef struct tagiox2plc_subscriber_close_cext_struct
{
	RTS_IEC_XWORD *port;
	RTS_IEC_STRING *iox2plc_subscriber_close_cext;
} iox2plc_subscriber_close_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_subscriber_close_cext',`(iox2plc_subscriber_close_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x902DD2C2, 0xF4690466),0x00010000)

/**
 * <description>
 * iox2plc_subscriber_open_cext
 * </description>
 * <element name="iox2plc_subscriber_open_cext" type=OUT></element>
 * <element name="service" type=IN></element>
 * <element name="type_name" type=IN></element>
 * <element name="payload_size" type=IN></element>
 * <element name="alignment" type=IN></element>
 * <element name="publishers" type=IN></element>
 * <element name="subscribers" type=IN></element>
 * <element name="history" type=IN></element>
 * <element name="out_port" type=IN></element>
*/
typedef struct tagiox2plc_subscriber_open_cext_struct
{
	RTS_IEC_STRING *service;
	RTS_IEC_STRING *type_name;
	RTS_IEC_UDINT payload_size;
	RTS_IEC_UDINT alignment;
	RTS_IEC_UDINT publishers;
	RTS_IEC_UDINT subscribers;
	RTS_IEC_BOOL history;
	RTS_IEC_XWORD *out_port;
	RTS_IEC_STRING *iox2plc_subscriber_open_cext;
} iox2plc_subscriber_open_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_subscriber_open_cext',`(iox2plc_subscriber_open_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0xBFEAB7D3, 0xA74065B7),0x00010000)

/**
 * <description>
 * iox2plc_subscriber_recv_cext
 * </description>
 * <element name="iox2plc_subscriber_recv_cext" type=OUT></element>
 * <element name="port" type=IN></element>
 * <element name="data" type=IN></element>
 * <element name="size" type=IN></element>
 * <element name="out_has_data" type=IN></element>
*/
typedef struct tagiox2plc_subscriber_recv_cext_struct
{
	RTS_IEC_XWORD port;
	RTS_IEC_BYTE *data;
	RTS_IEC_UDINT size;
	RTS_IEC_BOOL *out_has_data;
	RTS_IEC_STRING *iox2plc_subscriber_recv_cext;
} iox2plc_subscriber_recv_cext_struct;

DEF_API(`void',`CDECL',`iox2plc_subscriber_recv_cext',`(iox2plc_subscriber_recv_cext_struct *p)',1,RTSITF_GET_SIGNATURE(0x764956CC, 0xA9D9235B),0x00010000)

#ifdef __cplusplus
}
#endif

/** EXTERN LIB SECTION END **/

