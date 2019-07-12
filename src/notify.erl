-module(notify).
-export([login/3, logout/2]).

-include("common.hrl").

login(ListDevices, Pid, Device) ->
    % first, notify all devices when new device comes online
    Fun = fun({LPid, _Device}) ->
            utils:send(LPid, #proto_devices_online{ list = [{Pid, Device}] })
          end,
    lists:map(Fun, ListDevices),

    % notify a freshly logged device about all online devices
    utils:send(Pid, #proto_devices_online{ list = ListDevices }).

logout(Pid, ListDevices) ->
    Fun = fun({LPid, _Device}) ->
            utils:send(LPid, #proto_device_offline{ pid = Pid })
          end,
    lists:map(Fun, ListDevices).
