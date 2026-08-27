// SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

#include <string.h>
#include "CmpStd.h"
#include "CmpErrors.h"
#include "CmpItf.h"
#include "iox2/iceoryx2.h"
#include "CmpIceoryx2Dep.h"


#define IOX2PLC_NODE_NAME "codesys"

/* A failure is reported as the message iceoryx2 has for it, NULL means success.
 * Every message is a string literal in the .rodata of this component or of the
 * iceoryx2 library, so the pointer stays valid for the lifetime of the process
 * and is handed to IEC as is, without a copy and without ownership. */

/* Created once when the runtime loads this component and kept for the lifetime
 * of the process. */
static iox2_node_h s_node = NULL;
static const char *s_node_error = "iceoryx2 node was not created";

/* ------------------------------------------------------------------------- */
/* node and ports                                                            */
/* ------------------------------------------------------------------------- */

/* Runs when the runtime dlopens the component, before any hook and long before
 * the IEC bootprojects are loaded.
 * A failure is left for the opens to report, there is no one to tell yet. */
__attribute__((constructor))
static void node_startup(void)
{
	iox2_node_builder_h builder;
	iox2_node_name_h node_name = NULL;
	int rc;

	if (s_node != NULL)
		return;

	builder = iox2_node_builder_new(NULL);
	if (iox2_node_name_new(NULL, IOX2PLC_NODE_NAME, strlen(IOX2PLC_NODE_NAME), &node_name) == IOX2_OK)
		iox2_node_builder_set_name(&builder, iox2_cast_node_name_ptr(node_name));
	/* SIGINT/SIGTERM belong to the CODESYS runtime. */
	iox2_node_builder_set_signal_handling_mode(&builder, iox2_signal_handling_mode_e_DISABLED);

	rc = iox2_node_builder_create(builder, NULL, iox2_service_type_e_IPC, &s_node);
	if (rc != IOX2_OK)
	{
		s_node = NULL;
		s_node_error = iox2_node_creation_failure_string((enum iox2_node_creation_failure_e)rc);
		return;
	}

	s_node_error = NULL;
}

/* ------------------------------------------------------------------------- */
/* service factories                                                         */
/* ------------------------------------------------------------------------- */

static const char *open_pub_sub_factory(const char *service, const char *type_name,
	RTS_IEC_UDINT payload_size, RTS_IEC_UDINT alignment,
	RTS_IEC_UDINT publishers, RTS_IEC_UDINT subscribers, RTS_IEC_BOOL history,
	iox2_port_factory_pub_sub_h *out_factory)
{
	iox2_service_name_h name;
	iox2_service_builder_h builder;
	iox2_service_builder_pub_sub_h pub_sub;
	int rc;

	rc = iox2_service_name_new(NULL, service, strlen(service), &name);
	if (rc != IOX2_OK)
		return iox2_semantic_string_error_string((enum iox2_semantic_string_error_e)rc);

	builder = iox2_node_service_builder(&s_node, NULL, iox2_cast_service_name_ptr(name));
	iox2_service_name_drop(name);
	pub_sub = iox2_service_builder_pub_sub(builder);

	rc = iox2_service_builder_pub_sub_set_payload_type_details(&pub_sub,
		iox2_type_variant_e_FIXED_SIZE, type_name, strlen(type_name),
		(c_size_t)payload_size, (c_size_t)alignment);
	if (rc != IOX2_OK)
		/* iox2_type_detail_error_e is the one error iceoryx2 0.9.3 has no
		 * string function for. */
		return "invalid type name or payload size or alignment";

	iox2_service_builder_pub_sub_set_max_publishers(&pub_sub, (c_size_t)publishers);
	iox2_service_builder_pub_sub_set_max_subscribers(&pub_sub, (c_size_t)subscribers);
	iox2_service_builder_pub_sub_set_history_size(&pub_sub, history ? 1 : 0);
	iox2_service_builder_pub_sub_set_enable_safe_overflow(&pub_sub, true);
	iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(&pub_sub, 1);

	rc = iox2_service_builder_pub_sub_open_or_create(pub_sub, NULL, out_factory);
	if (rc != IOX2_OK)
		return iox2_pub_sub_open_or_create_error_string((enum iox2_pub_sub_open_or_create_error_e)rc);

	return NULL;
}

