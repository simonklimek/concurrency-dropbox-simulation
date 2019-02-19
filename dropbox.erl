-module(dropbox).
-export([server/1, start/0, stop/0, write/1, read/0, upload/1]).

server(String) ->
	receive
	  {write, NewString} ->
	     server(NewString);
	  {get, From} ->
	     From ! {fileContents, String},
	   server(String);
	 stop -> ok
	end.

start() ->
	Server_PID = spawn(dropbox, server, [""]),
 	   register(server_process, Server_PID).

stop() ->
	server_process ! stop,
	unregister(server_process).

write(S) ->
	server_process ! {write, S}.

read() ->
	server_process ! {get, self()},
	receive
	    {fileContents, S} -> S
	end.

upload(Str) ->
	mutex:wait(),
	   OldFile = read(),
	   NewFile = OldFile ++ Str,
	   write(NewFile),
	mutex:signal().
