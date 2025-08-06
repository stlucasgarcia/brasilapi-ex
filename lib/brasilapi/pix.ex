defmodule Brasilapi.Pix do
  @moduledoc """
  PIX domain module for BrasilAPI.

  This module provides the main interface for PIX (Brazilian instant payment system)
  functionality, including information about PIX participants.
  """

  alias Brasilapi.Pix.API

  @doc """
  Fetches information about all PIX participants.

  Delegates to `Brasilapi.Pix.API.get_participants/0`.
  """
  defdelegate get_participants(), to: API
end
