defmodule MindSanctuaryWeb.UserLive.Registration do
  use MindSanctuaryWeb, :live_view

  alias MindSanctuary.Accounts
  alias MindSanctuary.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center px-4">
      <!-- Background Elements -->
      <div class="absolute inset-0 overflow-hidden">
        <div class="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-br from-purple-400/20 to-pink-400/20 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-br from-blue-400/20 to-purple-400/20 rounded-full blur-3xl"></div>
      </div>

      <!-- Registration Container -->
      <div class="relative w-full max-w-md">
        <!-- Logo/Brand Section -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-600 to-purple-600 rounded-2xl mb-4">
            <.icon name="hero-sparkles" class="w-8 h-8 text-white" />
          </div>
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            Join MindSanctuary
          </h1>
          <p class="text-gray-600">
            Start your journey to better mental wellness
          </p>
        </div>

        <!-- Registration Card -->
        <div class="bg-white/80 backdrop-blur-sm rounded-3xl shadow-xl border border-white/20 p-8">
          <div class="mb-6 text-center">
            <p class="text-gray-600 mb-2">
              Already have an account?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-blue-600 hover:text-blue-700 ml-1">
                Sign in
              </.link>
            </p>
          </div>

          <.form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            class="space-y-6"
          >
            <!-- Username Field -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                <.icon name="hero-user" class="w-4 h-4 mr-1 inline" />
                Username (Auto-generated for anonymity)
              </label>
              <div class="relative">
                <.input
                  field={@form[:username]}
                  type="text"
                  value={UniqueNamesGenerator.generate([:adjectives, :animals])}
                  readonly
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-600"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <.icon name="hero-shield-check" class="w-5 h-5 text-gray-400" />
                </div>
              </div>
              <p class="mt-1 text-xs text-gray-500">
                Your identity is protected with an anonymous username
              </p>
            </div>

            <!-- Email Field -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                <.icon name="hero-envelope" class="w-4 h-4 mr-1 inline" />
                Email Address
              </label>
              <div class="relative">
                <.input
                  field={@form[:email]}
                  type="email"
                  placeholder="Enter your email address"
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

            <!-- Role Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                <.icon name="hero-identification" class="w-4 h-4 mr-1 inline" />
                Account Type
              </label>
              <div class="relative">
                <.input
                  field={@form[:role]}
                  type="select"
                  prompt="-- select your role --"
                  options={[
                    {"Regular User", "user"},
                    {"Volunteer (Staff)", "volunteer"}
                  ]}
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 appearance-none cursor-pointer"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <.icon name="hero-chevron-down" class="w-5 h-5 text-gray-400" />
                </div>
              </div>
              <div class="mt-2 space-y-1">
                <div class="flex items-center text-xs text-gray-600">
                  <.icon name="hero-user" class="w-3 h-3 mr-1" />
                  <span>Regular User - Access personal wellness tools</span>
                </div>
                <div class="flex items-center text-xs text-gray-600">
                  <.icon name="hero-heart" class="w-3 h-3 mr-1" />
                  <span>Volunteer - Help others in the community</span>
                </div>
              </div>
            </div>

            <!-- Terms and Privacy Notice -->
            <div class="p-4 bg-blue-50 border border-blue-200 rounded-xl">
              <div class="flex items-start">
                <.icon name="hero-information-circle" class="w-5 h-5 text-blue-600 mr-2 mt-0.5" />
                <div>
                  <p class="text-sm text-blue-800 font-medium mb-1">Privacy & Security</p>
                  <p class="text-xs text-blue-700">
                    Your data is encrypted and never shared. We'll send you a temporary password via email to complete your registration.
                  </p>
                </div>
              </div>
            </div>

            <!-- Submit Button -->
            <button
              type="submit"
              phx-disable-with="Creating account..."
              class="w-full group inline-flex items-center justify-center px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105"
            >
              <.icon name="hero-user-plus" class="w-5 h-5 mr-2 group-hover:scale-110 transition-transform duration-200" />
              Create Your Account
            </button>
          </.form>

          <!-- Benefits List -->
          <div class="mt-8 pt-6 border-t border-gray-200">
            <h3 class="text-sm font-semibold text-gray-900 mb-3">What you'll get:</h3>
            <ul class="space-y-2">
              <li class="flex items-center text-sm text-gray-600">
                <.icon name="hero-check-circle" class="w-4 h-4 text-green-500 mr-2" />
                Daily mood tracking and insights
              </li>
              <li class="flex items-center text-sm text-gray-600">
                <.icon name="hero-check-circle" class="w-4 h-4 text-green-500 mr-2" />
                Personalized habit building tools
              </li>
              <li class="flex items-center text-sm text-gray-600">
                <.icon name="hero-check-circle" class="w-4 h-4 text-green-500 mr-2" />
                Access to community support
              </li>
              <li class="flex items-center text-sm text-gray-600">
                <.icon name="hero-check-circle" class="w-4 h-4 text-green-500 mr-2" />
                Complete privacy and data protection
              </li>
            </ul>
          </div>
        </div>

        <!-- Footer -->
        <div class="mt-8 text-center">
          <p class="text-xs text-gray-500">
            By creating an account, you agree to our
            <.link navigate="#" class="font-medium text-blue-600 hover:text-blue-700 ml-1">Terms of Service</.link>
            {" and "}
            <.link navigate="#" class="font-medium text-blue-600 hover:text-blue-700">Privacy Policy</.link>
          </p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: MindSanctuaryWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Your account has been created! Check your email for your login details including your auto-generated password."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
