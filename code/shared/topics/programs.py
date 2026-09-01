from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent


programs_select_pubsub	= IoxPublishSubscribe('programs/select', history=True)

jog_cmd_pubsub = IoxPublishSubscribe('programs/jog_cmd')
jog_cmd_event  = IoxEvent('programs/jog_cmd')

calib_robot_pubsub = IoxPublishSubscribe('programs/calib_robot')

cnc_paint_pubsub = IoxPublishSubscribe('programs/cnc_paint')
cnc_paint_event  = IoxEvent('programs/cnc_paint')