static const char *open_event_factory(const char *service, iox2_port_factory_event_h *out_factory)
{
	iox2_service_name_h name;
	iox2_service_builder_h builder;
	iox2_service_builder_event_h event;
	int rc;

	rc = iox2_service_name_new(NULL, service, strlen(service), &name);
	if (rc != IOX2_OK)
		return iox2_semantic_string_error_string((enum iox2_semantic_string_error_e)rc);

	builder = iox2_node_service_builder(&s_node, NULL, iox2_cast_service_name_ptr(name));
	iox2_service_name_drop(name);
	event = iox2_service_builder_event(builder);

	rc = iox2_service_builder_event_open_or_create(event, NULL, out_factory);
	if (rc != IOX2_OK)
		return iox2_event_open_or_create_error_string((enum iox2_event_open_or_create_error_e)rc);

	return NULL;
}

/* ------------------------------------------------------------------------- */
/* port open implementations                                                 */
/* ------------------------------------------------------------------------- */

static const char *publisher_open(const char *service, const char *type_name,
	RTS_IEC_UDINT payload_size, RTS_IEC_UDINT alignment,
	RTS_IEC_UDINT publishers, RTS_IEC_UDINT subscribers, RTS_IEC_BOOL history,
	RTS_IEC_XWORD *out)
{
	iox2_port_factory_pub_sub_h factory = NULL;
	iox2_port_factory_publisher_builder_h builder;
	iox2_publisher_h publisher = NULL;
	const char *err;
	int rc;

	*out = 0;

	if (s_node == NULL)
		return s_node_error;

	err = open_pub_sub_factory(service, type_name, payload_size, alignment,
		publishers, subscribers, history, &factory);
	if (err != NULL)
		return err;

	builder = iox2_port_factory_pub_sub_publisher_builder(&factory, NULL);
	rc = iox2_port_factory_publisher_builder_create(builder, NULL, &publisher);
	iox2_port_factory_pub_sub_drop(factory);
	if (rc != IOX2_OK)
		return iox2_publisher_create_error_string((enum iox2_publisher_create_error_e)rc);

	*out = (RTS_IEC_XWORD)(RTS_UINTPTR)publisher;
	return NULL;
}

static const char *subscriber_open(const char *service, const char *type_name,
	RTS_IEC_UDINT payload_size, RTS_IEC_UDINT alignment,
	RTS_IEC_UDINT publishers, RTS_IEC_UDINT subscribers, RTS_IEC_BOOL history,
	RTS_IEC_XWORD *out)
{
	iox2_port_factory_pub_sub_h factory = NULL;
	iox2_port_factory_subscriber_builder_h builder;
	iox2_subscriber_h subscriber = NULL;
	const char *err;
	int rc;

	*out = 0;

	if (s_node == NULL)
		return s_node_error;

	err = open_pub_sub_factory(service, type_name, payload_size, alignment,
		publishers, subscribers, history, &factory);
	if (err != NULL)
		return err;

	builder = iox2_port_factory_pub_sub_subscriber_builder(&factory, NULL);
	rc = iox2_port_factory_subscriber_builder_create(builder, NULL, &subscriber);
	iox2_port_factory_pub_sub_drop(factory);
	if (rc != IOX2_OK)
		return iox2_subscriber_create_error_string((enum iox2_subscriber_create_error_e)rc);

	*out = (RTS_IEC_XWORD)(RTS_UINTPTR)subscriber;
	return NULL;
}

static const char *notifier_open(const char *service, RTS_IEC_XWORD *out)
{
	iox2_port_factory_event_h factory = NULL;
	iox2_port_factory_notifier_builder_h builder;
	iox2_notifier_h notifier = NULL;
	const char *err;
	int rc;

	*out = 0;

	if (s_node == NULL)
		return s_node_error;

	err = open_event_factory(service, &factory);
	if (err != NULL)
		return err;

	builder = iox2_port_factory_event_notifier_builder(&factory, NULL);
	rc = iox2_port_factory_notifier_builder_create(builder, NULL, &notifier);
	iox2_port_factory_event_drop(factory);
	if (rc != IOX2_OK)
		return iox2_notifier_create_error_string((enum iox2_notifier_create_error_e)rc);

	*out = (RTS_IEC_XWORD)(RTS_UINTPTR)notifier;
	return NULL;
}

