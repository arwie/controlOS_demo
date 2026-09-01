from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent


simio_details_pubsub = IoxPublishSubscribe('simio/list', subscribers=4, history=True)
simio_update_pubsub  = IoxPublishSubscribe('simio/update', subscribers=4, history=True)
simio_update_event   = IoxEvent('simio/update')

simio_cmd_pubsub = IoxPublishSubscribe('simio/cmd')
simio_cmd_event  = IoxEvent('simio/cmd')
