defmodule TextdbWeb.Router do
  use TextdbWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {TextdbWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["text/plain", "application/json", "json"]
  end

  scope "/", TextdbWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/data/:id", DataLive

    get "/analytics", AnalyticsController, :index
  end

  scope "/api", TextdbWeb do
    pipe_through :api

    get "/data/:id", ApiController, :fetch_data
    post "/data/:id", ApiController, :update_data
  end

  # Other scopes may use custom stacks.
  # scope "/api", TextdbWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TextdbWeb.Telemetry
    end
  end
end
