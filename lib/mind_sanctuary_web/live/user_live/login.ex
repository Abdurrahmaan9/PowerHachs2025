defmodule MindSanctuaryWeb.UserLive.Login do
  use MindSanctuaryWeb, :live_view

  alias MindSanctuary.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-100 via-white to-purple-100 flex items-center justify-center px-4">
      <!-- Background Elements -->
      <div class="absolute inset-0 overflow-hidden">
        <div class="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-br from-blue-400/20 to-purple-400/20 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-br from-purple-400/20 to-pink-400/20 rounded-full blur-3xl"></div>
      </div>

      <!-- Login Container -->
      <div class="relative w-full max-w-md">
        <!-- Logo/Brand Section -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-600 to-purple-600 rounded-2xl mb-4">
            <.icon name="hero-heart" class="w-8 h-8 text-white" />
          </div>
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            Welcome Back
          </h1>
          <p class="text-gray-600">
            Sign in to continue your wellness journey
          </p>
        </div>

        <!-- Login Card -->
        <div class="bg-white/80 backdrop-blur-sm rounded-3xl shadow-xl border border-white/20 p-8">
          <%= if @current_scope do %>
            <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl">
              <div class="flex items-center">
                <.icon name="hero-information-circle" class="w-5 h-5 text-blue-600 mr-2" />
                <p class="text-sm text-blue-800">
                  You need to reauthenticate to perform sensitive actions on your account.
                </p>
              </div>
            </div>
          <% else %>
            <div class="mb-6 text-center">
              <p class="text-gray-600 mb-2">
                Don't have an account?
                <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-blue-600 hover:text-blue-700 ml-1"
                  phx-no-format
                >
                  Sign up
                </.link>
              </p>
            </div>
          <% end %>

          <%= if local_mail_adapter?() do %>
            <div class="mb-6 p-4 bg-amber-50 border border-amber-200 rounded-xl">
              <div class="flex items-start">
                <.icon name="hero-information-circle" class="w-5 h-5 text-amber-600 mr-2 mt-0.5" />
                <div>
                  <p class="text-sm text-amber-800 font-medium mb-1">Development Mode</p>
                  <p class="text-xs text-amber-700">
                    You are running the local mail adapter.
                    <.link href="/dev/mailbox" class="underline font-medium">Visit the mailbox</.link>
                    to see sent emails.
                  </p>
                </div>
              </div>
            </div>
          <% end %>

          <!-- Email Login Form -->
         <!-- <.form
            :let={f}
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
              <div class="relative">
                <.input
                  readonly={!!@current_scope}
                  field={f[:email]}
                  type="email"
                  placeholder="Enter your email"
                  autocomplete="username"
                  required
                  phx-mounted={JS.focus()}
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <.icon name="hero-envelope" class="w-5 h-5 text-gray-400" />
                </div>
              </div>
            </div>

            <button
              type="submit"
              class="w-full group inline-flex items-center justify-center px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105"
            >
              <.icon name="hero-paper-airplane" class="w-5 h-5 mr-2 group-hover:translate-x-1 transition-transform duration-200" />
              Send Magic Link
            </button>
          </.form>

          Divider
          <div class="relative my-8">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-4 bg-white text-gray-500">or continue with</span>
            </div>
          </div> -->

          <!-- Password Login Form -->
          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
              <div class="relative">
                <.input
                  readonly={!!@current_scope}
                  field={f[:email]}
                  type="email"
                  placeholder="Enter your email"
                  autocomplete="username"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <.icon name="hero-envelope" class="w-5 h-5 text-gray-400" />
                </div>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Password</label>
              <div class="relative">
                <.input
                  field={@form[:password]}
                  type="password"
                  placeholder="Enter your password"
                  autocomplete="current-password"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <.icon name="hero-lock-closed" class="w-5 h-5 text-gray-400" />
                </div>
              </div>
            </div>

            <div class="flex items-center">
              <input
                type="checkbox"
                id="remember_me"
                name={@form[:remember_me].name}
                value="true"
                class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <label for="remember_me" class="ml-2 text-sm text-gray-700">
                Remember me for 30 days
              </label>
            </div>

            <button
              type="submit"
              name={@form[:remember_me].name}
              value="true"
              class="w-full group inline-flex items-center justify-center px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105"
            >
              <.icon name="hero-arrow-right" class="w-5 h-5 mr-2 group-hover:translate-x-1 transition-transform duration-200" />
              Sign In & Stay Signed In
            </button>

            <button
              type="submit"
              class="w-full inline-flex items-center justify-center px-6 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:border-blue-600 hover:text-blue-600 transition-all duration-300"
            >
              <.icon name="hero-clock" class="w-5 h-5 mr-2" />
              Sign In Only This Time
            </button>
          </.form>
        </div>

        <!-- Footer Links -->
        <div class="mt-8 text-center">
          <p class="text-sm text-gray-600">
            <.link navigate={~p"/users/register"} class="font-medium text-blue-600 hover:text-blue-700">
              Create an account
            </.link>
            {" • "}
            <.link navigate="#" class="font-medium text-gray-600 hover:text-gray-700">
              Forgot password?
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:mind_sanctuary, MindSanctuary.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
