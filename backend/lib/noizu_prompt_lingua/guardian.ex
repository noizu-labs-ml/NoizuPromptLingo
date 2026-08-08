defmodule NoizuPromptLingua.Guardian do
  use Guardian, otp_app: :noizu_prompt_lingua

  def subject_for_token(%NoizuPromptLingua.Users.Sessions.UserSession{} = session, _claims) do
    Noizu.EntityReference.Protocol.sref(session)
  end

  def subject_for_token(_, _) do
    {:error, :unhandled_resource}
  end

  def resource_from_claims(%{"sub" => "ref.user-session." <> _ = sref}) do
    Noizu.EntityReference.Protocol.entity(sref, Noizu.Context.system())
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
