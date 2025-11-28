defmodule Mix.Tasks.SeedBoards do
  use Mix.Task

  @shortdoc "Creates support boards for production"

  @moduledoc """
  Creates the support boards that are normally created by seeds.exs
  This can be run on production: `mix seed_boards`
  """

  def run(_args) do
    # Start the app
    Mix.Task.run("app.start")

    alias MindSanctuary.Repo
    alias MindSanctuary.Posts.Board

    boards = [
      %{
        name: "Domestic Violence Support",
        description: "A safe space to share experiences and find support for those affected by domestic violence",
        category: "domestic_violence",
        color: "red"
      },
      %{
        name: "Sexual Assault Survivors",
        description: "Support and healing for survivors of sexual assault in a confidential environment",
        category: "sexual_assault",
        color: "purple"
      },
      %{
        name: "Harassment & Bullying",
        description: "Discuss experiences with harassment and bullying, share coping strategies",
        category: "harassment",
        color: "yellow"
      },
      %{
        name: "Stalking Awareness",
        description: "Resources and support for those dealing with stalking situations",
        category: "stalking",
        color: "indigo"
      },
      %{
        name: "Emotional Abuse Recovery",
        description: "Healing from emotional and psychological abuse in relationships",
        category: "emotional_abuse",
        color: "pink"
      },
      %{
        name: "Financial Abuse Support",
        description: "Addressing financial control and economic abuse in relationships",
        category: "financial_abuse",
        color: "green"
      },
      %{
        name: "Resources & Hotlines",
        description: "Share and discover emergency resources, hotlines, and support services",
        category: "support_resources",
        color: "blue"
      }
    ]

    IO.puts("Creating support boards...")

    Enum.each(boards, fn board_attrs ->
      case %Board{}
           |> Board.changeset(board_attrs)
           |> Repo.insert() do
        {:ok, board} ->
          IO.puts("✓ Created board: #{board.name}")

        {:error, changeset} ->
          if changeset.errors[:name] == {"has already been taken", []} do
            IO.puts("⚠ Board already exists: #{board_attrs.name}")
          else
            IO.puts("✗ Failed to create board: #{board_attrs.name}")
            IO.inspect(changeset.errors)
          end
      end
    end)

    IO.puts("Board seeding completed!")
  end
end
