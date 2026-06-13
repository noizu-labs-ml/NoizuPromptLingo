defmodule Starter.Storage do
  @default_expiry 3600

  def presigned_upload_url(key, content_type \\ "application/octet-stream") do
    config = config()
    {:ok, url} = ExAws.S3.presigned_url(
      ExAws.Config.new(:s3, config),
      :put,
      config[:bucket],
      key,
      expires_in: @default_expiry,
      headers: [{"content-type", content_type}]
    )
    url
  end

  def presigned_download_url(key) do
    config = config()
    {:ok, url} = ExAws.S3.presigned_url(
      ExAws.Config.new(:s3, config),
      :get,
      config[:bucket],
      key,
      expires_in: @default_expiry
    )
    url
  end

  def delete_object(key) do
    config = config()
    ExAws.S3.delete_object(config[:bucket], key)
    |> ExAws.request(config)
  end

  defp config do
    Application.get_env(:starter, __MODULE__, [])
  end
end
