defmodule Brasilapi.Cep.Address do
  @moduledoc """
  Struct representing address data from BrasilAPI CEP v2.

  This struct contains postal code information including address details
  and geographic coordinates when available.
  """

  @type coordinates :: %{String.t() => term()}

  @type location :: %{
          type: String.t(),
          coordinates: coordinates()
        }

  @type t :: %__MODULE__{
          cep: String.t(),
          state: String.t(),
          city: String.t(),
          neighborhood: String.t(),
          street: String.t(),
          service: String.t(),
          location: location() | nil
        }

  @derive Jason.Encoder
  defstruct [
    :cep,
    :state,
    :city,
    :neighborhood,
    :street,
    :service,
    :location
  ]

  @doc """
  Creates an Address struct from a map.

  ## Examples

      iex> map = %{
      ...>   "cep" => "89010025",
      ...>   "state" => "SC",
      ...>   "city" => "Blumenau",
      ...>   "neighborhood" => "Centro",
      ...>   "street" => "Rua Doutor Luiz de Freitas Melro",
      ...>   "service" => "viacep",
      ...>   "location" => %{
      ...>     "type" => "Point",
      ...>     "coordinates" => %{}
      ...>   }
      ...> }
      iex> Brasilapi.Cep.Address.from_map(map)
      %Brasilapi.Cep.Address{
        cep: "89010025",
        state: "SC",
        city: "Blumenau",
        neighborhood: "Centro",
        street: "Rua Doutor Luiz de Freitas Melro",
        service: "viacep",
        location: %{type: "Point", coordinates: %{}}
      }

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      cep: Map.get(map, "cep"),
      state: Map.get(map, "state"),
      city: Map.get(map, "city"),
      neighborhood: Map.get(map, "neighborhood"),
      street: Map.get(map, "street"),
      service: Map.get(map, "service"),
      location: parse_location(Map.get(map, "location"))
    }
  end

  # Private functions

  defp parse_location(nil), do: nil

  defp parse_location(%{} = location) do
    %{
      type: Map.get(location, "type"),
      coordinates: Map.get(location, "coordinates", %{})
    }
  end

  defp parse_location(_), do: nil
end