static const char *listener_open(const char *service, RTS_IEC_XWORD *out)
{
	iox2_port_factory_event_h factory = NULL;
	iox2_port_factory_listener_builder_h builder;
	iox2_listener_h listener = NULL;
	const char *err;
	int rc;

	*out = 0;

	if (s_node == NULL)
		return s_node_error;

	err = open_event_factory(service, &factory);
	if (err != NULL)
		return err;

	builder = iox2_port_factory_event_listener_builder(&factory, NULL);
	rc = iox2_port_factory_listener_builder_create(builder, NULL, &listener);
	iox2_port_factory_event_drop(factory);
	if (rc != IOX2_OK)
		return iox2_listener_create_error_string((enum iox2_listener_create_error_e)rc);

	*out = (RTS_IEC_XWORD)(RTS_UINTPTR)listener;
	return NULL;
}

/* ------------------------------------------------------------------------- */
/* port operation implementations                                            */
/* ------------------------------------------------------------------------- */

static const char *publisher_send(RTS_IEC_XWORD port, const void *data, RTS_IEC_UDINT size, RTS_IEC_UDINT *out_delivered)
{
	iox2_publisher_h publisher = (iox2_publisher_h)(RTS_UINTPTR)port;
	c_size_t recipients = 0;
	int rc;

	*out_delivered = 0;

	rc = iox2_publisher_send_copy(&publisher, data, size, &recipients);
	if (rc != IOX2_OK)
		return iox2_send_error_string((enum iox2_send_error_e)rc);

	*out_delivered = (RTS_IEC_UDINT)recipients;
	return NULL;
}

static const char *subscriber_recv(RTS_IEC_XWORD port, void *data, RTS_IEC_UDINT size, RTS_IEC_BOOL *out_has_data)
{
	iox2_subscriber_h subscriber = (iox2_subscriber_h)(RTS_UINTPTR)port;
	iox2_sample_h sample = NULL;
	const void *payload = NULL;
	int rc;

	*out_has_data = 0;

	rc = iox2_subscriber_receive(&subscriber, NULL, &sample);
	if (rc != IOX2_OK)
		return iox2_receive_error_string((enum iox2_receive_error_e)rc);

	if (sample != NULL)
	{
		iox2_sample_payload(&sample, &payload, NULL);
		if (payload != NULL)
		{
			memcpy(data, payload, size);
			*out_has_data = 1;
		}
		iox2_sample_drop(sample);
	}

	return NULL;
}

static const char *notifier_notify(RTS_IEC_XWORD port, RTS_IEC_UDINT id, RTS_IEC_UDINT *out_notified)
{
	iox2_notifier_h notifier = (iox2_notifier_h)(RTS_UINTPTR)port;
	iox2_event_id_t event_id;
	c_size_t notified = 0;
	int rc;

	*out_notified = 0;

	event_id.value = (c_size_t)id;
	rc = iox2_notifier_notify_with_custom_event_id(&notifier, &event_id, &notified);
	if (rc != IOX2_OK)
		return iox2_notifier_notify_error_string((enum iox2_notifier_notify_error_e)rc);

	*out_notified = (RTS_IEC_UDINT)notified;
	return NULL;
}

static const char *listener_poll(RTS_IEC_XWORD port, RTS_IEC_UDINT *out_event_id, RTS_IEC_BOOL *out_has_event)
{
	iox2_listener_h listener = (iox2_listener_h)(RTS_UINTPTR)port;
	iox2_event_id_t event_id;
	bool has_event = false;
	int rc;

	*out_has_event = 0;

	rc = iox2_listener_try_wait_one(&listener, &event_id, &has_event);
	if (rc != IOX2_OK)
		/* An interrupted syscall is not an error, just no event this cycle. */
		return rc == iox2_listener_wait_error_e_INTERRUPT_SIGNAL
			? NULL : iox2_listener_wait_error_string((enum iox2_listener_wait_error_e)rc);

	if (has_event)
	{
		*out_event_id = (RTS_IEC_UDINT)event_id.value;
		*out_has_event = 1;
	}

	return NULL;
}

