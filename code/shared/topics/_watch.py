from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent


watch_update_pubsub = IoxPublishSubscribe('watch/update', subscribers=4, history=True)
watch_update_event = IoxEvent('watch/update')
