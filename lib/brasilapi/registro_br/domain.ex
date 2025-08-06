defmodule Brasilapi.RegistroBr.Domain do
  @moduledoc """
  Represents a Brazilian domain (.br) with its registration information.
  """

  @type t :: %__MODULE__{
          status_code: integer(),
          status: String.t(),
          fqdn: String.t(),
          hosts: [String.t()] | nil,
          publication_status: String.t() | nil,
          expires_at: String.t() | nil,
          suggestions: [String.t()] | nil,
          exempt: boolean() | nil,
          fqdnace: String.t() | nil
        }

  @derive Jason.Encoder
  defstruct [
    :status_code,
    :status,
    :fqdn,
    :hosts,
    :publication_status,
    :expires_at,
    :suggestions,
    :exempt,
    :fqdnace
  ]

  @doc """
  Creates a Domain struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      status_code: Map.get(map, "status_code"),
      status: Map.get(map, "status"),
      fqdn: Map.get(map, "fqdn"),
      hosts: Map.get(map, "hosts"),
      publication_status: Map.get(map, "publication-status"),
      expires_at: Map.get(map, "expires-at"),
      suggestions: Map.get(map, "suggestions"),
      exempt: Map.get(map, "exempt"),
      fqdnace: Map.get(map, "fqdnace")
    }
  end
end
