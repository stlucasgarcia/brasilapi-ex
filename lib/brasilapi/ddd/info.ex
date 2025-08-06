defmodule Brasilapi.Ddd.Info do
  @moduledoc """
  Struct representing DDD information from BrasilAPI DDD v1.

  This struct contains DDD information including the state and list of cities
  that use the specified area code.
  """

  @type t :: %__MODULE__{
          state: String.t(),
          cities: list(String.t())
        }

  @derive Jason.Encoder
  defstruct [
    :state,
    :cities
  ]

  @doc """
  Creates a DDD Info struct from a map.

  ## Examples

      iex> map = %{
      ...>   "state" => "SP",
      ...>   "cities" => [
      ...>     "EMBU",
      ...>     "VÁRZEA PAULISTA", 
      ...>     "VARGEM GRANDE PAULISTA",
      ...>     "SÃO PAULO"
      ...>   ]
      ...> }
      iex> Brasilapi.Ddd.Info.from_map(map)
      %Brasilapi.Ddd.Info{
        state: "SP",
        cities: ["EMBU", "VÁRZEA PAULISTA", "VARGEM GRANDE PAULISTA", "SÃO PAULO"]
      }

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      state: Map.get(map, "state"),
      cities: Map.get(map, "cities", [])
    }
  end
end