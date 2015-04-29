-module(event_handler).

-export([init/4,
        stream/3,
        info/3,
        terminate/2]).

-record(state, {channel}).

init(_Transport, Req, Opts, _Active) ->
    io:format("new channel ~p~n", [Opts]),
    {channel, ChannelPid} = lists:keyfind(channel, 1, Opts),
    subscriptor:subscribe(ChannelPid, self()),
    {ok, Req, #state{channel=ChannelPid}}.

stream(Data, Req, State=#state{channel=ChannelPid}) ->
    io:format("message from ~s~n", [Data]),
    subscriptor:send(ChannelPid, {msg, self(), Data}),
    {ok, Req, State}.

info({msg, _Sender, Data}, Req, State) ->
    {reply, Data, Req, State}.

terminate(_Req, #state{channel=ChannelPid}) ->
    io:format("terminate channel~n"),
    subscriptor:unsubscribe(ChannelPid, self()),
    ok.