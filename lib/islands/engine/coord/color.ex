defmodule Islands.Engine.Coord.Color do
  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.Island

  @spec color_for(Island.type() | atom) :: ANSI.ansidata()
  def color_for(:atoll), do: format(:sandy_brown, "<a>")
  def color_for(:dot), do: format(:teak, "<d>")
  def color_for(:l_shape), do: format(:tenne, "<l>")
  def color_for(:s_shape), do: format(:khaki, "<s>")
  def color_for(:square), do: format(:chocolate, "<q>")
  def color_for(:atoll_hit), do: format(:islamic_green, ">a<")
  def color_for(:dot_hit), do: format(:spring_green, ">d<")
  def color_for(:l_shape_hit), do: format(:dark_green, ">l<")
  def color_for(:s_shape_hit), do: format(:pale_green, ">s<")
  def color_for(:square_hit), do: format(:lawn_green, ">q<")
  def color_for(:hit), do: format(:islamic_green, ">h<")
  def color_for(:miss), do: format(:blue_ribbon, "<m>")
  def color_for(:board_miss), do: format(:deep_sky_blue, "<m>")
  def color_for(nil), do: format(:dodger_blue, "<o>")

  ## Private functions

  @spec format(atom, String.t()) :: ANSI.ansidata()
  defp format(attr, value),
    do: ANSI.format([attr, :"#{attr}_background", value], true)
end
