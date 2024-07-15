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
  Gets a feature flag value (or fallback) for the given flag key and context

  ## Examples
      iex> Flagship.FeatureFlags.get("flag_name", false)
      true

      Flag not set, and fallback is true
      iex> Flagship.FeatureFlags.get("flag_name", true)
      true

  The context can be sent as:
   a string, in which case it will be treated as a user key.
   a map, in which case it will be treated as a context object.
   or not at all, in which case it will be treated as a default context.

  * for information on setting the default context, see the README

  ## Examples
      iex> Flagship.FeatureFlags.get("flag_name", false, "user_key")
      true

      iex> Flag.FeatureFlags.get("flag_name", false, %{:kind => "location", :key => location_code})
      true
  """
  def get(key, fallback) do
    GenServer.call(__MODULE__, {:get, key, fallback, default_context()})
  end

  def get(key, fallback, context) when is_map(context) do
    GenServer.call(__MODULE__, {:get, key, fallback, context})
  end

  def get(key, fallback, user_key) do
    GenServer.call(__MODULE__, {:get, key, fallback, %{:kind => "user", :key => user_key}})
  end

  @doc """
  Reports details about a LaunchDarkly user or context

  ## Examples
      iex> Flagship.FeatureFlags.identify(%{:key => "user_key", :country => "US"})
      :ok
  """
  def identify(user) do
    GenServer.call(__MODULE__, {:identify, user})
  end

  @doc """
  Creates a new LaunchDarkly user

  ## Examples
      iex> Flagship.FeatureFlags.new_user(%{:key => "user_key", :country => "US"})
      %{:key => "user_key", :ip => "" :country => "US", :email => "foo@bar.baz", :first_name => "Foo", :last_name => "Bar", :avatar => "http://www.gravatar.com/avatar/1", :name => "Foo Bar", :anonymous => false, :custom => %{}, :private_attribute_names => []}

  """
  def new_user(user_map) do
    GenServer.call(__MODULE__, {:new_user, user_map})
  end

  @doc """
  Stops all LaunchDarkly client instances

  ## Examples
      iex> Flagship.FeatureFlags.stop_all_instances()
      :ok
  """
  def stop_all_instances() do
    GenServer.call(__MODULE__, {:stop_all_instances})
  end

  @doc false
  def init(:ok) do
    ldclient_options = Application.get_env(:flagship, :ld_client_options, %{})
    launch_darkly_sdk_key = Application.get_env(:flagship, :ld_sdk_key)
    LaunchDarkly.start_instance(launch_darkly_sdk_key, ldclient_options)
    wait_for_initialization()
    {:ok, %{}}
  end

  def terminate(_reason, _state) do
    stop_all_instances()
    :normal
  end

  @doc false
  def handle_call({:get, key, fallback, context}, from, state) do
    Logger.info(
      "Looking up value for LaunchDarkly flag: #{key} with context: #{inspect(context)} from: #{inspect(from)}}"
    )

    {:reply, LaunchDarkly.variation(key, context, fallback), state}
  end

  @doc false
  def handle_call({:identify, user}, from, state) do
    Logger.info("Identifying LaunchDarkly user: #{inspect(user)} from: #{inspect(from)}}")
    {:reply, LaunchDarkly.identify(user), state}
  end

  @doc false
  def handle_call({:stop_all_instances}, from, state) do
    Logger.info("Stopping all LaunchDarkly client instances from: #{inspect(from)}")
    {:reply, LaunchDarkly.stop_all_instances(), state}
  end

  @doc false
  def handle_call({:new_user, user_map}, from, state) do
    Logger.info("Creating a LaunchDarkly user: #{inspect(user_map)} from: #{inspect(from)}}")
    {:reply, LaunchDarkly.new_user(user_map), state}
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

  defp default_context do
    Application.get_env(:flagship, :default_context, %{})
  end
end
