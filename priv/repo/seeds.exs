# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MindSanctuary.Repo.insert!(%MindSanctuary.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
now = DateTime.utc_now(:second)
######### ADMIN SEED ACCOUNT #################
{:ok, admin} =
  %{
    email: "admin@myspace.com",
    username: UniqueNamesGenerator.generate([:adjectives, :animals]),
    role: "admin"
  }
  |> MindSanctuary.Accounts.register_user()

admin
|> MindSanctuary.Accounts.update_user_password(%{
  password: "admin@myspace.com",
  password_confirmation: "admin@myspace.com",
  confirmed_at: now
})

######### USER SEED ACCOUNT #################
{:ok, user} =
  %{
    email: "user@myspace.com",
    username: UniqueNamesGenerator.generate([:adjectives, :animals]),
    role: "user"
  }
  |> MindSanctuary.Accounts.register_user()

user
|> MindSanctuary.Accounts.update_user_password(%{
  password: "user@myspace.com",
  password_confirmation: "user@myspace.com",
  confirmed_at: now
})

######### VOLUNTEER SEED ACCOUNT #################
{:ok, volunteer} =
  %{
    email: "volunteer@myspace.com",
    username: UniqueNamesGenerator.generate([:adjectives, :animals]),
    role: "volunteer"
  }
  |> MindSanctuary.Accounts.register_user()

volunteer
|> MindSanctuary.Accounts.update_user_password(%{
  password: "volunteer@myspace.com",
  password_confirmation: "volunteer@myspace.com",
  confirmed_at: now
})

alias MindSanctuary.Repo
alias MindSanctuary.Chats.Chat

# Create public chat with ID = 1
Repo.insert!(%Chat{id: 1, title: "Public Chat", type: "public"})

######### SUPPORT BOARDS #################
alias MindSanctuary.Posts

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

Enum.each(boards, fn board_attrs ->
  Posts.create_board(board_attrs)
end)
