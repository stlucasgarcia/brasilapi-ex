defmodule Brasilapi.Cnpj.Company do
  @moduledoc """
  Represents a company data structure from the CNPJ API.
  """

  @type qsa :: %{
          :pais => String.t() | nil,
          :nome_socio => String.t() | nil,
          :codigo_pais => String.t() | nil,
          :faixa_etaria => String.t() | nil,
          :cnpj_cpf_do_socio => String.t() | nil,
          :qualificacao_socio => String.t() | nil,
          :codigo_faixa_etaria => integer() | nil,
          :data_entrada_sociedade => String.t() | nil,
          :identificador_de_socio => integer() | nil,
          :cpf_representante_legal => String.t() | nil,
          :nome_representante_legal => String.t() | nil,
          :codigo_qualificacao_socio => integer() | nil,
          :qualificacao_representante_legal => String.t() | nil,
          :codigo_qualificacao_representante_legal => integer() | nil
        }

  @type cnae_secundario :: %{
          :codigo => integer() | nil,
          :descricao => String.t() | nil
        }

  @type regime_tributario :: %{
          optional(:dt_fim_op_simples) => String.t() | nil,
          optional(:dt_ini_op_simples) => String.t() | nil,
          optional(:dt_opcao_mei) => String.t() | nil,
          optional(:dt_exclusao_mei) => String.t() | nil
        }

  @type t :: %__MODULE__{
          uf: String.t() | nil,
          cep: String.t() | nil,
          qsa: list(qsa()),
          cnpj: String.t() | nil,
          pais: String.t() | nil,
          email: String.t() | nil,
          porte: String.t() | nil,
          bairro: String.t() | nil,
          numero: String.t() | nil,
          ddd_fax: String.t() | nil,
          municipio: String.t() | nil,
          logradouro: String.t() | nil,
          cnae_fiscal: integer() | nil,
          codigo_pais: String.t() | nil,
          complemento: String.t() | nil,
          codigo_porte: integer() | nil,
          razao_social: String.t() | nil,
          nome_fantasia: String.t() | nil,
          capital_social: number() | nil,
          ddd_telefone_1: String.t() | nil,
          ddd_telefone_2: String.t() | nil,
          opcao_pelo_mei: String.t() | nil,
          descricao_porte: String.t() | nil,
          codigo_municipio: integer() | nil,
          cnaes_secundarios: list(cnae_secundario()),
          natureza_juridica: String.t() | nil,
          regime_tributario: list(regime_tributario()),
          situacao_especial: String.t() | nil,
          opcao_pelo_simples: String.t() | nil,
          situacao_cadastral: integer() | nil,
          data_opcao_pelo_mei: String.t() | nil,
          data_exclusao_do_mei: String.t() | nil,
          cnae_fiscal_descricao: String.t() | nil,
          codigo_municipio_ibge: integer() | nil,
          data_inicio_atividade: String.t() | nil,
          data_situacao_especial: String.t() | nil,
          data_opcao_pelo_simples: String.t() | nil,
          data_situacao_cadastral: String.t() | nil,
          nome_cidade_no_exterior: String.t() | nil,
          codigo_natureza_juridica: integer() | nil,
          data_exclusao_do_simples: String.t() | nil,
          motivo_situacao_cadastral: integer() | nil,
          ente_federativo_responsavel: String.t() | nil,
          identificador_matriz_filial: integer() | nil,
          qualificacao_do_responsavel: integer() | nil,
          descricao_situacao_cadastral: String.t() | nil,
          descricao_tipo_de_logradouro: String.t() | nil,
          descricao_motivo_situacao_cadastral: String.t() | nil,
          descricao_identificador_matriz_filial: String.t() | nil
        }

  defstruct [
    :uf,
    :cep,
    :qsa,
    :cnpj,
    :pais,
    :email,
    :porte,
    :bairro,
    :numero,
    :ddd_fax,
    :municipio,
    :logradouro,
    :cnae_fiscal,
    :codigo_pais,
    :complemento,
    :codigo_porte,
    :razao_social,
    :nome_fantasia,
    :capital_social,
    :ddd_telefone_1,
    :ddd_telefone_2,
    :opcao_pelo_mei,
    :descricao_porte,
    :codigo_municipio,
    :cnaes_secundarios,
    :natureza_juridica,
    :regime_tributario,
    :situacao_especial,
    :opcao_pelo_simples,
    :situacao_cadastral,
    :data_opcao_pelo_mei,
    :data_exclusao_do_mei,
    :cnae_fiscal_descricao,
    :codigo_municipio_ibge,
    :data_inicio_atividade,
    :data_situacao_especial,
    :data_opcao_pelo_simples,
    :data_situacao_cadastral,
    :nome_cidade_no_exterior,
    :codigo_natureza_juridica,
    :data_exclusao_do_simples,
    :motivo_situacao_cadastral,
    :ente_federativo_responsavel,
    :identificador_matriz_filial,
    :qualificacao_do_responsavel,
    :descricao_situacao_cadastral,
    :descricao_tipo_de_logradouro,
    :descricao_motivo_situacao_cadastral,
    :descricao_identificador_matriz_filial
  ]

  @doc """
  Converts a map from the API response to a Company struct.

  ## Examples

      iex> data = %{"cnpj" => "11000000000197", "razao_social" => "ACME INC"}
      iex> Brasilapi.Cnpj.Company.from_map(data)
      %Brasilapi.Cnpj.Company{cnpj: "11000000000197", razao_social: "ACME INC"}

  """
  @spec from_map(map()) :: t()
  def from_map(data) when is_map(data) do
    %__MODULE__{
      uf: data["uf"],
      cep: data["cep"],
      qsa: data["qsa"] || [],
      cnpj: data["cnpj"],
      pais: data["pais"],
      email: data["email"],
      porte: data["porte"],
      bairro: data["bairro"],
      numero: data["numero"],
      ddd_fax: data["ddd_fax"],
      municipio: data["municipio"],
      logradouro: data["logradouro"],
      cnae_fiscal: data["cnae_fiscal"],
      codigo_pais: data["codigo_pais"],
      complemento: data["complemento"],
      codigo_porte: data["codigo_porte"],
      razao_social: data["razao_social"],
      nome_fantasia: data["nome_fantasia"],
      capital_social: data["capital_social"],
      ddd_telefone_1: data["ddd_telefone_1"],
      ddd_telefone_2: data["ddd_telefone_2"],
      opcao_pelo_mei: data["opcao_pelo_mei"],
      descricao_porte: data["descricao_porte"],
      codigo_municipio: data["codigo_municipio"],
      cnaes_secundarios: data["cnaes_secundarios"] || [],
      natureza_juridica: data["natureza_juridica"],
      regime_tributario: data["regime_tributario"] || [],
      situacao_especial: data["situacao_especial"],
      opcao_pelo_simples: data["opcao_pelo_simples"],
      situacao_cadastral: data["situacao_cadastral"],
      data_opcao_pelo_mei: data["data_opcao_pelo_mei"],
      data_exclusao_do_mei: data["data_exclusao_do_mei"],
      cnae_fiscal_descricao: data["cnae_fiscal_descricao"],
      codigo_municipio_ibge: data["codigo_municipio_ibge"],
      data_inicio_atividade: data["data_inicio_atividade"],
      data_situacao_especial: data["data_situacao_especial"],
      data_opcao_pelo_simples: data["data_opcao_pelo_simples"],
      data_situacao_cadastral: data["data_situacao_cadastral"],
      nome_cidade_no_exterior: data["nome_cidade_no_exterior"],
      codigo_natureza_juridica: data["codigo_natureza_juridica"],
      data_exclusao_do_simples: data["data_exclusao_do_simples"],
      motivo_situacao_cadastral: data["motivo_situacao_cadastral"],
      ente_federativo_responsavel: data["ente_federativo_responsavel"],
      identificador_matriz_filial: data["identificador_matriz_filial"],
      qualificacao_do_responsavel: data["qualificacao_do_responsavel"],
      descricao_situacao_cadastral: data["descricao_situacao_cadastral"],
      descricao_tipo_de_logradouro: data["descricao_tipo_de_logradouro"],
      descricao_motivo_situacao_cadastral: data["descricao_motivo_situacao_cadastral"],
      descricao_identificador_matriz_filial: data["descricao_identificador_matriz_filial"]
    }
  end
end
