defmodule Brasilapi.Pix.API do
  @moduledoc """
  Client for BrasilAPI PIX endpoints.

  Provides functions to fetch information about PIX (Brazilian instant payment system) participants.
  """

  alias Brasilapi.Client
  alias Brasilapi.Pix.Participant

  @doc """
  Fetches information about all PIX participants for the current or previous day.

  ## Examples

      iex> Brasilapi.Pix.API.get_participants()
      {:ok, [%Brasilapi.Pix.Participant{ispb: "360305", nome: "CAIXA ECONOMICA FEDERAL", nome_reduzido: "CAIXA ECONOMICA FEDERAL"}]}

      iex> Brasilapi.Pix.API.get_participants()
      {:error, %{reason: :timeout}}

  """
  @spec get_participants() :: {:ok, [Participant.t()]} | {:error, map()}
  def get_participants do
    with {:ok, participants} when is_list(participants) <- Client.get("/pix/v1/participants") do
      parsed_participants = Enum.map(participants, &Participant.from_map/1)
      {:ok, parsed_participants}
    end
  end
end
