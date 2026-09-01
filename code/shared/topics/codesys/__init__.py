from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent

from .AppCfg import AppCfg
from .AppCmd import AppCmd
from .AppFbk import AppFbk


codesys_cmd_pubsub = IoxPublishSubscribe('codesys/cmd', AppCmd)
codesys_fbk_pubsub = IoxPublishSubscribe('codesys/fbk', AppFbk, subscribers=8)
codesys_fbk_event  = IoxEvent('codesys/fbk')
