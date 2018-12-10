defmodule Islands.Engine.Game.Grid.Tile do
  @moduledoc "Convenience module for client applications."

  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.Island

  @spec new(Island.type() | nil) :: ANSI.ansidata()
  def new(:atoll), do: format(:sandy_brown, "<a>")
  def new(:dot), do: format(:teak, "<d>")
  def new(:l_shape), do: format(:tenne, "<l>")
  def new(:s_shape), do: format(:khaki, "<s>")
  def new(:square), do: format(:chocolate, "<q>")
  def new(:atoll_hit), do: format(:islamic_green, ">a<")
  def new(:dot_hit), do: format(:spring_green, ">d<")
  def new(:l_shape_hit), do: format(:dark_green, ">l<")
  def new(:s_shape_hit), do: format(:pale_green, ">s<")
  def new(:square_hit), do: format(:lawn_green, ">q<")
  def new(:hit), do: format(:islamic_green, ">h<")
  def new(:miss), do: format(:blue_ribbon, "<m>")
  # def new(:board_miss), do: format(:dodger_blue, "<m>")
  def new(:board_miss), do: format(:blue_ribbon, "<m>")
  def new(nil), do: format(:deep_sky_blue, "<o>")

  ## Private functions

  @spec format(atom, String.t()) :: ANSI.ansidata()
  defp format(attr, value),
    do: ANSI.format([attr, :"#{attr}_background", value], true)
end
