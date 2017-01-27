defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    #IO.puts("((((((((((((((((((((((()))))))))))))))))))))))")
    #IO.inspect(auth)
    user_params =
      %{token: auth.credentials.token,
      email: auth.info.email,
      provider: to_string(auth.provider)}

    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
     conn
     |> configure_session(drop: true)
     |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        #IO.puts(")))))))))))))))))))))))))))))))))")
        #IO.inspect(user)
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, reason} ->
        #IO.puts(")))))))))))))))))))))))))))))))))")
        #IO.inspect(reason)
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end

  end
end
