defmodule Brasilapi.Brokers.Broker do
  @moduledoc """
  Represents a CVM-registered brokerage firm with complete registration information.
  """

  @type t :: %__MODULE__{
          cnpj: String.t(),
          nome_social: String.t(),
          nome_comercial: String.t(),
          bairro: String.t(),
          cep: String.t(),
          codigo_cvm: String.t(),
          complemento: String.t(),
          data_inicio_situacao: String.t(),
          data_patrimonio_liquido: String.t(),
          data_registro: String.t(),
          email: String.t(),
          logradouro: String.t(),
          municipio: String.t(),
          pais: String.t(),
          status: String.t() | nil,
          telefone: String.t(),
          type: String.t() | nil,
          uf: String.t(),
          valor_patrimonio_liquido: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :cnpj,
    :nome_social,
    :nome_comercial,
    :bairro,
    :cep,
    :codigo_cvm,
    :complemento,
    :data_inicio_situacao,
    :data_patrimonio_liquido,
    :data_registro,
    :email,
    :logradouro,
    :municipio,
    :pais,
    :status,
    :telefone,
    :type,
    :uf,
    :valor_patrimonio_liquido
  ]

  @doc """
  Creates a Broker struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      cnpj: Map.get(map, "cnpj"),
      nome_social: Map.get(map, "nome_social"),
      nome_comercial: Map.get(map, "nome_comercial"),
      bairro: Map.get(map, "bairro"),
      cep: Map.get(map, "cep"),
      codigo_cvm: Map.get(map, "codigo_cvm"),
      complemento: Map.get(map, "complemento"),
      data_inicio_situacao: Map.get(map, "data_inicio_situacao"),
      data_patrimonio_liquido: Map.get(map, "data_patrimonio_liquido"),
      data_registro: Map.get(map, "data_registro"),
      email: Map.get(map, "email"),
      logradouro: Map.get(map, "logradouro"),
      municipio: Map.get(map, "municipio"),
      pais: Map.get(map, "pais"),
      status: Map.get(map, "status"),
      telefone: Map.get(map, "telefone"),
      type: Map.get(map, "type"),
      uf: Map.get(map, "uf"),
      valor_patrimonio_liquido: Map.get(map, "valor_patrimonio_liquido")
    }
  end
end
