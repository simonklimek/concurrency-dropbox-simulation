-module(dropboxtest).
-export([start/0, user/1]).

start() ->
    dropbox:start(),
    mutex:start(),
	register(test_process, self()),
	loop("hello", "world", 10),
	unregister(test_process),
	mutex:stop(),
	dropbox:stop().

loop(_, _, 0) ->
     true;

loop(String1, String2, N) ->
     dropbox:write(""),
	spawn(dropboxtest, user, [String1]),
	spawn(dropboxtest, user, [String2]),
     receive
	done -> true
     end,
     receive
	done -> true
     end,
	
	io:format("Expected string = ~ts, actual string = ~ts~n~n",
       [(String1 ++ String2), dropbox:read()]),
	loop(String1, String2, N-1).

user(Str) ->
     dropbox:upload(Str),
	test_process ! done.
	
