from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent


sim_update_pubsub	= IoxPublishSubscribe('sim/update')
sim_cmd_pubsub		= IoxPublishSubscribe('sim/cmd')
sim_cmd_event		= IoxEvent('sim/cmd')
