defmodule Brasilapi.Rates.Rate do
  @moduledoc """
  Represents a Brazilian tax rate or official index with its value.
  """

  @type t :: %__MODULE__{
          nome: String.t(),
          valor: float()
        }

  @derive Jason.Encoder
  defstruct [:nome, :valor]

  @doc """
  Creates a Rate struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(%{
        "nome" => nome,
        "valor" => valor
      }) do
    %__MODULE__{
      nome: nome,
      valor: valor
    }
  end
end
