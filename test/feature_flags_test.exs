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
      assert Flagship.FeatureFlags.get("fake_flag_name", false, 'user-one') == false
    end

    test "calls the LaunchDarkly SDK" do
      assert capture_log(fn ->
               Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
               {:ok, _pid} = FeatureFlags.start_link(name: Flagship.FeatureFlags)
               assert Flagship.FeatureFlags.get("fake_flag_name", false, 'user-two') == false
             end) =~
               "Looking up value for LaunchDarkly flag: fake_flag_name with context:"
    end
  end
end
