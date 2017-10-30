%%% @author  <wqx@WIL>
%%% @copyright (C) 2017, 
%%% @doc
%%% a socket demo to get a web page from a URL
%%% @end
%%% Created : 30 Oct 2017 by  <wqx@WIL>

-module(socket_example).
-export([start_nano_server/0,nano_get_url/0,nano_get_url/1]).
-import(lists, [reverse/1]).

nano_get_url() ->
    nano_get_url("www.bing.com").

nano_get_url(Host) ->
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, []).

receive_data(Socket, SoFar) ->
    receive
	{tcp, Socket, Bin}->
	    receive_data(Socket, [Bin|SoFar]);
	{tcp_closed, Socket} ->
	    list_to_binary(reverse(SoFar))
    after 2000 ->
	    {error, timeout}

    end.
start_nano_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary,{packet, 4},
					 {reuseaddr, true},
					 {active,true}]),
    % is Listen a Socket too?
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
	{tcp, Socket, Bin}->
	    io:format("1. Receive = ~p~n", [Bin]),
	    Str = binary_to_term(Bin),
	    io:format("2. Unpack = ~p~n", [Str]),
	    Reply = lib_misc:string2value(Str),
	    io:format("3. Reply = ~p~n", [Reply]),
	    gen_tcp:send(Socket, term_to_binary(Reply)),
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("Server socket closed~n")
    end.
		     