/* ------------------------------------------------------------------------- */
/* external functions (IEC entry points)                                     */
/* ------------------------------------------------------------------------- */

void CDECL CDECL_EXT iox2plc_listener_close_cext(iox2plc_listener_close_cext_struct *p)
{
	iox2_listener_h listener = (iox2_listener_h)(RTS_UINTPTR)*p->port;

	if (listener != NULL)
	{
		iox2_listener_drop(listener);
		*p->port = 0;
	}

	p->iox2plc_listener_close_cext = NULL;
}

void CDECL CDECL_EXT iox2plc_listener_open_cext(iox2plc_listener_open_cext_struct *p)
{
	p->iox2plc_listener_open_cext = (RTS_IEC_STRING *)listener_open(p->service, p->out_port);
}

void CDECL CDECL_EXT iox2plc_listener_poll_cext(iox2plc_listener_poll_cext_struct *p)
{
	p->iox2plc_listener_poll_cext = (RTS_IEC_STRING *)listener_poll(p->port,
		p->out_event_id, p->out_has_event);
}

void CDECL CDECL_EXT iox2plc_notifier_close_cext(iox2plc_notifier_close_cext_struct *p)
{
	iox2_notifier_h notifier = (iox2_notifier_h)(RTS_UINTPTR)*p->port;

	if (notifier != NULL)
	{
		iox2_notifier_drop(notifier);
		*p->port = 0;
	}

	p->iox2plc_notifier_close_cext = NULL;
}

void CDECL CDECL_EXT iox2plc_notifier_notify_cext(iox2plc_notifier_notify_cext_struct *p)
{
	p->iox2plc_notifier_notify_cext = (RTS_IEC_STRING *)notifier_notify(p->port,
		p->event_id, p->out_notified);
}

void CDECL CDECL_EXT iox2plc_notifier_open_cext(iox2plc_notifier_open_cext_struct *p)
{
	p->iox2plc_notifier_open_cext = (RTS_IEC_STRING *)notifier_open(p->service, p->out_port);
}

void CDECL CDECL_EXT iox2plc_publisher_close_cext(iox2plc_publisher_close_cext_struct *p)
{
	iox2_publisher_h publisher = (iox2_publisher_h)(RTS_UINTPTR)*p->port;

	if (publisher != NULL)
	{
		iox2_publisher_drop(publisher);
		*p->port = 0;
	}

	p->iox2plc_publisher_close_cext = NULL;
}

void CDECL CDECL_EXT iox2plc_publisher_open_cext(iox2plc_publisher_open_cext_struct *p)
{
	p->iox2plc_publisher_open_cext = (RTS_IEC_STRING *)publisher_open(p->service, p->type_name,
		p->payload_size, p->alignment,
		p->publishers, p->subscribers, p->history, p->out_port);
}

void CDECL CDECL_EXT iox2plc_publisher_send_cext(iox2plc_publisher_send_cext_struct *p)
{
	p->iox2plc_publisher_send_cext = (RTS_IEC_STRING *)publisher_send(p->port,
		p->data, p->size, p->out_delivered);
}

void CDECL CDECL_EXT iox2plc_subscriber_close_cext(iox2plc_subscriber_close_cext_struct *p)
{
	iox2_subscriber_h subscriber = (iox2_subscriber_h)(RTS_UINTPTR)*p->port;

	if (subscriber != NULL)
	{
		iox2_subscriber_drop(subscriber);
		*p->port = 0;
	}

	p->iox2plc_subscriber_close_cext = NULL;
}

void CDECL CDECL_EXT iox2plc_subscriber_open_cext(iox2plc_subscriber_open_cext_struct *p)
{
	p->iox2plc_subscriber_open_cext = (RTS_IEC_STRING *)subscriber_open(p->service, p->type_name,
		p->payload_size, p->alignment,
		p->publishers, p->subscribers, p->history, p->out_port);
}

void CDECL CDECL_EXT iox2plc_subscriber_recv_cext(iox2plc_subscriber_recv_cext_struct *p)
{
	p->iox2plc_subscriber_recv_cext = (RTS_IEC_STRING *)subscriber_recv(p->port,
		p->data, p->size, p->out_has_data);
}
