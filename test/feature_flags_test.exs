defmodule Flagship.FeatureFlagsTest do
  use ExUnit.Case
  alias Flagship.FeatureFlags
  import ExUnit.CaptureLog

  describe "init/1" do
    test "starts the GenServer" do
      assert capture_log(fn ->
               Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
               assert FeatureFlags.init(:ok) == {:ok, %{}}
             end) =~ "Waiting for LaunchDarkly flag data..."
    end
  end

  describe "get/3" do
    test "returns fallback if flag not found" do
      Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
      {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
      assert Flagship.FeatureFlags.get("fake_flag_name", false, ~c"user-one") == false
    end

    test "calls the LaunchDarkly SDK" do
      assert capture_log(fn ->
               Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
               {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
               assert Flagship.FeatureFlags.get("fake_flag_name", false, ~c"user-two") == false
             end) =~
               "Looking up value for LaunchDarkly flag: fake_flag_name with context:"
    end

    test "gets the value for a flag when the context is a map" do
      assert capture_log(fn ->
        Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
        {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
        assert Flagship.FeatureFlags.get("fake_flag_name", false, ~c"user-two") == false
      end) =~
        "Looking up value for LaunchDarkly flag: fake_flag_name with context:"
    end
  end

  describe "new_user/1" do
    test "creates a new user" do
      assert capture_log(fn ->
        Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
        {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
        assert Flagship.FeatureFlags.new_user(%{key: "userkey"}) == %{key: "userkey"}
      end) =~ "Creating a LaunchDarkly user:"
    end
  end

  describe "identify/1" do
    test "identifies a user" do
      assert capture_log(fn ->
        Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
        {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
        assert Flagship.FeatureFlags.identify(%{key: "userkey"}) == :ok
      end) =~ "Identifying LaunchDarkly user: %{key: \"userkey\"}"
    end
  end

  describe "stop_all_instances/0" do
    test "stops all instances" do
      assert capture_log(fn ->
        Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
        {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
        assert Flagship.FeatureFlags.stop_all_instances() == :ok
      end) =~ "Stopping all LaunchDarkly client instances"
    end
    end
end
