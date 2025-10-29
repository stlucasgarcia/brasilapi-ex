defmodule Brasilapi.Holidays.HolidayTest do
  use ExUnit.Case
  doctest Brasilapi.Holidays.Holiday

  alias Brasilapi.Holidays.Holiday

  describe "from_map/1" do
    test "creates Holiday struct from complete map with string keys" do
      map = %{
        "date" => "2021-01-01",
        "name" => "Confraternização mundial",
        "type" => "national",
        "full_name" => "Confraternização Universal"
      }

      result = Holiday.from_map(map)

      assert %Holiday{
               date: "2021-01-01",
               name: "Confraternização mundial",
               type: "national",
               full_name: "Confraternização Universal"
             } = result
    end

    test "creates Holiday struct from map without full_name" do
      map = %{
        "date" => "2021-09-07",
        "name" => "Independência do Brasil",
        "type" => "national"
      }

      result = Holiday.from_map(map)

      assert %Holiday{
               date: "2021-09-07",
               name: "Independência do Brasil",
               type: "national",
               full_name: nil
             } = result
    end

    test "creates Holiday struct from empty map" do
      result = Holiday.from_map(%{})

      assert %Holiday{
               date: nil,
               name: nil,
               type: nil,
               full_name: nil
             } = result
    end

    test "creates Holiday struct with nil values" do
      map = %{
        "date" => nil,
        "name" => nil,
        "type" => nil,
        "full_name" => nil
      }

      result = Holiday.from_map(map)

      assert %Holiday{
               date: nil,
               name: nil,
               type: nil,
               full_name: nil
             } = result
    end
  end
end
