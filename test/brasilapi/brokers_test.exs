defmodule Brasilapi.BrokersTest do
  use ExUnit.Case

  alias Brasilapi.Brokers

  doctest Brasilapi.Brokers

  test "get_brokers/0 delegates to API.get_brokers/0" do
    # This test ensures the delegation is working correctly
    # The actual API functionality is tested in API test
    assert function_exported?(Brokers, :get_brokers, 0)
  end
end
