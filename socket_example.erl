%%% @author  <wqx@WIL>
%%% @copyright (C) 2017, 
%%% @doc
%%% a socket demo to get a web page from a URL
%%% @end
%%% Created : 30 Oct 2017 by  <wqx@WIL>

-module(socket_example).
-export([nano_get_url/0,nano_get_url/1]).
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
