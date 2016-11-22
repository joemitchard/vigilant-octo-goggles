# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :pooler, pools:
  [
    [
      name: :riaklocal1,
      group: :riak,
      max_count: 15,
      init_count: 2,
      start_mfa: { Riak.Connection, :start_link, ['127.0.0.1', 8087] }
    ]
  ]
