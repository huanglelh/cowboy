%% Feel free to use, reuse and abuse the code in this file.

-module(markdown_converter).
-behaviour(cowboy_middleware).

-define(MARKDOWN_STYLE_TEMPLATE,"markdown_tamplate.html").


-export([execute/2]).


execute(Req, Env) ->
	PathInfo = cowboy_req:path_info(Req),
	io:format("cowboy_req:path_info is ~p~n",[PathInfo]),
	[Path] = PathInfo,
	case filename:extension(Path) of
		<<".html">> -> maybe_generate_markdown(resource_path(Path));
		_Ext -> ok
	end,
	{ok, Req, Env}.

maybe_generate_markdown(Path) ->
	ModifiedAt = filelib:last_modified(source_path(Path)),
	GeneratedAt = filelib:last_modified(Path),
	case ModifiedAt > GeneratedAt of
		true -> erlmarkdown:conv_file_with_style(source_path(Path), Path,resource_path(?MARKDOWN_STYLE_TEMPLATE));
		false -> ok
	end.

resource_path(Path) ->
	PrivDir = code:priv_dir(markdown_middleware),
	filename:join([PrivDir, Path]).

source_path(Path) ->
	<< (filename:rootname(Path))/binary, ".md" >>.
