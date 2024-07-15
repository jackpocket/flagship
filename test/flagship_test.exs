defmodule FlagshipTest do
  use ExUnit.Case

  describe "set_flag/2" do
    test "sets a flag to true" do
      assert Flagship.set_flag("flag_name", true) == :ok
    end

    test "sets a flag to false" do
      assert Flagship.set_flag("flag_name", false) == :ok
    end

    test "sets a flag to non-boolean value" do
      assert Flagship.set_flag("flag_name", 53704) == :ok
    end
  end

  describe "with_flag/3" do
    test "sets an expected value before running a test, then resets the value" do
      Application.put_env(:flagship, :ld_sdk_key, "fake-sdk-key")
      {:ok, _pid} = Flagship.FeatureFlags.start_link(name: Flagship.FeatureFlags)
      assert Flagship.with_flag("flag_name", [true, false], fn -> true end) == [:ok, :ok]
    end
  end
end
