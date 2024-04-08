defmodule Flagship do
  @moduledoc """
  Main interface to working with feature flags in a test environment.
  """
  @doc """
  Flags are persisted across tests, prefer with_flag/3 when setting
  a feature flag for a single test so that it is reset at the end of
  the test
  """

  def set_flag(name, value) when is_binary(name) and is_boolean(value) do
    {:ok, flag} = impl().test_flag(name)
    flag_builder = impl().set_value(value, flag)
    impl().test_update(flag_builder)
  end

  def set_flag(name, value) when is_binary(name) do
    {:ok, flag} = impl().test_flag(name)
    flag = impl().value_for_all(value, flag)
    flag_builder = impl().set_value(value, flag)
    impl().test_update(flag_builder)
  end

  @doc """
  Sets the flag value, then executess the given test, and resets the flag value
  """
  def with_flag(name, values, test) when is_list(values) and is_binary(name) do
    for value <- values, do: with_flag(name, value, test)
  end

  def with_flag(name, value, test) when is_binary(name) do
    default = Flagship.FeatureFlags.get(name, false)
    set_flag(name, value)
    test.()
    set_flag(name, default)
  end

  @doc """
  Test macro to have two seperate tests with different values for a feature flag.
  This is handy when the test does stateful operations like database calls and you
  want ecto to clean up data between tests.


  The example below will create two tests named:
  - it works with OPS-1000 set to true
  - it works with OPS-1000 set to false

  ## Example

      test_with_flag "it works", "OPS-1000-feature-flag", [true, false] do
        game = create_game!()

        assert [game] = App.Games.list_games()
      end
  """
  defmacro test_with_flag(test_name, flag_name, flag_values, test_block) do
    for flag_value <- get_flag_values(flag_values) do
      quote do
        test "#{unquote(test_name)} with #{unquote(flag_name_abbreviation(flag_name))} set to #{unquote(flag_value)}" do
          with_flag(unquote(flag_name), unquote(flag_value), fn -> unquote(test_block) end)
        end
      end
    end
  end

  @doc """
  Same as test_with_flag/4 but with the ability to pass in a test context

  The example below will create two tests named:
  - renders with valid html with OPS-1000 set to true
  - renders with valid html with OPS-1000 set to false

  ## Example

      test_with_flag "renders with valid html", %{conn: conn}, "OPS-1000-feature-flag", [true, false] do
         ...
      end
  """
  defmacro test_with_flag(test_name, test_context, flag_name, flag_values, test_block) do
    for flag_value <- get_flag_values(flag_values) do
      quote do
        test "#{unquote(test_name)} with #{unquote(flag_name_abbreviation(flag_name))} set to #{unquote(flag_value)}",
             unquote(test_context) do
          with_flag(unquote(flag_name), unquote(flag_value), fn -> unquote(test_block) end)
        end
      end
    end
  end

  def impl do
    System.get_env("FLAGSHIP_IMPLEMENTATION", "Flagship.LaunchDarkly")
    |> List.wrap()
    |> Module.safe_concat()
  end

  defp get_flag_values(values) when is_list(values), do: values
  defp get_flag_values(value), do: [value]

  defp flag_name_abbreviation(flag_name) do
    flag_name
    |> String.split("-")
    |> Enum.take(2)
    |> Enum.join("-")
  end
end
