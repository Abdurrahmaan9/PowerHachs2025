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
admin_password = :crypto.strong_rand_bytes(12) |> Base.encode64() |> binary_part(0, 12)
admin_username = UniqueNamesGenerator.generate([:adjectives, :animals])
admin_email = "admin@myspace.com"

IO.puts("=== ADMIN ACCOUNT ===")
IO.puts("Username: #{admin_username}")
IO.puts("Email: #{admin_email}")
IO.puts("Password: #{admin_password}")
IO.puts("=======================")

{:ok, admin} =
  %{
    email: admin_email,
    username: admin_username,
    role: "admin"
  }
  |> MindSanctuary.Accounts.register_user()

admin
|> MindSanctuary.Accounts.update_user_password(%{
  password: admin_password,
  password_confirmation: admin_password,
  confirmed_at: now
})

######### USER SEED ACCOUNT #################
user_password = :crypto.strong_rand_bytes(12) |> Base.encode64() |> binary_part(0, 12)
user_username = UniqueNamesGenerator.generate([:adjectives, :animals])
user_email = "user@myspace.com"

IO.puts("\n=== USER ACCOUNT ===")
IO.puts("Username: #{user_username}")
IO.puts("Email: #{user_email}")
IO.puts("Password: #{user_password}")
IO.puts("===================")

{:ok, user} =
  %{
    email: user_email,
    username: user_username,
    role: "user"
  }
  |> MindSanctuary.Accounts.register_user()

user
|> MindSanctuary.Accounts.update_user_password(%{
  password: user_password,
  password_confirmation: user_password,
  confirmed_at: now
})

######### VOLUNTEER SEED ACCOUNT #################
volunteer_password = :crypto.strong_rand_bytes(12) |> Base.encode64() |> binary_part(0, 12)
volunteer_username = UniqueNamesGenerator.generate([:adjectives, :animals])
volunteer_email = "volunteer@myspace.com"

IO.puts("\n=== VOLUNTEER ACCOUNT ===")
IO.puts("Username: #{volunteer_username}")
IO.puts("Email: #{volunteer_email}")
IO.puts("Password: #{volunteer_password}")
IO.puts("========================")

{:ok, volunteer} =
  %{
    email: volunteer_email,
    username: volunteer_username,
    role: "volunteer"
  }
  |> MindSanctuary.Accounts.register_user()

volunteer
|> MindSanctuary.Accounts.update_user_password(%{
  password: volunteer_password,
  password_confirmation: volunteer_password,
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
