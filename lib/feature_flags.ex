defmodule Flagship.FeatureFlags do
  @moduledoc false
  use GenServer
  alias Flagship.LaunchDarkly
  require Logger

  @check_ms 500

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Gets a feature flag value (or fallback) for the given user key if targeted individually

  ## Examples
      iex> App.FeatureFlags.get(FeatureFlags, "flag_name", false, nil)
      true

      Flag not set, and fallback is true
      iex> App.FeatureFlags.get("flag_name", true, "userkey")
      true

  The default context is the user key, but you can also pass in a map with the context

  ## Examples
      iex> App.FeatureFlags.get("flag_name", false, %{:kind => "user", :key => "user_key"})
      true

      iex> App.FeatureFlags.get("flag_name", false, %{:kind => "location", :key => location_code})
      true
  """
  def get(key, fallback) do
    GenServer.call(__MODULE__, {:get, key, fallback, %{:kind => "location", :key => "NONE"}})
  end

  def get(key, fallback, context) when is_map(context) do
    GenServer.call(__MODULE__, {:get, key, fallback, context})
  end

  def get(key, fallback, user_key) do
    GenServer.call(__MODULE__, {:get, key, fallback, %{:kind => "user", :key => user_key}})
  end

  @doc false
  def init(:ok) do
    ldclient_options = Application.get_env(:flagship, :ld_client_options, %{})
    launch_darkly_sdk_key = Application.get_env(:flagship, :ld_sdk_key)
    LaunchDarkly.start_instance(launch_darkly_sdk_key, ldclient_options)
    wait_for_initialization()
    {:ok, %{}}
  end

  @doc false
  def handle_call({:get, key, fallback, context}, from, state) do
    Logger.info(
      "Looking up value for LaunchDarkly flag: #{key} with context: #{inspect(context)} from: #{inspect(from)}}"
    )
    {:reply, LaunchDarkly.variation(key, context, fallback), state}
  end

  def handle_info(:wait_for_initialization, state) do
    wait_for_initialization()
    {:noreply, state}
  end

  def initialized? do
    LaunchDarkly.initialized(:default)
  end

  defp wait_for_initialization() do
    Logger.info("Waiting for LaunchDarkly flag data...")

    if Flagship.FeatureFlags.initialized?() do
      Logger.info("LaunchDarkly flag data is ready.")
      :initialized
    else
      Process.send_after(self(), :wait_for_initialization, @check_ms)
    end
  end
end
