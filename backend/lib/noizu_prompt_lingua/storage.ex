defmodule NoizuPromptLingua.Storage do
  @default_expiry 3600

  @moduledoc """
  S3 presigning / object helpers.

  Returns `{:ok, url}` on success and a typed error otherwise:
  `{:error, :storage_not_configured}` when object storage has no bucket or
  credentials configured (un-activated deploys — runtime.exs only populates the
  Storage slice when `S3_BUCKET` is set), or `{:error, {:storage, reason}}`
  when the presign call itself fails (e.g. ExAws AuthCache exit on missing
  creds — stage log c6320). Callers degrade to a 503, never a raw MatchError
  500.
  """

  def presigned_upload_url(key, content_type \\ "application/octet-stream") do
    config = config()

    presign(:put, config, key,
      expires_in: @default_expiry,
      headers: [{"content-type", content_type}]
    )
  end

  def presigned_download_url(key) do
    config = config()
    presign(:get, config, key, expires_in: @default_expiry)
  end

  def delete_object(key) do
    config = config()

    ExAws.S3.delete_object(config[:bucket], key)
    |> ExAws.request(config)
  end

  defp presign(op, config, key, opts) do
    if configured?(config) do
      do_presign(op, config, key, opts)
    else
      {:error, :storage_not_configured}
    end
  end

  defp do_presign(op, config, key, opts) do
    case ExAws.S3.presigned_url(
           ExAws.Config.new(:s3, config),
           op,
           config[:bucket],
           key,
           opts
         ) do
      {:ok, url} ->
        {:ok, url}

      {:error, reason} ->
        {:error, {:storage, reason}}
    end
  rescue
    e -> {:error, {:storage, Exception.message(e)}}
  catch
    :exit, reason -> {:error, {:storage, {:exit, reason}}}
  end

  defp configured?(config) do
    config[:bucket] not in [nil, ""] and
      config[:access_key_id] not in [nil, ""] and
      config[:secret_access_key] not in [nil, ""]
  end

  defp config do
    Application.get_env(:noizu_prompt_lingua, __MODULE__, [])
  end
end
