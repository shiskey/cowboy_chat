-module(chat_app).

-behaviour(application).

%% Application callbacks

-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	{ok, ChannelPid} = subscriptor:new(),
    Dispatch = cowboy_router:compile([
        {'_',
            [
                %% Event handler
                {"/api", bullet_handler, [{handler, event_handler}, {channel, ChannelPid}]},

                %% Statics
                {"/", cowboy_static, {priv_file, chat, "static/index.html", [mimetypes, {<<"text">>, <<"html">>}]}},
                {"/[...]", cowboy_static, {priv_dir, chat, "static", [{mimetypes, cow_mimetypes, all}]}}
            ]
        }
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8000}], [
                                    {env, [{dispatch, Dispatch}]}
                                ]),
    chat_sup:start_link().

stop(_State) ->
    ok.
