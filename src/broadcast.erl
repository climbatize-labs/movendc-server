-module(broadcast).
-export([send/2]).

-include("common.hrl").

send([{<<"msg">>, Message}], State) ->
    Filter = fun({Pid, _Device}) ->
                SelfPid = list_to_binary(pid_to_list(self())),
                utils:send(Pid, #proto_broadcast{pid = SelfPid,
                                                 msg = Message})
             end,
    devices ! {friends, {self(), State#state.email}},
    receive
        Devices ->
            case Devices of
                [] ->
                    ok;
                List ->
                    lists:map(Filter, List)
            end
    after
        1000 ->
          timeout
    end.
