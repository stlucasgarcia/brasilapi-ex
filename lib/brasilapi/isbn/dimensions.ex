defmodule Brasilapi.Isbn.Dimensions do
  @moduledoc """
  Represents book dimensions with width, height, and measurement unit.
  """

  @type t :: %__MODULE__{
          width: number() | nil,
          height: number() | nil,
          unit: String.t() | nil
        }

  @derive Jason.Encoder
  defstruct [
    :width,
    :height,
    :unit
  ]

  @doc """
  Creates a Dimensions struct from API response data.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      width: Map.get(map, "width"),
      height: Map.get(map, "height"),
      unit: Map.get(map, "unit")
    }
  end
end
