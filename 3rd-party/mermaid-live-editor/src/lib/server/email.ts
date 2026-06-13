import sgMail from '@sendgrid/mail';

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY ?? '';
const FROM_EMAIL = process.env.SENDGRID_FROM_EMAIL ?? 'noreply@noizu.com';
const FROM_NAME = process.env.SENDGRID_FROM_NAME ?? 'Mermaid Live Editor';

if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

interface SendEmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export async function sendEmail({ to, subject, html, text }: SendEmailOptions): Promise<void> {
  if (!SENDGRID_API_KEY) {
    console.warn(`[email] SendGrid not configured. Would send to=${to} subject="${subject}"`);
    console.warn(`[email] Set SENDGRID_API_KEY to enable outgoing mail.`);
    return;
  }

  await sgMail.send({
    from: { email: FROM_EMAIL, name: FROM_NAME },
    html,
    subject,
    text: text ?? html.replace(/<[^>]*>/g, ''),
    to
  });
}

export function verificationEmail(url: string): { subject: string; html: string } {
  return {
    html: `
			<div style="font-family: system-ui, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
				<h2 style="margin: 0 0 16px;">Verify your email</h2>
				<p>Click the button below to verify your email address.</p>
				<a href="${url}" style="display: inline-block; padding: 12px 24px; background: #6366f1; color: #fff; text-decoration: none; border-radius: 6px; margin: 16px 0;">
					Verify Email
				</a>
				<p style="color: #888; font-size: 13px;">Or copy this link: ${url}</p>
			</div>
		`,
    subject: 'Verify your email — Mermaid Live Editor'
  };
}

export function resetPasswordEmail(url: string): { subject: string; html: string } {
  return {
    html: `
			<div style="font-family: system-ui, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
				<h2 style="margin: 0 0 16px;">Reset your password</h2>
				<p>Someone requested a password reset for your account. If this wasn't you, ignore this email.</p>
				<a href="${url}" style="display: inline-block; padding: 12px 24px; background: #6366f1; color: #fff; text-decoration: none; border-radius: 6px; margin: 16px 0;">
					Reset Password
				</a>
				<p style="color: #888; font-size: 13px;">This link expires in 1 hour.</p>
				<p style="color: #888; font-size: 13px;">Or copy this link: ${url}</p>
			</div>
		`,
    subject: 'Reset your password — Mermaid Live Editor'
  };
}

export function magicLinkEmail(url: string): { subject: string; html: string } {
  return {
    html: `
			<div style="font-family: system-ui, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
				<h2 style="margin: 0 0 16px;">Sign in to Mermaid</h2>
				<p>Click the button below to sign in. No password needed.</p>
				<a href="${url}" style="display: inline-block; padding: 12px 24px; background: #6366f1; color: #fff; text-decoration: none; border-radius: 6px; margin: 16px 0;">
					Sign In
				</a>
				<p style="color: #888; font-size: 13px;">This link expires in 10 minutes.</p>
				<p style="color: #888; font-size: 13px;">Or copy this link: ${url}</p>
			</div>
		`,
    subject: 'Sign in to Mermaid Live Editor'
  };
}
