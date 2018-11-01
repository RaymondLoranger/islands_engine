defmodule Islands.Engine.Coord.Color do
  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.Island

  @spec for(Island.type() | atom) :: ANSI.ansidata()
  def for(:atoll), do: format(:sandy_brown, "<a>")
  def for(:dot), do: format(:teak, "<d>")
  def for(:l_shape), do: format(:tenne, "<l>")
  def for(:s_shape), do: format(:khaki, "<s>")
  def for(:square), do: format(:chocolate, "<q>")
  def for(:atoll_hit), do: format(:islamic_green, ">a<")
  def for(:dot_hit), do: format(:spring_green, ">d<")
  def for(:l_shape_hit), do: format(:dark_green, ">l<")
  def for(:s_shape_hit), do: format(:pale_green, ">s<")
  def for(:square_hit), do: format(:lawn_green, ">q<")
  def for(:hit), do: format(:islamic_green, ">h<")
  def for(:miss), do: format(:blue_ribbon, "<m>")
  def for(:board_miss), do: format(:deep_sky_blue, "<m>")
  def for(nil), do: format(:dodger_blue, "<o>")

  ## Private functions

  @spec format(atom, String.t()) :: ANSI.ansidata()
  defp format(attr, value),
    do: ANSI.format([attr, :"#{attr}_background", value], true)
end
