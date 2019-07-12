-module(devices).

-export([start/0]).

start() ->
    loop([]).

loop(Devices) ->
    receive
        {login, {Pid, Email, Device}} ->
            case lists:keysearch(Email, 1, Devices) of
                {value, {_Email, ListDevices}} ->
                    NewListDevices = lists:keystore(Pid, 1, ListDevices, {Pid, Device}),
                    notify:login(ListDevices, Pid, Device),
                    loop(lists:keystore(Email, 1, Devices, {Email, NewListDevices}));
                false ->
                    loop(lists:keystore(Email, 1, Devices, {Email, [{Pid, Device}]}))
            end;
        {logout, {Pid, true, Email}} ->
            case lists:keysearch(Email, 1, Devices) of
                {value, {_Email, ListDevices}} ->
                    notify:logout(Pid, ListDevices),
                    NewListDevices = lists:keydelete(Pid, 1, ListDevices),
                    loop(lists:keystore(Email, 1, Devices, {Email, NewListDevices}));
                false ->
                    loop(Devices)
            end;
        {logout, {_Pid, false, _Email}} ->
            loop(Devices);
        {friends, {Pid, Email}} ->
            Devs = case lists:keysearch(Email, 1, Devices) of
                {value, {_Email, ListDevices}} ->
                    ListDevices;
                _ ->
                    []
            end,
            Pid ! Devs,
            loop(Devices);
        Unknown ->
            lager:debug("Unknown msg received ~p", [Unknown]),
            loop(Devices)
    end.
