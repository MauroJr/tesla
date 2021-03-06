defmodule LoggerTest do
  use ExUnit.Case, async: false

  use Tesla.Middleware.TestCase, middleware: Tesla.Middleware.Logger
  use Tesla.Middleware.TestCase, middleware: Tesla.Middleware.DebugLogger

  defmodule Client do
    use Tesla

    plug Tesla.Middleware.Logger
    plug Tesla.Middleware.DebugLogger

    adapter fn (env) ->
      {status, body} = case env.url do
        "/server-error" -> {500, "error"}
        "/client-error" -> {404, "error"}
        "/redirect"     -> {301, "moved"}
        "/ok"           -> {200, "ok"}
      end
      %{env | status: status, body: body}
    end
  end

  import ExUnit.CaptureLog

  test "server error" do
    log = capture_log(fn -> Client.get("/server-error") end)
    assert log =~ "/server-error -> 500"
  end

  test "client error" do
    log = capture_log(fn -> Client.get("/client-error") end)
    assert log =~ "/client-error -> 404"
  end

  test "redirect" do
    log = capture_log(fn -> Client.get("/redirect") end)
    assert log =~ "/redirect -> 301"
  end

  test "ok" do
    log = capture_log(fn -> Client.get("/ok") end)
    assert log =~ "/ok -> 200"
  end
end
