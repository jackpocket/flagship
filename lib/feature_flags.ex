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
      iex> App.FeatureFlags.get(FeatureFlags, "flag_name", false, :none)
      true

      Flag not set, and fallback is true
      iex> App.FeatureFlags.get("flag_name", true, "OH")
      true

      In the UI, add "CO" as an individual target
      iex> App.FeatureFlags.get("flag_name", false, "OH")
      false

      iex> App.FeatureFlags.get("flag_name", false, "CO")
      true
  """
  def get(key, fallback, location_code \\ :none) do
    GenServer.call(__MODULE__, {:get, key, fallback, String.upcase(to_string(location_code))})
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
  def handle_call({:get, key, fallback, location_code}, _from, state) do
    Logger.info(
      "Looking up value for LaunchDarkly flag: #{key} with location code: #{location_code}"
    )

    {:reply, LaunchDarkly.variation(key, location_code, fallback), state}
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
