-module(account).

-export([signup/2, login/2, logout/2]).

-include("common.hrl").

signup([{<<"pass">>, Password}, {<<"user">>, Email}], _State) ->
    Transaction = fun() ->
        case mnesia:read(db_account, Email) of
            [] ->
                case mnesia:write(#db_account{email    = Email,
                                              password = Password,
                                              data     = <<"">>}) of
                    {atomic, ok} ->
                        ok;
                    Err ->
                        {error, Err}
                end;
            _ -> already_exists
        end
    end,
    case mnesia:transaction(Transaction) of
        {atomic, {error, ok}} ->
            utils:send(#proto_account_signup_reply{error = <<"ok">>});
        {atomic, already_exists} ->
            utils:send(#proto_account_signup_reply{error = <<"already_exists">>});
        {atomic, {error, _Error}} ->
            utils:send(#proto_account_signup_reply{error = <<"general_failure">>})
    end.

logout(_Payload, #state{ logged = Logged, email = Email }) ->
    devices ! {logout, {self(), Logged, Email}},
    utils:send(#proto_account_logout_reply{error = <<"ok">>}),
    #state{}.

login([{<<"device">>, Device},
       {<<"pass">>,   Password},
       {<<"user">>,   Email}], State) ->
    case mnesia:dirty_read(db_account, Email) of
        [] ->
            utils:send(#proto_account_login_reply{error = <<"invalid_login">>}),
            State;
        [#db_account{password = DbPassword}] ->
            if
                DbPassword == Password ->
                    devices ! {login, {self(), Email, Device}},
                    NewLoginState = State#state{logged = true, device = Device, email = Email},
                    utils:send(#proto_account_login_reply{error = <<"ok">>}),
                    NewLoginState;
                true ->
                    utils:send(#proto_account_login_reply{error = <<"invalid_login">>}),
                    State
            end;
        _ ->
            utils:send(#proto_account_login_reply{error = <<"general_failure">>}),
            State
    end;
login(_, State) ->
	utils:send(#proto_account_login_reply{error = <<"general_failure">>}),
    State.
