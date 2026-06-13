defmodule TheRobotWars.Workers.EmailWorker do
  use Oban.Worker, queue: :mailer, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "magic_link", "to" => to, "link" => link}}) do
    TheRobotWars.Auth.SmartTokenEmail.send_magic_link(to, link)
    :ok
  end

  def perform(%Oban.Job{args: %{"type" => "otp_login", "to" => to, "code" => code}}) do
    TheRobotWars.Auth.SmartTokenEmail.send_otp_login(to, code)
    :ok
  end

  def perform(%Oban.Job{args: %{"type" => "password_reset", "to" => to, "code" => code}}) do
    TheRobotWars.Auth.SmartTokenEmail.send_password_reset(to, code)
    :ok
  end

  def perform(%Oban.Job{args: %{"type" => "verification", "to" => to, "link" => link}}) do
    TheRobotWars.Auth.SmartTokenEmail.send_verification_email(to, link)
    :ok
  end

  def enqueue(type, to, extra) do
    args = Map.merge(%{"type" => type, "to" => to}, extra)
    %{"type" => type, "to" => to}
    |> Map.merge(extra)
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
