defmodule Brasilapi.Pix.Participant do
  @moduledoc """
  Represents a PIX participant with their information from the Brazilian instant payment system.
  """

  @type t :: %__MODULE__{
          ispb: String.t(),
          nome: String.t(),
          nome_reduzido: String.t(),
          modalidade_participacao: String.t(),
          tipo_participacao: String.t(),
          inicio_operacao: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :ispb,
    :nome,
    :nome_reduzido,
    :modalidade_participacao,
    :tipo_participacao,
    :inicio_operacao
  ]

  @doc """
  Creates a Participant struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(%{
        "ispb" => ispb,
        "nome" => nome,
        "nome_reduzido" => nome_reduzido,
        "modalidade_participacao" => modalidade_participacao,
        "tipo_participacao" => tipo_participacao,
        "inicio_operacao" => inicio_operacao
      }) do
    %__MODULE__{
      ispb: ispb,
      nome: nome,
      nome_reduzido: nome_reduzido,
      modalidade_participacao: modalidade_participacao,
      tipo_participacao: tipo_participacao,
      inicio_operacao: inicio_operacao
    }
  end
end
