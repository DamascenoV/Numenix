defmodule Numenix.Repo do
  use Ecto.Repo,
    otp_app: :numenix,
    adapter: Ecto.Adapters.Postgres
end
