defmodule Brasilapi.Banks.Bank do
  @moduledoc """
  Represents a Brazilian bank with its identifying information.
  """

  @type t :: %__MODULE__{
          ispb: String.t(),
          name: String.t(),
          code: integer(),
          full_name: String.t()
        }

  @derive Jason.Encoder
  defstruct [:ispb, :name, :code, :full_name]

  @doc """
  Creates a Bank struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(%{
        "ispb" => ispb,
        "name" => name,
        "code" => code,
        "fullName" => full_name
      }) do
    %__MODULE__{
      ispb: ispb,
      name: name,
      code: code,
      full_name: full_name
    }
  end
end
