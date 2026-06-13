defmodule Starter.Auth.SmartTokenEmail do
  def send_magic_link(to_email, magic_link) do
    Starter.Mailer.from()
    |> SendGrid.Email.add_to(to_email)
    |> SendGrid.Email.put_subject("Your Magic Link")
    |> SendGrid.Email.put_text("Click here to sign in: #{magic_link}\n\nThis link expires in 15 minutes.")
    |> SendGrid.Email.put_html("""
    <h2>Sign In</h2>
    <p>Click the button below to sign in:</p>
    <p><a href="#{magic_link}" style="display:inline-block;padding:12px 24px;background:#000;color:#fff;text-decoration:none;border-radius:4px;">Sign In</a></p>
    <p>Or copy this link: #{magic_link}</p>
    <p><em>This link expires in 15 minutes and can only be used once.</em></p>
    """)
    |> Starter.Mailer.send()
  end

  def send_otp_login(to_email, otp_code) do
    Starter.Mailer.from()
    |> SendGrid.Email.add_to(to_email)
    |> SendGrid.Email.put_subject("Your Login Code: #{otp_code}")
    |> SendGrid.Email.put_text("Your login code is: #{otp_code}\n\nThis code expires in 10 minutes.")
    |> SendGrid.Email.put_html("""
    <h2>Your Login Code</h2>
    <p style="font-size:32px;font-weight:bold;letter-spacing:8px;font-family:monospace;margin:24px 0;">#{otp_code}</p>
    <p>Enter this code to sign in.</p>
    <p><em>This code expires in 10 minutes and can only be used once.</em></p>
    """)
    |> Starter.Mailer.send()
  end

  def send_password_reset(to_email, otp_code) do
    Starter.Mailer.from()
    |> SendGrid.Email.add_to(to_email)
    |> SendGrid.Email.put_subject("Password Reset Code: #{otp_code}")
    |> SendGrid.Email.put_text("Your password reset code is: #{otp_code}\n\nThis code expires in 10 minutes.")
    |> SendGrid.Email.put_html("""
    <h2>Password Reset</h2>
    <p>Use this code to reset your password:</p>
    <p style="font-size:32px;font-weight:bold;letter-spacing:8px;font-family:monospace;margin:24px 0;">#{otp_code}</p>
    <p><em>This code expires in 10 minutes and can only be used once.</em></p>
    <p>If you didn't request this, you can safely ignore this email.</p>
    """)
    |> Starter.Mailer.send()
  end

  def send_verification_email(to_email, verification_link) do
    Starter.Mailer.from()
    |> SendGrid.Email.add_to(to_email)
    |> SendGrid.Email.put_subject("Verify Your Email")
    |> SendGrid.Email.put_text("Verify your email: #{verification_link}\n\nThis link expires in 24 hours.")
    |> SendGrid.Email.put_html("""
    <h2>Verify Your Email</h2>
    <p>Click the button below to verify your email address:</p>
    <p><a href="#{verification_link}" style="display:inline-block;padding:12px 24px;background:#000;color:#fff;text-decoration:none;border-radius:4px;">Verify Email</a></p>
    <p>Or copy this link: #{verification_link}</p>
    <p><em>This link expires in 24 hours and can only be used once.</em></p>
    """)
    |> Starter.Mailer.send()
  end
end
